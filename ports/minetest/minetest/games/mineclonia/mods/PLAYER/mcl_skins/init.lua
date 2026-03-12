local mod_path = core.get_modpath(core.get_current_modname())

local mcl_skins_enabled = core.settings:get_bool("mcl_enable_skin_customization", true)
if mcl_skins_enabled then
	dofile(mod_path .. "/edit_skin.lua")
	dofile(mod_path .. "/mesh_hand.lua")
end
