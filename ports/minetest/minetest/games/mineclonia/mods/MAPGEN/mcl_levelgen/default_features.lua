local mcl_levelgen = mcl_levelgen
local ipairs = ipairs
local pairs = pairs

------------------------------------------------------------------------
-- Fundamental features.
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Random selector.
-- mcl_levelgen:random_selector
------------------------------------------------------------------------

local registered_placed_features = mcl_levelgen.registered_placed_features
local place_one_feature = mcl_levelgen.place_one_feature
local warned = {}

local function random_selector_place (_, x, y, z, cfg, rng)
	for _, feature in ipairs (cfg.features) do
		local id = feature.feature

		if rng:next_float () < feature.chance then
			local feature_desc = type (id) == "table"
				and id
				or registered_placed_features[id]
			if not feature_desc and not warned[id] then
				core.log ("warning", table.concat ({
					"Random selector attempted to place a ",
					"nonexistent placed feature, ", id,
				}))
				warned[id] = true
			elseif feature_desc then
				place_one_feature (feature_desc, x, y, z)
				return
			end
		end
	end

	local default_desc = type (cfg.default) == "table"
		and cfg.default
		or registered_placed_features[cfg.default]
	if not default_desc then
		if not warned[cfg.default] then
			core.log ("warning", table.concat ({
				"Random selector attempted to place a ",
				"nonexistent default placed feature, ", cfg.default,
			}))
			warned[cfg.default] = true
		end
		return
	end
	place_one_feature (default_desc, x, y, z)
end

mcl_levelgen.register_feature ("mcl_levelgen:random_selector", {
	place = random_selector_place,
})

------------------------------------------------------------------------
-- Simple random selector.
-- mcl_levelgen:simple_random_selector
------------------------------------------------------------------------

local registered_placed_features = mcl_levelgen.registered_placed_features
local place_one_feature = mcl_levelgen.place_one_feature

local function simple_random_selector_place (_, x, y, z, cfg, rng)
	local values = #cfg.features
	assert (values > 0)
	local idx = 1 + rng:next_within (values)
	local id = cfg.features[idx]
	local feature_desc = type (id) == "table"
		and id
		or registered_placed_features[id]
	if not feature_desc and not warned[id] then
		core.log ("warning", table.concat ({
			"Random selector attempted to place a ",
			"nonexistent placed feature, ", id,
		}))
		warned[id] = true
	elseif feature_desc then
		place_one_feature (feature_desc, x, y, z)
		return
	end
end

mcl_levelgen.register_feature ("mcl_levelgen:simple_random_selector", {
	place = simple_random_selector_place,
})

------------------------------------------------------------------------
-- Freeze Top Layer
-- mcl_levelgen:freeze_top_layer
------------------------------------------------------------------------

local index_biome = mcl_levelgen.index_biome
local index_heightmap = mcl_levelgen.index_heightmap
local get_block = mcl_levelgen.get_block
local set_block = mcl_levelgen.set_block
local cid_air = core.CONTENT_AIR
local cid_snow = core.get_content_id ("mcl_core:snow")
local cid_water_source = core.get_content_id ("mcl_core:water_source")
local cid_ice = core.get_content_id ("mcl_core:ice")
local cid_grass = core.get_content_id ("mcl_core:dirt_with_grass")
local cid_grass_snowy = core.get_content_id ("mcl_core:dirt_with_grass_snow")
local cid_mycelium = core.get_content_id ("mcl_core:mycelium")
local cid_mycelium_snow = core.get_content_id ("mcl_core:mycelium_snow")
local cid_podzol = core.get_content_id ("mcl_core:podzol")
local cid_podzol_snow = core.get_content_id ("mcl_core:podzol_snow")

local snowy_blocks = {
	[cid_grass] = cid_grass_snowy,
	[cid_mycelium] = cid_mycelium_snow,
	[cid_podzol] = cid_podzol_snow,
}

local exposed_blocks = {
	[cid_grass_snowy] = cid_grass,
	[cid_mycelium_snow] = cid_mycelium,
	[cid_podzol_snow] = cid_podzol,
}

local unpack_heightmap_modification
	= mcl_levelgen.unpack_heightmap_modification

local function freeze_layer_common (x1, z1, surface)
	local biome = index_biome (x1, surface, z1)
	local frigid
		= mcl_levelgen.is_temp_snowy (biome, x1, surface, z1)

	if frigid then
		-- Freeze the node below if it is
		-- water and not brighter than 10.
		-- TODO: test light levels.
		local cid, _ = get_block (x1, surface - 1, z1)
		if cid == cid_water_source then
			set_block (x1, surface - 1, z1, cid_ice, 255)
			-- Place one snow layer if the
			-- temperature is sufficiently frigid.
		elseif mcl_levelgen.can_place_snow (x1, surface, z1) then
			set_block (x1, surface, z1, cid_snow, 0)
			local replacement = snowy_blocks[cid]
			if replacement then
				set_block (x1, surface - 1, z1, replacement, -1)
			end
		end
	end
end

local function place_freeze_top_layer (_, x, y, z, cfg, rng)
	local start_y = mcl_levelgen.placement_run_minp.y
	local end_y = mcl_levelgen.placement_run_maxp.y
	local heightmap_modifications = mcl_levelgen.heightmap_modifications

	for key, value in pairs (heightmap_modifications) do
		local x, z, surface, _
			= unpack_heightmap_modification (key, value)
		local surface = surface - 1

		-- If the surface has moved, remove any snow layers or
		-- ice that may have been placed at the previous location
		local old_cid, _ = get_block (x, surface, z)
		if old_cid == cid_snow then
			set_block (x, surface, z, cid_air, 0)

			local old_cid, param2 = get_block (x, surface - 1, z)
			local replacement = exposed_blocks[old_cid]
			if replacement then
				set_block (x, surface - 1, z, replacement, param2)
			end
		end

		local old_cid, param2 = get_block (x, surface, z)
		-- A param2 of 255 indicates that this
		-- ice was placed by freeze_top_layer.
		if old_cid == cid_ice and param2 == 255 then
			set_block (x, surface, z, cid_water_source, 0)
		end

		local surface_new, _ = index_heightmap (x, z, false)
		if surface_new >= start_y - 31 and surface <= end_y + 32 then
			freeze_layer_common (x, z, surface_new)
		end
	end

	for dx = 0, 15 do
		for dz = 0, 15 do
			local x1, z1 = x + dx, z + dz
			local surface, _ = index_heightmap (x1, z1, false)
			if surface >= start_y and surface <= end_y then
				freeze_layer_common (x1, z1, surface)
			end
		end
	end
end

mcl_levelgen.register_feature ("mcl_levelgen:freeze_top_layer", {
	place = place_freeze_top_layer,
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:freeze_top_layer", {
	feature = "mcl_levelgen:freeze_top_layer",
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:freeze_top_layer", {
	configured_feature = "mcl_levelgen:freeze_top_layer",
	placement_modifiers = {},
})

------------------------------------------------------------------------
-- Ore placement.
-- mcl_levelgen:ore
------------------------------------------------------------------------

local mathsin = math.sin
local mathcos = math.cos
local mathmin = math.min
local mathmax = math.max
local floor = math.floor
local ceil = math.ceil

-- local ore_configuration = {
-- 	substitutions = {},
-- 	size = "",
-- 	discard_chance_on_air_exposure = 0.0,
-- }

local run_minp = mcl_levelgen.placement_run_minp
local run_maxp = mcl_levelgen.placement_run_maxp
local pi = math.pi

local lerp1d = mcl_levelgen.lerp1d
local adjoins_air = mcl_levelgen.adjoins_air

local function ore_placement_test (cid, x, y, z, rng, cfg)
	for _, substitution in ipairs (cfg.substitutions) do
		if substitution[1] == cid then
			local chance = cfg.discard_chance_on_air_exposure
			if (chance >= 1.0 or (chance > 0.0
					      and rng:next_float () < chance))
				and adjoins_air (x, y, z) then
				return nil, nil
			end

			return substitution[2], substitution[3]
		end
	end

	return nil, nil
end

mcl_levelgen.ore_placement_test = ore_placement_test

local function orehash (x1, y1, z1, cx, cy, cz)
	local dx = x1 - cx + 256
	local dz = y1 - cy + 256
	local dy = z1 - cz + 256
	return ((dx * 512 + dz) * 512) + dy
end

local function ore_place_1 (x1, x2, z1, z2, y1, y2,
			    xmin, ymin, zmin, hsize,
			    ysize, cfg, rng)
	local placed = false
	local cnt_ores = cfg.size

	-- Array of tuples of four elements supplying the position of
	-- each blob and its radius
	local ore_poses = {}

	local r = 1 / (cnt_ores * 4)
	for i = 1, cnt_ores * 4, 4 do
		local progress = i * r
		local x = lerp1d (progress, x1, x2)
		local y = lerp1d (progress, y1, y2)
		local z = lerp1d (progress, z1, z2)
		local blob_radius = rng:next_double ()
			* cnt_ores / 16.0
		local blob_radius_1
			= ((mathsin (pi * progress) + 1.0)
				* blob_radius + 1.0) / 2.0

		ore_poses[i] = x
		ore_poses[i + 1] = y
		ore_poses[i + 2] = z
		ore_poses[i + 3] = blob_radius_1
	end

	-- Delete blobs that intersect too egregiously.
	for i = 0, cnt_ores - 2 do
		local idx = i * 4 + 1

		if ore_poses[idx + 3] > 0.0 then
			for i = 0, cnt_ores - 1 do
				local idx1 = i * 4 + 1
				if ore_poses[idx1 + 3] > 0.0 then
					local dx = ore_poses[idx] - ore_poses[idx1]
					local dy = ore_poses[idx + 1] - ore_poses[idx1 + 1]
					local dz = ore_poses[idx + 2] - ore_poses[idx1 + 2]
					local dradius
						= ore_poses[idx + 3] - ore_poses[idx1 + 3]
					local d = dx * dx + dy * dy + dz * dz
					if dradius * dradius > d then
						if dradius > 0.0 then
							ore_poses[idx1 + 3] = -1.0
						else
							ore_poses[idx + 3] = -1.0
						end
					end
				end
			end
		end
	end

	-- Place each blob, taking care not to place the same blob
	-- twice.
	local written = {}

	for i = 1, cnt_ores * 4, 4 do
		local r = ore_poses[i + 3]
		if r >= 0.0 then
			local cx = ore_poses[i]
			local cy = ore_poses[i + 1]
			local cz = ore_poses[i + 2]
			local bxmin = mathmax (floor (cx - r), xmin)
			local bymin = mathmax (floor (cy - r), ymin)
			local bzmin = mathmax (floor (cz - r), zmin)
			local sr = 1 / r
			local bxmax = mathmin (mathmax (floor (cx + r), bxmin),
					       xmin + hsize - 1)
			local bzmax = mathmin (mathmax (floor (cz + r), bzmin),
					       zmin + hsize - 1)
			local bymax = mathmin (mathmax (floor (cy + r), bymin),
					       ymin + ysize - 1)
			local org_x, org_y, org_z = x1, y1, z1

			for x = bxmin, bxmax do
				for y = bymin, bymax do
					for z = bzmin, bzmax do
						local dx = (x + 0.5 - cx) * sr
						local dy = (y + 0.5 - cy) * sr
						local dz = (z + 0.5 - cz) * sr

						if dx * dx + dy * dy + dz * dz < 1.0 then
							local hash = orehash (x, y, z, org_x,
									      org_y, org_z)
							if not written[hash] then
								written[hash] = true
								local cid, _ = get_block (x, y, z)
								if cid then
									local param2
									cid, param2 = ore_placement_test (cid, x, y, z,
													  rng, cfg)
									if cid then
										set_block (x, y, z, cid, param2)
										placed = true
									end
								end
							end
						end
					end
				end
			end
		end
	end
	return placed
end

local function ore_place (_, x, y, z, cfg, rng)
	if y < run_minp.y or y > run_maxp.y then
		return false
	end

	-- Derive the bounds of the ellipsoid in which ores will be
	-- placed in individual blobs.

	local dir = rng:next_float () * pi
	local BLOCKS_PER_BLOB = 8.0
	local size_ellipsoid = cfg.size / BLOCKS_PER_BLOB
	local size_half = ceil ((cfg.size / BLOCKS_PER_BLOB + 1.0) / 2.0)

	-- Bounds of ellipsoid within which blobs may generate.
	local x1 = x - mathsin (dir) * size_ellipsoid
	local x2 = x + mathsin (dir) * size_ellipsoid
	local z1 = z - mathcos (dir) * size_ellipsoid
	local z2 = z + mathcos (dir) * size_ellipsoid
	local y1 = y + rng:next_within (3) - 2 -- -2 to 0
	local y2 = y + rng:next_within (3) - 2 -- -2 to 0

	-- Absolute confines of level modification.  The largest
	-- naturally generating ore (tuff) has a size of 64 and
	-- consequently the maximum extent of an ore vein on any axis
	-- is 13*2 blocks from the center, which is comfortably within
	-- the 32 block feature size limit.

	local hradius = ceil (size_ellipsoid) + size_half
	local xmin = x - hradius
	local zmin = z - hradius
	local ymin = y - 2 - size_half -- 2 = blob height.
	local hsize = hradius * 2.0
	local ysize = (2 + size_half) * 2.0

	-- Verify that at least one position within these confines is
	-- beneath the surface of the level.
	for x = xmin, xmin + hsize do
		for z = zmin, zmin + hsize do
			local _, blocking = index_heightmap (x, z, false)
			if ymin <= blocking then
				return ore_place_1 (x1, x2, z1, z2, y1, y2,
						    xmin, ymin, zmin, hsize,
						    ysize, cfg, rng)
			end
		end
	end
	return false
end

mcl_levelgen.register_feature ("mcl_levelgen:ore", {
	place = ore_place,
})

function mcl_levelgen.construct_ore_substitution_list (items)
	local substitutions = {}

	for _, tbl in ipairs (items) do
		local cids = {}
		local target = tbl.target
		if target:sub (1, 6) == "group:" then
			local group = target:sub (7)
			for name, tbl in pairs (core.registered_nodes) do
				if tbl.groups[group] and tbl.groups[group] > 0 then
					local id = core.get_content_id (name)
					table.insert (cids, id)
				end
			end
		else
			table.insert (cids, core.get_content_id (target))
		end

		for _, cid in ipairs (cids) do
			table.insert (substitutions, {
				cid, core.get_content_id (tbl.replacement),
				tbl.param2 or 0,
			})
		end
	end
	return substitutions
end

------------------------------------------------------------------------
-- Patch.
-- mcl_levelgen:random_patch
------------------------------------------------------------------------

local fix_lighting = mcl_levelgen.fix_lighting

-- local patch_configuration = {
-- 	placed_feature = nil,
-- 	tries = nil,
-- 	xz_spread = nil,
-- 	y_spread = nil,
-- }

local function patch_random_place (_, x, y, z, cfg, rng)
	if y < run_minp.y or y > run_maxp.y then
		return false
	end

	local feature = cfg.placed_feature
	if type (feature) == "string" then
		feature = mcl_levelgen.registered_placed_features[feature]
		if not feature then
			if not warned[feature] then
				local blurb = "Patch attempted to place nonexistent feature: "
				core.log ("warning", blurb .. feature)
				warned[feature] = true
			end
			return false
		end
	end

	local yspread = cfg.y_spread + 1
	local xzspread = cfg.xz_spread + 1
	local placed = false
	for i = 1, cfg.tries do
		-- Triangular distribution.
		local dx = rng:next_within (xzspread)
			- rng:next_within (xzspread)
		local dy = rng:next_within (yspread)
			- rng:next_within (yspread)
		local dz = rng:next_within (xzspread)
			- rng:next_within (xzspread)

		if place_one_feature (feature, x + dx, y + dy, z + dz) then
			placed = true
		end
	end

	if placed and cfg.fix_lighting then
		fix_lighting (x - xzspread, y - yspread, z - xzspread,
			      x + xzspread, y + yspread, z + xzspread)
	end

	return placed
end

mcl_levelgen.register_feature ("mcl_levelgen:random_patch", {
	place = patch_random_place,
})

------------------------------------------------------------------------
-- Simple block feature.
-- mcl_levelgen:simple_block
------------------------------------------------------------------------

local double_plant_p = mcl_levelgen.double_plant_p
local is_position_hospitable = mcl_levelgen.is_position_hospitable

local place_double_plant = mcl_levelgen.place_double_plant
local ull = mcl_levelgen.ull
local simple_block_rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))

local function simple_block_place (_, x, y, z, cfg, rng)
	simple_block_rng:reseed (rng:next_long ())
	if y < run_minp.y or y > run_maxp.y then
		return false
	end

	local cid_to_place, param2
		= cfg.content (x, y, z, simple_block_rng)
	if param2 == "grass_palette_index" then
		local biome = index_biome (x, y, z)
		local def = mcl_levelgen.registered_biomes[biome]
		param2 = def and def.grass_palette_index or 0
	end

	if is_position_hospitable (cid_to_place, x, y, z) then
		if double_plant_p (cid_to_place) then
			if (get_block (x, y + 1, z)) ~= cid_air then
				return false
			end
			place_double_plant (cid_to_place, x, y, z, param2,
					    set_block)
		else
			set_block (x, y, z, cid_to_place, param2)
		end
		return true
	end
	return false
end

mcl_levelgen.register_feature ("mcl_levelgen:simple_block", {
	place = simple_block_place,
})

------------------------------------------------------------------------
-- Fundamental placement modifiers.
------------------------------------------------------------------------

-- Weighted lists.

function mcl_levelgen.build_weighted_list (list)
	local total_weight = 0
	for _, entry in ipairs (list) do
		total_weight = total_weight + entry.weight
	end
	return function (rng)
		if total_weight == 0 then
			return nil
		else
			local cnt = rng:next_within (total_weight)
			for _, entry in ipairs (list) do
				cnt = cnt - entry.weight
				if cnt < 0 then
					if type (entry.data) == "number" then
						return entry.data
					else
						return entry.data (rng)
					end
				end
			end
			return nil
		end
	end
end

function mcl_levelgen.build_weighted_cid_provider (list)
	local total_weight = 0
	for _, entry in ipairs (list) do
		total_weight = total_weight + entry.weight
	end
	return function (x, y, z, rng)
		if total_weight == 0 then
			return nil, nil
		else
			local cnt = rng:next_within (total_weight)
			for _, entry in ipairs (list) do
				cnt = cnt - entry.weight
				if cnt < 0 then
					return entry.cid, entry.param2
				end
			end
			return nil, nil
		end
	end
end

function mcl_levelgen.build_count (n)
	return function (x, y, z, rng)
		local cnt = n (rng)
		local results = {}
		for i = 1, cnt do
			results[#results + 1] = x
			results[#results + 1] = y
			results[#results + 1] = z
		end
		return results
	end
end

local BIOME_SELECTOR_NOISE = mcl_levelgen.BIOME_SELECTOR_NOISE

function mcl_levelgen.build_noise_threshold_count (noise_level, above_noise,
						   below_noise)
	return function (x, y, z, rng)
		local noise = BIOME_SELECTOR_NOISE (x / 200.0, z / 200.0)
		local cnt = above_noise
		if noise < noise_level then
			cnt = below_noise
		end
		local results = {}
		for i = 1, cnt do
			results[#results + 1] = x
			results[#results + 1] = y
			results[#results + 1] = z
		end
		return results
	end
end

function mcl_levelgen.build_noise_based_count (noise_to_count_ratio, noise_factor,
					       noise_offset)
	return function (x, y, z, rng)
		local noise = BIOME_SELECTOR_NOISE (x / noise_factor,
						    z / noise_factor)
		local cnt = ceil ((noise + noise_offset) * noise_to_count_ratio)
		local results = {}
		for i = 1, cnt do
			results[#results + 1] = x
			results[#results + 1] = y
			results[#results + 1] = z
		end
		return results
	end
end

local function in_square (x, y, z, rng)
	return {
		x + rng:next_within (16),
		y,
		z + rng:next_within (16),
	}
end

function mcl_levelgen.build_in_square ()
	return in_square
end

local registered_biomes = mcl_levelgen.registered_biomes
local indexof = table.indexof

function mcl_levelgen.build_in_biome ()
	local last_biome, last_result = nil, nil
	return function (x, y, z, rng)
		local biome = index_biome (x, y, z)
		local current_feature = mcl_levelgen.current_placed_feature
		local current_step = mcl_levelgen.current_step
		if biome ~= last_biome then
			local def = registered_biomes[biome]
			local step_features = def.features[current_step]
			last_result = step_features
				and indexof (step_features,
					     current_feature) ~= -1
			last_biome = biome
		end
		return last_result and { x, y, z, } or nil
	end
end

local index_heightmap = mcl_levelgen.index_heightmap

local function heightmap_world_surface (x, y, z, rng)
	local surface, _ = index_heightmap (x, z, false)

	if surface <= mcl_levelgen.placement_level_min then
		return {}
	else
		return { x, surface, z, }
	end
end

local function heightmap_motion_blocking (x, y, z, rng)
	local _, surface = index_heightmap (x, z, false)

	if surface <= mcl_levelgen.placement_level_min then
		return {}
	else
		return { x, surface, z, }
	end
end

local function heightmap_world_surface_wg (x, y, z, rng)
	local surface, _ = index_heightmap (x, z, true)

	if surface <= mcl_levelgen.placement_level_min then
		return {}
	else
		return { x, surface, z, }
	end
end

local function heightmap_motion_blocking_wg (x, y, z, rng)
	local _, surface = index_heightmap (x, z, true)

	if surface <= mcl_levelgen.placement_level_min then
		return {}
	else
		return { x, surface, z, }
	end
end

function mcl_levelgen.build_heightmap (heightmap)
	assert (heightmap == "world_surface"
		or heightmap == "motion_blocking"
		or heightmap == "world_surface_wg"
		or heightmap == "motion_blocking_wg")

	if heightmap == "world_surface" then
		return heightmap_world_surface
	elseif heightmap == "motion_blocking" then
		return heightmap_motion_blocking
	elseif heightmap == "world_surface_wg" then
		return heightmap_world_surface_wg
	elseif heightmap == "motion_blocking_wg" then
		return heightmap_motion_blocking_wg
	end
end

local MIN_POS = -32768

function mcl_levelgen.build_surface_water_depth_filter (n)
	return function (x, y, z, rng)
		local surface, motion_blocking
			= index_heightmap (x, z, false)
		if surface - motion_blocking <= n then
			return { x, y, z, }
		else
			return nil
		end
	end
end

function mcl_levelgen.build_surface_relative_threshold_filter (heightmap,
							       min_inclusive,
							       max_inclusive)
	assert (heightmap == "world_surface"
		or heightmap == "motion_blocking"
		or heightmap == "world_surface_wg"
		or heightmap == "motion_blocking_wg")
	local heightmap = (heightmap == "motion_blocking_wg" and "motion_blocking")
		or (heightmap == "world_surface_wg" and "world_surface")
		or heightmap
	local generation_only = heightmap == "world_surface_wg"
		or heightmap == "motion_blocking_wg"
	return function (x, y, z, rng)
		local surface, motion_blocking
			= index_heightmap (x, z, generation_only)
		local y_test = heightmap == "motion_blocking"
			and motion_blocking or surface

		local min = y_test + min_inclusive
		local max = y_test + max_inclusive
		if min <= y and y <= max then
			return { x, y, z, }
		else
			return { x, MIN_POS, z, }
		end
	end
end

local function in_range (x, y, z)
	local min_x = mcl_levelgen.placement_run_min_x
	local min_y = mcl_levelgen.placement_run_min_y
	local min_z = mcl_levelgen.placement_run_min_z
	local max_x = mcl_levelgen.placement_run_max_x
	local max_y = mcl_levelgen.placement_run_max_y
	local max_z = mcl_levelgen.placement_run_max_z
	return x >= min_x and y >= min_y and z >= min_z
		and x <= max_x and y <= max_y and z <= max_z
end
mcl_levelgen.in_range = in_range

local function always ()
	return true
end

local MAX_POS = 512

function mcl_levelgen.build_environment_scan (parms)
	local direction = parms.direction
	local allowed_search_condition = parms.allowed_search_condition	or always
	local target_condition = parms.target_condition
	local max_steps = parms.max_steps

	return function (x, y, z, rng)
		if not in_range (x, y, z)
			or not allowed_search_condition (x, y, z) then
			return { x, direction * MAX_POS, z, }
		else
			for i = 1, max_steps do
				if target_condition (x, y, z) then
					return { x, y, z, }
				end

				y = y + direction
				if not in_range (x, y, z) then
					return { x, direction * MAX_POS, z, }
				end

				if not allowed_search_condition (x, y, z) then
					break
				end
			end
			return target_condition (x, y, z) and { x, y, z, }
				or { x, direction * MAX_POS, z, }
		end
	end
end

function mcl_levelgen.build_rarity_filter (n)
	local chance = 1.0 / n

	return function (x, y, z, rng)
		if rng:next_float () < chance then
			return { x, y, z, }
		else
			return {}
		end
	end
end

function mcl_levelgen.build_height_range (n)
	return function (x, y, z, rng)
		return { x, n (rng), z, }
	end
end

function mcl_levelgen.build_constant_height_offset (n)
	return function (x, y, z, rng)
		return { x, y + n, z, }
	end
end

function mcl_levelgen.build_random_offset (xz_scale, y_scale)
	return function (x, y, z, rng)
		return {
			x + xz_scale (rng),
			y + y_scale (rng),
			z + xz_scale (rng),
		}
	end
end

------------------------------------------------------------------------
-- Vegetation patch.
-- mcl_levelgen:vegetation_patch
------------------------------------------------------------------------

local mathabs = math.abs

-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/VegetationPatchFeature.html
-- https://minecraft.wiki/w/Vegetation_patch

-- local vegetation_patch_cfg = {
-- 	replaceable = nil,
-- 	ground = nil,
-- 	surface = nil, -- "ceiling" or "floor"
-- 	depth = nil,
-- 	extra_bottom_block_chance = nil,
-- 	vegetation_feature = nil,
-- 	vegetation_chance = nil,
-- 	vertical_range = nil,
-- 	xz_radius = nil,
-- 	extra_edge_column_chance = nil,
-- 	update_light = true,
-- }

local face_sturdy_p = mcl_levelgen.face_sturdy_p

local vegetation_directions = {
	ceiling = 1,
	floor = -1,
}

local function place_ground_surface (self, surfaces, dir, x, y, z, cfg, rng)
	-- x, y, z form the position from whence the plant will extend
	-- in growth_dir.  If it is empty and the block above is
	-- capable of supporting a plant, replace it with a moss
	-- surface.

	local cid, _ = get_block (x, y, z)
	if cid ~= cid_air
		or not face_sturdy_p (x, y + dir, z, "y", -dir) then
		return
	end

	local depth = cfg.depth (rng)
	local extra = cfg.extra_bottom_block_chance
	if extra > 0.0 and rng:next_float () < extra then
		depth = depth + 1
	end

	local replaceable = cfg.replaceable
	local ground = cfg.ground

	for y1 = y + dir, y + dir * depth, dir do
		local cid = get_block (x, y1, z)
		if indexof (replaceable, cid) ~= -1 then
			local cid, param2 = ground (x, y1, z, rng)
			set_block (x, y1, z, cid, param2)
			surfaces[#surfaces + 1] = {
				x, y, z,
			}
		end
	end
end

local function place_ground_surfaces (self, surfaces, x, y, z, rx, rz, cfg, rng)
	local dir = vegetation_directions[cfg.surface]
	assert (dir)
	local growth_dir = -dir
	local edge_chance = cfg.extra_edge_column_chance
	local vrange = cfg.vertical_range

	for dx = -rx, rx do
		for dz = -rz, rz do
			local at_x_edge = mathabs (dx) == rx
			local at_z_edge = mathabs (dz) == rz
			local at_one_edge = at_x_edge or at_z_edge
			local at_both_edges = at_x_edge and at_z_edge

			-- Omit corners and reduce the probability of
			-- generation at the extrema of the patch.
			if not at_both_edges then
				if not at_one_edge
					or rng:next_float () < edge_chance then
					local x, z = x + dx, z + dz
					local y = y

					-- Locate a surface within
					-- range to which to attach.
					for iy = y, y + dir * (vrange - 1), dir do
						y = iy
						local cid, _ = get_block (x, iy, z)
						if cid ~= cid_air then
							break
						end
					end

					-- Leave this surface.
					for iy = y, y + growth_dir * (vrange - 1), growth_dir do
						y = iy
						local cid, _ = get_block (x, iy, z)
						if cid == cid_air then
							break
						end
					end

					self:place_ground_surface (surfaces, dir, x, y, z, cfg, rng)
				end
			end
		end
	end
end

local function place_vegetation (self, placed_surfaces, cfg, rng)
	local chance = cfg.vegetation_chance
	local feature = cfg.vegetation_feature
	if type (feature) == "string" then
		feature = mcl_levelgen.registered_placed_features[feature]
		if not feature then
			if not warned[feature] then
				local blurb = "Vegetation patch attempted to place nonexistent feature: "
				core.log ("warning", blurb .. feature)
				warned[feature] = true
			end
			return
		end
	end

	for _, pos in ipairs (placed_surfaces) do
		local x, y, z = pos[1], pos[2], pos[3]
		if chance >= 0.0 and rng:next_float () < chance then
			place_one_feature (feature, x, y, z)
		end
	end
end

local vegetation_patch_rng
	= mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))

local function vegetation_patch_place (self, x, y, z, cfg, rng)
	vegetation_patch_rng:reseed (rng:next_long ())
	if y < run_minp.y or y > run_maxp.y then
		return false
	end

	local rng = vegetation_patch_rng
	local xz_radius = cfg.xz_radius
	local rx = xz_radius (rng) + 1
	local rz = xz_radius (rng) + 1
	local placed_surfaces = {}
	self:place_ground_surfaces (placed_surfaces, x, y, z, rx, rz, cfg, rng)
	self:place_vegetation (placed_surfaces, cfg, rng)
	if cfg.update_light then
		fix_lighting (x - rx - 2, y - 31, z - rz - 2,
			      x + rx + 2, y + 31, z + rz + 2)
	end
end

mcl_levelgen.register_feature ("mcl_levelgen:vegetation_patch", {
	place = vegetation_patch_place,
	place_ground_surface = place_ground_surface,
	place_ground_surfaces = place_ground_surfaces,
	place_vegetation = place_vegetation,
})

------------------------------------------------------------------------
-- Block column feature.
-- mcl_levelgen:block_column
------------------------------------------------------------------------

-- local block_column_cfg = {
-- 	layers = {
-- 		height = function (rng) ... end,
-- 		content = function (x, y, z, rng) ... end,
-- 	}, -- ``segments'' would be a more apposite identifier.
-- 	direction = nil,
-- 	allowed_placement = nil,
-- 	prioritize_tip = false,
-- }

local function abridge_segments (seg_heights, height, lim, cfg)
	local shrink = height - lim

	if not cfg.prioritize_tip then
		for i = #seg_heights, 1, -1 do
			local k = seg_heights[i]
			local d = mathmin (k, shrink)
			shrink = shrink - d
			seg_heights[i] = seg_heights[i] - d
			if shrink == 0 then
				break
			end
		end
	else
		for i = 1, #seg_heights do
			local k = seg_heights[i]
			local d = mathmin (k, shrink)
			shrink = shrink - d
			seg_heights[i] = seg_heights[i] - d
			if shrink == 0 then
				break
			end
		end
	end
end

local function block_column_place (_, x, y, z, cfg, rng)
	if y < run_minp.y or y > run_maxp.y then
		return false
	end

	-- Establish total height and truncate segments if
	-- insufficient.
	local height = 0
	local seg_heights = {}
	local segments = cfg.layers

	for i, segment in ipairs (segments) do
		local this_height = segment.height (rng)
		seg_heights[i] = this_height
		height = height + this_height
	end

	local allowed_placement = cfg.allowed_placement
	local dir = cfg.direction
	if height == 0 then
		return false
	else
		for i = 0, height - 1 do
			local y1 = y + (i * dir)

			-- Truncate the segment array to the first
			-- position that is not placeable.
			if not allowed_placement (x, y1, z) then
				abridge_segments (seg_heights, height, i, cfg)
				break
			end
		end

		local y1 = y
		for i, segment in ipairs (segments) do
			local this_height = seg_heights[i]
			if this_height > 0 then
				for i = 1, this_height do
					local cid, param2
						= segment.content (x, y1, z, rng)
					set_block (x, y1, z, cid, param2)
					y1 = y1 + dir
				end
			end
		end

		return true
	end
end

mcl_levelgen.register_feature ("mcl_levelgen:block_column", {
	place = block_column_place,
})

------------------------------------------------------------------------
-- Waterlogged vegetation patch.
-- mcl_levelgen:waterlogged_vegetation_patch
------------------------------------------------------------------------

local function containing_faces_sturdy_p (x, y, z)
	return face_sturdy_p (x - 1, y, z, "x", 1)
		and face_sturdy_p (x, y, z - 1, "z", 1)
		and face_sturdy_p (x + 1, y, z, "x", -1)
		and face_sturdy_p (x, y, z + 1, "z", -1)
		and face_sturdy_p (x, y - 1, z, "y", 1)
end

local function waterlogged_place_ground_surfaces (self, surfaces, x, y, z, rx,
						  rz, cfg, rng)
	local new_surfaces = {}
	local insert = table.insert

	-- Place ground surfaces as usual.
	place_ground_surfaces (self, surfaces, x, y, z, rx, rz, cfg, rng)

	-- Enumerate nodes that are not exposed, i.e. are not in
	-- contact with a face that is not whole.
	for i = #surfaces, 1, -1 do
		local pos = surfaces[i]
		pos[2] = pos[2] - 1
		if containing_faces_sturdy_p (pos[1], pos[2], pos[3]) then
			insert (new_surfaces, pos)
		end
		-- Erase surfaces in the process.
		surfaces[i] = nil
	end

	-- Replace the same with water sources and report them as new
	-- surfaces.
	for i = #new_surfaces, 1, -1 do
		local pos = new_surfaces[i]
		insert (surfaces, pos)
		local x, y, z = pos[1], pos[2], pos[3]
		set_block (x, y, z, cid_water_source, 0)
	end
end

mcl_levelgen.register_feature ("mcl_levelgen:waterlogged_vegetation_patch", {
	place = vegetation_patch_place,
	place_ground_surface = place_ground_surface,
	place_ground_surfaces = waterlogged_place_ground_surfaces,
	place_vegetation = place_vegetation,
})

------------------------------------------------------------------------
-- Vines.
-- mcl_levelgen:vines
------------------------------------------------------------------------

local is_air = mcl_levelgen.is_air
local vines_faces = {
	{
		"y", 1, 0, 1, 0,
	},
	{
		"x", -1, -1, 0, 0,
	},
	{
		"x", 1, 1, 0, 0,
	},
	{
		"z", -1, 0, 0, -1,
	},
	{
		"z", 1, 0, 0, 1,
	},
}

local function unpack5 (k)
	return k[1], k[2], k[3], k[4], k[5]
end

local cid_vine = core.get_content_id ("mcl_core:vine")
local facedir_to_wallmounted = mcl_levelgen.facedir_to_wallmounted

local function vines_place (_, x, y, z, cfg, rng)
	if y < run_minp.y or y > run_maxp.y then
		return false
	end

	if not is_air (x, y, z) then
		return false
	else
		for _, facing in ipairs (vines_faces) do
			local axis, dir, dx, dy, dz = unpack5 (facing)
			if face_sturdy_p (x + dx, y + dy, z + dz, axis, -dir) then
				local dir = facedir_to_wallmounted (axis, dir)
				set_block (x, y, z, cid_vine, dir)
				return true
			end
		end
		return false
	end
end

mcl_levelgen.register_feature ("mcl_levelgen:vines", {
	place = vines_place,
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:vines", {
	feature = "mcl_levelgen:vines",
})

------------------------------------------------------------------------
-- Lava Lake (erstwhile Lake).
-- mcl_levelgen:lake
------------------------------------------------------------------------

-- local lake_cfg = {
-- 	fluid_cid = nil,
-- 	barrier_cid = nil,
-- }
local lake_rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))
local ipos3 = mcl_levelgen.ipos3
local solid_p = mcl_levelgen.solid_p
local irreplaceable_cids = mcl_levelgen.construct_cid_list ({
	"group:features_cannot_replace",
})
local barrier_immune = mcl_levelgen.construct_cid_list ({
	"group:features_cannot_replace",
	"group:leaves",
	"group:tree",
})

local cid_water_source
	= core.get_content_id ("mcl_core:water_source")
local cid_lava_source
	= core.get_content_id ("mcl_core:lava_source")
local cid_stone
	= core.get_content_id ("mcl_core:stone")

local function water_or_lava_source_p (cid)
	return cid == cid_water_source
		or cid == cid_lava_source
end

local function hash_lake_pos (x, y, z)
	return (x * 16 + z) * 8 + y
end

local function is_lake (in_range, x, y, z)
	if x >= 16 or y >= 8 or z >= 16
		or x < 0 or y < 0 or z < 0 then
		return false
	end
	return in_range[hash_lake_pos (x, y, z)]
end

local function lake_place (_, x, y, z, cfg, rng)
	lake_rng:reseed (rng:next_long ())
	if y <= run_minp.y + 4 or y > run_maxp.y then
		return false
	else
		local in_range = {}
		local fluid_cid = cfg.fluid_cid

		-- Fill IN_RANGE with 8 randomly produced lakes
		-- starting from the northwest corner.
		local rng = lake_rng
		local n_centers = 0
		for i = 0, 8 do
			-- Width of pool.
			local wx = rng:next_double () * 6.0 + 3.0
			local wy = rng:next_double () * 4.0 + 2.0
			local wz = rng:next_double () * 6.0 + 3.0

			local rx = wx * 0.5
			local ry = wy * 0.5
			local rz = wz * 0.5

			-- Center of pool.
			local xcenter
				= rng:next_double () * (16.0 - wx - 2.0) + 1.0 + rx
			local ycenter
				= rng:next_double () * (8.0 - wy - 4.0) + 2.0 + ry
			local zcenter
				= rng:next_double () * (16.0 - wz - 2.0) + 1.0 + rz
			local rrx = 1 / rx
			local rry = 1 / ry
			local rrz = 1 / rz

			for x, y, z in ipos3 (1, 1, 1, 15, 7, 15) do
				local dx = (x - xcenter) * rrx
				local dz = (z - zcenter) * rry
				local dy = (y - ycenter) * rrz

				if dx * dx + dz * dz + dy * dy < 1.0 then
					in_range[hash_lake_pos (x, y, z)] = true
				end
			end

			-- Detect whether a lake has already been
			-- generated here, largely for good measure as
			-- lakes should not modify heightmaps in a
			-- manner that requires them to be idempotent.
			local cid, _ = get_block (floor (x + xcenter),
						  floor (y + ycenter),
						  floor (z + zcenter))
			if cid == fluid_cid then
				n_centers = n_centers + 1
			end
		end

		-- This lake has already been generated.
		if n_centers >= 8 then
			return true
		end

		-- Verify that the perimeter of the lake is solid and
		-- that there is no liquid above.
		local base_y = y - 4
		local base_x = x
		local base_z = z
		local border, lake = {}, {}
		for x, y, z in ipos3 (0, 0, 0, 15, 7, 15) do
			local is_lake_p = is_lake (in_range, x, y, z)
			local borders_lake = not is_lake_p
				and ((is_lake (in_range, x - 1, y, z))
					or (is_lake (in_range, x + 1, y, z))
					or (is_lake (in_range, x, y, z - 1))
					or (is_lake (in_range, x, y, z + 1))
					or (is_lake (in_range, x, y - 1, z))
					or (is_lake (in_range, x, y + 1, z)))

			if borders_lake then
				local cid, _ = get_block (base_x + x, base_y + y, base_z + z)

				if y >= 4 and water_or_lava_source_p (cid) then
					return false
				elseif y < 4 and not solid_p (cid) and cid ~= fluid_cid then
					-- A non-solid block or alien fluid
					-- exists in the lake's border.
					return false
				end
				border[#border + 1] = base_x + x
				border[#border + 1] = base_y + y
				border[#border + 1] = base_z + z
			elseif is_lake_p then
				lake[#lake + 1] = base_x + x
				lake[#lake + 1] = base_y + y
				lake[#lake + 1] = base_z + z
			end
		end

		fix_lighting (x, base_y, z, x + 15, y + 15, z + 15)

		-- Create the lake.
		for i = 1, #lake, 3 do
			local x, y, z = lake[i], lake[i + 1], lake[i + 2]
			local cid, _ = get_block (x, y, z)
			if indexof (irreplaceable_cids, cid) == -1 then
				if (y - base_y) >= 4 then
					set_block (x, y, z, cid_air, 0)
				else
					set_block (x, y, z, fluid_cid, 0)
				end
			end
		end

		local barrier_cid = cfg.barrier_cid
		if barrier_cid == cid_air then
			return true
		end

		-- Create the barrier.

		for i = 1, #border, 3 do
			local x, y, z = border[i], border[i + 1], border[i + 2]
			if (y - base_y) < 4 or rng:next_boolean () then
				local cid, _ = get_block (x, y, z)
				if solid_p (cid)
					and indexof (barrier_immune, cid) == -1 then
					set_block (x, y, z, barrier_cid, 0)
				end
			end
		end
		return true
	end
end

mcl_levelgen.register_feature ("mcl_levelgen:lake", {
	place = lake_place,
})

------------------------------------------------------------------------
-- Small Iceberg.
--
-- Yarn isn't helpful, sorry.  These numbers and formulas were derived
-- from visual inspection, printfs, and from the Minecraft wiki but
-- are virtually certainly incorrect.
------------------------------------------------------------------------

-- local iceberg_cfg = {
-- 	content = nil,
-- }

local preset = mcl_levelgen.overworld_preset
local OVERWORLD_SEA_LEVEL = preset.sea_level
local iceberg_rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))
local cid_snow_block = core.get_content_id ("mcl_core:snowblock")
local cid_packed_ice = core.get_content_id ("mcl_core:packed_ice")
-- local cid_blue_concrete = core.get_content_id ("mcl_colorblocks:concrete_blue")
local cid_blue_ice = core.get_content_id ("mcl_core:blue_ice")
local mathceil = math.ceil
local huge = math.huge

local function iceberg_p (cid)
	return cid == cid_ice
		or cid == cid_packed_ice
		or cid == cid_blue_ice
		or cid == cid_snow_block
end

local function iceberg_place_common (rng, x, y, z, snow, content)
	local cid, _ = get_block (x, y, z)
	if cid == cid_air or cid == cid_snow_block
		or cid == cid_ice
		or cid == cid_water_source then
		if snow and cid ~= cid_water_source then
			set_block (x, y, z, cid_snow_block, 0)
		else
			local cid, param2 = content (x, y, z)
			set_block (x, y, z, cid, param2)
		end
	end
end

local function count_adjoining_iceberg (x, y, z)
	local cnt = 0
	local cid, _ = get_block (x - 1, y, z)
	if iceberg_p (cid) then
		cnt = cnt + 1
	end
	local cid, _ = get_block (x + 1, y, z)
	if iceberg_p (cid) then
		cnt = cnt + 1
	end
	local cid, _ = get_block (x, y, z - 1)
	if iceberg_p (cid) then
		cnt = cnt + 1
	end
	local cid, _ = get_block (x, y, z + 1)
	if iceberg_p (cid) then
		cnt = cnt + 1
	end
	return cnt
end

local function iceberg_trim_surface (x, y, z, height, radius)
	for x, y, z in ipos3 (x - radius, y, z - radius,
			      x + radius, y + height, z + radius) do
		local cid, _ = get_block (x, y, z)
		if iceberg_p (cid) or cid == cid_snow then
			-- Icebergs mustn't generate overhangs
			-- otherwise than by carving.
			local cid_below, _ = get_block (x, y - 1, z)
			if cid_below == cid_air then
				set_block (x, y, z, cid_air, 0)

				-- Arrange that the block above also
				-- be eliminated.
				set_block (x, y + 1, z, cid_air, 0)
			elseif iceberg_p (cid) then
				local adjoining_iceberg
					= count_adjoining_iceberg (x, y, z)
				if adjoining_iceberg < 2 then
					set_block (x, y, z, cid_air, 0)
				end
			end
		end
	end
end

local function carving_radius_above (rng, dy, height, carve_radius)
	local broadness = 3.5 - rng:next_float ()
	local curved
	if height > 15 + rng:next_within (5) then
		-- Too tall to be scaled by the formula below
		-- comfortably.
		local k = dy < 3 + rng:next_within (6) and dy / 2 or dy
		curved = (1.0 - k / (height * broadness * 0.4)) * carve_radius
	else
		curved = (1.0 - (dy * dy) / (height * broadness)) * carve_radius
	end
	return mathceil (curved / 2.0)
end

local function carving_radius_keen (rng, dy, height, carve_radius)
	local broadness = 1.0 + rng:next_float () * 0.5
	local curved = (1.0 - dy / (height * broadness)) * carve_radius
	return mathceil (curved / 2.0)
end

local function dist_to_ellipse_center (x, z, r_major, r_minor, angle)
	local m1, m2 = mathcos (angle), mathsin (angle)

	-- Vector from center.
	local d1, d2 = x * m1 + z * -m2, x * m2 + z * m1

	-- Normalize and take length.
	local s1, s2 = d1 / r_major, d2 / r_minor
	return s1 * s1 + s2 * s2
end

local function carve_block (above_sea_level_p, x, y, z)
	local cid, _ = get_block (x, y, z)

	if iceberg_p (cid) then
		if not above_sea_level_p then
			set_block (x, y, z, cid_water_source, 0)
		else
			set_block (x, y, z, cid_air, 0)
		end
	end
end

local function carve_common (radius, above_sea_level_p, x, y, z,
			     ellipse_dx, ellipse_dz,
			     dy, angle, semi_major, semi_minor)
	local y = y + dy
	local r_major = radius + 1 + floor (semi_major / 3)
	local r_minor = mathmin (radius - 3, 3) + floor (semi_minor / 2) - 1

	for dx = -r_major, r_major do
		for dz = -r_major, r_major do
			local edist = dist_to_ellipse_center (dx - ellipse_dx,
							      dz - ellipse_dz,
							      r_major, r_minor,
							      angle)
			if edist < 1.0 then
				carve_block (above_sea_level_p, x + dx, y, z + dz)
			end
		end
	end
end

-- Elliptic icebergs.

local function real_semiminor (dy, height, semi_minor)
	if dy > 0 and height - dy <= 3 then
		-- Shrink ellipse near the top.
		return semi_minor - (4 - (height - dy))
	end
	return semi_minor
end

local function real_semimajor (dy, depth, semi_major)
	local k = semi_major
	return mathceil (k * (1.0 - (dy * dy) / (depth * 8.0)))
end

local function iceberg_carve_elliptic (rng, x, y, z, carve_radius, height,
				       semi_major, angle, semi_minor)
	local lim = mathmax (semi_major - 5, 1)
	-- Range: -(lim - 1) ... lim - 1
	local dx = 1 + rng:next_within (lim * 2 - 1) - lim
	local dz = 1 + rng:next_within (lim * 2 - 1) - lim
	local carving_angle = angle + pi * 0.5

	for dy = 0, height - 3 do
		local radius = carving_radius_above (rng, dy, height, carve_radius)
		carve_common (radius, true, x, y, z, dx, dz, dy, carving_angle,
			      semi_major, semi_minor)
	end

	for dy = -height + rng:next_within (5), -1 do
		local radius = carving_radius_keen (rng, -dy, height, carve_radius)
		carve_common (radius, false, x, y, z, dx, dz, dy, carving_angle,
			      semi_major, semi_minor)
	end
end

local function iceberg_place_elliptic (rng, x, y, z, content)
	local snowable = rng:next_double () < 0.3
	local angle = rng:next_double () * pi * 2

	-- https://minecraft.wiki/w/Iceberg_(feature)#Dimensions
	local semi_major = 11 - rng:next_within (5)
	local semi_minor = 3 + rng:next_within (3)
	local base_height = rng:next_within (6) + 6
	local carve_radius = mathmin (11, (rng:next_within (7)
					   + base_height - rng:next_within (5)))
	local depth_below = mathmin (rng:next_within (11) + base_height, 18)
	local rmax = semi_major
	local snow_threshold = mathmax (1, floor (base_height / 3))

	for dx, dy, dz in ipos3 (-rmax, 0, -rmax, rmax, base_height - 1, rmax) do
		local minor = real_semiminor (dy, base_height, semi_minor)
		local edist = dist_to_ellipse_center (dx, dz, rmax, minor, angle)
		if edist < 1.0 then
			local x, y, z = x + dx, y + dy, z + dz
			-- Thaw icebergs lightly as their perimeters
			-- are approached.
			if edist < 0.5 or rng:next_double () < 0.9 then
				local snowy = false
				if snowable and rng:next_double () < 0.95 then
					local snow_threshold_1
						= rng:next_within (snow_threshold)
					snowy = base_height - dy
						<= (snow_threshold_1 + base_height * 0.6)
				end
				iceberg_place_common (rng, x, y, z, snowy, content)
			end
		end
	end

	iceberg_trim_surface (x, y, z, base_height, rmax)

	for dx, dy, dz in ipos3 (-rmax, -depth_below + 1, -rmax, rmax, -1, rmax) do
		-- XXX: it appears this isn't exclusively employed in
		-- carving.
		local r = carving_radius_keen (rng, -dy, depth_below, carve_radius)
		-- XXX: Minecraft does not take the abs of this value
		-- and only applies it to the X axis, producing
		-- overhangs of kinds where an iceberg meets the ocean
		-- surface and is truncated on one side of a single
		-- axis.  Whether this is intentional or just an
		-- oversight on their part is debatable, but we ought
		-- to reproduce the same effect.
		if dx < r then
			local major = real_semimajor (dy, depth_below, semi_major)
			local edist = dist_to_ellipse_center (dx, dz, major,
							      semi_minor, angle)
			if edist < 1.0 then
				-- Thaw icebergs lightly as their perimeters
				-- are approached.
				local x, y, z = x + dx, y + dy, z + dz
				if edist < 0.5 or rng:next_double () < 0.9 then
					iceberg_place_common (rng, x, y, z, false, content)
				end
			end
		end
	end

	if rng:next_double () < 0.9 then
		iceberg_carve_elliptic (rng, x, y, z, carve_radius, base_height,
					semi_major, angle, semi_minor)
	end
	fix_lighting (x - rmax, y - depth_below + 1, z - rmax,
		      x + rmax, y + base_height - 1, z + rmax)
end

-- Circular icebergs.

local function iceberg_carve_circular (rng, x, y, z, carving_radius, height)
	local sx = rng:next_boolean () and -1 or 1
	local sz = rng:next_boolean () and -1 or 1

	local dx, dz
	if rng:next_boolean () then
		local lim2 = mathmax ((carving_radius
				       - floor (carving_radius / 2) - 1), 1)
		dx = (floor (carving_radius / 2) + 1 - rng:next_within (lim2)) * sx
		dz = (floor (carving_radius / 2) + 1 - rng:next_within (lim2)) * sz
	else
		local lim1 = mathmax (floor (carving_radius / 2) - 2, 1)
		dx = rng:next_within (lim1) * sx
		dz = rng:next_within (lim1) * sz
	end

	local carving_angle = rng:next_double () * pi * 2.0
	local semi_major = 11 - rng:next_within (5)
	local semi_minor = 3 + rng:next_within (3)

	for dy = 0, height - 3 do
		local radius = carving_radius_above (rng, dy, height,
						     carving_radius)
		carve_common (radius, true, x, y, z, dx, dz, dy, carving_angle,
			      semi_major, semi_minor)
	end

	for dy = -height + rng:next_within (5), -1 do
		local radius = carving_radius_keen (rng, -dy, height,
						    carving_radius)
		carve_common (radius, false, x, y, z, dx, dz, dy, carving_angle,
			      semi_major, semi_minor)
	end
end

local function clamp (value, min, max)
	return mathmax (mathmin (value, max), min)
end

local function dist_to_circle_center (rng, dx, dz, r)
	local offset = 10.0 * clamp (rng:next_float (), 0.2, 0.8) / r
	return dx * dx + dz * dz - offset
end

-- local function kontent ()
-- 	return cid_blue_concrete, 0
-- end

local function iceberg_place_circular (rng, x, y, z, content)
	local snowable = rng:next_double () < 0.3
	local height = rng:next_within (15) + 3

	-- There is a 10% chance of generating an abnormally tall
	-- iceberg.
	if rng:next_double () < 0.1 then
		height = mathmin (31, height + rng:next_within (19) + 7)
	end

	local carving_radius = mathmin (11, (rng:next_within (7)
					     + height - rng:next_within (5)))
	local depth_below = mathmin (rng:next_within (11) + height, 18)
	local snow_threshold = mathmax (1, floor (height / 2))

	for dx, dy, dz in ipos3 (-11, 0, -11, 11, height - 1, 11) do
		local r = carving_radius_above (rng, dy, height, carving_radius)
		if dx < r then -- ???
			local rsqr = r * r
			local dist = dist_to_circle_center (rng, dx, dz, r)
			local dalways = 3 + rng:next_within (3)
			if dist < rsqr
				and dist ~= -huge
				and dist ~= huge
				and (dist < (dalways * dalways)
				     or rng:next_double () < 0.9) then
				local snowy = false
				if snowable then
					local snow_threshold_1
						= rng:next_within (snow_threshold)
					snowy = height - dy
						<= (snow_threshold_1 + height * 0.6)
				end
				iceberg_place_common (rng, x + dx, y + dy, z + dz,
						      snowy, content)
			end
		end
	end

	iceberg_trim_surface (x, y, z, height, floor (carving_radius / 2))

	for dx, dy, dz in ipos3 (-11, -depth_below + 1, -11, 11, -1, 11) do
		local r = carving_radius_keen (rng, -dy, height, carving_radius)
		if dx < r then -- ???
			local rsqr = r * r
			local dist = dist_to_circle_center (rng, dx, dz, r)
			local dalways = 3 + rng:next_within (3)
			if dist < rsqr
				and dist ~= -huge
				and dist ~= huge
				and (dist < (dalways * dalways)
				     or rng:next_double () < 0.9) then
				iceberg_place_common (rng, x + dx, y + dy, z + dz,
						      false, content)
			end
		end
	end

	if rng:next_double () < 0.3 then
		iceberg_carve_circular (rng, x, y, z, carving_radius, height)
	end
	fix_lighting (x - 11, y - depth_below + 1, z - 11,
		      x + 11, y + height - 1, z + 11)
end

local function iceberg_place (_, x, y, z, cfg, rng)
	iceberg_rng:reseed (rng:next_long ())
	if OVERWORLD_SEA_LEVEL < run_minp.y or OVERWORLD_SEA_LEVEL > run_maxp.y then
		return false
	else
		local rng = iceberg_rng
		if rng:next_float () < 0.3 then
			iceberg_place_elliptic (rng, x, OVERWORLD_SEA_LEVEL, z,
						cfg.content)
		else
			iceberg_place_circular (rng, x, OVERWORLD_SEA_LEVEL, z,
						cfg.content)
		end
		return true
	end
end

mcl_levelgen.register_feature ("mcl_levelgen:iceberg", {
	place = iceberg_place,
})

------------------------------------------------------------------------
-- Blue Ice outgrowths.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/BlueIceFeature.html
------------------------------------------------------------------------

local function rtz (n)
	if n < 0 then
		return ceil (n)
	end
	return floor (n)
end

local function blue_ice_replaceable_p (cid)
	return cid == cid_air
		or cid == cid_water_source
		or cid == cid_packed_ice
		or cid == cid_ice
end

local dirs_up_only = {
	{ 1, 0, 0, },
	{ -1, 0, 0, },
	{ 0, 0, 1, },
	{ 0, 0, -1, },
	{ 0, 1, 0, },
}

local dirs_all = {
	{ 1, 0, 0, },
	{ -1, 0, 0, },
	{ 0, 0, 1, },
	{ 0, 0, -1, },
	{ 0, 1, 0, },
	{ 0, -1, 0, },
}

local function blue_ice_place (_, x, y, z, cfg, rng)
	iceberg_rng:reseed (rng:next_long ())
	local target_y = OVERWORLD_SEA_LEVEL - 1
	if target_y < run_minp.y or target_y > run_maxp.y then
		return false
	elseif y > target_y then
		return false
	else
		local rng = iceberg_rng
		-- Find an adjoining packed ice block.
		local found = false
		for _, dir in ipairs (dirs_up_only) do
			local x1 = x + dir[1]
			local y1 = y + dir[2]
			local z1 = z + dir[3]
			local cid, _ = get_block (x1, y1, z1)
			if cid == cid_packed_ice then
				found = true
				break
			end
		end
		if not found then
			return false
		end

		set_block (x, y, z, cid_blue_ice, 0)
		for i = 0, 200 do
			local yoff = rng:next_within (5) - rng:next_within (6)

			if yoff > -6 then
				local xz_dist = 3 + mathmin (0, ceil (yoff / 2))
				local dx = rng:next_within (xz_dist)
					- rng:next_within (xz_dist)
				local dz = rng:next_within (xz_dist)
					- rng:next_within (xz_dist)
				local x, y, z = x + dx, y + yoff, z + dz

				-- If this block is air, water, or any
				-- other form of ice, attempt to
				-- replace it with a blue ice block
				-- attached to another of its ilk.

				local cid, _ = get_block (x, y, z)
				if blue_ice_replaceable_p (cid) then
					for _, dir in ipairs (dirs_all) do
						local x1 = x + dir[1]
						local y1 = y + dir[2]
						local z1 = z + dir[3]
						local cid, _ = get_block (x1, y1, z1)
						if cid == cid_blue_ice then
							set_block (x, y, z, cid_blue_ice, 0)
							break
						end
					end
				end
			end
		end
		fix_lighting (x - 3, y - 5, x - 3, x + 3, y + 4, z - 3)
		return true
	end
end

mcl_levelgen.register_feature ("mcl_levelgen:blue_ice", {
	place = blue_ice_place,
})

------------------------------------------------------------------------
-- Forest Rock.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/ForestRockFeature.html
------------------------------------------------------------------------

-- local forest_rock_cfg = {
-- 	cid = nil,
-- 	param2 = nil,
-- }

local function forest_rock_advance_rng (rng)
	for i = 1, 3 do
		for j = 1, 6 do
			rng:next_within (2)
		end
	end
end

local stone_or_dirt = mcl_levelgen.construct_cid_list ({
	"group:stone_ore_target",
	"group:deepslate_ore_target",
	"group:dirt",
})

local function forest_rock_place (_, x, y, z, cfg, rng)
	if y < run_minp.y or y > run_maxp.y then
		forest_rock_advance_rng (rng)
		return false
	end

	local cid, param2 = cfg.cid, cfg.param2
	local cid_below, _ = get_block (x, y - 1, z)
	if cid_below == cid
		or indexof (stone_or_dirt, cid_below) == -1 then
		forest_rock_advance_rng (rng)
		return false
	end

	for i = 1, 3 do
		local rx = rng:next_within (2)
		local ry = rng:next_within (2)
		local rz = rng:next_within (2)
		local d = (rx + ry + rz) * 0.333 + 0.5
		local dsqr = d * d

		for x1, y1, z1 in ipos3 (x - rx, y - ry, z - rz,
					 x + rx, y + ry, z + rz) do
			local dx = (x - x1) * (x - x1)
			local dy = (y - y1) * (y - y1)
			local dz = (z - z1) * (z - z1)

			if dx + dy + dz <= dsqr then
				set_block (x1, y1, z1, cid, param2)
			end
		end
	end
	fix_lighting (x - 3, y - 3, z - 3, x + 3, y + 3, z + 3)
	return true
end

mcl_levelgen.register_feature ("mcl_levelgen:forest_rock", {
	place = forest_rock_place,
})

------------------------------------------------------------------------
-- Underwater magma.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/UnderwaterMagmaFeature.html
------------------------------------------------------------------------

-- local underwater_magma_cfg = {
-- 	floor_search_range = nil,
-- 	placement_radius_around_floor = nil,
-- 	placement_probability_per_valid_position = nil,
-- }

local find_ceiling_and_floor = mcl_levelgen.find_ceiling_and_floor
local cid_magma_block = core.get_content_id ("mcl_nether:magma")

local function is_water_source (x, y, z)
	local cid, _ = get_block (x, y, z)
	return cid == cid_water_source
end

local function is_not_water_source (x, y, z)
	local cid, _ = get_block (x, y, z)
	return cid ~= cid_water_source
end

local is_water_or_air = mcl_levelgen.is_water_or_air

local function essay_magma_placement (x, y, z)
	if not is_water_or_air (x, y, z)
		and not is_water_or_air (x, y - 1, z)
		and not is_water_or_air (x - 1, y, z)
		and not is_water_or_air (x, y, z - 1)
		and not is_water_or_air (x + 1, y, z)
		and not is_water_or_air (x, y, z + 1) then
		set_block (x, y, z, cid_magma_block, 0)
		return true
	end
	return false
end

local function underwater_magma_place (_, x, y, z, cfg, rng)
	if y < run_minp.y or y > run_maxp.y then
		local r = cfg.placement_radius_around_floor
		local rr = r * 2 + 1
		rng:consume (rr * rr * rr)
		return false
	else
		local range = cfg.floor_search_range
		local _, floor
			= find_ceiling_and_floor (x, y, z, range,
						  is_water_source,
						  is_not_water_source)

		if not floor then
			local r = cfg.placement_radius_around_floor
			local rr = r * 2 + 1
			rng:consume (rr * rr * rr)
			return false
		end

		local radius = cfg.placement_radius_around_floor
		local probability = cfg.placement_probability_per_valid_position

		local set = false
		for x, y, z in ipos3 (x - radius, y - radius, z - radius,
				      x + radius, y + radius, z + radius) do
			if rng:next_double () < probability
				and essay_magma_placement (x, y, z) then
				set = true
			end
		end
		if set then
			fix_lighting (x - radius, y - radius, z - radius,
				      x + radius, y + radius, z + radius)
		end
		return set
	end
end

mcl_levelgen.register_feature ("mcl_levelgen:underwater_magma", {
	place = underwater_magma_place,
})

------------------------------------------------------------------------
-- Disk.
-- mcl_levelgen:disk
------------------------------------------------------------------------

-- local disk_cfg = {
-- 	target = nil,
-- 	content = nil,
-- 	radius = nil,
-- 	half_height = nil,
-- }

local disk_rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))

local function disk_replace_column (x, top, bottom, z, cfg, rng)
	local content = cfg.content
	local pred = cfg.target
	local set = false

	for y = top, bottom, -1 do
		if pred (x, y, z) then
			local cid, param2 = content (x, y, z, rng)
			set_block (x, y, z, cid, param2)
			set = true

			-- Remove snow or plantlife that this node is
			-- no longer capable of supporting.
			local cid_above, _ = get_block (x, y + 1, z)
			if not is_position_hospitable (cid_above, x, y + 1, z) then
				set_block (x, y + 1, z, cid_air, 0)
				if double_plant_p (cid_above) then
					set_block (x, y + 2, z, cid_air, 0)
				end
			end
		end
	end
	return set
end

local function disk_place (_, x, y, z, cfg, rng)
	disk_rng:reseed (rng:next_long ())
	if y < run_minp.y or y > run_maxp.y then
		return false
	else
		local top = y + cfg.half_height
		local bottom = y - cfg.half_height
		local radius = cfg.radius (disk_rng)
		local replaced = false

		for dx, dy, dz in ipos3 (-radius, 0, -radius,
					 radius, 0, radius) do
			local d = dx * dx + dz * dz + dy * dy
			if d <= radius * radius then
				if disk_replace_column (x + dx, top, bottom, z + dz,
							cfg, disk_rng) then
					replaced = true
				end
			end
		end
		return replaced
	end
end

mcl_levelgen.register_feature ("mcl_levelgen:disk", {
	place = disk_place,
})

------------------------------------------------------------------------
-- Desert Well.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/DesertWellFeature.html
------------------------------------------------------------------------

-- local desert_well_cfg = {}
local is_solid = mcl_levelgen.is_solid

local cid_sand = core.get_content_id ("mcl_core:sand")
local cid_sandstone = core.get_content_id ("mcl_core:sandstone")
local cid_sandstone_slab = core.get_content_id ("mcl_stairs:slab_sandstone")
local cid_suspicious_sand = core.get_content_id ("mcl_sus_nodes:sand")

local convert_level_position = mcl_levelgen.convert_level_position

local function place_suspicious_sand (dir, x, y, z, rng)
	local x = x + dir[1]
	local z = z + dir[2]
	set_block (x, y, z, cid_suspicious_sand, dir)
	mcl_levelgen.notify_generated ("mcl_sus_nodes:suspicious_sand_meta", {
		pos = vector.new (convert_level_position (x, y, z)),
		loot_seed = mathabs (rng:next_integer ()),
		name = "desert_well",
	})
end

local function desert_well_advance_rng (rng)
	rng:next_within (4)
	rng:next_within (4)
	rng:next_integer ()
	rng:next_integer ()
end

local function desert_well_place (_, x, y, z, cfg, rng)
	if y < run_minp.y or y > run_maxp.y then
		desert_well_advance_rng (rng)
		return false
	else
		-- Move to the first solid block below.
		while not is_solid (x, y, z) do
			if not in_range (x, y, z) then
				desert_well_advance_rng (rng)
				return false
			end
			y = y - 1
		end

		-- Test that the foundation is solid and prevent
		-- repeated placement.
		local sy = y
		for x, y, z in ipos3 (x - 2, y - 2, z - 2,
				      x + 2, y - 0, z + 2) do
			if is_air (x, y, z) and y ~= sy then
				desert_well_advance_rng (rng)
				return false
			else
				local cid, _ = get_block (x, y, z)
				if cid == cid_sandstone_slab then
					desert_well_advance_rng (rng)
					return false
				end
			end
		end

		-- Replace the foundation with sandstone.
		for x, y, z in ipos3 (x - 2, y - 2, z - 2, x + 2, y, z + 2) do
			set_block (x, y, z, cid_sandstone, 0)
		end

		-- Create a cross-shaped well supported by sand.
		for dx, dy, dz in ipos3 (-1, -1, -1, 1, 0, 1) do
			local x, y, z = x + dx, y + dy, z + dz
			if not ((dx == -1 or dx == 1) and (dz == -1 or dz == 1)) then
				if dy == -1 then
					set_block (x, y, z, cid_sand, 0)
				else
					set_block (x, y, z, cid_water_source, 0)
				end
			end
		end

		-- Line the well with sandstone.
		for dx, dy, dz in ipos3 (-2, 1, -2, 2, 1, 2) do
			local x, y, z = x + dx, y + dy, z + dz
			if dx == -2 or dz == -2 or dx == 2 or dz == 2 then
				if dx == 0 or dz == 0 then
					set_block (x, y, z, cid_sandstone_slab, 0)
				else
					set_block (x, y, z, cid_sandstone, 0)
				end
			end
		end

		-- Build the dome.
		for dx, dy, dz in ipos3 (-1, 4, -1, 1, 4, 1) do
			local x, y, z = x + dx, y + dy, z + dz
			if dx == 0 and dz == 0 then
				set_block (x, y, z, cid_sandstone, 0)
			else
				set_block (x, y, z, cid_sandstone_slab, 0)
			end
		end

		for y = y + 1, y + 3 do
			set_block (x - 1, y, z - 1, cid_sandstone, 0)
			set_block (x - 1, y, z + 1, cid_sandstone, 0)
			set_block (x + 1, y, z - 1, cid_sandstone, 0)
			set_block (x + 1, y, z + 1, cid_sandstone, 0)
		end

		local dirs = {
			{ 1, 0, },
			{ -1, 0, },
			{ 0, 1, },
			{ 0, -1, },
		}
		local d1 = dirs[1 + rng:next_within (4)]
		local d2 = dirs[1 + rng:next_within (4)]
		place_suspicious_sand (d1, x, y - 1, z, rng)
		place_suspicious_sand (d2, x, y - 2, z, rng)
		fix_lighting (x - 2, y - 2, z - 2, x + 2, y + 4, z + 2)
		return true
	end
end

mcl_levelgen.register_feature ("mcl_levelgen:desert_well", {
	place = desert_well_place,
})

------------------------------------------------------------------------
-- Ice Spike.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/IceSpikeFeature.html
------------------------------------------------------------------------

local ice_spike_rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))
local request_additional_context = mcl_levelgen.request_additional_context
local cid_dirt = core.get_content_id ("mcl_core:dirt")

local function ice_spike_replaceable_p (cid)
	return cid == cid_air
		or cid == cid_dirt
		or cid == cid_snow_block
		or cid == cid_ice
end

local function is_ice_spike_replaceable (x, y, z)
	local cid, _ = get_block (x, y, z)
	return ice_spike_replaceable_p (cid)
end

-- local cid_glass = core.get_content_id ("mcl_core:glass")

local function ice_spike_place (_, x, y, z, cfg, rng)
	ice_spike_rng:reseed (rng:next_long ())
	if y < run_minp.y or y > run_maxp.y then
		return false
	else
		-- Move to the first solid block below.
		while not is_solid (x, y, z) do
			if not in_range (x, y, z) then
				return false
			end
			y = y - 1
		end
		local cid, _ = get_block (x, y, z)
		if cid ~= cid_snow_block then
			return false
		end

		y = y + rng:next_within (4)
		local min_changed = y
		local rng = ice_spike_rng
		local bulb_height = rng:next_within (4) + 7
		local bulb_radius = rng:next_within (2) + floor (bulb_height / 4)

		-- Potentially generate a tall ice spike.
		if bulb_radius > 1 and rng:next_within (60) == 0 then
			y = y + 10 + rng:next_within (30)
		end

		-- Request additional context if necessary.
		do
			local max_y = mcl_levelgen.placement_run_max_y
			local top = y + bulb_radius + 1
			if top > max_y then
				local requisition = top - max_y
				request_additional_context (requisition, 0)
				return false
			end
		end

		-- Build the bulb.
		for i = 0, bulb_height - 1 do
			local r = (1.0 - i / bulb_radius) * bulb_radius
			local rb = mathceil (r)
			local r = r * r
			for ix, iy, iz in ipos3 (x - rb, y + i, z - rb,
						 x + rb, y + i, z + rb) do
				local dx = (ix - x) * (ix - x)
				local dz = (iz - z) * (iz - z)
				local corner_p = dx == r or dz == r
				if (dx + dz <= r or (dx == 0 and dz == 0))
					and (not corner_p
					     or (dx == 0 and dz == 0)
					     or rng:next_float () <= 0.75) then
					if is_ice_spike_replaceable (ix, iy, iz) then
						set_block (ix, iy, iz, cid_packed_ice, 0)
					end
					if i ~= 0 and rb > 1 then
						if is_ice_spike_replaceable (ix, y - i, iz) then
							set_block (ix, y - i, iz, cid_packed_ice, 0)
						end
					end
				end
			end
		end

		-- Run this spike into the ground.
		local extension_radius = bulb_radius - 1
		if extension_radius < 0 then
			extension_radius = 0
		else
			extension_radius = 1
		end
		local min_y = mcl_levelgen.placement_run_min_y
		for dx = -extension_radius, extension_radius do
			for dz = -extension_radius, extension_radius do
				local y = y - 1
				local min_y = mathmax (51, min_y)
				local runlength = 50
				if mathabs (dx) == 1 or mathabs (dz) == 1 then
					runlength = rng:next_within (5)
				end

				-- Fill this column with intermittent
				-- segments of packed ice that extend
				-- into the surface.
				while y >= min_y do
					local cid, _ = get_block (x + dx, y, z + dz)
					if not ice_spike_replaceable_p (cid)
						and cid ~= cid_packed_ice then
						break
					end

					set_block (x + dx, y, z + dz, cid_packed_ice, 0)
					min_changed = mathmin (min_changed, y)
					y = y - 1
					runlength = runlength - 1
					if runlength <= 0 then
						y = y - rng:next_within (5) + 1
						runlength = rng:next_within (5)
					end
				end
			end
		end
		fix_lighting (x - bulb_radius, min_changed, y - bulb_radius,
			      x + bulb_radius, y + bulb_height - 1, z + bulb_radius)
		return true
	end
end

mcl_levelgen.register_feature ("mcl_levelgen:ice_spike", {
	place = ice_spike_place,
})

------------------------------------------------------------------------
-- Spring.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/SpringFeature.html
------------------------------------------------------------------------

-- local spring_cfg = {
-- 	fluid_cid = nil,
-- 	requires_block_below = nil,
-- 	rock_count = nil,
-- 	hole_count = nil,
-- 	valid_blocks = nil,
-- }

local function spring_place (_, x, y, z, cfg, rng)
	if y < run_minp.y or y > run_maxp.y then
		return false
	else
		local rock, hole = 0, 0
		local valid_blocks = cfg.valid_blocks
		local cid, _ = get_block (x, y + 1, z)
		if indexof (valid_blocks, cid) == -1 then
			return false
		end
		local cid, _ = get_block (x, y, z)
		if cid ~= cid_air and indexof (valid_blocks, cid) == -1 then
			return false
		end
		local cid, _ = get_block (x, y - 1, z)
		if indexof (valid_blocks, cid) ~= -1 then
			rock = rock + 1
		elseif cfg.requires_block_below then
			return false
		elseif cid == cid_air then
			hole = hole + 1
		end
		local cid, _ = get_block (x - 1, y, z)
		if indexof (valid_blocks, cid) ~= -1 then
			rock = rock + 1
		elseif cid == cid_air then
			hole = hole + 1
		end
		local cid, _ = get_block (x + 1, y, z)
		if indexof (valid_blocks, cid) ~= -1 then
			rock = rock + 1
		elseif cid == cid_air then
			hole = hole + 1
		end
		local cid, _ = get_block (x, y, z - 1)
		if indexof (valid_blocks, cid) ~= -1 then
			rock = rock + 1
		elseif cid == cid_air then
			hole = hole + 1
		end
		local cid, _ = get_block (x, y, z + 1)
		if indexof (valid_blocks, cid) ~= -1 then
			rock = rock + 1
		elseif cid == cid_air then
			hole = hole + 1
		end
		if rock == cfg.rock_count and hole == cfg.hole_count then
			set_block (x, y, z, cfg.fluid_cid, 0)
			fix_lighting (x, y, z, x, y, z)
			return true
		end
		return false
	end
end

mcl_levelgen.register_feature ("mcl_levelgen:spring", {
	place = spring_place,
})

------------------------------------------------------------------------
-- Default placed features.
------------------------------------------------------------------------

-- TODO: export these functions and remove duplicates.

local function trapezoidal_height (min, max, bound)
	local diff = max - min
	local bound_diff = rtz ((diff - bound) / 2)
	local base_diff = diff - bound_diff
	return function (rng)
		if bound >= diff then
			return rng:next_within (diff + 1) + min
		else
			return min + rng:next_within (base_diff + 1)
				+ rng:next_within (bound_diff + 1)
		end
	end
end

local function uniform_height (min_inclusive, max_inclusive)
	local diff = max_inclusive - min_inclusive + 1
	return function (rng)
		return rng:next_within (diff) + min_inclusive
	end
end

function mcl_levelgen.clamped_height (source, min_inclusive, max_inclusive)
	return function (rng)
		local value = source (rng)
		return mathmax (mathmin (value, max_inclusive),
				min_inclusive)
	end
end

local function ckd_random (rng, a, b)
	if a >= b then
		return a
	else
		return a + rng:next_within (b - a)
	end
end

-- https://mcreator.net/forum/105563/biased-bottom-height-provider

-- MAX_INCLUSIVE is actually exclusive but retains this misleading
-- identifier for consistency with Minecraft.

function mcl_levelgen.biased_to_bottom_height (min_inclusive, max_inclusive,
					       inner)
	if not inner then
		inner = 1
	end
	assert (max_inclusive - min_inclusive > inner, "Outer range is empty")
	local range_base = max_inclusive - min_inclusive - inner + 1
	return function (rng)
		local base = rng:next_within (range_base)
		return rng:next_within (base + inner) + min_inclusive
	end
end

local function very_biased_to_bottom_height (min_inclusive, max_inclusive,
					     inner)
	if not inner then
		inner = 1
	end
	assert (max_inclusive - min_inclusive > inner, "Outer range is empty")
	local inner_end = min_inclusive + inner
	return function (rng)
		local r1 = ckd_random (rng, inner_end, max_inclusive)
		local r2 = ckd_random (rng, min_inclusive, inner_end - 1)
		return ckd_random (rng, min_inclusive, r2 - 1 + r1)
	end
end

mcl_levelgen.uniform_height = uniform_height
mcl_levelgen.trapezoidal_height = trapezoidal_height
mcl_levelgen.very_biased_to_bottom_height = very_biased_to_bottom_height

local O = mcl_levelgen.construct_ore_substitution_list

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_coal", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 17,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:stone_with_coal",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_coal",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_coal_buried", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.5,
	size = 17,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:stone_with_coal",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_coal",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_andesite", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 64,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:andesite",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_core:andesite",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_clay", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 33,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:clay",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_core:clay",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_copper_large", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 20,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_copper:stone_with_copper",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_copper",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_copper_small", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 10,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_copper:stone_with_copper",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_copper",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_diamond_buried", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 1.0,
	size = 8,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:stone_with_diamond",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_diamond",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_diamond_large", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.7,
	size = 12,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:stone_with_diamond",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_diamond",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_diamond_medium", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.5,
	size = 8,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:stone_with_diamond",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_diamond",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_diamond_small", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.5,
	size = 4,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:stone_with_diamond",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_diamond",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_diorite", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 64,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:diorite",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_core:diorite",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_dirt", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 33,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:dirt",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_core:dirt",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_emerald", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 3,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:stone_with_emerald",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_emerald",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_gold_buried", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.5,
	size = 9,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:stone_with_gold",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_gold",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_gold", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 9,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:stone_with_gold",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_gold",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_granite", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 64,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:granite",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_core:granite",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_gravel", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 33,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:gravel",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_core:gravel",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_infested", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 9,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_monster_eggs:monster_egg_stone",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_monster_eggs:monster_egg_deepslate",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_iron", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 9,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:stone_with_iron",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_iron",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_iron_small", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 4,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:stone_with_iron",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_iron",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_lapis_buried", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 1.0,
	size = 7,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:stone_with_lapis",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_lapis",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_lapis", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 7,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:stone_with_lapis",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_lapis",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_redstone", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 8,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_core:stone_with_redstone",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:deepslate_with_redstone",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ore_tuff", {
	feature = "mcl_levelgen:ore",
	discard_chance_on_air_exposure = 0.0,
	size = 64,
	substitutions = O ({
		{
			target = "group:stone_ore_target",
			replacement = "mcl_deepslate:tuff",
		},
		{
			target = "group:deepslate_ore_target",
			replacement = "mcl_deepslate:tuff",
		},
	}),
})

local overworld = mcl_levelgen.overworld_preset
local OVERWORLD_TOP = overworld.min_y + overworld.height - 1
local OVERWORLD_MIN = overworld.min_y
local THIRTY = function () return 30 end
local TWENTY = function () return 20 end
local TWO = function () return 2 end
local FOURTY_SIX = function () return 46 end
local SIXTEEN = function () return 16 end
local SEVEN = function () return 7 end
local FOUR = function () return 4 end
local ONE_HUNDRED = function () return 100 end
local FIFTY = function () return 50 end
-- local SIX = function () return 6 end
local FOURTEEN = function () return 14 end
local TEN = function () return 10 end
local NINETY = function () return 90 end
local TWENTY_FIVE = function () return 25 end
local EIGHT = function () return 8 end
local THREE = function () return 3 end
local ONE_HUNDRED_AND_TWENTY_SEVEN = function () return 127 end

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_coal_upper", {
	configured_feature = "mcl_levelgen:ore_coal",
	placement_modifiers = {
		mcl_levelgen.build_count (THIRTY),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (136, OVERWORLD_TOP)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_coal_lower", {
	configured_feature = "mcl_levelgen:ore_coal_buried",
	placement_modifiers = {
		mcl_levelgen.build_count (TWENTY),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (trapezoidal_height (0, 192, 0)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_andesite_lower", {
	configured_feature = "mcl_levelgen:ore_andesite",
	placement_modifiers = {
		mcl_levelgen.build_count (TWO),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (0, 60)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_andesite_upper", {
	configured_feature = "mcl_levelgen:ore_andesite",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (6),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (64, 128)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_clay", {
	configured_feature = "mcl_levelgen:ore_clay",
	placement_modifiers = {
		mcl_levelgen.build_count (FOURTY_SIX),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (0, 256)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_copper", {
	configured_feature = "mcl_levelgen:ore_copper_small",
	placement_modifiers = {
		mcl_levelgen.build_count (SIXTEEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (trapezoidal_height (-16, 112, 0)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_copper_large", {
	configured_feature = "mcl_levelgen:ore_copper_large",
	placement_modifiers = {
		mcl_levelgen.build_count (SIXTEEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (trapezoidal_height (-16, 112, 0)),
		mcl_levelgen.build_in_biome (),
	},
})

local diamond_range = trapezoidal_height (OVERWORLD_MIN - 80, OVERWORLD_MIN + 80, 0)

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_diamond", {
	configured_feature = "mcl_levelgen:ore_diamond_small",
	placement_modifiers = {
		mcl_levelgen.build_count (SEVEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (diamond_range),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_diamond_buried", {
	configured_feature = "mcl_levelgen:ore_diamond_buried",
	placement_modifiers = {
		mcl_levelgen.build_count (FOUR),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (diamond_range),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_diamond_large", {
	configured_feature = "mcl_levelgen:ore_diamond_large",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (9),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (diamond_range),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_diamond_medium", {
	configured_feature = "mcl_levelgen:ore_diamond_medium",
	placement_modifiers = {
		mcl_levelgen.build_count (TWO),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (trapezoidal_height (-64, 4, 0)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_diorite_lower", {
	configured_feature = "mcl_levelgen:ore_diorite",
	placement_modifiers = {
		mcl_levelgen.build_count (TWO),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (0, 60)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_diorite_upper", {
	configured_feature = "mcl_levelgen:ore_diorite",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (6),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (64, 128)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_dirt", {
	configured_feature = "mcl_levelgen:ore_dirt",
	placement_modifiers = {
		mcl_levelgen.build_count (SEVEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (0, 160)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_emerald", {
	configured_feature = "mcl_levelgen:ore_emerald",
	placement_modifiers = {
		mcl_levelgen.build_count (ONE_HUNDRED),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (trapezoidal_height (-16, 480, 0)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_gold_extra", {
	configured_feature = "mcl_levelgen:ore_gold",
	placement_modifiers = {
		mcl_levelgen.build_count (FIFTY),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (32, 256, 0)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_gold", {
	configured_feature = "mcl_levelgen:ore_gold_buried",
	placement_modifiers = {
		mcl_levelgen.build_count (FOUR),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (trapezoidal_height (-64, 32, 0)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_gold_lower", {
	configured_feature = "mcl_levelgen:ore_gold_buried",
	placement_modifiers = {
		mcl_levelgen.build_count (uniform_height (0, 1)),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (-64, -48)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_granite_lower", {
	configured_feature = "mcl_levelgen:ore_granite",
	placement_modifiers = {
		mcl_levelgen.build_count (TWO),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (0, 60)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_granite_upper", {
	configured_feature = "mcl_levelgen:ore_granite",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (6),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (0, 60)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_gravel", {
	configured_feature = "mcl_levelgen:ore_gravel",
	placement_modifiers = {
		mcl_levelgen.build_count (FOURTEEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN,
								 OVERWORLD_TOP)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_infested", {
	configured_feature = "mcl_levelgen:ore_infested",
	placement_modifiers = {
		mcl_levelgen.build_count (FOURTEEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 63)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_iron_middle", {
	configured_feature = "mcl_levelgen:ore_iron",
	placement_modifiers = {
		mcl_levelgen.build_count (TEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (trapezoidal_height (-24, 56, 0)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_iron_small", {
	configured_feature = "mcl_levelgen:ore_iron_small",
	placement_modifiers = {
		mcl_levelgen.build_count (TEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (trapezoidal_height (OVERWORLD_MIN,
								     72, 0)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_iron_upper", {
	configured_feature = "mcl_levelgen:ore_iron",
	placement_modifiers = {
		mcl_levelgen.build_count (NINETY),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (trapezoidal_height (80, 384, 0)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_lapis_buried", {
	configured_feature = "mcl_levelgen:ore_lapis_buried",
	placement_modifiers = {
		mcl_levelgen.build_count (FOUR),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 64)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_lapis", {
	configured_feature = "mcl_levelgen:ore_lapis",
	placement_modifiers = {
		mcl_levelgen.build_count (TWO),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (trapezoidal_height (-32, 32, 0)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_redstone", {
	configured_feature = "mcl_levelgen:ore_redstone",
	placement_modifiers = {
		mcl_levelgen.build_count (FOUR),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 15)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_redstone_lower", {
	configured_feature = "mcl_levelgen:ore_redstone",
	placement_modifiers = {
		mcl_levelgen.build_count (EIGHT),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN - 32,
								 OVERWORLD_MIN + 32)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ore_tuff", {
	configured_feature = "mcl_levelgen:ore_tuff",
	placement_modifiers = {
		mcl_levelgen.build_count (TWO),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 0)),
		mcl_levelgen.build_in_biome (),
	},
})

-- Soil/ground vegetation.

local FIVE = function () return 5 end
local cid_double_grass = core.get_content_id ("mcl_flowers:double_grass")
local cid_tallgrass = core.get_content_id ("mcl_flowers:tallgrass")
local cid_fern = core.get_content_id ("mcl_flowers:fern")
local cid_double_fern = core.get_content_id ("mcl_flowers:double_fern")
local cid_dead_bush = core.get_content_id ("mcl_core:deadbush")
local cid_waterlily = core.get_content_id ("mcl_flowers:waterlily")

mcl_levelgen.register_configured_feature ("mcl_levelgen:block_tall_grass", {
	feature = "mcl_levelgen:simple_block",
	content = function (_, _, _, rng)
		return cid_double_grass, "grass_palette_index"
	end,
})

local function require_air (x, y, z, rng)
	local cid, _ = get_block (x, y, z)
	if cid == cid_air then
		return { x, y, z, }
	end
	return nil
end

mcl_levelgen.require_air = require_air

mcl_levelgen.register_configured_feature ("mcl_levelgen:patch_tall_grass", {
	feature = "mcl_levelgen:random_patch",
	placed_feature = {
		configured_feature = "mcl_levelgen:block_tall_grass",
		placement_modifiers = {
			require_air,
		},
	},
	tries = 96,
	xz_spread = 7,
	y_spread = 3,
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_tall_grass", {
	configured_feature = "mcl_levelgen:patch_tall_grass",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (5),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_tall_grass_2", {
	configured_feature = "mcl_levelgen:patch_tall_grass",
	placement_modifiers = {
		mcl_levelgen.build_noise_threshold_count (-0.8, 7, 0),
		mcl_levelgen.build_rarity_filter (32),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:block_short_grass", {
	feature = "mcl_levelgen:simple_block",
	content = function (_, _, _, rng)
		return cid_tallgrass, "grass_palette_index"
	end,
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:patch_grass", {
	feature = "mcl_levelgen:random_patch",
	placed_feature = {
		configured_feature = "mcl_levelgen:block_short_grass",
		placement_modifiers = {
			require_air,
		},
	},
	tries = 32,
	xz_spread = 7,
	y_spread = 3,
})

local E = mcl_levelgen.build_environment_scan
local scan_beneath_leaves = E ({
	allowed_search_condition = mcl_levelgen.is_leaf_or_air,
	target_condition = mcl_levelgen.is_air_with_dirt_below,
	max_steps = 24,
	direction = -1,
})
local scan_beneath_leaves_far = E ({
	allowed_search_condition = mcl_levelgen.is_leaf_or_air,
	target_condition = mcl_levelgen.is_air_with_dirt_below,
	max_steps = 31,
	direction = -1,
})
local scan_beneath_leaves_for_terracotta = E ({
	allowed_search_condition = mcl_levelgen.is_leaf_or_air,
	target_condition = mcl_levelgen.is_air_with_dirt_sand_or_terracotta_below,
	max_steps = 24,
	direction = -1,
})
local scan_beneath_leaves_for_water = E ({
	allowed_search_condition = mcl_levelgen.is_leaf_or_air,
	target_condition = mcl_levelgen.is_air_with_water_source_below,
	max_steps = 24,
	direction = -1,
})

mcl_levelgen.scan_beneath_leaves = scan_beneath_leaves
mcl_levelgen.scan_beneath_leaves_far = scan_beneath_leaves_far
mcl_levelgen.scan_beneath_leaves_for_terracotta = scan_beneath_leaves_for_terracotta
mcl_levelgen.scan_beneath_leaves_for_water = scan_beneath_leaves_for_water

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_grass_normal", {
	configured_feature = "mcl_levelgen:patch_grass",
	placement_modifiers = {
		mcl_levelgen.build_count (FIVE),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		scan_beneath_leaves,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_grass_badlands", {
	configured_feature = "mcl_levelgen:patch_grass",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		scan_beneath_leaves,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_grass_plain", {
	configured_feature = "mcl_levelgen:patch_grass",
	placement_modifiers = {
		mcl_levelgen.build_noise_threshold_count (-0.8, 10, 5),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		scan_beneath_leaves,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_grass_savannah", {
	configured_feature = "mcl_levelgen:patch_grass",
	placement_modifiers = {
		mcl_levelgen.build_count (TWENTY),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		scan_beneath_leaves,
		mcl_levelgen.build_in_biome (),
	},
})

local C = mcl_levelgen.build_weighted_cid_provider

mcl_levelgen.register_configured_feature ("mcl_levelgen:block_taiga_grass", {
	feature = "mcl_levelgen:simple_block",
	content = C ({
		{
			weight = 1,
			cid = cid_tallgrass,
			param2 = "grass_palette_index",
		},
		{
			weight = 4,
			cid = cid_fern,
			param2 = "grass_palette_index",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:patch_taiga_grass", {
	feature = "mcl_levelgen:random_patch",
	placed_feature = {
		configured_feature = "mcl_levelgen:block_taiga_grass",
		placement_modifiers = {
			require_air,
		},
	},
	tries = 32,
	xz_spread = 7,
	y_spread = 3,
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_grass_taiga", {
	configured_feature = "mcl_levelgen:patch_taiga_grass",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		scan_beneath_leaves,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_grass_taiga_2", {
	configured_feature = "mcl_levelgen:patch_taiga_grass",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		scan_beneath_leaves,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_grass_forest", {
	configured_feature = "mcl_levelgen:patch_grass",
	placement_modifiers = {
		mcl_levelgen.build_count (TWO),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		scan_beneath_leaves_far,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:block_jungle_grass", {
	feature = "mcl_levelgen:simple_block",
	content = C ({
		{
			weight = 3,
			cid = cid_tallgrass,
			param2 = "grass_palette_index",
		},
		{
			weight = 1,
			cid = cid_fern,
			param2 = "grass_palette_index",
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:patch_grass_jungle", {
	feature = "mcl_levelgen:random_patch",
	placed_feature = {
		configured_feature = "mcl_levelgen:block_jungle_grass",
		placement_modifiers = {
			function (x, y, z, rng)
				local cid, _ = get_block (x, y, z)
				if cid == cid_air then
					local cid, _ = get_block (x, y - 1, 0)
					if cid ~= cid_podzol then
						return { x, y, z, }
					end
				end
				return nil
			end,
		},
	},
	tries = 32,
	xz_spread = 7,
	y_spread = 3,
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_grass_jungle", {
	configured_feature = "mcl_levelgen:patch_grass_jungle",
	placement_modifiers = {
		mcl_levelgen.build_count (TWENTY_FIVE),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		scan_beneath_leaves_far,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:block_large_fern", {
	feature = "mcl_levelgen:simple_block",
	content = function (_, _, _, _)
		return cid_double_fern, "grass_palette_index"
	end,
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:patch_large_fern", {
	feature = "mcl_levelgen:random_patch",
	placed_feature = {
		configured_feature = "mcl_levelgen:block_large_fern",
		placement_modifiers = {
			require_air,
		},
	},
	tries = 96,
	xz_spread = 7,
	y_spread = 3,
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_large_fern", {
	configured_feature = "mcl_levelgen:patch_large_fern",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (5),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		scan_beneath_leaves,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:block_dead_bush", {
	feature = "mcl_levelgen:simple_block",
	content = function (_, _, _, _)
		return cid_dead_bush, 0
	end,
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:patch_dead_bush", {
	feature = "mcl_levelgen:random_patch",
	placed_feature = {
		configured_feature = "mcl_levelgen:block_dead_bush",
		placement_modifiers = {
			require_air,
		},
	},
	tries = 4,
	xz_spread = 7,
	y_spread = 3,
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_dead_bush", {
	configured_feature = "mcl_levelgen:patch_dead_bush",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_dead_bush_2", {
	configured_feature = "mcl_levelgen:patch_dead_bush",
	placement_modifiers = {
		mcl_levelgen.build_count (TWO),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_dead_bush_badlands", {
	configured_feature = "mcl_levelgen:patch_dead_bush",
	placement_modifiers = {
		mcl_levelgen.build_count (TWENTY),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		scan_beneath_leaves_for_terracotta,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:block_waterlily", {
	feature = "mcl_levelgen:simple_block",
	content = function (_, _, _, rng)
		return cid_waterlily, rng:next_within (4)
	end,
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:patch_waterlily", {
	feature = "mcl_levelgen:random_patch",
	placed_feature = {
		configured_feature = "mcl_levelgen:block_waterlily",
		placement_modifiers = {
			require_air,
		},
	},
	tries = 10,
	xz_spread = 7,
	y_spread = 3,
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:patch_waterlily", {
	configured_feature = "mcl_levelgen:patch_waterlily",
	placement_modifiers = {
		mcl_levelgen.build_count (FOUR),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		scan_beneath_leaves_for_water,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:lake_lava", {
	feature = "mcl_levelgen:lake",
	fluid_cid = cid_lava_source,
	barrier_cid = cid_stone,
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:lake_lava_underground", {
	configured_feature = "mcl_levelgen:lake_lava",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (9),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN,
								 OVERWORLD_TOP)),
		E ({
			direction = -1,
			max_steps = 32,
			target_condition = function (x, y, z)
				if y >= mcl_levelgen.placement_level_min + 5 then
					return is_air (x, y, z)
				end
				return false
			end,
		}),
		mcl_levelgen.build_surface_relative_threshold_filter ("world_surface",
								      -huge, -5),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:lake_lava_surface", {
	configured_feature = "mcl_levelgen:lake_lava",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (200),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface_wg"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:iceberg_packed", {
	feature = "mcl_levelgen:iceberg",
	content = function (x, y, z, rng)
		return cid_packed_ice, 0
	end,
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:iceberg_blue", {
	feature = "mcl_levelgen:iceberg",
	content = function (x, y, z, rng)
		return cid_blue_ice, 0
	end,
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:iceberg_packed", {
	configured_feature = "mcl_levelgen:iceberg_packed",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (9),
		mcl_levelgen.build_in_square (),
		function (x, y, z, rng)
			return { x, OVERWORLD_SEA_LEVEL, z, }
		end,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:iceberg_blue", {
	configured_feature = "mcl_levelgen:iceberg_blue",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (200),
		mcl_levelgen.build_in_square (),
		function (x, y, z, rng)
			return { x, OVERWORLD_SEA_LEVEL, z, }
		end,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:blue_ice", {
	feature = "mcl_levelgen:blue_ice",
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:blue_ice", {
	configured_feature = "mcl_levelgen:blue_ice",
	placement_modifiers = {
		mcl_levelgen.build_count (uniform_height (0, 19)),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (30, 61)),
		mcl_levelgen.build_in_biome (),
	},
})

local cid_mossy_cobblestone = core.get_content_id ("mcl_core:mossycobble")

mcl_levelgen.register_configured_feature ("mcl_levelgen:forest_rock", {
	feature = "mcl_levelgen:forest_rock",
	cid = cid_mossy_cobblestone,
	param2 = 0,
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:forest_rock", {
	configured_feature = "mcl_levelgen:forest_rock",
	placement_modifiers = {
		mcl_levelgen.build_count (TWO),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:underwater_magma", {
	feature = "mcl_levelgen:underwater_magma",
	floor_search_range = 5,
	placement_probability_per_valid_position = 0.5,
	placement_radius_around_floor = 1,
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:underwater_magma", {
	configured_feature = "mcl_levelgen:underwater_magma",
	placement_modifiers = {
		mcl_levelgen.build_count (uniform_height (44, 52)),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 256)),
		mcl_levelgen.build_surface_relative_threshold_filter ("motion_blocking",
								      -huge, -2),
		mcl_levelgen.build_in_biome (),
	},
})

local cid_clay_block = core.get_content_id ("mcl_core:clay")

mcl_levelgen.register_configured_feature ("mcl_levelgen:disk_clay", {
	feature = "mcl_levelgen:disk",
	half_height = 1,
	radius = uniform_height (2, 3),
	content = function (x, y, z, rng)
		return cid_clay_block, 0
	end,
	target = function (x, y, z)
		local cid, _ = get_block (x, y, z)
		return cid == cid_dirt or cid == cid_clay_block
	end,
})

local cid_mud = core.get_content_id ("mcl_mud:mud")

mcl_levelgen.register_configured_feature ("mcl_levelgen:disk_grass", {
	feature = "mcl_levelgen:disk",
	half_height = 2,
	radius = uniform_height (2, 6),
	content = function (x, y, z, rng)
		local above, _ = get_block (x, y + 1, z, rng)
		if not solid_p (above) and above ~= cid_water_source then
			local biome = index_biome (x, y, z)
			local def = mcl_levelgen.registered_biomes[biome]
			return cid_grass, def and def.grass_palette_index or 0
		else
			return cid_dirt, 0
		end
	end,
	target = function (x, y, z)
		local cid, _ = get_block (x, y, z)
		return cid == cid_dirt or cid == cid_mud
	end,
})

local cid_gravel = core.get_content_id ("mcl_core:gravel")

mcl_levelgen.register_configured_feature ("mcl_levelgen:disk_gravel", {
	feature = "mcl_levelgen:disk",
	half_height = 2,
	radius = uniform_height (2, 5),
	content = function (x, y, z, rng)
		return cid_gravel, 0
	end,
	target = function (x, y, z)
		local cid, _ = get_block (x, y, z)
		return cid == cid_dirt or cid == cid_grass
	end,
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:disk_sand", {
	feature = "mcl_levelgen:disk",
	half_height = 2,
	radius = uniform_height (2, 6),
	content = function (x, y, z, rng)
		if is_air (x, y - 1, z) then
			return cid_sandstone, 0
		else
			return cid_sand, 0
		end
	end,
	target = function (x, y, z)
		local cid, _ = get_block (x, y, z)
		return cid == cid_dirt or cid == cid_grass
	end,
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:disk_clay", {
	configured_feature = "mcl_levelgen:disk_clay",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		function (x, y, z, rng)
			if is_water_source (x, y, z) then
				return { x, y, z, }
			else
				return nil
			end
		end,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:disk_grass", {
	configured_feature = "mcl_levelgen:disk_grass",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_constant_height_offset (-1),
		function (x, y, z, rng)
			local cid, _ = get_block (x, y, z)
			if cid == cid_mud then
				return { x, y, z, }
			else
				return nil
			end
		end,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:disk_gravel", {
	configured_feature = "mcl_levelgen:disk_gravel",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		function (x, y, z, rng)
			if is_water_source (x, y, z) then
				return { x, y, z, }
			else
				return nil
			end
		end,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:disk_sand", {
	configured_feature = "mcl_levelgen:disk_sand",
	placement_modifiers = {
		mcl_levelgen.build_count (THREE),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		function (x, y, z, rng)
			if is_water_source (x, y, z) then
				return { x, y, z, }
			else
				return nil
			end
		end,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:desert_well", {
	feature = "mcl_levelgen:desert_well",
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:desert_well", {
	configured_feature = "mcl_levelgen:desert_well",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (1000),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:ice_spike", {
	feature = "mcl_levelgen:ice_spike",
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ice_spike", {
	configured_feature = "mcl_levelgen:ice_spike",
	placement_modifiers = {
		mcl_levelgen.build_count (THREE),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

local cid_coarse_dirt = core.get_content_id ("mcl_core:coarse_dirt")

mcl_levelgen.register_configured_feature ("mcl_levelgen:ice_patch", {
	feature = "mcl_levelgen:disk",
	half_height = 1,
	radius = uniform_height (2, 3),
	content = function (x, y, z, rng)
		return cid_packed_ice, 0
	end,
	target = function (x, y, z)
		local cid, _ = get_block (x, y, z)
		return cid == cid_dirt
			or cid == cid_grass
			or cid == cid_podzol
			or cid == cid_coarse_dirt
			or cid == cid_mycelium
			or cid == cid_snow_block
			or cid == cid_ice
	end,
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:ice_patch", {
	configured_feature = "mcl_levelgen:ice_patch",
	placement_modifiers = {
		mcl_levelgen.build_count (TWO),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_constant_height_offset (-1),
		function (x, y, z)
			local cid, _ = get_block (x, y, z)
			if cid == cid_snow_block then
				return { x, y, z, }
			else
				return nil
			end
		end,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:vines", {
	configured_feature = "mcl_levelgen:vines",
	placement_modifiers = {
		mcl_levelgen.build_count (ONE_HUNDRED_AND_TWENTY_SEVEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (64, 100)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:spring_water", {
	feature = "mcl_levelgen:spring",
	hole_count = 1,
	rock_count = 4,
	requires_block_below = true,
	fluid_cid = cid_water_source,
	valid_blocks = mcl_levelgen.construct_cid_list ({
		"mcl_amethyst:calcite",
		"mcl_core:andesite",
		"mcl_core:diorite",
		"mcl_core:dirt",
		"mcl_core:granite",
		"mcl_core:packed_ice",
		"mcl_core:stone",
		"mcl_deepslate:deepslate",
		"mcl_deepslate:tuff",
		"mcl_powder_snow:powder_snow",
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:spring_lava_frozen", {
	feature = "mcl_levelgen:spring",
	hole_count = 1,
	rock_count = 4,
	requires_block_below = true,
	fluid_cid = cid_lava_source,
	valid_blocks = mcl_levelgen.construct_cid_list ({
		"mcl_core:packed_ice",
		"mcl_core:snowblock",
		"mcl_powder_snow:powder_snow",
	}),
})

mcl_levelgen.register_configured_feature ("mcl_levelgen:spring_lava_overworld", {
	feature = "mcl_levelgen:spring",
	hole_count = 1,
	rock_count = 4,
	requires_block_below = true,
	fluid_cid = cid_lava_source,
	valid_blocks = mcl_levelgen.construct_cid_list ({
		"mcl_amethyst:calcite",
		"mcl_core:andesite",
		"mcl_core:diorite",
		"mcl_core:dirt",
		"mcl_core:granite",
		"mcl_core:stone",
		"mcl_deepslate:deepslate",
		"mcl_deepslate:tuff",
	}),
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:spring_water", {
	configured_feature = "mcl_levelgen:spring_water",
	placement_modifiers = {
		mcl_levelgen.build_count (TWENTY_FIVE),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 192)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:spring_lava", {
	configured_feature = "mcl_levelgen:spring_lava_overworld",
	placement_modifiers = {
		mcl_levelgen.build_count (TWENTY),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (very_biased_to_bottom_height (OVERWORLD_MIN,
									       OVERWORLD_TOP - 8, 8)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_levelgen:spring_lava_frozen", {
	configured_feature = "mcl_levelgen:spring_lava_frozen",
	placement_modifiers = {
		mcl_levelgen.build_count (TWENTY),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (very_biased_to_bottom_height (OVERWORLD_MIN,
									       OVERWORLD_TOP - 8, 8)),
		mcl_levelgen.build_in_biome (),
	},
})
