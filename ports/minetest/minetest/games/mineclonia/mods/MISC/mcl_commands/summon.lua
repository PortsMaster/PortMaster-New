local S = minetest.get_translator(minetest.get_current_modname())

local orig_func = minetest.registered_chatcommands["spawnentity"].func
local cmd = table.copy(minetest.registered_chatcommands["spawnentity"])
cmd.func = function(name, param)
	local ent = minetest.registered_entities[param]
	if minetest.settings:get_bool("only_peaceful_mobs", false) and ent and ent.is_mob and ent.type == "monster" then
		return false, S("Only peaceful mobs allowed!")
	else
		local bool, msg = orig_func(name, param)
		return bool, msg
	end
end
minetest.unregister_chatcommand("spawnentity")
minetest.register_chatcommand("summon", cmd)