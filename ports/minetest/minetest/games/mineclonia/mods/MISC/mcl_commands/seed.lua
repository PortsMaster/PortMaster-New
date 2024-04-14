local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_chatcommand("seed", {
	description = S("Displays the world seed"),
	params = "",
	privs = {},
	func = function(name)
		minetest.chat_send_player(name, "Seed: ["..minetest.colorize(mcl_colors.GREEN, ""..minetest.get_mapgen_setting("seed")).."]")
	end
})