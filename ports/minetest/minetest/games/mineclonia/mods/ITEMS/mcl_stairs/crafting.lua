minetest.register_craft({
	output = "mcl_core:sandstonecarved",
	recipe = {
		{"mcl_stairs:slab_sandstone"},
		{"mcl_stairs:slab_sandstone"}
	}
})

minetest.register_craft({
	output = "mcl_core:redsandstonecarved",
	recipe = {
		{"mcl_stairs:slab_redsandstone"},
		{"mcl_stairs:slab_redsandstone"}
	}
})

minetest.register_craft({
	output = "mcl_core:stonebrickcarved",
	recipe = {
		{"mcl_stairs:slab_stonebrick"},
		{"mcl_stairs:slab_stonebrick"}
	}
})

minetest.register_craft({
	output = "mcl_end:purpur_pillar",
	recipe = {
		{"mcl_stairs:slab_purpur_block"},
		{"mcl_stairs:slab_purpur_block"}
	}
})

minetest.register_craft({
	output = "mcl_nether:quartz_chiseled 2",
	recipe = {
		{"mcl_stairs:slab_quartzblock"},
		{"mcl_stairs:slab_quartzblock"},
	}
})

-- Fuel
minetest.register_craft({
	type = "fuel",
	recipe = "group:wood_stairs",
	burntime = 15,
})
minetest.register_craft({
	type = "fuel",
	recipe = "group:wood_slab",
	-- Original burn time: 7.5 (PC edition)
	burntime = 8,
})

