mcl_copper = {}
local path = minetest.get_modpath("mcl_copper")

dofile(path .. "/decaychains.lua")
dofile(path .. "/nodes.lua")
dofile(path .. "/items.lua")
dofile(path .. "/crafting.lua")

mcl_copper.register_decaychain("copper",{
	preserve_group = "preserves_copper",
	unpreserve_callback = "_on_axe_place",
	undecay_callback = "_on_axe_place",
	nodes = { --order is significant
		"mcl_copper:block",
		"mcl_copper:block_exposed",
		"mcl_copper:block_weathered",
		"mcl_copper:block_oxidized",
	},
})

mcl_copper.register_decaychain("cut_copper",{
	preserve_group = "preserves_copper",
	unpreserve_callback = "_on_axe_place",
	undecay_callback = "_on_axe_place",
	nodes = { --order is significant
		"mcl_copper:block_cut",
		"mcl_copper:block_exposed_cut",
		"mcl_copper:block_weathered_cut",
		"mcl_copper:block_oxidized_cut",
	},
})

-- "mcl_copper:block_exposed_cut"

for _,v in pairs({"stair","slab"}) do
	mcl_copper.register_decaychain("cut_copper_"..v,{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = { --order is significant
			"mcl_stairs:"..v.."_copper_cut",
			"mcl_stairs:"..v.."_copper_exposed_cut",
			"mcl_stairs:"..v.."_copper_weathered_cut",
			"mcl_stairs:"..v.."_copper_oxidized_cut",
		},
	})
end

for _,v in pairs({"inner","outer"}) do
	mcl_copper.register_decaychain("cut_copper_stair_"..v,{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = { --order is significant
			"mcl_stairs:stair_copper_cut_"..v,
			"mcl_stairs:stair_copper_exposed_cut_"..v,
			"mcl_stairs:stair_copper_weathered_cut_"..v,
			"mcl_stairs:stair_copper_oxidized_cut_"..v,
		},
	})
end
for _,v in pairs({"top","double"}) do
	mcl_copper.register_decaychain("cut_copper_slab_"..v,{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = { --order is significant
			"mcl_stairs:slab_copper_cut_"..v,
			"mcl_stairs:slab_copper_exposed_cut_"..v,
			"mcl_stairs:slab_copper_weathered_cut_"..v,
			"mcl_stairs:slab_copper_oxidized_cut_"..v,
		},
	})
end
