--[[
Sprint mod for Minetest by GunshipPenguin

To the extent possible under law, the author(s)
have dedicated all copyright and related and neighboring rights
to this software to the public domain worldwide. This software is
distributed without any warranty.
]]

--Configuration variables, these are all explained in README.md
mcl_sprint = {}

mcl_sprint.SPEED = 1.3

local players = {}

-- Returns true if the player with the given name is sprinting, false if not.
-- Returns nil if player does not exist.
function mcl_sprint.is_sprinting(playername)
	if players[playername] then
		local player = core.get_player_by_name (playername)
		return players[playername].sprinting
			or mcl_serverplayer.sprinting_locally (player)
	else
		return nil
	end
end

core.register_on_joinplayer(function(player)
	local playerName = player:get_player_name()

	players[playerName] = {
		sprinting = false,
		timeOut = 0,
		shouldSprint = false,
		lastPos = player:get_pos(),
		sprintDistance = 0,
		fov = 1.0,
	}
end)
core.register_on_leaveplayer(function(player)
	local playerName = player:get_player_name()
	players[playerName] = nil
end)

local function setSprinting(playerName, sprinting) --Sets the state of a player (0=stopped/moving, 1=sprinting)
	if not sprinting and not mcl_sprint.is_sprinting(playerName) then return end
	local player = core.get_player_by_name(playerName)
	players[playerName].sprinting = sprinting
	if players[playerName] then
		if sprinting then
			playerphysics.add_physics_factor(player, "speed", "mcl_sprint:sprint", mcl_sprint.SPEED)
			playerphysics.add_physics_factor(player, "fov", "mcl_sprint:sprint", 1.1)
		else
			playerphysics.remove_physics_factor(player, "speed", "mcl_sprint:sprint")
			playerphysics.remove_physics_factor(player, "fov", "mcl_sprint:sprint")
		end
		return true
	end
	return false
end

-- Given the param2 and paramtype2 of a node, returns the tile that is facing upwards
local function get_top_node_tile(param2, paramtype2)
	if paramtype2 == "colorwallmounted" then
		paramtype2 = "wallmounted"
		param2 = param2 % 8
	elseif paramtype2 == "colorfacedir" then
		paramtype2 = "facedir"
		param2 = param2 % 32
	end
	if paramtype2 == "wallmounted" then
		if param2 == 0 then
			return 2
		elseif param2 == 1 then
			return 1
		else
			return 5
		end
	elseif paramtype2 == "facedir" then
		if param2 >= 0 and param2 <= 3 then
			return 1
		elseif param2 == 4 or param2 == 10 or param2 == 13 or param2 == 19 then
			return 6
		elseif param2 == 5 or param2 == 11 or param2 == 14 or param2 == 16 then
			return 3
		elseif param2 == 6 or param2 == 8 or param2 == 15 or param2 == 17 then
			return 5
		elseif param2 == 7 or param2 == 9 or param2 == 12 or param2 == 18 then
			return 4
		elseif param2 >= 20 and param2 <= 23 then
			return 2
		else
			return 1
		end
	else
		return 1
	end
end
mcl_sprint.get_top_node_tile = get_top_node_tile

function mcl_sprint.spawn_particles (player, self_pos)
	-- Sprint node particles
	local playerNode = core.get_node (vector.offset (self_pos, 0, -1, 0))
	local def = core.registered_nodes[playerNode.name]
	if def and def.walkable then
		core.add_particlespawner({
			amount = math.random(1, 2),
			time = 1,
			minpos = {x=-0.5, y=0.1, z=-0.5},
			maxpos = {x=0.5, y=0.1, z=0.5},
			minvel = {x=0, y=5, z=0},
			maxvel = {x=0, y=5, z=0},
			minacc = {x=0, y=-13, z=0},
			maxacc = {x=0, y=-13, z=0},
			minexptime = 0.1,
			maxexptime = 1,
			minsize = 0.5,
			maxsize = 1.5,
			collisiondetection = true,
			attached = player,
			vertical = false,
			node = playerNode,
			node_tile = get_top_node_tile(playerNode.param2, def.paramtype2),
		})
	end
end

core.register_globalstep(function()
	--Get the gametime
	local gameTime = core.get_gametime()

	--Loop through all connected players
	for playerName, playerInfo in pairs(players) do
		local player = core.get_player_by_name(playerName)
		if player and not mcl_serverplayer.is_csm_capable (player) then
			local ctrl = player:get_player_control()
			--Check if the player should be sprinting
			if ctrl.aux1 and ctrl.up and not ctrl.sneak then
				players[playerName]["shouldSprint"] = true
			else
				players[playerName]["shouldSprint"] = false
			end

			local playerPos = player:get_pos()
			--If the player is sprinting, create particles behind and cause exhaustion
			if playerInfo["sprinting"] == true and not player:get_attach() and gameTime % 0.1 == 0 then
				-- Exhaust player for sprinting
				local lastPos = players[playerName].lastPos
				local dist = vector.distance({x=lastPos.x, y=0, z=lastPos.z}, {x=playerPos.x, y=0, z=playerPos.z})
				players[playerName].sprintDistance = players[playerName].sprintDistance + dist
				if players[playerName].sprintDistance >= 1 then
					local superficial = math.floor(players[playerName].sprintDistance)
					mcl_hunger.exhaust(playerName, mcl_hunger.EXHAUST_SPRINT * superficial)
					players[playerName].sprintDistance = players[playerName].sprintDistance - superficial
				end

				mcl_sprint.spawn_particles (player, playerPos)
			end

			--Adjust player states
			players[playerName].lastPos = playerPos
			if players[playerName]["shouldSprint"] == true then --Stopped
				local sprinting
				-- Prevent sprinting if hungry or sleeping
				if (mcl_hunger.active and mcl_hunger.get_hunger(player) <= 6)
				or (player:get_meta():get_string("mcl_beds:sleeping") == "true") then
					sprinting = false
				else
					sprinting = true
				end
				setSprinting(playerName, sprinting)
			elseif players[playerName]["shouldSprint"] == false then
				setSprinting(playerName, false)
			end

		end
	end
end)
