mcl_doors = {}

local this = core.get_current_modname()
local path = core.get_modpath(this)

dofile(path.."/api_doors.lua") -- Doors API
dofile(path.."/api_trapdoors.lua") -- Trapdoors API
dofile(path.."/register.lua") -- Register builtin doors and trapdoors
