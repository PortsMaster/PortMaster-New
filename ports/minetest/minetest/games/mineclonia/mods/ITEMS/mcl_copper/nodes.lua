local S = minetest.get_translator("mcl_copper")

local function on_lightning_strike(pos, pos1, pos2)
	local node = minetest.get_node(pos)
	if vector.distance(pos, pos2) <= 1 then
		node.name = mcl_copper.get_undecayed(node.name, 4)
	else
		node.name = mcl_copper.get_undecayed(node.name, math.random(4))
	end
	minetest.swap_node(pos, node)
end

minetest.register_node("mcl_copper:stone_with_copper", {
	description = S("Copper Ore"),
	_doc_items_longdesc = S("Some copper contained in stone, it is pretty common and can be found below sea level."),
	tiles = {"default_stone.png^mcl_copper_ore.png"},
	groups = {pickaxey = 3, building_block = 1, material_stone = 1, blast_furnace_smeltable=1},
	drop = "mcl_copper:raw_copper",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,

})

minetest.register_node("mcl_copper:block_raw", {
	description = S("Block of Raw Copper"),
	_doc_items_longdesc = S("A block used for compact raw copper storage."),
	tiles = {"mcl_copper_block_raw.png"},
	is_ground_content = false,
	groups = {pickaxey = 2, building_block = 1, blast_furnace_smeltable = 1 },
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_copper:block", {
	description = S("Block of Copper"),
	_doc_items_longdesc = S("A block of copper is mostly a decorative block."),
	tiles = {"mcl_copper_block.png"},
	is_ground_content = false,
	groups = {pickaxey = 2, building_block = 1, stonecuttable = 1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 3,
})

minetest.register_node("mcl_copper:block_exposed", {
	description = S("Exposed Copper"),
	_doc_items_longdesc = S("Exposed copper is a decorative block."),
	tiles = {"mcl_copper_exposed.png"},
	is_ground_content = false,
	groups = {pickaxey = 2, building_block = 1, stonecuttable = 1, affected_by_lightning = 1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_on_lightning_strike = on_lightning_strike,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_copper:block_weathered", {
	description = S("Weathered Copper"),
	_doc_items_longdesc = S("Weathered copper is a decorative block."),
	tiles = {"mcl_copper_weathered.png"},
	is_ground_content = false,
	groups = {pickaxey = 2, building_block = 1, stonecuttable = 1, affected_by_lightning = 1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_on_lightning_strike = on_lightning_strike,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_copper:block_oxidized", {
	description = S("Oxidized Copper"),
	_doc_items_longdesc = S("Oxidized copper is a decorative block."),
	tiles = {"mcl_copper_oxidized.png"},
	is_ground_content = false,
	groups = {pickaxey = 2, building_block = 1, stonecuttable = 1, affected_by_lightning = 1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_on_lightning_strike = on_lightning_strike,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_copper:block_cut", {
	description = S("Cut Copper"),
	_doc_items_longdesc = S("Cut copper is a decorative block."),
	tiles = {"mcl_copper_block_cut.png"},
	is_ground_content = false,
	groups = {pickaxey = 2, building_block = 1, stonecuttable = 1, cut_copper = 1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
	_mcl_stonecutter_recipes = { "mcl_copper:block" },
})

minetest.register_node("mcl_copper:block_exposed_cut", {
	description = S("Exposed Cut Copper"),
	_doc_items_longdesc = S("Exposed cut copper is a decorative block."),
	tiles = {"mcl_copper_exposed_cut.png"},
	is_ground_content = false,
	groups = {pickaxey = 2, building_block = 1, stonecuttable = 1, cut_copper = 1, affected_by_lightning = 1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_on_lightning_strike = on_lightning_strike,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
	_mcl_stonecutter_recipes = { "mcl_copper:block_exposed" },
})

minetest.register_node("mcl_copper:block_weathered_cut", {
	description = S("Weathered Cut Copper"),
	_doc_items_longdesc = S("Weathered cut copper is a decorative block."),
	tiles = {"mcl_copper_weathered_cut.png"},
	is_ground_content = false,
	groups = {pickaxey = 2, building_block = 1, stonecuttable = 1, cut_copper = 1, affected_by_lightning = 1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_on_lightning_strike = on_lightning_strike,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
	_mcl_stonecutter_recipes = { "mcl_copper:block_weathered" },
})

minetest.register_node("mcl_copper:block_oxidized_cut", {
	description = S("Oxidized Cut Copper"),
	_doc_items_longdesc = S("Oxidized cut copper is a decorative block."),
	tiles = {"mcl_copper_oxidized_cut.png"},
	is_ground_content = false,
	groups = {pickaxey = 2, building_block = 1, stonecuttable = 1, cut_copper = 1, affected_by_lightning = 1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_on_lightning_strike = on_lightning_strike,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
	_mcl_stonecutter_recipes = { "mcl_copper:block_oxidized" },
})

mcl_stairs.register_stair_and_slab("copper_cut", {
	baseitem = "mcl_copper:block_cut",
	description_stair = "Cut Copper Stairs",
	description_slab = "Cut Copper Slab",
	overrides = {_mcl_stonecutter_recipes = {"mcl_copper:block", "mcl_copper:block_cut"}}
})

mcl_stairs.register_stair_and_slab("copper_exposed_cut", {
	baseitem = "mcl_copper:block_exposed_cut",
	description_stair = "Exposed Cut Copper Stairs",
	description_slab = "Exposed Cut Copper Slab",
	overrides = {_mcl_stonecutter_recipes = {"mcl_copper:block_exposed", "mcl_copper:block_exposed_cut"}, _on_lightning_strike = on_lightning_strike}
})

mcl_stairs.register_stair_and_slab("copper_weathered_cut", {
	baseitem = "mcl_copper:block_weathered_cut",
	description_stair = "Weathered Cut Copper Stairs",
	description_slab = "Weathered Cut Copper Slab",
	overrides = {_mcl_stonecutter_recipes = {"mcl_copper:block_weathered", "mcl_copper:block_weathered_cut"}, _on_lightning_strike = on_lightning_strike}
})

mcl_stairs.register_stair_and_slab("copper_oxidized_cut", {
	baseitem = "mcl_copper:block_oxidized_cut",
	description_stair = "Oxidized Cut Copper Stairs",
	description_slab = "Oxidized Cut Copper Slab",
	overrides = {_mcl_stonecutter_recipes = {"mcl_copper:block_oxidized", "mcl_copper:block_oxidized_cut"}, _on_lightning_strike = on_lightning_strike}
})
