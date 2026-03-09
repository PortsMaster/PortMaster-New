mcl_ocean = {}
local modpath = core.get_modpath (core.get_current_modname ())

-- Prismarine (includes sea lantern)
dofile(modpath.."/prismarine.lua")

-- Corals
dofile(modpath.."/corals.lua")

-- Seagrass
dofile(modpath.."/seagrass.lua")

-- Kelp
dofile(modpath.."/kelp.lua")

-- Sea Pickle
dofile(modpath.."/sea_pickle.lua")

-- Async feature registration.
mcl_levelgen.register_levelgen_script (modpath .. "/lg_register.lua")
