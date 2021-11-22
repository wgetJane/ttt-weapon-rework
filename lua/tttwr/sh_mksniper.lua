local SWEP = {}

SWEP.AmmoEnt = "item_ammo_357_ttt"

SWEP.Primary = {
	ClipMax = 20,
	Ammo = "357",
}

SWEP.HeadshotMultiplier = 2
SWEP.LimbshotMultiplier = 0.5

SWEP.FalloffMult = false
SWEP.ConeResetMult = false

SWEP.ReloadTime = 3.5

SWEP.BulletDistance = 16384
SWEP.BulletTracer = 1

function TTTWR:MakeSniper(class, model, sound, dmg, ...)
	TTTWR.MakeWeapon(self, class, sound, dmg, ...)

	TTTWR.MakeZoomable(self)

	TTTWR.CopySWEP(self, SWEP)

	self.BulletForce = dmg * 0.5

	self.ViewModel = "models/weapons/cstrike/c_snip_" .. model .. ".mdl"
	self.WorldModel = "models/weapons/w_snip_" .. model .. ".mdl"
end

if SERVER then
	return
end

local snipers = setmetatable({}, TTTWR.weakkeys) -- pairs() is slow, should this be a linked list instead?
local empty = true

local tracedata = {
	endpos = Vector(),
	mask = MASK_SHOT,
	collisiongroup = COLLISION_GROUP_NONE,
	ignoreworld = false,
	output = {},
}

local remap, random = TTTWR.RemapClamp, math.random

local col = Color(255, 255, 255)

local dot = Material("sprites/redglow_mp1")

local GetColorModulation, SetColorModulation, GetBlend, SetBlend, SetMaterial, DepthRange, DrawSprite =
	render.GetColorModulation, render.SetColorModulation, render.GetBlend, render.SetBlend, render.SetMaterial, render.DepthRange, render.DrawSprite

local function PostDrawTranslucentRenderables(depth, sky)
	if depth or sky or empty then
		return
	end

	local setempty = true

	local IsValid = IsValid

	local td = tracedata

	local vec = td.endpos

	local TraceLine = util.TraceLine

	local col = col

	local eyepos = EyePos()

	local r, g, b = GetColorModulation()
	SetColorModulation(1, 1, 1)

	local blend = GetBlend()
	SetBlend(1)

	SetMaterial(dot)

	for ent in pairs(snipers) do
		local owner = IsValid(ent) and ent:GetOwner()

		if not (
			owner
			and IsValid(owner)
			and ent == owner:GetActiveWeapon()
		) then
			snipers[ent] = nil

			goto cont
		end

		setempty = false

		td.filter = owner

		local shootpos, aimvec = owner:GetShootPos(), owner:GetAimVector()

		td.start = shootpos

		for i = 1, 3 do
			vec[i] = shootpos[i] + aimvec[i] * 16384
		end

		local tr = TraceLine(td)

		if tr.HitSky or tr.HitNoDraw or not tr.Hit then
			goto cont
		end

		local size = remap(tr.Fraction, 0, 0.25, 2, 10)

		local offset = -remap(size, 2, 10, 0.25, 4)

		local isworld = not IsValid(tr.Entity)
		local isplayer = not isworld and tr.Entity:IsPlayer()

		if isplayer and tr.HitGroup == HITGROUP_CHEST then
			offset = offset - 1
		end

		for i = 1, 3 do
			vec[i] = tr.HitPos[i] + aimvec[i] * offset
		end

		size = size * (0.875 + random() * 0.25)

		if eyepos:DistToSqr(tr.HitPos) > eyepos:DistToSqr(vec) then
			-- this is needed because bits of playermodels stick out of their hitboxes
			-- like pouches, vests, etc that would obscure the laser dot
			DepthRange(
				0,
				isworld and 0.9999
				or isplayer and 0.996
				or 0.999
			)
		end

		DrawSprite(vec, size, size, col)

		DepthRange(0, 1)

		::cont::
	end

	SetBlend(blend)

	SetColorModulation(r, g, b)

	if setempty then
		empty = true
	end
end

local function OnIronsightsChanged(self, name, old, new)
	if new then
		snipers[self] = true

		empty = false
	else
		snipers[self] = nil
	end
end

function SWEP:PostSetupDataTables()
	return self:NetworkVarNotify("IronsightsPredicted", OnIronsightsChanged)
end

return function()
	hook.Add("PostDrawTranslucentRenderables", "tttwr_mksniper_PostDrawTranslucentRenderables", PostDrawTranslucentRenderables)
end
