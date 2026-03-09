------------------------------------------------------------------------
-- Poses, animations, physics, and damage, for client-side players.
------------------------------------------------------------------------

local S = core.get_translator (core.get_current_modname ())
local enable_engine_anticheat
	= core.settings:get_bool ("mcl_serverplayer_enable_anticheat", true)
if core.is_singleplayer () then
	enable_engine_anticheat = false
end

local client_poses = {}
local persistent_physics_factors = {}

core.register_on_joinplayer (function (player)
	if not client_poses[player] then
		client_poses[player] = {}
	end
	if not persistent_physics_factors[player] then
		mcl_serverplayer.load_persistent_physics_factors (player)
	end
end)

core.register_on_leaveplayer (function (player)
	client_poses[player] = nil
	mcl_serverplayer.save_persistent_physics_factors (player)
	persistent_physics_factors[player] = nil
end)

local POSE_STANDING = 1
local POSE_CROUCHING = 2
local POSE_SLEEPING = 3
local POSE_FALL_FLYING = 4
local POSE_SWIMMING = 5
local POSE_SIT_MOUNTED = 6
local POSE_MOUNTED = 7
local POSE_DEATH = 8
local POSE_SPIN_ATTACK = 9

mcl_serverplayer.POSE_STANDING = POSE_STANDING
mcl_serverplayer.POSE_CROUCHING = POSE_CROUCHING
mcl_serverplayer.POSE_SLEEPING = POSE_SLEEPING
mcl_serverplayer.POSE_FALL_FLYING = POSE_FALL_FLYING
mcl_serverplayer.POSE_SIT_MOUNTED = POSE_SIT_MOUNTED
mcl_serverplayer.POSE_MOUNTED = POSE_MOUNTED
mcl_serverplayer.POSE_DEATH = POSE_DEATH
mcl_serverplayer.POSE_SPIN_ATTACK = POSE_SPIN_ATTACK

local PLAYER_EVENT_JUMP = 1

function mcl_serverplayer.post_load_model (player, model)
	-- This function is apt to be called by an earlier joinplayer
	-- handler.
	if not client_poses[player] then
		client_poses[player] = {}
	end
	local poses = {
		[POSE_STANDING] = {
			stand = model.animations.stand,
			walk = model.animations.walk,
			mine = model.animations.mine,
			walk_mine = model.animations.walk_mine,
			walk_bow = model.animations.bow_walk,
			collisionbox = mcl_player.player_props_normal.collisionbox,
			eye_height = mcl_player.player_props_normal.eye_height,
		},
		[POSE_CROUCHING] = {
			stand = model.animations.sneak_stand,
			walk = model.animations.sneak_walk,
			mine = model.animations.sneak_mine,
			walk_bow = model.animations.bow_sneak,
			walk_mine = model.animations.sneak_walk_mine,
			collisionbox = mcl_player.player_props_sneaking.collisionbox,
			eye_height = mcl_player.player_props_sneaking.eye_height,
		},
		[POSE_SLEEPING] = {
			stand = model.animations.lay,
			walk = model.animations.lay,
			mine = model.animations.lay,
			walk_bow = model.animations.lay,
			walk_mine = model.animations.lay,
			collisionbox = mcl_player.player_props_normal.collisionbox,
			eye_height = 0.3,
		},
		[POSE_FALL_FLYING] = {
			stand = model.animations.fly,
			walk = model.animations.fly,
			mine = model.animations.fly,
			walk_bow = model.animations.fly,
			walk_mine = model.animations.fly,
			collisionbox = mcl_player.player_props_elytra.collisionbox,
			eye_height = mcl_player.player_props_elytra.eye_height,
		},
		[POSE_SPIN_ATTACK] = {
			stand = model.animations.spin_attack,
			walk = model.animations.spin_attack,
			mine = model.animations.spin_attack,
			walk_bow = model.animations.spin_attack,
			walk_mine = model.animations.spin_attack,
			collisionbox = mcl_player.player_props_elytra.collisionbox,
			eye_height = mcl_player.player_props_elytra.eye_height,
		},
		[POSE_SWIMMING] = {
			stand = model.animations.swim_stand,
			walk = model.animations.swim_walk,
			mine = model.animations.swim_mine,
			walk_bow = model.animations.swim_walk,
			walk_mine = model.animations.swim_walk_mine,
			collisionbox = mcl_player.player_props_swimming.collisionbox,
			eye_height = mcl_player.player_props_swimming.eye_height,
		},
		[POSE_SIT_MOUNTED] = {
			stand = model.animations.sit_mount,
			walk = model.animations.sit_mount,
			mine = model.animations.sit_mount,
			walk_bow = model.animations.sit_mount,
			walk_mine = model.animations.sit_mount,
			collisionbox = mcl_player.player_props_normal.collisionbox,
			eye_height = mcl_player.player_props_normal.eye_height,
		},
		[POSE_MOUNTED] = {
			stand = model.animations.sit,
			walk = model.animations.sit,
			mine = model.animations.sit,
			walk_bow = model.animations.sit,
			walk_mine = model.animations.sit,
			collisionbox = mcl_player.player_props_normal.collisionbox,
			eye_height = mcl_player.player_props_normal.eye_height,
		},
		[POSE_DEATH] = {
			stand = model.animations.die,
			walk = model.animations.die,
			mine = model.animations.die,
			walk_bow = model.animations.die,
			walk_mine = model.animations.die,
			collisionbox = mcl_player.player_props_normal.collisionbox,
			eye_height = mcl_player.player_props_normal.eye_height,
		},
	}
	local caps = {
		pose_defs = poses,
	}
	if mcl_serverplayer.is_csm_capable (player) then
		mcl_serverplayer.send_player_capabilities (player, caps)
		mcl_serverplayer.refresh_pose (player)
	end
	client_poses[player] = poses
end

mcl_serverplayer.movement_arresting_nodes = {
	["mcl_farming:sweet_berry_bush_0"] = {
		x = 0.8,
		y = 0.75,
		z = 0.8,
	},
	["mcl_farming:sweet_berry_bush_1"] = {
		x = 0.8,
		y = 0.75,
		z = 0.8,
	},
	["mcl_farming:sweet_berry_bush_2"] = {
		x = 0.8,
		y = 0.75,
		z = 0.8,
	},
	["mcl_farming:sweet_berry_bush_3"] = {
		x = 0.8,
		y = 0.75,
		z = 0.8,
	},
	["mcl_core:cobweb"] = {
		x = 0.25,
		y = 0.10,
		z = 0.25,
	},
	["mcl_powder_snow:powder_snow"] = {
		x = 0.9,
		y = 1.5,
		z = 0.9,
	},
}

local INITIAL_EFFECT_CTRL = {
	dim_lighting = {
		["nether"] = {
			ambient_level = 4,
			range_squeeze = 0,
		},
		["overworld"] = {
			ambient_level = 0,
			range_squeeze = 35,
		},
		["end"] = {
			ambient_level = 0,
			range_squeeze = 0,
		},
	},
}

local function get_biome_sky_color (nodepos)
	return mcl_biome_dispatch.get_sky_color (nodepos)
end

local function get_biome_fog_color (nodepos)
	return mcl_biome_dispatch.get_fog_color (nodepos)
end

function mcl_serverplayer.init_player (client_state, player)
	local can_sprint = not mcl_hunger.active
		or mcl_hunger.get_hunger (player) > 6

	local inv = player:get_inventory ()
	local stack = inv:get_stack ("armor", 3)
	local boots = inv:get_stack ("armor", 5)
	local can_fall_fly
		= core.get_item_group (stack:get_name (), "elytra") > 0
		and mcl_armor.elytra_usable (stack)
	local level = mcl_enchanting.get_enchantment (boots, "depth_strider")
	local soul_speed
		= mcl_enchanting.get_enchantment (boots, "soul_speed")
	local initial_caps = {
		pose_defs = client_poses[player],
		movement_arresting_nodes
			= mcl_serverplayer.movement_arresting_nodes,
		can_sprint = can_sprint,
		can_fall_fly = can_fall_fly,
		depth_strider_level = level,
		gamemode = mcl_gamemode.get_gamemode (player),
	}
	client_state.ammo_challenge = 0
	client_state.ammo = 0
	client_state.pose = POSE_STANDING
	client_state.anim = "stand"
	client_state.can_sprint = can_sprint
	client_state.can_fall_fly = can_fall_fly
	client_state.depth_strider_level = level
	if client_state.proto >= 8 then
		client_state.soul_speed_level = soul_speed
		initial_caps.soul_speed_level = soul_speed
	end
	client_state.movement_statistics = {
		dist_swum = 0.0,
		dist_walked_in_water = 0.0,
		dist_sprinted = 0.0,
	}
	mcl_serverplayer.send_player_capabilities (player, initial_caps)
	for id, modifier in pairs (persistent_physics_factors[player]) do
		mcl_serverplayer.send_register_attribute_modifier (player, modifier)
	end
	mcl_potions.send_effects_to_client (player)
	mcl_serverplayer.update_vitals (player)

	if client_state.proto >= 1 then
		mcl_shields.set_blocking (player, 0)
	end
	if client_state.proto >= 2 then
		local node_pos = mcl_util.get_nodepos (player:get_pos ())
		local initial = table.merge (INITIAL_EFFECT_CTRL, {
			biome_sky_color = get_biome_sky_color (node_pos),
			biome_fog_color = get_biome_fog_color (node_pos),
			weather_state = mcl_weather.state,
			moon_texture = client_state.proto >= 3
				and mcl_moon.get_moon_texture ()
				or nil,
			preciptation_spawners = client_state.proto >= 5
				and mcl_serverplayer.default_precipitation_spawners
				or nil,
		})
		mcl_serverplayer.send_effect_ctrl (player, initial)
	end
	if client_state.proto >= 4 then
		local riptide_eligible
			= mcl_tridents.weather_admits_of_riptide_p (player)
		client_state.riptide_eligible = riptide_eligible
		mcl_serverplayer.send_trident_ctrl (player, {
			riptide_eligible = riptide_eligible,
		})
	end
end

function mcl_serverplayer.sprinting_locally (player)
	if mcl_serverplayer.client_states[player] then
		return mcl_serverplayer.client_states[player].is_sprinting
	end
	return false
end

function mcl_serverplayer.set_depth_strider_level (player, level)
	local state = mcl_serverplayer.client_states[player]
	if not state then
		return
	end
	if level ~= state.depth_strider_level then
		state.depth_strider_level = level
		mcl_serverplayer.send_player_capabilities (player, {
			depth_strider_level = level,
		})
	end
end

function mcl_serverplayer.set_soul_speed_level (player, level)
	local state = mcl_serverplayer.client_states[player]
	if not state or not state.proto or state.proto < 8 then
		return
	end
	if level ~= state.soul_speed_level then
		state.soul_speed_level = level
		mcl_serverplayer.send_player_capabilities (player, {
			soul_speed_level = level,
		})
	end
end

function mcl_serverplayer.set_fall_flying_capable (player, can_fall_fly)
	local state = mcl_serverplayer.client_states[player]
	if not state then
		return
	end
	if can_fall_fly ~= state.can_fall_fly then
		state.can_fall_fly = can_fall_fly
		mcl_serverplayer.send_player_capabilities (player, {
			can_fall_fly = can_fall_fly,
		})
	end
end

local function apply_pose (state, player, poseid)
	local pose_table = client_poses[player][poseid]

	if not pose_table then
		return
	end

	-- Apply the pose in question.
	player:set_properties ({
		eye_height = pose_table.eye_height,
		collisionbox = pose_table.collisionbox,
	})
	player:set_animation (pose_table[state.anim])
end

function mcl_serverplayer.refresh_pose (player)
	local state = mcl_serverplayer.client_states[player]
	if state then
		apply_pose (state, player, state.override_pose or state.pose)
	end
end

function mcl_serverplayer.handle_playerpose (player, state, poseid)
	if poseid < POSE_STANDING
		or poseid > POSE_SPIN_ATTACK
		or (poseid > POSE_DEATH and state.proto <= 3) then
		error ("Unknown pose " .. poseid)
	end

	if poseid ~= state.pose then
		state.pose = poseid
		if not state.override_pose then
			-- Apply this pose.
			apply_pose (state, player, poseid)
		end
	end
end

function mcl_serverplayer.handle_playeranim (player, state, animname)
	if animname ~= state.anim then
		state.anim = animname

		-- Don't apply this animation if it doesn't exist yet.
		local pose_table = client_poses[player][state.pose]
		if pose_table and pose_table[animname] then
			player:set_animation (pose_table[animname])
		end
	end
end

local function dir_to_pitch (dir)
	local xz = math.abs (dir.x) + math.abs (dir.z)
	return -math.atan2 (-dir.y, xz)
end

function mcl_serverplayer.check_movement (state, player, self_pos)
	local last_pos = state.last_pos
	if last_pos and not vector.equals (self_pos, last_pos) then
		local stats = state.movement_statistics
		local d = vector.distance (self_pos, last_pos)
		local name = player:get_player_name ()
		if state.in_water or state.pose == POSE_SWIMMING then
			local old = math.floor (stats.dist_swum)
			stats.dist_swum = stats.dist_swum + d
			local new = math.floor (stats.dist_swum)
			if new - old > 0 then
				local exhaustion = mcl_hunger.EXHAUST_SWIM * (new - old)
				mcl_hunger.exhaust (name, exhaustion)
			end
		elseif state.is_sprinting then
			local old = math.floor (stats.dist_sprinted)
			stats.dist_sprinted = stats.dist_sprinted + d
			local new = math.floor (stats.dist_sprinted)
			if new - old > 0 then
				local exhaustion = mcl_hunger.EXHAUST_SPRINT * (new - old)
				mcl_hunger.exhaust (name, exhaustion)
			end
		end
	end
	if last_pos and (math.abs (self_pos.x - last_pos.x) > 0.05
				or math.abs (self_pos.z - last_pos.z) > 0.05) then
		local d = vector.direction (last_pos, self_pos)
		state.move_yaw = math.atan2 (d.z, d.x) - math.pi / 2
		state.move_pitch = dir_to_pitch (d)
		if not state.move_pitch then
			state.move_pitch = 0
		else
			state.move_pitch = state.move_pitch
				+ -state.move_pitch * 0.25
		end
	end
	if not state.move_yaw then
		state.move_yaw = player:get_look_horizontal ()
	end
	if not state.move_pitch then
		state.move_pitch = 0
	end
	state.last_pos = self_pos
end

local FOURTY_DEG = math.rad (40)
local TWENTY_DEG = math.rad (20)
local SEVENTY_FIVE_DEG = math.rad (75)
local FIFTY_DEG = math.rad (50)

local RIGHT_ARM_BLOCKING_OVERRIDE = {
	rotation = {
		vec = vector.new (-160, -20, 0):apply (math.rad),
		absolute = true,
	},
}

local LEFT_ARM_BLOCKING_OVERRIDE = {
	rotation = {
		vec = vector.new (-160, 20, 0):apply (math.rad),
		absolute = true,
	},
}

function mcl_serverplayer.get_visual_wielditem (player)
	local state = mcl_serverplayer.client_states[player]
	if state and state.visual_wielditem then
		return state.visual_wielditem
	end
	return player:get_wielded_item ()
end

local norm_radians = mcl_util.norm_radians

local IDENTITY_SCALE = {
	vec = vector.new (1, 1, 1),
	absolute = true,
}

local BODY_DEFAULT_OVERRIDE = {
	rotation = {
		vec = vector.new (0, math.pi, 0),
		absolute = true,
	},
	scale = IDENTITY_SCALE,
}

local DEFAULT_ANIMATION_SPEED = 30

function mcl_serverplayer.animate_localplayer (state, player)
	local speed = DEFAULT_ANIMATION_SPEED
	local look_dir = norm_radians (player:get_look_horizontal ())
	local pose = state.override_pose or state.pose
	local blocking = mcl_shields.is_blocking (player)

	if pose == POSE_CROUCHING or (blocking and blocking ~= 0) then
		speed = speed / 2
	end

	if speed ~= state.animation_speed then
		player:set_animation_frame_speed (speed)
		state.animation_speed = speed
	end

	if pose == POSE_STANDING or pose == POSE_CROUCHING
		or pose == POSE_MOUNTED or pose == POSE_SIT_MOUNTED then
		-- Animate body.
		if pose == POSE_MOUNTED or pose == POSE_SIT_MOUNTED then
			local attach = player:get_attach ()
			if attach then
				local yaw = attach:get_yaw ()
				local yrot = -norm_radians (look_dir - norm_radians (yaw))
				local pitch = -player:get_look_vertical ()
				player:set_bone_override ("Body_Control", BODY_DEFAULT_OVERRIDE)
				player:set_bone_override ("Head_Control", {
					rotation = {
						vec = vector.new (pitch, yrot, 0),
						absolute = true,
					},
				})
			end
		else
			local move_yaw = norm_radians (state.move_yaw)
			local diff = norm_radians (move_yaw - look_dir)
			if diff > FOURTY_DEG then
				move_yaw = look_dir + FOURTY_DEG
			elseif diff < -FOURTY_DEG then
				move_yaw = look_dir - FOURTY_DEG
			end
			state.move_yaw = move_yaw
			local body = look_dir - move_yaw
			local rot = vector.new (0, body - math.pi, 0)
			player:set_bone_override ("Body_Control", {
				rotation = { vec = rot, absolute = true, },
			})
			rot.y = move_yaw - look_dir
			rot.x = -player:get_look_vertical ()
			player:set_bone_override ("Head_Control", {
				rotation = { vec = rot, absolute = true, },
			})
		end
		-- Control arm rotation whilst blocking.
		if blocking == 2 then
			player:set_bone_override ("Arm_Right_Pitch_Control",
						RIGHT_ARM_BLOCKING_OVERRIDE)
			player:set_bone_override ("Arm_Left_Pitch_Control", nil)
		elseif blocking == 1 then
			player:set_bone_override ("Arm_Right_Pitch_Control", nil)
			player:set_bone_override ("Arm_Left_Pitch_Control",
						LEFT_ARM_BLOCKING_OVERRIDE)
		else
			player:set_bone_override ("Arm_Right_Pitch_Control", nil)
			player:set_bone_override ("Arm_Left_Pitch_Control", nil)
		end
	elseif pose == POSE_SWIMMING then
		local pitch = player:get_look_vertical ()
		local move_yaw = norm_radians (state.move_yaw)
		local move_pitch = state.move_pitch
		local rot = vector.new ((pitch - move_pitch) + TWENTY_DEG,
			move_yaw - look_dir, 0)
		player:set_bone_override ("Head_Control", {
			rotation = { vec = rot, absolute = true, },
		})
		rot.x = SEVENTY_FIVE_DEG + move_pitch
		rot.y = move_yaw - look_dir
		rot.z = math.pi
		player:set_bone_override ("Body_Control", {
			rotation = { vec = rot, absolute = true, },
		})
		state.move_yaw = move_yaw
	elseif pose == POSE_SPIN_ATTACK then
		player:set_bone_override ("Head_Control", {})
		player:set_bone_override ("Body_Control", BODY_DEFAULT_OVERRIDE)
		-- TODO: spin.
	elseif pose == POSE_FALL_FLYING then
		local move_pitch = state.move_pitch
		local move_yaw = norm_radians (state.move_yaw)
		local xrot = move_pitch + FIFTY_DEG
		local yrot = move_yaw - look_dir
		local rot = vector.new (xrot, yrot, 0)
		player:set_bone_override ("Head_Control", {
			rotation = { vec = rot, absolute = true, },
		})
		local xrot = -move_pitch + math.pi / 2
		rot.x, rot.y, rot.z
			= mcl_util.rotation_to_irrlicht (xrot, math.pi + yrot, 0)
		player:set_bone_override ("Body_Control", {
			rotation = { vec = rot, absolute = true, },
		})
		state.move_yaw = move_yaw
	elseif pose == POSE_SLEEPING then
		player:set_bone_override ("Head_Control", {})
		player:set_bone_override ("Body_Control", BODY_DEFAULT_OVERRIDE)
	elseif pose == POSE_DEATH then
		player:set_bone_override ("Head_Control", {})
		player:set_bone_override ("Body_Control", {})
	end

	local wielditem = state.visual_wielditem
		or player:get_wielded_item ()
	local wielded_def = wielditem:get_definition ()
	local name = wielditem:get_name ()
	mcl_player.position_wielditem (name, wielded_def, player)
end

function mcl_serverplayer.globalstep (player, dtime)
	local state = mcl_serverplayer.client_states[player]
	local self_pos = player:get_pos ()
	if state.rocketing then
		state.rocketing = state.rocketing - dtime
	end
	mcl_serverplayer.check_movement (state, player, self_pos)
	if state.is_sprinting then
		mcl_sprint.spawn_particles (player, self_pos)
	end
	if mcl_hunger.active then
		if state.can_sprint and mcl_hunger.get_hunger (player) <= 6 then
			state.can_sprint = false
			mcl_serverplayer.send_player_capabilities (player, {
				can_sprint = false,
			})
		elseif not state.can_sprint and mcl_hunger.get_hunger (player) > 6 then
			state.can_sprint = true
			mcl_serverplayer.send_player_capabilities (player, {
				can_sprint = true,
			})
		end
	end
	mcl_serverplayer.animate_localplayer (state, player)
	local name = player:get_player_name ()
	if state.is_fall_flying and not core.is_creative_enabled (name) then
		local fall_flown_ticks = (state.fall_flown_ticks or 0) + dtime
		if fall_flown_ticks >= 1 then
			local inv = player:get_inventory ()
			local elytra = inv:get_stack ("armor", 3)
			if core.get_item_group (elytra:get_name (), "elytra") > 0 then
				local penalty = math.floor (fall_flown_ticks)
				local durability = mcl_util.calculate_durability (elytra)
				local remaining = math.floor ((65536 - elytra:get_wear ())
								* durability / 65536)
				local uses = math.min (penalty, remaining - 1)
				fall_flown_ticks = fall_flown_ticks - penalty
				mcl_util.use_item_durability (elytra, uses)
				-- If this is not a pair of elytra,
				-- this invalid state should be
				-- corrected soon by the client,
				-- provided it cooperates...

				if remaining - uses <= 1 then
					-- Disable fall flying once
					-- the elytra's durability is
					-- depleted.
					mcl_serverplayer.set_fall_flying_capable (player, false)
					mcl_armor.disable_elytra (elytra)
				end
				inv:set_stack ("armor", 3, elytra)
			end
		end
		state.fall_flown_ticks = fall_flown_ticks
	end
	mcl_serverplayer.update_ammo (state, player, false)
	mcl_serverplayer.validate_mounting (state, player, dtime)
	if mcl_serverplayer.is_csm_at_least (player, 2) then
		mcl_serverplayer.update_skybox (state, player, dtime)
	end
	if mcl_serverplayer.is_csm_at_least (player, 4) then
		local riptide = mcl_tridents.weather_admits_of_riptide_p (player)
		if riptide ~= state.riptide_eligible then
			mcl_serverplayer.send_trident_ctrl (player, {
				riptide_eligible = riptide,
			})
			state.riptide_eligible = riptide
		end
	end
	if mcl_serverplayer.is_csm_at_least (player, 6) then
		mcl_serverplayer.update_biome_data (state, player, dtime)
	end
	if enable_engine_anticheat then
		mcl_serverplayer.anticheat_globalstep (state, player, dtime)
	end
end

function mcl_serverplayer.handle_movement_event (player, event)
	if event == PLAYER_EVENT_JUMP then
		if not mcl_hunger.active then
			return
		end

		local exhaustion
		if mcl_serverplayer.sprinting_locally (player) then
			exhaustion = mcl_hunger.EXHAUST_SPRINT_JUMP
		else
			exhaustion = mcl_hunger.EXHAUST_JUMP
		end
		mcl_hunger.exhaust (player:get_player_name (), exhaustion)
	else
		error ("Unknown movement event " .. event)
	end
end

function mcl_serverplayer.use_rocket (user, duration)
	local state = mcl_serverplayer.client_states[user]
	assert (state)
	if not state.can_fall_fly then
		mcl_title.set (user, "actionbar", {
			text = S("Elytra not equipped."),
			color = "white",
			stay = 60,
		})
		return false
	elseif not state.is_fall_flying then
		mcl_title.set (user, "actionbar", {
			text = S("Elytra not deployed. Jump while falling down to deploy."),
			color = "white",
			stay = 60,
		})
		return false
	else
		state.rocketing = duration
		mcl_serverplayer.send_rocket_use (user, duration)
		return true
	end
end

function mcl_serverplayer.handle_damage (player, state, payload)
	if payload.type == "fall" then
		local damage = math.ceil (payload.amount)
		if damage < 0 then
			-- This will kick the client.
			error ("Outrageous fall damage request")
		end

		-- Apply `fall_damage_add_percent' node definitions.
		local greatest = 0.0
		for _, node in pairs (payload.collisions) do
			local name = core.get_node (node).name
			local def = core.registered_nodes[name]
			if core.get_item_group(name, "fall_damage_add_percent") ~= 0 then
				local this = def.groups.fall_damage_add_percent
				if this < 0 then
					greatest = this
				else
					greatest = math.max (greatest, this)
				end
			end
		end
		damage = math.max (0, damage + damage * (greatest / 100.0))
		local reason = {type = "fall"}
		mcl_damage.finish_reason (reason)
		mcl_damage.damage_player (player, damage, reason)

		-- If payload.riding is set, it should designate a mob
		-- that is the player's current vehicle.
		if payload.riding then
			local object = core.object_refs[payload.riding]
			if object and object == state.vehicle then
				mcl_util.deal_damage (object, damage, reason)
			end
		end
	elseif payload.type == "kinetic" then
		local damage = math.ceil (payload.amount)
		if damage < 0 then
			-- This will kick the client.
			error ("Absurd kinetic damage request")
		end
		local reason = {type = "fly_into_wall"}
		mcl_damage.finish_reason (reason)
		mcl_damage.damage_player (player, damage, reason)
	else
		local blurb = "Client requesting unknown damage: "
			.. dump (payload)
		core.log ("warning", blurb)
	end
end

function mcl_serverplayer.is_swimming (player)
	if mcl_serverplayer.is_csm_capable (player) then
		local state = mcl_serverplayer.client_states[player]
		return state.is_swimming
	end
	return false
end

function mcl_serverplayer.in_singleheight_pose (player)
	if mcl_serverplayer.is_csm_capable (player) then
		local state = mcl_serverplayer.client_states[player]
		local pose = state.override_pose or state.pose
		return pose == POSE_FALL_FLYING
			or pose == POSE_SLEEPING
			or pose == POSE_SWIMMING
	end
	return false
end

mcl_player.register_globalstep (function (player, dtime)
	if mcl_serverplayer.is_csm_capable (player) then
		mcl_serverplayer.globalstep (player, dtime)
	end
end)

-- Override PLAYER's active pose, or annul the override if POSEID is
-- nil.  This pose will remain effect server-side till the player
-- leaves or the override is annulled.

function mcl_serverplayer.override_pose (player, poseid)
	if mcl_serverplayer.is_csm_capable (player) then
		local state = mcl_serverplayer.client_states[player]
		state.override_pose = poseid

		if poseid then
			apply_pose (state, player, poseid)
			mcl_serverplayer.send_posectrl (player, poseid)
		else
			apply_pose (state, player, state.pose)
			mcl_serverplayer.send_posectrl (player, false)
		end
	end
end

function mcl_serverplayer.handle_blocking (player, blocking)
	if mcl_serverplayer.is_csm_capable (player)
		and not mcl_serverplayer.is_csm_at_least (player, 1) then
		mcl_serverplayer.send_shieldctrl (player, blocking)
	end
end

------------------------------------------------------------------------
-- Client-side physics factors.  These attribute modifiers are sent to
-- clients upon connection and _are persistent_ on the server.
------------------------------------------------------------------------

function mcl_serverplayer.load_persistent_physics_factors (player)
	local meta = player:get_meta ()
	local str = meta:get_string ("mcl_serverplayer:attributes")
	persistent_physics_factors[player] = core.deserialize (str) or {}
end

function mcl_serverplayer.save_persistent_physics_factors (player)
	local meta = player:get_meta ()
	if persistent_physics_factors[player] then
		local data = core.serialize (persistent_physics_factors[player])
		meta:set_string ("mcl_serverplayer:attributes", data)
	end
end

core.register_on_shutdown (function ()
	for player in mcl_util.connected_players () do
		mcl_serverplayer.save_persistent_physics_factors (player)
	end
end)

function mcl_serverplayer.add_physics_factor (player, field, id, factor, op)
	local modifier = {
		field = field,
		id = id,
		value = factor,
		op = op,
	}
	if not persistent_physics_factors[player] then
		mcl_serverplayer.load_persistent_physics_factors (player)
	end
	persistent_physics_factors[player][id] = modifier
	if mcl_serverplayer.is_csm_capable (player) then
		mcl_serverplayer.send_register_attribute_modifier (player, modifier)
	end
end

function mcl_serverplayer.remove_physics_factor (player, field, id)
	if not persistent_physics_factors[player] then
		mcl_serverplayer.load_persistent_physics_factors (player)
	end
	persistent_physics_factors[player][id] = nil
	if mcl_serverplayer.is_csm_capable (player) then
		mcl_serverplayer.send_remove_attribute_modifier (player, field, id)
	end
end

------------------------------------------------------------------------
-- Client-side status effects.
------------------------------------------------------------------------

function mcl_serverplayer.add_status_effect (object, effect)
	if mcl_serverplayer.is_csm_capable (object) then
		mcl_serverplayer.send_register_status_effect (object, effect)
	else
		-- This might be a mob interested in tracking its
		-- status effects.
		local entity = object:get_luaentity ()
		if entity and entity.register_status_effect then
			entity:register_status_effect (effect)
		end
	end
end

function mcl_serverplayer.remove_status_effect (object, id)
	if mcl_serverplayer.is_csm_capable (object) then
		mcl_serverplayer.send_remove_status_effect (object, id)
	else
		-- This might be a mob interested in tracking its
		-- status effects.
		local entity = object:get_luaentity ()
		if entity and entity.remove_status_effect then
			entity:remove_status_effect (id)
		end
	end
end

------------------------------------------------------------------------
-- Game modes.
------------------------------------------------------------------------

mcl_gamemode.register_on_gamemode_change (function (player, _, gamemode)
	if mcl_serverplayer.is_csm_capable (player) then
		mcl_serverplayer.send_player_capabilities (player, {
			gamemode = gamemode,
		})
	end
end)

------------------------------------------------------------------------
-- Player vitals.
------------------------------------------------------------------------

function mcl_serverplayer.update_vitals (player)
	if mcl_serverplayer.is_csm_at_least (player, 1) then
		local hunger = mcl_hunger.get_hunger (player)
		local saturation = math.floor (mcl_hunger.get_saturation (player))
		local health = mcl_damage.get_hp (player)
		local state = mcl_serverplayer.client_states[player]

		if state.last_hunger ~= hunger
			or state.last_saturation ~= saturation
			or state.last_health ~= health then

			mcl_serverplayer.send_player_vitals (player, health,
							hunger,
							saturation)
			state.last_hunger = hunger
			state.last_saturation = saturation
			state.last_health = health
		end
	end
end

------------------------------------------------------------------------
-- Anticheat integration.
------------------------------------------------------------------------

local AIR_DRAG			= 0.98
local AIR_FRICTION		= 0.91
local SPRINTING_WATER_DRAG	= 0.9
local BASE_FRICTION		= 0.6
local BASE_FRICTION3		= math.pow (0.6, 3)
local DOLPHIN_GRANTED_FRICTION	= 0.96
local FALL_FLYING_DRAG_HORIZ	= 0.99
local BASE_SLIPPERY_1		= 0.989
local BASE_SLIPPERY		= 0.98

local function scale_speed (speed, friction)
	local f = BASE_FRICTION3 / (friction * friction * friction)
	return speed * f
end

-- Luanti's built-in anticheat is quite rudimentary and operates by
-- comparing time elapsed between movement packets to the minimum time
-- required for players to traverse the distance they have covered
-- given their greatest movement speed or climb speed parameter, as
-- the case may be.
--
-- Compatibility with this anticheat is implemented by adjusting these
-- server-side movement parameters to be consistent with the amount of
-- movement the client is entitled to perform.  Unfortunately, it does
-- not appear trivially possible effectively to prevent players
-- equipped with elytra from cheating.

local mathexp = math.exp
local mathlog = math.log
-- local mathpow = math.pow

local mathmin = math.min
local mathmax = math.max

local function walk_speed_max (movement_speed, friction)
	local g = AIR_FRICTION * friction
	local s = scale_speed (movement_speed * AIR_DRAG, friction)
	-- p''(x) = p'(x) * -(1.0 - g) + s
	-- p''(x) = s * exp (g * x - x)
	-- 0.00001 = p''(log (0.00001 / s) / (g - 1))
	-- p'(x) = (((s * exp (-((g - 1.0) * x))) / (1.0 - g)) + C) * exp ((g - 1.0) * x)
	-- p'(x) = (exp(-x) * (s * exp (g * x) - s * exp (s))) / g - 1

	local x = mathlog (0.00001 / s) / (g - 1)
	local dx = (mathexp (-x) * (s * mathexp (g * x) - s * mathexp (x))) / (g - 1)
	return dx
end

local function integrate_jump_speed (speed, initial_friction, t)
	local g = AIR_FRICTION
	local c = speed * initial_friction
	local v = (mathexp(t*g)/(mathexp(t)*g-mathexp(t))-1/(g-1))*c
	return v / t
end

local function jump_speed_max (jump_height, leaping)
	return jump_height + leaping * 2.0
end

local function swim_speed_max (movement_speed, water_velocity,
			       water_friction, velocity_factor,
			       depth_strider_level,
			       has_dolphins_grace)
	local g = water_friction * velocity_factor
	local s = water_velocity

	local level = mathmin (3, depth_strider_level)
	if level > 0 then
		local delta = BASE_FRICTION * AIR_FRICTION - g
		g = g + delta * level / 3
		s = g + (movement_speed - s) * level / 3
	end

	if has_dolphins_grace then
		g = DOLPHIN_GRANTED_FRICTION
	end
	s = s * AIR_FRICTION

	local x = mathlog (0.00001 / s) / (g - 1)
	local dx = (mathexp (-x) * (s * mathexp (g * x) - s * mathexp (x))) / (g - 1)

	-- p''(x) = -p'(x) * (1 - g) + s + ((20 - p'(x)) * 0.085 * g)
	-- p''(x) = 0.1*(10*s+17*g)*exp(0.915*g*x-x)
	-- p'(x) = -((((200*s+340*g)*exp(x-0.915*g*x)-200*s-340*g)*exp(0.915*g*x-x))/(183*g-200))
	-- n = p''((200*log((10*n)/(10*s+17*g)))/(183*g-200))

	local x = -((200 * mathlog (100000 * s + 170000 * g)) / (183 * g - 200))
	local t1 = ((200 * s + 340 * g)
		* mathexp (x - 0.915 * g * x) - 200 * s - 340 * g)
		* mathexp (0.915 * g * x - x)
	local t2 = 183 * g - 200
	local dy = -(t1 / t2)
	return dx, dy
end

--[[
local function fall_flying_fall_max (s, g)
	-- p''(x) = ((g^(x + 1) * log (g) * s) / (g - 1))
	-- 1e-10 = p''((log (((g-1) * 1e-10) / (log (g) * s)) - log (g)) / log (g))
	-- p'(x) = (g^(x + 1) * s) / (g - 1) - (g * s) / (g - 1)

	local x = (mathlog (((g - 1) * 1e-10) / (mathlog (g) * s)) - mathlog (g))
		/ mathlog (g)
	local v = (mathpow (g, x + 1) * s) / (g - 1) - (g * s) / (g - 1)
	return v
end
]]--

-- local mathsqrt = math.sqrt
local mathcos = math.cos
local mathabs = math.abs
local ELYTRA_FLIGHT_TIME = 10000.0

local function fall_flying_speed_max (t, pitch, gravity, drag, drag_horiz)
	local j = mathcos (pitch) * mathcos (pitch)
	local k = mathabs (mathcos (pitch))
	local s = -gravity * (-1.0 + j * 0.75)
	local g = drag
	local h = drag_horiz

	-- j = cos (pitch) ^ 2
	-- k = abs (cos (pitch))
	-- s = -gravity * (-1.0 + j * 0.75)
	-- g = drag
	-- h = drag_horiz

	-- y''(t) = (s + (y(t) + s) * -0.1 * j) * g - y(t) * (1.0 - g)
	-- x''(t) = ((y(t) + s) * -0.1 * j / k) * h - x(t) * (1.0 - h)

	local yt = ((10*g*j-100*g)*s*mathexp(-(((g*j-10*g+10)*t)/10)))/(10*(g*j-10*g+10))-((g*j-10*g)*s)/(g*j-10*g+10)
	local xt = ((10*g*h*j^2-100*g*h*j)*s*mathexp(-(((g*j-10*g+10)*t)/10)))/(10*(g^2*j^2+(10*g*h-20*g^2+10*g)*j+(100-100*g)*h+100*g^2-100*g)*k)-(h^2*j*s*mathexp(-((1-h)*t)))/(((g*h-g)*j+10*h^2+(-(10*g)-10)*h+10*g)*k)+(h*j*s)/(((g*h-g)*j+(10-10*g)*h+10*g-10)*k)
	return xt, yt
end

local function apply_physics_factors (factors, field_name, base)
	local total = base
	local to_add = {}
	local to_add_multiply_base = {}
	local to_multiply_total = {}
	for _, value in pairs (factors) do
		if value.field == field_name then
			if value.op == "scale_by" then
				table.insert (to_multiply_total, value.value)
			elseif value.op == "add_multiplied_base" then
				table.insert (to_add_multiply_base, value.value)
			elseif value.op == "add_multiplied_total" then
				table.insert (to_multiply_total, 1.0 + value.value)
			elseif value.op == "add" then
				table.insert (to_add, value.value)
			end
		end
	end
	for _, value in ipairs (to_add) do
		total = total + value
	end
	base = total
	for _, value in ipairs (to_add_multiply_base) do
		total = total + base * value
	end
	for _, value in ipairs (to_multiply_total) do
		total = total * value
	end
	return total, base
end

local DEFAULT_MOVEMENT_SPEED = 2.0
local DEFAULT_GRAVITY = -1.6
local SLOW_FALLING_GRAVITY = -0.2
local DEFAULT_WATER_VELOCITY = 0.4
local DEFAULT_WATER_FRICTION = 0.8
local DEFAULT_JUMP_HEIGHT = 8.4

local BASE_ROCKET_BOOST = 2.0
local ROCKET_BOOST_FORCE = 30.0

function mcl_serverplayer.player_movement_speed (player, state)
	local desired_speed_walk
	local desired_speed_climb
	local self_pos = player:get_pos ()
	self_pos.y = self_pos.y + 1.0e-4
	local node_pos = mcl_util.get_nodepos (self_pos)
	local node, _ = core.get_node (node_pos)
	node_pos.y = node_pos.y - 1
	local node_below, _ = core.get_node (node_pos)
	node_pos.y = node_pos.y - 1
	local node_below_below, _ = core.get_node (node_pos)
	node_pos.y = node_pos.y + 4
	local node_above, _ = core.get_node (node_pos)
	local factors = persistent_physics_factors[player] or {}
	local base_movement_speed, initial_base
		= apply_physics_factors (factors, "movement_speed",
					 DEFAULT_MOVEMENT_SPEED)
	local can_sprint = state.can_sprint

	if state.proto >= 8
		and state.soul_speed_level > 0
		and core.get_item_group (node_below.name, "soul_block") > 0 then
		local level = 0.03 * (1.0 + state.soul_speed_level * 0.35) * 20.0
		base_movement_speed = base_movement_speed + level
	end

	-- Is this player submerged in a fluid?
	if core.get_item_group (node.name, "water") > 0
		or core.get_item_group (node.name, "river_water") > 0
		or core.get_item_group (node.name, "lava") > 0 then
		local water_velocity
			= apply_physics_factors (factors, "water_velocity",
						 DEFAULT_WATER_VELOCITY)
		local water_friction
			= apply_physics_factors (factors, "water_friction",
						 DEFAULT_WATER_FRICTION)
		local movement_speed = base_movement_speed
		if can_sprint then
			water_friction = SPRINTING_WATER_DRAG
			if state.is_sprinting then
				movement_speed = movement_speed + initial_base * 0.3
			end
		end

		local depth_strider = state.depth_strider_level
		local dolphins_grace
			= mcl_potions.has_effect (player, "dolphin_grace")

		local vx, vy = swim_speed_max (movement_speed,
					       water_velocity,
					       water_friction,
					       1.0,
					       depth_strider,
					       dolphins_grace)
		desired_speed_walk = vx
		desired_speed_climb = vy
	elseif state.can_fall_fly and state.is_fall_flying then
		local gravity = apply_physics_factors (factors, "gravity",
						       DEFAULT_GRAVITY)
		if mcl_potions.has_effect (player, "slow_falling") then
			gravity = mathmax (gravity, SLOW_FALLING_GRAVITY)
		end
		-- XXX: Lua can't trust this.
		local pitch = -player:get_look_vertical ()
		local vx, vy = fall_flying_speed_max (ELYTRA_FLIGHT_TIME,
						      pitch, gravity, AIR_DRAG,
						      FALL_FLYING_DRAG_HORIZ)
		if state.rocketing and state.rocketing > -2.0 then
			vx = mathmax (vx, ROCKET_BOOST_FORCE + BASE_ROCKET_BOOST)
			vy = mathmax (vy, ROCKET_BOOST_FORCE + BASE_ROCKET_BOOST)
			desired_speed_walk = vx
			desired_speed_climb = mathabs(vy)
		elseif pitch >= 0 then
			desired_speed_walk = vx
			desired_speed_climb = mathabs (vy) * 0.35
		else
			desired_speed_walk = vx
			desired_speed_climb = mathmax (vy, 0)
		end
	else
		local leaping = mcl_potions.get_effect_level (player, "leaping")
		local jump_height = apply_physics_factors (factors, "jump_height",
							   DEFAULT_JUMP_HEIGHT)
		local vy = jump_speed_max (jump_height, leaping)
		local movement_speed = base_movement_speed
		if state.is_sprinting and state.can_sprint then
			movement_speed = movement_speed + initial_base * 0.3
		end
		local slippery
			= core.get_item_group (node_below.name, "slippery")
		local def = core.registered_nodes[node_below.name]
		if def and not def.walkable then
			-- Test the node two nodes below also, if
			-- node_below is air, to account for jumping.
			local slippery_1
				= core.get_item_group (node_below_below.name, "slippery")
			slippery = mathmax (slippery, slippery_1)
		end
		local friction = BASE_FRICTION
		if slippery > 3 then
			friction = BASE_SLIPPERY_1
		elseif slippery > 0 then
			friction = BASE_SLIPPERY
		end
		local vx = walk_speed_max (movement_speed, friction)
		if state.is_sprinting and state.can_sprint then
			-- Jumping while sprinting applies an impulse
			-- of 4.0 n/s in the direction of movement,
			-- which can be realized to the full by
			-- sprint-jumping in a 2 block tall tunnel.
			local t = 10
			local def = core.registered_nodes[node_above.name]
			if def and def.walkable then
				t = 2
			end
			local jump_speed_avg
				= integrate_jump_speed (vx + 4.0, friction, t)
			desired_speed_walk = mathmax (vx, jump_speed_avg)
		else
			desired_speed_walk = vx
		end
		-- A velocity of 4.0 is always attainable when
		-- climbing.
		desired_speed_climb = mathmax (vy, 4.0)
	end

	return desired_speed_walk, desired_speed_climb
end

local movement_speed_walk = core.settings:get ("movement_speed_walk")
	or 4
local movement_speed_climb = core.settings:get ("movement_speed_climb")
	or 6.5

function mcl_serverplayer.anticheat_globalstep (state, player, dtime)
	if core.check_player_privs (player, "fly") then
		player:set_physics_override ({
			speed_walk = 100.0,
			speed_climb = 100.0,
		})
	else
		local vx, vy = mcl_serverplayer.player_movement_speed (player, state)
		player:set_physics_override ({
			speed_walk = vx / movement_speed_walk,
			speed_climb = vy / movement_speed_climb / 3.574,
		})
	end
end
