local SWEP = {}

SWEP.HoldType = "shotgun"

SWEP.AmmoEnt = "item_box_buckshot_ttt"

SWEP.Primary = {
	ClipMax = 24,
	Ammo = "Buckshot",
}

SWEP.NoSetInsertingOnReload = true

SWEP.NoLuckyHeadshots = false

SWEP.HeadshotMultiplier = 2.4
SWEP.LimbshotMultiplier = 0.9

SWEP.FalloffEnd = 768

SWEP.ConeResetStart = false

SWEP.BulletDistance = 4096

SWEP.ShotgunNumShots = 8
SWEP.ShotgunSpread = 0.001

SWEP.ReloadTime = 0.5
SWEP.ReloadTimeConsecutive = 0.5
SWEP.ReloadTimeFinish = 0.5

SWEP.ReloadAnim = ACT_SHOTGUN_RELOAD_START

SWEP.DryFireSound = "weapons/shotgun/shotgun_empty.wav"

SWEP.DoNotStoreLastPrimaryFire = true

function TTTWR:MakeShotgun(class, model, ...)
	TTTWR.MakeWeapon(self, class, ...)

	TTTWR.CopySWEP(self, SWEP)

	self.spawnType = WEAPON_TYPE_SHOTGUN

	self.ViewModel = "models/weapons/cstrike/c_shot_" .. model .. ".mdl"
	self.WorldModel = "models/weapons/w_shot_" .. model .. ".mdl"
end

function SWEP:OnThink()
	if self.ShotgunThink then
		self:ShotgunThink()
	end

	local reloading = self:GetReloading()

	if reloading <= 0 then
		return true
	end

	local curtime = CurTime()

	local owner = self:GetOwner()
	if not IsValid(owner) then
		owner = nil
	end

	local clip = self:Clip1()

	local reserve = owner
		and owner.GetAmmoCount
		and owner:GetAmmoCount(self.Primary.Ammo)
		or self.Primary.ClipMax

	if self:GetInserting()
		and curtime > reloading - self.ReloadTime * (2 / 3)
	then
		self:SetInserting(false)

		if clip < self.Primary.ClipSize
			and reserve > 0
		then
			if owner and owner.RemoveAmmo then
				reserve = reserve - 1
				owner:SetAmmo(reserve, self.Primary.Ammo)
			end

			clip = clip + 1
			self:SetClip1(clip)
		end

		if self.OnInsertClip then
			self:OnInsertClip()
		end
	end

	local fin
	::fin::

	if fin or (
		owner
		and clip > 0
		and owner.KeyDown
		and owner:KeyDown(IN_ATTACK)
	) then
		self:SetReloading(0)
		self:SetInserting(false)

		if self.ShotgunFinishReloadAnim then
			self:ShotgunFinishReloadAnim()
		else
			self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
		end

		local nextfire = curtime + self.ReloadTimeFinish

		self:SetNextPrimaryFire(nextfire)
		self:SetNextSecondaryFire(nextfire)

		return true
	end

	if curtime <= reloading then
		return true
	end

	if clip >= self.Primary.ClipSize
		or reserve <= 0
	then
		fin = true
		goto fin
	end

	local relfin = curtime + self.ReloadTimeConsecutive

	self:SetReloading(relfin)

	self:SetNextPrimaryFire(relfin)
	self:SetNextSecondaryFire(relfin)

	self:SendWeaponAnim(ACT_VM_RELOAD)

	if owner and self.ReloadAnimSpeedConsecutive then
		self:SetVMSpeed(self.ReloadAnimSpeedConsecutive, owner)
	end

	self:SetInserting(true)

	return true
end

local hitents = setmetatable({}, TTTWR.weakkeys)
local dirs = {0,0,0,0,0,0,0,0,0} -- forward, right, and up normals
local numshots

local bullet = TTTWR.SharedBullet

local sin, cos = math.sin, math.cos

local function bulletCallback(attacker, trace, dmginfo)
	if (CLIENT and not IsFirstTimePredicted())
		or not IsValid(attacker)
	then
		return
	end

	local wep = util.WeaponFromDamage(dmginfo)

	if not IsValid(wep) then
		return
	end

	if SERVER and IsValid(trace.Entity) then
		local victim = trace.Entity

		hitents[victim] = (hitents[victim] or 0) + 1
	end

	numshots = numshots - 1

	local count, shots = numshots, wep.ShotgunNumShots

	-- fixed pattern
	local rad = (6.2831853071796 / (shots - 1)) * count
	local s, c = sin(rad), cos(rad)

	-- normal distribution
	local x = wep:GetRandomFloat(
			-0.5, 0.5, count
		) + wep:GetRandomFloat(
			-0.5, 0.5, count - shots
		)
	local y = wep:GetRandomFloat(
			-0.5, 0.5, count + shots * 2
		) + wep:GetRandomFloat(
			-0.5, 0.5, count - shots * 2
		)

	local cone = wep:GetPrimaryCone() * 0.4
	local acc = wep.ShotgunSpread * (wep:GetIronsights() and 0.85 or 1)

	local bul = bullet

	local d = dirs

	for i = 1, 3 do
		bul.Dir[i] = d[i]
			+ d[i + 3] * s * cone
			+ d[i + 6] * c * cone
			+ d[i + 3] * x * acc
			+ d[i + 6] * y * acc
	end

	bul.Spread[1], bul.Spread[2] = 0, 0

	if numshots > 0 then
		return attacker:FireBullets(bul)
	end
end

local multidmg, multiforce

function SWEP:PreFireBullet(owner, bul)
	local d = dirs

	d[1], d[2], d[3] = bul.Dir[1], bul.Dir[2], bul.Dir[3]

	local r = 1 / (d[1] * d[1] + d[2] * d[2]) ^ 0.5

	d[4], d[5], d[6] = d[2] * r, -d[1] * r, 0

	d[7], d[8], d[9] = d[5] * d[3], -d[4] * d[3], d[4] * d[2] - d[5] * d[1]

	r = 1 / (d[7] * d[7] + d[8] * d[8] + d[9] * d[9]) ^ 0.5

	d[7], d[8], d[9] = d[7] * r, d[8] * r, d[9] * r

	numshots = self.ShotgunNumShots

	local acc = self.ShotgunSpread * (self:GetIronsights() and 0.85 or 1)
	bul.Spread[1], bul.Spread[2] = acc, acc

	bul.Callback = bulletCallback

	for k in pairs(hitents) do
		hitents[k] = nil
	end

	if SERVER then
		for k in pairs(multidmg) do
			multidmg[k] = nil
		end
		for k in pairs(multiforce) do
			multiforce[k] = nil
		end
	end
end

if CLIENT then
	return
end

multidmg, multiforce =
	setmetatable({}, TTTWR.weakkeys),
	setmetatable({}, TTTWR.weakkeys)

local abs = math.abs

function SWEP:OnEntityTakeDamage(victim, dmginfo)
	local hent = hitents[victim]

	if not hent then
		return
	end

	local mdmg, mfrc = multidmg[victim], multiforce[victim]

	if hent > 1 then
		hitents[victim] = hent - 1

		multidmg[victim] = (mdmg or 0) + dmginfo:GetDamage()

		local frc = dmginfo:GetDamageForce()

		if mfrc then
			mfrc:Add(frc)
		else
			multiforce[victim] = frc
		end

		return true
	end

	hitents[victim] = nil

	if mdmg then
		dmginfo:AddDamage(mdmg)
		multidmg[victim] = nil
	end

	if mfrc then
		mfrc:Add(dmginfo:GetDamageForce())
		multiforce[victim] = nil

		if victim:IsPlayer() and victim:OnGround() then
			victim:SetGroundEntity(nil) -- probably should do this elsewhere

			if dmginfo:GetDamage() > 32 then
				victim.was_pushed = {
					att = dmginfo:GetAttacker(),
					t = CurTime(),
					wep = self:GetClass(),
				}
			end

			mfrc[3] = abs(mfrc[3])
		end

		dmginfo:SetDamageForce(mfrc)

		local owner = self:GetOwner()

		if not IsValid(owner) then
			return
		end

		local phys = victim:GetPhysicsObject()

		if not (IsValid(phys) and phys:IsMoveable()) then
			return
		end

		victim:SetPhysicsAttacker(owner)
	end
end

local remap = TTTWR.RemapClamp

function SWEP:GetHeadshotMultiplier(victim, dmginfo)
	local att = dmginfo:GetAttacker()

	if not IsValid(att) then
		return 2
	end

	return remap(
		victim:GetPos():Distance(att:GetPos()),
		64, 256, self.HeadshotMultiplier, 1
	)
end
