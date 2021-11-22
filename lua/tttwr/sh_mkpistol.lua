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

function TTTWR:MakePistol(class, model, ...)
	TTTWR.MakeWeapon(self, class, ...)

	TTTWR.CopySWEP(self, SWEP)

	self.Kind = WEAPON_PISTOL

	self.ViewModel = "models/weapons/cstrike/c_pist_" .. model .. ".mdl"
	self.WorldModel = "models/weapons/w_pist_" .. model .. ".mdl"
end

local function OnIronsightsChanged(self, name, old, new)
	return self:SetHoldType(new and "revolver" or "pistol")
end

function SWEP:PostSetupDataTables()
	if not self.NoSights then
		return self:NetworkVarNotify("IronsightsPredicted", OnIronsightsChanged)
	end
end
