local S = core.get_translator(core.get_current_modname())

core.register_chatcommand("xp", {
	params = S("[[<player>] <xp>]"),
	description = S("Gives a player some XP"),
	privs = {server=true},
	func = function(name, params)
		local player, xp = nil, 1000
		local P, i = {}, 0
		for str in string.gmatch(params, "([^ ]+)") do
			i = i + 1
			P[i] = str
		end
		if i > 2 then
			return false, S("Error: Too many parameters!")
		end
		if i > 0 then
			xp = tonumber(P[i]) ---@diagnostic disable-line: cast-local-type
		end
		if i < 2 then
			player = core.get_player_by_name(name)
		end
		if i == 2 then
			player = core.get_player_by_name(P[1])
		end

		if not xp then
			return false, S("Error: Incorrect value of XP")
		end

		if not player then
			return false, S("Error: Player not found")
		end

		mcl_experience.add_xp(player, xp)

		return true, S("Added @1 XP to @2, total: @3, experience level: @4", tostring(xp), player:get_player_name(), tostring(mcl_experience.get_xp(player)), tostring(mcl_experience.get_level(player)))
	end,
})
