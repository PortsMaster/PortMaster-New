mcl_playerinfo = {}

-- This metatable provides compatibility to the old mcl_playerinfo rerouting all
-- indexing attempts on mcl_playerinfo[playername] to the new mcl_player.player[playerobject]
local mt = {
	__index = function (t, k)
		if type(k) == "string" and k:sub(1,5) == "node_" and mcl_player.players[t.player] and mcl_player.players[t.player].nodes and mcl_player.players[t.player].nodes[k:sub(6,-1)] then
			return mcl_player.players[t.player].nodes[k:sub(6,-1)]
		end
		return false
	end,
	__newindex = function () return false end
}

core.register_on_joinplayer(function(pl)
	local pn = pl:get_player_name()
	mcl_playerinfo[pn] = { player = pl }
	setmetatable(mcl_playerinfo[pn], mt)
end)
core.register_on_leaveplayer(function(pl) mcl_playerinfo[pl:get_player_name()] = nil end)
