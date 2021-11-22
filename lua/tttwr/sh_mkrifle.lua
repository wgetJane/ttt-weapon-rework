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

function TTTWR:MakeRifle(class, model, ...)
	TTTWR.MakeWeapon(self, class, ...)

	TTTWR.CopySWEP(self, SWEP)

	self.ViewModel = "models/weapons/cstrike/c_rif_" .. model .. ".mdl"
	self.WorldModel = "models/weapons/w_rif_" .. model .. ".mdl"
end
