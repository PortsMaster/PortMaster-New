-- local prin
------------------------------------------------------------------------
-- Carver processing.
------------------------------------------------------------------------

local encode_node = mcl_levelgen.encode_node
local decode_node = mcl_levelgen.decode_node

local cid_grass_block, cid_mycelium, cid_dirt, cid_air, cid_lava, cid_nether_lava

local function init_cids ()
	cid_grass_block = core.get_content_id ("mcl_core:dirt_with_grass")
	cid_mycelium = core.get_content_id ("mcl_core:mycelium")
	cid_dirt = core.get_content_id ("mcl_core:dirt")
	cid_lava = core.get_content_id ("mcl_core:lava_source")
	cid_nether_lava = core.get_content_id ("mcl_nether:nether_lava_source")
end

if core then
	if core and core.get_mod_storage then
		core.register_on_mods_loaded (init_cids)
	else
		init_cids ()
	end
	cid_air = core.CONTENT_AIR
else
	cid_grass_block = 10
	cid_mycelium = 11
	cid_dirt = 12
	cid_lava = 3
	cid_nether_lava = 3
	cid_air = 0
end

local carver = {
	probability = 0.0,
	y = function (rng)
		return 0
	end,
	y_scale = function (rng)
		return 0
	end,
	lava_level = 0,
	cid_lava = cid_lava,
	replaceable = {},
	surface_system = nil,
	aquifer = nil,
	range = 4,
}

local chunksize = nil
local nodes = nil
local chunk_x = 0
local chunk_z = 0
local index = nil
local level_min = 0
local level_height = 0
local effective_level_min = 0
local effective_level_height = 0
local surface_system = nil
local aquifer = nil

local function carver_prepare (cx, cz, aquifer_in, surface_system_in,
			       chunksize_in, index_in, biomes, nodes_in,
			       heightmap, level_min_in, level_height_in,
			       effective_level_min_in,
			       effective_level_height_in,
			       terrain)
	chunk_x = cx
	chunk_z = cz
	chunksize = chunksize_in
	index = index_in
	nodes = nodes_in
	level_min = level_min_in
	level_height = level_height_in
	effective_level_min = effective_level_min_in
	effective_level_height = effective_level_height_in
	surface_system = surface_system_in
	aquifer = aquifer_in

	surface_system:initialize_for_carver (biomes, heightmap, cx, cz,
					      chunksize_in, terrain)
end

function carver:carve (x, z, rng)
	error ("Unimplemented: carve")
end

function carver:is_origin_chunk (rng)
	return rng:next_float () <= self.probability
end

local function get_block (self, x, y, z)
	if y <= self.lava_level then
		return encode_node (self.cid_lava, 0)
	end

	local default = aquifer.cid_default_block
	local cid, param2 = aquifer:get_node (x, y, z, 0.0)
	if cid == default then
		return nil -- Don't carve.
	else
		return encode_node (cid, param2)
	end
end

-- Replace the block at X, Y, Z with the appropriate fluid or air
-- block for its position.  If the block currently present at this
-- position is grass or mycelium and its removal exposes dirt, apply
-- surface rules to the exposed dirt block.  Return whether any dirt
-- was exposed.

local function carve_block (self, x, y, z, dx, dy, dz, dirt_exposed_p)
	local idx = index (dx, dy, dz, chunksize, level_height)
	local cid, _ = decode_node (nodes[idx])
	if (cid == cid_grass_block or cid == cid_mycelium) and dy > 0 then
		dirt_exposed_p = true
	end

	if not self.replaceable[cid] then
		return dirt_exposed_p
	end

	local value = get_block (self, x, y, z)
	if value then
		if dy > 0 and dirt_exposed_p then
			local idx = idx - chunksize
			cid, _ = decode_node (nodes[idx])
			if cid == cid_dirt then
				local system = surface_system
				local submerged	= decode_node (value) ~= cid_air
				local value = system:evaluate_for_carver (x, y - 1, z,
									  submerged)
				if value then
					nodes[idx] = value
				end
			end
		end

		nodes[idx] = value
		return dirt_exposed_p
	end
	return dirt_exposed_p
end

local mathmax = math.max
local mathmin = math.min
local floor = math.floor

local function carve (self, x, y, z, width, height, bypass_p)
	-- Test whether a rectangle of (16 + WIDTH * 2.0) * 2 x (16 +
	-- WIDTH * 2.0) * 2 around X, Y, Z, intersects with this
	-- MapChunk.

	do
		local radius = 16 + width * 2.0
		if not ((x - radius) <= (chunk_x + chunksize)
			and chunk_x <= (x + radius)
			and (z - radius) <= (chunk_z + chunksize)
			and chunk_z <= (z + radius)) then
			-- No intersection.
			return false
		end
	end

	local chunk_min_x
		= mathmax (floor (x - width) - chunk_x - 1, 0)
	local chunk_max_x
		= mathmin (floor (x + width) - chunk_x, chunksize - 1)
	local chunk_min_z
		= mathmax (floor (z - width) - chunk_z - 1, 0)
	local chunk_max_z
		= mathmin (floor (z + width) - chunk_z, chunksize - 1)
	local chunk_min_y
		= mathmax (floor (y - height) - 1 - effective_level_min,
			   -- Do not permit carvers to overwrite the
			   -- bottommost two layers of the level.
			   level_min - effective_level_min + 1, -1)
	local chunk_max_y
		= mathmin (floor (y + height) + 1 - effective_level_min,
			   effective_level_height - 1)

	for x1 = chunk_min_x, chunk_max_x do
		local absx = x1 + chunk_x
		local distx = (absx + 0.5 - x) / width
		for z1 = chunk_min_z, chunk_max_z do
			local absz = z1 + chunk_z
			local distz = (absz + 0.5 - z) / width
			if distx * distx + distz * distz < 1.0 then
				local dirt_exposed
				for y1 = chunk_max_y, chunk_min_y + 1, -1 do
					local absy = y1 + effective_level_min
					local disty = (absy - 0.5 - y) / height
					if not bypass_p (distx, disty, distz, absy) then
						dirt_exposed
							= carve_block (self, absx, absy, absz,
								       x1, y1, z1, dirt_exposed)
					end
				end
			end
		end
	end
end

-- Return whether no more intersections remain between X, Y, Z, and
-- that MapChunk which is defined by the previous call to
-- `carver_prepare', allowing for a margin of EXTRA_DISTANCE.

local function range_distance (r1, r2, value)
	local dmax = value - r2
	local dmin = r1 - value
	return dmax >= 0 and dmax or mathmax (dmin, 0)
end

local function no_longer_reachable (x, y, z, extra_distance, thickness)
	local cx1 = chunk_x + 8
	local cz1 = chunk_z + 8
	local cx2 = chunk_x + chunksize - 8
	local cz2 = chunk_z + chunksize - 8
	local dx = 0 or range_distance (cx1, cx2, x)
	local dz = 0 or range_distance (cz1, cz2, z)
	local radius = thickness + 2.0 + 16.0
	local dextra = extra_distance * extra_distance
	return dx * dx + dz * dz - dextra > radius * radius
end

------------------------------------------------------------------------
-- Cave carvers.
------------------------------------------------------------------------

local cave_carver = table.merge (carver, {
	horizontal_radius_multiplier = function (rng)
		return 1
	end,
	vertical_radius_multiplier = function (rng)
		return 1
	end,
	floor_level = function (rng)
		return 1
	end,
	max_caves = 15,
	cave_y_scale = 1.0,
})

local floor_level = 0

local function cave_bypass_p (dx, dy, dz, absy)
	return dy <= floor_level or dx * dx + dy * dy + dz * dz >= 1.0
end

local function create_room (self, x, y, z, room_size, room_height_scale)
	local width = 1.5 + room_size
	local height = width * room_height_scale
	carve (self, x, y, z, width, height, cave_bypass_p)
end

local placeholder = mcl_levelgen.ull (0, 0)
local tunnel_rng = mcl_levelgen.jvm_random (placeholder)
local tunnel_rng_nested = mcl_levelgen.jvm_random (placeholder)
local mathsin = math.sin
local mathcos = math.cos

local function copyull (ull)
	return { ull[1], ull[2], }
end

local pi = math.pi

local function create_tunnel (self, x, y, z, seed, horiz_radius, vert_radius,
			      thickness, yaw, pitch, first_seg, length, y_scale,
			      rng)
	rng:reseed (seed)
	local branch_point = rng:next_within (floor (length / 2))
		+ floor (length / 4)
	local steep = rng:next_within (6) == 0
	local yaw_variance = 0.0
	local pitch_variance = 0.0
	local pitch_arrest = steep and 0.92 or 0.7

	for i = first_seg, length do
		local w = 1.5 + mathsin (pi * ((i - 1) / length)) * thickness
		local h = w * y_scale
		local dh = mathcos (pitch)
		x = x + mathcos (yaw) * dh
		z = z + mathsin (yaw) * dh
		y = y + mathsin (pitch)
		pitch = pitch * pitch_arrest + pitch_variance * 0.1
		yaw = yaw + yaw_variance * 0.1
		pitch_variance = pitch_variance * 0.9
		yaw_variance = yaw_variance * 0.75
		pitch_variance = pitch_variance
			+ ((rng:next_float () - rng:next_float ())
				* rng:next_float () * 2.0)
		yaw_variance = yaw_variance
			+ ((rng:next_float () - rng:next_float ())
				* rng:next_float () * 4.0)

		if i - 1 == branch_point and thickness > 1.0 then
			local seed1 = copyull (rng:next_long ())

			-- Split into this tunnel into two.
			create_tunnel (self, x, y, z, seed1, horiz_radius,
				       vert_radius,
				       rng:next_float () * 0.5 + 0.5,
				       yaw - pi / 2, pitch / 3.0,
				       i, length, 1.0, tunnel_rng_nested)

			local seed2 = copyull (rng:next_long ())

			create_tunnel (self, x, y, z, seed2, horiz_radius,
				       vert_radius,
				       rng:next_float () * 0.5 + 0.5,
				       yaw + pi / 2, pitch / 3.0,
				       i, length, 1.0, tunnel_rng_nested)
			return
		end

		if rng:next_within (4) ~= 0 then
			-- Return once the ellipsoid no longer
			-- influences any portion of the MapChunk.
			if no_longer_reachable (x, y, z, length - i + 1,
						thickness) then
				return
			end
			carve (self, x, y, z, w * horiz_radius, h * vert_radius,
			       cave_bypass_p)
		end
	end
end

function cave_carver:get_thickness (rng)
	local val = rng:next_float () * 2.0 + rng:next_float ()
	if rng:next_within (10) == 0 then
		val = val * (rng:next_float () * rng:next_float () * 3.0 + 1.0)
	end
	return val
end

-- Carve a cave at the chunk X, Z within the MapChunk defined by a
-- previous call to `carver_prepare'.

function cave_carver:carve (x, z, rng)
	local range_in_blocks = 16 * (self.range * 2 - 1)
	local max1 = rng:next_within (self.max_caves) + 1
	local max2 = rng:next_within (max1) + 1
	local cnt_segments = rng:next_within (max2)
	local y_sampler = self.y
	local horiz_sampler = self.horizontal_radius_multiplier
	local vert_sampler = self.vertical_radius_multiplier
	local floor_sampler = self.floor_level

	for i = 1, cnt_segments do
		local center_x = x + rng:next_within (16)
		local center_y = y_sampler (rng)
		local center_z = z + rng:next_within (16)
		local horiz_radius = horiz_sampler (rng)
		local vert_radius = vert_sampler (rng)
		floor_level = floor_sampler (rng)
		local cnt_tunnels = 1
		if rng:next_within (4) == 0 then
			local room_scale = self.y_scale (rng)
			local room_size = 1.0 + rng:next_float () * 6.0
			create_room (self, center_x, center_y, center_z,
				     room_size, room_scale)
			cnt_tunnels = cnt_tunnels + rng:next_within (4)
		end

		for j = 1, cnt_tunnels do
			local yaw = rng:next_float () * pi * 2
			local pitch = (rng:next_float () - 0.5) / 4.0
			local thickness = self:get_thickness (rng)
			local length = range_in_blocks
				- rng:next_within (floor (range_in_blocks / 4))
			local seed = rng:next_long ()

			create_tunnel (self, center_x, center_y, center_z,
				       seed, horiz_radius, vert_radius, thickness,
				       yaw, pitch, 1, length, self.cave_y_scale,
				       tunnel_rng)
		end
	end
end

------------------------------------------------------------------------
-- Nether cave carver.
------------------------------------------------------------------------

local nether_cave_carver = table.merge (cave_carver, {
	max_caves = 10,
	cave_y_scale = 5.0,
	cid_lava = cid_nether_lava,
})

function nether_cave_carver:get_thickness (rng)
	return (rng:next_float () * 2.0 + rng:next_float ()) * 2.0
end

------------------------------------------------------------------------
-- Ravine carver.
------------------------------------------------------------------------

local EPSILON = math.pow (2, -52)
local EPSILON_INVERSE = math.pow (2, 52)
local FLOAT_EPSILON = math.pow (2, -23)
local FLOAT_MIN = math.pow (2, -126)
local FLOAT_MAX = math.pow (2, 128) - math.pow (2, 104)
local mathabs = math.abs
local huge = math.huge
local ceil = math.ceil

local emulate_single_precision = false
local roundf32

if emulate_single_precision then

local function round_to_even (x)
	return x + EPSILON_INVERSE - EPSILON_INVERSE
end

local function signbit (x)
	return (x == -0.0 or x <= 0) and -1
		or (x == 0.0) and 0 or 1
end

function roundf32 (x)
	local abs, sign = mathabs (x), signbit (x)

	if abs < FLOAT_MIN then
		return sign * round_to_even (abs / FLOAT_MIN / FLOAT_EPSILON)
			* FLOAT_MIN * FLOAT_EPSILON
	else
		local i = (1 + FLOAT_EPSILON / EPSILON) * abs
		local result = i - (i - abs)
		if result > FLOAT_MAX or result ~= result then
			return huge
		end

		return sign * result
	end
end

else

function roundf32 (x)
	return x
end

end

local quantized_sin = {}

for i = 0, 65535 do
	quantized_sin[i + 1] = mathsin (i * pi * 2.0 / 65536.0)
end

local function rtz (n)
	if n < 0 then
		return ceil (n)
	end
	return floor (n)
end

local band = bit.band

local function qsin (x)
	local val = rtz (x * 10430.378) -- 2pi / 65536.0f
	return quantized_sin[band (val, 65535) + 1]
end

local function qcos (x)
	local val = rtz (x * 10430.378 + 16384.0)
	return quantized_sin[band (val, 65535) + 1]
end

local ravine_carver = table.merge (carver, {
	vertical_rotation = function (rng)
		return 0.0
	end,
	distance_factor = function (rng)
		return 1.0
	end,
	thickness = function (rng)
		return 1.0
	end,
	width_smoothness = 0,
	horizontal_radius_factor = function (rng)
		return 1.0
	end,
	vertical_radius_default_factor = 1.0,
	vertical_radius_center_factor = 1.0,
})

local squeezevec = {
	[0] = math.huge,
}

local function get_vertical_radius (self, rng, initial_y_radius, length, i)
	local center = 1.0 - mathabs (0.5 - roundf32 (i / length)) * 2.0
	local factor = self.vertical_radius_default_factor
		+ self.vertical_radius_center_factor * center
	return roundf32 (factor * initial_y_radius
			 * roundf32 (rng:next_float () * 0.25 + 0.75))
end

local function ravine_bypass_p (dx, dy, dz, absy)
	local y = absy - level_min
	return (dx * dx + dz * dz) * squeezevec[y] + (dy * dy) / 6.0 >= 1.0
end

local function carve_ravine (self, seed, x, y, z, thickness, yaw, pitch, length, y_scale)
	local rng = tunnel_rng
	rng:reseed (seed)

	local squeeze = 1.0
	local smooth = self.width_smoothness
	for i = 1, level_height do
		if i == 1 or rng:next_within (smooth) == 0 then
			squeeze = roundf32 (1.0 + rng:next_float ()
					    * rng:next_float ())
		end
		squeezevec[i] = roundf32 (squeeze * squeeze)
	end

	local pitch_variability = 0.0
	local yaw_variability = 0.0
	local horiz_sampler = self.horizontal_radius_factor
	for i = 1, length do
		local radius = 1.5 + roundf32 (qsin ((i - 1) * pi / length)
					       * thickness)
		local val = horiz_sampler (rng)
		local x_radius = roundf32 (radius * val)
		local y_radius = get_vertical_radius (self, rng, radius * y_scale,
						      length, i - 1)
		local pxz = qcos (pitch)
		y = y + qsin (pitch)
		x = x + roundf32 (qcos (yaw) * pxz)
		z = z + roundf32 (qsin (yaw) * pxz)
		pitch = roundf32 (pitch * 0.7 + pitch_variability * 0.05)
		yaw = roundf32 (yaw + yaw_variability * 0.05)
		pitch_variability = roundf32 (pitch_variability * 0.8)
		yaw_variability = roundf32 (yaw_variability * 0.5)
		pitch_variability = pitch_variability
			+ roundf32 (((rng:next_float () - rng:next_float ())
					* rng:next_float () * 2.0))
		yaw_variability = yaw_variability
			+ roundf32 (((rng:next_float () - rng:next_float ())
					* rng:next_float () * 4.0))
		if rng:next_within (4) ~= 0 then
			if no_longer_reachable (x, y, z, length - i + 1, thickness) then
				return
			end
			carve (self, x, y, z, x_radius, y_radius,
			       ravine_bypass_p)
		end
	end
end

function ravine_carver:carve (x, z, rng)
	local range_in_blocks = 16 * (self.range * 2 - 1)
	local x = x + rng:next_within (16)
	local y = self.y (rng)
	local z = z + rng:next_within (16)
	local yaw = rng:next_float () * pi * 2
	local pitch = self.vertical_rotation (rng)
	local y_scale = self.y_scale (rng)
	local thickness = self.thickness (rng)
	local dist = floor (range_in_blocks
			    * roundf32 (self.distance_factor (rng)))
	local seed = rng:next_long ()
	carve_ravine (self, seed, x, y, z, roundf32 (thickness),
		      roundf32 (yaw), roundf32 (pitch), dist,
		      roundf32 (y_scale))
end

------------------------------------------------------------------------
-- Carver registration.
------------------------------------------------------------------------

local carvers_initialized = false
local registered_carvers = {}
mcl_levelgen.registered_carvers = registered_carvers

local function setcids (replaceable_cids, name)
	if not core then
		replaceable_cids[1] = true
		return
	end
	if name:sub (1, 6) == "group:" then
		local group = name:sub (7)
		for name, tbl in pairs (core.registered_nodes) do
			if tbl.groups[group] and tbl.groups[group] > 0 then
				local id = core.get_content_id (name)
				replaceable_cids[id] = true
			end
		end
	else
		local id = core.get_content_id (name)
		replaceable_cids[id] = true
	end
end

function mcl_levelgen.register_carver (name, carver)
	assert (carver.probability)
	assert (carver.replaceable)
	local copy = table.copy (carver)
	registered_carvers[name] = copy
end

function mcl_levelgen.load_carvers ()
	for name, biome in pairs (mcl_levelgen.registered_biomes) do
		local carvers = {}
		local biomecarvers = biome.carvers.air or {}
		for _, carver in ipairs (biomecarvers) do
			if not registered_carvers[carver] and mcl_levelgen.verbose then
				print ("Biome `" .. name
				       .. "' declares an undefined carver `"
				       .. carver .. "'")
				print (table.concat ({
					"This affects not only the generation of the missing carver,",
					"but also the randomization of the process of carver selection",
					"and the carvers themselves.  You stand admonished.",
				}, "\n"))
			else
				table.insert (carvers, registered_carvers[carver])
			end
		end
		biome.carvers = carvers
	end
	for _, carver in pairs (registered_carvers) do
		local replaceable_cids = {}
		for _, name in ipairs (carver.replaceable) do
			setcids (replaceable_cids, name)
		end
		carver.replaceable = replaceable_cids
	end
	carvers_initialized = true
end

------------------------------------------------------------------------
-- Carver definitions.
------------------------------------------------------------------------

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

local function trapezoidal_float (min, max, bound)
	local diff = max - min
	local bound_diff = (diff - bound) / 2.0
	local base_diff = diff - bound_diff
	return function (rng)
		return min + rng:next_float () * base_diff
			+ rng:next_float () * bound_diff
	end
end

local OVERWORLD_BOTTOM = -64

local default_cave_carver = table.merge (cave_carver, {
	probability = 0.15,
	y = uniform_height (OVERWORLD_BOTTOM + 8, 180),
	y_scale = uniform_float (0.1, 0.9),
	lava_level = OVERWORLD_BOTTOM + 8,
	replaceable = {
		"group:overworld_carvable",
		"group:dirt",
		"group:sand",
		"group:hardened_clay",
		"group:snow_layer",
		"mcl_core:stone_with_iron",
		"mcl_deepslate:deepslate_with_iron",
		"mcl_copper:stone_with_copper",
		"mcl_deepslate:deepslate_with_copper",
		"mcl_core:water_source",
		"mcl_core:gravel",
		"mcl_sus_nodes:gravel",
		"mcl_core:sandstone",
		"mcl_core:redsandstone",
		"mcl_amethyst:calcite",
		"mcl_core:packed_ice",
		"mcl_raw_ores:raw_iron_block",
		"mcl_copper:block_raw",
	},
	horizontal_radius_multiplier = uniform_float (0.7, 1.4),
	vertical_radius_multiplier = uniform_float (0.8, 1.3),
	floor_level = uniform_float (-1.0, -0.4),
})

local cave_extra_underground_carver = table.merge (cave_carver, {
	probability = 0.07,
	y = uniform_height (OVERWORLD_BOTTOM + 8, 47),
	y_scale = uniform_float (0.1, 0.9),
	lava_level = OVERWORLD_BOTTOM + 8,
	replaceable = {
		"group:overworld_carvable",
		"group:dirt",
		"group:sand",
		"group:hardened_clay",
		"group:snow_layer",
		"mcl_core:stone_with_iron",
		"mcl_deepslate:deepslate_with_iron",
		"mcl_copper:stone_with_copper",
		"mcl_deepslate:deepslate_with_copper",
		"mcl_core:water_source",
		"mcl_core:gravel",
		"mcl_sus_nodes:gravel",
		"mcl_core:sandstone",
		"mcl_core:redsandstone",
		"mcl_amethyst:calcite",
		"mcl_core:packed_ice",
		"mcl_raw_ores:raw_iron_block",
		"mcl_copper:block_raw",
	},
	horizontal_radius_multiplier = uniform_float (0.7, 1.4),
	vertical_radius_multiplier = uniform_float (0.8, 1.3),
	floor_level = uniform_float (-1.0, -0.4),
})

local default_ravine_carver = table.merge (ravine_carver, {
	probability = 0.01,
	y = uniform_height (10, 67),
	y_scale = function ()
		return 3.0
	end,
	lava_level = OVERWORLD_BOTTOM + 8,
	replaceable = {
		"group:overworld_carvable",
		"group:dirt",
		"group:sand",
		"group:hardened_clay",
		"group:snow_layer",
		"mcl_core:stone_with_iron",
		"mcl_deepslate:deepslate_with_iron",
		"mcl_copper:stone_with_copper",
		"mcl_deepslate:deepslate_with_copper",
		"mcl_core:water_source",
		"mcl_core:gravel",
		"mcl_sus_nodes:gravel",
		"mcl_core:sandstone",
		"mcl_core:redsandstone",
		"mcl_amethyst:calcite",
		"mcl_core:packed_ice",
		"mcl_raw_ores:raw_iron_block",
		"mcl_copper:block_raw",
	},
	vertical_rotation = uniform_float (-0.125, 0.125),
	distance_factor = uniform_float (0.75, 1.0),
	thickness = trapezoidal_float (0.0, 6.0, 2.0),
	width_smoothness = 3,
	horizontal_radius_factor = uniform_float (0.75, 1.0),
	vertical_radius_default_factor = 1.0,
	vertical_radius_center_factor = 0.0,
})

local nether_cave_carver = table.merge (nether_cave_carver, {
	probability = 0.2,
	y = uniform_height (0, 126),
	y_scale = function (_) return 0.5 end,
	floor_level = function (_) return -0.7 end,
	lava_level = 10,
	replaceable = {
		"group:deepslate_ore_target",
		"group:stone_ore_target",
		"mcl_nether:netherrack",
		"mcl_blackstone:basalt",
		"mcl_blackstone:blackstone",
		"mcl_crimson:warped_nylium",
		"mcl_crimson:crimson_nylium",
		"mcl_nether:nether_wart_block",
		"mcl_crimson:warped_wart_block",
		"mcl_nether:soul_sand",
		"mcl_blackstone:soul_soil",
	},
	horizontal_radius_multiplier = function (_) return 1.0 end,
	vertical_radius_multiplier = function (_) return 1.0 end,
})

mcl_levelgen.register_carver ("mcl_levelgen:cave_carver", default_cave_carver)
mcl_levelgen.register_carver ("mcl_levelgen:cave_extra_underground_carver",
			      cave_extra_underground_carver)
mcl_levelgen.register_carver ("mcl_levelgen:ravine_carver", default_ravine_carver)
mcl_levelgen.register_carver ("mcl_levelgen:nether_cave_carver", nether_cave_carver)

------------------------------------------------------------------------
-- Carver generation.
------------------------------------------------------------------------

local registered_biomes = mcl_levelgen.registered_biomes
local carver_rng = mcl_levelgen.jvm_random (placeholder)
local set_carver_seed = mcl_levelgen.set_carver_seed
local addkull = mcl_levelgen.addkull

-- Callers must arrange that the aquifer and surface system be
-- configured for this MapChunk before invoking the carver subsystem.

function mcl_levelgen.carve_terrain (preset, nodes, biomes, heightmap, x, y, z,
				     chunksize, index, effective_level_min,
				     effective_level_height, terrain)
	if not carvers_initialized then
		return
	end

	-- Carvers are permitted to extend eight to nine chunks from
	-- their origins.

	local min_x = x - 128
	local max_x = x + chunksize + 128
	local min_z = z - 128
	local max_z = z + chunksize + 128
	local rng = carver_rng
	local seed = copyull (preset.seed)

	carver_prepare (x, z, terrain.aquifer, terrain.surface_system,
			chunksize, index, biomes, nodes, heightmap,
			preset.min_y, preset.height, effective_level_min,
			effective_level_height, terrain)

	for chunk_x = min_x, max_x, 16 do
		for chunk_z = min_z, max_z, 16 do
			-- Carver generation disregards biome
			-- coordinate munging.
			local biome = preset:index_biomes_block (chunk_x, 0, chunk_z)
			local biomedata = registered_biomes[biome]
			for i, carver in ipairs (biomedata.carvers) do
				set_carver_seed (rng, seed, chunk_x / 16, chunk_z / 16)
				addkull (seed, 1)

				if carver:is_origin_chunk (rng) then
					carver:carve (chunk_x, chunk_z, rng)
				end
			end
			seed[1] = preset.seed[1]
			seed[2] = preset.seed[2]
		end
	end
end
