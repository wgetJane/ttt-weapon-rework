local SWEP = weapons.GetStored("weapon_ttt_push")

SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = true

function SWEP:PrimaryAttack()
	self.IsCharging = 1
end

function SWEP:SecondaryAttack()
	self.IsCharging = -1
end

function SWEP:ChargedAttack()
	local force = self.IsCharging

	self.IsCharging = false

	local charge = math.Clamp(self:GetCharge(), 0, 1)

	self:SetCharge(0)

	if charge ~= 0 then
		self:FirePulse(force * (charge + 1))
	end
end

local bullet = TTTWR.SharedBullet

local bulletCallback, pforce

function SWEP:FirePulse(force)
	local owner = self:GetOwner()

	if not IsValid(owner) then
		return
	end

	local nxt = CurTime() + self.Primary.Delay

	self:SetNextPrimaryFire(nxt)
	self:SetNextSecondaryFire(nxt)

	self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	owner:SetAnimation(PLAYER_ATTACK1)

	local bul = bullet

	bul.Attacker = owner

	bul.Damage = 0.01
	bul.Force = 60 * math.abs(force)

	bul.Distance = 8192
	bul.HullSize = nil

	bul.Num = 6

	bul.Src = owner:GetShootPos()
	bul.Dir = owner:GetAimVector()

	bul.Spread[1], bul.Spread[2] = self.Primary.Cone, self.Primary.Cone

	bul.Tracer = 1
	bul.TracerName = "AirboatGunHeavyTracer"

	bul.AmmoType = nil

	bul.IgnoreEntity = nil

	pforce = force

	bul.Callback = bulletCallback

	return owner:FireBullets(bul)
end

function SWEP:Think()
	self.BaseClass.Think(self)

	local owner = self:GetOwner()

	if not IsValid(owner) then
		return
	end

	if self:GetActivity() ~= ACT_VM_IDLE then
		local vm = owner:GetViewModel()

		if IsValid(vm) and vm:IsSequenceFinished() then
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end

	if not (self.IsCharging and owner:IsTerror()) then
		return
	end

	if not (owner:KeyDown(IN_ATTACK) or owner:KeyDown(IN_ATTACK2)) then
		self:ChargedAttack()

		return
	end

	local charge = self:GetCharge()

	if charge == 1 then
		return
	end

	self:SetCharge(math.Clamp(charge + 0.5 * FrameTime(), 0, 1))
end

if CLIENT then

local Initialize = TTTWR.getfn(SWEP, "Initialize")

function SWEP:Initialize()
	self:AddHUDHelp("newton_help_pri", "newton_help_sec", true)

	return Initialize(self)
end

local DrawHUD = TTTWR.getfn(SWEP, "DrawHUD")

function SWEP:DrawHUD()
	if self.HUDHelp then
		self:DrawHelp()
	end

	return DrawHUD(self)
end

	return
end

local vec = Vector()

local max = math.max

function bulletCallback(attacker, trace)
	local victim = trace.Entity

	if not (
		IsValid(victim)
		and victim:IsPlayer()
		and not victim:IsFrozen()
	) then
		return
	end

	local vec = vec
	for i = 1, 3 do
		vec[i] = trace.Normal[i] * 100 * pforce
	end

	local curtime = CurTime()

	local waspushed = victim.was_pushed
	local same = waspushed and victim.was_pushed.t == curtime

	if same and waspushed.wasonground then
		vec[3] = max(vec[3], 50)
	end

	local onground = victim:OnGround()

	if onground then
		victim:SetGroundEntity(nil)
	end

	if not same then
		victim:SetLocalVelocity(vector_origin) -- cancel out current velocity
	end

	local vel = victim:GetAbsVelocity()
	vel:Add(vec)

	victim:SetLocalVelocity(vel)

	if same then
		return
	end

	victim.was_pushed = {
		att = attacker,
		t = curtime,
		wep = "weapon_ttt_push",
		wasonground = onground,
	}
end

function SWEP:OnEntityTakeDamage(victim, dmginfo)
	local owner = self:GetOwner()

	if not IsValid(owner) then
		return
	end

	if pforce < 0 then
		local force = dmginfo:GetDamageForce()

		force:Mul(-1 / 3)

		dmginfo:SetDamageForce(force)
	end

	local phys = victim:GetPhysicsObject()

	if not (IsValid(phys) and phys:IsMoveable()) then
		return
	end

	victim:SetPhysicsAttacker(owner)
end
