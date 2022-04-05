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

function TTTWR:MakeSniper(class, model, sound, dmg, ...)
	TTTWR.MakeWeapon(self, class, sound, dmg, ...)

	TTTWR.MakeZoomable(self)

	TTTWR.CopySWEP(self, SWEP)

	self.BulletForce = dmg * 0.5

	self.ViewModel = "models/weapons/cstrike/c_snip_" .. model .. ".mdl"
	self.WorldModel = "models/weapons/w_snip_" .. model .. ".mdl"
end
