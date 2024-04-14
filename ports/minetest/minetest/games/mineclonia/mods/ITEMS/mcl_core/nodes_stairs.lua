local S = minetest.get_translator(minetest.get_current_modname())

mcl_stairs.register_stair_and_slab("stone_rough", {
	baseitem = "mcl_core:stone",
	description_stair = S("Stone Stairs"),
	description_slab = S("Stone Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:stone"}},
})

mcl_stairs.register_slab("stone", {
	baseitem = "mcl_core:stone_smooth",
	description = S("Smooth Stone Slab"),
	tiles = {"mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_side.png"},
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:stone_smooth"}},
})

mcl_stairs.register_stair_and_slab("andesite", {
	baseitem = "mcl_core:andesite",
	description_stair = S("Andesite Stairs"),
	description_slab = S("Andesite Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:andesite"}},
})
mcl_stairs.register_stair_and_slab("granite", {
	baseitem = "mcl_core:granite",
	description_stair = S("Granite Stairs"),
	description_slab = S("Granite Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:granite"}},
})
mcl_stairs.register_stair_and_slab("diorite", {
	baseitem = "mcl_core:diorite",
	description_stair = S("Diorite Stairs"),
	description_slab = S("Diorite Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:diorite"}},
})

mcl_stairs.register_stair_and_slab("cobble", {
	baseitem = "mcl_core:cobble",
	description_stair = S("Cobblestone Stairs"),
	description_slab = S("Cobblestone Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:cobble"}},
})
mcl_stairs.register_stair_and_slab("mossycobble", {
	baseitem = "mcl_core:mossycobble",
	description_stair = S("Mossy Cobblestone Stairs"),
	description_slab = S("Mossy Cobblestone Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:mossycobble"}},
})

mcl_stairs.register_stair_and_slab("brick_block", {
	baseitem = "mcl_core:brick_block",
	description_stair = S("Brick Stairs"),
	description_slab = S("Brick Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:brick_block"}},
})


mcl_stairs.register_stair_and_slab("sandstone", {
	baseitem = "mcl_core:sandstone",
	description_stair = S("Sandstone Stairs"),
	description_slab = S("Sandstone Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:sandstone"}},
})
mcl_stairs.register_stair_and_slab("sandstonesmooth2", {
	baseitem = "mcl_core:sandstonesmooth2",
	description_stair = S("Smooth Sandstone Stairs"),
	description_slab = S("Smooth Sandstone Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:sandstone"}},
})
mcl_stairs.register_stair_and_slab("sandstonesmooth", {
	baseitem = "mcl_core:sandstonesmooth",
	description_stair = S("Cut Sandstone Stairs"),
	description_slab = S("Cut Sandstone Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:sandstone", "mcl_core:sandstonesmooth2"}},
})

mcl_stairs.register_stair_and_slab("redsandstone", {
	baseitem = "mcl_core:redsandstone",
	description_stair = S("Red Sandstone Stairs"),
	description_slab = S("Red Sandstone Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:redsandstone"}},
})
mcl_stairs.register_stair_and_slab("redsandstonesmooth2", {
	baseitem = "mcl_core:redsandstonesmooth2",
	description_stair = S("Smooth Red Sandstone Stairs"),
	description_slab = S("Smooth Red Sandstone Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:redsandstone"}},
})
mcl_stairs.register_stair_and_slab("redsandstonesmooth", {
	baseitem = "mcl_core:redsandstonesmooth",
	description_stair = S("Cut Red Sandstone Stairs"),
	description_slab = S("Cut Red Sandstone Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:redsandstone", "mcl_core:redsandstonesmooth2"}},
})

mcl_stairs.register_stair_and_slab("stonebrick", {
	baseitem = "mcl_core:stonebrick",
	description_stair = S("Stone Brick Stairs"),
	description_slab = S("Stone Brick Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:stone", "mcl_core:stonebrick"}},
})

mcl_stairs.register_stair("andesite_smooth", {
	baseitem = "mcl_core:andesite_smooth",
	description = S("Polished Andesite Stairs"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:andesite_smooth", "mcl_core:andesite"}},
})
mcl_stairs.register_slab("andesite_smooth", {
	baseitem = "mcl_core:andesite_smooth",
	description = S("Polished Andesite Slab"),
	tiles = {"mcl_core_andesite_smooth.png", "mcl_core_andesite_smooth.png", "mcl_stairs_andesite_smooth_slab.png"},
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:andesite_smooth", "mcl_core:andesite"}},
})

mcl_stairs.register_stair("granite_smooth", {
	baseitem = "mcl_core:granite_smooth",
	description = S("Polished Granite Stairs"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:granite_smooth", "mcl_core:granite"}},
})
mcl_stairs.register_slab("granite_smooth", {
	baseitem = "mcl_core:granite_smooth",
	description = S("Polished Granite Slab"),
	tiles = {"mcl_core_granite_smooth.png", "mcl_core_granite_smooth.png", "mcl_stairs_granite_smooth_slab.png"},
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:granite_smooth", "mcl_core:granite"}},
})

mcl_stairs.register_stair("diorite_smooth", {
	baseitem = "mcl_core:diorite_smooth",
	description = S("Polished Diorite Stairs"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:diorite_smooth", "mcl_core:diorite"}},
})
mcl_stairs.register_slab("diorite_smooth", {
	baseitem = "mcl_core:diorite_smooth",
	description = S("Polished Diorite Slab"),
	tiles = {"mcl_core_diorite_smooth.png", "mcl_core_diorite_smooth.png", "mcl_stairs_diorite_smooth_slab.png"},
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:diorite_smooth", "mcl_core:diorite"}},
})

mcl_stairs.register_stair_and_slab("stonebrickmossy", {
	baseitem = "mcl_core:stonebrickmossy",
	description_stair = S("Mossy Stone Brick Stairs"),
	description_slab = S("Mossy Stone Brick Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:stonebrickmossy"}},
})
