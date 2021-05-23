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

local readvec = (function(vec)
	return function()
		vec[1] = net.ReadInt(15)
		vec[2] = net.ReadInt(15)
		vec[3] = net.ReadInt(15)
		return vec
	end
end)(Vector())

net.Receive("tttwr_playsound", function()
	local snd = soundmap[net.ReadUInt(bits) + 1]

	if not snd then
		return
	end

	if net.ReadBool() then
		return sound.Play(snd, readvec(), 75, 100, 1)
	end

	local ent = Entity(net.ReadUInt(maxplayers_bits) + 1)

	if not (IsValid(ent) and ent:IsPlayer()) then
		return
	end

	if net.ReadBool() and ent:IsDormant() then
		ent:SetPos(readvec())
	end

	ent = ent:GetActiveWeapon() or ent

	return ent:EmitSound(snd)
end)

	return
end

util.AddNetworkString("tttwr_playsound")

local writevec = (function(floor)
	return function(x, y, z)
		net.WriteInt(floor(x + 0.5), 15)
		net.WriteInt(floor(y + 0.5), 15)
		net.WriteInt(floor(z + 0.5), 15)
	end
end)(math.floor)

function TTTWR.PlaySound(owner, snd, worldsnd)
	local sndid = soundmap[snd]

	if not (sndid and IsValid(owner)) then
		return
	end

	sndid = sndid - 1

	local entid = owner:EntIndex() - 1

	local x, y, z

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
		writevec(owner:GetShootPos():Unpack())

		return net.Broadcast()
	end

	net.WriteUInt(entid, maxplayers_bits)

	if ply:TestPVS(owner) then
		net.WriteBool(false)
	else
		net.WriteBool(true)

		if not x then
			x, y, z = owner:GetPos():Unpack()
		end

		writevec(x, y, z)
	end

	net.Send(ply)

	goto loop
end
