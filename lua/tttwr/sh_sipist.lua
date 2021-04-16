local SWEP = weapons.GetStored("weapon_ttt_sipistol")

TTTWR.MakePistol(SWEP,
	"sipist",
	"usp",
	{"weapons/usp/usp1.wav", 65, 90, 0.8},
	30,
	60 / 200,
	0.012,
	2,
	16,
	-5.91, -4, 2.84,
	-0.5, 0, 0
)

TTTWR.MakeEquipment(SWEP)


SWEP.ExtraAmmoOnBuy = 32

SWEP.WorldModel = "models/weapons/w_pist_usp_silencer.mdl"

SWEP.ShootSequence = 1
SWEP.DryFireAnim = ACT_VM_DRYFIRE_SILENCED
SWEP.ReloadAnim = ACT_VM_RELOAD_SILENCED
SWEP.DeployAnim = ACT_VM_DRAW_SILENCED
SWEP.IdleAnim = ACT_VM_IDLE_SILENCED


if CLIENT then
	SWEP.Icon = "vgui/ttt/icon_silenced"
end
