local S = core.get_translator(core.get_current_modname())

local function handle_kill_command(suspect, victim)
	if core.settings:get_bool("enable_damage") == false then
		return false, S("Players can't be killed right now, damage has been disabled.")
	end
	local victimref = core.get_player_by_name(victim)
	if victimref == nil then
		return false, S("Player @1 does not exist.", victim)
	elseif victimref:get_hp() <= 0 then
		if suspect == victim then
			return false, S("You are already dead")
		else
			return false, S("@1 is already dead", victim)
		end
	end
	-- DIE!
	mcl_damage.damage_player (victimref, mcl_damage.get_hp (victimref),
				  { type = "out_of_world", })
	-- Log
	if suspect ~= victim then
		core.log("action", string.format("%s killed %s using /kill", suspect, victim))
	else
		core.log("action", string.format("%s committed suicide using /kill", victim))
	end
	return true
end

if core.registered_chatcommands["kill"] then
	core.unregister_chatcommand("kill")
end
core.register_chatcommand("kill", {
	params = S("[<name>]"),
	description = S("Kill player or yourself"),
	privs = {server=true},
	func = function(name, param)
		if(param == "") then
			-- Selfkill
			return handle_kill_command(name, name)
		else
			return handle_kill_command(name, param)
		end
	end,
})
