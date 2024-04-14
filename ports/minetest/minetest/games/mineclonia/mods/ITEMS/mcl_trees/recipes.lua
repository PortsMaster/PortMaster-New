
minetest.register_craft({
	output = "mcl_trees:stick 4",
	recipe = {
		{"group:wood"},
		{"group:wood"},
	}
})

minetest.register_craft({
	output = "mcl_trees:paper 3",
	recipe = {
		{"mcl_trees:reeds", "mcl_trees:reeds", "mcl_trees:reeds"},
	}
})

minetest.register_craft({
	output = "mcl_trees:ladder 3",
	recipe = {
		{"mcl_trees:stick", "", "mcl_trees:stick"},
		{"mcl_trees:stick", "mcl_trees:stick", "mcl_trees:stick"},
		{"mcl_trees:stick", "", "mcl_trees:stick"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:tree",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:bark",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_trees:ladder",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:wood",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:sapling",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_trees:bowl",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_trees:stick",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:bark_stairs",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:bark_slab",
	burntime = 8,
})

minetest.register_craft({
	output = "mcl_trees:bowl 4",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""},
	}
})

minetest.register_craft({
	output = "mcl_trees:apple_gold",
	recipe = {
		{"mcl_stone:ingot_gold", "mcl_stone:ingot_gold", "mcl_stone:ingot_gold"},
		{"mcl_stone:ingot_gold", "mcl_trees:apple", "mcl_stone:ingot_gold"},
		{"mcl_stone:ingot_gold", "mcl_stone:ingot_gold", "mcl_stone:ingot_gold"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_trees:charcoal",
	burntime = 80,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_trees:charcoal",
	recipe = "group:tree",
	cooktime = 10,
})
