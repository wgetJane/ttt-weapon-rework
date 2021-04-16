local SWEP = weapons.GetStored("weapon_ttt_stungun")

local GetHeadshotMultiplier = TTTWR.getfn(SWEP, "GetHeadshotMultiplier")

TTTWR.MakeSMG(SWEP,
	"tmp",
	"tmp",
	{"weapons/tmp/tmp-1.wav", 70, 90},
	9,
	60 / 600,
	0.02,
	1.2,
	30,
	-6.8, -9, 2.66,
	0, 0.25, 0
)


TTTWR.MakeEquipment(SWEP)

SWEP.IsSilent = true

SWEP.GetHeadshotMultiplier = GetHeadshotMultiplier
SWEP.HeadshotMultiplier = 4.5

SWEP.ShootSequence = 3


function SWEP:OnThink()
	-- the tmp's deploy animation ends with a weird angle
	if self:GetActivity() == ACT_VM_DRAW then
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end

if CLIENT then
	return
end

local rand = math.Rand

local sendrecoil = TTTWR.SendRecoil

local function bulletCallback(attacker, trace, dmginfo)
	local victim = trace.Entity

	if not IsValid(victim) then
		return
	end

	local eff = EffectData()

	eff:SetEntity(victim)
	eff:SetMagnitude(3)
	eff:SetScale(2)

	util.Effect("TeslaHitboxes", eff, true, true)

	if not victim:IsPlayer() then
		return
	end

	for i = 1, 2 do
		-- inverse normal distribution
		local r = rand(-0.75, 0.75) + rand(-0.25, 0.25)
		r = (r < 0 and -1 or 1) - r

		sendrecoil(victim, r * 10, 1 / 15, i)
	end
end

function SWEP:PreFireBullet(owner, bul)
	bul.Callback = bulletCallback
end
