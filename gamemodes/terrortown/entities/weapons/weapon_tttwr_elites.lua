TTTWR.MakePistol(SWEP,
	"elites",
	"elite",
	"weapons/elite/elite-1.wav",
	19,
	60 / 360,
	0.03,
	2.4,
	30
)


SWEP.HoldType = "duel"

SWEP.HeadshotMultiplier = 2

SWEP.ReloadTime = 4
SWEP.DeployTime = 0.7

SWEP.WorldModel_Dropped = "models/weapons/w_pist_elite_dropped.mdl"
SWEP.WorldModel_Deployed = SWEP.WorldModel

SWEP.WorldModel = SWEP.WorldModel_Dropped

SWEP.StoreLastPrimaryFire = true


function SWEP:PreSetupDataTables()
	-- hacky workaround: ghost pistol entity for 3rd-person muzzleflash effect
	--  unfortunately, this has to be a networked entity
	--  because the effect doesn't work on clientside entities
	self:NetworkVar("Entity", 0, "GhostPistol")
	self:NetworkVar("Bool", 1, "FiringLeft")
end

-- idk why, but the shooting animation will randomly either look fine or look stupid
-- for some reason, there's a better chance of it looking fine when ping is higher
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

local remap = TTTWR.RemapClamp

-- more accurate when tap-firing
function SWEP:GetPrimaryCone()
	return self.BaseClass.GetPrimaryCone(self) * remap(
		CurTime() - self:GetLastPrimaryFire(),
		0.2, 0.4,
		1, 2 / 3
	)
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
		local data = EffectData()
		data:SetEntity(self)
		data:SetFlags(90)
		data:SetAttachment(4)

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
