local SWEP = weapons.GetStored("weapon_ttt_decoy")
local ENT = scripted_ents.GetStored("ttt_decoy").t

SWEP.Primary.Damage = -1
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.1

SWEP.AllowDrop = true

SWEP.OnDrop = nil

util.AddNetworkString("tttwr_decoy")

local function updatedecoys(ply, clear)
	if not IsValid(ply) then
		return
	end

	net.Start("tttwr_decoy")

	net.WriteFloat(CurTime())

	if not ply.decoys then
		ply.decoys = {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL}
	end

	local dna = 0

	local i = 8

	::loop::

	if clear and (
		clear == true
		or clear == i
		or clear == ply.decoys[i]
	) then
		ply.decoys[i] = NULL
	end

	local ent = ply.decoys[i]

	if IsValid(ent) then
		net.WriteBool(true)

		if ent == ply.decoy then
			dna = i
		end

		net.WriteVector(
			ent.FakeSignalPos
			or ent:WorldSpaceCenter()
		)

		net.WriteBool(ent.NoRadarSignal ~= true)
	else
		net.WriteBool(false)
	end

	i = i - 1
	if i ~= 0 then
		goto loop
	end

	net.WriteUInt(dna, 4)

	net.Send(ply)
end

net.Receive("tttwr_decoy", function(len, ply)
	if not (IsValid(ply) and ply:IsTerror() and ply.decoys) then
		return
	end

	if net.ReadBool() then
		local decoy = ply.decoys[net.ReadUInt(4)]

		ply.decoy = IsValid(decoy) and decoy or nil
	else
		local decoy = ply.decoys[net.ReadUInt(3) + 1]

		if IsValid(decoy) then
			decoy.NoRadarSignal = not net.ReadBool()
		end
	end

	return updatedecoys(ply)
end)

hook.Add("TTTPrepareRound", "tttwr_decoy_TTTPrepareRound", function()
	local players = player.GetAll() --player.GetHumans()

	for i = 1, #players do
		updatedecoys(players[i], true)
	end
end)

local DecoyStick = TTTWR.getfn(SWEP, "DecoyStick")

function SWEP:DecoyStick()
	local owner = self:GetOwner()

	if not (
		IsValid(owner)
		and owner:GetTraitor()
		and owner.decoys
	) then
		return
	end

	self._stickindex = nil

	for i = 1, 8 do
		if not IsValid(owner.decoys[i]) then
			self._stickindex = i

			break
		end
	end

	if self._stickindex then
		return DecoyStick(self)
	else
		LANG.Msg(owner, "decoy_toomany")
	end
end

local placed = setmetatable({}, TTTWR.weakkeys)
local placed_n = 0

function SWEP:PlacedDecoy(decoy)
	local owner = self:GetOwner()

	decoy.DecoyOwner = owner

	decoy:SetOwner()

	decoy.FakeSignalPos = owner:WorldSpaceCenter()

	placed[decoy] = true
	placed_n = placed_n + 1

	self:TakePrimaryAmmo(1)

	if not IsValid(owner.decoy) then
		owner.decoy = decoy
	end

	owner.decoys[self._stickindex] = decoy

	if self:Clip1() <= 0 then
		self:Remove()
	end

	updatedecoys(owner)
end

function ENT:UseOverride(user)
	if not (
		IsValid(user)
		and self.DecoyOwner == user
	) then
		return
	end

	if user:CanCarryType(self.WeaponKind or WEAPON_EQUIP2) then
		local decoy = user:Give("weapon_ttt_decoy")

		if IsValid(decoy) then
			decoy:SetClip1(1)
		end

		self:Remove()

		return
	end

	local decoy = user:GetWeapon("weapon_ttt_decoy")

	if IsValid(decoy) and decoy:Clip1() < decoy.Primary.ClipSize then
		decoy:SetClip1(decoy:Clip1() + 1)

		self:Remove()

		return
	end

	LANG.Msg(user, "decoy_no_room")
end

function ENT:OnRemove()
	placed[self] = nil
	placed_n = placed_n - 1

	local owner = self.DecoyOwner

	if not IsValid(owner) then
		return
	end

	if self == owner.decoy and owner.decoys then
		owner.decoy = nil

		for i = 1, 8 do
			local ent = owner.decoys[i]

			if ent ~= self and IsValid(ent) then
				owner.decoy = ent

				break
			end
		end
	end

	updatedecoys(owner, self)
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)

	self:SetHealth(self:Health() - dmginfo:GetDamage())

	if self:Health() > 0 then
		return
	end

	local pos = self:WorldSpaceCenter()

	local eff = EffectData()
	eff:SetOrigin(pos)

	util.Effect("cball_explode", eff)

	sound.Play("npc/assassin/ball_zap1.wav", pos)

	local owner = self.DecoyOwner

	if IsValid(owner) and owner.decoys then
		for i = 1, 8 do
			if owner.decoys[i] == self then
				LANG.Msg(owner, "decoy_broken2", {num = i})

				break
			end
		end
	end

	self:Remove()
end

local ceil, max = math.ceil, math.max

weapons.GetStored("weapon_ttt_wtester").PerformScan = function(self, idx, repeated)
	if self:GetCharge() < 1250 then
		return
	end

	local sample = self.ItemSamples[idx]

	local owner = self:GetOwner()

	if not (sample and IsValid(owner)) then
		if repeated then
			self:ClearScanState()
		end

		return
	end

	local target = sample.ply

	if IsValid(target.decoy) then
		target = target.decoy
	elseif not target:IsTerror() then
		target = target.server_ragdoll
	end

	if not IsValid(target) then
		self:Report("dna_gone")

		self:SetCharge(self:GetCharge() - 50)

		if repeated then
			self:ClearScanState()
		end

		return
	end

	local pos = target.FakeSignalPos or target:WorldSpaceCenter()

	self:SendScan(pos)

	self:SetLastScanned(idx)

	self.NowRepeating = self:GetRepeating()

	self:SetCharge(
		max(0, self:GetCharge() - max(50, ceil(owner:GetPos():Distance(pos)) * 0.5))
	)
end

concommand.Remove("ttt_radar_scan")

local maxplayers_bits = TTTWR.maxplayers_bits

concommand.Add("ttt_radar_scan", function(ply)
	if not (IsValid(ply) and ply:IsTerror()) then
		return
	end

	if not ply:HasEquipmentItem(EQUIP_RADAR) then
		LANG.Msg(ply, "radar_not_owned")

		return
	end

	if ply.radar_charge > CurTime() then
		LANG.Msg(ply, "radar_charging")

		return
	end

	ply.radar_charge = CurTime() + 30

	local istraitor = ply:GetTraitor()

	net.Start("TTT_Radar")

	local players = player.GetAll()

	for i = 1, #players do
		local ent = players[i]

		if ent == ply
			or not (IsValid(ply) and ent:IsTerror())
			or (ent:GetNWBool("disguised", false) and not istraitor)
		then
			goto cont
		end

		net.WriteUInt(ent:EntIndex() - 1, maxplayers_bits)

		net.WriteUInt(
			ent:GetTraitor() == istraitor and ent:GetRole() or ROLE_INNOCENT, 2
		)

--[[
		local inpvs = ply:TestPVS(ent)

		net.WriteBool(inpvs)

		if not inpvs then
			net.WriteVector(ent:WorldSpaceCenter())
		end
--]]

		::cont::
	end

	net.WriteUInt(ply:EntIndex() - 1, maxplayers_bits)

	local sendnum, senddecoys = 0

	if placed_n > 0 then
		local n = 0

		for ent in pairs(placed) do
			if not IsValid(ent) then
				placed[ent] = nil

				goto cont
			end

			n = n + 1

			if ent.NoRadarSignal or ent.DecoyOwner == ply then
				goto cont
			end

			sendnum = sendnum + 1

			if not senddecoys then
				senddecoys = {}
			end

			senddecoys[sendnum] = ent

			::cont::
		end

		placed_n = n
	end

	net.WriteBool(senddecoys and true or false)

	if senddecoys then
		net.WriteUInt(sendnum - 1, 6)

		for i = 1, sendnum do
			local ent = senddecoys[i]

			net.WriteVector(
				ent.FakeSignalPos
				or ent:WorldSpaceCenter()
			)
		end
	end

	net.Send(ply)
end)
