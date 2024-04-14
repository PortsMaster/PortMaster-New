-- Copyright (c) 2013-18 rubenwardy. MIT.

local S = awards.translator

minetest.register_chatcommand("awards", {
	params = S("[c|clear|disable|enable]"),
	description = S("Show, clear, disable or enable your awards"),
	func = function(name, param)
		if param == "clear" then
			awards.clear_player(name)
			minetest.chat_send_player(name,
			S("All your awards and statistics have been cleared. You can now start again."))
		elseif param == "disable" then
			awards.disable(name)
			minetest.chat_send_player(name, S("You have disabled awards."))
		elseif param == "enable" then
			awards.enable(name)
			minetest.chat_send_player(name, S("You have enabled awards."))
		elseif param == "c" then
			awards.show_to(name, name, nil, true)
		else
			awards.show_to(name, name, nil, false)
		end
	end
})

minetest.register_chatcommand("awd", {
	params = S("<award ID>"),
	description = S("Show details of an award"),
	func = function(name, param)
		local def = awards.registered_awards[param]
		if def then
			minetest.chat_send_player(name, string.format("%s: %s", def.title, def.description))
		else
			minetest.chat_send_player(name, S("Award not found."))
		end
	end
})

minetest.register_chatcommand("awpl", {
	privs = {
		server = true
	},
	params = S("<name>"),
	description = S("Get the awards statistics for the given player or yourself"),
	func = function(name, param)
		if not param or param == "" then
			param = name
		end
		minetest.chat_send_player(name, param)
		local player = awards.player(param)
		minetest.chat_send_player(name, dump(player))
	end
})
