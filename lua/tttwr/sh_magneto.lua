local SWEP = weapons.GetStored("weapon_zm_carry")

SWEP.DeploySpeed = 28 / 15

if CLIENT then

local ttt_magnetotrans = CreateConVar("ttt_magnetotrans", "1", FCVAR_ARCHIVE)

local tex = GetRenderTargetEx(
	"tttwr_magneto_tex",
	0, 0,
	RT_SIZE_FULL_FRAME_BUFFER,
	MATERIAL_RT_DEPTH_SHARED,
	0x8000, --TEXTUREFLAGS_RENDERTARGET
	CREATERENDERTARGETFLAGS_HDR,
	IMAGE_FORMAT_DEFAULT
)

local mat = CreateMaterial("tttwr_magneto_mat", "UnlitGeneric", {
	["$basetexture"] = tex:GetName(),
	["$color"] = "0.65, 0.65, 0.65",
	["$alpha"] = 0.65,
})

local heldent

local heldr, heldg, heldb, helda = 1, 1, 1, 1

local PushRenderTarget, PopRenderTarget, OverrideAlphaWriteEnable, SetWriteDepthToDestAlpha, Clear, GetBlend, SetBlend, GetColorModulation, SetColorModulation, SetMaterial, OverrideBlend, DrawScreenQuad =
	render.PushRenderTarget, render.PopRenderTarget, render.OverrideAlphaWriteEnable, render.SetWriteDepthToDestAlpha, render.Clear, render.GetBlend, render.SetBlend, render.GetColorModulation, render.SetColorModulation, render.SetMaterial, render.OverrideBlend, render.DrawScreenQuad

local _RenderOverride, flags, alphatest

local function checkmat(name)
	if name == "" then
		return
	end

	local mat = Material(name)

	if not mat or mat:IsError() then
		return
	end

	return bit.band(mat:GetInt("$flags") or 0, 256) == 256
end

hook.Add("PreDrawEffects", "tttwr_magneto_PreDrawEffects", function()
	local ent = heldent

	if not IsValid(ent) then
		return
	end

	if alphatest == nil then
		alphatest = false

		if checkmat(ent:GetMaterial()) then
			alphatest = true

			goto done
		end

		local mats = ent:GetMaterials()

		for i = 1, #mats do
			if checkmat(mats[i]) then
				alphatest = true

				goto done
			end
		end

		::done::
	end

	local redraw = alphatest

	PushRenderTarget(tex)

	if redraw then
		OverrideAlphaWriteEnable(true, true)

		OverrideBlend(
			true,
			BLEND_ONE_MINUS_DST_ALPHA,
			BLEND_DST_ALPHA,
			BLENDFUNC_ADD
		)
	end

	SetWriteDepthToDestAlpha(false)

	Clear(0, 0, 0, 0)

	local a, r, g, b = GetBlend(), GetColorModulation()
	SetBlend(helda)
	SetColorModulation(heldr, heldg, heldb)

	::redraw::

	if _RenderOverride then
		_RenderOverride(ent, flags)
	else
		ent:DrawModel(flags)
	end

	if redraw then
		redraw = nil

		OverrideAlphaWriteEnable(false)

		OverrideBlend(false)

		goto redraw
	end

	SetColorModulation(r, g, b)
	SetBlend(a)

	SetWriteDepthToDestAlpha(true)

	PopRenderTarget()

	SetMaterial(mat)

	OverrideBlend(
		true,
		BLEND_ONE,
		BLEND_ONE_MINUS_SRC_ALPHA,
		BLENDFUNC_ADD
	)

	DrawScreenQuad()

	OverrideBlend(false)

	flags = nil
end)

local GetRenderTarget = render.GetRenderTarget

local function RenderOverride(self, f)
	if not GetRenderTarget() then
		flags = flags or f
	elseif _RenderOverride then
		return _RenderOverride(self, f)
	else
		return self:DrawModel(f)
	end
end

local lastadd, lastrem = 0, 0

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

		if IsValid(ent) and ttt_magnetotrans:GetBool() then
			_RenderOverride = ent.RenderOverride
			ent.RenderOverride = RenderOverride

			heldent = ent

			local col = ent:GetColor()

			heldr, heldg, heldb, helda =
				col.r / 255, col.g / 255, col.b / 255, col.a / 255
		end
	elseif not b and curtime >= lastadd then
		lastrem = curtime

		lastadd = 0

		if IsValid(heldent) then
			heldent.RenderOverride = _RenderOverride
			_RenderOverride = nil
		end

		heldent, alphatest = nil, nil
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
				avel:Mul(mult - 1)

				phys:SetVelocity(vel)
				phys:AddAngleVelocity(avel)
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
