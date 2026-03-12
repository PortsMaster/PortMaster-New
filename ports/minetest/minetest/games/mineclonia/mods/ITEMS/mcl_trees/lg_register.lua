if not core.global_exists ("mcl_trees") then
	mcl_trees = {}
end

local mathmax = math.max
local mathmin = math.min
local mathabs = math.abs
local floor = math.floor

local band = bit.band

local tree_placement_flags = {
	place_center_x = true,
	place_center_z = true,
}

local cid_air = core.CONTENT_AIR
local is_position_hospitable = mcl_levelgen.is_position_hospitable

local function build_hospitability_check (cid)
	return function (x, y, z, rng)
		if is_position_hospitable (cid, x, y, z) then
			return { x, y, z, }
		else
			return nil
		end
	end
end
mcl_trees.build_hospitability_check = build_hospitability_check

local get_block = mcl_levelgen.get_block

local function build_node_check (cid1, cid2, xoff, yoff, zoff)
	return function (x, y, z, rng)
		local cid, _ = get_block (x, y + yoff, z)
		if cid == cid1 or (cid2 and cid == cid2) then
			return { x, y, z, }
		else
			return { }
		end
	end
end

local set_block = mcl_levelgen.set_block
local run_minp = mcl_levelgen.placement_run_minp
local run_maxp = mcl_levelgen.placement_run_maxp
local is_water_or_air = mcl_levelgen.is_water_or_air

local function test_clearance (x, y, z, min, max, rng)
	local trunk_height = min + rng:next_within (max - min + 1)
	for y = y, y + trunk_height - 1 do
		if y > run_maxp.y + 32 then
			return false
		end
		if not is_water_or_air (x, y, z) then
			return false
		end
	end
	return true
end

local biomecolor_nodes = {}
local registered_biomes = mcl_levelgen.registered_biomes
local index_biome = mcl_levelgen.index_biome

local function get_biome_color (x, y, z)
	local biome = index_biome (x, y, z)
	local def = registered_biomes[biome]
	return def.leaves_palette_index
end
mcl_trees.get_biome_color = get_biome_color

local function apply_biome_coloration (aabb)
	local x1, y1, z1 = aabb[1], aabb[2], aabb[3]
	local x2, y2, z2 = aabb[4], aabb[5], aabb[6]

	x1 = mathmax (run_minp.x - 16, x1)
	x2 = mathmin (run_maxp.x + 16, x2)
	z1 = mathmax (run_minp.z - 16, z1)
	z2 = mathmin (run_maxp.z + 16, z2)
	y1 = mathmax (run_minp.y - 32, y1)
	y2 = mathmin (run_maxp.y + 32, y2)

	for x = x1, x2 do
		for y = y1, y2 do
			for z = z1, z2 do
				local cid, distance = get_block (x, y, z)
				if biomecolor_nodes[cid] then
					local idx = get_biome_color (x, y, z)
					set_block (x, y, z, cid, band (distance, -32) + idx)
				end
			end
		end
	end
end

mcl_trees.apply_biome_coloration = apply_biome_coloration

local function register_tree_feature (name, schematic_set, after_place, details,
				      sapling_type, trunk_offset,
				      min_trunk_clearance, max_trunk_clearance)
	if not trunk_offset then
		trunk_offset = 0
	end
	local schematics = {}
	for i, schematic in ipairs (schematic_set) do
		local name = "mcl_trees:" .. name .. "_" .. i
		table.insert (schematics, name)

		if not mcl_levelgen.is_levelgen_environment then
			mcl_levelgen.register_portable_schematic (name, schematic, true)
		end
	end
	local min_trunk_clearance = min_trunk_clearance or 8
	local max_trunk_clearance = max_trunk_clearance or 8

	if mcl_levelgen.is_levelgen_environment then
		local n = #schematics
		mcl_levelgen.register_feature ("mcl_trees:" .. name, table.merge ({
			place = function (self, x, y, z, cfg, rng)
				if y < run_minp.y or y > run_maxp.y then
					rng:consume (1)
					rng:next_within (n)
					rng:consume (after_place and 2 or 1)
					return false
				end

				if not test_clearance (x, y, z, min_trunk_clearance,
						       max_trunk_clearance, rng) then
					rng:next_within (n)
					rng:consume (after_place and 2 or 1)
					return false
				end

				local i = 1 + rng:next_within (n)
				local schematic = schematics[i]
				local aabb
					= mcl_levelgen.place_schematic (x, y + trunk_offset,
									z, schematic,
									"random", false,
									tree_placement_flags,
									rng)
				if after_place then
					after_place (x, y, z, cfg, rng)
				end
				apply_biome_coloration (aabb)
				return true
			end,
			tree_type = name,
		}))
		mcl_levelgen.register_configured_feature ("mcl_trees:" .. name, table.merge ({
			feature = "mcl_trees:" .. name,
		}, details))

		local sapling_type = core.get_content_id (sapling_type)
		mcl_levelgen.register_placed_feature ("mcl_trees:" .. name, {
			configured_feature = "mcl_trees:" .. name,
			placement_modifiers = {
				build_hospitability_check (sapling_type),
			},
		})
	end
end

------------------------------------------------------------------------
-- Level generator feature registration.
------------------------------------------------------------------------

local W = mcl_levelgen.build_weighted_list
local E = mcl_levelgen.build_environment_scan
local modpath = core.get_modpath ("mcl_core")

local spruce = {
	modpath .. "/schematics/mcl_core_spruce_1.mts",
	modpath .. "/schematics/mcl_core_spruce_2.mts",
	modpath .. "/schematics/mcl_core_spruce_3.mts",
	modpath .. "/schematics/mcl_core_spruce_4.mts",
	modpath .. "/schematics/mcl_core_spruce_5.mts",
	modpath .. "/schematics/mcl_core_spruce_tall.mts",
	modpath .. "/schematics/mcl_core_spruce_lollipop.mts",
}

local pine = {
	modpath .. "/schematics/mcl_core_spruce_matchstick.mts",
}

local mega_spruce = {
	modpath .. "/schematics/mcl_core_spruce_huge_1.mts",
	modpath .. "/schematics/mcl_core_spruce_huge_2.mts",
	modpath .. "/schematics/mcl_core_spruce_huge_3.mts",
	modpath .. "/schematics/mcl_core_spruce_huge_4.mts",
}

local mega_pine = {
	modpath .. "/schematics/mcl_core_spruce_huge_up_1.mts",
	modpath .. "/schematics/mcl_core_spruce_huge_up_2.mts",
	modpath .. "/schematics/mcl_core_spruce_huge_up_3.mts",
}

register_tree_feature ("spruce", spruce, nil, nil, "mcl_trees:sapling_spruce",
		       0, 6, 10)
register_tree_feature ("pine", pine, nil, nil, "mcl_trees:sapling_spruce",
		       0, 10, 10)

local get_content_id
if mcl_levelgen.is_levelgen_environment then
	get_content_id = core.get_content_id
else
	-- CIDs are unavailable when this mod is loaded, but they're
	-- only referenced from the level generator environment.
	get_content_id = function ()
		return core.CONTENT_IGNORE
	end
end

local ull = mcl_levelgen.ull
local podzol_rng = mcl_levelgen.jvm_random (ull (0, 0), ull (0, 0))
local is_cid_dirt = mcl_levelgen.is_cid_dirt
local cid_podzol = get_content_id ("mcl_core:podzol")

local function podzolize (x, y, z)
	local y = y - 1
	for dx = -2, 2 do
		for dz = -2, 2 do
			if mathabs (dx) ~= 2 or mathabs (dz) ~= 2 then
				local cid, _ = get_block (x + dx, y, z + dz)
				if is_cid_dirt[cid] then
					set_block (x + dx, y, z + dz, cid_podzol, 0)
				end
			end
		end
	end
end

local function place_podzol (x, y, z, cfg, rng)
	podzol_rng:reseed (rng:next_long ())

	podzolize (x + 2, y, z + 2)
	podzolize (x - 2, y, z - 2)
	podzolize (x + 2, y, z - 2)
	podzolize (x - 2, y, z + 2)

	for i = 0, 5 do
		local n = podzol_rng:next_within (64)
		local k = n % 8
		local g = floor (n / 8)
		if x == 0 or k == 7 or g == 0 or g == 7 then
			podzolize (x + -3 + k, y, z + -3 + g)
		end
	end
end

register_tree_feature ("mega_spruce", mega_spruce, place_podzol, nil,
		       "mcl_trees:sapling_spruce",
		       -1, 20, 20)
register_tree_feature ("mega_pine", mega_pine, place_podzol, nil,
		       "mcl_trees:sapling_spruce", -1, 20, 20)

local classic_oak = {
	modpath .. "/schematics/mcl_core_oak_v6.mts",
	modpath .. "/schematics/mcl_core_oak_classic.mts",
}

local fancy_oak = {
	modpath .. "/schematics/mcl_core_oak_balloon.mts",
	modpath .. "/schematics/mcl_core_oak_large_1.mts",
	modpath .. "/schematics/mcl_core_oak_large_2.mts",
	modpath .. "/schematics/mcl_core_oak_large_3.mts",
	modpath .. "/schematics/mcl_core_oak_large_4.mts",
}

local swamp_oak = {
	modpath .. "/schematics/mcl_core_oak_swamp.mts",
}

register_tree_feature ("oak", classic_oak, nil, nil, "mcl_trees:sapling_oak")
register_tree_feature ("fancy_oak", fancy_oak, nil, nil, "mcl_trees:sapling_oak")
register_tree_feature ("swamp_oak", swamp_oak, nil, nil, "mcl_trees:sapling_oak")

local get_block = mcl_levelgen.get_block
local set_block = mcl_levelgen.set_block
local fix_lighting = mcl_levelgen.fix_lighting

local cid_bee_nest = core.get_content_id ("mcl_beehives:bee_nest")

local dirs = {
	{1, 0,},
	{0, 1,},
	{-1, 0,},
	{0, -1,},
}

local beehive_param2 = {
	3, 0, 1, 2,
}

local function place_beehive (x, y, z, cfg, rng)
	local leaf_cid = cfg.leaf_cid
	if rng:next_float () >= cfg.beehive_probability then
		return
	end
	local dir = 1 + rng:next_within (4)
	local xoff, zoff = dirs[dir][1], dirs[dir][2]
	local x = x + xoff
	local z = z + zoff
	for i = 2, 8 do
		local cid, _ = get_block (x, y + i, z)
		if cid == leaf_cid then
			set_block (x, y + i - 1, z, cid_bee_nest,
				   beehive_param2[dir])
			fix_lighting (x, y + i, z, x, y + i, z)
			break
		end
	end
end

register_tree_feature ("oak_with_beehive_005", classic_oak, place_beehive, {
	leaf_cid = get_content_id ("mcl_trees:leaves_oak"),
	beehive_probability = 0.05,
}, "mcl_trees:sapling_oak")

register_tree_feature ("fancy_oak_with_beehive_005", fancy_oak, place_beehive, {
	leaf_cid = get_content_id ("mcl_trees:leaves_oak"),
	beehive_probability = 0.05,
}, "mcl_trees:sapling_oak")

register_tree_feature ("oak_with_beehive_002", classic_oak, place_beehive, {
	leaf_cid = get_content_id ("mcl_trees:leaves_oak"),
	beehive_probability = 0.02,
}, "mcl_trees:sapling_oak")

register_tree_feature ("fancy_oak_with_beehive_002", fancy_oak, place_beehive, {
	leaf_cid = get_content_id ("mcl_trees:leaves_oak"),
	beehive_probability = 0.02,
}, "mcl_trees:sapling_oak")

register_tree_feature ("oak_with_beehive_0002", classic_oak, place_beehive, {
	leaf_cid = get_content_id ("mcl_trees:leaves_oak"),
	beehive_probability = 0.002,
}, "mcl_trees:sapling_oak")

register_tree_feature ("fancy_oak_with_beehive_0002", fancy_oak, place_beehive, {
	leaf_cid = get_content_id ("mcl_trees:leaves_oak"),
	beehive_probability = 0.002,
}, "mcl_trees:sapling_oak")

register_tree_feature ("fancy_oak_with_beehive", fancy_oak, place_beehive, {
	leaf_cid = get_content_id ("mcl_trees:leaves_oak"),
	beehive_probability = 1.0,
}, "mcl_trees:sapling_oak")

local birch = {
	modpath .. "/schematics/mcl_core_birch.mts",
}

local super_birch = {
	modpath .. "/schematics/mcl_core_birch_tall.mts",
}

register_tree_feature ("birch", birch, nil, nil, "mcl_trees:sapling_birch")
register_tree_feature ("super_birch", super_birch, nil, nil, "mcl_trees:sapling_birch")

register_tree_feature ("birch_with_beehive_005", birch, place_beehive, {
	leaf_cid = get_content_id ("mcl_trees:leaves_birch"),
	beehive_probability = 0.05,
}, "mcl_trees:sapling_birch")

register_tree_feature ("birch_with_beehive_002", birch, place_beehive, {
	leaf_cid = get_content_id ("mcl_trees:leaves_birch"),
	beehive_probability = 0.02,
}, "mcl_trees:sapling_birch")

register_tree_feature ("birch_with_beehive_0002", birch, place_beehive, {
	leaf_cid = get_content_id ("mcl_trees:leaves_birch"),
	beehive_probability = 0.002,
}, "mcl_trees:sapling_birch")

register_tree_feature ("super_birch_with_beehive_005", super_birch, place_beehive, {
	leaf_cid = get_content_id ("mcl_trees:leaves_birch"),
	beehive_probability = 0.05,
}, "mcl_trees:sapling_birch")

register_tree_feature ("super_birch_with_beehive_002", super_birch, place_beehive, {
	leaf_cid = get_content_id ("mcl_trees:leaves_birch"),
	beehive_probability = 0.02,
}, "mcl_trees:sapling_birch")

register_tree_feature ("super_birch_with_beehive_0002", super_birch, place_beehive, {
	leaf_cid = get_content_id ("mcl_trees:leaves_birch"),
	beehive_probability = 0.002,
}, "mcl_trees:sapling_birch")

register_tree_feature ("super_birch_with_beehive", super_birch, place_beehive, {
	leaf_cid = get_content_id ("mcl_trees:leaves_birch"),
	beehive_probability = 1.0,
}, "mcl_trees:sapling_birch")

local jungle = {
	modpath .. "/schematics/mcl_core_jungle_tree.mts",
	modpath .. "/schematics/mcl_core_jungle_tree_2.mts",
	modpath .. "/schematics/mcl_core_jungle_tree_3.mts",
	modpath .. "/schematics/mcl_core_jungle_tree_4.mts",
}

register_tree_feature ("jungle", jungle, nil, nil, "mcl_trees:sapling_jungle",
		       0, 12, 12)

local mega_jungle = {
	modpath .. "/schematics/mcl_core_jungle_tree_huge_1.mts",
	modpath .. "/schematics/mcl_core_jungle_tree_huge_2.mts",
	modpath .. "/schematics/mcl_core_jungle_tree_huge_3.mts",
	modpath .. "/schematics/mcl_core_jungle_tree_huge_4.mts",
}

register_tree_feature ("mega_jungle", mega_jungle, nil, nil,
		       "mcl_trees:sapling_jungle", -1, 31, 31)

local jungle_bush = {
	modpath .. "/schematics/mcl_core_jungle_bush_oak_leaves.mts",
	modpath .. "/schematics/mcl_core_jungle_bush_oak_leaves_2.mts",
}

register_tree_feature ("jungle_bush", jungle_bush, nil, nil, "mcl_trees:sapling_oak",
		       0, 2, 2)

local acacia = {
	modpath .. "/schematics/mcl_core_acacia_1.mts",
	modpath .. "/schematics/mcl_core_acacia_2.mts",
	modpath .. "/schematics/mcl_core_acacia_3.mts",
	modpath .. "/schematics/mcl_core_acacia_4.mts",
	modpath .. "/schematics/mcl_core_acacia_5.mts",
	modpath .. "/schematics/mcl_core_acacia_6.mts",
	modpath .. "/schematics/mcl_core_acacia_7.mts",
}

register_tree_feature ("acacia", acacia, nil, nil, "mcl_trees:sapling_acacia",
		       0, 8, 8)

local cherry_blossom = core.get_modpath ("mcl_cherry_blossom")

local cherry = {
	cherry_blossom .. "/schematics/mcl_cherry_blossom_tree_1.mts",
	cherry_blossom .. "/schematics/mcl_cherry_blossom_tree_2.mts",
	cherry_blossom .. "/schematics/mcl_cherry_blossom_tree_3.mts",
}

local cherry_with_beehive = {
	cherry_blossom .. "/schematics/mcl_cherry_blossom_tree_beehive_1.mts",
	cherry_blossom .. "/schematics/mcl_cherry_blossom_tree_beehive_2.mts",
	cherry_blossom .. "/schematics/mcl_cherry_blossom_tree_beehive_3.mts",
}

register_tree_feature ("cherry", cherry, nil, nil,
		       "mcl_trees:sapling_cherry_blossom", 0, 7, 9)
register_tree_feature ("cherry_with_beehive", cherry_with_beehive, nil, nil,
		       "mcl_trees:sapling_cherry_blossom", 0, 7, 9)

local dark_oak = {
	modpath .. "/schematics/mcl_core_dark_oak.mts",
}

local cid_dirt = get_content_id ("mcl_core:dirt")

local function fix_hanging_trunks (x, y, z, cfg, rng)
	local trunk_cid = cfg.cid_trunk
	local modified = false
	for dx = -4, 4 do
		for dz = -4, 4 do
			local cid, _ = get_block (x + dx, y, z + dz)
			if cid == trunk_cid
				and is_water_or_air (x + dx, y - 1, z + dz) then
				set_block (x + dx, y - 1, z + dz, cid_dirt, true)
				modified = true
			end
		end
	end
	if modified then
		fix_lighting (x - 4, y - 1, z - 4, x + 4, y, z + 4)
	end
end

register_tree_feature ("dark_oak", dark_oak, fix_hanging_trunks, {
	cid_trunk = get_content_id ("mcl_trees:tree_dark_oak"),
}, "mcl_trees:sapling_dark_oak", 0, 6, 9)

if mcl_levelgen.is_levelgen_environment then

for name, def in pairs (core.registered_nodes) do
	if def.groups.leaves and def.groups.biomecolor
		and def.groups.leaves > 0
		and def.groups.biomecolor > 0 then
		local cid = core.get_content_id (name)
		biomecolor_nodes[cid] = true
	end
end

local cid_spruce_sapling
	= core.get_content_id ("mcl_trees:sapling_spruce")
local cid_oak_sapling
	= core.get_content_id ("mcl_trees:sapling_oak")
local cid_birch_sapling
	= core.get_content_id ("mcl_trees:sapling_birch")

mcl_levelgen.register_placed_feature ("mcl_trees:trees_snowy", {
	configured_feature = "mcl_trees:spruce",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 0,
			},
			{
				weight = 1,
				data = 1,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
		build_hospitability_check (cid_spruce_sapling),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:trees_plains", {
	feature = "mcl_levelgen:random_selector",
	default = {
		configured_feature = "mcl_trees:oak_with_beehive_005",
		placement_modifiers = {},
	},
	features = {
		{
			feature = {
				configured_feature = "mcl_trees:fancy_oak_with_beehive_005",
				placement_modifiers = {},
			},
			chance = 1/3,
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_plains", {
	configured_feature = "mcl_trees:trees_plains",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 19,
				data = 0,
			},
			{
				weight = 1,
				data = 1,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
		build_hospitability_check (cid_oak_sapling),
	}
})

mcl_levelgen.register_configured_feature ("mcl_trees:trees_birch_and_oak", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:oak_with_beehive_0002",
	features = {
		{
			chance = 0.2,
			feature = "mcl_trees:birch_with_beehive_0002",
		},
		{
			chance = 0.1,
			feature = "mcl_trees:fancy_oak_with_beehive_0002",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_birch_and_oak", {
	configured_feature = "mcl_trees:trees_birch_and_oak",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 10,
			},
			{
				weight = 1,
				data = 11,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:trees_jungle", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:jungle",
	features = {
		{
			chance = 0.1,
			feature = "mcl_trees:fancy_oak",
		},
		{
			chance = 0.5,
			feature = "mcl_trees:jungle_bush",
		},
		{
			chance = 1/3,
			feature = "mcl_trees:mega_jungle",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_jungle", {
	configured_feature = "mcl_trees:trees_jungle",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			-- The correct figures would be 50 and 51,
			-- but our schematics are too tall and produce
			-- excessively dense canopies.
			{
				weight = 9,
				data = 50,
			},
			{
				weight = 1,
				data = 51,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_birch", {
	configured_feature = "mcl_trees:birch_with_beehive_0002",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 10,
			},
			{
				weight = 1,
				data = 11,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
		build_hospitability_check (cid_birch_sapling),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:trees_savanna", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:oak",
	features = {
		{
			chance = 0.8,
			feature = "mcl_trees:acacia",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_savanna", {
	configured_feature = "mcl_trees:trees_savanna",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 1,
			},
			{
				weight = 1,
				data = 2,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:trees_flower_forest", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:oak_with_beehive_002",
	features = {
		{
			chance = 0.2,
			feature = "mcl_trees:birch_with_beehive_002",
		},
		{
			chance = 0.1,
			feature = "mcl_trees:fancy_oak_with_beehive_002",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_flower_forest", {
	configured_feature = "mcl_trees:trees_flower_forest",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 6,
			},
			{
				weight = 1,
				data = 7,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_mesa", {
	configured_feature = "mcl_trees:oak",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 5,
			},
			{
				weight = 1,
				data = 6,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
		build_hospitability_check (cid_oak_sapling),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:trees_taiga", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:spruce",
	features = {
		{
			chance = 1/3,
			feature = "mcl_trees:pine",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_taiga", {
	configured_feature = "mcl_trees:trees_taiga",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 10,
			},
			{
				weight = 1,
				data = 11,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:trees_old_growth_pine_taiga", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:spruce",
	features = {
		{
			chance = 1/39,
			feature = "mcl_trees:mega_spruce",
		},
		{
			chance = 4/13,
			feature = "mcl_trees:mega_pine",
		},
		{
			chance = 1/3,
			feature = "mcl_trees:pine",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_old_growth_pine_taiga", {
	configured_feature = "mcl_trees:trees_old_growth_pine_taiga",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 10,
			},
			{
				weight = 1,
				data = 11,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:trees_old_growth_spruce_taiga", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:spruce",
	features = {
		{
			chance = 1/3,
			feature = "mcl_trees:mega_spruce",
		},
		{
			chance = 1/3,
			feature = "mcl_trees:pine",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_old_growth_spruce_taiga", {
	configured_feature = "mcl_trees:trees_old_growth_spruce_taiga",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 10,
			},
			{
				weight = 1,
				data = 11,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:birch_tall", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:birch_with_beehive_0002",
	features = {
		{
			chance = 0.5,
			feature = "mcl_trees:super_birch_with_beehive_0002",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:birch_tall", {
	configured_feature = "mcl_trees:birch_tall",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 10,
			},
			{
				weight = 1,
				data = 11,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:trees_sparse_jungle", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:jungle",
	features = {
		{
			chance = 0.1,
			feature = "mcl_trees:fancy_oak",
		},
		{
			chance = 0.5,
			feature = "mcl_trees:jungle_bush",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_sparse_jungle", {
	configured_feature = "mcl_trees:trees_sparse_jungle",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 2,
			},
			{
				weight = 1,
				data = 3,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

local cid_snow = get_content_id ("mcl_core:snowblock")
local cid_powder_snow = get_content_id ("mcl_powder_snow:powder_snow")

mcl_levelgen.register_placed_feature ("mcl_trees:spruce_on_snow", {
	configured_feature = "mcl_trees:spruce",
	placement_modifiers = {
		E ({
			direction = 1,
			max_steps = 8,
			target_condition = function (x, y, z)
				return (get_block (x, y, z)) ~= cid_powder_snow
			end,
		}),
		build_node_check (cid_snow, cid_powder_snow,
				  0, -1, 0),
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:pine_on_snow", {
	configured_feature = "mcl_trees:pine",
	placement_modifiers = {
		E ({
			direction = 1,
			max_steps = 8,
			target_condition = function (x, y, z)
				return (get_block (x, y, z)) ~= cid_powder_snow
			end,
		}),
		build_node_check (cid_snow, cid_powder_snow,
				  0, -1, 0),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:trees_grove", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:spruce_on_snow",
	features = {
		{
			chance = 1/3,
			feature = "mcl_trees:pine_on_snow",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_grove", {
	configured_feature = "mcl_trees:trees_grove",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 10,
			},
			{
				weight = 1,
				data = 11,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_swamp", {
	configured_feature = "mcl_trees:swamp_oak",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 2,
			},
			{
				weight = 1,
				data = 3,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (2),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
		build_hospitability_check (cid_oak_sapling),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:trees_windswept_hills", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:oak",
	features = {
		{
			chance = 2/3,
			feature = "mcl_trees:spruce",
		},
		{
			chance = 0.1,
			feature = "mcl_trees:fancy_oak",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_windswept_hills", {
	configured_feature = "mcl_trees:trees_windswept_hills",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 0,
			},
			{
				weight = 1,
				data = 1,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_windswept_forest", {
	configured_feature = "mcl_trees:trees_windswept_hills",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 3,
			},
			{
				weight = 1,
				data = 4,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_windswept_savanna", {
	configured_feature = "mcl_trees:trees_savanna",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 2,
			},
			{
				weight = 1,
				data = 3,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:trees_water", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:oak",
	features = {
		{
			chance = 0.1,
			feature = "mcl_trees:fancy_oak",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_water", {
	configured_feature = "mcl_trees:trees_water",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 0,
			},
			{
				weight = 1,
				data = 1,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:trees_meadow", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:super_birch_with_beehive",
	features = {
		{
			chance = 0.5,
			feature = "mcl_trees:fancy_oak_with_beehive",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_meadow", {
	configured_feature = "mcl_trees:trees_meadow",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (100),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:cherry_with_beehive_005", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:cherry",
	features = {
		{
			chance = 0.05,
			feature = "mcl_trees:cherry_with_beehive",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:trees_cherry", {
	configured_feature = "mcl_trees:cherry_with_beehive_005",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 10,
			},
			{
				weight = 1,
				data = 11,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:dark_forest_vegetation", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_trees:oak",
	features = {
		{
			chance = 1/40,
			feature = {
				configured_feature = "mcl_mushrooms:huge_brown_mushroom",
				placement_modifiers = {},
			},
		},
		{
			chance = 1/20,
			feature = {
				configured_feature = "mcl_mushrooms:huge_red_mushroom",
				placement_modifiers = {},
			},
		},
		{
			chance = 2/3,
			feature = "mcl_trees:dark_oak",
		},
		{
			chance = 1/5,
			feature = "mcl_trees:birch",
		},
		{
			chance = 1/10,
			feature = "mcl_trees:fancy_oak",
		},
	},
})

local SIXTEEN = function (_) return 16 end

mcl_levelgen.register_placed_feature ("mcl_trees:dark_forest_vegetation", {
	configured_feature = "mcl_trees:dark_forest_vegetation",
	placement_modifiers = {
		mcl_levelgen.build_count (SIXTEEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_trees:bamboo_vegetation", {
	feature = "mcl_levelgen:random_selector",
	default = {
		configured_feature = "mcl_levelgen:patch_grass_jungle",
		placement_modifiers = {},
	},
	features = {
		{
			chance = 1/20,
			feature = "mcl_trees:fancy_oak",
		},
		{
			chance = 3/20,
			feature = "mcl_trees:jungle_bush",
		},
		{
			chance = 7/10,
			feature = "mcl_trees:mega_jungle",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_trees:bamboo_vegetation", {
	configured_feature = "mcl_trees:bamboo_vegetation",
	placement_modifiers = {
		mcl_levelgen.build_count (W ({
			{
				weight = 9,
				data = 30,
			},
			{
				weight = 1,
				data = 31,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (0),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Procedural generation of trees.  This configured feature is only
-- utilized by mangroves.
--
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/TreeFeature.html
------------------------------------------------------------------------

local huge = math.huge

-- local procedural_tree_cfg = {
-- 	trunk_content = nil,
-- 	trunk_placer = nil,
-- 	foliage_content = nil,
-- 	root_placer = nil,
-- 	dirt_content = nil,
-- 	minimum_size = nil,
-- 	decorators = nil,
-- 	ignore_vines = false,
-- 	force_dirt = false,
-- }

-- local feature_size_iface = {
-- 	min_size = nil,
-- 	max_size = nil,
-- 	min_clipped_height = nil,
-- 	radius_at_height = nil,
-- }

-- local trunk_placer_iface = {
-- 	generate_trunk = nil,
-- 	can_replace = nil,
-- 	get_height = nil,
-- }

-- local foliage_placer_iface = {
-- 	offset = nil,
-- 	radius = nil,
-- 	generate_foliage = nil,
-- 	get_random_height = nil,
-- 	get_foliage_radius = nil,
-- }

-- local root_placer_iface = {
-- 	find_trunk_pos = nil,
-- 	generate_roots = nil,
-- }

-- Tree decorators are simply functions.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/treedecorator/TreeDecorator.html

local cid_vine = core.get_content_id ("mcl_core:vine")
local replaceable_by_trees = {
	"air",
	"group:glow_lichen",
	"group:leaves",
	"group:seagrass",
	"group:water",
	"mcl_core:deadbush",
	"mcl_core:vine",
	"mcl_crimson:crimson_roots",
	"mcl_crimson:nether_sprouts",
	"mcl_crimson:warped_roots",
	"mcl_flowers:double_fern",
	"mcl_flowers:double_grass",
	"mcl_flowers:double_grass_top",
	"mcl_flowers:lilac",
	"mcl_flowers:peony",
	"mcl_flowers:rose_bush",
	"mcl_flowers:sunflower",
	"mcl_flowers:tallgrass",
	"mcl_lush_caves:hanging_roots",
	-- TODO:
	-- "mcl_flowers:pitcher_plant",
}
mcl_trees.replaceable_by_trees = replaceable_by_trees

local is_cid_replaceable_by_trees = {}
local is_cid_wood = {}

for _, cid in ipairs (mcl_levelgen.construct_cid_list (replaceable_by_trees)) do
	is_cid_replaceable_by_trees[cid] = true
end

for _, cid in ipairs (mcl_levelgen.construct_cid_list ({"group:wood"})) do
	is_cid_wood[cid] = true
end

local function is_vine (x, y, z)
	local cid, _ = get_block (x, y, z)
	return cid == cid_vine
end

local function gauge_headroom (tree_height, trunk_x, trunk_y, trunk_z, cfg)
	local ignore_vines = cfg.ignore_vines
	local size = cfg.minimum_size
	local trunk_placer = cfg.trunk_placer

	for dy = 0, tree_height + 1 do
		local r = size:radius_at_height (tree_height, dy)

		for dx = -r, r do
			for dz = -r, r do
				local x = trunk_x + dx
				local y = trunk_y + dy
				local z = trunk_z + dz

				if not trunk_placer:can_replace (x, y, z)
					or (not ignore_vines and is_vine (x, y, z)) then
					return dy - 2 -- One additional node for foliage.
				end
			end
		end
	end
	return tree_height
end

local function procedural_tree_place (x, y, z, cfg, rng)
	local trunk_placer = cfg.trunk_placer
	local foliage_placer = cfg.foliage_placer
	local tree_height
		= trunk_placer:get_height (rng)
	local foliage_height
		= foliage_placer:get_random_height (rng, tree_height, cfg)
	local trunk_height = tree_height - foliage_height
	local foliage_radius
		= cfg.foliage_placer:get_foliage_radius (rng, trunk_height)
	local trunk_x, trunk_y, trunk_z = x, y, z
	local root_placer = cfg.root_placer
	if root_placer then
		trunk_x, trunk_y, trunk_z
			= root_placer:find_trunk_pos (x, y, z, rng)
	end
	local min_y = mathmin (y, trunk_y)
	local max_y = mathmax (y, trunk_y)

	local level_min = mcl_levelgen.placement_level_min
	local level_max = level_min + mcl_levelgen.placement_level_height - 1
	if min_y <= level_min or max_y > level_max then
		return false
	end

	local min_clipped = cfg.minimum_size.min_clipped_height
	local free_height = gauge_headroom (tree_height, trunk_x, trunk_y,
					    trunk_z, cfg)

	if free_height >= tree_height
		or (min_clipped and free_height >= min_clipped) then
		if root_placer
			and not root_placer:generate_roots (x, y, z, trunk_x, trunk_y, trunk_z,
							    cfg, rng) then
			return false
		end

		local generated_logs = {}
		trunk_placer:generate_trunk (trunk_x, trunk_y, trunk_z,
					     free_height, cfg, rng,
					     generated_logs)
		for _, logdata in ipairs (generated_logs) do
			foliage_placer:generate_foliage (logdata, free_height,
							 foliage_height,
							 foliage_radius, cfg, rng)
		end
		return true
	end
	return false
end

local generated_blocks = {}
local tree_minp = vector.zero ()
local tree_maxp = vector.zero ()
local band = bit.band

local function longhash (x, y, z)
	return (32768 + x) * 65536 * 65536 + (32768 + y) * 65536
		+ (32768 + z)
end

local function unhash (pos)
	return floor (pos / (65536 * 65536)) - 32768,
		band (floor (pos / 65536), 0xffff) - 32768,
		pos % 65536 - 32768
end

local procedural_tree_rng = mcl_levelgen.xoroshiro (ull (0), ull (0))

local function tree_place (_, x, y, z, cfg, rng)
	procedural_tree_rng:reseed (rng:next_long ())
	if y < run_minp.y or y > run_maxp.y then
		return false
	end

	local rng = procedural_tree_rng
	-- Initialize the environment for procedural tree generation.
	tree_minp.x = huge
	tree_minp.y = huge
	tree_minp.z = huge
	tree_maxp.x = -huge
	tree_maxp.y = -huge
	tree_maxp.z = -huge
	generated_blocks = {}

	if not procedural_tree_place (x, y, z, cfg, rng) then
		return false
	end

	local decorators = cfg.decorators
	for _, decorator in ipairs (decorators) do
		decorator (rng, generated_blocks)
	end
	return true
end

mcl_levelgen.register_feature ("mcl_trees:tree", {
	place = tree_place,
})

------------------------------------------------------------------------
-- Tree placement environment.
------------------------------------------------------------------------

function mcl_trees.place_root_block (x, y, z, cid, param2)
	local hash = longhash (x, y, z)
	generated_blocks[hash] = "root"
	set_block (x, y, z, cid, param2)
	tree_minp.x = mathmin (tree_minp.x, x)
	tree_minp.y = mathmin (tree_minp.y, y)
	tree_minp.z = mathmin (tree_minp.z, z)
	tree_maxp.x = mathmax (tree_maxp.x, x)
	tree_maxp.y = mathmax (tree_maxp.y, y)
	tree_maxp.z = mathmax (tree_maxp.z, z)
end

function mcl_trees.place_trunk_block (x, y, z, cid, param2)
	local hash = longhash (x, y, z)
	generated_blocks[hash] = "trunk"
	set_block (x, y, z, cid, param2)
	tree_minp.x = mathmin (tree_minp.x, x)
	tree_minp.y = mathmin (tree_minp.y, y)
	tree_minp.z = mathmin (tree_minp.z, z)
	tree_maxp.x = mathmax (tree_maxp.x, x)
	tree_maxp.y = mathmax (tree_maxp.y, y)
	tree_maxp.z = mathmax (tree_maxp.z, z)
end

function mcl_trees.place_foliage_block (x, y, z, cid, param2)
	local hash = longhash (x, y, z)
	generated_blocks[hash] = "foliage"
	set_block (x, y, z, cid, param2)
	tree_minp.x = mathmin (tree_minp.x, x)
	tree_minp.y = mathmin (tree_minp.y, y)
	tree_minp.z = mathmin (tree_minp.z, z)
	tree_maxp.x = mathmax (tree_maxp.x, x)
	tree_maxp.y = mathmax (tree_maxp.y, y)
	tree_maxp.z = mathmax (tree_maxp.z, z)
end

function mcl_trees.is_position_replaceable (x, y, z)
	local cid, param2 = get_block (x, y, z)
	return cid == cid_air or is_cid_replaceable_by_trees[cid], cid, param2
end

------------------------------------------------------------------------
-- Upwards branching trunk placement.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/trunk/UpwardsBranchingTrunkPlacer.html
------------------------------------------------------------------------

local upwards_branching_trunk_placer = {
	height_rand_b = 0,
	height_rand_a = 0,
	base_height = 0,
	extra_branch_steps = nil,
	extra_branch_length = nil,
	place_branch_per_log_probability = nil,
	can_grow_through = {},
}

local insert = table.insert

local dirs = {
	{ 1, 0, },
	{ 0, 1, },
	{ -1, 0, },
	{ 0, -1, },
}

local indexof = table.indexof
local is_position_replaceable = mcl_trees.is_position_replaceable
local place_trunk_block = mcl_trees.place_trunk_block

local function place_wood (x, y, z, content, grow_through, rng)
	local valid, cid, _ = is_position_replaceable (x, y, z)
	if valid or indexof (grow_through, cid) ~= -1 then
		local cid, param2 = content (x, y, z, rng)
		place_trunk_block (x, y, z, cid, param2)
		return true
	end
	return false
end

local function place_trunk_branch (rng, generated_logs, free_height,
				   x, y, z, dir, branch_length,
				   branch_steps, content, grow_through)
	local ymax = y + branch_length
	local length_rem = branch_length

	while length_rem < free_height and branch_steps > 0 do
		if length_rem >= 1 then
			ymax = y + length_rem
			x = x + dir[1]
			z = z + dir[2]
			insert (generated_logs, {
				x, ymax, z, 0, false,
			})
			if place_wood (x, ymax, z, content,
				       grow_through, rng) then
				ymax = ymax + 1
			end
		end
		length_rem = length_rem + 1
		branch_steps = branch_steps - 1
	end

	-- Was this branch of the mangrove trunk generated?
	if ymax - y > 1 then
		insert (generated_logs, {
			x, ymax, z, 0, false,
		})
		insert (generated_logs, {
			x, ymax - 2, z, 0, false,
		})
	end
end

function upwards_branching_trunk_placer:generate_trunk (trunk_x, trunk_y, trunk_z,
							free_height, cfg, rng,
							generated_logs)
	local branch_probability = self.place_branch_per_log_probability
	local content = cfg.trunk_content
	local grow_through = self.can_grow_through
	for dy = 0, free_height - 1 do
		local y = trunk_y + dy
		if place_wood (trunk_x, y, trunk_z,
			       content, grow_through, rng)
			and dy < free_height - 1
			and rng:next_float () < branch_probability then
			local dir = dirs[1 + rng:next_within (4)]
			local branch_length_dist = self.extra_branch_length (rng)
				- self.extra_branch_length (rng) - 1
			local branch_steps = self.extra_branch_steps (rng)
			local branch_length = mathmax (branch_length_dist, 0)
			place_trunk_branch (rng, generated_logs, free_height,
					    trunk_x, y, trunk_z,
					    dir, branch_length, branch_steps,
					    content, grow_through)
		end

		if dy == free_height - 1 then
			insert (generated_logs, {
				trunk_x, y + 1, trunk_z, 0, false,
			})
		end
	end
end

function upwards_branching_trunk_placer:can_replace (x, y, z)
	local valid, cid, _ = is_position_replaceable (x, y, z)
	return valid or is_cid_wood[cid]
end

function upwards_branching_trunk_placer:get_height (rng)
	local ra = self.height_rand_a
	local rb = self.height_rand_b
	return self.base_height
		+ rng:next_within (ra + 1)
		+ rng:next_within (rb + 1)
end

function mcl_trees.create_upwards_branching_trunk_placer (data)
	return table.merge (upwards_branching_trunk_placer, data)
end

------------------------------------------------------------------------
-- Random spread foliage placer.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/foliage/RandomSpreadFoliagePlacer.html
------------------------------------------------------------------------

local random_spread_foliage_placer = {
	radius = nil,
	leaf_placement_attempts = nil,
	foliage_height = nil,
}

local place_foliage_block = mcl_trees.place_foliage_block

function random_spread_foliage_placer:generate_one_foliage_block (x, y, z, content, rng)
	local valid, _, _ = is_position_replaceable (x, y, z)
	if not valid then
		return false
	else
		local content, param2 = content (x, y, z, rng)
		place_foliage_block (x, y, z, content, param2)
		return true
	end
end

function random_spread_foliage_placer:generate_foliage (logdata, free_height,
							foliage_height,
							foliage_radius, cfg, rng)
	-- LOGDATA is a list of 5 elements: the position of the log, a
	-- delta to apply to the radius of the foliage, and whether
	-- the trunk is thicker than a single block.  The latter two
	-- fields are not utilized by mangrove trees.

	local radius = foliage_radius
	local height = foliage_height
	local x, y, z = logdata[1], logdata[2], logdata[3]
	local content = cfg.foliage_content
	for i = 1, self.leaf_placement_attempts do
		local dx = rng:next_within (radius) - rng:next_within (radius)
		local dy = rng:next_within (height) - rng:next_within (height)
		local dz = rng:next_within (radius) - rng:next_within (radius)
		self:generate_one_foliage_block (x + dx, y + dy, z + dz, content, rng)
	end
end

function random_spread_foliage_placer:get_foliage_radius (rng, trunk_height)
	return self.radius (rng)
end

function random_spread_foliage_placer:get_random_height (rng, tree_height, cfg)
	return self.foliage_height (rng)
end

function mcl_trees.create_random_spread_foliage_placer (data)
	return table.merge (random_spread_foliage_placer, data)
end

------------------------------------------------------------------------
-- Two layers feature size.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/size/TwoLayersFeatureSize.html
------------------------------------------------------------------------

local two_layers_feature_size = {
	limit = nil,
	lower_size = nil,
	upper_size = nil,
}

function two_layers_feature_size:radius_at_height (total, dy)
	if dy < self.limit then
		return self.lower_size
	else
		return self.upper_size
	end
end

function mcl_trees.create_two_layers_feature_size (data)
	return table.merge (two_layers_feature_size, data)
end

------------------------------------------------------------------------
-- Pathfinding mangrove root placement.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/root/MangroveRootPlacer.html
------------------------------------------------------------------------

local mangrove_root_placement = {
	can_grow_through = nil,
	muddy_roots_in = nil,
	muddy_roots_content = nil,
	max_root_width = nil,
	max_root_length = nil,
	random_skew_chance = 0,

	trunk_offset_y = nil,
	root_content = nil,
	above_root_content = nil,
	above_root_placement_chance = nil,
}

local function manhattan3d (ax, ay, az, bx, by, bz)
	return mathabs (ax - bx)
		+ mathabs (az - bz)
		+ mathabs (ay - by)
end

local function root_replaceable (self, x, y, z)
	local valid, cid, _ = is_position_replaceable (x, y, z)
	if not valid then
		return indexof (self.can_grow_through, cid) ~= -1
	end
	return true
end

function mangrove_root_placement:find_trunk_pos (x, y, z, rng)
	return x, y + self.trunk_offset_y (rng), z
end

local function get_viable_offshoots (self, start_x, start_y, start_z,
				     trunk_x, trunk_y, trunk_z, dir, rng)
	local pos_below = {
		start_x,
		start_y - 1,
		start_z,
	}
	local pos_horiz = {
		start_x + dir[1],
		start_y,
		start_z + dir[2],
	}
	local pos_horiz_below = {
		start_x + dir[1],
		start_y - 1,
		start_z + dir[2],
	}

	local max_dist = self.max_root_width
	local skew = self.random_skew_chance
	local dist_to_trunk = manhattan3d (start_x, start_y, start_z,
					   trunk_x, trunk_y, trunk_z)
	-- Distance limit reached; extend vertically only.
	if dist_to_trunk > max_dist then
		return pos_below
	elseif dist_to_trunk > max_dist - 3 then
		-- If moving horizontally, do so at a greater incline.
		if rng:next_float () < skew then
			return pos_below, pos_horiz_below
		else
			return pos_below
		end
	elseif rng:next_float () < skew then
		return pos_below
	elseif rng:next_boolean () then
		return pos_horiz
	else
		return pos_below
	end

end

local function grow_offshoots (self, start_x, start_y, start_z,
			       direction, trunk_x, trunk_y,
			       trunk_z, list, rng, depth)
	if depth >= self.max_root_length
		or #list > self.max_root_length then
		return false
	end

	local v1, v2 = get_viable_offshoots (self, start_x, start_y, start_z,
					     trunk_x, trunk_y, trunk_z, direction,
					     rng)
	if root_replaceable (self, v1[1], v1[2], v1[3]) then
		-- Not yet in contact with the ground.
		insert (list, v1)
		if not grow_offshoots (self, v1[1], v1[2], v1[3], direction,
				       trunk_x, trunk_y, trunk_z, list, rng,
				       depth + 1) then
			return false
		end
	end
	if v2 and root_replaceable (self, v2[1], v2[2], v2[3]) then
		-- Not yet in contact with the ground.
		insert (list, v2)
		if not grow_offshoots (self, v2[1], v2[2], v2[3], direction,
				       trunk_x, trunk_y, trunk_z, list, rng,
				       depth + 1) then
			return false
		end
	end

	return true
end

function mangrove_root_placement:generate_roots (x, y, z, trunk_x, trunk_y, trunk_z,
						 cfg, rng)
	local roots = {}

	for y = y, trunk_y - 1 do
		if not root_replaceable (self, x, y, z) then
			return false
		end
	end

	insert (roots, {{ trunk_x, trunk_y - 1, trunk_z, }})
	for _, direction in ipairs (dirs) do
		local start_x = trunk_x + direction[1]
		local start_y = trunk_y
		local start_z = trunk_z + direction[2]
		local list = {}

		if not grow_offshoots (self, start_x, start_y, start_z,
				       direction, trunk_x, trunk_y,
				       trunk_z, list, rng, 0) then
			return false
		end
		insert (list, { start_x, start_y, start_z, })
		insert (roots, list)
	end

	local root_content = self.root_content
	for _, rootlist in ipairs (roots) do
		for _, root in ipairs (rootlist) do
			self:place_root (root[1], root[2], root[3], rng,
					 root_content)
		end
	end
	fix_lighting (tree_minp.x, tree_minp.y, tree_minp.z,
		      tree_maxp.x, tree_maxp.y, tree_maxp.z)
	return true
end

local place_root_block = mcl_trees.place_root_block
local is_air = mcl_levelgen.is_air

function mangrove_root_placement:place_root (x, y, z, rng, root_content)
	local cid, _ = get_block (x, y, z)
	local cid_new, param2
	if indexof (self.muddy_roots_in, cid) ~= -1 then
		cid_new, param2 = self.muddy_roots_content (x, y, z, rng)
	else
		cid_new, param2 = root_content (x, y, z, rng)
	end
	place_root_block (x, y, z, cid_new, param2)
	local content_above = self.above_root_content
	if content_above
		and rng:next_float () < self.above_root_placement_chance
		and is_air (x, y + 1, z) then
		local cid_above, param2 = content_above (x, y + 1, z, rng)
		place_root_block (x, y + 1, z, cid_above, param2)
	end
end

function mcl_trees.create_mangrove_root_placement (data)
	return table.merge (mangrove_root_placement, data)
end

------------------------------------------------------------------------
-- Tree decorators.
------------------------------------------------------------------------

local MAX_VINES = 4

local facedir_to_wallmounted = mcl_levelgen.facedir_to_wallmounted

local function try_decorate_with_vines (x, y, z, axis, attach_dir)
	local param2 = facedir_to_wallmounted (axis, attach_dir)
	for i = 1, MAX_VINES + 1 do
		local cid, _ = get_block (x, y, z)
		if cid ~= cid_air then
			break
		end
		set_block (x, y, z, cid_vine, param2)
		y = y - 1
	end
end

local function decorate_with_vines (rng, generated_blocks, probability)
	for block, blocktype in pairs (generated_blocks) do
		if blocktype == "foliage" then
			local x, y, z = unhash (block)

			if rng:next_float () < probability then
				try_decorate_with_vines (x - 1, y, z, "x", 1)
			end
			if rng:next_float () < probability then
				try_decorate_with_vines (x + 1, y, z, "x", -1)
			end
			if rng:next_float () < probability then
				try_decorate_with_vines (x, y, z - 1, "z", 1)
			end
			if rng:next_float () < probability then
				try_decorate_with_vines (x, y, z + 1, "z", -1)
			end
		end
	end
end

function mcl_levelgen.build_leave_vine_decoration (probability)
	return function (rng, generated_blocks)
		return decorate_with_vines (rng, generated_blocks, probability)
	end
end

local fisher_yates = mcl_levelgen.fisher_yates

local function sufficient_air_blocks (x, y, z, dir, required)
	for i = 1, required do
		if not is_air (x, y, z) then
			return false
		end
		x, y, z = x + dir[1], y + dir[2], z + dir[3]
	end
	return true
end

local function attach_to_leaves (rng, generated_blocks, cfg)
	local probability = cfg.probability
	local exclusion_radius_xz = cfg.exclusion_radius_xz
	local exclusion_radius_y = cfg.exclusion_radius_y
	local content = cfg.content
	local required_empty_blocks = cfg.required_empty_blocks
	local directions = cfg.directions

	local leaves = {}
	for block, blocktype in pairs (generated_blocks) do
		if blocktype == "foliage" then
			insert (leaves, block)
		end
	end
	fisher_yates (leaves, rng)

	local n_directions = #directions
	local excluded = {}
	for _, pos in ipairs (leaves) do
		local dir = directions[1 + rng:next_within (n_directions)]
		local x, y, z = unhash (pos)
		x = x + dir[1]
		y = y + dir[2]
		z = z + dir[3]
		local newhash = longhash (x, y, z)

		if not excluded[newhash] and rng:next_float () < probability
			and sufficient_air_blocks (x, y, z, dir, required_empty_blocks) then
			for dy = -exclusion_radius_y, exclusion_radius_y do
				for dx = -exclusion_radius_xz, exclusion_radius_xz do
					for dz = -exclusion_radius_xz, exclusion_radius_xz do
						local exclude
							= longhash (x + dx, y + dy, z + dz)
						excluded[exclude] = true
					end
				end
			end
			local cid, param2 = content (x, y, z, rng)
			set_block (x, y, z, cid, param2)
		end
	end
end

function mcl_levelgen.build_attach_to_leaves_decoration (cfg)
	return function (rng, generated_blocks)
		attach_to_leaves (rng, generated_blocks, cfg)
	end
end

local sort = table.sort

local function compare_y (a, b)
	local _, y1, _ = unhash (a)
	local _, y2, _ = unhash (b)
	return y1 < y2
end

local function gety (hash)
	local _, y, _ = unhash (hash)
	return y
end

local direction_indices = {
	1, 2, 3, 4,
}

local function decorate_with_beehive (rng, generated_blocks, probability)
	if rng:next_float () >= probability then
		return
	end

	local leaves, logs = {}, {}
	for block, blocktype in pairs (generated_blocks) do
		if blocktype == "foliage" then
			insert (leaves, block)
		elseif blocktype == "trunk" then
			insert (logs, block)
		end
	end
	sort (leaves, compare_y)
	sort (logs, compare_y)

	-- Ascertain the bottommost layer where logs and leaves
	-- contact.
	local contact
	if #leaves > 0 then
		contact = mathmax (gety (leaves[1]) - 1, gety (logs[1]) + 1)
	else
		-- Failing that, a random offset from the bottom.
		contact = mathmin (gety (logs[1]) - 1 + rng:next_within (3) + 1,
				   gety (logs[#logs]))
	end

	fisher_yates (logs, rng)
	fisher_yates (direction_indices, rng)
	for _, log in ipairs (logs) do
		local x, y, z = unhash (log)
		if y == contact then
			for _, dir in ipairs (direction_indices) do
				local direction = dirs[dir]
				local x1 = x + direction[1]
				local z1 = z + direction[2]

				if is_air (x1, y, z1) then
					set_block (x1, y, z1, cid_bee_nest,
						   beehive_param2[dir])
					fix_lighting (x1, y, z1, x1, y, z1)
					return
				end
			end
		end
	end
end

function mcl_levelgen.build_beehive_decoration (probability)
	return function (rng, generated_blocks)
		decorate_with_beehive (rng, generated_blocks, probability)
	end
end

end

