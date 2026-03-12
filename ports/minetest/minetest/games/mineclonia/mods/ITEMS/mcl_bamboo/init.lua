mcl_bamboo = {}
local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator("mcl_bamboo")

dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/recipes.lua")

mcl_util.generate_on_place_plant_function(function(pos)
	local node_below = core.get_node(vector.offset(pos,0,-1,0))
	return core.get_item_group(node_below.name, "soil_bamboo") > 0
end)

local block_doc = S("A Block made of Bamboo stalks. Can be crafted into Bamboo Planks.")

local block_groups = {
	handy = 1, axey = 1, material_wood = 1, building_block = 1,
	flammable = 3, fire_encouragement = 5, fire_flammability = 20
}

mcl_trees.register_wood("bamboo",{
	readable_name = "Bamboo",
	sign_color="#FCE6BC",
	sapling = false,
	potted_sapling = false,
	leaves = false,
	wood_amount = 2,
	tree = {
		description = S("Block of Bamboo"),
		_doc_items_longdesc = block_doc,
		groups = block_groups,
		tiles = {"mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_bottom.png","mcl_bamboo_bamboo_block.png" },
		_mcl_cooking_output = false,
	},
	stripped = {
		description = S("Block of Stripped Bamboo"),
		_doc_items_longdesc = block_doc,
		groups = block_groups,
		tiles = {"mcl_bamboo_bamboo_bottom_stripped.png", "mcl_bamboo_bamboo_bottom_stripped.png","mcl_bamboo_bamboo_block_stripped.png" }
	},
	wood = { tiles = {"mcl_bamboo_bamboo_plank.png"}},
	bark = false,
	stripped_bark = false,
	fence = { tiles = { "mcl_bamboo_fence_bamboo.png" },},
	fence_gate = { tiles = { "mcl_bamboo_fence_gate_bamboo.png" }, },
	door = {
		inventory_image = "mcl_bamboo_door_wield.png",
		tiles_bottom = {"mcl_bamboo_door_bottom.png","mcl_bamboo_door_bottom.png"},
		tiles_top = {"mcl_bamboo_door_top.png","mcl_bamboo_door_bottom.png"},
	},
	trapdoor = {
		tile_front = "mcl_bamboo_trapdoor_side.png",
		tile_side = "mcl_bamboo_trapdoor_side.png",
		wield_image = "mcl_bamboo_trapdoor_side.png",
	},
	boat = {
		item = {
			description = S("Bamboo Raft"),
		},
		object = {
			variant = mcl_boats.variant.RAFT,
		},
	},
	chest_boat = {
		item = {
			description = S("Chest Bamboo Raft"),
		},
		object = {
			variant = mcl_boats.variant.RAFT,
		},
	},
	hanging_sign = true,
})

core.register_abm({
	label = "Bamboo growth",
	nodenames = {"group:bamboo_tree"},
	neighbors = {"group:soil_sapling","group:soil_bamboo"},
	interval = 15,
	chance = 10,
	action = function(pos)
		mcl_bamboo.grow(pos)
	end,
})

mcl_levelgen.register_levelgen_script (modpath .. "/lg_register.lua")
