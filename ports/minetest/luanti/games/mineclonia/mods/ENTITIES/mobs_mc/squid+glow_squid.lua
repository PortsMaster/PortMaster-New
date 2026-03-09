-- v1.1

--###################
--################### SQUID
--###################

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class

local squid = {
	description = S("Squid"),
	textures = {
		{ "mobs_mc_squid.png" }
	},
	type = "animal",
	_spawn_category = "water_creature",
	can_despawn = true,
	hp_min = 10,
	hp_max = 10,
	xp_min = 1,
	xp_max = 3,
	head_eye_height = 0.4,
	collisionbox = { -0.4, 0.0, -0.4, 0.4, 0.9, 0.4 },
	visual = "mesh",
	mesh = "mobs_mc_squid.b3d",
	sounds = {
		damage = {name="mobs_mc_squid_hurt", gain=0.3},
		death = {name="mobs_mc_squid_death", gain=0.4},
		flop = "mobs_mc_squid_flop",
		-- TODO: sounds: random
		distance = 16,
	},
	animation = {
	},
	visual_size = { x = 3, y = 3 },
	makes_footstep_sound = false,
	can_ride_boat = false,
	movement_speed = 14,
	breathes_in_water = true,
	runaway = false,
	drops = {
		{
			name = "mcl_mobitems:ink_sac",
			chance = 1,
			min = 1,
			max = 3,
			looting = "common"
		}
	},
	floats = false,
	_propel_dir = vector.new (0, 0, 0),
	_tentacle_movement = math.pi * 2,
	_tentacle_speed = 0,
	_squid_speed = 0,
	_rotate_speed = 0,
	_was_touching_water = false,
	_body_roll = 0,
	_stepheight_enabled = true,
	_ink_jet_glow = nil,
	_ink_jet_textures = {
		{
			name = "mcl_particles_squid_ink.png^[colorize:#000000:255",
			alpha_tween = {
				1,
				0,
			},
		},
		{
			name = "mcl_particles_squid_ink_1.png^[colorize:#000000:255",
			alpha_tween = {
				1,
				0,
			},
		},
		{
			name = "mcl_particles_squid_ink_2.png^[colorize:#000000:255",
			alpha_tween = {
				1,
				0,
			},
		},
	}
}

------------------------------------------------------------------------
-- Squid visuals.
------------------------------------------------------------------------

local Y_AXIS = vector.new (0, 1, 0)
local X_AXIS = vector.new (1, 0, 0)

function squid:spawn_ink_jet ()
	local pitch = self:get_pitch ()
	local yaw = self:get_yaw ()
	local v = vector.new (0, 0, -1)
	v = vector.rotate_around_axis (v, Y_AXIS, yaw)
	v = vector.rotate_around_axis (v, X_AXIS, pitch)
	local pos_min = vector.new (-0.3, -0.3, -0.3)
	local pos_max = vector.new (0.3, 0.3, 0)
	pos_min = vector.rotate_around_axis (pos_min, Y_AXIS, yaw)
	pos_min = vector.rotate_around_axis (pos_min, X_AXIS, pitch)
	pos_max = vector.rotate_around_axis (pos_max, Y_AXIS, yaw)
	pos_max = vector.rotate_around_axis (pos_max, X_AXIS, pitch)
	local pos = vector.new (0, 0, -0.4)
	pos = vector.rotate_around_axis (pos, Y_AXIS, yaw)
	pos = vector.rotate_around_axis (pos, X_AXIS, pitch)
	pos.y = pos.y + 0.25
	local self_pos = self.object:get_pos ()
	pos = vector.add (pos, self_pos)

	local particlespawner = {
		amount = 240,
		time = 0.25,
		texpool = self._ink_jet_textures,
		glow = self._ink_jet_glow,
		pos = {
			min = vector.add (pos, pos_min),
			max = vector.add (pos, pos_max),
		},
		vel = {
			min = vector.multiply (v, 2.0),
			max = vector.multiply (v, 5.0),
		},
		exptime = {
			min = 0.25,
			max = 0.5,
		},
		collisiondetection = true,
		object_collision = true,
	}
	core.add_particlespawner (particlespawner)
end

function squid:receive_damage (mcl_reason, damage)
	local rc = mob_class.receive_damage (self, mcl_reason, damage)
	if rc and damage > 0 and mcl_reason.source then
		self:spawn_ink_jet ()
	end
	return rc
end

------------------------------------------------------------------------
-- Squid movement.
------------------------------------------------------------------------

local TWO_PI = math.pi * 2

local pr = PcgRandom (os.time () * TWO_PI)
local r = 1 / 2147483647

local function random_anim_speed ()
	return 1 / (pr:next (0, 2147483647) * r + 1.0) * 0.2
end

function squid:get_staticdata_table ()
	local supertable = mob_class.get_staticdata_table (self)
	if supertable then
		supertable._tentacle_movement = nil
		supertable._tentacle_speed = nil
		supertable._squid_speed = nil
		supertable._rotate_speed = nil
		supertable._was_touching_water = false
		supertable._body_roll = nil
		supertable._stepheight_enabled = true
	end
	return supertable
end

local pow_by_step = mcl_mobs.pow_by_step

function squid:set_body_roll (roll)
	-- Squid must be rotated around their body bone, not the
	-- bottom of their collision box.
	if self.object.set_bone_override then
		self.object:set_bone_override ("root", {
			rotation = {
				vec = vector.new (math.pi / 2, 0, math.pi + roll),
				interpolate = 0.1,
				absolute = true,
			},
		})
	else
		local rot = vector.new (90, 0, 180 + math.deg (roll))
		self.object:set_bone_position ("root", nil, rot)
	end
	self._body_roll = roll
	return 0
end

function squid:motion_step (dtime, moveresult, self_pos)
	if self.stupefied then
		return
	end
	local movement = self._tentacle_movement
	local speed = self._tentacle_speed

	movement = movement + speed * (dtime / 0.05)

	if movement >= TWO_PI then
		movement = 0
		if pr:next (1, 10) == 1 or self._tentacle_speed == 0 then
			speed = random_anim_speed ()
		end

		local anim_speed = speed / TWO_PI
		self.object:set_animation ({
			x = 0,
			y = 40,
		}, 40 / anim_speed, 0, false)
	end

	local f = dtime / 0.05
	if core.get_item_group (self.standing_in, "water") > 0 then
		local progress = movement / math.pi
		local r_scale = dtime
		self._was_touching_water = true
		if progress < 1.0 then
			if progress > 0.75 then
				self._squid_speed = 1.0
				self._rotate_speed = 1.0
			else
				local f = pow_by_step (0.8, dtime)
				r_scale = (1 - f) / (1 - 0.8)
				self._rotate_speed
					= self._rotate_speed * f
			end
		else
			local f_speed = pow_by_step (0.9, dtime)
			local f_rotate = pow_by_step (0.99, dtime)
			r_scale = (1 - f_rotate) / (1 - 0.99)
			self._squid_speed
				= self._squid_speed * f_speed
			self._rotate_speed
				= self._rotate_speed * f_rotate
		end

		local d = self._propel_dir
		local new_v = {
			x = self._squid_speed * d.x * 20,
			y = self._squid_speed * d.y * 20,
			z = self._squid_speed * d.z * 20,
		}

		local v = self.object:get_velocity ()
		self:check_collision (self_pos, new_v, 1.0)
		self.object:set_velocity (new_v)

		-- Animate this mob according to the previous velocity
		-- (i.e. after collisions are processed).
		local xz = math.sqrt (v.x * v.x + v.z * v.z)
		local yaw = self:get_yaw ()
		local pitch = self:get_pitch ()
		local target_yaw
			= (math.atan2 (v.z, v.x) - math.pi / 2)
		local target_pitch
			= math.atan2 (v.y, xz)
		self:set_yaw (yaw + (target_yaw - yaw) * 0.1 * f)
		self:set_pitch (pitch + (target_pitch - pitch) * 0.1 * f)
		local roll = self._body_roll
		-- The value computed is a value in degrees, not
		-- radians, in which pi only serves as the number of
		-- degrees by which to rotate per rotation cycle.
		local target = roll + math.rad (math.pi * self._rotate_speed * 1.5 * r_scale)
		local norm = mcl_util.norm_radians (target)
		self:set_body_roll (norm)

		if self._stepheight_enabled then
			self.object:set_properties ({
					stepheight = 0.0,
			})
			self._stepheight_enabled = false
		end
	else
		self._was_touching_water = false

		local pitch = self:get_pitch ()
		self:set_pitch (pitch + (0 - pitch) * 0.02 * f)

		local v = self.object:get_velocity ()
		local p = pow_by_step (0.98, dtime)
		local v_scale = (1 - p) / (1 - 0.98)
		local new_y = v.y + self.fall_speed * v_scale * p
		v.x = 0
		v.y = new_y
		v.z = 0
		self:check_collision (self_pos, v, 1.0)
		self.object:set_velocity (v)

		if moveresult.touching_ground
			or moveresult.standing_on_object then
			if not self._stepheight_enabled then
				self.object:set_properties ({
					stepheight = 0.6,
				})
				self._stepheight_enabled = true
			end
		elseif self._stepheight_enabled then
			self.object:set_properties ({
				stepheight = 0,
			})
			self._stepheight_enabled = false
		end
	end

	self._tentacle_movement = movement
	self._tentacle_speed = speed
end

------------------------------------------------------------------------
-- Squid "AI".
------------------------------------------------------------------------

local scale_chance = mcl_mobs.scale_chance

local function squid_move_randomly (self, self_pos, dtime)
	if pr:next (1, scale_chance (50, dtime)) == 1
		or not self._was_touching_water
		or vector.length (self._propel_dir) == 0 then
		local r1 = pr:next (0, 2147483647) * r * TWO_PI
		local r2 = pr:next (0, 2147483647) * r
		local x = math.cos (r1) * 0.2
		local y = -0.1 + r2 * 0.2
		local z = math.sin (r1) * 0.2
		self._propel_dir = vector.new (x, y, z)
	end
	return false
end

local function is_airlike (nodepos)
	local name = core.get_node (nodepos).name
	local def = core.registered_nodes[name]
	return def and def.liquidtype == "none" and not def.walkable
end

local function squid_flee_attacker (self, self_pos, dtime)
	if self._fleeing_attacker then
		local attacker = self._recent_attacker
		if not attacker then
			self._fleeing_attacker = false
			return false
		end

		local flee_pos = attacker:get_pos ()
		local movement = vector.subtract (self_pos, flee_pos)
		local length = vector.length (movement)
		local propel_dir = movement
		local no_vertical = false

		if is_airlike (vector.add (self_pos, movement)) then
			no_vertical = true
		end

		local speed = 3.0
		if length > 5.0 then
			speed = speed - (length - 5.0) / 5.0
		end
		if speed > 0 then
			propel_dir = vector.multiply (movement, speed)
		end

		propel_dir.x = propel_dir.x / 20
		propel_dir.y = no_vertical and 0 or propel_dir.y / 20
		propel_dir.z = propel_dir.z / 20
		self._propel_dir = propel_dir
		return true
	elseif self._recent_attacker then
		self._fleeing_attacker = true
		return "_fleeing_attacker"
	end
	return false
end

squid.ai_functions = {
	squid_flee_attacker,
	squid_move_randomly,
}

mcl_mobs.register_mob ("mobs_mc:squid", squid)

------------------------------------------------------------------------
-- Glow Squid.
------------------------------------------------------------------------

local base_psdef = {
	amount = 8,
	time=0,
	minpos = vector.new (-1,-1,-1),
	maxpos = vector.new (1,1,1),
	minvel = vector.new (-0.25,-0.25,-0.25),
	maxvel = vector.new (0.25,0.25,0.25),
	minacc = vector.new (-0.5,-0.5,-0.5),
	maxacc = vector.new (0.5,0.5,0.5),
	minexptime = 1,
	maxexptime = 2,
	minsize = 0.8,
	maxsize= 1.5,
	glow = 5,
	collisiondetection = true,
	collision_removal = true,
}

local psdefs = {}

for i=1,4 do
	local p = table.copy(base_psdef)
	p.texture = "extra_mobs_glow_squid_glint"..i..".png"
	table.insert(psdefs,p)
end

local glow_squid = table.merge (squid, {
	description = S("Glow Squid"),
	_spawn_category = "underground_water_creature",
	textures = {
		{ "extra_mobs_glow_squid.png" }
	},
	drops = {
		{
			name = "mcl_mobitems:glow_ink_sac",
			chance = 1,
			min = 1,
			max = 3,
			looting = "common"
		}
	},
	glow = 14,
	particlespawners = psdefs,
	_extinguish_for = 0,
	_ink_jet_glow = 8,
	_ink_jet_textures = {
		{
			name = "mcl_particles_squid_ink.png^[colorize:#33e099:255",
			alpha_tween = {
				1,
				0,
			},
		},
		{
			name = "mcl_particles_squid_ink_1.png^[colorize:#33e099:255",
			alpha_tween = {
				1,
				0,
			},
		},
		{
			name = "mcl_particles_squid_ink_2.png^[colorize:#33e099:255",
			alpha_tween = {
				1,
				0,
			},
		},
	},
})

function glow_squid:receive_damage (mcl_reason, damage)
	if squid.receive_damage (self, mcl_reason, damage) then
		self:set_properties ({
			glow = 0,
		})
		self._extinguish_for = 5
	end
	return false
end

function glow_squid:ai_step (dtime)
	mob_class.ai_step (self, dtime)

	if self._extinguish_for > 0 then
		self._extinguish_for = self._extinguish_for - dtime

		if self._extinguish_for <= 0 then
			self:set_properties ({
				glow = core.LIGHT_MAX,
			})
		end
	end
end

mcl_mobs.register_mob ("mobs_mc:glow_squid", glow_squid)

------------------------------------------------------------------------
-- Squid & Glow Squid spawning.
------------------------------------------------------------------------

mcl_mobs.register_egg ("mobs_mc:squid", S("Squid"), "#223b4d", "#708999", 0)
mcl_mobs.register_egg ("mobs_mc:glow_squid", S("Glow Squid"), "#095757", "#87f6c0", 0)

------------------------------------------------------------------------
-- Modern Squid & Glow Squid spawning.
------------------------------------------------------------------------

local squid_spawner_frozen_ocean = table.merge (mobs_mc.aquatic_animal_spawner, {
	name = "mobs_mc:squid",
	spawn_category = "water_creature",
	biomes = {
		"FrozenOcean",
		"DeepFrozenOcean",
	},
	weight = 1,
	pack_min = 1,
	pack_max = 4,
})

local squid_spawner_cold_ocean = table.merge (squid_spawner_frozen_ocean, {
	biomes = {
		"ColdOcean",
		"DeepColdOcean",
	},
	weight = 3,
	pack_min = 1,
	pack_max = 4,
})

local squid_spawner_lukewarm_ocean = table.merge (squid_spawner_frozen_ocean, {
	biomes = {
		"LukewarmOcean",
	},
	weight = 10,
	pack_min = 1,
	pack_max = 2,
})

local squid_spawner_warm_ocean = table.merge (squid_spawner_frozen_ocean, {
	biomes = {
		"WarmOcean",
	},
	weight = 10,
	pack_min = 4,
	pack_max = 4,
})

local squid_spawner_deep_lukewarm_ocean = table.merge (squid_spawner_frozen_ocean, {
	biomes = {
		"DeepLukewarmOcean",
	},
	weight = 8,
	pack_min = 1,
	pack_max = 4,
})

local squid_spawner_ocean = table.merge (squid_spawner_frozen_ocean, {
	biomes = {
		"Ocean",
		"DeepOcean",
	},
	weight = 1,
	pack_min = 1,
	pack_max = 4,
})

local squid_spawner_river = table.merge (squid_spawner_frozen_ocean, {
	biomes = {
		"River",
		"FrozenRiver",
	},
	weight = 2,
	pack_min = 1,
	pack_max = 4,
})

mcl_mobs.register_spawner (squid_spawner_frozen_ocean)
mcl_mobs.register_spawner (squid_spawner_cold_ocean)
mcl_mobs.register_spawner (squid_spawner_lukewarm_ocean)
mcl_mobs.register_spawner (squid_spawner_warm_ocean)
mcl_mobs.register_spawner (squid_spawner_deep_lukewarm_ocean)
mcl_mobs.register_spawner (squid_spawner_ocean)
mcl_mobs.register_spawner (squid_spawner_river)

local default_spawner = mcl_mobs.default_spawner

local glow_squid_spawner = {
	name = "mobs_mc:glow_squid",
	spawn_category = "underground_water_creature",
	spawn_placement = "aquatic",
	weight = 10,
	pack_max = 6,
	pack_min = 4,
	biomes = mobs_mc.overworld_biomes,
}

function glow_squid_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache,
						 spawn_flag)
	if spawn_pos.y > -32.5 then
		return false
	end

	local light = core.get_node_light (node_pos)

	if light == 0 then
		if default_spawner.test_spawn_position (self, spawn_pos,
							node_pos, sdata,
							node_cache,
							spawn_flag) then
			return true
		end
	end
	return false
end

function glow_squid_spawner:describe_additional_spawning_criteria ()
	return S ("Glow Squid only spawn in absolute darkness at Y levels of 33 or below.")
end

mcl_mobs.register_spawner (glow_squid_spawner)
