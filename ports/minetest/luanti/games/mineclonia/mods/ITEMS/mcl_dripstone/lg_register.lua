local E = mcl_levelgen.build_environment_scan

------------------------------------------------------------------------
-- Async dripstone features.
------------------------------------------------------------------------

-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/DripstoneClusterFeature.html

-- local dripstone_cfg = {
-- 	floor_to_ceiling_search_range = nil,
-- 	height = nil,
-- 	radius = nil,
-- 	max_stalagmite_stalactite_height_diff = nil,
-- 	height_deviation = nil,
-- 	dripstone_block_layer_thickness = nil,
-- 	density = nil,
-- 	weitness = nil,
-- 	chance_of_dripstone_column_at_max_distance_from_center = nil,
-- 	max_distance_from_edge_affecting_chance_of_dripstone_column = nil,
-- 	max_distance_from_center_affecting_height_bias = nil,
-- }

local cid_water_source = core.get_content_id ("mcl_core:water_source")
local cid_water_flowing = core.get_content_id ("mcl_core:water_flowing")
local cid_lava_source = core.get_content_id ("mcl_core:lava_source")
local cid_lava_flowing = core.get_content_id ("mcl_core:lava_flowing")
local cid_air = core.CONTENT_AIR

local get_block = mcl_levelgen.get_block
local set_block = mcl_levelgen.set_block

local function air_or_water_p (x, y, z)
	local cid, _ = get_block (x, y, z)
	return cid == cid_air
		or cid == cid_water_source
		or cid == cid_water_flowing
end

local function not_air_or_water_p (x, y, z)
	return not air_or_water_p (x, y, z)
end

local function lava_p (x, y, z)
	local cid, _ = get_block (x, y, z)
	return cid == cid_lava_source
		or cid == cid_lava_flowing
end

local function air_water_or_lava_p (x, y, z)
	local cid, _ = get_block (x, y, z)
	return cid == cid_air
		or cid == cid_water_source
		or cid == cid_water_flowing
		or cid == cid_lava_source
		or cid == cid_lava_flowing
end

local ull = mcl_levelgen.ull
local dripstone_rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))
local mathmin = math.min
local mathmax = math.max
local mathabs = math.abs
local huge = math.huge

local function distance_to_dripstone_probability (radius_x, radius_z,
						  dx, dz, cfg)
	local dist_to_r = mathmin (radius_x - mathabs (dx),
				   radius_z - mathabs (dz))
	local max_dist_to_r
		= cfg.max_distance_from_edge_affecting_chance_of_dripstone_column
	local max_chance
		= cfg.chance_of_dripstone_column_at_max_distance_from_center
	local x = mathmin (dist_to_r, max_dist_to_r) / max_dist_to_r
	return max_chance + (1.0 - max_chance) * x
end

local find_ceiling_and_floor = mcl_levelgen.find_ceiling_and_floor

local function clamped_gaussian (rng, min, max, mean, deviation)
	local x = mean + rng:next_gaussian () * deviation
	return mathmax (mathmin (x, max), min)
end

local floor = math.floor
local ceil = math.ceil

local function get_height (rng, dx, dz, density, height, cfg)
	if rng:next_float () > density then
		return 0
	else
		local bias_max
			= cfg.max_distance_from_center_affecting_height_bias
		local d = mathabs (dx) + mathabs (dz)
		local x = mathmin (1.0, d / bias_max)
		local bias = height * 0.5 - x * (height * 0.5)
		return floor (clamped_gaussian (rng, 0.0, height, bias,
						cfg.height_deviation))
	end
end

local cid_stone = core.get_content_id ("mcl_core:stone")
local cid_granite = core.get_content_id ("mcl_core:granite")
local cid_diorite = core.get_content_id ("mcl_core:diorite")
local cid_andesite = core.get_content_id ("mcl_core:andesite")
local cid_tuff = core.get_content_id ("mcl_deepslate:tuff")
local cid_deepslate = core.get_content_id ("mcl_deepslate:deepslate")

local function dripstone_replaceable_p (cid)
	return cid == cid_stone
		or cid == cid_granite
		or cid == cid_diorite
		or cid == cid_andesite
		or cid == cid_tuff
		or cid == cid_deepslate
end

local cid_dripstone_block
	= core.get_content_id ("mcl_dripstone:dripstone_block")

local function dripstone_base_p (cid)
	return cid == cid_dripstone_block
		or dripstone_replaceable_p (cid)
end

local dripstone_directions = {
	"bottom",
	"top",
}

local dripstone_stages = {
	"tip_merge",
	"tip",
	"frustum",
	"middle",
	"base",
}

local cids = {}

for i = 1, #dripstone_directions do
	local dir = dripstone_directions[i]
	for _, stage in ipairs (dripstone_stages) do
		local id = string.format ("mcl_dripstone:dripstone_%s_%s",
					  dir, stage)
		table.insert (cids, core.get_content_id (id))
	end
end

local TIP_MERGE = 1
local TIP = 2
local FRUSTUM = 3
local MIDDLE = 4
local BASE = 5

local function place_dripstone_blocks (x, y, z, thick, dir)
	for y = y, y + (thick - 1) * dir, dir do
		local cid, param2 = get_block (x, y, z)
		if not dripstone_replaceable_p (cid) then
			return
		end
		set_block (x, y, z, cid_dripstone_block, param2)
	end
end

local fix_lighting = mcl_levelgen.fix_lighting

local function spawn_pointed_dripstone (x, y, z, dir, n, contact)
	local offset = dir == -1 and #dripstone_stages or 0
	local cid, _ = get_block (x, y + -dir, z)
	if dripstone_base_p (cid) then
		if n >= 3 then
			set_block (x, y, z, cids[offset + BASE], 0)
			y = y + dir

			for i = 1, n - 3 do
				set_block (x, y, z, cids[offset + MIDDLE], 0)
				y = y + dir
			end
		end

		if n >= 2 then
			set_block (x, y, z, cids[offset + FRUSTUM], 0)
			y = y + dir
		end

		if n >= 1 then
			if contact then
				set_block (x, y, z, cids[offset + TIP_MERGE], 0)
			else
				set_block (x, y, z, cids[offset + TIP], 0)
			end
		end
	end
end

local function can_water_spawn_1 (x, y, z)
	local cid = get_block (x, y, z)
	return dripstone_replaceable_p (cid)
		or dripstone_base_p (cid)
end

local function can_water_spawn (x, y, z)
	return can_water_spawn_1 (x, y, z - 1)
		and can_water_spawn_1 (x - 1, y, z)
		and can_water_spawn_1 (x, y, z + 1)
		and can_water_spawn_1 (x + 1, y, z)
		and can_water_spawn_1 (x, y - 1, z)
		and dripstone_replaceable_p ((get_block (x, y, z)))
end

local function generate (x, y, z, dx, dz, wetness, dripstone_probability,
			 height, density, cfg)
	local rng = dripstone_rng
	local search_range = cfg.floor_to_ceiling_search_range
	local ceiling, floor
		= find_ceiling_and_floor (x, y, z, search_range, air_or_water_p,
					  not_air_or_water_p)
	local water_generated = false

	if ceiling or floor then
		local thickness = cfg.dripstone_block_layer_thickness
		local is_wet = rng:next_float () < wetness
		if is_wet and floor and can_water_spawn (x, floor, z) then
			water_generated = true
			set_block (x, floor, z, cid_water_source, 0)
		end

		local stalactite = rng:next_double () < dripstone_probability
		local stalactite_height = 0

		if ceiling and stalactite and not lava_p (x, ceiling, z) then
			local thick = thickness (rng)
			place_dripstone_blocks (x, ceiling, z, thick, 1)

			local height
				= floor and mathmin (height, ceiling - floor) or height
			stalactite_height = get_height (rng, dx, dz, density, height, cfg)
		end

		local stalagmite = rng:next_double () < dripstone_probability
		local stalagmite_height = 0

		if floor and stalagmite and not lava_p (x, floor, z) then
			local thick = thickness (rng)
			place_dripstone_blocks (x, floor, z, thick, -1)

			if ceiling then
				local max_diff = cfg.max_stalagmite_stalactite_height_diff
				local min_diff = -max_diff
				local diff = -min_diff
					+ rng:next_within (max_diff + min_diff + 1)
				stalagmite_height = mathmax (0, stalactite_height + diff)
			else
				stalagmite_height
					= get_height (rng, dx, dz, density, height, cfg)
			end
		end

		-- Reconcile stalagmite height with stalactite height.
		if ceiling and floor
			and (ceiling - stalactite_height <= floor + stalagmite_height) then
			local stalactite_min
				= mathmax (ceiling - stalactite_height, floor + 1)
			local stalagmite_max
				= mathmin (floor + stalagmite_height, ceiling - 1)
			local min = mathmin (stalactite_min, stalagmite_max)
			local max = mathmax (stalagmite_max, stalactite_min)
			local brk = min + rng:next_within (max - min + 1)
			stalactite_height = ceiling - brk
			stalagmite_height = brk - floor - 1
		end

		local contact = rng:next_boolean ()
			and stalactite_height > 0
			and stalagmite_height > 0
			and (floor and ceiling)
			and ((stalactite_height + stalagmite_height)
				>= (floor - ceiling + 1))

		if ceiling then
			spawn_pointed_dripstone (x, ceiling - 1, z, -1,
						 stalactite_height, contact)
		end
		if floor then
			spawn_pointed_dripstone (x, floor + 1, z, 1,
						 stalagmite_height, contact)
		end
	end

	return water_generated, floor
end

local function place_dripstone_cluster (_, x, y, z, cfg, rng)
	dripstone_rng:reseed (rng:next_long ())
	local rng = dripstone_rng

	local run_maxp = mcl_levelgen.placement_run_maxp
	local run_minp = mcl_levelgen.placement_run_minp
	if not air_or_water_p (x, y, z)
		or y < run_minp.y or y > run_maxp.y then
		return false
	end

	local height = cfg.height (rng)
	local wetness = cfg.wetness (rng)
	local density = cfg.density (rng)

	local radius = cfg.radius
	local radius_x = radius (rng)
	local radius_z = radius (rng)
	local water_generated = false
	local floor_min, floor_max = huge, -huge

	for dx = -radius_x, radius_x do
		for dz = -radius_z, radius_z do
			local dripstone_probability
				= distance_to_dripstone_probability (radius_x, radius_z,
								     dx, dz, cfg)
			local water, floor
				= generate (x + dx, y, z + dz,
					    dx, dz, wetness, dripstone_probability,
					    height, density, cfg)
			if water then
				floor_min = mathmin (floor, floor_min)
				floor_max = mathmax (floor, floor_max)
				water_generated = true
			end
		end
	end

	if water_generated then
		fix_lighting (x - radius_x, floor_min, z - radius_z,
			      x + radius_x, floor_max, z + radius_z)
	end
	return true
end

local function uniform_height (min_inclusive, max_inclusive)
	local diff = max_inclusive - min_inclusive + 1
	return function (rng)
		return rng:next_within (diff) + min_inclusive
	end
end

local function uniform_float (min_inclusive, max_inclusive)
	local diff = max_inclusive - min_inclusive
	return function (rng)
		return rng:next_float () * diff + min_inclusive
	end
end

mcl_levelgen.register_feature ("mcl_dripstone:dripstone_cluster", {
	place = place_dripstone_cluster,
})

mcl_levelgen.register_configured_feature ("mcl_dripstone:dripstone_cluster", {
	feature = "mcl_dripstone:dripstone_cluster",
	density = uniform_float (0.3, 0.7),
	dripstone_block_layer_thickness = uniform_height (2, 4),
	floor_to_ceiling_search_range = 12,
	height = uniform_height (3, 6),
	height_deviation = 3,
	chance_of_dripstone_column_at_max_distance_from_center = 0.1,
	max_distance_from_center_affecting_height_bias = 8,
	max_distance_from_edge_affecting_chance_of_dripstone_column = 3,
	max_stalagmite_stalactite_height_diff = 1,
	radius = uniform_height (2, 8),
	wetness = function (rng)
		return clamped_gaussian (rng, 0.1, 0.9, 0.1, 0.3)
	end,
})

local overworld = mcl_levelgen.overworld_preset
local OVERWORLD_MIN = overworld.min_y

mcl_levelgen.register_placed_feature ("mcl_dripstone:dripstone_cluster", {
	configured_feature = "mcl_dripstone:dripstone_cluster",
	placement_modifiers = {
		mcl_levelgen.build_count (uniform_height (48, 96)),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 256)),
		mcl_levelgen.build_in_biome (),
	},
})

-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/SmallDripstoneFeature.html

-- local pointed_dripstone_cfg = {
-- 	chance_of_taller_dripstone = 0.2,
-- 	chance_of_directional_spread = 0.7,
-- 	chance_of_spread_radius2 = 0.5,
-- 	chance_of_spread_radius3 = 0.5,
-- }

local function select_dir (x, y, z, rng)
	local cid_above, _ = get_block (x, y + 1, z)
	local cid_below, _ = get_block (x, y - 1, z)
	local base_above = dripstone_base_p (cid_above)
	local base_below = dripstone_base_p (cid_below)
	if base_above and base_below then
		return rng:next_boolean () and -1 or 1
	elseif base_above then
		return -1
	elseif base_below then
		return 1
	else
		return nil
	end
end

local function spread_one (x, y, z)
	local cid, param2 = get_block (x, y, z)
	if not dripstone_replaceable_p (cid) then
		return
	end
	set_block (x, y, z, cid_dripstone_block, param2)
end

local dirs = {
	{ -1, 0, },
	{ 0, -1, },
	{ 1, 0, },
	{ 0, 1, },
}

local band = bit.band
local function random_dir (rng)
	return dirs[band (rng:next_integer (), 3) + 1]
end

local function spread_dripstone_block_1 (x, y, z, chance, chance1, chance2, rng)
	if rng:next_float () < chance then
		spread_one (x, y, z)
		if rng:next_float () > chance1 then
			local dir = random_dir (rng)
			spread_one (x + dir[1], y, z + dir[2])
			if rng:next_float () > chance2 then
				local dir = random_dir (rng)
				spread_one (x + dir[1], y, z + dir[2])
			end
		end
	end
end

local function spread_dripstone_block (x, y, z, cfg, rng)
	spread_one (x, y, z)
	local chance = cfg.chance_of_directional_spread
	local chance1 = cfg.chance_of_spread_radius2
	local chance2 = cfg.chance_of_spread_radius3

	spread_dripstone_block_1 (x - 1, y, z, chance, chance1, chance2, rng)
	spread_dripstone_block_1 (x, y, z - 1, chance, chance1, chance2, rng)
	spread_dripstone_block_1 (x + 1, y, z, chance, chance1, chance2, rng)
	spread_dripstone_block_1 (x, y, z + 1, chance, chance1, chance2, rng)
end

local function place_pointed_dripstone (_, x, y, z, cfg, rng)
	dripstone_rng:reseed (rng:next_long ())
	local rng = dripstone_rng

	local run_maxp = mcl_levelgen.placement_run_maxp
	local run_minp = mcl_levelgen.placement_run_minp
	if y < run_minp.y or y > run_maxp.y then
		return false
	end

	local dir = select_dir (x, y, z, rng)
	if dir then
		spread_dripstone_block (x, y + -dir, z, cfg, rng)

		local height = 1
		if rng:next_float () < cfg.chance_of_taller_dripstone
			and air_or_water_p (x, y + dir, z) then
			height = 2
		end

		spawn_pointed_dripstone (x, y, z, dir, height, false)
		return true
	end
	return false
end

mcl_levelgen.register_feature ("mcl_dripstone:pointed_dripstone", {
	place = place_pointed_dripstone,
})

mcl_levelgen.register_configured_feature ("mcl_dripstone:pointed_dripstone_1", {
	feature = "mcl_dripstone:pointed_dripstone",
	chance_of_directional_spread = 0.7,
	chance_of_spread_radius2 = 0.5,
	chance_of_spread_radius3 = 0.5,
	chance_of_taller_dripstone = 0.2,
})

mcl_levelgen.register_configured_feature ("mcl_dripstone:pointed_dripstone", {
	feature = "mcl_levelgen:simple_random_selector",
	features = {
		{
			configured_feature = "mcl_dripstone:pointed_dripstone_1",
			placement_modifiers = {
				E ({
					direction = -1,
					max_steps = 12,
					allowed_search_condition = air_or_water_p,
					target_condition
						= mcl_levelgen.is_position_walkable,
				}),
				mcl_levelgen.build_constant_height_offset (1),
			},
		},
		{
			configured_feature = "mcl_dripstone:pointed_dripstone_1",
			placement_modifiers = {
				E ({
					direction = 1,
					max_steps = 12,
					allowed_search_condition = air_or_water_p,
					target_condition
						= mcl_levelgen.is_position_walkable,
				}),
				mcl_levelgen.build_constant_height_offset (-1),
			},
		},
	},
})

local function rtz (n)
	if n < 0 then
		return ceil (n)
	end
	return floor (n)
end

local function clamped_gaussian_int (mean, dev, min, max)
	return function (rng)
		return rtz (clamped_gaussian (rng, min, max, mean, dev))
	end
end

mcl_levelgen.register_placed_feature ("mcl_dripstone:pointed_dripstone", {
	configured_feature = "mcl_dripstone:pointed_dripstone",
	placement_modifiers = {
		mcl_levelgen.build_count (uniform_height (192, 256)),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 256)),
		mcl_levelgen.build_count (uniform_height (0, 5)),
		mcl_levelgen.build_random_offset (clamped_gaussian_int (0.0, 3.0, 10, -10),
						  clamped_gaussian_int (0.0, 0.6, 2, -2)),
		mcl_levelgen.build_in_biome (),
	},
})

-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/LargeDripstoneFeature.html

-- local large_ceiling_configuration = {
-- 	floor_to_ceiling_search_range = nil,
-- 	column_radius_min = nil,
-- 	column_radius_max = nil,
-- 	height_scale = nil,
-- 	max_column_radius_to_cave_height_ratio = nil,
-- 	stalactite_bluntness = nil,
-- 	stalagmite_bluntness = nil,
-- 	wind_speed = nil,
-- 	min_radius_for_wind = nil,
-- 	min_bluntness_for_wind = nil,
-- }

local pi = math.pi
local mathcos = math.cos
local mathsin = math.sin
local mathpow = math.pow
local mathlog = math.log
local mathsqrt = math.sqrt

local function assess_dripstone_base (x, y, z, radius)
	if air_or_water_p (x, y, z) then
		return false
	end

	local granularity = 6.0 / radius
	local dir = 0.0

	while dir < pi * 2 do
		local dx = rtz (mathcos (dir) * radius)
		local dz = rtz (mathsin (dir) * radius)

		if air_water_or_lava_p (x + dx, y, z + dz) then
			return false
		end

		dir = dir + granularity
	end
	return true
end

local function dripstone_height (d, radius, height_scale, bluntness)
	-- https://minecraft.wiki/w/Dripstone_(feature)#/media/File:Dripstone_Math.jpg
	local r = mathmax (d, bluntness)
	local t0 = r / radius * 0.384 -- 0.384 is the zero of the function.
	local t1 = 3/4 * mathpow (t0, 4/3)
	local t2 = mathpow (t0, 2/3)
	local t3 = mathlog (t0) * 1/3
	local t4 = height_scale * (t1 - t2 - t3)
	return mathmax (t4, 0.0) / 0.384 * radius
end

local function center_height (parms)
	return dripstone_height (0.0, parms.radius, parms.scale, parms.bluntness)
end

local function prepare_to_generate (parms, initial_y)
	local x = parms.origin_x
	local z = parms.origin_z
	local y = parms.origin_y
	local y_lim = (parms.is_stalagmite and 32 or -32) + initial_y
	local max_movement = mathmin (10, mathabs (y_lim - y) + 1,
				      center_height (parms))
	local dir = -parms.dir

	-- Reduce the radius while searching for a sufficient amount
	-- of stone to which to attach.
	local radius = parms.radius
	while radius > 1 do
		for i = 0, max_movement - 1 do
			if lava_p (x, y + dir * i, z) then
				return false
			end
			if assess_dripstone_base (x, y + dir * i, z, radius) then
				parms.origin_y = y + dir * i
				parms.radius = radius
				return true
			end
		end

		radius = floor (radius / 2)
	end
	return false
end

local index_heightmap = mcl_levelgen.index_heightmap
local vectornew = vector.new

local function generate_large_dripstone (parms, rng, wind)
	local radius, scale, bluntness
		= parms.radius, parms.scale, parms.bluntness
	local dir = parms.dir
	local y, origin_y = parms.origin_y, parms.origin_y
	local x, z = parms.origin_x, parms.origin_z
	local max = parms.is_stalagmite	and (index_heightmap (x, z, true)) or huge
	for dx = -radius, radius do
		for dz = -radius, radius do
			local dist = mathsqrt (dx * dx + dz * dz)
			local x, z = x + dx, z + dz
			if dist <= radius then
				local height = dripstone_height (dist, radius,
								 scale, bluntness)
				if height > 0 then
					if rng:next_float () < 0.2 then
						local f = rng:next_float () * 0.2 + 0.8
						height = height * f
					end

					local placed = false
					for y = y, mathmin (y + (height - 1) * dir, max), dir do
						local x = x
						local z = z
						if wind then
							x = floor (x + (origin_y - y) * wind.x)
							z = floor (z + (origin_y - y) * wind.z)
						end
						if air_water_or_lava_p (x, y, z) then
							placed = true
							set_block (x, y, z, cid_dripstone_block, 0)
						elseif placed then
							-- Cut short by stone.
							if dripstone_replaceable_p (x, y, z) then
								break
							end
						end
					end
				end
			end
		end
	end
end

local function large_dripstone_place (_, x, y, z, cfg, rng)
	dripstone_rng:reseed (rng:next_long ())
	local rng = dripstone_rng

	local run_maxp = mcl_levelgen.placement_run_maxp
	local run_minp = mcl_levelgen.placement_run_minp
	if not air_or_water_p (x, y, z)
		or y < run_minp.y or y > run_maxp.y then
		return false
	end

	local search_range = cfg.floor_to_ceiling_search_range
	local ceiling, floor
		= find_ceiling_and_floor (x, y, z, search_range, air_or_water_p,
					  not_air_or_water_p)

	if ceiling and floor then
		local interval = ceiling - floor - 1
		if interval < 4 then
			return false
		end

		local r_min = cfg.column_radius_min
		local r_max = cfg.column_radius_max
		local ratio = cfg.max_column_radius_to_cave_height_ratio
		local rbound = mathmin (mathmax (r_min, interval * ratio), r_max)
		local radius = r_min + rng:next_within (rbound - r_min + 1)
		local stalactite_parms = {
			origin_x = x,
			origin_y = ceiling - 1,
			origin_z = z,
			radius = radius,
			bluntness = cfg.stalactite_bluntness (rng),
			scale = cfg.height_scale (rng),
			is_stalagmite = false,
			dir = -1,
		}
		local stalagmite_parms = {
			origin_x = x,
			origin_y = floor + 1,
			origin_z = z,
			radius = radius,
			bluntness = cfg.stalagmite_bluntness (rng),
			scale = cfg.height_scale (rng),
			is_stalagmite = true,
			dir = 1,
		}

		local min_wind, min_wind_bluntness
			= cfg.min_radius_for_wind, cfg.min_bluntness_for_wind
		local wind = nil
		if stalagmite_parms.radius >= min_wind
			and stalagmite_parms.bluntness >= min_wind_bluntness
			and stalactite_parms.radius >= min_wind
			and stalactite_parms.bluntness >= min_wind_bluntness then
			local speed = cfg.wind_speed (rng)
			local dir = rng:next_float () * pi
			wind = vectornew (mathcos (dir) * speed, 0, mathsin (dir) * speed)
		end

		if prepare_to_generate (stalactite_parms, y) then
			generate_large_dripstone (stalactite_parms, rng, wind)
			local height = center_height (stalactite_parms)
			fix_lighting (x - radius, ceiling - height, z - radius,
				      x + radius, ceiling - 1, z + radius)
		end
		if prepare_to_generate (stalagmite_parms, y) then
			generate_large_dripstone (stalagmite_parms, rng, wind)
			local height = center_height (stalagmite_parms)
			fix_lighting (x - radius, floor + height, z - radius,
				      x + radius, floor + 1, z + radius)
		end
		return true
	end
	return false
end

mcl_levelgen.register_feature ("mcl_dripstone:large_dripstone", {
	place = large_dripstone_place,
})

mcl_levelgen.register_configured_feature ("mcl_dripstone:large_dripstone", {
	feature = "mcl_dripstone:large_dripstone",
	column_radius_min = 3,
	column_radius_max = 19,
	floor_to_ceiling_search_range = 30,
	height_scale = uniform_float (0.4, 2.0),
	max_column_radius_to_cave_height_ratio = 0.33,
	min_bluntness_for_wind = 0.6,
	min_radius_for_wind = 4,
	stalactite_bluntness = uniform_float (0.3, 0.9),
	stalagmite_bluntness = uniform_float (0.4, 1.0),
	wind_speed = uniform_float (0.0, 0.3),
})

mcl_levelgen.register_placed_feature ("mcl_dripstone:large_dripstone", {
	configured_feature = "mcl_dripstone:large_dripstone",
	placement_modifiers = {
		mcl_levelgen.build_count (uniform_height (10, 48)),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 256)),
		mcl_levelgen.build_in_biome (),
	},
})
