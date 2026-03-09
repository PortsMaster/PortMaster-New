--###################
--################### GUARDIAN
--###################

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

local guardian = {
	description = S("Guardian"),
	type = "monster",
	_spawn_category = "monster",
	hp_min = 30,
	hp_max = 30,
	xp_min = 10,
	xp_max = 10,
	breath_max = -1,
	attack_type = "null",
	view_range = 16.0,
	tracking_distance = 16.0,
	movement_speed = 10,
	damage = 6,
	reach = 3,
	head_eye_height = 0.425,
	collisionbox = {-0.425, 0, -0.425, 0.425, 0.85, 0.425},
	doll_size_override = { x = 0.6, y = 0.6 },
	visual = "mesh",
	mesh = "mobs_mc_guardian.b3d",
	textures = {
		{"mobs_mc_guardian.png"},
	},
	visual_size = {x=3, y=3},
	sounds = {
		random = "mobs_mc_guardian_random",
		war_cry = "mobs_mc_guardian_random",
		damage = {name="mobs_mc_guardian_hurt", gain=0.7},
		death = "mobs_mc_guardian_death",
		flop = "mobs_mc_squid_flop",
		distance = 16,
	},
	animation = {
		stand_speed = 25, walk_speed = 50, run_speed = 50,
		stand_start = 0,		stand_end = 20,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
	drops = {
		-- Greatly increased amounts of prismarine
		{name = "mcl_ocean:prismarine_shard",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},
		-- The following drops are approximations
		-- Fish / prismarine crystal
		{name = "mcl_fishing:fish_raw",
		chance = 4,
		min = 1,
		max = 1,
		looting = "common",},
		{name = "mcl_ocean:prismarine_crystals",
		chance = 4,
		min = 1,
		max = 2,
		looting = "common",},

		-- Rare drop: fish
		{name = "mcl_fishing:fish_raw",
		chance = 160, -- 2.5% / 4
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.0025,},
		{name = "mcl_fishing:salmon_raw",
		chance = 160,
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.0025,},
		{name = "mcl_fishing:clownfish_raw",
		chance = 160,
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.0025,},
		{name = "mcl_fishing:pufferfish_raw",
		chance = 160,
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.0025,},
	},
	swims = true,
	makes_footstep_sound = false,
	pace_interval = 1,
	pace_chance = 80,
	idle_gravity_in_liquids = true,
	flops = true,
	_default_laser_delay = 4.0,
}

------------------------------------------------------------------------
-- Guardian movement and physics.
------------------------------------------------------------------------

local NINETY_DEG = math.pi / 2
local clip_rotation = mcl_mobs.clip_rotation

function guardian:do_go_pos (dtime, moveresult)
	local target = self.movement_target or vector.zero ()
	local self_pos = self.object:get_pos ()
	local dx, dy, dz = target.x - self_pos.x,
		target.y - self_pos.y,
		target.z - self_pos.z
	local vel = self.movement_velocity
	local magnitude = math.sqrt (dx * dx + dy * dy + dz * dz)
	local y_mag = dy / magnitude
	local yaw = math.atan2 (dz, dx) - NINETY_DEG
	local y_rot = clip_rotation (self:get_yaw (), yaw, NINETY_DEG)
	self:set_yaw (y_rot)
	local current_speed = self._acc_movement_speed or 0
	local speed = (vel - current_speed) * 0.125 + current_speed
	self._acc_movement_speed = speed
	self:set_velocity (speed)
	local clock = math.round (self._acc_seed * 20)
	local acc_x = math.cos (clock / 2)
	local acc_y = math.sin (clock * 0.75)

	-- Compute values perpendicular to this mob's forward movement
	-- axis.
	local wiggle_x = math.cos (y_rot)
	local wiggle_z = math.sin (y_rot)
	local f = dtime / 0.05
	local x = wiggle_x * acc_x * f
	-- Reuse these values as a forward magnitude of kinds.
	local y = (acc_y * (wiggle_x + wiggle_z) * 0.25) * f
		+ speed * y_mag * 0.1 * f
	local z = wiggle_z * acc_x * f
	local fv = vector.new (x, y, z)
	self.object:add_velocity (fv)
	self.acc_speed = 2.0
	self._acc_no_gravity = true
end

function guardian:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	self._acc_seed = math.random (4)
	self._previous_eye_diff = nil
	return true
end

function guardian:motion_step (dtime, moveresult, self_pos)
	mob_class.aquatic_step (self, dtime, moveresult, self_pos)
	self._acc_seed = self._acc_seed + dtime
end

function guardian:movement_step (dtime, moveresult)
	mob_class.aquatic_movement_step (self, dtime, moveresult)
	if self.attack then
		self._acc_no_gravity
			= self._immersion_depth >= self.head_eye_height
	end
end

function guardian:configure_aquatic_mob ()
	mob_class.configure_aquatic_mob (self)
	self.motion_step = guardian.motion_step
	self.movement_step = guardian.movement_step
end

------------------------------------------------------------------------
-- Guardian effects.
------------------------------------------------------------------------

local EYE_LATITUDE = 0.4

function guardian:check_head_swivel (self_pos, dtime, clear)
	-- This is not readily supported on Minetest 5.8.0 and
	-- earlier.
	if not self.object.set_bone_override then
		return
	end

	if clear then
	   self._locked_object = nil
	else
	   self:who_are_you_looking_at ()
	end

	if self._locked_object then
		if not is_valid (self._locked_object) then
			self._locked_object = nil
			return
		end
		local yaw = self.object:get_yaw ()
		local forward_vector = core.yaw_to_dir (yaw)
		local diff = vector.offset (self_pos, 0, self:get_eye_height (), 0)
		local eye_vector = {
			x = math.cos (yaw) * EYE_LATITUDE,
			y = 0,
			z = math.sin (yaw) * EYE_LATITUDE,
		}
		-- Project vector from eye to player position onto eye
		-- vector.
		local target_head_pos = mcl_util.target_eye_pos (self._locked_object)
		diff = vector.subtract (diff, target_head_pos)
		if self._previous_eye_diff
			and vector.equals (self._previous_eye_diff, diff) then
			return
		end
		if vector.dot (forward_vector, vector.normalize (diff)) < 0 then
			self._previous_eye_diff = diff
			local proj = vector.dot (diff, eye_vector)
			if proj < -1 then
				proj = -1
			elseif proj > 1 then
				proj = 1
			end
			local position = proj * -EYE_LATITUDE
			self.object:set_bone_override ("eye", {
							       position = {
								       vec = vector.new (position, 0, 0),
								       absolute = false,
							       },
			})
			local x_mag_sqr = diff.x * diff.x + diff.z * diff.z
			local pitch = math.atan2 (-diff.y, math.sqrt (x_mag_sqr))
			self:set_pitch (pitch)
		else
			self:set_pitch (0)
		end
	else
		if not self._previous_eye_diff then
			return
		end
		self._previous_eye_diff = nil
		self.object:set_bone_override ("eye", {
			position = {
				vec = vector.zero (),
				absolute = false,
			},
		})
		self:set_pitch (0)
	end
end

function guardian:can_reset_pitch ()
	return not self._locked_object
end

function guardian:set_animation_speed (custom_speed)
	local anim = self._current_animation
	if not anim then
		return
	end
	local name = anim .. "_speed"
	local normal_speed = self.animation[name]
		or self.animation.speed_normal
		or 25
	local speed = custom_speed or normal_speed
	local v = self:get_velocity ()
	local scaled_speed = speed * self.frame_speed_multiplier
	self.object:set_animation_frame_speed (scaled_speed * math.max (1, v / 2))
end

------------------------------------------------------------------------
-- Guardian AI.
------------------------------------------------------------------------

function guardian:attack_end ()
	mob_class.attack_end (self)
	self._pace_asap = true
end

function guardian:attack_null (self_pos, dtime, target_pos, line_of_sight)
	if not self.attacking then
		self._laser_delay = self._default_laser_delay
		self.attacking = true
	end
	if not line_of_sight then
		self.attack = nil
		self:attack_end ()
		return
	end
	self:cancel_navigation ()
	self:halt_in_tracks ()
	self._laser_delay = self._laser_delay - dtime
	self:look_at (self.attack:get_pos ())
	if self._laser_delay <= 0 then
		local magic_damage = 1.0
		if mcl_vars.difficulty == 3 then
			magic_damage = 3.0
		end
		mcl_util.deal_damage (self.attack, magic_damage, {
			type = "magic",
			source = self.object,
		})
		self.attack:punch (self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {
				fleshy = self.damage,
			},
		})
		self.attack = nil
		self:attack_end ()
	end
end

local dist_sqr = mcl_mobs.dist_sqr

function guardian:get_active_target (self_pos)
	if not self._pace_asap then
		local target = mob_class.get_active_target (self)
		local pos = target and target:get_pos ()
		if pos and dist_sqr (self_pos, pos) > 9.0 then
			return target
		end
	end

	-- Don't attack when the target is too near, but attempt to
	-- elude it by triggering `attack_end' and pacing.
	return nil
end

guardian.ai_functions = {
	mob_class.check_attack,
	mob_class.check_pace,
}

local function guardian_target_attackable_p (self, self_pos, obj, entity)
	if not self._pace_asap then
		-- `not entity' indicates that OBJ is a player.
		if not entity
			or entity.name == "mobs_mc:squid"
			or entity.name == "mobs_mc:glow_squid"
			or entity.name == "mobs_mc:axolotl" then
			-- Guardians should attempt to evade targets
			-- within 3 nodes of themselves.
			return dist_sqr (self_pos, obj:get_pos ()) > 9.0
		end
	end
	return false
end

guardian._targeting_rules = {
	mcl_mobs.build_nearest_target_rule ("entity", guardian_target_attackable_p,
					    nil, nil, false),
}

------------------------------------------------------------------------
-- Guardian spawning.
------------------------------------------------------------------------

local monster_spawner = mobs_mc.monster_spawner
local guardian_spawner = table.merge (monster_spawner, {
	name = "mobs_mc:guardian",
	weight = 1,
	pack_min = 2,
	pack_max = 4,
	biomes = {},
	spawn_placement = "aquatic",
	structures = {
		"mcl_levelgen:ocean_monument",
	},
})

local pr = PcgRandom (math.floor (os.time () * 3985) % 0x100000000)
local v = vector.new ()
local mathmin = math.min

local function guardian_visibility_test (node_pos)
	-- Return whether the sky is not visible from the first
	-- non-water node above NODE_POS.
	v.x = node_pos.x
	v.z = node_pos.z
	for y = node_pos.y, mathmin (0, node_pos.y + 80) do
		v.y = y
		local node = core.get_node (v)
		local def = core.registered_nodes[node.name]
		if def and (not def.groups.water or def.groups.water == 0) then
			local sky_visible = mcl_weather.can_see_outdoors (v)
			return not sky_visible
		end
	end

	-- Return whether the sky is not visible at sea level.
	v.y = 0
	return not mcl_weather.can_see_outdoors (v)
end

local function is_water (node)
	local def = core.registered_nodes[node.name]
	return def and def.groups.water and def.groups.water > 0
end

function guardian_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache,
					       spawn_flag)
	if mcl_vars.difficulty > 0
		and is_water (self:get_node (node_cache, 0, node_pos))
		and is_water (self:get_node (node_cache, -1, node_pos)) then
		return pr:next (1, 20) == 1
			or guardian_visibility_test (node_pos)
	end
	return nil
end

function guardian_spawner:describe_additional_spawning_criteria ()
	return monster_spawner.describe_additional_spawning_criteria (self)
		.. "  "
		.. S ("Guardians spawn less frequently in regions of the ocean which are exposed to the sky at the surface.")
end

mcl_mobs.register_spawner (guardian_spawner)
mcl_mobs.suppress_spawning_in_structure ("mcl_levelgen:ocean_monument",
					 "underground_water_creature")
mcl_mobs.suppress_spawning_in_structure ("mcl_levelgen:ocean_monument",
					 "axolotls")

------------------------------------------------------------------------
-- Guardian sundries.
------------------------------------------------------------------------

function guardian:receive_damage (mcl_reason, damage)
	local result = mob_class.receive_damage (self, mcl_reason, damage)
	if not result then
		return false
	end
	local source = mcl_reason.source
	if not source then
		return
	end
	local entity = source:get_luaentity ()
	if (source:is_player () or (entity and entity.is_mob))
		and self.movement_goal ~= "go_pos"
		and not mcl_reason.flags.bypasses_guardian then
		mcl_util.deal_damage (source, 2.0, {
			type = "thorns",
			source = self.object,
		})
	end
	self._pace_asap = true
	return result
end

mobs_mc.guardian = guardian
mcl_mobs.register_mob ("mobs_mc:guardian", guardian)

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:guardian", S("Guardian"), "#5a8272", "#f17d31", 0)
