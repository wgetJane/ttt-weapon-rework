local SWEP = weapons.GetStored("weapon_zm_carry")

SWEP.DeploySpeed = 28 / 15

if CLIENT then

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

local localply, heldent

local heldr, heldg, heldb, helda = 1, 1, 1, 1

local PushRenderTarget, PopRenderTarget, SetWriteDepthToDestAlpha, Clear, GetBlend, SetBlend, GetColorModulation, SetColorModulation, PushFlashlightMode, PopFlashlightMode, SetMaterial, OverrideBlend, DrawScreenQuad =
	render.PushRenderTarget, render.PopRenderTarget, render.SetWriteDepthToDestAlpha, render.Clear, render.GetBlend, render.SetBlend, render.GetColorModulation, render.SetColorModulation, render.PushFlashlightMode, render.PopFlashlightMode, render.SetMaterial, render.OverrideBlend, render.DrawScreenQuad

hook.Add("PostDrawTranslucentRenderables", "tttwr_magneto_PostDrawTranslucentRenderables", function(depth, sky)
	if depth or sky then
		return
	end

	local ent = heldent

	if not IsValid(ent) then
		return
	end

	PushRenderTarget(tex)

	SetWriteDepthToDestAlpha(false)

	Clear(0, 0, 0, 0)

	local a, r, g, b = GetBlend(), GetColorModulation()
	SetBlend(helda)
	SetColorModulation(heldr, heldg, heldb)

	if ent.RenderOverride then
		ent:RenderOverride()
	else
		ent:DrawModel()
	end

	local ply = localply

	if not IsValid(ply) then
		ply = LocalPlayer()
		localply = ply
	end

	local flash = IsValid(ply) and ply:FlashlightIsOn()

	if flash then
		PushFlashlightMode(true)

		if ent.RenderOverride then
			ent:RenderOverride()
		else
			ent:DrawModel()
		end

		PopFlashlightMode()
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
end)

local lastadd, lastrem = 0, 0

net.Receive("tttwr_magneto", function()
	local curtime = net.ReadFloat()

	local b = net.ReadBool()

	local ent = b and net.ReadEntity()

	if b and curtime >= lastrem then
		lastadd = curtime

		lastrem = 0

		if IsValid(heldent) then
			heldent:SetNoDraw(false)
		end

		heldent = ent

		if IsValid(ent) then
			ent:SetNoDraw(true)

			local col = ent:GetColor()

			heldr, heldg, heldb, helda =
				col.r / 255, col.g / 255, col.b / 255, col.a / 255
		end
	elseif not b and curtime >= lastadd then
		lastrem = curtime

		lastadd = 0

		if IsValid(heldent) then
			heldent:SetNoDraw(false)
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

	if not ent:IsWeapon() then
		self._magnetoowner = owner

		net.Start("tttwr_magneto")
		net.WriteFloat(CurTime())
		net.WriteBool(true)
		net.WriteEntity(ent)
		net.Send(owner)
	end

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
