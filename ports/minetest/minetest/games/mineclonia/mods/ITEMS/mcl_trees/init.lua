mcl_trees = {}
mcl_trees.woods = {}

local modpath = core.get_modpath(core.get_current_modname())

dofile(modpath.."/functions.lua")
dofile(modpath.."/api.lua")
dofile(modpath.."/abms.lua")

dofile (modpath .. "/lg_register.lua")
mcl_levelgen.register_levelgen_script (modpath .. "/lg_register.lua")
