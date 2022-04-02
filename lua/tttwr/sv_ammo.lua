local ENT = scripted_ents.GetStored("base_ammo_ttt").t

function ENT:OnTakeDamage(d)
	return self:TakePhysicsDamage(d)
end

local min = math.min

function ENT:Touch(ent)
	if not (
		not self.tickRemoval
		and IsValid(ent)
		and ent:IsPlayer()
		and self:CheckForWeapon(ent)
		and self:PlayerCanPickup(ent)
	) then
		return
	end

	local ammo = ent:GetAmmoCount(self.AmmoType)

	if ammo >= self.AmmoMax then
		return
	end

	local give = self.AmmoAmount

	give = min(give, self.AmmoMax - ammo)

	ent:GiveAmmo(give, self.AmmoType)

	self.AmmoAmount = self.AmmoAmount - give

	if self.AmmoAmount > 0 then
		return
	end

	self.tickRemoval = true

	self:Remove()
end

local function makedropammofn(getamt, removeammo)
	return function(ply)
		if not IsValid(ply) then
			return
		end

		local wep = ply:GetActiveWeapon()

		if not (IsValid(wep) and wep.AmmoEnt) then
			return
		end

		local amt = getamt(wep, ply)

		if amt < 1 then
			return
		end

		local pos, ang = ply:GetShootPos(), ply:EyeAngles()

		local fwd, rgt, up = ang:Forward(), ang:Right(), ang:Up()

		local dir = fwd * 32
		rgt:Mul(6)
		up:Mul(-5)
		dir:Add(rgt)
		dir:Add(up)

		if util.QuickTrace(pos, dir, ply).HitWorld then
			return
		end

		removeammo(wep, ply, amt)

		ply:AnimPerformGesture(ACT_GMOD_GESTURE_ITEM_GIVE)

		local box = ents.Create(wep.AmmoEnt)

		if not IsValid(box) then
			return
		end

		pos:Add(dir)

		box:SetPos(pos)
		box:SetOwner(ply)
		box:Spawn()
		box:PhysWake()

		local phys = box:GetPhysicsObject()

		if IsValid(phys) then
			fwd:Mul(1000)

			phys:ApplyForceCenter(fwd)
			phys:ApplyForceOffset(VectorRand(), vector_origin)
		end

		box.AmmoAmount = amt

		timer.Simple(2, function()
			if IsValid(box) then
				box:SetOwner(nil)
			end
		end)
	end
end

concommand.Remove("ttt_dropammo")
concommand.Add("ttt_dropammo", makedropammofn(
	function(wep, ply)
		return min(
			wep.Primary.ClipSize,
			ply:GetAmmoCount(wep.Primary.Ammo)
		)
	end,
	function(wep, ply, amt)
		return ply:RemoveAmmo(amt, wep.Primary.Ammo)
	end
))

concommand.Add("ttt_dropclip", makedropammofn(
	function(wep)
		return wep:Clip1()
	end,
	function(wep)
		return wep:SetClip1(0)
	end
))
