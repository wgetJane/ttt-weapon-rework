local SetupDataTables, PrimaryAttack, ShootBullet, GetRandomFloat, DryFire, CanDyingShot, DyingShot, SetVMSpeed, Reload, Think, Deploy

function TTTWR:MakeWeapon(
	class, sound,
	dmg, delay, cone, recoil, clip,
	x, y, z, a, b, c
)
	local pr = self.Primary

	pr.Damage = dmg
	pr.Delay = delay
	pr.Cone = cone
	pr.Recoil = recoil
	pr.ClipSize = clip
	pr.DefaultClip = clip
	pr.Sound = "Weapon_" .. sound .. ".Single"

	pr.Automatic = true

	if x then
		self.IronSightsPos = Vector(x, y, z)
		self.IronSightsAng = Vector(a, b, c)
	else
		self.NoSights = true
	end

	self.Base = "weapon_tttbase"

	self.AutoSpawnable = true -- side-effect: this makes grenades spawn less often

	self.HoldType = "ar2"

	self.Kind = WEAPON_HEAVY

	self.ReloadTime = 3
	self.DeployTime = 0.75
	-- the deploy animation playing too fast looks too weird and distracting
	-- it's not really an issue if weapons deploy faster than they appear
	self.DeployAnimSpeed = 1.25

	self.SetupDataTables = SetupDataTables
	self.PrimaryAttack = PrimaryAttack
	self.ShootBullet = ShootBullet
	self.GetRandomFloat = GetRandomFloat
	self.DryFire = DryFire
	self.CanDyingShot = CanDyingShot
	self.DyingShot = DyingShot
	self.SetVMSpeed = SetVMSpeed
	self.Reload = Reload
	self.Think = Think
	self.Deploy = Deploy

	if SERVER then
		self.NoLuckyHeadshots = true
		self.ShootThroughLimbs = true

		return
	end

	self.Slot = 2

	self.PrintName = "tttwr_" .. class .. "_name"

	self.UseHands = true
	self.ViewModelFlip = false
	self.ViewModelFOV = 54

	self.Icon = "!tttwr_icons/" .. class
end

function SetupDataTables(self)
	if not (
		self.PreSetupDataTables
		and self:PreSetupDataTables() == true
	) then
		-- these get sent to everyone in the pvs instead of just the owner, that's annoying
		-- i know i can use the net library instead, but im lazy

		self:NetworkVar("Float", 0, "Reloading")
		self:NetworkVar("Bool", 0, "Inserting")

		if self.StoreLastPrimaryFire then
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

function PrimaryAttack(self, worldsnd)
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

	if not worldsnd then
		self:EmitSound(pri.Sound, pri.SoundLevel)
	elseif SERVER then
		sound.Play(pri.Sound, self:GetPos(), pri.SoundLevel)
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
		local vm = owner:GetViewModel()

		if IsValid(vm) then
			vm:SendViewModelMatchingSequence(self.ShootSequence)
		end
	end

	if owner then
		owner:MuzzleFlash()

		owner:SetAnimation(PLAYER_ATTACK1)
	end

	local sights = self:GetIronsights()

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

	if self.SetLastPrimaryFire then
		self:SetLastPrimaryFire(curtime)
	end

	if owner and owner.ViewPunch then
		local ang = ang

		ang[1] = recoil * -0.15

		owner:ViewPunch(ang)
	end

	if CLIENT and IsFirstTimePredicted() and owner == LocalPlayer() then
		receiverecoil(recoil, self.RecoilTime)
	end

	local curatt = self:GetNextPrimaryFire()
	local diff = curtime - curatt

	if diff > frametime or diff < 0 then
		curatt = curtime
	end

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

	if self.OnPostShoot then
		return self:OnPostShoot(curatt)
	end
end

local bullet = {
	Spread = Vector(),
}
TTTWR.SharedBullet = bullet

function ShootBullet(self, dmg, recoil, numbul, cone)
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

local sharedrand = util.SharedRandom

function GetRandomFloat(self, x, y, seed)
	return sharedrand(
		self.ClassName,
		x or 0, y or 1,
		(seed or 0) - self:EntIndex()
	)
end

local max = math.max

function DryFire(self, setnext)
	if self:Reload() ~= false then
		return
	end

	self:EmitSound(
		self.DryFireSound or "Weapon_Pistol.Empty",
		50, 100, 1 / 3, CHAN_WEAPON, SND_CHANGE_VOL
	)

	setnext(self, CurTime() + max(0.2, (
			setnext == self.SetNextSecondaryFire
				and self.Secondary
				or self.Primary
		).Delay))
end

function CanDyingShot(self, curtime)
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

function DyingShot(self)
	self.ForceTracer = true

	local data = EffectData()
	data:SetEntity(self)
	data:SetFlags(2)

	util.Effect("MuzzleFlash", data)

	self:PrimaryAttack(true)

	return true
end

function SetVMSpeed(self, speed, owner)
	if speed == 1 then
		return
	end

	if not owner then
		owner = self:GetOwner()
		if not IsValid(owner) then
			return
		end
	end

	if owner then
		local vm = owner:GetViewModel()

		if IsValid(vm) then
			vm:SetPlaybackRate(speed)
		end
	end
end

-- reload function is rewritten here so i can change reload times
function Reload(self)
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
		if SERVER or owner:ShouldDrawLocalPlayer() then
			if self.Do3rdPersonReloadAnim then
				self:Do3rdPersonReloadAnim(owner)
			else
				owner:SetAnimation(PLAYER_RELOAD)
			end
		end

		local vm = owner:GetViewModel()

		if IsValid(vm) then
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

function Think(self)
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
function Deploy(self)
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

			self:SetDeploySpeed(speed, owner)
		end
	end

	self:SetVMSpeed(self.DeployAnimSpeed)

	-- prevent ironsight viewmodel position calculation while deploying
	-- since SWEP:Think does not get called during the deploy animation
	self.bIron = nil

	return self.BaseClass.Deploy(self)
end

local remap = TTTWR.RemapClamp

if SERVER then
	local clamp = math.Clamp

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
