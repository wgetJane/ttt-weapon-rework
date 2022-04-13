local SWEP = weapons.GetStored("weapon_zm_sledge")

TTTWR.MakeWeapon(SWEP,
	"huge",
	"weapons/m249/m249-1.wav",
	11,
	0.09,
	0.1,
	3,
	150,
	-5.95, -5.119, 2.349,
	0, 0, 0
)

SWEP.HoldType = "shotgun"

SWEP.FalloffStart = 384
SWEP.FalloffEnd = 1280

SWEP.ConeResetMult = false

SWEP.ReloadTime = 5
SWEP.DeployTime = 1

SWEP.StoreLastPrimaryFire = true

SWEP.ActivityRemapIronsighted = {
	[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_AR2,
	[ACT_MP_RUN] = ACT_HL2MP_RUN_AR2,
	[ACT_MP_WALK] = ACT_HL2MP_WALK_AR2,
	[ACT_MP_JUMP] = ACT_HL2MP_JUMP_AR2,
	[ACT_MP_SWIM] = ACT_HL2MP_SWIM_AR2,
	[ACT_MP_SWIM_IDLE] = ACT_HL2MP_SWIM_IDLE_AR2,
	[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
	[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
}

function SWEP:PreSetupDataTables()
	self:NetworkVar("Float", 2, "Inaccuracy")
end

local remapclamp, clamp = TTTWR.RemapClamp, math.Clamp

local function getacc(self)
	return clamp(
		self:GetInaccuracy() - remapclamp(
			CurTime() - self:GetLastPrimaryFire(),
			0.2, 0.6, 0, 2000
		),
		0, 2000
	)
end

function SWEP:OnPostShoot()
	return self:SetInaccuracy(
		clamp(getacc(self) + 200, 0, 2000)
	)
end

local remap = math.Remap

function SWEP:GetPrimaryCone()
	if not self:GetIronsights() then
		return self.BaseClass.GetPrimaryCone(self)
	end

	return self.BaseClass.GetPrimaryCone(self) * remap(
		getacc(self), 0, 2000, 1, 0.2
	) * (1 / 0.85)
end

function SWEP:GetRecoilScale(sights)
	if sights then
		return remap(
			getacc(self), 0, 2000, 1, 0.1
		)
	end
end

if CLIENT then
	SWEP.Icon = "vgui/ttt/icon_m249"
end
