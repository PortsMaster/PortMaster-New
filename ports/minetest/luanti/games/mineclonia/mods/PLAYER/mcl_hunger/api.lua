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

function mcl_hunger.play_drinking_sound(object)
	core.sound_play("mcl_potions_drinking", {
		gain = 0.75,
		max_hear_distance = 6,
		object = object,
	}, true)
end

function mcl_hunger.play_eating_sound(object)
	core.sound_play("mcl_hunger_eat", {
		gain = 0.4,
		max_hear_distance = 6,
		object = object,
	}, true)
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
		end
		mcl_serverplayer.update_vitals (player)
		return true
	end

	function mcl_hunger.set_saturation(player, saturation)
		saturation = math.min(mcl_hunger.get_hunger(player), math.max(0, saturation))
		player:get_meta():set_string("mcl_hunger:saturation", tostring(saturation))
		mcl_serverplayer.update_vitals (player)
		return true
	end

	function mcl_hunger.set_exhaustion(player, exhaustion)
		exhaustion = math.min(mcl_hunger.EXHAUST_LVL, math.max(0.0, exhaustion))
		player:get_meta():set_string("mcl_hunger:exhaustion", tostring(exhaustion))
		return true
	end

	function mcl_hunger.exhaust(playername, increase)
		local player = core.get_player_by_name(playername)
		if not player or mcl_vars.difficulty == 0 then return false end
		mcl_hunger.set_exhaustion(player, mcl_hunger.get_exhaustion(player) + increase)
		if mcl_hunger.get_exhaustion(player) >= mcl_hunger.EXHAUST_LVL then
			mcl_hunger.set_exhaustion(player, 0.0)
			local s = mcl_hunger.get_saturation(player)
			if s > 0 then
				mcl_hunger.set_saturation(player, math.max(s - 1.5, 0))
			elseif s <= 0.0001 then
				local h = mcl_hunger.get_hunger(player)
				h = math.max(h-1, 0)
				mcl_hunger.set_hunger(player, h)
			end
		end
		return true
	end

	function mcl_hunger.saturate(playername, increase)
		local player = core.get_player_by_name(playername)
		local ok = mcl_hunger.set_saturation(player,
			math.min(mcl_hunger.get_saturation(player) + increase, mcl_hunger.get_hunger(player)))
		return ok
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
end
