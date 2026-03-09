------------------------------------------------------------------------
-- Plantlife.
------------------------------------------------------------------------

local is_air_with_grass_below = mcl_levelgen.is_air_with_grass_below

local function require_air_with_grass_below (x, y, z, rng)
	if is_air_with_grass_below (x, y, z) then
		return { x, y, z, }
	else
		return nil
	end
end

-- Sweet Berries.
local cid_sweet_berry_bush_3
	= core.get_content_id ("mcl_farming:sweet_berry_bush_3")

mcl_levelgen.register_configured_feature ("mcl_farming:block_berry_bush_3", {
	feature = "mcl_levelgen:simple_block",
	content = function (_, _, _, rng)
		return cid_sweet_berry_bush_3, 3
	end,
})

mcl_levelgen.register_configured_feature ("mcl_farming:patch_berry_bush", {
	feature = "mcl_levelgen:random_patch",
	placed_feature = {
		configured_feature = "mcl_farming:block_berry_bush_3",
		placement_modifiers = {
			require_air_with_grass_below,
		},
	},
	tries = 96,
	xz_spread = 7,
	y_spread = 3,
})

mcl_levelgen.register_placed_feature ("mcl_farming:patch_berry_common", {
	configured_feature = "mcl_farming:patch_berry_bush",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (32),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface_wg"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_farming:patch_berry_rare", {
	configured_feature = "mcl_farming:patch_berry_bush",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (384),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface_wg"),
		mcl_levelgen.build_in_biome (),
	},
})

-- Melons.
local cid_melon_block = core.get_content_id ("mcl_farming:melon")
local cid_grass_block = core.get_content_id ("mcl_core:dirt_with_grass")
local fix_lighting = mcl_levelgen.fix_lighting

mcl_levelgen.register_configured_feature ("mcl_farming:block_melon", {
	feature = "mcl_levelgen:simple_block",
	content = function (x, y, z, rng)
		fix_lighting (x, y, z, x, y, z)
		return cid_melon_block, 0
	end,
})

local buildable_to_p = mcl_levelgen.buildable_to_p
local water_or_lava_p = mcl_levelgen.water_or_lava_p
local get_block = mcl_levelgen.get_block

local function require_replaceable_non_fluid_with_grass_below (x, y, z)
	local cid, _ = get_block (x, y, z)
	if buildable_to_p (cid) and not water_or_lava_p (cid) then
		local cid, _ = get_block (x, y - 1, z)
		if cid == cid_grass_block then
			return { x, y, z, }
		end
	end
	return nil
end

mcl_levelgen.register_configured_feature ("mcl_farming:patch_melon", {
	feature = "mcl_levelgen:random_patch",
	placed_feature = {
		configured_feature = "mcl_farming:block_melon",
		placement_modifiers = {
			require_replaceable_non_fluid_with_grass_below,
		},
	},
	tries = 64,
	xz_spread = 7,
	y_spread = 3,
})

mcl_levelgen.register_placed_feature ("mcl_farming:patch_melon", {
	configured_feature = "mcl_farming:patch_melon",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (6),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_farming:patch_melon_sparse", {
	configured_feature = "mcl_farming:patch_melon",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (64),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

-- Pumpkins.
local cid_pumpkin_block = core.get_content_id ("mcl_farming:pumpkin")

mcl_levelgen.register_configured_feature ("mcl_farming:block_pumpkin", {
	feature = "mcl_levelgen:simple_block",
	content = function (x, y, z, rng)
		fix_lighting (x, y, z, x, y, z)
		return cid_pumpkin_block, 0
	end,
})

mcl_levelgen.register_configured_feature ("mcl_farming:patch_pumpkin", {
	feature = "mcl_levelgen:random_patch",
	placed_feature = {
		configured_feature = "mcl_farming:block_pumpkin",
		placement_modifiers = {
			require_air_with_grass_below,
		},
	},
	tries = 96,
	xz_spread = 7,
	y_spread = 3,
})

mcl_levelgen.register_placed_feature ("mcl_farming:patch_pumpkin", {
	configured_feature = "mcl_farming:patch_pumpkin",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (300),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

-- Sugar Cane

local cid_sugar_cane = core.get_content_id ("mcl_core:reeds")

local is_air = mcl_levelgen.is_air
local biased_to_bottom_height = mcl_levelgen.biased_to_bottom_height
local is_position_hospitable = mcl_levelgen.is_position_hospitable
local index_biome = mcl_levelgen.index_biome

mcl_levelgen.register_configured_feature ("mcl_farming:sugar_cane_column", {
	feature = "mcl_levelgen:block_column",
	layers = {
		{
			height = biased_to_bottom_height (2, 4, nil),
			content = function (x, y, z, _)
				local biome = index_biome (x, y, z)
				local def = mcl_levelgen.registered_biomes[biome]
				local param2 = def and def.grass_palette_index or 0
				return cid_sugar_cane, param2
			end,
		},
	},
	prioritize_tip = false,
	allowed_placement = is_air,
	direction = 1,
})

local function build_hospitability_check (cid)
	return function (x, y, z, rng)
		if is_position_hospitable (cid, x, y, z) then
			return { x, y, z, }
		else
			return nil
		end
	end
end

local function require_air (x, y, z, rng)
	if is_air (x, y, z) then
		return { x, y, z, }
	else
		return nil
	end
end

mcl_levelgen.register_configured_feature ("mcl_farming:patch_sugar_cane", {
	feature = "mcl_levelgen:random_patch",
	tries = 20,
	xz_spread = 4,
	y_spread = 0,
	placed_feature = {
		configured_feature = "mcl_farming:sugar_cane_column",
		placement_modifiers = {
			require_air,
			build_hospitability_check (cid_sugar_cane),
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_farming:patch_sugar_cane", {
	configured_feature = "mcl_farming:patch_sugar_cane",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (6),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_farming:patch_sugar_cane_desert", {
	configured_feature = "mcl_farming:patch_sugar_cane",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_farming:patch_sugar_cane_badlands", {
	configured_feature = "mcl_farming:patch_sugar_cane",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (5),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_farming:patch_sugar_cane_swamp", {
	configured_feature = "mcl_farming:patch_sugar_cane",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (3),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})
