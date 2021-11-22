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

function TTTWR:MakeSMG(class, model, ...)
	TTTWR.MakeWeapon(self, class, ...)

	TTTWR.CopySWEP(self, SWEP)

	self.ViewModel = "models/weapons/cstrike/c_smg_" .. model .. ".mdl"
	self.WorldModel = "models/weapons/w_smg_" .. model .. ".mdl"
end
