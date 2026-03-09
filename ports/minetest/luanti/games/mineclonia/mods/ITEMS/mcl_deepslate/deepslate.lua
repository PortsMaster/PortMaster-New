local cobble = "mcl_deepslate:deepslate_cobbled"
local S = mcl_deepslate.translator

local function register_deepslate_variant(name, defs)
	mcl_deepslate.register_variants(name,table.update({
		basename = "deepslate",
		basetiles = "mcl_deepslate",
	}, defs))
end

core.register_node("mcl_deepslate:deepslate", {
	description = S("Deepslate"),
	_doc_items_longdesc = S("Deepslate is a stone type found deep underground in the Overworld that functions similar to regular stone but is harder than the stone."),
	_doc_items_hidden = false,
	tiles = { "mcl_deepslate_top.png", "mcl_deepslate_top.png", "mcl_deepslate.png" },
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = { pickaxey = 1, stone = 1, building_block = 1, material_stone = 1, converts_to_moss = 1, overworld_carvable = 1, deepslate_ore_target = 1, },
	drop = cobble,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_3way,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})

mcl_monster_eggs.register_infested_block("mcl_deepslate:deepslate", S("Infested Deepslate"))
core.register_alias("mcl_deepslate:infested_deepslate", "mcl_monster_eggs:monster_egg_deepslate")

core.register_node("mcl_deepslate:deepslate_reinforced", {
	description = S("Reinforced Deepslate"),
	_doc_items_longdesc = S("Reinforced deepslate is a very hard block undestructable by even wither explosions. It is unobtainable in survival mode."),
	_doc_items_hidden = false,
	tiles = {
		"mcl_deepslate_reinforced_top.png",
		"mcl_deepslate_reinforced_bottom.png",
		{name="mcl_deepslate_reinforced.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=7.25}}
	},
	is_ground_content = false,
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = { handy = 1, unmovable_by_piston = 1, stone = 1, building_block = 1, material_stone = 1,
		   features_cannot_replace = 1, wither_immune = 1, },
	drop = "",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_3way,
	_mcl_blast_resistance = 1200,
	_mcl_hardness = 55,
})

mcl_deepslate.register_deepslate_ore("coal", S("Deepslate Coal Ore"), {_mcl_cooking_output = "mcl_core:coal_lump"})
mcl_deepslate.register_deepslate_ore("iron", S("Deepslate Iron Ore"), {_mcl_cooking_output = "mcl_core:iron_ingot"})
mcl_deepslate.register_deepslate_ore("gold", S("Deepslate Gold Ore"), {_mcl_cooking_output = "mcl_core:gold_ingot"})
mcl_deepslate.register_deepslate_ore("emerald", S("Deepslate Emerald Ore"), {_mcl_cooking_output = "mcl_core:emerald"})
mcl_deepslate.register_deepslate_ore("diamond", S("Deepslate Diamond Ore"), {_mcl_cooking_output = "mcl_core:diamond"})
mcl_deepslate.register_deepslate_ore("lapis", S("Deepslate Lapis Lazuli Ore"), {_mcl_cooking_output = "mcl_core:lapis"})
mcl_deepslate.register_deepslate_ore("redstone", S("Deepslate Redstone Ore"), {
	_mcl_ore_lit = "mcl_deepslate:deepslate_with_redstone_lit",
	_mcl_ore_unlit = "mcl_deepslate:deepslate_with_redstone",
	_mcl_cooking_output = "mcl_redstone:redstone"
})
mcl_deepslate.register_deepslate_ore("redstone_lit", S("Lit Deepslate Redstone Ore"), {
	tiles = { "mcl_deepslate_redstone_ore.png" },
	_mcl_ore_lit = "mcl_deepslate:deepslate_with_redstone_lit",
	_mcl_ore_unlit = "mcl_deepslate:deepslate_with_redstone",
	_mcl_silk_touch_drop = { "mcl_deepslate:deepslate_with_redstone" },
	_mcl_cooking_output = nil,
})
mcl_deepslate.register_deepslate_ore("copper", S("Deepslate Copper Ore"), {_mcl_cooking_output = "mcl_copper:copper_ingot"}, "mcl_copper:stone_with_copper")

register_deepslate_variant("cobbled", {
	node = {
		description = S("Cobbled Deepslate"),
		_doc_items_longdesc = S("Cobbled deepslate is a stone variant that functions similar to cobblestone or blackstone."),
		groups = { cobble = 1, stonecuttable = 1 },
		_mcl_cooking_output = "mcl_deepslate:deepslate",
		_mcl_crafting_output = {square2 = {output = "mcl_deepslate:deepslate_polished 4"}}
	},
	stair = {
		description = S("Cobbled Deepslate Stairs"),
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", },
	},
	slab = {
		description = S("Cobbled Deepslate Slab"),
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", },
	},
	wall = {
		description = S("Cobbled Deepslate Wall"),
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", },
	},
})

register_deepslate_variant("polished", {
	node = {
		description = S("Polished Deepslate"),
		_doc_items_longdesc = S("Polished deepslate is the stone-like polished version of deepslate."),
		groups = { stonecuttable = 1 },
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled",  },
		_mcl_crafting_output = {square2 = {output = "mcl_deepslate:deepslate_bricks 4"}}
	},
	stair = {
		description = S("Polished Deepslate Stairs"),
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", "mcl_deepslate:deepslate_polished", },
	},
	slab = {
		description = S("Polished Deepslate Slab"),
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", "mcl_deepslate:deepslate_polished", },
	},
	wall = {
		description = S("Polished Deepslate Wall"),
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", "mcl_deepslate:deepslate_polished", },
	}
})

register_deepslate_variant("bricks", {
	node = {
		description = S("Deepslate Bricks"),
		_doc_items_longdesc = S("Deepslate bricks are the brick version of deepslate."),
		groups = { stonecuttable = 1 },
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", "mcl_deepslate:deepslate_polished" },
		_mcl_cooking_output = "mcl_deepslate:deepslate_bricks_cracked",
		_mcl_crafting_output = {square2 = {output = "mcl_deepslate:deepslate_tiles 4"}}
	},
	stair = {
		description = S("Deepslate Brick Stairs"),
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", "mcl_deepslate:deepslate_polished", "mcl_deepslate:deepslate_bricks", },
	},
	slab = {
		description = S("Deepslate Brick Slab"),
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", "mcl_deepslate:deepslate_polished", "mcl_deepslate:deepslate_bricks", },
	},
	wall = {
		description = S("Deepslate Brick Wall"),
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", "mcl_deepslate:deepslate_polished", "mcl_deepslate:deepslate_bricks", },
	},
	cracked = {
		description = S("Cracked Deepslate Bricks"),
	}
})

register_deepslate_variant("tiles", {
	node = {
		description = S("Deepslate Tiles"),
		_doc_items_longdesc = S("Deepslate tiles are a decorative variant of deepslate."),
		groups = { stonecuttable = 1 },
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", "mcl_deepslate:deepslate_polished", "mcl_deepslate:deepslate_bricks", },
		_mcl_cooking_output = "mcl_deepslate:deepslate_tiles_cracked"
	},
	stair = {
		description = S("Deepslate Tile Stairs"),
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", "mcl_deepslate:deepslate_polished", "mcl_deepslate:deepslate_bricks", "mcl_deepslate:deepslate_tiles", },
	},
	slab = {
		description = S("Deepslate Tile Slab"),
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", "mcl_deepslate:deepslate_polished", "mcl_deepslate:deepslate_bricks", "mcl_deepslate:deepslate_tiles", },
	},
	wall = {
		description = S("Deepslate Tiles Wall"),
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", "mcl_deepslate:deepslate_polished", "mcl_deepslate:deepslate_bricks", "mcl_deepslate:deepslate_tiles", },
	},
	cracked = {
		description = S("Cracked Deepslate Tiles")
	}
})

register_deepslate_variant("chiseled", {
	node = {
		description = S("Chiseled Deepslate"),
		_doc_items_longdesc = S("Deepslate tiles are a decorative variant of deepslate."),
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", }
	}
})

local deepslate_variants = {"cobbled", "polished", "bricks", "tiles"}
for i = 1, 3 do
	local s = "mcl_deepslate:deepslate_"..deepslate_variants[i]
	core.register_craft({
		output = "mcl_deepslate:deepslate_"..deepslate_variants[i+1].." 4",
		recipe = { { s, s }, { s, s } }
	})
end

core.register_craft({
	output = "mcl_deepslate:deepslate_chiseled",
	recipe = {
		{ "mcl_stairs:slab_deepslate_cobbled" },
		{ "mcl_stairs:slab_deepslate_cobbled" },
	},
})
