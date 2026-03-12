local S = core.get_translator(core.get_current_modname())

core.register_craftitem("mcl_core:stick", {
	description = S("Stick"),
	_doc_items_longdesc = S("Sticks are a very versatile crafting material; used in countless crafting recipes."),
	_doc_items_hidden = false,
	inventory_image = "default_stick.png",
	groups = { craftitem=1, stick=1 },
	_mcl_toollike_wield = true,
	_mcl_burntime = 5
})

core.register_craftitem("mcl_core:paper", {
	description = S("Paper"),
	_doc_items_longdesc = S("Paper is used to craft books and maps."),
	inventory_image = "default_paper.png",
	groups = { craftitem=1 },
})

core.register_craftitem("mcl_core:coal_lump", {
	description = S("Coal"),
	_doc_items_longdesc = S("“Coal” refers to coal lumps obtained by digging coal ore which can be found underground. Coal is your standard furnace fuel, but it can also be used to make torches, coal blocks and a few other things."),
	_doc_items_hidden = false,
	inventory_image = "default_coal_lump.png",
	groups = { craftitem=1, coal=1 },
	_mcl_burntime = 80,
	_mcl_crafting_output = {square3 = {output = "mcl_core:coalblock"}}
})

core.register_craftitem("mcl_core:charcoal_lump", {
	description = S("Charcoal"),
	_doc_items_longdesc = S("Charcoal is an alternative furnace fuel created by cooking wood in a furnace. It has the same burning time as coal and also shares many of its crafting recipes, but it can not be used to create coal blocks."),
	_doc_items_hidden = false,
	inventory_image = "mcl_core_charcoal.png",
	groups = { craftitem=1, coal=1 },
	_mcl_burntime = 80
})

core.register_craftitem("mcl_core:iron_nugget", {
	description = S("Iron Nugget"),
	_doc_items_longdesc = S("Iron nuggets are very small pieces of molten iron; the main purpose is to create iron ingots."),
	inventory_image = "mcl_core_iron_nugget.png",
	groups = {craftitem=1, metal_nugget=1},
	_mcl_crafting_output = {square3 = {output = "mcl_core:iron_ingot"}}
})

core.register_craftitem("mcl_core:gold_nugget", {
	description = S("Gold Nugget"),
	_doc_items_longdesc = S("Gold nuggets are very small pieces of molten gold; the main purpose is to create gold ingots."),
	inventory_image = "mcl_core_gold_nugget.png",
	groups = {craftitem=1, metal_nugget=1},
	_mcl_crafting_output = {square3 = {output = "mcl_core:gold_ingot"}}
})

core.register_craftitem("mcl_core:diamond", {
	description = S("Diamond"),
	_doc_items_longdesc = S("Diamonds are precious minerals and useful to create the highest tier of armor and tools."),
	inventory_image = "default_diamond.png",
	groups = { craftitem=1, beacon_fuel = 1 },
	_mcl_armor_trim_color = "#5faed8",
	_mcl_armor_trim_desc = S("Diamond Material"),
	_mcl_crafting_output = {square3 = {output = "mcl_core:diamondblock"}}
})

core.register_craftitem("mcl_core:clay_lump", {
	description = S("Clay Ball"),
	_doc_items_longdesc = S("Clay balls are a raw material, mainly used to create bricks in the furnace."),
	_doc_items_hidden = false,
	inventory_image = "default_clay_lump.png",
	groups = { craftitem=1 },
	_mcl_cooking_output = "mcl_core:brick",
	_mcl_crafting_output = {square2 = {output = "mcl_core:clay"}}
})

core.register_craftitem("mcl_core:iron_ingot", {
	description = S("Iron Ingot"),
	_doc_items_longdesc = S("Molten iron. It is used to craft armor, tools, and whatnot."),
	inventory_image = "default_steel_ingot.png",
	groups = { craftitem=1, beacon_fuel = 1 },
	_mcl_armor_trim_color = "#938e88",
	_mcl_armor_trim_desc = S("Iron Material"),
	_mcl_crafting_output = {
		single = {output = "mcl_core:iron_nugget 9"},
		square3 = {output = "mcl_core:ironblock"}
	}
})

core.register_craftitem("mcl_core:gold_ingot", {
	description = S("Gold Ingot"),
	_doc_items_longdesc = S("Molten gold. It is used to craft armor, tools, and whatnot."),
	inventory_image = "default_gold_ingot.png",
	groups = { craftitem=1, beacon_fuel = 1 },
	_mcl_armor_trim_color = "#ce9627",
	_mcl_armor_trim_desc = S("Gold Material"),
	_mcl_crafting_output = {
		single = {output = "mcl_core:gold_nugget 9"},
		square3 = {output = "mcl_core:goldblock"}
	}
})

core.register_craftitem("mcl_core:emerald", {
	description = S("Emerald"),
	_doc_items_longdesc = S("Emeralds are used in villager trades as currency."),
	inventory_image = "mcl_core_emerald.png",
	groups = { craftitem=1, beacon_fuel = 1 },
	_mcl_armor_trim_color = "#1b9958",
	_mcl_armor_trim_desc = S("Emerald Material"),
	_mcl_crafting_output = {square3 = {output = "mcl_core:emeraldblock"}}
})

core.register_craftitem("mcl_core:lapis", {
	description = S("Lapis Lazuli"),
	_doc_items_longdesc = S("Lapis Lazuli are required for enchanting items on an enchanting table."),
	inventory_image = "mcl_core_lapis.png",
	groups = { craftitem=1 },
	_mcl_armor_trim_color = "#1c306b",
	_mcl_armor_trim_desc = S("Lapis Material"),
	_mcl_crafting_output = {
		single = {output = "mcl_dyes:blue"},
		square3 = {output = "mcl_core:lapisblock"}
	}
})

core.register_craftitem("mcl_core:brick", {
	description = S("Brick"),
	_doc_items_longdesc = S("Bricks are used to craft brick blocks."),
	inventory_image = "default_clay_brick.png",
	groups = { craftitem=1 },
	_mcl_crafting_output = {square2 = {output = "mcl_core:brick_block"}}
})

core.register_craftitem("mcl_core:flint", {
	description = S("Flint"),
	_doc_items_longdesc = S("Flint is a raw material."),
	inventory_image = "default_flint.png",
	groups = { craftitem=1 },
})

core.register_craftitem("mcl_core:sugar", {
	description = S("Sugar"),
	_doc_items_longdesc = S("Sugar comes from sugar canes and is used to make sweet foods."),
	inventory_image = "mcl_core_sugar.png",
	groups = { craftitem = 1, brewitem=1 },
})

core.register_craftitem("mcl_core:bowl",{
	description = S("Bowl"),
	_doc_items_longdesc = S("Bowls are mainly used to hold tasty soups."),
	inventory_image = "mcl_core_bowl.png",
	groups = { craftitem = 1 },
	_mcl_burntime = 10
})

core.register_craftitem("mcl_core:apple", {
	description = S("Apple"),
	_doc_items_longdesc = S("Apples are food items which can be eaten."),
	wield_image = "default_apple.png",
	inventory_image = "default_apple.png",
	groups = { food = 2, eatable = 4, compostability = 65 },
	_mcl_saturation = 2.4,
})

core.register_craftitem("mcl_core:apple_gold", {
	-- TODO: Add special highlight color
	description = S("Golden Apple"),
	_doc_items_longdesc = S("Golden apples are precious food items which can be eaten."),
	wield_image = "mcl_core_apple_golden.png",
	inventory_image = "mcl_core_apple_golden.png",
	groups = { food = 2, eatable = 4, can_eat_when_full = 1 },
	_mcl_saturation = 9.6,
	_mcl_eat_effect = function (_, placer)
		mcl_potions.give_effect_by_level("absorption", placer, 1, 120)
		mcl_potions.give_effect_by_level("regeneration", placer, 2, 5)
	end,
	_placement_def = {
		["mobs_mc:villager_zombie"] = "default",
		inherit = "magic_victuals",
	},
})

core.register_craftitem("mcl_core:apple_gold_enchanted", {
	description = S("Enchanted Golden Apple"),
	_doc_items_longdesc = S("Golden apples are precious food items which can be eaten."),
	wield_image = "mcl_core_apple_golden.png" .. mcl_enchanting.overlay,
	inventory_image = "mcl_core_apple_golden.png" .. mcl_enchanting.overlay,
	groups = { food = 2, eatable = 4, can_eat_when_full = 1, rarity = 2 },
	_mcl_saturation = 9.6,
	_mcl_eat_effect = function (_, placer)
		mcl_potions.give_effect("fire_resistance", placer, 1, 300)
		mcl_potions.give_effect_by_level("resistance", placer, 1, 300)
		mcl_potions.give_effect_by_level("absorption", placer, 4, 120)
		mcl_potions.give_effect_by_level("regeneration", placer, 2, 20)
	end
})
