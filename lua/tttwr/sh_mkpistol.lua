local SWEP = {}

SWEP.HoldType = "pistol"

SWEP.AmmoEnt = "item_ammo_pistol_ttt"

SWEP.Primary = {
	ClipMax = 120,
	Ammo = "Pistol",
}

SWEP.ConeResetStart = 0.5
SWEP.ConeResetEnd = 1

SWEP.ReloadTime = 2.5
SWEP.DeployTime = 0.75
SWEP.DeployAnimSpeed = 1.25

if CLIENT then
	SWEP.Slot = 1
end

SWEP.ActivityRemapIronsighted = {
	[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_REVOLVER,
	[ACT_MP_RUN] = ACT_HL2MP_RUN_REVOLVER,
	[ACT_MP_WALK] = ACT_HL2MP_WALK_REVOLVER,
	[ACT_MP_JUMP] = ACT_HL2MP_JUMP_REVOLVER,
	[ACT_MP_SWIM] = ACT_HL2MP_SWIM_REVOLVER,
	[ACT_MP_SWIM_IDLE] = ACT_HL2MP_SWIM_IDLE_REVOLVER,
}

function TTTWR:MakePistol(class, model, ...)
	TTTWR.MakeWeapon(self, class, ...)

	TTTWR.CopySWEP(self, SWEP)

	self.Kind = WEAPON_PISTOL

	self.ViewModel = "models/weapons/cstrike/c_pist_" .. model .. ".mdl"
	self.WorldModel = "models/weapons/w_pist_" .. model .. ".mdl"
end
