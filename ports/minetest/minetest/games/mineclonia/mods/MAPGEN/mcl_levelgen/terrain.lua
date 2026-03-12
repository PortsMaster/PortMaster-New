------------------------------------------------------------------------
-- Terrain generation.
--
-- Each level generator should be instantiated from a preset as so
-- illustrated:
--
-- local preset = mcl_levelgen.make_overworld_preset (seed, <params>)
-- local state = mcl_levelgen.make_terrain_generator (preset, <chunksize * 16>)
--
-- A table of node content IDs indexed by node positions and another
-- of param2s in the engine's flat array format adequately sized for a
-- single MapChunk, and the block coordinates of its origin in
-- Minecraft's coordinate space (where the Z axis is inverted by
-- comparison with Luanti's), may subsequently be provided to
-- level_state:generate, and will be populated with values derived
-- from noise.
------------------------------------------------------------------------

local ipairs = ipairs
local toblock = mcl_levelgen.toblock
local toquart = mcl_levelgen.toquart

local terrain_generator = {
	is_ersatz = false,
}
mcl_levelgen.terrain_generator = terrain_generator

local cid_stone, cid_water_source, cid_lava_source, cid_nether_lava_source, cid_air
local cid_copper_ore, cid_deepslate_iron_ore, cid_raw_copper, cid_raw_iron
local cid_granite, cid_tuff

local function init_cids ()
	cid_stone = core.get_content_id ("mcl_core:stone")
	cid_water_source = core.get_content_id ("mcl_core:water_source")
	cid_lava_source = core.get_content_id ("mcl_core:lava_source")
	cid_nether_lava_source
		= core.get_content_id ("mcl_nether:nether_lava_source")
	cid_air = core.CONTENT_AIR
	cid_copper_ore = core.get_content_id ("mcl_copper:stone_with_copper")
	cid_deepslate_iron_ore = core.get_content_id ("mcl_deepslate:deepslate_with_iron")
	cid_raw_copper = core.get_content_id ("mcl_copper:block_raw")
	cid_raw_iron = core.get_content_id ("mcl_raw_ores:raw_iron_block")
	cid_granite = core.get_content_id ("mcl_core:granite")
	cid_tuff = core.get_content_id ("mcl_deepslate:tuff")
end

if core and core.get_content_id then
	if core.register_on_mods_loaded then
		core.register_on_mods_loaded (init_cids)
		core.register_on_mods_loaded (function ()
			mcl_levelgen.init_ore_veins ()
		end)
	else
		init_cids ()
	end
else
	cid_stone = 3
	cid_water_source = 1
	cid_lava_source = 4
	cid_air = 0
	cid_copper_ore = 91
	cid_deepslate_iron_ore = 92
	cid_raw_copper = 93
	cid_raw_iron = 94
	cid_granite = 95
	cid_tuff = 96
end

------------------------------------------------------------------------
-- Ore veins.
------------------------------------------------------------------------
local mathabs = math.abs
local mathmin = math.min
local mathmax = math.max

local ORE_VEIN_COPPER_MIN = mcl_levelgen.ORE_VEIN_COPPER_MIN
local ORE_VEIN_COPPER_MAX = mcl_levelgen.ORE_VEIN_COPPER_MAX
local ORE_VEIN_IRON_MIN = mcl_levelgen.ORE_VEIN_IRON_MIN
local ORE_VEIN_IRON_MAX = mcl_levelgen.ORE_VEIN_IRON_MAX
local ORE_VEIN_MIN_HEIGHT = mcl_levelgen.ORE_VEIN_MIN_HEIGHT
local ORE_VEIN_MAX_HEIGHT = mcl_levelgen.ORE_VEIN_MAX_HEIGHT

local COPPER_VEIN, IRON_VEIN

function mcl_levelgen.init_ore_veins ()
	COPPER_VEIN = {
		ORE_VEIN_COPPER_MIN,
		ORE_VEIN_COPPER_MAX,
		cid_copper_ore,
		cid_raw_copper,
		cid_granite,
	}

	IRON_VEIN = {
		ORE_VEIN_IRON_MIN,
		ORE_VEIN_IRON_MAX,
		cid_deepslate_iron_ore,
		cid_raw_iron,
		cid_tuff,
	}
end

mcl_levelgen.init_ore_veins ()

local function vein_select (selector)
	if selector > 0.0 then
		return COPPER_VEIN
	else
		return IRON_VEIN
	end
end

local function map_values (val, in_min, in_max, out_min, out_max)
	if val <= in_min then
		return out_min
	elseif val >= in_max then
		return out_max
	else
		local x = (val - in_min) / (in_max - in_min)
		return out_min + x * (out_max - out_min)
	end
end

-- veiny, nwithveins, ntotal = 0, 0, 0

local function vein_block_at_position (gen, x, y, z, cid_default_block)
	if y < ORE_VEIN_MIN_HEIGHT or y > ORE_VEIN_MAX_HEIGHT then
		return cid_default_block, 0
	end

	local selector = gen.vein_toggle (x, y, z, nil)
	local vein = vein_select (selector)
	if vein[2] - y >= 0 and y - vein[1] >= 0 then
		local mindist = mathmin (vein[2] - y, y - vein[1])
		-- Reduce the likelyhood of ore generation near the
		-- periphery of a vein.
		local fringe_penalty
			= map_values (mindist, 0.0, 20.0, -0.2, 0.0)
		if mathabs (selector) + fringe_penalty < 0.4 then
			return cid_default_block, 0
		else
			local rng = gen.ore_random
			rng:reseed_positional (x, y, z)

			-- if x == -45 and y == 15 and z == 186 then
			-- 	print (rng:next_float ())
			-- 	print (rng:next_float ())
			-- 	print (rng:next_float ())
			-- 	print (ore_density)
			-- 	print (map_values (ore_density, 0.4, 0.6, 0.1, 0.3))
			-- 	rng:reseed_positional (x, y, z)
			-- end

			if rng:next_float () > 0.7
				or gen.vein_ridged (x, y, z, nil) >= 0.0 then
				return cid_default_block, 0
			end

			local type_selector
				= map_values (mathabs (selector), 0.4, 0.6, 0.1, 0.3)
			if rng:next_float () < type_selector
				and gen.vein_gap (x, y, z, nil) > -0.3 then
				return (rng:next_float () < 0.02 and vein[4] or vein[3]), 0
			end
			return vein[5], 0
		end
	else
		return cid_default_block, 0
	end
end

------------------------------------------------------------------------
-- Caching density functions.
-- These functions replace their placeholder counterparts in density
-- functions when instantiated, and access the terrain generator's
-- state to perform caching, interpolation, and other analogous
-- transformations.
------------------------------------------------------------------------

local density_function = table.merge (mcl_levelgen.density_function, {
	saved_min_value = false,
	saved_max_value = false,
})
local make_density_function = mcl_levelgen.make_density_function

function density_function:min_value ()
	if self.saved_min_value then
		return self.saved_min_value
	end
	return self.input:min_value ()
end

function density_function:max_value ()
	if self.saved_max_value then
		return self.saved_max_value
	end
	return self.input:max_value ()
end

function density_function:petrify_internal (visited)
	local func = self.__call
	if not self.saved_min_value then
		self.saved_min_value = self.input:min_value ()
		self.saved_max_value = self.input:max_value ()
		self.input = self.input:petrify_and_clone (visited)
	end
	return function (x, y, z, blender)
		return func (self, x, y, z, blender)
	end
end

-- Interpolators.

local interpolator = table.merge (density_function, {
	-- Multidimensional array of noises along the Z and Y axes at
	-- the current X-axis row.
	noises_here = {},

	-- Multidimensional array of noises along the Z and Y axes at
	-- the next X-axis row.
	noises_next = {},

	-- Array holding:
	--   Cached values that correspond to the current and the next
	--   position along each axis.
	--
	--   Values produced by interpolating all pairs of values
	--   along the X and Z axes at the current and the next Y-axis
	--   column.
	--
	--   Values produced by interpolating all pairs of values
	--   along the Z axis at the current X-axis row and Y-axis
	--   column.
	--
	--   The final value of the trilinear process illustrated
	--   above; interpolation is conducted in the noise sampling
	--   loop.  If nil, return the value of `input'.
	data = {},

	-- Input function whose value to interpolate.
	input = nil,
})

function interpolator:create_noise_arrays (n_cells_y, n_cells_xz)
	local t1 = {}
	local t2 = {}

	self.noises_here = t1
	self.noises_next = t2

	for i = 1, n_cells_xz + 1 do
		local t3, t4 = {}, {}
		t1[i], t2[i] = t3, t4

		for j = 1, n_cells_xz + 1 do
			t3[j], t4[j] = 0.0, 0.0
		end
	end

	local tdata = {}
	for i = 1, 8 + 4 + 2 do
		tdata[i] = 0.0
	end
	tdata[15] = nil -- Value.
	self.data = tdata
end

-- Fill this interpolator's `noises_here' or `noises_there' array
-- (according as INITIAL is non-nil or not) with values from the
-- wrapped function originating at X, Z, and
-- each position from Y_BASE to Y_BASE + N_CELLS_Y (inclusive).
--
-- CELL_HEIGHT must be the width and length of each noise cell
-- (element in this array) and its height respectively.

function interpolator:fill_noise_slice (initial, x, z_base, zoff,
					y_base, n_cells_z,
					n_cells_y, cell_width,
					cell_height)
	local array = (initial and self.noises_here or self.noises_next)
	local dst = array[zoff + 1]
	local input = self.input
	local x = x * cell_width
	local z = (z_base + zoff) * cell_width
	local y = y_base * cell_height

	for i = 0, n_cells_y do
		local val = input (x, y + i * cell_height, z)
		dst[i + 1] = val
	end
end

-- Move values along each position in `noises_here' and `noises_y' at
-- Y and Z to the `xyzNNN' fields of this interpolator in preparation
-- for interpolating within cells in this region.  Y must be relative
-- to the Y_BASE which was supplied to `fill_noise_slice'

local function interpolator_cache_yz_values (self, y, z)
	local here, there = self.noises_here, self.noises_next
	local herez2 = here[z + 2]
	local herez1 = here[z + 1]
	local therez2 = there[z + 2]
	local therez1 = there[z + 1]
	local data = self.data

	local xyz000 = 1
	local xyz001 = 2
	local xyz010 = 3
	local xyz011 = 4
	local xyz100 = 5
	local xyz101 = 6
	local xyz110 = 7
	local xyz111 = 8

	data[xyz111] = therez2[y + 2]
	data[xyz110] = therez1[y + 2]
	data[xyz101] = therez2[y + 1]
	data[xyz100] = therez1[y + 1]
	data[xyz011] = herez2[y + 2]
	data[xyz010] = herez1[y + 2]
	data[xyz001] = herez2[y + 1]
	data[xyz000] = herez1[y + 1]
end
interpolator.cache_yz_values = interpolator_cache_yz_values

local function lerp1d (u, s1, s2)
	return (s2 - s1) * u + s1
end

-- Partially interpolate between the corners of the cells being
-- considered along the X and Z axes by PROGRESS on the Y axis, and
-- cache the products in `self.xz00', `xz10', `xz01', and `xz11'.

local function interpolator_y_interpolate (data, progress)
	local xyz000 = 1
	local xyz001 = 2
	local xyz010 = 3
	local xyz011 = 4
	local xyz100 = 5
	local xyz101 = 6
	local xyz110 = 7
	local xyz111 = 8
	local xz00 = 9
	local xz01 = 10
	local xz10 = 11
	local xz11 = 12

	data[xz11] = lerp1d (progress, data[xyz101], data[xyz111])
	data[xz10] = lerp1d (progress, data[xyz100], data[xyz110])
	data[xz01] = lerp1d (progress, data[xyz001], data[xyz011])
	data[xz00] = lerp1d (progress, data[xyz000], data[xyz010])
end
interpolator.y_interpolate = interpolator_y_interpolate

-- Likewise, but along the X axis.

local function interpolator_x_interpolate (data, progress)
	local xz00 = 9
	local xz01 = 10
	local xz10 = 11
	local xz11 = 12
	local z0 = 13
	local z1 = 14

	data[z1] = lerp1d (progress, data[xz01], data[xz11])
	data[z0] = lerp1d (progress, data[xz00], data[xz10])
end
interpolator.x_interpolate = interpolator_x_interpolate

-- Complete interpolation.

local function interpolator_z_interpolate (data, progress)
	local z0 = 13
	local z1 = 14
	local value = 15
	data[value] = lerp1d (progress, data[z0], data[z1])
end

function interpolator:__call (x, y, z, blender)
	local data = self.data
	local value = 15
	if data[value] then
		return data[value]
	else
		return self.input (x, y, z, blender)
	end
end

function interpolator:petrify_internal (visited)
	self.saved_max_value = self.input:max_value ()
	self.saved_min_value = self.input:min_value ()
	local input = self.input:petrify_and_clone (visited)
	self.input = input
	local data = self.data
	local value = 15
	return function (x, y, z, blender)
		if data[value] then
			return data[value]
		else
			return input (x, y, z, blender)
		end
	end
end

-- Flat Cache.

local flat_cache = table.merge (density_function, {
	input = nil,
	nvalues = 0,
	values = {},
	chunk_origin_x = false,
	chunk_origin_z = false,
})

function flat_cache:create_noise_arrays (width_and_depth_quart)
	local values = {}

	for x = 1, width_and_depth_quart + 1 do
		local tem = {}
		values[x] = tem
		for z = 1, width_and_depth_quart + 1 do
			tem[z] = 0
		end
	end

	self.values = values
	self.nvalues = #values
end

function flat_cache:clear_cache ()
	self.chunk_origin_x = false
	self.chunk_origin_z = false
end

function flat_cache:prime_noise_arrays (origin_x, origin_z)
	local nvalues = self.nvalues
	local values = self.values
	local input = self.input

	for x = 1, nvalues do
		local tem = values[x]
		for z = 1, nvalues do
			tem[z] = input (origin_x + toblock (x - 1),
					0,
					origin_z + toblock (z - 1),
					nil)
		end
	end

	self.chunk_origin_x = toquart (origin_x)
	self.chunk_origin_z = toquart (origin_z)
end

function flat_cache:__call (x, y, z, blender)
	local origin_x = self.chunk_origin_x
	if origin_x then
		local qx = toquart (x) - origin_x
		local qz = toquart (z) - self.chunk_origin_z
		local nvalues = self.nvalues
		if qx >= 0 and qz >= 0 and qx < nvalues and qz < nvalues then
			return self.values[qx + 1][qz + 1]
		end
	end
	return self.input (x, y, z, blender)
end

-- Cache Once.

local cache_once = table.merge (density_function, {
	input = nil,
	cache = {},
})

local function longhash (x, y, z)
	return (32768 + x) * 65536 * 65536 + (32768 + y) * 65536
		+ (32768 + z)
end

function cache_once:clear_cache ()
	self.cache = {}
end

function cache_once:__call (x, y, z, blender)
	local hash = longhash (x, y, z)
	local val = self.cache[hash]
	if val then
		return val
	end
	local val = self.input (x, y, z, blender)
	self.cache[hash] = val
	return val
end

-- Cache 2D

local cache_2d = table.merge (density_function, {
	input = nil,
	cache = {},
})

local function hash2d (x, z)
	return (32768 + x) * 65536 + (32768 + z)
end

function cache_2d:clear_cache ()
	self.cache = {}
end

function cache_2d:__call (x, y, z, blender)
	local hash = hash2d (x, z)
	local val = self.cache[hash]
	if val then
		return val
	end
	local val = self.input (x, 0, z, blender)
	self.cache[hash] = val
	return val
end

------------------------------------------------------------------------
-- Heightmap storage.  Two pairs of 10 bit values are recorded in
-- `heightmap' array for each horizontal position in a MapChunk
-- representing the values of the WORLD_SURFACE_WG and OCEAN_FLOOR_WG
-- heightmaps.  See: https://minecraft.wiki/w/Heightmap
------------------------------------------------------------------------

local lshift = bit.lshift
local rshift = bit.rshift
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot

local function pack_height_map (surface, motion_blocking)
	local bias = 512
	local bits = 10

	return lshift (surface + bias, bits)
		+ (motion_blocking + bias)
end

mcl_levelgen.pack_height_map = pack_height_map

local function unpack_height_map (vals)
	local bias = 512
	local bits = 10
	local mask = 0x3ff
	local surface = rshift (vals, bits) - bias
	local motion_blocking = band (vals, mask) - bias
	return surface, motion_blocking
end

mcl_levelgen.unpack_height_map = unpack_height_map

local function update_height_map (map, x, y, z, isair, isstone, chunksize)
	local index = x * chunksize + z + 1
	local surface, motion_blocking = unpack_height_map (map[index])

	if not isair then
		surface = mathmax (surface, y + 1)
	end

	if isstone then
		motion_blocking = mathmax (motion_blocking, y + 1)
	end
	map[index] = pack_height_map (surface, motion_blocking)
end

function terrain_generator:clear_height_map ()
	local map = self.heightmap_wg
	local chunksize = self.chunksize
	for i = 1, chunksize * chunksize do
		map[i] = 0
	end
end

------------------------------------------------------------------------
-- Terrain generation.
------------------------------------------------------------------------

local function fill_interpolators (self, initial, x_cell,
				   z_cell, y_base,
				   n_cells_z, n_cells_y)
	local interpolators = self.interpolators
	for zoff = 0, n_cells_z do
		for _, interpolator in ipairs (interpolators) do
			interpolator:fill_noise_slice (initial, x_cell,
						       z_cell, zoff,
						       y_base,
						       n_cells_z, n_cells_y,
						       self.cell_width,
						       self.cell_height)
		end
	end
end

local function interpolator_update (self, y, z)
	for _, interpolator in ipairs (self.interpolators) do
		interpolator_cache_yz_values (interpolator, y, z)
	end
end

local function interpolator_update_y (self, progress)
	for _, data in ipairs (self.interpolator_data) do
		interpolator_y_interpolate (data, progress)
	end
end

local function interpolator_update_x (self, progress)
	for _, data in ipairs (self.interpolator_data) do
		interpolator_x_interpolate (data, progress)
	end
end

local function generic_interpolator_update_z (self, progress)
	for _, data in ipairs (self.interpolator_data) do
		interpolator_z_interpolate (data, progress)
	end
end

local function interpolator_update_z_1 (self, progress)
	local data = self.interpolator_data
	interpolator_z_interpolate (data[1], progress)
end

local function interpolator_update_z_2 (self, progress)
	local data = self.interpolator_data
	interpolator_z_interpolate (data[1], progress)
	interpolator_z_interpolate (data[2], progress)
end

local function interpolator_update_z_3 (self, progress)
	local data = self.interpolator_data
	interpolator_z_interpolate (data[1], progress)
	interpolator_z_interpolate (data[2], progress)
	interpolator_z_interpolate (data[3], progress)
end

local function interpolator_update_z_4 (self, progress)
	local data = self.interpolator_data
	interpolator_z_interpolate (data[1], progress)
	interpolator_z_interpolate (data[2], progress)
	interpolator_z_interpolate (data[3], progress)
	interpolator_z_interpolate (data[4], progress)
end

local function interpolator_update_z_5 (self, progress)
	local data = self.interpolator_data
	interpolator_z_interpolate (data[1], progress)
	interpolator_z_interpolate (data[2], progress)
	interpolator_z_interpolate (data[3], progress)
	interpolator_z_interpolate (data[4], progress)
	interpolator_z_interpolate (data[5], progress)
end

local function interpolator_update_z_6 (self, progress)
	local data = self.interpolator_data
	interpolator_z_interpolate (data[1], progress)
	interpolator_z_interpolate (data[2], progress)
	interpolator_z_interpolate (data[3], progress)
	interpolator_z_interpolate (data[4], progress)
	interpolator_z_interpolate (data[5], progress)
	interpolator_z_interpolate (data[6], progress)
end

local function interpolator_update_z_7 (self, progress)
	local data = self.interpolator_data
	interpolator_z_interpolate (data[1], progress)
	interpolator_z_interpolate (data[2], progress)
	interpolator_z_interpolate (data[3], progress)
	interpolator_z_interpolate (data[4], progress)
	interpolator_z_interpolate (data[5], progress)
	interpolator_z_interpolate (data[6], progress)
	interpolator_z_interpolate (data[7], progress)
end

local function interpolator_update_z_8 (self, progress)
	local data = self.interpolator_data
	interpolator_z_interpolate (data[1], progress)
	interpolator_z_interpolate (data[2], progress)
	interpolator_z_interpolate (data[3], progress)
	interpolator_z_interpolate (data[4], progress)
	interpolator_z_interpolate (data[5], progress)
	interpolator_z_interpolate (data[6], progress)
	interpolator_z_interpolate (data[7], progress)
	interpolator_z_interpolate (data[8], progress)
end

local interpolator_z_functions = {
	interpolator_update_z_1,
	interpolator_update_z_2,
	interpolator_update_z_3,
	interpolator_update_z_4,
	interpolator_update_z_5,
	interpolator_update_z_6,
	interpolator_update_z_7,
	interpolator_update_z_8,
}

local function select_interpolator_z_function (self)
	local data = self.interpolator_data
	return interpolator_z_functions[#data]
		or generic_interpolator_update_z
end

local function prepare_interpolation (self, origin_x, origin_z, x_cell,
				      z_cell, y_base, n_cells_xz, n_cells_y)
	local cachers = self.flat_caches
	for _, cacher in ipairs (cachers) do
		cacher:prime_noise_arrays (origin_x, origin_z)
	end

	fill_interpolators (self, true, x_cell, z_cell, y_base,
			    n_cells_xz, n_cells_y)
end

local function exchange_slices (self)
	local interpolators = self.interpolators
	for _, interpolator in ipairs (interpolators) do
		interpolator.noises_here, interpolator.noises_next
			= interpolator.noises_next, interpolator.noises_here
	end
end

local function reset_interpolators (self)
	local value = 15
	for _, data in ipairs (self.interpolator_data) do
		data[value] = nil
	end

	local caches = self.caches_to_clear
	for _, cache in ipairs (caches) do
		cache:clear_cache ()
	end
end

local mathmax = math.max
local floor = math.floor
local ceil = math.ceil

-- function terrain_generator:generate (x, y, z, cids, param2s, vm_index)
-- 	for x = 0, self.chunksize - 1 do
-- 		for z = 0, self.chunksize - 1 do
-- 			for ny = 0, self.chunksize - 1 do
-- 				local index = vm_index (x, ny, z)
-- 				if ny + y <= 0 then
-- 					cids[index] = cid_stone
-- 				else
-- 					cids[index] = cid_air
-- 				end
-- 			end
-- 		end
-- 	end
-- 	return true
-- end

local function state_from_density (aquifer, get_node, cid_default_block,
				   x, y, z, density, veins, gen)
	if density > 0.0 then
		if veins then
			return vein_block_at_position (gen, x, y, z,
						       cid_default_block)
		end
		return cid_default_block, 0
	end
	if veins then
		local cid, param2 = get_node (aquifer, x, y, z, density)
		if cid == cid_default_block then
			return vein_block_at_position (gen, x, y, z,
						       cid_default_block)
		else
			return cid, param2
		end
	end
	return get_node (aquifer, x, y, z, density)
end

local function clear_surface_level_cache (self)
	local cache = self.surface_level_cache
	for i, _ in pairs (cache) do
		cache[i] = nil
	end
end

local gen_node_caches = {}

local function encode_node (cid, param2)
	return lshift (cid, 8) + param2
end
mcl_levelgen.encode_node = encode_node

local function decode_node (node)
	return band (rshift (node, 8), 0xffff),
		band (node, 0xff)
end
mcl_levelgen.decode_node = decode_node

local function structure_decode_node (node)
	return band (rshift (node, 8), 0xffff),
		band (node, 0xff),
		rshift (node, 24)
end
mcl_levelgen.structure_decode_node = structure_decode_node

local function index (x, y, z, chunksize, level_height)
	return ((x * level_height) + y) * chunksize + z + 1
end

local function generate_step (self, x_pos, y_pos, z_pos,
			      aquifer, get_node,
			      cid_default_block, veins,
			      x, y_min, z, gn, map_wg,
			      final_density, chunksize,
			      level_height)
	-- GN currently holds beardifier influences.
	local i = index (x_pos - x, y_pos - y_min, z_pos - z,
			 chunksize, level_height)
	local density
		= final_density (x_pos, y_pos, z_pos, nil) + gn[i]
	local cid, param2
		= state_from_density (aquifer, get_node,
				      cid_default_block,
				      x_pos, y_pos,
				      z_pos, density,
				      veins, self)
	gn[i] = encode_node (cid, param2)
	update_height_map (map_wg, x_pos - x,
			   y_pos - y_min,
			   z_pos - z,
			   cid == cid_air,
			   cid == cid_default_block,
			   chunksize, cid)
end

local function level_size_key (chunksize, level_height)
	return chunksize * 1024 + level_height
end

local function initialize_structuremask (structuremask)
	local x1, y1, z1 = structuremask[1],
		structuremask[2],
		structuremask[3]
	local x2, y2, z2 = structuremask[4],
		structuremask[5],
		structuremask[6]

	if z2 >= z1 and y2 >= y1 and x2 >= x1 then
		local size = (z2 - z1 + 1) * (y2 - y1 + 1) * (x2 - x1 + 1)
		local size_word = rshift (size + 7, 3)
		for i = 7, size_word + 6 do
			structuremask[i] = 0
		end
		for i = size_word + 7, #structuremask do
			structuremask[i] = nil
		end
	else
		for i = 7, #structuremask do
			structuremask[i] = nil
		end
	end
end

local function update_structuremask (x, y, z, structuremask,
				     structure_step)
	-- 4 bits are available for each structuremask element, and 8
	-- can occupy each element of the array.
	local ix = x - structuremask[1]
	local iy = y - structuremask[2]
	local iz = z - structuremask[3]
	local h = (structuremask[5] - structuremask[2]) + 1
	local l = (structuremask[6] - structuremask[3]) + 1
	local idx = ((ix * h) + iy) * l + iz
	local elem = rshift (idx, 3) + 7
	local bit = lshift (band (idx, 7), 2)
	local current = structuremask[elem]
	local mask = bnot (lshift (0xf, bit))
	structuremask[elem] = bor (band (current, mask),
				   lshift (structure_step, bit))
	return elem
end

function terrain_generator:init_gen_node_caches (chunksize, level_height)
	local key = level_size_key (chunksize, level_height)
	if not gen_node_caches[key] then
		local cache = {}
		for i = 1, chunksize * level_height * chunksize do
			cache[i] = 0
		end
		gen_node_caches[key] = cache
	end
	return gen_node_caches[key]
end

function terrain_generator:generate (x, y, z, cids, param2s, structuremask, vm_index, biomes)
	local y_min = self.y_min
	local chunksize = self.chunksize

	assert (x % 16 == 0)
	assert (z % 16 == 0)
	assert (y % 16 == 0)

	local y_max = y + self.chunksize_y - 1
	local cell_width = self.cell_width
	local cell_height = self.cell_height
	local x_cell = floor (x / cell_width)
	local z_cell = floor (z / cell_width)
	local level_height = self.level_height
	local horiz_cells = ceil (chunksize / cell_width)

	-- Return if there is nothing to generate.
	do
		local level_y_max = y_min + level_height - 1
		local y_bottom_block = mathmax (y, y_min)
		local y_top_block = mathmin (y_max, level_y_max)
		if y_top_block - y_bottom_block < 0 then
			return false
		end
	end

	-- Build structure references and starts.
	-- local clock = core.get_us_time ()
	mcl_levelgen.prepare_structures (self.structures, self, x, z)
	-- print (string.format ("%.2f", (core.get_us_time () - clock) / 1000))

	-- Table of nodes produced for this horizontal section of the
	-- level.  Also reused to store beardifier influences if need
	-- be.
	local gn = self:init_gen_node_caches (chunksize, level_height)
	mcl_levelgen.beardify (self.structures, self, gn, index, x, z)

	-- Reset the temporary heightmap.
	self:clear_height_map ()

	-- Reseat the aquifer.
	local aquifer, get_node = self.aquifer, self.aquifer.get_node
	aquifer:reseat (x, y_min, z)
	local cid_default_block = self.cid_default_block

	-- Initialize flat cachers and interpolators.
	local y_total = floor (level_height / cell_height)
	local y_bottom = floor (y_min / cell_height)
	local final_density = self.final_density
	prepare_interpolation (self, x, z, x_cell, z_cell, y_bottom,
			       horiz_cells, y_total)
	local veins = self.preset.ore_veins_enabled
	local interpolator_update_z
		= select_interpolator_z_function (self)

	-- Height map holding height levels at horizontal positions.
	local map_wg = self.heightmap_wg
	for x1 = 0, horiz_cells - 1 do
		local x_base = x1 * cell_width + x

		-- This calculates the _next_ slice's values.
		fill_interpolators (self, false, x_cell + x1 + 1, z_cell,
				    y_bottom, horiz_cells, y_total)

		for z1 = 0, horiz_cells - 1 do
			local z_base = z1 * cell_width + z
			for y1 = y_total - 1, 0, -1 do
				local y_base = y1 * cell_height + y_min
				interpolator_update (self, y1, z1)

				-- Begin processing individual blocks
				-- in this cell.
				for internal_y = cell_height - 1, 0, -1 do
					local y_pos = y_base + internal_y
					interpolator_update_y (self, internal_y / cell_height)

					for internal_x = 0, cell_width - 1 do
						local x_pos = x_base + internal_x
						interpolator_update_x (self, internal_x / cell_width)

						for internal_z = 0, cell_width - 1 do
							interpolator_update_z (self, internal_z / cell_width)
							local z_pos = z_base + internal_z
							generate_step (self, x_pos, y_pos, z_pos,
								       aquifer, get_node,
								       cid_default_block, veins,
								       x, y_min, z, gn, map_wg,
								       final_density, chunksize,
								       level_height)
						end
					end
				end
			end
		end

		exchange_slices (self)
		reset_interpolators (self)
	end

	-- Reset flat caches.
	local flat_caches = self.flat_caches
	for _, cache in ipairs (flat_caches) do
		cache:clear_cache ()
	end

	-- Reset preliminary surface level cache.
	clear_surface_level_cache (self)

	-- Process surface systems and carvers.
	local system = self.surface_system
	system:post_process (self, x, y, z, gn, map_wg, chunksize, biomes)

	-- local clock = core.get_us_time ()
	mcl_levelgen.carve_terrain (self.preset, gn, biomes, map_wg,
				    x, y, z, chunksize, index,
				    self.preset.min_y, self.preset.height, self)
	-- print (string.format ("%.2f", (core.get_us_time () - clock) / 1000))

	-- Regenerate the heightmap (or rather two heightmaps: one
	-- representing the state of the terrain after surface system
	-- and carver execution, and the second after structure
	-- placement).
	self:regenerate_heightmaps (gn, chunksize, self.preset)

	-- Process structures.
	-- local clock = core.get_us_time ()
	local structure_extents
		= mcl_levelgen.finish_structures (self.structures, self,
						  biomes, x, y, z, y_min,
						  level_height, index, gn)
	-- print (string.format ("%.2f", (core.get_us_time () - clock) / 1000))
	structuremask[1] = structure_extents[1]
	structuremask[2] = mathmax (structure_extents[2], y)
	structuremask[3] = structure_extents[3]
	structuremask[4] = structure_extents[4]
	structuremask[5] = mathmin (structure_extents[5], y_max)
	structuremask[6] = structure_extents[6]
	initialize_structuremask (structuremask)

	-- Write the section that intersects the output area to CIDs
	-- and PARAM2.
	local y0 = mathmax (y, y_min)
	local y1 = mathmin (y_max, y_min + level_height - 1)
	local i = index (0, y0 - y_min, 0, chunksize, level_height)
	local skip = (level_height - (y1 - y0 + 1)) * chunksize
	for ix = 0, chunksize - 1 do
		local x_within_p = ix >= (structuremask[1] - x)
			and ix <= (structuremask[4] - x)
		for iy = y0, y1 do
			local y_within_p = iy >= (structuremask[2])
				and iy <= (structuremask[5])
			for iz = 0, chunksize - 1 do
				local z_within_p = iz >= (structuremask[3] - z)
					and iz <= (structuremask[6] - z)
				local idx = vm_index (ix, iy - y, iz)
				local structure_step
				cids[idx], param2s[idx], structure_step
					= structure_decode_node (gn[i])
				if x_within_p and y_within_p and z_within_p then
					update_structuremask (x + ix, iy, z + iz,
							      structuremask, structure_step)
				end
				i = i + 1
			end
		end
		i = i + skip
	end
	-- Reset the chunksize/beardifier density cache.
	for i = 1, chunksize * level_height * chunksize do
		gn[i] = 0.0
	end
	-- if veiny > 0 then
	-- 	nwithveins = nwithveins + 1
	-- 	veiny = 0
	-- end
	-- ntotal = ntotal + 1
	return true
end

------------------------------------------------------------------------
-- Auxiliary terrain generation sampling.
------------------------------------------------------------------------

local function get_one_height_or_column (self, x, z, predicate, arg)
	local y_min = self.y_min
	local cell_width = self.cell_width
	local cell_height = self.cell_height
	local x_cell = floor (x / cell_width)
	local z_cell = floor (z / cell_width)
	local level_height = self.level_height
	local y_bottom = floor (y_min / cell_height)
	local y_total = floor (level_height / cell_height)

	-- Reseat the aquifer.
	local x_chunk, z_chunk = band (x, -16), band (z, -16)
	local aquifer, get_node = self.aquifer, self.aquifer.get_node
	aquifer:reseat (x_chunk, y_min, z_chunk)

	-- Prepare interpolation by filling both ZY-slices and
	-- clearing the flat cache.
	prepare_interpolation (self, x_chunk, z_chunk, x_cell, z_cell,
			       y_bottom, 1, y_total)
	fill_interpolators (self, false, x_cell + 1, z_cell, y_bottom,
			    1, y_total)

	local progress_x = (x % cell_width) / cell_width
	local progress_z = (z % cell_width) / cell_width
	local final_density = self.final_density
	local cid_default_block = self.cid_default_block
	local interpolator_update_z = generic_interpolator_update_z

	local veins = self.preset.ore_veins_enabled
	for y = y_total - 1, 0, -1 do
		local y_base = y * cell_height + y_min
		interpolator_update (self, y, 0)
		-- Begin processing individual blocks
		-- in this cell.
		for internal_y = cell_height - 1, 0, -1 do
			local y_pos = y_base + internal_y
			local progress = internal_y / cell_height
			interpolator_update_y (self, progress)
			interpolator_update_x (self, progress_x)
			interpolator_update_z (self, progress_z)
			local density = final_density (x, y_pos, z)
			local value = predicate (self, aquifer, get_node,
						 cid_default_block,
						 x, y_pos, z, density,
						 veins, arg)
			if value then
				return value
			end
		end
	end

	return nil
end

local function get_one_height_processed (terrain, aquifer, get_node,
					 cid_default_block,
					 x, y_pos, z, density,
					 veins, arg)
	local cid, param2
		= state_from_density (aquifer, get_node,
				      cid_default_block,
				      x, y_pos, z, density,
				      veins, terrain)
	if arg (cid, param2) then
		return y_pos + 1
	end
	return nil
end

local function get_one_height_cb (_, _, _, _, _, y_pos, _, density, _, _)
	if density >= 0.0 then
		return y_pos + 1
	end
	return nil
end

function terrain_generator:get_one_height (x, z, is_solid)
	if is_solid then
		return get_one_height_or_column (self, x, z,
						 get_one_height_processed,
						 is_solid) or -32768
	else
		return get_one_height_or_column (self, x, z, get_one_height_cb,
						 nil) or -32768
	end
end

local get_one_column_y_min

local function get_one_column_cb (terrain, aquifer, get_node,
				  cid_default_block,
				  x, y_pos, z, density,
				  veins, arg)
	local cid, param2
		= state_from_density (aquifer, get_node,
				      cid_default_block,
				      x, y_pos, z, density,
				      veins, terrain)
	arg[y_pos - get_one_column_y_min + 1] = encode_node (cid, param2)
end

function terrain_generator:get_one_column (x, z, column_data)
	local level_height = self.level_height
	get_one_column_y_min = self.y_min
	column_data[level_height + 1] = nil
	get_one_height_or_column (self, x, z, get_one_column_cb,
				  column_data)
	return column_data
end

local function map_area_height_1 (self, value, x1_proper, z1_proper, x2_proper,
				  z2_proper, processor, arg)
	local y_min = self.y_min
	local cell_width = self.cell_width
	local cell_height = self.cell_height
	local x_chunk, z_chunk = band (x1_proper, -16), band (z1_proper, -16)
	local x_cell = floor (x_chunk / cell_width)
	local z_cell = floor (z_chunk / cell_width)
	local x_cells = ceil ((x2_proper - x_chunk + 1) / cell_width)
	local z_cells = ceil ((z2_proper - z_chunk + 1) / cell_width)
	local horiz_cells = mathmax (x_cells, z_cells)
	local cell_base_x = floor (x1_proper / cell_width)
	local cell_base_z = floor (z1_proper / cell_width)

	-- Reseat the aquifer.
	local aquifer = self.aquifer
	aquifer:reseat (x_chunk, y_min, z_chunk)

	-- Prepare interpolation by filling both ZY-slices and
	-- clearing the flat cache.
	local level_height = self.level_height
	local y_bottom = floor (y_min / cell_height)
	local y_total = floor (level_height / cell_height)
	prepare_interpolation (self, x_chunk, z_chunk, cell_base_x, z_cell,
			       y_bottom, horiz_cells, y_total)
	local final_density = self.final_density
	local interpolator_update_z = generic_interpolator_update_z

	-- TODO: rearrange interpolation order to iterate over each
	-- column exactly once if it can be established that such an
	-- alteration will not produce unacceptably severe
	-- inconsistencies with terrain generation.
	for x1 = cell_base_x - x_cell, x_cells - 1 do
		local x_base = x1 * cell_width + x_chunk

		-- This calculates the _next_ slice's values.
		fill_interpolators (self, false, x_cell + x1 + 1, z_cell,
				    y_bottom, horiz_cells, y_total)

		for z1 = cell_base_z - z_cell, z_cells - 1 do
			local z_base = z1 * cell_width + z_chunk
			for y1 = y_total - 1, 0, -1 do
				local y_base = y1 * cell_height + y_min
				interpolator_update (self, y1, z1)

				-- Begin processing individual blocks
				-- in this cell.
				for internal_y = cell_height - 1, 0, -1 do
					local y_pos = y_base + internal_y
					interpolator_update_y (self, internal_y / cell_height)

					local x0 = mathmax (0, x1_proper - x_base)
					local x2 = mathmax (0, x_base + cell_width - 1 - x2_proper)
					for internal_x = x0, cell_width - 1 - x2 do
						local x_pos = x_base + internal_x
						interpolator_update_x (self, internal_x / cell_width)

						local z0 = mathmax (0, z1_proper - z_base)
						local z2 = mathmax (0, z_base + cell_width - 1 - z2_proper)
						for internal_z = z0, cell_width - 1 - z2 do
							interpolator_update_z (self, internal_z / cell_width)
							local z_pos = z_base + internal_z
							value = processor (self, value,
									   x_pos, y_pos, z_pos,
									   final_density (x_pos,
											  y_pos,
											  z_pos),
									   arg)
						end
					end
				end
			end
		end

		exchange_slices (self)
		reset_interpolators (self)
	end
	return value
end

local function map_area_height (self, x1, z1, x2, z2, initial, processor, arg)
	local x1_chunk = band (x1, -16)
	local z1_chunk = band (z1, -16)
	local chunksize = self.chunksize
	local value = initial

	for x1_iter = x1_chunk, x2, chunksize do
		for z1_iter = z1_chunk, z2, chunksize do
			local x1_proper = mathmax (x1_iter, x1)
			local z1_proper = mathmax (z1_iter, z1)
			local x2_proper = mathmin (x1_iter + chunksize - 1, x2)
			local z2_proper = mathmin (z1_iter + chunksize - 1, z2)

			value = map_area_height_1 (self, value, x1_proper,
						   z1_proper, x2_proper,
						   z2_proper, processor, arg)
		end
	end
	return value
end

local area_heightmap_x1
local area_heightmap_z1
local area_heightmap_x2
local area_heightmap_z2
local area_heightmap_heightmap

local function map_area_heightmap_no_solid (terrain, value, x, y, z, density, arg)
	assert (x >= area_heightmap_x1 and x <= area_heightmap_x2)
	assert (z >= area_heightmap_z1 and z <= area_heightmap_z2)

	if density > 0.0 then
		local length = area_heightmap_z2
			- area_heightmap_z1 + 1
		local dx = x - area_heightmap_x1
		local dz = z - area_heightmap_z1
		local idx = dx * length + dz + 1
		if arg[idx] <= y then
			arg[idx] = y + 1
		end
	end
end

local function map_area_heightmap (terrain, value, x, y, z, density, arg)
	assert (x >= area_heightmap_x1 and x <= area_heightmap_x2)
	assert (z >= area_heightmap_z1 and z <= area_heightmap_z2)

	local cid, param2
		= state_from_density (terrain.aquifer,
				      terrain.aquifer.get_node,
				      terrain.cid_default_block,
				      x, y, z, density,
				      terrain.ore_veins_enabled,
				      terrain)
	if arg (cid, param2) then
		local length = area_heightmap_z2
			- area_heightmap_z1 + 1
		local dx = x - area_heightmap_x1
		local dz = z - area_heightmap_z1
		local idx = dx * length + dz + 1
		if area_heightmap_heightmap[idx] <= y then
			area_heightmap_heightmap[idx] = y + 1
		end
	end
end

local huge = math.huge

function terrain_generator:area_heightmap (x1, z1, x2, z2, heightmap, is_solid)
	local w = x2 - x1 + 1
	local l = z2 - z1 + 1
	local total = w * l
	for i = 1, total do
		heightmap[i] = -huge
	end

	-- Note: level-relative coordinates are returned, rather than
	-- absolute ones as in heightmaps produced by
	-- terrain_generator:generate.
	area_heightmap_x1 = x1
	area_heightmap_z1 = z1
	area_heightmap_x2 = x2
	area_heightmap_z2 = z2
	if is_solid then
		area_heightmap_heightmap = heightmap
		map_area_height (self, x1, z1, x2, z2, nil,
				 map_area_heightmap, is_solid)
	else
		map_area_height (self, x1, z1, x2, z2, nil,
				 map_area_heightmap_no_solid,
				 heightmap)
	end
	return total
end

local heightmap = {}

function terrain_generator:area_min_height (x1, z1, x2, z2, is_solid)
	local total = self:area_heightmap (x1, z1, x2, z2, heightmap,
					   is_solid)
	local value = heightmap[1]
	for i = 2, total do
		value = mathmin (value, heightmap[i])
	end
	return value
end

local function rtz (n)
	if n < 0 then
		return ceil (n)
	end
	return floor (n)
end

function terrain_generator:area_average_height (x1, z1, x2, z2, is_solid)
	local total = self:area_heightmap (x1, z1, x2, z2, heightmap,
					   is_solid)
	local value = heightmap[1]
	for i = 2, total do
		value = value + heightmap[i]
	end
	return rtz (value / total)
end

------------------------------------------------------------------------
-- Aquifer and surface system interface.
------------------------------------------------------------------------

local function sample_preliminary_surface_level (dfn, min_y, max_y, x, z, step)
	for y = max_y, min_y, -step do
		-- This constant is documented on some of the regional
		-- Minecraft wiki editions, and from testing it
		-- appears to be correct.
		if dfn (x, y, z) > 0.390625 then
			return y
		end
	end
	return huge
end

-- X and Z are to be absolute positions.

function terrain_generator:get_preliminary_surface_level (x, z)
	local cache = self.surface_level_cache
	local x = band (x, -4)
	local z = band (z, -4)
	local hash = bor (lshift (x + 0x8000, 16), z + 0x8000)
	local val = cache[hash]
	if val then
		return val
	end
	local dfn = self.initial_density_without_jaggedness
	local min_y = self.y_min
	local max_y = min_y + self.level_height
	local cell_height = self.cell_height
	val = sample_preliminary_surface_level (dfn, min_y, max_y, x, z, cell_height)
	cache[hash] = val
	return val
end

------------------------------------------------------------------------
-- Terrain generator instantiation.
------------------------------------------------------------------------

function mcl_levelgen.make_terrain_generator (preset, chunksize, ychunksize)
	local gen = table.copy (terrain_generator)
	gen.preset = preset
	gen.level_height = preset.height
	gen.y_min = preset.min_y
	gen.chunksize = chunksize
	gen.chunksize_y = ychunksize
	local cell_width = preset.noise_cell_width
	local cell_height = preset.noise_cell_height
	gen.cell_width = cell_width
	gen.cell_height = cell_height

	-- chunksize is permitted not to be divisible by cell_height
	-- or cell_width.
	gen.n_cells_xz = ceil (chunksize / cell_width)
	gen.n_cells_y = ceil (mathmax (chunksize, preset.height)
			      / cell_height)
	gen.cell_total_width = gen.n_cells_xz * cell_width

	-- Wrap the preset's final density function with functions
	-- that will undertake caching and interpolation.  Save the
	-- results (and the interpolators in particular), for they
	-- must be separately primed before density samping commences
	-- in earnest.

	local density_functions = {}
	local markers = {}

	gen.interpolators = {}
	gen.interpolator_data = {}
	gen.flat_caches = {}
	gen.caches_to_clear = {}

	local function instantiate_marker_fns (func)
		local fn = density_functions[func]
		if fn then
			return fn
		end

		if func.is_marker then
			if markers[func.input] then
				fn = markers[func.input]
			elseif func.name == "interpolated" then
				fn = table.merge (interpolator, {
					noises_here = {},
					noises_next = {},
					input = func,
				})
				fn = make_density_function (fn)
				table.insert (gen.interpolators, fn)
				fn:create_noise_arrays (gen.n_cells_y,
							gen.n_cells_xz)
				table.insert (gen.interpolator_data, fn.data)
			elseif func.name == "flat_cache" then
				fn = table.merge (flat_cache, {
					input = func,
				})
				fn = make_density_function (fn)
				local qsize = toquart (gen.n_cells_xz * gen.cell_width)
				fn:create_noise_arrays (qsize)
				table.insert (gen.flat_caches, fn)
			elseif func.name == "cache_2d" then
				fn = table.merge (cache_2d, {
					input = func,
					cache = {},
				})
				fn = make_density_function (fn)
				table.insert (gen.caches_to_clear, fn)
			elseif func.name == "cache_once" then
				fn = table.merge (cache_once, {
					input = func,
					cache = {},
				})
				fn = make_density_function (fn)
				table.insert (gen.caches_to_clear, fn)
			end
			markers[func.input] = fn
		else
			fn = func
		end
		density_functions[func] = fn
		return fn
	end

	local final_density, visited
		= preset.final_density:wrap (instantiate_marker_fns,
					     mcl_levelgen.identity)
	gen.final_density = final_density:petrify ()

	local function wrapnext (noise)
		return noise:wrap_internal (instantiate_marker_fns,
					    mcl_levelgen.identity,
					    visited):petrify ()
	end
	local input = preset.initial_density_without_jaggedness
	gen.initial_density_without_jaggedness = wrapnext (input)
	gen.erosion = wrapnext (preset.erosion)
	gen.depth = wrapnext (preset.depth)
	gen.floodedness = wrapnext (preset.fluid_level_floodedness_noise)
	gen.fluid_spread = wrapnext (preset.fluid_level_spread_noise)
	gen.lava_noise = wrapnext (preset.lava_noise)
	gen.barrier_noise = wrapnext (preset.barrier_noise)
	gen.surface_level_cache = {}

	if core then
		gen.cid_default_fluid = core.get_content_id (preset.default_fluid)
		gen.cid_default_block = core.get_content_id (preset.default_block)
	else
		gen.cid_default_block = cid_stone
		gen.cid_default_fluid = cid_water_source
	end

	if preset.aquifers_enabled then
		gen.aquifer = mcl_levelgen.create_localized_aquifer (preset, gen)
	else
		gen.aquifer = mcl_levelgen.create_default_aquifer (preset, gen)
	end

	gen.structures = mcl_levelgen.make_structure_level (preset)

	local heightmap, heightmap_wg = {}, {}
	for i = 1, chunksize * chunksize do
		heightmap[i] = 0
		heightmap_wg[i] = 0
	end
	gen.heightmap = heightmap
	gen.heightmap_wg = heightmap_wg
	gen.surface_system = mcl_levelgen.make_surface_system (preset)
	gen.biome_seed = mcl_levelgen.get_biome_seed (preset.seed)

	if preset.ore_veins_enabled then
		local ore = preset.factory ("minecraft:ore"):fork_positional ()
		gen.ore_random = ore:create_reseedable ()
		gen.vein_toggle = wrapnext (preset.vein_toggle)
		gen.vein_ridged = wrapnext (preset.vein_ridged)
		gen.vein_gap = wrapnext (preset.vein_gap)
	end
	return gen
end

------------------------------------------------------------------------
-- Heightmap recomputation.
------------------------------------------------------------------------

function terrain_generator:regenerate_heightmaps (nodes, chunksize, preset)
	local heightmap = self.heightmap_wg
	local heightmap_structures = self.heightmap
	local level_height = preset.height
	-- Reset the heightmap first.
	for i = 1, chunksize * chunksize do
		heightmap[i] = 0
	end

	for y = level_height - 1, 0, -1 do
		local ybase = y * chunksize
		for x = 0, chunksize - 1 do
			local xbase = ybase + x * chunksize * level_height
			for z = 0, chunksize - 1 do
				local index = xbase + z + 1
				local cid, _ = decode_node (nodes[index])
				local isair = cid == cid_air
				local isstone = cid ~= cid_air
					and cid ~= cid_lava_source
					and cid ~= cid_nether_lava_source
					and cid ~= cid_water_source
				update_height_map (heightmap, x, y, z,
						   isair, isstone,
						   chunksize)
				local idx = x + chunksize * z + 1
				heightmap_structures[idx] = heightmap[idx]
			end
		end
	end
end
