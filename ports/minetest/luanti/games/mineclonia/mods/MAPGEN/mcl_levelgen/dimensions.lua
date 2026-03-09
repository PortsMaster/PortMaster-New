local ipairs = ipairs
local mathmax = math.max
local mathmin = math.min
local floor = math.floor

------------------------------------------------------------------------
-- Dimension registration and initialization.
------------------------------------------------------------------------

local registered_dimensions = {}
mcl_levelgen.registered_dimensions = registered_dimensions

function mcl_levelgen.register_dimension (level_id, level_callbacks)
	-- Permit dimensions to be redefined.
	-- assert (not registered_dimensions[level_id])
	registered_dimensions[level_id] = level_callbacks
end

------------------------------------------------------------------------
-- Dimension initialization.
------------------------------------------------------------------------

local all_dimensions = {}
local dimensions_sorted = {}

function mcl_levelgen.get_dimension (id)
	return all_dimensions[id]
end

function mcl_levelgen.for_each_dimension ()
	return ipairs (dimensions_sorted)
end

local mt_chunksize = mcl_levelgen.mt_chunksize
local ychunksize = mt_chunksize.y * 16
local chunksize = mt_chunksize.x * 16

function mcl_levelgen.initialize_dimensions (seed)
	local dims = {}

	for id, desc in pairs (registered_dimensions) do
		local preset = desc:create_preset (seed)
		local dim = {}

		-- Extents of level in the global coordinate system.
		dim.y_global = desc.y_global
		dim.y_global_block = floor (desc.y_global) / 16
		dim.y_max = desc.y_global + preset.height - 1

		-- Difference between y_global and the preset's y_min;
		-- i.e., Y + DESC.y_offset translates a global height
		-- into the level's coordinate system, while Y_LEVEL -
		-- DESC.y_offset restores it to the original.
		dim.y_offset = preset.min_y - desc.y_global
		dim.preset = preset
		dim.id = id
		dim.data_namespace = desc.data_namespace
		dim.no_lighting = desc.no_lighting
			or mcl_levelgen.lighting_disabled
		all_dimensions[id] = dim
		table.insert (dims, dim)
	end

	table.sort (dims, function (a, b)
		return a.y_global < b.y_global
	end)

	for i = 2, #dims do
		local y_prev = dims[i - 1].y_global + dims[i - 1].y_max
		assert (y_prev <= dims[i].y_global)
	end

	dimensions_sorted = dims
	mcl_levelgen.dimensions_sorted = dims

	local overworld = mcl_levelgen.get_dimension ("mcl_levelgen:overworld")
	mcl_levelgen.overworld_preset = overworld.preset

	if not mcl_levelgen.verbose then
		return
	end
	for _, dim in ipairs (dims) do
		print (string.format ([[Dimension %s:
Level minimum layer: %d
Level height: %d
Level offset: %d
Global minimum layer: %d
Global maximum layer: %d]],
				      dim.id, dim.preset.min_y,
				      dim.preset.height, dim.y_offset,
				      dim.y_global, dim.y_max))
	end
end

function mcl_levelgen.initialize_terrain (dim)
	if dim then
		dim.terrain = mcl_levelgen.make_terrain_generator (dim.preset,
								   chunksize,
								   ychunksize)
		return
	end

	for _, dim in ipairs (dimensions_sorted) do
		dim.terrain = mcl_levelgen.make_terrain_generator (dim.preset,
								   chunksize,
								   ychunksize)
	end
end

local function dim_intersect_p (dim, y1, y2)
	return y2 >= dim.y_global and y1 <= dim.y_max
end

------------------------------------------------------------------------
-- Level querying.
------------------------------------------------------------------------

local i, y1, y2

local function dims_intersecting_iterator ()
	local dims = dimensions_sorted
	while i <= #dims do
		local dim = dimensions_sorted[i]
		i = i + 1

		if dim_intersect_p (dim, y1, y2) then
			local y1 = mathmax (y1, dim.y_global)
			local y2 = mathmin (y2, dim.y_max)
			local y_start = y1 + dim.y_offset
			local y_end = y2 + dim.y_offset
			return y1, y2, y_start, y_end, dim
		end
	end
	return nil
end

function mcl_levelgen.dims_intersecting (y1i, y2i)
	i, y1, y2 = 1, y1i, y2i
	return dims_intersecting_iterator
end

function mcl_levelgen.dimension_at_layer (y)
	for _, dim in ipairs (dimensions_sorted) do
		if y >= dim.y_global and y <= dim.y_max then
			return dim
		end
	end

	return nil
end

local dimension_at_layer = mcl_levelgen.dimension_at_layer

-- Convert from Luanti to Minecraft positions and vice versa.  Value
-- is nil if there is no dimension at this position.
function mcl_levelgen.conv_pos (v)
	local dim = dimension_at_layer (v.y)

	if dim then
		-- Minecraft's Z axis is inverted such that North is
		-- -Z.
		--
		-- This function converts a Luanti position to the
		-- equivalent that is considered by the level
		-- generator.  As it is imperative for performance
		-- that level generator chunks should be aligned with
		-- Minetest MapBlocks, Luanti positions are further
		-- offset along the Z axis by a delta of -1.
		return vector.new (v.x, v.y + dim.y_offset, -v.z - 1), dim
	end
	return nil
end

function mcl_levelgen.conv_pos_raw (v)
	local dim = dimension_at_layer (v.y)

	if dim then
		-- Minecraft's Z axis is inverted such that North is
		-- -Z.
		--
		-- This function converts a Luanti position to the
		-- equivalent that is considered by the level
		-- generator.  As it is imperative for performance
		-- that level generator chunks should be aligned with
		-- Minetest MapBlocks, Luanti positions are further
		-- offset along the Z axis by a delta of -1.
		return v.x, v.y + dim.y_offset, -v.z - 1, dim
	end
	return nil
end

function mcl_levelgen.conv_pos_dimension (v)
	local dim = dimension_at_layer (v.y)

	if dim then
		return v.x, v.y - dim.y_global, v.z, dim
	end
	return nil
end

------------------------------------------------------------------------
-- Default dimensions.
------------------------------------------------------------------------

mcl_levelgen.register_dimension ("mcl_levelgen:overworld", {
	y_global = mcl_vars.mg_overworld_min,
	data_namespace = 0,
	create_preset = function (self, seed)
		local use_large_biomes = mcl_levelgen.use_large_biomes
		return mcl_levelgen.make_overworld_preset (seed, use_large_biomes)
	end,
	no_lighting = false,
})

mcl_levelgen.register_dimension ("mcl_levelgen:nether", {
	y_global = mcl_vars.mg_nether_min,
	data_namespace = 1,
	create_preset = function (self, seed)
		return mcl_levelgen.make_nether_preset (seed)
	end,
	no_lighting = false,
})

mcl_levelgen.register_dimension ("mcl_levelgen:end", {
	y_global = mcl_vars.mg_end_min,
	data_namespace = 2,
	create_preset = function (self, seed)
		return mcl_levelgen.make_end_preset (seed)
	end,
	no_lighting = true,
})
