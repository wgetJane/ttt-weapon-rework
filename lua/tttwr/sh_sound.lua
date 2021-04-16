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

	local pos = net.ReadVector()

	sound.Play(snd, pos, 75, 100, 1)
end)

	return
end

util.AddNetworkString("tttwr_playsound")

function TTTWR.PlaySound(ply, snd, pos)
	if not pos then
		return
	end

	net.Start("tttwr_playsound")

	net.WriteUInt(soundmap[snd] - 1, bits)

	net.WriteVector(pos)

	if ply then
		return net.SendOmit(ply)
	end

	return net.Broadcast() --net.SendPAS(pos)
end
