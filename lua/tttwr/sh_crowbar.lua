local SWEP = weapons.GetStored("weapon_zm_improvised")

SWEP.Secondary.Delay = SWEP.Primary.Delay
SWEP.DeploySpeed = 28 / 15

sound.Add({
	name = "Weapon_Crowbar.Single",
	channel = CHAN_WEAPON,
	volume = 0.5,
	level = 75,
	pitch = 100,
	sound = "weapons/iceaxe/iceaxe_swing1.wav",
})

if SERVER then
	return
end

local PrimaryAttack = TTTWR.getfn(SWEP, "PrimaryAttack")

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()

	if IsValid(owner) then
		owner:SetAnimation(PLAYER_ATTACK1)
	end

	return PrimaryAttack(self)
end
