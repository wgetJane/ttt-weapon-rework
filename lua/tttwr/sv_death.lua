local ttt_prioritytargets = CreateConVar("ttt_prioritytargets", "2", FCVAR_NOTIFY + FCVAR_REPLICATED)

util.AddNetworkString("tttwr_priotargs")

local maxplayers_bits = TTTWR.maxplayers_bits

hook.Add("TTTBeginRound", "tttwr_TTTBeginRound", function()
	local targcount = ttt_prioritytargets:GetInt()

	if targcount < 1 then
		return
	end

	local players = player.GetAll()

	local innocents, traitors = {}, {}

	for i = 1, #players do
		local ply = players[i]

		ply.PriorityTargets = nil

		if ply:IsTerror() and ply:Alive() then
			if ply:GetTraitor() then
				traitors[#traitors + 1] = ply
			elseif not ply:GetDetective() then
				innocents[#innocents + 1] = ply
			end
		end
	end

	if #innocents == 0 then
		return
	end

	local n = 0

	for i = 1, #traitors do
		local ply = traitors[i]

		local targs = setmetatable({}, TTTWR.weakkeys)

		net.Start("tttwr_priotargs")

		for _ = 1, targcount do
			if n < 1 then
				table.Shuffle(innocents)

				n = #innocents
			end

			local targ = innocents[n]
			n = n - 1

			targs[targ:AccountID()] = true

			net.WriteUInt(targ:EntIndex() - 1, maxplayers_bits)
		end

		ply.PriorityTargets = targs

		net.Send(ply)
	end
end)

local ttt_credits_award_pct = GetConVar("ttt_credits_award_pct")
local ttt_credits_award_size = GetConVar("ttt_credits_award_size")
local ttt_credits_award_repeat = GetConVar("ttt_credits_award_repeat")
local ttt_credits_detectivekill = GetConVar("ttt_credits_detectivekill")
local ttt_det_credits_traitorkill = GetConVar("ttt_det_credits_traitorkill")
local ttt_det_credits_traitordead = GetConVar("ttt_det_credits_traitordead")

local ttt_dyingshot = GetConVar("ttt_dyingshot")
local ttt_dyingshot_enabled = CreateConVar("ttt_dyingshot_enabled", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY)

hook.Add("TTTBodyFound", "tttwr_TTTBodyFound", function(ply, deadply, rag)
	if not (IsValid(rag) and rag.was_role == ROLE_TRAITOR) then
		return
	end

	local creds = ttt_det_credits_traitordead:GetInt()

	if creds <= 0 then
		return
	end

	local params = {num = creds}

	local players = player.GetAll()

	for i = 1, #players do
		local ply = players[i]

		if ply:IsActiveDetective() then
			ply:AddCredits(creds)

			LANG.Msg(ply, "credit_det_all", params)
		end
	end
end)

TTTWR.deathsounds = {
--[[ way too quiet
	"player/death1.wav",
	"player/death2.wav",
	"player/death3.wav",
	"player/death4.wav",
	"player/death5.wav",
	"player/death6.wav",
--]]
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/Barney/ba_pain06.wav",
	"vo/npc/Barney/ba_pain07.wav",
	"vo/npc/Barney/ba_pain09.wav",
	"vo/npc/Barney/ba_ohshit03.wav",
	"vo/npc/Barney/ba_no01.wav",
	"vo/npc/male01/no02.wav",
	"hostage/hpain/hpain1.wav",
	"hostage/hpain/hpain2.wav",
	"hostage/hpain/hpain3.wav",
	"hostage/hpain/hpain4.wav",
	"hostage/hpain/hpain5.wav",
	"hostage/hpain/hpain6.wav",
}

local lastdeathsound

local CheckPriorityKill, CheckCreditAward

-- having to overwrite all of this sucks, but there's no other way

function GAMEMODE:DoPlayerDeath(ply, attacker, dmginfo)
	if ply:IsSpec() then
		return
	end

	local curtime = CurTime()

	if ply.DyingShotTime and curtime == ply.DyingShotTime then
		return
	end

	if GetRoundState() == ROUND_ACTIVE then
		SCORE:HandleKill(ply, attacker, dmginfo)

		if IsValid(attacker) and attacker:IsPlayer() then
			attacker:RecordKill(ply)

			DamageLog(Format("KILL:\t %s [%s] killed %s [%s]", attacker:Nick(), attacker:GetRoleString(), ply:Nick(), ply:GetRoleString()))
		else
			DamageLog(Format("KILL:\t <something/world> killed %s [%s]", ply:Nick(), ply:GetRoleString()))
		end

		KARMA.Killed(attacker, ply, dmginfo)
	end

	local wep = ply:GetActiveWeapon()
	wep = IsValid(wep) and wep

	local killwep = util.WeaponFromDamage(dmginfo)

	local killerscene

	if ttt_dyingshot_enabled:GetBool() or ttt_dyingshot:GetBool() then
		if not (wep
			and wep.DyingShot
			and wep.CanDyingShot
			and IsValid(attacker)
			and attacker:IsPlayer()
			and dmginfo:IsDamageType(DMG_BULLET + DMG_CLUB + DMG_SLASH)
			and wep:CanDyingShot(curtime)
		) then
			goto done
		end

		ply:LagCompensation(true) -- i wish i could unlag only a single entity

		local vec = ply:GetShootPos()
		vec:Sub(attacker:WorldSpaceCenter())
		vec:Normalize()

		ply:LagCompensation(false)

		if vec:Dot(ply:GetAimVector()) > 0 then
			goto done
		end

		killerscene = {
			pos = attacker:GetPos(),
			ang = attacker:GetAngles(),
			sequence = attacker:GetSequence(),
			cycle = attacker:GetCycle(),
			aim_yaw = attacker:GetPoseParameter("aim_yaw"),
			move_yaw = attacker:GetPoseParameter("move_yaw"),
			aim_pitch = attacker:GetPoseParameter("aim_pitch"),
		}

		ply.dying_wep = wep

		ply.DyingShotTime = curtime

		wep:DyingShot()

		print((
			"%s (%s) fired their DYING SHOT"
		):format(
			ply:Nick(), ply:SteamID()
		))

		::done::
	end

	if wep then
		WEPS.DropNotifiedWeapon(ply, wep, true)
		wep:DampenDrop()

		local pos, ang

		local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand")

		if bone then
			pos, ang = ply:GetBonePosition(bone)
		end

		local bpos, bang

		if pos and ang then
			bone = wep:LookupBone("ValveBiped.Bip01_R_Hand")

			if bone then
				bpos, bang = wep:GetBonePosition(bone)
			end
		end

		if bpos and bang then
			pos:Sub(bpos)
			ang:Sub(bang)

			pos:Add(wep:GetPos())
			ang:Add(wep:GetAngles())
		else
			local att = ply:LookupAttachment("anim_attachment_RH")

			if att == -1 then
				goto done
			end

			att = ply:GetAttachment(att)

			if not att then
				goto done
			end

			pos, ang = att.Pos, att.Ang
		end

		if util.TraceLine({
			start = pos,
			endpos = pos,
			filter = wep,
			collisiongroup = COLLISION_GROUP_WEAPON,
		}).Hit then
			goto done
		end

		wep:SetPos(pos)
		wep:SetAngles(ang)

		::done::
	end

	local dropweps = ply:GetWeapons()

	for i = 1, #dropweps do
		local wep = dropweps[i]

		WEPS.DropNotifiedWeapon(ply, wep, true)
		wep:DampenDrop()
	end

	if IsValid(ply.hat) then
		ply.hat:Drop()
	end

	local rag = CORPSE.Create(ply, attacker, dmginfo)
	ply.server_ragdoll = rag

	if IsValid(rag) then
		util.PaintDown(
			ply:GetPos() + Vector(math.Rand(-35, 35), math.Rand(-35, 35), 20),
			"Blood", ply
		)

		util.StartBleeding(rag, dmginfo:GetDamage(), 15)

		if killerscene and not attacker:Alive() then
			rag.dmgwep = IsValid(killwep) and killwep:GetClass() or ""

			if rag.scene then
				rag.scene.killer = killerscene
			end
		end
	end

	if ttt_prioritytargets:GetInt() > 0 then
		CheckPriorityKill(ply, attacker)
	else
		CheckCreditAward(ply, attacker)
	end

	ply:StripAll()

	ply:SendLastWords(dmginfo)

	if not (
		ply.was_headshot
		or dmginfo:IsDamageType(DMG_SLASH)
		or (IsValid(killwep) and killwep.IsSilent)
	) then
		local deathsounds = TTTWR.deathsounds

		local i

		for _ = 1, 2 do
			i = math.random(#deathsounds)

			if i ~= lastdeathsound then
				break
			end
		end

		lastdeathsound = i

		sound.Play(deathsounds[i], ply:GetShootPos(), 90, 100)
	end

	if IsValid(attacker) and attacker:IsPlayer() then
		local reward =
			attacker:IsActiveTraitor()
				and ply:GetDetective()
				and ttt_credits_detectivekill:GetInt()
			or attacker:IsActiveDetective()
				and ply:GetTraitor()
				and ttt_det_credits_traitorkill:GetInt()
			or 0

		if reward > 0 then
			attacker:AddCredits(reward)

			LANG.Msg(
				attacker,
				"credit_kill",
				{
					num = reward,
					role = LANG.NameParam(ply:GetRoleString())
				}
			)
		end
	end
end

function CheckPriorityKill(victim, attacker)
	if GetRoundState() ~= ROUND_ACTIVE
		or not IsValid(victim)
	then
		return
	end

	local sid = victim:AccountID()

	if not sid then
		return
	end

	local creds = ttt_credits_award_size:GetInt()

	local players = player.GetAll()

	local params = {
		num = creds,
		targ = victim:Nick(),
	}

	for i = 1, #players do
		local ply = players[i]

		if ply:IsActiveTraitor()
			and ply.PriorityTargets
			and ply.PriorityTargets[sid]
		then
			ply:AddCredits(creds)

			LANG.Msg(ply, "priotarg_kill", params)
		end
	end
end

function CheckCreditAward(victim, attacker)
	if GetRoundState() ~= ROUND_ACTIVE
		or not IsValid(victim)
		or victim:GetTraitor()
		or (
			GAMEMODE.AwardedCredits
			and not ttt_credits_award_repeat:GetBool()
		)
	then
		return
	end

	local inno_alive = 0
	local inno_dead = 0

	local players = player.GetAll()

	for i = 1, #players do
		local ply = players[i]

		if not ply:GetTraitor() then
			if ply:IsTerror() then
				inno_alive = inno_alive + 1
			elseif ply:IsDeadTerror() then
				inno_dead = inno_dead + 1
			end
		end
	end

	inno_dead = inno_dead + 1
	inno_alive = math.max(inno_alive - 1, 0)
	local inno_total = inno_dead + inno_alive

	if GAMEMODE.AwardedCredits then
		inno_dead = inno_dead - GAMEMODE.AwardedCreditsDead
	end

	local pct = inno_dead / inno_total

	if pct < ttt_credits_award_pct:GetFloat() then
		return
	end

	local creds = ttt_credits_award_size:GetInt()

	if creds > 0 then
		local params = {num = creds}

		for i = 1, #players do
			local ply = players[i]

			if ply:IsActiveTraitor() then
				ply:AddCredits(creds)

				LANG.Msg(ply, "credit_tr_all", params)
			end
		end
	end

	GAMEMODE.AwardedCredits = true
	GAMEMODE.AwardedCreditsDead = inno_dead + GAMEMODE.AwardedCreditsDead
end
