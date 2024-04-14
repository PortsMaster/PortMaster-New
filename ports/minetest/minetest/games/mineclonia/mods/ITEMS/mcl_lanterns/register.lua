local S = minetest.get_translator("mcl_lanterns")

mcl_lanterns.register_lantern("lantern", {
	description = S("Lantern"),
	longdesc = S("Lanterns are light sources which can be placed on the top or the bottom of most blocks."),
	texture = "mcl_lanterns_lantern.png",
	texture_inv = "mcl_lanterns_lantern_inv.png",
	light_level = 14,
})

mcl_lanterns.register_lantern("soul_lantern", {
	description = S("Soul Lantern"),
	longdesc = S("Lanterns are light sources which can be placed on the top or the bottom of most blocks."),
	texture = "mcl_lanterns_soul_lantern.png",
	texture_inv = "mcl_lanterns_soul_lantern_inv.png",
	light_level = 10,
})

minetest.register_craft({
	output = "mcl_lanterns:lantern_floor",
	recipe = {
		{"mcl_core:iron_nugget", "mcl_core:iron_nugget", "mcl_core:iron_nugget"},
		{"mcl_core:iron_nugget", "mcl_torches:torch"   , "mcl_core:iron_nugget"},
		{"mcl_core:iron_nugget", "mcl_core:iron_nugget", "mcl_core:iron_nugget"},
	},
})

minetest.register_craft({
	output = "mcl_lanterns:soul_lantern_floor",
	recipe = {
		{"mcl_core:iron_nugget", "mcl_core:iron_nugget"      , "mcl_core:iron_nugget"},
		{"mcl_core:iron_nugget", "mcl_blackstone:soul_torch" , "mcl_core:iron_nugget"},
		{"mcl_core:iron_nugget", "mcl_core:iron_nugget"      , "mcl_core:iron_nugget"},
	},
})
