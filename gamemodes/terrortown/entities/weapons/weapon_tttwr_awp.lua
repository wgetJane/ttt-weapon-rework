TTTWR.MakeSniper(SWEP,
	"awp",
	"awp",
	"AWP",
	75,
	2,
	0.001,
	10,
	5
)


SWEP.HeadshotMultiplier = 1 / 0.375

SWEP.ReloadTime = 4


function SWEP:OnPostShoot()
	self:SetVMSpeed(0.8)
end

if CLIENT then
	return
end

local abs = math.abs

function SWEP:OnEntityTakeDamage(victim, dmginfo)
	if not victim:IsPlayer() then
		dmginfo:ScaleDamage(4 / 3)

		return
	end

	if not victim:OnGround() then
		return
	end

	victim:SetGroundEntity(nil)

	victim.was_pushed = {
		att = dmginfo:GetAttacker(),
		t = CurTime(),
		wep = self:GetClass(),
	}

	local frc = dmginfo:GetDamageForce()
	frc[3] = abs(frc[3])

	dmginfo:SetDamageForce(frc)
end
