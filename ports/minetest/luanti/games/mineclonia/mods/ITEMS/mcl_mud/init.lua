local S = core.get_translator(core.get_current_modname())

core.register_node("mcl_mud:mud", {
	description = S("Mud"),
	_doc_items_longdesc = S("Mud is a decorative block that generates in mangrove swamps. Mud can also be obtained by using water bottles on dirt or coarse dirt."),
	_doc_items_hidden = false,
	tiles = {"mcl_mud.png"},
	sounds = {
		footstep = {name="mud_footsteps", gain=1},
		dug = {name="mud_place_dug", gain=1},
		place = {name="mud_place_dug", gain=1},
	},
	groups = {handy=1, shovely=1, enderman_takable=1, grass_block=1, soil_flower=1, soil_generic_plant = 1, soil_sugarcane=1, soil_bamboo=1, soil_fungus=1, building_block=1, soil_propagule=1, converts_to_moss=1, solid = 1, overworld_carvable = 1},
	_mcl_hardness = 0.5,
	collision_box = {
		type = "fixed",
		fixed = {
			{-8 / 16, -8 / 16, -8 / 16, 8 / 16, 6 / 16, 8 / 16},
		},
	},
})

core.register_node("mcl_mud:packed_mud", {
	description = S("Packed Mud"),
	_doc_items_longdesc = S("Packed mud is a decorative block used to craft mud bricks."),
	_doc_items_hidden = false,
	tiles = {"mcl_mud_packed_mud.png"},
	is_ground_content = false,
	groups = {handy=1, pickaxey=1, building_block=1},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 1,
	_mcl_crafting_output = {square2 = {output = "mcl_mud:mud_bricks 4"}}
})

core.register_node("mcl_mud:mud_bricks", {
	description = S("Mud Bricks"),
	_doc_items_longdesc = S("Decorative block crafted from packed mud."),
	_doc_items_hidden = false,
	tiles = {"mcl_mud_bricks.png"},
	is_ground_content = false,
	groups = {handy=1, pickaxey=1, building_block=1, stonecuttable = 1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 1.5,
})

mcl_stairs.register_stair_and_slab("mud_brick", {
	baseitem = "mcl_mud:mud_bricks",
	description_stair = S("Mud Brick Stair"),
	description_slab = S("Mud Brick Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_mud:mud_bricks"}},{_mcl_stonecutter_recipes = {"mcl_mud:mud_bricks"}}
})

-- packed mud
core.register_craft({
	type = "shapeless",
	output = "mcl_mud:packed_mud",
	recipe = {
		"mcl_mud:mud",
		"mcl_farming:wheat_item",
	}
})
