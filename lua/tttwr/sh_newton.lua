local SWEP = weapons.GetStored("weapon_ttt_push")

function SWEP:PrimaryAttack()
	local nxt = CurTime() + self.Primary.Delay

	self:SetNextPrimaryFire(nxt)
	self:SetNextSecondaryFire(nxt)

	self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	local owner = self:GetOwner()

	if IsValid(owner) then
		owner:SetAnimation(PLAYER_ATTACK1)
	end

	self:FirePulse(false)
end

function SWEP:SecondaryAttack()
	local nxt = CurTime() + self.Primary.Delay

	self:SetNextPrimaryFire(nxt)
	self:SetNextSecondaryFire(nxt)

	self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	local owner = self:GetOwner()

	if IsValid(owner) then
		owner:SetAnimation(PLAYER_ATTACK1)
	end

	self:FirePulse(true)
end

local bullet = TTTWR.SharedBullet

local bulletCallback, pull

function SWEP:FirePulse(p)
	local owner = self:GetOwner()

	if not IsValid(owner) then
		return
	end

	local bul = bullet

	bul.Attacker = owner

	bul.Damage = 1
	bul.Force = 60

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

	pull = p

	bul.Callback = bulletCallback

	return owner:FireBullets(bul)
end

function SWEP:Think()
	if self:GetActivity() ~= ACT_VM_IDLE then
		local owner = self:GetOwner()

		if IsValid(owner) then
			local vm = owner:GetViewModel()

			if IsValid(vm) and vm:IsSequenceFinished() then
				self:SendWeaponAnim(ACT_VM_IDLE)
			end
		end
	end

	return self.BaseClass.Think(self)
end

SWEP.SetupDataTables = nil
SWEP.ChargedAttack = nil
SWEP.PreDrop = nil
SWEP.OnRemove = nil
SWEP.Deploy = nil
SWEP.Holster = nil

local max = math.max

if CLIENT then

local Initialize = TTTWR.getfn(SWEP, "Initialize")

function SWEP:Initialize()
	self:AddHUDHelp("newton_help_pri", "newton_help_sec", true)

	return Initialize(self)
end

local localply

local SetDrawColor, DrawLine = surface.SetDrawColor, surface.DrawLine

function SWEP:DrawHUD()
	if self.HUDHelp then
		self:DrawHelp()
	end

	local ply = localply

	if not IsValid(ply) then
		ply = LocalPlayer()
		localply = ply
	end

	if IsValid(ply) and ply.IsTraitor and ply:IsTraitor() then
		SetDrawColor(255, 0, 0, 255)
	else
		SetDrawColor(0, 255, 0, 255)
	end

	local x, y = ScrW() * 0.5, ScrH() * 0.5

	DrawLine(x - 10, y, x - 5, y)
	DrawLine(x + 10, y, x + 5, y)
	DrawLine(x, y - 10, x, y - 5)
	DrawLine(x, y + 10, x, y + 5)

	local curtime = CurTime()

	local nxt = self:GetNextPrimaryFire()

	if nxt < curtime then
		return
	end

	local w, h = 30, 20 * max(0, nxt - curtime) / self.Primary.Delay

	DrawLine(x + w, y - h, x + w, y + h)
	DrawLine(x - w, y - h, x - w, y + h)
end

	return
end

local vec = Vector()

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
		vec[i] = trace.Normal[i] * (pull and -100 or 90)
	end

	local curtime = CurTime()

	local waspushed = victim.was_pushed
	local same = waspushed and victim.was_pushed.t == curtime

	if same and waspushed.wasonground then
		vec[3] = max(vec[3], pull and 40 or 50)
	end

	local onground = victim:OnGround()

	if onground then
		victim:SetGroundEntity(nil)
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

	if pull then
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
