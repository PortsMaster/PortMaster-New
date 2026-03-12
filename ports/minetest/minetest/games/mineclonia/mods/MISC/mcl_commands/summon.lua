local S = core.get_translator(core.get_current_modname())

local orig_func = core.registered_chatcommands["spawnentity"].func
local cmd = table.copy(core.registered_chatcommands["spawnentity"])
cmd.func = function(name, param)
	local ent = core.registered_entities[param]
	if core.settings:get_bool("only_peaceful_mobs", false) and ent and ent.is_mob and ent.type == "monster" then
		return false, S("Only peaceful mobs allowed!")
	else
		local bool, msg = orig_func(name, param)
		return bool, msg
	end
end
core.unregister_chatcommand("spawnentity")
core.register_chatcommand("summon", cmd)