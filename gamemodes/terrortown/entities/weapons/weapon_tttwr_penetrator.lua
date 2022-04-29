TTTWR.MakePistol(SWEP,
	"penetrator",
	"deagle",
	{"weapons/deagle/deagle-1.wav", 90, 133},
	35,
	60 / 150,
	0,
	4,
	8,
	-6.361, -3.701, 2.15,
	0, 0, 0
)


TTTWR.MakeEquipment(SWEP,
	CreateConVar(
		"ttt_buyable_penetrator", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "server needs a map change to apply new value"
	):GetBool() and {ROLE_DETECTIVE} or nil
)

SWEP.FakeDefaultEquipment = true

SWEP.ExtraAmmoOnBuy = 24

SWEP.HeadshotMultiplier = 17 / 7

SWEP.ConeResetMult = false

SWEP.ReloadTime = 2.5
SWEP.DeployTime = 0.75
SWEP.DeployAnimSpeed = 1.15

SWEP.BulletTracer = 1

SWEP.Primary.ClipMax = 36
SWEP.Primary.Ammo = "AlyxGun"

SWEP.AmmoEnt = "item_ammo_revolver_ttt"

SWEP.DryFireAnim = ACT_VM_DRYFIRE

if CLIENT then
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "penetrator_desc",
	}
end

function SWEP:Initialize()
	self:SetColor(Color(77, 153, 255))

	return self.BaseClass.Initialize(self)
end

local tracedata = {
	endpos = Vector(),
	mask = CONTENTS_SOLID + CONTENTS_MONSTER,
	ignoreworld = true,
	output = {},
}

function SWEP:PreFireBullet(owner, bul)
	local td = tracedata

	td.start = bul.Src

	for i = 1, 3 do
		td.endpos[i] = bul.Src[i] + bul.Dir[i] * bul.Distance
	end

	td.filter = owner

	local hitpos

	for _ = 1, 64 do
		local tr = util.TraceLine(td)

		local ent = tr.Entity

		if ent then
			if istable(td.filter) then
				table.insert(td.filter, ent)
			else
				td.filter = {owner, ent}
			end

			td.start = tr.HitPos

			if ent:IsPlayer() then
				hitpos = tr.HitPos
			end
		end

		if tr.Fraction == 1 then
			break
		end
	end

	td.filter = nil

	if hitpos then
		bul.Src = hitpos
	end
end

if SERVER then
	return
end

function SWEP:PreDrawViewModel()
	render.SetColorModulation(0.3, 0.6, 1)
end

function SWEP:ViewModelDrawn()
	render.SetColorModulation(1, 1, 1)
end
