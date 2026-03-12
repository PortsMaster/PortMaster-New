mcl_worlds = {}

-- For a given position, returns a 2-tuple:
-- 1st return value: true if pos is in void
-- 2nd return value: true if it is in the deadly part of the void
function mcl_worlds.is_in_void(pos)
	local void =
		not ((pos.y < mcl_vars.mg_overworld_max and pos.y > mcl_vars.mg_overworld_min) or
		(pos.y < mcl_vars.mg_nether_max+128 and pos.y > mcl_vars.mg_nether_min) or
		(pos.y < mcl_vars.mg_end_max and pos.y > mcl_vars.mg_end_min))

	local void_deadly = false
	local deadly_tolerance = 64 -- the player must be this many nodes “deep” into the void to be damaged
	if void then
		-- Overworld → Void → End → Void → Nether → Void
		if pos.y < mcl_vars.mg_overworld_min and pos.y > mcl_vars.mg_end_max then
			void_deadly = pos.y < mcl_vars.mg_overworld_min - deadly_tolerance
		elseif pos.y < mcl_vars.mg_end_min and pos.y > mcl_vars.mg_nether_max+128 then
			-- The void between End and Nether. Like usual, but here, the void
			-- *above* the Nether also has a small tolerance area, so player
			-- can fly above the Nether without getting hurt instantly.
			void_deadly = (pos.y < mcl_vars.mg_end_min - deadly_tolerance) and (pos.y > mcl_vars.mg_nether_max+128 + deadly_tolerance)
		elseif pos.y < mcl_vars.mg_nether_min then
			void_deadly = pos.y < mcl_vars.mg_nether_min - deadly_tolerance
		end
	end
	return void, void_deadly
end

-- Takes an Y coordinate as input and returns:
-- 1) The corresponding Minecraft layer (can be nil if void)
-- 2) The corresponding Minecraft dimension ("overworld", "nether" or "end") or "void" if it is in the void
-- If the Y coordinate is not located in any dimension, it will return:
--     nil, "void"
function mcl_worlds.y_to_layer(y)
	if y >= mcl_vars.mg_overworld_min then
		return y - mcl_vars.mg_overworld_min_old, "overworld"
	elseif y >= mcl_vars.mg_nether_min and y <= mcl_vars.mg_nether_max+128 then
		return y - mcl_vars.mg_nether_min, "nether"
	elseif y >= mcl_vars.mg_end_min and y <= mcl_vars.mg_end_max then
		return y - mcl_vars.mg_end_min, "end"
	else
		return nil, "void"
	end
end

-- Takes a pos and returns the dimension it belongs to (same as above)
function mcl_worlds.pos_to_dimension(pos)
	local _, dim = mcl_worlds.y_to_layer(pos.y)
	return dim
end

-- Takes a Minecraft layer and a “dimension” name
-- and returns the corresponding Y coordinate for
-- Mineclonia.
-- mc_dimension is one of "overworld", "nether", "end" (default: "overworld").
function mcl_worlds.layer_to_y(layer, mc_dimension)
	if mc_dimension == "overworld" or mc_dimension == nil then
		return layer + mcl_vars.mg_overworld_min_old
	elseif mc_dimension == "nether" then
		return layer + mcl_vars.mg_nether_min
	elseif mc_dimension == "end" then
		return layer + mcl_vars.mg_end_min
	end
end

-- Takes a position and returns true if this position can have weather
function mcl_worlds.has_weather(pos)
	-- Weather in the Overworld and the high part of the void below
	return pos.y <= mcl_vars.mg_overworld_max and pos.y >= mcl_vars.mg_overworld_min - 64
end

-- Takes a position and returns true if this position can have Nether dust
function mcl_worlds.has_dust(pos)
	-- Weather in the Overworld and the high part of the void below
	return pos.y <= mcl_vars.mg_nether_max + 138 and pos.y >= mcl_vars.mg_nether_min - 10
end

-- Takes a position (pos) and returns true if compasses are working here
function mcl_worlds.compass_works(pos)
	-- It doesn't work in Nether and the End, but it works in the Overworld and in the high part of the void below
	local _, dim = mcl_worlds.y_to_layer(pos.y)
	if dim == "nether" or dim == "end" then
		return false
	elseif dim == "void" then
		return pos.y <= mcl_vars.mg_overworld_max and pos.y >= mcl_vars.mg_overworld_min - 64
	else
		return true
	end
end

-- Takes a position (pos) and returns true if clocks are working here
mcl_worlds.clock_works = mcl_worlds.compass_works

--------------- CALLBACKS ------------------
mcl_worlds.registered_on_dimension_change = {}

-- Register a callback function func(player, dimension).
-- It will be called whenever a player changes between dimensions.
-- The void counts as dimension.
-- * player: The player who changed the dimension
-- * dimension: The new dimension of the player ("overworld", "nether", "end", "void").
function mcl_worlds.register_on_dimension_change(func)
	table.insert(mcl_worlds.registered_on_dimension_change, func)
end

-- Playername-indexed table containig the name of the last known dimension the
-- player was in.
local last_dimension = {}

-- Notifies this mod about a dimension change of a player.
-- * player: Player who changed the dimension
-- * dimension: New dimension ("overworld", "nether", "end", "void")
function mcl_worlds.dimension_change(player, dimension)
	local playername = player:get_player_name()
	for i=1, #mcl_worlds.registered_on_dimension_change do
		mcl_worlds.registered_on_dimension_change[i](player, dimension, last_dimension[playername])
	end
	last_dimension[playername] = dimension
end

----------------------- INTERNAL STUFF ----------------------

-- Update the dimension callbacks every DIM_UPDATE seconds
local DIM_UPDATE = 1
local dimtimer = 0

core.register_on_joinplayer(function(player)
	last_dimension[player:get_player_name()] = mcl_worlds.pos_to_dimension(player:get_pos())
end)

core.register_globalstep(function(dtime)
	-- regular updates based on iterval
	dimtimer = dimtimer + dtime;
	if dimtimer >= DIM_UPDATE then
		for player in mcl_util.connected_players() do
			local dim = mcl_worlds.pos_to_dimension(player:get_pos())
			local name = player:get_player_name()
			if dim ~= last_dimension[name] then
				mcl_worlds.dimension_change(player, dim)
			end
		end
		dimtimer = 0
	end
end)

function mcl_worlds.get_cloud_parameters()
	local mg_name = core.get_mapgen_setting("mg_name")
	if mg_name == "valleys" or mg_name == "carpathian" then
		return {
			height = 384, --valleys and carpathian have a much higher average elevation thus often "normal" landscape ends up in the clouds
			speed = {x=-2, z=0},
			thickness=5,
			color="#FFF0FEF",
			ambient = "#201060",
		}
	elseif mg_name == "singlenode" then
		-- mcl_levelgen enabled.  Layer 197.
		return {
			height = 133,
			speed = {x=-2, z=0},
			thickness = 4,
			color = "#FFF0FEF",
		}
	else
		-- MC-style clouds: Layer 127, thickness 4, fly to the “West”
		return {
			height = mcl_worlds.layer_to_y(127),
			speed = {x=-2, z=0},
			thickness = 4,
			color = "#FFF0FEF",
		}
	end
end

------------------------------------------------------------------------
-- Chunk inhabited time.
-- Very counterintuitively it is mod storage that performs the best
-- for storing chunk metadata, despite being said to be inefficient in
-- the Minetest wiki.
------------------------------------------------------------------------

local mod_storage = core.get_mod_storage ()

local function round_trunc (pos)
	return math.floor (pos + 0.5)
end

local function id_dimension (y)
	if y >= mcl_vars.mg_overworld_min then
		return "overworld_"
	elseif y >= mcl_vars.mg_nether_min and y <= mcl_vars.mg_nether_max then
		return "nether_"
	elseif y >= mcl_vars.mg_end_min and y <= mcl_vars.mg_end_max then
		return "theEnd_"
	else
		-- Void.
		return "theVoid_"
	end
end

function mcl_worlds.chunk_inhabited_time (pos)
	local chunk_x = math.floor (round_trunc (pos.x) / 16)
	local chunk_z = math.floor (round_trunc (pos.z) / 16)
	local chunkstring = id_dimension (pos.y) .. chunk_x .. "," .. chunk_z

	return mod_storage:get_float (chunkstring)
end

function mcl_worlds.tick_chunk_inhabited_time (pos, player, dtime)
	if core.check_player_privs (player, "no_regional_difficulty") then
		return
	end
	local chunk_x = math.floor (round_trunc (pos.x) / 16)
	local chunk_z = math.floor (round_trunc (pos.z) / 16)
	local chunkstring = id_dimension (pos.y) .. chunk_x .. "," .. chunk_z
	local time = mod_storage:get_float (chunkstring) + dtime
	mod_storage:set_float (chunkstring, time)
end

core.register_privilege ("no_regional_difficulty", {
	description = "Exempt players from increasing the regional difficulty of chunks they inhabit",
	give_to_singleplayer = false,
	give_to_admin = false,
})

------------------------------------------------------------------------
-- Local difficulty computation.
-- Ref: https://minecraft.wiki/w/Regional_difficulty
------------------------------------------------------------------------

function mcl_worlds.get_regional_difficulty (pos)
	if mcl_vars.difficulty == 0 then
		return 0
	end
	local inhabited_time = mcl_worlds.chunk_inhabited_time (pos)
	local total_daytime = core.get_day_count () * 24000
	local daytime_factor, chunk_factor
	if total_daytime > 1512000 then -- 63 days
		daytime_factor = 0.25
	elseif total_daytime < 72000 then -- 3 days
		daytime_factor = 0
	else
		total_daytime
			= total_daytime + core.get_timeofday () * 24000
		daytime_factor = (total_daytime - 72000) / 5760000
	end
	chunk_factor = math.min (inhabited_time / 360000, 1.0)
	if mcl_vars.difficulty < 3 then
		chunk_factor = chunk_factor * 0.75
	end
	local phase = mcl_moon.get_moon_brightness ()
	if phase / 4 > daytime_factor then
		chunk_factor = chunk_factor + daytime_factor
	else
		chunk_factor = chunk_factor + phase / 4
	end
	if mcl_vars.difficulty == 1 then
		chunk_factor = chunk_factor * 0.5
	end
	local difficulty = 0.75 + daytime_factor + chunk_factor
	if mcl_vars.difficulty == 1 then
		return difficulty
	elseif mcl_vars.difficulty == 2 then
		return difficulty * 2
	else
		return difficulty * 3
	end
end

-- This is a multiplier for mob buffs.
function mcl_worlds.get_special_difficulty (pos)
	local regional = mcl_worlds.get_regional_difficulty (pos)
	if regional < 2.0 then
		return 0.0
	end
	return regional > 4.0 and 1.0 or (regional - 2.0) / 2
end

-- local function fill_area_db ()
-- 	for x = 0, 4095 do
-- 		local clock = os.clock ()
-- 		for z = 0, 4095 do
-- 			mcl_worlds.tick_chunk_inhabited_time ({
-- 					x = (x - 2048) * 16,
-- 					y = 0,
-- 					z = (z - 2048) * 16,
-- 			}, 1)
-- 		end
-- 		local time = os.clock () - clock
-- 		print ("Next X " .. x)
-- 		print (string.format ("Previous iteration took %.4f s (%.2f ms per chunk)\n",
-- 				      time, time * 1000 / 4096))
-- 	end
-- end
