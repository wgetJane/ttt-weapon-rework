local SWEP = {}

SWEP.AmmoEnt = "item_ammo_smg1_ttt"

SWEP.Primary = {
	ClipMax = 60,
	Ammo = "smg1",
}

SWEP.LimbshotMultiplier = 0.5

SWEP.FalloffStart = 384
SWEP.FalloffEnd = 1280

SWEP.ReloadTime = 3

SWEP.ActivityRemapIronsighted = {
	[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_RPG,
	[ACT_MP_RUN] = ACT_HL2MP_RUN_RPG,
	[ACT_MP_WALK] = ACT_HL2MP_WALK_RPG,
	[ACT_MP_JUMP] = ACT_HL2MP_JUMP_RPG,
	[ACT_MP_SWIM] = ACT_HL2MP_SWIM_RPG,
	[ACT_MP_SWIM_IDLE] = ACT_HL2MP_SWIM_IDLE_RPG,
}

function TTTWR:MakeRifle(class, model, ...)
	TTTWR.MakeWeapon(self, class, ...)

	TTTWR.CopySWEP(self, SWEP)

	self.ViewModel = "models/weapons/cstrike/c_rif_" .. model .. ".mdl"
	self.WorldModel = "models/weapons/w_rif_" .. model .. ".mdl"
end
