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


function SWEP:OnThink()
	-- the m4a1's attack animation ends with a weird angle
	if self:GetActivity() == ACT_VM_PRIMARYATTACK
		and CurTime() > self:GetLastPrimaryFire() + 0.25
	then
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end
