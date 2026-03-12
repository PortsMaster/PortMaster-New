local S = core.get_translator("mcl_gamemode")

mcl_gamemode = {
	gamemodes = {
		"survival",
		"creative",
	},
	registered_on_gamemode_change = {}
}

local gamemode_aliases = {
	["0"] = "survival",
	["1"] = "creative",
	["s"] = "survival",
	["c"] = "creative",
}

function mcl_gamemode.register_on_gamemode_change(func)
	table.insert(mcl_gamemode.registered_on_gamemode_change, func)
end

local old_is_creative_enabled = core.is_creative_enabled

function core.is_creative_enabled(name)
	if old_is_creative_enabled(name) then return true end
	if not name or name == "" then return false end
	assert(type(name) == "string", "core.is_creative_enabled requires a string (the playername) argument. This is likely an error in a non-mineclonia mod.")
	local p = core.get_player_by_name(name)
	if p then
		return p:get_meta():get_string("gamemode") == "creative"
	end
	return false
end

function mcl_gamemode.get_gamemode(p)
	return core.is_creative_enabled(p:get_player_name()) and "creative" or "survival"
end

function mcl_gamemode.set_gamemode(p, gm)
	if table.indexof(mcl_gamemode.gamemodes, gm) == -1 then return false end
	local old_gm = mcl_gamemode.get_gamemode(p)
	p:get_meta():set_string("gamemode", gm)
	for _, func in ipairs(mcl_gamemode.registered_on_gamemode_change) do
		func(p, old_gm, gm)
	end
	return true
end

core.register_chatcommand("gamemode",{
	params = S("[<gamemode>] [<player>]"),
	description = S("Change gamemode (survival/creative/0/1/s/c) for yourself or player"),
	privs = { server = true },
	func = function(n,param)
		local p
		local args = param:split(" ")
		if args[2] ~= nil then
			p = core.get_player_by_name(args[2])
			n = args[2]
		else
			p = core.get_player_by_name(n)
		end
		if not p then
			return false, S("Player not online")
		end

		local gm = gamemode_aliases[args[1]] or args[1]
		if gm and mcl_gamemode.set_gamemode(p, gm) == false then
			return false, S("Failed to set gamemode @1 for player @2", gm, p:get_player_name())
		end

		if gm == "survival" and core.is_creative_enabled() then
			return true, S("Player @1 is still in creative mode because world is in creative mode", n)
		end

		--Result message - show effective game mode
		return true, S("Gamemode for player @1: @2", n, mcl_gamemode.get_gamemode(p))
	end
})
