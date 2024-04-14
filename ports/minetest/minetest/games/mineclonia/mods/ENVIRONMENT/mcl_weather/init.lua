local modpath = minetest.get_modpath(minetest.get_current_modname())

mcl_weather = {}

-- If not located then embeded skycolor mod version will be loaded.
if minetest.get_modpath("skycolor") == nil then
	dofile(modpath.."/skycolor.lua")
end

dofile(modpath.."/weather_core.lua")
dofile(modpath.."/snow.lua")
dofile(modpath.."/rain.lua")
dofile(modpath.."/nether_dust.lua")
dofile(modpath.."/thunder.lua")