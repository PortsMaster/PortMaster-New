local S = core.get_translator(core.get_current_modname())

--mcl_walls.register_wall(nodename, description, source, tiles, inventory_image, groups, sounds, overrides)

mcl_walls.register_wall_def("mcl_walls:cobble",{
	source = "mcl_core:cobble",
	description = S("Cobblestone Wall"),
	tiles = {"mcl_walls_cobble_wall_top.png", "default_cobble.png", "mcl_walls_cobble_wall_side.png"},
	_mcl_stonecutter_recipes = { "mcl_core:cobble" },
})
mcl_walls.register_wall_def("mcl_walls:mossycobble", {
	source = "mcl_core:mossycobble",
	description = S("Mossy Cobblestone Wall"),
	tiles = {"mcl_walls_cobble_mossy_wall_top.png", "default_mossycobble.png", "mcl_walls_cobble_mossy_wall_side.png"},
	_mcl_stonecutter_recipes = { "mcl_core:mossycobble" },
})
mcl_walls.register_wall_def("mcl_walls:andesite", {
	description = S("Andesite Wall"),
	source = "mcl_core:andesite",
	_mcl_stonecutter_recipes = {"mcl_core:andesite"},
})
mcl_walls.register_wall_def("mcl_walls:granite", {
	description = S("Granite Wall"),
	source = "mcl_core:granite",
	_mcl_stonecutter_recipes = {"mcl_core:granite",},
})
mcl_walls.register_wall_def("mcl_walls:diorite", {
	description = S("Diorite Wall"),
	source = "mcl_core:diorite",
	_mcl_stonecutter_recipes = {"mcl_core:diorite",},
})
mcl_walls.register_wall_def("mcl_walls:brick", {
	description = S("Brick Wall"),
	source = "mcl_core:brick_block",
	_mcl_stonecutter_recipes = {"mcl_core:brick_block",},
})
mcl_walls.register_wall_def("mcl_walls:sandstone", {
	description = S("Sandstone Wall"),
	source = "mcl_core:sandstone",
	_mcl_stonecutter_recipes = {"mcl_core:sandstone",},
})
mcl_walls.register_wall_def("mcl_walls:redsandstone", {
	description = S("Red Sandstone Wall"),
	source = "mcl_core:redsandstone",
	_mcl_stonecutter_recipes = {"mcl_core:redsandstone",},
})
mcl_walls.register_wall_def("mcl_walls:stonebrick", {
	description = S("Stone Brick Wall"),
	source = "mcl_core:stonebrick",
	_mcl_stonecutter_recipes = {"mcl_core:stonebrick", "mcl_core:stone"},
})
mcl_walls.register_wall_def("mcl_walls:stonebrickmossy", {
	description = S("Mossy Stone Brick Wall"),
	source = "mcl_core:stonebrickmossy",
	_mcl_stonecutter_recipes = {"mcl_core:stonebrickmossy",},
})
mcl_walls.register_wall_def("mcl_walls:prismarine", {
	description = S("Prismarine Wall"),
	source = "mcl_ocean:prismarine",
	_mcl_stonecutter_recipes = {"mcl_ocean:prismarine",},
})
mcl_walls.register_wall_def("mcl_walls:endbricks", {
	description = S("End Stone Brick Wall"),
	source = "mcl_end:end_bricks",
	_mcl_stonecutter_recipes = {"mcl_end:end_bricks","mcl_end:end_stone"},
})
mcl_walls.register_wall_def("mcl_walls:netherbrick", {
	description = S("Nether Brick Wall"),
	source = "mcl_nether:nether_brick",
	_mcl_stonecutter_recipes = {"mcl_nether:nether_brick",},
})
mcl_walls.register_wall_def("mcl_walls:rednetherbrick", {
	description = S("Red Nether Brick Wall"),
	source = "mcl_nether:red_nether_brick",
	_mcl_stonecutter_recipes = {"mcl_nether:red_nether_brick",},
})
mcl_walls.register_wall_def("mcl_walls:mudbrick", {
	description = S("Mud Brick Wall"),
	source = "mcl_mud:mud_bricks",
	_mcl_stonecutter_recipes = {"mcl_mud:mud_bricks",},
})
