local SWEP = {}

SWEP.Base = "weapon_tttbase"

SWEP.AutoSpawnable = true -- side-effect: this makes grenades spawn less often

SWEP.HoldType = "ar2"

SWEP.HeadshotMultiplier = 5 / 3
SWEP.LimbshotMultiplier = 2 / 3

SWEP.FalloffStart = 64
SWEP.FalloffEnd = 1024
SWEP.FalloffMult = 0.5

SWEP.ConeResetStart = 0.2
SWEP.ConeResetEnd = 0.5
SWEP.ConeResetMult = 0x1p-126

SWEP.ReloadTime = 3
SWEP.DeployTime = 1
SWEP.DeployAnimSpeed = 1
SWEP.DeploySpeed = 12 -- will get changed on the first deploy

if SERVER then
	SWEP.NoLuckyHeadshots = true
	SWEP.ShootThroughLimbs = true
else
	SWEP.Slot = 2

	SWEP.UseHands = true
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 54
end

function TTTWR:MakeWeapon(
	class, snd,
	dmg, delay, cone, recoil, clip,
	x, y, z, a, b, c
)
	TTTWR.CopySWEP(self, SWEP)

	local pr = self.Primary

	pr.Damage = dmg
	pr.Delay = delay
	pr.Cone = cone == 0 and 0x1p-126 or cone
	pr.Recoil = recoil == 0 and 0x1p-126 or recoil
	pr.ClipSize = clip
	pr.DefaultClip = clip

	pr.Automatic = true

	if x then
		self.IronSightsPos = Vector(x, y, z)
		self.IronSightsAng = Vector(a, b, c)
	else
		self.NoSights = true
	end

	local sndfile, lvl, pit, vol = snd, 85, 100, 1

	if istable(snd) then
		sndfile = snd[1]
		lvl = snd[2] or lvl
		pit = snd[3] or pit
		vol = snd[4] or vol
	end

	pr.Sound = "tttwr_" .. class .. ".Single"
	pr.SoundLevel = lvl

	local script = {
		name = pr.Sound,
		channel = CHAN_WEAPON,
		level = lvl,
		pitch = pit,
		volume = vol,
		sound = ")" .. sndfile,
	}

	if CLIENT then
		pr.Sound_CL = "tttwr_" .. class .. ".Single_CL"

		script.name_sv = pr.Sound
		script.name_cl = pr.Sound_CL
		script.vol_x1 = vol
	else
		sound.Add(script)
	end

	TTTWR.sounds[pr.Sound] = CLIENT and script or true

	self.Kind = WEAPON_HEAVY

	self.PrintName = "tttwr_" .. class .. "_name"

	self.Icon = "!tttwr_icons/" .. class
end

function SWEP:SetupDataTables()
	if not (
		self.PreSetupDataTables
		and self:PreSetupDataTables() == true
	) then
		-- these get sent to everyone in the pvs instead of just the owner, that's annoying
		-- i know i can use the net library instead, but im lazy

		self:NetworkVar("Float", 0, "Reloading")
		self:NetworkVar("Bool", 0, "Inserting")

		if self.StoreLastPrimaryFire or self.ConeResetMult then
			self:NetworkVar("Float", 1, "LastPrimaryFire")
		end
	end

	self.BaseClass.SetupDataTables(self)

	if self.PostSetupDataTables then
		self:PostSetupDataTables()
	end
end

local ang = Angle()
TTTWR.SharedAngle = ang

local receiverecoil

local frametime = TTTWR.FrameTime

local floor = math.floor

function SWEP:PrimaryAttack(worldsnd)
	if self.OnTryShoot and self:OnTryShoot() == false then
		return
	end

	if not self:CanPrimaryAttack() then
		return
	end

	local curtime = CurTime()

	local owner = self:GetOwner()
	if not IsValid(owner) then
		owner = nil
	end

	if self.OnPreShoot then
		self:OnPreShoot()
	end

	local pri = self.Primary

	local localowned = CLIENT and owner == LocalPlayer()

	if localowned then
		self:EmitSound(pri.Sound_CL)
	elseif owner then
		TTTWR.PlaySound(owner, pri.Sound, worldsnd)
	else
		self:EmitSound(pri.Sound)
	end

	if owner and self.DoShootAnim then
		self:DoShootAnim(owner)
	else
		self:SendWeaponAnim(
			self.DryFireAnim
			and self:Clip1() == 1
			and self.DryFireAnim
			or self.PrimaryAnim
			or ACT_VM_PRIMARYATTACK
		)
	end

	if owner and self.ShootSequence then
		local vm = self:GetOwnerViewModel(owner)

		if vm then
			vm:SendViewModelMatchingSequence(self.ShootSequence)
		end
	end

	if owner then
		owner:MuzzleFlash()

		owner:SetAnimation(PLAYER_ATTACK1)
	end


	local curatt = self:GetNextPrimaryFire()
	local diff = curtime - curatt

	if diff > frametime or diff < 0 then
		curatt = curtime
	end

	local sights = self:GetIronsights()

	local delay = pri.Delay

	self:SetNextSecondaryFire(
		curatt + (
			sights and delay > 0.1 and 0.1 or delay
		)
	)

	self:SetNextPrimaryFire(curatt + delay)

	if owner then
		-- prevent players from skipping slow attack delays by switching to a new weapon
		owner.NextWepPrimaryFire = self:GetNextPrimaryFire()
	end

	local recoil = (
			self.GetRecoil and self:GetRecoil() or pri.Recoil
		) * (
			self.GetRecoilScale
			and self:GetRecoilScale(sights)
			or (
				sights and (
					self.IronsightsRecoilScale or 0.6
				) or 1
			)
		)

	self:ShootBullet(
		pri.Damage, recoil, pri.NumShots, self:GetPrimaryCone()
	)

	self:TakePrimaryAmmo(1)

	if owner and owner.ViewPunch then
		local ang = ang

		ang[1] = recoil * -0.1

		owner:ViewPunch(ang)
	end

	if localowned and IsFirstTimePredicted() then
		receiverecoil(recoil, self.RecoilTime)
	end

	if self.OnPostShoot then
		self:OnPostShoot(curatt)
	end

	if self.SetLastPrimaryFire then
		self:SetLastPrimaryFire(curtime)
	end
end

local bullet = {
	Spread = Vector(),
}
TTTWR.SharedBullet = bullet

function SWEP:ShootBullet(dmg, recoil, numbul, cone)
	local owner = self:GetOwner()

	if not IsValid(owner) then
		return
	end

	local bul = bullet

	bul.Attacker = owner

	bul.Damage = dmg
	bul.Force = self.BulletForce or 10

	bul.Distance = self.BulletDistance or 8192
	bul.HullSize = self.BulletSize or 0

	bul.Num = numbul or 1

	bul.Src = owner:GetShootPos()
	bul.Dir = owner:GetAimVector()

	cone = cone * (self:GetIronsights() and 0.85 or 1)
	bul.Spread[1], bul.Spread[2] = cone, cone

	bul.Tracer = self.BulletTracer or (self.IsSilent and 0) or 4
	bul.TracerName = self.Tracer or "Tracer"

	if self.ForceTracer and bul.Tracer > 0 then
		self.ForceTracer = nil

		bul.Tracer = 1
	end

	bul.AmmoType = nil

	bul.IgnoreEntity = nil

	bul.Callback = nil

	if self.PreFireBullet then
		self:PreFireBullet(owner, bul)
	end

	return owner:FireBullets(bul)
end

local remap = TTTWR.RemapClamp

function SWEP:GetPrimaryCone()
	local cone = self.BaseClass.GetPrimaryCone(self)

	if self.ConeResetMult then
		cone = cone * remap(
			CurTime() - self:GetLastPrimaryFire(),
			self.ConeResetStart, self.ConeResetEnd,
			1, self.ConeResetMult
		)
	end

	return cone
end

local sharedrand = util.SharedRandom

function SWEP:GetRandomFloat(x, y, seed)
	return sharedrand(
		self.ClassName,
		x or 0, y or 1,
		(seed or 0) - self:EntIndex()
	)
end

local clamp = math.Clamp

function SWEP:DryFire(setnext)
	if self:Reload() ~= false then
		return
	end

	setnext(self, CurTime() + clamp((
			setnext == self.SetNextSecondaryFire
				and self.Secondary
				or self.Primary
		).Delay, 0.25, 0.5))

	local ent = CLIENT and self:GetOwnerViewModel() or self

	if ent ~= self and not IsFirstTimePredicted() then
		return
	end

	ent:EmitSound(
		self.DryFireSound or "weapons/pistol/pistol_empty.wav",
		60, 100, 0.25, CHAN_AUTO
	)
end

function SWEP:CanDyingShot(curtime)
	if self:GetNextPrimaryFire() > (curtime or CurTime()) then
		return false
	end

	local owner = self:GetOwner()

	return self:GetIronsights()
		or (
			IsValid(owner)
			and owner.KeyDown
			and owner:KeyDown(IN_ATTACK)
		)
		or false
end

function SWEP:DyingShot()
	self.ForceTracer = true

	local data = EffectData()
	data:SetEntity(self)
	data:SetFlags(2)

	util.Effect("MuzzleFlash", data)

	self:PrimaryAttack(true)

	return true
end

function SWEP:GetOwnerViewModel(owner)
	if not owner then
		owner = self:GetOwner()

		if not IsValid(owner) then
			return
		end
	end

	local vm = owner:GetViewModel()

	if IsValid(vm) then
		return vm
	end
end

function SWEP:SetVMSpeed(speed, owner)
	local vm = self:GetOwnerViewModel(owner)

	if vm then
		vm:SetPlaybackRate(speed)
	end
end

-- reload function is rewritten here so i can change reload times
function SWEP:Reload()
	if self:Clip1() == self.Primary.ClipSize then
		return
	end

	local curtime = CurTime()

	local reloading = self:GetReloading()

	if reloading > 0
		and curtime <= reloading
	then
		return
	end

	local owner = self:GetOwner()
	if not IsValid(owner) then
		owner = nil
	end

	if owner
		and owner.GetAmmoCount
		and owner:GetAmmoCount(self.Primary.Ammo) <= 0
	then
		return false
	end

	if self.SetZoom then
		self:SetZoom(false)
	end

	if not self.NoSights then
		self:SetIronsights(false)
	end

	self:SendWeaponAnim(self.ReloadAnim or ACT_VM_RELOAD)

	if owner then
		owner:SetAnimation(PLAYER_RELOAD)

		local vm = self:GetOwnerViewModel(owner)

		if vm then
			if self.ReloadSequence then
				vm:SendViewModelMatchingSequence(self.ReloadSequence)
			end

			vm:SetPlaybackRate(
				self.ReloadAnimSpeed
				or self:SequenceDuration() / self.ReloadTime,
				owner
			)
		end
	end

	self:SetInserting(not self.NoSetInsertingOnReload)

	local relfin = curtime + self.ReloadTime

	self:SetReloading(relfin)

	self:SetNextPrimaryFire(relfin)
	self:SetNextSecondaryFire(relfin)

	if self.OnStartReload then
		self:OnStartReload()
	end

	return true
end

local min = math.min

function SWEP:Think()
	self.BaseClass.Think(self)

	if self.OnThink
		and self:OnThink() == true
	then
		return
	end

	local reloading = self:GetReloading()

	if reloading <= 0 then
		return
	end

	local curtime = CurTime()

	if curtime > reloading then
		self:SetReloading(0)

		self:SendWeaponAnim(self.IdleAnim or ACT_VM_IDLE)

		return
	end

	if not (
		self:GetInserting()
		and curtime > reloading - self.ReloadTime * (1 / 3)
	) then
		return
	end

	self:SetInserting(false)

	local clip = self:Clip1()

	if clip == self.Primary.ClipSize then
		return
	end

	local owner = self:GetOwner()
	if not IsValid(owner) then
		owner = nil
	end

	local add = min(
		self.Primary.ClipSize - clip,
		owner
			and owner.GetAmmoCount
			and owner:GetAmmoCount(self.Primary.Ammo)
			or self.Primary.ClipMax
	)

	if owner and owner.RemoveAmmo then
		owner:RemoveAmmo(add, self.Primary.Ammo)
	end

	self:SetClip1(clip + add)

	if self.OnInsertClip then
		self:OnInsertClip()
	end
end

-- deploy speed needs to be set when the deploy animation duration can be accessed
-- since css weapons have weirdly different deploy times
-- (why does the mac10 take 3 seconds to deploy???)
function SWEP:Deploy()
	if self.OnDeploy then
		self:OnDeploy()
	end

	self:SetReloading(0)
	self:SetInserting(false)

	if self.DeployAnim then
		self:SendWeaponAnim(self.DeployAnim)
	end

	local owner = self:GetOwner()
	if not IsValid(owner) then
		owner = nil
	end

	if owner
		and owner.NextWepPrimaryFire
		and owner.NextWepPrimaryFire > CurTime()
		and owner.NextWepPrimaryFire > self:GetNextPrimaryFire()
	then
		self:SetNextPrimaryFire(owner.NextWepPrimaryFire)
	end

	local seq = self:SelectWeightedSequence(
		self.DeployAnim or ACT_VM_DRAW
	)

	if seq ~= -1 then
		local speed = self:SequenceDuration(seq) / self.DeployTime

		if speed ~= self.DeploySpeed then
			self.DeploySpeed = speed

			self:SetDeploySpeed(speed)

			local nextfire = CurTime() + self.DeployTime

			if self:GetNextPrimaryFire() < nextfire then
				self:SetNextPrimaryFire(nextfire)
			end
		end
	end

	self:SetVMSpeed(self.DeployAnimSpeed)

	-- prevent ironsight viewmodel position calculation while deploying
	-- since SWEP:Think does not get called during the deploy animation
	self.bIron = nil

	return self.BaseClass.Deploy(self)
end

if SERVER then
	function TTTWR.SendRecoil(ply, recoil, time, axis)
		net.Start("tttwr_recoil")

		recoil = remap(recoil or 2, -45, 45, -2 ^ 16, 2 ^ 16 - 1)
		recoil = floor(recoil + 0.5)

		net.WriteInt(recoil, 17)

		time = clamp(time or 1 / 15, 0, 1.05)
		time = floor(time * 60 + 0.5)

		net.WriteUInt(time, 6)

		net.WriteBit(axis == 2)

		net.Send(ply)
	end

	return function()
		util.AddNetworkString("tttwr_recoil")
	end
end

local function netReceiveRecoil()
	return receiverecoil(
		remap(net.ReadInt(17), -2 ^ 16, 2 ^ 16 - 1, -45, 45),
		net.ReadUInt(6) * (1 / 60),
		net.ReadBit() + 1
	)
end

local head -- linked list used for recoil

local pool, pool_size = {nxtpool={nxtpool={}}}, 3 -- premade tables for linked list

function receiverecoil(recoil, time, axis)
	local push
	if pool then
		push = pool

		pool = push.nxtpool

		pool_size = pool_size - 1
	else
		push = {}
	end

	push.nxt = head
	push.max = recoil or 2
	push.done = 0
	push.birth = RealTime()
	push.time = time or 1 / 15
	push.axis = axis or 1

	head = push
end

local localply

local ease = math.EaseInOut

local function ClientThink()
	if not head then
		return
	end

	local ply = localply

	if not IsValid(ply) then
		localply = LocalPlayer()

		return
	end

	local realtime = RealTime()

	local eyeang

	local rec, prev = head

	::loop::

	local nxt = rec.nxt

	local maxr = rec.max

	local s = maxr >= 0 and 1 or -1

	local recoil = maxr * ease(
		(realtime - rec.birth) / rec.time, 0.01, 2 / 3
	)

	local done = rec.done
	rec.done = recoil

	local sub = recoil - done

	local a = rec.axis or 1

	if sub * s < 0 or recoil * s >= maxr * s then
		if pool_size < 4 then
			rec.nxtpool = pool

			pool = rec

			pool_size = pool_size + 1
		else
			rec.nxtpool = nil
		end

		if rec == head then
			head = nxt
		elseif prev then
			prev.nxt = nxt
		end

		rec.nxt = nil

		rec = prev

		if sub * s < 0 then
			sub = maxr - done
		end
	end

	if sub * s > 0 then
		if not eyeang then
			eyeang = ply:EyeAngles()
		end

		eyeang[a] = eyeang[a] - sub
	end

	prev, rec = rec, nxt

	if rec then
		goto loop
	end

	if eyeang and ply:Alive() then
		ply:SetEyeAngles(eyeang)
	end
end

return function()
	net.Receive("tttwr_recoil", netReceiveRecoil)

	hook.Add("Think", "tttwr_ClientThink", ClientThink)
end
