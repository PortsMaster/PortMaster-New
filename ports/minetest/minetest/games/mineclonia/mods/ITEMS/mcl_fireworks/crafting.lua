minetest.register_craft({
	type = "shapeless",
	output = "mcl_fireworks:rocket_1 3",
	recipe = {"mcl_core:paper", "mcl_mobitems:gunpowder"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_fireworks:rocket_2 3",
	recipe = {"mcl_core:paper", "mcl_mobitems:gunpowder", "mcl_mobitems:gunpowder"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_fireworks:rocket_3 3",
	recipe = {"mcl_core:paper", "mcl_mobitems:gunpowder", "mcl_mobitems:gunpowder", "mcl_mobitems:gunpowder"},
})