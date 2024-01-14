Weather = {}

function Weather.register_weather( id, weather_id )
	if not mapvar then mapvar = {} end
	if not mapvar.tmp then mapvar.tmp = {} end
	if not mapvar.tmp.weather_eff then mapvar.tmp.weather_eff = {} end
	
	--Log("Weather.register_weather ", id, "  ", weather_id)
	
	table.insert(mapvar.tmp.weather_eff, weather_id);
	
	if Weather.slave_proc then
		for k,v in pairs(Weather.slave_proc) do
			if v.r then v.r(id, weather_id) end
		end
	end	
end

function Weather.set_slave_weather_proc(key, reg, create)
	if not Weather.slave_proc then Weather.slave_proc = {} end
	local t = {}
	t.r = reg
	t.c = create	
	Weather.slave_proc[key] = t
end

function Weather.clean_slave_weather_proc(key)
	if Weather.slave_proc then 
		Weather.slave_proc[key] = nil
	end
end

function Weather.check_weather()
	--Log("check_weather,  CONFIG.weather = ", CONFIG.weather) 
	if CONFIG.weather == 1 then
		if Weather.slave_proc then
			for k,v in pairs(Weather.slave_proc) do
				if v.c then v.c() end
			end
		end
	else
		if mapvar and mapvar.tmp and mapvar.tmp.weather_eff then
			for k,v in pairs(mapvar.tmp.weather_eff) do
				--Log("killing wheather ", v);
				SetObjDead(v);
			end
			mapvar.tmp.weather_eff = {}
		end
	end
end

function register_weather( id, weather_id )
	Weather.register_weather( id, weather_id )
end