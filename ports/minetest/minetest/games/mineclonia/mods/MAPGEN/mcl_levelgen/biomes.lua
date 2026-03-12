------------------------------------------------------------------------
-- Biomes.
--
-- Biomes in a level are provided by one or more biome sources that
-- are evaluated on "Quart positions," i.e., 4x4 cubical regions.
--
-- Overworld biomes are assigned by evaluating a collection of density
-- functions and locating the closest entry in a list of biomes
-- identified by ranges of values expected of those density functions.
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Biome position utilities.
------------------------------------------------------------------------

local ipairs = ipairs
local tonumber = tonumber
local floor = math.floor
local ceil = math.ceil
local rshift = bit.rshift
local arshift = bit.arshift
local lshift = bit.lshift
local band = bit.band
local bor = bit.bor
local insert = table.insert

local function toquart (x)
	return arshift (x, 2)
end

local function inquart (x)
	return band (x, 3)
end

local function toblock (x)
	return lshift (x, 2)
end

mcl_levelgen.toquart = toquart
mcl_levelgen.inquart = inquart
mcl_levelgen.toblock = toblock

local function verbose_print (...)
	if mcl_levelgen.verbose then
		print (...)
	end
end

------------------------------------------------------------------------
-- Biome parameter accessors.
------------------------------------------------------------------------

local function rtz (n)
	if n < 0 then
		return ceil (n)
	end
	return floor (n)
end

local function temperature (x)
	return x[1]
end

local function humidity (x)
	return x[2]
end

local function continentalness (x)
	return x[3]
end

local function erosion (x)
	return x[4]
end

local function depth (x)
	return x[5]
end

local function weirdness (x)
	return x[6]
end

local function offset (x)
	return x[7]
end

local function quantize (x)
	return rtz (x * 10000)
end

local function build_biome_extents (temperature_min,
				    temperature_max,
				    humidity_min,
				    humidity_max,
				    continentalness_min,
				    continentalness_max,
				    erosion_min,
				    erosion_max,
				    depth_min,
				    depth_max,
				    weirdness_min,
				    weirdness_max,
				    offset)
	assert (temperature_min <= temperature_max)
	assert (humidity_min <= humidity_max)
	assert (continentalness_min <= continentalness_max)
	assert (erosion_min <= erosion_max)
	assert (depth_min <= depth_max)
	assert (weirdness_min <= weirdness_max)
	return {
		{
			quantize (temperature_min),
			quantize (temperature_max),
		},
		{
			quantize (humidity_min),
			quantize (humidity_max),
		},
		{
			quantize (continentalness_min),
			quantize (continentalness_max),
		},
		{
			quantize (erosion_min),
			quantize (erosion_max),
		},
		{
			quantize (depth_min),
			quantize (depth_max),
		},
		{
			quantize (weirdness_min),
			quantize (weirdness_max),
		},
		{
			quantize (offset),
			quantize (offset),
		}
	}
end

-- Redefine a number of functions after they are captured by
-- `build_biome_extents' to avoid blacklisting, as they are referenced
-- extensively from code that admits of compilation.
local function rtz (n)
	if n < 0 then
		return ceil (n)
	end
	return floor (n)
end

local function quantize (x)
	return rtz (x * 10000)
end

mcl_levelgen.quantize = quantize

local function unquantize (x)
	return x / 10000.0
end

mcl_levelgen.unquantize = unquantize

------------------------------------------------------------------------
-- R-Tree data structure.
------------------------------------------------------------------------

local M = 6 -- 6 children per node.
local NDIM = 7 -- 7 dimensions.
local abs = math.abs

-- Node format:
-- {
-- 	-- Extents of bounding box.
-- 	extents = nil,
--
-- 	-- M children, or nil if leaf node.
-- 	children = nil,
--
-- 	-- Value, or nil if subtree.
-- 	value = nil,
-- }

local function avg_distance (extents)
	local x = 0

	x = x + abs (rtz ((temperature (extents)[1] + temperature (extents)[2]) / 2))
	x = x + abs (rtz ((humidity (extents)[1] + humidity (extents)[2]) / 2))
	x = x + abs (rtz ((continentalness (extents)[1] + continentalness (extents)[2]) / 2))
	x = x + abs (rtz ((erosion (extents)[1] + erosion (extents)[2]) / 2))
	x = x + abs (rtz ((depth (extents)[1] + depth (extents)[2]) / 2))
	x = x + abs (rtz ((weirdness (extents)[1] + weirdness (extents)[2]) / 2))
	x = x + abs (rtz ((offset (extents)[1] + offset (extents)[2]) / 2))
	return x
end

local function cost_extents (extents)
	local x = 0

	x = x + abs (temperature (extents)[1] - temperature (extents)[2])
	x = x + abs (humidity (extents)[1] - humidity (extents)[2])
	x = x + abs (continentalness (extents)[1] - continentalness (extents)[2])
	x = x + abs (erosion (extents)[1] - erosion (extents)[2])
	x = x + abs (depth (extents)[1] - depth (extents)[2])
	x = x + abs (weirdness (extents)[1] - weirdness (extents)[2])
	x = x + abs (offset (extents)[1] - offset (extents)[2])
	return x
end

local min = math.min
local max = math.max

local function vol_extents (extents)
	local x

	x = max (0.00001, abs (temperature (extents)[1] - temperature (extents)[2]))
	x = x * max (0.00001, abs (humidity (extents)[1] - humidity (extents)[2]))
	x = x * max (0.00001, abs (continentalness (extents)[1] - continentalness (extents)[2]))
	x = x * max (0.00001, abs (erosion (extents)[1] - erosion (extents)[2]))
	x = x * max (0.00001, abs (weirdness (extents)[1] - weirdness (extents)[2]))
	return x
end

local function extend_range (r1, r2)
	if not r1 then
		return r2
	end
	local min1, max1 = unpack (r1)
	local min2, max2 = unpack (r2)
	return { min (min1, min2), max (max1, max2), }
end

local function compute_extents (children)
	local new_temp, new_humidity, new_continentalness
	local new_erosion, new_depth, new_weirdness, new_offset

	for _, node in ipairs (children) do
		local extents = node.extents
		new_temp
			= extend_range (new_temp, temperature (extents))
		new_humidity
			= extend_range (new_humidity, humidity (extents))
		new_continentalness
			= extend_range (new_continentalness, continentalness (extents))
		new_erosion
			= extend_range (new_erosion, erosion (extents))
		new_depth
			= extend_range (new_depth, depth (extents))
		new_weirdness
			= extend_range (new_weirdness, weirdness (extents))
		new_offset
			= extend_range (new_offset, offset (extents))
	end
	return {
		new_temp, new_humidity, new_continentalness,
		new_erosion, new_depth, new_weirdness, new_offset,
	}
end

local function sort_by_dim (nodes, first_dim, ignore_sign)
	local function compare (a, b)
		for i = 1, NDIM do
			local x = (i + first_dim - 2) % NDIM + 1
			local range_a = a.extents[x]
			local range_b = b.extents[x]
			local center_a = rtz ((range_a[1] + range_a[2]) / 2)
			local center_b = rtz ((range_b[1] + range_b[2]) / 2)
			if ignore_sign then
				center_a = abs (center_a)
				center_b = abs (center_b)
			end
			if center_a < center_b then
				return true
			elseif center_a > center_b then
				return false
			end
			-- Proceed to the next value.
		end
		return false
	end
	table.sort (nodes, compare)
end

local pow = math.pow
local log = math.log
local LOG_M = log (M)

local function logm (x)
	return log (x) / LOG_M
end

local function construct_subtrees (nodes)
	local children, subtrees = {}, {}
	-- children_of_subtree is such that the value returned will
	-- never hold more than M subtrees.
	local children_per_subtree
		= floor (pow (M, floor (logm (#nodes - 0.01))))
	-- print (children_per_subtree, #nodes)

	for _, node in ipairs (nodes) do
		local n = #children
		children[n + 1] = node
		if n + 1 == children_per_subtree then
			local extents = compute_extents (children)
			table.insert (subtrees, {
				extents = extents,
				children = children,
			})
			children = {}
		end
	end

	-- If any children remain, insert them into subtrees.
	if #children > 0 then
		local extents = compute_extents (children)
		table.insert (subtrees, {
			extents = extents,
			children = children,
		})
	end
	return subtrees
end

local function subtree_cost (subtrees)
	local cost = 0
	for _, item in ipairs (subtrees) do
		cost = cost + cost_extents (item.extents)
	end
	return cost
end

local function pack1 (extents)
	local min = extents[1]
	local max = extents[2]
	assert (min <= 32767 and min >= -32768)
	assert (max <= 32767 and max >= -32768)
	return bor (lshift (min, 16), max + 32768)
end

local function pack_extents_1 (extents)
	return {
		pack1 (extents[1]),
		pack1 (extents[2]),
		pack1 (extents[3]),
		pack1 (extents[4]),
		pack1 (extents[5]),
		pack1 (extents[6]),
		pack1 (extents[7]),
	}
end

local function pack1_quantize (extents)
	local min = quantize (extents[1])
	local max = quantize (extents[2])
	assert (min <= 32767 and min >= -32768)
	assert (max <= 32767 and max >= -32768)
	return bor (lshift (min, 16), max + 32768)
end

local function pack_extents_quantize (extents)
	return {
		pack1_quantize (extents[1]),
		pack1_quantize (extents[2]),
		pack1_quantize (extents[3]),
		pack1_quantize (extents[4]),
		pack1_quantize (extents[5]),
		pack1_quantize (extents[6]),
		pack1_quantize (extents[7]),
	}
end

mcl_levelgen.pack_extents_quantize = pack_extents_quantize

local function pack_extents (rtree)
	local new_extents = pack_extents_1 (rtree.extents)
	if rtree.children then
		local children = {}
		for _, child in ipairs (rtree.children) do
			table.insert (children, pack_extents (child))
		end
		return {
			extents = new_extents,
			children = children,
		}
	else
		assert (rtree.value)
		return {
			extents = new_extents,
			value = rtree.value,
		}
	end
end

local function build_rtree_internal (nodes)
	if #nodes == 0 then
		error ("A bucket must contain children")
	elseif #nodes == 1 then
		return nodes[1]
	elseif #nodes <= M then
		-- Sort nodes by distance from origin.
		table.sort (nodes, function (a, b)
			return avg_distance (a.extents)
				< avg_distance (b.extents)
		end)
		return {
			sorting = -1,
			extents = compute_extents (nodes),
			children = nodes,
		}
	else
		local best_cost, dimid, children

		-- Attempt to sort and bucketize NODES by their
		-- centerpoints along each dimension and select that
		-- dimension which produces the least expansive search
		-- area when initially compared by.

		for firstdim = 1, NDIM do
			sort_by_dim (nodes, firstdim, false)
			local subtrees = construct_subtrees (nodes)
			local cost = subtree_cost (subtrees)
			if not best_cost or cost < best_cost then
				dimid = firstdim
				best_cost = cost
				children = subtrees
			end
		end

		-- Order subtrees by distance from the origin.
		sort_by_dim (children, dimid, true)

		-- Recurse into subtrees, also dividing them if need
		-- be.
		local realchildren = {}
		for i, child in ipairs (children) do
			realchildren[i] = build_rtree_internal (child.children)
		end
		return {
			sorting = dimid,
			extents = compute_extents (realchildren),
			children = realchildren,
		}
	end
end

local function build_rtree (nodes)
	local original = build_rtree_internal (nodes)
	if mcl_levelgen.verbose then
		verbose_print ("** Biome tree and bucket sorting strategies:")
		mcl_levelgen.print_rtree (original, 0)
	end
	return pack_extents (original)
end

local function distance_to_value (range, value)
	local dmax = tonumber (value - band (range, 0xffff) + 32768)
	local dmin = tonumber (arshift (range, 16) - value)
	-- For consistency with Minecraft, this comparison function
	-- treats the upper bounds of these ranges as inclusive
	-- values.
	return dmax > 0 and dmax or max (dmin, 0)
end

local function sqr (x)
	return x * x
end

local function distance_total (extents, coords)
	local d = 0
	d = d + sqr (distance_to_value (extents[1], coords[1]))
	d = d + sqr (distance_to_value (extents[2], coords[2]))
	d = d + sqr (distance_to_value (extents[3], coords[3]))
	d = d + sqr (distance_to_value (extents[4], coords[4]))
	d = d + sqr (distance_to_value (extents[5], coords[5]))
	d = d + sqr (distance_to_value (extents[6], coords[6]))
	d = d + sqr (distance_to_value (extents[7], coords[7]))
	return d
end

mcl_levelgen.biome_distance_total = distance_total

local huge = math.huge

local function rtree_index_1 (coords, leaf, distance, tree)
	local children = tree.children
	for i = 1, #children do
		local node = children[i]
		--- d must be less than distance if it contains any
		--- constitutents of which the same holds true.
		local d = distance_total (node.extents, coords)
		local value = node.value
		if d < distance and value then
			leaf = node
			distance = d
		elseif d < distance then
			leaf, distance = rtree_index_1 (coords, leaf,
							distance, node)
		end
	end
	return leaf, distance
end

local function rtree_index_closest (coords, tree)
	local leaf, distance = nil, huge
	if tree.last_result then
		leaf = tree.last_result
		distance = distance_total (leaf.extents, coords)
	end
	leaf = rtree_index_1 (coords, leaf, distance, tree)
	tree.last_result = leaf
	return leaf.value
end

local function fmt_extents (extents)
	return string.format ("[[%d-%d], [%d-%d], [%d-%d], [%d-%d], [%d-%d], [%d-%d], %d]",
			      temperature (extents)[1],
			      temperature (extents)[2],
			      humidity (extents)[1],
			      humidity (extents)[2],
			      continentalness (extents)[1],
			      continentalness (extents)[2],
			      erosion (extents)[1],
			      erosion (extents)[2],
			      depth (extents)[1],
			      depth (extents)[2],
			      weirdness (extents)[1],
			      weirdness (extents)[2],
			      offset (extents)[1])
end

function mcl_levelgen.print_rtree (rtree, depth)
	if rtree.children then
		print (string.rep (' ', depth) .. "+<" .. rtree.sorting .. "> "
		       .. fmt_extents (rtree.extents))
		for _, child in ipairs (rtree.children) do
			mcl_levelgen.print_rtree (child, depth + 1)
		end
	else
		print (string.rep (' ', depth) .. " " .. rtree.value .. " "
		       .. fmt_extents (rtree.extents))
	end
end

------------------------------------------------------------------------
-- FFI biome R-Trees.
------------------------------------------------------------------------

local biome_name_to_id_map = {}
local biome_id_to_name_map = {}

local use_ffi = mcl_levelgen.use_ffi

if use_ffi then
	local ffi = require ("ffi")
	ffi.cdef (string.format ([[
struct NoiseNode
{
  struct NoiseNode *children[%d];
  int noise_biome;
  int extents[7];
};

struct NoiseSamplerRTree
{
  struct NoiseNode *last_result;
  struct NoiseNode *root;
};

extern int rtree_index_closest (struct NoiseSamplerRTree *, int[7]);
extern struct NoiseSamplerRTree *build_rtree (struct NoiseNode *);
extern void free_rtree (struct NoiseSamplerRTree *);
]], M))
	local ns = mcl_levelgen.ffi_ns
	local ct_NoiseNode = ffi.typeof ("struct NoiseNode");
	local c_coords = ffi.new ("int[7]")
	local allnodes = {}

	local function ffi_copy_rtree_node (root)
		local gc_node = ffi.new (ct_NoiseNode)
		if root.value then
			gc_node.noise_biome
				= biome_name_to_id_map[root.value]
		else
			for i = 0, M - 1 do
				local n = #root.children
				if i < n then
					local child
						= ffi_copy_rtree_node (root.children[i + 1])
					gc_node.children[i] = child
					-- Inhibit garbage collection of CHILD.
					insert (allnodes, child)
				end
			end
			gc_node.noise_biome = -1
		end
		for i = 0, NDIM - 1 do
			gc_node.extents[i] = root.extents[i + 1]
		end
		return gc_node
	end

	local function ffi_create_noise_rtree (rtree)
		local gc_root = ffi_copy_rtree_node (rtree)
		local ffi_rtree = ns.build_rtree (gc_root)
		allnodes = {}
		ffi.gc (ffi_rtree, ns.free_rtree)
		return ffi_rtree
	end

	local old_build_rtree = build_rtree
	-- local old_rtree_index_closest = rtree_index_closest

	function build_rtree (nodes)
		local lua_rtree = old_build_rtree (nodes)
		local gc_tree = ffi_create_noise_rtree (lua_rtree)
		return gc_tree
	end

	function rtree_index_closest (coords, tree)
		c_coords[0] = coords[1]
		c_coords[1] = coords[2]
		c_coords[2] = coords[3]
		c_coords[3] = coords[4]
		c_coords[4] = coords[5]
		c_coords[5] = coords[6]
		c_coords[6] = coords[7]
		local id = ns.rtree_index_closest (tree, c_coords)
		return biome_id_to_name_map[id]
	end
end

------------------------------------------------------------------------
-- Biome parameter definitions (Overworld).
------------------------------------------------------------------------

local NO_BIOMES = {
	0, 0, 0, 0, 0,
}

local DEEP_OCEAN_BIOMES = {
	"DeepFrozenOcean", "DeepColdOcean", "DeepOcean",
	"DeepLukewarmOcean", "WarmOcean",
}

local OCEAN_BIOMES = {
	"FrozenOcean", "ColdOcean", "Ocean", "LukewarmOcean",
	"WarmOcean",
}

local ORDINARY_BIOMES = { --  N.B: indiced by temperature grade, then humidity.
	{
		"SnowyPlains", "SnowyPlains", "SnowyPlains",
		"SnowyTaiga", "Taiga",
	},
	{
		"Plains", "Plains", "Forest", "Taiga",
		"OldGrowthSpruceTaiga",
	},
	{
		"FlowerForest", "Plains", "Forest", "BirchForest",
		"DarkForest",
	},
	{
		"Savannah", "Savannah", "Forest", "Jungle", "Jungle",
	},
	{
		"Desert", "Desert", "Desert", "Desert", "Desert",
	},
}

local VARIANT_BIOMES = {
	{
		"IceSpikes", 0, "SnowyTaiga", 0, 0,
	},
	{
		0, 0, 0, 0, "OldGrowthPineTaiga",
	},
	{
		"SunflowerPlains", 0, 0, "OldGrowthBirchForest", 0,
	},
	{
		0, 0, "Plains", "SparseJungle", "BambooJungle",
	},
	NO_BIOMES,
}

local PLATEAU_BIOMES = {
	{
		"SnowyPlains", "SnowyPlains", "SnowyPlains", "SnowyTaiga",
		"SnowyTaiga",
	},
	{
		"Meadow", "Meadow", "Forest", "Taiga", "OldGrowthSpruceTaiga",
	},
	{
		"Meadow", "Meadow", "Meadow", "Meadow", "DarkForest",
	},
	{
		"SavannahPlateau", "SavannahPlateau", "Forest", "Forest",
		"Jungle",
	},
	{
		"Mesa", "Mesa", "Mesa", "WoodedMesa", "WoodedMesa",
	},
}

local VARIANT_PLATEAU_BIOMES = {
	{
		"IceSpikes", 0, 0, 0, 0,
	},
	{
		"CherryGrove", 0, "Meadow", "Meadow", "OldGrowthPineTaiga",
	},
	{
		"CherryGrove", "CherryGrove", "Forest", "BirchForest", 0,
	},
	NO_BIOMES,
	{
		"ErodedMesa", "ErodedMesa", 0, 0, 0,
	},
}

local WINDSWEPT_BIOMES = {
	{
		"WindsweptGravellyHills",
		"WindsweptGravellyHills",
		"WindsweptHills",
		"WindsweptForest",
		"WindsweptForest",
	},
	{
		"WindsweptGravellyHills",
		"WindsweptGravellyHills",
		"WindsweptHills",
		"WindsweptForest",
		"WindsweptForest",
	},
	{
		"WindsweptHills",
		"WindsweptHills",
		"WindsweptHills",
		"WindsweptForest",
		"WindsweptForest",
	},
	NO_BIOMES,
	NO_BIOMES,
}

-- https://minecraft.wiki/w/World_generation#Overworld
local temperature_grades = {
	{ -1.0, -0.45, },
	{ -0.45, -0.15, },
	{ -0.15, 0.2, },
	{ 0.2, 0.55, },
	{ 0.55, 1.0, },
}

local humidity_grades = {
	{ -1.0, -0.35, },
	{ -0.35, -0.1, },
	{ -0.1, 0.1, },
	{ 0.1, 0.3, },
	{ 0.3, 1.0, },
}

local erosion_grades = {
	{ -1.0, -0.78, },
	{ -0.78, -0.375, },
	{ -0.375, -0.2225, },
	{ -0.2225, 0.05, },
	{ 0.05, 0.45, },
	{ 0.45, 0.55, },
	{ 0.55, 1.0, },
}

local MUSHROOM_ISLANDS_CONTINENTALNESS = {
	-1.2, -1.05,
}

local DEEP_OCEAN_CONTINENTALNESS = {
	-1.05, -0.455,
}

local OCEAN_CONTINENTALNESS = {
	-0.455, -0.19,
}

local COAST_CONTINENTALNESS = {
	-0.19, -0.11,
}

local INLAND_CONTINENTALNESS = {
	-0.11, 0.55,
}

local NEAR_INLAND_CONTINENTALNESS = {
	-0.11, 0.03,
}

local MID_INLAND_CONTINENTALNESS = {
	0.03, 0.3,
}

local FAR_INLAND_CONTINENTALNESS = {
	0.3, 1.0,
}

function mcl_levelgen.parameters_adjoin_deep_dark (erosion, depth)
	return erosion < -0.225 and depth > 0.9
end

local function construct_biome (textid, temperature, humidity,
				continentalness, erosion, depth,
				weirdness, offset)
	assert (type (textid) == "string")
	if not mcl_levelgen.registered_biomes[textid] then
		verbose_print ("Unregistered biome: " .. textid)
	end
	local extents = build_biome_extents (temperature[1],
					     temperature[2],
					     humidity[1],
					     humidity[2],
					     continentalness[1],
					     continentalness[2],
					     erosion[1],
					     erosion[2],
					     depth[1],
					     depth[2],
					     weirdness[1],
					     weirdness[2],
					     offset)
	local node = {
		extents = extents,
		value = textid,
	}
	return node
end

local ZERO_DEPTH = { 0, 0, }
local ONE_DEPTH = { 1.0, 1.0, }
local ALL = { -1.0, 1.0, }

local function register_surface_biome (nodes, textid, temperature, humidity,
				       continentalness, erosion, weirdness,
				       offset)
	local leaf = construct_biome (textid, temperature, humidity,
				      continentalness, erosion, ZERO_DEPTH,
				      weirdness, offset)
	local leaf1 = construct_biome (textid, temperature, humidity,
				       continentalness, erosion, ONE_DEPTH,
				       weirdness, offset)
	table.insert (nodes, leaf)
	table.insert (nodes, leaf1)
end

local function register_biomes_at_sea (nodes)
	-- Mushroom Islands.
	register_surface_biome (nodes, "MushroomIslands",
				ALL, ALL, MUSHROOM_ISLANDS_CONTINENTALNESS,
				ALL, ALL, 0.0)

	-- Ocean biomes.
	for i = 1, #temperature_grades do
		local range = temperature_grades[i]
		register_surface_biome (nodes, DEEP_OCEAN_BIOMES[i], range,
					ALL, DEEP_OCEAN_CONTINENTALNESS, ALL,
					ALL, 0.0)
		register_surface_biome (nodes, OCEAN_BIOMES[i], range,
					ALL, OCEAN_CONTINENTALNESS, ALL,
					ALL, 0.0)
	end
end

local function grade_select (list, a, b)
	return { list[a][1], list[b][2], }
end

local function range_select (a, b)
	return { a[1], b[2], }
end

local function select_ordinary_biome (temp, humidity, weirdness)
	if weirdness[2] < 0 then
		return ORDINARY_BIOMES[temp][humidity]
	else
		local variant = VARIANT_BIOMES[temp][humidity]
		return (variant and variant ~= 0) and variant
			or ORDINARY_BIOMES[temp][humidity]
	end
end

local function select_badlands_biome (humidity, weirdness)
	if humidity <= 2 then
		return weirdness[2] < 0 and "Mesa" or "ErodedMesa"
	elseif humidity <= 3 then
		return "Mesa"
	else
		return "WoodedMesa"
	end
end

local function select_ordinary_or_badlands (temp, humidity, weirdness)
	if temp == 5 then
		return select_badlands_biome (humidity, weirdness)
	else
		return select_ordinary_biome (temp, humidity, weirdness)
	end
end

local function select_plateau (temp, humidity, weirdness)
	if weirdness[2] < 0 then
		return PLATEAU_BIOMES[temp][humidity]
	else
		local variant = VARIANT_PLATEAU_BIOMES[temp][humidity]
		return (variant and variant ~= 0)
			and variant or PLATEAU_BIOMES[temp][humidity]
	end
end

local function select_slope (temp, humidity, weirdness)
	if temp >= 4 then
		return select_plateau (temp, humidity, weirdness)
	elseif humidity <= 2 then
		return "SnowySlopes"
	else
		return "Grove"
	end
end

local function select_ordinary_badlands_or_slope (temp, humidity, weirdness)
	if temp == 1 then
		return select_slope (temp, humidity, weirdness)
	else
		return select_ordinary_or_badlands (temp, humidity, weirdness)
	end
end

local function select_windswept (temp, humidity, weirdness)
	local value = WINDSWEPT_BIOMES[temp][humidity]
	return (value and value ~= 0)
		and value or select_ordinary_biome (temp, humidity, weirdness)
end

local function select_beach (temp, humidity)
	if temp == 1 then
		return "SnowyBeach"
	elseif temp == 5 then
		return "Desert"
	else
		return "Beach"
	end
end

local function potentially_select_windswept_savannah (temp, humidity, weirdness, plain)
	if temp > 2 and humidity <= 4 and weirdness[2] >= 0 then
		return "WindsweptSavannah"
	else
		return plain
	end
end

local function select_windswept_or_coast (temp, humidity, weirdness)
	local plain_or_beach
	if weirdness[2] >= 0 then
		plain_or_beach
			= select_ordinary_biome (temp, humidity, weirdness)
	else
		plain_or_beach
			= select_beach (temp, humidity, weirdness)
	end
	return potentially_select_windswept_savannah (temp, humidity, weirdness,
						      plain_or_beach)
end

local function register_medium_pv_biomes_for_climate_grade (nodes, i, j,
							    temp_range,
							    humidity_range,
							    weirdness,
							    plain,
							    plain_or_badlands,
							    plain_or_badlands_or_slope,
							    windswept,
							    plateau,
							    beach,
							    windswept_savannah,
							    windswept_coast,
							    slope)
	register_surface_biome (nodes, slope,
				temp_range, humidity_range,
				range_select (NEAR_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[1], weirdness,
				0.0)
	register_surface_biome (nodes, plain_or_badlands_or_slope,
				temp_range, humidity_range,
				range_select (NEAR_INLAND_CONTINENTALNESS,
					      MID_INLAND_CONTINENTALNESS),
				erosion_grades[2], weirdness,
				0.0)
	register_surface_biome (nodes, i == 1 and slope or plateau,
				temp_range, humidity_range,
				FAR_INLAND_CONTINENTALNESS,
				erosion_grades[2], weirdness, 0.0)
	register_surface_biome (nodes, plain, temp_range,
				humidity_range,
				NEAR_INLAND_CONTINENTALNESS,
				erosion_grades[3], weirdness,
				0.0)
	register_surface_biome (nodes, plain_or_badlands,
				temp_range, humidity_range,
				MID_INLAND_CONTINENTALNESS,
				erosion_grades[3], weirdness,
				0.0)
	register_surface_biome (nodes, plateau,
				temp_range, humidity_range,
				FAR_INLAND_CONTINENTALNESS,
				erosion_grades[3], weirdness,
				0.0)
	register_surface_biome (nodes, plain,
				temp_range, humidity_range,
				range_select (COAST_CONTINENTALNESS,
					      NEAR_INLAND_CONTINENTALNESS),
				erosion_grades[4], weirdness,
				0.0)
	register_surface_biome (nodes, plain_or_badlands,
				temp_range, humidity_range,
				range_select (MID_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[4], weirdness,
				0.0)
	if weirdness[2] < 0 then
		register_surface_biome (nodes, beach,
					temp_range, humidity_range,
					COAST_CONTINENTALNESS,
					erosion_grades[5], weirdness,
					0.0)
		register_surface_biome (nodes, plain,
					temp_range, humidity_range,
					range_select (NEAR_INLAND_CONTINENTALNESS,
						      FAR_INLAND_CONTINENTALNESS),
					erosion_grades[5], weirdness,
					0.0)
	else
		register_surface_biome (nodes, plain,
					temp_range, humidity_range,
					range_select (COAST_CONTINENTALNESS,
						      FAR_INLAND_CONTINENTALNESS),
					erosion_grades[5], weirdness,
					0.0)
	end
	register_surface_biome (nodes, windswept_coast,
				temp_range, humidity_range,
				COAST_CONTINENTALNESS,
				erosion_grades[6], weirdness,
				0.0)
	register_surface_biome (nodes, windswept_savannah,
				temp_range, humidity_range,
				NEAR_INLAND_CONTINENTALNESS,
				erosion_grades[6], weirdness,
				0.0)
	register_surface_biome (nodes, windswept,
				temp_range, humidity_range,
				range_select (MID_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[6], weirdness,
				0.0)
	local eroded_coast = plain
	if weirdness[2] < 0 then
		eroded_coast = beach
	end
	register_surface_biome (nodes, eroded_coast,
				temp_range, humidity_range,
				COAST_CONTINENTALNESS,
				erosion_grades[7], weirdness,
				0.0)

	-- Very eroded snowy plains.
	if i == 1 then
		register_surface_biome (nodes, plain,
					temp_range, humidity_range,
					range_select (NEAR_INLAND_CONTINENTALNESS,
						      FAR_INLAND_CONTINENTALNESS),
					erosion_grades[7], weirdness,
					0.0)
	end
end

local function select_peak (temp, humidity, weirdness)
	if temp <= 3 then
		return weirdness[2] < 0 and "JaggedPeaks" or "FrozenPeaks"
	else
		return temp == 4 and "StonyPeaks"
			or select_badlands_biome (humidity, weirdness)
	end
end

local function register_medium_pv_biomes (nodes, weirdness)
	register_surface_biome (nodes, "StonyShore", ALL, ALL,
				COAST_CONTINENTALNESS,
				grade_select (erosion_grades, 1, 3),
				weirdness, 0.0)
	register_surface_biome (nodes, "Swamp",
				grade_select (temperature_grades, 2, 3),
				ALL,
				range_select (NEAR_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[7], weirdness, 0.0)
	register_surface_biome (nodes, "MangroveSwamp",
				grade_select (temperature_grades, 4, 5),
				ALL,
				range_select (NEAR_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[7], weirdness, 0.0)

	for i = 1, #temperature_grades do
		local temp_range = temperature_grades[i]
		for j = 1, #humidity_grades do
			local humidity_range = humidity_grades[j]
			local plain = select_ordinary_biome (i, j, weirdness)
			local plain_or_badlands
				= select_ordinary_or_badlands (i, j, weirdness)
			local plain_or_badlands_or_slope
				= select_ordinary_badlands_or_slope (i, j, weirdness)
			local windswept = select_windswept (i, j, weirdness)
			local plateau = select_plateau (i, j, weirdness)
			local beach = select_beach (i, j)
			local windswept_savannah
				= potentially_select_windswept_savannah (i, j,
									 weirdness,
									 plain)
			local windswept_coast
				= select_windswept_or_coast (i, j, weirdness, plain)
			local slope = select_slope (i, j, weirdness)

			register_medium_pv_biomes_for_climate_grade (nodes, i, j,
								     temp_range,
								     humidity_range,
								     weirdness,
								     plain,
								     plain_or_badlands,
								     plain_or_badlands_or_slope,
								     windswept,
								     plateau,
								     beach,
								     windswept_savannah,
								     windswept_coast,
								     slope)
		end
	end
end

local function register_high_pv_biomes_for_climate_grade (nodes, i, j,
							  temp_range,
							  humidity_range,
							  weirdness,
							  plain,
							  plain_or_badlands,
							  plain_or_badlands_or_slope,
							  windswept,
							  windswept_savannah,
							  plateau,
							  slope,
							  peak)
	register_surface_biome (nodes, plain, temp_range, humidity_range,
				COAST_CONTINENTALNESS,
				grade_select (erosion_grades, 1, 2),
				weirdness, 0.0)
	register_surface_biome (nodes, slope, temp_range, humidity_range,
				NEAR_INLAND_CONTINENTALNESS,
				erosion_grades[1], weirdness, 0.0)
	register_surface_biome (nodes, peak, temp_range, humidity_range,
				range_select (MID_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[1], weirdness, 0.0)
	register_surface_biome (nodes, plain_or_badlands_or_slope,
				temp_range, humidity_range,
				NEAR_INLAND_CONTINENTALNESS,
				erosion_grades[2], weirdness, 0.0)
	register_surface_biome (nodes, slope, temp_range, humidity_range,
				range_select (MID_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[2], weirdness, 0.0)
	register_surface_biome (nodes, plain, temp_range, humidity_range,
				range_select (COAST_CONTINENTALNESS,
					      NEAR_INLAND_CONTINENTALNESS),
				grade_select (erosion_grades, 3, 4),
				weirdness, 0.0)
	register_surface_biome (nodes, plateau, temp_range, humidity_range,
				range_select (MID_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[3], weirdness, 0.0)
	register_surface_biome (nodes, plain_or_badlands,
				temp_range, humidity_range,
				MID_INLAND_CONTINENTALNESS,
				erosion_grades[4], weirdness, 0.0)
	register_surface_biome (nodes, plateau, temp_range, humidity_range,
				FAR_INLAND_CONTINENTALNESS,
				erosion_grades[4], weirdness, 0.0)
	register_surface_biome (nodes, plain, temp_range, humidity_range,
				range_select (COAST_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[5], weirdness, 0.0)
	register_surface_biome (nodes, windswept_savannah,
				temp_range, humidity_range,
				range_select (COAST_CONTINENTALNESS,
					      NEAR_INLAND_CONTINENTALNESS),
				erosion_grades[6], weirdness, 0.0)
	register_surface_biome (nodes, windswept, temp_range, humidity_range,
				range_select (MID_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[6], weirdness, 0.0)
	register_surface_biome (nodes, plain, temp_range, humidity_range,
				range_select (COAST_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[7], weirdness, 0.0)
end

local function register_high_pv_biomes (nodes, weirdness)
	for i = 1, #temperature_grades do
		local temp_range = temperature_grades[i]
		for j = 1, #humidity_grades do
			local humidity_range = humidity_grades[j]
			local plain = select_ordinary_biome (i, j, weirdness)
			local plain_or_badlands
				= select_ordinary_or_badlands (i, j, weirdness)
			local plain_or_badlands_or_slope
				= select_ordinary_badlands_or_slope (i, j, weirdness)
			local windswept = select_windswept (i, j, weirdness)
			local windswept_savannah
				= potentially_select_windswept_savannah (i, j,
									 weirdness,
									 plain)
			local plateau = select_plateau (i, j, weirdness)
			local slope = select_slope (i, j, weirdness)
			local peak = select_peak (i, j, weirdness)

			register_high_pv_biomes_for_climate_grade (nodes, i, j,
								   temp_range,
								   humidity_range,
								   weirdness,
								   plain,
								   plain_or_badlands,
								   plain_or_badlands_or_slope,
								   windswept,
								   windswept_savannah,
								   plateau,
								   slope,
								   peak)
		end
	end
end

local function register_low_pv_biomes_for_climate_grade (nodes, i, j,
							 temp_range,
							 humidity_range,
							 weirdness,
							 plain,
							 plain_or_badlands,
							 plain_or_badlands_or_slope,
							 beach,
							 windswept_savannah,
							 windswept_coast)
	register_surface_biome (nodes, plain_or_badlands,
				temp_range, humidity_range,
				NEAR_INLAND_CONTINENTALNESS,
				grade_select (erosion_grades, 1, 2),
				weirdness, 0.0)
	register_surface_biome (nodes, plain_or_badlands_or_slope,
				temp_range, humidity_range,
				range_select (MID_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				grade_select (erosion_grades, 1, 2),
				weirdness, 0.0)
	register_surface_biome (nodes, plain, temp_range, humidity_range,
				NEAR_INLAND_CONTINENTALNESS,
				grade_select (erosion_grades, 3, 4),
				weirdness, 0.0)
	register_surface_biome (nodes, plain_or_badlands,
				temp_range, humidity_range,
				range_select (MID_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				grade_select (erosion_grades, 3, 4),
				weirdness, 0.0)
	register_surface_biome (nodes, beach, temp_range, humidity_range,
				COAST_CONTINENTALNESS,
				grade_select (erosion_grades, 4, 5),
				weirdness, 0.0)
	register_surface_biome (nodes, plain, temp_range, humidity_range,
				range_select (NEAR_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[5], weirdness, 0.0)
	register_surface_biome (nodes, windswept_coast,
				temp_range, humidity_range,
				COAST_CONTINENTALNESS,
				erosion_grades[6], weirdness, 0.0)
	register_surface_biome (nodes, windswept_savannah,
				temp_range, humidity_range,
				NEAR_INLAND_CONTINENTALNESS,
				erosion_grades[6], weirdness, 0.0)
	register_surface_biome (nodes, plain, temp_range, humidity_range,
				range_select (MID_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[6], weirdness, 0.0)
	register_surface_biome (nodes, beach, temp_range, humidity_range,
				COAST_CONTINENTALNESS,
				erosion_grades[7], weirdness, 0.0)
	if i == 1 then
		register_surface_biome (nodes, plain,
					temp_range, humidity_range,
					range_select (NEAR_INLAND_CONTINENTALNESS,
						      FAR_INLAND_CONTINENTALNESS),
					erosion_grades[7], weirdness, 0.0)
	end
end

local function register_low_pv_biomes (nodes, weirdness)
	register_surface_biome (nodes, "StonyShore", ALL, ALL,
				COAST_CONTINENTALNESS,
				grade_select (erosion_grades, 1, 3),
				weirdness, 0.0)
	register_surface_biome (nodes, "Swamp",
				grade_select (temperature_grades, 2, 3),
				ALL,
				range_select (NEAR_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[7], weirdness, 0.0)
	register_surface_biome (nodes, "MangroveSwamp",
				grade_select (temperature_grades, 4, 5),
				ALL,
				range_select (NEAR_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[7], weirdness, 0.0)

	for i = 1, #temperature_grades do
		local temp_range = temperature_grades[i]
		for j = 1, #humidity_grades do
			local humidity_range = humidity_grades[j]
			local plain = select_ordinary_biome (i, j, weirdness)
			local plain_or_badlands
				= select_ordinary_or_badlands (i, j, weirdness)
			local plain_or_badlands_or_slope
				= select_ordinary_badlands_or_slope (i, j, weirdness)
			local beach = select_beach (i, j)
			local windswept_savannah
				= potentially_select_windswept_savannah (i, j,
									 weirdness,
									 plain)
			local windswept_coast
				= select_windswept_or_coast (i, j, weirdness, plain)
			register_low_pv_biomes_for_climate_grade (nodes, i, j,
								  temp_range,
								  humidity_range,
								  weirdness,
								  plain,
								  plain_or_badlands,
								  plain_or_badlands_or_slope,
								  beach,
								  windswept_savannah,
								  windswept_coast)
		end
	end
end

local function register_peak_pv_biomes_for_climate_grade (nodes, i, j,
							  temp_range,
							  humidity_range,
							  weirdness,
							  plain,
							  plain_or_badlands,
							  plain_or_badlands_or_slope,
							  plateau,
							  windswept,
							  windswept_savannah,
							  peak)
	register_surface_biome (nodes, peak, temp_range, humidity_range,
				range_select (COAST_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[1], weirdness, 0.0)
	register_surface_biome (nodes, plain_or_badlands_or_slope,
				temp_range, humidity_range,
				range_select (COAST_CONTINENTALNESS,
					      NEAR_INLAND_CONTINENTALNESS),
				erosion_grades[2], weirdness, 0.0)
	register_surface_biome (nodes, peak, temp_range, humidity_range,
				range_select (MID_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[2], weirdness, 0.0)
	register_surface_biome (nodes, plain, temp_range, humidity_range,
				range_select (COAST_CONTINENTALNESS,
					      NEAR_INLAND_CONTINENTALNESS),
				grade_select (erosion_grades, 3, 4),
				weirdness, 0.0)
	register_surface_biome (nodes, plateau, temp_range, humidity_range,
				range_select (MID_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[3], weirdness, 0.0)
	register_surface_biome (nodes, plain_or_badlands,
				temp_range, humidity_range,
				MID_INLAND_CONTINENTALNESS,
				erosion_grades[4], weirdness, 0.0)
	register_surface_biome (nodes, plateau,	temp_range, humidity_range,
				FAR_INLAND_CONTINENTALNESS,
				erosion_grades[4], weirdness, 0.0)
	register_surface_biome (nodes, plain, temp_range, humidity_range,
				range_select (COAST_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[5], weirdness, 0.0)
	register_surface_biome (nodes, windswept_savannah,
				temp_range, humidity_range,
				range_select (COAST_CONTINENTALNESS,
					      NEAR_INLAND_CONTINENTALNESS),
				erosion_grades[6], weirdness, 0.0)
	register_surface_biome (nodes, windswept, temp_range, humidity_range,
				range_select (MID_INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[6], weirdness, 0.0)
	register_surface_biome (nodes, plain, temp_range, humidity_range,
				range_select (COAST_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[7], weirdness, 0.0)
end

local function register_peak_pv_biomes (nodes, weirdness)
	for i = 1, #temperature_grades do
		local temp_range = temperature_grades[i]
		for j = 1, #humidity_grades do
			local humidity_range = humidity_grades[j]
			local plain = select_ordinary_biome (i, j, weirdness)
			local plain_or_badlands
				= select_ordinary_or_badlands (i, j, weirdness)
			local plain_or_badlands_or_slope
				= select_ordinary_badlands_or_slope (i, j, weirdness)
			local plateau = select_plateau (i, j, weirdness)
			local windswept = select_windswept (i, j, weirdness)
			local windswept_savannah
				= potentially_select_windswept_savannah (i, j,
									 weirdness,
									 windswept)
			local peak = select_peak (i, j, weirdness)
			register_peak_pv_biomes_for_climate_grade (nodes, i, j,
								   temp_range,
								   humidity_range,
								   weirdness,
								   plain,
								   plain_or_badlands,
								   plain_or_badlands_or_slope,
								   plateau,
								   windswept,
								   windswept_savannah,
								   peak)
		end
	end
end

local function register_valley_pv_biomes (nodes, weirdness)
	local FROZEN = temperature_grades[1]
	local NOT_FROZEN = grade_select (temperature_grades, 2, 5)

	local biome = weirdness[2] < 0 and "StonyShore" or "FrozenRiver"
	register_surface_biome (nodes, biome, FROZEN, ALL,
				COAST_CONTINENTALNESS,
				grade_select (erosion_grades, 1, 2),
				weirdness, 0.0)
	local biome = weirdness[2] < 0 and "StonyShore" or "River"
	register_surface_biome (nodes, biome, NOT_FROZEN, ALL,
				COAST_CONTINENTALNESS,
				grade_select (erosion_grades, 1, 2),
				weirdness, 0.0)
	register_surface_biome (nodes, "FrozenRiver", FROZEN, ALL,
				NEAR_INLAND_CONTINENTALNESS,
				grade_select (erosion_grades, 1, 2),
				weirdness, 0.0)
	register_surface_biome (nodes, "River", NOT_FROZEN, ALL,
				NEAR_INLAND_CONTINENTALNESS,
				grade_select (erosion_grades, 1, 2),
				weirdness, 0.0)
	register_surface_biome (nodes, "FrozenRiver", FROZEN, ALL,
				range_select (COAST_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				grade_select (erosion_grades, 3, 6),
				weirdness, 0.0)
	register_surface_biome (nodes, "River", NOT_FROZEN, ALL,
				range_select (COAST_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				grade_select (erosion_grades, 3, 6),
				weirdness, 0.0)
	register_surface_biome (nodes, "FrozenRiver", FROZEN, ALL,
				COAST_CONTINENTALNESS,
				erosion_grades[7], weirdness, 0.0)
	register_surface_biome (nodes, "River", NOT_FROZEN, ALL,
				COAST_CONTINENTALNESS,
				erosion_grades[7], weirdness, 0.0)

	register_surface_biome (nodes, "Swamp",
				grade_select (temperature_grades, 2, 3), ALL,
				range_select (INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[7], weirdness, 0.0)
	register_surface_biome (nodes, "MangroveSwamp",
				grade_select (temperature_grades, 4, 5), ALL,
				range_select (INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[7], weirdness, 0.0)
	register_surface_biome (nodes, "FrozenRiver", FROZEN, ALL,
				range_select (INLAND_CONTINENTALNESS,
					      FAR_INLAND_CONTINENTALNESS),
				erosion_grades[7], weirdness, 0.0)

	for i = 1, #temperature_grades do
		local temp_range = temperature_grades[i]
		for j = 1, #humidity_grades do
			local humidity_range = humidity_grades[j]
			local plain_or_badlands
				= select_ordinary_or_badlands (i, j, weirdness)
			register_surface_biome (nodes, plain_or_badlands,
						temp_range, humidity_range,
						range_select (MID_INLAND_CONTINENTALNESS,
							      FAR_INLAND_CONTINENTALNESS),
						grade_select (erosion_grades, 1, 2),
						weirdness, 0.0)
		end
	end
end

local function register_biomes_on_land (nodes)
	-- Register biomes against the weirdness values that will
	-- yield PV values appropriate for them.  WARNING: the order
	-- in which biomes are defined is significant and directly
	-- influences the precedence of the features they define.
	-- There is no rhyme or reason to the order specified in this
	-- function, but it was produced by a computer program that
	-- attempted random permutations of these PV grades till the
	-- biome list aligned with Minecraft 1.20.4.

	register_medium_pv_biomes (nodes, {-1.0, -0.93333334,})
	register_high_pv_biomes (nodes, {-0.93333334, -0.7666667})
	register_peak_pv_biomes (nodes, {-0.7666667, -0.56666666,})
	register_high_pv_biomes (nodes, {-0.56666666, -0.4,})
	register_medium_pv_biomes (nodes, {-0.4, -0.26666668,})
	register_low_pv_biomes (nodes, {-0.26666668, -0.05,})
	register_valley_pv_biomes (nodes, {-0.05, 0.05,})
	register_low_pv_biomes (nodes, {0.05, 0.26666668,})
	register_medium_pv_biomes (nodes, {0.26666668, 0.4,})
	register_high_pv_biomes (nodes, {0.4, 0.56666666,})
	register_peak_pv_biomes (nodes, {0.56666666, 0.7666667,})
	register_high_pv_biomes (nodes, {0.7666667, 0.93333334,})
	register_medium_pv_biomes (nodes, {0.93333334, 1.0,})
end

local UNDERGROUND_DEPTH = {
	0.2, 0.9,
}

local function register_underground_biome (nodes, textid, temperature, humidity,
					   continentalness, erosion, weirdness,
					   offset)
	local leaf = construct_biome (textid, temperature, humidity,
				      continentalness, erosion,
				      UNDERGROUND_DEPTH, weirdness, offset)
	table.insert (nodes, leaf)
end

local function register_biomes_underground (nodes)
	register_underground_biome (nodes, "DripstoneCaves", ALL, ALL,
				    {0.8, 1.0,}, ALL, ALL, 0.0)
	register_underground_biome (nodes, "LushCaves", ALL, {0.7, 1.0,},
				    ALL, ALL, ALL, 0.0)
	local deep_dark = construct_biome ("DeepDark", ALL, ALL, ALL,
					   grade_select (erosion_grades, 1, 2),
					   {1.1, 1.1,}, ALL, 0.0)
	table.insert (nodes, deep_dark)
end

local function print_biome_report (levelname, nodes)
	local nunique, seen, unique = 0, {}, {}
	local cost_total = 0
	verbose_print (string.format ("Registered %d biome definitions for level %s",
				      #nodes, levelname))
	for _, biome in pairs (nodes) do
		if not seen[biome.value] then
			seen[biome.value] = 0
			table.insert (unique, biome.value)
			nunique = nunique + 1
		end
		local cost = seen[biome.value] + vol_extents (biome.extents)
		cost_total = cost_total + vol_extents (biome.extents)
		seen[biome.value] = cost
	end
	verbose_print (string.format ("  (comprising %d unique biomes, distributed as follows:)",
				      nunique))
	table.sort (unique, function (a, b)
		return seen[a] > seen[b]
	end)
	for _, biome in pairs (unique) do
		local str = string.format ("%-25s%.8f%%", biome,
					   seen[biome] / cost_total * 100.0)
		verbose_print (str)
	end
end

local function construct_overworld_lut ()
	local nodes = {}
	verbose_print ("** Registering offshore biomes")
	register_biomes_at_sea (nodes)
	verbose_print ("** Registering inland biomes")
	register_biomes_on_land (nodes)
	verbose_print ("** Registering cave & Deep Dark biomes")
	register_biomes_underground (nodes)
	print_biome_report ("Overworld", nodes)

	-- Preserve `node''s order, as this ultimately affects the
	-- order in which biome decorations are assigned IDs.
	return build_rtree (table.copy (nodes)), nodes
end

local function rtree_index_silly (coords, nodes)
	local d = math.huge
	local value = nil
	for _, biome in ipairs (nodes) do
		local d1 = distance_total (biome.extents, coords)
		if d1 < d then
			value = biome
			d = d1
		end
	end
	return value, d
end

mcl_levelgen.rtree_index_silly = rtree_index_silly
mcl_levelgen.rtree_index_closest = rtree_index_closest
mcl_levelgen.construct_overworld_lut = construct_overworld_lut

local scratch = {}
for i = 1, 7 do
	scratch[i] = 0.0
end

local function quantize_index (temperature, humidity,
			       continentalness, erosion,
			       depth, weirdness)
	scratch[1] = quantize (temperature)
	scratch[2] = quantize (humidity)
	scratch[3] = quantize (continentalness)
	scratch[4] = quantize (erosion)
	scratch[5] = quantize (depth)
	scratch[6] = quantize (weirdness)
	return scratch
end

function mcl_levelgen.index_biome_lut (tree, temperature, humidity,
				       continentalness,
				       erosion, depth, weirdness)
	local coords = quantize_index (temperature, humidity,
				       continentalness, erosion,
				       depth, weirdness)
	local value = rtree_index_closest (coords, tree)
	return value
end

------------------------------------------------------------------------
-- Nether Biomes.
------------------------------------------------------------------------

function mcl_levelgen.construct_nether_lut ()
	local ZERO = { 0.0, 0.0, }
	local nodes = {
		construct_biome ("NetherWastes", ZERO, ZERO, ZERO,
				 ZERO, ZERO, ZERO, 0.0),
		construct_biome ("SoulSandValley", ZERO, {-0.5, -0.5,},
				 ZERO, ZERO, ZERO, ZERO, 0.0),
		construct_biome ("CrimsonForest", {0.4, 0.4,},
				 ZERO, ZERO, ZERO, ZERO, ZERO, 0.0),
		construct_biome ("WarpedForest", ZERO, {0.5, 0.5,},
				 ZERO, ZERO, ZERO, ZERO, 0.375),
		construct_biome ("BasaltDeltas", {-0.5, -0.5,}, ZERO,
				 ZERO, ZERO, ZERO, ZERO, 0.175),
	}
	print_biome_report ("Nether", nodes)
	return build_rtree (table.copy (nodes)), nodes
end

------------------------------------------------------------------------
-- End Biomes.
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Biome definitions.
------------------------------------------------------------------------

local registered_biomes = {}
mcl_levelgen.registered_biomes = registered_biomes

function mcl_levelgen.register_biome (name, def)
	assert (def.temperature, "Biome definition does not define a temperature")
	assert (def.grass_palette_index,
		"Biome definition does not define a grass palette index")
	assert (def.groups, "Biome definition does not define a group list")
	if def.grass_palette_index > 31
		and not def.leaves_palette_index then
		error ("Biome definition requires a leaf palette index but none "
		       .. "is specified")
	elseif not def.leaves_palette_index then
		def.leaves_palette_index = def.grass_palette_index
	end
	-- Copy the feature list, or modifications to it may affect
	-- unintended different biomes.
	def.features = table.copy (def.features)
	registered_biomes[name] = def
end

mcl_levelgen.register_biome ("TheVoid", {
	carvers = {},
	downfall = 0.5,
	features = {
		-- Steps 0 - 10.
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{},
	},
	has_precipitation = false,
	temperature = 0.5,
	grass_palette_index = 0,
	groups = {},
})

local OVERWORLD_DEFAULT_ORES = {
	"mcl_levelgen:ore_dirt",
	"mcl_levelgen:ore_gravel",
	"mcl_levelgen:ore_granite_upper",
	"mcl_levelgen:ore_granite_lower",
	"mcl_levelgen:ore_diorite_upper",
	"mcl_levelgen:ore_diorite_lower",
	"mcl_levelgen:ore_andesite_upper",
	"mcl_levelgen:ore_andesite_lower",
	"mcl_levelgen:ore_tuff",
	"mcl_levelgen:ore_coal_upper",
	"mcl_levelgen:ore_coal_lower",
	"mcl_levelgen:ore_iron_upper",
	"mcl_levelgen:ore_iron_middle",
	"mcl_levelgen:ore_iron_small",
	"mcl_levelgen:ore_gold",
	"mcl_levelgen:ore_gold_lower",
	"mcl_levelgen:ore_redstone",
	"mcl_levelgen:ore_redstone_lower",
	"mcl_levelgen:ore_diamond",
	"mcl_levelgen:ore_diamond_medium",
	"mcl_levelgen:ore_diamond_large",
	"mcl_levelgen:ore_diamond_buried",
	"mcl_levelgen:ore_lapis",
	"mcl_levelgen:ore_lapis_buried",
	"mcl_levelgen:ore_copper",
	"mcl_levelgen:underwater_magma",
	"mcl_levelgen:disk_sand",
	"mcl_levelgen:disk_clay",
	"mcl_levelgen:disk_gravel",
}

mcl_levelgen.register_biome ("Mesa", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.000000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:ore_gold_extra",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_levelgen:patch_dead_bush_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane_badlands",
			"mcl_farming:patch_pumpkin",
			"mcl_levelgen:patch_cactus_decorated",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = false,
	temperature = 2.000000,
	grass_palette_index = 19,
	groups = {
		is_badlands = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#6eb1ff",
})

mcl_levelgen.register_biome ("BambooJungle", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.9,
	features = {
		-- Steps 0 - 10.
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		OVERWORLD_DEFAULT_ORES,
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_bamboo:bamboo",
			"mcl_trees:bamboo_vegetation",
			"mcl_flowers:flower_warm",
			"mcl_levelgen:patch_grass_jungle",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_levelgen:vines",
			"mcl_farming:patch_melon",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.95,
	grass_palette_index = 26,
	groups = {
		is_jungle = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#77a8ff",
})

mcl_levelgen.register_biome ("BasaltDeltas", {
	carvers = {
		air = {
			"mcl_levelgen:nether_cave_carver",
		},
	},
	downfall = 0.0,
	features = {
		{},
		{},
		{},
		{},
		{
			"mcl_nether:delta",
			"mcl_nether:small_basalt_columns",
			"mcl_nether:large_basalt_columns",
		},
		{},
		{},
		{
			"mcl_nether:basalt_blobs",
			"mcl_levelgen:blackstone_blobs",
			"mcl_nether:spring_delta",
			"mcl_levelgen:patch_fire",
			"mcl_levelgen:patch_soul_fire",
			"mcl_nether:glowstone_extra",
			"mcl_nether:glowstone",
			"mcl_mushrooms:brown_mushroom_nether",
			"mcl_mushrooms:red_mushroom_nether",
			"mcl_levelgen:ore_magma",
			"mcl_levelgen:spring_closed_double",
			"mcl_levelgen:ore_gold_deltas",
			"mcl_levelgen:ore_quartz_deltas",
			"mcl_levelgen:ore_ancient_debris_large",
			"mcl_levelgen:ore_debris_small",
		},
		{},
		{},
		{},
	},
	temperature = 2.0,
	grass_palette_index = 16,
	groups = {
		is_nether = true,
	},
	fog_color = "#685f70",
	sky_color = "#6eb1ff",
})

mcl_levelgen.register_biome ("Beach", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.4,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		OVERWORLD_DEFAULT_ORES,
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	temperature = 0.8,
	grass_palette_index = 0,
	groups = {
		is_beach = true,
		is_overworld = true,
	},
	has_precipitation = true,
	fog_color = "#c0d8ff",
	sky_color = "#78a7ff",
})

mcl_levelgen.register_biome ("BirchForest", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.6,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		OVERWORLD_DEFAULT_ORES,
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_flowers:forest_flowers",
			"mcl_trees:trees_birch",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_forest",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.6,
	grass_palette_index = 15,
	groups = {
		is_forest = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7aa5ff",
})

mcl_levelgen.register_biome ("CherryGrove", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.800000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
			"mcl_levelgen:ore_emerald",
		},
		{
			"mcl_levelgen:ore_infested",
		},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_tall_grass_2",
			"mcl_levelgen:patch_grass_plain",
			"mcl_flowers:flower_cherry",
			"mcl_trees:trees_cherry",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.500000,
	grass_palette_index = 11,
	groups = {
		is_mountain = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7ba4ff",
})

mcl_levelgen.register_biome ("ColdOcean", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.500000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_water",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_ocean:seagrass_cold",
			"mcl_ocean:seagrass_simple",
			"mcl_ocean:kelp_cold",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.500000,
	grass_palette_index = 0,
	groups = {
		is_ocean = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7ba4ff",
})

mcl_levelgen.register_biome ("CrimsonForest", {
	carvers = {
		air = {
			"mcl_levelgen:nether_cave_carver",
		},
	},
	downfall = 0.000000,
	features = {
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{
			"mcl_levelgen:spring_open",
			"mcl_levelgen:patch_fire",
			"mcl_nether:glowstone_extra",
			"mcl_nether:glowstone",
			"mcl_levelgen:ore_magma",
			"mcl_levelgen:spring_closed",
			"mcl_levelgen:ore_gravel_nether",
			"mcl_levelgen:ore_blackstone",
			"mcl_levelgen:ore_gold_nether",
			"mcl_levelgen:ore_quartz_nether",
			"mcl_levelgen:ore_ancient_debris_large",
			"mcl_levelgen:ore_debris_small",
		},
		{},
		{
			"mcl_levelgen:spring_lava",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_crimson:weeping_vines",
			"mcl_crimson:crimson_fungi",
			"mcl_crimson:crimson_forest_vegetation",
		},
	},
	has_precipitation = false,
	temperature = 2.000000,
	grass_palette_index = 1,
	groups = {
		is_nether = true,
	},
	fog_color = "#330303",
	sky_color = "#6eb1ff",
})

mcl_levelgen.register_biome ("DarkForest", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.800000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:dark_forest_vegetation",
			"mcl_flowers:forest_flowers",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_forest",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.700000,
	grass_palette_index = 18,
	groups = {
		is_forest = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#79a6ff",
})

mcl_levelgen.register_biome ("DeepColdOcean", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.500000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_water",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_ocean:seagrass_deep_cold",
			"mcl_ocean:seagrass_simple",
			"mcl_ocean:kelp_cold",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.500000,
	grass_palette_index = 0,
	groups = {
		is_deep_ocean = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7ba4ff",
})

mcl_levelgen.register_biome ("DeepDark", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.400000,
	features = {
		{},
		{},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{
			"mcl_sculk:sculk_vein",
			"mcl_sculk:sculk_patch_deep_dark",
		},
		{},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_tall_grass_2",
			"mcl_trees:trees_plains",
			"mcl_flowers:flower_plains",
			"mcl_levelgen:patch_grass_plain",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = false,
	temperature = 0.800000,
	grass_palette_index = 0,
	groups = {
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#78a7ff",
})

mcl_levelgen.register_biome ("DeepFrozenOcean", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.500000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_levelgen:iceberg_packed",
			"mcl_levelgen:iceberg_blue",
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{
			"mcl_levelgen:blue_ice",
		},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_water",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.500000,
	temperature_modifier = "frozen",
	grass_palette_index = 0,
	groups = {
		is_deep_ocean = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7ba4ff",
})

mcl_levelgen.register_biome ("DeepLukewarmOcean", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.500000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_water",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_ocean:seagrass_deep_warm",
			"mcl_ocean:seagrass_simple",
			"mcl_ocean:kelp_warm",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.500000,
	grass_palette_index = 0,
	groups = {
		is_deep_ocean = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7ba4ff",
})

mcl_levelgen.register_biome ("DeepOcean", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.500000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_water",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_ocean:seagrass_deep",
			"mcl_ocean:seagrass_simple",
			"mcl_ocean:kelp_cold",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.500000,
	grass_palette_index = 0,
	groups = {
		is_deep_ocean = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7ba4ff",
})

mcl_levelgen.register_biome ("Desert", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.000000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_levelgen:fossil_upper",
			"mcl_levelgen:fossil_lower",
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{
			"mcl_levelgen:desert_well",
		},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_levelgen:patch_dead_bush_2",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane_desert",
			"mcl_farming:patch_pumpkin",
			"mcl_levelgen:patch_cactus_desert",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = false,
	temperature = 2.000000,
	grass_palette_index = 17,
	groups = {
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#6eb1ff",
})

mcl_levelgen.register_biome ("DripstoneCaves", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.400000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
			"mcl_dripstone:large_dripstone",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper_large",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{
			"mcl_dripstone:dripstone_cluster",
			"mcl_dripstone:pointed_dripstone",
		},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_tall_grass_2",
			"mcl_trees:trees_plains",
			"mcl_flowers:flower_plains",
			"mcl_levelgen:patch_grass_plain",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.800000,
	grass_palette_index = 0,
	groups = {
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#78a7ff",
})

mcl_levelgen.register_biome ("EndBarrens", {
	carvers = {
	},
	downfall = 0.500000,
	features = {
	},
	has_precipitation = false,
	temperature = 0.500000,
	grass_palette_index = 15,
	groups = {
		is_end = true,
	},
	fog_color = "#a080a0",
	sky_color = "#000000",
})

mcl_levelgen.register_biome ("EndHighlands", {
	carvers = {
	},
	downfall = 0.500000,
	features = {
		{},
		{},
		{},
		{},
		{
			"mcl_end:end_gateway_return",
		},
		{},
		{},
		{},
		{},
		{
			"mcl_end:chorus_plant",
		},
	},
	has_precipitation = false,
	temperature = 0.500000,
	grass_palette_index = 15,
	groups = {
		is_end = true,
	},
	fog_color = "#a080a0",
	sky_color = "#000000",
})

mcl_levelgen.register_biome ("EndMidlands", {
	carvers = {
	},
	downfall = 0.500000,
	features = {
	},
	has_precipitation = false,
	temperature = 0.500000,
	grass_palette_index = 15,
	groups = {
		is_end = true,
	},
	fog_color = "#a080a0",
	sky_color = "#000000",
})

mcl_levelgen.register_biome ("ErodedMesa", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.000000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:ore_gold_extra",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_levelgen:patch_dead_bush_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane_badlands",
			"mcl_farming:patch_pumpkin",
			"mcl_levelgen:patch_cactus_decorated",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = false,
	temperature = 2.000000,
	grass_palette_index = 20,
	groups = {
		is_badlands = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#6eb1ff",
})

mcl_levelgen.register_biome ("FlowerForest", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.800000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_flowers:flower_forest_flowers",
			"mcl_trees:trees_flower_forest",
			"mcl_flowers:flower_flower_forest",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.700000,
	grass_palette_index = 14,
	groups = {
		is_forest = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#79a6ff",
})

mcl_levelgen.register_biome ("Forest", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.800000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_flowers:forest_flowers",
			"mcl_trees:trees_birch_and_oak",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_forest",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.700000,
	grass_palette_index = 13,
	groups = {
		is_forest = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#79a6ff",
})

mcl_levelgen.register_biome ("FrozenOcean", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.500000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_levelgen:iceberg_packed",
			"mcl_levelgen:iceberg_blue",
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{
			"mcl_levelgen:blue_ice",
		},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_water",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.000000,
	temperature_modifier = "frozen",
	grass_palette_index = 2,
	groups = {
		is_ocean = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7fa1ff",
})

mcl_levelgen.register_biome ("FrozenPeaks", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.900000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
			"mcl_levelgen:ore_emerald",
		},
		{
			"mcl_levelgen:ore_infested",
		},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
			"mcl_levelgen:spring_lava_frozen",
		},
		{
			"mcl_levelgen:glow_lichen",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = -0.700000,
	grass_palette_index = 2,
	groups = {
		is_mountain = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#859dff",
})

mcl_levelgen.register_biome ("FrozenRiver", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.500000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_water",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.000000,
	grass_palette_index = 2,
	groups = {
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7fa1ff",
})

mcl_levelgen.register_biome ("Grove", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.800000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
			"mcl_levelgen:ore_emerald",
		},
		{
			"mcl_levelgen:ore_infested",
		},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
			"mcl_levelgen:spring_lava_frozen",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_grove",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = -0.200000,
	grass_palette_index = 2,
	groups = {
		is_forest = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#81a0ff",
})

mcl_levelgen.register_biome ("IceSpikes", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.500000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{
			"mcl_levelgen:ice_spike",
			"mcl_levelgen:ice_patch",
		},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_snowy",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.000000,
	grass_palette_index = 2,
	groups = {
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7fa1ff",
})

mcl_levelgen.register_biome ("JaggedPeaks", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.900000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
			"mcl_levelgen:ore_emerald",
		},
		{
			"mcl_levelgen:ore_infested",
		},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
			"mcl_levelgen:spring_lava_frozen",
		},
		{
			"mcl_levelgen:glow_lichen",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = -0.700000,
	grass_palette_index = 2,
	groups = {
		is_mountain = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#859dff",
})

mcl_levelgen.register_biome ("Jungle", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.900000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_bamboo:bamboo_light",
			"mcl_trees:trees_jungle",
			"mcl_flowers:flower_warm",
			"mcl_levelgen:patch_grass_jungle",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_levelgen:vines",
			"mcl_farming:patch_melon",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.950000,
	grass_palette_index = 24,
	groups = {
		is_jungle = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#77a8ff",
})

mcl_levelgen.register_biome ("LukewarmOcean", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.500000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_water",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_ocean:seagrass_warm",
			"mcl_ocean:kelp_warm",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.500000,
	grass_palette_index = 0,
	groups = {
		is_ocean = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7ba4ff",
})

mcl_levelgen.register_biome ("LushCaves", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.500000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:ore_clay",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_tall_grass_2",
			"mcl_lush_caves:lush_caves_ceiling_vegetation",
			"mcl_lush_caves:cave_vines",
			"mcl_lush_caves:lush_caves_clay",
			"mcl_lush_caves:lush_caves_vegetation",
			"mcl_lush_caves:rooted_azalea_tree",
			"mcl_lush_caves:spore_blossom",
			"mcl_lush_caves:classic_vines_cave_feature",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.500000,
	grass_palette_index = 0,
	groups = {
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7ba4ff",
})

mcl_levelgen.register_biome ("MangroveSwamp", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.900000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_levelgen:fossil_upper",
			"mcl_levelgen:fossil_lower",
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_grass",
			"mcl_levelgen:disk_clay",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_mangrove:trees_mangrove",
			"mcl_levelgen:patch_grass_normal",
			"mcl_levelgen:patch_dead_bush",
			"mcl_levelgen:patch_waterlily",
			"mcl_ocean:seagrass_swamp",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.800000,
	grass_palette_index = 27,
	groups = {
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#78a7ff",
})

mcl_levelgen.register_biome ("Meadow", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.800000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
			"mcl_levelgen:ore_emerald",
		},
		{
			"mcl_levelgen:ore_infested",
		},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_tall_grass_2",
			"mcl_levelgen:patch_grass_plain",
			"mcl_flowers:flower_meadow",
			"mcl_trees:trees_meadow",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.500000,
	grass_palette_index = 30,
	groups = {
		is_mountain = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7ba4ff",
})

mcl_levelgen.register_biome ("MushroomIslands", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 1.000000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_mushrooms:mushroom_island_vegetation",
			"mcl_mushrooms:brown_mushroom_taiga",
			"mcl_mushrooms:red_mushroom_taiga",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.900000,
	grass_palette_index = 29,
	groups = {
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#77a8ff",
})

mcl_levelgen.register_biome ("NetherWastes", {
	carvers = {
		air = {
			"mcl_levelgen:nether_cave_carver",
		},
	},
	downfall = 0.000000,
	features = {
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{
			"mcl_levelgen:spring_open",
			"mcl_levelgen:patch_fire",
			"mcl_levelgen:patch_soul_fire",
			"mcl_nether:glowstone_extra",
			"mcl_nether:glowstone",
			"mcl_mushrooms:brown_mushroom_nether",
			"mcl_mushrooms:red_mushroom_nether",
			"mcl_levelgen:ore_magma",
			"mcl_levelgen:spring_closed",
			"mcl_levelgen:ore_gravel_nether",
			"mcl_levelgen:ore_blackstone",
			"mcl_levelgen:ore_gold_nether",
			"mcl_levelgen:ore_quartz_nether",
			"mcl_levelgen:ore_ancient_debris_large",
			"mcl_levelgen:ore_debris_small",
		},
		{},
		{
			"mcl_levelgen:spring_lava",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
		},
	},
	has_precipitation = false,
	temperature = 2.000000,
	grass_palette_index = 17,
	groups = {
		is_nether = true,
	},
	fog_color = "#330808",
	sky_color = "#6eb1ff",
})

mcl_levelgen.register_biome ("Ocean", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.500000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_water",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_ocean:seagrass_normal",
			"mcl_ocean:seagrass_simple",
			"mcl_ocean:kelp_cold",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.500000,
	grass_palette_index = 0,
	groups = {
		is_ocean = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7ba4ff",
})

mcl_levelgen.register_biome ("OldGrowthBirchForest", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.600000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_flowers:forest_flowers",
			"mcl_trees:birch_tall",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_forest",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.600000,
	grass_palette_index = 15,
	groups = {
		is_forest = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7aa5ff",
})

mcl_levelgen.register_biome ("OldGrowthPineTaiga", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.800000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
			"mcl_levelgen:forest_rock",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_large_fern",
			"mcl_trees:trees_old_growth_pine_taiga",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_taiga",
			"mcl_levelgen:patch_dead_bush",
			"mcl_mushrooms:brown_mushroom_old_growth",
			"mcl_mushrooms:red_mushroom_old_growth",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_farming:patch_berry_common",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.300000,
	grass_palette_index = 31,
	groups = {
		is_overworld = true,
		is_taiga = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7ca3ff",
})

mcl_levelgen.register_biome ("OldGrowthSpruceTaiga", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.800000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
			"mcl_levelgen:forest_rock",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_large_fern",
			"mcl_trees:trees_old_growth_spruce_taiga",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_taiga",
			"mcl_levelgen:patch_dead_bush",
			"mcl_mushrooms:brown_mushroom_old_growth",
			"mcl_mushrooms:red_mushroom_old_growth",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_farming:patch_berry_common",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.250000,
	grass_palette_index = 12,
	groups = {
		is_overworld = true,
		is_taiga = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7da3ff",
})

mcl_levelgen.register_biome ("Plains", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.400000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_tall_grass_2",
			"mcl_trees:trees_plains",
			"mcl_flowers:flower_plains",
			"mcl_levelgen:patch_grass_plain",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.800000,
	grass_palette_index = 11,
	groups = {
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#78a7ff",
})

mcl_levelgen.register_biome ("River", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.500000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_water",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_ocean:seagrass_river",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.500000,
	grass_palette_index = 0,
	groups = {
		is_overworld = true,
		is_river = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7ba4ff",
})

mcl_levelgen.register_biome ("Savannah", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.000000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_tall_grass",
			"mcl_trees:trees_savanna",
			"mcl_flowers:flower_warm",
			"mcl_levelgen:patch_grass_savannah",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = false,
	temperature = 2.000000,
	grass_palette_index = 1,
	groups = {
		is_overworld = true,
		is_savannah = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#6eb1ff",
})

mcl_levelgen.register_biome ("SavannahPlateau", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.000000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_tall_grass",
			"mcl_trees:trees_savanna",
			"mcl_flowers:flower_warm",
			"mcl_levelgen:patch_grass_savannah",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = false,
	temperature = 2.000000,
	grass_palette_index = 1,
	groups = {
		is_overworld = true,
		is_savannah = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#6eb1ff",
})

mcl_levelgen.register_biome ("SmallEndIslands", {
	carvers = {
	},
	downfall = 0.500000,
	features = {
		{
			"mcl_end:end_island_decorated",
		},
	},
	has_precipitation = false,
	temperature = 0.500000,
	grass_palette_index = 0,
	groups = {
		is_end = true,
	},
	fog_color = "#a080a0",
	sky_color = "#000000",
})

mcl_levelgen.register_biome ("SnowyBeach", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.300000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.050000,
	grass_palette_index = 32,
	leaves_palette_index = 31,
	groups = {
		is_beach = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7fa1ff",
})

mcl_levelgen.register_biome ("SnowyPlains", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.500000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_snowy",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.000000,
	grass_palette_index = 10,
	groups = {
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7fa1ff",
})

mcl_levelgen.register_biome ("SnowySlopes", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.900000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
			"mcl_levelgen:ore_emerald",
		},
		{
			"mcl_levelgen:ore_infested",
		},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
			"mcl_levelgen:spring_lava_frozen",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = -0.300000,
	grass_palette_index = 10,
	groups = {
		is_mountain = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#829fff",
})

mcl_levelgen.register_biome ("SnowyTaiga", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.400000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_large_fern",
			"mcl_trees:trees_taiga",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_taiga_2",
			"mcl_mushrooms:brown_mushroom_taiga",
			"mcl_mushrooms:red_mushroom_taiga",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_farming:patch_berry_rare",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = -0.500000,
	grass_palette_index = 10,
	groups = {
		is_overworld = true,
		is_taiga = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#839eff",
})

mcl_levelgen.register_biome ("SoulSandValley", {
	carvers = {
		air = {
			"mcl_levelgen:nether_cave_carver",
		},
	},
	downfall = 0.000000,
	features = {
		{},
		{},
		{
			"mcl_nether:basalt_pillar",
		},
		{},
		{},
		{},
		{},
		{
			"mcl_levelgen:spring_open",
			"mcl_levelgen:patch_fire",
			"mcl_levelgen:patch_soul_fire",
			"mcl_nether:glowstone_extra",
			"mcl_nether:glowstone",
			"mcl_crimson:patch_crimson_roots",
			"mcl_levelgen:ore_magma",
			"mcl_levelgen:spring_closed",
			"mcl_levelgen:ore_soul_sand",
			"mcl_levelgen:ore_gravel_nether",
			"mcl_levelgen:ore_blackstone",
			"mcl_levelgen:ore_gold_nether",
			"mcl_levelgen:ore_quartz_nether",
			"mcl_levelgen:ore_ancient_debris_large",
			"mcl_levelgen:ore_debris_small",
		},
		{},
		{
			"mcl_levelgen:spring_lava",
		},
	},
	has_precipitation = false,
	temperature = 2.000000,
	grass_palette_index = 17,
	groups = {
		is_nether = true,
	},
	fog_color = "#1b4745",
	sky_color = "#6eb1ff",
})

mcl_levelgen.register_biome ("SparseJungle", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.800000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_sparse_jungle",
			"mcl_flowers:flower_warm",
			"mcl_levelgen:patch_grass_jungle",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_levelgen:vines",
			"mcl_farming:patch_melon_sparse",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.950000,
	grass_palette_index = 26,
	groups = {
		is_jungle = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#77a8ff",
})

mcl_levelgen.register_biome ("StonyPeaks", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.300000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
			"mcl_levelgen:ore_emerald",
		},
		{
			"mcl_levelgen:ore_infested",
		},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 1.000000,
	grass_palette_index = 33,
	leaves_palette_index = 11,
	groups = {
		is_mountain = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#76a8ff",
})

mcl_levelgen.register_biome ("StonyShore", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.300000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.200000,
	grass_palette_index = 34,
	leaves_palette_index = 31,
	groups = {
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7da2ff",
})

mcl_levelgen.register_biome ("SunflowerPlains", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.400000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_tall_grass_2",
			"mcl_flowers:patch_sunflower",
			"mcl_trees:trees_plains",
			"mcl_flowers:flower_plains",
			"mcl_levelgen:patch_grass_plain",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.800000,
	grass_palette_index = 11,
	groups = {
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#78a7ff",
})

mcl_levelgen.register_biome ("Swamp", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.900000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_levelgen:fossil_upper",
			"mcl_levelgen:fossil_lower",
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_clay",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_swamp",
			"mcl_flowers:flower_swamp",
			"mcl_levelgen:patch_grass_normal",
			"mcl_levelgen:patch_dead_bush",
			"mcl_levelgen:patch_waterlily",
			"mcl_mushrooms:brown_mushroom_swamp",
			"mcl_mushrooms:red_mushroom_swamp",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane_swamp",
			"mcl_farming:patch_pumpkin",
			"mcl_ocean:seagrass_swamp",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.800000,
	grass_palette_index = 28,
	groups = {
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#78a7ff",
})

mcl_levelgen.register_biome ("Taiga", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.800000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_levelgen:patch_large_fern",
			"mcl_trees:trees_taiga",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_taiga_2",
			"mcl_mushrooms:brown_mushroom_taiga",
			"mcl_mushrooms:red_mushroom_taiga",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_farming:patch_berry_common",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.250000,
	grass_palette_index = 12,
	groups = {
		is_overworld = true,
		is_taiga = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7da3ff",
})

mcl_levelgen.register_biome ("TheEnd", {
	carvers = {
	},
	downfall = 0.500000,
	features = {
		{},
		{},
		{},
		{},
		{
			"mcl_end:end_spike",
		},
	},
	has_precipitation = false,
	temperature = 0.500000,
	grass_palette_index = 0,
	groups = {
		is_end = true,
	},
	fog_color = "#a080a0",
	sky_color = "#000000",
})

mcl_levelgen.register_biome ("WarmOcean", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.500000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_water",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
			"mcl_ocean:warm_ocean_vegetation",
			"mcl_ocean:seagrass_warm",
			"mcl_ocean:sea_pickle",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.500000,
	grass_palette_index = 0,
	groups = {
		is_ocean = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7ba4ff",
})

mcl_levelgen.register_biome ("WarpedForest", {
	carvers = {
		air = {
			"mcl_levelgen:nether_cave_carver",
		},
	},
	downfall = 0.000000,
	features = {
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{
			"mcl_levelgen:spring_open",
			"mcl_levelgen:patch_fire",
			"mcl_levelgen:patch_soul_fire",
			"mcl_nether:glowstone_extra",
			"mcl_nether:glowstone",
			"mcl_levelgen:ore_magma",
			"mcl_levelgen:spring_closed",
			"mcl_levelgen:ore_gravel_nether",
			"mcl_levelgen:ore_blackstone",
			"mcl_levelgen:ore_gold_nether",
			"mcl_levelgen:ore_quartz_nether",
			"mcl_levelgen:ore_ancient_debris_large",
			"mcl_levelgen:ore_debris_small",
		},
		{},
		{
			"mcl_levelgen:spring_lava",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_crimson:warped_fungi",
			"mcl_crimson:warped_forest_vegetation",
			"mcl_crimson:nether_sprouts",
			"mcl_crimson:twisting_vines",
		},
	},
	has_precipitation = false,
	temperature = 2.000000,
	grass_palette_index = 17,
	groups = {
		is_nether = true,
	},
	fog_color = "#1a051a",
	sky_color = "#6eb1ff",
})

mcl_levelgen.register_biome ("WindsweptForest", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.300000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
			"mcl_levelgen:ore_emerald",
		},
		{
			"mcl_levelgen:ore_infested",
		},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_windswept_forest",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.200000,
	grass_palette_index = 34,
	leaves_palette_index = 31,
	groups = {
		is_hill = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7da2ff",
})

mcl_levelgen.register_biome ("WindsweptGravellyHills", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.300000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
			"mcl_levelgen:ore_emerald",
		},
		{
			"mcl_levelgen:ore_infested",
		},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_windswept_hills",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.200000,
	grass_palette_index = 34,
	leaves_palette_index = 31,
	groups = {
		is_hill = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7da2ff",
})

mcl_levelgen.register_biome ("WindsweptHills", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.300000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
			"mcl_levelgen:ore_emerald",
		},
		{
			"mcl_levelgen:ore_infested",
		},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_windswept_hills",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = true,
	temperature = 0.200000,
	grass_palette_index = 34,
	leaves_palette_index = 31,
	groups = {
		is_hill = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#7da2ff",
})

mcl_levelgen.register_biome ("WindsweptSavannah", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.000000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_windswept_savanna",
			"mcl_flowers:flower_default",
			"mcl_levelgen:patch_grass_normal",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane",
			"mcl_farming:patch_pumpkin",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = false,
	temperature = 2.000000,
	grass_palette_index = 1,
	groups = {
		is_overworld = true,
		is_savannah = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#6eb1ff",
})

mcl_levelgen.register_biome ("WoodedMesa", {
	carvers = {
		air = {
			"mcl_levelgen:cave_carver",
			"mcl_levelgen:cave_extra_underground_carver",
			"mcl_levelgen:ravine_carver",
		},
	},
	downfall = 0.000000,
	features = {
		{},
		{
			"mcl_levelgen:lake_lava_underground",
			"mcl_levelgen:lake_lava_surface",
		},
		{
			"mcl_amethyst:amethyst_geode",
		},
		{
			"mcl_dungeons:monster_room",
			"mcl_dungeons:monster_room_deep",
		},
		{},
		{},
		{
			"mcl_levelgen:ore_dirt",
			"mcl_levelgen:ore_gravel",
			"mcl_levelgen:ore_granite_upper",
			"mcl_levelgen:ore_granite_lower",
			"mcl_levelgen:ore_diorite_upper",
			"mcl_levelgen:ore_diorite_lower",
			"mcl_levelgen:ore_andesite_upper",
			"mcl_levelgen:ore_andesite_lower",
			"mcl_levelgen:ore_tuff",
			"mcl_levelgen:ore_coal_upper",
			"mcl_levelgen:ore_coal_lower",
			"mcl_levelgen:ore_iron_upper",
			"mcl_levelgen:ore_iron_middle",
			"mcl_levelgen:ore_iron_small",
			"mcl_levelgen:ore_gold",
			"mcl_levelgen:ore_gold_lower",
			"mcl_levelgen:ore_redstone",
			"mcl_levelgen:ore_redstone_lower",
			"mcl_levelgen:ore_diamond",
			"mcl_levelgen:ore_diamond_medium",
			"mcl_levelgen:ore_diamond_large",
			"mcl_levelgen:ore_diamond_buried",
			"mcl_levelgen:ore_lapis",
			"mcl_levelgen:ore_lapis_buried",
			"mcl_levelgen:ore_copper",
			"mcl_levelgen:underwater_magma",
			"mcl_levelgen:ore_gold_extra",
			"mcl_levelgen:disk_sand",
			"mcl_levelgen:disk_clay",
			"mcl_levelgen:disk_gravel",
		},
		{},
		{
			"mcl_levelgen:spring_water",
			"mcl_levelgen:spring_lava",
		},
		{
			"mcl_levelgen:glow_lichen",
			"mcl_trees:trees_mesa",
			"mcl_levelgen:patch_grass_badlands",
			"mcl_levelgen:patch_dead_bush_badlands",
			"mcl_mushrooms:brown_mushroom_normal",
			"mcl_mushrooms:red_mushroom_normal",
			"mcl_farming:patch_sugar_cane_badlands",
			"mcl_farming:patch_pumpkin",
			"mcl_levelgen:patch_cactus_decorated",
		},
		{
			"mcl_levelgen:freeze_top_layer",
		},
	},
	has_precipitation = false,
	temperature = 2.000000,
	grass_palette_index = 19,
	groups = {
		is_badlands = true,
		is_overworld = true,
	},
	fog_color = "#c0d8ff",
	sky_color = "#6eb1ff",
})

------------------------------------------------------------------------
-- Biome groups.
------------------------------------------------------------------------

local function indexof (list, val)
	for i, v in ipairs (list) do
		if v == val then
			return i
		end
	end
	return -1
end

function mcl_levelgen.build_biome_list (id_or_group_list)
	local names = {}
	for _, id in ipairs (id_or_group_list) do
		if string.find (id, "#") == 1 then
			local group = string.sub (id, 2)
			for name, biome in pairs (registered_biomes) do
				if biome.groups[group]
					and indexof (names, name) == -1 then
					table.insert (names, name)
				end
			end
		else
			if not registered_biomes[id] then
				error ("Biome does not exist: " .. id)
			end
			if indexof (names, id) == -1 then
				table.insert (names, id)
			end
		end
	end
	return names
end

function mcl_levelgen.modify_biome_groups (biomes_or_groups, groups)
	for _, id in ipairs (mcl_levelgen.build_biome_list (biomes_or_groups)) do
		local biome = registered_biomes[id]
		assert (biome)

		for group, value in pairs (groups) do
			if biome.groups[group] ~= nil
				and biome.groups[group] ~= value then
				print (string.format ("Warning: overriding biome %s's `%s' group to `%s'",
						      id, group, tostring (value)))
			end
			biome.groups[group] = value
		end
	end
end

mcl_levelgen.modify_biome_groups ({ "#is_deep_ocean", }, {
	is_ocean = true,
	is_deep_ocean = true,
})

------------------------------------------------------------------------
-- Biome ID assignment and post-processing.
------------------------------------------------------------------------

local seed = mcl_levelgen.ull (0, 1234)
local rng = mcl_levelgen.jvm_random (seed)
-- N.B: Not to be confused with the `temperature' level generation noise.
local TEMPERATURE_NOISE
	= mcl_levelgen.make_simplex_noise (rng, { 0, })
local seed = mcl_levelgen.ull (0, 3456)
local rng = mcl_levelgen.jvm_random (seed)
local FROZEN_BIOME_NOISE
	= mcl_levelgen.make_simplex_noise (rng, { -2, -1, 0, })
local seed = mcl_levelgen.ull (0, 2345)
local rng = mcl_levelgen.jvm_random (seed)
local BIOME_SELECTOR_NOISE
	= mcl_levelgen.make_simplex_noise (rng, { 0, })
mcl_levelgen.BIOME_SELECTOR_NOISE = BIOME_SELECTOR_NOISE

-- luacheck: push ignore 511
if false then
	for x = -256, 255 do
		for z = -256, 255 do
			local value = TEMPERATURE_NOISE (x * 0.05, z * 0.05, false) * 7.0
			print (value)
		end
	end
end

if false then
	for x = -256, 255 do
		for z = -256, 255 do
			local value = FROZEN_BIOME_NOISE (x * 0.05, z * 0.05, false) * 7.0
			print (value)
		end
	end
end
--luacheck: pop

local mathmax = math.max
local registered_biomes_id = {}
local biome_id_callbacks = {}

mcl_levelgen.biome_name_to_id_map = biome_name_to_id_map
mcl_levelgen.biome_id_to_name_map = biome_id_to_name_map
mcl_levelgen.registered_biomes_id = registered_biomes_id

function mcl_levelgen.assign_biome_ids (assignments)
	local maxid = -1
	local isnew = {}

	for biome, id in pairs (assignments) do
		local biomedata = registered_biomes[biome]
		if biomedata then
			assert (id <= 255)
			biome_name_to_id_map[biome] = id
			biome_id_to_name_map[id] = biome
			registered_biomes_id[id] = biomedata
		end
		maxid = mathmax (maxid, id)
	end

	-- Assign IDs to biomes not in the map.
	for biome, data in pairs (registered_biomes) do
		if not biome_name_to_id_map[biome] then
			maxid = maxid + 1
			if maxid >= 255 then
				error ("Biome IDs exhausted")
			end
			biome_name_to_id_map[biome] = maxid
			biome_id_to_name_map[maxid] = biome
			registered_biomes_id[maxid] = data
			assignments[biome] = maxid
			isnew[maxid] = true
		end
	end

	verbose_print ("Biome ID assignments: ")
	verbose_print ("  (* = New ID assignment)")
	for id = 0, maxid do
		local name = biome_id_to_name_map[id]
		if name then
			verbose_print (string.format ("%3d%-2s%s", id,
						      isnew[id] and "*" or "",
						      name))
		end
	end

	for _, fn in ipairs (biome_id_callbacks) do
		fn ()
	end
end

function mcl_levelgen.register_on_biome_ids_available (fn)
	table.insert (biome_id_callbacks, fn)
end

-- Biome properties.

local function get_temperature_in_biome (biome, x, y, z)
	local biome = registered_biomes[biome]
	local temp = biome.temperature

	-- Apply temperature modifier.
	if biome.temperature_modifier == "frozen" then
		local temp_offset
			= FROZEN_BIOME_NOISE (x * 0.05, z * 0.05) * 7.0
		local selector = BIOME_SELECTOR_NOISE (x * 0.2, z * 0.2)
		if temp_offset + selector < 0.3 then
			local selector1 = BIOME_SELECTOR_NOISE (x * 0.09, z * 0.09)
			if selector1 < 0.8 then
				temp = 0.2
			end
		end
	end

	-- And altitude chill.
	if y > 80 then
		local chill = TEMPERATURE_NOISE (x / 8.0, z / 8.0) * 8.0
		return temp - (chill + y - 80) * 0.05 / 40
	end
	return temp
end

mcl_levelgen.get_temperature_in_biome = get_temperature_in_biome

local function is_temp_snowy (biome, x, y, z)
	local temp = get_temperature_in_biome (biome, x, y, z)
	return temp < 0.15
end

mcl_levelgen.is_temp_snowy = is_temp_snowy

local function is_temp_rainy (biome, x, y, z)
	local temp = get_temperature_in_biome (biome, x, y, z)
	return temp >= 0.15
end

mcl_levelgen.is_temp_rainy = is_temp_rainy

------------------------------------------------------------------------
-- Biome position randomization.
------------------------------------------------------------------------

local tmp, tmp1 = mcl_levelgen.ull (0, 0), mcl_levelgen.ull (0, 0)
local lcj_next = mcl_levelgen.lcj_next
local extkull = mcl_levelgen.extkull
local ashrull = mcl_levelgen.ashrull

local function munge_distance (seed, tqx, tqy, tqz, tpx, tpy, tpz)
	tmp[1], tmp[2] = seed[1], seed[2]
	local tmp1 = tmp1
	extkull (tmp1, tqx)
	lcj_next (tmp, tmp1)
	extkull (tmp1, tqy)
	lcj_next (tmp, tmp1)
	extkull (tmp1, tqz)
	lcj_next (tmp, tmp1)
	extkull (tmp1, tqx)
	lcj_next (tmp, tmp1)
	extkull (tmp1, tqy)
	lcj_next (tmp, tmp1)
	extkull (tmp1, tqz)
	lcj_next (tmp, tmp1)
	tmp1[1], tmp1[2] = tmp[1], tmp[2]
	ashrull (tmp1, 24)
	local bp = band (tmp1[1], 1023) / 1024.0
	local dx = (bp - 0.5) * 0.9

	lcj_next (tmp, seed)
	tmp1[1], tmp1[2] = tmp[1], tmp[2]
	ashrull (tmp1, 24)
	local bp = band (tmp1[1], 1023) / 1024.0
	local dy = (bp - 0.5) * 0.9

	lcj_next (tmp, seed)
	tmp1[1], tmp1[2] = tmp[1], tmp[2]
	ashrull (tmp1, 24)
	local bp = band (tmp1[1], 1023) / 1024.0
	local dz = (bp - 0.5) * 0.9
	return (tpz + dz) * (tpz + dz)
		+ (tpy + dy) * (tpy + dy)
		+ (tpx + dx) * (tpx + dx)
end

-- Return a displaced version of the quart position of the block
-- position X, Y, Z.  This position is lightly randomized and is not
-- consulted during biome generation, only when accessing generated
-- biome data.
--
-- Value is guaranteed to fall within one QuartBlock's distance of X,
-- Y, Z's absolute position on each axis.

function mcl_levelgen.munge_biome_coords (seed, x, y, z)
	x = x - 2
	y = y - 2
	z = z - 2
	local qx = arshift (x, 2)
	local qy = arshift (y, 2)
	local qz = arshift (z, 2)
	x = band (x, 3) / 4.0
	y = band (y, 3) / 4.0
	z = band (z, 3) / 4.0

	local nearest_transform = 0
	local max_distance = huge

	for i = 0, 7 do
		local dx = rshift (band (i, 4), 2)
		local dy = rshift (band (i, 2), 1)
		local dz = band (i, 1)
		local dist = munge_distance (seed, qx + dx, qy + dy,
					     qz + dz, x - dx, y - dy,
					     z - dz)
		if max_distance > dist then
			nearest_transform = i
			max_distance = dist
		end
	end

	x = rshift (band (nearest_transform, 4), 2)
	y = rshift (band (nearest_transform, 2), 1)
	z = band (nearest_transform, 1)
	return qx + x, qy + y, qz + z
end

if mcl_levelgen.detect_luajit () then
	local str = [[
	local tonumber = tonumber
	local rshift = bit.rshift
	local arshift = bit.arshift
	local lshift = bit.lshift
	local band = bit.band

	local function lcj_next (seed, increment)
		return seed * (seed * 0x5851f42d4c957f2dll
			       + 0x14057b7ef767814fll)
			+ increment
	end

	local function munge_one (value)
		local fixed = band (arshift (value, 24), 1023ll)
		local bp = tonumber (fixed) / 1024.0
		return (bp - 0.5) * 0.9
	end

	-- local munge_biome_coords = mcl_levelgen.munge_biome_coords
	-- local test_values = {}
	-- local ipos3 = mcl_levelgen.ipos3
	-- local seed = mcl_levelgen.ull (485850, 399343388)

	-- for x, y, z in ipos3 (-100, -100, -100, 100, 100, 100) do
	-- 	table.insert (test_values, { munge_biome_coords (seed, x, y, z) })
	-- 	-- if #test_values % 100000 == 0 then
	-- 	-- 	print (#test_values)
	-- 	-- end
	-- end

	local function munge_distance (seed, tqx, tqy, tqz, tpx, tpy, tpz)
		local seed = 0x100000000ll * seed[2] + seed[1]
		local increment = seed
		seed = lcj_next (seed, tqx * 1ll)
		seed = lcj_next (seed, tqy * 1ll)
		seed = lcj_next (seed, tqz * 1ll)
		seed = lcj_next (seed, tqx * 1ll)
		seed = lcj_next (seed, tqy * 1ll)
		seed = lcj_next (seed, tqz * 1ll)

		local dx = munge_one (seed)
		seed = lcj_next (seed, increment)
		local dy = munge_one (seed)
		seed = lcj_next (seed, increment)
		local dz = munge_one (seed)
		return (tpz + dz) * (tpz + dz)
			+ (tpy + dy) * (tpy + dy)
			+ (tpx + dx) * (tpx + dx)
	end

	-- local test_values_1 = {}
	-- for x, y, z in ipos3 (-100, -100, -100, 100, 100, 100) do
	-- 	table.insert (test_values_1, { munge_biome_coords (seed, x, y, z) })
	-- end
	-- for i = 1, #test_values do
	-- 	local x1, y1, z1 = unpack (test_values[i])
	-- 	local x2, y2, z2 = unpack (test_values_1[i])
	-- 	assert (x1 == x2)
	-- 	assert (y1 == y2)
	-- 	assert (z1 == z2)
	-- end
	return munge_distance
]]
	local fn = loadstring (str)
	munge_distance = fn ()
end

-- Convert a level seed SEED into a biome seed and return the result.

function mcl_levelgen.get_biome_seed (seed)
	local tmp = mcl_levelgen.ull (0, 0)
	mcl_levelgen.biomeseedull (tmp, seed)
	return tmp
end

------------------------------------------------------------------------
-- Biome locating.
------------------------------------------------------------------------

function mcl_levelgen.locate_biome_in_area (preset, x, y, z, radius, rng,
					    predicate, arg)
	local qx = toquart (x)
	local qz = toquart (z)
	local qy = toquart (y)
	local qradius = toquart (radius)
	local biome, pos_x, pos_z
	local cnt_matching = 0

	preset:index_biomes_begin (qradius * 2 + 1, qradius * 2 + 1,
				   qx - qradius, qz - qradius)
	for dz = -qradius, qradius do
		for dx = -qradius, qradius do
			local x, z = qx + dx, qz + dz
			local located_biome
				= preset:index_biomes_cached (x, qy, z)
			if predicate (located_biome, arg) then
			-- Select a random biome from within this area.
				if not biome or rng:next_within (cnt_matching + 1) == 0 then
					biome = located_biome
					pos_x = toblock (x)
					pos_z = toblock (z)
				end
				cnt_matching = cnt_matching + 1
			end
		end
	end
	return biome, pos_x, y, pos_z
end

local ipos2 = mcl_levelgen.ipos2

function mcl_levelgen.get_biomes_chebyshev (preset, x, y, z, r)
	local qx1 = toquart (x - r)
	local qy1 = toquart (y - r)
	local qz1 = toquart (z - r)
	local qx2 = toquart (x + r)
	local qy2 = toquart (y + r)
	local qz2 = toquart (z + r)

	preset:index_biomes_begin (qx2 - qx1 + 1, qz2 - qz1 + 1, qx1, qz1)
	local seen = {}
	local biomes = {}

	for qz, qx, qy in ipos2 (qz1, qx1, qy1, qz2, qx2, qy2) do
		local biome = preset:index_biomes_cached (qx, qy, qz)
		if not seen[biomes] then
			insert (biomes, biome)
		end
	end
	return biomes
end

-- https://old.reddit.com/r/technicalminecraft/comments/10cn3dv/how_is_world_spawn_determined/
-- https://maven.fabricmc.net/docs/yarn-1.20.4+build.1/net/minecraft/world/biome/source/util/MultiNoiseUtil.MultiNoiseSampler.html#findBestSpawnPosition()
-- Which appears to call methods in:
-- https://maven.fabricmc.net/docs/yarn-1.20.4+build.1/net/minecraft/world/biome/source/util/MultiNoiseUtil.FittestPositionFinder.html

local mathsin = math.sin
local mathcos = math.cos
local mathmin = math.min

local SPAWN_MALUS_START = 2500 * 2500
local SPAWN_PENALTY_VALUE = 10000 * 10000

local function spawn_distance (a, targets, x, z)
	-- Minecraft disregards depth.
	local depth = a[5]
	a[5] = 0
	local distance = distance_total (targets[1], a)
	for i = 2, #targets do
		local d = distance_total (targets[i], a)
		distance = mathmin (distance, d)
	end
	a[5] = depth

	-- Minecraft applies a penalty as the spawn position drifts
	-- further away from 0, 0.
	local d_scaled = (x * x + z * z) / SPAWN_MALUS_START
	local d_origin = rtz (d_scaled * d_scaled * SPAWN_PENALTY_VALUE)
	return distance + d_origin
end

local TWO_PI = math.pi * 2

local function find_fittest (in_dist, x, y, z, spawn_target,
			     dist_max, dist_increment, sample)
	local cur_dist = dist_increment
	local angle = 0.0
	local x1, z1 = x, z

	while cur_dist <= dist_max do
		local x = rtz (x + mathsin (angle) * cur_dist)
		local z = rtz (z + mathcos (angle) * cur_dist)
		local extents = sample (x, y, z)
		local dist = spawn_distance (extents, spawn_target, x, z)

		if dist < in_dist then
			in_dist = dist
			x1 = x
			z1 = z
		end

		angle = angle + dist_increment / cur_dist
		if angle > TWO_PI then
			angle = 0.0
			cur_dist = cur_dist + dist_increment
		end
	end
	return in_dist, x1, z1
end

function mcl_levelgen.biome_spawn_position (spawn_targets, y, sample)
	local x, z = 0, 0
	local packed = {}
	for i, target in ipairs (spawn_targets) do
		packed[i] = pack_extents_quantize (target)
	end
	local in_dist = spawn_distance (sample (x, y, z), packed, x, z)
	in_dist, x, z = find_fittest (in_dist, x, y, z, packed,
				      2048.0, 512.0, sample)
	in_dist, x, z = find_fittest (in_dist, x, y, z, packed,
				      512.0, 32.0, sample)
	return x, z, in_dist
end

local function vertical_search_positions (center, interval, y_min, y_max)
	local dist_min = center - y_min + 1
	local dist_max = y_max - center + 1
	local r = mathmax (floor (dist_min / interval),
			   floor (dist_max / interval))
	local list = { center, }

	for i = 1, r do
		local kbelow = center - i * interval
		local kabove = center + i * interval

		if kbelow >= y_min then
			insert (list, kbelow)
		end
		if kabove <= y_max then
			insert (list, kabove)
		end
	end
	return list
end

local ispiral1 = mcl_levelgen.ispiral1

function mcl_levelgen.locate_biome_spirally (preset, x, y, z, radius, horiz_interval,
					     vert_interval, predicate, data)
	local r = floor (radius / horiz_interval)
	local search_ys
	-- NOTE: Minecraft's /locate command apparently forgoes the
	-- -64 layer.
		= vertical_search_positions (y, vert_interval, preset.min_y + 1,
					     preset.min_y + preset.height - 1)
	for dx, dz in ispiral1 (0, 0, r) do
		local x = dx * horiz_interval + x
		local qx = toquart (x)
		local z = dz * horiz_interval + z
		local qz = toquart (z)

		preset:index_biomes_begin (1, 1, qx, qz)
		for _, y in ipairs (search_ys) do
			local qy = toquart (y)
			local biome = preset:index_biomes_cached (qx, qy, qz)
			if predicate (biome, data) then
				return x, y, z
			end
		end
	end
	return nil
end

------------------------------------------------------------------------
-- Biome utilities.  These duplicate functions in mcl_biome_dispatch,
-- but are defined here so that they may be available in async
-- environments.
------------------------------------------------------------------------

local test_dispatchers = {
	[0] = function ()
		return function ()
			return false
		end
	end,
	function (a)
		return function (biome)
			return biome == a
		end
	end,
	function (a, b)
		return function (biome)
			return biome == a or biome == b
		end
	end,
	function (a, b, c)
		return function (biome)
			return biome == a
				or biome == b
				or biome == c
		end
	end,
	function (a, b, c, d)
		return function (biome)
			return biome == a
				or biome == b
				or biome == c
				or biome == d
		end
	end,
	function (a, b, c, d, e)
		return function (biome)
			return biome == a
				or biome == b
				or biome == c
				or biome == d
				or biome == e
		end
	end,
	function (a, b, c, d, e, f)
		return function (biome)
			return biome == a
				or biome == b
				or biome == c
				or biome == d
				or biome == e
				or biome == f
		end
	end,
	function (a, b, c, d, e, f, g)
		return function (biome)
			return biome == a
				or biome == b
				or biome == c
				or biome == d
				or biome == e
				or biome == f
				or biome == g
		end
	end,
	function (a, b, c, d, e, f, g, h)
		return function (biome)
			return biome == a
				or biome == b
				or biome == c
				or biome == d
				or biome == e
				or biome == f
				or biome == g
				or biome == h
		end
	end,
}

local function test_dispatcher_generic (...)
	local args = {...}
	return function (biome)
		for _, biome1 in ipairs (args) do
			if biome == biome1 then
				return true
			end
		end
		return false
	end
end

function mcl_levelgen.make_biome_test (ids_or_tags)
	local list = mcl_levelgen.build_biome_list (ids_or_tags)
	return (test_dispatchers[#list] or test_dispatcher_generic) (unpack (list))
end
