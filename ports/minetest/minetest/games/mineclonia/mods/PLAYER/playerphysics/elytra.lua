-- elytra physics
local elytra_vars = {
	slowdown_mult = 0.0, -- amount of vel to take per sec
	fall_speed = 0.2, -- amount of vel to fall down per sec
	speedup_mult = 2, -- amount of speed to add based on look dir
	max_speed = 6, -- max amount to multiply against look direction when flying
	pitch_penalty = 1.3, -- if pitching up, slow down at this rate as a multiplier
	rocket_speed = 5.5,
}

local function anglediff(a1, a2)
	local a = a1 - a2
	return math.abs((a + math.pi) % (math.pi*2) - math.pi)
end

local function clamp(num, min, max)
	return math.min(max, math.max(num, min))
end

mcl_player.register_globalstep(function(player, dtime)
	local fly_pos = player:get_pos()
	local fly_node = minetest.get_node({x = fly_pos.x, y = fly_pos.y - 0.1, z = fly_pos.z}).name
	local player_vel = player:get_velocity()
	local elytra = mcl_player.players[player].elytra

	if not elytra.active then
		elytra.speed = 0
	end

	if not elytra.last_yaw then
		elytra.last_yaw = player:get_look_horizontal()
	end

	local is_just_jumped = player:get_player_control().jump and not mcl_player.players[player].is_pressing_jump and not elytra.active
	mcl_player.players[player].is_pressing_jump = player:get_player_control().jump
	if is_just_jumped and not elytra.active then
		local direction = player:get_look_dir()
		elytra.speed = 1 - (direction.y/2 + 0.5)
	end

	local fly_node_walkable = minetest.registered_nodes[fly_node] and minetest.registered_nodes[fly_node].walkable
	elytra.active = player:get_inventory():get_stack("armor", 3):get_name() == "mcl_armor:elytra"
		and not player:get_attach()
		and (elytra.active or (is_just_jumped and player_vel.y < -0))
		and ((not fly_node_walkable) or fly_node == "ignore")

	if elytra.active then
		if is_just_jumped then -- move the player up when they start flying to give some clearance
			player:set_pos(vector.offset(player:get_pos(), 0, 0.8, 0))
		end
		mcl_player.player_set_animation(player, "fly")
		local direction = player:get_look_dir()
		local turn_amount = anglediff(minetest.dir_to_yaw(direction), minetest.dir_to_yaw(player_vel))
		local direction_mult = clamp(-(direction.y+0.1), -1, 1)
		if direction_mult < 0 then direction_mult = direction_mult * elytra_vars.pitch_penalty end

		local speed_mult = elytra.speed
		local block_below = minetest.get_node(vector.offset(fly_pos, 0, -0.9, 0)).name
		local reg_node_below = minetest.registered_nodes[block_below]
		if (reg_node_below and not reg_node_below.walkable) and (player_vel.y ~= 0) then
			speed_mult = speed_mult + direction_mult * elytra_vars.speedup_mult * dtime
		end
		speed_mult = speed_mult - elytra_vars.slowdown_mult * clamp(dtime, 0.09, 0.2) -- slow down but don't overdo it
		speed_mult = clamp(speed_mult, -elytra_vars.max_speed, elytra_vars.max_speed)
		if turn_amount > 0.3 and math.abs(direction.y) < 0.98 then -- don't do this if looking straight up / down
			speed_mult = speed_mult - (speed_mult * (turn_amount / (math.pi*8)))
		end

		playerphysics.add_physics_factor(player, "gravity", "mcl_playerplus:elytra", elytra_vars.fall_speed)
		if elytra.rocketing > 0 then
			elytra.rocketing = elytra.rocketing - dtime
			if vector.length(player_vel) < 40 then
				-- player:add_velocity(vector.multiply(player:get_look_dir(), 4))
				speed_mult = elytra_vars.rocket_speed
				minetest.add_particle({
					pos = fly_pos,
					velocity = {x = 0, y = 0, z = 0},
					acceleration = {x = 0, y = 0, z = 0},
					expirationtime = math.random(0.3, 0.5),
					size = math.random(1, 2),
					collisiondetection = false,
					vertical = false,
					texture = "mcl_particles_bonemeal.png^[colorize:#bc7a57:127",
					glow = 5,
				})
			end
		end

		elytra.speed = speed_mult -- set the speed so you can keep track of it and add to it

		local new_vel = vector.multiply(direction, speed_mult * dtime * 30) -- use the look dir and speed as a mult
		-- new_vel.y = new_vel.y - elytra_vars.fall_speed * dtime -- make the player fall a set amount

		-- slow the player down so less spongy movement by applying some of the inverse velocity
		-- NOTE: do not set this higher than about 0.2 or the game will get the wrong vel and it will be broken
		-- this is far from ideal, but there's no good way to set_velocity or slow down the player
		player_vel = vector.multiply(player_vel, -0.1)
		-- if speed_mult < 1 then player_vel.y = player_vel.y * 0.1 end
		new_vel = vector.add(new_vel, player_vel)

		player:add_velocity(new_vel)
	else -- reset things when you stop flying with elytra
		elytra.rocketing = 0
		mcl_player.players[player].elytra.active = false
		playerphysics.remove_physics_factor(player, "gravity", "mcl_playerplus:elytra")
	end
	mcl_player.players[player].elytra.last_yaw = player:get_look_horizontal()
end)
