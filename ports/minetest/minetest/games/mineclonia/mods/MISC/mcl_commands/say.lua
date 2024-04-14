local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_privilege("announce", {
	description = S("Can use /say"),
	give_to_singleplayer = false,
})
minetest.register_chatcommand("say", {
	params = S("<message>"),
	description = S("Send a message to every player"),
	privs = {announce=true},
	func = function(name, param)
		if not param then
			return false, S("Invalid usage, see /help say.")
		end
		minetest.chat_send_all(("["..name.."] "..param))
		return true
	end,
})