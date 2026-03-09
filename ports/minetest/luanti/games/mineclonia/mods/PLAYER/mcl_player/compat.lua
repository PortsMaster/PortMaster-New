mcl_player.player_attached = {}

local mt = {
	__index = function (_, k)
		local pl = core.get_player_by_name(k)
		if pl then
			return mcl_player.players[pl].attached
		end
		return false
	end,
	__newindex = function (_, k, v)
		local pl = core.get_player_by_name(k)
		if pl then
			mcl_player.players[pl].attached = v
		end
		return true
	end,
}

setmetatable(mcl_player.player_attached, mt)
