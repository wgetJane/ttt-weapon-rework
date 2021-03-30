local SetZoom, SecondaryAttack, PreDrop, Holster, AdjustMouseSensitivity, DrawHUD

function TTTWR:MakeZoomable(fov, sens, dot)
	self.Secondary.Sound = "Default.Zoom"

	self.NoSights = nil
	self.IronSightsPos = Vector(5, -15, -2)
	self.IronSightsAng = Vector(2.6, 1.37, 3.5)

	self.ZoomFOV = fov or 20
	self.ZoomSensitivity = sens or 0.2
	self.ZoomRedDot = dot

	self.SetZoom = SetZoom
	self.SecondaryAttack = SecondaryAttack
	self.PreDrop = PreDrop
	self.Holster = Holster

	if SERVER then
		return
	end

	self.AdjustMouseSensitivity = AdjustMouseSensitivity
	self.DrawHUD = DrawHUD
end

function SetZoom(self, b)
	local owner = self:GetOwner()

	if not (IsValid(owner) and owner:IsPlayer()) then
		return
	end

	if b == self:GetIronsights() then
		return
	end

	return owner:SetFOV(
		b and self.ZoomFOV or 0,
		b and 0.3 or 0.2
	)
end

function SecondaryAttack(self)
	local curtime = CurTime()

	if self:GetNextSecondaryFire() > curtime then
		return
	end

	local b = not self:GetIronsights()

	self:SetZoom(b)
	self:SetIronsights(b)

	if CLIENT then
		self:EmitSound(self.Secondary.Sound)
	end

	self:SetNextSecondaryFire(CurTime() + 0.3)
end

function PreDrop(self)
	self:SetZoom(false)

	return self.BaseClass.PreDrop(self)
end

function Holster(self)
	self:SetZoom(false)
	self:SetIronsights(false)

	return true
end

if SERVER then
	return
end

function AdjustMouseSensitivity(self)
	return self:GetIronsights() and self.ZoomSensitivity or nil
end

local scope = surface.GetTextureID("sprites/scope")
local dot = surface.GetTextureID("sprites/redglow_mp1")

local random = math.random

local SetDrawColor, DrawRect, DrawLine, SetTexture, DrawTexturedRectRotated =
	surface.SetDrawColor, surface.DrawRect, surface.DrawLine,
	surface.SetTexture, surface.DrawTexturedRectRotated

function DrawHUD(self)
	if not self:GetIronsights() then
		return self.BaseClass.DrawHUD(self)
	end

	SetDrawColor(0, 0, 0, 255)

	local scrw, scrh = ScrW(), ScrH()
	local x, y = scrw * 0.5, scrh * 0.5

	local w = x - scrh * 0.5

	DrawRect(0, 0, w, scrh)
	DrawRect(x + scrh * 0.5, 0, w, scrh)

	if self.ZoomRedDot then
		local doth = scrh * (48 / 1080)

		SetTexture(dot)
		SetDrawColor(255, 0, 0, 255)

		DrawTexturedRectRotated(x, y, doth, doth, random() * 360)
	else
		local gap, len = 80, scrh

		::drawlines::
		DrawLine(x - len, y, x - gap, y)
		DrawLine(x + len, y, x + gap, y)
		DrawLine(x, y - len, x, y - gap)
		DrawLine(x, y + len, x, y + gap)

		if gap > 0 then
			gap, len = 0, 50
			goto drawlines
		end

		SetDrawColor(255, 0, 0, 255)

		DrawLine(x, y, x + 1, y + 1)
	end

	SetTexture(scope)
	SetDrawColor(255, 255, 255, 255)

	scrh = scrh + 2
	DrawTexturedRectRotated(x, y, scrh, scrh, 0)
end
