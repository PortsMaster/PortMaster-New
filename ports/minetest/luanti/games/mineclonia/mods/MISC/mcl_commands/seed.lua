local S = core.get_translator(core.get_current_modname())

core.register_chatcommand("seed", {
	description = S("Displays the world seed"),
	params = "",
	privs = {},
	func = function(name)
		core.chat_send_player(name, "Seed: ["..core.colorize(mcl_colors.GREEN, ""..core.get_mapgen_setting("seed")).."]")
	end
})