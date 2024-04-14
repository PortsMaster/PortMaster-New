local S = minetest.get_translator(minetest.get_current_modname())

local function register_chatcommand_alias(alias, cmd)
	local def = minetest.chatcommands[cmd]
	minetest.register_chatcommand(alias, def)
end

register_chatcommand_alias("?", "help")
register_chatcommand_alias("pardon", "unban")
register_chatcommand_alias("stop", "shutdown")
register_chatcommand_alias("tell", "msg")
register_chatcommand_alias("w", "msg")
register_chatcommand_alias("tp", "teleport")
register_chatcommand_alias("clear", "clearinv")

minetest.register_chatcommand("banlist", {
	description = S("List bans"),
	privs = minetest.chatcommands["ban"].privs,
	func = function(name)
		return true, S("Ban list: @1", minetest.get_ban_list())
	end,
})
