TTTWR.MakeShotgun(SWEP,
	"xm",
	"xm1014",
	"tttwr/xm.ogg",
	6,
	60 / 240,
	0.085,
	6,
	8,
	-6.881, -9.214, 2.66,
	-0.101, -0.7, -0.201
)


SWEP.ReloadAnimSpeed = 1

if SERVER then
	resource.AddSingleFile("sound/tttwr/xm.ogg")
end
