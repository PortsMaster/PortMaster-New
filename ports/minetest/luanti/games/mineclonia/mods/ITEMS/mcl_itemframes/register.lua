local S = core.get_translator(core.get_current_modname())

mcl_itemframes.register_itemframe("frame", {
	node = {
		description = S("Item Frame"),
		_tt_help = S("Can hold an item"),
		_doc_items_longdesc = S("Item frames are decorative blocks in which items can be placed."),
		_doc_items_usagehelp = S("Just place any item on the item frame. Use the item frame again to retrieve the item."),
		tiles = {"mcl_itemframes_itemframe_background.png"},
		inventory_image = "mcl_itemframes_item_frame.png",
		wield_image = "mcl_itemframes_item_frame.png",
	},
})

mcl_itemframes.register_itemframe("glow_frame", {
	node = {
		description = S("Glow Item Frame"),
		_tt_help = S("Can hold an item and glows"),
		_doc_items_longdesc = S("Item frames are decorative blocks in which items can be placed."),
		_doc_items_usagehelp = S("Just place any item on the item frame. Use the item frame again to retrieve the item."),
		tiles = {"mcl_itemframes_glow_item_frame_border.png"},
		inventory_image = "mcl_itemframes_glow_item_frame.png",
		wield_image = "mcl_itemframes_glow_item_frame.png",
	},
	object_properties = {glow = 15},
})

mcl_itemframes.register_itemframe("invisible_frame", {
	node = {
		description = S("Invisible Item Frame"),
		drawtype = "airlike",
		_tt_help = S("Can hold an item but is invisible"),
		inventory_image = "mcl_itemframes_invisible_item_frame.png",
		wield_image = "mcl_itemframes_invisible_item_frame.png",
		groups = {not_in_creative_inventory = 1},
	},
})

mcl_itemframes.register_itemframe("invisible_glow_frame", {
	node = {
		description = S("Invisible Glow Item Frame"),
		drawtype = "airlike",
		_tt_help = S("Can hold an item and glows but is invisible"),
		inventory_image = "mcl_itemframes_invisible_glow_item_frame.png",
		wield_image = "mcl_itemframes_invisible_glow_item_frame.png",
		groups = {not_in_creative_inventory = 1},
	},
	object_properties = {glow = 15},
})

awards.register_achievement("mcl_itemframes:glowframe", {
	title = S("Glow and Behold!"),
	description = S("Craft a glow item frame."),
	icon = "mcl_itemframes_glow_item_frame.png",
	trigger = {
		type = "craft",
		item = "mcl_itemframes:glow_frame",
		target = 1
	},
	type = "Advancement",
	group = "Overworld",
})

-- Register the base frame's recipes.
core.register_craft({
	output = "mcl_itemframes:frame",
	recipe = {
		{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"},
		{"mcl_core:stick", "mcl_mobitems:leather", "mcl_core:stick"},
		{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"},
	}
})

core.register_craft({
	type = "shapeless",
	output = "mcl_itemframes:glow_frame",
	recipe = {"mcl_mobitems:glow_ink_sac", "mcl_itemframes:item_frame"},
})
