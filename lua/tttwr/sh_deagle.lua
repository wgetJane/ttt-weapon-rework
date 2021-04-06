local SWEP = weapons.GetStored("weapon_zm_revolver")

TTTWR.MakePistol(SWEP,
	"deagle",
	"deagle",
	"Deagle",
	33,
	60 / 150,
	0.015,
	6,
	8,
	-6.361, -3.701, 2.15,
	0, 0, 0
)


SWEP.ReloadTime = 2.5
SWEP.DeployTime = 0.7
SWEP.DeployAnimSpeed = 1

SWEP.BulletTracer = 1

SWEP.Primary.ClipMax = 36
SWEP.Primary.Ammo = "AlyxGun"

SWEP.AmmoEnt = "item_ammo_revolver_ttt"

SWEP.DryFireAnim = ACT_VM_DRYFIRE

SWEP.StoreLastPrimaryFire = true


local remap, clamp, ease = TTTWR.RemapClamp, math.Clamp, math.EaseInOut

function SWEP:GetPrimaryCone()
	local lastshoot = CurTime() - self:GetLastPrimaryFire()

	local scale = 1

	if lastshoot < 1.5 then
		scale = remap(ease(lastshoot * (1 / 1.5), 0.1, 0), 1, 0, 1, 4)

		if lastshoot < 0.2 then
			scale = scale / (2 - clamp(lastshoot * 5, 0, 1))
		end
	end

	return self.BaseClass.GetPrimaryCone(self) * scale
end

if CLIENT then
	return
end

function SWEP:GetHeadshotMultiplier()
	local lastshoot = CurTime() - self:GetLastPrimaryFire()

	local inmin, inmax, outmin, outmax = 5 / 6, 4 / 3, 1 / 0.66, 1 / 0.33

	if lastshoot > inmax then
		inmin, inmax, outmin, outmax = inmax, 1.5, outmax, 1 / 0.22
	end

	return remap(
		lastshoot,
		inmin, inmax,
		outmin, outmax
	)
end
