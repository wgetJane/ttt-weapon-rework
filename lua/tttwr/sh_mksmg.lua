local SWEP = {}

SWEP.AmmoEnt = "item_ammo_pistol_ttt"

SWEP.Primary = {
	ClipMax = 120,
	Ammo = "Pistol",
}

SWEP.HeadshotMultiplier = 4 / 3
SWEP.LimbshotMultiplier = 5 / 6

SWEP.ReloadTime = 2.75
SWEP.DeployTime = 0.875

SWEP.ActivityRemapIronsighted = {
	[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_RPG,
	[ACT_MP_RUN] = ACT_HL2MP_RUN_RPG,
	[ACT_MP_WALK] = ACT_HL2MP_WALK_RPG,
	[ACT_MP_JUMP] = ACT_HL2MP_JUMP_RPG,
	[ACT_MP_SWIM] = ACT_HL2MP_SWIM_RPG,
	[ACT_MP_SWIM_IDLE] = ACT_HL2MP_SWIM_IDLE_RPG,
}

function TTTWR:MakeSMG(class, model, ...)
	TTTWR.MakeWeapon(self, class, ...)

	TTTWR.CopySWEP(self, SWEP)

	self.spawnType = WEAPON_TYPE_HEAVY

	self.ViewModel = "models/weapons/cstrike/c_smg_" .. model .. ".mdl"
	self.WorldModel = "models/weapons/w_smg_" .. model .. ".mdl"
end
