local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

-- All required translation strings are currently generated in mcl_trees
-- local S = core.get_translator(core.get_current_modname())

mcl_trees.register_wood("oak",{
	readable_name = "Oak",
	sign_color="#917056",
	tree_schems= {
		{ file = modpath.."/schematics/mcl_core_oak_balloon.mts"},
		{ file = modpath.."/schematics/mcl_core_oak_large_1.mts"},
		{ file = modpath.."/schematics/mcl_core_oak_large_2.mts"},
		{ file = modpath.."/schematics/mcl_core_oak_large_3.mts"},
		{ file = modpath.."/schematics/mcl_core_oak_large_4.mts"},
		{ file = modpath.."/schematics/mcl_core_oak_swamp.mts"},
		{ file = modpath.."/schematics/mcl_core_oak_v6.mts"},
		{ file = modpath.."/schematics/mcl_core_oak_classic.mts"},
	},
	tree = { tiles = {"default_tree_top.png", "default_tree_top.png","default_tree.png"} },
	leaves = {
		tiles = { "default_leaves.png" },
		color = "#77ab2f",
	},
	drop_apples = true,
	wood = { tiles = {"default_wood.png"}},
	sapling = {
		tiles = {"default_sapling.png"},
		inventory_image = "default_sapling.png",
		wield_image = "default_sapling.png",
		_after_grow=mcl_trees.sapling_add_bee_nest,
	},
	door = {
		inventory_image = "doors_item_wood.png",
		tiles_bottom = {"mcl_doors_door_wood_lower.png", "mcl_doors_door_wood_side_lower.png"},
		tiles_top = {"mcl_doors_door_wood_upper.png", "mcl_doors_door_wood_side_upper.png"}
	},
	trapdoor = {
		tile_front = "doors_trapdoor.png",
		tile_side = "doors_trapdoor_side.png",
		wield_image = "doors_trapdoor.png",
	},
	potted_sapling = {
		image = "default_sapling.png",
	},
	hanging_sign = true,
})

mcl_trees.register_wood("dark_oak",{
	readable_name = "Dark Oak",
	sign_color="#625048",
	tree_schems_2x2 = {
		{ file = modpath.."/schematics/mcl_core_dark_oak.mts"},
	},
	tree = { tiles = {"mcl_core_log_big_oak_top.png", "mcl_core_log_big_oak_top.png","mcl_core_log_big_oak.png"} },
	leaves = {
		tiles = { "mcl_core_leaves_big_oak.png" },
		color = "#77ab2f",
	},
	drop_apples = true,
	wood = { tiles = {"mcl_core_planks_big_oak.png"}},
	sapling = {
		tiles = {"mcl_core_sapling_big_oak.png"},
		inventory_image = "mcl_core_sapling_big_oak.png",
		wield_image = "mcl_core_sapling_big_oak.png",
	},
	fence = {
		tiles = { "mcl_fences_fence_big_oak.png" },
	},
	fence_gate = {
		tiles = { "mcl_fences_fence_gate_big_oak.png" },
	},
	potted_sapling = {
		image = "mcl_core_sapling_big_oak.png",
	},
	hanging_sign = true,
})

mcl_trees.register_wood("jungle",{
	readable_name = "Jungle",
	sign_color="#845A43",
	tree_schems = {
		{ file = modpath.."/schematics/mcl_core_jungle_tree.mts"},
		{ file = modpath.."/schematics/mcl_core_jungle_tree_2.mts"},
		{ file = modpath.."/schematics/mcl_core_jungle_tree_3.mts"},
		{ file = modpath.."/schematics/mcl_core_jungle_tree_4.mts"},
	},
	tree_schems_2x2 = {
		{ file = modpath.."/schematics/mcl_core_jungle_tree_huge_1.mts"},
		{ file = modpath.."/schematics/mcl_core_jungle_tree_huge_2.mts"},
		{ file = modpath.."/schematics/mcl_core_jungle_tree_huge_3.mts"},
		{ file = modpath.."/schematics/mcl_core_jungle_tree_huge_4.mts"},
	},
	tree = { tiles = {"default_jungletree_top.png", "default_jungletree_top.png","default_jungletree.png"} },
	leaves = {
		tiles = { "default_jungleleaves.png" },
		color = "#30bb0b",
	},
	sapling_chances = {40, 36, 32, 24, 10},
	wood = { tiles = {"default_junglewood.png"}},
	sapling = {
		tiles = {"default_junglesapling.png"},
		inventory_image = "default_junglesapling.png",
		wield_image = "default_junglesapling.png",
	},
	potted_sapling = {
		image = "default_junglesapling.png",
	},
	hanging_sign = true,
})

mcl_trees.register_wood("spruce",{
	readable_name = "Spruce",
	sign_color="#604335",
	tree_schems = {
		{ file = modpath.."/schematics/mcl_core_spruce_1.mts"},
		{ file = modpath.."/schematics/mcl_core_spruce_2.mts"},
		{ file = modpath.."/schematics/mcl_core_spruce_3.mts"},
		{ file = modpath.."/schematics/mcl_core_spruce_4.mts"},
		{ file = modpath.."/schematics/mcl_core_spruce_5.mts"},
		{ file = modpath.."/schematics/mcl_core_spruce_lollipop.mts"},
		{ file = modpath.."/schematics/mcl_core_spruce_matchstick.mts"},
		{ file = modpath.."/schematics/mcl_core_spruce_tall.mts"},
	},
	tree_schems_2x2 = {
		{ file = modpath.."/schematics/mcl_core_spruce_huge_1.mts"},
		{ file = modpath.."/schematics/mcl_core_spruce_huge_2.mts"},
		{ file = modpath.."/schematics/mcl_core_spruce_huge_3.mts"},
		{ file = modpath.."/schematics/mcl_core_spruce_huge_4.mts"},
		{ file = modpath.."/schematics/mcl_core_spruce_huge_up_1.mts"},
		{ file = modpath.."/schematics/mcl_core_spruce_huge_up_2.mts"},
		{ file = modpath.."/schematics/mcl_core_spruce_huge_up_3.mts"},
	},
	leaves = {
		color = "#2bbb0f",
	},
	sapling = {
		_after_grow = function(pos, _, is_2by2)
			if is_2by2 then
				local nn = core.find_nodes_in_area_under_air(vector.offset(pos,-6,-6,-6), vector.offset(pos, 6, 6, 6), {"group:dirt"})
				table.sort(nn, function(a, b) return vector.distance(pos, a) < vector.distance(pos, b) end)
				for i = 1, math.random(math.min(#nn, 2), #nn) do
					core.set_node(nn[i], {name="mcl_core:podzol"})
				end
			end
		end
	},
	hanging_sign = true,
})

mcl_trees.register_wood("acacia",{
	readable_name = "Acacia",
	sign_color="#965638",
	tree_schems ={
		{ file = modpath.."/schematics/mcl_core_acacia_1.mts"},
		{ file = modpath.."/schematics/mcl_core_acacia_2.mts"},
		{ file = modpath.."/schematics/mcl_core_acacia_3.mts"},
		{ file = modpath.."/schematics/mcl_core_acacia_4.mts"},
		{ file = modpath.."/schematics/mcl_core_acacia_5.mts"},
		{ file = modpath.."/schematics/mcl_core_acacia_6.mts"},
		{ file = modpath.."/schematics/mcl_core_acacia_7.mts"},
		{ file = modpath.."/schematics/mcl_core_acacia_weirdo.mts"},
	},
	tree = { tiles = {"default_acacia_tree_top.png", "default_acacia_tree_top.png","default_acacia_tree.png"} },
	leaves = {
		tiles = { "default_acacia_leaves.png" },
		color = "#aea42a",
	},
	wood = { tiles = {"default_acacia_wood.png"}},
	sapling = {
		tiles = {"default_acacia_sapling.png"},
		inventory_image = "default_acacia_sapling.png",
		wield_image = "default_acacia_sapling.png",
	},
	potted_sapling = {
		image = "default_acacia_sapling.png",
	},
	hanging_sign = true,
})

mcl_trees.register_wood("birch",{
	readable_name = "Birch",
	sign_color="#AA907A",
	tree_schems = {
		{ file = modpath.."/schematics/mcl_core_birch.mts"},
	},
	leaves = {
		color = "#68a55f",
	},
	sapling = {
		_after_grow=mcl_trees.sapling_add_bee_nest,
	},
	hanging_sign = true,
})
