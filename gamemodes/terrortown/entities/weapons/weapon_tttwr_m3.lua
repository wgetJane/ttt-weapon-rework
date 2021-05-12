TTTWR.MakeShotgun(SWEP,
	"m3",
	"m3super90",
	"weapons/xm1014/xm1014-1.wav",
	11,
	60 / 65,
	0.085,
	7,
	8,
	-7.65, -9, 3.4,
	0, 0, 0
)


SWEP.ShootSequence = 2

SWEP.PumpSound = "weapons/m3/m3_pump.wav"


function SWEP:ShotgunThink()
	if self.PlayPumpSound
		and CurTime() > self.PlayPumpSound
	then
		self.PlayPumpSound = nil

		if self:GetActivity() == ACT_VM_PRIMARYATTACK then
			local ent = CLIENT and self:GetOwnerViewModel() or self

			if ent == self or IsFirstTimePredicted() then
				ent:EmitSound(
					self.PumpSound, 75, 100, 1, CHAN_WEAPON
				)
			end

			return
		end
	end

	if self:GetActivity() == ACT_SHOTGUN_RELOAD_START
		and self:GetInserting()
	then
		local vm = self:GetOwnerViewModel()

		if vm and vm:IsSequenceFinished() then
			self:SetInserting(false)

			self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
		end
	end
end

function SWEP:OnPostShoot()
	self.PlayPumpSound = CurTime() + 0.4
end

-- this fucked up code is here to fix an animation glitch with the m3
-- this is really annoying, and glitches like these aren't present in the original viewmodels
-- path to m3's original viewmodel: "models/weapons/v_shot_m3super90.mdl"
function SWEP:ShotgunFinishReloadAnim()
	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
	self:SetVMSpeed(12)

	self:SetInserting(true)
end
