mcl_core = {}

-- Repair percentage for toolrepair
mcl_core.repair = 0.05

mcl_autogroup.register_diggroup("handy")
mcl_autogroup.register_diggroup("pickaxey", {
	levels = { "wood", "gold", "stone", "iron", "diamond" }
})
mcl_autogroup.register_diggroup("axey")
mcl_autogroup.register_diggroup("shovely")
mcl_autogroup.register_diggroup("shearsy")
mcl_autogroup.register_diggroup("shearsy_wool")
mcl_autogroup.register_diggroup("shearsy_cobweb")
mcl_autogroup.register_diggroup("swordy")
mcl_autogroup.register_diggroup("swordy_cobweb")
mcl_autogroup.register_diggroup("hoey")

-- Load files
local modpath = minetest.get_modpath(minetest.get_current_modname())
dofile(modpath.."/functions.lua")
dofile(modpath.."/nodes_base.lua") -- Simple solid cubic nodes with simple definitions
dofile(modpath.."/nodes_liquid.lua") -- Liquids
dofile(modpath.."/nodes_trees.lua") -- Trees
dofile(modpath.."/nodes_cactuscane.lua") -- Cactus and sugar canes
dofile(modpath.."/nodes_glass.lua") -- Glass
dofile(modpath.."/nodes_climb.lua") -- Climbable nodes
dofile(modpath.."/nodes_stairs.lua")
dofile(modpath.."/nodes_misc.lua") -- Other and special nodes
dofile(modpath.."/craftitems.lua")
dofile(modpath.."/crafting.lua")
