local GetHeadshotMultiplier

function TTTWR:MakeSMG(class, model, ...)
	TTTWR.MakeWeapon(self, class, ...)

	self.Primary.ClipMax = 120
	self.Primary.Ammo = "Pistol"

	self.AmmoEnt = "item_ammo_pistol_ttt"

	if GetHeadshotMultiplier then
		self.GetHeadshotMultiplier = GetHeadshotMultiplier
	end

	self.ReloadTime = 2.75
	self.DeployTime = 0.6

	self.ViewModel = "models/weapons/cstrike/c_smg_" .. model .. ".mdl"
	self.WorldModel = "models/weapons/w_smg_" .. model .. ".mdl"
end

if CLIENT then
	return
end

local max = math.max

function GetHeadshotMultiplier(self, victim, dmginfo)
	local att = dmginfo:GetAttacker()
	if not IsValid(att) then
		return 2
	end

	return 1.7 + max(0,
		1.5 - 0.002 * max(0,
			victim:GetPos():Distance(att:GetPos()) - 150
		) ^ 1.25
	)
end
