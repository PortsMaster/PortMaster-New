--- Originally created by michieal.
-- These are just the recipes specific to bamboo now. The usual wood stuff is registered by mcl_trees
core.register_craft({
	output = "mcl_trees:tree_bamboo",
	recipe = {
		{"group:bamboo_tree","group:bamboo_tree","group:bamboo_tree"},
		{"group:bamboo_tree","group:bamboo_tree","group:bamboo_tree"},
		{"group:bamboo_tree","group:bamboo_tree","group:bamboo_tree"},
	}
})

core.register_craft({
	output = "mcl_bamboo:scaffolding 6",
	recipe = {{"group:bamboo_tree", "mcl_mobitems:string", "group:bamboo_tree"},
			 {"group:bamboo_tree", "", "group:bamboo_tree"},
			 {"group:bamboo_tree", "", "group:bamboo_tree"}}
})

core.register_craft({
	output = "mcl_core:stick",
	recipe = {
		{"mcl_bamboo:bamboo"},
		{"mcl_bamboo:bamboo"},
	}
})

core.register_craft({
	output = "mcl_bamboo:bamboo_mosaic",
	recipe = {
		{"mcl_stairs:slab_bamboo"},
		{"mcl_stairs:slab_bamboo"}
	}
})
