local ipairs = ipairs
local pairs = pairs
local S, PS = core.get_translator (core.get_current_modname ())

mcl_biome_dispatch = {}

------------------------------------------------------------------------
-- Biome system abstraction layer.
------------------------------------------------------------------------

local levelgen_enabled = mcl_levelgen.levelgen_enabled
local get_biome = mcl_levelgen.get_biome

function mcl_biome_dispatch.get_biome_name (v)
	if levelgen_enabled then
		return get_biome (v, true)
	else
		local data = core.get_biome_data (v)
		return core.get_biome_name (data.biome)
	end
end

function mcl_biome_dispatch.get_biome_name_nosample (v)
	if levelgen_enabled then
		return get_biome (v, false)
	else
		local data = core.get_biome_data (v)
		return core.get_biome_name (data.biome)
	end
end

local is_temp_snowy = mcl_levelgen.is_temp_snowy
local registered_biomes = mcl_levelgen.registered_biomes
local conv_pos_raw = mcl_levelgen.conv_pos_raw
local get_temperature_in_biome = mcl_levelgen.get_temperature_in_biome

function mcl_biome_dispatch.is_position_cold (biome_name, v)
	if levelgen_enabled and biome_name then
		local x, y, z, _ = conv_pos_raw (v)
		return x and is_temp_snowy (biome_name, x, y, z)
	elseif biome_name then
		local data = core.registered_biomes[biome_name]
		if data and data._mcl_biome_type == "snowy" then
			return true
		elseif data and data._mcl_biome_type == "cold" then
			return biome_name == "Taiga" and v.y > 140
				or biome_name == "MegaSpruceTaiga" and v.y > 100
		end
	end
	return false
end

function mcl_biome_dispatch.is_position_arid (biome_name)
	if not biome_name then
		return false
	elseif levelgen_enabled then
		local data = registered_biomes[biome_name]
		return not data.has_precipitation
	else
		local data = core.registered_biomes[biome_name]
		return data and data._mcl_biome_type == "hot"
	end
end

function mcl_biome_dispatch.get_sky_color (pos)
	if levelgen_enabled then
		local biome = get_biome (pos, false)
		if biome then
			local data = registered_biomes[biome]
			return data.sky_color
		end
	else
		local biome_index = core.get_biome_data (pos).biome
		local biome_name = core.get_biome_name (biome_index)
		local biome = core.registered_biomes[biome_name]
		return biome and biome._mcl_skycolor
	end
	return false
end

function mcl_biome_dispatch.get_fog_color (pos)
	if levelgen_enabled then
		local biome = get_biome (pos, false)
		if biome then
			local data = registered_biomes[biome]
			return data.fog_color
		end
	else
		local biome_index = core.get_biome_data (pos).biome
		local biome_name = core.get_biome_name (biome_index)
		local biome = core.registered_biomes[biome_name]
		return biome and biome._mcl_fogcolor
	end
	return false
end

function mcl_biome_dispatch.get_sky_and_fog_colors (pos)
	if levelgen_enabled then
		local biome = get_biome (pos, false)
		if biome then
			local data = registered_biomes[biome]
			return data.sky_color, data.fog_color
		end
	else
		local biome_index = core.get_biome_data (pos).biome
		local biome_name = core.get_biome_name (biome_index)
		local biome = core.registered_biomes[biome_name]
		if biome then
			return biome._mcl_skycolor, biome._mcl_fogcolor
		end
	end
	return false
end

function mcl_biome_dispatch.get_temperature_in_biome (biome_name, v)
	if levelgen_enabled and biome_name then
		local x, y, z, _ = conv_pos_raw (v)
		return x and get_temperature_in_biome (biome_name, x, y, z)
			or 1.0
	else
		local data = core.registered_biomes[biome_name]
		if data and data._mcl_biome_type == "snowy" then
			return 0.0
		elseif data and data._mcl_biome_type == "cold" then
			return 0.5
		elseif data and data._mcl_biome_type ~= "hot" then
			return 1.0
		elseif data then
			return 1.5
		end
	end
	return 1.0
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

local function related_list_from_base (bases, subtypes, skip_base)
	local list = {}
	if type (bases) == "string" then
		bases = {bases,}
	end
	for _, base in ipairs (bases) do
		assert (core.registered_biomes[base],
			"Old-style biome " .. base .. " is not registered")
		if not skip_base then
			table.insert (list, base)
		end

		for _, subtype in ipairs (subtypes) do
			local name = base .. subtype
			if core.registered_biomes[name] then
				table.insert (list, name)
			end
		end
	end
	return list
end

local ocean_subtypes = {
	"_beach",
	"_ocean",
	"_deep_ocean",
}

local function approximate_warm_ocean ()
	local base = {
		"BambooJungle",
		"Jungle",
		"JungleEdge",
		"JungleEdgeM",
		"JungleM",
		"MangroveSwamp",
		"Mesa",
		"MesaBryce",
		"MesaPlateauF",
		"MesaPlateauFM",
		"Savanna",
		"SavannaM",
		"Swampland",
	}
	return related_list_from_base (base, ocean_subtypes, true)
end

local function approximate_ocean ()
	local base = {
		"BirchForest",
		"BirchForestM",
		"Desert",
		"FlowerForest",
		"Forest",
		"MegaSpruceTaiga",
		"MegaTaiga",
		"MushroomIsland",
		"Plains",
		"RoofedForest",
		"StoneBeach",
		"SunflowerPlains",
		"Taiga",
	}
	return related_list_from_base (base, ocean_subtypes, true)
end

local function approximate_cold_ocean ()
	local base = {
		"ColdTaiga",
		"ExtremeHills",
		"ExtremeHills+",
		"ExtremeHillsM",
		"IcePlains",
		"IcePlainsSpikes",
	}
	return related_list_from_base (base, ocean_subtypes, true)
end

local engine_aliases = nil

local function initialize_engine_aliases ()
	if engine_aliases
	-- Do not initialize engine_aliases on classic superflat
	-- worlds.
		or mcl_vars.superflat then
		return engine_aliases
	end
	engine_aliases = {
		TheVoid = {},
		Mesa = related_list_from_base ("Mesa", overworld_subtypes),
		BambooJungle = related_list_from_base ("BambooJungle", overworld_subtypes),
		BasaltDeltas = "BasaltDelta",
		Beach = {},
		BirchForest = related_list_from_base ({"BirchForest", "BirchForestM",},
						      overworld_subtypes),
		ColdOcean = approximate_cold_ocean (),
		DarkForest = related_list_from_base ("RoofedForest", overworld_subtypes),
		PaleGarden = related_list_from_base ("PaleGarden", overworld_subtypes),
		DeepColdOcean = approximate_cold_ocean (),
		DeepFrozenOcean = {},
		DeepOcean = approximate_ocean (),
		DeepLukewarmOcean = approximate_warm_ocean (),
		Desert = related_list_from_base ("Desert", overworld_subtypes),
		DripstoneCaves = "DripstoneCave",
		ErodedMesa = related_list_from_base ("MesaBryce", overworld_subtypes),
		FlowerForest = related_list_from_base ("FlowerForest",
						       overworld_subtypes),
		Forest = related_list_from_base ("Forest", overworld_subtypes),
		FrozenOcean = approximate_cold_ocean (),
		FrozenPeaks = "FrozenPeaks",
		FrozenRiver = {},
		Grove = related_list_from_base ("Grove", overworld_subtypes),
		IceSpikes = related_list_from_base ("IcePlainsSpikes", overworld_subtypes),
		JaggedPeaks = "JaggedPeaks",
		Jungle = related_list_from_base ({"Jungle", "JungleM",}, overworld_subtypes),
		LukewarmOcean = approximate_warm_ocean (),
		LushCaves = related_list_from_base ("LushCaves", overworld_subtypes),
		MangroveSwamp = related_list_from_base ("MangroveSwamp", overworld_subtypes),
		Meadow = related_list_from_base ("Meadow", overworld_subtypes),
		MushroomIslands = related_list_from_base ({"MushroomIsland", "MushroomIslandShore",},
							  overworld_subtypes),
		NetherWastes = "Nether",
		Ocean = approximate_ocean (),
		OldGrowthBirchForest = {},
		OldGrowthPineTaiga = related_list_from_base ("MegaTaiga", overworld_subtypes),
		OldGrowthSpruceTaiga = related_list_from_base ("MegaSpruceTaiga",
							       overworld_subtypes),
		Plains = related_list_from_base ("Plains", overworld_subtypes),
		River = {},
		Savannah = related_list_from_base ({"Savanna", "SavannaM",},
			overworld_subtypes),
		SavannahPlateau = {},
		SmallEndIslands = "EndSmallIslands",
		SnowyBeach = {},
		SnowyPlains = related_list_from_base ("IcePlains", overworld_subtypes),
		SnowySlopes = "SnowySlopes",
		SnowyTaiga = related_list_from_base ("ColdTaiga", overworld_subtypes),
		SoulSandValley = "SoulsandValley",
		SparseJungle = related_list_from_base ({"JungleEdge", "JungleEdgeM",},
						       overworld_subtypes),
		StonyPeaks = "StonyPeaks",
		StonyShore = related_list_from_base ("StoneBeach", overworld_subtypes),
		SunflowerPlains = related_list_from_base ("SunflowerPlains",
							  overworld_subtypes),
		Swamp = related_list_from_base ("Swampland", overworld_subtypes),
		Taiga = related_list_from_base ("Taiga", overworld_subtypes),
		TheEnd = {
			"End",
			"EndBorder",
			"EndIsland",
		},
		WarmOcean = approximate_warm_ocean (),
		WindsweptForest = {},
		WindsweptGravellyHills = related_list_from_base ("ExtremeHillsM",
								 overworld_subtypes),
		WindsweptHills = related_list_from_base ({"ExtremeHills", "ExtremeHills+",},
							 overworld_subtypes),
		WindsweptSavannah = {},
		WoodedMesa = related_list_from_base ({"MesaPlateauF", "MesaPlateauFM",},
						     overworld_subtypes),
	}
	return engine_aliases
end

-- Return a list of biome names represented by IDS_OR_TAGS, a list of
-- new-style biome names or tags prefixed with `#'.

local blurb = "No old-style biome exists by this name and no alternatives are available: "

function mcl_biome_dispatch.build_biome_list (ids_or_tags)
	if type (ids_or_tags) == "string" then
		ids_or_tags = {ids_or_tags,}
	end

	if levelgen_enabled then
		return mcl_levelgen.build_biome_list (ids_or_tags)
	else
		local names = {}
		local engine_aliases = initialize_engine_aliases ()
		for _, id in ipairs (ids_or_tags) do
			if string.find (id, "#") == 1 then
				local group = string.sub (id, 2)
				for name, biome in pairs (core.registered_biomes) do
					if biome._mcl_groups
						and biome._mcl_groups[group]
						and table.indexof (names, name) == -1 then
						table.insert (names, name)
					end
				end
			elseif mcl_vars.superflat then
				if id == "Plains" then
					table.insert (names, "flat")
				end
			elseif engine_aliases[id] then
				local aliases = engine_aliases[id]
				if type (aliases) == "string" then
					if table.indexof (names, aliases) == -1 then
						table.insert (names, aliases)
					end
				else
					for _, alias in ipairs (aliases) do
						if table.indexof (names, alias) == -1 then
							table.insert (names, alias)
						end
					end
				end
			else
				if not core.registered_biomes[id] then
					error (blurb .. id)
				end
				if table.indexof (names, id) == -1 then
					table.insert (names, id)
				end
			end
		end
		return names
	end
end

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

function mcl_biome_dispatch.make_biome_test (ids_or_tags)
	local list = mcl_biome_dispatch.build_biome_list (ids_or_tags)
	return (test_dispatchers[#list] or test_dispatcher_generic) (unpack (list))
end

------------------------------------------------------------------------
-- Spawn position computation.
------------------------------------------------------------------------

local LIMBO_POSITION = vector.new (31007, 31007, 31007)

local get_dimension = mcl_levelgen.get_dimension
local global_spawnpoint = core.setting_get_pos ("static_spawnpoint")

function mcl_biome_dispatch.get_spawn_point_2d ()
	if levelgen_enabled and global_spawnpoint then
		return global_spawnpoint
	elseif levelgen_enabled then
		local level = get_dimension ("mcl_levelgen:overworld")
		local x, z = level.preset:find_spawn_position ()
		global_spawnpoint = vector.new (x, 0, -z - 1)
		return global_spawnpoint
	else
		return vector.new (0, 0, 0)
	end
end

function mcl_biome_dispatch.use_detailed_spawning_mechanics ()
	return levelgen_enabled
end

local function is_up_face_sturdy (v)
	local node = core.get_node (v)
	return mcl_mobs.is_up_face_sturdy (v, node)
end

local function is_walkable (v, y_off)
	v.y = v.y + y_off
	local node = core.get_node (v)
	v.y = v.y - y_off
	local def = core.registered_nodes[node.name]
	return def and def.walkable
end

local function move_respawn_position (dim, v)
	local surface, _
		= mcl_levelgen.map_index_heightmap (dim, v.x, v.z, false)
	if not surface then
		return false
	end
	local y = surface + dim.y_global - 2
	v.y = y
	core.load_area (v)

	if is_up_face_sturdy (v) then
		local up_face_sturdy = true
		-- Search upwards for solid ground.
		for y = y, y + 80 do
			if up_face_sturdy
				and not is_walkable (v, 1)
				and not is_walkable (v, 2) then
				v.y = y + 0.5
				return true
			end
			v.y = y + 1
			up_face_sturdy = is_up_face_sturdy (v)
		end
	else
		-- Search downwards for solid ground.
		for y = y, y - 80, -1 do
			if y < dim.y_global then
				break
			end
			v.y = y
			if is_up_face_sturdy (v)
				and not is_walkable (v, 1)
				and not is_walkable (v, 2) then
				v.y = y + 0.5
				return true
			end
		end
	end
	return false
end

local last_diameter, last_a, last_c

local function findlcg (m)
	if last_diameter == m then
		return last_a, last_c
	else
		local a, c = mcl_util.findlcg (m)
		last_a = a
		last_c = c
		last_diameter = m
		return a, c
	end
end

local floor = math.floor

local function respawn_set_pos (player, _)
	local pos = mcl_biome_dispatch.next_respawn_position (nil)
	player:set_pos (pos)
end

function mcl_biome_dispatch.next_respawn_position (obj)
	local spawn_pos = mcl_biome_dispatch.get_spawn_point_2d ()
	local spawn_radius = tonumber (core.settings:get ("mcl_spawn_radius")) or 24
	local dim = get_dimension ("mcl_levelgen:overworld")
	local v1 = vector.offset (spawn_pos, -spawn_radius, 0, -spawn_radius)
	local v2 = vector.offset (spawn_pos, spawn_radius, 0, spawn_radius)
	v1.y = dim.y_global
	v2.y = dim.y_max
	if not mcl_levelgen.is_area_fully_regenerated (dim, v1.x, v1.y, v1.z,
						       v2.x, v2.y, v2.z) then
		if not obj then
			return LIMBO_POSITION
		end
		return mcl_biome_dispatch.emerged_teleport_prepare (obj,
								    v1, v2,
								    nil,
								    respawn_set_pos,
								    nil)
	end

	local diameter = spawn_radius * 2 + 1
	local m = diameter * diameter
	local a, c = findlcg (m)
	local state = math.random (0, m - 1)
	local v = vector.copy (spawn_pos)

	for i = 1, m do
		state = mcl_util.lcg_next (a, c, m, state)
		local dx = floor (state / diameter) - spawn_radius
		local dz = state % diameter - spawn_radius

		v.x = spawn_pos.x + dx
		v.z = spawn_pos.z + dz

		if move_respawn_position (dim, v) then
			return v
		end
	end
	local v = vector.copy (spawn_pos)
	move_respawn_position (dim, v)
	return v
end

local progress_str = nil

local function report_spawn_generation_progress_1 ()
	if progress_str and progress_str ~= 1 then
		core.log ("action", progress_str)
		progress_str = nil
	end
end

local function report_spawn_generation_progress (progress)
	if progress.total_regen > progress.n_regenerated then
		if not progress_str then
			core.after (0.5, report_spawn_generation_progress_1)
		end
		progress_str = string.format ("Emerged %d/%d MapBlocks; %d/%d MapBlocks regenerated",
					      progress.n_emerged, progress.total_emerge,
					      progress.n_regenerated, progress.total_regen)
	elseif progress_str ~= 1 then
		progress_str = 1
		core.log ("action", string.format ("Completed regeneration of %d MapBlocks",
						   progress.total_regen))
	end
end

local function generate_spawn_area ()
	local spawn_pos = mcl_biome_dispatch.get_spawn_point_2d ()
	local spawn_radius = tonumber (core.settings:get ("mcl_spawn_radius")) or 24
	local dim = get_dimension ("mcl_levelgen:overworld")
	local v1 = vector.offset (spawn_pos, -spawn_radius,
				  dim.y_global, -spawn_radius)
	local v2 = vector.offset (spawn_pos, spawn_radius,
				  dim.y_max, spawn_radius)
	core.log ("action", string.format ("Generating world spawn from (%d,%d,%d) to (%d,%d,%d)",
					   v1.x, v1.y, v1.z, v2.x, v2.y, v2.z))
	mcl_levelgen.generate_area (v1.x, v1.y, v1.z, v2.x, v2.y, v2.z,
				    report_spawn_generation_progress)
end

if mcl_biome_dispatch.use_detailed_spawning_mechanics () then
	core.register_on_mods_loaded (function ()
		core.after (0.1, generate_spawn_area)
	end)

	-- Override static_spawnpoint before players are permitted to
	-- join, as the engine positions new players without regard to
	-- registered respawn callbacks.
	core.register_on_newplayer (function (player)
		local pos = mcl_biome_dispatch.next_respawn_position (player)
		player:set_pos (pos)
	end)
end

------------------------------------------------------------------------
-- Portals & respawning mechanics.
------------------------------------------------------------------------

local insert = table.insert
local mathmin = math.min
-- local mathmax = math.max

local objects_in_limbo = {}

-- Players that are teleporting to an ungenerated area are held in a
-- ``limbo'' between dimensions until such time as their destination
-- is completely regenerated.  A progress formspec is also displayed
-- during this period.

local limbo_formspec = [[
formspec_version[6]
size[15,8]
position[0.5,0.5]
allow_close[false]
hypertext[0,3;15,4;_;<center><big>%s</big></center>]
image[4,5;7,0.1;(blank.png^[resize:100x1^[fill:100x1:#525252)%s%s]
bgcolor[;true;]
background[-10,-10;0,0;mcl_biome_dispatch_transition_bkg.png;true]
]]

local limbo_forceloaded

local function toggle_forceload ()
	if next (objects_in_limbo, nil) then
		if not limbo_forceloaded then
			if core.forceload_block (LIMBO_POSITION, true) then
				limbo_forceloaded = true
			end
		end
	elseif limbo_forceloaded then
		limbo_forceloaded = false
		core.forceload_free_block (LIMBO_POSITION)
	end
end

local function limbo_cancel (player, limbo, no_teleport)
	if not no_teleport then
		player:set_pos (limbo.src_pos)
	end
	objects_in_limbo[player] = nil
	core.close_formspec (player:get_player_name (),
			     "mcl_biome_dispatch:limbo_formspec")
	toggle_forceload ()
end

local function limbo_callback (progress, player, limbo_in)
	local n_regen = progress.n_regenerated
	local total_regen = progress.total_regen
	local n_emerged = progress.n_emerged
	local total_emerge = progress.total_emerge
	local limbo = objects_in_limbo[player]
	if limbo ~= limbo_in then
		return false
	end

	if n_regen == total_regen and n_emerged == total_emerge then
		limbo.callback (player, limbo.data)
		limbo_cancel (player, limbo, true)
	elseif player:is_player () then
		local text = limbo.text
		local progress_load
			= mathmin (100, floor (n_emerged / total_emerge * 100))
		local progress_regen
			= mathmin (100, floor (n_regen / total_regen * 100))

		if progress_load ~= limbo.last_progress_load
			or progress_regen ~= limbo.last_progress_regen then
			local pload = progress_load > 0
				and string.format ("^[fill:%dx1:#9c9c9c", progress_load)
				or ""
			local pregen = progress_regen > 0
				and string.format ("^[fill:%dx1:#458b00", progress_regen)
				or ""
			local pmax, pmin
			if progress_regen > progress_load then
				pmax = pregen
				pmin = pload
			else
				pmax = pload
				pmin = pregen
			end
			local formspec = string.format (limbo_formspec, text,
							pmax, pmin)
			core.show_formspec (player:get_player_name (),
					    "mcl_biome_dispatch:limbo_formspec",
					    formspec)
			limbo.last_progress_load = progress_load
			limbo.last_progress_regen = progress_regen
		end
	end
end

local function limbo_restore (player, limbo)
	player:set_pos (LIMBO_POSITION)
	local v1 = limbo.v1
	local v2 = limbo.v2
	mcl_levelgen.generate_area (v1.x, v1.y, v1.z, v2.x, v2.y, v2.z,
				    limbo_callback, player, limbo)
end

core.register_on_leaveplayer (function (player)
	if objects_in_limbo[player] then
		limbo_cancel (player, objects_in_limbo[player])
	end
end)

core.register_on_shutdown (function ()
	for player, limbo in pairs (objects_in_limbo) do
		limbo_cancel (player, limbo)
	end
end)

local function stupid_emerge_teleport (_, _, calls_remaining, param)
	if calls_remaining == 0 and param[2]:is_valid () then
		param[1] (param[2], param[3])
	end
end

function mcl_biome_dispatch.emerged_teleport_prepare (player, v1, v2, msg, callback, data)
	if not levelgen_enabled then
		core.emerge_area (v1, v2, stupid_emerge_teleport,
				  {callback, player, data,})
		return player:get_pos ()
	end
	if objects_in_limbo[player] then
		limbo_cancel (player, objects_in_limbo[player])
	end
	local limbo_data = {
		v1 = v1,
		v2 = v2,
		src_pos = player:get_pos (),
		msg = msg or S ("Loading terrain"),
		callback = callback,
		data = data,
	}
	objects_in_limbo[player] = limbo_data
	local escaped = core.formspec_escape (limbo_data.msg)
	limbo_data.text = core.hypertext_escape (escaped)
	limbo_restore (player, limbo_data, nil)
	toggle_forceload ()
	return LIMBO_POSITION
end

local function collect_attached_players (object, players)
	for _, object in ipairs (object:get_children ()) do
		if object:is_player () then
			insert (players, object)
		end
		collect_attached_players (object, players)
	end
end

function mcl_biome_dispatch.teleport_with_emerge (object, v1, v2, msg, callback, data)
	local players = {}
	collect_attached_players (object, players)
	local limbo_pos
		= mcl_biome_dispatch.emerged_teleport_prepare (object, v1, v2,
							       msg, callback, data)
	object:set_pos (limbo_pos)

	for _, player in ipairs (players) do
		mcl_biome_dispatch.emerged_teleport_prepare (player, v1, v2, msg,
							     callback, data)
	end
end

function mcl_biome_dispatch.in_limbo (player)
	return objects_in_limbo[player] ~= nil
end

function mcl_biome_dispatch.is_limbo_pos (v)
	return vector.equals (v, LIMBO_POSITION)
end

function mcl_biome_dispatch.get_end_portal_pos ()
	if not levelgen_enabled then
		return mcl_vars.mg_end_exit_portal_pos
	end

	local dim = get_dimension ("mcl_levelgen:end")
	local surface, _
		= mcl_levelgen.map_index_heightmap (dim, 0, 0, true)
	if not surface then
		return mcl_vars.mg_end_exit_portal_pos
	end
	return vector.new (0, surface - dim.y_offset - 1, 0)
end

------------------------------------------------------------------------
-- Miscellaneous provisioning tasks.
------------------------------------------------------------------------

local overworld_structures

local function get_overworld_structure_level ()
	if overworld_structures then
		return overworld_structures
	end
	local dim = get_dimension ("mcl_levelgen:overworld")
	local level = mcl_levelgen.make_structure_level (dim.preset)
	overworld_structures = level
	return level
end

local band = bit.band
local arshift = bit.arshift

local function struct_unhash (hash)
	local x = arshift (hash, 13) - 4096
	local z = band (hash, 0x1fff) - 4096
	return x, z
end

local insert = table.insert
local enable_ersatz = mcl_levelgen.enable_ersatz

function mcl_biome_dispatch.get_stronghold_positions ()
	if levelgen_enabled or enable_ersatz then
		local level = get_overworld_structure_level ()
		local starts = level.stronghold_starts["mcl_levelgen:strongholds"]
		if not starts then
			return {}
		end
		local list = {}
		for hash, value in pairs (starts) do
			if value then
				local cx, cz = struct_unhash (hash)
				local v = vector.new (cx * 16 + 2, 0, -(cz * 16 + 2) - 1)
				insert (list, v)
			end
		end
		return list
	end

	local shrine = mcl_structures.registered_structures["end_shrine"]
	if not shrine then
		return {}
	end
	return shrine.static_pos
end

local function locate_structure_or_biome (taskinfo)
	local dim = mcl_levelgen.get_dimension (taskinfo.dim)
	assert (dim)
	if not mcl_levelgen.enable_ersatz then
		mcl_levelgen.initialize_terrain (dim)
	else
		dim.terrain = mcl_levelgen.get_ersatz_terrain (dim)
	end
	if taskinfo.sids then
		local x, y, z
			= mcl_levelgen.locate_structure_placement (dim.terrain, taskinfo.x,
								   taskinfo.y, taskinfo.z,
								   taskinfo.sids,
								   taskinfo.range)
		return x, y, z
	else
		assert (taskinfo.biome_tags)
		local ok, list, _
			= pcall (mcl_levelgen.build_biome_list, taskinfo.biome_tags)
		if ok and #list >= 1 then
			local predicate = mcl_levelgen.make_biome_test (list)
			local x, y, z
				= mcl_levelgen.locate_biome_spirally (dim.preset,
								      taskinfo.x,
								      taskinfo.y,
								      taskinfo.z,
								      taskinfo.range,
								      taskinfo.hres,
								      taskinfo.vres,
								      predicate, nil)
			return x, y, z
		else
			return nil, nil, nil
		end
	end
end

local pending_locate_tasks = {}
local outstanding_locate_task = false

local function dispatch_locate_task (taskinfo)
	local dim = get_dimension (taskinfo.dim)
	local callback = taskinfo.callback
	local cb_data = taskinfo.cb_data

	taskinfo.callback = nil
	taskinfo.cb_data = nil
	-- Async execution is impossible in ersatz structure
	-- generation environments, as core.get_biome_data is not
	-- available in async environments and cannot be reproduced in
	-- Lua (see:
	-- https://irc.luanti.org/luanti/2025-08-09#i_6277165).
	if enable_ersatz then
		local x, y, z = locate_structure_or_biome (taskinfo)
		if x then
			local v = vector.new (x, y - dim.y_offset, -z - 1)
			callback (v, cb_data)
		else
			callback (nil, cb_data)
		end
		outstanding_locate_task = false
		return
	end
	-- Owch!!!  Interested parties should investigate eliminating
	-- this closure.
	core.handle_async (locate_structure_or_biome, function (x, y, z)
		if x then
			local v = vector.new (x, y - dim.y_offset, -z - 1)
			callback (v, cb_data)
		else
			callback (nil, cb_data)
		end

		outstanding_locate_task = false
		local n = #pending_locate_tasks
		while n > 0 and not outstanding_locate_task do
			local taskinfo = pending_locate_tasks[1]
			for i = 2, n do
				pending_locate_tasks[i - 1]
					= pending_locate_tasks[i]
			end
			pending_locate_tasks[n] = nil

			if not taskinfo.retain_p
				or taskinfo.retain_p (cb_data) then
				dispatch_locate_task (taskinfo)
				outstanding_locate_task = true
			end

			n = n - 1
		end
	end, taskinfo)
end

function mcl_biome_dispatch.locate_structure_near (pos, sid_or_sids, range_chebyshev,
						   callback, cb_data, retain_p)
	if not levelgen_enabled and not enable_ersatz then
		callback (nil, cb_data)
		return
	end
	local x, y, z, dim = conv_pos_raw (pos)
	if not dim then
		callback (nil, cb_data)
	else
		local taskinfo = {
			x = floor (x + 0.5),
			y = floor (y + 0.5),
			z = floor (z + 0.5),
			range = range_chebyshev,
			sids = sid_or_sids,
			dim = dim.id,
			callback = callback,
			retain_p = retain_p,
			cb_data = cb_data,
		}
		if not outstanding_locate_task then
			outstanding_locate_task = true
			dispatch_locate_task (taskinfo)
		else
			taskinfo.callback = callback
			taskinfo.cb_data = cb_data
			insert (pending_locate_tasks, taskinfo)
		end
	end
end

function mcl_biome_dispatch.locate_biome_near (pos, tags, range, hres, vres,
					       callback, cb_data)
	if not levelgen_enabled then
		local ok, list, _ = pcall (mcl_biome_dispatch.build_biome_list, tags)
		if not ok or #list == 0 then
			callback (nil, cb_data)
		else
			local k = floor (range / hres) + 1
			callback (findbiome.find_biome (pos, list, hres, k * k), cb_data)
		end
		return
	end

	local x, y, z, dim = conv_pos_raw (pos)
	if not dim then
		callback (nil, cb_data)
	else
		local taskinfo = {
			x = floor (x + 0.5),
			y = floor (y + 0.5),
			z = floor (z + 0.5),
			range = range,
			hres = hres,
			vres = vres,
			biome_tags = tags,
			dim = dim.id,
			callback = callback,
			cb_data = cb_data,
		}
		if not outstanding_locate_task then
			outstanding_locate_task = true
			dispatch_locate_task (taskinfo)
		else
			taskinfo.callback = callback
			taskinfo.cb_data = cb_data
			insert (pending_locate_tasks, taskinfo)
		end
	end
end

function mcl_biome_dispatch.list_registered_structures ()
	if not levelgen_enabled and not enable_ersatz then
		return {}
	end
	local structs = core.ipc_get ("mcl_biome_dispatch:registered_structures")
	return structs or {}
end

function mcl_biome_dispatch.list_registered_biomes_and_groups ()
	if not levelgen_enabled and not enable_ersatz then
		return {}
	end
	local biomes_and_groups
		= core.ipc_get ("mcl_biome_dispatch:registered_biomes_and_groups")
	return biomes_and_groups or {}
end

if levelgen_enabled then
	local modpath = core.get_modpath (core.get_current_modname ())
	core.register_async_dofile (modpath .. "/async_init.lua")
elseif enable_ersatz then
	local modpath = core.get_modpath (core.get_current_modname ())
	core.register_on_mods_loaded (function ()
		dofile (modpath .. "/async_init.lua")
	end)
end

------------------------------------------------------------------------
-- Chat commands.
------------------------------------------------------------------------

local mathsqrt = math.sqrt
local huge = math.huge

core.register_chatcommand ("locate", {
	params = "[structure | biome | poi] <ID>",
	description = S ("Locate a structure, biome, or point of interest identified by ID in the current dimension."),
	privs = { maphack = true, },
	func = function (name, param)
		local command, id = unpack (param:split (" "))
		if command == "structure" then
			if type (id) ~= "string" then
				core.chat_send_player (name, S ([[/locate structure requires a structure ID.
These structures are available: ]]))
				local tbl = mcl_biome_dispatch.list_registered_structures ()
				core.chat_send_player (name, table.concat (tbl, ", "))
				return
			end
			local player = core.get_player_by_name (name)
			if player then
				local pos = player:get_pos ()
				mcl_biome_dispatch.locate_structure_near (pos, id, 96, function (v, _)
					if v then
						local dist = floor (vector.distance (v, pos) + 0.5)
						local blurb = PS ("The nearest structure of type @1 is located at (@2,@3,@4) (@5 block away)",
								  "The nearest structure of type @1 is located at (@2,@3,@4) (@5 blocks away)",
								  dist, id, v.x, v.y, v.z, dist)
						core.chat_send_player (name, blurb)
					else
						local blurb = S ("No structure of type @1 exists near your position", id)
						core.chat_send_player (name, blurb)
					end
				end, function (_)
					return player:is_valid ()
				end)
			end
		elseif command == "biome" then
			if type (id) ~= "string" then
				core.chat_send_player (name, S ([[/locate biome requires a biome ID or a tag prefixed with `#'.
These biomes and tags are available: ]]))
				local tbl = mcl_biome_dispatch.list_registered_biomes_and_groups ()
				core.chat_send_player (name, table.concat (tbl, ", "))
				return
			end
			local player = core.get_player_by_name (name)
			if player then
				local pos = player:get_pos ()
				mcl_biome_dispatch.locate_biome_near (pos, { id, }, 6400, 32, 64, function (v, _)
					if v then
						local dist = floor (vector.distance (v, pos) + 0.5)
						local blurb = PS ("The nearest biome matching @1 is located at (@2,@3,@4) (@5 block away)",
								  "The nearest biome matching @1 is located at (@2,@3,@4) (@5 blocks away)",
								  dist, id, v.x, v.y, v.z, dist)
						core.chat_send_player (name, blurb)
					else
						local blurb = S ("No biome matching @1 exists near your position", id)
						core.chat_send_player (name, blurb)
					end
				end)
			end
		elseif command == "poi" then
			if type (id) ~= "string" then
				core.chat_send_player (name, S ([[/locate poi requires an identifier designating a valid point of interest.
These points of interest are available: ]]))
				local tbl = {}
				for name, _ in pairs (mcl_villages.registered_pois) do
					insert (tbl, name)
				end
				core.chat_send_player (name, table.concat (tbl, ", "))
				return
			elseif not mcl_villages.registered_pois[id]  then
				core.chat_send_player (name, S ("@1 does not identify a valid point of interest", id))
				return
			end
			local player = core.get_player_by_name (name)
			if player then
				local pos = player:get_pos ()
				local v1 = vector.offset (pos, -3000, -3000, -3000)
				local v2 = vector.offset (pos, 3000, 3000, 3000)

				local pois = mcl_villages.get_pois_in_by_nodepos (v1, v2)
				local distmax = huge
				local poi_nearest = nil
				for _, poi in ipairs (pois) do
					if poi.data == id then
						local v = poi.min
						local dx = v.x - pos.x
						local dy = v.y - pos.y
						local dz = v.z - pos.z
						local d = (dx * dx) + (dy * dy) + (dz * dz)
						if d < distmax then
							poi_nearest = v
							distmax = d
						end
					end
				end

				if not poi_nearest then
					local blurb = S ("No point of interest named @1 exists near your position", id)
					core.chat_send_player (name, blurb)
				else
					local v = poi_nearest
					local dist = floor (mathsqrt (distmax) + 0.5)
					local blurb = PS ("The nearest point of interest named @1 is located at (@2,@3,@4) (@5 block away)",
							  "The nearest point of interest named @1 is located at (@2,@3,@4) (@5 blocks away)",
							  dist, id, v.x, v.y, v.z, dist)
					core.chat_send_player (name, blurb)
				end
			end
		else
			core.chat_send_player (name, S ("Usage: /locate [structure | biome | poi] <ID>"))
		end
	end,
})

------------------------------------------------------------------------
-- Slime chunk seeding.
------------------------------------------------------------------------

local ull = mcl_levelgen.ull

local SLIME_CHUNK_SALT = ull (0, 0x3ad8025f)
local slime_chunk_rng = mcl_levelgen.jvm_random (ull (0, 0))
local set_slime_chunk_seed = mcl_levelgen.set_slime_chunk_seed

-- This value is always defined, even when neither mcl_levelgen nor
-- the ersatz generator is enabled.
local seed = mcl_levelgen.seed

function mcl_biome_dispatch.is_slime_chunk (x, z)
	local cx, cz = arshift (x, 4), arshift (-z - 1, 4)
	set_slime_chunk_seed (slime_chunk_rng, seed, cx, cz,
			      SLIME_CHUNK_SALT)
	return slime_chunk_rng:next_within (10) == 0
end

if mcl_levelgen.levelgen_enabled then

mcl_levelgen.register_hud_callback (function (x, y, z)
	if mcl_biome_dispatch.is_slime_chunk (x, z) then
		return string.format ("Slime chunk: YES (%d, %d)",
				      arshift (x, 4), arshift (-z - 1, 4))
	else
		return "Slime chunk: NO"
	end
end)

end
