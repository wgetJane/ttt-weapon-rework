local SWEP = weapons.GetStored("weapon_zm_sledge")

TTTWR.MakeWeapon(SWEP,
	"huge",
	"weapons/m249/m249-1.wav",
	7,
	60 / 1000,
	0.1,
	2,
	200,
	-5.95, -5.119, 2.349,
	0, 0, 0
)

SWEP.HoldType = "shotgun"

SWEP.Primary.ClipMax = 200

SWEP.ReloadTime = 5
SWEP.DeployTime = 0.75

SWEP.StoreLastPrimaryFire = true

function SWEP:PreSetupDataTables()
	-- this is a 32-bit signed integer, which is overkill for what im using it for
	-- again, i can use the net library instead, but im lazy
	self:NetworkVar("Int", 0, "ConsecutiveShots")
end

function SWEP:OnPreShoot()
	return self:SetConsecutiveShots(
		(CurTime() - self:GetLastPrimaryFire() < 0.2)
		and (self:GetConsecutiveShots() + 1)
		or 0
	)
end

local remap = TTTWR.RemapClamp

function SWEP:GetPrimaryCone()
	return (
		self:GetIronsights()
		and remap(
			CurTime() - self:GetLastPrimaryFire(),
			0.1, 0.2,
			remap(self:GetConsecutiveShots(), 1, 20, 1, 0.05), 1
		) * (1 / 0.85)
		or 1
	) * self.BaseClass.GetPrimaryCone(self)
end

function SWEP:GetRecoilScale(sights)
	if not sights then
		return
	end

	return remap(
		CurTime() - self:GetLastPrimaryFire(),
		0.1, 0.2,
		remap(self:GetConsecutiveShots(), 1, 20, 1, 0.125), 1
	)
end

if CLIENT then
	SWEP.Icon = "vgui/ttt/icon_m249"
end
