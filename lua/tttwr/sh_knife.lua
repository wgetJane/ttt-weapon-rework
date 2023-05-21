local ttt_backstab_knife = CreateConVar("ttt_backstab_knife", 1, FCVAR_ARCHIVE + FCVAR_NOTIFY)

local SWEP = weapons.GetStored("weapon_ttt_knife")
local ENT = scripted_ents.GetStored("ttt_knife_proj").t

SWEP.Primary.Damage = 40
SWEP.Secondary.Damage = 60
ENT.ThrownDamage = 60

SWEP.StabKill = nil
ENT.HitPlayer = nil
ENT.KillPlayer = nil

local vec, vec2 = Vector(), Vector()

function SWEP:CanBackstabTarget(owner, victim, opos, aimvec)
	// if we have backstabbing disabled, its always an insta kill :D
	if !ttt_backstab_knife:GetBool() then
		return true
	end
	opos = opos or owner:GetShootPos()
	local vpos = victim:GetShootPos()

	local vec = vec
	vec[1], vec[2], vec[3] = vpos[1] - opos[1], vpos[2] - opos[2], 0
	vec:Normalize()

	local vfwd = victim:GetAimVector()
	vfwd[3] = 0
	vfwd:Normalize()

	if vec:Dot(vfwd) < 0 then -- behind victim?
		return false
	end

	aimvec = aimvec or owner:GetAimVector()

	local ofwd = vec2
	ofwd[1], ofwd[2], ofwd[3] = aimvec[1], aimvec[2], 0
	ofwd:Normalize()

	if vec:Dot(ofwd) < 0.5 -- looking at victim?
		or vfwd:Dot(ofwd) < -0.3 -- facing same direction as victim?
	then
		return false
	end

	return true
end

local vecorig, vecmins, vecmaxs =
	vector_origin, Vector(-8, -8, -8), Vector(8, 8, 8)

local traceres = {}
local tracedata = {
	endpos = Vector(),
	collisiongroup = COLLISION_GROUP_NONE,
	output = traceres,
}

function SWEP:GetMeleeVictim(owner, shootpos, aimvec)
	shootpos = shootpos or owner:GetShootPos()
	aimvec = aimvec or owner:GetAimVector()

	local td = tracedata
	td.filter = owner
	td.start = shootpos
	td.mask = MASK_SHOT_HULL
	td.ignoreworld = false

	for i = 1, 3 do
		td.endpos[i] = shootpos[i] + aimvec[i] * 70
	end

	local tr = util.TraceLine(td)

	local victim = tr.Entity

	if IsValid(victim) and victim.GetShootPos then
		return victim
	end
	-- line trace failed, perform a 0x0x0 hull trace

	td.mins, td.maxs = vecorig, vecorig

	util.TraceHull(td)

	victim = tr.Entity

	if IsValid(victim) and victim.GetShootPos then
		td.mins, td.maxs = nil, nil

		return victim
	end
	-- 0x0x0 hull trace failed, perform a 16x16x16 hull trace

	td.mins, td.maxs = vecmins, vecmaxs

	util.TraceHull(td)

	td.mins, td.maxs = nil, nil

	victim = tr.Entity

	if IsValid(victim) and victim.GetShootPos then
		return victim
	end
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()

	if not IsValid(owner) then
		return
	end

	if SERVER then
		owner:LagCompensation(true)
	end

	local shootpos = owner:GetShootPos()
	local aimvec = owner:GetAimVector()

	local victim = self:GetMeleeVictim(owner, shootpos, aimvec)

	local curtime = CurTime()

	self:SetNextPrimaryFire(curtime + self.Primary.Delay)
	self:SetNextSecondaryFire(curtime + self.Secondary.Delay)

	self:SendWeaponAnim(
		victim
		and ACT_VM_SECONDARYATTACK
		or ACT_VM_MISSCENTER
	)

	owner:SetAnimation(PLAYER_ATTACK1)

	if CLIENT then
		self:EmitSound(
			victim
			and (
				self:CanBackstabTarget(owner, victim, shootpos, aimvec)
				and "Weapon_Knife.Stab"
				or "Weapon_Knife.Hit"
			)
			or traceres.Hit
			and "Weapon_Knife.HitWall"
			or "Weapon_Knife.Slash"
		)
	elseif victim then
		return self:Stab(owner, victim, shootpos, aimvec)
	else
		return owner:LagCompensation(false)
	end
end

function SWEP:Deploy()
	if CLIENT then
		self:EmitSound("Weapon_Knife.Deploy")
	end

	local owner = self:GetOwner()

	if IsValid(owner) then
		local vm = owner:GetViewModel()

		if IsValid(vm) then
			vm:SetPlaybackRate(math.min(
				5 / 3,
				1.15 / (self:GetNextPrimaryFire() - CurTime())
			))
		end
	end

	return self.BaseClass.Deploy(self)
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

if CLIENT then
	local localply

	local SetDrawColor, DrawLine, SimpleText =
		surface.SetDrawColor, surface.DrawLine, draw.SimpleText

	local T = LANG.GetTranslation

	function SWEP:DrawHUD()
		local ply = localply

		if not IsValid(ply) then
			ply = LocalPlayer()
			localply = ply
			if not IsValid(ply) then
				return
			end
		end

		local shootpos = ply:GetShootPos()
		local aimvec = ply:GetAimVector()

		local victim = self:GetMeleeVictim(ply, shootpos, aimvec)

		if victim and (
			--[[victim:Health() < self.Primary.Damage + 1
			or]] self:CanBackstabTarget(ply, victim, shootpos, aimvec)
		) then
			local x, y = ScrW() * 0.5, ScrH() * 0.5

			SetDrawColor(255, 0, 0, 255)

			DrawLine(x - 20, y - 20, x - 10, y - 10)
			DrawLine(x + 20, y + 20, x + 10, y + 10)

			DrawLine(x - 20, y + 20, x - 10, y + 10)
			DrawLine(x + 20, y - 20, x + 10, y - 10)

			SimpleText(
				T("knife_instant"),
				"TabLarge",
				x, y - 30,
				COLOR_RED,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_BOTTOM
			)
		end

		return self.BaseClass.DrawHUD(self)
	end

	return
end

local mask = bit.bor(CONTENTS_SOLID, CONTENTS_MONSTER, CONTENTS_HITBOX)

-- for some reason, how deep the knife sticks into the victim's body is random every round
-- i have no clue why this is happening
local function StickInPlayer(victim, startpos, dir, knife)
	if not (IsValid(victim) and victim:IsPlayer()) then
		return
	end

	local tr = traceres

	local vec = vec

	local set, nearest, nearest_dp

	if tr.Entity == victim and bit.band(tr.Contents, CONTENTS_HITBOX) > 0 then
		-- a line trace was used to find the victim, so bone is already available
		goto skip
	end

	set = victim:GetHitboxSet()

	nearest_dp = 9

	-- a hull trace was used to find the victim, so we need to pick a bone somehow
	-- iterate through hitboxes to find the bone with the closest angle
	for i = 0, victim:GetHitBoxCount(set) do
		local bone = victim:GetHitBoxBone(i, set)

		if not (bone and bone > -1) then
			goto cont
		end

		local pos, ang = victim:GetBonePosition(bone)

		if not (pos and ang) then
			goto cont
		end

		local mins, maxs = victim:GetHitBoxBounds(i, set)

		-- use obb centre
		for i = 1, 3 do
			vec[i] = (mins[i] + maxs[i]) * 0.5
		end
		vec:Rotate(ang)

		for i = 1, 3 do
			vec[i] = startpos[i] - pos[i] - vec[i]
		end
		vec:Normalize()

		local dp = dir:Dot(vec)

		if dp < nearest_dp then
			nearest = pos
			nearest_dp = dp
		end

		::cont::
	end

	if nearest then
		-- perform a trace to the closest bone's position
		-- whichever bone is hit by it is where the knife goes
		local td = tracedata
		td.mask = mask
		td.ignoreworld = true

		for i = 1, 3 do
			vec[i] = nearest[i] - startpos[i]
		end
		vec:Normalize()

		for i = 1, 3 do
			td.endpos[i] = nearest[i] + vec[i] * 32
		end

		util.TraceLine(td)

		if tr.Entity ~= victim then
			-- the trace somehow hit something else, this is fucked up
			-- use a filter function (slow) and retrace for this rare scenario
			td.filter = function(ent)
				return ent == victim
			end

			util.TraceLine(td)
		end
	end

	::skip::

	local physbone, ang =
		tr.PhysicsBone, tr.Normal:Angle()

	local pos = ang:Forward()
	pos:Mul(-7)
	pos:Add(tr.HitPos)

	ang[1] = ang[1] - 30
	ang:RotateAroundAxis(ang:Right(), -110)

	-- use a relative position to try to prevent floating knives
	local bone = victim:TranslatePhysBoneToBone(physbone)
	local bpos, bang = victim:GetBonePosition(bone)
	if not (bpos and bang) then
		local m = victim:GetBoneMatrix(bone)
		bpos = bpos or m:GetTranslation()
		bang = bang or m:GetAngles()
	end

	pos:Mul(-1)
	pos:Add(bpos)
	pos:Mul(-1)

	ang:Mul(-1)
	ang:Add(bang)
	ang:Mul(-1)

	--local prints = self.fingerprints

	victim.effect_fn = function(rag)
		local knife = IsValid(knife) and knife or ents.Create("prop_physics")
		knife:SetModel("models/weapons/w_knife_t.mdl")
		knife:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		knife:SetMoveCollide(MOVECOLLIDE_DEFAULT)
		knife:SetMoveType(MOVETYPE_VPHYSICS)

--[[
		local phys = rag:GetPhysicsObjectNum(physbone)

		pos:Add(IsValid(phys) and phys:GetPos() or bpos)
		ang:Add(IsValid(phys) and phys:GetAngles() or bang)
--]]
----[[
		local bone = rag:TranslatePhysBoneToBone(physbone)
		local bpos, bang = rag:GetBonePosition(bone)
		if not (bpos and bang) then
			local m = rag:GetBoneMatrix(bone)
			bpos = bpos or m:GetTranslation()
			bang = bang or m:GetAngles()
		end
		pos:Add(bpos)
		ang:Add(bang)
--]]

		knife:SetPos(pos)
		knife:SetAngles(ang)

		knife:Spawn()

		--knife.fingerprints = prints
		--knife:SetNWBool("HasPrints", true)

		local kphys = knife:GetPhysicsObject()
		if IsValid(kphys) then
			kphys:EnableCollisions(false)
		end

		constraint.Weld(knife, rag, 0, physbone, 0, true, true)
	end
end

function SWEP:Stab(owner, victim, shootpos, aimvec)
	shootpos = shootpos or owner:GetShootPos()
	aimvec = aimvec or owner:GetAimVector()

	local kill = victim:Health() < self.Primary.Damage + 1
		or self:CanBackstabTarget(owner, victim, shootpos, aimvec)

	if kill then
		StickInPlayer(victim, shootpos, aimvec)
	end

	-- note: two blood impact effects are shown when hitting somebody with the knife
	--  this is cringe, but there's nothing i can do about it
	--  because it's caused by the DMG_SLASH damage type

	local tr = traceres

	local dmginfo = DamageInfo()
	dmginfo:SetDamage(kill and 2000 or self.Primary.Damage)
	dmginfo:SetAttacker(owner)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(DMG_SLASH)
	dmginfo:SetDamageForce(tr.Normal)
	dmginfo:SetDamagePosition(tr.HitPos)
	dmginfo:SetReportedPosition(owner:GetPos())

	tr.HitGroup = 0 -- prevent hitgroup damage scaling

	victim:DispatchTraceAttack(dmginfo, tr)

	if IsValid(victim) and victim:Health() <= 0 then
		self:Remove()
	end

	return owner:LagCompensation(false)
end

function ENT:HitPlayer(victim)
	self.HitPlayer = util.noop

	local owner = self:GetOwner()

	if not IsValid(owner) then
		return
	end

	local dmg = math.max(
		self.ThrownDamage or 60,
		10 + self.StartPos:Distance(self:GetPos()) * (1 / 3)
	)

	local kill = victim:Health() < dmg + 1

	local pos = self:GetPos()

	local phys = self:GetPhysicsObject()
	local vel = IsValid(phys) and phys:GetVelocity() or self:GetVelocity()
	vel:Normalize()

	local td, tr = tracedata, traceres
	td.filter = owner
	td.start = pos
	td.mask = mask
	td.ignoreworld = true

	for i = 1, 3 do
		td.endpos[i] = td.start[i] + vel[i] * 128
	end

	-- this trace is for detecting where the knife should hit
	util.TraceLine(td)

	if tr.Hit and tr.Entity ~= victim then
		-- trace somehow hit something else

		td.mins, td.maxs = vecorig, vecorig
		td.filter = function(ent)
			return ent == victim
		end

		util.TraceHull(td)

		td.mins, td.maxs = nil, nil
		td.filter = owner
	end

	if kill then
		StickInPlayer(victim, pos, vel, self)

		self.Stuck = true
	elseif not self.Weaponised then
		self:BecomeWeaponDelayed()
	end

	local dmginfo = DamageInfo()
	dmginfo:SetDamage(kill and 2000 or dmg)
	dmginfo:SetAttacker(owner)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(DMG_SLASH)
	dmginfo:SetDamageForce(vel)
	dmginfo:SetDamagePosition(pos)
	dmginfo:SetReportedPosition(owner:GetPos())

	tr.HitGroup = 0 -- prevent hitgroup damage scaling

	return victim:DispatchTraceAttack(dmginfo, tr)
end

-- probably should change the ENT:Think method too, since i dislike how it creates two tables every frame
