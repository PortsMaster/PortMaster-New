local S = minetest.get_translator(minetest.get_current_modname())

local sounds = mcl_sounds.node_sound_glass_defaults({
	footstep = {name = "mcl_amethyst_amethyst_walk",  gain = 0.4},
	dug      = {name = "mcl_amethyst_amethyst_break", gain = 0.44},
})

-- Amethyst block
minetest.register_node("mcl_amethyst:amethyst_block",{
	description = S("Block of Amethyst"),
	_doc_items_longdesc = S("The Block of Amethyst is a decoration block crafted from amethyst shards."),
	tiles = {"mcl_amethyst_amethyst_block.png"},
	groups = {pickaxey = 1, building_block = 1},
	sounds = sounds,
	_mcl_hardness = 1.5,
	_mcl_blast_resistance = 1.5,
})

minetest.register_node("mcl_amethyst:budding_amethyst_block",{
	description = S("Budding Amethyst"),
	_doc_items_longdesc = S("The Budding Amethyst can grow amethyst"),
	tiles = {"mcl_amethyst_budding_amethyst.png"},
	drop = "",
	groups = {
		pickaxey = 1,
		building_block = 1,
		dig_by_piston = 1,
	},
	sounds = sounds,
	_mcl_hardness = 1.5,
	_mcl_blast_resistance = 1.5,
})

mcl_wip.register_wip_item("mcl_amethyst:budding_amethyst_block")

-- Amethyst Shard
minetest.register_craftitem("mcl_amethyst:amethyst_shard",{
	description = S("Amethyst Shard"),
	_doc_items_longdesc = S("An amethyst shard is a crystalline mineral."),
	inventory_image = "mcl_amethyst_amethyst_shard.png",
	groups = {craftitem = 1},
})

-- Calcite
minetest.register_node("mcl_amethyst:calcite",{
	description = S("Calcite"),
	_doc_items_longdesc = S("Calcite can be found as part of amethyst geodes."),
	tiles = {"mcl_amethyst_calcite_block.png"},
	groups = {pickaxey = 1, building_block = 1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_hardness = 0.75,
	_mcl_blast_resistance = 0.75,
})

-- Tinied Glass
minetest.register_node("mcl_amethyst:tinted_glass",{
	description = S("Tinted Glass"),
	_doc_items_longdesc = S("Tinted Glass is a type of glass which blocks lights while it is visually transparent."),
	tiles = {"mcl_amethyst_tinted_glass.png"},
	_mcl_hardness = 0.3,
	_mcl_blast_resistance = 0.3,
	drawtype = "glasslike",
	use_texture_alpha = "blend",
	sunlight_propagates = false,
	groups = {handy = 1, building_block = 1, deco_block = 1},
	sounds = mcl_sounds.node_sound_glass_defaults(),
	is_ground_content = false,
})

-- Amethyst Cluster
local bud_def = {
	{
		size          = "small",
		description   = S("Small Amethyst Bud"),
		long_desc     = S("Small Amethyst Bud is the first growth of amethyst bud."),
		light_source  = 3,
		next_stage    = "mcl_amethyst:medium_amethyst_bud",
		selection_box = { -4/16, -7/16, -4/16, 4/16, -3/16, 4/16 },
	},
	{
		size          = "medium",
		description   = S("Medium Amethyst Bud"),
		long_desc     = S("Medium Amethyst Bud is the second growth of amethyst bud."),
		light_source  = 4,
		next_stage    = "mcl_amethyst:large_amethyst_bud",
		selection_box = { -4.5/16, -8/16, -4.5/16, 4.5/16, -2/16, 4.5/16 },
	},
	{
		size          = "large",
		description   = S("Large Amethyst Bud"),
		long_desc     = S("Large Amethyst Bud is the third growth of amethyst bud."),
		light_source  = 5,
		next_stage    = "mcl_amethyst:amethyst_cluster",
		selection_box = { -4.5/16, -8/16, -4.5/16, 4.5/16, -1/16, 4.5/16 },
	},
}

for _, def in pairs(bud_def) do
	local size = def.size
	local name = "mcl_amethyst:" .. size .. "_amethyst_bud"
	local tile = "mcl_amethyst_amethyst_bud_" .. size .. ".png"
	local inventory_image = "mcl_amethyst_amethyst_bud_" .. size .. ".png"
	minetest.register_node(name, {
		description = def.description,
		_doc_items_longdesc = def.longdesc,
		drop = "",
		tiles = {tile},
		inventory_image = inventory_image,
		paramtype1 = "light",
		paramtype2 = "wallmounted",
		drawtype = "plantlike",
		use_texture_alpha = "clip",
		sunlight_propagates = true,
		walkable = false,
		light_source = def.light_source,
		groups = {
			destroy_by_lava_flow = 1,
			dig_by_piston = 1,
			pickaxey = 1,
			deco_block = 1,
			amethyst_buds = 1,
			attached_node = 1,
		},
		sounds = sounds,
		selection_box = {
			type = "fixed",
			fixed = def.selection_box
		},
		_mcl_hardness = 1.5,
		_mcl_blast_resistance = 1.5,
		_mcl_silk_touch_drop = true,
		_mcl_amethyst_next_grade = def.next_stage,
	})
end

minetest.register_node("mcl_amethyst:amethyst_cluster",{
	description = S("Amethyst Cluster"),
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
	paramtype1 = "light",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	walkable = false,
	light_source = 7,
	groups = {
		destroy_by_lava_flow = 1,
		dig_by_piston = 1,
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
	_mcl_blast_resistance = 1.5,
	_mcl_silk_touch_drop = true,
})

-- Register Crafts
minetest.register_craft({
	output = "mcl_amethyst:amethyst_block",
	recipe = {
		{"mcl_amethyst:amethyst_shard", "mcl_amethyst:amethyst_shard"},
		{"mcl_amethyst:amethyst_shard", "mcl_amethyst:amethyst_shard"},
	},
})

minetest.register_craft({
	output = "mcl_amethyst:tinted_glass 2",
	recipe = {
		{"",                            "mcl_amethyst:amethyst_shard", ""},
		{"mcl_amethyst:amethyst_shard", "mcl_core:glass",              "mcl_amethyst:amethyst_shard",},
		{"",                            "mcl_amethyst:amethyst_shard", ""},
	},
})

if minetest.get_modpath("mcl_spyglass") then
	minetest.clear_craft({output = "mcl_spyglass:spyglass",})
	local function craft_spyglass(ingot)
		minetest.register_craft({
			output = "mcl_spyglass:spyglass",
			recipe = {
				{"mcl_amethyst:amethyst_shard"},
				{ingot},
				{ingot},
			}
		})
	end
	if minetest.get_modpath("mcl_copper") then
		craft_spyglass("mcl_copper:copper_ingot")
	else
		craft_spyglass("mcl_core:iron_ingot")
	end
end

-- Amethyst Growing
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/grow.lua")
