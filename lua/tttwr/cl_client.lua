local function add(k, v)
	return LANG.AddToLanguage("english", k, v)
end
local function get(k)
	return LANG.GetTranslationFromLanguage(k, "english")
end

for k, v in pairs({
	fn57 = "Five-Seven",
	glock = "Glock",
	usp = "USP",
	p228 = "228 Compact",
	elites = "Dual Elites",

	mac10 = "MAC-10",
	mp5 = "MP5",
	ump = "UMP",
	p90 = "P90",

	m16 = "M16",
	ak47 = "AK-47",
	famas = "FAMAS",
	galil = "Galil",
	aug = "AUG",
	krieg = "Krieg",

	scout = "Scout",
	awp = "AWP",
	g3 = "G3",
	sg = "SG 550",

	m3 = "Pump Shotgun",
	xm = "Auto Shotgun",

	huge = "H.U.G.E-249",

	sim16 = "Silenced M16",

	deagle = "Deagle",
	sipist = "Silenced USP",
	tmp = "TMP Prototype",
}) do
	add("tttwr_" .. k .. "_name", v)
end

add("ammo_pistol", "Pistol ammo")
add("ammo_smg1", "Rifle ammo")
add("ammo_357", "Sniper ammo")
add("ammo_airboatgun", "LMG ammo")

add("sim16_desc", [[
M16 with a suppressor and slightly
better damage, accuracy, and recoil.
Uses assault rifle ammo.

Victims will not scream when killed.]])

add("ump_desc", get("ump_desc"):gsub("SMG ammo", "pistol ammo"))

add("newton_desc", get("newton_desc"):gsub("Push people", "Push and pull people", 1))
add("newton_help_pri", "{primaryfire} to push")
add("newton_help_sec", "{secondaryfire} to pull")

add("knife_desc", get("knife_desc"):gsub("Kills wounded targets instantly", "Kills with a backstab instantly", 1))

add("decoy_toomany", "You have too many decoys planted!")
add("decoy_broken2", "Your Decoy {num} was destroyed!")
add("decoy_menutitle", "Decoy control")
add("decoy_equip_lbl1", "Toggle decoy radar signals")
add("decoy_equip_lbl2", "Choose fake DNA location")
add("decoy_equip_cbox", "Decoy {num}")
add("equip_tooltip_decoy", "Decoy control")

add("equip_buycost", "This item costs {num} credit(s).")

add("sb_tag_priotarg", "PRIORITY TARGET")
add("priotarg_show1", "Kill this target for extra credits: {targ}")
add("priotarg_show2", "Kill these targets for extra credits: {targ1} and {targ2}")
add("priotarg_show3", "Kill these targets for extra credits: {targs}")
add("priotarg_kill", "You have been rewarded {num} credit(s) for the death of {targ}")

local matdata = {
	["$basetexture"] = Material("materials/tttwr/tttwr_icons.png"):GetName(),
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$translucent"] = 1,
}

for y, v in ipairs({
	{"fn57", "glock", "usp", "p228", "elites", "deagle",},
	{"mac10", "mp5", "ump", "p90", "tmp",},
	{"m16", "ak47", "famas", "galil", "aug", "krieg", "sim16",},
	{"scout", "awp", "g3", "sg", "m3", "xm",},
}) do
	for x, v in ipairs(v) do
		matdata["$basetexturetransform"] = (
			"center 0 0 scale 0.125 0.25 rotate 0 translate %s %s"
		):format((x - 1) * 0.125, (y - 1) * 0.25)

		CreateMaterial("tttwr_icons/" .. v, "UnlitGeneric", matdata)
	end
end
