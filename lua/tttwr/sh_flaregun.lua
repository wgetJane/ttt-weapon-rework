local SWEP = weapons.GetStored("weapon_ttt_flaregun")

SWEP.Primary.Cone = 0

function SWEP:Initialize()
	self:SetColor(Color(255, 0, 0))

	return self.BaseClass.Initialize(self)
end

local ang = TTTWR.SharedAngle

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then
		return
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	self:ShootFlare()

	self:TakePrimaryAmmo(1)

	local owner = self:GetOwner()

	if IsValid(owner) then
		owner:MuzzleFlash()

		owner:SetAnimation(PLAYER_ATTACK1)

		local ang = ang

		ang[1] = -self.Primary.Recoil

		owner:ViewPunch(ang)
	end
end

local bullet = TTTWR.SharedBullet

local bulletCallback

function SWEP:ShootFlare()
	local owner = self:GetOwner()

	if not IsValid(owner) then
		return
	end

	local bul = bullet

	bul.Attacker = owner

	bul.Damage = self.Primary.Damage
	bul.Force = 2

	bul.Distance = 8192
	bul.HullSize = 0

	bul.Num = 1

	bul.Src = owner:GetShootPos()
	bul.Dir = owner:GetAimVector()

	bul.Spread[1], bul.Spread[2] = 0, 0

	bul.Tracer = 1
	bul.TracerName = "AR2Tracer"

	bul.AmmoType = nil

	bul.IgnoreEntity = nil

	bul.Callback = bulletCallback

	return owner:FireBullets(bul)
end

if CLIENT then
	function SWEP:PreDrawViewModel()
		render.SetColorModulation(1, 0, 0)
	end

	function SWEP:ViewModelDrawn()
		render.SetColorModulation(1, 1, 1)
	end

	return
end

local function ignite(ent, duration, radius, attacker, infl)
	ent:Ignite(duration, radius)

	local igninf = {
		att = attacker,
		infl = infl,
	}

	ent.ignite_info = igninf

	if ent:IsPlayer() then
		return timer.Simple(duration + 0.1, function()
			if IsValid(ent) and igninf == ent.ignite_info then
				ent.ignite_info = nil
			end
		end)
	end
end

local head

local function burncorpse(ent)
	if not head then
		timer.Start("tttwr_flaregun")
	end

	local burntime = 6

--[[
	local burnprog = ent._tttwr_flaregun_burnprogress

	if burnprog then
		burntime = burntime - burntime * burnprog
	end
--]]

	local curtime = CurTime()

	head = {
		nxt = head,
		ent = ent,
		death = curtime + burntime,
		--birth = curtime,
		--lastprog = burnprog,
	}
end

local tracedata = {
	filter = {NULL, NULL},
	mask = MASK_SHOT,
	collisiongroup = COLLISION_GROUP_DEBRIS,
	ignoreworld = false,
	output = {},
}

local min, remap = math.min, TTTWR.RemapClamp

function bulletCallback(attacker, trace, dmginfo)
	local victim = trace.Entity

	local infl = dmginfo:GetInflictor()

	local hitpos = trace.HitPos

	local td = tracedata
	td.endpos = hitpos
	td.filter[2] = attacker

	local radius = 110

	-- ents.FindInSphere uses an actual sphere, fortunately
	-- unlike UTIL_EntitiesInSphere which trolls you by actually using a cube
	local ents = ents.FindInSphere(hitpos, radius)

	for i = 1, #ents do
		local ent = ents[i]

		if not (
			IsValid(ent)
			and ent ~= victim
			and ent ~= attacker
			and ent:IsPlayer()
			and ent:Alive()
		) then
			goto cont
		end

		td.start = ent:WorldSpaceCenter()
		td.filter[1] = ent

		if util.TraceLine(td).Fraction < 0.99 then
			goto cont
		end

		ignite(
			ent,
			remap(
				min(
					hitpos:Distance(td.start),
					hitpos:Distance(ent:GetPos())
				),
				0, radius,
				6, 3
			),
			100,
			attacker,
			infl
		)

		::cont::
	end

	if not IsValid(victim) then
		return
	end

	ignite(victim, victim:IsPlayer() and 6 or 10, 100, attacker, infl)

	if victim:GetClass() == "prop_ragdoll" then
		return burncorpse(victim)
	end
end

--local ragcol = Color(0, 0, 0)

timer.Create("tttwr_flaregun", 0.1, 0, function()
	if not head then
		return timer.Stop("tttwr_flaregun")
	end

	local curtime = CurTime()

	local IsValid = IsValid

	--local col = ragcol

	local rag, prev = head

	::loop::

	local nxt, ent = rag.nxt, rag.ent

	if not (IsValid(ent) and ent:IsOnFire()) then
	elseif ent:WaterLevel() > 0 then
		ent:Extinguish()
	elseif curtime >= rag.death then
		net.Start("TTT_FlareScorch")
		net.WriteEntity(ent)

		local n, physobjs = 0, {}

		for i = 0, ent:GetPhysicsObjectCount() - 1 do
			local phys = ent:GetPhysicsObjectNum(i)

			if IsValid(phys) then
				n = n + 1

				physobjs[n] = phys:GetPos()
			end
		end

		net.WriteUInt(n, 8)

		for i = n, 1, -1 do
			net.WriteVector(physobjs[i])

			physobjs[i] = nil
		end

		net.Broadcast()


		ent:SetNotSolid(true)
		ent:Remove()
	else
--[[
		local prog = (rag.death - curtime) / (rag.death - rag.birth)

		if rag.lastprog then
			prog = prog - rag.lastprog
		end

		prog = clamp(prog, 0, 1)

		ent._tttwr_flaregun_burnprogress = 1 - prog

		col.r, col.g, col.b =
			70 + prog * 185,
			55 + prog * 200,
			50 + prog * 205

		ent:SetColor(col)
--]]
		goto cont
	end

	if rag == head then
		head = nxt
	elseif prev then
		prev.nxt = nxt
	end

	rag.nxt, rag.ent = nil, nil

	rag = prev

	::cont::

	prev, rag = rag, nxt

	if rag then
		goto loop
	end
end)
timer.Stop("tttwr_flaregun")

hook.Add("TTTOnCorpseCreated", "tttwr_flaregun_TTTOnCorpseCreated", function(rag, ply)
	if GetRoundState() == ROUND_ACTIVE
		and IsValid(rag)
		and IsValid(ply)
		and ply:IsOnFire()
		and ply.ignite_info
	then
		ignite(rag, 10, 100, ply.ignite_info.att, ply.ignite_info.infl)
		burncorpse(rag)
	end
end)
