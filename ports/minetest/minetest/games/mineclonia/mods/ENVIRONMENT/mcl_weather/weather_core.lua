local S = core.get_translator(core.get_current_modname())

-- weather states, 'none' is default, other states depends from active mods
mcl_weather.state = "none"

-- player list for saving player meta info
mcl_weather.players = {}

-- default weather check interval for global step
mcl_weather.check_interval = 5

-- weather min duration
mcl_weather.min_duration = 600

-- weather max duration
mcl_weather.max_duration = 9000

-- weather calculated end time
mcl_weather.end_time = nil

-- registered weathers
mcl_weather.reg_weathers = {}

-- global flag to disable/enable ABM logic.
mcl_weather.allow_abm = true

mcl_weather.reg_weathers["none"] = {
	min_duration = mcl_weather.min_duration,
	max_duration = mcl_weather.max_duration,
	light_factor = nil,
	transitions = {
		[50] = "rain",
	},
	clear = function() end,
}

local storage = core.get_mod_storage()
-- Save weather into mod storage, so it can be loaded after restarting the server
local function save_weather()
	if not mcl_weather.end_time then return end
	storage:set_string("mcl_weather_state", mcl_weather.state)
	storage:set_int("mcl_weather_end_time", mcl_weather.end_time)
	core.log("verbose", "[mcl_weather] Weather data saved: state="..mcl_weather.state.." end_time="..mcl_weather.end_time)
end
core.register_on_shutdown(save_weather)

local particlespawners={}
function mcl_weather.add_spawner_player(pl,id,ps)
	local name=pl:get_player_name()
	if not particlespawners[name] then
		particlespawners[name] = {}
	end
	if not particlespawners[name][id] then
		mcl_weather.remove_spawners_player(pl)
		particlespawners[name] = {}
		ps.playername =name
		ps.attached = pl
		particlespawners[name][id]=core.add_particlespawner(ps)
		return particlespawners[name][id]
	end
end
function mcl_weather.remove_spawners_player(pl)
	local name=pl:get_player_name()
	if not particlespawners[name] then return end
	for _, v in pairs(particlespawners[name]) do
		core.delete_particlespawner(v)
	end
	particlespawners[name] = nil
	return true
end

function mcl_weather.remove_all_spawners()
	for pl in mcl_util.connected_players() do
		mcl_weather.remove_spawners_player(pl)
	end
end

function mcl_weather.get_rand_end_time(min_duration, max_duration)
	local r
	if min_duration and max_duration then
		r = math.random(min_duration, max_duration)
	else
		r = math.random(mcl_weather.min_duration, mcl_weather.max_duration)
	end
	return core.get_gametime() + r
end

function mcl_weather.get_current_light_factor()
	if mcl_weather.state == "none" then
		return nil
	else
		return mcl_weather.reg_weathers[mcl_weather.state].light_factor
	end
end

-- Returns true if pos is outdoor.
-- Outdoor is defined as any node in the Overworld under open sky.
-- FIXME: Nodes below glass also count as “outdoor”, this should not be the case.
function mcl_weather.is_outdoor(pos)
	local cpos = vector.offset(pos,0,1,0)
	local dim = mcl_worlds.pos_to_dimension(cpos)
	if core.get_node_light(cpos, 0.5) == 15 and dim == "overworld" then
		return true
	end
	return false
end

function mcl_weather.can_see_outdoors(pos)
	local light = core.get_natural_light(pos, 0.5)
	if light ~= nil and light >= 1 then
		return true
	end
	return false
end

local floor = math.floor

-- checks if player is undewater. This is needed in order to
-- turn off weather particles generation.
function mcl_weather.is_underwater(player)
	local ppos = player:get_pos()
	local offset = player:get_eye_offset()
	local player_eye_pos = {
		x = floor (ppos.x + offset.x + 0.5),
		y = floor (ppos.y + offset.y + 2.0),
		z = floor (ppos.z + offset.z + 0.5),
	}
	local node_level
		= mcl_liquids.get_node_level (player_eye_pos)
	if node_level == 8 or node_level == 7 then
		return true
	end
	return false
end

local t = 0

core.register_globalstep(function(dtime)
	t = t + dtime
	if t < mcl_weather.check_interval then return end
	t = 0

	if mcl_weather.end_time == nil then
		mcl_weather.end_time = mcl_weather.get_rand_end_time()
	end
	-- recalculate weather
	if mcl_weather.end_time <= core.get_gametime() then
		local changeWeather = core.settings:get_bool("mcl_doWeatherCycle")
		if changeWeather == nil then
			changeWeather = true
		end
		if changeWeather then
			mcl_weather.set_random_weather(mcl_weather.state, mcl_weather.reg_weathers[mcl_weather.state])
		else
			mcl_weather.end_time = mcl_weather.get_rand_end_time()
		end
	end
end)

-- Sets random weather (which could be 'none' (no weather)).
function mcl_weather.set_random_weather(_, weather_meta)
	if weather_meta == nil then return end
	local transitions = weather_meta.transitions
	local random_roll = math.random(0,100)
	local new_weather
	for v, weather in pairs(transitions) do
		if random_roll < v then
			new_weather = weather
			break
		end
	end
	if new_weather then
		mcl_weather.change_weather(new_weather)
	end
end

-- Change weather to new_weather.
-- * explicit_end_time is OPTIONAL. If specified, explicitly set the
--   gametime (core.get_gametime) in which the weather ends.
-- * changer is OPTIONAL, for logging purposes.
function mcl_weather.change_weather(new_weather, explicit_end_time, changer_name)
	local changer_name = changer_name or debug.getinfo(2).name.."()"

	if (mcl_weather.reg_weathers and mcl_weather.reg_weathers[new_weather]) then
		if (mcl_weather.state and mcl_weather.reg_weathers[mcl_weather.state]) then
			mcl_weather.reg_weathers[mcl_weather.state].clear()
		end

		local old_weather = mcl_weather.state

		mcl_weather.state = new_weather

		if old_weather == "none" then
			old_weather = "clear"
		end
		if new_weather == "none" then
			new_weather = "clear"
		end
		core.log("info", "[mcl_weather] " .. changer_name .. " changed the weather from " .. old_weather .. " to " .. new_weather)

		local weather_meta = mcl_weather.reg_weathers[mcl_weather.state]
		if explicit_end_time then
			mcl_weather.end_time = explicit_end_time
		else
			mcl_weather.end_time = mcl_weather.get_rand_end_time(weather_meta.min_duration, weather_meta.max_duration)
		end
		mcl_weather.skycolor.update_sky_color()
		save_weather()
		return true
	end
	return false
end

function mcl_weather.get_weather()
	return mcl_weather.state
end

core.register_privilege("weather_manager", {
	description = S("Gives ability to control weather"),
	give_to_singleplayer = false
})

-- Weather command definition. Set
core.register_chatcommand("weather", {
	params = "(clear | rain | thunder) [<duration>]",
	description = S("Changes the weather to the specified parameter."),
	privs = {weather_manager = true},
	func = function(name, param)
		if (param == "") then
			return false, S("Error: No weather specified.")
		end
		local new_weather, end_time
		local parse1, parse2 = string.match(param, "(%w+) ?(%d*)")
		if parse1 then
			if parse1 == "clear" then
				new_weather = "none"
			else
				new_weather = parse1
			end
		else
			return false, S("Error: Invalid parameters.")
		end
		if parse2 then
			if type(tonumber(parse2)) == "number" then
				local duration = tonumber(parse2)
				if duration < 1 then
					return false, S("Error: Duration can't be less than 1 second.")
				end
				end_time = core.get_gametime() + duration
			end
		end

		local success = mcl_weather.change_weather(new_weather, end_time, name)
		if success then
			return true
		else
			return false, S("Error: Invalid weather specified. Use “clear”, “rain”, or “thunder”.")
		end
	end
})

core.register_chatcommand("toggledownfall", {
	params = "",
	description = S("Toggles between clear weather and weather with downfall (randomly rain, thunderstorm or snow)"),
	privs = {weather_manager = true},
	func = function(name, _)
		-- Currently rain/thunder/snow: Set weather to clear
		if mcl_weather.state ~= "none" then
			return mcl_weather.change_weather("none", nil, name)

		-- Currently clear: Set weather randomly to rain/thunder/snow
		else
			local new = { "rain", "thunder", "snow" }
			local r = math.random(1, #new)
			return mcl_weather.change_weather(new[r], nil, name)
		end
	end
})

-- Configuration setting which allows user to disable ABM for weathers (if they use it).
-- Weather mods expected to be use this flag before registering ABM.
local weather_allow_abm = core.settings:get_bool("weather_allow_abm")
if weather_allow_abm == false then
	mcl_weather.allow_abm = false
end


local function load_weather()
	local weather = storage:get_string("mcl_weather_state")
	-- Previous versions of Mineclonia had a redundant snow state
	-- that would not produce rain in non-snowy biomes.
	if weather == "snow" then
		weather = "rain"
	end
	if weather and weather ~= "" then
		mcl_weather.state = weather
		mcl_weather.end_time = storage:get_int("mcl_weather_end_time")
		mcl_weather.change_weather(weather, mcl_weather.end_time)
		if type(mcl_weather.end_time) ~= "number" then
			-- Fallback in case of corrupted end time
			mcl_weather.end_time = mcl_weather.min_duration
		end
		core.log("info", "[mcl_weather] Weather restored.")
	else
		core.log("info", "[mcl_weather] No weather data found. Starting with clear weather.")
	end
end

load_weather()
