local SWEP = {}

SWEP.AmmoEnt = "item_ammo_357_ttt"

SWEP.Primary = {
	ClipMax = 20,
	Ammo = "357",
}

SWEP.HeadshotMultiplier = 2
SWEP.LimbshotMultiplier = 0.5

SWEP.FalloffMult = false
SWEP.ConeResetMult = false

SWEP.ReloadTime = 3.5

SWEP.BulletDistance = 16384
SWEP.BulletTracer = 1

SWEP.ActivityRemap = {
	[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG,
	[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG,
}

SWEP.ActivityRemapIronsighted = {
	[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_RPG,
	[ACT_MP_RUN] = ACT_HL2MP_RUN_RPG,
	[ACT_MP_WALK] = ACT_HL2MP_WALK_RPG,
	[ACT_MP_JUMP] = ACT_HL2MP_JUMP_RPG,
	[ACT_MP_SWIM] = ACT_HL2MP_SWIM_RPG,
	[ACT_MP_SWIM_IDLE] = ACT_HL2MP_SWIM_IDLE_RPG,
}

function TTTWR:MakeSniper(class, model, sound, dmg, ...)
	TTTWR.MakeWeapon(self, class, sound, dmg, ...)

	TTTWR.MakeZoomable(self)

	TTTWR.CopySWEP(self, SWEP)

	self.BulletForce = dmg * 0.5

	self.ViewModel = "models/weapons/cstrike/c_snip_" .. model .. ".mdl"
	self.WorldModel = "models/weapons/w_snip_" .. model .. ".mdl"
end
