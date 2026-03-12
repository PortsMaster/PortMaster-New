------------------------------------------------------------------------
-- Luanti map generator adapter (a.k.a. "ersatz levels").
--
-- This module implements interfaces which adapt the structure
-- generators in mcl_levelgen to Luanti's objectively inferior
-- built-in map generators.
--
-- It follows from the inferiority of the built-in map generators that
-- there are certain caveats to be born in mind when enabling these
-- facilities or implementing structures.  To wit:
--
--   - It is not possible to read the entire vertical section of the
--     map within piece placement functions.
--
--   - Terrain heights must be derived from reimplementations of the
--     built-in map generators in Lua and may therefore be incorrect
--     or downright unavailable if the map generator in use is not yet
--     implemented.
--
--   - Biome data is not reliably available and in any event would not
--     adapt to terrain.
--
--   - No control is afforded over structures' interactions with
--     engine decorations.
--
-- Caveat emptor!
------------------------------------------------------------------------

local ipairs = ipairs
local pairs = pairs

------------------------------------------------------------------------
-- Ersatz environment initialization.
------------------------------------------------------------------------

local ersatz_biome_translations = {}

-- Assign biome IDs, though their values are insigificant.
mcl_levelgen.assign_biome_ids ({})

-- Translate biomes that are frequently considered significant by
-- structure generators.

function mcl_levelgen.ersatz_translate_biome (id)
	return ersatz_biome_translations[id]
end

local overworld_subtypes = {
	"_shore",
	"_beach",
	"_ocean",
	"_deep_ocean",
	"_sandlevel",
	"_snowtop",
	"_beach_water",
	"_underground",
	"_deep_underground",
}

local biome_specific_overrides = {}
biome_specific_overrides[0] = {}

local function maybe_map_biome (biome, target)
	local id = core.get_biome_id (biome)
	if id then
		ersatz_biome_translations[id] = target
	end
end

local function init_ersatz_biome_translations ()
	local ersatz_biome_map = {
		-- Nether.
		["BasaltDelta"] = "BasaltDeltas",
		["CrimsonForest"] = "CrimsonForest",
		["Nether"] = "NetherWastes",
		["SoulsandValley"] = "SoulSandValley",
		["WarpedForest"] = "WarpedForest",

		-- Overworld.
		["BambooJungle"] = "BambooJungle",
		["BirchForest"] = "BirchForest",
		["BirchForestM"] = "OldGrowthBirchForest",
		["ColdTaiga"] = "SnowyTaiga",
		["DeepDark"] = "DeepDark",
		["Desert"] = "Desert",
		["DripstoneCave"] = "DripstoneCaves",
		["ExtremeHills"] = "WindsweptHills",
		["ExtremeHills+"] = "WindsweptHills",
		["ExtremeHillsM"] = "WindsweptGravellyHills",
		["FlowerForest"] = "FlowerForest",
		["Forest"] = "Forest",
		["FrozenPeaks"] = "FrozenPeaks",
		["Grove"] = "Grove",
		["IcePlains"] = "SnowyPlains",
		["IcePlainsSpikes"] = "IceSpikes",
		["JaggedPeaks"] = "JaggedPeaks",
		["Jungle"] = "Jungle",
		["JungleEdge"] = "SparseJungle",
		["JungleEdgeM"] = "SparseJungle",
		["JungleM"] = "Jungle",
		["LushCaves"] = "LushCaves",
		["MangroveSwamp"] = "MangroveSwamp",
		["Meadow"] = "Meadow",
		["MegaSpruceTaiga"] = "OldGrowthSpruceTaiga",
		["MegaTaiga"] = "OldGrowthPineTaiga",
		["Mesa"] = "Mesa",
		["MesaBryce"] = "ErodedMesa",
		["MesaPlateauF"] = "WoodedMesa",
		["MesaPlateauFM"] = "WoodedMesa",
		["MushroomIsland"] = "MushroomIslands",
		["Plains"] = "Plains",
		["RoofedForest"] = "DarkForest",
		["Savanna"] = "Savannah",
		["SavannaM"] = "Savannah",
		["SnowySlopes"] = "SnowySlopes",
		["StoneBeach"] = "StonyShore",
		["StonyPeaks"] = "StonyPeaks",
		["SunflowerPlains"] = "SunflowerPlains",
		["Swampland"] = "Swamp",
		["Taiga"] = "Taiga",

		--- The End.
		["End"] = "TheEnd",
		["EndBarrens"] = "EndBarrens",
		["EndBorder"] = "TheEnd",
		["EndHighlands"] = "EndHighlands",
		["EndIsland"] = "TheEnd",
		["EndMidlands"] = "EndMidlands",
		["EndSmallIslands"] = "EndSmallIslands",
	}

	for biome, target in pairs (ersatz_biome_map) do
		maybe_map_biome (biome, target)
		for _, subtype in ipairs (overworld_subtypes) do
			maybe_map_biome (biome .. subtype, target)
		end
	end

	local cold_biome_overrides = {
		["Ocean"] = "ColdOcean",
		["DeepOcean"] = "DeepColdOcean",
	}
	local snowy_biome_overrides = {
		["Ocean"] = "FrozenOcean",
		["DeepOcean"] = "DeepFrozenOcean",
	}
	local hot_biome_overrides = {
		["Ocean"] = "WarmOcean",
		["DeepOcean"] = "LukewarmOcean",
	}
	local default_biome_overrides = {
		["Ocean"] = "Ocean",
		["DeepOcean"] = "DeepOcean",
	}

	for biome, def in pairs (core.registered_biomes) do
		local id = core.get_biome_id (biome)
		assert (id)
		if def._mcl_biome_type == "cold" then
			biome_specific_overrides[id] = cold_biome_overrides
		elseif def._mcl_biome_type == "hot" then
			biome_specific_overrides[id] = hot_biome_overrides
		elseif def._mcl_biome_type == "snowy" then
			biome_specific_overrides[id] = snowy_biome_overrides
		else
			biome_specific_overrides[id] = default_biome_overrides
		end
	end
end

-- Disable decorations; they must be placed after structures in
-- mg_ersatz.lua.
if core.set_mapgen_setting then
	local str = core.get_mapgen_setting ("mg_flags")
	local flags = string.split (str, ",", false)
	for i, flag in ipairs (flags) do
		if flag:find ("decorations") then
			flags[i] = "nodecorations"
		end
	end
	core.set_mapgen_setting ("mg_flags", table.concat (flags, ","), true)
end

core.register_on_mods_loaded (init_ersatz_biome_translations)

------------------------------------------------------------------------
-- Ersatz dimensions.
------------------------------------------------------------------------

-- Register ersatz dimensions.
dofile (mcl_levelgen.prefix .. "/dimensions.lua")

local v = vector.zero ()
local mg_overworld_min = mcl_vars.mg_overworld_min
local toblock = mcl_levelgen.toblock
local mapgen_model

local ersatz_overworld_min_y = -64
local ersatz_overworld_sea_level = 65
local ersatz_overworld_y_offset = -64

if mcl_vars.mg_is_classic_superflat then
	ersatz_overworld_min_y = mcl_vars.mg_overworld_min
	ersatz_overworld_sea_level = 7
	ersatz_overworld_y_offset = 0
end

local ersatz_preset_template_overworld = table.merge (mcl_levelgen.level_preset_template, {
	min_y = ersatz_overworld_min_y,
	height = 384,
	sea_level = ersatz_overworld_sea_level,
	ersatz_default_height = 65,
	index_biomes_block = function (self, x, y, z)
		v.x = x
		v.z = -z - 1
		v.y = y - ersatz_overworld_y_offset + mg_overworld_min
		if mapgen_model then
			local override = mapgen_model.get_biome_override (x, -z - 1)
			if override then
				local data = core.get_biome_data (v)
				return biome_specific_overrides[data.biome][override]
					or override
			end
		end
		local data = core.get_biome_data (v)
		if data then
			return ersatz_biome_translations[data.biome] or "Plains"
		else
			return "Plains"
		end
	end,
	index_biomes_begin = function (self, wx, wz, xorigin, zorigin)
	end,
	index_biomes_cached = function (self, x, y, z)
		v.x = toblock (x)
		v.z = -toblock (z) - 1
		v.y = toblock (y) - ersatz_overworld_y_offset + mg_overworld_min
		if mapgen_model then
			local override = mapgen_model.get_biome_override (v.x, v.z)
			if override then
				local data = core.get_biome_data (v)
				return biome_specific_overrides[data.biome][override]
					or override
			end
		end
		local data = core.get_biome_data (v)
		if data then
			return ersatz_biome_translations[data.biome] or "Plains"
		else
			return "Plains"
		end
	end,
	index_biomes = function (self, x, y, z)
		v.x = toblock (x)
		v.z = -toblock (z) - 1
		v.y = toblock (y) - ersatz_overworld_y_offset + mg_overworld_min
		if mapgen_model then
			local override = mapgen_model.get_biome_override (v.x, v.z)
			if override then
				local data = core.get_biome_data (v)
				return biome_specific_overrides[data.biome][override]
					or override
			end
		end
		local data = core.get_biome_data (v)
		if data then
			return ersatz_biome_translations[data.biome] or "Plains"
		else
			return "Plains"
		end
	end,
	generated_biomes = function (self)
		return self.all_biomes
	end,
	all_biomes = {
		"BambooJungle",
		"BirchForest",
		"DarkForest",
		"DeepDark",
		"DeepOcean",
		"Desert",
		"DripstoneCaves",
		"ErodedMesa",
		"FlowerForest",
		"Forest",
		"FrozenPeaks",
		"IceSpikes",
		"JaggedPeaks",
		"Jungle",
		"MangroveSwamp",
		"Meadow",
		"Mesa",
		"MushroomIslands",
		"Ocean",
		"OldGrowthBirchForest",
		"OldGrowthPineTaiga",
		"OldGrowthSpruceTaiga",
		"Plains",
		"Savannah",
		"SnowyPlains",
		"SnowySlopes",
		"SnowyTaiga",
		"SparseJungle",
		"StonyPeaks",
		"StonyShore",
		"SunflowerPlains",
		"Swamp",
		"Taiga",
		"WindsweptGravellyHills",
		"WindsweptHills",
		"WoodedMesa",
	},
	aquifers_enabled = true,
})

local mg_nether_min = mcl_vars.mg_nether_min

local ersatz_preset_template_nether = table.merge (mcl_levelgen.level_preset_template, {
	min_y = 0,
	height = 128,
	sea_level = 32,
	ersatz_default_height = 129,
	default_block = "mcl_nether:netherrack",
	default_fluid = "mcl_nether:nether_lava_source",
	index_biomes_block = function (self, x, y, z)
		v.x = x
		v.z = -z - 1
		v.y = y + mg_nether_min
		return ersatz_biome_translations[core.get_biome_data (v).biome]
			or "NetherWastes"
	end,
	index_biomes_begin = function (self, wx, wz, xorigin, zorigin)
	end,
	index_biomes_cached = function (self, x, y, z)
		v.x = toblock (x)
		v.z = -toblock (z) - 1
		v.y = toblock (y) + mg_nether_min
		return ersatz_biome_translations[core.get_biome_data (v).biome]
			or "NetherWastes"
	end,
	index_biomes = function (self, x, y, z)
		v.x = toblock (x)
		v.z = -toblock (z) - 1
		v.y = toblock (y) + mg_nether_min
		return ersatz_biome_translations[core.get_biome_data (v).biome]
			or "NetherWastes"
	end,
	generated_biomes = function (self)
		return self.all_biomes
	end,
	all_biomes = {
		"BasaltDeltas",
		"CrimsonForest",
		"NetherWastes",
		"SoulSandValley",
		"WarpedForest",
	},
})

local mg_end_min = mcl_vars.mg_end_min

local ersatz_preset_template_end = table.merge (mcl_levelgen.level_preset_template, {
	min_y = 0,
	height = 128,
	sea_level = 0,
	default_block = "mcl_end:end_stone",
	default_fluid = "air",
	ersatz_default_height = 75,
	index_biomes_block = function (self, x, y, z)
		v.x = x
		v.z = -z - 1
		v.y = y + mg_end_min
		return ersatz_biome_translations[core.get_biome_data (v).biome]
			or "TheEnd"
	end,
	index_biomes_begin = function (self, wx, wz, xorigin, zorigin)
	end,
	index_biomes_cached = function (self, x, y, z)
		v.x = toblock (x)
		v.z = -toblock (z) - 1
		v.y = toblock (y) + mg_end_min
		return ersatz_biome_translations[core.get_biome_data (v).biome]
			or "TheEnd"
	end,
	index_biomes = function (self, x, y, z)
		v.x = toblock (x)
		v.z = -toblock (z) - 1
		v.y = toblock (y) + mg_end_min
		return ersatz_biome_translations[core.get_biome_data (v).biome]
			or "TheEnd"
	end,
	generated_biomes = function (self)
		return self.all_biomes
	end,
	all_biomes = {
		"EndBarrens",
		"EndHighlands",
		"EndMidlands",
		"EndSmallIslands",
		"TheEnd",
	},
})

local function make_ersatz_preset (template, seed)
	local preset = mcl_levelgen.copy_preset (template)
	mcl_levelgen.initialize_random (preset, seed)
	return preset
end

mcl_levelgen.register_dimension ("mcl_levelgen:overworld", {
	y_global = mcl_vars.mg_overworld_min,
	data_namespace = 0,
	create_preset = function (self, seed)
		return make_ersatz_preset (ersatz_preset_template_overworld, seed)
	end,
	no_lighting = false,
})

mcl_levelgen.register_dimension ("mcl_levelgen:nether", {
	y_global = mcl_vars.mg_nether_min,
	data_namespace = 1,
	create_preset = function (self, seed)
		return make_ersatz_preset (ersatz_preset_template_nether, seed)
	end,
	no_lighting = false,
})

mcl_levelgen.register_dimension ("mcl_levelgen:end", {
	y_global = mcl_vars.mg_end_min,
	data_namespace = 2,
	create_preset = function (self, seed)
		return make_ersatz_preset (ersatz_preset_template_end, seed)
	end,
	no_lighting = false,
})

mcl_levelgen.initialize_dimensions (mcl_levelgen.seed)

------------------------------------------------------------------------
-- Ersatz post-processing.
------------------------------------------------------------------------

if core and core.get_mod_storage then -- Main environment.

dofile (mcl_levelgen.prefix .. "/areastore.lua")

local y_offset = nil

core.set_gen_notify ({ custom = true, }, nil, {
	"mcl_levelgen:structure_pieces",
	"mcl_levelgen:gen_notifies",
})

local registered_notification_handlers = {}
local warned = {}
local save_structure_pieces = mcl_levelgen.save_structure_pieces

mcl_levelgen.registered_notification_handlers
	= registered_notification_handlers

function mcl_levelgen.register_notification_handler (name, handler)
	assert (type (name) == "string")
	registered_notification_handlers[name] = handler
end

local function run_notification_handlers (gen_notifies)
	if gen_notifies then
		for _, notify in ipairs (gen_notifies) do
			local name = notify.name
			local handler = registered_notification_handlers[name]
			if not handler and not warned[name] then
				warned[name] = true
				core.log ("warning", "Invoking unknown feature generation handler: " .. name)
			elseif handler then
				handler (notify.name, notify.data)
			end
		end
	end
end

local function post_process_mapchunk_in_dim (minp, maxp, dim)
	local custom = core.get_mapgen_object ("gennotify").custom
	y_offset = dim.y_offset
	run_notification_handlers (custom["mcl_levelgen:gen_notifies"])
	y_offset = nil
	local pieces = custom["mcl_levelgen:structure_pieces"]
	if pieces then
		save_structure_pieces (pieces)
	end
end

local dims_intersecting = mcl_levelgen.dims_intersecting
local temp_min, temp_max = vector.zero (), vector.zero ()

local function post_process_mapchunk (minp, maxp)
	local generated = false
	for y1, y2, ystart, yend, dim in dims_intersecting (minp.y, maxp.y) do
		if generated then
			break
		end

		temp_min.x = minp.x
		temp_min.z = minp.z
		temp_min.y = y1
		temp_max.x = maxp.x
		temp_max.z = maxp.z
		temp_max.y = y2
		post_process_mapchunk_in_dim (temp_min, temp_max, dim)
		generated = true
	end
end

core.register_on_generated (post_process_mapchunk)

function mcl_levelgen.level_to_minetest_position (x, y, z)
	if y_offset then
		return x, y - y_offset, -z - 1
	else
		-- Don't convert Y positions if no dimension currently
		-- exists; this is exercised by structure blocks.
		return x, y, -z - 1
	end
end
end

------------------------------------------------------------------------
-- Ersatz terrain generator object.
------------------------------------------------------------------------

local mt_chunksize = core.ipc_get ("mcl_levelgen:mt_chunksize")

local mathmin = math.min
local mathmax = math.max
local floor = math.floor
local ceil = math.ceil

local cid_air = core.CONTENT_AIR

local chunksize = mt_chunksize.x * 16
local ychunksize = mt_chunksize.y * 16
local y_offset

local ull = mcl_levelgen.ull

local ersatz_terrain = {
	chunksize = chunksize,
	chunksize_y = ychunksize,
	preset = nil,
	biome_seed = ull (0, 0),
	is_ersatz = true,
}
mcl_levelgen.ersatz_terrain = ersatz_terrain

local cid_water_source

core.register_on_mods_loaded (function ()
	cid_water_source = core.get_content_id ("mcl_core:water_source")
end)

function ersatz_terrain:get_one_height (x, z, is_solid)
	if mapgen_model then
		local water_solid_p
			= is_solid and is_solid (cid_water_source, 0)
		return mapgen_model.get_column_height (x, -z - 1,
						       water_solid_p)
			+ y_offset
	end
	return self.preset.ersatz_default_height
end

function ersatz_terrain:area_heightmap (x1, z1, x2, z2, heightmap, is_solid)
	local w = x2 - x1 + 1
	local l = z2 - z1 + 1
	local total = w * l

	if mapgen_model then
		local water_solid_p
			= is_solid and is_solid (cid_water_source, 0)
		local get_column_height = mapgen_model.get_column_height
		for i = 1, total do
			local dx = floor ((i - 1) / l)
			local dz = (i - 1) % l
			heightmap[i] = get_column_height (dx + x1, -(dz + z1) - 1,
							  water_solid_p)
				+ y_offset
		end
	else
		local default = self.preset.ersatz_default_height
		for i = 1, total do
			heightmap[i] = default
		end
	end
	return total
end

local tmp_heightmap = {}

function ersatz_terrain:area_min_height (x1, z1, x2, z2, is_solid)
	local heightmap = tmp_heightmap
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

function ersatz_terrain:area_average_height (x1, z1, x2, z2, is_solid)
	local heightmap = tmp_heightmap
	local total = self:area_heightmap (x1, z1, x2, z2, heightmap,
					   is_solid)
	local value = heightmap[1]
	for i = 2, total do
		value = value + heightmap[i]
	end
	return rtz (value / total)
end

local encode_node = mcl_levelgen.encode_node

function ersatz_terrain:get_one_column (x, z, column_data)
	local preset = self.preset
	local level_height = preset.height
	local y_min = preset.min_y
	local height = self:get_one_height (x, z)
	local default_block = encode_node (self.cid_default_block, 0)
	local air = encode_node (cid_air, 0)
	for i = 1, level_height do
		if i + y_min >= height then
			column_data[i] = air
		else
			column_data[i] = default_block
		end
	end
	column_data[level_height + 1] = nil
	return column_data
end

local structure_levels = {}
local aquifers = {}

local function create_structure_level (dim)
	if not structure_levels[dim] then
		structure_levels[dim]
			= mcl_levelgen.make_structure_level (dim.preset)
	end
	return structure_levels[dim]
end

local function create_aquifer (dim, ersatz_terrain)
	if not aquifers[dim] then
		-- NOTE: ERSATZ_TERRAIN is not copied.
		local fn = dim.preset.aquifers_enabled
			and mcl_levelgen.create_ersatz_aquifer
			or mcl_levelgen.create_placeholder_aquifer
		aquifers[dim] = fn (dim.preset, ersatz_terrain)
	end
	return aquifers[dim]
end

local ersatz_surface_system = {}
local mg_overworld_min = mcl_vars.mg_overworld_min
local mg_overworld_max = mcl_vars.mg_overworld_max

function mcl_levelgen.get_ersatz_terrain (dim)
	local preset = dim.preset
	local y_global = dim.y_global
	y_offset = preset.min_y - y_global
	if y_global >= mg_overworld_min
		and y_global <= mg_overworld_max  then
		mapgen_model = mcl_mapgen_models.get_mapgen_model ()
	else
		mapgen_model = nil
	end
	ersatz_terrain.preset = preset
	ersatz_terrain.cid_default_block
		= core.get_content_id (preset.default_block)
	ersatz_terrain.chunksize_y = ychunksize
	ersatz_terrain.structures = create_structure_level (dim)
	ersatz_terrain.aquifer = create_aquifer (dim, ersatz_terrain)
	ersatz_terrain.surface_system = ersatz_surface_system
	return ersatz_terrain
end

------------------------------------------------------------------------
-- Ersatz aquifer object.
------------------------------------------------------------------------

local ersatz_aquifer = table.copy (mcl_levelgen.aquifer)

local SURFACE_SAMPLE_INTERVAL = 8
local SURFACE_SAMPLE_SHIFT = 3
local SURFACE_CENTER = floor (SURFACE_SAMPLE_INTERVAL / 2)
local cache_width = chunksize / SURFACE_SAMPLE_INTERVAL + 2
assert (cache_width == floor (cache_width))

local arshift = bit.arshift
local band = bit.band

local origin_x
local origin_z

local lerp2d = mcl_levelgen.lerp2d

function ersatz_aquifer:reseat (min_x, min_y, min_z)
	if not mapgen_model then
		return
	end

	origin_x = min_x
	origin_z = min_z
	local cache = self.surface_height_cache
	for dx = 0, cache_width do
		for dz = 0, cache_width do
			local x = (dx - 1) * SURFACE_SAMPLE_INTERVAL
				+ SURFACE_CENTER + min_x
			local z = (dz - 1) * SURFACE_SAMPLE_INTERVAL
				+ SURFACE_CENTER + min_z
			local height = mapgen_model.get_column_height (x, -z - 1, false)
				+ y_offset
			cache[dx * cache_width + dz + 1] = height
		end
	end
end

local sqrt = math.sqrt

local function aquifer_height (self, gx, gz)
	return self.surface_height_cache[gx * cache_width + gz + 1]
end

local function aquifer_floodedness (self, gx, gz)
	local height = self.surface_height_cache[gx * cache_width + gz + 1]
	if height <= self.sea_level then
		return 1.0
	else
		return 1.0 - sqrt (mathmin (height - self.sea_level, 8.0) / 8.0)
	end
end

local function aquifer_lerp_values (self, gx1, gz1, gx2, gz2, x, z)
	local x1 = (gx1 - 1) * SURFACE_SAMPLE_INTERVAL + SURFACE_CENTER
	local z1 = (gz1 - 1) * SURFACE_SAMPLE_INTERVAL + SURFACE_CENTER
	local x_progress = (x - x1) / SURFACE_SAMPLE_INTERVAL
	local z_progress = (z - z1) / SURFACE_SAMPLE_INTERVAL
	return lerp2d (x_progress, z_progress,
		       aquifer_floodedness (self, gx1, gz1),
		       aquifer_floodedness (self, gx2, gz1),
		       aquifer_floodedness (self, gx1, gz2),
		       aquifer_floodedness (self, gx2, gz2)),
		lerp2d (x_progress, z_progress,
			aquifer_height (self, gx1, gz1),
			aquifer_height (self, gx2, gz1),
			aquifer_height (self, gx1, gz2),
			aquifer_height (self, gx2, gz2))
end

function ersatz_aquifer:get_node (x, y, z, density)
	local gx1 = arshift (x - origin_x, SURFACE_SAMPLE_SHIFT) + 1
	local gz1 = arshift (z - origin_z, SURFACE_SAMPLE_SHIFT) + 1
	local gx2 = band (x - origin_x, SURFACE_SAMPLE_INTERVAL - 1) > SURFACE_CENTER
		and gx1 + 1 or gx1 - 1
	local gz2 = band (z - origin_z, SURFACE_SAMPLE_INTERVAL - 1) > SURFACE_CENTER
		and gz1 + 1 or gz1 - 1
	local floodedness, height
		= aquifer_lerp_values (self, mathmin (gx1, gx2),
				       mathmin (gz1, gz2),
				       mathmax (gx1, gx2),
				       mathmax (gz1, gz2),
				       x - origin_x,
				       z - origin_z)
	if y <= self.sea_level then
		local surface_distance = mathmax (0.0, (height - y) / 45.0)
		local value = floodedness - surface_distance
		if value > 0.6 then
			return self.cid_default_fluid, 0
		elseif value > 0.45 then
			return self.cid_default_block, 0
		end
	end
	return cid_air, 0
end

function mcl_levelgen.create_ersatz_aquifer (preset, terrain_generator)
	local aquifer = table.copy (ersatz_aquifer)
	aquifer:initialize (preset)
	aquifer.surface_height_cache = {}
	aquifer.terrain = terrain_generator
	return aquifer
end

local placeholder_aquifer = table.copy (mcl_levelgen.aquifer)

function placeholder_aquifer:get_node (x, y, z, density)
	return cid_air, 0
end

function mcl_levelgen.create_placeholder_aquifer (preset, _)
	local aquifer = table.copy (placeholder_aquifer)
	aquifer:initialize (preset)
	return aquifer
end

------------------------------------------------------------------------
-- Ersatz surface system.
------------------------------------------------------------------------

-- This stub exists only to facilitate replacing exposed dirt blocks
-- previously covered with grass or mycelium with appropriate
-- substitutes.

local ersatz_biomes

function ersatz_surface_system:initialize_for_carver (biomes, heightmap,
						      bx, bz, chunksize,
						      terrain)
	ersatz_biomes = biomes
end

local ersatz_biomemap_index
local cid_mycelium_encoded
local cid_grass

core.register_on_mods_loaded (function ()
	local cid_mycelium = core.get_content_id ("mcl_core:mycelium")
	cid_grass = core.get_content_id ("mcl_core:dirt_with_grass")
	cid_mycelium_encoded = encode_node (cid_mycelium, 0)
end)

local registered_biomes = mcl_levelgen.registered_biomes

function ersatz_surface_system:evaluate_for_carver (x, y, z, submerged)
	local biome = ersatz_biomes[ersatz_biomemap_index (x, z)]
	if biome == "MushroomIslands" then
		return cid_mycelium_encoded
	else
		local def = registered_biomes[biome]
		local param2 = def and def.grass_palette_index or 0
		return encode_node (cid_grass, param2)
	end
end

------------------------------------------------------------------------
-- Jigsaw Block registration.
------------------------------------------------------------------------

if core and core.register_node then
	dofile (mcl_levelgen.prefix .. "/jigsaw.lua")
end

------------------------------------------------------------------------
-- Ersatz mapgen registration.
------------------------------------------------------------------------

if core and core.register_mapgen_script then
	core.register_mapgen_script (mcl_levelgen.prefix .. "/init.lua")
	if not mcl_vars.mg_is_classic_superflat then
		dofile (mcl_levelgen.prefix .. "/ersatz_structures.lua")
		mcl_levelgen.register_levelgen_script ((mcl_levelgen.prefix
							.. "/ersatz_structures.lua"), true)
	else
		dofile (mcl_levelgen.prefix .. "/data_register.lua")
		mcl_levelgen.register_levelgen_script ((mcl_levelgen.prefix
							.. "/data_register.lua"), true)
	end
end
if core and not core.get_mod_storage then
	dofile (mcl_levelgen.prefix .. "/mg_ersatz.lua")
	ersatz_biomemap_index = mcl_levelgen.ersatz_biomemap_index
end
