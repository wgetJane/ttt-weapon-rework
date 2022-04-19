local WasBought

function TTTWR:MakeEquipment(canbuy, cost)
	self.AutoSpawnable = false

	self.Kind = WEAPON_EQUIP

	self.spawnType = WEAPON_TYPE_SPECIAL

	self.WasBought = WasBought

	if canbuy then
		self.CanBuy = canbuy
	end

	if cost then
		self.BuyCost = cost

		if TTT2 then
			self.credits = cost
		end
	end

	if SERVER then
		return
	end

	self.Slot = 6
end

local min = math.min

function WasBought(self, buyer)
	if not IsValid(buyer) then
		return
	end

	local extra = self.ExtraAmmoOnBuy or self.Primary.ClipSize

	extra = min(
		extra,
		self.Primary.ClipMax - buyer:GetAmmoCount(self.Primary.Ammo)
	)

	if extra > 0 then
		buyer:GiveAmmo(extra, self.Primary.Ammo)
	end
end
