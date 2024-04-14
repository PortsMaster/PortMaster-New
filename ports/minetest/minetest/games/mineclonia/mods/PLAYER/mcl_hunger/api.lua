mcl_hunger.registered_foods = {}

function mcl_hunger.init_player(player)
	local meta = player:get_meta()
	if meta:get_string("mcl_hunger:hunger") == "" then
		meta:set_string("mcl_hunger:hunger", tostring(20))
	end
	if meta:get_string("mcl_hunger:saturation") == "" then
		meta:set_string("mcl_hunger:saturation", tostring(mcl_hunger.SATURATION_INIT))
	end
	if meta:get_string("mcl_hunger:exhaustion") == "" then
		meta:set_string("mcl_hunger:exhaustion", tostring(0))
	end
end

if mcl_hunger.active then
	function mcl_hunger.get_hunger(player)
		local hunger = tonumber(player:get_meta():get_string("mcl_hunger:hunger")) or 20
		return hunger
	end

	function mcl_hunger.get_saturation(player)
		local saturation = tonumber(player:get_meta():get_string("mcl_hunger:saturation")) or mcl_hunger.SATURATION_INIT
		return saturation
	end

	function mcl_hunger.get_exhaustion(player)
		local exhaustion = tonumber(player:get_meta():get_string("mcl_hunger:exhaustion")) or 0
		return exhaustion
	end

	function mcl_hunger.set_hunger(player, hunger, update_hudbars)
		hunger = math.min(20, math.max(0, hunger))
		player:get_meta():set_string("mcl_hunger:hunger", tostring(hunger))
		if update_hudbars ~= false then
			hb.change_hudbar(player, "hunger", hunger)
			mcl_hunger.update_saturation_hud(player, nil, hunger)
		end
		return true
	end

	function mcl_hunger.set_saturation(player, saturation, update_hudbar)
		saturation = math.min(mcl_hunger.get_hunger(player), math.max(0, saturation))
		player:get_meta():set_string("mcl_hunger:saturation", tostring(saturation))
		if update_hudbar ~= false then
			mcl_hunger.update_saturation_hud(player, saturation)
		end
		return true
	end

	function mcl_hunger.set_exhaustion(player, exhaustion, update_hudbar)
		exhaustion = math.min(mcl_hunger.EXHAUST_LVL, math.max(0.0, exhaustion))
		player:get_meta():set_string("mcl_hunger:exhaustion", tostring(exhaustion))
		if update_hudbar ~= false then
			mcl_hunger.update_exhaustion_hud(player, exhaustion)
		end
		return true
	end

	function mcl_hunger.exhaust(playername, increase)
		local player = minetest.get_player_by_name(playername)
		if not player then return false end
		mcl_hunger.set_exhaustion(player, mcl_hunger.get_exhaustion(player) + increase)
		if mcl_hunger.get_exhaustion(player) >= mcl_hunger.EXHAUST_LVL then
			mcl_hunger.set_exhaustion(player, 0.0)
			local h = nil
			local satuchanged = false
			local s = mcl_hunger.get_saturation(player)
			if s > 0 then
				mcl_hunger.set_saturation(player, math.max(s - 1.5, 0))
				satuchanged = true
			elseif s <= 0.0001 then
				h = mcl_hunger.get_hunger(player)
				h = math.max(h-1, 0)
				mcl_hunger.set_hunger(player, h)
				satuchanged = true
			end
			if satuchanged then
				if h then h = h end
				mcl_hunger.update_saturation_hud(player, mcl_hunger.get_saturation(player), h)
			end
		end
		mcl_hunger.update_exhaustion_hud(player, mcl_hunger.get_exhaustion(player))
		return true
	end

	function mcl_hunger.saturate(playername, increase, update_hudbar)
		local player = minetest.get_player_by_name(playername)
		local ok = mcl_hunger.set_saturation(player,
			math.min(mcl_hunger.get_saturation(player) + increase, mcl_hunger.get_hunger(player)))
		if update_hudbar ~= false then
			mcl_hunger.update_saturation_hud(player, mcl_hunger.get_saturation(player), mcl_hunger.get_hunger(player))
		end
		return ok
	end

	function mcl_hunger.register_food(name, hunger_change, replace_with_item, poisontime, poison, exhaust, poisonchance, sound)
		if not mcl_hunger.active then
			return
		end
		local food = mcl_hunger.registered_foods
		food[name] = {}
		food[name].saturation = hunger_change	-- hunger points added
		food[name].replace = replace_with_item	-- what item is given back after eating
		food[name].poisontime = poisontime	-- time it is poisoning. If this is set, this item is considered poisonous,
							-- otherwise the following poison/exhaust fields are ignored
		food[name].poison = poison		-- poison damage per tick for poisonous food
		food[name].exhaust = exhaust		-- exhaustion per tick for poisonous food
		food[name].poisonchance = poisonchance	-- chance percentage that this item poisons the player (default: 100%)
		food[name].sound = sound		-- special sound that is played when eating
	end

	function mcl_hunger.stop_poison(player)
		if not mcl_hunger.active then
			return
		end
		mcl_hunger.poison_hunger[player:get_player_name()] = 0
		mcl_hunger.reset_bars_poison_hunger(player)
	end

else
	-- When hunger is disabled, the functions are basically no-ops

	function mcl_hunger.get_hunger()
		return 20
	end

	function mcl_hunger.get_saturation()
		return mcl_hunger.SATURATION_INIT
	end

	function mcl_hunger.get_exhaustion()
		return 0
	end

	function mcl_hunger.set_hunger()
		return false
	end

	function mcl_hunger.set_saturation()
		return false
	end

	function mcl_hunger.set_exhaustion()
		return false
	end

	function mcl_hunger.exhaust()
		return false
	end

	function mcl_hunger.saturate()
		return false
	end

	function mcl_hunger.register_food() end

	function mcl_hunger.stop_poison() end

end
