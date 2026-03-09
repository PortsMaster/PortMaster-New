------------------------------------------------------------------------
-- Nether level generation.
------------------------------------------------------------------------

local mcl_levelgen = mcl_levelgen
local ipairs = ipairs

local mathmin = math.min
local mathmax = math.max
local mathabs = math.abs

local get_block = mcl_levelgen.get_block
local set_block = mcl_levelgen.set_block
local fix_lighting = mcl_levelgen.fix_lighting
local is_air = mcl_levelgen.is_air

local ull = mcl_levelgen.ull
local nether_rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))

local uniform_height = mcl_levelgen.uniform_height
local biased_to_bottom_height = mcl_levelgen.biased_to_bottom_height

local run_minp = mcl_levelgen.placement_run_minp
local run_maxp = mcl_levelgen.placement_run_maxp

------------------------------------------------------------------------
-- Glowstone Blob.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/GlowstoneBlobFeature.html
------------------------------------------------------------------------

local nether_preset = mcl_levelgen.get_dimension ("mcl_levelgen:nether").preset
local NETHER_MIN = nether_preset.min_y
local NETHER_TOP = NETHER_MIN + nether_preset.height - 1

local TEN = function (_) return 10 end

local cid_blackstone = core.get_content_id ("mcl_blackstone:blackstone")
local cid_basalt = core.get_content_id ("mcl_blackstone:basalt")
local cid_netherrack = core.get_content_id ("mcl_nether:netherrack")
local cid_glowstone = core.get_content_id ("mcl_nether:glowstone")

local just_one_neighboring_p = mcl_levelgen.just_one_neighboring_p

local function glowstone_p (cid, param2)
	return cid == cid_glowstone
end

local function one_neighboring_glowstone_p (x1, y1, z1)
	return just_one_neighboring_p (x1, y1, z1, glowstone_p)
end

local function glowstone_blob_place (_, x, y, z, cfg, rng)
	nether_rng:reseed (rng:next_long ())
	if y < run_minp.y or y > run_maxp.y or not is_air (x, y, z) then
		return false
	else
		local rng = nether_rng
		local cid, _ = get_block (x, y + 1, z)
		local min_x = x
		local min_y = y
		local min_z = z
		local max_x = x
		local max_y = y
		local max_z = z

		if cid == cid_blackstone
			or cid == cid_basalt
			or cid == cid_netherrack then
			set_block (x, y, z, cid_glowstone, 0)

			for i = 1, 1500 do
				local dx = rng:next_within (8) - rng:next_within (8)
				local dy = rng:next_within (8) - rng:next_within (8)
				local dz = rng:next_within (8) - rng:next_within (8)
				local x1, y1, z1 = x + dx, y + dy, z + dz

				if is_air (x1, y1, z1) then
					-- Place glowstone if there is
					-- exclusively one adjacent
					-- glowstone block.
					if one_neighboring_glowstone_p (x1, y1, z1) then
						set_block (x1, y1, z1, cid_glowstone, 0)
						min_x = mathmin (min_x, x1)
						min_y = mathmin (min_y, y1)
						min_z = mathmin (min_z, z1)
						max_x = mathmax (max_x, x1)
						max_y = mathmax (max_y, y1)
						max_z = mathmax (max_z, z1)
					end
				end
			end

			fix_lighting (min_x, min_y, min_z, max_x, max_y, max_z)
			return true
		end

		return false
	end
end

mcl_levelgen.register_feature ("mcl_nether:glowstone_blob", {
	place = glowstone_blob_place,
})

mcl_levelgen.register_configured_feature ("mcl_nether:glowstone_extra", {
	feature = "mcl_nether:glowstone_blob",
})

mcl_levelgen.register_placed_feature ("mcl_nether:glowstone", {
	configured_feature = "mcl_nether:glowstone_extra",
	placement_modifiers = {
		mcl_levelgen.build_count (TEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (NETHER_MIN,
								 NETHER_TOP)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_nether:glowstone_extra", {
	configured_feature = "mcl_nether:glowstone_extra",
	placement_modifiers = {
		mcl_levelgen.build_count (biased_to_bottom_height (0, 9, nil)),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (NETHER_MIN + 4,
								 NETHER_TOP - 4)),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Basalt Pillar feature
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/BasaltPillarFeature.html
------------------------------------------------------------------------

local request_additional_context = mcl_levelgen.request_additional_context
local cid_basalt = core.get_content_id ("mcl_blackstone:basalt")
local cid_bedrock = core.get_content_id ("mcl_core:bedrock")
local nodes_to_replace
local insert = table.insert
local floor = math.floor

local function longhash (x, y, z)
	return (32768 + x) * 65536 * 65536 + (32768 + y) * 65536
		+ (32768 + z)
end

local band = bit.band

local function unhash (pos)
	return floor (pos / (65536 * 65536)) - 32768,
		band (floor (pos / 65536), 0xffff) - 32768,
		pos % 65536 - 32768
end

local function push_block (x, y, z)
	insert (nodes_to_replace, longhash (x, y, z))
end

local function replace_nodes ()
	for _, node in ipairs (nodes_to_replace) do
		local x, y, z = unhash (node)
		local cid, _ = get_block (x, y, z)
		if cid ~= cid_bedrock then
			set_block (x, y, z, cid_basalt, 0)
		end
	end
end

local ipos3 = mcl_levelgen.ipos3

local function basalt_pillar_place (_, x, y, z, cfg, rng)
	nether_rng:reseed (rng:next_long ())
	if y < run_minp.y or y > run_maxp.y
		or not is_air (x, y, z) then
		return false
	end

	local level_min = mcl_levelgen.placement_level_min
	local min_y = mcl_levelgen.placement_run_min_y
	nodes_to_replace = {}

	local rng = nether_rng
	local y_start = y
	if not is_air (x, y + 1, z) then
		local north = true
		local south = true
		local west = true
		local east = true
		while is_air (x, y, z) do
			if y < level_min then
				replace_nodes ()
				return true
			elseif y < min_y then
				request_additional_context (0, 32)
				return false
			end
			if north and rng:next_within (10) ~= 0 then
				push_block (x, y, z - 1)
			else
				north = false
			end
			if south and rng:next_within (10) ~= 0 then
				push_block (x, y, z + 1)
			else
				south = false
			end
			if west and rng:next_within (10) ~= 0 then
				push_block (x - 1, y, z)
			else
				west = false
			end
			if east and rng:next_within (10) ~= 0 then
				push_block (x + 1, y, z)
			else
				east = false
			end
			push_block (x, y, z)
			y = y - 1
		end

		y = y + 1
		if rng:next_boolean () then
			push_block (x - 1, y, z)
		end
		if rng:next_boolean () then
			push_block (x + 1, y, z)
		end
		if rng:next_boolean () then
			push_block (x, y, z - 1)
		end
		if rng:next_boolean () then
			push_block (x, y, z + 1)
		end

		local y_min = y
		for dx, _, dz in ipos3 (-3, 0, -3, 4, 0, 4) do
			local dist = mathabs (dx) * mathabs (dz)
			if rng:next_within (10) < 10 - dist then
				for y = y, level_min, -1 do
					if y < min_y then
						request_additional_context (0, 32)
						return false
					elseif not is_air (x + dx, y, z + dz) then
						push_block (x + dx, y, z + dz)
						y_min = mathmin (y_min, y)
						break
					end
				end
			end
		end
		replace_nodes ()
		fix_lighting (x - 1, y_min, z - 1, x + 1, y_start, z + 1)
		return true
	end
	return false
end

mcl_levelgen.register_feature ("mcl_nether:basalt_pillar", {
	place = basalt_pillar_place,
})

mcl_levelgen.register_configured_feature ("mcl_nether:basalt_pillar", {
	feature = "mcl_nether:basalt_pillar",
})

mcl_levelgen.register_placed_feature ("mcl_nether:basalt_pillar", {
	configured_feature = "mcl_nether:basalt_pillar",
	placement_modifiers = {
		mcl_levelgen.build_count (TEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (NETHER_MIN,
								 NETHER_TOP)),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Delta feature.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/DeltaFeature.html
------------------------------------------------------------------------

local delta_cannot_replace = mcl_levelgen.construct_cid_list ({
	"mcl_chests:chest_left",
	"mcl_chests:chest_right",
	"mcl_chests:chest_small",
	"mcl_core:bedrock",
	"mcl_fences:nether_brick_fence",
	"mcl_mobspawners:spawner",
	"mcl_nether:nether_brick",
	"mcl_nether:nether_wart",
	"mcl_stairs:stair_nether_brick",
	"mcl_stairs:stair_nether_brick_inner",
	"mcl_stairs:stair_nether_brick_outer",
})

-- local delta_cfg = {
-- 	content = function (_, _, _, _) ... end,
-- 	rim_content = function (_, _, _, _) ... end,
-- 	rim_size = function (_) .. end,
-- 	size = function (_) ... end,
-- }

local iterate_outwards

do
	local cx, cz, flip, cnt_z
	local xrange, xmax, zmax

	local function iterate_outwards_iterator ()
		if flip then
			flip = false
			return cx, -cz
		end
		cz = nil
		while not cz or cz > zmax do
			cx = cx + 1
			if cx > xrange then
				cnt_z = cnt_z + 1
				if cnt_z > xmax + zmax then
					return nil, nil
				end
				xrange = mathmin (xrange + 1, xmax)
				cx = -xrange
			end
			cz = cnt_z - mathabs (cx)
			flip = cz ~= 0
		end
		return cx, cz
	end

	function iterate_outwards (dx, dz)
		cx = 0
		cnt_z = 0
		flip = false
		xrange = 0
		xmax = dx
		zmax = dz
		return iterate_outwards_iterator
	end
end

local indexof = table.indexof

local function delta_set_block (x, y, z, cid, param2)
	local cid_here, _ = get_block (x, y, z)
	if cid_here == cid
		or indexof (delta_cannot_replace, cid) ~= -1 then
		return false
	elseif is_air (x, y + 1, z)
		and not is_air (x - 1, y, z)
		and not is_air (x + 1, y, z)
		and not is_air (x, y, z - 1)
		and not is_air (x, y, z + 1)
		and not is_air (x, y - 1, z) then
		set_block (x, y, z, cid, param2)
		return true
	end
	return false
end

local function delta_place (_, x, y, z, cfg, rng)
	nether_rng:reseed (rng:next_long ())
	if y < run_minp.y or y > run_maxp.y then
		return false
	end

	local rng = nether_rng
	local generate_rim = rng:next_double () < 0.9
	local size, rim_size = cfg.size, cfg.rim_size
	local rim_x = generate_rim and rim_size (rng) or 0
	local rim_z = generate_rim and rim_size (rng) or 0
	local have_rim = rim_x > 0 and rim_z > 0
	local rx, rz = size (rng), size (rng)
	local rmax = mathmax (rx, rz)
	local rim_content = cfg.rim_content
	local content = cfg.content
	local placed = false

	for dx, dz in iterate_outwards (rx, rz) do
		if mathabs (dx) + mathabs (dz) <= rmax then
			local x, z = dx + x, dz + z
			if have_rim then
				local cid, param2 = rim_content (x, y, z, rng)
				if delta_set_block (x, y, z, cid, param2) then
					placed = true
					cid, param2 = content (x + rim_x, y, z + rim_z, rng)
					delta_set_block (x + rim_x, y, z + rim_z, cid, param2)
				end
			else
				local cid, param2 = content (x, y, z, rng)
				placed = delta_set_block (x, y, z, cid, param2) or placed
			end
		end
	end
	if placed then
		fix_lighting (x - rx - rim_x, y, z - rz - rim_z,
			      x + rx + rim_x, y, z + rz + rim_z)
	end
	return placed
end

mcl_levelgen.register_feature ("mcl_nether:delta_feature", {
	place = delta_place,
})

local cid_nether_lava_source
	= core.get_content_id ("mcl_nether:nether_lava_source")
local cid_magma_block
	= core.get_content_id ("mcl_nether:magma")

mcl_levelgen.register_configured_feature ("mcl_nether:delta", {
	feature = "mcl_nether:delta_feature",
	content = function (_, _, _, _)
		return cid_nether_lava_source, 0
	end,
	rim_content = function (_, _, _, _)
		return cid_magma_block, 0
	end,
	rim_size = uniform_height (0, 2),
	size = uniform_height (3, 7),
})

local FOURTY = function (_) return 40 end

mcl_levelgen.register_placed_feature ("mcl_nether:delta", {
	configured_feature = "mcl_nether:delta",
	placement_modifiers = {
		mcl_levelgen.build_count_on_every_layer (FOURTY),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Basalt Blobs.
------------------------------------------------------------------------

mcl_levelgen.register_configured_feature ("mcl_nether:basalt_blobs", {
	feature = "mcl_levelgen:netherrack_replace_blobs",
	radius = uniform_height (3, 7),
	target_cid = cid_netherrack,
	content = function (_, _, _, _)
		return cid_basalt, 0
	end,
})

local SEVENTY_FIVE = function (_) return 75 end

mcl_levelgen.register_placed_feature ("mcl_nether:basalt_blobs", {
	configured_feature = "mcl_nether:basalt_blobs",
	placement_modifiers = {
		mcl_levelgen.build_count (SEVENTY_FIVE),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (NETHER_MIN,
								 NETHER_TOP)),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Basalt Columns.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/BasaltColumnsFeature.html
------------------------------------------------------------------------

-- local basalt_columns_cfg = {
-- 	height = function (_) ... end,
-- 	reach = function (_) ... end,
-- }

local cids_not_eligible_for_placement = mcl_levelgen.construct_cid_list ({
	"mcl_chests:chest_left",
	"mcl_chests:chest_right",
	"mcl_chests:chest_small",
	"mcl_core:bedrock",
	"mcl_core:lava_source",
	"mcl_fences:nether_brick_fence",
	"mcl_mobspawners:spawner",
	"mcl_nether:magma",
	"mcl_nether:nether_brick",
	"mcl_nether:nether_lava_source",
	"mcl_nether:nether_wart",
	"mcl_nether:soul_sand",
	"mcl_stairs:stair_nether_brick",
	"mcl_stairs:stair_nether_brick_inner",
	"mcl_stairs:stair_nether_brick_outer",

})

local huge = math.huge

local cid_air = core.CONTENT_AIR
local lava_p = mcl_levelgen.lava_p
local basalt_min_y = huge
local basalt_max_y = -huge

-- field_31495, field_31496, field_31497, and field_31498 appear to be
-- unused.

local function is_air_or_lava_sea (x, y, z, sea_level)
	local cid, _ = get_block (x, y, z)
	return cid == cid_air or (y <= sea_level and lava_p (cid))
end

local function position_can_support_column (x, y, z, sea_level)
	if is_air_or_lava_sea (x, y, z, sea_level) then
		local cid, _ = get_block (x, y - 1, z)
		return cid ~= cid_air
			and indexof (cids_not_eligible_for_placement, cid) == -1
	end
	return false
end

local function locate_surface_down (x, y, z, level_min, sea_level, lim)
	while y > level_min + 1 and lim > 0 do
		lim = lim - 1
		if position_can_support_column (x, y, z, sea_level) then
			return y
		end
		y = y - 1
	end
	return nil
end

local function locate_surface_up (x, y, z, level_max, lim)
	-- This function is only called when it is known that Y is
	-- above lava level and within a block that is not a valid
	-- source for a column.
	while y <= level_max and lim > 0 do
		lim = lim - 1
		local cid, _ = get_block (x, y, z)
		if indexof (cids_not_eligible_for_placement, cid) ~= -1 then
			return nil
		elseif cid == cid_air then
			return y
		end
		y = y + 1
	end
	return nil
end

local function generate_column_cluster (x, y, z, height, reach, sea_level)
	local success = false
	local level_min = mcl_levelgen.placement_level_min
	local level_max = mcl_levelgen.placement_level_height + level_min - 1

	for dx, _, dz in ipos3 (-reach, 0, -reach,
				reach, 0, reach) do
		local x, z = x + dx, z + dz
		local dist = mathabs (dx) + mathabs (dz)
		local lim = mathmin (dist, 32)
		local y1
		if is_air_or_lava_sea (x, y, z, sea_level) then
			y1 = locate_surface_down (x, y, z, level_min,
						  sea_level, lim)
		else
			y1 = locate_surface_up (x, y, z, level_max, lim)
		end
		local y = y1
		if y then
			local height = height - floor (dist / 2)
			for y = y, y + height do
				if is_air_or_lava_sea (x, y, z, sea_level) then
					success = true
					set_block (x, y, z, cid_basalt, 0)
					basalt_min_y = mathmin (basalt_min_y, y)
					basalt_max_y = mathmax (basalt_max_y, y)
				else
					local cid, _ = get_block (x, y, z)
					if cid ~= cid_basalt then
						break
					end
				end
			end
		end
	end
	return success
end

local function basalt_columns_place (_, x, y, z, cfg, rng)
	nether_rng:reseed (rng:next_long ())
	if y < run_minp.y or y > run_maxp.y then
		return false
	end

	local sea_level = mcl_levelgen.placement_level.sea_level
	local rng = nether_rng

	if not position_can_support_column (x, y, z, sea_level) then
		return false
	else
		local height = cfg.height (rng)
		local is_dense = rng:next_float () < 0.9
		local r = mathmin (height, is_dense and 5 or 8)
		local count = is_dense and 50 or 15
		local any = false
		local reach = cfg.reach

		basalt_min_y = huge
		basalt_max_y = -huge

		for i = 1, count do
			local dx = rng:next_within (r * 2 + 1) + -r
			local dz = rng:next_within (r * 2 + 1) + -r
			local dist = mathabs (dx) + mathabs (dz)

			if dist <= height
				and generate_column_cluster (x + dx, y,
							     z + dz,
							     height - dist,
							     reach (rng),
							     sea_level) then
				any = true
			end
		end

		if any then
			fix_lighting (x - r, basalt_min_y, z - r,
				      x + r, basalt_max_y, z + r)
		end
		return any
	end
end

mcl_levelgen.register_feature ("mcl_nether:basalt_columns", {
	place = basalt_columns_place,
})

mcl_levelgen.register_configured_feature ("mcl_nether:large_basalt_columns", {
	feature = "mcl_nether:basalt_columns",
	height = uniform_height (5, 10),
	reach = uniform_height (3, 2),
})

local ONE = function (_) return 1 end

mcl_levelgen.register_configured_feature ("mcl_nether:small_basalt_columns", {
	feature = "mcl_nether:basalt_columns",
	height = uniform_height (1, 4),
	reach = ONE,
})

local TWO = function (_) return 2 end

mcl_levelgen.register_placed_feature ("mcl_nether:large_basalt_columns", {
	configured_feature = "mcl_nether:large_basalt_columns",
	placement_modifiers = {
		mcl_levelgen.build_count_on_every_layer (TWO),
		mcl_levelgen.build_in_biome (),
	},
})

local FOUR = function (_) return 4 end

mcl_levelgen.register_placed_feature ("mcl_nether:small_basalt_columns", {
	configured_feature = "mcl_nether:small_basalt_columns",
	placement_modifiers = {
		mcl_levelgen.build_count_on_every_layer (FOUR),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Basalt Delta springs.
------------------------------------------------------------------------

local SIXTEEN = function (_) return 16 end

local cid_gravel = core.get_content_id ("mcl_core:gravel")
local cid_soul_sand = core.get_content_id ("mcl_nether:soul_sand")

mcl_levelgen.register_configured_feature ("mcl_nether:spring_lava_nether", {
	feature = "mcl_levelgen:spring",
	hole_count = 1,
	rock_count = 4,
	requires_block_below = true,
	fluid_cid = cid_nether_lava_source,
	valid_blocks = {
		cid_netherrack,
		cid_soul_sand,
		cid_gravel,
		cid_magma_block,
		cid_blackstone,
	},
})

mcl_levelgen.register_placed_feature ("mcl_nether:spring_delta", {
	configured_feature = "mcl_nether:spring_lava_nether",
	placement_modifiers = {
		mcl_levelgen.build_count (SIXTEEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (NETHER_MIN + 4,
								 NETHER_TOP - 4)),
		mcl_levelgen.build_in_biome (),
	},
})
