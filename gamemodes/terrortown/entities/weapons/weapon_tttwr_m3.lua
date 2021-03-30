TTTWR.MakeShotgun(SWEP,
	"m3",
	"m3super90",
	"M3",
	11,
	60 / 70,
	0.085,
	7,
	8,
	-7.65, -8, 2,
	2, 0, 0
)


SWEP.ShootSequence = 2

SWEP.Primary.Sound = "Weapon_XM1014.Single"
SWEP.PumpSound = "Weapon_M3.Pump"


function SWEP:ShotgunThink()
	if self.PlayPumpSound
		and CurTime() > self.PlayPumpSound
	then
		self.PlayPumpSound = nil

		if self:GetActivity() == ACT_VM_PRIMARYATTACK then
			self:EmitSound(self.PumpSound, 50)
		end
	end
end

function SWEP:OnPostShoot()
	self.PlayPumpSound = CurTime() + 0.4
end

-- this fucked up code is here to make an animation glitch with the m3 less noticeable
function SWEP:ShotgunFinishReloadAnim()
	if CLIENT then
		self.m3_preddiff = CurTime() - UnPredictedCurTime()

		if IsFirstTimePredicted() then
			self.m3_firstpreddiff = self.m3_preddiff > 0.125
				and self.m3_preddiff
				or nil
		end
	end

	if SERVER
		or self.m3_firstpreddiff
		and self.m3_preddiff < self.m3_firstpreddiff * 0.6
	then
		self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	else
		self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
		self:SetVMSpeed(-0.01)
	end
end
