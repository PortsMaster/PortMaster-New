--- Originally created by michieal.
-- These are just the recipes specific to bamboo now. The usual wood stuff is registered by mcl_trees


minetest.register_craft({
	output = "mcl_core:stick",
	recipe = {
		{"mcl_bamboo:bamboo"},
		{"mcl_bamboo:bamboo"},
	}
})

minetest.register_craft({
	output = "mcl_trees:tree_bamboo",
	recipe = {
		{"group:bamboo_tree","group:bamboo_tree","group:bamboo_tree"},
		{"group:bamboo_tree","group:bamboo_tree","group:bamboo_tree"},
		{"group:bamboo_tree","group:bamboo_tree","group:bamboo_tree"},
	}
})

minetest.register_craft({
	output = "mcl_trees:wood_bamboo",
	recipe = {
		{"group:bamboo_tree","group:bamboo_tree"},
		{"group:bamboo_tree","group:bamboo_tree"},
	}
})

minetest.register_craft({
	output = "mcl_bamboo:scaffolding 6",
	recipe = {{"group:bamboo_tree", "mcl_mobitems:string", "group:bamboo_tree"},
			 {"group:bamboo_tree", "", "group:bamboo_tree"},
			 {"group:bamboo_tree", "", "group:bamboo_tree"}}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_bamboo:scaffolding",
	burntime = 20
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_bamboo:bamboo",
	burntime = 2.5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_bamboo:bamboo_mosaic",
	burntime = 7.5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_stairs:slab_bamboo_mosaic",
	burntime = 7.5,
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_stairs:stair_bamboo_mosaic",
	burntime = 15,
})
