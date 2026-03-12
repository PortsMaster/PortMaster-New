------------------------------------------------------------------------
-- Skybox and weather support for client-side players.
------------------------------------------------------------------------

mcl_serverplayer.default_precipitation_spawners = {
	default = {
		textures = {
			"weather_pack_rain_raindrop_1.png",
			"weather_pack_rain_raindrop_2.png",
			"weather_pack_rain_raindrop_3.png",
		},
		velocity_min = vector.new (0, -14, 0),
		velocity_max = vector.new (0, -14, 0),
		particles_per_column = 28,
		size = 3,
		range_vertical = 10,
		range_horizontal = 10,
		period = 65536.0,
		above_heightmap = true,
	},
	cold = {
		textures = {
			"weather_pack_snow_snowflake1.png",
			"weather_pack_snow_snowflake2.png",
			"weather_pack_snow_snowflake3.png",
			"weather_pack_snow_snowflake4.png",
			"weather_pack_snow_snowflake5.png",
			"weather_pack_snow_snowflake6.png",
			"weather_pack_snow_snowflake7.png",
			"weather_pack_snow_snowflake8.png",
			"weather_pack_snow_snowflake9.png",
			"weather_pack_snow_snowflake10.png",
			"weather_pack_snow_snowflake11.png",
		},
		velocity_min = vector.new (-0.124, -0.53, -0.124),
		velocity_max = vector.new (0.124, -0.49, 0.124),
		particles_per_column = 30,
		size = 1,
		range_vertical = 10,
		range_horizontal = 10,
		period = 65536.0,
		above_heightmap = true,
	},
}

function mcl_serverplayer.update_skybox (state, player, dtime)
	local self_pos = player:get_pos ()
	local node_pos = mcl_util.get_nodepos (self_pos)
	local _, dim = mcl_worlds.y_to_layer (node_pos.y)
	local skybox_data = state.skybox_data or {}
	local biome_sky_color
		= mcl_biome_dispatch.get_sky_color (node_pos)
	local biome_fog_color
		= mcl_biome_dispatch.get_fog_color (node_pos)
	local weather_state = mcl_weather.state
	local update_p = false
	local need_climate_update = state.proto >= 5
	local climate = nil

	if need_climate_update then
		local name = mcl_biome_dispatch.get_biome_name (node_pos)
		if not mcl_worlds.has_weather (node_pos) then
			climate = "none"
		elseif mcl_biome_dispatch.is_position_cold (name, node_pos) then
			climate = "cold"
		elseif mcl_biome_dispatch.is_position_arid (name, node_pos) then
			climate = "arid"
		else
			climate = "default"
		end
	end

	if biome_sky_color ~= skybox_data.biome_sky_color
		or biome_fog_color ~= skybox_data.biome_fog_color
		or weather_state ~= skybox_data.weather_state
		or (need_climate_update
		    and climate ~= skybox_data.climate) then
		update_p = true
	end

	skybox_data.biome_sky_color = biome_sky_color
	skybox_data.biome_fog_color = biome_fog_color
	skybox_data.weather_state = weather_state
	skybox_data.climate = climate

	if update_p then
		mcl_serverplayer.send_effect_ctrl (player, skybox_data)
	end

	local tod_update_timer = (state.tod_update_timer or 0) + dtime
	if tod_update_timer > 0.5 or dim ~= state.last_dimension then
		tod_update_timer = 0
		if dim == "end" then
			player:override_day_night_ratio (0.5)
		elseif dim == "nether" or dim == "void" then
			player:override_day_night_ratio (nil)
		elseif weather_state == "rain" then
			local tod = core.get_timeofday ()
			local ratio = core.time_to_day_night_ratio (tod) * 0.85
			player:override_day_night_ratio (ratio)
		elseif weather_state == "thunder" then
			local tod = core.get_timeofday ()
			local ratio = core.time_to_day_night_ratio (tod) * 0.675
			player:override_day_night_ratio (ratio)
		else
			player:override_day_night_ratio (nil)
		end
	end

	state.last_dimension = dim
	state.tod_update_timer = tod_update_timer
	state.skybox_data = skybox_data
end
