if TTTWR == false then
	return
end

TTTWR = {
	fns = TTTWR and TTTWR.fns or {},
	weakkeys = {__mode = "k"},
	sounds = {},
}

local included = {}

local function incl(name, cl)
	name = "tttwr/"
		.. (cl and "cl_" or cl == false and "sv_" or "sh_")
		.. name
		.. ".lua"

	if cl ~= false and SERVER then
		AddCSLuaFile(name)
	end

	if not cl or CLIENT then
		local fn = include(name)

		if isfunction(fn) then
			included[#included + 1] = fn
		end
	end
end

local function PostGamemodeLoaded()
	PostGamemodeLoaded = nil
	hook.Remove("PostGamemodeLoaded", "tttwr_PostGamemodeLoaded")

	-- kind of a messy way to make sure this only runs in ttt
	if GAMEMODE_NAME ~= "terrortown" then
		TTTWR = false

		incl, included = nil, nil

		return
	end

	TTTWR.loaded = true

	TTTWR.maxplayers_bits = math.ceil(math.log(game.MaxPlayers()) / math.log(2))

	function TTTWR:getfn(fnname)
		TTTWR.fns = TTTWR.fns or {}

		local id = (self.ClassName or tostring(self)) .. "\n" .. fnname

		local fn = TTTWR.fns[id] or self[fnname]

		TTTWR.fns[id] = fn

		return fn
	end

	incl("client", true)

	incl("decoy", true)

	incl("priotargs", true)

	local ammpist = scripted_ents.GetStored("item_ammo_pistol_ttt").t
	ammpist.AmmoAmount = 60
	ammpist.AmmoMax = 120

	-- allow these weapons to be deployed near-instantly
	for _, v in pairs({
		"weapon_ttt_binoculars",
		"weapon_ttt_cse",
		"weapon_ttt_decoy",
		"weapon_ttt_defuser",
		"weapon_ttt_health_station",
		"weapon_ttt_radio",
		"weapon_ttt_teleport",
		"weapon_ttt_unarmed",
		"weapon_ttt_wtester",
	}) do
		weapons.GetStored(v).DeploySpeed = 12
	end

	incl("crowbar")

	incl("deagle")

	incl("huge")

	incl("knife")

	incl("flaregun")

	incl("newton")

	incl("sipist")

	incl("stungun")

	incl("magneto")

	incl("equip")

	incl("movement")

	incl("sound")

	if CLIENT then
		goto skip
	end

	resource.AddSingleFile("materials/tttwr/tttwr_icons.png")

	incl("decoy", false)

	incl("ammo", false)

	incl("scaledmg", false)

	incl("death", false)

	incl("replace", false)

	incl("hooks", false)

	::skip::

	for i = 1, #included do
		included[i]()
	end

	incl, included = nil, nil
end

local min, max = math.min, math.max

function TTTWR.RemapClamp(val, a, b, c, d)
	return c + (d - c) * min(1, max(0, (val - a) / (b - a)))
end

TTTWR.FrameTime = (function(ft)
	local a = Angle(0.015)

	if ft == a[1] then
		return 0.015
	end

	--for r = 10, 100 do
	for r = math.floor(1 / ft), math.ceil(1 / ft) do
		a[1] = 1 / r

		if ft == a[1] then
			return 1 / r
		end
	end

	return ft
end)(engine.TickInterval())

incl("mkweapon")

incl("mkpistol")
incl("mksmg")
incl("mkrifle")
incl("mksniper")
incl("mkshotgun")

incl("mkzoomable")
incl("mkequip")

if GAMEMODE then
	PostGamemodeLoaded()
else
	hook.Add("PostGamemodeLoaded", "tttwr_PostGamemodeLoaded", PostGamemodeLoaded)
end
