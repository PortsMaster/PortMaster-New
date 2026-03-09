local S = core.get_translator(core.get_current_modname())

local function register_chatcommand_alias(alias, cmd)
	local def = core.chatcommands[cmd]
	core.register_chatcommand(alias, def)
end

register_chatcommand_alias("?", "help")
register_chatcommand_alias("pardon", "unban")
register_chatcommand_alias("stop", "shutdown")
register_chatcommand_alias("tell", "msg")
register_chatcommand_alias("w", "msg")
register_chatcommand_alias("tp", "teleport")
register_chatcommand_alias("clear", "clearinv")

core.register_chatcommand("banlist", {
	description = S("List bans"),
	privs = core.chatcommands["ban"].privs,
	func = function()
		return true, S("Ban list: @1", core.get_ban_list())
	end,
})
