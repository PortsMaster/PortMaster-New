local modpath = core.get_modpath(core.get_current_modname())

dofile(modpath.."/small.lua")
dofile(modpath.."/huge.lua")

-- Aliases for old MCL2 versions
core.register_alias("mcl_farming:mushroom_red", "mcl_mushrooms:mushroom_red")
core.register_alias("mcl_farming:mushroom_brown", "mcl_mushrooms:mushroom_brown")

mcl_levelgen.register_levelgen_script (modpath .. "/lg_register.lua")
