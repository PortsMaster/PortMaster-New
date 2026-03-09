local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

mcl_trees.register_wood("pale_oak",{
	readable_name = "Pale Oak",
	sign_color = "#cfbfc5",
	tree_schems_2x2 = {
		{file = modpath.."/schematics/mcl_pale_oak_1.mts", offset = vector.new(1,0,1)},
		{file = modpath.."/schematics/mcl_pale_oak_2.mts", offset = vector.new(1,0,1)},
		{file = modpath.."/schematics/mcl_pale_oak_3.mts", offset = vector.new(1,0,1)},
	},
	tree = { tiles = {"mcl_pale_oak_log_top.png", "mcl_pale_oak_log_top.png","mcl_pale_oak_log.png" }},
	bark = { tiles = {"mcl_pale_oak_log.png"}},
	leaves = {
		tiles = { "mcl_pale_oak_leaves.png" },
		paramtype2 = "none",
		palette = ""
	},
	wood = { tiles = {"mcl_pale_oak_planks.png"}},
	stripped = {
		tiles = {"mcl_stripped_pale_oak_log_top.png", "mcl_stripped_pale_oak_log_top.png","mcl_stripped_pale_oak_log_side.png"}
	},
	stripped_bark = {
		tiles = {"mcl_stripped_pale_oak_log_side.png"}
	},
	fence = {
		tiles = { "mcl_pale_oak_planks.png" },
	},
	fence_gate = {
		tiles = { "mcl_pale_oak_planks.png" },
	},
	door = {
		inventory_image = "mcl_pale_oak_door_item.png",
		tiles_bottom = {"mcl_pale_oak_door_bottom.png", "mcl_pale_oak_door_bottom.png"},
		tiles_top = {"mcl_pale_oak_door_top.png", "mcl_pale_oak_door_top.png"}
	},
	trapdoor = {
		tile_front = "mcl_pale_oak_trapdoor.png",
		tile_side = "mcl_pale_oak_trapdoor_side.png",
		wield_image = "mcl_pale_oak_trapdoor.png",
	},
	hanging_sign = true,
})

dofile(modpath .. "/resin_blocks.lua")
dofile(modpath .. "/plants.lua")
