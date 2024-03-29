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

CreateConVar("ttt_volume_guns_self", 0.5, FCVAR_ARCHIVE, "Adjusts sound volume of your own gunshots", 0, 1)
CreateConVar("ttt_volume_guns_other", 1, FCVAR_ARCHIVE, "Adjusts sound volume of other players' gunshots", 0, 1)

local function volumecb(name)
	local k = name == "ttt_volume_guns_self" and "name_cl" or "name_sv"
	local vol = GetConVar(name):GetFloat()

	for _, v in pairs(TTTWR.sounds) do
		v.name = v[k]
		v.volume = v.vol_x1 * vol
		sound.Add(v)
	end
end

volumecb("ttt_volume_guns_self")
volumecb("ttt_volume_guns_other")

cvars.AddChangeCallback("ttt_volume_guns_self", volumecb, "tttwr")
cvars.AddChangeCallback("ttt_volume_guns_other", volumecb, "tttwr")

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

	local wep = ent:GetActiveWeapon()

	ent = IsValid(wep) and wep or ent

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

function TTTWR:PlaySound(owner, snd, worldsnd)
	if worldsnd then
		worldsnd = owner:GetShootPos()

		sound.Play(snd, worldsnd, 75, 100, 1)
	else
		self:EmitSound(snd)
	end

	local sndid = soundmap[snd]

	if not sndid then
		return
	end

	sndid = sndid - 1

	local entid = owner:EntIndex() - 1

	local x, y, z = owner:GetPos()

	local players = RecipientFilter()

	players:AddAllPlayers()
	players:RemovePAS(x)

	players = players:GetPlayers()

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

	net.Start("tttwr_playsound", true)

	net.WriteUInt(sndid, bits)

	net.WriteBool(worldsnd)

	if worldsnd then
		writevec(worldsnd:Unpack())

		return net.Send(players)
	end

	net.WriteUInt(entid, maxplayers_bits)

	if ply:TestPVS(owner) then
		net.WriteBool(false)
	else
		net.WriteBool(true)

		if not y then
			x, y, z = x:Unpack()
		end

		writevec(x, y, z)
	end

	net.Send(ply)

	goto loop
end
