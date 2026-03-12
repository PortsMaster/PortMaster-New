local S = core.get_translator(core.get_current_modname())

local function register_raw_ore(ore, description, block_desc, longdesc, block_longdesc, blockgroups)
	local raw_ingot = "mcl_raw_ores:raw_"..ore
	local texture = "mcl_raw_ores_raw_"..ore

	core.register_craftitem(raw_ingot, {
		description = description,
		_doc_items_longdesc = longdesc,
		inventory_image = texture..".png",
		groups = { craftitem = 1, blast_furnace_smeltable = 1 },
		_mcl_cooking_output = "mcl_core:"..ore.."_ingot",
		_mcl_crafting_output = {square3 = {output = raw_ingot.."_block"}}
	})

	core.register_node(raw_ingot.."_block", {
		description = block_desc,
		_doc_items_longdesc = block_longdesc,
		tiles = { texture.."_block.png" },
		is_ground_content = false,
		groups = table.merge ({
			pickaxey = 2,
			building_block = 1,
			blast_furnace_smeltable = 1,
		}, blockgroups),
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 5,
		_mcl_crafting_output = {single = {output = raw_ingot.." 9"}}
	})
end

register_raw_ore("iron", S("Raw Iron"), S("Block of Raw Iron"), S("Raw Iron. Mine an Iron ore to get it."),
	S("A block of raw Iron is mostly a decorative block but also useful as a compact storage of raw Iron."))
register_raw_ore("gold", S("Raw Gold"), S("Block of Raw Gold"), S("Raw Gold. Mine a Gold ore to get it."),
	S("A block of raw Gold is mostly a decorative block but also useful as a compact storage of raw Gold."),
	{ piglin_protected = 1, })
