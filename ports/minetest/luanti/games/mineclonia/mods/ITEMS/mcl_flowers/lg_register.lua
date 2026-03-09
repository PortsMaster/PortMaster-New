------------------------------------------------------------------------
-- Flower features.
------------------------------------------------------------------------

local W = mcl_levelgen.build_weighted_cid_provider
local is_air = mcl_levelgen.is_air
local ull = mcl_levelgen.ull

local function build_flower_content_list (flowers)
	local list = {}

	for _, flower in ipairs (flowers) do
		local name = "mcl_flowers:" .. flower
		local param2 = 0
		if name == "mcl_flowers:double_grass"
			or name == "mcl_flowers:tallgrass" then
			param2 = "grass_palette_index"
		end
		local cid = core.get_content_id (name)
		table.insert (list, { cid, param2, })
	end
	return list
end

local function build_flower_weighted_cid_provider (flowers, weights)
	local list = {}

	assert (#flowers == #weights)
	for i, flower in ipairs (flowers) do
		local name = "mcl_flowers:" .. flower
		local cid = core.get_content_id (name)
		table.insert (list, {
			weight = weights[i],
			cid = cid,
			param2 = 0,
		})
	end

	return W (list)
end

local function build_flower_cid_provider (flower)
	local name = "mcl_flowers:" .. flower
	local param2 = 0
	if name == "mcl_flowers:double_grass"
		or name == "mcl_flowers:tallgrass" then
		param2 = "grass_palette_index"
	end
	local cid = core.get_content_id (name)
	return function (_, _, _, _)
		return cid, param2
	end
end

local function require_air (x, y, z, rng)
	if is_air (x, y, z) then
		return { x, y, z, }
	end
	return nil
end

local function register_flower_feature (name, parms)
	local block_content = parms.block_content
	local patch_cfg = parms.patch_cfg
	local name = "mcl_flowers:" .. name

	mcl_levelgen.register_configured_feature (name .. "_block", {
		feature = "mcl_levelgen:simple_block",
		content = block_content,
	})
	mcl_levelgen.register_configured_feature (name, table.merge ({
		feature = "mcl_levelgen:random_patch",
		placed_feature = {
			configured_feature = name .. "_block",
			placement_modifiers = {
				require_air,
			},
		},
	}, patch_cfg))
end

local pink_petals_cids = {
	core.get_content_id ("mcl_flowers:pink_petals_1"),
	core.get_content_id ("mcl_flowers:pink_petals_2"),
	core.get_content_id ("mcl_flowers:pink_petals_3"),
	core.get_content_id ("mcl_flowers:pink_petals_4"),
}

local function provide_pink_petals (x, y, z, rng)
	local cid = pink_petals_cids[1 + rng:next_within (4)]
	return cid, rng:next_within (4)
end

register_flower_feature ("flower_default", {
	block_content = build_flower_weighted_cid_provider ({
		"poppy", "dandelion",
	}, { 2, 1, }),
	patch_cfg = {
		tries = 64,
		xz_spread = 7,
		y_spread = 3,
	},
})

register_flower_feature ("flower_flower_forest", {
	block_content = mcl_levelgen.build_noise_content_provider ({
		noise = {
			amplitudes = { 1.0, },
			first_octave = 0,
		},
		scale = 1/48,
		seed = ull (0, 2345),
		content = build_flower_content_list ({
			"dandelion",
			"poppy",
			"allium",
			"azure_bluet",
			"tulip_red",
			"tulip_orange",
			"tulip_white",
			"tulip_pink",
			"oxeye_daisy",
			"cornflower",
			"lily_of_the_valley",
		}),
	}),
	patch_cfg = {
		tries = 96,
		xz_spread = 6,
		y_spread = 2,
	},
})

register_flower_feature ("flower_meadow", {
	block_content = mcl_levelgen.build_dual_noise_content_provider ({
		noise = {
			amplitudes = { 1.0, },
			first_octave = -3,
		},
		scale = 1.0,
		seed = ull (0, 2345),
		content = build_flower_content_list ({
			"double_grass",
			"allium",
			"poppy",
			"azure_bluet",
			"dandelion",
			"cornflower",
			"oxeye_daisy",
			"tallgrass",
		}),
		slow_noise = {
			amplitudes = { 1.0, },
			first_octave = -10,
		},
		slow_scale = 1.0,
		variety = {
			min = 1,
			max = 3,
		},
	}),
	patch_cfg = {
		tries = 96,
		xz_spread = 6,
		y_spread = 2,
	},
})

register_flower_feature ("flower_plain", {
	block_content = mcl_levelgen.build_noise_threshold_provider ({
		default_content = build_flower_content_list ({"dandelion",})[1],
		high_chance = 1/3,
		high_content = build_flower_content_list ({
			"poppy",
			"azure_bluet",
			"oxeye_daisy",
			"cornflower",
		}),
		low_content = build_flower_content_list ({
			"tulip_orange",
			"tulip_red",
			"tulip_pink",
			"tulip_white",
		}),
		noise = {
			amplitudes = { 1.0, },
			first_octave = 0,
		},
		scale = 0.005,
		seed = ull (0, 2345),
		threshold = -0.8,
	}),
	patch_cfg = {
		tries = 64,
		xz_spread = 6,
		y_spread = 2,
	},
})

register_flower_feature ("flower_swamp", {
	block_content = build_flower_cid_provider ("blue_orchid"),
	patch_cfg = {
		tries = 64,
		xz_spread = 6,
		y_spread = 2,
	},
})

register_flower_feature ("patch_lilac", {
	block_content = build_flower_cid_provider ("lilac"),
	patch_cfg = {
		tries = 96,
		xz_spread = 7,
		y_spread = 3,
	},
})

register_flower_feature ("patch_rose_bush", {
	block_content = build_flower_cid_provider ("rose_bush"),
	patch_cfg = {
		tries = 96,
		xz_spread = 7,
		y_spread = 3,
	},
})

register_flower_feature ("patch_peony", {
	block_content = build_flower_cid_provider ("peony"),
	patch_cfg = {
		tries = 96,
		xz_spread = 7,
		y_spread = 3,
	},
})

register_flower_feature ("patch_lily_of_the_valley", {
	block_content = build_flower_cid_provider ("lily_of_the_valley"),
	patch_cfg = {
		tries = 96,
		xz_spread = 7,
		y_spread = 3,
	},
})

mcl_levelgen.register_configured_feature ("mcl_flowers:forest_flowers", {
	feature = "mcl_levelgen:simple_random_selector",
	features = {
		{
			configured_feature = "mcl_flowers:patch_lilac",
			placement_modifiers = {},
		},
		{
			configured_feature = "mcl_flowers:patch_rose_bush",
			placement_modifiers = {},
		},
		{
			configured_feature = "mcl_flowers:patch_peony",
			placement_modifiers = {},
		},
		{
			configured_feature = "mcl_flowers:patch_lily_of_the_valley",
			placement_modifiers = {},
		},
	},
})

register_flower_feature ("flower_cherry", {
	block_content = provide_pink_petals,
	patch_cfg = {
		tries = 96,
		xz_spread = 6,
		y_spread = 2,
	},
})

register_flower_feature ("patch_sunflower", {
	block_content = build_flower_cid_provider ("sunflower"),
	patch_cfg = {
		tries = 96,
		xz_spread = 6,
		y_spread = 2,
	},
})

mcl_levelgen.register_placed_feature ("mcl_flowers:flower_default", {
	configured_feature = "mcl_flowers:flower_default",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (32),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

local THREE = function (_) return 3 end

mcl_levelgen.register_placed_feature ("mcl_flowers:flower_flower_forest", {
	configured_feature = "mcl_flowers:flower_flower_forest",
	placement_modifiers = {
		mcl_levelgen.build_count (THREE),
		mcl_levelgen.build_rarity_filter (2),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_flowers:flower_meadow", {
	configured_feature = "mcl_flowers:flower_meadow",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_flowers:flower_plains", {
	configured_feature = "mcl_flowers:flower_plain",
	placement_modifiers = {
		mcl_levelgen.build_noise_threshold_count (-0.8, 4, 15),
		mcl_levelgen.build_rarity_filter (32),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_flowers:flower_swamp", {
	configured_feature = "mcl_flowers:flower_swamp",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (32),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_flowers:flower_warm", {
	configured_feature = "mcl_flowers:flower_default",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (16),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

local uniform_height = mcl_levelgen.uniform_height
local clamped_height = mcl_levelgen.clamped_height

mcl_levelgen.register_placed_feature ("mcl_flowers:forest_flowers", {
	configured_feature = "mcl_flowers:forest_flowers",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (7),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_count (clamped_height (uniform_height (-3, 1),
							  0, 1)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_flowers:flower_forest_flowers", {
	configured_feature = "mcl_flowers:forest_flowers",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (7),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_count (clamped_height (uniform_height (-1, 3),
							  0, 3)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_flowers:flower_cherry", {
	configured_feature = "mcl_flowers:flower_cherry",
	placement_modifiers = {
		mcl_levelgen.build_noise_threshold_count (-0.8, 10, 5),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_flowers:patch_sunflower", {
	configured_feature = "mcl_flowers:patch_sunflower",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (3),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	}
})
