local mcl_levelgen = mcl_levelgen

local C = mcl_levelgen.build_weighted_cid_provider

------------------------------------------------------------------------
-- Nether Forest Vegetation feature.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/NetherForestVegetationFeature.html
------------------------------------------------------------------------

local run_minp = mcl_levelgen.placement_run_minp
local run_maxp = mcl_levelgen.placement_run_maxp
local ull = mcl_levelgen.ull
local crimson_rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))
local get_block = mcl_levelgen.get_block
local set_block = mcl_levelgen.set_block
local is_air = mcl_levelgen.is_air
local is_position_hospitable = mcl_levelgen.is_position_hospitable
local fix_lighting = mcl_levelgen.fix_lighting

local huge = math.huge
local mathmax = math.max
local mathmin = math.min
local mathabs = math.abs
local floor = math.floor

-- local nether_forest_vegetation_cfg = {
-- 	content = function (x, y, z, rng) ... end,
-- 	spread_width = nil,
-- 	spread_height = nil,
-- }

local cid_warped_nylium = core.get_content_id ("mcl_crimson:warped_nylium")
local cid_crimson_nylium = core.get_content_id ("mcl_crimson:crimson_nylium")

local function nether_forest_vegetation_place (_, x, y, z, cfg, rng)
	crimson_rng:reseed (rng:next_long ())
	if y < run_minp.y or y > run_maxp.y then
		return false
	else
		local cid, _ = get_block (x, y - 1, z)
		if cid ~= cid_warped_nylium and cid ~= cid_crimson_nylium then
			return false
		else
			local rng = crimson_rng
			local spread_width = cfg.spread_width
			local spread_height = cfg.spread_height
			local content = cfg.content
			local placed = 0
			for i = 1, spread_width * spread_width do
				local x = x + rng:next_within (spread_width)
					- rng:next_within (spread_width)
				local y = y + rng:next_within (spread_height)
					- rng:next_within (spread_height)
				local z = z + rng:next_within (spread_width)
					- rng:next_within (spread_width)

				if is_air (x, y, z) then
					local cid, param2 = content (x, y, z, rng)
					if is_position_hospitable (cid, x, y, z) then
						set_block (x, y, z, cid, param2)
						placed = placed + 1
					end
				end
			end
			return placed > 0
		end
	end
end

mcl_levelgen.register_feature ("mcl_crimson:nether_forest_vegetation", {
	place = nether_forest_vegetation_place,
})

local cid_crimson_roots = core.get_content_id ("mcl_crimson:crimson_roots")
local cid_warped_roots = core.get_content_id ("mcl_crimson:warped_roots")
local cid_crimson_fungus = core.get_content_id ("mcl_crimson:crimson_fungus")
local cid_warped_fungus = core.get_content_id ("mcl_crimson:warped_fungus")

mcl_levelgen.register_configured_feature ("mcl_crimson:crimson_forest_vegetation", {
	feature = "mcl_crimson:nether_forest_vegetation",
	spread_height = 4,
	spread_width = 8,
	content = C ({
		{
			weight = 87,
			cid = cid_crimson_roots,
			param2 = 0,
		},
		{
			weight = 11,
			cid = cid_crimson_fungus,
			param2 = 0,
		},
		{
			weight = 1,
			cid = cid_warped_fungus,
			param2 = 0,
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_crimson:warped_forest_vegetation", {
	feature = "mcl_crimson:nether_forest_vegetation",
	spread_height = 4,
	spread_width = 8,
	content = C ({
		{
			weight = 85,
			cid = cid_warped_roots,
			param2 = 0,
		},
		{
			weight = 1,
			cid = cid_crimson_roots,
			param2 = 0,
		},
		{
			weight = 13,
			cid = cid_warped_fungus,
			param2 = 0,
		},
		{
			weight = 1,
			cid = cid_crimson_fungus,
			param2 = 0,
		},
	}),
})

local cid_nether_sprouts = core.get_content_id ("mcl_crimson:nether_sprouts")

mcl_levelgen.register_configured_feature ("mcl_crimson:nether_sprouts", {
	feature = "mcl_crimson:nether_forest_vegetation",
	spread_height = 4,
	spread_width = 8,
	content = function (_, _, _)
		return cid_nether_sprouts, 0
	end,
})

local FOUR = function (_) return 4 end
local FIVE = function (_) return 5 end
local SIX = function (_) return 6 end

mcl_levelgen.register_placed_feature ("mcl_crimson:crimson_forest_vegetation", {
	configured_feature = "mcl_crimson:crimson_forest_vegetation",
	placement_modifiers = {
		mcl_levelgen.build_count_on_every_layer (SIX),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_crimson:warped_forest_vegetation", {
	configured_feature = "mcl_crimson:warped_forest_vegetation",
	placement_modifiers = {
		mcl_levelgen.build_count_on_every_layer (FIVE),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_crimson:nether_sprouts", {
	configured_feature = "mcl_crimson:nether_sprouts",
	placement_modifiers = {
		mcl_levelgen.build_count_on_every_layer (FOUR),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Weeping Vines feature.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/WeepingVinesFeature.html
------------------------------------------------------------------------

local just_one_neighboring_p = mcl_levelgen.just_one_neighboring_p

local cid_nether_wart_block
	= core.get_content_id ("mcl_nether:nether_wart_block")
local cid_netherrack
	= core.get_content_id ("mcl_nether:netherrack")
local cid_weeping_vines
	= core.get_content_id ("mcl_crimson:weeping_vines")

local function nether_wart_or_netherrack_p (cid, param2)
	return cid == cid_netherrack or cid == cid_nether_wart_block
end

local function place_wart_blocks_in_area (rng, x, y, z)
	local min_x = huge
	local min_y = huge
	local min_z = huge
	local max_x = -huge
	local max_y = -huge
	local max_z = -huge

	for i = 1, 200 do
		local dx = rng:next_within (6) - rng:next_within (6)
		local dy = rng:next_within (2) - rng:next_within (5)
		local dz = rng:next_within (6) - rng:next_within (6)
		local x1, y1, z1 = x + dx, y + dy, z + dz

		if is_air (x1, y1, z1)
			and just_one_neighboring_p (x1, y1, z1,
						    nether_wart_or_netherrack_p) then
			min_x = mathmin (min_x, x1)
			min_y = mathmin (min_y, y1)
			min_z = mathmin (min_z, z1)
			max_x = mathmax (max_x, x1)
			max_y = mathmax (max_y, y1)
			max_z = mathmax (max_z, z1)
			set_block (x1, y1, z1, cid_nether_wart_block, 0)
		end
	end

	if min_x ~= huge then
		fix_lighting (min_x, min_y, min_z, max_x, max_y, max_z)
	end
end

local function place_one_weeping_vine (x, y, z, column_length)
	local level = 0
	for y = y - 1, y - column_length, -1 do
		if not is_air (x, y, z) then
			break
		end
		set_block (x, y + 1, z, cid_weeping_vines, level)
		level = level + 1
	end
end

local function place_weeping_vines_in_area (rng, x, y, z)
	for i = 1, 100 do
		local dx = rng:next_within (8) - rng:next_within (8)
		local dy = rng:next_within (2) - rng:next_within (7)
		local dz = rng:next_within (8) - rng:next_within (8)
		local x1, y1, z1 = x + dx, y + dy, z + dz

		if is_air (x1, y1, z1) then
			local cid, _ = get_block (x1, y1 + 1, z1)
			if cid == cid_netherrack or cid == cid_nether_wart_block then
				local column_length
				if rng:next_within (5) == 0 then
					column_length = 1
				else
					column_length = 1 + rng:next_within (7)
					if rng:next_within (6) == 0 then
						column_length = column_length * 2
					end
				end

				place_one_weeping_vine (x1, y1, z1, column_length)
			end
		end
	end
end

local function weeping_vines_place (_, x, y, z, cfg, rng)
	crimson_rng:reseed (rng:next_long ())

	if y < run_minp.y or y > run_maxp.y then
		return false
	else
		-- Test whether the roof can support these vines.
		local cid, _ = get_block (x, y + 1, z)
		if cid == cid_netherrack or cid == cid_nether_wart_block then
			place_wart_blocks_in_area (crimson_rng, x, y, z)
			place_weeping_vines_in_area (crimson_rng, x, y, z)
			return true
		end
		return false
	end
end

local TEN = function (_) return 10 end

local nether_preset = mcl_levelgen.get_dimension ("mcl_levelgen:nether").preset
local NETHER_MIN = nether_preset.min_y
local NETHER_TOP = NETHER_MIN + nether_preset.height - 1

local uniform_height = mcl_levelgen.uniform_height

mcl_levelgen.register_feature ("mcl_crimson:weeping_vines", {
	place = weeping_vines_place,
})

mcl_levelgen.register_configured_feature ("mcl_crimson:weeping_vines", {
	feature = "mcl_crimson:weeping_vines",
})

mcl_levelgen.register_placed_feature ("mcl_crimson:weeping_vines", {
	configured_feature = "mcl_crimson:weeping_vines",
	placement_modifiers = {
		mcl_levelgen.build_count (TEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (NETHER_MIN,
								 NETHER_TOP)),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Twisting Vines feature.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/TwistingVinesFeature.html
------------------------------------------------------------------------

-- local twisting_vines_cfg = {
-- 	spread_width = nil,
-- 	spread_height = nil,
-- 	max_height = nil,
-- }

local cid_air = core.CONTENT_AIR

local cid_twisting_vines
	= core.get_content_id ("mcl_crimson:twisting_vines")
local cid_warped_wart_block
	= core.get_content_id ("mcl_crimson:warped_wart_block")

local function twisting_vines_can_place (x, y, z)
	local cid, _ = get_block (x, y, z)
	if cid == cid_air then
		local cid, _ = get_block (x, y - 1, z)
		return cid == cid_netherrack
			or cid == cid_warped_nylium
			or cid == cid_warped_wart_block
	end
	return false
end

local function place_one_twisting_vine (x, y, z, column_length)
	local level = 0
	for y = y + 1, y + column_length do
		if not is_air (x, y, z) then
			break
		end
		set_block (x, y - 1, z, cid_twisting_vines, level)
		level = level + 1
	end
end

local function find_base (x, y, z)
	while is_air (x, y - 1, z) do
		y = y - 1
	end
	return y
end

local function twisting_vines_place (_, x, y, z, cfg, rng)
	crimson_rng:reseed (rng:next_long ())

	if y < run_minp.y or y > run_maxp.y then
		return false
	else
		if twisting_vines_can_place (x, y, z) then
			local rng = crimson_rng
			local spread_width = cfg.spread_width
			local spread_height = cfg.spread_height

			local max_height = cfg.max_height

			for i = 1, spread_width * spread_width do
				local dx = -spread_width
					+ rng:next_within (spread_width * 2)
				local dz = -spread_width
					+ rng:next_within (spread_width * 2)
				local dy = -spread_height
					+ rng:next_within (spread_height * 2)
				local x1, z1 = x + dx, z + dz
				local y1 = find_base (x1, y + dy, z1)
				if y1 >= y - 32
					and twisting_vines_can_place (x1, y1, z1) then
					local column_length
					if rng:next_within (5) == 0 then
						column_length = 1
					else
						column_length = 1 + rng:next_within (max_height)
						if rng:next_within (6) == 0 then
							column_length = column_length * 2
						end
					end
					place_one_twisting_vine (x1, y1, z1, column_length)
				end
			end
			return true
		end
		return false
	end
end

mcl_levelgen.register_feature ("mcl_crimson:twisting_vines", {
	place = twisting_vines_place,
})

mcl_levelgen.register_configured_feature ("mcl_crimson:twisting_vines", {
	feature = "mcl_crimson:twisting_vines",
	max_height = 8,
	spread_height = 4,
	spread_width = 8,
})

mcl_levelgen.register_placed_feature ("mcl_crimson:twisting_vines", {
	configured_feature = "mcl_crimson:twisting_vines",
	placement_modifiers = {
		mcl_levelgen.build_count (TEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (NETHER_MIN,
								 NETHER_TOP)),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Huge Fungus feature.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/HugeFungusFeature.html
------------------------------------------------------------------------

-- local huge_fungus_cfg = {
-- 	valid_base_block_cid = nil
-- 	stem_content = function (x, y, z, rng) ... end,
-- 	hat_content = function (x, y, z, rng) ... end,
-- 	decor_content = function (x, y, z, rng) ... end,
-- 	replaceable_cids = {},
-- 	planted = nil,
-- }

local buildable_to_p = mcl_levelgen.buildable_to_p
local is_buildable_to = mcl_levelgen.is_buildable_to
local ipos3 = mcl_levelgen.ipos3
local indexof = table.indexof

local function is_replaceable (replaceable, x, y, z)
	local cid, _ = get_block (x, y, z)
	return buildable_to_p (cid) or indexof (replaceable, cid) ~= -1, cid
end

local function delete_vines_up (x1, y1, z1)
	local cid
	repeat
		set_block (x1, y1, z1, cid_air, 0)
		y1 = y1 + 1
		cid = get_block (x1, y1, z1)
	until cid ~= cid_twisting_vines
end

local function delete_vines_down (x1, y1, z1)
	local cid
	repeat
		set_block (x1, y1, z1, cid_air, 0)
		y1 = y1 - 1
		cid = get_block (x1, y1, z1)
	until cid ~= cid_weeping_vines
end

local function place_stem (x, y, z, height, cfg, rng, thick_stem)
	local stem_content = cfg.stem_content
	local r = thick_stem and 1 or 0
	local replaceable = cfg.replaceable_cids

	for x1, z1, y1 in ipos3 (x - r, z - r, y,
				 x + r, z + r, y + height - 1) do
		local corner = mathabs (x1 - x) > 0
			and mathabs (z1 - z) > 0
			and mathabs (x1 - x) == r
			and mathabs (z1 - z) == r

		local rc, cid = is_replaceable (replaceable, x1, y1, z1)
		if rc then
			if cid == cid_twisting_vines then
				delete_vines_up (x1, y1, z1)
			elseif cid == cid_weeping_vines then
				delete_vines_down (x1, y1, z1)
			end

			if not corner or rng:next_float () < 0.1 then
				local cid, param2 = stem_content (x1, y1, z1)
				set_block (x1, y1, z1, cid, param2)
			end
		end
	end
	fix_lighting (x - r, z - r, y, x + r, z + r, y + height - 1)
end

local function place_hat_columnize (rng, x1, y1, z1, cid, param2, is_warped)
	local cid_below, _ = get_block (x1, y1 - 1, z1)
	if cid_below == cid or rng:next_float () < 0.15 then
		set_block (x1, y1, z1, cid, param2)

		if cid_below == cid_air
			and not is_warped
			and rng:next_within (11) == 0 then
			local height = rng:next_within (5) + 1
			if rng:next_within (7) == 0 then
				height = height * 2
			end

			place_one_weeping_vine (x1, y1 - 1, z1, height)
		end
	end
end

local function place_hat_block (rng, x, y, z, decoration_chance,
				generation_chance, vine_chance,
				decor_content, hat_content)
	if rng:next_float () < decoration_chance then
		local cid, param2 = decor_content (x, y, z, rng)
		set_block (x, y, z, cid, param2)
	elseif rng:next_float () < generation_chance then
		local cid, param2 = hat_content (x, y, z, rng)
		set_block (x, y, z, cid, param2)

		if rng:next_float () < vine_chance
			and is_air (x, y - 1, z) then
			local height = rng:next_within (5) + 1
			if rng:next_within (7) == 0 then
				height = height * 2
			end

			place_one_weeping_vine (x, y - 1, z, height)
		end
	end
end

local function place_hat (x, y, z, stem_height, cfg, rng, thick_stem)
	local is_warped
		= cfg.valid_base_block_cid == cid_warped_nylium
	local height_variance = floor (stem_height / 3)
	local cap_height
		= mathmin (rng:next_within (1 + height_variance) + 5,
			   stem_height)
	local cap_start = stem_height - cap_height
	local max_radius = 1
	local hat_content = cfg.hat_content
	local decor_content = cfg.decor_content

	for dy = cap_start, stem_height do
		local radius

		if cap_height > 8 and dy < cap_height + 4 then
			radius = 3 + (thick_stem and 1 or 0)
		elseif dy < (stem_height - rng:next_within (3)) then
			radius = 2 + (thick_stem and 1 or 0)
		else
			radius = 1 + (thick_stem and 1 or 0)
		end

		max_radius = mathmax (max_radius, radius)

		for dx, _, dz in ipos3 (-radius, 0, -radius,
					radius, 0, radius) do
			local at_edges = mathabs (dx) == radius
				or mathabs (dz) == radius
			local not_at_edges_or_top
				= dy ~= stem_height and not at_edges

			local x1, y1, z1 = x + dx, y + dy, z + dz
			if is_buildable_to (x1, y1, z1) then
				-- Destroy obstructing vines.
				local cid, _ = get_block (x1, y1, z1)
				if cid == cid_twisting_vines then
					delete_vines_up (x1, y1, z1)
				elseif cid == cid_weeping_vines then
					delete_vines_down (x1, y1, z1)
				end

				if dy - cap_start <= 2 then
					if not not_at_edges_or_top then
						local cid, param2
							= hat_content (x1, y1, z1, rng)
						place_hat_columnize (rng, x1, y1, z1,
								     cid, param2, is_warped)
					end
				elseif not_at_edges_or_top then
					place_hat_block (rng, x1, y1, z1, 0.1, 0.2,
							 not is_warped and 0.1 or 0.0,
							 decor_content, hat_content)
				elseif at_edges then
					place_hat_block (rng, x1, y1, z1, 0.01, 0.7,
							 not is_warped and 0.083 or 0.0,
							 decor_content, hat_content)
				else
					place_hat_block (rng, x1, y1, z1, 0.0005, 0.98,
							 not is_warped and 0.07 or 0.0,
							 decor_content, hat_content)
				end
			end
		end
	end

	fix_lighting (x - max_radius, y + cap_start, z - max_radius,
		      x + max_radius, y + stem_height, z + max_radius)
end

local function huge_fungus_place (_, x, y, z, cfg, rng)
	crimson_rng:reseed (rng:next_long ())

	if y < run_minp.y or y > run_maxp.y then
		return false
	else
		local cid, _ = get_block (x, y - 1, z)
		if cid ~= cfg.valid_base_block_cid then
			return false
		end

		local rng = crimson_rng
		local height = rng:next_within (10) + 4
		if rng:next_within (12) == 0 then
			height = height * 2
		end

		-- https://minecraft.wiki/w/Huge_fungus#Config
		local y_max = mcl_levelgen.placement_level_min
			+ mcl_levelgen.placement_level_height
		if not cfg.planted and y + height + 1 >= y_max then
			return false
		end

		local thick_stem = not cfg.planted
			and rng:next_float () < 0.06
		set_block (x, y, z, cid_air, 0)
		place_stem (x, y, z, height, cfg, rng, thick_stem)
		place_hat (x, y, z, height, cfg, rng, thick_stem)
		return true
	end
end

mcl_levelgen.register_feature ("mcl_crimson:huge_fungus", {
	place = huge_fungus_place,
})

local cid_shroomlight
	= core.get_content_id ("mcl_crimson:shroomlight")
local cid_crimson_stem
	= core.get_content_id ("mcl_trees:tree_crimson")
local cid_warped_stem
	= core.get_content_id ("mcl_trees:tree_warped")

local function provide_shroomlight (x, y, z, rng)
	return cid_shroomlight, 0
end

mcl_levelgen.register_configured_feature ("mcl_crimson:crimson_fungus", {
	feature = "mcl_crimson:huge_fungus",
	decor_content = provide_shroomlight,
	stem_content = function (_, _, _, _)
		return cid_crimson_stem, 0
	end,
	hat_content = function (_, _, _, _)
		return cid_nether_wart_block, 0
	end,
	valid_base_block_cid = cid_crimson_nylium,
	replaceable_cids = mcl_levelgen.construct_cid_list ({
		"group:mushroom",
		"group:plant",
		"group:sapling",
		"mcl_crimson:crimson_fungus",
		"mcl_crimson:crimson_roots",
		"mcl_crimson:nether_sprouts",
		"mcl_crimson:twisting_vines",
		"mcl_crimson:warped_fungus",
		"mcl_crimson:warped_roots",
		"mcl_crimson:weeping_vines",
	}),
})

mcl_levelgen.register_configured_feature ("mcl_crimson:warped_fungus", {
	feature = "mcl_crimson:huge_fungus",
	decor_content = provide_shroomlight,
	stem_content = function (_, _, _, _)
		return cid_warped_stem, 0
	end,
	hat_content = function (_, _, _, _)
		return cid_warped_wart_block, 0
	end,
	valid_base_block_cid = cid_warped_nylium,
	replaceable_cids = mcl_levelgen.construct_cid_list ({
		"group:mushroom",
		"group:plant",
		"group:sapling",
		"mcl_crimson:crimson_fungus",
		"mcl_crimson:crimson_roots",
		"mcl_crimson:nether_sprouts",
		"mcl_crimson:twisting_vines",
		"mcl_crimson:warped_fungus",
		"mcl_crimson:warped_roots",
		"mcl_crimson:weeping_vines",
	}),
})

local EIGHT = function (_) return 8 end

mcl_levelgen.register_placed_feature ("mcl_crimson:crimson_fungi", {
	configured_feature = "mcl_crimson:crimson_fungus",
	placement_modifiers = {
		mcl_levelgen.build_count_on_every_layer (EIGHT),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_crimson:warped_fungi", {
	configured_feature = "mcl_crimson:warped_fungus",
	placement_modifiers = {
		mcl_levelgen.build_count_on_every_layer (EIGHT),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Miscellaneous features.
------------------------------------------------------------------------

mcl_levelgen.register_configured_feature ("mcl_crimson:block_crimson_roots", {
	feature = "mcl_levelgen:simple_block",
	content = function (_, _, _, _)
		return cid_crimson_roots, 0
	end,
})

mcl_levelgen.register_configured_feature ("mcl_crimson:patch_crimson_roots", {
	feature = "mcl_levelgen:random_patch",
	placed_feature = {
		configured_feature = "mcl_crimson:block_crimson_roots",
		placement_modifiers = {
			mcl_levelgen.require_air,
		},
	},
	tries = 96,
	xz_spread = 7,
	y_spread = 3,
})

mcl_levelgen.register_placed_feature ("mcl_crimson:patch_crimson_roots", {
	configured_feature = "mcl_crimson:patch_crimson_roots",
	placement_modifiers = {
		mcl_levelgen.build_height_range (uniform_height (NETHER_MIN,
								 NETHER_TOP)),
		mcl_levelgen.build_in_biome (),
	},
})
