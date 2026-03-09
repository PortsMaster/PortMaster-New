local S = core.get_translator(core.get_current_modname())

core.register_craftitem("mcl_fishing:fish_raw", {
	description = S("Raw Fish"),
	_doc_items_longdesc = S("Raw fish is obtained by fishing and is a food item which can be eaten safely. Cooking it improves its nutritional value."),
	inventory_image = "mcl_fishing_fish_raw.png",
	groups = { food=2, eatable = 2, smoker_cookable = 1, campfire_cookable = 1 },
	_mcl_saturation = 0.4,
	_mcl_cooking_output = "mcl_fishing:fish_cooked"
})

core.register_craftitem("mcl_fishing:fish_cooked", {
	description = S("Cooked Fish"),
	_doc_items_longdesc = S("Mmh, fish! This is a healthy food item."),
	inventory_image = "mcl_fishing_fish_cooked.png",
	groups = { food=2, eatable=5 },
	_mcl_saturation = 6,
})

core.register_craftitem("mcl_fishing:salmon_raw", {
	description = S("Raw Salmon"),
	_doc_items_longdesc = S("Raw salmon is obtained by fishing and is a food item which can be eaten safely. Cooking it improves its nutritional value."),
	inventory_image = "mcl_fishing_salmon_raw.png",
	groups = { food=2, eatable = 2, smoker_cookable = 1, campfire_cookable = 1 },
	_mcl_saturation = 0.4,
	_mcl_cooking_output = "mcl_fishing:salmon_cooked"
})

core.register_craftitem("mcl_fishing:salmon_cooked", {
	description = S("Cooked Salmon"),
	_doc_items_longdesc = S("This is a healthy food item which can be eaten."),
	inventory_image = "mcl_fishing_salmon_cooked.png",
	groups = { food=2, eatable=6 },
	_mcl_saturation = 9.6,
})

core.register_craftitem("mcl_fishing:clownfish_raw", {
	description = S("Clownfish"),
	_doc_items_longdesc = S("Clownfish may be obtained by fishing (and luck) and is a food item which can be eaten safely."),
	inventory_image = "mcl_fishing_clownfish_raw.png",
	groups = { food=2, eatable = 1 },
	_mcl_saturation = 0.2,
})

core.register_craftitem("mcl_fishing:pufferfish_raw", {
	description = S("Pufferfish"),
	_tt_help = core.colorize(mcl_colors.YELLOW, S("Very poisonous")),
	_doc_items_longdesc = S("Pufferfish are a common species of fish and can be obtained by fishing. They can technically be eaten, but they are very bad for humans. Eating a pufferfish only restores 1 hunger point and will poison you very badly (which drains your health non-fatally) and causes serious food poisoning (which increases your hunger)."),
	inventory_image = "mcl_fishing_pufferfish_raw.png",
	groups = { food=2, eatable=1, brewitem = 1 },
	_mcl_saturation = 0.2,
	_mcl_eat_effect = function (_, placer)
		mcl_potions.give_effect_by_level("hunger", placer, 3, 15)
		mcl_potions.give_effect_by_level("poison", placer, 3, 60)
		mcl_potions.give_effect_by_level("nausea", placer, 2, 15)
	end
})

core.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{"","","mcl_core:stick"},
		{"","mcl_core:stick","mcl_mobitems:string"},
		{"mcl_core:stick","","mcl_mobitems:string"},
	}
})
core.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{"mcl_core:stick", "", ""},
		{"mcl_mobitems:string", "mcl_core:stick", ""},
		{"mcl_mobitems:string","","mcl_core:stick"},
	}
})

