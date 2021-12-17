local cvs = {
	[EQUIP_ARMOR] = CreateConVar("ttt_buycost_armor", "2", FCVAR_NOTIFY + FCVAR_REPLICATED),
	[EQUIP_RADAR] = CreateConVar("ttt_buycost_radar", "2", FCVAR_NOTIFY + FCVAR_REPLICATED),
	[EQUIP_DISGUISE] = CreateConVar("ttt_buycost_disguise", "1", FCVAR_NOTIFY + FCVAR_REPLICATED),
}

local function buycostcb()
	for _, v in ipairs(EquipmentItems[ROLE_TRAITOR]) do
		local cv = cvs[v.id or 0]

		if cv then
			v.buycost = cv:GetInt()
		end
	end
end
buycostcb()

cvars.AddChangeCallback("ttt_buycost_armor", buycostcb, "tttwr")
cvars.AddChangeCallback("ttt_buycost_radar", buycostcb, "tttwr")
cvars.AddChangeCallback("ttt_buycost_disguise", buycostcb, "tttwr")

local function getcost(ply, id, is_item)
	if is_item then
		local items = EquipmentItems[ply:GetRole()]

		local eq = items and items[tonumber(id)]

		if eq and eq.buycost then
			return eq.buycost
		end
	else
		local swep = weapons.GetStored(id)

		if swep and swep.BuyCost then
			return swep.BuyCost
		end
	end
end

if SERVER then

hook.Add("TTTCanOrderEquipment", "tttwr_TTTCanOrderEquipment", function(ply, id, is_item)
	local cost = getcost(ply, id, is_item)

	if cost and ply:GetCredits() < cost then
		return false
	end
end)

hook.Add("TTTOrderedEquipment", "tttwr_TTTOrderedEquipment", function(ply, id, is_item)
	local cost = getcost(ply, id, is_item)

	if cost and cost > 1 then
		ply:SubtractCredits(cost - 1)
	end
end)

	return
end

local color_darkened = Color(255, 255, 255, 80)

-- let's just hope this doesn't break in a future update
hook.Add("TTTEquipmentTabs", "tttwr_TTTEquipmentTabs", function(dsheet)
	local dequip = dsheet:GetItems()[1].Panel

	local dlist = dequip:GetChild(0)

	local icons = dlist:GetItems()

	local ply = LocalPlayer()
	local credits = ply:GetCredits()

	for i = 1, #icons do
		local ic = icons[i]

		local id = ic.item.id

		local is_item = tonumber(id)

		local cost = getcost(ply, id, is_item) or 1

		if credits < cost then
			ic:SetIconColor(color_darkened)
		end

		if not is_item then
			local swep = weapons.GetStored(id)

			if swep and swep.FakeDefaultEquipment then
				ic.Layers[1]:SetVisible(false)
			end
		end
	end

	local dhelp = dequip:GetChild(1):GetChild(1)

	local lblcredits = dhelp:GetChild(0)

	local x, y = lblcredits:GetPos()

	local lblremaining = vgui.Create("DLabel", dhelp)
	lblremaining:SetColor(Color(255, 240, 64))
	lblremaining:SetFont("TabLarge")
	lblremaining:SetPos(x, y)

	lblcredits:MoveBelow(lblremaining, y)
	lblcredits:SetTooltip(false)

	function lblcredits:Check(sel)
		local credits = ply:GetCredits()

		local cost = getcost(ply, sel.id, tonumber(sel.id)) or 1

		lblremaining:SetText(LANG.GetParamTranslation("equip_cost", {num = credits}))
		lblremaining:SizeToContents()

		return credits >= cost,
			LANG.GetParamTranslation("equip_buycost", {num = cost})
	end

	local lblowned = dhelp:GetChild(1)
	lblowned:MoveBelow(lblcredits, y)

	local lblbought = dhelp:GetChild(2)
	lblbought:MoveBelow(lblowned, y)
end)
