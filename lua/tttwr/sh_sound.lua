local soundmap, n = {}, 0

for k in pairs(TTTWR.sounds) do
	n = n + 1

	soundmap[n] = k
end

table.sort(soundmap)

for i = 1, n do
	soundmap[soundmap[i]] = i
end

local bits = math.ceil(math.log(n) / math.log(2))

local maxplayers_bits = TTTWR.maxplayers_bits

if CLIENT then

local silence = {
	["Weapon_Shotgun.NPC_Reload"] = true,
	["Weapon_Shotgun.Special1"] = true,
	["Weapon_357.OpenLoader"] = true,
	["Weapon_357.RemoveLoader"] = true,
	["Weapon_357.ReplaceLoader"] = true,
	["Weapon_Pistol.Special1"] = true,
	["Weapon_Pistol.Special2"] = true,
	["Weapon.ImpactSoft"] = true,
	["Weapon.StepLeft"] = true,
	["Weapon.StepRight"] = true,
}

hook.Add("PlayerFireAnimationEvent", "tttwr_PlayerFireAnimationEvent", function(ply, pos, ang, event, name)
	if event == 15 and silence[name] then
		return true
	end
end)

net.Receive("tttwr_playsound", function()
	local snd = soundmap[net.ReadUInt(bits) + 1]

	if not snd then
		return
	end

	if net.ReadBool() then
		return sound.Play(snd, net.ReadVector(), 75, 100, 1)
	end

	local ent = Entity(net.ReadUInt(maxplayers_bits) + 1)

	if not (IsValid(ent) and ent:IsPlayer()) then
		return
	end

	if net.ReadBool() then
		ent:SetNetworkOrigin(net.ReadVector())
	end

	ent = ent:GetActiveWeapon() or ent

	return ent:EmitSound(snd)
end)

	return
end

util.AddNetworkString("tttwr_playsound")

function TTTWR.PlaySound(owner, snd, worldsnd)
	local sndid = soundmap[snd]

	if not (sndid and IsValid(owner)) then
		return
	end

	sndid = sndid - 1

	local entid = owner:EntIndex() - 1

	local pos

	local players = player.GetHumans()

	local i = #players + 1

	::loop::

	i = i - 1

	if i == 0 then
		return
	end

	local ply = players[i]

	if ply == owner and not worldsnd then
		goto loop
	end

	net.Start("tttwr_playsound")

	net.WriteUInt(sndid, bits)

	net.WriteBool(worldsnd)

	if worldsnd then
		net.WriteVector(owner:GetShootPos())

		return net.Broadcast()
	end

	net.WriteUInt(entid, maxplayers_bits)

	if ply:TestPVS(owner) then
		net.WriteBool(false)
	else
		net.WriteBool(true)

		pos = pos or owner:GetPos()

		net.WriteVector(pos)
	end

	net.Send(ply)

	goto loop
end
