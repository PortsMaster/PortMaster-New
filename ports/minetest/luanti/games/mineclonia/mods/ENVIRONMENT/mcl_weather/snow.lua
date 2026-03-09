mcl_weather.snow = {}

local PARTICLES_COUNT_SNOW = 100
mcl_weather.snow.init_done = false

local psdef= {
	amount = PARTICLES_COUNT_SNOW,
	time = 0, --stay on til we turn it off
	minpos = vector.new(-25,20,-25),
	maxpos =vector.new(25,25,25),
	minvel = vector.new(-0.2,-1,-0.2),
	maxvel = vector.new(0.2,-4,0.2),
	minacc = vector.new(0,-1,0),
	maxacc = vector.new(0,-4,0),
	minexptime = 3,
	maxexptime = 5,
	minsize = 2,
	maxsize = 5,
	collisiondetection = true,
	collision_removal = true,
	object_collision = true,
	vertical = true,
	glow = 1
}

function mcl_weather.has_snow(pos)
	if not mcl_worlds.has_weather(pos) then return false end
	if not mcl_weather.can_see_outdoors(pos) then
		return false
	end
	local name = mcl_biome_dispatch.get_biome_name (pos)
	return name and mcl_biome_dispatch.is_position_cold (name, pos)
end

function mcl_weather.snow.set_sky_box()
	mcl_weather.skycolor.add_layer(
		"weather-pack-snow-sky",
		{{r=0, g=0, b=0},
		{r=85, g=86, b=86},
		{r=135, g=135, b=135},
		{r=85, g=86, b=86},
		{r=0, g=0, b=0}})
	mcl_weather.skycolor.active = true
	for player in mcl_util.connected_players() do
		player:set_clouds({color="#ADADADE8"})
	end
	mcl_weather.skycolor.active = true
end

function mcl_weather.snow.clear()
	mcl_weather.skycolor.remove_layer("weather-pack-snow-sky")
	mcl_weather.snow.init_done = false
	mcl_weather.remove_all_spawners()
end

local function make_weather_for_player(player)
	mcl_weather.rain.remove_sound(player)
	mcl_weather.snow.add_player(player)
	mcl_weather.snow.set_sky_box()
end
mcl_weather.snow.make_weather_for_player = make_weather_for_player

function mcl_weather.snow.make_weather()
	for player in mcl_util.connected_players() do
		local pos = mcl_util.get_nodepos (player:get_pos ())
		if mcl_weather.has_snow(pos) then
			make_weather_for_player(player)
		end
	end
end

function mcl_weather.snow.step(_)
	mcl_weather.snow.make_weather()
end

function mcl_weather.snow.add_player(player)
	for i=1,2 do
		psdef.texture="weather_pack_snow_snowflake"..i..".png"
		mcl_weather.add_spawner_player(player,"snow"..i,psdef)
	end
end

if mcl_weather.allow_abm then
	core.register_abm({
		label = "Snow piles up",
		nodenames = {"group:opaque","group:leaves","group:snow_cover"},
		neighbors = {"air"},
		interval = 27,
		chance = 33,
		min_y = mcl_vars.mg_overworld_min,
		action = function(pos, node)
			local abovehalf = vector.offset(pos,0,0.5,0)
			if (mcl_weather.state ~= "rain"
			    and mcl_weather.state ~= "thunder"
			    and mcl_weather.state ~= "snow")
				or not mcl_weather.has_snow(abovehalf)
				or mcl_levelgen.is_protected_chunk (pos)
				or node.name == "mcl_core:snowblock" then
				return
			end
			local above = vector.offset(pos,0,1,0)
			local above_node = core.get_node(above)
			if above_node.name == "air" and mcl_weather.is_outdoor(pos) then
				local nn = nil
				if node.name:find("snow") then
					local l = node.name:sub(-1)
					l = tonumber(l)
					if node.name == "mcl_core:snow" then
						nn={name = "mcl_core:snow_2"}
					elseif l and l < 7 then
						nn={name="mcl_core:snow_"..tostring(math.min(8,l + 1))}
					elseif l and l >= 7 then
						nn={name = "mcl_core:snowblock"}
					end
					if nn then core.set_node(pos,nn) end
				else
					core.set_node(above,{name = "mcl_core:snow"})
				end
			end
		end
	})

	-- Filling up cauldrons with powder snow
	core.register_abm({
		label = "Fill cauldrons with powder snow",
		nodenames = {"mcl_cauldrons:cauldron", "mcl_cauldrons:cauldron_1_powder_snow", "mcl_cauldrons:cauldron_2_powder_snow"},
		interval = 56.0,
		chance = 1,
		action = function(pos)
			if mcl_weather.state == "rain"
				and mcl_weather.is_outdoor (pos)
				and mcl_weather.has_snow (pos)
				and not mcl_levelgen.is_protected_chunk (pos) then
				mcl_cauldrons.add_level(pos, 1, "powder_snow")
			end
		end
	})
end
