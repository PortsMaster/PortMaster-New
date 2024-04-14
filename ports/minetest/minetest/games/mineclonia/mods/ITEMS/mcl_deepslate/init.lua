local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local cobble = "mcl_deepslate:deepslate_cobbled"

local function spawn_silverfish(pos, oldnode, oldmetadata, digger)
	if not minetest.is_creative_enabled("") then
		minetest.add_entity(pos, "mobs_mc:silverfish")
	end
end

minetest.register_node("mcl_deepslate:deepslate", {
	description = S("Deepslate"),
	_doc_items_longdesc = S("Deepslate is a stone type found deep underground in the Overworld that functions similar to regular stone but is harder than the stone."),
	_doc_items_hidden = false,
	tiles = { "mcl_deepslate_top.png", "mcl_deepslate_top.png", "mcl_deepslate.png" },
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = { pickaxey = 1, stone = 1, building_block = 1, material_stone = 1, converts_to_moss = 1 },
	drop = cobble,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_3way,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_deepslate:deepslate_reinforced", {
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
	groups = { stone = 1, building_block = 1, material_stone = 1 },
	drop = "",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_3way,
	_mcl_blast_resistance = 1200,
	_mcl_hardness = 55,
})

minetest.register_node("mcl_deepslate:infested_deepslate", {
	description = S("Infested Deepslate"),
	_doc_items_longdesc = S("An infested block is a block from which a silverfish will pop out when it is broken. It looks identical to its normal counterpart."),
	_tt_help = S("Hides a silverfish"),
	tiles = { "mcl_deepslate_top.png", "mcl_deepslate_top.png", "mcl_deepslate.png" },
	groups = { dig_immediate = 3, spawns_silverfish = 1, deco_block = 1 },
	drop = "",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	after_dig_node = spawn_silverfish,
	_mcl_hardness = 0,
	_mcl_blast_resistance = 0.5,
})

minetest.register_node("mcl_deepslate:tuff", {
	description = S("Tuff"),
	_doc_items_longdesc = S("Tuff is an ornamental rock formed from volcanic ash, occurring in underground blobs below Y=16."),
	_doc_items_hidden = false,
	tiles = { "mcl_deepslate_tuff.png" },
	groups = { pickaxey = 1, deco_block = 1, converts_to_moss = 1 },
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
	_mcl_silk_touch_drop = true,
})

local function register_deepslate_ore(item, desc, extra, basename)
	local nodename = "mcl_deepslate:deepslate_with_"..item
	local basename = basename or "mcl_core:stone_with_" .. item

	local def = table.copy(minetest.registered_nodes[basename])
	def._doc_items_longdesc = S("@1 is a variant of @2 that can generate in deepslate and tuff blobs.", desc, def.description)
	def.description = desc
	def.tiles = { "mcl_deepslate_" .. item .. "_ore.png" }

	table.update(def,extra or {})

	minetest.register_node(nodename, def)

	local result = minetest.get_craft_result({
		method = "cooking",
		width = 1,
		items = {basename},
	})

	if not result.item:is_empty() then
		minetest.register_craft({
			type = "cooking",
			output = result.item:to_string(),
			recipe = nodename,
			cooktime = result.time,
		})
	end
end

register_deepslate_ore("coal", S("Deepslate Coal Ore"))
register_deepslate_ore("iron", S("Deepslate Iron Ore"))
register_deepslate_ore("gold", S("Deepslate Gold Ore"))
register_deepslate_ore("emerald", S("Deepslate Emerald Ore"))
register_deepslate_ore("diamond", S("Deepslate Diamond Ore"))
register_deepslate_ore("lapis", S("Deepslate Lapis Lazuli Ore"))
register_deepslate_ore("redstone", S("Deepslate Redstone Ore"), {
	_mcl_ore_lit = "mcl_deepslate:deepslate_with_redstone_lit",
	_mcl_ore_unlit = "mcl_deepslate:deepslate_with_redstone",
})
register_deepslate_ore("redstone_lit", S("Lit Deepslate Redstone Ore"), {
	tiles = { "mcl_deepslate_redstone_ore.png" },
	_mcl_ore_lit = "mcl_deepslate:deepslate_with_redstone_lit",
	_mcl_ore_unlit = "mcl_deepslate:deepslate_with_redstone",
	_mcl_silk_touch_drop = { "mcl_deepslate:deepslate_with_redstone" },
})
register_deepslate_ore("copper", S("Deepslate Copper Ore"), nil, "mcl_copper:stone_with_copper")

local function register_deepslate_variant(name, defs)
	local main_itemstring = "mcl_deepslate:deepslate_"..name
	local main_def = {
		_doc_items_hidden = false,
		tiles = { "mcl_deepslate_"..name..".png" },
		is_ground_content = false,
		groups = { pickaxey = 1, building_block = 1, material_stone = 1 },
		sounds = mcl_sounds.node_sound_stone_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3.5,
		_mcl_silk_touch_drop = true,
	}
	if defs.node then
		defs.node.groups = table.merge(main_def.groups, defs.node.groups)
		minetest.register_node(main_itemstring, table.merge(main_def, defs.node))
	end

	if defs.cracked then
		minetest.register_node(main_itemstring.."_cracked", table.merge(main_def, {
			_doc_items_longdesc = S("@1 are a cracked variant.", defs.cracked.description),
			tiles = { "mcl_deepslate_"..name.."_cracked.png" },
		}, defs.cracked))
	end
	if defs.stair then
		mcl_stairs.register_stair("deepslate_"..name, {
			description = defs.stair.description,
			baseitem = main_itemstring,
			overrides = defs.stair
		})
	end
	if defs.slab then
		mcl_stairs.register_slab("deepslate_"..name, {
			description = defs.slab.description,
			baseitem = main_itemstring,
			overrides = defs.slab
		})
	end

	if defs.wall then
		mcl_walls.register_wall("mcl_deepslate:deepslate"..name.."wall", defs.wall.description, main_itemstring, nil, nil, nil, nil, defs.wall)
	end
end

register_deepslate_variant("cobbled", {
	node = {
		description = S("Cobbled Deepslate"),
		_doc_items_longdesc = S("Cobbled deepslate is a stone variant that functions similar to cobblestone or blackstone."),
		groups = { cobble = 1, stonecuttable = 1 },
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
		_mcl_stonecutter_recipes = { "mcl_deepslate:deepslate_cobbled", "mcl_deepslate:deepslate_polished", "mcl_deepslate:deepslate_bricks", },
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

local deepslate_variants =  {"cobbled", "polished", "bricks", "tiles"}
for i = 1, 3 do
	local s = "mcl_deepslate:deepslate_"..deepslate_variants[i]
	minetest.register_craft({
		output = "mcl_deepslate:deepslate_"..deepslate_variants[i+1].." 4",
		recipe = { { s, s }, { s, s } }
	})
end

for _, p in pairs({ "bricks", "tiles" }) do
	minetest.register_craft({
		type = "cooking",
		output = "mcl_deepslate:deepslate_"..p.."_cracked",
		recipe = "mcl_deepslate:deepslate_"..p,
		cooktime = 10,
	})
end

minetest.register_craft({
	type = "cooking",
	output = "mcl_deepslate:deepslate",
	recipe = cobble,
	cooktime = 10,
})

minetest.register_craft({
	output = "mcl_deepslate:deepslate_chiseled",
	recipe = {
		{ "mcl_stairs:slab_deepslate_cobbled" },
		{ "mcl_stairs:slab_deepslate_cobbled" },
	},
})
