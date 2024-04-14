mcl_weather.snow = {}

local PARTICLES_COUNT_SNOW = 100
mcl_weather.snow.init_done = false
local mgname = minetest.get_mapgen_setting("mg_name")

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
	if  mgname == "singlenode" then return false end
	local bn = minetest.get_biome_name(minetest.get_biome_data(pos).biome)
	local bd = minetest.registered_biomes[bn]
	if not mcl_weather.can_see_outdoors(pos) then
		return false
	end
	if bd and bd._mcl_biome_type == "snowy" then return true end
	if bd and bd._mcl_biome_type == "cold" then
		if bn == "Taiga" and pos.y > 140 then return true end
		if bn == "MegaSpruceTaiga" and pos.y > 100 then return true end
	end
	return false
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
	for _, player in pairs(minetest.get_connected_players()) do
		player:set_clouds({color="#ADADADE8"})
	end
	mcl_weather.skycolor.active = true
end

function mcl_weather.snow.clear()
	mcl_weather.skycolor.remove_layer("weather-pack-snow-sky")
	mcl_weather.snow.init_done = false
	mcl_weather.remove_all_spawners()
end

function mcl_weather.snow.add_player(player)
	for i=1,2 do
		psdef.texture="weather_pack_snow_snowflake"..i..".png"
		mcl_weather.add_spawner_player(player,"snow"..i,psdef)
	end
end

local timer = 0
minetest.register_globalstep(function(dtime)
	if mcl_weather.state ~= "snow" then
		return false
	end

	timer = timer + dtime;
	if timer >= 0.5 then
		timer = 0
	else
		return
	end

	if mcl_weather.snow.init_done == false then
		mcl_weather.snow.set_sky_box()
		mcl_weather.snow.init_done = true
	end

	for _, player in pairs(minetest.get_connected_players()) do
		if mcl_weather.is_underwater(player) or not mcl_weather.has_snow(player:get_pos()) then
			mcl_weather.remove_spawners_player(player)
			mcl_weather.set_sky_box_clear(player)
		else
			mcl_weather.snow.add_player(player)
			mcl_weather.snow.set_sky_box()
		end
	end
end)

-- register snow weather
if mcl_weather.reg_weathers.snow == nil then
	mcl_weather.reg_weathers.snow = {
		clear = mcl_weather.snow.clear,
		light_factor = 0.6,
		-- 10min - 20min
		min_duration = 600,
		max_duration = 1200,
		transitions = {
			[65] = "none",
			[80] = "rain",
			[100] = "thunder",
		}
	}
end

minetest.register_abm({
	label = "Snow piles up",
	nodenames = {"group:opaque","group:leaves","group:snow_cover"},
	neighbors = {"air"},
	interval = 27,
	chance = 33,
	min_y = mcl_vars.mg_overworld_min,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if (mcl_weather.state ~= "rain" and mcl_weather.state ~= "thunder" and mcl_weather.state ~= "snow")
		or not mcl_weather.has_snow(pos)
		or node.name == "mcl_core:snowblock" then
			return end

		local above = vector.offset(pos,0,1,0)
		local above_node = minetest.get_node(above)

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
				if nn then minetest.set_node(pos,nn) end
			else
				minetest.set_node(above,{name = "mcl_core:snow"})
			end
		end
	end
})
