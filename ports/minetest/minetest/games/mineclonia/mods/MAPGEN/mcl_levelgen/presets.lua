------------------------------------------------------------------------
-- Presets.
-- A preset is a collection of noises, density functions, biome
-- functions, and configuration options that directs the level
-- generator in the generation process.  Every preset is initialized
-- from a template and a seed.
-------------------------------------------------------------------------

local level_preset_template = {
	----------------------------------------------------------------
	-- Basic noise settings.
	-- https://minecraft.wiki/w/Noise_settings
	----------------------------------------------------------------
	min_y = nil,
	height = nil,
	noise_size_horizontal = nil,
	noise_size_vertical = nil,
	default_block = "mcl_core:stone",
	default_fluid = "mcl_core:water_source",
	surface_rule = nil, -- As yet unused.
	spawn_target = {},
	sea_level = nil,
	disable_mob_generation = nil, -- XXX: should this be implemented?
	aquifers_enabled = nil,
	ore_veins_enabled = nil,
	use_legacy_random_source = nil,
	biome_lut = nil,
	seed = nil, -- ull
	index_biomes = nil,
	index_biomes_full = nil,

	----------------------------------------------------------------
	-- Noise functions.
	----------------------------------------------------------------
	barrier_noise = nil,
	fluid_level_floodedness_noise = nil,
	fluid_level_spread_noise = nil,
	lava_noise = nil,
	temperature = nil,
	vegetation = nil,
	continents = nil,
	erosion = nil,
	depth = nil,
	ridges = nil,
	initial_density_without_jaggedness = nil,
	final_density = nil,
	vein_toggle = nil,
	vein_ridged = nil,
	vein_gap = nil,
	registry = {},

	----------------------------------------------------------------
	-- Surface configuration.
	----------------------------------------------------------------
	create_surface_rules = nil,

	----------------------------------------------------------------
	-- Standard noises.
	----------------------------------------------------------------
	noises = {},

	----------------------------------------------------------------
	-- Standard random number generator factory.
	----------------------------------------------------------------
	factory = nil,

	----------------------------------------------------------------
	-- Feature configuration; initialized in features.lua.
	----------------------------------------------------------------
	feature_indices = {},
	features = {},
}
mcl_levelgen.level_preset_template = level_preset_template

-- NormalNoise parameters...
local standard_noise_templates = {
	temperature = {
		keyword = "minecraft:temperature",
		-- Note that what Minecraft terms ``num_octaves'' is
		-- not so much an octave count as a lacunarity--larger
		-- values yield a larger multiplier for noise input
		-- coordinates.  It also decides the index of the
		-- first octave created if the legacy JVM RNG is
		-- enabled.
		num_octaves = -10,
		octaves = {
			1.5, 0.0, 1.0, 0.0, 0.0, 0.0,
		},
	},
	vegetation = {
		keyword = "minecraft:vegetation",
		num_octaves = -8,
		octaves = {
			1.0, 1.0, 0.0, 0.0, 0.0, 0.0,
		},
	},
	continentalness = {
		keyword = "minecraft:continentalness",
		num_octaves = -9,
		octaves = {
			1.0, 1.0, 2.0, 2.0, 2.0, 1.0, 1.0, 1.0, 1.0,
		},
	},
	erosion = {
		keyword = "minecraft:erosion",
		num_octaves = -9,
		octaves = {
			1.0, 1.0, 0.0, 1.0, 1.0,
		},
	},
	temperature_large = {
		keyword = "minecraft:temperature_large",
		num_octaves = -12,
		octaves = {
			1.5, 0.0, 1.0, 0.0, 0.0, 0.0,
		},
	},
	vegetation_large = {
		keyword = "minecraft:vegetation_large",
		num_octaves = -10,
		octaves = {
			1.0, 1.0, 0.0, 0.0, 0.0, 0.0,
		},
	},
	continentalness_large = {
		keyword = "minecraft:continentalness_large",
		num_octaves = -11,
		octaves = {
			1.0, 1.0, 2.0, 2.0, 2.0, 1.0, 1.0, 1.0, 1.0,
		},
	},
	erosion_large = {
		keyword = "minecraft:erosion_large",
		num_octaves = -11,
		octaves = {
			1.0, 1.0, 0.0, 1.0, 1.0,
		},
	},
	ridge = {
		keyword = "minecraft:ridge",
		num_octaves = -7,
		octaves = {
			1.0, 2.0, 1.0, 0.0, 0.0, 0.0,
		},
	},
	offset = {
		keyword = "minecraft:offset",
		num_octaves = -3,
		octaves = {
			1.0, 1.0, 1.0, 0.0,
		},
	},
	aquifer_barrier = {
		keyword = "minecraft:aquifer_barrier",
		num_octaves = -3,
		octaves = {
			1.0,
		},
	},
	aquifer_fluid_level_floodedness = {
		keyword = "minecraft:aquifer_fluid_level_floodedness",
		num_octaves = -7,
		octaves = {
			1.0,
		},
	},
	aquifer_lava = {
		keyword = "minecraft:aquifer_lava",
		num_octaves = -1,
		octaves = {
			1.0,
		},
	},
	aquifer_fluid_level_spread = {
		keyword = "minecraft:aquifer_fluid_level_spread",
		num_octaves = -5,
		octaves = {
			1.0,
		},
	},
	pillar = {
		keyword = "minecraft:pillar",
		num_octaves = -7,
		octaves = {
			1.0, 1.0,
		},
	},
	pillar_rareness = {
		keyword = "minecraft:pillar_rareness",
		num_octaves = -8,
		octaves = {
			1.0,
		},
	},
	pillar_thickness = {
		keyword = "minecraft:pillar_thickness",
		num_octaves = -8,
		octaves = {
			1.0,
		},
	},
	spaghetti_2d = {
		keyword = "minecraft:spaghetti_2d",
		num_octaves = -7,
		octaves = {
			1.0,
		},
	},
	spaghetti_2d_elevation = {
		keyword = "minecraft:spaghetti_2d_elevation",
		num_octaves = -8,
		octaves = {
			1.0,
		},
	},
	spaghetti_2d_modulator = {
		keyword = "minecraft:spaghetti_2d_modulator",
		num_octaves = -11,
		octaves = {
			1.0,
		},
	},
	spaghetti_2d_thickness = {
		keyword = "minecraft:spaghetti_2d_thickness",
		num_octaves = -11,
		octaves = {
			1.0,
		},
	},
	spaghetti_3d_1 = {
		keyword = "minecraft:spaghetti_3d_1",
		num_octaves = -7,
		octaves = {
			1.0,
		},
	},
	spaghetti_3d_2 = {
		keyword = "minecraft:spaghetti_3d_2",
		num_octaves = -7,
		octaves = {
			1.0,
		},
	},
	spaghetti_3d_rarity = {
		keyword = "minecraft:spaghetti_3d_rarity",
		num_octaves = -11,
		octaves = {
			1.0,
		},
	},
	spaghetti_3d_thickness = {
		keyword = "minecraft:spaghetti_3d_thickness",
		num_octaves = -8,
		octaves = {
			1.0,
		},
	},
	spaghetti_roughness = {
		keyword = "minecraft:spaghetti_roughness",
		num_octaves = -5,
		octaves = {
			1.0,
		},
	},
	spaghetti_roughness_modulator = {
		keyword = "minecraft:spaghetti_roughness_modulator",
		num_octaves = -8,
		octaves = {
			1.0,
		},
	},
	cave_entrance = {
		keyword = "minecraft:cave_entrance",
		num_octaves = -7,
		octaves = {
			0.4, 0.5, 1.0,
		}
	},
	cave_layer = {
		keyword = "minecraft:cave_layer",
		num_octaves = -8,
		octaves = {
			1.0,
		},
	},
	cave_cheese = {
		keyword = "minecraft:cave_cheese",
		num_octaves = -8,
		octaves = {
			0.5, 1.0, 2.0, 1.0, 2.0, 1.0, 0.0, 2.0, 0.0,
		},
	},
	ore_veininess = {
		keyword = "minecraft:ore_veininess",
		num_octaves = -8,
		octaves = {
			1.0,
		},
	},
	ore_vein_a = {
		keyword = "minecraft:ore_vein_a",
		num_octaves = -7,
		octaves = {
			1.0,
		},
	},
	ore_vein_b = {
		keyword = "minecraft:ore_vein_b",
		num_octaves = -7,
		octaves = {
			1.0,
		},
	},
	ore_gap = {
		keyword = "minecraft:ore_gap",
		num_octaves = -5,
		octaves = {
			1.0,
		},
	},
	noodle = {
		keyword = "minecraft:noodle",
		num_octaves = -8,
		octaves = {
			1.0,
		},
	},
	noodle_thickness = {
		keyword = "minecraft:noodle_thickness",
		num_octaves = -8,
		octaves = {
			1.0,
		},
	},
	noodle_ridge_a = {
		keyword = "minecraft:noodle_ridge_a",
		num_octaves = -7,
		octaves = {
			1.0,
		},
	},
	noodle_ridge_b = {
		keyword = "minecraft:noodle_ridge_b",
		num_octaves = -7,
		octaves = {
			1.0,
		},
	},
	jagged = {
		keyword = "minecraft:jagged",
		num_octaves = -16,
		octaves = {
			1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
			1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
		},
	},
	surface = {
		keyword = "minecraft:surface",
		num_octaves = -6,
		octaves = {
			1.0, 1.0, 1.0,
		},
	},
	surface_secondary = {
		keyword = "minecraft:surface_secondary",
		num_octaves = -6,
		octaves = {
			1.0, 1.0, 0.0, 1.0,
		},
	},
	clay_bands_offset = {
		keyword = "minecraft:clay_bands_offset",
		num_octaves = -8,
		octaves = {
			1.0,
		},
	},
	badlands_pillar = {
		keyword = "minecraft:badlands_pillar",
		num_octaves = -2,
		octaves = {
			1.0, 1.0, 1.0, 1.0,
		},
	},
	badlands_pillar_roof = {
		keyword = "minecraft:badlands_pillar_roof",
		num_octaves = -8,
		octaves = {
			1.0,
		},
	},
	badlands_surface = {
		keyword = "minecraft:badlands_surface",
		num_octaves = -6,
		octaves = {
			 1.0, 1.0, 1.0,
		},
	},
	iceberg_pillar = {
		keyword = "minecraft:iceberg_pillar",
		num_octaves = -6,
		octaves = {
			1.0, 1.0, 1.0, 1.0,
		},
	},
	iceberg_pillar_roof = {
		keyword = "minecraft:iceberg_pillar_roof",
		num_octaves = -3,
		octaves = {
			1.0,
		},
	},
	iceberg_surface = {
		keyword = "minecraft:iceberg_surface",
		num_octaves = -6,
		octaves = {
			1.0, 1.0, 1.0,
		},
	},
	surface_swamp = {
		keyword = "minecraft:surface_swamp",
		num_octaves = -2,
		octaves = {
			1.0,
		},
	},
	calcite = {
		keyword = "minecraft:calcite",
		num_octaves = -9,
		octaves = {
			1.0, 1.0, 1.0, 1.0,
		},
	},
	gravel = {
		keyword = "minecraft:gravel",
		num_octaves = -8,
		octaves = {
			1.0, 1.0, 1.0, 1.0,
		},
	},
	powder_snow = {
		keyword = "minecraft:powder_snow",
		num_octaves = -6,
		octaves = {
			1.0, 1.0, 1.0, 1.0,
		},
	},
	packed_ice = {
		keyword = "minecraft:packed_ice",
		num_octaves = -7,
		octaves = {
			1.0, 1.0, 1.0, 1.0,
		},
	},
	ice = {
		keyword = "minecraft:ice",
		num_octaves = -4,
		octaves = {
			1.0, 1.0, 1.0, 1.0,
		},
	},
	soul_sand_layer = {
		keyword = "minecraft:soul_sand_layer",
		num_octaves = -8,
		octaves = {
			1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1/75,
		},
	},
	gravel_layer = {
		keyword = "minecraft:gravel_layer",
		num_octaves = -8,
		octaves = {
			1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1/75,
		},
	},
	patch = {
		keyword = "minecraft:patch",
		num_octaves = -5,
		octaves = {
			1.0, 0.0, 0.0, 0.0, 0.0, 1/75,
		},
	},
	netherrack = {
		keyword = "minecraft:netherrack",
		num_octaves = -3,
		octaves = {
			1.0, 0.0, 0.0, 0.35,
		},
	},
	nether_wart = {
		keyword = "minecraft:nether_wart",
		num_octaves = -3,
		octaves = {
			1.0, 0.0, 0.0, 0.9,
		},
	},
	nether_state_selector = {
		keyword = "minecraft:nether_state_selector",
		num_octaves = -4,
		octaves = {
			1.0,
		},
	},
}

local function copy_preset (template)
	local copy = table.copy (template)
	copy.registry = {}
	copy.noises = {}
	return copy
end
mcl_levelgen.copy_preset = copy_preset

------------------------------------------------------------------------
-- Common density functions.
------------------------------------------------------------------------

local MOUNTAIN_HEIGHT_1_MIN = 0.6
local MOUNTAIN_HEIGHT_1_MAX = 1.5
local MOUNTAIN_HEIGHT_2_MIN = 0.6
local MOUNTAIN_HEIGHT_2_MAX = 1.0

local mathmax = math.max
local mathmin = math.min

local function lerp1d (u, s1, s2)
	return (s2 - s1) * u + s1
end

local MOUNTAIN_CONTINENTALNESS_SCALE_BASE = 1.17
local MOUNTAIN_CONTINENTALNESS_SCALE_RECIPROCAL = 1.0 / 2.17

local function mountain_continentalness (low, height, high)
	local base = 1.0 - (1.0 - height) * 0.5
	local inverse = 0.5 * (1.0 - height)
	local scale = (low + MOUNTAIN_CONTINENTALNESS_SCALE_BASE)
		* MOUNTAIN_CONTINENTALNESS_SCALE_RECIPROCAL
	if low < high then
		return mathmax (scale * base - inverse, -0.2222)
	else
		return mathmax (scale * base - inverse, 0.0)
	end
end

local function continentalness_origin (height)
	local base = 1.0 - (1.0 - height) * 0.5
	local inverse = 0.5 * (1.0 - height)
	return (inverse / (MOUNTAIN_CONTINENTALNESS_SCALE_RECIPROCAL * base))
		- MOUNTAIN_CONTINENTALNESS_SCALE_BASE
end

local function get_derivative (f0, f1, g0, g1)
	-- val_diff / loc_diff
	return (f1 - f0) / (g1 - g0)
end

local function mountain_ridge_spline (pv, mountain_height, is_high_continentalness,
				      maybe_amplify)
	local points = {}
	local mountain_low
		= mountain_continentalness (-1.0, mountain_height, -0.7)
	local mountain_high
		= mountain_continentalness (1.0, mountain_height, -0.7)
	local origin = continentalness_origin (mountain_height)

	if -0.65 < origin and origin < 1.0 then
		local base = mountain_continentalness (-0.65, mountain_height, -0.7)
		local below = mountain_continentalness (-0.75, mountain_height, -0.7)
		local first_deriv
			= get_derivative (mountain_low, below, -1.0, -0.75)
		table.insert (points, {
			location = -1.0,
			value = maybe_amplify (mountain_low),
			derivative = first_deriv,
		})
		table.insert (points, {
			location = -0.75,
			value = maybe_amplify (below),
			derivative = 0.0,
		})
		table.insert (points, {
			location = -0.65,
			value = maybe_amplify (base),
			derivative = 0.0,
		})
		-- Origin onward.
		local ground = mountain_continentalness (origin, mountain_height, -0.7)
		local derivative = get_derivative (ground, mountain_high, origin, 1.0)
		table.insert (points, {
			location = origin - 0.01,
			value = maybe_amplify (ground),
			derivative = 0.0,
		})
		table.insert (points, {
			location = origin,
			value = maybe_amplify (ground),
			derivative = derivative,
		})
		table.insert (points, {
			location = 1.0,
			value = maybe_amplify (mountain_high),
			derivative = derivative,
		})
	else
		local derivative = get_derivative (mountain_low, mountain_high,
						   -1.0, 1.0)
		if is_high_continentalness then
			table.insert (points, {
				location = -1.0,
				value = maybe_amplify (mathmax (0.2, mountain_low)),
				derivative = 0.0,
			})
			table.insert (points, {
				location = 0.0,
				value = maybe_amplify (lerp1d (0.5, mountain_low,
							       mountain_high)),
				derivative = derivative,
			})
		else
			table.insert (points, {
				location = -1.0,
				value = maybe_amplify (mountain_low),
				derivative = derivative,
			})
		end
		table.insert (points, {
			location = 1.0,
			value = maybe_amplify (mountain_high),
			derivative = derivative,
		})
	end
	return mcl_levelgen.spline_from_points (pv, points)
end

mcl_levelgen.mountain_ridge_spline = mountain_ridge_spline

local function ridge_spline (pv, valleys_value, low_value, mid_value,
			     high_value, peak_value, min_derivative,
			     maybe_amplify)
	local first_derivative = mathmax (0.5 * (low_value - valleys_value),
					  min_derivative)
	local mid_derivative = 5.0 * (mid_value - low_value)
	local points = {
		{
			location = -1.0,
			value = maybe_amplify (valleys_value),
			derivative = first_derivative,
		},
		{
			location = -0.4,
			value = maybe_amplify (low_value),
			derivative = mathmin (first_derivative,
					      mid_derivative),
		},
		{
			location = 0.0,
			value = maybe_amplify (mid_value),
			derivative = mid_derivative,
		},
		{
			location = 0.4,
			value = maybe_amplify (high_value),
			derivative = 2.0 * (high_value - mid_value),
		},
		{
			location = 1.0,
			value = maybe_amplify (peak_value),
			derivative = 0.7 * (peak_value - high_value),
		},
	}
	return mcl_levelgen.spline_from_points (pv, points)
end

mcl_levelgen.ridge_spline = ridge_spline

local function erosion_spline (erosion, pv, valleys_value, mid_pv_value,
			       peak_pv_value, mountain_height, low_pv_value,
			       high_erosion_low_pv_value, is_high_continentalness_0,
			       is_high_continentalness, maybe_amplify)
	local grade0 = mountain_ridge_spline (pv, lerp1d (mountain_height,
							  MOUNTAIN_HEIGHT_1_MIN,
							  MOUNTAIN_HEIGHT_1_MAX),
					      is_high_continentalness, maybe_amplify)
	local grade1 = mountain_ridge_spline (pv, lerp1d (mountain_height,
							  MOUNTAIN_HEIGHT_2_MIN,
							  MOUNTAIN_HEIGHT_2_MAX),
					      is_high_continentalness, maybe_amplify)
	local grade2 = mountain_ridge_spline (pv, mountain_height, is_high_continentalness,
					      maybe_amplify)
	local grade3 = ridge_spline (pv, valleys_value - 0.15,
				     0.5 * mountain_height,
				     0.5 * mountain_height,
				     0.5 * mountain_height,
				     0.6 * mountain_height,
				     0.5, maybe_amplify)
	local grade4 = ridge_spline (pv, valleys_value,
				     low_pv_value * mountain_height,
				     mid_pv_value * mountain_height,
				     0.5 * mountain_height,
				     0.6 * mountain_height,
				     0.5, maybe_amplify)
	local grade5 = ridge_spline (pv, valleys_value,
				     low_pv_value,
				     low_pv_value,
				     mid_pv_value,
				     peak_pv_value,
				     0.5, maybe_amplify)
	local grade6 = ridge_spline (pv, valleys_value,
				     low_pv_value,
				     low_pv_value,
				     mid_pv_value,
				     peak_pv_value,
				     0.5, maybe_amplify)
	local grade7 = mcl_levelgen.spline_from_points (pv, {
		{
			location = -1.0,
			value = maybe_amplify (valleys_value),
			derivative = 0.0,
		},
		{
			location = -0.4,
			value = grade5,
			derivative = 0.0,
		},
		{
			location = 0.0,
			value = maybe_amplify (peak_pv_value + 0.07),
			derivative = 0.0,
		},
	})
	local grade8 = ridge_spline (pv, -0.02,
				     high_erosion_low_pv_value,
				     high_erosion_low_pv_value,
				     mid_pv_value, peak_pv_value,
				     0.0, maybe_amplify)
	local points = {
		{
			location = -0.85,
			value = grade0,
			derivative = 0.0,
		},
		{
			location = -0.7,
			value = grade1,
			derivative = 0.0,
		},
		{
			location = -0.4,
			value = grade2,
			derivative = 0.0,
		},
		{
			location = -0.35,
			value = grade3,
			derivative = 0.0,
		},
		{
			location = -0.1,
			value = grade4,
			derivative = 0.0,
		},
		{
			location = 0.2,
			value = grade5,
			derivative = 0.0,
		},
	}

	if is_high_continentalness_0 then
		table.insert (points, {
			location = 0.4,
			value = grade6,
			derivative = 0.0,
		})
		table.insert (points, {
			location = 0.45,
			value = grade7,
			derivative = 0.0,
		})
		table.insert (points, {
			location = 0.55,
			value = grade7,
			derivative = 0.0,
		})
		table.insert (points, {
			location = 0.58,
			value = grade6,
			derivative = 0.0,
		})
	end
	table.insert (points, {
		location = 0.7,
		value = grade8,
		derivative = 0.0,
	})
	return mcl_levelgen.spline_from_points (erosion, points)
end

-- Construct a function that provides the offset (i.e., terrain
-- height) of the overworld.

local function overworld_offset_function (continentalness, erosion, pv,
					  is_amplified)
	local spline_entries = {}
	local function maybe_amplify (x)
		if is_amplified and x >= 0.0 then
			return x * 2.0
		end
		return x
	end

	-- MushroomIslands.
	table.insert (spline_entries, {
		location = -1.1,
		value = maybe_amplify (0.044),
		derivative = 0.0,
	})
	-- Deep Ocean.
	table.insert (spline_entries, {
		location = -1.02,
		value = maybe_amplify (-0.2222),
		derivative = 0.0,
	})
	table.insert (spline_entries, {
		location = -0.51,
		value = maybe_amplify (-0.2222),
		derivative = 0.0,
	})
	-- Ocean.
	table.insert (spline_entries, {
		location = -0.44,
		value = maybe_amplify (-0.12),
		derivative = 0.0,
	})
	table.insert (spline_entries, {
		location = -0.18,
		value = maybe_amplify (-0.12),
		derivative = 0.0,
	})

	-- Build splines that apply PV and erosion.
	local coast_erosion_spline
		= erosion_spline (erosion, pv, -0.15, 0.0, 0.0,
				  0.1, 0.0, -0.03, false, false,
				  maybe_amplify)
	local inland_erosion_spline
		= erosion_spline (erosion, pv, -0.1, 0.03, 0.1,
				  0.1, 0.01, -0.03, false, false,
				  maybe_amplify)
	local far_inland_erosion_spline
		= erosion_spline (erosion, pv, -0.1, 0.03, 0.1,
				  0.7, 0.01, -0.03, true, true,
				  maybe_amplify)
	local final_erosion_spline
		= erosion_spline (erosion, pv, -0.05, 0.03, 0.1,
				  1.0, 0.01, 0.01, true, true,
				  maybe_amplify)

	-- Coast.
	table.insert (spline_entries, {
		location = -0.16,
		value = coast_erosion_spline,
		derivative = 0.0,
	})
	table.insert (spline_entries, {
		location = -0.15,
		value = coast_erosion_spline,
		derivative = 0.0,
	})
	-- Near Inland to Mid Inland terrain.
	table.insert (spline_entries, {
		location = -0.10,
		value = inland_erosion_spline,
		derivative = 0.0,
	})
	-- Far Inland terrain.
	table.insert (spline_entries, {
		location = 0.25,
		value = far_inland_erosion_spline,
		derivative = 0.0,
	})
	table.insert (spline_entries, {
		location = 1.0,
		value = final_erosion_spline,
		derivative = 0.0,
	})
	return mcl_levelgen.make_spline (continentalness, spline_entries)
end

local y_clamped_gradient = mcl_levelgen.make_y_clamped_gradient

local function flat_cache (input)
	return mcl_levelgen.make_marker_func ("flat_cache", input)
end

local function cache_2d (input)
	return mcl_levelgen.make_marker_func ("cache_2d", input)
end

local function cache_once (input)
	return mcl_levelgen.make_marker_func ("cache_once", input)
end

local function interpolated (input)
	return mcl_levelgen.make_marker_func ("interpolated", input)
end

local function shift_a (input)
	return mcl_levelgen.make_shift_a (input)
end

local function shift_b (input)
	return mcl_levelgen.make_shift_b (input)
end

local function mul (a, b)
	return mcl_levelgen.make_binary_operation ("multiply", a, b)
end

local function add (a, b)
	return mcl_levelgen.make_binary_operation ("add", a, b)
end

local function min (a, b)
	return mcl_levelgen.make_binary_operation ("min", a, b)
end

local function max (a, b)
	return mcl_levelgen.make_binary_operation ("max", a, b)
end

local function dabs (func)
	return mcl_levelgen.make_unary_op ("abs", func)
end

local function half_negative (x)
	return mcl_levelgen.make_unary_op ("half_negative", x)
end

local function quarter_negative (x)
	return mcl_levelgen.make_unary_op ("quarter_negative", x)
end

local function squeeze (x)
	return mcl_levelgen.make_unary_op ("squeeze", x)
end

local function clamp (x, min, max)
	return mcl_levelgen.make_clamp (x, min, max)
end

local function cube (x)
	return mcl_levelgen.make_unary_op ("cube", x)
end

local function square (x)
	return mcl_levelgen.make_unary_op ("square", x)
end

local function const (x)
	return mcl_levelgen.make_constant (x)
end

local function range_choice (input, min_inclusive, max_exclusive,
			     when_in_range, when_out_of_range)
	return mcl_levelgen.make_range_choice (input, min_inclusive,
					       max_exclusive,
					       when_in_range,
					       when_out_of_range)
end

local function shifted_noise_2d (shiftx, shiftz, xz_scale, noise)
	return mcl_levelgen.make_shifted_noise (shiftx, mcl_levelgen.ZERO,
						shiftz, xz_scale, 0.0,
						noise)
end

local function weird_scaled_sampler (input, noise, samplertype)
	return mcl_levelgen.make_weird_scaled_sampler (samplertype, noise, input)
end

local function pv (func)
	return mul (add (dabs (add (dabs (func), const (-2.0 / 3.0))),
			 const (-1.0 / 3.0)), const (-3.0))
end

-- This sidesteps evaluating input twice.
local function lerp_constant (input, k, b)
	return add (mul (input, add (b, const (-k))), const (k))
end

local function noise_func (noise, xz_scale, y_scale)
	return mcl_levelgen.make_noise_from_parms (noise, xz_scale, y_scale)
end

mcl_levelgen.lerp_constant = lerp_constant

-- local function lerp (input, a, b)
-- 	if a.constant then
-- 		return lerp_constant (input, a.constant, b)
-- 	end

-- 	local input_cached = cache_once (input)
-- 	local value_inverted = add (input_cached, const (-1.0))
-- 	return add (mul (a, value_inverted), mul (b, input_cached))
-- end

local function taper_off_at_extrema (input, level_bottom, level_height,
				     top_margin_upper_offset,
				     top_margin_lower_offset,
				     top_margin_extreme,
				     bottom_margin_lower_offset,
				     bottom_margin_upper_offset,
				     bottom_margin_extreme)
	local desired_height = level_bottom + level_height
	-- Value approaches 1 as y does
	-- desired_height - top_margin_lower_offset.
	local upper_gradient
		= y_clamped_gradient (desired_height - top_margin_upper_offset,
				      desired_height - top_margin_lower_offset,
				      1.0, 0.0)
	local upper_value
		= lerp_constant (upper_gradient, top_margin_extreme, input)


	-- Value approaches 1 as y does level_bottom +
	-- bottom_margin_upper_offset.
	local lower_gradient
		= y_clamped_gradient (level_bottom + bottom_margin_lower_offset,
				      level_bottom + bottom_margin_upper_offset,
				      0.0, 1.0)
	local lower_value
		= lerp_constant (lower_gradient, bottom_margin_extreme, upper_value)
	return lower_value
end

local function identity (x)
	return x
end
mcl_levelgen.identity = identity

local function point (location, value, derivative)
	return {
		location = location,
		value = value,
		derivative = derivative or 0.0,
	}
end

local function erosion_factor_function (erosion, ridges, pv, target_factor, is_last,
					maybe_amplify)
	local points = {
		point (-0.2, maybe_amplify (6.3)),
		point (0.2, maybe_amplify (target_factor)),
	}
	local default = mcl_levelgen.spline_from_points (ridges, points)
	local points = {
		point (-0.6, default),
		point (-0.5, mcl_levelgen.spline_from_points (ridges, {
			point (-0.05, maybe_amplify (6.3)),
			point (0.05, maybe_amplify (2.67)),
		})),
		point (-0.35, default),
		point (-0.25, default),
		point (-0.1, mcl_levelgen.spline_from_points (ridges, {
			point (-0.05, maybe_amplify (2.67)),
			point (0.05, maybe_amplify (6.3)),
		})),
		point (0.03, default),
	}
	if is_last then
		local ridges_spline = mcl_levelgen.spline_from_points (ridges, {
			point (0.0, maybe_amplify (target_factor)),
			point (0.1, maybe_amplify (0.625)),
		})
		local pv_spline = mcl_levelgen.spline_from_points (pv, {
			point (-0.9, maybe_amplify (target_factor)),
			point (-0.69, ridges_spline),
		})
		table.insert (points, point (0.35, maybe_amplify (target_factor)))
		table.insert (points, point (0.45, maybe_amplify (pv_spline)))
		table.insert (points, point (0.55, maybe_amplify (pv_spline)))
		table.insert (points, point (0.62, maybe_amplify (target_factor)))
	else
		local pv_spline_1 = mcl_levelgen.spline_from_points (pv, {
			point (-0.7, default),
			point (-0.15, maybe_amplify (1.37)),
		})
		local pv_spline_2 = mcl_levelgen.spline_from_points (pv, {
			point (0.45, default),
			point (0.7, maybe_amplify (1.56)),
		})
		table.insert (points, point (0.05, pv_spline_2))
		table.insert (points, point (0.4, pv_spline_2))
		table.insert (points, point (0.45, pv_spline_1))
		table.insert (points, point (0.55, pv_spline_1))
		table.insert (points, point (0.58, maybe_amplify (target_factor)))
	end
	return mcl_levelgen.spline_from_points (erosion, points)
end

local function overworld_factor_function (continentalness, erosion,
					  ridges, pv, is_amplified)
	local function maybe_amplify (x)
		if is_amplified then
			return 1.25 - 6.25 / (x + 5.0)
		end
		return x
	end

	local points = {
		{
			location = -0.19,
			value = maybe_amplify (3.95),
			derivative = 0.0,
		},
		{
			location = -0.15,
			value = erosion_factor_function (erosion, ridges, pv, 6.25,
							 true, identity),
			derivative = 0.0,
		},
		{
			location = -0.1,
			value = erosion_factor_function (erosion, ridges, pv, 5.47,
							 true, maybe_amplify),
			derivative = 0.0,
		},
		{
			location = 0.03,
			value = erosion_factor_function (erosion, ridges, pv, 5.08,
							 true, maybe_amplify),
			derivative = 0.0,
		},
		{
			location = 0.06,
			value = erosion_factor_function (erosion, ridges, pv, 4.69,
							 false, maybe_amplify),
			derivative = 0.0,
		},
	}
	return mcl_levelgen.make_spline (continentalness, points)
end

local function weirdness_jaggedness_spline (ridges, val, maybe_amplify)
	return mcl_levelgen.spline_from_points (ridges, {
		point (-0.01, maybe_amplify (val * 0.63)),
		point (0.01, maybe_amplify (val * 0.3)),
	})
end

local abs = math.abs

local function get_pv_value (x)
	return -(abs (abs (x) - 2.0 / 3.0) - 1.0 / 3.0) * 3.0
end

local PV_ZERO_POINT_FOUR = get_pv_value (0.4)
local PV_FIVE_POINT_SIX = get_pv_value (0.5 + 2.0 / 30.0)

local function pv_jaggedness_spline (ridges, pv, upper_target,
				     center_target, maybe_amplify)
	local pv_min = PV_ZERO_POINT_FOUR
	local pv_max = PV_FIVE_POINT_SIX
	local center = (pv_min + pv_max) / 2.0
	local points = {}
	table.insert (points, point (pv_min, 0.0))
	if center_target > 0.0 then
		table.insert (points,
			      point (center, weirdness_jaggedness_spline (ridges,
									  center_target,
									  maybe_amplify)))
	else
		table.insert (points, point (center, 0.0))
	end
	if upper_target > 0.0 then
		table.insert (points,
			      point (1.0, weirdness_jaggedness_spline (ridges,
								       upper_target,
								       maybe_amplify)))
	else
		table.insert (points, point (1.0, 0.0))
	end
	return mcl_levelgen.spline_from_points (pv, points)
end

local function erosion_jaggedness_spline (erosion, ridges, pv,
					  upper_target_low_erosion,
					  upper_target_moderate_erosion,
					  center_target_low_erosion,
					  center_target_moderate_erosion,
					  maybe_amplify)
	local low_erosion = pv_jaggedness_spline (ridges, pv,
						  upper_target_low_erosion,
						  center_target_low_erosion,
						  maybe_amplify)
	local moderate_erosion
		= pv_jaggedness_spline (ridges, pv,
					upper_target_moderate_erosion,
					center_target_moderate_erosion,
					maybe_amplify)
	return mcl_levelgen.spline_from_points (erosion, {
		point (-1.0, low_erosion),
		point (-0.78, moderate_erosion),
		point (-0.5775, moderate_erosion),
		point (-0.375, 0.0),
	})
end

local function overworld_jaggedness_function (continentalness, erosion,
					      ridges, pv, is_amplified)
	local function maybe_amplify (x)
		if is_amplified then
			return x * 2
		end
		return x
	end

	return mcl_levelgen.make_spline (continentalness, {
		point (-0.11, 0.0),
		point (0.03, erosion_jaggedness_spline (erosion, ridges, pv, 1.0, 0.5,
							0.0, 0.0, maybe_amplify)),
		point (0.65, erosion_jaggedness_spline (erosion, ridges, pv, 1.0, 1.0,
							1.0, 0.0, maybe_amplify)),
	})
end

mcl_levelgen.overworld_jaggedness_function = overworld_jaggedness_function

local MINECRAFT_Y_GRADIENT_MIN = -4064
local MINECRAFT_Y_GRADIENT_MAX = 4062
local MINECRAFT_BASE_OFFSET = -0.50375

local function register_terrain_funcs (preset, registry, noises, jagged,
				       continentalness, erosion,
				       name_offset, name_factor, name_jaggedness,
				       name_depth, name_sloped_cheese, is_amplified)
	-- TODO: blending?
	local pv = registry.ridges_folded
	local offset = add (const (MINECRAFT_BASE_OFFSET),
			    overworld_offset_function (continentalness, erosion,
						       pv, is_amplified))
	local offset_cached = cache_2d (offset)
	offset = flat_cache (offset_cached)
	registry[name_offset] = offset
	local factor = overworld_factor_function (continentalness, erosion,
						  registry.ridges, pv,
						  is_amplified)
	factor = flat_cache (cache_2d (factor))
	registry[name_factor] = factor
	local jaggedness = overworld_jaggedness_function (continentalness,
							  erosion, registry.ridges,
							  pv, is_amplified)
	jaggedness = flat_cache (cache_2d (jaggedness))
	registry[name_jaggedness] = jaggedness

	local depth = add (y_clamped_gradient (-64, 320, 1.5, -1.5), offset)
	registry[name_depth] = depth

	local jaggedness_final = mul (jaggedness, half_negative (jagged))
	local depth_jaggedness = add (depth, jaggedness_final)
	local product_factor = mul (depth_jaggedness, factor)
	local gradient = mul (const (4.0), quarter_negative (product_factor))
	registry[name_sloped_cheese] = add (gradient, registry.base_3d_noise_overworld)
end

local end_islands = mcl_levelgen.make_end_island_func

local function copyull (ull)
	return { ull[1], ull[2], }
end

local function translate_from_unit_range_to (input, a, b)
	local center = (b + a) * 0.5
	local scale = (b - a) * 0.5
	return add (const (center), mul (const (scale), input))
end

local function map_unit_noise (noise, xz_scale, y_scale, a, b)
	return translate_from_unit_range_to (noise_func (noise, xz_scale,
							 y_scale),
					     a, b)
end

local function get_spaghetti_2d_function (registry, noises)
	local modulator = noise_func (noises.spaghetti_2d_modulator, 2.0, 1.0)
	local map2 = weird_scaled_sampler (modulator, noises.spaghetti_2d, "type_2")
	local elevation = map_unit_noise (noises.spaghetti_2d_elevation,
					  1.0, 0.0, -8.0, 8.0)
	local depth_bias = y_clamped_gradient (-64, 320, 8.0, -40.0)
	local biased_elevation = dabs (add (elevation, depth_bias))
	local thickness_modulator = registry.spaghetti_2d_thickness_modulator
	local modulated = cube (add (biased_elevation, thickness_modulator))
	local value = max (add (map2, mul (const (0.083), thickness_modulator)),
			   modulated)
	return clamp (value, -1.0, 1.0)
end

local function get_cave_entrance_function (registry, noises)
	local rarity = cache_once (noise_func (noises.spaghetti_3d_rarity, 2.0, 1.0))
	local thickness_3d = map_unit_noise (noises.spaghetti_3d_thickness,
					     1.0, 1.0, -0.065, -0.088)
	local sample_a = weird_scaled_sampler (rarity, noises.spaghetti_3d_1,
					       "type_1")
	local sample_b = weird_scaled_sampler (rarity, noises.spaghetti_3d_2,
					       "type_1")
	local sample_mixed = clamp (add (max (sample_a, sample_b), thickness_3d),
				    -1.0, 1.0)
	local roughness = registry.spaghetti_roughness_function
	local entrance = noise_func (noises.cave_entrance, 0.75, 0.5)
	local entrance_biased = add (add (entrance, const (0.37)),
				     y_clamped_gradient (-10, 30, 0.3, 0))
	return cache_once (min (entrance_biased, add (roughness, sample_mixed)))
end

local function noodle_interpolation (input, value, input_min_inclusive,
				     input_max_inclusive, value_out_of_range)
	return interpolated (range_choice (input, input_min_inclusive,
					   input_max_inclusive + 1, value,
					   const (value_out_of_range)))
end

local NOODLE_RIDGE_SCALE = 64 / 24
local NOODLE_DEFAULT_VALUE = 64

local function get_noodle_function (registry, noises)
	local y_pos = registry.y
	local noodle_density
		= noodle_interpolation (y_pos, noise_func (noises.noodle, 1.0, 1.0),
					-60, 320, -1)
	local noodle_thickness
		= noodle_interpolation (y_pos,
					map_unit_noise (noises.noodle_thickness, 1.0, 1.0,
							-0.05, -0.1),
					-60, 320, 0)
	local ridge_a
		= noodle_interpolation (y_pos, noise_func (noises.noodle_ridge_a,
							   NOODLE_RIDGE_SCALE,
							   NOODLE_RIDGE_SCALE),
					-60, 320, 0)
	local ridge_b
		= noodle_interpolation (y_pos, noise_func (noises.noodle_ridge_b,
							   NOODLE_RIDGE_SCALE,
							   NOODLE_RIDGE_SCALE),
					-60, 320, 0)
	local ridges = mul (const (1.5), max (dabs (ridge_a), dabs (ridge_b)))
	return range_choice (noodle_density, -1000000.0, 0.0,
			     const (NOODLE_DEFAULT_VALUE),
			     add (noodle_thickness, ridges))
end

local function get_pillars_function (registry, noises)
	local noise = noise_func (noises.pillar, 25.0, 0.3)
	local rareness = map_unit_noise (noises.pillar_rareness, 1.0, 1.0,
					 0.0, -2.0)
	local thickness = map_unit_noise (noises.pillar_thickness, 1.0, 1.0,
					  0.0, 1.1)
	local combined = add (mul (noise, const (2.0)), rareness)
	return cache_once (mul (combined, cube (thickness)))
end

local function common_density_functions (preset, registry, noises)
	registry.zero = mcl_levelgen.ZERO
	registry.y
		= mcl_levelgen.make_y_clamped_gradient (MINECRAFT_Y_GRADIENT_MIN,
							MINECRAFT_Y_GRADIENT_MAX,
							MINECRAFT_Y_GRADIENT_MIN,
							MINECRAFT_Y_GRADIENT_MAX)
	registry.shift_x = flat_cache (cache_2d (shift_a (noises.offset)))
	registry.shift_z = flat_cache (cache_2d (shift_b (noises.offset)))

	local function make_terrain_rng ()
		local legacy, rng = preset.use_legacy_random_source
		if legacy then
			local seed = copyull (preset.seed)
			rng = mcl_levelgen.jvm_random (seed)
		else
			rng = preset.factory ("minecraft:terrain")
		end
		return rng
	end
	registry.base_3d_noise_overworld
		= mcl_levelgen.make_blended_noise_from_parms (make_terrain_rng (),
							      0.25, 0.125, 80.0, 160.0,
							      8.0)
	registry.base_3d_noise_nether
		= mcl_levelgen.make_blended_noise_from_parms (make_terrain_rng (),
							      0.25, 0.375, 80.0, 60.0,
							      8.0)
	registry.base_3d_noise_end
		= mcl_levelgen.make_blended_noise_from_parms (make_terrain_rng (),
							      0.25, 0.25, 80.0, 160.0,
							      4.0)

	local shift_x, shift_z = registry.shift_x, registry.shift_z
	registry.continents = flat_cache (shifted_noise_2d (shift_x, shift_z,
							    0.25,
							    noises.continentalness))
	registry.erosion = flat_cache (shifted_noise_2d (shift_x, shift_z,
							 0.25,
							 noises.erosion))
	-- Weirdness...
	registry.ridges = flat_cache (shifted_noise_2d (shift_x, shift_z,
							0.25, noises.ridge))
	-- PV...
	registry.ridges_folded = pv (registry.ridges)

	-- Register unscaled noises.
	local jaggedness = noise_func (noises.jagged, 1500.0, 0.0)
	register_terrain_funcs (preset, registry, noises, jaggedness,
				registry.continents, registry.erosion,
				"offset", "factor", "jaggedness", "depth",
				"sloped_cheese", false)

	-- Register scaled noises for the large biomes preset.
	registry.continents_large
		= flat_cache (shifted_noise_2d (shift_x, shift_z,
						0.25,
						noises.continentalness_large))
	registry.erosion_large
		= flat_cache (shifted_noise_2d (shift_x, shift_z,
						0.25,
						noises.erosion_large))
	register_terrain_funcs (preset, registry, noises, jaggedness,
				registry.continents_large,
				registry.erosion_large,
				"offset_large", "factor_large",
				"jaggedness_large", "depth_large",
				"sloped_cheese_large", false)

	-- Register scaled noises for the amplified present.
	register_terrain_funcs (preset, registry, noises, jaggedness,
				registry.continents, registry.erosion,
				"offset_amplified", "factor_amplified",
				"jaggedness_amplified", "depth_amplified",
				"sloped_cheese_amplified", false)

	registry.sloped_cheese_end = add (end_islands (copyull (preset.seed)),
					  registry.base_3d_noise_end)

	local spaghetti_roughness = noise_func (noises.spaghetti_roughness,
						1.0, 1.0)
	local spaghetti_roughness_modulator
		= map_unit_noise (noises.spaghetti_roughness_modulator, 1.0, 1.0,
				  0.0, -0.1)
	registry.spaghetti_roughness_function
		= cache_once (mul (spaghetti_roughness_modulator,
				   add (dabs (spaghetti_roughness),
					const (-0.4))))

	registry.spaghetti_2d_thickness_modulator
		= cache_once (map_unit_noise (noises.spaghetti_2d_thickness,
					      2.0, 1.0, -0.6, -1.3))
	registry.spaghetti_2d = get_spaghetti_2d_function (registry, noises)
	registry.entrances = get_cave_entrance_function (registry, noises)
	registry.noodle = get_noodle_function (registry, noises)
	registry.pillars = get_pillars_function (registry, noises)
end

local ull = mcl_levelgen.ull
local addull = mcl_levelgen.addull

local function jvm_rng_from_key_and_delta (key, delta)
	local delta_ull = ull (0, delta)
	addull (delta_ull, key)
	return mcl_levelgen.jvm_random (delta_ull)
end

local function initialize_noises (preset)
	local use_legacy_random_source = preset.use_legacy_random_source
	local make_normal_noise = mcl_levelgen.make_normal_noise
	local factory = preset.factory

	local function create_noise (key, template)
		if use_legacy_random_source then
			if key == "offset" then
				return make_normal_noise (factory (template.keyword), 0,
							  { 0.0, }, true)
			elseif key == "temperature" then
				local rng = jvm_rng_from_key_and_delta (preset.seed, 0)
				return make_normal_noise (rng, -7, { 1.0, 1.0, }, false)
			elseif key == "vegetation" then
				local rng = jvm_rng_from_key_and_delta (preset.seed, 1)
				return make_normal_noise (rng, -7, { 1.0, 1.0, }, false)
			end
		end

		-- print ("Instantiating noise: " .. key .. " ")
		local rng = factory (template.keyword)
		local noise = make_normal_noise (rng, template.num_octaves,
						 template.octaves, true)
		-- print ("Instantiated noise: " .. key .. " " .. noise (0.0, 0.0, 0.0))
		return noise
	end

	local metatable = {
		__index = function (tbl, key)
			local value = rawget (tbl, key)
			if value then
				return value
			end

			local template = standard_noise_templates[key]
			assert (template, "Noise template is not defined: " .. key)
			local noise = create_noise (key, template)
			tbl[key] = noise
			return noise
		end
	}
	setmetatable (preset.noises, metatable)
end
mcl_levelgen.initialize_noises = initialize_noises

local seed_from_ull = mcl_levelgen.seed_from_ull
local mix64 = mcl_levelgen.mix64

function mcl_levelgen.xoroshiro_from_seed (seed)
	local lo, hi = ull (0, 0), ull (0, 0)
	seed_from_ull (lo, hi, seed)
	-- print ("unmixed", mcl_levelgen.tostringull (lo),
	--        mcl_levelgen.tostringull (hi))
	mix64 (lo)
	mix64 (hi)
	-- print (mcl_levelgen.tostringull (seed) .. " => "
	--        .. mcl_levelgen.tostringull (lo)
	--        .. " " .. mcl_levelgen.tostringull (hi))
	return mcl_levelgen.xoroshiro (lo, hi)
end

local function initialize_random (preset, seed)
	local rng
	preset.seed = copyull (seed)
	if preset.use_legacy_random_source then
		rng = mcl_levelgen.jvm_random (seed)
	else
		rng = mcl_levelgen.xoroshiro_from_seed (seed)
	end
	preset.factory = rng:fork_positional ()
end
mcl_levelgen.initialize_random = initialize_random

local function initialize_density_functions (preset)
	common_density_functions (preset, preset.registry, preset.noises)
end

local function post_process (final_density)
	return squeeze (mul (interpolated (final_density), const (0.64)))
end

local lshift = bit.lshift
local band = bit.band
local function toblock (x)
	return lshift (x, 2)
end

local toquart = mcl_levelgen.toquart
local index_biome_lut = mcl_levelgen.index_biome_lut

local quantize = mcl_levelgen.quantize

local huge = math.huge

local function initialize_noise_biomes (preset, large_biomes, amplified, get_lut,
					is_nether)
	local nodes
	preset.biome_lut, nodes = get_lut ()

	-- Strip caching or interpolating wrappers from density
	-- functions.
	local function strip_markers (dfunc)
		if dfunc.is_marker then
			return dfunc.input
		else
			return dfunc
		end
	end

	local index_cache, index = {}, nil
	local x_origin, z_origin, width_z
	local n_indices = 0

	local biome_flat_cache = {}
	function biome_flat_cache:__call (x, y, z, blender)
		if index then
			local i = self.offset
			local x = index_cache[index + i]
			if x == -huge then
				x = self.input (x, y, z, blender)
				index_cache[index + i] = x
			end
			return x
		else
			return self.input (x, y, z, blender)
		end
	end

	function biome_flat_cache:petrify_internal (visited)
		local input = self.input:petrify_and_clone (visited)
		local offset = self.offset
		return function (x, y, z, blender)
			local val = index_cache[index + offset]
			if val == -huge then
				val = input (x, y, z, blender)
				index_cache[index + offset] = val
			end
			return val
		end
	end

	function biome_flat_cache:min_value ()
		return self.input:min_value ()
	end

	function biome_flat_cache:max_value ()
		return self.input:max_value ()
	end

	local make_density_function = mcl_levelgen.make_density_function

	-- Strip caching or interpolating wrappers excepting
	-- flat_caches; used to optimize noise computation.
	local function do_flat_cache (dfunc)
		if dfunc.is_marker then
			if dfunc.name == "flat_cache" then
				local flat_cache = table.merge (biome_flat_cache, {
									input = dfunc.input,
									offset = n_indices + 1,
				})
				n_indices = n_indices + 1
				flat_cache = make_density_function (flat_cache)
				return flat_cache
			end
			return dfunc.input
		else
			return dfunc
		end
	end

	local registry, noises = preset.registry, preset.noises
	local shift_x, shift_z = registry.shift_x, registry.shift_z
	local temp_noise = large_biomes and noises.temperature_large
		or noises.temperature
	local vegetation_noise = large_biomes and noises.vegetation_large
		or noises.vegetation
	preset.temperature = shifted_noise_2d (shift_x, shift_z, 0.25,
					       temp_noise)
	preset.vegetation = shifted_noise_2d (shift_x, shift_z, 0.25,
					      vegetation_noise)

	if is_nether then
		preset.continents = registry.zero
		preset.erosion = registry.zero
		preset.depth = registry.zero
		preset.ridges = registry.zero
	else
		preset.continents = large_biomes and registry.continents_large
			or registry.continents
		preset.erosion = large_biomes and registry.erosion_large
			or registry.erosion
		preset.depth = large_biomes and registry.depth_large
			or (amplified and registry.depth_amplified
			    or registry.depth)
		preset.ridges = registry.ridges
	end

	local wrap_petrify_multiple = mcl_levelgen.wrap_petrify_multiple
	local temperature_cached,
		vegetation_cached,
		continents_cached,
		erosion_cached,
		depth_cached,
		ridges_cached = wrap_petrify_multiple (do_flat_cache, identity, {
		preset.temperature,
		preset.vegetation,
		preset.continents,
		preset.erosion,
		preset.depth,
		preset.ridges,
	})

	local temperature_stripped,
		vegetation_stripped,
		continents_stripped,
		erosion_stripped,
		depth_stripped,
		ridges_stripped = wrap_petrify_multiple (strip_markers, identity, {
		preset.temperature,
		preset.vegetation,
		preset.continents,
		preset.erosion,
		preset.depth,
		preset.ridges,
	})

	local biome_lut = preset.biome_lut

	preset.index_biomes = function (self, qx, qy, qz)
		local x, y, z = toblock (qx), toblock (qy), toblock (qz)
		return index_biome_lut (biome_lut,
					temperature_stripped (x, 0, z),
					vegetation_stripped (x, 0, z),
					continents_stripped (x, 0, z),
					erosion_stripped (x, 0, z),
					depth_stripped (x, y, z),
					ridges_stripped (x, 0, z))
	end

	preset.index_biomes_begin = function (self, wx, wz, xorigin, zorigin)
		for i = 1, wx * wz * n_indices do
			index_cache[i] = -huge
		end
		x_origin = xorigin
		z_origin = zorigin
		width_z = wz
	end

	preset.index_biomes_cached = function (self, qx, qy, qz)
		local x, y, z = toblock (qx), toblock (qy), toblock (qz)
		local cx = qx - x_origin
		local cz = qz - z_origin
		index = ((cx * width_z) + cz) * n_indices
		local t = temperature_cached (x, y, z)
		local v = vegetation_cached (x, y, z)
		local c = continents_cached (x, y, z)
		local e = erosion_cached (x, y, z)
		local d = depth_cached (x, y, z)
		local r = ridges_cached (x, y, z)
		return index_biome_lut (biome_lut, t, v, c, e, d, r)
	end

	preset.biome_debug_string = function (self, x, y, z)
		local t = temperature_stripped (x, y, z)
		local v = vegetation_stripped (x, y, z)
		local c = continents_stripped (x, y, z)
		local e = erosion_stripped (x, y, z)
		local d = depth_stripped (x, y, z)
		local w = ridges_stripped (x, y, z)
		local pv = self.registry.ridges_folded (x, y, z)

		return string.format ("T: %.3f V: %.3f, C: %.3f, E: %.3f, D: %.3f, W: %0.3f, PV: %0.3f",
				      t, v, c, e, d, w, pv)
	end

	local function sample (x, y, z)
		x = band (x, -4)
		y = band (y, -4)
		z = band (z, -4)
		local t = temperature_stripped (x, y, z)
		local v = vegetation_stripped (x, y, z)
		local c = continents_stripped (x, y, z)
		local e = erosion_stripped (x, y, z)
		local d = depth_stripped (x, y, z)
		local w = ridges_stripped (x, y, z)
		return {
			quantize (t),
			quantize (v),
			quantize (c),
			quantize (e),
			quantize (d),
			quantize (w),
			0.0,
		}
	end

	preset.biome_coordinates = function (self, x, y, z)
		return sample (x, y, z)
	end

	local all_biomes, seen = {}, {}

	for _, node in ipairs (nodes) do
		if not seen[node.value] then
			table.insert (all_biomes, node.value)
			seen[node.value] = true
		end
	end

	preset.generated_biomes = function (self)
		return all_biomes
	end

	local biome_spawn_position = mcl_levelgen.biome_spawn_position
	if #preset.spawn_target > 0 then
		local spawn_target = preset.spawn_target
		preset.find_spawn_position = function (self)
			return biome_spawn_position (spawn_target, 0, sample)
		end
	else
		preset.find_spawn_position = function (self)
			return 0, 0
		end
	end
end

------------------------------------------------------------------------
-- Overworld presets.
------------------------------------------------------------------------

local SURFACE_DENSITY = 1.5625

-- Return a function that computes the density of all positions
-- beneath the surface, as decided by SURFACE_DENSITY.

local function get_underground_func (registry, noises, sloped_cheese)
	local spaghetti2d = registry.spaghetti_2d
	local spaghetti_roughness = registry.spaghetti_roughness_function

	-- Noise which provides the basic density of this cave.
	local cave_layer = noise_func (noises.cave_layer, 1.0, 8.0)
	local cave_scaled = mul (const (4.0), square (cave_layer))

	-- Noise subtracted from the said basic density to create
	-- cheese caves.
	local cheese = noise_func (noises.cave_cheese, 1.0, 2.0 / 3.0)

	-- Blended with terrain in reverse so as not to create
	-- unnatural recesses or protrude from terrain.
	local cheese_terrain_blended
		= add (clamp (add (const (0.27), cheese), -1.0, 1.0),
		       clamp (add (const (1.5),
				   mul (const (-0.64), sloped_cheese)),
			      0.0, 0.5))
	local cave_final = add (cave_scaled, cheese_terrain_blended)

	-- Combine with spaghetti caves.
	local cave_carved = min (min (cave_final, registry.entrances),
				 add (spaghetti2d, spaghetti_roughness))

	-- And replace with pillar noise if it is sufficiently
	-- intense.
	local pillars = range_choice (registry.pillars, -1000000.0, 0.03,
				      const (-1000000.0), registry.pillars)
	return max (cave_carved, pillars)
end

local FLUID_LEVEL_SPREAD_SCALE = 5 / 7

local function check_overworld_at_extrema (density, is_amplified)
	return taper_off_at_extrema (density, -64, 384,
				     is_amplified and 16 or 80,
				     is_amplified and 0 or 64,
				     -0.078125, 0, 24,
				     is_amplified and 0.4 or 0.1171875)
end

mcl_levelgen.check_overworld_at_extrema = check_overworld_at_extrema

local ORE_VEIN_COPPER_MIN = 0
local ORE_VEIN_COPPER_MAX = 50
local ORE_VEIN_IRON_MIN = -60
local ORE_VEIN_IRON_MAX = -8
local ORE_VEIN_MAX_HEIGHT = 50 -- Copper.
local ORE_VEIN_MIN_HEIGHT = -60 -- Iron.

mcl_levelgen.ORE_VEIN_COPPER_MIN = ORE_VEIN_COPPER_MIN
mcl_levelgen.ORE_VEIN_COPPER_MAX = ORE_VEIN_COPPER_MAX
mcl_levelgen.ORE_VEIN_IRON_MIN = ORE_VEIN_IRON_MIN
mcl_levelgen.ORE_VEIN_IRON_MAX = ORE_VEIN_IRON_MAX
mcl_levelgen.ORE_VEIN_MIN_HEIGHT = ORE_VEIN_MIN_HEIGHT
mcl_levelgen.ORE_VEIN_MAX_HEIGHT = ORE_VEIN_MAX_HEIGHT

local function initialize_overworld_generation (params, large_biomes, amplified)
	local registry, noises = params.registry, params.noises
	params.barrier_noise = noise_func (noises.aquifer_barrier, 1.0, 0.5)
	params.fluid_level_floodedness_noise
		= noise_func (noises.aquifer_fluid_level_floodedness, 1.0, 0.67)
	params.fluid_level_spread_noise
		= noise_func (noises.aquifer_fluid_level_spread, 1.0,
			      FLUID_LEVEL_SPREAD_SCALE)
	params.lava_noise
		= noise_func (noises.aquifer_lava, 1.0, 1.0)

	local factor = large_biomes and registry.factor_large
		or (amplified and registry.factor_amplified
		    or registry.factor)
	local depth = large_biomes and registry.depth_large
		or (amplified and registry.depth_amplified
		    or registry.depth)
	local sloped_cheese -- Final 3d noise.
		= large_biomes and registry.sloped_cheese_large
		or (amplified and registry.sloped_cheese_amplified
		    or registry.sloped_cheese)
	local sloped_cheese_with_cave_entrances
		= min (sloped_cheese, mul (const (5.0),
					   registry.entrances))
	local underground_func
		= get_underground_func (registry, noises, sloped_cheese)
	local sloped_cheese_or_underground
		= range_choice (sloped_cheese,
				-1000000.0, SURFACE_DENSITY,
				sloped_cheese_with_cave_entrances,
			        underground_func)
	local tapered = check_overworld_at_extrema (sloped_cheese_or_underground,
						    amplified)
	params.final_density = min (post_process (tapered), registry.noodle)

	-- This density function is sampled by aquifers and surface
	-- systems to ascertain preliminary surface levels.
	local product_factor = mul (depth, cache_2d (factor))
	local scaled = mul (const (4.0), quarter_negative (product_factor))
	-- XXX: huh???  What is the significance of this offset?
	local scaled_offset = clamp (add (scaled, const (-0.703125)),
				     -64.0, 64.0)
	local tapered_initial
		= check_overworld_at_extrema (scaled_offset, amplified)
	params.initial_density_without_jaggedness = tapered_initial

	local vein_toggle
		= noodle_interpolation (registry.y,
					noise_func (params.noises.ore_veininess, 1.5, 1.5),
					ORE_VEIN_MIN_HEIGHT, ORE_VEIN_MAX_HEIGHT, 0)
	local vein_a
		= noodle_interpolation (registry.y,
					noise_func (params.noises.ore_vein_a, 4.0, 4.0),
					ORE_VEIN_MIN_HEIGHT, ORE_VEIN_MAX_HEIGHT, 0)
	local vein_b
		= noodle_interpolation (registry.y,
					noise_func (params.noises.ore_vein_b, 4.0, 4.0),
					ORE_VEIN_MIN_HEIGHT, ORE_VEIN_MAX_HEIGHT, 0)
	local vein_ridged = add (const (-0.08), max (dabs (vein_a), dabs (vein_b)))
	local vein_gap = noise_func (params.noises.ore_gap, 1.0, 1.0)
	params.vein_toggle = vein_toggle
	params.vein_ridged = vein_ridged
	params.vein_gap = vein_gap
end

-- Overworld preset functions.

local ALL_VALUES = { -1.0, 1.0, }
local ZERO = { 0.0, 0.0, }

local overworld_preset_template = table.merge (level_preset_template, {
	min_y = -64,
	height = 384,
	sea_level = 63,
	noise_size_horizontal = 1,
	noise_size_vertical = 2,
	noise_cell_width = toblock (1),
	noise_cell_height = toblock (2),
	aquifers_enabled = true,
	ore_veins_enabled = true,
	spawn_target = {
		{
			ALL_VALUES,
			ALL_VALUES,
			{ -0.11, 1.0, },
			ALL_VALUES,
			ZERO,
			{ -1.0, -0.16, },
			ZERO,
		},
		{
			ALL_VALUES,
			ALL_VALUES,
			{ -0.11, 1.0, },
			ALL_VALUES,
			ZERO,
			{ 0.16, 1.0, },
			ZERO,
		},
	},
})

function overworld_preset_template:index_biomes_block (x, y, z)
	return self:index_biomes (toquart (x), toquart (y), toquart (z))
end

local function initialize_overworld_surface_rules (preset)
	preset.create_surface_rules = function (self)
		return mcl_levelgen.overworld_surface_rule (self, true, false, true)
	end
end

local construct_overworld_lut = mcl_levelgen.construct_overworld_lut

function mcl_levelgen.make_overworld_preset (seed, large_biomes)
	local preset = copy_preset (overworld_preset_template)
	initialize_random (preset, seed)
	initialize_noises (preset)
	initialize_density_functions (preset)
	initialize_noise_biomes (preset, large_biomes, false,
				 construct_overworld_lut, false)
	initialize_overworld_generation (preset, large_biomes)
	initialize_overworld_surface_rules (preset)
	return preset
end

------------------------------------------------------------------------
-- Nether presets.
------------------------------------------------------------------------

local function initialize_nether_generation (preset)
	local registry = preset.registry
	preset.barrier_noise = registry.zero
	preset.fluid_level_floodedness_noise = registry.zero
	preset.fluid_level_spread_noise = registry.zero
	preset.lava_noise = registry.zero
	preset.initial_density_without_jaggedness = registry.zero
	preset.vein_toggle = registry.zero
	preset.vein_ridged = registry.zero
	preset.vein_gap = registry.zero

	local nether_noise
		= taper_off_at_extrema (registry.base_3d_noise_nether,
					0, 128, 24, 0, 0.9375, -8, 24, 2.5)
	preset.final_density = post_process (nether_noise)
end

local function initialize_nether_surface_rules (preset)
	preset.create_surface_rules = function (self)
		return mcl_levelgen.nether_surface_rule (self)
	end
end

-- Nether preset functions.

local nether_preset_template = table.merge (level_preset_template, {
	min_y = 0,
	height = 128,
	sea_level = 32,
	noise_size_horizontal = 1,
	noise_size_vertical = 2,
	noise_cell_width = toblock (1),
	noise_cell_height = toblock (2),
	disable_mob_generation = true,
	aquifers_enabled = false,
	ore_veins_enabled = false,
	use_legacy_random_source = true,
	default_block = "mcl_nether:netherrack",
	default_fluid = "mcl_nether:nether_lava_source",
})

nether_preset_template.index_biomes_block
	= overworld_preset_template.index_biomes_block

local construct_nether_lut = mcl_levelgen.construct_nether_lut

function mcl_levelgen.make_nether_preset (seed)
	local preset = copy_preset (nether_preset_template)
	initialize_random (preset, seed)
	initialize_noises (preset)
	initialize_density_functions (preset)
	initialize_noise_biomes (preset, false, false,
				 construct_nether_lut, true)
	initialize_nether_generation (preset)
	initialize_nether_surface_rules (preset)
	return preset
end

------------------------------------------------------------------------
-- End presets.
------------------------------------------------------------------------

local end_preset_template = table.merge (level_preset_template, {
	min_y = 0,
	height = 128,
	sea_level = 0,
	noise_size_horizontal = 2,
	noise_size_vertical = 1,
	noise_cell_width = toblock (2),
	noise_cell_height = toblock (1),
	disable_mob_generation = true,
	aquifers_enabled = false,
	ore_veins_enabled = false,
	use_legacy_random_source = true,
	default_block = "mcl_end:end_stone",
	default_fluid = "air",
})

end_preset_template.index_biomes_block
	= overworld_preset_template.index_biomes_block

local arshift = bit.arshift
local lshift = bit.lshift
local end_islands = mcl_levelgen.make_end_island_func

local function initialize_end_biomes (preset)
	-- Strip caching or interpolating wrappers from density
	-- functions.
	local function strip_markers (dfunc)
		if dfunc.is_marker then
			return dfunc.input
		else
			return dfunc
		end
	end

	local registry = preset.registry
	preset.vegetation = registry.zero
	preset.temperature = registry.zero
	preset.continents = registry.zero
	preset.depth = registry.zero
	preset.ridges = registry.zero
	-- Actually just `end_island_eval (simplex_octave (...))',
	-- but Minecraft can be observed performing this ridiculous
	-- dance.
	preset.erosion = cache_2d (end_islands (preset.seed))

	local erosion_stripped
		= preset.erosion:wrap (strip_markers, identity)

	preset.index_biomes = function (self, qx, qy, qz)
		local bx, bz
			= toblock (qx), toblock (qz)
		local sx, sz
			= arshift (bx, 4), arshift (bz, 4)

		if sx * sx + sz * sz <= 4096 then
			return "TheEnd"
		else
			local erode_x = lshift (sx * 2 + 1, 3)
			local erode_z = lshift (sz * 2 + 1, 3)
			local value = erosion_stripped (erode_x, 0, erode_z)
			if value > 0.25 then -- (40 - 8) / 128.0
				return "EndHighlands"
			elseif value >= -0.0625 then -- (0 - 8) / 128.0
				return "EndMidlands"
			elseif value >= -0.21875 then -- (-20.0 - 8) / 128.0
				return "EndBarrens"
			else
				return "SmallEndIslands"
			end
		end
	end

	preset.index_biomes_cached = preset.index_biomes
	preset.index_biomes_begin = function (self, wx, wz, xorigin, zorigin)
	end
	preset.biome_debug_string = function (self, x, y, z)
		return string.format ("E: %.3f", erosion_stripped (x, y, z))
	end
	local all_biomes = {
		"TheEnd",
		"EndHighlands",
		"EndMidlands",
		"SmallEndIslands",
		"EndBarrens",
	}
	preset.generated_biomes = function (_)
		return all_biomes
	end
	preset.find_spawn_position = function (_)
		return 0, 0
	end

	preset.index_biomes_cached = preset.index_biomes
end

local function initialize_end_generation (preset)
	local registry = preset.registry
	preset.barrier_noise = registry.zero
	preset.fluid_level_floodedness_noise = registry.zero
	preset.fluid_level_spread_noise = registry.zero
	preset.lava_noise = registry.zero
	preset.initial_density_without_jaggedness = registry.zero
	preset.vein_toggle = registry.zero
	preset.vein_ridged = registry.zero
	preset.vein_gap = registry.zero

	local end_islands_only
		= taper_off_at_extrema (add (preset.erosion, const (-0.703125)),
					0, 128, 72, -184, -23.4375, 4, 32,
					-0.234375)
	preset.initial_density_without_jaggedness = end_islands_only
	local end_noise
		= taper_off_at_extrema (registry.sloped_cheese_end,
					0, 128, 72, -184, -23.4375, 4, 32,
					-0.234375)
	preset.final_density = post_process (end_noise)
end

local function initialize_end_surface_rules (preset)
	preset.create_surface_rules = function (self)
		return mcl_levelgen.end_surface_rule ()
	end
end

function mcl_levelgen.make_end_preset (seed)
	local preset = copy_preset (end_preset_template)
	initialize_random (preset, seed)
	initialize_noises (preset)
	initialize_density_functions (preset)
	initialize_end_biomes (preset)
	initialize_end_generation (preset)
	initialize_end_surface_rules (preset)
	return preset
end
