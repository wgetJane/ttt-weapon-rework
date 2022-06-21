local SWEP = {}

SWEP.NoSights = false
SWEP.IronSightsPos = Vector(5, -15, -2)
SWEP.IronSightsAng = Vector(2.6, 1.37, 3.5)

SWEP.IsCurrentlyZoomedIn = false

SWEP.Secondary = {
	Sound = "Default.Zoom",
}

function TTTWR:MakeZoomable(fov, dot)
	TTTWR.CopySWEP(self, SWEP)

	self.ZoomFOV = fov or 20
	self.ZoomRedDot = dot
end

function SWEP:SetZoom(b)
	if b == self.IsCurrentlyZoomedIn and IsFirstTimePredicted() then
		return
	end

	self.IsCurrentlyZoomedIn = b

	local owner = self:GetOwner()

	if not (IsValid(owner) and owner:IsPlayer()) then
		return
	end

	return owner:SetFOV(
		b and self.ZoomFOV or 0,
		b and 0.3 or 0.2
	)
end

function SWEP:SecondaryAttack()
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

function SWEP:PreDrop()
	self:SetZoom(false)

	if self.ZoomablePreDrop then
		self:ZoomablePreDrop()
	end

	return self.BaseClass.PreDrop(self)
end

function SWEP:Holster()
	self:SetZoom(false)

	if self.ZoomableHolster then
		return self:ZoomableHolster()
	end

	return true
end

if SERVER then
	return
end

local default_fov = GetConVar("default_fov")

local tan = math.tan

function SWEP:AdjustMouseSensitivity()
	local owner = self:GetOwner()

	if not IsValid(owner) then
		return
	end

	local lfov, dfov = owner:GetFOV(), default_fov:GetInt()

	if lfov ~= dfov then
		return tan(lfov * 87266462599716e-16) / tan(dfov * 87266462599716e-16)
	end
end

local scope = Material("sprites/scope")
local dot = surface.GetTextureID("sprites/redglow_mp1")

local random = math.random

local SetDrawColor, DrawRect, DrawLine, SetTexture, SetMaterial, DrawTexturedRectRotated =
	surface.SetDrawColor, surface.DrawRect, surface.DrawLine,
	surface.SetTexture, surface.SetMaterial, surface.DrawTexturedRectRotated

function SWEP:DrawHUD()
	if not self:GetIronsights() then
		if self.ZoomableDrawHUD then
			self:ZoomableDrawHUD()
		end

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

	SetMaterial(scope)
	SetDrawColor(255, 255, 255, 255)

	scrh = scrh + 2
	DrawTexturedRectRotated(x, y, scrh, scrh, 0)

	if self.ZoomableDrawHUD then
		self:ZoomableDrawHUD()
	end
end
