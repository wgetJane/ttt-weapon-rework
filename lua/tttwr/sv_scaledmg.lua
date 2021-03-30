local hboxmodels = {} -- cache hitbox info (bone, bounds, etc)

local function gethitboxes(ply)
	local model = ply:GetModel()

	local sets = hboxmodels[model]

	if not sets then
		sets = {}
		hboxmodels[model] = sets
	end

	local set = ply:GetHitboxSet()

	local boxes = sets[set]

	if boxes then
		return boxes
	end

	boxes = {
		bones = {},
		mins = {},
		maxs = {},
		hitgroups = {},
	}
	sets[set] = boxes

	local i = 0

	for h = 0, ply:GetHitBoxCount(set) - 1 do
		local hg = ply:GetHitBoxHitGroup(h, set)

		if hg > HITGROUP_STOMACH then
			goto cont
		end

		i = i + 1

		boxes[i] = h

		boxes.bones[i] = ply:GetHitBoxBone(h, set)

		boxes.mins[i], boxes.maxs[i] = ply:GetHitBoxBounds(h, set)

		boxes.hitgroups[i] = hg

		::cont::
	end

	boxes.n = i

	return boxes
end

local dmgtypes = bit.bor(DMG_DIRECT, DMG_BLAST, DMG_FALL, DMG_PHYSGUN)

local vec = Vector()
local tracedata = {
	filter = {NULL, NULL},
	endpos = vec,
	mask = MASK_SHOT,
	collisiongroup = COLLISION_GROUP_NONE,
	ignoreworld = false,
	output = {},
}

local abs = math.abs

function GAMEMODE:ScalePlayerDamage(ply, hitgroup, dmginfo)
	if not IsValid(ply) then
		return
	end

	local isbul = dmginfo:IsBulletDamage()

	local wep = util.WeaponFromDamage(dmginfo)
	if wep and not IsValid(wep) then
		wep = nil
	end

	if isbul and ply:HasEquipmentItem(EQUIP_ARMOR) then
		local scale = ply.ArmorScale or 0.7

		if wep and wep.ArmorPenetration then
			scale = scale + (1 - scale) * wep.ArmorPenetration
		end

		dmginfo:ScaleDamage(scale)
	end

	if isbul
		and hitgroup > HITGROUP_STOMACH
		and wep
		and wep.ShootThroughLimbs
		and ply.hit_trace
		and ply.hit_trace.Entity == ply
	then
		local boxes = gethitboxes(ply)

		local start = ply.hit_trace.HitPos
		local dir = ply.hit_trace.Normal

		-- use shorter raytraces for horizontal shots
		-- probably unnecessary
		local len = 32 + abs(dir[3]) * 40

		local vec = vec
		for i = 1, 3 do
			vec[i] = dir[i] * len
		end

		local minfrac, newhg = 1

		local i = boxes.n

		::loop::

		local pos, ang = ply:GetBonePosition(boxes.bones[i])

		if not (pos and ang) then -- probably unnecessary
			local m = ply:GetBoneMatrix(boxes.bones[i])
			pos = pos or m:GetTranslation()
			ang = ang or m:GetAngles()
		end

		local _, _, frac = util.IntersectRayWithOBB(
			start, vec,
			pos, ang,
			boxes.mins[i], boxes.maxs[i] -- should i care about model scale?
		)

		if frac and frac < minfrac then
			minfrac = frac

			newhg = boxes.hitgroups[i]
		end

		i = i - 1
		if i ~= 0 then
			goto loop
		end

		if newhg then
			for i = 1, 3 do
				vec[i] = start[i] + vec[i] * minfrac
			end

			local td = tracedata
			td.start = start
			td.filter[1] = ply
			td.filter[2] = dmginfo:GetAttacker()

			-- make sure there's nothing in the way
			if not util.TraceLine(td).Hit then
				hitgroup = newhg
			end
		end
	end

	ply.was_headshot = false

	if hitgroup == HITGROUP_HEAD then
		ply.was_headshot = isbul

		dmginfo:ScaleDamage(
			wep and wep:GetHeadshotMultiplier(ply, dmginfo) or 2
		)
	elseif hitgroup > HITGROUP_STOMACH then
		dmginfo:ScaleDamage(
			wep and wep.LimbshotMultiplier or 0.55
		)
	end

	if dmginfo:IsDamageType(dmgtypes) then
		dmginfo:ScaleDamage(2)
	end
end
