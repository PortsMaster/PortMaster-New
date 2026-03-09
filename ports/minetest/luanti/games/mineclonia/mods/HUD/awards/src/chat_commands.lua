-- Copyright (c) 2013-18 rubenwardy. MIT.

local S = awards.translator

core.register_chatcommand("awards", {
	params = "[c|clear|disable|enable]",
	description = S("Show, clear, disable or enable your advancements"),
	func = function(name, param)
		if param == "clear" then
			awards.clear_player(name)
			core.chat_send_player(name,
			S("All your advancements and statistics have been cleared. You can now start again."))
		elseif param == "disable" then
			awards.disable(name)
			core.chat_send_player(name, S("You have disabled advancements."))
		elseif param == "enable" then
			awards.enable(name)
			core.chat_send_player(name, S("You have enabled advancements."))
		elseif param == "c" then
			awards.show_to(name, name, nil, true)
		else
			awards.show_to(name, name, nil, false)
		end
	end
})

core.register_chatcommand("awd", {
	params = S("<advancement ID>"),
	description = S("Show details of an advancement"),
	func = function(name, param)
		local def = awards.registered_awards[param]
		if def then
			core.chat_send_player(name, string.format("%s: %s", def.title, def.description))
		else
			core.chat_send_player(name, S("Advancement not found."))
		end
	end
})

core.register_chatcommand("awpl", {
	privs = {
		server = true
	},
	params = S("<name>"),
	description = S("Get the advancement statistics for the given player or yourself"),
	func = function(name, param)
		if not param or param == "" then
			param = name
		end
		core.chat_send_player(name, param)
		local player = awards.player(param)
		core.chat_send_player(name, dump(player))
	end
})
