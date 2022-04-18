if TTT2 then
	return
end

local ttt_prioritytargets = CreateConVar("ttt_prioritytargets", "2", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED)

local yellow = Color(255, 255, 0)

local sb_tag_priotarg = {
	txt = "sb_tag_priotarg",
	color = yellow,
}

LANG.Styles.priotargs = function(text)
	MSTACK:AddMessageEx({
		text = text,
		col = yellow,
		bg = Color(150, 0, 0, 200),
	})

	print("TTT:   " .. text)
end

LANG.SetStyle("priotarg_show1", "priotargs")
LANG.SetStyle("priotarg_show2", "priotargs")
LANG.SetStyle("priotarg_show3", "priotargs")
LANG.SetStyle("priotarg_kill", "priotargs")

local maxplayers_bits = TTTWR.maxplayers_bits

net.Receive("tttwr_priotargs", function()
	local targs = {}

	for _ = 1, ttt_prioritytargets:GetInt() do
		local ent = Entity(net.ReadUInt(maxplayers_bits) + 1)

		if IsValid(ent) and ent:IsPlayer() and not targs[ent] then
			ent.sb_tag = sb_tag_priotarg

			targs[#targs + 1] = ent:Nick()

			targs[ent] = true
		end
	end

	local n = #targs

	if n == 1 then
		LANG.Msg("priotarg_show1", {targ = targs[1]})
	elseif n == 2 then
		LANG.Msg("priotarg_show2", {targ1 = targs[1], targ2 = targs[2]})
	elseif n > 0 then
		LANG.Msg("priotarg_show3", {targs = table.concat(targs, ", ")})
	end
end)
