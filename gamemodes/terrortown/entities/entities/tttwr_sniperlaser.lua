if TTTWR_DISABLED then
	ENT.TTTWR_DISABLED = true

	return
end

AddCSLuaFile()

ENT.Type = "anim"

local extendbounds = Vector(0, 4, 4)

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetSolidFlags(FSOLID_NOT_SOLID)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)

	self:SetRenderMode(RENDERMODE_TRANSCOLOR)

	self.SetNextThink = self.ClientsideSniperLaser
		and self.SetNextClientThink or self.NextThink

	if SERVER then
		self.UpdateBoundsInterval = 0.1 -- try to save bandwidth
		self.NextUpdateBounds = 0
	end
end

function ENT:OnRemove()
	local ply = self:GetOwner()

	if IsValid(ply) then
		ply.SniperLaserEnt = nil
	end
end

function ENT:EnableLaser()
	if not self:GetNoDraw() then
		return
	end

	self:SetNoDraw(false)

	self:SetNextThink(CurTime())
end

function ENT:DisableLaser()
	if not self:GetNoDraw() then
		self:SetNoDraw(true)
	end

	self:SetNextThink(CurTime() + 2)

	return true
end

local tracedata = {
	endpos = Vector(),
	mask = MASK_SHOT,
	collisiongroup = COLLISION_GROUP_NONE,
	ignoreworld = false,
	output = {},
}

local TEX_GLASS = util.GetSurfaceIndex("glass")

local function GetTrace(ply)
	local td = tracedata

	local vec = td.endpos

	td.filter = ply

	local shootpos, aimvec = ply:GetShootPos(), ply:GetAimVector()

	td.start = shootpos

	for i = 1, 3 do
		vec[i] = shootpos[i] + aimvec[i] * 32768
	end

	local tr, filter

	while true do
		tr = util.TraceLine(td)

		if tr.SurfaceProps ~= TEX_GLASS then
			break
		end

		local ent = tr.Entity

		if IsValid(ent)
			and ent:GetClass() == "func_breakable"
			and not ent:HasSpawnFlags(2048)
		then
			filter = filter or {ply}

			filter[#filter + 1] = ent

			td.filter = filter
		else
			break
		end
	end

	return tr
end

function ENT:Think()
	if self:GetNoDraw() then
		return
	end

	local ply = self:GetOwner()

	if CLIENT and not self.ClientsideSniperLaser then
		if IsValid(ply) then
			local vec = tracedata.endpos

			vec:SetUnpacked(
				-(self:GetPos():Distance(ply:GetShootPos())),
				-4, -4
			)

			self:SetRenderBounds(vec, extendbounds, extendbounds)
		end

		return
	end

	if not (
		IsValid(ply)
		and ply.IsTerror
		and ply:IsTerror()
	) then
		self:Remove()

		return
	end

	local wep = ply:GetActiveWeapon()

	if not (
		IsValid(wep)
		and wep.GetSniperCharge
		and wep:GetSniperCharge() > 100
	) then
		return self:DisableLaser()
	end

	local tr = GetTrace(ply)

	local vec = tracedata.endpos

	vec:SetUnpacked(tr.Fraction * -32768, -4, -4)

	local curtime = CurTime()

	if SERVER and curtime > self.NextUpdateBounds then
		local curt = self.NextUpdateBounds
		local diff = curtime - curt

		if diff > 0.1 or diff < 0 then
			curt = curtime
		end

		self.NextUpdateBounds = curt + self.UpdateBoundsInterval

		self:SetCollisionBounds(vec, extendbounds)
	end

	if CLIENT then
		self:SetCollisionBounds(vec, extendbounds)

		self:SetRenderBounds(vec, extendbounds, extendbounds)

		self:SetPos(tr.StartPos)
	else
		vec:Set(tr.HitPos)
		vec:Sub(ply:GetPos())

		self:SetLocalPos(vec)
	end

	self:SetLocalAngles(tr.Normal:Angle())

	self:SetNextThink(curtime)

	return true
end

if SERVER then
	return
end

local remap, random = TTTWR.RemapClamp, math.random

local beam = Material("cable/redlaser")
local dot = Material("sprites/redglow_mp1")

local SetMaterial, DepthRange, DrawBeam, DrawSprite =
	render.SetMaterial, render.DepthRange, render.DrawBeam, render.DrawSprite

function ENT:Draw()
	local ply = self:GetOwner()

	if not IsValid(ply) then
		return
	end

	local wep = ply:GetActiveWeapon()

	if not (
		IsValid(wep)
		and wep.GetSniperCharge
		and wep:GetSniperCharge() > 100
	) then
		return
	end

	local tr, startpos, endpos

	local islocalply = wep:IsCarriedByLocalPlayer()

	if islocalply then
		tr = GetTrace(ply)

		endpos = tr.HitPos
	end

	if islocalply and not ply:ShouldDrawLocalPlayer() then
		tr = tr or GetTrace(ply)

		local vm = not wep:GetIronsights() and ply:GetViewModel()
		local att = vm and IsValid(vm) and vm:GetAttachment(1)

		startpos = att and att.Pos

		if not startpos then
			startpos = tr.Normal:Cross(vector_up)
			startpos[3] = startpos[3] - 5
			startpos:Add(tr.StartPos)
		end

		DepthRange(0, 0.001)
	else
		local att = wep:GetAttachment(1)

		startpos = att and att.Pos
	end

	startpos = startpos or ply:GetShootPos()
	endpos = endpos or self:GetPos()

	SetMaterial(beam)

	local size = remap(wep:GetSniperCharge(), 100, 1000, 0, 2 + random())

	DrawBeam(startpos, endpos, size, 0, 0)

	SetMaterial(dot)

	size = size + 1.5

	DrawSprite(endpos, size, size)

	DepthRange(0, 1)
end
