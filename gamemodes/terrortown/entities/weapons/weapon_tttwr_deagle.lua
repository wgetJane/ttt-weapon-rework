--fake weapon that just spawns weapon_zm_revolver before disappearing

if CLIENT then
	return
end

SWEP.AutoSpawnable = true

function SWEP:Initialize()
	local ent = ents.Create("weapon_zm_revolver")

	if not IsValid(ent) then
		return
	end

	ent._tttwr_dontreplace = true

	ent:SetPos(self:GetPos())
	ent:SetAngles(self:GetAngles())

	self:Remove()

	ent:Spawn()
	ent:PhysWake()
end
