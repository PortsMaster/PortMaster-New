local modname = core.get_current_modname()
local S = core.get_translator(modname)

mcl_furnaces.register_furnace("mcl_smoker:smoker", {
	cook_group = "smoker_cookable",
	factor = 2,
	node_normal = {
		description = S("Smoker"),
		_tt_help = S("Cooks food faster than furnace"),
		_doc_items_longdesc = S(
			"Smokers cook several items, mainly raw foods, into cooked foods, but twice as fast as a normal furnace."),
		_doc_items_usagehelp =
			S("Use the smoker to open the furnace menu.") .. "\n" ..
			S("Place a furnace fuel in the lower slot and the source material in the upper slot.") .. "\n" ..
			S("The smoker will slowly use its fuel to smelt the item.") .. "\n" ..
			S("The result will be placed into the output slot at the right side.") .. "\n" ..
			S("Use the recipe book to see what foods you can smelt, what you can use as fuel and how long it will burn."),
		_doc_items_hidden = false,
		tiles = {
			"smoker_top.png", "smoker_bottom.png",
			"smoker_side.png", "smoker_side.png",
			"smoker_side.png", "smoker_front.png"
		},
	},
	node_active = {
		description = S("Burning Smoker"),
		_doc_items_create_entry = false,
		tiles = {
			"smoker_top.png", "smoker_bottom.png",
			"smoker_side.png", "smoker_side.png",
			"smoker_side.png", {
				name = "smoker_front_on.png",
				animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 48 }
			},
		},
		drop = "mcl_smoker:smoker",
	},
})

core.register_craft({
	output = "mcl_smoker:smoker",
	recipe = {
		{ "",           "group:tree",           "" },
		{ "group:tree", "mcl_furnaces:furnace", "group:tree" },
		{ "",           "group:tree",           "" },
	}
})

doc.add_entry_alias("nodes", "mcl_smoker:smoker", "nodes", "mcl_smoker:smoker_active")
