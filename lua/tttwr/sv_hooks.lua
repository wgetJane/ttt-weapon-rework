hook.Add("OnDamagedByExplosion", "tttwr_OnDamagedByExplosion", function()
	return true
end)

hook.Add("PreCleanupMap", "tttwr_PreCleanupMap", function()
	GAMEMODE.LastCleanupTime = CurTime()
end)

local wepfromdmg = util.WeaponFromDamage

hook.Add("EntityTakeDamage", "tttwr_EntityTakeDamage", function(victim, dmginfo)
	if not IsValid(victim) then
		return
	end

	if victim.DyingShotTime and CurTime() == victim.DyingShotTime then
		-- this is probably only necessary in PlayerTraceAttack
		return true
	end

	local wep = wepfromdmg(dmginfo)

	if not wep then
		return
	end

	if wep.OnEntityTakeDamage
		and wep:OnEntityTakeDamage(victim, dmginfo) == true
	then
		return true
	end
end)

--[[
hook.Add("PostEntityTakeDamage", "tttwr_PostEntityTakeDamage", function(victim, dmginfo, took)
	if not IsValid(victim) then
		return
	end

	local wep = wepfromdmg(dmginfo)

	if not wep then
		return
	end

	if wep.PostEntityTakeDamage then
		wep:PostEntityTakeDamage(victim, dmginfo, took)
	end

	if not (
		victim.was_headshot
		and victim:IsPlayer()
		and victim:Alive()
	) then
		return
	end

	SuppressHostEvents(NULL)
	victim:DoCustomAnimEvent(PLAYERANIMEVENT_CUSTOM_GESTURE, ACT_FLINCH_HEAD)
end)
--]]

hook.Add("PlayerTraceAttack", "tttwr_PlayerTraceAttack", function(victim, dmginfo, dir, trace)
	if not IsValid(victim) then
		return
	end

	if victim.DyingShotTime and CurTime() == victim.DyingShotTime then
		-- for some reason, trace attacks will repeat when players fire a dying shot
		return true
	end

	local wep = wepfromdmg(dmginfo)

	if wep
		and wep.OnPlayerTraceAttack
		and wep:OnPlayerTraceAttack(victim, dmginfo, dir, trace) == true
	then
		return true
	end
end)

--[[
hook.Add("ScalePlayerDamage", "tttwr_ScalePlayerDamage", function(victim, hitgroup, dmginfo)
	if not IsValid(victim) then
		return
	end

	local wep = wepfromdmg(dmginfo)

	if wep
		and wep.OnScalePlayerDamage
		and wep:OnScalePlayerDamage(victim, hitgroup, dmginfo) == true
	then
		return true
	end
end)
--]]
