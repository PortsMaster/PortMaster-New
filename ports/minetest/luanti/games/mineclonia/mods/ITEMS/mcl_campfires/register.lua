local S = core.get_translator(core.get_current_modname())

-- Register Plain Campfire
mcl_campfires.register_campfire("mcl_campfires:campfire", {
	description = S("Campfire"),
	inv_texture = "mcl_campfires_campfire_inv.png",
	fire_texture = "mcl_campfires_campfire_fire.png",
	lit_logs_texture = "mcl_campfires_campfire_log_lit.png",
	drops = "mcl_core:charcoal_lump 2",
	lightlevel = core.LIGHT_MAX,
	damage = 1,
})

-- Register Soul Campfire
mcl_campfires.register_campfire("mcl_campfires:soul_campfire", {
	description = S("Soul Campfire"),
	inv_texture = "mcl_campfires_soul_campfire_inv.png",
	fire_texture = "mcl_campfires_soul_campfire_fire.png",
	lit_logs_texture = "mcl_campfires_soul_campfire_log_lit.png",
	drops = "mcl_blackstone:soul_soil",
	lightlevel = 10,
	damage = 2,
	groups = {
		soul_firelike = 1,
	},
})

-- Register Campfire Crafting
core.register_craft({
	output = "mcl_campfires:campfire_lit",
	recipe = {
		{ "", "mcl_core:stick", "" },
		{ "mcl_core:stick", "group:coal", "mcl_core:stick" },
		{ "group:tree", "group:tree", "group:tree" },
	}
})

core.register_craft({
	output = "mcl_campfires:soul_campfire_lit",
	recipe = {
		{ "", "mcl_core:stick", "" },
		{ "mcl_core:stick", "group:soul_block", "mcl_core:stick" },
		{ "group:tree", "group:tree", "group:tree" },
	}
})
