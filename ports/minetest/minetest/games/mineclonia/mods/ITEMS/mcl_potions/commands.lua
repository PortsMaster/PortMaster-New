local S = core.get_translator(core.get_current_modname())

-- ░█████╗░██╗░░██╗░█████╗░████████╗  ░█████╗░░█████╗░███╗░░░███╗███╗░░░███╗░█████╗░███╗░░██╗██████╗░░██████╗
-- ██╔══██╗██║░░██║██╔══██╗╚══██╔══╝  ██╔══██╗██╔══██╗████╗░████║████╗░████║██╔══██╗████╗░██║██╔══██╗██╔════╝
-- ██║░░╚═╝███████║███████║░░░██║░░░  ██║░░╚═╝██║░░██║██╔████╔██║██╔████╔██║███████║██╔██╗██║██║░░██║╚█████╗░
-- ██║░░██╗██╔══██║██╔══██║░░░██║░░░  ██║░░██╗██║░░██║██║╚██╔╝██║██║╚██╔╝██║██╔══██║██║╚████║██║░░██║░╚═══██╗
-- ╚█████╔╝██║░░██║██║░░██║░░░██║░░░  ╚█████╔╝╚█████╔╝██║░╚═╝░██║██║░╚═╝░██║██║░░██║██║░╚███║██████╔╝██████╔╝
-- ░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░  ░╚════╝░░╚════╝░╚═╝░░░░░╚═╝╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░╚═════╝░

core.register_chatcommand("effect",{
	params = S("<effect>|heal|list|clear|remove <duration|heal-amount|effect>|INF [<level>] [<factor>] [NOPART]"),
	description = S("Add a status effect to yourself. Arguments: <effect>: name of status effect. Passing \"list\" as effect name lists available effects. Passing \"heal\" as effect name heals (or harms) by amount designed by the next parameter. Passing \"clear\" as effect name removes all effects. Passing \"remove\" as effect name removes the effect named by the next parameter. <duration>: duration in seconds. Passing \"INF\" as duration makes the effect infinite. (<heal-amount>: amount of healing when the effect is \"heal\", passing a negative value subtracts health. <effect>: name of a status effect to be removed when using \"remove\" as the previous parameter.) <level>: effect power determinant, bigger level results in more powerful effect for effects that depend on the level (no changes for other effects), defaults to 1, pass F to use low-level factor instead. <factor>: effect strength modifier, can mean different things depending on the effect, no changes for effects that do not depend on level/factor. NOPART at the end means no particles will be shown for this effect."),
	privs = {server = true},
	func = function(name, params)

		local P = {}
		local i = 0
		for str in string.gmatch(params, "([^ ]+)") do
			i = i + 1
			P[i] = str
		end

		if not P[1] then
			return false, S("Missing effect parameter!")
		elseif P[1] == "list" then
			local effects = "heal"
			for effect, _ in pairs(mcl_potions.registered_effects) do
				effects = effects .. ", " .. effect
			end
			return true, effects
		elseif P[1] == "heal" then
			local hp = tonumber(P[2])
			if not hp or hp == 0 then
				return false, S("Missing or invalid heal amount parameter!")
			else
				mcl_potions.healing_func(core.get_player_by_name(name), hp)
				if hp > 0 then
					if hp < 1 then hp = 1 end
					return true, S("Player @1 healed by @2 HP.", name, hp)
				else
					if hp > -1 then hp = -1 end
					return true, S("Player @1 harmed by @2 HP.", name, hp)
				end
			end
		elseif P[1] == "clear" then
			mcl_potions._reset_effects(core.get_player_by_name(name))
			return true, S("Effects cleared for player @1", name)
		elseif P[1] == "remove" then
			if not P[2] then
				return false, S("Missing effect parameter!")
			end
			if mcl_potions.registered_effects[P[2]] then
				mcl_potions.clear_effect(core.get_player_by_name(name), P[2])
				return true, S("Removed effect @1 from player @2", P[2], name)
			else
				return false, S("@1 is not an available status effect.", P[2])
			end
		elseif not tonumber(P[2]) and P[2] ~= "INF" then
			return false, S("Missing or invalid duration parameter!")
		elseif P[3] and not tonumber(P[3]) and P[3] ~= "F" and P[3] ~= "NOPART" then
			return false, S("Invalid level parameter!")
		elseif P[3] and P[3] == "F" and not P[4] then
			return false, S("Missing or invalid factor parameter when level is F!")
		end
		-- Default factor = 1
		if not P[3] then
			P[3] = 1
		elseif P[3] == "NOPART" then
			P[3] = 1
			P[4] = "NOPART"
		end

		local inf = P[2] == "INF"

		local nopart
		if P[3] == "F" then
			nopart = P[5] == "NOPART"
		else
			nopart = P[4] == "NOPART"
		end

		local def = mcl_potions.registered_effects[P[1]]
		if def then
			if P[3] == "F" then
				local given = mcl_potions.give_effect(P[1], core.get_player_by_name(name), tonumber(P[4]), inf and "INF" or tonumber(P[2]), nopart)
				if given then
					if def.uses_factor then
						return true, S("@1 effect given to player @2 for @3 seconds with factor of @4.", def.description, name, P[2], P[4])
					else
						return true, S("@1 effect given to player @2 for @3 seconds.", def.description, name, P[2])
					end
				else
					return false, S("Giving effect @1 to player @2 failed.", def.description, name)
				end
			else
				local given = mcl_potions.give_effect_by_level(P[1], core.get_player_by_name(name), tonumber(P[3]), inf and "INF" or tonumber(P[2]), nopart)
				if given then
					if def.uses_factor then
						return true, S("@1 effect on level @2 given to player @3 for @4 seconds.", def.description, P[3], name, P[2])
					else
						return true, S("@1 effect given to player @2 for @3 seconds.", def.description, name, P[2])
					end
				else
					return false, S("Giving effect @1 to player @2 failed.", def.description, name)
				end
			end
		else
			return false, S("@1 is not an available status effect.", P[1])
		end

	 end,
})
