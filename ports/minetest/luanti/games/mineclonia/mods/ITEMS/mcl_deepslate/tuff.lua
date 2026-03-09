local S = mcl_deepslate.translator

local function register_tuff_variant(name, defs)
	mcl_deepslate.register_variants(name,table.update({
		basename = "tuff",
		basetiles = "mcl_deepslate_tuff",
		basedef = {
			_mcl_hardness = 1.5,
		},
	}, defs))
end

core.register_node("mcl_deepslate:tuff", {
	description = S("Tuff"),
	_doc_items_longdesc = S("Tuff is an ornamental rock formed from volcanic ash, occurring in underground blobs below Y=16."),
	_doc_items_hidden = false,
	tiles = { "mcl_deepslate_tuff.png" },
	groups = { pickaxey = 1, building_block = 1, converts_to_moss = 1, stonecuttable = 1, overworld_carvable = 1, deepslate_ore_target = 1, },
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

core.register_node("mcl_deepslate:tuff_chiseled", {
    description = S("Chiseled Tuff"),
    _doc_items_longdesc = S("Chiseled tuff is a chiseled variant of tuff."),
    _doc_items_hidden = false,
    tiles = { "mcl_deepslate_tuff_chiseled_top.png", "mcl_deepslate_tuff_chiseled_top.png", "mcl_deepslate_tuff_chiseled.png" },
    groups = { pickaxey = 1, building_block = 1 },
    sounds = mcl_sounds.node_sound_stone_defaults(),
    _mcl_blast_resistance = 6,
    _mcl_hardness = 1.5,
    _mcl_stonecutter_recipes = { "mcl_deepslate:tuff", },
})

core.register_node("mcl_deepslate:tuff_chiseled_bricks", {
    description = S("Chiseled Tuff Bricks"),
    _doc_items_longdesc = S("Chiseled tuff bricks are a variant of tuff bricks, featuring a large brick in the center of the block, with geometric design above and below."),
    _doc_items_hidden = false,
    tiles = { "mcl_deepslate_tuff_chiseled_bricks_top.png", "mcl_deepslate_tuff_chiseled_bricks_top.png", "mcl_deepslate_tuff_chiseled_bricks.png"},
    groups = { pickaxey = 1, building_block = 1 },
    sounds = mcl_sounds.node_sound_stone_defaults(),
    _mcl_blast_resistance = 6,
    _mcl_hardness = 1.5,
    _mcl_stonecutter_recipes = { "mcl_deepslate:tuff", "mcl_deepslate:tuff_polished", "mcl_deepslate:tuff_bricks", },
})

register_tuff_variant("", {
    stair = {
        description = S("Tuff Stairs"),
        _mcl_stonecutter_recipes = { "mcl_deepslate:tuff", },
    },
    slab = {
        description = S("Tuff Slab"),
        _mcl_stonecutter_recipes = { "mcl_deepslate:tuff", },
    },
    wall = {
        description = S("Tuff Wall"),
        _mcl_stonecutter_recipes = { "mcl_deepslate:tuff", },
    },
})

register_tuff_variant("polished", {
    node = {
        description = S("Polished Tuff"),
        _doc_items_longdesc = S("Polished tuff is a polished variant of the tuff block."),
        groups = { stonecuttable = 1 },
        _mcl_stonecutter_recipes = { "mcl_deepslate:tuff", },
    },
    stair = {
        description = S("Polished Tuff Stairs"),
        _mcl_stonecutter_recipes = { "mcl_deepslate:tuff", "mcl_deepslate:tuff_polished", },
    },
    slab = {
        description = S("Polished Tuff Slab"),
        _mcl_stonecutter_recipes = { "mcl_deepslate:tuff", "mcl_deepslate:tuff_polished", },
    },
    wall = {
        description = S("Polished Tuff Wall"),
        _mcl_stonecutter_recipes = { "mcl_deepslate:tuff", "mcl_deepslate:tuff_polished", },
    },
})

register_tuff_variant("bricks", {
    node = {
        description = S("Tuff Bricks"),
        _doc_items_longdesc = S("Tuff bricks are a brick variant of tuff."),
        groups = { stonecuttable = 1 },
        _mcl_stonecutter_recipes = { "mcl_deepslate:tuff_polished", },
    },
    stair = {
        description = S("Tuff Bricks Stairs"),
        _mcl_stonecutter_recipes = { "mcl_deepslate:tuff", "mcl_deepslate:tuff_polished", "mcl_deepslate:tuff_polished", },
    },
    slab = {
        description = S("Tuff Bricks Slab"),
        _mcl_stonecutter_recipes = { "mcl_deepslate:tuff", "mcl_deepslate:tuff_polished", "mcl_deepslate:tuff_polished", },
    },
    wall = {
        description = S("Tuff Bricks Wall"),
        _mcl_stonecutter_recipes = { "mcl_deepslate:tuff", "mcl_deepslate:tuff_polished", "mcl_deepslate:tuff_polished", },
    },
})

core.register_craft({
	output = "mcl_deepslate:tuff_polished 4",
	recipe = { { "mcl_deepslate:tuff", "mcl_deepslate:tuff" }, { "mcl_deepslate:tuff", "mcl_deepslate:tuff" } }
})

core.register_craft({
	output = "mcl_deepslate:tuff_bricks 4",
	recipe = { { "mcl_deepslate:tuff_polished", "mcl_deepslate:tuff_polished" }, { "mcl_deepslate:tuff_polished", "mcl_deepslate:tuff_polished" } }
})

core.register_craft({
	output = "mcl_deepslate:tuff_chiseled",
	recipe = {
		{ "mcl_stairs:slab_tuff_polished" },
		{ "mcl_stairs:slab_tuff_polished" },
	},
})

core.register_craft({
	output = "mcl_deepslate:tuff_chiseled_bricks",
	recipe = {
		{ "mcl_stairs:slab_tuff_bricks" },
		{ "mcl_stairs:slab_tuff_bricks" },
	},
})
