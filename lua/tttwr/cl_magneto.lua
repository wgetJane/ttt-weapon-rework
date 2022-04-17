local SWEP = weapons.GetStored("weapon_zm_carry")

SWEP.DeploySpeed = 28 / 15

local ttt_magnetotrans = CreateConVar("ttt_magnetotrans", 1, FCVAR_ARCHIVE)

local tex = GetRenderTargetEx(
	"tttwr_magneto_tex",
	0, 0,
	RT_SIZE_FULL_FRAME_BUFFER,
	MATERIAL_RT_DEPTH_NONE,
	0x8000, --TEXTUREFLAGS_RENDERTARGET
	CREATERENDERTARGETFLAGS_HDR,
	IMAGE_FORMAT_DEFAULT
)

local mat = CreateMaterial("tttwr_magneto_matasdf", "UnlitGeneric", {
	["$basetexture"] = tex:GetName(),
	["$alpha"] = 0.5,
})

local _RenderOverride, heldrm

local GetRenderTarget, CopyRenderTargetToTexture, SetMaterial, DrawScreenQuad =
	render.GetRenderTarget, render.CopyRenderTargetToTexture, render.SetMaterial, render.DrawScreenQuad

local function RenderOverride(self, f)
	if not GetRenderTarget() then
		CopyRenderTargetToTexture(tex)

		if _RenderOverride then
			_RenderOverride(self, f)
		else
			self:DrawModel(f)
		end

		SetMaterial(mat)

		DrawScreenQuad()
	elseif _RenderOverride then
		return _RenderOverride(self, f)
	else
		return self:DrawModel(f)
	end
end

local lastadd, lastrem, heldent = 0, 0

net.Receive("tttwr_magneto", function()
	local curtime = net.ReadFloat()

	local b = net.ReadBool()

	local ent = b and net.ReadEntity()

	if b and curtime >= lastrem then
		lastadd = curtime

		lastrem = 0

		if IsValid(heldent) then
			heldent.RenderOverride = _RenderOverride
			_RenderOverride = nil
		end

		heldent = nil

		if not (
			ttt_magnetotrans:GetBool()
			and IsValid(ent)
			and ent:GetBrushPlaneCount() == 0 -- ignore func_physbox
		) then
			return
		end

		heldrm = ent:GetRenderMode()

		if heldrm == RENDERMODE_NORMAL then
			ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
		end

		_RenderOverride = ent.RenderOverride
		ent.RenderOverride = RenderOverride

		heldent = ent
	elseif not b and curtime >= lastadd then
		lastrem = curtime

		lastadd = 0

		if IsValid(heldent) then
			if heldrm == RENDERMODE_NORMAL
				and heldent:GetRenderMode() == RENDERMODE_TRANSCOLOR
			then
				heldent:SetRenderMode(heldrm)
			end

			heldent.RenderOverride = _RenderOverride
			_RenderOverride = nil
		end

		heldent = nil
	end
end)
