--Bow
dofile(minetest.get_modpath("mcl_bows") .. "/arrow.lua")
dofile(minetest.get_modpath("mcl_bows") .. "/bow.lua")

--Crossbow
dofile(minetest.get_modpath("mcl_bows") .. "/crossbow.lua")

--Compatiblility with older MineClone worlds
minetest.register_alias("mcl_throwing:bow", "mcl_bows:bow")
minetest.register_alias("mcl_throwing:arrow", "mcl_bows:arrow")
