local ipairs = ipairs
local pairs = pairs
local mathmax = math.max
local mathmin = math.min
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local lshift = bit.lshift
local rshift = bit.rshift
local arshift = bit.arshift
local floor = math.floor
local ceil = math.ceil
local huge = math.huge

--------------------------------------------------------------------------
-- Level feature placement.
--------------------------------------------------------------------------

local NUM_GENERATION_STEPS = 11

--------------------------------------------------------------------------
-- Biome feature assignment and dependency resolution.
--------------------------------------------------------------------------

-- Features are registered individually in biomes, but as the sequence
-- in which they are defined is significant, there are several
-- invariants required of feature registrations, to wit: no feature
-- may be defined in such a position that it succeeds a feature in one
-- biome but precedes the latter, or any of its dependents, in
-- another.  A directed dependency tree is built and searched for
-- cycles, a tree of dependents is inserted in reverse order,
-- maintaining the relative position of each feature in its feature
-- list.

local function indexof (list, val)
	for i, v in ipairs (list) do
		if v == val then
			return i
		end
	end
	return -1
end

local function feature_w_step (step, feature)
	return string.format ("%d:%s", step, feature)
end

-- Attribution: Luanti

local string_find = string.find
local string_sub = string.sub

local function split (str, delim, include_empty, max_splits, sep_is_pattern)
	delim = delim or ","
	if delim == "" then
		error ("string.split separator is empty", 2)
	end
	max_splits = max_splits or -2
	local items = {}
	local pos, len = 1, #str
	local plain = not sep_is_pattern
	max_splits = max_splits + 1
	repeat
		local np, npe = string_find (str, delim, pos, plain)
		np, npe = (np or (len+1)), (npe or (len+1))
		if (not np) or (max_splits == 1) then
			np = len + 1
			npe = np
		end
		local s = string_sub (str, pos, np - 1)
		if include_empty or (s ~= "") then
			max_splits = max_splits - 1
			items[#items + 1] = s
		end
		pos = npe + 1
	until (max_splits == 0) or (pos > (len + 1))
	return items
end

local insert = table.insert

local function dfs (start, graph, g_next, visited, depth)
	local visited = visited or { [start] = true, }

	-- print (string.rep (' ', depth or 0) .. start)
	for _, item in ipairs (g_next[start]) do
		if visited[item] then
			print ("Cycle detected in feature dependency list: ")
			print (string.format ("  %-40s -> %s", start, item))
			return false
		end
		visited[item] = true
		if not dfs (item, graph, g_next, visited, (depth or 0) + 1) then
			print (string.format ("  %-40s -> %s", start, item))
			return false
		end
		visited[item] = false
	end
	return true
end

--[[

if false then

local function bfs (start, consider_item, g_next)
	consider_item (start)
	local pdl = { start, }

	while #pdl > 0 do
		start, pdl[#pdl] = pdl[#pdl], nil
		local elems = g_next[start]
		for i = #elems, 1, -1 do
			local item = elems[i]
			consider_item (item)
			insert (pdl, item)
		end
	end
end

end

]]

local function dfs1 (start, consider_item, g_next)
	local elems = g_next[start]
	for _, item in ipairs (elems) do
		dfs1 (item, consider_item, g_next)
	end
	consider_item (start)
end

local function merge_feature_precedences (preset)
	local feature_deps = {}
	local all_features = {}
	local ordered = {}
	local features_by_step = {}
	local indices = {}
	local feature_dependents = {}

	-- Build the feature dependence graph.
	for _, name in ipairs (preset:generated_biomes ()) do
		local biome = mcl_levelgen.registered_biomes[name]
		for step, features in ipairs (biome.features) do
			local prev_feature = nil
			for i, feature_id in ipairs (features) do
				local feature = feature_w_step (step, feature_id)
				if not feature_deps[feature] then
					feature_deps[feature] = {}
				end
				if prev_feature and indexof (feature_deps[feature],
							     prev_feature) == -1 then
					insert (feature_deps[feature], prev_feature)
				end
				prev_feature = feature
				if indexof (all_features, feature) == -1 then
					indices[feature] = #all_features + 1
					insert (all_features, feature)
				end

				local next_feature = features[i + 1]

				if next_feature then
					next_feature
						= feature_w_step (step, next_feature)
				end

				local dependents = feature_dependents[feature]
				if not dependents then
					dependents = {}
					feature_dependents[feature] = dependents
				end

				if next_feature
					and indexof (dependents, next_feature) == -1 then
					insert (dependents, next_feature)
				end
			end
		end
	end

	table.sort (all_features, function (a, b)
		local step_a, _
			= unpack (split (a, ':', true, 1))
		local step_b, _
			= unpack (split (b, ':', true, 1))
		step_a = tonumber (step_a)
		step_b = tonumber (step_b)
		if step_a < step_b then
			return true
		elseif step_a > step_b then
			return false
		else
			return indices[a] < indices[b]
		end
	end)

	-- Resolve cycles in this directed graph and insert its
	-- elements in reverse order of iteration.
	local seen = {}
	for _, feature in ipairs (all_features) do
		-- First, detect cycles.
		local success = dfs (feature, feature_deps[feature], feature_deps, nil)

		if not success then
			print (string.format ("  %-40s -> %s", "[level generator]", feature))
			error ("Could not enumerate features in order of precedence")
		end

		-- Insert a tree of dependents depth-first.
		dfs1 (feature, function (item)
			if not seen[item] then
				insert (ordered, item)
				seen[item] = true
			end
		end, feature_dependents)
	end

	-- Build the sequence list.
	for i = 1, NUM_GENERATION_STEPS do
		features_by_step[i] = {}
	end
	local seen = {}
	for i = #ordered, 1, -1 do
		if not seen[ordered[i]] then
			local step, feature_id
				= unpack (split (ordered[i], ':', true, 1))
			local list = features_by_step[tonumber (step)]
			insert (list, feature_id)
			seen[ordered[i]] = true
		end
	end
	return features_by_step
end

mcl_levelgen.merge_feature_precedences = merge_feature_precedences

------------------------------------------------------------------------
-- Feature registration.
------------------------------------------------------------------------

local registered_features = {}
mcl_levelgen.registered_features = registered_features

local registered_configured_features = {}
mcl_levelgen.registered_configured_features = registered_configured_features

local registered_placed_features = {}
mcl_levelgen.registered_placed_features = registered_placed_features

function mcl_levelgen.register_feature (id, feature)
	local existing = registered_features[id]
	if existing then
		error ("Feature " .. id .. " is already defined")
	end
	assert (feature.place)
	registered_features[id] = feature
end

function mcl_levelgen.register_configured_feature (id, configured_feature)
	local feature = registered_configured_features[id]
	if feature then
		error ("Configured feature " .. id .. " is already defined")
	end
	assert (configured_feature.feature)
	if not registered_features[configured_feature.feature] then
		error ("Configured feature " .. id .. " refers to a feature "
		       .. configured_feature.feature .. " that does not exist")
	end
	registered_configured_features[id] = configured_feature
end

function mcl_levelgen.register_placed_feature (id, placed_feature)
	local existing = registered_placed_features[id]
	if existing then
		error ("Placed feature " .. id .. " is already defined")
	end
	assert (placed_feature.configured_feature)
	if not registered_configured_features[placed_feature.configured_feature] then
		error ("Placed feature " .. id .. " refers to a configured feature "
		       .. placed_feature.configured_feature .. " that does not exist")
	end
	registered_placed_features[id] = placed_feature
end

local features_generated = {}

function mcl_levelgen.generate_feature (id, before, biomes, stage)
	if not registered_placed_features[id] then
		error ("Placed feature " .. id .. " is not defined")
	end
	if features_generated[stage .. ":" .. id] then
		error ("Feature has already been registered for generation: " .. id)
	end
	features_generated[stage .. ":" .. id] = true

	for _, biome in ipairs (biomes) do
		local def = mcl_levelgen.registered_biomes[biome]
		if not def.features[stage] then
			return
		end

		local index = table.indexof (def.features[stage], before)
		if index ~= -1 then
			table.insert (def.features[stage], index, id)
		end
	end
end

local for_each_dimension = mcl_levelgen.for_each_dimension

function mcl_levelgen.initialize_biome_features ()
	for _, dim in for_each_dimension () do
		local preset = dim.preset
		preset.features = merge_feature_precedences (preset)

		-- Construct a table mapping each registered biome's
		-- feature list to the index of the same feature in
		-- the feature precedence list.

		local feature_indices = {}
		for step, features in ipairs (preset.features) do
			local tbl = {}
			feature_indices[step] = tbl
			for i, feature in ipairs (features) do
				tbl[feature] = i
			end
		end
		preset.feature_indices = feature_indices
	end
end

if core and mcl_levelgen.load_feature_environment then

------------------------------------------------------------------------
-- Feature generation environment.
------------------------------------------------------------------------

local cid_air = core.CONTENT_AIR
local cids_walkable = {}

local function initialize_cids ()
	for name, def in pairs (core.registered_nodes) do
		if def.walkable then
			local cid = core.get_content_id (name)
			cids_walkable[cid] = true
		end
	end
end

if core.register_on_mods_loaded then
	core.register_on_mods_loaded (initialize_cids)
else
	initialize_cids ()
end

local run_minp, run_maxp = vector.new (), vector.new ()
local vm, run, heightmap, wg_heightmap, biomes, y_offset, level_min
local run_min_y, run_max_y, run_min_x, run_max_x, run_min_z, run_max_z

local HEIGHTMAP_SIZE_NODES = mcl_levelgen.HEIGHTMAP_SIZE_NODES
local unpack_augmented_height_map = mcl_levelgen.unpack_augmented_height_map
local pack_height_map = mcl_levelgen.pack_height_map
local SURFACE_UNCERTAIN = mcl_levelgen.SURFACE_UNCERTAIN
local MOTION_BLOCKING_UNCERTAIN = mcl_levelgen.MOTION_BLOCKING_UNCERTAIN
local SURFACE_MODIFIED = mcl_levelgen.SURFACE_MODIFIED
local MOTION_BLOCKING_MODIFIED = mcl_levelgen.MOTION_BLOCKING_MODIFIED
local REQUIRED_CONTEXT_Y = mcl_levelgen.REQUIRED_CONTEXT_Y
local REQUIRED_CONTEXT_XZ = mcl_levelgen.REQUIRED_CONTEXT_XZ
local cids, param2s = {}, {}
local area = nil
local vm_modified = false
local relight_rgn, gen_notifies = nil, {}
local heightmap_modifications
local preset
local features_requesting_additional_context = {}
local context_expansion_below, context_expansion_above
local structure_masks
local current_step
local structure_features

mcl_levelgen.placement_run_minp = run_minp
mcl_levelgen.placement_run_maxp = run_maxp
mcl_levelgen.placement_level_min = 0
mcl_levelgen.placement_level_height = 0
mcl_levelgen.placement_level = nil
mcl_levelgen.current_placed_feature = nil
mcl_levelgen.heightmap_modifications = nil

local function collect_unlit_region (aabb, list)
	aabb[4] = aabb[4] - 1
	aabb[5] = aabb[5] - 1
	aabb[6] = aabb[6] - 1
	insert (list, aabb)
end

function mcl_levelgen.convert_level_position (x, y, z)
	return x, y - y_offset, -z - 1
end

local function convert_minetest_position (x, y, z)
	return x, y + y_offset, -z - 1
end

local custom_liquids_enabled = mcl_levelgen.custom_liquids_enabled

function mcl_levelgen.process_features (p_vm, p_run, p_heightmap, p_wg_heightmap,
					p_structure_masks, p_structure_features,
					p_biomes, p_y_offset, p_level_min,
					p_level_height, p_preset)
	run = p_run
	run_minp.x = run.x * 16
	run_minp.z = -(run.z * 16 + 16)
	run_minp.y = run.y1 * 16 + p_level_min
	run_maxp.x = run_minp.x + 15
	run_maxp.z = run_minp.z + 15
	run_maxp.y = run.y2 * 16 + p_level_min + 15
	vm = p_vm
	heightmap = p_heightmap
	wg_heightmap = p_wg_heightmap
	biomes = p_biomes
	y_offset = p_y_offset
	level_min = p_level_min
	mcl_levelgen.placement_level_min = p_level_min
	mcl_levelgen.placement_level_height = p_level_height
	mcl_levelgen.placement_level = p_preset
	relight_rgn = mcl_util.empty_region
	heightmap_modifications = {}
	mcl_levelgen.heightmap_modifications = heightmap_modifications
	preset = p_preset
	gen_notifies = {}
	structure_features = p_structure_features

	run_min_y = mathmax ((run.y1 - REQUIRED_CONTEXT_Y) * 16 + p_level_min,
			     p_level_min)
	run_max_y = mathmin ((run.y2 + REQUIRED_CONTEXT_Y) * 16 + 15 + p_level_min,
			     p_level_min + p_level_height - 1)
	run_min_x = (run.x - REQUIRED_CONTEXT_XZ) * 16
	run_max_x = (run.x + REQUIRED_CONTEXT_XZ) * 16 + 15
	run_min_z = run_minp.z - REQUIRED_CONTEXT_XZ * 16
	run_max_z = run_min_z + HEIGHTMAP_SIZE_NODES - 1
	mcl_levelgen.placement_run_min_y = run_min_y
	mcl_levelgen.placement_run_max_y = run_max_y
	mcl_levelgen.placement_run_min_z = run_min_z
	mcl_levelgen.placement_run_max_z = run_max_z
	mcl_levelgen.placement_run_min_x = run_min_x
	mcl_levelgen.placement_run_max_x = run_max_x
	vm:get_data (cids)
	vm:get_param2_data (param2s)
	area = VoxelArea (vm:get_emerged_area ())
	vm_modified = false
	features_requesting_additional_context = {}
	context_expansion_above = 0
	context_expansion_below = 0
	structure_masks = p_structure_masks
	current_step = 0
	-- local clock = core.get_us_time ()
	-- mcl_levelgen.test_structuremask ()
	mcl_levelgen.process_features_1 ()
	if custom_liquids_enabled then
		mcl_levelgen.scan_fluids ()
	end
	-- print (string.format ("%.2f", (core.get_us_time () - clock) / 1000))
	if vm_modified then
		vm:set_data (cids)
		vm:set_param2_data (param2s)
	end

	local relight_list = {}
	if relight_rgn then
		relight_rgn:walk (collect_unlit_region, relight_list)
	end

	vm = nil
	relight_rgn = nil
	biomes = nil
	heightmap = nil
	wg_heightmap = nil
	cids, param2s = {}, {}
	return relight_list, gen_notifies,
		features_requesting_additional_context,
		context_expansion_above,
		context_expansion_below
end

local function conflicting_structure_mask (x, y, z)
	for _, mask in ipairs (structure_masks) do
		local x1, y1, z1 = mask[1], mask[2], mask[3]
		local x2, y2, z2 = mask[4], mask[5], mask[6]

		if x >= x1 and y >= y1 and z >= z1
			and x <= x2 and y <= y2 and z <= z2 then
			local h = (y2 - y1) + 1
			local l = (z2 - z1) + 1
			local ix = x - x1
			local iy = y - y1
			local iz = z - z1
			local idx = ((ix * h) + iy) * l + iz
			local elem = rshift (idx, 3) + 7
			local bit = lshift (band (idx, 7), 2)
			return band (rshift (mask[elem], bit), 0xf) > current_step
		end
	end
	return false
end

local function is_not_air (cid, param2)
	return cid ~= cid_air
end

local function is_walkable (cid, param2)
	return cids_walkable[cid]
end

local function index (x, y, z)
	local x = x
	local y = y - y_offset
	local dz = z - run_min_z
	local run_origin = (run.z - REQUIRED_CONTEXT_XZ) * 16
	local z = run_origin + (HEIGHTMAP_SIZE_NODES - dz - 1)
	return area:index (x, y, z)
end

local function get_block_1 (x, y, z)
	local idx = index (x, y, z)
	return cids[idx], param2s[idx]
end

local function complete_partial_heightmap (x, z, current_min, idx,
					   blocks_motion, flag)
	-- This run does not possess enough context to finalize this
	-- height map.
	if current_min <= run_min_y then
		return current_min
	end

	local value = heightmap[idx]
	local shift = (flag == SURFACE_UNCERTAIN
		      and 10 or 0)

	for y = current_min, run_min_y do
		local cid, param2 = get_block_1 (x, y, z)
		if blocks_motion (cid, param2) then
			local mask = 0x3ff
			local bias = -512
			local k = y + 1 - level_min
			mask = bnot (lshift (mask, shift))
			value = bor (band (mask, value,
					   bnot (lshift (flag, 28))),
				     lshift (k + bias, shift))
			heightmap[idx] = value
			return y + 1
		end
	end

	-- The true height of the level is still below the context
	-- available to this placement run.
	local mask = 0x3ff
	local bias = -512
	local k = run_min_y - level_min
	mask = bnot (lshift (mask, shift))
	value = bor (band (mask, value), lshift (k + bias, shift))
	heightmap[idx] = value
	return run_min_y
end

local function heightmap_index (x, z)
	local dx = x - run_min_x
	local dz = z - run_min_z
	return (dx * HEIGHTMAP_SIZE_NODES) + dz + 1
end

function mcl_levelgen.index_heightmap (x, z, generation_only)
	local run_x = run_min_x
	local run_z = run_min_z
	if z - run_z >= HEIGHTMAP_SIZE_NODES
		or x - run_x >= HEIGHTMAP_SIZE_NODES
		or z - run_z <= 0 or x - run_x <= 0 then
		error ("Heightmap index out of bounds")
	end
	local idx = heightmap_index (x, z)
	local heightmap = generation_only
		and wg_heightmap or heightmap
	local surface, motion_blocking, flags
		= unpack_augmented_height_map (heightmap[idx])
	surface = surface + level_min
	motion_blocking = motion_blocking + level_min
	if band (flags, SURFACE_UNCERTAIN) ~= 0 then
		surface = complete_partial_heightmap (x, z, surface, idx, is_not_air,
						      SURFACE_UNCERTAIN)
	end
	if band (flags, MOTION_BLOCKING_UNCERTAIN) ~= 0 then
		motion_blocking
			= complete_partial_heightmap (x, z, motion_blocking, idx,
						      is_walkable,
						      MOTION_BLOCKING_UNCERTAIN)
	end
	return surface, motion_blocking
end

local biome_seed = mcl_levelgen.biome_seed
local munge_biome_coords = mcl_levelgen.munge_biome_coords
local toquart = mcl_levelgen.toquart
local hashmapblock = mcl_levelgen.hashmapblock
local index_biome_list = mcl_levelgen.index_biome_list

local HORIZONTAL_QUARTS_PER_RUN = toquart (HEIGHTMAP_SIZE_NODES)

function mcl_levelgen.index_biome (x, y, z)
	local run_x = run_min_x
	local run_z = run_min_z
	if z - run_z >= HEIGHTMAP_SIZE_NODES
		or x - run_x >= HEIGHTMAP_SIZE_NODES
		or z - run_z <= 0 or x - run_x <= 0 then
		error ("Heightmap index out of bounds")
	end

	local qx, qy, qz = munge_biome_coords (biome_seed, x, y, z)
	local org_qx, org_qy, org_qz = qx, qy, qz

	-- Convert this QuartPos into the Luanti coordinate system.
	local dz = qz - toquart (run_min_z)
	local run_origin = (run.z - REQUIRED_CONTEXT_XZ) * 16
	qz = toquart (run_origin) + HORIZONTAL_QUARTS_PER_RUN - dz - 1
	qy = mathmax (qy, toquart (level_min))
	qy = qy - toquart (level_min)

	local bx, by, bz = arshift (qx, 2), arshift (qy, 2), arshift (qz, 2)
	local hash = hashmapblock (bx, by, bz)
	local list = biomes[hash]

	if list then
		return index_biome_list (list, band (qx, 3), band (qy, 3),
					 band (qz, 3))
	else
		return preset:index_biomes (org_qx, org_qy, org_qz)
	end
end

function mcl_levelgen.get_block (x, y, z)
	local run_x = run_min_x
	local run_z = run_min_z
	if z - run_z >= HEIGHTMAP_SIZE_NODES
		or x - run_x >= HEIGHTMAP_SIZE_NODES
		or z - run_z <= 0
		or x - run_x <= 0
		or y > run_max_y
		or y < run_min_y then
		return nil, nil
	end
	return get_block_1 (x, y, z)
end

local function hash_heightmap_modification (x, z)
	return bor (lshift (x + 32768, 16), z + 32768)
end

function mcl_levelgen.unpack_heightmap_modification (hash, value)
	local surface, motion_blocking
		= unpack_augmented_height_map (value)
	return rshift (hash, 16) - 32768, band (hash, 0xffff) - 32768,
		surface + level_min, motion_blocking + level_min
end

local function find_solid_surface (x, y, z, is_solid)
	for y = y, run_min_y, -1 do
		if is_solid (get_block_1 (x, y, z)) then
			return y + 1
		end
	end

	return run_min_y
end

local function correct_heightmaps (x, y, z, cid, param2, force)
	-- Correct heightmaps to agree with the new state of the
	-- level.
	local idx = heightmap_index (x, z)
	local value = heightmap[idx]
	local surface, motion_blocking
		= unpack_augmented_height_map (value)
	local modified = false
	surface = surface + level_min
	motion_blocking = motion_blocking + level_min

	local flags = rshift (value, 28)

	if not is_not_air (cid, param2) then
		if (surface - 1) == y or force then
			-- Search downwards.
			surface = find_solid_surface (x, y, z, is_not_air)
			if surface == run_min_y then
				flags = bor (flags, SURFACE_UNCERTAIN)
			end
			flags = bor (flags, SURFACE_MODIFIED)
			modified = true
		end
	elseif surface < y + 1 then
		surface = y + 1
		flags = bor (band (flags, bnot (SURFACE_UNCERTAIN)),
			     SURFACE_MODIFIED)
		modified = true
	end

	if not is_walkable (cid, param2) then
		if (motion_blocking - 1) == y or force then
			-- Search downwards.
			motion_blocking
				= find_solid_surface (x, y, z, is_walkable)
			if motion_blocking == run_min_y then
				flags = bor (flags, MOTION_BLOCKING_UNCERTAIN)
			end
			flags = bor (flags, MOTION_BLOCKING_MODIFIED)
			modified = true
		end
	elseif motion_blocking < y + 1 then
		motion_blocking = y + 1
		flags = bor (band (flags, bnot (MOTION_BLOCKING_UNCERTAIN)),
			     MOTION_BLOCKING_MODIFIED)
		modified = true
	end

	if modified then
		local hash = hash_heightmap_modification (x, z)
		if not heightmap_modifications[hash] then
			heightmap_modifications[hash] = value
		end
		heightmap[idx] = bor (lshift (flags, 28),
				      pack_height_map (surface - level_min,
						       motion_blocking - level_min))
	end
end

mcl_levelgen.is_walkable = is_walkable

function mcl_levelgen.set_block (x, y, z, cid, param2)
	assert (cid and param2)
	local run_x = run_min_x
	local run_z = run_min_z
	if z - run_z >= HEIGHTMAP_SIZE_NODES
		or x - run_x >= HEIGHTMAP_SIZE_NODES
		or z - run_z <= 0 or x - run_x <= 0 then
		core.log ("warning", "A feature placement function is writing "
			  .. " outside the placement run")
		core.log ("warning", debug.traceback ())
		return
	end
	if y < run_min_y or y > run_max_y then
		if y > run_maxp.y + REQUIRED_CONTEXT_Y * 16
			or y < run_minp.y - REQUIRED_CONTEXT_Y * 16 then
			core.log ("warning", "A feature placement function is writing "
				  .. " outside the placement run")
			core.log ("warning", debug.traceback ())
		end
		return
	end
	if conflicting_structure_mask (x, y, z) then
		return
	end
	local idx = index (x, y, z)
	cids[idx] = cid
	if param2 ~= -1 then
		param2s[idx] = param2
	end
	vm_modified = true
	correct_heightmaps (x, y, z, cid, param2, false)
end

-- local ipos3 = mcl_levelgen.ipos3
-- local cid_glass_magenta = core.get_content_id ("mcl_core:glass_magenta")

-- function mcl_levelgen.test_structuremask ()
-- 	for x, y, z in ipos3 (run_min_x, run_min_y, run_min_z,
-- 			      run_max_x, run_max_y, run_max_z) do
-- 		if conflicting_structure_mask (x, y, z) then
-- 			local idx = index (x, y, z)
-- 			cids[idx] = cid_glass_magenta
-- 			param2s[idx] = 0
-- 			vm_modified = true
-- 		end
-- 	end
-- end

local function update_relight_rgn (aabb)
	local new_relight_rgn = relight_rgn:union (aabb)
	if not new_relight_rgn then
		local simplified = relight_rgn:simplify ()
		new_relight_rgn = simplified:union (aabb)
	end
	if not new_relight_rgn then
		core.log ("warning", "Lighting region grew too complex")
	end
	relight_rgn = new_relight_rgn
end

function mcl_levelgen.fix_lighting (x1, y1, z1, x2, y2, z2)
	if not relight_rgn then
		return
	end

	-- core.fix_light processes lighting with MapBlock granularity
	-- anyway.
	local aabb = {
		band (x1, -16),
		band (y1 - y_offset, -16),
		band (-z2 - 1, -16),
		band (x2, -16) + 15 + 1,
		band (y2 - y_offset, -16) + 15 + 1,
		band (-z1, -16) + 15 + 1,
	}
	update_relight_rgn (aabb)
end

function mcl_levelgen.request_additional_context (yabove, ybelow)
	local feature = mcl_levelgen.current_placed_feature
	if indexof (features_requesting_additional_context, feature) == -1 then
		insert (features_requesting_additional_context, feature)
	end
	context_expansion_above
		= mathmax (context_expansion_above, yabove)
	context_expansion_below
		= mathmax (context_expansion_below, ybelow)
end

------------------------------------------------------------------------
-- Lua fluid transformation support.
------------------------------------------------------------------------

local ipos3 = mcl_levelgen.ipos3

local function longhash (x, y, z)
	return (32768 + z) * 65536 * 65536 + (32768 + y) * 65536
		+ (32768 + x)
end

local floodable_p = mcl_levelgen.floodable_p

local function neighbor_floodable_p (z, y, x, height, cid_flowing)
	local idx = area:index (x, y, z)
	local cid, param2 = cids[idx], param2s[idx]
	return floodable_p (cid)
		or (cid == cid_flowing and param2 < height)
end

function mcl_levelgen.scan_fluids ()
	local id_fluid_cid = mcl_levelgen.id_fluid_cid
	local all_fluids = mcl_levelgen.all_fluids
	local list = {}

	for _, cid in ipairs (all_fluids) do
		list[cid] = {}
	end

	local min, max = vm:get_emerged_area ()
	local min_x = min.x
	local min_y = min.y
	local min_z = min.z
	local max_x = max.x
	local max_y = max.y
	local max_z = max.z
	-- local clock = core.get_us_time ()

	-- XXX: insufficient context is available to placement runs to
	-- update liquid flows which are obstructed by the borders of
	-- a locked region.

	for z, y, x in ipos3 (min_z, min_y, min_x, max_z, max_y, max_x) do
		local index = area:index (x, y, z)
		local cid, param2 = cids[index], param2s[index]
		local cid_flowing = id_fluid_cid (cid)

		if cid_flowing then
			local height = cid ~= cid_flowing and 8 or param2
			if (y > min_y and neighbor_floodable_p (z, y - 1, x,
								param2, cid_flowing))
				or (z < max_z and neighbor_floodable_p (z + 1, y, x, height,
									cid_flowing))
				or (z > min_z and neighbor_floodable_p (z - 1, y, x, height,
									cid_flowing))
				or (x > min_x and neighbor_floodable_p (z, y, x + 1, height,
									cid_flowing))
				or (x < max_x and neighbor_floodable_p (z, y, x - 1, height,
									cid_flowing)) then
				insert (list[cid], longhash (x, y, z))
			end
		end
	end
	-- print ((core.get_us_time () - clock) / 1000)

	insert (gen_notifies, {
		name = "mcl_levelgen:custom_liquid_list",
		data = list,
		append = false,
	})
end

------------------------------------------------------------------------
-- Schematic placement.
------------------------------------------------------------------------

local portable_schematics = mcl_levelgen.portable_schematics
local cid_ignore = core.CONTENT_IGNORE
local active_processors = {}

function mcl_levelgen.push_schematic_processor (processor_function)
	local current = #active_processors
	insert (active_processors, processor_function)
	-- if type (processor_function) == "table"
	-- 	and processor_function.initialize then
	-- 	processor_function.initialize ()
	-- end
	return current
end

function mcl_levelgen.push_schematic_processors (processors)
	local current = #active_processors
	for _, processor in ipairs (processors) do
		insert (active_processors, processor)
		-- if type (processor) == "table"
		-- 	and processor.initialize then
		-- 	processor.initialize ()
		-- end
	end
	return current
end

function mcl_levelgen.pop_schematic_processors (current)
	for i = current + 1, #active_processors do
		active_processors[i] = nil
	end
end

local function apply_schematic_processors (x, y, z, rng, cid, param2)
	local cid_current, param2_current = get_block_1 (x, y, z)
	for _, processor in ipairs (active_processors) do
		-- print ("  --> ", cid, param2)
		cid, param2 = processor (x, y, z, rng, cid_current,
					 param2_current, cid, param2)
		-- print ("  <-- ", cid, param2)
		if not cid then
			return nil, nil
		end
	end
	return cid, param2
end

local decode_schem_data = mcl_levelgen.decode_schem_data

local ull = mcl_levelgen.ull
local schematic_rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))
local rotations = {
	"0", "90", "180", "270",
}
local v = vector.zero ()

local function rtz (n)
	if n < 0 then
		return ceil (n)
	end
	return floor (n)
end

local MTSCHEM_PROB_ALWAYS = 0xFF
local MTSCHEM_PROB_NEVER  = 0x00

local function hash_schem_pos (x, z)
	return bor (lshift ((x + 32768), 16), (z + 32768))
end

local rotate_param2 = mcl_levelgen.rotate_param2

local function copy_to_data (schematic, px, py, pz, rot, force_place)
	local size = schematic.size
	local xstride = 1
	local ystride = size.x
	local zstride = size.x * size.y
	local sx = size.x
	local sy = size.y
	local sz = size.z
	local xz_updates = {}

	local i_start, i_step_x, i_step_z
	if rot == "90" then
		i_start = sx - 1
		i_step_x = zstride
		i_step_z = -xstride
		sx, sz = sz, sx
	elseif rot == "180" then
		i_start = zstride * (sz - 1) + sx - 1
		i_step_x = -xstride
		i_step_z = -zstride
	elseif rot == "270" then
		i_start = zstride * (sz - 1)
		i_step_x = -zstride
		i_step_z = xstride
		sx, sz = sz, sx
	else
		i_start = 0
		i_step_x = xstride
		i_step_z = zstride
	end

	local y_map = py
	local yprob = schematic.yslice_prob
	local schemdata = schematic.data
	local rng = schematic_rng
	local have_processors = #active_processors > 0

	for y = 0, sy - 1 do
		if yprob[y + 1].prob == MTSCHEM_PROB_ALWAYS
			or yprob[y + 1].prob >= 1 + rng:next_within (0xff) then
			for z = 0, sz - 1 do
				local i = z * i_step_z + y * ystride + i_start
				for x = 0, sx - 1 do
					local gx = px + x
					local gy = py + y
					local gz = pz + z

					if area:contains (gx, gy, gz) then
						local data = schemdata[i + 1]
						if not data then
							core.log ("warning", "Placing invalid schematic...  idx="
								  .. i .. " rot=" .. rot)
							return
						end

						local cid, param2, probability, force_place_node
							= decode_schem_data (data)

						if probability ~= MTSCHEM_PROB_NEVER then
							local x_level, y_level, z_level
								= convert_minetest_position (gx, y_map, gz)

							if have_processors then
								-- print (gx, y_map, gz)
								cid, param2
									= apply_schematic_processors (x_level,
												      y_level,
												      z_level,
												      rng, cid,
												      param2)
								-- print ("  -->", cid, param2)
							end

							local vi = area:index (gx, y_map, gz)
							if cid and (force_place or force_place_node
								    or cids[vi] == cid_air
								    or cids[vi] == cid_ignore) then
								local continue = probability == MTSCHEM_PROB_ALWAYS
									or probability > 1 + rng:next_within (0x80)
								if continue
									and not conflicting_structure_mask (x_level,
													    y_level,
													    z_level) then
									cids[vi] = cid

									if rot ~= "0" then
										param2 = rotate_param2 (cid, param2, rot)
									end
									param2s[vi] = param2

									local hash = hash_schem_pos (x, z)
									local val = xz_updates[hash] or -huge
									xz_updates[hash] = mathmax (val, y_map)
								end
							end
						end
						i = i + i_step_x
					end
				end
			end
		end
		y_map = y_map + 1
	end

	-- Fix heightmaps.
	for key, absy in pairs (xz_updates) do
		local x = rshift (key, 16) - 32768 + px
		local zoff = band (key, 65535) - 32768
		local z = -pz - 1 - zoff
		local idx = heightmap_index (x, z)
		local surface, motion_blocking, _
			= unpack_augmented_height_map (heightmap[idx])

		local y = absy + y_offset
		if surface + level_min <= y
			or motion_blocking + level_min <= y then
			local cid, param2 = get_block_1 (x, y, z)
			correct_heightmaps (x, y, z, cid, param2, true)
		end
	end
end

function mcl_levelgen.random_schematic_rotation (rng)
	local x = 1 + rng:next_within (4)
	return rotations[x]
end

function mcl_levelgen.get_schematic_size (schematic, rotation)
	local schematic = portable_schematics[schematic]
	assert (schematic)
	local size = schematic.size

	if rotation == "90" or rotation == "270" then
		return size.z, size.y, size.x
	else
		return size.x, size.y, size.z
	end
end

function mcl_levelgen.place_schematic (x, y, z, schematic, rotation, force_place,
				       flags, rng)
	local schematic = portable_schematics[schematic]
	assert (schematic)
	schematic_rng:reseed (rng:next_long ())
	local rng = schematic_rng

	if rotation == "random" then
		local x = 1 + rng:next_within (4)
		rotation = rotations[x]
	else
		if rotation ~= "0"
			and rotation ~= "90"
			and rotation ~= "180"
			and rotation ~= "270" then
			error ("Invalid rotation provided to `place_schematic'", rotation)
		end
	end

	local x = x
	local y = y - y_offset
	local z = -z - 1
	local size = schematic.size

	if rotation == "90" or rotation == "270" then
		v.x = size.z
		v.y = size.y
		v.z = size.x
		size = v
	end

	if flags then
		if flags.place_center_x
			or flags.place_center_y
			or flags.place_center_z then
			size = vector.copy (size)
			if flags.place_center_x then
				x = x - rtz ((size.x - 1) / 2)
			end
			if flags.place_center_z then
				z = z - rtz ((size.z - 1) / 2)
			end
			if flags.place_center_y then
				y = y - rtz ((size.y - 1) / 2)
			end
		end
	end

	copy_to_data (schematic, x, y, z, rotation, force_place)
	update_relight_rgn ({
		x, y, z,
		x + size.x - 1,
		y + size.y - 1,
		z + size.z - 1,
	})
	vm_modified = true
	return {
		x, y + y_offset,
		-z - size.z,
		x + size.x - 1,
		y + size.y + y_offset - 1,
		-z - 1,
	}
end

------------------------------------------------------------------------
-- Feature generation.
------------------------------------------------------------------------

local rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))
local tmp = mcl_levelgen.xoroshiro_from_seed (mcl_levelgen.seed)
local tmp = tmp:fork_positional () ("mcl_levelgen:structure_features")
local structure_rng = tmp:fork_positional ():create_reseedable ()
local expand_biome_list = mcl_levelgen.expand_biome_list

local function place_one_feature (feature, x, y, z) -- A placed feature.
	local id = feature.configured_feature
	local cfg = registered_configured_features[id]
	local positions = {
		x or run_minp.x, y or level_min, z or run_minp.z,
	}
	local positions_next = {}

	for _, modifier in ipairs (feature.placement_modifiers) do
		for i = 1, #positions, 3 do
			local x = positions[i]
			local y = positions[i + 1]
			local z = positions[i + 2]
			local values = modifier (x, y, z, rng)
			assert (not values or #values % 3 == 0)
			if values then
				for _, value in ipairs (values) do
					insert (positions_next, value)
				end
			end
		end

		positions = positions_next
		positions_next = {}
	end

	local plain_feature = registered_features[cfg.feature]
	local placed = false
	for i = 1, #positions, 3 do
		placed = plain_feature:place (positions[i],
					      positions[i + 1],
					      positions[i + 2],
					      cfg, rng)
			or placed
	end
	return placed
end
mcl_levelgen.place_one_feature = place_one_feature

local registered_biomes = mcl_levelgen.registered_biomes
local sort = table.sort
local warned = {}

local function run_permits_feature_p (run, feature)
	return not run.supplemental
		or indexof (run.data.features, feature) ~= -1
end

local function place_structure_feature (feature_cfg)
	local x, y, z = feature_cfg[1], feature_cfg[2], feature_cfg[3]
	structure_rng:reseed_positional (x, y, z)
	local id = feature_cfg[5]
	local cfg = registered_configured_features[id]
	if not cfg then
		core.log ("warning", "Structure requesting unknown configured feature: " .. id)
		return
	end
	local plain_feature = registered_features[cfg.feature]
	plain_feature:place (x, y, z, cfg, structure_rng)
end

function mcl_levelgen.process_features_1 ()
	local seed = mcl_levelgen.seed
	local pop = mcl_levelgen.set_population_seed (rng, seed,
						      run_minp.x,
						      run_minp.z)

	-- Enumerate the biomes in this region.
	local gen_biomes, seen = {}, {}
	for _, index in pairs (biomes) do
		expand_biome_list (index, gen_biomes, seen)
	end
	local dim_feature_indices = preset.feature_indices
	local dim_features = preset.features

	for step = 1, NUM_GENERATION_STEPS do
		-- Collect the indices of the features that generate
		-- in each biome intersecting the run.

		local indices = dim_feature_indices[step]
		local features, seen = {}, {}
		for _, biome in ipairs (gen_biomes) do
			local def = registered_biomes[biome]
			local biomefeatures = def.features[step]

			if biomefeatures then
				for _, feature in ipairs (biomefeatures) do
					if not seen[feature]
						and run_permits_feature_p (run, feature) then
						seen[feature] = true
						assert (indices[feature])
						insert (features, indices[feature])
					end
				end
			end
		end
		sort (features)

		local step_features = dim_features[step]
		for _, idx in ipairs (features) do
			local name = step_features[idx]
			local feature = registered_placed_features[name]

			if feature then
				mcl_levelgen.set_decorator_seed (rng, pop, idx - 1, step - 1)
				mcl_levelgen.current_placed_feature = name
				mcl_levelgen.current_step = step
				current_step = step
				place_one_feature (feature)
			elseif not warned[name] then
				core.log ("warning", "Placing undefined feature: " .. name)
				warned[name] = true
			end
		end

		-- Generate features whose generation was requested by
		-- structures.
		for _, feature_cfg in ipairs (structure_features) do
			local feature_step = feature_cfg[4]
			if step == feature_step then
				place_structure_feature (feature_cfg)
			end
		end
	end
end

function mcl_levelgen.notify_generated (name, data, append)
	assert (type (name) == "string")
	if append then
		local last_generated = gen_notifies[#gen_notifies]
		if last_generated and last_generated.name == name then
			assert (last_generated.append)
			insert (last_generated.data, data)
			return
		end
		data = { data, }
	end

	insert (gen_notifies, {
		name = name,
		data = data,
		append = append,
	})
end

end
