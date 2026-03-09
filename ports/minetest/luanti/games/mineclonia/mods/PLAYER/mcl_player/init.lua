mcl_player = {
	registered_globalsteps = {},
	registered_globalsteps_slow = {},
	players = {},
}

local tpl_playerinfo = {
	textures = { "character.png", "blank.png", "blank.png" },
	model = "",
	animation = "",
	sneak = false,
	visible = true,
	attached = false,
	elytra = {active = false, rocketing = 0, riptide = 0},
	is_pressing_jump = {},
	lastPos = nil,
	swimDistance = 0,
	jump_cooldown = -1,	-- Cooldown timer for jumping, we need this to prevent the jump exhaustion to increase rapidly
	vel_yaw = nil,
	is_swimming = false,
	nodes = {},
	inventory_formspecs = {},
	joinplayer_done = false, --will be set to true in _mcl_autogroup (last mod) on_joinplayer
}

local nodeinfo_pos = { --offset positions of the "nodeinfo" nodes.
	stand =       vector.new(0, -0.1, 0),
	stand_below = vector.new(0, -1.1, 0),
	head =        vector.new(0, 1.4, 0),
	head_top =    vector.new(0, 1.9, 0),
	feet =        vector.new(0, 0.2, 0),
}
mcl_player.node_offsets = nodeinfo_pos

-- Minetest bug: get_bone_position() returns all zeros vectors.
-- Workaround: call set_bone_position() one time first.
-- (Set in on_joinplayer)
local bone_start_positions = {
	Head_Control =            vector.new(0, 6.75, 0),
	Arm_Right_Pitch_Control = vector.new(0, 0, 0),
	Arm_Left_Pitch_Control =  vector.new(0, 0, 0),
	Body_Control =            vector.new(0, 6.75, 0),
}

for k, _ in pairs(nodeinfo_pos) do
	tpl_playerinfo.nodes[k] = ""
end

local slow_gs_timer = 0.5

core.register_on_joinplayer(function(player)
	mcl_player.players[player] = table.copy(tpl_playerinfo)
	mcl_player.players[player].inventory_formspecs = {}
	mcl_player.players[player].nodes = {}
	player:get_inventory():set_size("hand", 1)
	for bone, pos in pairs(bone_start_positions) do
		mcl_util.set_bone_position(player, bone, pos, vector.zero())
	end
end)

core.register_on_leaveplayer(function(player)
	mcl_player.players[player] = nil
end)

local function node_ok(pos, fallback)
	local node = core.get_node_or_nil(pos)
	if node and node.name and core.registered_nodes[node.name] then
		return node.name
	end
	return fallback or "air"
end

function mcl_player.register_globalstep(func)
	table.insert(mcl_player.registered_globalsteps, func)
end

function mcl_player.register_globalstep_slow(func)
	table.insert(mcl_player.registered_globalsteps_slow, func)
end

local connected_player_cache = {}

local iterator_idx

local function connected_players_iterator ()
	local player
	repeat
		player = connected_player_cache[iterator_idx]
		if not player then
			return nil
		end
		iterator_idx = iterator_idx + 1
	until player[1]:is_valid ()
	return player[1], player[2]
end

function mcl_player.iterate_connected_players ()
	iterator_idx = 1
	return connected_players_iterator
end

-- Check each player and run callbacks
core.register_globalstep(function(dtime)
	connected_player_cache = {}
	for player in mcl_util.connected_players() do
		for _, func in pairs(mcl_player.registered_globalsteps) do
			if mcl_player.players[player] then
				func(player, dtime)
			end
		end
		table.insert (connected_player_cache, {
			player,
			player:get_pos (),
		})
	end

	slow_gs_timer = slow_gs_timer - dtime
	if slow_gs_timer > 0 then return end
	slow_gs_timer = 0.5
	for player in mcl_util.connected_players() do
		for _, func in pairs(mcl_player.registered_globalsteps_slow) do
			if mcl_player.players[player] then
				func(player, dtime)
			end
		end
		mcl_player.players[player].lastPos = player:get_pos()
	end
end)

--cache nodes near the player according to offsets defined above
mcl_player.register_globalstep(function(player)
	for k, v in pairs(nodeinfo_pos) do
		mcl_player.players[player].nodes[k] = node_ok(vector.add(player:get_pos(), v))
	end
end)

mcl_player.register_globalstep_slow(function(player)
	-- Is player suffocating inside node? (Only for solid full opaque cube type nodes
	-- without group disable_suffocation=1)
	-- if swimming, check the feet node instead, because the head node will be above the player when swimming
	local ndef = core.registered_nodes[mcl_player.players[player].nodes.head]
	if mcl_player.players[player].is_swimming
		or mcl_serverplayer.in_singleheight_pose (player) then
		ndef = core.registered_nodes[mcl_player.players[player].nodes.feet]
	end
	if (ndef.walkable == nil or ndef.walkable == true)
	and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
	and (ndef.node_box == nil or ndef.node_box.type == "regular")
	and (ndef.groups.disable_suffocation ~= 1)
	and (ndef.groups.opaque == 1)
	and (mcl_player.players[player].nodes.head ~= "ignore")
	-- Check privilege, too
	and (not core.check_player_privs(player:get_player_name(), {noclip = true})) then
		if player:get_hp() > 0 then
			mcl_util.deal_damage(player, 1, {type = "in_wall"})
		end
	end
end)

-- Change the fall damage dealt depending on the block the player landed on or leaping status effect
mcl_damage.register_modifier(function(obj, damage, reason)
	if obj:is_player () and mcl_serverplayer.is_csm_capable (obj) then
		return
	end
	if reason.type == "fall" then
		local pos = obj:get_pos()
		local node = core.get_node(pos)
		local velocity = obj:get_velocity() or obj:get_player_velocity() or {x=0,y=-10,z=0}
		local v_axis_max = math.max(math.abs(velocity.x), math.abs(velocity.y), math.abs(velocity.z))
		local step = {x = velocity.x / v_axis_max, y = velocity.y / v_axis_max, z = velocity.z / v_axis_max}
		for _ = 1, math.ceil(v_axis_max/5)+1 do -- trace at least 1/5 of the way per second
			if not node or node.name == "ignore" then
				core.get_voxel_manip():read_from_map(pos, pos)
				node = core.get_node(pos)
			end
			if node then
				if core.get_item_group(node.name, "water") ~= 0 then
					return 0
				elseif node.name == "mcl_portals:portal_end" then
					if mcl_portals and mcl_portals.end_teleport then
						mcl_portals.end_teleport(obj)
					end
					return 0
				elseif node.name == "mcl_core:cobweb" then
					return 0
				elseif node.name == "mcl_core:vine" then
					return 0
				elseif node.name == "mcl_powder_snow:powder_snow" then
					return 0
				end
			end
			pos = vector.add(pos, step)
			node = core.get_node(pos)
		end
		return damage - mcl_potions.get_effect_level(obj, "leaping") --damage is reduced by 1 per level of leaping effect
	end
end, -200)

function mcl_player.player_knockback (player, hitter, dir, tool_capabilities, damage)
	local knockback = 1

	if hitter and hitter:is_valid() then
		local wielditem = mcl_util.get_wielditem (hitter)
		knockback = knockback
			+ mcl_enchanting.get_enchantment (wielditem,
							  "knockback")
		knockback = knockback
			+ mcl_util.get_additional_knockback (hitter)
	end

	-- Throwables should always deal knockback.
	-- https://minecraft.wiki/w/Knockback_(mechanic)
	if tool_capabilities
		and (tool_capabilities.damage_groups.snowball_vulnerable
			or tool_capabilities.damage_groups.egg_vulnerable) then
		damage = 1
	end

	if damage > 0 then
		local velocity = player:get_velocity ()
		local standing
			= velocity.y < 0.2 and velocity.y > -0.2 -- Very dubious test.
		local knockback
			= mcl_util.calculate_knockback (velocity, knockback * 0.5,
							0, standing, dir.x, dir.z)
		if not mcl_serverplayer.is_csm_capable (player) then
			local delta = vector.subtract (knockback, velocity)
			player:add_velocity (delta)
		else
			mcl_serverplayer.send_knockback (player, knockback)
		end
	end
end

core.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	-- This section borrowed from Minetest.
	if player:get_hp() == 0 then
		return -- RIP
	end

	if hitter and hitter:is_valid() then
		-- Server::handleCommand_Interact() adds eye offset to
		-- one but not the other so the direction is slightly
		-- off, calculate it ourselves
		dir = vector.subtract(player:get_pos(), hitter:get_pos())
	end
	local d = vector.length(dir)
	if d ~= 0.0 then
		dir = vector.divide(dir, d)
	end

	mcl_player.player_knockback (player, hitter, dir, tool_capabilities, damage)
end)

-- Each player's influence on this metric is cumulative with those of
-- others.  register_globalstep_slow is unsuitable because these
-- global variables must only be reset once.

local old_gametime = nil
local gametime_timeout = 1

core.register_globalstep (function (dtime)
		local increment_by
		gametime_timeout = gametime_timeout + dtime
		if gametime_timeout < 1 then
			return
		end
		gametime_timeout = 0
		-- Respect time_speed.
		local gametime = math.floor (core.get_timeofday () * 24000)
		if not old_gametime then
			old_gametime = gametime
			return
		end
		if gametime < old_gametime then
			-- Wraparound.
			increment_by = 24000 - old_gametime + gametime
		else
			increment_by = gametime - old_gametime
		end
		old_gametime = gametime
		for player in mcl_util.connected_players () do
			local pos = player:get_pos ()
			mcl_worlds.tick_chunk_inhabited_time (pos, player, increment_by)
		end
end)

function mcl_player.set_inventory_formspec (player, formspec, priority)
	local playerdata = mcl_player.players[player]
	if not playerdata then -- The player has already left.
		return
	end
	local formspecs = playerdata.inventory_formspecs
	formspecs[priority] = formspec
	local best, priority

	for k, formspec in pairs (formspecs) do
		if not best or k > priority then
			best = formspec
			priority = k
		end
	end
	if best then
		player:set_inventory_formspec (best)
	end
end

local modpath = core.get_modpath(core.get_current_modname())
dofile(modpath.."/animations.lua")
dofile(modpath.."/settings.lua")
dofile(modpath.."/compat.lua")
