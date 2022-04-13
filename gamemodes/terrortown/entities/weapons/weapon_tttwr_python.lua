TTTWR.MakePistol(SWEP,
	"python",
	"",
	{"weapons/357/357_fire3.wav", 90, 90},
	35,
	60 / 120,
	0.02,
	5,
	6,
	-4.7, -4.2, 1.5,
	0, -0.25, 0
)


SWEP.AutoSpawnable = false -- already spawns by replacing half of deagles (see sv_replace.lua)

SWEP.HeadshotMultiplier = 17 / 7

SWEP.ConeResetStart = 2 / 3

SWEP.ReloadTime = 1.5
SWEP.ReloadTimeConsecutive = 0.6
SWEP.ReloadTimeFinish = 0.4
SWEP.DeployTime = 0.75
SWEP.DeployAnimSpeed = 1.15

SWEP.ReloadAnimSpeed = 1.1375
SWEP.ReloadAnimLoopSpeed = 1.65
SWEP.ReloadAnimEndSpeed = 0.95
SWEP.ReloadSequence = 8
SWEP.ReloadLoopSequence = 9
SWEP.ReloadEndSequence = 10

SWEP.BulletTracer = 1

SWEP.Primary.ClipMax = 36
SWEP.Primary.Ammo = "AlyxGun"

SWEP.AmmoEnt = "item_ammo_revolver_ttt"

SWEP.NoSetInsertingOnReload = false

SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"

SWEP.ActivityRemap = {
	[ACT_MP_RELOAD_STAND] = ACT_HL2MP_GESTURE_RELOAD_REVOLVER,
	[ACT_MP_RELOAD_CROUCH] = ACT_HL2MP_GESTURE_RELOAD_REVOLVER,
}

function SWEP:OnThink()
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
		and curtime > reloading - TTTWR.FrameTime
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

		local vm = self:GetOwnerViewModel(owner)

		if vm then
			vm:SendViewModelMatchingSequence(self.ReloadEndSequence)

			vm:SetPlaybackRate(self.ReloadAnimEndSpeed)
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

	local vm = self:GetOwnerViewModel(owner)

	if vm then
		vm:SendViewModelMatchingSequence(self.ReloadLoopSequence)

		vm:SetPlaybackRate(self.ReloadAnimLoopSpeed)
	end

	self:SetInserting(true)

	return true
end

if SERVER then
	return
end

local remap = TTTWR.RemapClamp

-- this makes the recoil animation look less exaggerated
function SWEP:GetViewModelPosition(pos, ang)
	pos, ang = self.BaseClass.GetViewModelPosition(self, pos, ang)

	local cycle

	if self:GetActivity() == ACT_VM_PRIMARYATTACK then
		local vm = self:GetOwnerViewModel()

		if vm then
			cycle = vm:GetCycle()
		end
	end

	local offset

	if cycle then
		local inmin, inmax, outmin, outmax = 0.029, 0.44, 1, 0

		if cycle < inmin then
			inmin, inmax, outmin, outmax = 0, inmin, outmax, outmin
		end

		offset = remap(
			cycle, inmin, inmax, outmin, outmax
		)
	end

	if offset and offset ~= 0 then
		ang:RotateAroundAxis(ang:Right(), offset * -27)
		ang:RotateAroundAxis(ang:Forward(), offset * -8)
	end

	pos:Sub(ang:Up())

	return pos, ang
end

function SWEP:FireAnimationEvent(pos, ang, event, options)
	if event == 21 then
		event = 5001
	elseif event == 22 then
		if options == "PISTOL muzzle" then
			local data = EffectData()
			data:SetEntity(self)
			data:SetFlags(2)

			util.Effect("MuzzleFlash", data)
		end

		return true
	end

	return self.BaseClass.FireAnimationEvent(self, pos, ang, event, options)
end
