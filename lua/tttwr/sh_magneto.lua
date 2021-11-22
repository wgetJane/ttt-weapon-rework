local SWEP = weapons.GetStored("weapon_zm_carry")

SWEP.DeploySpeed = 28 / 15

if CLIENT then

local ttt_magnetotrans = CreateConVar("ttt_magnetotrans", "1", FCVAR_ARCHIVE)

local tex = GetRenderTargetEx(
	"tttwr_magneto_tex",
	0, 0,
	RT_SIZE_FULL_FRAME_BUFFER,
	MATERIAL_RT_DEPTH_NONE,
	0x8000, --TEXTUREFLAGS_RENDERTARGET
	CREATERENDERTARGETFLAGS_HDR,
	IMAGE_FORMAT_DEFAULT
)

local mat = CreateMaterial("tttwr_magneto_matasdf", "UnlitGeneric", {
	["$basetexture"] = tex:GetName(),
	["$alpha"] = 0.5,
})

local _RenderOverride, heldrm

local GetRenderTarget, CopyRenderTargetToTexture, SetMaterial, DrawScreenQuad =
	render.GetRenderTarget, render.CopyRenderTargetToTexture, render.SetMaterial, render.DrawScreenQuad

local function RenderOverride(self, f)
	if not GetRenderTarget() then
		CopyRenderTargetToTexture(tex)

		if _RenderOverride then
			_RenderOverride(self, f)
		else
			self:DrawModel(f)
		end

		SetMaterial(mat)

		DrawScreenQuad()
	elseif _RenderOverride then
		return _RenderOverride(self, f)
	else
		return self:DrawModel(f)
	end
end

local lastadd, lastrem, heldent = 0, 0

net.Receive("tttwr_magneto", function()
	local curtime = net.ReadFloat()

	local b = net.ReadBool()

	local ent = b and net.ReadEntity()

	if b and curtime >= lastrem then
		lastadd = curtime

		lastrem = 0

		if IsValid(heldent) then
			heldent.RenderOverride = _RenderOverride
			_RenderOverride = nil
		end

		heldent = nil

		if not (
			ttt_magnetotrans:GetBool()
			and IsValid(ent)
			and ent:GetBrushPlaneCount() == 0 -- ignore func_physbox
		) then
			return
		end

		heldrm = ent:GetRenderMode()

		if heldrm == RENDERMODE_NORMAL then
			ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
		end

		_RenderOverride = ent.RenderOverride
		ent.RenderOverride = RenderOverride

		heldent = ent
	elseif not b and curtime >= lastadd then
		lastrem = curtime

		lastadd = 0

		if IsValid(heldent) then
			if heldrm == RENDERMODE_NORMAL
				and heldent:GetRenderMode() == RENDERMODE_TRANSCOLOR
			then
				heldent:SetRenderMode(heldrm)
			end

			heldent.RenderOverride = _RenderOverride
			_RenderOverride = nil
		end

		heldent = nil
	end
end)

	return
end

util.AddNetworkString("tttwr_magneto")

local AllowPickup = TTTWR.getfn(SWEP, "AllowPickup")

function SWEP:AllowPickup(target)
	local owner = self:GetOwner()

	if IsValid(owner)
		and IsValid(target)
		and target.IsHealthStation
		and target.CanPickup ~= false
		and IsValid(target:GetPhysicsObject())
	then
		return owner:GetDetective()
	end

	return AllowPickup(self, target)
end

local Pickup = TTTWR.getfn(SWEP, "Pickup")

function SWEP:Pickup()
	local owner = self:GetOwner()

	if not IsValid(owner) then
		return
	end

	Pickup(self)

	if not IsValid(self.CarryHack) then
		return
	end

	local ent = self.EntHolding

	self._magnetoowner = owner

	net.Start("tttwr_magneto")
	net.WriteFloat(CurTime())
	net.WriteBool(true)
	net.WriteEntity(ent)
	net.Send(owner)

	if ent.MagnetoPickUpMass then
		ent:GetPhysicsObject():SetMass(ent.MagnetoPickUpMass)
	end
end

local Reset = TTTWR.getfn(SWEP, "Reset")

function SWEP:Reset()
	local ent = self.EntHolding
	local phys = IsValid(ent)
		and ent:GetPhysicsObject()
		or nil

	if IsValid(phys) then
		if IsValid(self._magnetoowner) then
			net.Start("tttwr_magneto")
			net.WriteFloat(CurTime())
			net.WriteBool(false)
			net.Send(self._magnetoowner)
		end

		self._magnetoowner = nil

		if ent.MagnetoDropMass then
			phys:SetMass(ent.MagnetoDropMass)
		end

		local mult = ent.MagnetoDropVelocityMult
		if mult then
			timer.Simple(0, function()
				if not IsValid(phys) then
					return
				end

				local vel = phys:GetVelocity()
				local avel = phys:GetAngleVelocity()

				vel:Mul(mult)
				avel:Mul(mult)

				phys:SetVelocityInstantaneous(vel)
				phys:SetAngleVelocityInstantaneous(avel)
			end)
		end
	end

	return Reset(self)
end

local ENT = scripted_ents.GetStored("ttt_health_station").t

ENT.IsHealthStation = true
ENT.MagnetoPickUpMass = 20
ENT.MagnetoDropMass = 200
ENT.MagnetoDropVelocityMult = 0.2
