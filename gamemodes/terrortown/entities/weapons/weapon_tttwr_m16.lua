TTTWR.MakeRifle(SWEP,
	"m16",
	"m4a1",
	"M4A1",
	23,
	60 / 400,
	0.018,
	2,
	30,
	-7.86, -4.6, 0.2,
	3.32, -1.35, -4.2
)


function SWEP:OnPostShoot()
	self.SetIdleAnimTime = CurTime() + self:SequenceDuration() - 0.25
end

function SWEP:OnThink()
	if self.SetIdleAnimTime and CurTime() > self.SetIdleAnimTime then
		self.SetIdleAnimTime = nil

		-- the m4a1's attack animation ends with a weird angle
		if self:GetActivity() == ACT_VM_PRIMARYATTACK then
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end
end
