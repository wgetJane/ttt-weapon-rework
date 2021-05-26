local PreSetupDataTables, OnPostShoot, GetPrimaryCone, GetHeadshotMultiplier

function TTTWR:MakeRifle(class, model, ...)
	TTTWR.MakeWeapon(self, class, ...)

	self.Primary.ClipMax = 60
	self.Primary.Ammo = "smg1"

	self.AmmoEnt = "item_ammo_smg1_ttt"

	self.HeadshotMultiplier = 2.5

	self.ReloadTime = 3
	self.DeployTime = 0.75

	self.PreSetupDataTables = PreSetupDataTables
	self.OnPostShoot = OnPostShoot
	self.GetPrimaryCone = GetPrimaryCone

	if SERVER then
		self.GetHeadshotMultiplier = GetHeadshotMultiplier
	end

	self.StoreLastPrimaryFire = true

	self.ViewModel = "models/weapons/cstrike/c_rif_" .. model .. ".mdl"
	self.WorldModel = "models/weapons/w_rif_" .. model .. ".mdl"
end

function PreSetupDataTables(self)
	self:NetworkVar("Float", 2, "Inaccuracy")
end

local remap, clamp = TTTWR.RemapClamp, math.Clamp

local function getacc(self)
	return clamp(
		self:GetInaccuracy() - remap(
			CurTime() - self:GetLastPrimaryFire(),
			0.2, 0.4, 0, 2000
		),
		0, 2000
	)
end

function OnPostShoot(self)
	local acc = getacc(self)

	return self:SetInaccuracy(
		clamp(acc + clamp(acc, 250, 500), 0, 2000)
	)
end

function GetPrimaryCone(self)
	local scale = 0.5 + getacc(self) * 0.001

	if scale > 1 then
		scale = remap(scale, 1, 2.5, 1, 0.045 / self.Primary.Cone)
	end

	return self.BaseClass.GetPrimaryCone(self) * scale
end

if CLIENT then
	return
end

function GetHeadshotMultiplier(self)
	return remap(
		getacc(self), 500, 2000, self.HeadshotMultiplier, 1
	)
end
