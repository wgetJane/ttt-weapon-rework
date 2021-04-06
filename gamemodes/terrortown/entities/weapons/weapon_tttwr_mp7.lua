TTTWR.MakeSMG(SWEP,
	"mp7",
	"",
	"SMG1",
	13,
	60 / 750,
	0.03,
	1.15,
	30,
	-6.42, -4.8, 0.84,
	0.9, 0, 0
)


SWEP.AutoSpawnable = false -- not spawnable for now, since it feels like it doesn't fit in

SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"

if SERVER then
	return
end

SWEP.ViewModelFOV = 58

function SWEP:OnThink()
	if self.PlayReloadSound
		and CurTime() > self.PlayReloadSound
	then
		self.PlayReloadSound = nil

		if self:GetActivity() == ACT_VM_RELOAD then
			self:EmitSound("Weapon_SMG1.Reload")
		end
	end
end

function SWEP:OnStartReload()
	self.PlayReloadSound = CurTime() + 1
end
