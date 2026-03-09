------------------------------------------------------------------------
-- Aquifer processing.
------------------------------------------------------------------------

local ipairs = ipairs
local cid_air, cid_lava_source

-- local prin = false

if core and core.get_content_id then
	cid_air = core.CONTENT_AIR
	if core.register_on_mods_loaded then
		core.register_on_mods_loaded (function ()
			cid_lava_source = core.get_content_id ("mcl_core:lava_source")
		end)
	else
		cid_lava_source = core.get_content_id ("mcl_core:lava_source")
	end
else
	cid_air = 0
	cid_lava_source = 4
end

local aquifer = {
	preset = nil,
	sea_level = nil,
	cid_default_fluid = nil,
}

-- Default Overworld aquifer.
local mathmin = math.min
local LAVA_FLOODING_THRESHOLD = -54

function aquifer:get_node (x, y, z, density)
	local sea_level = self.sea_level
	-- This statement is harmless in the Nether, as the nether
	-- originates at Y=0.
	if y < mathmin (LAVA_FLOODING_THRESHOLD, sea_level) then
		return cid_lava_source, 0
	elseif y < sea_level then
		return self.cid_default_fluid, 0
	end
	return cid_air, 0
end

function aquifer:reseat (min_x, min_y, min_z)
end

function aquifer:initialize (preset)
	self.sea_level = preset.sea_level
	if core then
		self.cid_default_fluid = core.get_content_id (preset.default_fluid)
		self.cid_default_block = core.get_content_id (preset.default_block)
	else
		self.cid_default_block = 3
		self.cid_default_fluid = 1
	end
end

function mcl_levelgen.create_default_aquifer (preset)
	local aquifer = table.copy (aquifer)
	aquifer:initialize (preset)
	return aquifer
end

mcl_levelgen.aquifer = aquifer

------------------------------------------------------------------------
-- Noise-based aquifers.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/chunk/AquiferSampler.Impl.html
------------------------------------------------------------------------

local CENTER_VARIABILITY_XZ = 10
local CENTER_VARIABILITY_Y = 9

local GRID_UNIT_XZ = 16
local GRID_UNIT_Y = 12

local CHUNK_POS_OFFSETS = {
	{0, 0},
	{-2, -1},
	{-1, -1},
	{0, -1},
	{1, -1},
	{-3, 0},
	{-2, 0},
	{-1, 0},
	{1, 0},
	{-2, 1},
	{-1, 1},
	{0, 1},
	{1, 1},
}

local floor = math.floor
local mathmax = math.max
local abs = math.abs

local localized_aquifer = table.merge (aquifer, {
	content_cache = {},
	location_cache = {},
	terrain_generator = nil,
})

-- These functions are manually open coded in `get_node' for otherwise
-- they tend to be blacklisted and produce trace aborts at the most
-- inopportune moments.
local function togrid_xz (pos)
	return floor (pos / GRID_UNIT_XZ)
end

local function togrid_y (pos)
	return floor (pos / GRID_UNIT_Y)
end

local bor = bit.bor
local band = bit.band
local lshift = bit.lshift
local arshift = bit.arshift

local function longhash (x, y, z)
	return bor (band (x, 0x3ff), lshift (band (y, 0x3ff), 10),
		    lshift (band (z, 0x3ff), 20))
end

local function unhash (pos)
	return arshift (lshift (pos, 22), 22),
		arshift (lshift (pos, 12), 22),
		arshift (lshift (pos, 2), 22)
end

local XZMASK = 0xf
local YMASK = 0x3f

local function gindex (xgrid, ygrid, zgrid)
	return bor (bor (lshift (band (xgrid, XZMASK), 10),
			 lshift (band (ygrid, YMASK), 4)),
		    band (zgrid, XZMASK)) + 1
end

function mcl_levelgen.create_localized_aquifer (preset, terrain_generator)
	local aquifer = table.copy (localized_aquifer)
	aquifer:initialize (preset)

	local grid_size_horiz = togrid_xz (terrain_generator.chunksize) + 2

	-- Minecraft derives grid positions from absolute coordinates,
	-- but the extents of a mapblock that is being emerged and the
	-- bottommost Y position of the level are liable not to be
	-- divisible by GRID_UNIT_Y.  The chunk size must therefore be
	-- adjusted accordingly.
	local base = preset.min_y % GRID_UNIT_Y
	local grid_size_vert = togrid_y (base + terrain_generator.level_height) + 3
	aquifer.y_base = base
	aquifer.xz_size = grid_size_horiz
	aquifer.y_size = grid_size_vert
	local cache_size = gindex (grid_size_horiz - 1, grid_size_vert - 1,
				   grid_size_horiz - 1)
	aquifer.cache_size = cache_size

	if grid_size_horiz > XZMASK + 1 or grid_size_vert > YMASK + 1 then
		error ("Grid coordinates are not representable; reduce level "
		       .. "or chunk size")
	end

	local content_cache = {}
	local location_cache = {}
	for i = 1, cache_size do
		content_cache[i] = false
		location_cache[i] = false
	end
	aquifer.content_cache = content_cache
	aquifer.location_cache = location_cache

	aquifer.cid_default_block = terrain_generator.cid_default_block
	aquifer.cid_default_fluid = terrain_generator.cid_default_fluid

	local factory = preset.factory ("minecraft:aquifer"):fork_positional ()
	aquifer.rng = factory:create_reseedable ()
	aquifer.terrain_generator = terrain_generator
	aquifer.erosion = terrain_generator.erosion
	aquifer.depth = terrain_generator.depth
	aquifer.floodedness = terrain_generator.floodedness
	aquifer.spread = terrain_generator.fluid_spread
	aquifer.lava = terrain_generator.lava_noise
	aquifer.barrier = terrain_generator.barrier_noise
	return aquifer
end

--- XXX: These values are upvalues to avoid requiring a `self'
--- parameter in `localized_aquifier:get_node' and its callees.
local x_origin
local z_origin
local y_origin
local x_grid_origin
local z_grid_origin
local y_grid_origin
local location_cache
local content_cache
local cid_default_fluid
local cid_default_block
local rng
local sea_level
local lavanoise
local erosion
local depth
local floodedness
local spread
local barrier
local terrain_generator

-- local thit = 0
-- local tmiss = 0
-- local tm = 0

function localized_aquifer:reseat (min_x, min_y, min_z)
	-- print (thit, tmiss, string.format ("%.2f%%", thit / (thit + tmiss) * 100))
	-- thit, tmiss = 0, 0
	x_origin = min_x - GRID_UNIT_XZ
	z_origin = min_z - GRID_UNIT_XZ
	-- MIN_Y must be relative to the level origin.
	y_origin = min_y - min_y % GRID_UNIT_Y - GRID_UNIT_Y
	assert (x_origin % GRID_UNIT_XZ == 0)
	assert (z_origin % GRID_UNIT_XZ == 0)
	assert (y_origin % GRID_UNIT_Y  == 0)
	-- print (string.format ("%.2f", (tm + 0.5) * 1000))
	-- tm = 0

	x_grid_origin = togrid_xz (min_x) - 1
	z_grid_origin = togrid_xz (min_z) - 1
	y_grid_origin = togrid_y (min_y - min_y % GRID_UNIT_Y) - 1

	location_cache = self.location_cache
	content_cache = self.content_cache
	for i = 1, self.cache_size do
		location_cache[i] = false
		content_cache[i] = false
	end
	terrain_generator = self.terrain_generator
	cid_default_block = self.cid_default_block
	cid_default_fluid = self.cid_default_fluid
	rng = self.rng
	sea_level = self.sea_level
	lavanoise = self.lava
	erosion = self.erosion
	depth = self.depth
	floodedness = self.floodedness
	spread = self.spread
	barrier = self.barrier
end

local huge = math.huge
local minuscule_liquid_level = -32768

local function flood_stochastically (x, y, z, min_surface_top)
	-- These are (global) aquifer section coordinates rather than
	-- aquifer grid positions.
	local x_section = floor (x / 16)
	local y_section = floor (y / 40)
	local z_section = floor (z / 16)
	local section_center = y_section * 40 + 20

	-- Spread noise is sampled once-per-section.
	-- https://gist.github.com/jacobsjo/0ce1f9d02e5c3e490e228ac5ad810482#Randomized_fluid_level
	-- This was overlooked when aquifers were initially
	-- implemented and occasioned hours of fruitless debugging.
	local noise_value
		= spread (x_section, y_section, z_section) * 10.0
	local level = floor (noise_value / 3) * 3
	-- print (x_section, y_section, z_section, level)
	return mathmin (min_surface_top - 8, section_center + level)
end

local parameters_adjoin_deep_dark = mcl_levelgen.parameters_adjoin_deep_dark

local function local_surface_level (x, y, z, sea_level,
				    min_surface_top, submerged_p)
	local erosion, depth = erosion (x, y, z), depth (x, y, z)
	if parameters_adjoin_deep_dark (erosion, depth) then
		return minuscule_liquid_level
	end

	local depth = min_surface_top - y
	local surface_proximity
	if submerged_p then
		local surface_proximity_unscaled = mathmin (mathmax (depth, 0), 64)
		surface_proximity = 1.0 - surface_proximity_unscaled / 64
	else
		surface_proximity = 0.0
	end
	local floodedness = mathmin (mathmax (floodedness (x, y, z),
					      -1.0), 1.0)
	-- if prin then
	-- 	print ("surfaceProximity: ", surface_proximity)
	-- 	print ("floodedness: ", floodedness)
	-- end
	local flood_threshold
		= -0.3 + (1.0 - surface_proximity) * (0.8 + 0.3)
	local stochastic_threshold
		= -0.8 + (1.0 - surface_proximity) * (0.4 + 0.8)

	if floodedness > flood_threshold then
		-- Flood completely.
		return sea_level
	elseif floodedness > stochastic_threshold then
		-- Stochastic flooding.
		return flood_stochastically (x, y, z, min_surface_top)
	else
		-- if prin then
		-- 	print ("no flooding")
		-- end
		-- Don't flood at all.
		return minuscule_liquid_level
	end
end

local LAVA_GENERATION_THRESHOLD = -10

-- Values are the surface height of this fluid and whether it must be
-- lava.
local function compute_fluid_content (x, y, z)
	local sea_level = sea_level
	local y_above = y + GRID_UNIT_Y
	local y_below = y - GRID_UNIT_Y
	local this_pos_submerged_p = false
	local terrain = terrain_generator
	local min_surface_top = huge

	-- Sample chunks around this position to measure the lowest
	-- surface level in the vicinity.  If any surface is submerged
	-- and beneath sea level
	for i, offset in ipairs (CHUNK_POS_OFFSETS) do
		local sx = x + offset[1] * 16
		local sz = z + offset[2] * 16
		local surface = terrain:get_preliminary_surface_level (sx, sz)
		local surface_pos = surface + 8

		-- print (sx, sz, surface, y_below, y_above)

		-- If the surface is completely beneath the current
		-- position, return the default sea level.
		if i == 1 and y_below > surface_pos then
			return sea_level, false
		end

		-- Likewise if the surface is below sea level and
		-- overlaps a certain vertical interval centered
		-- around the current position.
		local sample_submerged = y_above > surface_pos
		if sample_submerged or i == 1 then
			if surface_pos < sea_level then
				if i == 1 then
					this_pos_submerged_p = true
				end

				if sample_submerged then
					return sea_level, false
				end
			end
		end

		min_surface_top = mathmin (min_surface_top, surface_pos)
	end

	-- if prin then
	-- 	print (" ===> " .. min_surface_top - 8 .. " " .. tostring (this_pos_submerged_p))
	-- end
	local new_surface_level
		= local_surface_level (x, y, z, sea_level,
				       min_surface_top,
				       this_pos_submerged_p)

	-- Decide whether to return lava.
	if new_surface_level ~= huge
		and new_surface_level < LAVA_GENERATION_THRESHOLD then
		local xsection = floor (x / 64)
		local ysection = floor (y / 40)
		local zsection = floor (z / 64)
		local lava_sample = lavanoise (xsection, ysection, zsection)
		if abs (lava_sample) > 0.3 then
			return new_surface_level, true
		end
	end
	return new_surface_level, false
end

local function encode_fluid_content (level, lava)
	return bor (level + 0x8000, lava and 0x10000 or 0)
end

local function decode_fluid_content (data)
	return band (data, 0xffff) - 0x8000, band (data, 0x10000) ~= 0
end

local function get_fluid_content (x, y, z, gindex)
	local val = content_cache[gindex]
	if val then
		return decode_fluid_content (val)
	end
	local surface_level, lava = compute_fluid_content (x, y, z)
	val = encode_fluid_content (surface_level, lava)
	content_cache[gindex] = val
	return surface_level, lava
end

local SQR_5 = 5 * 5

local function closeness (d1, d2)
	return 1.0 - abs (d2 - d1) / SQR_5
end

local function evaluate (depth, lava, y)
	if y < depth then
		return (lava or y < LAVA_FLOODING_THRESHOLD)
			and cid_lava_source or cid_default_fluid, 0
	else
		return cid_air, 0
	end
end

local function get_pressure (x, y, z, level_closest, lava_closest,
			     level_avg, lava_avg)
	-- One or more aquifers are inactive.
	if not (level_closest >= level_avg and level_avg > y)
	-- or both liquids are of identical types.
		or y < LAVA_FLOODING_THRESHOLD
		or lava_closest == lava_avg then
		local level_diff = abs (level_closest - level_avg)
		if level_diff == 0.0 then
			return 0.0
		end
		local center = 0.5 * (level_closest + level_avg)
		local offset_here = y + 0.5 - center
		local raw_pressure

		if offset_here > 0.0 then
			local half_diff = level_diff / 2.0
			local dist_center = half_diff - abs (offset_here)
			if dist_center > 0.0 then
				raw_pressure = dist_center / 1.5
			else
				raw_pressure = dist_center / 2.5
			end
		else
			local half_diff = level_diff / 2.0
			local dist_center = half_diff - abs (offset_here)
			local shifted = 3.0 + dist_center
			if shifted > 0.0 then
				raw_pressure = shifted / 3.0
			else
				raw_pressure = shifted / 10.0
			end
		end

		local barrier_val = 0.0
		if raw_pressure >= -2.0 and raw_pressure <= 2.0 then
			barrier_val = barrier (x, y, z)
		end
		return 2.0 * (barrier_val + raw_pressure)
	end

	-- Return the default pressure if the liquid types differ and
	-- neither is air.
	return 2.0
end

local offsets = {
	0,
	-1,
	0,
	0,
	-1,
	1,
	0,
	0,
	0,
	0,
	0,
	1,
	0,
	1,
	0,
	0,
	1,
	1,
	1,
	-1,
	0,
	1,
	-1,
	1,
	1,
	0,
	0,
	1,
	0,
	1,
	1,
	1,
	0,
	1,
	1,
	1,
}

local distbuf
local aquifer
local DB_HUGE

if mcl_levelgen.use_ffi then
	local ffi = require ("ffi")
	aquifer = mcl_levelgen.ffi_ns
	ffi.cdef ([[
extern void pick_grid_positions_1 (int *, int, int, int);
]])
	-- "If no initializers are given, the object is filled with
	-- zero bytes."
	distbuf = ffi.new ("int[19]")
	DB_HUGE = ffi.cast ("int", 0x7fffffff)
	local c_offsets = ffi.new ("int[37]")
	for i = 1, 36 do
		c_offsets[i] = offsets[i]
	end
	offsets = c_offsets
else
	distbuf = { 0, 0, 0, 0, 0, 0 }
	for i = 1, 12 do
		distbuf[#distbuf] = 0
	end
	DB_HUGE = huge
	aquifer = nil
end

local dist_closest = 1
local dist_average = 2
local dist_furthest = 3
local pos_closest = 4
local pos_average = 5
local pos_furthest = 6

local function fix_distances (distbuf, pos, dx, dy, dz)
	local d = dx * dx + dy * dy + dz * dz

	if distbuf[dist_closest] >= d then
		distbuf[pos_furthest] = distbuf[pos_average]
		distbuf[dist_furthest] = distbuf[dist_average]
		distbuf[pos_average] = distbuf[pos_closest]
		distbuf[dist_average] = distbuf[dist_closest]
		distbuf[pos_closest] = pos
		distbuf[dist_closest] = d
	elseif distbuf[dist_average] >= d then
		distbuf[pos_furthest] = distbuf[pos_average]
		distbuf[dist_furthest] = distbuf[dist_average]
		distbuf[pos_average] = pos
		distbuf[dist_average] = d
	elseif distbuf[dist_furthest] >= d then
		distbuf[pos_furthest] = pos
		distbuf[dist_furthest] = d
	end
end

local function pick_grid_positions (distbuf, rx, ry, rz)
	local offsets = offsets
	local xstart = arshift (rx - 5, 4)
	local ystart = floor ((ry + 1) / 12)
	local zstart = arshift (rz - 5, 4)
	local j = 7
	for i = 1, 36, 3 do
		local xgrid = xstart + offsets[i]
		local ygrid = ystart + offsets[i + 1]
		local zgrid = zstart + offsets[i + 2]
		local index = gindex (xgrid, ygrid, zgrid)
		local pos = location_cache[index]
		if not pos then
			local xrnd = xgrid + x_grid_origin
			local yrnd = ygrid + y_grid_origin
			local zrnd = zgrid + z_grid_origin
			rng:reseed_positional (xrnd, yrnd, zrnd)

			local x = rng:next_within (CENTER_VARIABILITY_XZ)
			local lx = xgrid * GRID_UNIT_XZ + x
			local y = rng:next_within (CENTER_VARIABILITY_Y)
			local ly = ygrid * GRID_UNIT_Y + y
			local z = rng:next_within (CENTER_VARIABILITY_XZ)
			local lz = zgrid * GRID_UNIT_XZ + z
			pos = longhash (lx, ly, lz)
			location_cache[index] = pos
		end
		distbuf[j] = pos
		j = j + 1
	end

	if aquifer then
		aquifer.pick_grid_positions_1 (distbuf, rx, ry, rz)
	else
		-- Extract the array bounds check from the loop below.
		-- The loop body is practically never reached, as each
		-- condition in fix_distances but the first
		-- encountered by the jit winds up returning to its
		-- prologue.

		for j = 7, 18 do
			local lx, ly, lz = unhash (distbuf[j])
			fix_distances (distbuf, distbuf[j], lx - rx, ly - ry, lz - rz)
		end
	end
end

local function depth_at_id (posid)
	local lx, ly, lz = unhash (distbuf[posid])
	local gx, gy, gz = floor (lx / 16), floor (ly / 12), floor (lz / 16)
	local index = gindex (gx, gy, gz)
	return get_fluid_content (lx + x_origin, ly + y_origin,
				  lz + z_origin, index)
end

function localized_aquifer.get_node (_, x, y, z, density)
	if y < LAVA_FLOODING_THRESHOLD then
		return cid_lava_source, 0
	else
		local distbuf = distbuf
		distbuf[dist_closest] = DB_HUGE
		distbuf[dist_average] = DB_HUGE
		distbuf[dist_furthest] = DB_HUGE

		-- Select the three closest positions out of 2x3x2
		-- random positions selected from around the center of
		-- this grid coordinate.
		-- local clock = os.clock ()
		pick_grid_positions (distbuf, x - x_origin, y - y_origin, z - z_origin)
		-- tm = tm + os.clock () - clock

		-- Ascertain the fluid content of the nearest position.
		local depth, lava = depth_at_id (pos_closest)
		local d = closeness (distbuf[dist_closest], distbuf[dist_average])

		-- If the nearest aquifer center is too distant from
		-- the second closest to be significant, return the
		-- fluid type derived from the former.
		if (d <= 0.0)
			-- Or if water but one block above lava level
			or (not lava and y == LAVA_FLOODING_THRESHOLD) then
			return evaluate (depth, lava, y)
		else
			-- Otherwise, calculate whether the pressure
			-- differential between the current aquifer
			-- position and its nearest neighbors is
			-- sufficiently great to prompt barrier
			-- formation.
			local avg_depth, avg_lava = depth_at_id (pos_average)
			local pressure
				= get_pressure (x, y, z, depth, lava,
						avg_depth, avg_lava)
			if density + pressure * d > 0.0 then
				-- Generate a barrier.
				return cid_default_block, 0
			end

			-- Repeat the process with the remaining
			-- neighbors.
			local d0 = closeness (distbuf[dist_closest], distbuf[dist_furthest])
			local d1 = closeness (distbuf[dist_average], distbuf[dist_furthest])
			if d0 > 0.0 or d1 > 0.0 then
				local far_depth, far_lava = depth_at_id (pos_furthest)
				if d0 > 0.0 then
					local pressure = get_pressure (x, y, z, depth, lava,
								       far_depth, far_lava)
					if density + d * d0 * pressure > 0.0 then
						-- Generate a barrier.
						return cid_default_block, 0
					end
				end

				if d1 > 0.0 then
					local pressure = get_pressure (x, y, z, avg_depth, avg_lava,
								       far_depth, far_lava)
					if density + d * d1 * pressure > 0.0 then
						-- Generate a barrier.
						return cid_default_block, 0
					end
				end
			end
			return evaluate (depth, lava, y)
		end
	end
end

-- if true then
-- 	mcl_levelgen.make_surface_system = function () end
-- 	local seed = mcl_levelgen.ull (0, 3228473)
-- 	local level = mcl_levelgen.make_overworld_preset (seed)
-- 	local terrain = mcl_levelgen.make_terrain_generator (level, 80)

-- 	terrain.aquifer:reseat (-64, -64, -192)
-- end
