mcl_end = {}

local basepath = core.get_modpath(core.get_current_modname())
dofile(basepath.."/chorus_plant.lua")
dofile(basepath.."/building.lua")
dofile(basepath.."/eye_of_ender.lua")
dofile (basepath.."/common.lua")
dofile(basepath.."/end_crystal.lua")

------------------------------------------------------------------------
-- Level generation & callbacks.
------------------------------------------------------------------------

mcl_levelgen.register_levelgen_script (basepath .. "/common.lua")
mcl_levelgen.register_levelgen_script (basepath .. "/lg_register.lua")
mcl_levelgen.register_levelgen_script (basepath .. "/end_city.lua", true)
dofile (basepath .. "/end_city.lua")

local v = vector.zero ()
local level_to_minetest_position = mcl_levelgen.level_to_minetest_position

local function handle_spawn_end_crystal (_, data)
	v.x, v.y, v.z
		= level_to_minetest_position (data[1], data[2], data[3])
	core.add_entity (v, "mcl_end:crystal")
end

mcl_levelgen.register_notification_handler ("mcl_end:spawn_end_crystal",
					    handle_spawn_end_crystal)

local v1 = vector.zero ()
local function handle_end_gateway (_, data)
	v.x, v.y, v.z
		= level_to_minetest_position (data[1], data[2], data[3])
	core.load_area (v)
	local meta = core.get_meta (v)
	if data[5] then
		v1.x, v1.y, v1.z
			= level_to_minetest_position (data[5], data[6], data[7])
		meta:set_string ("mcl_portals:gateway_destination",
				 core.pos_to_string (v1))
	end
	meta:set_int ("mcl_portals:gateway_exact", data[4] and 1 or 0)
end

mcl_levelgen.register_notification_handler ("mcl_end:end_gateway",
					    handle_end_gateway)
