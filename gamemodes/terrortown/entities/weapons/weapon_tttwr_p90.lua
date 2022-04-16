TTTWR.MakeSMG(SWEP,
	"p90",
	"p90",
	"weapons/p90/p90-1.wav",
	10,
	0.09, -- 666 rpm
	0.03,
	0.3,
	50
)


TTTWR.MakeZoomable(SWEP, 45, true)

SWEP.HoldType = "smg"

SWEP.IronsightsRecoilScale = 0.2
SWEP.IronsightsConeScale = 1 / 3

SWEP.ReloadTime = 3
SWEP.DeployTime = 1
