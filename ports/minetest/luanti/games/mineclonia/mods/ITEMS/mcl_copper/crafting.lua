local block_type = { "", "_cut", "_chiseled", "_grate" }
local block_exposure_level = { "", "_exposed", "_weathered", "_oxidized" }
local waxed = { "", "_preserved" }

for _, x in pairs(block_exposure_level) do

	for _, w in pairs(waxed) do
		core.register_craft({
			output = "mcl_copper:block"..x.."_cut"..w.." 4",
			recipe = {
				{ "mcl_copper:block"..x..w, "mcl_copper:block"..x..w },
				{ "mcl_copper:block"..x..w, "mcl_copper:block"..x..w }
			}
		})

		core.register_craft({
			output = "mcl_copper:block"..x.."_grate"..w.." 4",
			recipe = {
				{ "", "mcl_copper:block"..x..w, "" },
				{ "mcl_copper:block"..x..w, "", "mcl_copper:block"..x..w },
				{ "", "mcl_copper:block"..x..w, "" }
			}
		})

		core.register_craft({
			output = "mcl_copper:block"..x.."_chiseled"..w.." 4",
			recipe = {
				{ "mcl_stairs:slab_copper"..x.."_cut"..w },
				{ "mcl_stairs:slab_copper"..x.."_cut"..w }
			}
		})

		core.register_craft({
			output = "mcl_copper:bulb"..x.."_off"..w.." 4",
			recipe = {
				{ "", "mcl_copper:block"..x..w, "" },
				{ "mcl_copper:block"..x..w, "mcl_mobitems:blaze_rod", "mcl_copper:block"..x..w },
				{ "", "mesecons:redstone", "" }
			}
		})
	end

	for _, t in pairs(block_type) do
		core.register_craft({
			output = "mcl_copper:block"..x..t.."_preserved",
			recipe = {
				{ "mcl_copper:block"..x..t, "mcl_honey:honeycomb" }
			}
		})
	end

	core.register_craft({
		output = "mcl_stairs:slab_copper"..x.."_cut_preserved 6",
		recipe = {
			{ "mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved" }
		}
	})

	core.register_craft({
		output = "mcl_stairs:stair_copper"..x.."_cut_preserved 4",
		recipe = {
			{ "", "", "mcl_copper:block"..x.."_cut_preserved" },
			{"", "mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved"},
			{"mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved" }
		}
	})

	core.register_craft({
		output = "mcl_stairs:stair_copper"..x.."_cut_preserved 4",
		recipe = {
			{ "mcl_copper:block"..x.."_cut_preserved", "", "" },
			{ "mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved", "" },
			{ "mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved" }
		}
	})

	core.register_craft({
		output = "mcl_copper:door"..x.."_preserved",
		recipe = {
			{ "mcl_copper:door"..x, "mcl_honey:honeycomb" }
		}
	})

	core.register_craft({
		output = "mcl_copper:trapdoor"..x.."_preserved",
		recipe = {
			{ "mcl_copper:trapdoor"..x, "mcl_honey:honeycomb" }
		}
	})

	core.register_craft({
		output = "mcl_copper:bulb"..x.."_off_preserved",
		recipe = {
			{ "mcl_copper:bulb"..x.."_off", "mcl_honey:honeycomb" }
		}
	})

	core.register_craft({
		output = "mcl_stairs:slab_copper"..x.."_cut_preserved",
		recipe = {
			{ "mcl_stairs:slab_copper"..x.."_cut", "mcl_honey:honeycomb" }
		}
	})

	core.register_craft({
		output = "mcl_stairs:stair_copper"..x.."_cut_preserved",
		recipe = {
			{ "mcl_stairs:stair_copper"..x.."_cut", "mcl_honey:honeycomb" }
		}
	})

	core.register_craft({
		output = "mcl_lanterns:copper_lantern"..x.."_floor_preserved",
		recipe = {
			{ "mcl_lanterns:copper_lantern"..x.."_floor", "mcl_honey:honeycomb" }
		}
	})

	core.register_craft({
		output = "mcl_lanterns:copper_chain"..x.."_preserved",
		recipe = {
			{ "mcl_lanterns:copper_chain"..x, "mcl_honey:honeycomb" }
		}
	})

	core.register_craft({
		output = "mcl_panes:copper_bar"..x.."_flat_preserved",
		recipe = {
			{ "mcl_panes:copper_bar"..x.."_flat", "mcl_honey:honeycomb" }
		}
	})
end

core.register_craft({
	output = "mcl_copper:door 3",
	recipe = {
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" }
	}
})

core.register_craft({
	output = "mcl_copper:trapdoor",
	recipe = {
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" }
	}
})

core.register_craft({
	output = "mcl_copper:copper_torch 4",
	recipe = {
		{ "mcl_copper:copper_nugget" },
		{ "group:coal"        },
		{ "mcl_core:stick"    },
	}
})

core.register_craft({
	output = "mcl_lanterns:copper_lantern_floor",
	recipe = {
		{ "mcl_copper:copper_nugget", "mcl_copper:copper_nugget", "mcl_copper:copper_nugget" },
		{ "mcl_copper:copper_nugget", "mcl_copper:copper_torch", "mcl_copper:copper_nugget" },
		{ "mcl_copper:copper_nugget", "mcl_copper:copper_nugget", "mcl_copper:copper_nugget" },
	},
})

core.register_craft({
	output = "mcl_lanterns:copper_chain",
	recipe = {
		{ "mcl_copper:copper_nugget" },
		{ "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_nugget" },
	}
})

core.register_craft({
	output = "mcl_panes:copper_bar_flat 16",
	recipe = {
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
	}
})
