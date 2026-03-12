local S = core.get_translator(core.get_current_modname())
local D = mcl_util.get_dynamic_translator()

local function on_lightning_strike(pos, _, pos2)
	local node = core.get_node(pos)
	if vector.distance(pos, pos2) <= 1 then
		node.name = mcl_copper.get_undecayed(node.name, 4)
	else
		node.name = mcl_copper.get_undecayed(node.name, math.random(4))
	end
	core.swap_node(pos, node)
end

local function bulb_connects_to()
	return true
end

local function bulb_update(pos, node)
	local name = node.name
	local defs = core.registered_nodes[name]
	local switch_to = defs._mcl_copper_bulb_switch_to
	local powered = name:find("_powered")
	local power = mcl_redstone.get_power(pos)
	local on = core.get_item_group(name, "comparator_signal") == 15
	if powered then
		if power == 0 then
			return {name = switch_to, param2 = 0}
		end
	else
		if power ~= 0 then
			if on then
				return {name = switch_to, param2 = 1}
			else
				return {name = switch_to, param2 = 1}
			end
		end
	end
	return node
end

core.register_node("mcl_copper:stone_with_copper", {
	description = S("Copper Ore"),
	_doc_items_longdesc = S("Some copper contained in stone, it is pretty common and can be found below sea level."),
	tiles = {"default_stone.png^mcl_copper_ore.png"},
	groups = {pickaxey = 3, building_block = 1, material_stone = 1, blast_furnace_smeltable=1},
	drop = {
		max_items = 1,
		items = {
			{items = {"mcl_copper:raw_copper 5"}, rarity = 4},
			{items = {"mcl_copper:raw_copper 4"}, rarity = 3},
			{items = {"mcl_copper:raw_copper 3"}, rarity = 2},
			{items = {"mcl_copper:raw_copper 2"}},
		}
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
	_mcl_cooking_output = "mcl_copper:copper_ingot"
})

core.register_node("mcl_copper:block_raw", {
	description = S("Block of Raw Copper"),
	_doc_items_longdesc = S("A block used for compact raw copper storage."),
	tiles = {"mcl_copper_block_raw.png"},
	is_ground_content = false,
	groups = {pickaxey = 2, building_block = 1, blast_furnace_smeltable = 1 },
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
	_mcl_crafting_output = {single = {output = "mcl_copper:raw_copper 9"}}
})

local n_desc = {
	[""] = "",
	["_exposed"] = "Exposed ",
	["_weathered"] = "Weathered ",
	["_oxidized"] = "Oxidized ",
}

local bulb_light = {
	[""] = core.LIGHT_MAX,
	["_exposed"] = 12,
	["_weathered"] = 8,
	["_oxidized"] = 4,
}

for n, desc in pairs(n_desc) do
	local bdesc = desc
	if n == "" then
		bdesc = "Block of "
	end
	core.register_node("mcl_copper:block"..n, {
		description = D(bdesc .. "Copper"),
		_doc_items_longdesc = D(bdesc .. "Copper is mostly a decorative block."),
		tiles = {"mcl_copper"..(n == "" and "_block" or n) ..".png"},
		is_ground_content = false,
		groups = {pickaxey = 2, building_block = 1, stonecuttable = 1},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
		_mcl_crafting_output = {
			single = {
				output = n == "" and "mcl_copper:copper_ingot 9" or ""
			}
		}
	})

	core.register_node("mcl_copper:block"..n.."_cut", {
		description = D(desc .. "Cut Copper"),
		_doc_items_longdesc = D(desc .. "Cut Copper is mostly a decorative block."),
		tiles = {"mcl_copper"..(n == "" and "_block" or n) .."_cut.png"},
		is_ground_content = false,
		groups = {pickaxey = 2, building_block = 1, stonecuttable = 1},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
		_mcl_stonecutter_recipes = { "mcl_copper:block"..n }
	})

	core.register_node("mcl_copper:block"..n.."_chiseled", {
		description = D(desc .. "Chiseled Copper"),
		_doc_items_longdesc = D(desc .. "Chiseled Copper is mostly a decorative block."),
		tiles = {"mcl_copper"..(n == "" and "_block" or n) .."_chiseled.png"},
		is_ground_content = false,
		groups = {pickaxey = 2, building_block = 1, stonecuttable = 1},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
		_mcl_stonecutter_recipes = { "mcl_copper:block"..n, "mcl_copper:block"..n.."_cut" }
	})
	core.register_node("mcl_copper:block"..n.."_grate", {
		description = D(desc .. "Copper Grate"),
		_doc_items_longdesc = D(desc .. "Copper Grate is mostly a decorative block."),
		drawtype = "allfaces",
		paramtype = "light",
		tiles = {"mcl_copper"..(n == "" and "_block" or n) .."_grate.png"},
		use_texture_alpha = "clip",
		is_ground_content = false,
		groups = {pickaxey = 2, building_block = 1, copper_grate = 1, },
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
		_mcl_stonecutter_recipes = { "mcl_copper:block"..n }
	})

	core.register_node("mcl_copper:bulb"..n.."_on", {
		description = D(desc .. "Copper Bulb On"),
		_doc_items_longdesc = D(desc .. "Copper Bulb is mostly a decorative block."),
		tiles = {"mcl_copper"..(n == "" and "_block" or n) .."_bulb_on.png"},
		is_ground_content = false,
		light_source = bulb_light[n],
		paramtype = "light",
		groups = {pickaxey = 2, not_in_creative_inventory = 1, redstone_not_conductive = 1, comparator_signal = 15},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
		drop = "mcl_copper:bulb"..n.."_off",
		_mcl_copper_bulb_switch_to = "mcl_copper:bulb"..n.."_off_powered",
		_mcl_redstone = {connects_to = bulb_connects_to, update = bulb_update},
	})

	core.register_node("mcl_copper:bulb"..n.."_on_powered", {
		description = D(desc .. "Copper Bulb Powered On"),
		_doc_items_longdesc = D(desc .. "Copper Bulb is mostly a decorative block."),
		tiles = {"mcl_copper"..(n == "" and "_block" or n) .."_bulb_on_powered.png"},
		is_ground_content = false,
		light_source = bulb_light[n],
		paramtype = "light",
		groups = {pickaxey = 2, not_in_creative_inventory = 1, redstone_not_conductive = 1, comparator_signal = 15},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
		drop = "mcl_copper:bulb"..n.."_off",
		_mcl_copper_bulb_switch_to = "mcl_copper:bulb"..n.."_on",
		_mcl_redstone = {connects_to = bulb_connects_to, update = bulb_update}
	})

	core.register_node("mcl_copper:bulb"..n.."_off", {
		description = D(desc .. "Copper Bulb"),
		_doc_items_longdesc = D(desc .. "Copper Bulb is mostly a decorative block."),
		tiles = {"mcl_copper"..(n == "" and "_block" or n) .."_bulb_off.png"},
		is_ground_content = false,
		groups = {pickaxey = 2, building_block = 1, redstone_not_conductive = 1, comparator_signal = 0},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
		_mcl_copper_bulb_switch_to = "mcl_copper:bulb"..n.."_on_powered",
		_mcl_redstone = {connects_to = bulb_connects_to, update = bulb_update},
	})

	core.register_node("mcl_copper:bulb"..n.."_off_powered", {
		description = D(desc .. "Copper Bulb Powered Off"),
		_doc_items_longdesc = D(desc .. "Copper Bulb is mostly a decorative block."),
		tiles = {"mcl_copper"..(n == "" and "_block" or n) .."_bulb_off_powered.png"},
		is_ground_content = false,
		groups = {pickaxey = 2, not_in_creative_inventory = 1, redstone_not_conductive = 1, comparator_signal = 0 },
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
		drop = "mcl_copper:bulb"..n.."_off",
		_mcl_copper_bulb_switch_to = "mcl_copper:bulb"..n.."_off",
		_mcl_redstone = {connects_to = bulb_connects_to, update = bulb_update},
	})

	mcl_doors:register_trapdoor("mcl_copper:trapdoor"..n, {
		description = D(desc .. "Copper Trapdoor"),
		groups = { copper = 1, pickaxey = 2, deco_block = 1 },
		sounds = mcl_sounds.node_sound_metal_defaults(),
		sound_close = "doors_steel_door_close",
		sound_open = "doors_steel_door_open",
		tile_front = "mcl_copper_trapdoor"..n..".png",
		tile_side = "mcl_copper_trapdoor"..n.."_side.png",
		wield_image = "mcl_copper_trapdoor"..n..".png",
		_mcl_hardness = 3
	})

	mcl_doors:register_door("mcl_copper:door"..n, {
		description = D(desc .. "Copper Door"),
		groups = { door = 1, copper = 1, pickaxey = 2, building_block = 1, door_iron = 1,},
		inventory_image = "mcl_copper_door"..n..".png",
		sounds = mcl_sounds.node_sound_metal_defaults(),
		sound_close = "doors_steel_door_close",
		sound_open = "doors_steel_door_open",
		tiles_bottom = { "mcl_copper_door"..n.."_bottom.png^[transformFX", "mcl_copper_door"..n.."_bottom.png" },
		tiles_top = { "mcl_copper_door"..n.."_top.png^[transformFX", "mcl_copper_door"..n.."_top.png" },
		_mcl_hardness = 3
	})

	mcl_lanterns.register_lantern("copper_lantern"..n, {
		description = D(desc .. "Copper Lantern"),
		longdesc = D(desc .. "Copper Lanterns are light sources which can be placed on the top or the bottom of most blocks."),
		texture = "mcl_copper_lantern"..n..".png",
		texture_inv = "mcl_copper_lantern"..n.."_inv.png",
		light_level = core.LIGHT_MAX,
	})

	mcl_lanterns.register_chain("copper_chain"..n, {
		description = D(desc .. "Copper Chain"),
		_doc_items_longdesc = D(desc .. "Copper Chains are metallic decoration blocks."),
		inventory_image = "mcl_copper_chain"..n.."_inv.png",
		tiles = {"mcl_copper_chain"..n..".png"},
	})

	mcl_panes.register_pane("copper_bar"..n, {
		description = D(desc .. "Copper Bars"),
		_doc_items_longdesc = S(desc.."Copper Bars neatly connect to their neighbors as you build them."),
		textures = {"mcl_copper_pane"..n..".png", "mcl_copper_pane"..n..".png","mcl_copper_pane_top"..n..".png"},
		inventory_image = "mcl_copper_pane"..n..".png",
		groups = {pickaxey = 1, copper_bars = 1},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		use_texture_alpha = "clip",
		recipe = {
			{"mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot"},
			{"mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot"},
		},
		_mcl_blast_resistance = 6,
		_mcl_hardness = 5
	})
end

-- These are static translation strings, but use D instead of S, anyway, to get
-- them sorted with their 'parent' cut copper blocks in the tr and po files
mcl_stairs.register_stair_and_slab("copper_cut", {
	baseitem = "mcl_copper:block_cut",
	description_stair = D("Cut Copper Stairs"),
	description_slab = D("Cut Copper Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_copper:block", "mcl_copper:block_cut"}}
})

mcl_stairs.register_stair_and_slab("copper_exposed_cut", {
	baseitem = "mcl_copper:block_exposed_cut",
	description_stair = D("Exposed Cut Copper Stairs"),
	description_slab = D("Exposed Cut Copper Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_copper:block_exposed", "mcl_copper:block_exposed_cut"}, _on_lightning_strike = on_lightning_strike}
})

mcl_stairs.register_stair_and_slab("copper_weathered_cut", {
	baseitem = "mcl_copper:block_weathered_cut",
	description_stair = D("Weathered Cut Copper Stairs"),
	description_slab = D("Weathered Cut Copper Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_copper:block_weathered", "mcl_copper:block_weathered_cut"}, _on_lightning_strike = on_lightning_strike}
})

mcl_stairs.register_stair_and_slab("copper_oxidized_cut", {
	baseitem = "mcl_copper:block_oxidized_cut",
	description_stair = D("Oxidized Cut Copper Stairs"),
	description_slab = D("Oxidized Cut Copper Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_copper:block_oxidized", "mcl_copper:block_oxidized_cut"}, _on_lightning_strike = on_lightning_strike}
})

mcl_torches.register_torch({
        name = "copper_torch",
        description = S("Copper Torch"),
        doc_items_longdesc = S("Copper Torches are light sources which can be placed at the side or on the top of most blocks."),
        doc_items_hidden = false,
        icon = "mcl_copper_torch.png",
        tiles = {{
                name = "mcl_copper_torch_animated.png",
                animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
        }},
        light =  14,
        groups = {dig_immediate = 3, deco_block = 1},
        sounds = mcl_sounds.node_sound_wood_defaults(),
        particles = true,
        flame_type = 1,
})
