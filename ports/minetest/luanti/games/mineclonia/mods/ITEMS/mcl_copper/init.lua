mcl_copper = {}

local path = core.get_modpath(core.get_current_modname())

dofile(path .. "/decaychains.lua")
dofile(path .. "/nodes.lua")
dofile(path .. "/items.lua")
dofile(path .. "/crafting.lua")

mcl_copper.register_decaychain("copper",{
	preserve_group = "preserves_copper",
	unpreserve_callback = "_on_axe_place",
	undecay_callback = "_on_axe_place",
	nodes = {
		"mcl_copper:block",
		"mcl_copper:block_exposed",
		"mcl_copper:block_weathered",
		"mcl_copper:block_oxidized",
	},
})

for _, v in pairs({ "chiseled", "grate", "cut" }) do
	mcl_copper.register_decaychain(v.."_copper",{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = {
			"mcl_copper:block_"..v,
			"mcl_copper:block_exposed_"..v,
			"mcl_copper:block_weathered_"..v,
			"mcl_copper:block_oxidized_"..v,
		},
	})
end

for _, v in pairs({ "on", "off" }) do
	mcl_copper.register_decaychain("copper_bulb_"..v,{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = {
			"mcl_copper:bulb_"..v,
			"mcl_copper:bulb_exposed_"..v,
			"mcl_copper:bulb_weathered_"..v,
			"mcl_copper:bulb_oxidized_"..v,
		},
	})

	mcl_copper.register_decaychain("copper_bulb_"..v .. "_powered",{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = {
			"mcl_copper:bulb_"..v.."_powered",
			"mcl_copper:bulb_exposed_"..v.."_powered",
			"mcl_copper:bulb_weathered_"..v.."_powered",
			"mcl_copper:bulb_oxidized_"..v.."_powered",
		},
	})
end

for _, v in pairs({"", "_t_1", "_t_2", "_b_1", "_b_2"}) do
	mcl_copper.register_decaychain("copper_door"..v,{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = {
			"mcl_copper:door"..v,
			"mcl_copper:door_exposed"..v,
			"mcl_copper:door_weathered"..v,
			"mcl_copper:door_oxidized"..v,
		},
	})
end

for _, v in pairs({"", "_open"}) do
	mcl_copper.register_decaychain("copper_trapdoor"..v,{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = {
			"mcl_copper:trapdoor"..v,
			"mcl_copper:trapdoor_exposed"..v,
			"mcl_copper:trapdoor_weathered"..v,
			"mcl_copper:trapdoor_oxidized"..v,
		},
	})
end

mcl_copper.register_decaychain("lantern_ceiling",{
	preserve_group = "preserves_copper",
	unpreserve_callback = "_on_axe_place",
	undecay_callback = "_on_axe_place",
	nodes = {
		"mcl_lanterns:copper_lantern_ceiling",
		"mcl_lanterns:copper_lantern_exposed_ceiling",
		"mcl_lanterns:copper_lantern_weathered_ceiling",
		"mcl_lanterns:copper_lantern_weathered_ceiling",
	},
})

mcl_copper.register_decaychain("lantern_floor",{
	preserve_group = "preserves_copper",
	unpreserve_callback = "_on_axe_place",
	undecay_callback = "_on_axe_place",
	nodes = {
		"mcl_lanterns:copper_lantern_floor",
		"mcl_lanterns:copper_lantern_exposed_floor",
		"mcl_lanterns:copper_lantern_weathered_floor",
		"mcl_lanterns:copper_lantern_oxidized_floor",
	},
})

mcl_copper.register_decaychain("bar",{
	preserve_group = "preserves_copper",
	unpreserve_callback = "_on_axe_place",
	undecay_callback = "_on_axe_place",
	nodes = {
		"mcl_panes:copper_bar",
		"mcl_panes:copper_bar_exposed",
		"mcl_panes:copper_bar_weathered",
		"mcl_panes:copper_bar_oxidized",
	},
})

mcl_copper.register_decaychain("bar_flat",{
	preserve_group = "preserves_copper",
	unpreserve_callback = "_on_axe_place",
	undecay_callback = "_on_axe_place",
	nodes = {
		"mcl_panes:copper_bar_flat",
		"mcl_panes:copper_bar_exposed_flat",
		"mcl_panes:copper_bar_weathered_flat",
		"mcl_panes:copper_bar_oxidized_flat",
	},
})

mcl_copper.register_decaychain("chain",{
	preserve_group = "preserves_copper",
	unpreserve_callback = "_on_axe_place",
	undecay_callback = "_on_axe_place",
	nodes = {
		"mcl_lanterns:copper_chain",
		"mcl_lanterns:copper_chain_exposed",
		"mcl_lanterns:copper_chain_weathered",
		"mcl_lanterns:copper_chain_oxidized",
	},
})

-- "mcl_copper:block_exposed_cut"

for _,v in pairs({"stair","slab"}) do
	mcl_copper.register_decaychain("cut_copper_"..v,{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = {
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
		nodes = {
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
		nodes = {
			"mcl_stairs:slab_copper_cut_"..v,
			"mcl_stairs:slab_copper_exposed_cut_"..v,
			"mcl_stairs:slab_copper_weathered_cut_"..v,
			"mcl_stairs:slab_copper_oxidized_cut_"..v,
		},
	})
end
