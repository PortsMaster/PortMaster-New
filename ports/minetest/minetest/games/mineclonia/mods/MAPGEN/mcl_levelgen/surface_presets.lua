------------------------------------------------------------------------
-- Surface system presets.
------------------------------------------------------------------------

local function y_above_test (value, surface_depth_multiplier)
	return mcl_levelgen.y_above_cond (value, surface_depth_multiplier, false)
end

local function y_surface_test (value, surface_depth_multiplier)
	return mcl_levelgen.y_above_cond (value, surface_depth_multiplier, true)
end

local function water_above_test (offset, surface_depth_multiplier)
	return mcl_levelgen.water_cond (offset, surface_depth_multiplier, false)
end

local function water_surface_test (offset, surface_depth_multiplier)
	return mcl_levelgen.water_cond (offset, surface_depth_multiplier, true)
end

local function biome (name1, name2, name3)
	return mcl_levelgen.biome_cond (name1, name2, name3)
end

local function sequence (...)
	return mcl_levelgen.sequence_rule ({...})
end

local function if_true (cond, value)
	return mcl_levelgen.condition_rule (cond, value)
end

local function not_cond (cond)
	return mcl_levelgen.not_cond (cond)
end

local function if_false (cond, value)
	local cond1 = mcl_levelgen.not_cond (cond)
	return mcl_levelgen.condition_rule (cond1, value)
end

local function block (cid, param2)
	return mcl_levelgen.block_rule (cid, param2)
end

local function vertical_gradient (preset, name, min, max)
	return mcl_levelgen.make_vertical_gradient (preset, name, min, max)
end

-- https://maven.fabricmc.net/docs/yarn-1.20.4+build.1/net/minecraft/world/gen/surfacebuilder/MaterialRules.html
-- These names are publicly documented even though their provenance
-- appears to be Minecraft.

local ON_FLOOR = mcl_levelgen.stone_depth_check_cond (0, false, 0, "floor")
local UNDER_FLOOR = mcl_levelgen.stone_depth_check_cond (0, true, 0, "floor")
local DEEP_UNDER_FLOOR = mcl_levelgen.stone_depth_check_cond (0, true, 6, "floor")
local VERY_DEEP_UNDER_FLOOR = mcl_levelgen.stone_depth_check_cond (0, true, 30, "floor")
local ON_CEILING = mcl_levelgen.stone_depth_check_cond (0, false, 0, "ceiling")
local UNDER_CEILING = mcl_levelgen.stone_depth_check_cond (0, true, 0, "ceiling")

function mcl_levelgen.overworld_surface_rule (preset, limit_surface,
					      need_bedrock_roof,
					      need_bedrock_floor)
	local function getcid (name)
		if core then
			local id = core.get_content_id (name)
			return id
		else
			return name
		end
	end
	local cid_grass_block
		= getcid ("mcl_core:dirt_with_grass")
	local cid_dirt = getcid ("mcl_core:dirt")
	local cid_sandstone = getcid ("mcl_core:sandstone")
	local cid_sand = getcid ("mcl_core:sand")
	local cid_stone = getcid ("mcl_core:stone")
	local cid_gravel = getcid ("mcl_core:gravel")
	local cid_calcite = getcid ("mcl_amethyst:calcite")
	local cid_powder_snow = getcid ("mcl_powder_snow:powder_snow")
	local cid_packed_ice = getcid ("mcl_core:packed_ice")
	local cid_ice = getcid ("mcl_core:ice")
	local cid_snow_block = getcid ("mcl_core:snowblock")
	local cid_mud = getcid ("mcl_mud:mud")
	local cid_coarse_dirt = getcid ("mcl_core:coarse_dirt")
	local cid_mycelium = getcid ("mcl_core:mycelium")
	local cid_water_source = getcid ("mcl_core:water_source")
	local cid_white_terracotta
		= getcid ("mcl_colorblocks:hardened_clay_white")
	local cid_orange_terracotta
		= getcid ("mcl_colorblocks:hardened_clay_orange")
	local cid_terracotta
		= getcid ("mcl_colorblocks:hardened_clay")
	-- local cid_yellow_terracotta
	-- 	= getcid ("mcl_colorblocks:hardened_clay_yellow")
	-- local cid_brown_terracotta
	-- 	= getcid ("mcl_colorblocks:hardened_clay_brown")
	-- local cid_red_terracotta
	-- 	= getcid ("mcl_colorblocks:hardened_clay_red")
	-- local cid_light_gray_terracotta
	-- 	= getcid ("mcl_colorblocks:hardened_clay_silver")
	local cid_red_sand = getcid ("mcl_core:redsand")
	local cid_red_sandstone = getcid ("mcl_core:redsandstone")
	local cid_air = getcid ("air")
	local cid_bedrock = getcid ("mcl_core:bedrock")
	local cid_deepslate = getcid ("mcl_deepslate:deepslate")
	local cid_podzol = getcid ("mcl_core:podzol")

	local grass_block = block (cid_grass_block, "grass_palette_index")
	local dirt = block (cid_dirt, 0)
	local sandstone = block (cid_sandstone, 0)
	local sand = block (cid_sand, 0)
	local stone = block (cid_stone, 0)
	local gravel = block (cid_gravel, 0)
	local calcite = block (cid_calcite, 0)
	local powder_snow = block (cid_powder_snow, 0)
	local packed_ice = block (cid_packed_ice, 0)
	local ice = block (cid_ice, 0)
	local snow_block = block (cid_snow_block, 0)
	local mud = block (cid_mud, 0)
	local coarse_dirt = block (cid_coarse_dirt, 0)
	local mycelium = block (cid_mycelium, 0)
	local water = block (cid_water_source, 0)
	local white_terracotta = block (cid_white_terracotta, 0)
	local orange_terracotta = block (cid_orange_terracotta, 0)
	local terracotta = block (cid_terracotta, 0)
	-- local yellow_terracotta = block (cid_yellow_terracotta, 0)
	-- local brown_terracotta = block (cid_brown_terracotta, 0)
	-- local red_terracotta = block (cid_red_terracotta, 0)
	-- local light_gray_terracotta = block (cid_light_gray_terracotta, 0)
	local red_sand = block (cid_red_sand, 0)
	local red_sandstone = block (cid_red_sandstone, 0)
	local air = block (cid_air, 0)
	local bedrock = block (cid_bedrock, 0)
	local deepslate = block (cid_deepslate, 0)
	local podzol = block (cid_podzol, 0)

	local anchor_coarse_dirt = y_above_test (97, 2)
	local anchor_orange_terracotta = y_above_test (256, 0)
	local anchor_terracotta_begin = y_surface_test (63, -1)
	local anchor_bandlands_begin = y_surface_test (74, 1)
	local anchor_mangrove_swamp_water_begin = y_above_test (60, 0)
	local anchor_swamp_water_begin = y_above_test (62, 0)
	local anchor_63_abs = y_above_test (63, 0)
	local water_offset = water_above_test (-1, 0)
	local water_absence = water_above_test (0, 0)
	local near_surface = water_surface_test (-6, -1)
	local hole = mcl_levelgen.hole_cond ()
	local is_frozen_ocean = biome ("FrozenOcean", "DeepFrozenOcean")
	local steep = mcl_levelgen.steep_cond ()
	local grass_surface = sequence (if_true (water_absence, grass_block), dirt)
	local sand_surface = sequence (if_true (ON_CEILING, sandstone), sand)
	local stone_surface = sequence (if_true (ON_CEILING, stone), gravel)
	local ocean_or_beach = biome ("WarmOcean", "Beach", "SnowyBeach")
	local desert = biome ("Desert")
	local bandlands = mcl_levelgen.bandlands_rule ()

	local function noise (name, min, max)
		return mcl_levelgen.noise_threshold_cond (preset.noises[name],
							  min, max or math.huge)
	end
	local function surface_threshold (value)
		return noise ("surface", value / 8.25, math.huge)
	end
	local special_noises
		= sequence (if_true (biome ("StonyPeaks"),
				     sequence (if_true (noise ("calcite",
							       -0.0125,
							       0.0125),
							calcite),
					       stone)),
			    if_true (biome ("StonyShore"),
				     sequence (if_true (noise ("gravel",
							       -0.05,
							       0.05),
							stone_surface),
					       stone)),
			    if_true (biome ("WindsweptHills"),
				     if_true (surface_threshold (1.0),
					      stone)),
			    if_true (ocean_or_beach, sand_surface),
			    if_true (desert, sand_surface),
			    if_true (biome ("DripstoneCaves"), stone))
	local powder_snow_trap_rare
		= if_true (noise ("powder_snow", 0.45, 0.58),
			   if_true (water_absence, powder_snow))
	local powder_snow_trap_dense
		= if_true (noise ("powder_snow", 0.35, 0.6),
			   if_true (water_absence, powder_snow))
	local surface_peaks
		= sequence (if_true (biome ("FrozenPeaks"),
				     sequence (if_true (steep, packed_ice),
					       if_true (noise ("packed_ice", -0.5, 0.2),
							packed_ice),
					       if_true (noise ("ice", -0.0625, 0.025),
							ice),
					       if_true (water_absence, snow_block))),
			    if_true (biome ("SnowySlopes"),
				     sequence (if_true (steep, stone),
					       powder_snow_trap_rare,
					       if_true (water_absence,
							snow_block))),
			    if_true (biome ("JaggedPeaks"), stone),
			    special_noises,
			    if_true (biome ("WindsweptSavannah"),
				     if_true (surface_threshold (1.75),
					      stone)),
			    if_true (biome ("WindsweptGravellyHills"),
				     sequence (if_true (surface_threshold (2.0),
							stone_surface),
					       if_true (surface_threshold (1.0),
							stone),
					       if_true (surface_threshold (-1.0),
							dirt),
					       stone_surface)),
			    if_true (biome ("MangroveSwamp"), mud),
			    dirt)
	local frozen_peaks_and_floor
		= sequence (if_true (biome ("FrozenPeaks"),
				     sequence (if_true (steep, packed_ice),
					       if_true (noise ("packed_ice", 0.0, 0.2),
							packed_ice),
					       if_true (noise ("ice", 0.0, 0.025), ice),
					       if_true (water_absence, snow_block))),
			    if_true (biome ("SnowySlopes"),
				     sequence (if_true (steep, stone),
					       powder_snow_trap_dense,
					       if_true (water_absence,
							snow_block))),
			    if_true (biome ("JaggedPeaks"),
				     sequence (if_true (steep, stone),
					       if_true (water_absence,
							snow_block))),
			    if_true (biome ("Grove"),
				     sequence (powder_snow_trap_dense,
					       if_true (water_absence,
							snow_block))),
			    special_noises,
			    if_true (biome ("WindsweptSavannah"),
				     sequence (if_true (surface_threshold (1.75),
							stone),
					       if_true (surface_threshold (-0.5),
							coarse_dirt))),
			    if_true (biome ("WindsweptGravellyHills"),
				     sequence (if_true (surface_threshold (2.0),
							stone_surface),
					       if_true (surface_threshold (1.0),
							stone),
					       if_true (surface_threshold (-1.0),
							grass_surface),
					       stone_surface)),
			    if_true (biome ("OldGrowthPineTaiga",
					    "OldGrowthSpruceTaiga"),
				     sequence (if_true (surface_threshold (1.75),
							coarse_dirt),
					       if_true (surface_threshold (-0.95),
							podzol))),
			    if_true (biome ("IceSpikes"),
				     if_true (water_absence, snow_block)),
			    if_true (biome ("MangroveSwamp"), mud),
			    if_true (biome ("MushroomIslands"), mycelium),
			    grass_surface)
	local low_surface = noise ("surface", -0.909, -0.5454)
	local mid_surface = noise ("surface", -0.1818, 0.1818)
	local high_surface = noise ("surface", 0.5454, 0.909)
	local wooded_badlands_dirt
		= if_true (biome ("WoodedMesa"),
			   if_true (anchor_coarse_dirt,
				    sequence (if_true (low_surface,
						       coarse_dirt),
					      if_true (mid_surface,
						       coarse_dirt),
					      if_true (high_surface,
						       coarse_dirt),
					      grass_surface)))
	local swamp_wetland
		= if_true (biome ("Swamp"),
			   if_true (anchor_swamp_water_begin,
				    if_false (anchor_63_abs,
					      if_true (noise ("surface_swamp", 0.0),
						       water))))
	local mangrove_swamp_wetland
		= if_true (biome ("MangroveSwamp"),
			   if_true (anchor_mangrove_swamp_water_begin,
				    if_false (anchor_63_abs,
					      if_true (noise ("surface_swamp", 0.0),
						       water))))
	local mesa_bandlands
		= if_true (biome ("Mesa", "ErodedMesa", "WoodedMesa"),
			   sequence (if_true (ON_FLOOR,
					      sequence (if_true (anchor_orange_terracotta,
								 orange_terracotta),
							if_true (anchor_bandlands_begin,
								 sequence (if_true (low_surface,
										    terracotta),
									   if_true (mid_surface,
										    terracotta),
									   if_true (high_surface,
										    terracotta),
									   bandlands)),
							if_true (water_offset,
								 sequence (if_true (ON_CEILING,
										    red_sandstone),
									   red_sand)),
							if_false (hole, orange_terracotta),
							if_true (near_surface, white_terracotta),
							stone_surface)),
				     if_true (anchor_terracotta_begin,
					      sequence (if_true (anchor_63_abs,
								 if_false (anchor_bandlands_begin,
									   orange_terracotta)),
							bandlands)),
				     if_true (UNDER_FLOOR,
					      if_true (near_surface, white_terracotta))))
	local temperature = mcl_levelgen.temperature_cond ()
	local dry_floor
		= if_true (ON_FLOOR,
			   if_true (water_offset,
				    sequence (if_true (is_frozen_ocean,
						       if_true (hole,
								sequence (if_true (water_absence,
										   air),
									  if_true (temperature, ice),
									  water))),
					      frozen_peaks_and_floor)))
	local inland_floor
		= if_true (near_surface,
			   sequence (if_true (ON_FLOOR,
					      if_true (is_frozen_ocean,
						       if_true (hole, water))),
				     if_true (UNDER_FLOOR, surface_peaks),
				     if_true (ocean_or_beach,
					      if_true (DEEP_UNDER_FLOOR,
						       sandstone)),
				     if_true (desert,
					      if_true (VERY_DEEP_UNDER_FLOOR,
						       sandstone))))
	local default_surface
		= if_true (ON_FLOOR,
			   sequence (if_true (biome ("FrozenPeaks", "JaggedPeaks"),
					      stone),
				     if_true (biome ("WarmOcean", "LukewarmOcean",
						     "DeepLukewarmOcean"),
					      sand_surface),
				     stone_surface))
	local overworld_surface
		= sequence (if_true (ON_FLOOR,
				     sequence (wooded_badlands_dirt,
					       swamp_wetland,
					       mangrove_swamp_wetland)),
			    mesa_bandlands,
			    dry_floor,
			    inland_floor,
			    default_surface)

	local level_max = preset.min_y + preset.height - 1
	local level_min = preset.min_y
	local sequences = {}
	if need_bedrock_roof then
		local gradient = vertical_gradient (preset, "minecraft:bedrock_roof",
						    level_max - 5, level_max)
		table.insert (sequences, if_false (gradient, bedrock))
	end
	if need_bedrock_floor then
		local gradient = vertical_gradient (preset, "minecraft:bedrock_floor",
						    level_min, level_min + 5)
		table.insert (sequences, if_true (gradient, bedrock))
	end
	if limit_surface then
		local test = mcl_levelgen.above_preliminary_surface_cond ()
		table.insert (sequences, if_true (test, overworld_surface))
	else
		table.insert (sequences, overworld_surface)
	end
	local deepslate_gradient = vertical_gradient (preset, "minecraft:deepslate",
						      0, 8)
	table.insert (sequences, if_true (deepslate_gradient, deepslate))
	-- luacheck: push ignore 511
	if false then
		local test = mcl_levelgen.above_preliminary_surface_cond ()
		return if_true (test, dirt)
	-- luacheck: pop
	else
		return mcl_levelgen.sequence_rule (sequences)
	end
end

------------------------------------------------------------------------
-- Nether surface system presets.
------------------------------------------------------------------------

function mcl_levelgen.nether_surface_rule (preset)
	local function getcid (name)
		if core then
			local id = core.get_content_id (name)
			return id
		else
			return name
		end
	end

	local function noise (name, min, max)
		return mcl_levelgen.noise_threshold_cond (preset.noises[name],
							  min, max or math.huge)
	end

	local cid_gravel = getcid ("mcl_core:gravel")
	local cid_netherrack = getcid ("mcl_nether:netherrack")
	local cid_basalt = getcid ("mcl_blackstone:basalt")
	local cid_blackstone = getcid ("mcl_blackstone:blackstone")
	local cid_soul_sand = getcid ("mcl_nether:soul_sand")
	local cid_soul_soil = getcid ("mcl_blackstone:soul_soil")
	local cid_warped_wart_block = getcid ("mcl_crimson:warped_wart_block")
	local cid_nether_wart_block = getcid ("mcl_nether:nether_wart_block")
	local cid_warped_nylium = getcid ("mcl_crimson:warped_nylium")
	local cid_crimson_nylium = getcid ("mcl_crimson:crimson_nylium")
	local cid_bedrock = getcid ("mcl_core:bedrock")

	local gravel = block (cid_gravel, 0)
	local netherrack = block (cid_netherrack, 0)
	local basalt = block (cid_basalt, 0)
	local blackstone = block (cid_blackstone, 0)
	local soul_sand = block (cid_soul_sand, 0)
	local soul_soil = block (cid_soul_soil, 0)
	local warped_wart_block = block (cid_warped_wart_block, 0)
	local nether_wart_block = block (cid_nether_wart_block, 0)
	local warped_nylium = block (cid_warped_nylium, 0)
	local crimson_nylium = block (cid_crimson_nylium, 0)
	local bedrock = block (cid_bedrock, 0)

	local level_max = preset.min_y + preset.height - 1
	local level_min = preset.min_y
	local at_lava = y_above_test (31, 0)
	local above_lava = y_above_test (32, 0)
	local not_submerged = y_surface_test (30, 0)
	local near_lava = not_cond (y_surface_test (35, 0))
	local in_bedrock_gradient = y_above_test (level_max - 5, 0)
	local hole = mcl_levelgen.hole_cond ()
	local netherrack_cond = noise ("netherrack", 0.54)
	local nether_wart = noise ("nether_wart", 1.17)
	local nether_state_selector
		= noise ("nether_state_selector", 0.0)
	local gravel_patch_near_lava
		= if_true (noise ("patch", -0.012),
			   if_true (not_submerged,
				    if_true (near_lava, gravel)))
	local basalt_deltas
	-- Basalt within surface_depth of a ceiling surface, and
	-- either basalt or blackstone otherwise.
		= sequence (if_true (UNDER_CEILING, basalt),
			    if_true (UNDER_FLOOR,
				     sequence (gravel_patch_near_lava,
					       if_true (nether_state_selector,
							basalt),
					       blackstone)))
	local select_soul_sand_or_soil
		= sequence (if_true (nether_state_selector, soul_sand),
			    soul_soil)
	local soul_sand_valley
		= sequence (if_true (UNDER_CEILING, select_soul_sand_or_soil),
			    if_true (UNDER_FLOOR,
				     sequence (gravel_patch_near_lava,
					       select_soul_sand_or_soil)))
	local warped_nylium_or_wart_1
		= if_true (at_lava, sequence (if_true (nether_wart, warped_wart_block),
					      warped_nylium))
	local warped_nylium_or_wart
		= if_false (netherrack_cond, warped_nylium_or_wart_1)
	local crimson_nylium_or_wart_1
		= if_true (at_lava, sequence (if_true (nether_wart, nether_wart_block),
					      crimson_nylium))
	local crimson_nylium_or_wart
		= if_false (netherrack_cond, crimson_nylium_or_wart_1)
	local soul_sand_or_erosion
		= if_true (noise ("soul_sand_layer", -0.012),
			   sequence (if_false (hole,
					       if_true (not_submerged,
							if_true (near_lava,
								 soul_sand))),
				     netherrack))
	local gravel_patch_not_hole
		= if_true (at_lava,
			   if_true (near_lava,
				    if_true (noise ("gravel_layer", -0.012),
					     sequence (if_true (above_lava, gravel),
						       if_false (hole, gravel)))))

	return mcl_levelgen.sequence_rule ({
		if_true (vertical_gradient (preset, "minecraft:bedrock_floor",
					    level_min, level_min + 5),
			 bedrock),
		if_false (vertical_gradient (preset, "minecraft:bedrock_roof",
					     level_max - 5, level_max),
			  bedrock),
		if_true (in_bedrock_gradient, netherrack),
		if_true (biome ("BasaltDeltas"), basalt_deltas),
		if_true (biome ("SoulSandValley"), soul_sand_valley),
		if_true (ON_FLOOR, sequence (if_true (biome ("WarpedForest"),
						      warped_nylium_or_wart),
					     if_true (biome ("CrimsonForest"),
						      crimson_nylium_or_wart))),
		if_true (biome ("NetherWastes"),
			 sequence (if_true (UNDER_FLOOR, soul_sand_or_erosion),
				   if_true (ON_FLOOR, gravel_patch_not_hole))),
		netherrack,
	})
end

------------------------------------------------------------------------
-- End surface system presets.
------------------------------------------------------------------------

function mcl_levelgen.end_surface_rule ()
	local cid_end_stone = core.get_content_id ("mcl_end:end_stone")
	local end_stone = block (cid_end_stone, 0)
	return end_stone
end
