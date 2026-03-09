for _,v in pairs({"","_exposed","_weathered"}) do
	core.register_alias("mcl_copper:waxed_block"..v,"mcl_copper:block"..v.."_preserved")
	core.register_alias("mcl_copper:waxed_block"..v.."_cut","mcl_copper:block"..v.."_cut_preserved")
	core.register_alias("mcl_stairs:stair_waxed_copper"..v.."_cut","mcl_stairs:stair_copper"..v.."_cut_preserved")
	core.register_alias("mcl_stairs:stair_waxed_copper"..v.."_cut_inner","mcl_stairs:stair_copper"..v.."_cut_inner_preserved")
	core.register_alias("mcl_stairs:stair_waxed_copper"..v.."_cut_outer","mcl_stairs:stair_copper"..v.."_cut_outer_preserved")
	core.register_alias("mcl_stairs:slab_waxed_copper"..v.."_cut","mcl_stairs:slab_copper"..v.."_cut_preserved")
	core.register_alias("mcl_stairs:slab_waxed_copper"..v.."_cut_top","mcl_stairs:slab_copper"..v.."_cut_top_preserved")
	core.register_alias("mcl_stairs:slab_waxed_copper"..v.."_cut_double","mcl_stairs:slab_copper"..v.."_cut_double_preserved")
end

--waxed oxidized makes no sense - it doesn't exist anymore
core.register_alias("mcl_copper:waxed_block_oxidized","mcl_copper:block_oxidized")
core.register_alias("mcl_copper:waxed_block_oxidized_cut","mcl_copper:block_oxidized_cut")
core.register_alias("mcl_stairs:stair_waxed_copper_oxidized_cut","mcl_stairs:stair_copper_oxidized_cut")
core.register_alias("mcl_stairs:stair_waxed_copper_oxidized_cut_inner","mcl_stairs:stair_copper_oxidized_cut_inner")
core.register_alias("mcl_stairs:stair_waxed_copper_oxidized_cut_outer","mcl_stairs:stair_copper_oxidized_cut_outer")
core.register_alias("mcl_stairs:slab_waxed_copper_oxidized_cut","mcl_stairs:slab_copper_oxidized_cut")
core.register_alias("mcl_stairs:slab_waxed_copper_oxidized_cut_top","mcl_stairs:slab_copper_oxidized_cut_top")
core.register_alias("mcl_stairs:slab_waxed_copper_oxidized_cut_double","mcl_stairs:slab_copper_oxidized_cut_double")
