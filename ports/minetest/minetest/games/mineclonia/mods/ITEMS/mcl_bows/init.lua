mcl_bows = {}

local modpath = core.get_modpath(core.get_current_modname())

--Bow
dofile(modpath .. "/arrow.lua")
dofile(modpath .. "/bow.lua")

--Crossbow
dofile(modpath .. "/crossbow.lua")

--Compatiblility with older Mineclonia worlds
core.register_alias("mcl_throwing:bow", "mcl_bows:bow")
core.register_alias("mcl_throwing:arrow", "mcl_bows:arrow")
