minetest.register_craft({
	output = "mcl_tools:pick_wood",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"", "mcl_core:stick", ""},
		{"", "mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:pick_stone",
	recipe = {
		{"group:cobble", "group:cobble", "group:cobble"},
		{"", "mcl_core:stick", ""},
		{"", "mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:pick_iron",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"", "mcl_core:stick", ""},
		{"", "mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:pick_gold",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"", "mcl_core:stick", ""},
		{"", "mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:pick_diamond",
	recipe = {
		{"mcl_core:diamond", "mcl_core:diamond", "mcl_core:diamond"},
		{"", "mcl_core:stick", ""},
		{"", "mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:shovel_wood",
	recipe = {
		{"group:wood"},
		{"mcl_core:stick"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:shovel_stone",
	recipe = {
		{"group:cobble"},
		{"mcl_core:stick"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:shovel_iron",
	recipe = {
		{"mcl_core:iron_ingot"},
		{"mcl_core:stick"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:shovel_gold",
	recipe = {
		{"mcl_core:gold_ingot"},
		{"mcl_core:stick"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:shovel_diamond",
	recipe = {
		{"mcl_core:diamond"},
		{"mcl_core:stick"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:axe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "mcl_core:stick"},
		{"", "mcl_core:stick"},
	}
})
minetest.register_craft({
	output = "mcl_tools:axe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"mcl_core:stick", "group:wood"},
		{"mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:axe_stone",
	recipe = {
		{"group:cobble", "group:cobble"},
		{"group:cobble", "mcl_core:stick"},
		{"", "mcl_core:stick"},
	}
})
minetest.register_craft({
	output = "mcl_tools:axe_stone",
	recipe = {
		{"group:cobble", "group:cobble"},
		{"mcl_core:stick", "group:cobble"},
		{"mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:axe_iron",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:stick"},
		{"", "mcl_core:stick"},
	}
})
minetest.register_craft({
	output = "mcl_tools:axe_iron",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:stick", "mcl_core:iron_ingot"},
		{"mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:axe_gold",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mcl_core:stick"},
		{"", "mcl_core:stick"},
	}
})
minetest.register_craft({
	output = "mcl_tools:axe_gold",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"mcl_core:stick", "mcl_core:gold_ingot"},
		{"mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:axe_diamond",
	recipe = {
		{"mcl_core:diamond", "mcl_core:diamond"},
		{"mcl_core:diamond", "mcl_core:stick"},
		{"", "mcl_core:stick"},
	}
})
minetest.register_craft({
	output = "mcl_tools:axe_diamond",
	recipe = {
		{"mcl_core:diamond", "mcl_core:diamond"},
		{"mcl_core:stick", "mcl_core:diamond"},
		{"mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:sword_wood",
	recipe = {
		{"group:wood"},
		{"group:wood"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:sword_stone",
	recipe = {
		{"group:cobble"},
		{"group:cobble"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:sword_iron",
	recipe = {
		{"mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:sword_gold",
	recipe = {
		{"mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:sword_diamond",
	recipe = {
		{"mcl_core:diamond"},
		{"mcl_core:diamond"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:shears",
	recipe = {
		{ "mcl_core:iron_ingot", "" },
		{ "", "mcl_core:iron_ingot", },
	}
})
minetest.register_craft({
	output = "mcl_tools:shears",
	recipe = {
		{ "", "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot", "" },
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:pick_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:shovel_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:sword_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:axe_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:gold_nugget",
	recipe = "mcl_tools:sword_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:gold_nugget",
	recipe = "mcl_tools:axe_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:gold_nugget",
	recipe = "mcl_tools:shovel_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:gold_nugget",
	recipe = "mcl_tools:pick_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:iron_nugget",
	recipe = "mcl_tools:sword_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:iron_nugget",
	recipe = "mcl_tools:axe_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:iron_nugget",
	recipe = "mcl_tools:shovel_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:iron_nugget",
	recipe = "mcl_tools:pick_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:pick_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:shovel_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:sword_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:axe_wood",
	burntime = 10,
})
