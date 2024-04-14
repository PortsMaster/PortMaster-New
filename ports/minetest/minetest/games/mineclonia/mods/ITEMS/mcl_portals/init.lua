-- Load files

mcl_portals = {
	storage = minetest.get_mod_storage(),
}

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/portal_nether.lua")
dofile(modpath.."/portal_end.lua")
dofile(modpath.."/portal_gateway.lua")
