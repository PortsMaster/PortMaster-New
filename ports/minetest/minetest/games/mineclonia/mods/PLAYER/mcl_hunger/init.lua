local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

local S = core.get_translator(modname)

mcl_hunger = {}

--[[ This variable tells you if the hunger gameplay mechanic is active.
The state of the hunger mechanic will be determined at game start.
Hunger is enabled when damage is enabled.
If the damage setting is changed within the game, this does NOT
update the hunger mechanic, so the game must be restarted for this
to take effect. ]]
mcl_hunger.active = false
if core.settings:get_bool("enable_damage") == true and core.settings:get_bool("mcl_enable_hunger") ~= false then
	mcl_hunger.active = true
end

mcl_hunger.EAT_DELAY = 1.61

-- Exhaustion increase
mcl_hunger.EXHAUST_DIG = 5  -- after digging node
mcl_hunger.EXHAUST_JUMP = 50 -- jump
mcl_hunger.EXHAUST_SPRINT_JUMP = 200 -- jump while sprinting
mcl_hunger.EXHAUST_ATTACK = 100 -- hit an enemy
mcl_hunger.EXHAUST_SWIM = 10 -- player movement in water
mcl_hunger.EXHAUST_SPRINT = 100 -- sprint (per node)
mcl_hunger.EXHAUST_DAMAGE = 100 -- taking damage (protected by armor)
mcl_hunger.EXHAUST_REGEN = 6000 -- Regenerate 1 HP
mcl_hunger.EXHAUST_HUNGER = 5 -- Hunger status effect at base level.
mcl_hunger.EXHAUST_LVL = 4000 -- at what exhaustion player saturation gets lowered

mcl_hunger.SATURATION_INIT = 5 -- Initial saturation for new/respawning players

mcl_hunger.eat_cooldown = {} -- used for quick eat (either special setting or when food has `no_eat_delay` group)
mcl_hunger.eat_duration = {}

mcl_hunger.eat_anim_hud = {}
mcl_hunger.eat_anim_block = {}
mcl_hunger.eat_anim_effect = {} -- effect timer for precise interval

dofile(modpath.."/api.lua")
dofile(modpath.."/hunger.lua")
dofile(modpath.."/compat.lua")

if not mcl_hunger.active then
	core.register_on_joinplayer(function(player)
		mcl_hunger.init_player(player)
	end)
	return
end

--[[ Data value format notes:
	Hunger values is identical to Minecraft's and ranges from 0 to 20.
	Exhaustion and saturation values are stored as integers, unlike in Minecraft.
	Exhaustion is Minecraft exhaustion times 1000 and ranges from 0 to 4000.
	Saturation is Minecraft saturation and ranges from 0 to 20.

	Food saturation is stored in the custom item definition field _mcl_saturation.
	This field uses the original Minecraft value.
]]

-- register saturation hudbar
hb.register_hudbar("hunger", 0xFFFFFF, S("Food"), { icon = "hbhunger_icon.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 20, 20, false, nil, nil, 1)

core.register_on_joinplayer(function(player)
	mcl_hunger.init_player(player)
	hb.init_hudbar(player, "hunger", mcl_hunger.get_hunger(player))
end)

core.register_on_respawnplayer(function(player)
	local h, s, e = 20, mcl_hunger.SATURATION_INIT, 0
	mcl_hunger.set_hunger(player, h, false)
	mcl_hunger.set_saturation(player, s)
	mcl_hunger.set_exhaustion(player, e)
	hb.change_hudbar(player, "hunger", h)
end)

-- PvP combat exhaustion
core.register_on_punchplayer(function(victim, puncher, time_from_last_punch, tool_capabilities, dir, damage) ---@diagnostic disable-line: unused-local
	if puncher:is_player() then
		mcl_hunger.exhaust(puncher:get_player_name(), mcl_hunger.EXHAUST_ATTACK)
	end
end)

-- Exhaust on taking damage
core.register_on_player_hpchange(function(player, hp_change)
	if hp_change < 0 then
		local name = player:get_player_name()
		mcl_hunger.exhaust(name, mcl_hunger.EXHAUST_DAMAGE)
	end
end)

local food_tick_timers = {} -- one food_tick_timer per player, keys are the player-objects
local peaceful_heal_timer = {}
local peaceful_nourish_timer = {}

mcl_player.register_globalstep(function(player, dtime)
	local food_tick_timer = food_tick_timers[player] and food_tick_timers[player] + dtime or 0
	local player_name = player:get_player_name()
	local food_level = mcl_hunger.get_hunger(player)
	local food_saturation_level = mcl_hunger.get_saturation(player)
	local player_health = mcl_damage.get_hp (player)
	local props = player:get_properties ()

	if mcl_vars.difficulty == 0 then
		-- Heal player by 1 heart every two seconds and grant
		-- more food points every half a second.
		if (peaceful_heal_timer[player] or 1.0) >= 1.0 then
			if player_health > 0 and player_health < props.hp_max then
				mcl_damage.heal_player (player, 1)
			end
			peaceful_heal_timer[player] = 0
		else
			peaceful_heal_timer[player]
				= peaceful_heal_timer[player] + dtime
		end
		if (peaceful_nourish_timer[player] or 0.5) >= 0.5 then
			local hunger = mcl_hunger.get_hunger (player)
			if hunger < 20 then
				mcl_hunger.set_hunger (player, hunger + 1, true)
			end
			peaceful_nourish_timer[player] = 0
		else
			peaceful_nourish_timer[player]
				= peaceful_nourish_timer[player] + dtime
		end
	elseif food_tick_timer > 4.0 then
		food_tick_timer = 0

		if food_level >= 18 then -- slow regeneration
			if player_health > 0 and player_health < props.hp_max then
				mcl_damage.heal_player (player, 1)
				mcl_hunger.exhaust(player_name, mcl_hunger.EXHAUST_REGEN)
			end
		elseif food_level == 0 then -- starvation
			-- the amount of health at which a player will stop to get
			-- harmed by starvation (10 for Easy, 1 for Normal, 0 for Hard)
			local maximum_starvation
			if mcl_vars.difficulty <= 1 then
				maximum_starvation = 10
			elseif mcl_vars.difficulty < 3 then
				maximum_starvation = 1
			else
				maximum_starvation = 0
			end
			if player_health > maximum_starvation then
				mcl_util.deal_damage (player, 1, {type = "starve"})
			end
		end

	elseif food_tick_timer > 0.5 and food_level == 20 and food_saturation_level > 0 then -- fast regeneration
		if player_health > 0 and player_health < props.hp_max then
			food_tick_timer = 0
			mcl_damage.heal_player (player, 1)
			mcl_hunger.exhaust(player_name, mcl_hunger.EXHAUST_REGEN)
		end
	end

	food_tick_timers[player] = food_tick_timer -- update food_tick_timer table
end)

-- JUMP EXHAUSTION
mcl_player.register_globalstep(function(player, dtime)
	if mcl_serverplayer.is_csm_capable (player) then
		return
	end
	local name = player:get_player_name()
	local node_stand, node_stand_below, node_head, node_feet, node_head_top

	-- Update jump status immediately since we need this info in real time.
	-- WARNING: This section is HACKY as hell since it is all just based on heuristics.

	if mcl_player.players[player].jump_cooldown > 0 then
		mcl_player.players[player].jump_cooldown = mcl_player.players[player].jump_cooldown - dtime
	end

	if player:get_player_control().jump and mcl_player.players[player].jump_cooldown <= 0 then
		node_stand = mcl_player.players[player].nodes.stand
		node_stand_below = mcl_player.players[player].nodes.stand_below
		node_head = mcl_player.players[player].nodes.head
		node_feet = mcl_player.players[player].nodes.feet
		node_head_top = mcl_player.players[player].nodes.head_top
		if not node_stand or not node_stand_below or not node_head or not node_feet then
			return
		end
		if (not core.registered_nodes[node_stand]
		or not core.registered_nodes[node_stand_below]
		or not core.registered_nodes[node_head]
		or not core.registered_nodes[node_feet]
		or not core.registered_nodes[node_head_top]) then
			return
		end

		-- Cause buggy exhaustion for jumping

		--[[ Checklist we check to know the player *actually* jumped:
			* Not on or in liquid
			* Not on or at climbable
			* On walkable
			* Not on disable_jump
		FIXME: This code is pretty hacky and it is possible to miss some jumps or detect false
		jumps because of delays, rounding errors, etc.
		What this code *really* needs is some kind of jumping “callback” which this engine lacks
		as of 0.4.15.
		]]

		if core.get_item_group(node_feet, "liquid") == 0 and
				core.get_item_group(node_stand, "liquid") == 0 and
				not core.registered_nodes[node_feet].climbable and
				not core.registered_nodes[node_stand].climbable and
				(core.registered_nodes[node_stand].walkable or core.registered_nodes[node_stand_below].walkable)
				and core.get_item_group(node_stand, "disable_jump") == 0
				and core.get_item_group(node_stand_below, "disable_jump") == 0 then

			-- Cause exhaustion for jumping
			if mcl_sprint.is_sprinting(name) then
				mcl_hunger.exhaust(name, mcl_hunger.EXHAUST_SPRINT_JUMP)
			else
				mcl_hunger.exhaust(name, mcl_hunger.EXHAUST_JUMP)
			end

			-- Reset cooldown timer
			mcl_player.players[player].jump_cooldown = 0.45
		end
	end
end)

mcl_player.register_globalstep_slow(function(player)
	if mcl_serverplayer.is_csm_capable (player) then
		return
	end
	--[[ Swimming: Cause exhaustion.
	NOTE: As of 0.4.15, it only counts as swimming when you are with the feet inside the liquid!
	Head alone does not count. We respect that for now. ]]
	if not player:get_attach() and (core.get_item_group(mcl_player.players[player].nodes.node_feet, "liquid") ~= 0 or
			core.get_item_group(mcl_player.players[player].nodes.node_stand, "liquid") ~= 0) then
		local lastPos = mcl_player.players[player].lastPos
		if lastPos then
			local dist = vector.distance(lastPos, player:get_pos())
			mcl_player.players[player].swimDistance = mcl_player.players[player].swimDistance + dist
			if mcl_player.players[player].swimDistance >= 1 then
				local superficial = math.floor(mcl_player.players[player].swimDistance)
				mcl_hunger.exhaust(player:get_player_name(), mcl_hunger.EXHAUST_SWIM * superficial)
				mcl_player.players[player].swimDistance = mcl_player.players[player].swimDistance - superficial
			end
		end

	end
end)
