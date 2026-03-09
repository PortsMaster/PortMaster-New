local S = core.get_translator(core.get_current_modname())

core.register_privilege("announce", {
	description = S("Can use /say"),
	give_to_singleplayer = false,
})
core.register_chatcommand("say", {
	params = S("<message>"),
	description = S("Send a message to every player"),
	privs = {announce=true},
	func = function(name, param)
		if not param then
			return false, S("Invalid usage, see /help say.")
		end
		core.chat_send_all(("["..name.."] "..param))
		return true
	end,
})