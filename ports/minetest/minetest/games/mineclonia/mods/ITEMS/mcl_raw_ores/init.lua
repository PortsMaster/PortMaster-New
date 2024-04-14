local S = minetest.get_translator(minetest.get_current_modname())

local function register_raw_ore(ore, description, block_desc, longdesc, block_longdesc)
	local raw_ingot = "mcl_raw_ores:raw_"..ore
	local texture = "mcl_raw_ores_raw_"..ore

	minetest.register_craftitem(raw_ingot, {
		description = description,
		_doc_items_longdesc = longdesc,
		inventory_image = texture..".png",
		groups = { craftitem = 1, blast_furnace_smeltable = 1 },
	})

	minetest.register_node(raw_ingot.."_block", {
		description = block_desc,
		_doc_items_longdesc = block_longdesc,
		tiles = { texture.."_block.png" },
		is_ground_content = false,
		groups = { pickaxey = 2, building_block = 1, blast_furnace_smeltable = 1 },
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 5,
	})

	minetest.register_craft({
		output = raw_ingot.."_block",
		recipe = {
			{ raw_ingot, raw_ingot, raw_ingot },
			{ raw_ingot, raw_ingot, raw_ingot },
			{ raw_ingot, raw_ingot, raw_ingot },
		},
	})

	minetest.register_craft({
		type = "cooking",
		output = "mcl_core:"..ore.."_ingot",
		recipe = raw_ingot,
		cooktime = 10,
	})

	minetest.register_craft({
		type = "cooking",
		output = "mcl_core:"..ore.."block",
		recipe = raw_ingot.."_block",
		cooktime = 90,
	})

	minetest.register_craft({
		output = raw_ingot.." 9",
		recipe = {
			{ raw_ingot.."_block" },
		},
	})
end

register_raw_ore("iron", S("Raw Iron"), S("Block of Raw Iron"), S("Raw Iron. Mine an Iron ore to get it."),
	S("A block of raw Iron is mostly a decorative block but also useful as a compact storage of raw Iron."))
register_raw_ore("gold", S("Raw Gold"), S("Block of Raw Gold"), S("Raw Gold. Mine a Gold ore to get it."),
	S("A block of raw Gold is mostly a decorative block but also useful as a compact storage of raw Gold."))
