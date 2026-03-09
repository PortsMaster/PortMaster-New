mcl_farming = {}
local modpath = core.get_modpath(core.get_current_modname())

-- IMPORTANT API AND HELPER FUNCTIONS --
-- Contain functions for planting seed, addind plant growth and gourds (melon/pumpkin-like)
dofile(modpath.."/shared_functions.lua")

dofile(modpath.."/soil.lua")
dofile(modpath.."/hoes.lua")
dofile(modpath.."/wheat.lua")
dofile(modpath.."/pumpkin.lua")
dofile(modpath.."/melon.lua")
dofile(modpath.."/carrots.lua")
dofile(modpath.."/potatoes.lua")
dofile(modpath.."/beetroot.lua")
dofile(modpath.."/sweet_berry.lua")

mcl_levelgen.register_levelgen_script (modpath .. "/lg_register.lua")
