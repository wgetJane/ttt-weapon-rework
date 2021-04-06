TTTWR.MakeShotgun(SWEP,
	"spas",
	"",
	"Shotgun",
	9,
	60 / 75,
	0.085,
	7,
	6,
	-8.096, -8, 4.22,
	0, 0.98, -0.3
)


SWEP.ReloadTimeConsecutive = 0.5
SWEP.DeployTime = 0.5
SWEP.DeployAnimSpeed = 1.5

SWEP.PumpTime = 0.2

SWEP.PumpSound = "Weapon_Shotgun.Special1"
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"

-- pump animation can look fucky at really high ping, need to figure out why
function SWEP:ShotgunThink()
	if self:GetInserting()
		and self:GetActivity() == ACT_VM_PRIMARYATTACK
		and CurTime() > self:GetNextPrimaryFire() - self.Primary.Delay + self.PumpTime
	then
		self:SetInserting(false)

		self:SendWeaponAnim(ACT_SHOTGUN_PUMP)

		self:EmitSound(self.PumpSound, 50)
	end
end

function SWEP:OnPostShoot()
	self:SetInserting(true) -- hijack this dtvar
end

if SERVER then
	return
end

function SWEP:OnInsertClip()
	return self:EmitSound("Weapon_M3.Insertshell")
end

function SWEP:GetViewModelPosition(pos, ang)
	pos, ang = self.BaseClass.GetViewModelPosition(self, pos, ang)

	local fwd, rgt = ang:Forward(), ang:Right()

	for i = 1, 3 do
		pos[i] = pos[i] - rgt[i] * 1 + fwd[i] * 2
	end

	ang:RotateAroundAxis(ang:Up(), -1)

	return pos, ang
end
