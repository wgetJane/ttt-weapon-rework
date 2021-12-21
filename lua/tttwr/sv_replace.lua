--[[ todo list:
 - make pistols and grenades spawn more often
 - consistent weapon spawns for all rounds until map change (this rewards players for memorisation)
 - better sampling algorithm (reservoir sampling?) instead of shuffling tables over and over
]]

local totttwr = {
	weapon_zm_pistol = {
		ammo = "item_ammo_pistol_ttt",
		"weapon_tttwr_fn57",
		"weapon_tttwr_glock",
		"weapon_tttwr_usp",
		"weapon_tttwr_p228",
		"weapon_tttwr_elites",
	},
	weapon_ttt_m16 = {--weapon_zm_mac10 = {
		ammo = "item_ammo_pistol_ttt",
		"weapon_tttwr_mac10",
		"weapon_tttwr_mp5",
		"weapon_tttwr_ump",
		"weapon_tttwr_p90",
		--"weapon_tttwr_mp7",
	},
	weapon_zm_mac10 = {--weapon_ttt_m16 = {
		ammo = "item_ammo_smg1_ttt",
		"weapon_tttwr_m16",
		"weapon_tttwr_ak47",
		"weapon_tttwr_famas",
		"weapon_tttwr_galil",
		"weapon_tttwr_aug",
		"weapon_tttwr_sg",
	},
	weapon_zm_rifle = {
		ammo = "item_ammo_357_ttt",
		"weapon_tttwr_scout",
		"weapon_tttwr_awp",
		"weapon_tttwr_g3",
		"weapon_tttwr_krieg",
	},
	weapon_zm_shotgun = {
		ammo = "item_box_buckshot_ttt",
		"weapon_tttwr_m3",
		"weapon_tttwr_xm",
		"weapon_tttwr_spas",
	},
	weapon_zm_revolver = {
		ammo = "item_ammo_revolver_ttt",
		checkactive = true,
		"weapon_zm_revolver",
		"weapon_tttwr_python",
	},
}
totttwr.weapon_ttt_glock = totttwr.weapon_zm_pistol

for k, v in pairs(totttwr) do
	local SWEP = weapons.GetStored(k)

	if not v.checkactive then
		SWEP.AutoSpawnable = false
	end

	--SWEP.AmmoEnt = v.ammo

	v.n = 0

	function SWEP:Initialize()
		self.BaseClass.Initialize(self)

		if (v.checkactive and GetRoundState() == ROUND_ACTIVE)
			or not IsValid(self)
		then
			return
		end

		if self._tttwr_dontreplace then
			self._tttwr_dontreplace = nil

			return
		end

		if v.n < 1 then
			table.Shuffle(v)

			v.n = #v
		end

		local new = v[v.n]

		v.n = v.n - 1

		local ent = new and ents.Create(new)

		if not (ent and IsValid(ent)) then
			return
		end

		if totttwr[new] then
			ent._tttwr_dontreplace = true
		end

		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:SetName(self:GetName())
		ent:SetKeyValue("spawnflags", self:GetSpawnFlags())

		self:Remove()

		ent:Spawn()
		ent:PhysWake()
	end
end
