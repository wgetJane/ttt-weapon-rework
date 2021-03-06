TTTWR.MakeSMG(SWEP,
	"mp7",
	"",
	"weapons/smg1/smg1_fire1.wav",
	9,
	60 / 800,
	0.045,
	1,
	45,
	-5.88, -6.8, 1.83,
	0.9, 0.9, 0
)


SWEP.HoldType = "smg"

SWEP.AutoSpawnable = false -- not spawnable for now, since it feels like it doesn't fit in

SWEP.DeployTime = 0.75

SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"

if SERVER then
	return
end

function SWEP:OnThink()
	if self.PlayReloadSound
		and CurTime() > self.PlayReloadSound
	then
		self.PlayReloadSound = nil

		if self:GetActivity() == ACT_VM_RELOAD then
			self:EmitSound("weapons/smg1/smg1_reload.wav")
		end
	end
end

function SWEP:OnStartReload()
	self.PlayReloadSound = CurTime() + 1
end

function SWEP:GetViewModelPosition(pos, ang)
	pos, ang = self.BaseClass.GetViewModelPosition(self, pos, ang)

	local fwd, rgt, up = ang:Forward(), ang:Right(), ang:Up()

	for i = 1, 3 do
		pos[i] = pos[i] + fwd[i] * 2 - rgt[i] * 0.6 - up[i] * 1
	end

	ang:RotateAroundAxis(up, -0.9)

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

		util.Effect("EjectBrass_57", data)

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
