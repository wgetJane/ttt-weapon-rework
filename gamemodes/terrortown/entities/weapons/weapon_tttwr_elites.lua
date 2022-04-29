TTTWR.MakePistol(SWEP,
	"elites",
	"elite",
	"weapons/elite/elite-1.wav",
	15,
	60 / 360,
	0.03,
	2,
	30
)


TTTWR.MakeEquipment(SWEP,
	CreateConVar(
		"ttt_buyable_elites", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "server needs a map change to apply new value"
	):GetBool() and {ROLE_TRAITOR} or nil
)

SWEP.FakeDefaultEquipment = true

SWEP.HoldType = "duel"

SWEP.Secondary.Automatic = true

SWEP.HeadshotMultiplier = 1

SWEP.ReloadTime = 4
SWEP.DeployTime = 1
SWEP.DeployAnimSpeed = 1.15

SWEP.BulletTracer = 1

SWEP.WorldModel_Dropped = "models/weapons/w_pist_elite_dropped.mdl"
SWEP.WorldModel_Deployed = SWEP.WorldModel

SWEP.WorldModel = SWEP.WorldModel_Dropped

if CLIENT then
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "elites_desc",
	}
end

function SWEP:PreSetupDataTables()
	-- hacky workaround: ghost pistol entity for 3rd-person muzzleflash effect
	--  unfortunately, this has to be a networked entity
	--  because the effect doesn't work on clientside entities
	self:NetworkVar("Entity", 0, "GhostPistol")
	self:NetworkVar("Bool", 1, "FiringLeft")
end

function SWEP:PrimaryAttack()
	self.DisableEliteAutoAim = nil

	return self:PrimaryFire()
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextPrimaryFire() then
		return
	end

	self.DisableEliteAutoAim = true

	return self:PrimaryFire()
end

local tracedata = {
	mask = MASK_SHOT,
	output = {},
}

function SWEP:PreFireBullet(owner, bul)
	if self.DisableEliteAutoAim then
		return
	end

	local players = player.GetAll()

	local td = tracedata

	td.start = bul.Src
	td.filter = owner

	local lastvic = CurTime() - self:GetLastPrimaryFire() < 0.4
		and self.LastAutoAimVictim
		and Entity(self.LastAutoAimVictim)
	local lastvic_pos

	local nearest_dp, nearest_ply, nearest_pos = 0.92387953251129 -- 45 degree cone

	for i = 1, #players do
		local ply = players[i]

		if ply == owner
			or not ply:IsTerror()
			or owner:IsActiveTraitor() and ply:GetTraitor()
			or owner:IsActiveDetective() and ply:GetDetective()
			or ply:IsDormant()
			or SERVER and not ply:TestPVS(ply:GetPos())
		then
			goto cont
		end

		local bone = ply:LookupBone("ValveBiped.Bip01_Spine2")

		local pos = bone
			and ply:GetBoneMatrix(bone):GetTranslation()
			or ply:WorldSpaceCenter()

		local vec = pos - bul.Src
		vec:Normalize()

		local dp = bul.Dir:Dot(vec)

		if dp < nearest_dp and ply ~= lastvic then
			goto cont
		end

		td.endpos = pos

		if util.TraceLine(td).Entity ~= ply then
			goto cont
		end

		if ply == lastvic then
			lastvic_pos = pos

			goto cont
		end

		nearest_ply = ply
		nearest_pos = pos
		nearest_dp = dp

		::cont::
	end

	if lastvic_pos and not nearest_pos then
		nearest_ply = lastvic
		nearest_pos = lastvic_pos
	end

	if nearest_pos then
		if IsValid(lastvic) and nearest_ply ~= lastvic then
			bul.Damage = bul.Damage * 2
		end

		self.LastAutoAimVictim = nearest_ply:EntIndex()

		nearest_pos:Sub(bul.Src)
		nearest_pos:Normalize()

		bul.Dir = nearest_pos
	end
end

function SWEP:OnPreShoot()
	local clip = self:Clip1()

	local firingleft = clip % 2 == 0

	self.ShootSequence = clip == 1 and 7
		or clip == 2 and 4
		or (firingleft and 2 or 5) + (
			CurTime() - self:GetLastPrimaryFire() < 0.2
			and 1 or 0
		)

	return self:SetFiringLeft(firingleft)
end

function SWEP:OnPostShoot()
	self:SetVMSpeed(0.6)
end

function SWEP:GetTracerOrigin()
	if not self:GetFiringLeft() then
		return
	end

	local vm = self:GetOwnerViewModel()

	if not vm then
		return
	end

	local muz2 = vm:GetAttachment(2)

	if muz2 then
		return muz2.Pos
	end
end

if SERVER then
	function SWEP:Initialize()
		local ghost = self:GetGhostPistol()

		if not IsValid(ghost) then
			ghost = ents.Create("base_anim")

			ghost:SetParent(self)
			ghost:DrawShadow(false)
			ghost:SetModel(self.WorldModel_Deployed)
			ghost:SetModelScale(0)

			self:SetGhostPistol(ghost)
		end

		return self.BaseClass.Initialize(self)
	end

	return
end

function SWEP:Initialize()
	self:AddHUDHelp("elites_help_pri", "elites_help_sec", true)

	return self.BaseClass.Initialize(self)
end

function SWEP:DrawWorldModel(draw)
	do
	if not draw then
		goto ret
	end

	local owner = self:GetOwner()

	local active = IsValid(owner)
		and owner:GetActiveWeapon() == self

	local model = active
		and self.WorldModel_Deployed
		or self.WorldModel_Dropped

	if model ~= self.WorldModel then
		self.WorldModel = model

		self:SetModel(model)
	end

	if not active then
		goto ret
	end

	local ghost = self:GetGhostPistol()

	if not IsValid(ghost) then
		goto ret
	end

	if not ghost:GetNoDraw() then
		ghost:SetNoDraw(true)
	end

	if ghost:GetModelScale() ~= 1 then
		ghost:SetModelScale(1)
	end

	local muz2 = self:GetAttachment(2)

	if muz2 then
		local pos, ang = muz2.Pos, muz2.Ang

		local muz1 = ghost:GetAttachment(1)

		if muz1 then
			local ppos, pang = ghost:GetPos(), ghost:GetAngles()

			ppos:Sub(muz1.Pos)
			pang:Sub(muz1.Ang)

			ppos:Add(pos)
			pang:Add(ang)

			pos, ang = ppos, pang
		end

		ghost:SetPos(pos)
		ghost:SetAngles(ang)
	end

	::ret:: end
	return self.BaseClass.DrawWorldModel(self, draw)
end

function SWEP:FireAnimationEvent(pos, ang, event, options)
	if not (event == 20 or event == 5003)
		or self:GetFiringLeft()
	then
		goto ret
	end

	if event == 20 then
		if self:GetOwnerViewModel() then
			goto ret
		end

		local data = EffectData()
		data:SetEntity(self)
		data:SetFlags(90)

		local att = self:GetAttachment(4)

		data:SetOrigin(att and att.Pos or pos)
		data:SetAngles(att and att.Ang or ang)

		util.Effect("EjectBrass_9mm", data)
	else
		local ghost = self:GetGhostPistol()

		if not IsValid(ghost) then
			goto ret
		end

		local data = EffectData()
		data:SetEntity(ghost)
		data:SetFlags(2)

		util.Effect("MuzzleFlash", data)
	end

	do return true end

	::ret::
	return self.BaseClass.FireAnimationEvent(self, pos, ang, event, options)
end

function SWEP:DrawHUD()
	local owner = self:GetOwner()

	if not IsValid(owner) then
		return
	end

	local x, y = ScrW() * 0.5, ScrH() * 0.5

	local r, g = 0, 255

	if owner:GetTraitor() then
		r, g = g, r
	end

	surface.DrawCircle(x, y, 45 / owner:GetFOV() * y, r, g, 0, 128)

	return self.BaseClass.DrawHUD(self)
end
