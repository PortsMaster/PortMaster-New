-- mods/default/crafting.lua

--
-- Crafting definition
--

core.register_craft({
	type = "shapeless",
	output = "mcl_core:mossycobble",
	recipe = { "mcl_core:cobble", "mcl_core:vine" },
})

core.register_craft({
	type = "shapeless",
	output = "mcl_core:stonebrickmossy",
	recipe = { "mcl_core:stonebrick", "mcl_core:vine" },
})

core.register_craft({
	output = "mcl_core:coarse_dirt 4",
	recipe = {
		{"mcl_core:dirt", "mcl_core:gravel"},
		{"mcl_core:gravel", "mcl_core:dirt"},
	}
})
core.register_craft({
	output = "mcl_core:coarse_dirt 4",
	recipe = {
		{"mcl_core:gravel", "mcl_core:dirt"},
		{"mcl_core:dirt", "mcl_core:gravel"},
	}
})

core.register_craft({
	type = "shapeless",
	output = "mcl_core:granite",
	recipe = {"mcl_core:diorite", "mcl_nether:quartz"},
})

core.register_craft({
	type = "shapeless",
	output = "mcl_core:andesite 2",
	recipe = {"mcl_core:diorite", "mcl_core:cobble"},
})

core.register_craft({
	output = "mcl_core:diorite 2",
	recipe = {
		{"mcl_core:cobble", "mcl_nether:quartz"},
		{"mcl_nether:quartz", "mcl_core:cobble"},
	}
})
core.register_craft({
	output = "mcl_core:diorite 2",
	recipe = {
		{"mcl_nether:quartz", "mcl_core:cobble"},
		{"mcl_core:cobble", "mcl_nether:quartz"},
	}
})

core.register_craft({
	output = "mcl_core:stick 4",
	recipe = {
		{"group:wood"},
		{"group:wood"},
	}
})

core.register_craft({
	output = "mcl_core:ladder 3",
	recipe = {
		{"mcl_core:stick", "", "mcl_core:stick"},
		{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"},
		{"mcl_core:stick", "", "mcl_core:stick"},
	}
})

core.register_craft({
	output = "mcl_core:apple_gold",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mcl_core:apple", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot", "mcl_core:gold_ingot"},
	}
})

core.register_craft({
	output = "mcl_core:bowl 4",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""},
	}
})

core.register_craft({
	output = "mcl_core:snowblock",
	recipe = {
		{"mcl_throwing:snowball", "mcl_throwing:snowball"},
		{"mcl_throwing:snowball", "mcl_throwing:snowball"},
	}
})

core.register_craft({
	output = "mcl_core:snow 6",
	recipe = {
		{"mcl_core:snowblock", "mcl_core:snowblock", "mcl_core:snowblock"},
	}
})
--
-- Crafting (tool repair)
--
core.register_craft({
	type = "toolrepair",
	additional_wear = -mcl_core.repair,
})
