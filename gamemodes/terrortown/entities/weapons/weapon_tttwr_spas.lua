TTTWR.MakeShotgun(SWEP,
	"spas",
	"",
	"weapons/shotgun/shotgun_fire7.wav",
	9,
	60 / 75,
	0.085,
	7,
	6,
	-8.08, -8, 2,
	1, 1.03, 0.1
)


SWEP.ReloadTimeConsecutive = 0.5
SWEP.DeployTime = 0.5
SWEP.DeployAnimSpeed = 1.5

SWEP.PumpTime = 0.2

SWEP.PumpSound = "weapons/shotgun/shotgun_cock.wav"
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"

-- pump animation can look fucky at really high ping, need to figure out why
function SWEP:ShotgunThink()
	if self:GetActivity() == ACT_VM_PRIMARYATTACK
		and CurTime() > self:GetNextPrimaryFire() - self.Primary.Delay + self.PumpTime
	then
		self:SendWeaponAnim(ACT_SHOTGUN_PUMP)

		local ent = CLIENT and self:GetOwnerViewModel() or self

		if ent ~= self and not IsFirstTimePredicted() then
			return
		end

		ent:EmitSound(
			self.PumpSound, 75, 100, 1, CHAN_AUTO
		)
	end
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
		pos[i] = pos[i] + fwd[i] * 2 - rgt[i]
	end

	ang:RotateAroundAxis(ang:Up(), -1)

	return pos, ang
end

function SWEP:FireAnimationEvent(pos, ang, event, options)
	if event == 21 then
		event = 5001
	elseif event == 6001 then
		local data = EffectData()
		data:SetFlags(90)

		local vm = self:GetOwnerViewModel()

		local att = vm
			and vm:GetAttachment(2)
			or self:GetAttachment(2)

		data:SetOrigin(att and att.Pos or pos)
		data:SetAngles(att and att.Ang or ang)

		util.Effect("EjectBrass_12Gauge", data)

		return true
	elseif event == 22 then
		local data = EffectData()
		data:SetEntity(self)
		data:SetFlags(2)

		util.Effect("MuzzleFlash", data)

		return true
	end

	return self.BaseClass.FireAnimationEvent(self, pos, ang, event, options)
end
