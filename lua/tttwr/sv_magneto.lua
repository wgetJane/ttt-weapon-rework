local SWEP = weapons.GetStored("weapon_zm_carry")

SWEP.DeploySpeed = 28 / 15

local ttt_magneto_hpstation = CreateConVar("ttt_magneto_hpstation", 1, FCVAR_ARCHIVE)

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
		local allow = ttt_magneto_hpstation:GetInt()

		if allow == 1 then
			return owner:GetDetective()
		else
			return allow == 2
		end
	end

	return AllowPickup(self, target)
end

local ttt_magneto_lagcomp = CreateConVar("ttt_magneto_lagcomp", 1, FCVAR_ARCHIVE)

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

	if ttt_magneto_lagcomp:GetBool() and not ent:IsLagCompensated() then
		local tname = "tttwr_magneto_lagcomp " .. ent:EntIndex()

		self.HoldingLagCompensated = tname

		timer.Remove(tname)

		ent:SetLagCompensated(true)
	end
end

local Reset = TTTWR.getfn(SWEP, "Reset")

function SWEP:Reset()
	local ent = self.EntHolding

	local tname = self.HoldingLagCompensated

	if tname and IsValid(ent) then
		timer.Create(tname, 10, 1, function()
			if IsValid(ent) then
				ent:SetLagCompensated(false)
			end

			timer.Remove(tname)
		end)
	end

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
