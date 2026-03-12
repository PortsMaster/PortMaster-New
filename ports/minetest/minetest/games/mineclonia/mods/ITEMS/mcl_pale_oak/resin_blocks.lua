local S = core.get_translator("mcl_pale_oak")

core.register_craftitem("mcl_pale_oak:resin_clump", {
	description = S("Resin Clump"),
	inventory_image = "mcl_pale_oak_resin_clump.png",
	groups = { craftitem = 1 },
	_mcl_crafting_output = {
		square3 = {output = "mcl_pale_oak:block_of_resin"}
	},
	_mcl_cooking_output = "mcl_pale_oak:resin_brick"
})

core.register_craftitem("mcl_pale_oak:resin_brick", {
	description = S("Resin Brick"),
	inventory_image = "mcl_pale_oak_resin_brick.png",
	groups = { craftitem = 1 },
	_mcl_crafting_output = {
		square2 = {output = "mcl_pale_oak:resin_brick_block"}
	},
	_mcl_armor_trim_color = "#ff5315",
	_mcl_armor_trim_desc = "Resin Material"
})

core.register_node("mcl_pale_oak:block_of_resin", {
	description = S("Block of Resin"),
	tiles = {"mcl_pale_oak_resin_block.png"},
	_mcl_hardness = 0,
	groups = { dig_immediate = 3 },
	_mcl_crafting_output = {
		single = {output = "mcl_pale_oak:resin_clump 9"}
	}
})

core.register_node("mcl_pale_oak:resin_brick_block", {
	description = S("Resin Bricks"),
	tiles = {"mcl_pale_oak_resin_brick_block.png"},
	_mcl_hardness = 1.5,
	_mcl_blast_resistance = 6,
	groups = { pickaxey = 1, material_stone = 1 },
})

core.register_node("mcl_pale_oak:chiseled_resin_brick", {
	description = S("Chiseled Resin Brick"),
	tiles = {"mcl_pale_oak_chiseled_resin_bricks.png"},
	_mcl_hardness = 1.5,
	_mcl_blast_resistance = 6,
	groups = { pickaxey = 1 },
})

mcl_stairs.register_stair_and_slab("resin_brick", {
    baseitem = "mcl_pale_oak:resin_brick_block",
    description_stair = "Resin Brick Stairs",
    description_slab = "Resin Brick Slab",
	groups = { pickaxey=1 },
	overrides = {
		_mcl_stonecutter_recipes = {"mcl_pale_oak:resin_brick_block"},
	}
})

mcl_walls.register_wall("mcl_pale_oak:resin_brick_wall", "Resin Brick Wall", "mcl_pale_oak:resin_brick", {"mcl_pale_oak_resin_brick_block.png"})
