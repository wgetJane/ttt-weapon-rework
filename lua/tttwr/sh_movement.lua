hook.Add("PlayerSpawn", "tttwr_PlayerSpawn", function(ply)
	if not IsValid(ply) then
		return
	end

	ply:SetViewOffsetDucked(Vector(0, 0, 36))
	ply:SetCrouchedWalkSpeed(100 / 220)
	ply:SetSlowWalkSpeed(220 * (2 / 3))
end)

local tracedata = {
	endpos = Vector(),
	mins = Vector(-15.9, -15.9, 0),
	max = Vector(15.9, 15.9, 0),
	mask = MASK_SOLID_BRUSHONLY,
	collisiongroup = COLLISION_GROUP_DEBRIS,
	ignoreworld = false,
	output = {},
}

local max = math.max

-- i wish i can just raise the duck hull height instead of doing all this,
-- but mappers just LOVE making 36-unit-tall vents for some reason
hook.Add("PlayerPostThink", "tttwr_PlayerPostThink", function(ply)
	if not (
		IsValid(ply)
		and ply:IsTerror()
		and ply:Crouching()
	) then
		return
	end

	local td = tracedata
	td.filter = ply
	td.start = ply:GetPos()

	td.start[3] = td.start[3] + 36

	td.endpos[1], td.endpos[2], td.endpos[3] =
		td.start[1], td.start[2], td.start[3] + 4

	local frac = util.TraceHull(td).Fraction

	if frac == 1 then
		return
	end

	local offset = ply:GetCurrentViewOffset()

	if offset[3] < 36 then
		return
	end

	offset[3] = offset[3] - 4 * (1 - frac)

	ply:SetCurrentViewOffset(offset)
end)

local min = math.min

function GAMEMODE:Move(ply, mv)
	if not ply:IsTerror() then
		return
	end

	local ironspeed, ironmul

	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep.GetIronsights and wep:GetIronsights() then
		local walkspeed = ply:GetWalkSpeed()

		if ply:Crouching() then
			walkspeed = walkspeed * ply:GetCrouchedWalkSpeed()
		end

		ironspeed = min(walkspeed, wep.IronsightWalkSpeed or 120)

		ironmul = ironspeed / (walkspeed == 0 and 1 or walkspeed)
	end

	local mul = hook.Call("TTTPlayerSpeedModifier", GAMEMODE, ply, ironmul ~= nil, mv) or 1

	local cmaxspeed = mv:GetMaxClientSpeed()
	local maxspeed = mv:GetMaxSpeed()

	if ironmul then
		cmaxspeed = max(ironspeed, cmaxspeed * ironmul)
		maxspeed = max(ironspeed, maxspeed * ironmul)
	end

	mv:SetMaxClientSpeed(cmaxspeed * mul)
	mv:SetMaxSpeed(maxspeed * mul)
end

--[[
 i fucking hate gmod footsteps
 most of them are way too quiet, like a lot of ambient noises are louder than footsteps on concrete
 meanwhile, footsteps on grass and dirt are very significantly much louder than other footsteps
 ?????????
 im not dealing with this shit anymore

if SERVER then
	function GAMEMODE:PlayerFootstep()
		return true
	end

	return
end

function GAMEMODE:PlayerFootstep(ply, pos, foot, snd, volume, filter)
	if not IsValid(ply)
		or not ply:Alive()
		or ply:IsSpec()
		or ply:Crouching()
		or ply:GetMaxSpeed() < 150
	then
		return true
	end

	if not localply then
		localply = LocalPlayer()
	end

	ply:EmitSound(
		snd,
		75,
		100,
		volume * 2,
		CHAN_BODY,
		SND_CHANGE_VOL
	)

	return true
end
--]]
