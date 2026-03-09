------------------------------------------------------------------------
-- Structure generation.
--
-- When a MapChunk is generated, aggregations of structures called
-- structure sets are tested against all neighboring chunks within
-- eight Minecraft chunks of the said MapChunk.  A structure set is
-- an aggregation of structures combined with placement mechanics.
--
-- If a structure set assigns a structure to a chunk, this assignment
-- is referred to as a structure start.  A structure start provides
-- enough data ("structure pieces") deterministically to reproduce a
-- structure throughout all of the MapChunks it spans, and each such
-- chunk is said to hold a reference to structure starts which
-- intersect it.  This data may influence the noise sampling process
-- (by means of "beardifier" values) to adapt terrain to the presence
-- of a structure, and subsequently, when a MapChunk's terrain is
-- generated, those portions of structure starts referenced by the
-- chunks inside which intersect with the MapChunk are placed, and the
-- generated MapChunk is emerged.
------------------------------------------------------------------------

local mcl_levelgen = mcl_levelgen
local ipairs = ipairs
local pairs = pairs
local ull = mcl_levelgen.ull
local insert = table.insert
local mathcos = math.cos
local mathsin = math.sin

local function indexof (list, val)
	for i, v in ipairs (list) do
		if v == val then
			return i
		end
	end
	return -1
end

------------------------------------------------------------------------
-- Structure placement.
------------------------------------------------------------------------

local NUM_GENERATION_STEPS = 11

mcl_levelgen.RAW_GENERATION = 1
mcl_levelgen.LAKES = 2
mcl_levelgen.LOCAL_MODIFICATIONS = 3
mcl_levelgen.UNDERGROUND_STRUCTURES = 4
mcl_levelgen.SURFACE_STRUCTURES = 5
mcl_levelgen.STRONGHOLDS = 6
mcl_levelgen.UNDERGROUND_ORES = 7
mcl_levelgen.UNDERGROUND_DECORATION = 8
mcl_levelgen.FLUID_SPRINGS = 9
mcl_levelgen.VEGETAL_DECORATION = 10
mcl_levelgen.TOP_LAYER_MODIFICATION = 11

local floor = math.floor
local ceil = math.ceil
local mathabs = math.abs
local mathmin = math.min
local mathmax = math.max
local huge = math.huge

-- local structure_placement = {
-- 	locate_offset = { 0, 0, 0, },
-- 	frequency_reduction_method = nil,
-- 	frequency = 1.0,
-- 	salt = 0,
-- 	exclusion_zone = nil,
-- 	chunk_test = nil,
-- }

local function rtz (x)
	if x >= 0 then
		return floor (x)
	else
		return ceil (x)
	end
end

local default_rng = mcl_levelgen.jvm_random (ull (0, 0))
local set_region_seed = mcl_levelgen.set_region_seed
local set_carver_seed = mcl_levelgen.set_carver_seed

-- Distribution methods.

function build_random_spread_chunk_test (spacing, separation, spread_method)
	local function distribute_triangular (rng, n)
		return rtz ((rng:next_within (n) + rng:next_within (n)) / 2)
	end
	local function distribute_linear (rng, n)
		return rng:next_within (n)
	end
	assert (spacing > separation, "Separation cannot be satisfied by spacing")

	local distribute = distribute_linear
	if spread_method == "triangular" then
		distribute = distribute_triangular
	end

	local rng = default_rng
	return function (level, salt, cx, cz)
		local level_seed = level.level_seed
		-- Divide the level into SPACING sized regions and
		-- select a random chunk within that is at least
		-- SEPARATION removed from adjacent regions.
		local region_x = floor (cx / spacing)
		local region_z = floor (cz / spacing)
		set_region_seed (rng, level_seed, region_x, region_z, salt)
		local cx1 = distribute (rng, spacing - separation)
		local cz1 = distribute (rng, spacing - separation)
		return cx == (region_x * spacing + cx1)
			and cz == (region_z * spacing + cz1)
	end
end

function build_random_spread_locator_test (spacing, separation, spread_method)
	local function distribute_triangular (rng, n)
		return rtz ((rng:next_within (n) + rng:next_within (n)) / 2)
	end
	local function distribute_linear (rng, n)
		return rng:next_within (n)
	end
	assert (spacing > separation, "Separation cannot be satisfied by spacing")

	local distribute = distribute_linear
	if spread_method == "triangular" then
		distribute = distribute_triangular
	end

	local rng = default_rng
	return function (level, salt, region_x, region_z)
		local level_seed = level.level_seed
		-- The level is divided into SPACING sized regions and
		-- select a random chunk within that is at least
		-- SEPARATION removed from adjacent regions.
		set_region_seed (rng, level_seed, region_x, region_z, salt)
		local cx1 = distribute (rng, spacing - separation)
		local cz1 = distribute (rng, spacing - separation)
		return (region_x * spacing + cx1), (region_z * spacing + cz1)
	end
end

-- luacheck: push ignore 511
if false then
	local l = build_random_spread_chunk_test (32, 8, "linear")
	local level_seed = ull (0, 0)
	mcl_levelgen.stringtoull (level_seed, "44877572094875933")
	for x = -256, 255 do
		for z = -256, 255 do
			if l (level_seed, 48580, x, z) then
				print ("  (1) structure_start: ", x, z)
			end
		end
	end
end
-- luacheck: pop

-- Frequency reduction methods.

local function frequency_reducer_default (level_seed, salt, cx, cz,
					  frequency)
	-- Note: this is intentional as salt and cz are exchanged in
	-- Minecraft.
	set_region_seed (default_rng, level_seed, salt, cx, cz)
	return default_rng:next_float () < frequency
end

-- luacheck: push ignore 511
if false then
	local level_seed = ull (0, 0)
	mcl_levelgen.stringtoull (level_seed, "44877572094875933")
	for x = -64, 63 do
		for z = -64, 63 do
			if frequency_reducer_default (level_seed, 0, x, z, 1/48) then
				print (" (D) Should generate: " .. x .. ", " .. z)
			end
		end
	end
end
-- luacheck: pop

local rshift = bit.rshift
local arshift = bit.arshift
local lshift = bit.lshift
local bxor = bit.bxor
local bnot = bit.bnot
local band = bit.band
local bor = bit.bor
local tmp = ull (0, 0)
local extkull = mcl_levelgen.extkull
local xorull = mcl_levelgen.xorull

local function frequency_reducer_type_1 (level_seed, salt, cx, cz, frequency)
	local cx_component = arshift (cx, 4)
	local hash = bxor (cx_component, band (cz, bnot (15)))
	extkull (tmp, hash)
	xorull (tmp, level_seed)
	default_rng:reseed (tmp)
	default_rng:next_integer ()
	return default_rng:next_within (floor (1.0 / frequency)) == 0
end

-- luacheck: push ignore 511
if false then
	local level_seed = ull (0, 0)
	mcl_levelgen.stringtoull (level_seed, "44877572094875933")

	for x = -64, 63 do
		for z = -64, 63 do
			if frequency_reducer_type_1 (level_seed, 0, x, z, 0.3) then
				print ("Should generate: " .. x .. ", " .. z)
			end
		end
	end
end
-- luacheck: pop

local function frequency_reducer_type_2 (level_seed, salt, cx, cz, frequency)
	-- https://minecraft.wiki/w/Structure_set
	-- Although this page is still partially incorrect as it
	-- overlooks the other distinction, namely, that cx and the
	-- salt are not exchanged.

	set_region_seed (default_rng, level_seed, cx, cz, 10387320)
	return default_rng:next_float () < frequency
end

-- luacheck: push ignore 511
if false then
	local level_seed = ull (0, 0)
	mcl_levelgen.stringtoull (level_seed, "44877572094875933")

	for x = -64, 63 do
		for z = -64, 63 do
			if frequency_reducer_type_2 (level_seed, 0, x, z, 1/22) then
				print ("Should generate: " .. x .. ", " .. z)
			end
		end
	end
end
-- luacheck: pop

local function frequency_reducer_type_3 (level_seed, salt, cx, cz, frequency)
	set_carver_seed (default_rng, level_seed, cx, cz)
	return default_rng:next_float () < frequency
end

-- luacheck: push ignore 511
if false then
	local level_seed = ull (0, 0)
	mcl_levelgen.stringtoull (level_seed, "44877572094875933")

	for x = -64, 63 do
		for z = -64, 63 do
			if frequency_reducer_type_3 (level_seed, 0, x, z, 1/409) then
				print ("Should generate: " .. x .. ", " .. z)
			end
		end
	end
end
-- luacheck: pop

local frequency_reducers = {
	default = frequency_reducer_default,
	legacy_type_1 = frequency_reducer_type_1,
	legacy_type_2 = frequency_reducer_type_2,
	legacy_type_3 = frequency_reducer_type_3,
}

local ipos = mcl_levelgen.make_ipos_iterator ()
local structure_starts_in_chunk_p
local registered_structure_sets = {}

local function evaluate_exclusions (level, placement, cx, cz)
	if placement.exclusion_zone then
		local sid = placement.exclusion_zone[1]
		local dist = placement.exclusion_zone[2]
		local set = registered_structure_sets[sid]
		if set then
			local placement = set.placement
			for x, _, z in ipos (cx - dist, 0, cz - dist,
					     cx + dist, 0, cz + dist) do
				-- NOTE: it is important to avoid recursion
				-- when defining exclusion zones.
				if structure_starts_in_chunk_p (level, placement, x, z) then
					return false
				end
			end
		end
	end
	return true
end

function structure_starts_in_chunk_p (level, placement, cx, cz)
	local level_seed = level.level_seed
	local method = placement.frequency_reduction_method
	local frequency = placement.frequency
	local salt = placement.salt
	return placement.chunk_test (level, salt, cx, cz)
		and (frequency >= 1.0 or method (level_seed, salt,
						 cx, cz, frequency))
		and evaluate_exclusions (level, placement, cx, cz)
end

function mcl_levelgen.build_random_spread_placement (frequency, reduction,
						     spacing, separation,
						     salt, spread_type,
						     locate_offset,
						     exclusion_zone)
	local tbl = {
		frequency = frequency or 1.0,
		frequency_reduction_method
			= (reduction and assert (frequency_reducers[reduction]))
				or frequency_reducer_default,
		chunk_test = build_random_spread_chunk_test (spacing, separation,
							     spread_type),
		locator_test = build_random_spread_locator_test (spacing, separation,
								 spread_type),
		locate_offset = locate_offset or { 0, 0, 0, },
		spacing = spacing,
		exclusion_zone = exclusion_zone,
		salt = assert (salt),
	}

	return tbl
end

------------------------------------------------------------------------
-- Concentric ring placement.
------------------------------------------------------------------------

-- local concentric_ring_cfg = {
-- 	distance = distance,
-- 	spread = spread,
-- 	count = count,
-- 	preferred_biomes = preferred_biomes,
-- }

local function struct_hash (cx, cz)
	-- One bit wider than necessary to accomodate chunks near the
	-- edge(s) of the level.
	local x = cx + 4096
	local z = cz + 4096
	assert (x >= 0 and z >= 0)
	return bor (lshift (x, 13), z)
end

local function struct_unhash (hash)
	local x = arshift (hash, 13) - 4096
	local z = band (hash, 0x1fff) - 4096
	return x, z
end

local tostringull = mcl_levelgen.tostringull

if core and core.get_mod_storage then

local storage = core.get_mod_storage ()

local registered_concentric_ring_configurations = {}

function mcl_levelgen.register_concentric_ring_configuration (name, parms)
	registered_concentric_ring_configurations[name] = parms
end

function mcl_levelgen.prime_concentric_placement (preset, name)
	local seed = tostringull (preset.seed)
	local key = string.format ("concentric_ring_placement,%s,%s",
				   seed, name)

	local existing = storage:get_string (key)
	local ipc_key = "mcl_levelgen:concentric_ring_cfgs," .. seed
	local tbl = core.ipc_get (ipc_key) or {}
	if existing and existing ~= "" then
		tbl[name] = core.deserialize (existing)
	else
		core.log ("action", "[mcl_levelgen]: Preparing stronghold placement.  This may take a while.")
		local def = registered_concentric_ring_configurations[name]
		local list = mcl_levelgen.generate_stronghold_positions (preset, def)
		storage:set_string (key, core.serialize (list))
		tbl[name] = list
	end
	core.ipc_set (ipc_key, tbl)
end

else

function mcl_levelgen.register_concentric_ring_configuration (name, parms)
end

function mcl_levelgen.prime_concentric_placement (preset, name)
end

end

local blurb
	= "Concentric ring placement was utilized in a preset for which it was not prepared"

local function build_concentric_ring_chunk_test (tbl)
	local id = tbl.id
	return function (level, salt, cx, cz)
		local hash = struct_hash (cx, cz)
		local is_start = level.stronghold_starts[id]
		assert (is_start, blurb)
		return is_start[hash]
	end
end

function mcl_levelgen.build_concentric_ring_placement (id, frequency, reduction, salt,
						       locate_offset, exclusion_zone)
	local tbl = {
		id = id,
		frequency = frequency or 1.0,
		frequency_reduction_method
			= (reduction and assert (frequency_reducers[reduction]))
				or frequency_reducer_default,
		salt = assert (salt),
		locate_offset = locate_offset or { 0, 0, 0, },
		exclusion_zone = exclusion_zone,
	}
	tbl.chunk_test = build_concentric_ring_chunk_test (tbl)
	return tbl
end

local function is_preferred_biome (biome, preferred_biomes)
	return indexof (preferred_biomes, biome) ~= -1
end

local locate_biome_in_area = mcl_levelgen.locate_biome_in_area
local pi = math.pi

local function round (x)
	if x < 0 then
		local int = ceil (x)
		local frac = x - int
		return int - ((frac <= -0.5) and 1 or 0)
	end
	local int = floor (x)
	local frac = x - int
	return int + ((frac >= 0.5) and 1 or 0)
end

function mcl_levelgen.generate_stronghold_positions (preset, parms)
	local distance = parms.distance
	local count = parms.count
	local spread = parms.spread
	local preferred_biomes = parms.preferred_biomes
	local rng = mcl_levelgen.jvm_random (preset.seed)
	local biome_rng = mcl_levelgen.jvm_random (ull (0, 0))
	local angle = rng:next_double () * pi * 2
	local completed_spread = 0
	local triangle_counter = 0
	local positions = {}

	for i = 0, count - 1 do
		local dist_triangle
			= (4 * distance + distance * triangle_counter * 6)
		local dist_randomized = (rng:next_double () - 0.5)
			* distance * 2.5
		local dist_scaled
			= dist_triangle + dist_randomized
		local cx = round (mathcos (angle) * dist_scaled)
		local cz = round (mathsin (angle) * dist_scaled)
		rng:fork_into (biome_rng)

		-- First attempt to locate a preferred biome within
		-- range.
		local center_x = cx * 16 + 8
		local center_z = cz * 16 + 8
		local biome, x, _, z
			= locate_biome_in_area (preset, center_x,
						0, center_z, 112, biome_rng,
						is_preferred_biome,
						preferred_biomes)
		if biome then
			insert (positions, {
				arshift (x, 4),
				arshift (z, 4),
			})
		else
			insert (positions, {
				cx, cz,
			})
		end

		angle = angle + (pi * 2) / spread
		completed_spread = completed_spread + 1
		if completed_spread == spread then
			triangle_counter = triangle_counter + 1
			completed_spread = 0
			spread = spread + (2 * spread / (triangle_counter + 1))
			spread = mathmin (spread, count - i)
			angle = angle + rng:next_double () * pi * 2
		end
	end

	return positions
end

------------------------------------------------------------------------
-- Structure registration.
------------------------------------------------------------------------

-- local structure_def = {
-- 	biomes = {},
-- 	create_start = function (self, level, rng, cx, cz) end,
-- }

-- local structure_set = {
-- 	structures = {}, -- { structure = STRUCTURE, weight = WEIGHT, ... },
-- 	total_weight = nil,
-- 	placement = nil,
-- }

local all_registered_structure_sets = {}
local registered_structures_by_step = {}

for i = 1, NUM_GENERATION_STEPS do
	registered_structures_by_step[i] = {}
end

mcl_levelgen.registered_structures = {}
mcl_levelgen.registered_structure_sets = registered_structure_sets

function mcl_levelgen.register_structure_set (keyword, tbl)
	if mcl_levelgen.registered_structure_sets[keyword] then
		error ("Structure set " .. keyword .. " is already defined...")
	end

	assert (tbl.structures)
	assert (tbl.placement)
	local structures = {}
	local total_weight = 0
	for _, structure in ipairs (tbl.structures) do
		if type (structure) == "table" then
			local weight = structure.weight
			local structure = structure.structure
			local def = mcl_levelgen.registered_structures[structure]
			if not def then
				error ("Structure is not defined: " .. structure)
			end
			total_weight = total_weight + weight
			table.insert (structures, {
				weight = weight,
				structure = def,
			})
		else
			local def = mcl_levelgen.registered_structures[structure]
			if not def then
				error ("Structure is not defined: " .. structure)
			end
			total_weight = total_weight + 1
			table.insert (structures, {
				weight = 1,
				structure = def,
			})
		end
	end
	local set = {
		structures = structures,
		total_weight = total_weight,
		placement = tbl.placement,
	}
	table.insert (all_registered_structure_sets, set)
	mcl_levelgen.registered_structure_sets[keyword] = set
	return set
end

function mcl_levelgen.register_structure (keyword, def)
	if mcl_levelgen.registered_structures[keyword] then
		error ("Structure " .. keyword .. " is already defined...")
	end
	assert (def.create_start)
	assert (def.step
		and def.step > 0
		and def.step <= NUM_GENERATION_STEPS)
	def.name = keyword
	if not def.terrain_adaptation then
		def.terrain_adaptation = "none"
	else
		assert (def.terrain_adaptation == "none"
			or def.terrain_adaptation == "beard_thin"
			or def.terrain_adaptation == "beard_box"
			or def.terrain_adaptation == "bury"
			or def.terrain_adaptation == "encapsulate")
	end
	mcl_levelgen.registered_structures[keyword] = def
	local by_step = registered_structures_by_step[def.step]
	table.insert (by_step, keyword)
	return def
end

------------------------------------------------------------------------
-- Sorting of structure generation lists.
------------------------------------------------------------------------

local default_load_order = {
	"mcl_levelgen",
	"mcl_end",
	"mcl_villages",
}

local function append_structures (dst, src)
	local k = #dst
	for i = 1, #src do
		dst[k + i] = src[i]
	end
end

-- Sort a list of structures STRUCTURES by their namespaces, and,
-- within any single namespace, in order of their definition, but
-- giving namespaces which appear in `default_load_order' the
-- precedence they are assigned in that list over the rest.

local function sort_structure_list (in_structures)
	local new_list = {}
	local structures = {}

	for _, structure in ipairs (in_structures) do
		local name = string.split (structure, ':', nil, 2)
		if #name ~= 2 then
			local blurb = "Structure name: `"
				.. name
				.. "' does not incorporate a namespace"
			error (blurb)
		end
		local namespace = name[1]
		local namespace_list = structures[namespace] or {}
		structures[namespace] = namespace_list
		insert (namespace_list, structure)
	end

	local namespaces = {}
	for namespace, _ in pairs (structures) do
		if indexof (default_load_order, namespace) == -1 then
			insert (namespaces, namespace)
		end
	end
	for _, namespace in ipairs (default_load_order) do
		if structures[namespace] then
			append_structures (new_list, structures[namespace])
		end
	end
	for _, namespace in ipairs (namespaces) do
		append_structures (new_list, structures[namespace])
	end
	return new_list
end

mcl_levelgen.register_on_scripts_loaded (function ()
	for i = 1, NUM_GENERATION_STEPS do
		local structures = registered_structures_by_step[i]
		local sorted = sort_structure_list (structures)
		registered_structures_by_step[i] = sorted
	end
end)

------------------------------------------------------------------------
-- Level-wide structure generator state.
------------------------------------------------------------------------

-- Each structure piece should be a table incorporating a single
-- function `place', which places the piece's contents strictly within
-- the provided section of the MapChunk being generated, and a field
-- `bbox', holding the bounds of the piece itself.

local ull = mcl_levelgen.ull

local function set_contains_structure_generating_in_biomes_p (set, biomes)
	for _, structure in ipairs (set.structures) do
		for _, biome in ipairs (structure.structure.biomes) do
			if indexof (biomes, biome) ~= -1 then
				return true
			end
		end
	end
	return false
end

function mcl_levelgen.make_structure_level (preset)
	local structure_level = {
		preset = preset,
		level_seed = preset.seed,
		structure_sets = {},
		structure_starts = {},
		structure_refs = {},
		cnt_starts = 0,
	}

	local structure_start_link = {}
	structure_start_link.next = structure_start_link
	structure_start_link.prev = structure_start_link
	structure_level.structure_start_link = structure_start_link

	-- Enumerate all structure sets containing structures eligible
	-- to generate in biomes defined by PRESET.

	local biomes = preset:generated_biomes ()
	for _, set in ipairs (all_registered_structure_sets) do
		if set_contains_structure_generating_in_biomes_p (set, biomes) then
			table.insert (structure_level.structure_sets, set)
		end
	end

	-- Load (and hash) stronghold positions generated in the main
	-- thread.
	local stronghold_starts = {}
	if core then
		local seed = tostringull (preset.seed)
		local ipc_key = "mcl_levelgen:concentric_ring_cfgs," .. seed
		local tbl = core.ipc_get (ipc_key)

		if tbl then
			for name, list in pairs (tbl) do
				local is_start = {}
				for _, pos in ipairs (list) do
					local hash = struct_hash (pos[1], pos[2])
					is_start[hash] = true
				end
				stronghold_starts[name] = is_start
			end
		end
	end
	structure_level.stronghold_starts = stronghold_starts

	return structure_level
end

local generation_rng = mcl_levelgen.jvm_random (ull (0, 0), ull (0, 0))
local structure_rng = mcl_levelgen.jvm_random (ull (0, 0), ull (0, 0))

-- Invoke CB with each structure start that should generate in the
-- chunk CX, CZ, CX, and CZ, LEVEL, and DATA.  LEVEL must be the
-- structure level representing the level in which structures are to
-- generate.

local function do_nothing ()
end

local function get_structure_starts (level, terrain, cx, cz, cb, data, structure_sets)
	for _, set in ipairs (structure_sets or level.structure_sets) do
		local structures = set.structures
		local total_weight = set.total_weight
		local n_structures = #structures
		local seed = level.level_seed

		if not structure_starts_in_chunk_p (level, set.placement, cx, cz) then
			do_nothing ()
		elseif n_structures == 1 then
			set_carver_seed (structure_rng, seed, cx, cz)
			local start = structures[1].structure:create_start (level, terrain,
									    structure_rng,
									    cx, cz)
			if start then
				cb (start, cx, cz, level, data)
			end
		else
			set_carver_seed (generation_rng, seed, cx, cz)
			local indices_eliminated = {}
			while #indices_eliminated < n_structures do
				local weight = generation_rng:next_within (total_weight)
				local idx = 1
				while idx <= n_structures do
					if indexof (indices_eliminated, idx) == -1 then
						local entry = structures[idx]
						weight = weight - entry.weight

						if weight < 0 then
							break
						end
					end
					idx = idx + 1
				end

				local entry = structures[idx]
				set_carver_seed (structure_rng, seed, cx, cz)
				local start = entry.structure:create_start (level, terrain,
									    structure_rng,
									    cx, cz)
				if start then
					cb (start, cx, cz, level, data)
					break
				end

				-- Otherwise remove this element from
				-- consideration and try again.
				insert (indices_eliminated, idx)
				total_weight = total_weight - entry.weight
			end
		end
	end
end

-- Prepare structure generation for a MapChunk at X, Z.  TERRAIN
-- should be the terrain generator in use.

local chunksize

local function internal_chunk_hash (dx, dz)
	local x = dx
	local z = dz
	return x * chunksize + z + 1
end

local function insert_structure_start (start, cx, cz, level, data)
	data[#data + 1] = start
end

local function unpack6 (aabb)
	return aabb[1], aabb[2], aabb[3], aabb[4], aabb[5], aabb[6]
end

local function intersect_2d_p (a, x1, z1, x2, z2)
	return a[4] >= x1 and a[1] <= x2
		and a[6] >= z1 and a[3] <= z2
end
mcl_levelgen.intersect_2d_p = intersect_2d_p

local function AABB_intersect_p (a, b)
	local x1a, y1a, z1a, x2a, y2a, z2a = unpack6 (a)
	local x1b, y1b, z1b, x2b, y2b, z2b = unpack6 (b)

	return x1a <= x2b
		and y1a <= y2b
		and z1a <= z2b
		and x2a >= x1b
		and y2a >= y1b
		and z2a >= z1b
end
mcl_levelgen.AABB_intersect_p = AABB_intersect_p

local function AABB_intersect (a, b)
	local x1a, y1a, z1a, x2a, y2a, z2a = unpack6 (a)
	local x1b, y1b, z1b, x2b, y2b, z2b = unpack6 (b)
	return {
		mathmax (x1a, x1b),
		mathmax (y1a, y1b),
		mathmax (z1a, z1b),
		mathmin (x2a, x2b),
		mathmin (y2a, y2b),
		mathmin (z2a, z2b),
	}
end
mcl_levelgen.AABB_intersect = AABB_intersect

local function collect_structure_references (starts, cx, cz)
	local x1, z1 = cx * 16, cz * 16
	local x2, z2 = x1 + 15, z1 + 15
	local refs = {}

	for x = cx - 8, cx + 8 do
		for z = cz - 8, cz + 8 do
			local hash = struct_hash (x, z)
			local local_starts = starts[hash].starts
			for _, start in ipairs (local_starts) do
				if intersect_2d_p (start.bbox, x1, z1, x2, z2) then
					refs[#refs + 1] = start
				end
			end
		end
	end

	return refs
end

local MAX_LOADED_STARTS = 16384

function mcl_levelgen.prepare_structures (level, terrain, x, z)
	local cx, cz = floor (x / 16), floor (z / 16)
	local starts = level.structure_starts
	local starts_created = 0
	local link = level.structure_start_link

	-- Build a map of structure starts in each chunk within 8
	-- MapBlocks of the MapChunk at X, Z.
	chunksize = floor (terrain.chunksize / 16)
	for x = cx - 8, cx + chunksize + 7 do
		for z = cz - 8, cz + chunksize + 7 do
			local hash = struct_hash (x, z)
			local start = starts[hash]
			if not start then
				local local_starts = {}
				local record = {
					starts = local_starts,
					hash = hash,
					prev = link,
					next = link.next,
				}
				link.next.prev = record
				link.next = record
				starts[hash] = record
				get_structure_starts (level, terrain, x, z,
						      insert_structure_start,
						      local_starts, nil)
				starts_created = starts_created + 1
			else
				-- Relink to the start of the list.
				start.next.prev = start.prev
				start.prev.next = start.next
				start.next = link.next
				start.last = link
				link.next.prev = start
				link.next = start
			end
		end
	end

	-- And references for each chunk in the MapChunk.
	local refs = level.structure_refs
	for dx = 0, chunksize - 1 do
		for dz = 0, chunksize - 1 do
			local ihash = internal_chunk_hash (dx, dz)
			local cx = cx + dx
			local cz = cz + dz
			refs[ihash] = collect_structure_references (starts, cx, cz)
		end
	end

	-- Remove excess elements from the start cache.
	local cnt = level.cnt_starts + starts_created
	level.cnt_starts = cnt
end

local current_structure_start
local current_structure_piece

local level_chunksize
local level_y_chunksize
local nodes_origin_x
local nodes_origin_y
local nodes_origin_z
local placed_pieces = {}
local piece_recorded = {}

local function execute_structure_start_in_chunk (level, terrain, start, rng,
						 x1, z1, x2, z2, sid, chunksum)
	current_structure_start = start
	for _, piece in ipairs (start.pieces) do
		local bbox = piece.bbox
		if intersect_2d_p (bbox, x1, z1, x2, z2) then
			current_structure_piece = piece
			piece:place (level, terrain, rng, x1, z1, x2, z2)
		end

		if not piece_recorded[piece]
			and intersect_2d_p (bbox, nodes_origin_x,
					    nodes_origin_z,
					    nodes_origin_x + level_chunksize - 1,
					    nodes_origin_z + level_chunksize - 1)
			and bbox[5] >= nodes_origin_y
			and bbox[2] < nodes_origin_y + level_y_chunksize then
			insert (placed_pieces, {
				bbox[1],
				bbox[2],
				bbox[3],
				bbox[4],
				bbox[5],
				bbox[6],
				sid,
			})
			piece_recorded[piece] = true
		end
	end
	current_structure_piece = nil
	current_structure_start = nil
end

local set_population_seed = mcl_levelgen.set_population_seed
local set_decorator_seed = mcl_levelgen.set_decorator_seed
local prepare_structure_placement0
local prepare_structure_placement1
local current_generation_step
local gen_notifies = {}

local function place_structures_in_chunk (level, terrain, starts, i,
					  structures, cx, cz, chunksum)
	local x1, z1 = cx * 16, cz * 16
	local x2, z2 = x1 + 15, z1 + 15
	local rng = structure_rng
	local pop = set_population_seed (rng, level.level_seed, x1, z1)

	current_generation_step = i
	prepare_structure_placement1 (level, terrain, x1, z1)

	for j, sid in ipairs (structures) do
		set_decorator_seed (rng, pop, j - 1, i - 1)

		for _, start in ipairs (starts) do
			if start.structure == sid then
				execute_structure_start_in_chunk (level, terrain, start,
								  rng, x1, z1, x2, z2,
								  sid, chunksum)
			end
		end
	end
end

-- local function count_entries (link)
-- 	local k = link.next
-- 	local n = 0
-- 	while k ~= link do
-- 		n = n + 1
-- 		k = k.next
-- 	end
-- 	return n
-- end

local structure_extents = {
	0, 0, 0, 0, 0, 0,
}

function mcl_levelgen.finish_structures (level, terrain, biomes, x, y, z,
					 effective_level_min, level_height,
					 index, nodes)
	chunksize = floor (terrain.chunksize / 16)
	local refs = level.structure_refs
	local cx, cz = floor (x / 16), floor (z / 16)

	prepare_structure_placement0 (level, terrain, biomes, index,
				      x, y, z, effective_level_min,
				      level_height, nodes)

	for i = 1, NUM_GENERATION_STEPS do
		local structures = registered_structures_by_step[i]
		if #structures > 0 then
			for dx = 0, chunksize - 1 do
				for dz = 0, chunksize - 1 do
					local hash = internal_chunk_hash (dx, dz)
					local starts = refs[hash]
					place_structures_in_chunk (level, terrain, starts, i,
								   structures, cx + dx, cz + dz,
								   dx + dz)
				end
			end
		end
	end

	local starts = level.structure_starts
	local link = level.structure_start_link
	local cnt = level.cnt_starts
	if cnt > MAX_LOADED_STARTS then
		-- Remove the least recently loaded entries from the
		-- cache.
		local n = cnt - MAX_LOADED_STARTS
		for i = 1, n do
			local prev = link.prev
			starts[prev.hash] = nil
			link.prev = prev.prev
			link.prev.next = link
		end
		level.cnt_starts = MAX_LOADED_STARTS
	end
	return structure_extents
end

function mcl_levelgen.structure_biome_test (level, structure_def, x, y, z)
	local biome = level.preset:index_biomes_block (x, y, z)
	return indexof (structure_def.biomes, biome) ~= -1
end

------------------------------------------------------------------------
-- Structure utilities.
------------------------------------------------------------------------

local function bbox_height (bbox)
	return bbox[5] - bbox[2] + 1
end

local function bbox_width_x (bbox)
	return bbox[4] - bbox[1] + 1
end

local function bbox_width_z (bbox)
	return bbox[6] - bbox[3] + 1
end
mcl_levelgen.bbox_height = bbox_height
mcl_levelgen.bbox_width_x = bbox_width_x
mcl_levelgen.bbox_width_z = bbox_width_z

local function bbox_from_pieces (pieces)
	local bbox = {
		huge, huge, huge,
		-huge, -huge, -huge,
	}
	for _, piece in ipairs (pieces) do
		local box_1 = piece.bbox
		bbox[1] = mathmin (bbox[1], box_1[1])
		bbox[2] = mathmin (bbox[2], box_1[2])
		bbox[3] = mathmin (bbox[3], box_1[3])
		bbox[4] = mathmax (bbox[4], box_1[4])
		bbox[5] = mathmax (bbox[5], box_1[5])
		bbox[6] = mathmax (bbox[6], box_1[6])
	end
	return bbox
end
mcl_levelgen.bbox_from_pieces = bbox_from_pieces

function mcl_levelgen.create_structure_start (structure_def, pieces)
	if #pieces == 0 then
		return nil
	end

	local bbox = bbox_from_pieces (pieces)
	return {
		structure = structure_def.name,
		bbox = bbox,
		pieces = pieces,
		terrain_adaptation = structure_def.terrain_adaptation,
	}
end
local create_structure_start = mcl_levelgen.create_structure_start

function mcl_levelgen.translate_vertically (pieces, dy)
	for _, piece in ipairs (pieces) do
		local bbox = piece.bbox
		bbox[2] = bbox[2] + dy
		bbox[5] = bbox[5] + dy
	end
end

function mcl_levelgen.translate_pieces (pieces, dx, dy, dz)
	for _, piece in ipairs (pieces) do
		local bbox = piece.bbox
		bbox[1] = bbox[1] + dx
		bbox[4] = bbox[4] + dx
		bbox[2] = bbox[2] + dy
		bbox[5] = bbox[5] + dy
		bbox[3] = bbox[3] + dz
		bbox[6] = bbox[6] + dz
	end
end

local translate_vertically = mcl_levelgen.translate_vertically

-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1
-- /net/minecraft/structure/StructurePiecesCollector.html
-- #shiftInto(int,int,net.minecraft.util.math.random.Random,int)

function mcl_levelgen.shift_into (pieces, top_y, bottom_y, rng,
				  top_penalty)
	-- print ("TopY: " .. top_y .. " BottomY: " .. bottom_y)
	local advisory_top_y = top_y - top_penalty
	local bbox = bbox_from_pieces (pieces)
	local max_y = bbox_height (bbox) + bottom_y + 1
	-- print ("MaxY: " .. max_y .. " AdvisoryTopY: " .. advisory_top_y)
	if max_y < advisory_top_y then
		local value = rng:next_within (advisory_top_y - max_y)
		-- print ("Value: " .. value .. " (" .. (advisory_top_y - max_y) .. ")")
		max_y = max_y + value
	end
	local dy = max_y - bbox[5]
	translate_vertically (pieces, dy)
	return dy
end

function mcl_levelgen.bbox_center (bbox)
	local width = bbox[4] - bbox[1] + 1
	local height = bbox[5] - bbox[2] + 1
	local length = bbox[6] - bbox[3] + 1
	local cw = floor (width / 2)
	local ch = floor (height / 2)
	local cl = floor (length / 2)
	return cw + bbox[1], ch + bbox[2], cl + bbox[3]
end

function mcl_levelgen.any_collisions (pieces, bbox)
	for _, piece in ipairs (pieces) do
		if AABB_intersect_p (piece.bbox, bbox) then
			return true
		end
	end
	return false
end

function mcl_levelgen.first_collision (pieces, bbox)
	for _, piece in ipairs (pieces) do
		if AABB_intersect_p (piece.bbox, bbox) then
			return piece
		end
	end
	return nil
end

function mcl_levelgen.any_collisions_2d (pieces, bbox, parent)
	for _, piece in ipairs (pieces) do
		if intersect_2d_p (piece.bbox, bbox[1], bbox[3],
				   bbox[4], bbox[6])
			and piece ~= parent then
			return true
		end
	end
	return false
end

function mcl_levelgen.any_collisions_matching_2d (pieces, bbox, predicate, data)
	for _, piece in ipairs (pieces) do
		if intersect_2d_p (piece.bbox, bbox[1], bbox[3],
				   bbox[4], bbox[6])
			and predicate (piece, data) then
			return true
		end
	end
	return false
end

------------------------------------------------------------------------
-- Beardification.
------------------------------------------------------------------------

local beard_weights = {}
local ipos1 = mcl_levelgen.ipos1
local sqrt = math.sqrt

for x, y, z in ipos1 (0, 0, 0, 24, 24, 24) do
	local idx = ((x * 24) + y) * 24 + z + 1
	local dx, dy, dz = x - 12, y - 12 + 0.5, z - 12
	local length = dx * dx + dy * dy + dz * dz
	beard_weights[idx] = math.exp (-length / 16)
end

local function map_bury (dx, dy, dz)
	local length = sqrt (dx * dx + dy * dy + dz * dz)
	if length > 6.0 then
		return 0.0
	else
		return 1.0 - length / 6.0
	end
end

local function map_beard_or_beard_box (dx, dy, dz, dy_floor)
	local dx_idx = dx + 12
	local dy_idx = dy + 12
	local dz_idx = dz + 12

	if not (dx_idx >= 0 and dy_idx >= 0 and dz_idx >= 0
		and dx_idx < 24 and dy_idx < 24 and dz_idx < 24) then
		return 0.0
	end
	local idx = ((dx_idx * 24) + dy_idx) * 24 + dz_idx + 1
	local dist_center = dy_floor + 0.5
	local dist_sqr = (dx * dx + dist_center * dist_center + dz * dz)
	local inv_value = 1.0 / sqrt (dist_sqr / 2.0)
	local floor_scale = -dist_center * inv_value / 2.0
	return floor_scale * beard_weights[idx]
end

local function apply_terrain_adaptation (pieces, terrain_adaptation,
					 weights, index, bbox, chunksize,
					 level_height, x_chunk, z_chunk,
					 y_min)
	for _, piece in ipairs (pieces) do
		if not piece.no_terrain_adaptation then
			local piece_bbox = piece.bbox
			local x1 = mathmax (piece_bbox[1] - 12, bbox[1] + 12)
			local y1 = mathmax (piece_bbox[2] - 12, bbox[2])
			local z1 = mathmax (piece_bbox[3] - 12, bbox[3] + 12)
			local x2 = mathmin (piece_bbox[4] + 12, bbox[4] - 12)
			local y2 = mathmin (piece_bbox[5] + 12, bbox[5])
			local z2 = mathmin (piece_bbox[6] + 12, bbox[6] - 12)
			for x, y, z in ipos1 (x1, y1, z1, x2, y2, z2) do
				local value
				if piece.reduced_terrain_adaptation then
					local coords = piece.reduced_terrain_adaptation
					local dx = mathabs (x - coords[1])
					local dy = y - coords[2]
					local dz = mathabs (z - coords[3])
					value = map_beard_or_beard_box (dx, dy, dz, dy) * coords[4]
				else
					local dx = mathmax (0, piece_bbox[1] - x, x - piece_bbox[4])
					local dz = mathmax (0, piece_bbox[3] - z, z - piece_bbox[6])
					local yground = piece_bbox[2] + (piece.ground_offset or 0)
					local dy = y - yground
					local dy_final = dy

					if terrain_adaptation == "beard_box"
						or terrain_adaptation == "encapsulate" then
						dy_final = mathmax (0, yground - y, y - piece_bbox[5])
					end

					if terrain_adaptation == "bury" then
						value = map_bury (dx, dy_final / 2.0, dz)
					elseif terrain_adaptation == "beard_thin"
						or terrain_adaptation == "beard_box" then
						value = map_beard_or_beard_box (dx, dy_final, dz, dy) * 0.8
					else -- if terrain_adaptation == "encapsulate" then
						value = map_bury (dx / 2.0, dy_final / 2.0, dz / 2.0) * 0.8
					end
				end
				local idx = index (x - x_chunk, y - y_min,
						   z - z_chunk, chunksize,
						   level_height)
				weights[idx] = weights[idx] + value
			end
		end
	end
end

local function beardifier_box_intersect_p (a, x1b, y1b, z1b, x2b, y2b, z2b)
	local x1a, y1a, z1a, x2a, y2a, z2a = unpack6 (a)

	return x1a <= x2b
		and y1a <= y2b
		and z1a <= z2b
		and x2a >= x1b
		and y2a >= y1b
		and z2a >= z1b
end

local function beardify_1 (level, terrain, weights, index, x, z,
			   level_height, y_min, chunksize, boxes)
	local bbox = {
		x - 12,
		y_min,
		z - 12,
		x + 12 + chunksize - 1,
		y_min + level_height - 1,
		z + 12 + chunksize - 1,
	}
	local starts = level.structure_starts
	local cx, cz = floor (x / 16), floor (z / 16)
	local chunksize_1 = floor (terrain.chunksize / 16)
	local any_adaptation = false
	for cx = cx - 8, cx + chunksize_1 + 7 do
		for cz = cz - 8, cz + chunksize_1 + 7 do
			local hash = struct_hash (cx, cz)
			local local_starts = starts[hash].starts

			for _, start in ipairs (local_starts) do
				if start.terrain_adaptation ~= "none"
					and AABB_intersect_p (start.bbox, bbox) then
					any_adaptation = true
					apply_terrain_adaptation (start.pieces,
								  start.terrain_adaptation,
								  weights, index, bbox,
								  chunksize, level_height,
								  x, z, y_min)
					if boxes then
						local bx1, by1, bz1, bx2, by2, bz2
							= unpack6 (start.bbox)
						bx1 = bx1 - 12
						by1 = by1 - 12
						bz1 = bz1 - 12
						bx2 = bx2 + 12
						by2 = by2 + 12
						bz2 = bz2 + 12
						local intersection = false
						for _, box in ipairs (boxes) do
							if beardifier_box_intersect_p (box, bx1, by1, bz1,
										       bx2, by2, bz2) then
								box[1] = mathmin (box[1], bx1)
								box[2] = mathmin (box[2], by1)
								box[3] = mathmin (box[3], bz1)
								box[4] = mathmax (box[4], bx2)
								box[5] = mathmax (box[5], by2)
								box[6] = mathmax (box[6], bz2)
								intersection = true
								break
							end
						end
						if not intersection then
							insert (boxes, {
								bx1, by1, bz1,
								bx2, by2, bz2,
							})
						end
					end
				end
			end
		end
	end
	return any_adaptation
end
mcl_levelgen.beardify_1 = beardify_1

-- Fill WEIGHTS with beardifier weights from each piece intersecting
-- the MapChunk at X, Y, with reference to structure starts stored in
-- LEVEL.
--
-- WEIGHTS must be initialized to 0.

function mcl_levelgen.beardify (level, terrain, weights, index, x, z)
	local chunksize = terrain.chunksize
	local level_height = terrain.level_height
	local y_min = terrain.y_min
	beardify_1 (level, terrain, weights, index, x, z,
		    level_height, y_min, chunksize, nil)
end

------------------------------------------------------------------------
-- Structure generation environment.
------------------------------------------------------------------------

local biome_seed
local biomes
local heightmap
local heightmap_wg
local index
local level_height
local level_max_y
local level_min
local effective_level_min
local nodes

function prepare_structure_placement0 (level, terrain, p_biomes,
				       p_index, x, y, z,
				       p_effective_level_min,
				       p_level_height, p_nodes)
	biome_seed = terrain.biome_seed
	biomes = p_biomes
	heightmap = terrain.heightmap
	heightmap_wg = terrain.heightmap_wg
	index = p_index
	level_chunksize = terrain.chunksize
	level_y_chunksize = terrain.chunksize_y
	level_height = p_level_height
	level_min = level.preset.min_y
	effective_level_min = p_effective_level_min
	level_max_y = effective_level_min + level_height - 1
	nodes = p_nodes
	nodes_origin_x = x
	nodes_origin_y = y
	nodes_origin_z = z
	structure_extents[1] = huge
	structure_extents[2] = huge
	structure_extents[3] = huge
	structure_extents[4] = -huge
	structure_extents[5] = -huge
	structure_extents[6] = -huge

	mcl_levelgen.placement_level_min = effective_level_min
	mcl_levelgen.placement_level_height = level_height
end
mcl_levelgen.prepare_structure_placement0 = prepare_structure_placement0

local origin_x
local origin_z

function prepare_structure_placement1 (level, terrain, x1, z1)
	assert (x1 >= nodes_origin_x
		and x1 < nodes_origin_x + level_chunksize)
	assert (z1 >= nodes_origin_z
		and z1 < nodes_origin_z + level_chunksize)
	origin_x = x1
	origin_z = z1
end

local cid_air

if core then
	cid_air = core.CONTENT_AIR
else
	cid_air = 0
end

local function is_not_air (cid, param2)
	return cid ~= cid_air
end

mcl_levelgen.is_not_air = is_not_air

if not mcl_levelgen.load_feature_environment then

local decode_node = mcl_levelgen.decode_node
local encode_node = mcl_levelgen.encode_node

local ENCODED_NODE_MASK = 0xffffff

local function structure_encode_node (cid, param2)
	local node = encode_node (cid, param2)
	return node + lshift (current_generation_step, 24)
end

local cid_air_encoded
local cids_walkable = {}

if core and core.get_content_id then
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
	cid_air_encoded = encode_node (cid_air, 0)
else
	for i = 2, 2048 do
		cids_walkable[i] = true
	end
	cid_air_encoded = encode_node (cid_air, 0)
end

local function block_index (x, y, z)
	return index (x - nodes_origin_x,
		      y - effective_level_min,
		      z - nodes_origin_z, level_chunksize,
		      level_height)
end

local function heightmap_index (x, z)
	return ((x - nodes_origin_x) * level_chunksize)
		+ (z - nodes_origin_z) + 1
end

local function get_block_1 (x, y, z)
	local idx = block_index (x, y, z)
	local nodedata = nodes[idx]
	return decode_node (nodedata)
end

function mcl_levelgen.get_block (x, y, z)
	if x < origin_x or x >= origin_x + 16
		or z < origin_z or z >= origin_z + 16
		or y < effective_level_min
		or y > level_max_y then
		return nil
	end

	return get_block_1 (x, y, z)
end

local function is_walkable (cid, param2)
	return cids_walkable[cid]
end

mcl_levelgen.is_walkable = is_walkable

local unpack_height_map = mcl_levelgen.unpack_height_map
local pack_height_map = mcl_levelgen.pack_height_map

local function find_solid_surface (x, y, z, is_solid)
	for y = y, effective_level_min, -1 do
		if is_solid (get_block_1 (x, y, z)) then
			return y + 1
		end
	end

	return effective_level_min
end

local function correct_heightmaps (x, y, z, cid, param2, force)
	-- Correct heightmaps to agree with the new state of the
	-- level.
	local idx = heightmap_index (x, z)
	local value = heightmap[idx]
	local surface, motion_blocking = unpack_height_map (value)
	surface = surface + level_min
	motion_blocking = motion_blocking + level_min

	-- if x == 561 and z == 8043 then
	-- 	print ("IN", surface - level_min, motion_blocking - level_min)
	-- end

	if not is_not_air (cid, param2) then
		if (surface - 1) == y or force then
			-- Search downwards.
			surface = find_solid_surface (x, y, z, is_not_air)
		end
	elseif surface < y + 1 then
		surface = y + 1
	end

	if not is_walkable (cid, param2) then
		if (motion_blocking - 1) == y or force then
			-- Search downwards.
			motion_blocking = find_solid_surface (x, y, z, is_walkable)
		end
	elseif motion_blocking < y + 1 then
		motion_blocking = y + 1
	end

	-- if x == 561 and z == 8043 then
	-- 	print ("OUT", surface - level_min, motion_blocking - level_min)
	-- end
	heightmap[idx] = pack_height_map (surface - level_min,
					  motion_blocking - level_min)
end

local function update_structure_extents (x, y, z)
	structure_extents[1] = mathmin (x, structure_extents[1])
	structure_extents[2] = mathmin (y, structure_extents[2])
	structure_extents[3] = mathmin (z, structure_extents[3])
	structure_extents[4] = mathmax (x, structure_extents[4])
	structure_extents[5] = mathmax (y, structure_extents[5])
	structure_extents[6] = mathmax (z, structure_extents[6])
end

function mcl_levelgen.set_block (x, y, z, cid, param2)
	if x < origin_x or x >= origin_x + 16
		or z < origin_z or z >= origin_z + 16
		or y < effective_level_min or y > level_max_y then
		return nil
	end

	local node = structure_encode_node (cid, param2)
	local idx = block_index (x, y, z)
	nodes[idx] = node
	correct_heightmaps (x, y, z, cid, param2, false)
	update_structure_extents (x, y, z)
end

local set_block = mcl_levelgen.set_block

function mcl_levelgen.set_block_checked (x, y, z, cid, param2, writable_p)
	if x < origin_x or x >= origin_x + 16
		or z < origin_z or z >= origin_z + 16
		or y < effective_level_min or y > level_max_y then
		return nil
	end

	local node = structure_encode_node (cid, param2)
	local idx = block_index (x, y, z)
	local cid_1, param2_1 = decode_node (nodes[idx])
	if writable_p (cid_1, param2_1) then
		nodes[idx] = node
		correct_heightmaps (x, y, z, cid, param2, false)
		update_structure_extents (x, y, z)
	end
end

function mcl_levelgen.reorientate_coords (piece, x, y, z)
	local dir, bbox = piece.dir, piece.bbox
	if dir == "north" then
		return bbox[1] + x, bbox[2] + y, bbox[6] - z
	elseif dir == "south" then
		return bbox[1] + x, bbox[2] + y, bbox[3] + z
	elseif dir == "west" then
		return bbox[4] - z, bbox[2] + y, bbox[3] + x
	elseif dir == "east" then
		return bbox[1] + z, bbox[2] + y, bbox[3] + x
	else
		assert (false)
	end
end

local munge_biome_coords = mcl_levelgen.munge_biome_coords
local bindex = mcl_levelgen.biome_table_index
local toquart = mcl_levelgen.toquart

local function munge_biome_index (x, y, z, level_min, bx, bz)
	local qx, qy, qz = munge_biome_coords (biome_seed, x, y, z)
	qy = qy - toquart (level_min)
	return qx - toquart (bx), qy, qz - toquart (bz)
end

function mcl_levelgen.index_biome (x, y, z)
	if x < origin_x or x >= origin_x + 16
		or z < origin_z or z >= origin_z + 16
		or y < effective_level_min or y > level_max_y then
		error ("Biome index out of bounds")
	end
	local ix, iy, iz = munge_biome_index (x, y, z, level_min,
					      nodes_origin_x,
					      nodes_origin_z)
	local cs = toquart (level_chunksize)
	local idx = bindex (ix, iy, iz, cs, toquart (level_height), cs)
	return biomes[idx]
end

function mcl_levelgen.index_heightmap (x, z, wg)
	if x < origin_x or x >= origin_x + 16
		or z < origin_z or z >= origin_z + 16 then
		return level_min, level_min
	end

	local heightmap = wg and heightmap_wg or heightmap
	local idx = heightmap_index (x, z)
	local surface, motion_blocking
		= unpack_height_map (heightmap[idx])
	return surface + level_min, motion_blocking + level_min
end

local function notify_generated_unchecked (name, data, append)
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
mcl_levelgen.notify_generated_unchecked = notify_generated_unchecked

function mcl_levelgen.notify_generated (name, x, y, z, data, append)
	assert (type (name) == "string")
	if y >= nodes_origin_y
		and y < nodes_origin_y + level_y_chunksize
		and x >= origin_x
		and z >= origin_z
		and x < origin_x + 16
		and z < origin_z + 16 then
		notify_generated_unchecked (name, data, append)
	end
end
local notify_generated = mcl_levelgen.notify_generated

function mcl_levelgen.create_entity (x_block, y_block, z_block, name, staticdata)
	-- It is possible for mcl_levelgen.create_entity and other
	-- functions which exercise this facility to be invoked by
	-- data block processors, and crash when a jigsaw structure
	-- exercising such processors is generated from a jigsaw
	-- block.
	if not mcl_levelgen.is_levelgen_environment then
		return
	end
	notify_generated ("mcl_levelgen:create_entity_1", x_block, y_block, z_block, {
		x_block, y_block, z_block, name, staticdata,
	})
end

function mcl_levelgen.set_loot_table (x_block, y_block, z_block, rng, name)
	if not mcl_levelgen.is_levelgen_environment then
		return
	end
	notify_generated ("mcl_levelgen:set_loot_table_1", x_block, y_block, z_block, {
		x_block, y_block, z_block, name, mathabs (rng:next_integer ()),
	})
end

function mcl_levelgen.flush_structure_gen_data ()
	local notifies, pieces = gen_notifies, placed_pieces
	gen_notifies = {}
	placed_pieces = {}
	piece_recorded = {}
	return notifies, pieces
end

function mcl_levelgen.current_structure_start ()
	return current_structure_start
end

function mcl_levelgen.current_structure_piece ()
	return current_structure_piece
end

function mcl_levelgen.lowest_corner_from_point (terrain, x1, z1, dx, dz)
	local h1 = terrain:get_one_height (x1, z1, is_not_air)
	local h2 = terrain:get_one_height (x1, z1 + dz, is_not_air)
	local h3 = terrain:get_one_height (x1 + dx, z1, is_not_air)
	local h4 = terrain:get_one_height (x1 + dx, z1 + dz, is_not_air)
	return mathmin (h1, h2, h3, h4) - 1
end

local lowest_corner_from_point = mcl_levelgen.lowest_corner_from_point

function mcl_levelgen.lowest_corner_from_chunk_origin (terrain, cx, cz, dx, dz)
	local x1 = cx * 16
	local z1 = cz * 16
	return lowest_corner_from_point (terrain, x1, z1, dx, dz)
end

function mcl_levelgen.height_of_lowest_corner_including_center (terrain, cx, cz, rotation)
	local dx = 5
	local dz = 5
	if rotation == "90" then
		dx = -5
	elseif rotation == "180" then
		dx = -5
		dz = -5
	elseif rotation == "270" then
		dz = -5
	end

	local x1 = cx * 16 + 7
	local z1 = cz * 16 + 7

	local h1 = terrain:get_one_height (x1, z1, is_not_air)
	local h2 = terrain:get_one_height (x1, z1 + dz, is_not_air)
	local h3 = terrain:get_one_height (x1 + dx, z1, is_not_air)
	local h4 = terrain:get_one_height (x1 + dx, z1 + dz, is_not_air)
	return mathmin (h1, h2, h3, h4) - 1
end

local ALL_DIRS = {
	"north",
	"east",
	"south",
	"west",
}

function mcl_levelgen.random_orientation (rng)
	return ALL_DIRS[1 + rng:next_within (4)]
end

function mcl_levelgen.make_rotated_bbox (x, y, z, orientation, width, height, length)
	if orientation == "north" or orientation == "south" then
		return {
			x, y, z, x + width - 1, y + height - 1, z + length - 1,
		}
	else
		return {
			x, y, z, x + length - 1, y + height - 1, z + width - 1,
		}
	end
end

-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/util/math/BlockBox.html#rotated(int,int,int,int,int,int,int,int,int,net.minecraft.util.math.Direction)

function mcl_levelgen.rotated_block_box (x, y, z, dx, dy, dz, width, height, length, dir)
	if dir == "south" then
		return {
			x + dx, y + dy, z + dz,
			x + width - 1 + dx,
			y + height - 1 + dy,
			z + length - 1 + dz,
		}
	elseif dir == "north" then
		return {
			x + dx, y + dy, z - length + 1 + dz,
			x + width - 1 + dx,
			y + height - 1 + dy,
			z + dz,
		}
	elseif dir == "west" then
		return {
			x - length + 1 + dz, y + dy, z + dx,
			x + dz,
			y + height - 1 + dy,
			z + width - 1 + dx,
		}
	elseif dir == "east" then
		return {
			x + dz, y + dy, z + dx,
			x + length - 1 + dz,
			y + height - 1 + dy,
			z + width - 1 + dx,
		}
	end
	assert (false)
end

------------------------------------------------------------------------
-- Feature placement.
------------------------------------------------------------------------

-- This function may be invoked at any point in the generation
-- process, but the feature specified is not guaranteed to be placed
-- unless it is scheduled before the chunk containing X, Y, Z could
-- possibly be generated, e.g., while computing structure starts for a
-- structure guaranteed to intersect this position, or while placing a
-- structure piece that does.

function mcl_levelgen.schedule_feature_placement (x, y, z, configured_feature)
	notify_generated_unchecked ("mcl_levelgen:defer_feature_placement", {
		x, y, z, current_generation_step, configured_feature,
	})
end

local schedule_feature_placement = mcl_levelgen.schedule_feature_placement
local index_heightmap = mcl_levelgen.index_heightmap

local heightmap_accessors = {
	world_surface = function (x, z)
		local surface, _ = index_heightmap (x, z, false)
		return surface
	end,
	motion_blocking = function (x, z)
		local _, motion_blocking = index_heightmap (x, z, false)
		return motion_blocking
	end,
	world_surface_wg = function (x, z)
		local surface, _ = index_heightmap (x, z, true)
		return surface
	end,
	motion_blocking_wg = function (x, z)
		local _, motion_blocking = index_heightmap (x, z, true)
		return motion_blocking
	end,
}

local function place_feature_structure_piece (self, level, terrain, rng,
					      x1, z1, x2, z2)
	local x = self.x
	local y = self.y
	local z = self.z
	local index_heightmap = self.index_heightmap

	if index_heightmap then
		if x >= x1 and z >= z1 and x <= x2 and z <= z2 then
			local y = index_heightmap (x, z)
			schedule_feature_placement (x, y, z, self.configured_feature)
		end
	else
		if x >= x1 and z >= z1 and x <= x2 and z <= z2
			and y >= nodes_origin_y
			and y < nodes_origin_y + level_y_chunksize then
			schedule_feature_placement (x, y, z, self.configured_feature)
		end
	end
end

function mcl_levelgen.make_feature_structure_piece (feature, x, y, z, rx, ry, rz,
						    heightmap)
	local bbox = {
		x - rx,
		y - ry,
		z - rz,
		x + rx,
		y + ry,
		z + rz,
	}
	return {
		configured_feature = feature,
		place = place_feature_structure_piece,
		x = x,
		y = y,
		z = z,
		bbox = bbox,
		no_terrain_adaptation = true,
		index_heightmap = heightmap
			and heightmap_accessors[heightmap] or nil,
	}
end

------------------------------------------------------------------------
-- Schematic placement.
------------------------------------------------------------------------

local portable_schematics = mcl_levelgen.portable_schematics
local cid_ignore = core and core.CONTENT_IGNORE or 5000
local cid_ignore_encoded = encode_node (cid_ignore, 0)
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
local v = { x = 0, y = 0, z = 0, }

local MTSCHEM_PROB_ALWAYS = 0xFF
local MTSCHEM_PROB_NEVER  = 0x00

local function hash_schem_pos (x, z)
	return bor (lshift ((x + 32768), 16), (z + 32768))
end

local function copy_to_data (schematic, px, py, pz, rot, force_place)
	local size = schematic.size
	local xstride = 1
	local ystride = size.x
	local zstride = size.x * size.y
	local sx = size.x
	local sy = size.y
	local sz = size.z
	local xz_updates = {}
	local y_generate = {}
	local rotate_param2 = mcl_levelgen.rotate_param2

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

	local yprob = schematic.yslice_prob
	local schemdata = schematic.data
	local rng = schematic_rng
	local have_processors = #active_processors > 0

	local min_y = mathmax (py, effective_level_min)
	local max_y = mathmin (py + sy - 1, level_max_y)
	for y = min_y, max_y do
		local yprob = yprob[y - min_y + 1].prob
		if yprob == MTSCHEM_PROB_ALWAYS
			or yprob >= 1 + rng:next_within (0xff) then
			y_generate[y] = true
		else
			y_generate[y] = false
		end
	end

	for x, y, z in ipos1 (mathmax (px, origin_x),
			      min_y,
			      mathmax (pz, origin_z),
			      mathmin (px + sx - 1, origin_x + 15),
			      max_y,
			      mathmin (pz + sz - 1, origin_z + 15)) do
		if y_generate[y] then
			local schem_z = sz - (z - pz + 1)
			local schem_x = x - px
			local schem_y = y - py
			local schem_idx = schem_z * i_step_z
				+ schem_y * ystride
				+ schem_x * i_step_x
				+ i_start + 1
			local data = schemdata[schem_idx]
			if not data then
				core.log ("warning", "Placing invalid schematic...  idx="
					  .. schem_idx .. " (" .. #schemdata .. ")"
					  .. " rot=" .. rot)
				return
			end
			local cid, param2, probability, force_place_node
				= decode_schem_data (data)
			if probability ~= MTSCHEM_PROB_NEVER then
				if have_processors then
					cid, param2
						= apply_schematic_processors (x, y, z, rng, cid, param2)
				end

				local idx = block_index (x, y, z)
				local current = band (nodes[idx], ENCODED_NODE_MASK)
				if cid and (force_place or force_place_node
					    or current == cid_air_encoded
					    or current == cid_ignore_encoded) then
					local continue = probability == MTSCHEM_PROB_ALWAYS
						or probability > 1 + rng:next_within (0x80)
					if continue then
						if rot ~= "0" then
							param2 = rotate_param2 (cid, param2, rot)
						end
						nodes[idx] = structure_encode_node (cid, param2)
						local hash = hash_schem_pos (x, z)
						local val = xz_updates[hash] or -huge
						xz_updates[hash] = mathmax (val, y)
						update_structure_extents (x, y, z)
					end
				end
			end
		end
	end

	-- Fix heightmaps.
	for key, y in pairs (xz_updates) do
		local x = rshift (key, 16) - 32768
		local z = band (key, 65535) - 32768
		local idx = heightmap_index (x, z)
		local surface, motion_blocking
			= unpack_height_map (heightmap[idx])

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
local get_schematic_size = mcl_levelgen.get_schematic_size

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
			error ("Invalid rotation provided to `place_schematic': "
			       .. tostring (rotation))
		end
	end

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
	return {
		x, y, z,
		x + size.x - 1, y + size.y - 1, z + size.z - 1,
	}
end

------------------------------------------------------------------------
-- Schematic structure piece.
------------------------------------------------------------------------

local place_schematic = mcl_levelgen.place_schematic
local push_schematic_processors = mcl_levelgen.push_schematic_processors
local pop_schematic_processors = mcl_levelgen.pop_schematic_processors
local NO_FLAGS = {}

local function place_schematic_structure_piece (self, level, terrain, rng,
						x1, z1, x2, z2)
	local bbox = self.bbox
	local x, y, z = bbox[1], bbox[2], bbox[3]
	local processors = self.processors
	local sentinel = self.placement_sentinel
	if processors then
		local i = push_schematic_processors (processors)
		place_schematic (x, y, z, self.schematic, self.rotation,
				 self.force_place, NO_FLAGS, rng)
		pop_schematic_processors (i)
	else
		place_schematic (x, y, z, self.schematic, self.rotation,
				 self.force_place, NO_FLAGS, rng)
	end
	if sentinel then
		sentinel (self, rng, x1, z1, x2, z2)
	end
end

local function run_preprocessors (rng, processors, template_or_sid)
	local tbl = {}

	if processors then
		for _, processor in ipairs (processors) do
			if type (processor) == "table"
				and processor.structure_preprocess then
				local key, value
					= processor.structure_preprocess (rng, template_or_sid)
				tbl[key] = value
			end
		end
	end

	return tbl
end

function mcl_levelgen.get_preprocessor_metadata (key)
	local piece = current_structure_piece
	return piece.processor_data[key]
end

function mcl_levelgen.make_schematic_piece (schematic_id, x, y, z,
					    rotation, rng, center,
					    force_place, processors,
					    placement_sentinel,
					    ground_offset)
	if rotation == "random" then
		local x = 1 + rng:next_within (4)
		rotation = rotations[x]
	end
	local sx, sy, sz = get_schematic_size (schematic_id, rotation)
	if center then
		x = x - rtz ((sx - 1) / 2)
		z = z - rtz ((sz - 1) / 2)
	end
	return {
		rotation = rotation,
		place = place_schematic_structure_piece,
		schematic = schematic_id,
		force_place = force_place,
		processors = processors,
		processor_data = run_preprocessors (rng, processors,
						    schematic_id),
		placement_sentinel = placement_sentinel,
		bbox = {
			x, y, z,
			x + sx - 1,
			y + sy - 1,
			z + sz - 1,
		},
		ground_offset = ground_offset,
	}
end

------------------------------------------------------------------------
-- Template placement.
------------------------------------------------------------------------

local get_template_bounding_box
local place_template_internal
local run_template_constructors
local generate_jigsaw
local bounds = {}

local function set_block_with_meta (x, y, z, cid, param2, meta)
	set_block (x, y, z, cid, param2)
	if meta then
		notify_generated ("mcl_levelgen:set_block_meta", x, y, z, {
			x, y, z, meta,
		}, true)
	end
end

local function construct_block (x, y, z)
	notify_generated ("mcl_levelgen:construct_block", x, y, z, {
		x, y, z,
	}, true)
end
mcl_levelgen.construct_block = construct_block

function mcl_levelgen.place_template (template, x, y, z, px, pz, options,
				      mirroring, rotation, rng)
	bounds[1] = origin_x
	bounds[2] = effective_level_min
	bounds[3] = origin_z
	bounds[4] = origin_x + 15
	bounds[5] = level_max_y
	bounds[6] = origin_z + 15
	local suppressions
		= place_template_internal (template, x, y, z, px, pz, options,
					   bounds, mirroring, rotation,
					   active_processors, rng,
					   set_block_with_meta, get_block_1)
	run_template_constructors (template, x, y, z, px, pz, mirroring,
				   rotation, construct_block, suppressions)
end
local place_template = mcl_levelgen.place_template

local function place_template_structure_piece (self, level, terrain, rng,
					       x1, z1, x2, z2)
	local x, y, z, px, pz = self.x, self.y, self.z, self.px, self.pz
	local processors = self.processors
	if processors then
		local i = push_schematic_processors (processors)
		place_template (self.template, x, y, z, px, pz,
				self.options, self.mirroring,
				self.rotation, rng)
		pop_schematic_processors (i)
	else
		place_template (self.template, x, y, z, px, pz,
				self.options, self.mirroring,
				self.rotation, rng)
	end
end

function mcl_levelgen.make_template_piece_with_pivot (template, x, y, z, px, pz,
						      mirroring, rotation, rng,
						      options, processors,
						      ground_offset)
	local x1, y1, z1, x2, y2, z2
		= get_template_bounding_box (template, x, y, z, px, pz,
					     mirroring, rotation)
	local bbox = {
		x1, y1, z1,
		x2, y2, z2,
	}
	return {
		template = template,
		rotation = rotation,
		mirroring = mirroring,
		place = place_template_structure_piece,
		ground_offset = ground_offset,
		options = options,
		processors = processors,
		processor_data = run_preprocessors (rng, processors,
						    template),
		x = x,
		y = y,
		z = z,
		px = px,
		pz = pz,
		bbox = bbox,
	}
end

function mcl_levelgen.make_template_piece (template, x, y, z,
					   mirroring, rotation, rng,
					   options, processors,
					   ground_offset, bbox)
	if not bbox then
		local x1, y1, z1, x2, y2, z2
			= get_template_bounding_box (template, x, y, z, 0, 0,
						     mirroring, rotation)
		bbox = {
			x1, y1, z1,
			x2, y2, z2,
		}
	end
	return {
		template = template,
		rotation = rotation,
		mirroring = mirroring,
		place = place_template_structure_piece,
		ground_offset = ground_offset,
		options = options,
		processors = processors,
		processor_data = run_preprocessors (rng, processors,
						    template),
		x = x,
		y = y,
		z = z,
		px = 0,
		pz = 0,
		bbox = bbox,
	}
end
local make_template_piece = mcl_levelgen.make_template_piece

function mcl_levelgen.init_structures_after_templates ()
	get_template_bounding_box = mcl_levelgen.get_template_bounding_box
	place_template_internal = mcl_levelgen.place_template_internal
	run_template_constructors = mcl_levelgen.run_template_constructors
	generate_jigsaw = mcl_levelgen.generate_jigsaw
end

------------------------------------------------------------------------
-- Jigsaw structure generation.
------------------------------------------------------------------------

local structure_biome_test = mcl_levelgen.structure_biome_test

local function jigsaw_create_piece (element, rotation, rng, sx, sy, sz, bbox)
	local piece = make_template_piece (element.template, sx, sy, sz,
					   nil, rotation, rng, nil,
					   element.processors,
					   element.ground_level_delta, bbox)
	piece.element = element
	piece.no_terrain_adaptation = element.no_terrain_adaptation
	return piece
end

-- local jigsaw_structure = {
-- 	max_distance_from_center = ...,
-- 	project_start_to_heightmap = "world_surface_wg" or "motion_blocking_wg",
-- 	size = ...,
-- 	start_height = function (rng) ... end,
-- 	start_jigsaw_name = "name" or nil,
-- }

local function project_start_to_world_surface_wg (x, z, level, terrain)
	local height = terrain:get_one_height (x, z, is_not_air)
	return height
end

local function project_start_to_motion_blocking_wg (x, z, level, terrain, _)
	local height = terrain:get_one_height (x, z)
	return height
end

local function jigsaw_test_generation_position (x, y, z, sx, sy, sz, level,
						_, structure)
	if not structure.test_start_position then
		return structure_biome_test (level, structure, x, y, z)
	else
		return structure_biome_test (level, structure, sx, sy, sz)
	end
end

function mcl_levelgen.jigsaw_create_start (self, level, terrain, rng, cx, cz)
	local sx = cx * 16
	local sz = cz * 16
	local sy = self.start_height (rng)
	local project_start = nil
	local projection = self.project_start_to_heightmap
	if projection == "world_surface_wg" then
		project_start = project_start_to_world_surface_wg
	elseif projection == "motion_blocking_wg" then
		project_start = project_start_to_motion_blocking_wg
	else
		assert (not projection)
	end
	local pieces = generate_jigsaw (rng, sx, sy, sz, nil, self.start_pool,
					self.start_jigsaw_name,
					self.max_distance_from_center,
					self.size, jigsaw_create_piece,
					jigsaw_test_generation_position,
					project_start, level, terrain, self,
					level.preset.min_y, level.preset.height)
	return create_structure_start (self, pieces)
end

end

------------------------------------------------------------------------
-- External structure placement interface.
------------------------------------------------------------------------

local function compare_grid_size (a, b)
	return a.placement.spacing < b.placement.spacing
end

local positions_at_distance_chebyshev
	= mcl_levelgen.positions_at_distance_chebyshev

local bbox_center = mcl_levelgen.bbox_center
local candidates

local function insert_structure_candidate (start, _, _, _, ids)
	if indexof (ids, start.structure) ~= -1 then
		local x, y, z = bbox_center (start.bbox)
		insert (candidates, {x, y, z,})
	end
end

local sort_src_x
local sort_src_z

local function compare_distance_to_src (a, b)
	local dist_a, dist_b
	local x, z = sort_src_x, sort_src_z
	do
		local dx, dz = a[1] * 16 - x, a[2] * 16 - z
		local d = dx * dx + dz * dz
		dist_a = d
	end
	do
		local dx, dz = b[1] * 16 - x, b[2] * 16 - z
		local d = dx * dx + dz * dz
		dist_b = d
	end
	return dist_a < dist_b
end

function mcl_levelgen.locate_structure_placement (terrain, x, y, z, id_or_ids, grid_limit_xz)
	local level = terrain.structures

	-- First, attempt to locate structure sets containing any of
	-- ID_OR_IDS in the level.

	if type (id_or_ids) == "string" then
		id_or_ids = { id_or_ids, }
	end

	local target_sets = {}
	local target_stronghold_sets = {}
	for _, set in ipairs (level.structure_sets) do
		for _, structure in ipairs (set.structures) do
			if indexof (id_or_ids, structure.structure.name) ~= -1 then
				if set.placement.spacing
					and set.placement.locator_test then
					insert (target_sets, set)
				elseif level.stronghold_starts[set.placement.id] then
					insert (target_stronghold_sets, set)
				end
				break
			end
		end
	end
	if #target_sets == 0 and #target_stronghold_sets == 0 then
		return nil
	end

	local nearest, d_nearest = nil, huge
	local nearest_rgn_absolute = huge

	-- Initially consider structures with concentric ring placement.
	local cx = floor (x / 16)
	local cz = floor (z / 16)
	for _, set in ipairs (target_stronghold_sets) do
		local positions_by_distance = {}

		for hash, _ in pairs (level.stronghold_starts[set.placement.id]) do
			local cx, cz = struct_unhash (hash)
			insert (positions_by_distance, {cx, cz,})
		end

		sort_src_x = x
		sort_src_z = z
		table.sort (positions_by_distance, compare_distance_to_src)

		for _, pos in ipairs (positions_by_distance) do
			candidates = {}
			local just_this_set = {set,}
			local cx1, cz1 = pos[1], pos[2]

			if not nearest
				or mathmax (mathabs (cx1 - floor (nearest[1] / 16)),
					    mathabs (cz1 - floor (nearest[3] / 16))) < 16 then
				get_structure_starts (level, terrain, cx1, cz1,
						      insert_structure_candidate,
						      id_or_ids, just_this_set)
				for _, candidate in ipairs (candidates) do
					local dx = mathabs (candidate[1] - x)
					local dy = mathabs (candidate[2] - y)
					local dz = mathabs (candidate[3] - z)
					local d_sqr = dx * dx + dy * dy + dz * dz
					if d_sqr < d_nearest then
						d_nearest = d_sqr
						nearest = candidate
						nearest_rgn_absolute
							= mathmin (nearest_rgn_absolute,
								   mathmax (mathabs (cx - cx1),
									    mathabs (cz - cz1)))
					end
				end
				candidates = nil
			end
		end
	end

	-- Sort TARGET_SETS by grid size.
	table.sort (target_sets, compare_grid_size)

	for _, set in ipairs (target_sets) do
		local placement = set.placement
		local spacing = placement.spacing
		local region_x = floor (cx / placement.spacing)
		local region_z = floor (cz / placement.spacing)

		for i = 0, grid_limit_xz do
			if i * spacing > (nearest_rgn_absolute + 8) then
				break
			end
			local just_this_set = {set,}
			candidates = {}
			for dx, dz in positions_at_distance_chebyshev (i) do
				local rx = region_x + dx
				local rz = region_z + dz
				local scx, scz = placement.locator_test (level, placement.salt, rx, rz)

				if scx and scz then
					-- This will conduct detailed placement tests.
					get_structure_starts (level, terrain, scx, scz,
							      insert_structure_candidate,
							      id_or_ids, just_this_set)
				end
			end
			for _, candidate in ipairs (candidates) do
				local dx = mathabs (candidate[1] - x)
				local dy = mathabs (candidate[2] - y)
				local dz = mathabs (candidate[3] - z)
				local d_sqr = dx * dx + dy * dy + dz * dz
				if d_sqr < d_nearest then
					d_nearest = d_sqr
					nearest = candidate
					nearest_rgn_absolute
						= mathmin (nearest_rgn_absolute, i * spacing)
				end
			end
			candidates = nil
		end
	end
	if nearest then
		return nearest[1], nearest[2], nearest[3]
	end
	return nil
end

local function insert_structure_start (start, _, _, _, _)
	insert (candidates, start)
end

function mcl_levelgen.fix_structure_pieces (terrain, x, y, z, sets, grid_limit_xz)
	local pieces = {}
	local target_sets = {}
	local level = terrain.structures

	local cx = floor (x / 16)
	local cz = floor (z / 16)

	for _, set in ipairs (sets) do
		local def = registered_structure_sets[set]
		if def and indexof (level.structure_sets, def) ~= -1 then
			insert (target_sets, def)
		end
	end

	for _, set in ipairs (target_sets) do
		local placement = set.placement
		local region_x = floor (cx / placement.spacing)
		local region_z = floor (cz / placement.spacing)

		if placement.locator_test then
			for i = 0, grid_limit_xz do
				local just_this_set = {set,}
				candidates = {}
				for dx, dz in positions_at_distance_chebyshev (i) do
					local rx = region_x + dx
					local rz = region_z + dz
					local scx, scz = placement.locator_test (level, placement.salt, rx, rz)

					if scx and scz then
						-- This will conduct detailed placement tests.
						get_structure_starts (level, terrain, scx, scz,
								      insert_structure_start,
								      nil, just_this_set)
					end
				end
				for _, candidate in ipairs (candidates) do
					for _, piece in ipairs (candidate.pieces) do
						insert (pieces, {
							sid = candidate.structure,
							bbox = piece.bbox,
						})
					end
				end
			end
		end
	end

	return pieces
end
