------------------------------------------------------------------------
-- Ender Dragon.
------------------------------------------------------------------------

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref
local mobs_griefing = mobs_mc.is_mob_griefing_enabled("ender_dragon")
local dragon_debug
	= core.settings:get_bool ("dragon_debug", false)

local dragon = {
	description = S("Ender Dragon"),
	type = "monster",
	_spawn_category = "misc",
	persist_in_peaceful = true,
	hp_max = 200,
	hp_min = 200,
	xp_min = 500,
	xp_max = 500,
	collisionbox = {
		-0.45, 0, -0.45,
		0.45, 1, 0.45,
	},
	selectionbox = {
		0, 0, 0, 0, 0, 0,
	},
	doll_size_override = { x = 0.16, y = 0.16 },
	physical = false,
	visual = "mesh",
	mesh = "mobs_mc_dragon.b3d",
	textures = {
		{
			"mobs_mc_dragon.png",
		},
	},
	visual_size = {
		x = 3,
		y = 3,
	},
	sounds = {
		shoot_attack = "mobs_mc_ender_dragon_shoot",
		attack = "mobs_mc_ender_dragon_attack",
		distance = 60,
	},
	animation = {
		stand_start = 0, stand_end = 40,
	},
	ignores_nametag = true,
	persistent = true,
	fire_resistant = true,
	is_boss = true,
	can_ride_cart = false,
	can_ride_boat = false,
	_dragon_parts = {},
	_tick_time = 0.0,
	_target_yaw = 0.0,
	fall_speed = 0.0,
	_start_velocity = vector.new (0, 0, 0),
	_yaw_acc = 0.0,
	_damage_time = 0,
	_circling_positions = {},
	_circling_positions_by_hash = {},
	_current_crystal = nil,
	_current_beam = nil,
	_crystals_remaining = 0,
	_crystals = {},
	_phase = "hold",
	_hold_clockwise = true,
	_joint_yaw = {},
	_joint_pitch = {},
	_scanned_for = 0.0,
	_charge_time = 0.0,
	_bellow_time = 0.0,
	_bellow_count = 0,
	_bellowed = false,
	_vistime = 0.0,
	_damage_sustained_on_podium = 0.0,
	_death_routine_progress = 0.0,
	_death_xp_time = 0.0,
	_dragon_dead = false,
}

------------------------------------------------------------------------
-- Ender Dragon hitbox entity.
------------------------------------------------------------------------

local dragon_piece = {
	initial_properties = {
		visual = "cube",
		visual_size = vector.zero (),
		physical = false,
		collide_with_objects = false,
		static_save = false,
		textures = {
			"mcl_core_glass_green.png",
			"mcl_core_glass_green.png",
			"mcl_core_glass_green.png",
			"mcl_core_glass_green.png",
			"mcl_core_glass_green.png",
			"mcl_core_glass_green.png",
		},
		use_texture_alpha = false,
	},
	_hittable_by_projectile = true,
	fire_resistant = true,
}

function dragon_piece:on_step (dtime)
	if not self._dragon or not is_valid (self._dragon) then
		self.object:remove ()
	else
		-- This is not redundant: it arrests hitboxes if the
		-- dragon's AI is suspended.
		local v = self._dragon:get_velocity ()
		self.object:set_velocity (v)
	end
end

function dragon_piece:deal_damage (damage, mcl_reason)
	if not is_valid (self._dragon) then
		return false
	end
	return mcl_util.deal_damage (self._dragon, damage, mcl_reason)
end

function dragon_piece:on_punch (puncher, time_from_last_punch,
			tool_capabilities, dir, damage)
	if not is_valid (self._dragon) then
		return false
	end
	core.sound_play ("default_punch", {
		object = self.object,
		max_hear_distance = 5
	}, true)
	local mcl_reason = {}
	mcl_damage.from_punch (mcl_reason, puncher)
	mcl_damage.finish_reason (mcl_reason)
	mcl_reason.dragon_part = self._dragon_part
	mcl_util.deal_damage (self._dragon, damage, mcl_reason)
	return true
end

core.register_entity ("mobs_mc:dragon_piece", dragon_piece)

------------------------------------------------------------------------
-- Ender Dragon visuals and physics.
------------------------------------------------------------------------

local DEATH_VELOCITY = vector.new (0.0, 2.0, 0.0)
local ZERO_VECTOR = vector.zero ()

function dragon:restore_portal ()
	local struct = mcl_structures.registered_structures["end_exit_portal_open"]
	local pr = PcgRandom (core.get_mapgen_setting("seed"))
	local podium = mcl_biome_dispatch.get_end_portal_pos ()

	mcl_portals.spawn_gateway_portal ()
	mcl_structures.place_structure (podium, struct, pr, -1)

	if self._initial then
		core.set_node (vector.add (podium, vector.new (0, 5, 0)), {
			name = "mcl_end:dragon_egg",
		})
	end

	-- Free The End Advancement
	local self_pos = self.object:get_pos ()
	for players in core.objects_inside_radius (self_pos, 64) do
		if players:is_player () then
			awards.unlock (players:get_player_name (), "mcl:freeTheEnd")
		end
	end
end

function dragon:check_dying (dtime)
	if not self._dragon_dead then
		return
	end

	local self_pos = self.object:get_pos ()
	self:rotate_joints (self_pos)
	mcl_bossbars.update_boss (self.object, S ("Ender Dragon"), "light_purple")
	local t = self._death_routine_progress + dtime
	self._death_routine_progress = t
	self._dragon_target = nil

	if t >= 9 and not self._explosion_particles_spawned then
		core.add_particlespawner ({
			amount = 240,
			time = 6.0,
			pos = vector.new (0, 1.5, 0),
			radius = 3,
			acc = vector.zero (),
			exptime = {
				min = 0.5,
				max = 1.0,
			},
			size = {
				min = 8,
				max = 12,
			},
			texture = "mcl_particles_smoke.png",
			attached = self.object,
		})
		self._explosion_particles_spawned = true
	end

	if not self._death_xp_reward then
		local xp_reward = self.xp_max
		if self._initial then
			xp_reward = 12000
		end
		self._death_xp_reward = xp_reward
	end
	local xp_remaining = self._death_xp_reward

	if t >= 7.5 and xp_remaining > 200 then
		if t - self._death_xp_time >= 0.25 then
			local amount = math.floor (xp_remaining * 0.08)
			self._death_xp_time = t
			self._death_xp_reward = xp_remaining - amount
			mcl_experience.throw_xp (self_pos, amount)
		end
	end

	if xp_remaining <= 200 then
		mcl_experience.throw_xp (self_pos, xp_remaining)
		self._death_xp_reward = 0
		self.object:set_velocity (ZERO_VECTOR)
		self:restore_portal ()
		self:safe_remove ()
	else
		self.object:set_velocity (DEATH_VELOCITY)
	end
	return true
end

function dragon:create_part (bb_width, bb_height, part)
	local self_pos = self.object:get_pos ()
	local object = core.add_entity (self_pos, "mobs_mc:dragon_piece")
	if not object then
		self:safe_remove ()
		return nil
	end
	local entity = object:get_luaentity ()
	object:set_properties ({
		collisionbox = {
			-bb_width * 0.5, -bb_height * 0.5, -bb_width * 0.5,
			bb_width * 0.5, bb_height * 0.5, bb_width * 0.5,
		},
		selectionbox = {
			-bb_width * 0.5, -bb_height * 0.5, -bb_width * 0.5,
			bb_width * 0.5, bb_height * 0.5, bb_width * 0.5,
		},
	})
	entity._bb_width = bb_width
	entity._bb_height = bb_height
	entity._dragon = self.object
	entity._dragon_part = part
	return object
end

local NUM_SAMPLES = 64

function dragon:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end

	-- Initialize sampling.
	self._sample_ptr = 0
	self._tick_time = 0.0
	self._last_sampled = -1
	self._heading_samples = {}
	self._heading_samples[NUM_SAMPLES] = nil
	self._joint_yaw = {}
	self._joint_pitch = {}

	-- Create hitbox entities.
	self._dragon_parts = {}
	self._dragon_parts["head"] = self:create_part (1.0, 1.0, "head")
	self._dragon_parts["neck"] = self:create_part (3.0, 3.0, "neck")
	self._dragon_parts["body"] = self:create_part (5.0, 3.0, "body")
	self._dragon_parts["tail_0"] = self:create_part (2.0, 2.0, "tail_0")
	self._dragon_parts["tail_1"] = self:create_part (2.0, 2.0, "tail_1")
	self._dragon_parts["tail_2"] = self:create_part (2.0, 2.0, "tail_2")
	self._dragon_parts["wing_0"] = self:create_part (4.0, 2.0, "wing_0")
	self._dragon_parts["wing_1"] = self:create_part (4.0, 2.0, "wing_1")

	-- Initialize movement.
	self._start_velocity = vector.new (0, 0, 0)
	self:derive_circling_positions ()

	if self.health > 0 then
		-- Initialize dragon fight.
		self:refresh_dragon_fight ()
	else
		self._dragon_target = nil
		self._phase = "death"
	end
	return true
end

function dragon:get_staticdata_table ()
	local supertable = mob_class.get_staticdata_table (self)
	if supertable then
		supertable._dragon_parts = nil
		supertable._phase = nil
		supertable._circling_positions = nil
		supertable._circling_positions_by_hash = nil
		supertable._dragon_target = nil
		supertable._hold_path = nil
		supertable._land_path = nil
		supertable._takeoff_path = nil
		supertable._strafe_path = nil
		supertable._charge_target = nil
		supertable._crystals_remaining = nil
		supertable._crystals = nil
		supertable._charge_target = nil
	end
	return supertable
end

-- Joints and part positioning.
local joints_by_temporal_order = {
	[1] = "head",
	[2] = "neck5",
	[3] = "neck4",
	[4] = "neck3",
	[5] = "neck2",
	[6] = "neck1",
	[7] = "body",
	[8] = "tail1",
	[9] = "tail2",
	[10] = "tail3",
	[11] = "tail4",
	[12] = "tail5",
	[13] = "tail6",
	[14] = "tail7",
	[15] = "tail8",
	[16] = "tail9",
	[17] = "tail10",
	[18] = "tail11",
	[19] = "tail12",
}
local BODY = 7

local function get_prev_sample (self)
	local idx = self._sample_ptr
	return self._heading_samples[idx]
end

local function sample_idx (idx)
	return ((idx - 1) % NUM_SAMPLES) + 1
end

local function lerp_yaw (prev_sample, current_sample, progress)
	local diff = mcl_util.norm_radians (current_sample - prev_sample)
	local raw = prev_sample + diff * progress
	return mcl_util.norm_radians (raw)
end

local function lerp_pos (prev_sample, current_sample, progress)
	local x = prev_sample.x + (current_sample.x - prev_sample.x) * progress
	local y = prev_sample.y + (current_sample.y - prev_sample.y) * progress
	local z = prev_sample.z + (current_sample.z - prev_sample.z) * progress
	return vector.new (x, y, z)
end

function dragon:sample_heading (dtime, self_pos, yaw)
	local last_sampled = self._last_sampled
	local current_time = self._tick_time + dtime
	local time_elapsed = current_time - last_sampled
	self._tick_time = current_time

	if self._last_sampled == -1 or time_elapsed >= 0.05 then
		local sample_length = self._last_sampled == -1
			and 1.0 or time_elapsed / 0.05
		local num_samples = math.floor (sample_length)
		local prev_sample = get_prev_sample (self) or {yaw, self_pos}

		for i = 1, num_samples do
			local target_time = last_sampled + i * 0.05
			local progress = i / sample_length
			local yaw = lerp_yaw (prev_sample[1], yaw, progress)
			local pos = lerp_pos (prev_sample[2], self_pos, progress)

			local idx = sample_idx (self._sample_ptr + 1)
			self._sample_ptr = idx
			self._heading_samples[idx] = {
				yaw, pos,
			}
			self._last_sampled = target_time
		end
	end
end

function dragon:joint_sample (joint_no)
	local idx = sample_idx (self._sample_ptr - (joint_no - 1))
	local sample = self._heading_samples[idx]
	return sample or self._heading_samples[1] or {
		0, self.object:get_pos (),
	}
end

function dragon:set_yaw (yaw)
	self._target_yaw = yaw
end

function dragon:get_yaw ()
	return self._target_yaw
end

local BODY_LENGTH = 12.5

local function rotate_point (point, center, yaw, pitch)
	if pitch == 0 then
		local x = -math.sin (yaw)
		local z = math.cos (yaw)
		local x1 = point.x - center.x
		local z1 = point.z - center.z
		local x2 = x1 * z + z1 * x
		local z2 = z1 * z - x1 * x
		return vector.new (x2 + center.x, point.y, z2 + center.z)
	else
		local point1
			= vector.offset (point, -center.x, -center.y, -center.z)
		local point2 = vector.rotate (point1, vector.new (pitch, yaw, 0))
		point2.x = point2.x + center.x
		point2.y = point2.y + center.y
		point2.z = point2.z + center.z
		return point2
	end
end

function dragon:get_joint_position (i, yaw)
	if i == BODY then
		local center = vector.new (0, 0, BODY_LENGTH / 2)
		return rotate_point (ZERO_VECTOR, center, yaw, 0)
	end
	return ZERO_VECTOR
end

local PITCH_MULTIPLIER = (math.pi / 180) * 7.5

function dragon:joint_pitch (self_pos, id, body_y, local_y)
	if id >= 7 then
		return 0
	elseif self._phase == "descent" or self._phase == "takeoff"
		and self._dragon_target then
		local podium_pos = self._podium_position
		if podium_pos then
			local d = vector.distance (self_pos, podium_pos)
			return ((6 - id) / math.max (1.0, d / 4.0))
				* PITCH_MULTIPLIER
		else
			return 0
		end
	elseif self:is_phase_sitting () then
		return math.max (0, 6 - id) * PITCH_MULTIPLIER
	else
		return (body_y - local_y) * PITCH_MULTIPLIER
	end
end

local rotate_joints_scratch_1 = {}
local rotate_joints_scratch_2 = {}
local rotate_joints_scratch_3 = {}
local ROLL_MULTIPLIER = 10.0

function dragon:rotate_joints (self_pos)
	local joint_yaw = rotate_joints_scratch_1
	local joint_pitch = rotate_joints_scratch_2
	local joint_roll = rotate_joints_scratch_3
	local real_yaw = self._joint_yaw
	local real_pitch = self._joint_pitch
	local yaw_so_far = 0
	local pitch_so_far = 0
	local roll_so_far = 0
	local pos_body = self:joint_sample (7)[2]
	for i = 1, BODY do
		local idx = #joints_by_temporal_order - 11 - i
		local yaw, pos = unpack (self:joint_sample (idx))
		local pitch = self:joint_pitch (self_pos, idx, pos_body.y, pos.y)
		local next_yaw = self:joint_sample (idx + 1)[1]
		local roll = mcl_util.norm_radians ((yaw - next_yaw) * ROLL_MULTIPLIER)
		joint_yaw[idx] = mcl_util.norm_radians (yaw - yaw_so_far)
		joint_pitch[idx] = mcl_util.norm_radians (pitch - pitch_so_far)
		joint_roll[idx] = mcl_util.norm_radians (roll - roll_so_far)
		yaw_so_far = yaw_so_far + joint_yaw[idx]
		pitch_so_far = pitch_so_far + joint_pitch[idx]
		roll_so_far = roll_so_far + joint_roll[idx]
		real_yaw[idx] = yaw
		real_pitch[idx] = pitch
	end
	local body_yaw = unpack (self:joint_sample (BODY))
	for i = BODY + 1, #joints_by_temporal_order do
		local yaw = self:joint_sample (i)[1]
		joint_yaw[i] = mcl_util.norm_radians (body_yaw - yaw)
		joint_pitch[i] = 0
		joint_roll[i] = 0
		body_yaw = body_yaw - joint_yaw[i]
		real_yaw[i] = yaw
		real_pitch[i] = 0
	end

	if not self.object.set_bone_override then
		return
	end

	for i = 1, #joint_yaw do
		local bone = joints_by_temporal_order[i]
		self.object:set_bone_override (bone, {
			rotation = {
				vec = vector.new (joint_pitch[i], joint_roll[i],
						  joint_yaw[i]),
				absolute = false,
				interpolate = 0.1,
			},
			position = {
				vec = self:get_joint_position (i, joint_yaw[i]),
				absolute = false,
				interpolate = 0.1,
			},
		})
	end
end

local dragon_parts = {
	head = {
		temporal_position = 1,
		position = vector.new (0.0, 2.6, 5.6),
	},
	neck = {
		temporal_position = 3,
		position = vector.new (0.0, 2.6, 4.0),
	},
	body = {
		temporal_position = 7,
		position = vector.new (0.0, 2.6, 0.0),
	},
	wing_0 = {
		temporal_position = 7,
		position = vector.new (4.5, 2.6, 0.0),
	},
	wing_1 = {
		temporal_position = 7,
		position = vector.new (-4.5, 2.6, 0.0),
	},
	tail_0 = {
		temporal_position = 9,
		position = vector.new (0.0, 2.6, -3.5),
	},
	tail_1 = {
		temporal_position = 12,
		position = vector.new (0.0, 2.6, -5.5),
	},
	tail_2 = {
		temporal_position = 15,
		position = vector.new (0.0, 2.6, -7.5),
	},
}

function dragon:position_parts (self_pos, velocity)
	for part, data in pairs (dragon_parts) do
		local idx = data.temporal_position
		local yaw = self._joint_yaw[idx]
		local pitch = self._joint_pitch[idx]
		local position = data.position
		local pos = rotate_point (position, ZERO_VECTOR, yaw, -pitch * 0.2)
		local offset = vector.add (pos, self_pos)
		self._dragon_parts[part]:set_pos (offset)
		self._dragon_parts[part]:set_velocity (velocity)
	end
end

local FIFTY_DEG = math.rad (50)
local Y_DRAG = 0.91
local YAW_DRAG = 0.8
local pow_by_step = mcl_mobs.pow_by_step

function dragon:motion_step (dtime, moveresult, self_pos)
	local target = self._dragon_target
	if target then
		local v = self._start_velocity
		local dx = target.x - self_pos.x
		local dy = target.y - self_pos.y
		local dz = target.z - self_pos.z
		local speed = self:get_flight_speed ()
		local horiz = math.sqrt (dx * dx + dz * dz)
		local magnitude = math.sqrt (dx * dx + dz * dz + dy * dy)
		if horiz > 0.0 then
			dy = math.max (-speed, math.min (((dy * 20) / horiz), speed))
		else
			dy = dy * 20
		end

		local y_drag = pow_by_step (Y_DRAG, dtime)
		local y_scale = (1 - y_drag) / (1 - Y_DRAG)
		v.y = v.y + dy * 0.01 * y_scale

		local yaw = self:get_yaw ()
		local dir = vector.direction (self_pos, target)
		local forward = vector.new (-math.sin (yaw), v.y, math.cos (yaw))
		forward = vector.normalize (forward)
		local turn_penalty
			= math.max ((vector.dot (dir, forward) + 0.5) / 1.5, 0.0)

		if math.abs (horiz) > 5e-05 then
			local value = math.atan2 (dz, dx) - math.pi / 2
			local yaw_diff
				= mcl_util.norm_radians (value - yaw)
			local turn_speed = self:get_turn_speed (v)
			local yaw_drag = pow_by_step (YAW_DRAG, dtime)
			local yaw_scale = (1 - yaw_drag) / (1 - YAW_DRAG)
			local yaw_acc = (self._yaw_acc * yaw_drag)
				+ math.max (math.min (yaw_diff, FIFTY_DEG), -FIFTY_DEG)
					* turn_speed * yaw_scale
			self:set_yaw (yaw + yaw_acc * 0.1 * (dtime / 0.05))
			self._yaw_acc = yaw_acc
		end

		local x_drag_est = pow_by_step (0.875, dtime)
		local x_scale = (1 - x_drag_est) / (1 - 0.875)
		local accel = 2.0 / (magnitude + 1.0)
		accel = 1.2 * (turn_penalty * accel + (1.0 - accel))
		accel = accel * x_scale
		local acc = vector.new (0.0, 0.0, 1.0)
		local fv_x, fv_y, fv_z = self:accelerate_relative (acc, accel, accel)
		v.x = v.x + fv_x
		v.y = v.y + fv_y
		v.z = v.z + fv_z

		self.object:set_velocity (v)
		local dir1 = vector.normalize (v)
		local x_drag = 0.8 + 0.15 * (vector.dot (dir1, forward) + 1.0) / 2.0
		local x_drag_real = pow_by_step (x_drag, dtime)
		v.x = v.x * x_drag_real
		v.z = v.z * x_drag_real
		v.y = v.y * y_drag
	elseif not self._dragon_dead then
		self._start_velocity = vector.zero ()
		self.object:set_velocity (self._start_velocity)
	end

	-- Sample position and yaw.
	local yaw = self:get_yaw ()
	self:sample_heading (dtime, self_pos, yaw)
end

function dragon:get_part_bounding_box (name)
	local part = self._dragon_parts[name]
	local entity = part and part:get_luaentity ()
	if not entity then
		return nil
	end
	local pos = part:get_pos ()
	return {
		-entity._bb_width * 0.5 + pos.x,
		-entity._bb_height * 0.5 + pos.y,
		-entity._bb_width * 0.5 + pos.z,
		entity._bb_width * 0.5 + pos.x,
		entity._bb_height * 0.5 + pos.y,
		entity._bb_width * 0.5 + pos.z,
	}
end

-- Simulate the damage immunity implemented by Minecraft.

local damage_immune = {}

core.register_globalstep (function (dtime)
	for k, v in pairs (damage_immune) do
		local t = v - dtime
		if t <= 0 then
			damage_immune[k] = nil
		else
			damage_immune[k] = t
		end
	end
end)

function dragon:damage_entity (self_pos, object, pos, do_knockback)
	if damage_immune[object] then
		return
	end
	if do_knockback then
		local mcl_reason = {
			type = "mob",
			source = self.object,
		}
		mcl_damage.finish_reason (mcl_reason)
		mcl_util.deal_damage (object, 5.0, mcl_reason)

		local dx = pos.x - self_pos.x
		local dz = pos.z - self_pos.z
		local total = math.max (dx * dx + dz * dz, 0.1)
		local x = dx / total * 4.0 * 20
		local z = dz / total * 4.0 * 20
		object:add_velocity (vector.new (x, 4, z))
	else
		local mcl_reason = {
			type = "mob",
			source = self.object,
		}
		mcl_damage.finish_reason (mcl_reason)
		mcl_util.deal_damage (object, 10.0, mcl_reason)
	end
	damage_immune[object] = 0.5
end

local function offset_cbox (cbox, pos, inflate)
	cbox[1] = cbox[1] + pos.x - inflate
	cbox[2] = cbox[2] + pos.y - inflate
	cbox[3] = cbox[3] + pos.z - inflate
	cbox[4] = cbox[4] + pos.x + inflate
	cbox[5] = cbox[5] + pos.y + inflate
	cbox[6] = cbox[6] + pos.z + inflate
end

local function box_intersection (box, other_box)
	for index = 1, 3 do
		if box[index] > other_box[index + 3]
			or other_box[index] > box[index + 3] then
			return false
		end
	end
	return true
end

function dragon:damage_entities_intersecting_part (self_pos, cbox, do_knockback, damaged)
	if not cbox then
		return
	end

	local aa = vector.new (cbox[1] - 3.0, cbox[2] - 3.0, cbox[3] - 3.0)
	local bb = vector.new (cbox[4] + 3.0, cbox[5] + 3.0, cbox[6] + 3.0)
	local cbox1 = {
		cbox[1] - 1.0,
		cbox[2] - 1.0,
		cbox[3] - 1.0,
		cbox[4] + 1.0,
		cbox[5] + 1.0,
		cbox[6] + 1.0,
	}

	for object in core.objects_in_area (aa, bb) do
		if object ~= self.object and not damaged[object] then
			local entity = object:get_luaentity ()
			if object:is_player () or (entity and entity.is_mob) then
				local pos = object:get_pos ()
				local cbox2 = object:get_properties ().collisionbox
				offset_cbox (cbox2, pos, 1.0)

				if box_intersection (cbox1, cbox2) then
					self:damage_entity (self_pos, object, pos, do_knockback)
					damaged[object] = true
				end
			end
		end
	end
end

local is_dragon_immune = {}

core.register_on_mods_loaded (function ()
	for name, def in pairs (core.registered_nodes) do
		if name == "air" or name == "ignore"
			or name == "mcl_core:barrier"
			or name == "mcl_core:bedrock"
			or name == "mcl_portals:portal_end"
			or def.groups.end_portal_frame
			or def.groups.command_block
			or name == "mcl_core:obsidian"
			or name == "mcl_core:crying_obsidian"
			or name == "mcl_end:end_stone"
			or def.groups.iron_bars
			or def.groups.fire
			or name == "mcl_deepslate:deepslate_reinforced"
			or def.groups.respawn_anchor then
			is_dragon_immune[name] = true
		end
	end
end)

function dragon:check_walls (cbox)
	if not cbox or not mobs_griefing then
		return
	end

	local xstart = math.floor (cbox[1] - 0.5)
	local ystart = math.floor (cbox[2] - 0.5)
	local zstart = math.floor (cbox[3] - 0.5)
	local xend = math.floor (cbox[4] - 0.5)
	local yend = math.floor (cbox[5] - 0.5)
	local zend = math.floor (cbox[6] - 0.5)
	local v = vector.zero ()

	for z = zstart, zend do
		for x = xstart, xend do
			for y = ystart, yend do
				v.x = x
				v.y = y
				v.z = z
				local node = core.get_node (v)
				if not is_dragon_immune[node.name] and
					not core.is_protected (v, "") then
					core.dig_node (v)
				end
			end
		end
	end
end

function dragon:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	local t = self._damage_time - dtime
	self._damage_time = math.max (0, t)
end

function dragon:rotate_step (dtime)
	local self_pos = self.object:get_pos ()
	local velocity = self.object:get_velocity ()
	self:rotate_joints (self_pos)
	-- Position dragon parts.
	self:position_parts (self_pos, velocity)

	local bb_head = self:get_part_bounding_box ("head")
	local bb_body = self:get_part_bounding_box ("body")
	local bb_neck = self:get_part_bounding_box ("neck")
	local bb_wing_0 = self:get_part_bounding_box ("wing_0")
	local bb_wing_1 = self:get_part_bounding_box ("wing_1")

	if self._damage_time == 0 then
		local list = {}
		self:damage_entities_intersecting_part (self_pos, bb_wing_0, true, list)
		self:damage_entities_intersecting_part (self_pos, bb_wing_1, true, list)
		self:damage_entities_intersecting_part (self_pos, bb_head, false, list)
		self:damage_entities_intersecting_part (self_pos, bb_neck, false, list)
	end
	self:check_walls (bb_head)
	self:check_walls (bb_neck)
	self:check_walls (bb_body)
end

function dragon:set_animation_speed (custom_speed)
	if not self:is_phase_sitting () then
		self.object:set_animation_frame_speed (10)
	else
		self.object:set_animation_frame_speed (25)
	end
end

------------------------------------------------------------------------
-- Ender Dragon mechanics.
------------------------------------------------------------------------

-- Disable environmental damage for dragons.

function dragon:check_entity_cramming ()
end

function dragon:do_env_damage ()
	return false
end

function dragon:falling (pos)
	return false
end

-- Dragons cannot be punched otherwise than through their hitbox
-- entities and are in fact not selectable.
function dragon:on_punch (_, _, _, _)
end

function dragon:check_for_death (mcl_reason, damage)
	if self.health > 0 then
		return mob_class.check_for_death (self, mcl_reason, damage)
	else
		self._phase = "death"
		return false
	end
end

function dragon:receive_damage (mcl_reason, damage)
	-- Only register damage from players and attenuate any damage
	-- not dealt to the head.

	if mcl_reason.direct and self:is_phase_sitting () then
		local ent = mcl_reason.direct:get_luaentity ()
		local wind_charge = "mcl_charges:wind_charge_flying"
		if ent and (ent._is_arrow or ent.name == wind_charge) then
			return false
		end
	end

	if (mcl_reason.source and mcl_reason.source:is_player ())
		or mcl_reason.flags.always_affects_dragons then
		if mcl_reason.dragon_part ~= "head" then
			damage = damage / 4.0 + math.min (damage, 1.0)
		end
		if damage < 0.01 then
			return false
		end
		if mob_class.receive_damage (self, mcl_reason, damage) then
			-- Am I sitting?
			if self:is_phase_sitting () then
				local dmg = self._damage_sustained_on_podium + damage
				self._damage_sustained_on_podium = dmg

				if dmg > 0.25 * self.initial_properties.hp_max then
					self._damage_sustained_on_podium = 0
					self._takeoff_path = nil
					self._phase = "takeoff"
				end
			end
			self._damage_time = 0.5
			return true
		end
	end

	return false
end

------------------------------------------------------------------------
-- Ender Dragon navigation.
------------------------------------------------------------------------

local hashpos = mcl_mobs.gwp_longhash

local function find_end_surface_position (x, z, elevation)
	local end_min = mcl_vars.mg_end_platform_pos.y + 10
	local end_max = mcl_vars.mg_end_max_official
	local node = vector.new (math.floor (x + 0.5), end_max,
				 math.floor (z + 0.5))

	while node.y > end_min do
		node.y = node.y - 1
		local node_data = core.get_node (node)
		local def = core.registered_nodes[node_data.name]

		if def and def.walkable then
			node.y = node.y + 1 + elevation
			return node
		end
	end

	node.y = end_min + elevation
	return node
end
mobs_mc.find_end_surface_position = find_end_surface_position

local posn_neighbors = {
	[1] = {
		2,
		12,
		13,
	},
	[2] = {
		1,
		3,
		14,
	},
	[3] = {
		2,
		4,
		14,
	},
	[4] = {
		3,
		5,
		15,
	},
	[5] = {
		4,
		6,
		16,
	},
	[6] = {
		5,
		7,
		16,
	},
	[7] = {
		6,
		8,
		17,
	},
	[8] = {
		7,
		9,
		18,
	},
	[9] = {
		8,
		10,
		18,
	},
	[10] = {
		9,
		11,
		19,
	},
	[11] = {
		10,
		12,
		20,
	},
	[12] = {
		1,
		11,
		20,
	},
	[13] = {
		1,
		14,
		20,
		21,
	},
	[14] = {
		2,
		3,
		13,
		15,
		21,
		22,
	},
	[15] = {
		4,
		14,
		16,
		22,
	},
	[16] = {
		5,
		6,
		15,
		17,
		22,
		23,
	},
	[17] = {
		7,
		16,
		18,
		23,
	},
	[18] = {
		8,
		9,
		17,
		19,
		23,
		24,
	},
	[19] = {
		10,
		18,
		20,
		24,
	},
	[20] = {
		11,
		12,
		13,
		19,
		21,
		24,
	},
	[21] = {
		13,
		14,
		20,
		22,
		23,
		24,
	},
	[22] = {
		14,
		15,
		16,
		21,
		23,
		24,
	},
	[23] = {
		16,
		17,
		18,
		21,
		22,
		24,
	},
	[24] = {
		18,
		19,
		20,
		21,
		22,
		23,
	},
}

function dragon:derive_circling_positions ()
	-- 1 to 12   = exterior of obsidian pillars.
	-- 13 to 20  = interior of obsidian pillars.
	-- 21 to 24  = vicinity of portal.

	self._circling_positions = {}
	self._circling_positions_by_hash = {}

	for i = 1, 24 do
		if i <= 12 then
			local f = (i - 1) / 12
			local c = math.cos (2.0 * (-math.pi + math.pi * f))
			local s = math.sin (2.0 * (-math.pi + math.pi * f))
			self._circling_positions[i]
				= find_end_surface_position (c * 60, s * 60, 5)
		elseif i <= 20 then
			local f = (i - 1) / 8
			local c = math.cos (2.0 * (-math.pi + math.pi * f))
			local s = math.sin (2.0 * (-math.pi + math.pi * f))
			self._circling_positions[i]
				= find_end_surface_position (c * 40, s * 40, 15)
		elseif i <= 24 then
			local f = (i - 1) / 4
			local c = math.cos (2.0 * (-math.pi + math.pi * f))
			local s = math.sin (2.0 * (-math.pi + math.pi * f))
			self._circling_positions[i]
				= find_end_surface_position (c * 20, s * 20, 5)
		end

		local pos = self._circling_positions[i]
		local hash = hashpos (pos.x, pos.y, pos.z)
		self._circling_positions_by_hash[hash] = i
	end
end

function dragon:get_closest_circling_position (self_pos)
	local distance, nearest
	local first = 1

	if self._crystals_remaining == 0 then
		first = 13
	end

	local positions = self._circling_positions
	local id
	for i = first, #positions do
		local dist = vector.distance (positions[i], self_pos)
		if not nearest or dist < distance then
			nearest = positions[i]
			id = i
			distance = dist
		end
	end

	assert (nearest)
	return nearest, id
end

dragon.gwp_penalties = {
	OPEN = 0.0,
}

function dragon:gwp_classify_node (context, pos)
	return "OPEN"
end

function dragon:gwp_classify_for_movement (pos)
	return "OPEN"
end

function dragon:gwp_align_start_pos (pos)
	return mcl_util.get_nodepos (pos)
end

function dragon:gwp_start (context)
	local self_pos = self.object:get_pos ()
	local start, _ = self:get_closest_circling_position (self_pos)
	return start
end

function dragon:gwp_limit_range (range)
	return math.huge
end

function dragon:get_gwp_node (context, x, y, z)
	local hash = hashpos (x, y, z)
	if context.nodes[hash] then
		return context.nodes[hash]
	end
	local obj = {
		x = x, y = y, z = z,
		g = nil, h = nil, penalty = 0,
		f = 0, total_d = 0,
	}
	context.nodes[hash] = obj
	return obj
end

function dragon:gwp_edges (context, gwp_node)
	local min = 1
	local neighbors = {}

	if self._crystals_remaining == 0 then
		min = 13
	end

	local hash = hashpos (gwp_node.x, gwp_node.y, gwp_node.z)
	local node = self._circling_positions_by_hash[hash]

	if node then
		for _, neighbor in pairs (posn_neighbors[node]) do
			if neighbor >= min then
				local posn = self._circling_positions[neighbor]
				local x, y, z = posn.x, posn.y, posn.z
				local gwp_node = self:get_gwp_node (context, x, y, z)
				gwp_node.class = "OPEN"
				gwp_node.penalty = 0.0
				table.insert (neighbors, gwp_node)
			end
		end
	end
	return neighbors
end

function dragon:position_hop (dest_node, real_dest)
	local dest = self._circling_positions[dest_node]
	local context = self:gwp_initialize ({dest}, math.huge, 0.0)
	assert (context)
	self:gwp_cycle (context, math.huge)

	if real_dest then
		local x = real_dest.x
		local y = real_dest.y
		local z = real_dest.z
		real_dest = self:get_gwp_node (context, x, y, z)
	end

	local path, partial
		= self:gwp_reconstruct (context, real_dest)
	return path or nil, partial
end

------------------------------------------------------------------------
-- Ender Dragon combat routines.
------------------------------------------------------------------------

function dragon:crystal_destroyed (crystal, puncher)
	if self._phase == "hold" then
		if not puncher then
			puncher = self:get_nearest_player (crystal, 128)
		end
		if puncher and is_valid (puncher)
			and (not puncher:is_player ()
				or self:attack_player_allowed (puncher)) then
			self:strafe (puncher)
		end
	end
end

function dragon:is_phase_sitting ()
	return self._phase == "hover"
		or self._phase == "scan"
		or self._phase == "acid_attack"
		or self._phase == "bellow_acid"
end

function dragon:get_flight_speed ()
	if self._phase == "charge"
		or self._phase == "death" then
		return 60
	elseif self._phase == "descent" then
		return 30
	else
		return 20
	end
end

function dragon:get_turn_speed (v)
	if self._phase == "descent" then
		local v = (math.sqrt (v.x * v.x + v.z * v.z) * 0.05) + 1.0
		local clipped = math.min (v, 40.0)
		return clipped / v
	else
		local v = (math.sqrt (v.x * v.x + v.z * v.z) * 0.05) + 1.0
		local clipped = math.min (v, 40.0)
		return 0.7 / clipped / v
	end
end

function dragon:do_phase_hover (self_pos, dtime)
	self._dragon_target = self_pos
end

function dragon:strafe (target)
	self._dragon_target = nil
	self._strafe_target = target
	self._strafe_path = nil
	self._vistime = 0.0
	self._phase = "strafe"
end

function dragon:maybe_land_or_strafe (self_pos, dtime)
	local chance = self._crystals_remaining
	if math.random (chance + 3) == 1 then
		self._phase = "land"
		return
	end

	-- Perhaps begin to strafe the player.
	local player, dist = self:get_nearest_player (self_pos, 360.0)
	if player then
		local dist_chance = math.floor ((dist * dist) / 512.0) + 2.0
		local crystal_chance = self._crystals_remaining + 2

		if math.random (dist_chance) == 1
			or math.random (crystal_chance) == 1 then
			self:strafe (player)
			return
		end
	end
end

function dragon:do_phase_hold (self_pos, dtime)
	if not self._hold_path then
		local _, id = self:get_closest_circling_position (self_pos)

		if math.random (8) == 1 then
			self._hold_clockwise = false
			id = id + 6
		end

		if self._hold_clockwise then
			id = id + 1
		else
			id = id - 1
		end

		-- Limit to interior or exterior ring.
		if self._crystals_remaining > 0 then
			id = (id - 1) % 12 + 1
		else
			id = (id - 13) % 8 + 13
		end

		self._hold_path = self:position_hop (id)
		self._dragon_target = nil
	end

	if self._hold_path then
		local path = self._hold_path
		local idx = #path
		local target = self._dragon_target

		if not target or vector.distance (target, self_pos) < 10 then
			path[idx] = nil

			if idx <= 1 then
				self._hold_path = nil
				if self:maybe_land_or_strafe (self_pos, dtime) then
					return
				end
			else
				local next_wp = path[idx - 1]
				local y_delta = math.round (math.random () * 20.0)
				local pos = vector.offset (next_wp, 0, y_delta, 0)
				self._dragon_target = pos
			end
		end
	end
end

function dragon:do_phase_land (self_pos, dtime)
	self._bellow_count = 0
	if not self._land_path then
		local podium = find_end_surface_position (0, 0, 0)
		local detour = find_end_surface_position (40, 0, 0)

		-- Swoop past player if present.
		local player = self:get_nearest_player (self_pos, 360.0)
		if player then
			local player_pos = player:get_pos ()
			player_pos.y = 0
			local dir_from_podium = vector.normalize (player_pos)
			detour.x = dir_from_podium.x * -40
			detour.y = 105
			detour.z = dir_from_podium.z * -40
		end
		local _, id = self:get_closest_circling_position (detour)

		self._land_path = self:position_hop (id, podium)
		self._dragon_target = nil
	end

	if self._land_path then
		local path = self._land_path
		local idx = #path
		local target = self._dragon_target

		if not target or vector.distance (target, self_pos) < 10 then
			path[idx] = nil

			if idx <= 1 then
				self._land_path = nil
				self._dragon_target = nil
				self._podium_position
					= find_end_surface_position (0, 0, 0)
				self._phase = "descent"
			else
				local next_wp = path[idx - 1]
				local y_delta = math.round (math.random () * 20.0)
				local pos = vector.offset (next_wp, 0, y_delta, 0)
				self._dragon_target = pos
			end
		end
	end
end

local HEAD_POS = vector.new (0.0, 0.75, 5.6)

function dragon:do_phase_descent (self_pos, dtime)
	local target = self._dragon_target
	if not target then
		target = find_end_surface_position (0, 0, 0)
	end

	if self:check_timer ("descent_particles", 0.5) then
		local head_pos
			= self:get_head_pos (vector.new (0, -0.6, 0), HEAD_POS)
		local dir = vector.direction (vector.add (self_pos, head_pos), target)
		core.add_particlespawner ({
			pos = {
				min = vector.offset (head_pos, -0.5, -0.5, -0.5),
				max = vector.offset (head_pos, 0.5, 0.5, 0.5),
			},
			time = 0.5,
			amount = 160,
			exptime = 100,
			vel = {
				min = vector.offset (dir * 1.6, -0.3, -0.3, -0.3),
				max = vector.offset (dir * 1.6, 0.3, 0.3, 0.3),
			},
			collisiondetection = true,
			collision_removal = true,
			size = {
				min = 1.0,
				max = 1.5,
			},
			texpool = {
				"mcl_particles_dragon_breath_1.png^[colorize:#ff00ff:127",
				"mcl_particles_dragon_breath_2.png^[colorize:#ff00ff:127",
				"mcl_particles_dragon_breath_3.png^[colorize:#ff00ff:127",
			},
			attached = self.object,
		})
	end

	if vector.distance (self_pos, target) < 1.0 then
		self._phase = "scan"
		self._scanned_for = 0.0
		self._dragon_target = nil
	else
		self._dragon_target = target
	end
end

function dragon:get_nearest_player (self_pos, radius)
	local nearest, dist

	for object, distance in mcl_util.connected_players (self_pos, radius) do
		if (not dist or dist > distance)
			and self:attack_player_allowed (object) then
			nearest = object
			dist = distance
		end
	end
	return nearest, dist
end

function dragon:get_head_pos (self_pos, pos)
	local pos = dragon_parts["head"].position
	local pitch = self._joint_pitch[1]
	local yaw = self._joint_yaw[1]
	local pos1 = vector.rotate (pos, vector.new (pitch, yaw, 0))
	pos1.x = pos1.x + self_pos.x
	pos1.y = pos1.y + self_pos.y
	pos1.z = pos1.z + self_pos.z
	return pos1
end

function dragon:look_at_and_integrate_yaw (self_pos, pos, dtime)
	local head_pos = self:get_head_pos (self_pos)
	local dz = pos.z - head_pos.z
	local dx = pos.x - head_pos.x
	local value = math.atan2 (dz, dx) - math.pi / 2
	local yaw = self:get_yaw ()
	local yaw_diff
		= mcl_util.norm_radians (value - yaw)
	local dist = math.sqrt (dx * dx + dz * dz) + 1.0
	local lim = math.max (-100, math.min (100, dist))
	local turn_speed = 0.7 / lim / dist
	local yaw_drag = pow_by_step (YAW_DRAG, dtime)
	local yaw_scale = (1 - yaw_drag) / (1 - YAW_DRAG)
	local yaw_acc = (self._yaw_acc * yaw_drag)
		+ math.max (math.min (yaw_diff, FIFTY_DEG), -FIFTY_DEG)
		* turn_speed * yaw_scale
	self:set_yaw (yaw + yaw_acc * (dtime / 0.05))
	self._yaw_acc = yaw_acc
end

function dragon:do_phase_scan (self_pos, dtime)
	local player = self:get_nearest_player (self_pos, 20.0)
	local t = self._scanned_for + dtime
	self._scanned_for = t

	if player then
		if self._scanned_for > 1.25 then
			self._bellow_time = 0.0
			self._phase = "acid_attack"
		else
			local player_pos = player:get_pos ()
			self:look_at_and_integrate_yaw (self_pos, player_pos, dtime)
		end
	elseif self._scanned_for > 5.0 then
		local player = self:get_nearest_player (self_pos, 150.0)

		if player then
			self._charge_target = player:get_pos ()
			self._charge_time = 0.0
			self._phase = "charge"
		else
			self._takeoff_path = nil
			self._phase = "takeoff"
		end
	end
end

local function is_clear (target)
	local name = core.get_node (target).name
	local def = core.registered_nodes[name]
	return def and not def.walkable
end

function dragon:do_phase_acid_attack (self_pos, dtime)
	if self._bellow_time == 0.0 then
		self:mob_sound ("attack")
	end
	local t = self._bellow_time + dtime
	self._bellow_time = t

	if t >= 2.0 then
		self._bellow_time = 0.0
		self._bellowed = false
		self._phase = "bellow_acid"
	end
end

function dragon:do_phase_bellow_acid (self_pos, dtime)
	if self._bellow_time == 0.0 then
		-- Spawn dragon breath particles.
		local yaw = self:get_yaw ()
		local pos = vector.rotate (HEAD_POS, vector.new (0, yaw, 0))
		local rot = vector.new (-self._joint_pitch[1] * 1.15, yaw, 0)
		local dir = vector.rotate (vector.new (0, 0, 1), rot)
		local v = vector.multiply (dir, 12.0)
		local base_pos = vector.add (self_pos, pos)
		core.add_particlespawner ({
			pos = {
				min = vector.offset (base_pos, -0.5, -0.5, -0.5),
				max = vector.offset (base_pos, 0.5, 0.5, 0.5),
			},
			time = 0.5,
			amount = 160,
			exptime = 100,
			vel = {
				min = vector.offset (v, -0.3, -0.3, -0.3),
				max = vector.offset (v, 0.3, 0.3, 0.3),
			},
			acc = {
				min = vector.new (-0.19, -9.81, -0.19),
				max = vector.new (0.19, -9.81, 0.19),
			},
			collisiondetection = true,
			collision_removal = true,
			size = {
				min = 1.0,
				max = 1.5,
			},
			texpool = {
				"mcl_particles_dragon_breath_1.png^[colorize:#ff00ff:127",
				"mcl_particles_dragon_breath_2.png^[colorize:#ff00ff:127",
				"mcl_particles_dragon_breath_3.png^[colorize:#ff00ff:127",
			},
		})
	end

	local t = self._bellow_time + dtime
	self._bellow_time = t

	if t >= 0.5 and not self._bellowed then
		local yaw = self:get_yaw ()
		local pos = vector.rotate (HEAD_POS, vector.new (0, yaw, 0))
		local rot = vector.new (-self._joint_pitch[1] * 1.15, yaw, 0)
		local dir = vector.rotate (vector.new (0, 0, 1), rot)
		local x_off = self_pos.x + (dir.x * 5.0 / 2.0)
		local z_off = self_pos.z + (dir.z * 5.0 / 2.0)
		local target = vector.offset (pos, x_off, self_pos.y, z_off)
		target = mcl_util.get_nodepos (target)

		while is_clear (target) and target.y > mcl_vars.mg_end_min do
			target.y = target.y - 1
		end
		target.y = target.y + 0.5
		local object = core.add_entity (target, "mobs_mc:dragon_effect_cloud")
		if object then
			local entity = object:get_luaentity ()
			entity:init ({
				radius = 5.0,
				duration = 10.0,
				radius_per_second = 0.0,
				damage = 6.0,
			})
		end
		self._bellowed = true
		self._bellow_count = self._bellow_count + 1
	end

	if t >= 10 then
		if self._bellow_count >= 4 then
			self._takeoff_path = nil
			self._phase = "takeoff"
		else
			self._scanned_for = 0.0
			self._phase = "scan"
		end
	end
end

function dragon:do_phase_charge (self_pos, dtime)
	if not self._charge_target then
		self._phase = "hold"
	elseif self._charge_time > 0 then
		local t = self._charge_time + dtime
		if t >= 0.5 then
			self._phase = "hold"
		end
		self._charge_time = t
	else
		local target = self._charge_target
		if vector.distance (self_pos, target) < 10.0 then
			self._charge_time = dtime
		end
		self._dragon_target = target
	end
end

function dragon:do_phase_takeoff (self_pos, dtime)
	if not self._takeoff_path then
		local yaw = self:joint_sample (1)[1]
		local x = 40 * math.cos (yaw)
		local z = 40 * -math.sin (yaw)
		local y = mcl_vars.mg_end_platform_pos.y + 105
		local v = vector.new (x, y, z)
		local _, id = self:get_closest_circling_position (v)

		if self._crystals_remaining > 0 then
			id = (id - 1) % 12 + 1
		else
			id = (id - 13) % 8 + 13
		end

		self._takeoff_path = self:position_hop (id)
		self._dragon_target = nil
	end

	if self._takeoff_path then
		local path = self._takeoff_path
		local idx = #path
		local target = self._dragon_target

		if not target or vector.distance (target, self_pos) < 10 then
			path[idx] = nil

			if idx <= 1 then
				self._takeoff_path = nil
				self._dragon_target = nil
				self._phase = "hold"
			else
				local next_wp = path[idx - 1]
				local y_delta = math.round (math.random () * 20.0)
				local pos = vector.offset (next_wp, 0, y_delta, 0)
				self._dragon_target = pos
			end
		end
	end
end

local TEN_DEG = math.rad (10)

function dragon:maybe_shoot (self_pos, dtime, target, target_pos)
	local dist = vector.distance (self_pos, target_pos)
	if dist < 64.0 then
		local yaw = self:get_yaw ()
		local pos = vector.rotate (HEAD_POS, vector.new (0, yaw, 0))
		pos = vector.add (pos, self_pos)

		-- Offset target_pos by 0.1 nodes to account for cases
		-- where the target is standing on a solid.
		if self:line_of_sight (pos, vector.offset (target_pos, 0, 0.1, 0)) then
			local t = self._vistime + dtime
			self._vistime = t

			if t >= 0.25 then
				local dx = target_pos.x - pos.x
				local dz = target_pos.z - pos.z
				local target = math.atan2 (dz, dx) - math.pi / 2
				local diff = mcl_util.norm_radians (yaw - target)

				if diff > -TEN_DEG and diff < TEN_DEG then
					self:mob_sound ("shoot_attack")
					local dir = vector.direction (pos, target_pos)
					local vel = vector.multiply (dir, 24)
					local obj = core.add_entity (pos, "mobs_mc:dragon_fireball")
					if obj then
						obj:set_velocity (vel)
					end
					return true
				end
			end
		else
			local t = math.max (self._vistime - dtime, 0)
			self._vistime = t
		end
	else
		local t = math.max (self._vistime - dtime, 0)
		self._vistime = t
	end
end

function dragon:do_phase_strafe (self_pos, dtime)
	local target = self._strafe_target
	local target_pos = target:get_pos ()

	if not self._strafe_path and not self._dragon_target then
		if not target_pos then
			self._strafe_target = nil
			self._hold_path = nil
			self._phase = "hold"
			return
		end

		-- Initialize a circling path.
		local _, id = self:get_closest_circling_position (self_pos)

		if math.random (8) == 1 then
			self._hold_clockwise = false
			id = id + 6
		end

		if self._hold_clockwise then
			id = id + 1
		else
			id = id - 1
		end

		-- Limit to interior or exterior ring.
		if self._crystals_remaining > 0 then
			id = (id - 1) % 12 + 1
		else
			id = (id - 13) % 8 + 13
		end

		self._strafe_path = self:position_hop (id)
		self._dragon_target = nil
	end

	if self:maybe_shoot (self_pos, dtime, target, target_pos) then
		self._strafe_target = nil
		self._strafe_path = nil
		self._hold_path = nil
		self._phase = "hold"
		return
	end

	-- Follow this path.  Once it completes, set
	-- self._dragon_target to a position near the target.

	if self._strafe_path then
		local path = self._strafe_path
		local idx = #path
		local target = self._dragon_target

		if not target or vector.distance (target, self_pos) < 10 then
			path[idx] = nil

			if idx <= 1 then
				self._strafe_path = nil
			else
				local next_wp = path[idx - 1]
				local y_delta = math.round (math.random () * 20.0)
				local pos = vector.offset (next_wp, 0, y_delta, 0)
				self._dragon_target = pos
			end
		end
	elseif self._dragon_target then
		local dx = target_pos.x - self_pos.x
		local dz = target_pos.z - self_pos.z
		local dist = math.sqrt (dx * dx + dz * dz)
		local height = math.min (10.0, 0.4 + dist / 80.0 - 1.0)
		self._dragon_target = vector.offset (target_pos, 0, height, 0)
	end
end

function dragon:do_phase_death (self_pos, dtime)
	local podium = find_end_surface_position (0, 0, 0)
	self._dragon_target = podium

	if self:check_timer ("death_particles", 0.5) then
		core.add_particlespawner ({
			amount = 120,
			time = 1.0,
			pos = vector.new (0, 1.5, 0),
			radius = 3,
			acc = vector.zero (),
			exptime = {
				min = 0.5,
				max = 1.0,
			},
			size = {
				min = 8,
				max = 12,
			},
			texture = "mcl_particles_smoke.png",
			attached = self.object,
		})
	end

	if vector.distance (self_pos, podium) < 7.0 then
		self._dragon_dead = true
		self._dragon_target = nil
	end
end

function dragon:apply_debug_nametag ()
	local info = {}
	table.insert (info, self.description)
	table.insert (info, string.format ("HP: (%.2f / %d)",
					   self.health, 200))
	table.insert (info, string.format ("Crystals remaining: %d",
					   self._crystals_remaining))
	table.insert (info, string.format ("Combat routine phase: %s",
					   self._phase))
	self.object:set_nametag_attributes ({
		text = table.concat (info, "\n"),
	})
end

function dragon:run_ai (dtime, moveresult)
	if self.dead or self._dragon_dead then
		return
	end
	local self_pos = self.object:get_pos ()
	if self._phase == "hover" then
		self:do_phase_hover (self_pos, dtime)
	elseif self._phase == "hold" then
		self:do_phase_hold (self_pos, dtime)
	elseif self._phase == "land" then
		self:do_phase_land (self_pos, dtime)
	elseif self._phase == "descent" then
		self:do_phase_descent (self_pos, dtime)
	elseif self._phase == "scan" then
		self:do_phase_scan (self_pos, dtime)
	elseif self._phase == "acid_attack" then
		self:do_phase_acid_attack (self_pos, dtime)
	elseif self._phase == "bellow_acid" then
		self:do_phase_bellow_acid (self_pos, dtime)
	elseif self._phase == "charge" then
		self:do_phase_charge (self_pos, dtime)
	elseif self._phase == "takeoff" then
		self:do_phase_takeoff (self_pos, dtime)
	elseif self._phase == "strafe" then
		self:do_phase_strafe (self_pos, dtime)
	elseif self._phase == "death" then
		self:do_phase_death (self_pos, dtime)
	end
	self:step_dragon_fight (dtime, self_pos)

	if dragon_debug then
		self:apply_debug_nametag ()
	end
end

------------------------------------------------------------------------
-- Dragon fight monitoring.
------------------------------------------------------------------------

function dragon:refresh_dragon_fight ()
	-- Locate and tally remaining crystals.
	local crystals = {}
	local center = vector.new (0, mcl_vars.mg_end_platform_pos.y, 0)
	local min = vector.offset (center, -128, 0, -128)
	local max = vector.offset (center, 128, mcl_vars.mg_end_max_official - center.y, 128)
	for object in core.objects_in_area (min, max) do
		local entity = object:get_luaentity ()
		if entity and entity.name == "mcl_end:crystal" then
			table.insert (crystals, object)
		end
	end
	self._crystals_remaining = #crystals
	self._crystals = crystals
end

function dragon:check_crystals (dtime, self_pos)
	local living = {}
	local nearest, dist, nearest_pos
	for _, crystal in pairs (self._crystals) do
		if not is_valid (crystal) then
			-- A crystal was removed.
			if crystal == self._current_crystal then
				self._current_crystal = nil
			end
		else
			local entity = crystal:get_luaentity ()
			local pos = crystal:get_pos ()
			if entity._exploded then
				self:crystal_destroyed (pos, entity._puncher)
			else
				table.insert (living, crystal)
				local distance = vector.distance (self_pos, pos)

				if not nearest or distance < dist then
					nearest = crystal
					dist = distance
					nearest_pos = pos
				end
			end
		end
	end

	if nearest ~= self._current_crystal then
		self._current_crystal = nearest

		if self._current_beam then
			self._current_beam:remove ()
		end
		if nearest then
			self._current_beam
				= core.add_entity (nearest_pos, "mcl_end:crystal_beam")
			if self._current_beam then
				local entity = self._current_beam:get_luaentity ()
				entity:init (self.object, nearest)
			end
		end
	end

	if self._current_crystal then
		local entity = self._current_crystal:get_luaentity ()

		if not entity then
			self._current_crystal = nil
		elseif entity._exploded then
			local mcl_reason = {
				type = "explosion",
				source = self.object,
				dragon_part = "head",
			}
			mcl_damage.finish_reason (mcl_reason)
			mcl_util.deal_damage (self.object, 10.0, mcl_reason)
			self._current_crystal:remove ()
			self._current_crystal = nil
		elseif self:check_timer ("crystal_heal", 0.5) then
			local hp_max = self.initial_properties.hp_max
			self.health = math.min (self.health + 1.0, hp_max)
		end
	end
	self._crystals_remaining = #living
	self._crystals = living
end

function dragon:step_dragon_fight (dtime, self_pos)
	if self:check_timer ("refresh_dragon_fight", 2.5) then
		self:refresh_dragon_fight ()
	end
	self:check_crystals (dtime, self_pos)
	mcl_bossbars.update_boss (self.object, S ("Ender Dragon"), "light_purple")
end

------------------------------------------------------------------------
-- Ender Dragon spawning.
------------------------------------------------------------------------

mcl_mobs.register_mob ("mobs_mc:enderdragon", dragon)
mcl_mobs.register_egg ("mobs_mc:enderdragon", S("Ender Dragon"), "#252525", "#b313c9", 0, true)

------------------------------------------------------------------------
-- Ender Dragon area effect cloud.
------------------------------------------------------------------------

local dragon_effect_cloud = {
	initial_properties = {
		visual_size = {
			x = 0,
			y = 0,
			z = 0,
		},
		physical = false,
		collide_with_objects = false,
		visual = "cube",
		textures = {
			"blank.png",
		},
	},
	_radius = 5.0,
	_radius_per_second = 0.0,
	_duration = 10.0,
	_ttl = 10.0,
	_time_to_refresh = 0.0,
	_damage = 6.0,
}

function dragon_effect_cloud:configure ()
	local size = self._radius
	local cbox = {
		-size, 0.0, -size,
		size, 0.25, size,
	}
	self.object:set_properties ({
		collisionbox = cbox,
	})
	self._collisionbox = cbox
end

function dragon_effect_cloud:on_activate (staticdata, dtime)
	if staticdata then
		local data = core.deserialize (staticdata)
		if data then
			self._radius = data.radius or 5.0
			self._duration = data.duration or 10.0
			self._ttl = data.ttl or 10.0
			self._radius_per_second = data.radius_per_second or 0.0
			self._damage = data.damage or 6.0
		end
	end
	self:configure ()
end

function dragon_effect_cloud:get_staticdata ()
	return core.serialize ({
		radius = self._radius,
		duration = self._duration,
		ttl = self._ttl,
		radius_per_second = self._radius_per_second,
		damage = self._damage,
	})
end

function dragon_effect_cloud:create_particlespawner (self_pos)
	local spawner = {
		pos = vector.offset (self_pos, 0, 0.25, 0),
		time = 1.0,
		amount = self._radius * 100,
		exptime = {
			min = 1.0,
			max = 1.4,
		},
		radius = {
			min = ZERO_VECTOR,
			max = vector.new (self._radius, 0, self._radius),
		},
		vel = {
			min = vector.new (-0.1, -0.1, -0.1),
			max = vector.new (0.1, 0.1, 0.1),
		},
		acc = ZERO_VECTOR,
		collisiondetection = false,
		size = {
			min = 1.0,
			max = 1.5,
		},
		texpool = {
			"mcl_particles_dragon_breath_1.png^[colorize:#ff00ff:127",
			"mcl_particles_dragon_breath_2.png^[colorize:#ff00ff:127",
			"mcl_particles_dragon_breath_3.png^[colorize:#ff00ff:127",
		},
	}
	core.add_particlespawner (spawner)
end

local function is_mob (object)
	local entity = object:get_luaentity ()
	return entity and entity.is_mob
end

function dragon_effect_cloud:on_step (dtime)
	local ttl = self._ttl - dtime
	self._ttl = ttl
	if ttl <= 0 then
		self.object:remove ()
		return
	end
	local self_pos = self.object:get_pos ()
	local t = self._time_to_refresh - dtime
	if t <= 0 then
		t = 1.0
		self:create_particlespawner (self_pos)
	end
	self._time_to_refresh = t
	local cbox = table.copy (self._collisionbox)
	local aa = vector.new (cbox[1] + self_pos.x - 2.0,
			       cbox[2] + self_pos.y - 2.0,
			       cbox[3] + self_pos.z - 2.0)
	local bb = vector.new (cbox[4] + self_pos.x + 2.0,
			       cbox[5] + self_pos.y + 2.0,
			       cbox[6] + self_pos.z + 2.0)
	offset_cbox (cbox, self_pos, 0.0)
	for object in core.objects_in_area (aa, bb) do
		if not damage_immune[object]
			and (object:is_player () or is_mob (object)) then
			local pos = object:get_pos ()
			local dx = pos.x - self_pos.x
			local dz = pos.z - self_pos.z
			local dist = dx * dx + dz * dz
			if dist < self._radius * self._radius then
				local cbox1 = object:get_properties ().collisionbox
				offset_cbox (cbox1, pos, 0.0)

				if box_intersection (cbox, cbox1) then
					damage_immune[object] = 0.5
					mcl_util.deal_damage (object, self._damage, {
						type = "dragon_breath",
					})
				end
			end
		end
	end
	self._radius = self._radius + self._radius_per_second * dtime
end

function dragon_effect_cloud:init (params)
	self._radius = params.radius
	self._duration = params.duration
	self._ttl = params.duration
	self._radius_per_second = params.radius_per_second
	self._damage = params.damage
	self:configure ()
end

function dragon_effect_cloud:on_punch (_, _, _, _, _)
	return true
end

function dragon_effect_cloud:on_rightclick (clicker)
	local item = clicker:get_wielded_item ()
	if item and item:get_name () == "mcl_potions:glass_bottle" then
		local inv = clicker:get_inventory ()
		inv:remove_item ("main", "mcl_potions:glass_bottle")
		-- If room exists add dragon's breath to inventory,
		-- and otherwise drop it as an item.
		if inv:room_for_item ("main", { name = "mcl_potions:dragon_breath", }) then
			clicker:get_inventory():add_item ("main", "mcl_potions:dragon_breath")
		else
			local pos = clicker:get_pos ()
			pos.y = pos.y + 0.5
			core.add_item (pos, {
				name = "mcl_potions:dragon_breath",
			})
		end
		self._radius = math.max (0, self._radius - 0.5)
	end
end

core.register_entity ("mobs_mc:dragon_effect_cloud", dragon_effect_cloud)

------------------------------------------------------------------------
-- Ender Dragon Fireball.
------------------------------------------------------------------------

local dragon_fireball = {
	initial_properties = {
		visual = "sprite",
		visual_size = {
			x = 1,
			y = 1,
		},
		textures = {
			"mobs_mc_dragon_fireball.png",
		},
		collisionbox = {
			-.5, -.5, -.5, .5, .5, .5,
		},
		physical = true,
		collide_with_objects = false,
		static_save = false,
	},
}

function dragon_fireball:on_punch (_, _, _, _, _)
	return true
end

function dragon_fireball:splash_particle (pos)
	local d = -0.1
	core.add_particlespawner ({
		amount = 50,
		time = 0.1,
		minpos = {x=pos.x-d, y=pos.y, z=pos.z-d},
		maxpos = {x=pos.x+d, y=pos.y+d, z=pos.z+d},
		minvel = {x=-2, y=0, z=-2},
		maxvel = {x=2, y=2, z=2},
		minexptime = 0.5,
		maxexptime = 1.25,
		minsize = 1,
		maxsize = 2,
		collisiondetection = true,
		vertical = false,
		texpool = {
			"mcl_particles_dragon_breath_1.png^[colorize:#ff00ff:127",
			"mcl_particles_dragon_breath_2.png^[colorize:#ff00ff:127",
			"mcl_particles_dragon_breath_3.png^[colorize:#ff00ff:127",
		},
	})
end

function dragon_fireball:on_step (dtime, moveresult)
	if moveresult.collides then
		local self_pos = self.object:get_pos ()
		self:splash_particle (self_pos)
		self.object:remove ()

		local object = core.add_entity (self_pos, "mobs_mc:dragon_effect_cloud")
		if object then
			local entity = object:get_luaentity ()
			entity:init ({
				radius = 3.0,
				duration = 30,
				radius_per_second = 4.0 / 30,
				damage = 12.0,
			})
		end
	end
end

core.register_entity ("mobs_mc:dragon_fireball", dragon_fireball)
