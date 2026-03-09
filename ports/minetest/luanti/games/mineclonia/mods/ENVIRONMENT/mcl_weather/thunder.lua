mcl_weather.thunder = {
	next_strike = 0,
	min_delay = 3,
	max_delay = 12,
	init_done = false,
}

mcl_lightning.register_on_strike(function(pos, pos2, objects)
	if not mcl_weather.has_rain(pos) then return nil, true end
end)

function mcl_weather.thunder.step(_)
	mcl_weather.rain.set_particles_mode("thunder")
	mcl_weather.rain.make_weather()

	if mcl_weather.thunder.init_done == false then
		mcl_weather.skycolor.add_layer("weather-pack-thunder-sky", {
			{r=0, g=0, b=0},
			{r=40, g=40, b=40},
			{r=85, g=86, b=86},
			{r=40, g=40, b=40},
			{r=0, g=0, b=0},
		})
		mcl_weather.skycolor.active = true
		for player in mcl_util.connected_players() do
			player:set_clouds({color="#3D3D3FE8"})
		end
		mcl_weather.thunder.init_done = true
	end
	if (mcl_weather.thunder.next_strike <= core.get_gametime()) then
		mcl_lightning.strike()
		local delay = math.random(mcl_weather.thunder.min_delay, mcl_weather.thunder.max_delay)
		mcl_weather.thunder.next_strike = core.get_gametime() + delay
	end
end

function mcl_weather.thunder.clear()
	mcl_weather.rain.clear()
	mcl_weather.skycolor.remove_layer("weather-pack-thunder-sky")
	mcl_weather.skycolor.remove_layer("lightning")
	mcl_weather.thunder.init_done = false
end

-- register thunderstorm weather
if mcl_weather.reg_weathers.thunder == nil then
	mcl_weather.reg_weathers.thunder = {
		clear = mcl_weather.thunder.clear,
		light_factor = 0.33333,
		-- 10min - 20min
		min_duration = 600,
		max_duration = 1200,
		transitions = {
			[100] = "rain",
		},
	}
end
