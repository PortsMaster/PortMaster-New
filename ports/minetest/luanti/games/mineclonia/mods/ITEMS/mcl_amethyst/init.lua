local S = core.get_translator(core.get_current_modname())

local sounds = mcl_sounds.node_sound_glass_defaults({
	footstep = {name = "mcl_amethyst_amethyst_walk",  gain = 0.4},
	dug      = {name = "mcl_amethyst_amethyst_break", gain = 0.44},
})

-- Amethyst block
core.register_node("mcl_amethyst:amethyst_block",{
	description = S("Block of Amethyst"),
	_doc_items_longdesc = S("The Block of Amethyst is a decoration block crafted from amethyst shards."),
	tiles = {"mcl_amethyst_amethyst_block.png"},
	groups = {pickaxey = 1, building_block = 1},
	sounds = sounds,
	_mcl_hardness = 1.5,
})

core.register_node("mcl_amethyst:budding_amethyst_block",{
	description = S("Budding Amethyst"),
	_doc_items_longdesc = S("The Budding Amethyst can grow amethyst"),
	tiles = {"mcl_amethyst_budding_amethyst.png"},
	drop = "",
	groups = {
		pickaxey = 1,
		building_block = 1,
		dig_by_piston = 1,
		unsticky = 1,
	},
	sounds = sounds,
	_mcl_hardness = 1.5,
})

core.register_craftitem("mcl_amethyst:amethyst_shard",{
	description = S("Amethyst Shard"),
	_doc_items_longdesc = S("An amethyst shard is a crystalline mineral."),
	inventory_image = "mcl_amethyst_amethyst_shard.png",
	groups = {craftitem = 1},
	_mcl_armor_trim_color = "#8246a5",
	_mcl_armor_trim_desc = S("Amethyst Material"),
	_mcl_crafting_output = {square2 = {output = "mcl_amethyst:amethyst_block"}}
})

-- Calcite
core.register_node("mcl_amethyst:calcite",{
	description = S("Calcite"),
	_doc_items_longdesc = S("Calcite can be found as part of amethyst geodes."),
	tiles = {"mcl_amethyst_calcite_block.png"},
	groups = {pickaxey = 1, building_block = 1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_hardness = 0.75,
})

-- Tinted Glass
core.register_node("mcl_amethyst:tinted_glass",{
	description = S("Tinted Glass"),
	_doc_items_longdesc = S("Tinted Glass is a type of glass which blocks lights while it is visually transparent."),
	tiles = {"mcl_amethyst_tinted_glass.png"},
	_mcl_hardness = 0.3,
	drawtype = "glasslike",
	use_texture_alpha = "blend",
	sunlight_propagates = false,
	groups = {handy = 1, building_block = 1, deco_block = 1},
	sounds = mcl_sounds.node_sound_glass_defaults(),
	is_ground_content = false,
})

-- Amethyst Cluster
local bud_def = {
	small = {
		description   = S("Small Amethyst Bud"),
		_doc_items_longdesc = S("Small Amethyst Bud is the first growth of amethyst bud."),
		light_source  = 1,
		_mcl_amethyst_next_grade = "mcl_amethyst:medium_amethyst_bud",
		selection_box = {
			type = "fixed",
			fixed = { -4/16, -7/16, -4/16, 4/16, -3/16, 4/16 },
		}
	},
	medium = {
		description   = S("Medium Amethyst Bud"),
		_doc_items_longdesc = S("Medium Amethyst Bud is the second growth of amethyst bud."),
		light_source  = 2,
		_mcl_amethyst_next_grade = "mcl_amethyst:large_amethyst_bud",
		selection_box = {
			type = "fixed",
			fixed = { -4.5/16, -8/16, -4.5/16, 4.5/16, -2/16, 4.5/16 },
		}
	},
	large = {
		description   = S("Large Amethyst Bud"),
		_doc_items_longdesc = S("Large Amethyst Bud is the third growth of amethyst bud."),
		light_source  = 4,
		_mcl_amethyst_next_grade = "mcl_amethyst:amethyst_cluster",
		selection_box = {
			type = "fixed",
			fixed = { -4.5/16, -8/16, -4.5/16, 4.5/16, -1/16, 4.5/16 },
		},
	},
}

for size, def in pairs(bud_def) do
	core.register_node("mcl_amethyst:" .. size .. "_amethyst_bud", table.merge(def, {
		drop = "",
		tiles = { 	"mcl_amethyst_amethyst_bud_" .. size .. ".png" },
		inventory_image = "mcl_amethyst_amethyst_bud_" .. size .. ".png",
		paramtype = "light",
		paramtype2 = "wallmounted",
		drawtype = "plantlike",
		use_texture_alpha = "clip",
		sunlight_propagates = true,
		walkable = false,
		groups = {
			dig_by_piston = 1,
			unsticky = 1,
			pickaxey = 1,
			deco_block = 1,
			amethyst_buds = 1,
			attached_node = 1,
		},
		sounds = sounds,
		_mcl_hardness = 1.5,
		_mcl_silk_touch_drop = true,
	}))
end

core.register_node("mcl_amethyst:amethyst_cluster",{
	description = S("Amethyst Cluster"),
	paramtype = "light",
	_doc_items_longdesc = S("Amethyst Cluster is the final growth of amethyst bud."),
	drop = {
		max_items = 1,
		items = {
			{
				tools = {"~mcl_tools:pick_"},
				items = {"mcl_amethyst:amethyst_shard 4"},
			},
			{
				items = {"mcl_amethyst:amethyst_shard 2"},
			},
		}
	},
	tiles = {"mcl_amethyst_amethyst_cluster.png",},
	inventory_image = "mcl_amethyst_amethyst_cluster.png",
	paramtype2 = "wallmounted",
	drawtype = "plantlike",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	walkable = false,
	light_source = 5,
	groups = {
		dig_by_piston = 1,
		unsticky = 1,
		pickaxey = 1,
		deco_block = 1,
		attached_node = 1,
	},
	sounds = sounds,
	selection_box = {
		type = "fixed",
		fixed = { -4.8/16, -8/16, -4.8/16, 4.8/16, 3.9/16, 4.8/16 },
	},
	_mcl_hardness = 1.5,
	_mcl_silk_touch_drop = true,
})

-- Register Crafts
core.register_craft({
	output = "mcl_amethyst:tinted_glass 2",
	recipe = {
		{"",                            "mcl_amethyst:amethyst_shard", ""},
		{"mcl_amethyst:amethyst_shard", "mcl_core:glass",              "mcl_amethyst:amethyst_shard",},
		{"",                            "mcl_amethyst:amethyst_shard", ""},
	},
})

-- Amethyst Growth
local modpath = core.get_modpath (core.get_current_modname ())
dofile(modpath .. "/grow.lua")

-- Level generation.
mcl_levelgen.register_levelgen_script (modpath .. "/lg_register.lua")
