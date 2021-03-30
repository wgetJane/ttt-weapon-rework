local SWEP = weapons.GetStored("weapon_ttt_decoy")

SWEP.Primary.Damage = -1
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.1

SWEP.AllowDrop = true

local localply

local decoys = {n = 0, {},{},{},{},{},{},{},{}}

local lastupdate = 0

local updatepanel

net.Receive("tttwr_decoy", function()
	local updatetime = net.ReadFloat()

	if lastupdate > updatetime then
		return
	end

	lastupdate = updatetime

	local decoys = decoys

	decoys.n = 0

	local i = 8

	::loop::

	local decoy = decoys[i]
	decoy.valid = net.ReadBool()

	if decoy.valid then
		decoys.n = decoys.n + 1

		decoy.pos = net.ReadVector()
		decoy.on = net.ReadBool()
		decoy.dna = false
	end

	i = i - 1
	if i ~= 0 then
		goto loop
	end

	decoy = decoys[net.ReadUInt(4)]

	if decoy then
		decoy.dna = true
	end

	if updatepanel then
		return updatepanel(decoys)
	end
end)

hook.Add("TTTEquipmentTabs", "tttwr_decoy_TTTEquipmentTabs", function(dsheet)
	local ply = LocalPlayer()

	if not (
		IsValid(ply)
		and decoys.n > 0
	) then
		return
	end

	local dform = vgui.Create("DForm", dsheet)
	dform:SetName(LANG.GetTranslation("decoy_menutitle"))
	dform:StretchToParent(0, 0, 0, 0)
	dform:SetAutoSize(false)

	local panel = vgui.Create("Panel", dform)
	panel:Dock(FILL)

	local shadowcol = Color(0, 0, 0, 192)

	local checkboxes1, checkboxes2 = {}, {}

	local network = true

	local function onchange(self, val)
		if not network then
			return
		end

		net.Start("tttwr_decoy")

		net.WriteBool(self._decoy_b)

		local i = self._decoy_i

		if self._decoy_b then
			net.WriteUInt(val and i or 0, 4)

			network = false

			for j = 1, 8 do
				if i ~= j then
					checkboxes2[j]:SetChecked(false)
				end
			end

			network = true
		else
			net.WriteUInt(i - 1, 3)
			net.WriteBool(val)
		end

		net.SendToServer()
	end

	local x, y = 20
	local b, text, cboxes = false, "decoy_equip_lbl1", checkboxes1

	::loop::

	local lbl = Label(LANG.GetTranslation(text), panel)
	lbl:SizeToContents()
	lbl:SetTextColor(color_white)
	lbl:SetExpensiveShadow(1, shadowcol)
	lbl:SetPos(x, 10)

	x, y = lbl:GetPos()
	y = y + 10 + lbl:GetTall()

	local nx = 20 + lbl:GetWide()

	for i = 1, 8 do
		local cbox = panel:Add("DCheckBoxLabel")

		cboxes[i] = cbox

		cbox._decoy_i = i
		cbox._decoy_b = b
		cbox.OnChange = onchange

		cbox:SetText(LANG.GetPTranslation("decoy_equip_cbox", {num = i}))
		cbox:SetPos(x + 10, y)

		cbox.Label:SetTextColor(color_white)
		cbox.Label:SetExpensiveShadow(1, shadowcol)

		y = y + 10 + cbox:GetTall()

		nx = math.max(nx, 20 + cbox:GetWide())
	end

	if not b then
		x = nx + 40

		b, text, cboxes = true, "decoy_equip_lbl2", checkboxes2

		goto loop
	end

	dsheet:AddSheet(
		LANG.GetTranslation("decoy_name"),
		dform,
		"icon16/ipod_cast.png",
		false, false,
		LANG.GetTranslation("equip_tooltip_decoy")
	)

	function updatepanel(decoys)
		if not IsValid(dform) then
			updatepanel = nil

			return
		end

		local _network = network
		network = false

		for i = 1, 8 do
			local decoy = decoys[i]
			local cbox1 = checkboxes1[i]
			local cbox2 = checkboxes2[i]

			if not decoy.valid then
				cbox1:SetChecked(false)
				cbox2:SetChecked(false)

				cbox1:SetEnabled(false)
				cbox2:SetEnabled(false)

				goto cont
			end

			cbox1:SetEnabled(true)
			cbox2:SetEnabled(true)

			cbox1:SetChecked(decoy.on)
			cbox2:SetChecked(decoy.dna)

			::cont::
		end

		network = _network
	end

	updatepanel(decoys)

	local xfer_name = LANG.GetTranslation("xfer_name")

	for _, v in ipairs(dsheet:GetItems()) do
		if v.Name == xfer_name then
			dsheet:AddSheet(
				xfer_name,
				dsheet:CloseTab(v.Tab),
				v.Tab.Image:GetImage(),
				v.Panel.NoStretchX,
				v.Panel.NoStretchY,
				v.Tab:GetTooltip()
			)

			break
		end
	end
end)

local ring = surface.GetTextureID("effects/select_ring")

local SetTexture, SetFont, SetDrawColor, DrawTexturedRect, GetTextSize, SetTextColor, SetTextPos, DrawText =
	surface.SetTexture, surface.SetFont, surface.SetDrawColor, surface.DrawTexturedRect, surface.GetTextSize, surface.SetTextColor, surface.SetTextPos, surface.DrawText

local clamp, ceil = math.Clamp, math.ceil

hook.Add("HUDPaint", "tttwr_decoy_HUDPaint", function()
	if not hook.Call("HUDShouldDraw", GAMEMODE, "TTTRadar") then
		return
	end

	local decoys = decoys

	if decoys.n <= 0 then
		return
	end

	local ply = localply

	if not IsValid(ply) then
		ply = LocalPlayer()
		localply = ply

		if not IsValid(ply) then
			return
		end
	end

	if not ply:IsActiveTraitor() then
		return
	end

	local plypos = ply:GetPos()

	local scrw, scrh = ScrW(), ScrH()

	local mx, my = scrw * 0.5, scrh * 0.5

	SetTexture(ring)

	SetFont("HudSelectionText")

	local i = 8

	::loop::

	local decoy = decoys[i]

	if decoy.valid then
		local r, g, b, a = 100, 210, 230, 230

		if not decoy.on then
			r, g, b = 200, 100, 255
		end

		local scrpos = decoy.pos:ToScreen()

		if not scrpos.visible then
			goto cont
		end

		local x, y = scrpos.x - mx, scrpos.y - my

		local dist = (x * x + y * y) ^ 0.5

		if dist < 180 then
			a = clamp(a * dist * (1 / 180), 40, 230)
		end

		local size = 24

		if scrpos.x < 0
			or scrpos.y < 0
			or scrpos.x > scrw
			or scrpos.y > scrh
		then
			size = size * 0.5
		end

		x, y =
			clamp(scrpos.x, size, scrw - size),
			clamp(scrpos.y, size, scrh - size)

		if x < 0
			or y < 0
			or x > scrw
			or y > scrh
		then
			goto cont
		end

		SetDrawColor(r, g, b, a)

		DrawTexturedRect(x - size, y - size, size * 2, size * 2)

		local text = tostring(i)
		local w, h = GetTextSize(text)

		SetTextColor(r, g, b, 230)

		if size < 24 then
			SetTextPos(x - w * 0.5, y - h * 0.5)

			DrawText(text)

			goto cont
		end

		SetTextPos(x - w * 0.5, y - h * 0.5 - 8)

		DrawText(text)

		text = tostring(ceil(plypos:Distance(decoy.pos)))
		w, h = GetTextSize(text)

		SetTextColor(r, g, b, a)

		SetTextPos(x - w * 0.5, y - h * 0.5 + 4)

		DrawText(text)

		::cont::
	end

	i = i - 1
	if i ~= 0 then
		goto loop
	end
end)

local maxplayers_bits = TTTWR.maxplayers_bits

local function timeout()
	return RADAR:Timeout()
end

net.Receive("TTT_Radar", function()
	RADAR.targets = {}

	local i = 0

	local ply = LocalPlayer()

	::loop::

	local ent = Entity(net.ReadUInt(maxplayers_bits) + 1)

	if ent == ply then
		if net.ReadBool() then
			local istraitor = ply:GetTraitor()

			for _ = 1, net.ReadUInt(6) + 1 do
				i = i + 1

				RADAR.targets[i] = {
					role = istraitor and 3 or ROLE_INNOCENT,
					pos = net.ReadVector(),
				}
			end
		end
	else
		if IsValid(ent) and ent:Alive() then
			i = i + 1

			RADAR.targets[i] = {
				role = net.ReadUInt(2),
				--pos = net.ReadBool() and ent:WorldSpaceCenter() or net.ReadVector(),
				pos = ent:WorldSpaceCenter(),
			}
		end

		goto loop
	end

	RADAR.enable = true
	RADAR.endtime = CurTime() + RADAR.duration

	timer.Create("radartimeout", RADAR.duration + 1, 1, timeout)
end)
