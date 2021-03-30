local PostSetupDataTables

function TTTWR:MakePistol(class, model, ...)
	TTTWR.MakeWeapon(self, class, ...)

	self.HoldType = "pistol"

	if not self.NoSights then
		self.PostSetupDataTables = PostSetupDataTables
	end

	self.Kind = WEAPON_PISTOL

	self.Primary.ClipMax = 120
	self.Primary.Ammo = "Pistol"

	self.AmmoEnt = "item_ammo_pistol_ttt"

	self.HeadshotMultiplier = 2.4

	self.ReloadTime = 2.5
	self.DeployTime = 0.4

	self.ViewModel = "models/weapons/cstrike/c_pist_" .. model .. ".mdl"
	self.WorldModel = "models/weapons/w_pist_" .. model .. ".mdl"

	if CLIENT then
		self.Slot = 1
	end
end

local function OnIronsightsChanged(self, name, old, new)
	return self:SetHoldType(new and "revolver" or "pistol")
end

function PostSetupDataTables(self)
	return self:NetworkVarNotify("IronsightsPredicted", OnIronsightsChanged)
end
