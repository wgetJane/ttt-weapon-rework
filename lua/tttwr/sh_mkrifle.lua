local GetPrimaryCone

function TTTWR:MakeRifle(class, model, ...)
	TTTWR.MakeWeapon(self, class, ...)

	self.Primary.ClipMax = 60
	self.Primary.Ammo = "smg1"

	self.AmmoEnt = "item_ammo_smg1_ttt"

	self.HeadshotMultiplier = 2.5

	self.ReloadTime = 3
	self.DeployTime = 0.75

	self.GetPrimaryCone = GetPrimaryCone

	self.StoreLastPrimaryFire = true

	self.ViewModel = "models/weapons/cstrike/c_rif_" .. model .. ".mdl"
	self.WorldModel = "models/weapons/w_rif_" .. model .. ".mdl"
end

local remap = TTTWR.RemapClamp

-- more accurate when tap-firing
function GetPrimaryCone(self)
	return self.BaseClass.GetPrimaryCone(self) * remap(
		CurTime() - self:GetLastPrimaryFire(),
		0.2, 0.4,
		1.125, 0.75
	)
end
