local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

mcl_util = {}

-- `table` extensions
dofile(modpath .. "/table.lua")
core.register_mapgen_script (modpath .. "/table.lua")
core.register_async_dofile (modpath .. "/table.lua")
-- Utilities for environment access (nodes, mapgen)
dofile(modpath .. "/environment.lua")
-- Item-related utilities
dofile(modpath .. "/item.lua")
-- Functions operating on ObjectRefs
dofile(modpath .. "/object.lua")
-- Misc. utility functions
dofile(modpath .. "/misc.lua")
-- Queue class
mcl_util.queue = dofile(modpath .. "/queue.lua")
-- Ringbuffer class
mcl_util.ringbuffer = dofile(modpath .. "/ringbuffer.lua")
-- Conversion to roman numerals
dofile(modpath .. "/roman.lua")
-- Backwards compatibility
dofile(modpath .. "/compat.lua")
-- Shape library.
dofile(modpath.."/shape.lua")
core.register_mapgen_script (modpath .. "/shape.lua")
core.register_async_dofile (modpath .. "/shape.lua")
-- Spatial index library.
dofile (modpath .. "/spatialindex.lua")
