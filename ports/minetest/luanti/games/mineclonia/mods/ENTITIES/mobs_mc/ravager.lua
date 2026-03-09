local S = core.get_translator ("mobs_mc")
local mob_class = mcl_mobs.mob_class
local raid_mob = mobs_mc.raid_mob

local ipairs = ipairs

------------------------------------------------------------------------
-- Ravager.
-- TODO:
-- [X] Pathfinding rules.
-- [X] Animations & particle effects.
-- [X] Roar attacks and additional knockback.
-- [X] Mounting.
-- [X] Drops.
-- [X] Raid spawning.
------------------------------------------------------------------------

local ravager = table.merge (raid_mob, {
	description = S ("Ravager"),
	type = "monster",
	_spawn_category = "monster",
	hp_min = 100,
	hp_max = 100,
	xp_min = 20,
	xp_max = 20,
	visual = "mesh",
	mesh = "mobs_mc_ravager.b3d",
	textures = {
		{
			"mobs_mc_ravager.png",
		},
	},
	collisionbox = {
		-0.975, 0, -0.975,
		0.975, 2.2, 0.975,
	},
	sounds = {},
	movement_speed = 6.0,
	knockback_resistance = 0.75,
	damage = 12.0,
	attack_type = "melee",
	_attack_knockback = 1.5,
	view_range = 32,
	tracking_distance = 32,
	stepheight = 1.02,
	can_ride_boat = false,
	reach = 2.0,
	pace_bonus = 0.4,
	animation = {
		stand_start = 0,
		stand_end = 0,
		walk_start = 20,
		walk_end = 40,
		walk_speed = 20,
	},
	drops = {
		{
			name = "mcl_mobitems:saddle",
			chance = 1,
			min = 1,
			max = 1,
		},
	},

	-- Patrolling mob parameters.
	_can_serve_as_captain = false,

	-- Ravager parameters.
	_roar_time = 0,
	_attack_time = 0,
	_stunned_time = 0,
})

------------------------------------------------------------------------
-- Ravager visuals.
------------------------------------------------------------------------

local HEAD_BONE_OVERRIDE = {
	rotation = {
		vec = vector.new (),
		interpolation = 0.1,
	},
	position = {
		vec = vector.new (),
		interpolation = 0,
	},
}

local mathatan2 = math.atan2
local mathsqrt = math.sqrt

local NINETY_DEG = math.pi / 2
local SEVENTY_DEG = math.rad (70)
local norm_radians = mcl_util.norm_radians
local mathmax = math.max
local mathmin = math.min
local mathabs = math.abs
local mathsin = math.sin

local TICKS_PER_SEC = 20
local mathpow = math.pow

local function lerp1d_scaled (u, dtime, s1, s2)
	local x = dtime * TICKS_PER_SEC
	local v = -(s2 * mathpow (1 - u, x))
		+ s1 * mathpow (1 - u, x) + s2
	return v
end

local function lerp_rotation_scaled (u, dtime, s1, s2)
	local diff = norm_radians (s2 - s1)
	local s = lerp1d_scaled (u, dtime, s1, s1 + diff)
	return norm_radians (s)
end

function ravager:check_head_swivel (self_pos, dtime, clear)
	if clear then
		self._locked_object = nil
	else
		self:who_are_you_looking_at ()
	end

	local object = self._locked_object
	local tbl = HEAD_BONE_OVERRIDE
	local zrot
	local xrot

	if not object or not object:is_valid ()
		or object:get_hp () == 0 then
		zrot = 0
		xrot = 0
	else
		local pos = mcl_util.target_eye_pos (object)
		local dx = pos.x - self_pos.x
		local dz = pos.z - self_pos.z
		local dy = pos.y - self_pos.y
		local yaw = mathatan2 (dz, dx)
			- NINETY_DEG - self:get_yaw ()
		local yaw = norm_radians (-yaw)
		local pitch = mathatan2 (dy, mathsqrt (dx * dx + dz * dz))
		if mathabs (yaw) > NINETY_DEG then
			zrot = 0
			xrot = 0
		else
			xrot = mathmin (mathmax (pitch * 0.5, -SEVENTY_DEG), SEVENTY_DEG)
			zrot = mathmin (mathmax (yaw, -SEVENTY_DEG), SEVENTY_DEG)
		end
	end
	local last_z = self._ravager_zrot or zrot
	local last_x = self._ravager_xrot or xrot
	xrot = lerp_rotation_scaled (0.2, dtime, last_x, xrot)
	zrot = lerp_rotation_scaled (0.2, dtime, last_z, zrot)
	tbl.rotation.vec.z = zrot
	tbl.rotation.vec.x = xrot
	if self:animate_head (tbl)
		or self._ravager_zrot ~= zrot
		or self._ravager_xrot ~= xrot then
		self._ravager_zrot = zrot
		self._ravager_xrot = xrot
		self.object:set_bone_override ("head", tbl)
	end
end

function ravager:get_staticdata_table ()
	local tbl = mob_class.get_staticdata_table (self)
	if tbl then
		tbl._ravager_zrot = nil
		tbl._ravager_yrot = nil
	end
	return tbl
end

function ravager:ravager_fumes ()
	core.add_particlespawner ({
		amount = 20,
		time = 2.0,
		size = 1.4,
		texture = "mcl_particles_effect.png^[colorize:#a9a9a9:255",
		pos = {
			min = vector.new (-1.0, -2.0, -1.0),
			max = vector.new (1.0, 2.0, 1.0),
		},
		vel = {
			min = vector.new (-0.8, 0.8, -0.8),
			max = vector.new (0.8, 1.2, 0.8),
		},
		exptime = {
			min = 3.0,
			max = 3.0,
		},
		attached = self.object,
	})
end

function ravager:ravager_explosion ()
	core.add_particlespawner ({
		amount = 32,
		time = 0.1,
		size = {
			min = 1.2,
			max = 2.0,
		},
		texture = "mcl_particles_mob_death.png^[colorize:#c5c5c5c5:255",
		pos = {
			min = vector.new (-2, 0, -2),
			max = vector.new (2, 0, 2),
		},
		vel = {
			min = vector.new (-4.0, -4.0, -4.0),
			max = vector.new (4.0, 4.0, 4.0),
		},
		exptime = {
			min = 2.0,
			max = 2.0,
		},
		attached = self.object,
	})
end

local THIRTY_DEG = math.rad (30)

local RAVAGER_MOUTH_OPEN_OVERRIDE = {
	rotation = {
		vec = vector.new (-THIRTY_DEG, 0, 0),
		interpolation = 0.25,
	}
}
local RAVAGER_MOUTH_DEFAULT_OVERRIDE = {
	rotation = {
		vec = vector.zero (),
		interpolation = 0.25,
	},
}

function ravager:animate_bite ()
	self.object:set_bone_override ("mouth", RAVAGER_MOUTH_OPEN_OVERRIDE)
end

function ravager:animate_mouth (dtime)
	if self._attack_time >= 0.25
		and self._attack_time - dtime < 0.25 then
		self.object:set_bone_override ("mouth", RAVAGER_MOUTH_DEFAULT_OVERRIDE)
	end
end

local pi = math.pi

function ravager:animate_head (transform)
	if self._stunned_time > 0.0 then
		local t = mathmin (2.0, 2.0 - self._stunned_time)
		local x_pos = mathsin (t * pi)
		transform.rotation.vec.z = 0.0
		transform.rotation.vec.x = -THIRTY_DEG
		transform.position.vec.x = x_pos * 3.0
		return true
	else
		transform.position.vec.x = 0.0
		return false
	end
end

------------------------------------------------------------------------
-- Ravager AI.
------------------------------------------------------------------------

local floor = math.floor

function ravager:ravager_no_movement ()
	return self._roar_time > 0
		or self._attack_time > 0
		or self._stunned_time > 0
end

function ravager:ravager_knockback (self_pos, object)
	local pos = object:get_pos ()
	local dx = pos.x - self_pos.x
	local dz = pos.z - self_pos.z
	if mcl_util.object_has_mc_physics (object) then
		local d_sqr = mathmax (dx * dx + dz * dz, 0.001)
		local v = vector.new (dx / d_sqr * 80.0, 4.0,
				      dz / d_sqr * 80.0)
		object:add_velocity (v)
	else
		local d = mathsqrt (dx * dx + dz * dz)
		local v = vector.new (dx / d * 10.0, 4.0,
				      dz / d * 10.0)
		object:add_velocity (v)
	end
end

function ravager:ravager_attack ()
	local self_pos = self.object:get_pos ()
	local v1 = vector.new (self.collisionbox[1] - 4.0 + self_pos.x,
			       self.collisionbox[2] - 4.0 + self_pos.y,
			       self.collisionbox[3] - 4.0 + self_pos.z)
	local v2 = vector.new (self.collisionbox[4] + 4.0 + self_pos.x,
			       self.collisionbox[5] + 4.0 + self_pos.y,
			       self.collisionbox[6] + 4.0 + self_pos.z)
	for object in core.objects_in_area (v1, v2) do
		local entity = object:get_luaentity ()
		local is_alive = false

		if (entity and entity ~= self and entity.is_mob)
			or object:is_player () then
			is_alive = true
			if not entity or not entity._is_illager then
				local mcl_reason = {
					type = "mob",
					direct = self.object,
				}
				mcl_damage.finish_reason (mcl_reason)
				mcl_util.deal_damage (object, 6.0, mcl_reason)
			end
		end

		if is_alive
		-- The object may have been deleted.
			and object:is_valid () then
			self:ravager_knockback (self_pos, object)
		end
	end

	self:ravager_explosion ()
end

function ravager:ai_step (dtime)
	raid_mob.ai_step (self, dtime)
	if self.dead then
		return
	end

	if self:ravager_no_movement () then
		-- Velocity rescaling can't adapt to a movement_speed
		-- of 0.
		self:set_physics_factor_base ("movement_speed", 0.001)
	else
		local target = self.attack and 7.0 or 6.0
		local speed = self:stock_value ("movement_speed")
		local value = lerp1d_scaled (0.1, dtime, speed, target)
		self:set_physics_factor_base ("movement_speed", value)
	end

	self:animate_mouth (dtime)
	if self._roar_time > 0 then
		local t = self._roar_time
		self._roar_time = self._roar_time - dtime
		if t >= 0.5 and t - dtime < 0.5 then
			self:ravager_attack ()
		end
	end
	if self._attack_time > 0 then
		self._attack_time = self._attack_time - dtime
	end
	if self._stunned_time > 0 then
		self._stunned_time = self._stunned_time - dtime
		if self._stunned_time < 0 then
			self._roar_time = 1.0
		end
	end
end

local mathsqrt = math.sqrt

function ravager:shield_impact (object, mcl_reason)
	if self._roar_time <= 0 then
		if math.random (2) == 1 then
			self._stunned_time = 2.0
			self:ravager_fumes ()
			local pos = object:get_pos ()
			local self_pos = self.object:get_pos ()
			if pos then
				local dir = vector.direction (pos, self_pos)
				local dist = vector.distance (pos, self_pos)
				local v = vector.multiply (dir, 10.0 / mathsqrt (dist))
				self.object:add_velocity (v)
			end
		else
			local self_pos = self.object:get_pos ()
			-- Otherwise the default knockback is more
			-- than adequate to repulse the player.
			if mcl_util.object_has_mc_physics (object) then
				self:ravager_knockback (self_pos, object)
			end
		end
	end
end

function ravager:pre_melee_attack (distance, delay, line_of_sight)
	return self._stunned_time <= 0
		and self._roar_time <= 0
		and mob_class.pre_melee_attack (self, distance, delay,
						line_of_sight)
end

function ravager:custom_attack ()
	mob_class.custom_attack (self)
	self._attack_time = 0.5
	self:animate_bite ()
end

ravager.ai_functions = {
	mob_class.check_attack,
	raid_mob.check_pathfind_to_raid,
	raid_mob.check_navigate_village,
	raid_mob.check_distant_patrol,
	raid_mob.check_celebrate,
	mob_class.check_pace,
}

local function adult_villager_p (self, self_pos, obj, entity)
	return entity
		and (entity.name == "mobs_mc:villager"
		     or entity.name == "mobs_mc:wandering_trader")
		and not entity.child
end

ravager._targeting_rules = {
	mcl_mobs.build_retaliation_target_rule (mobs_mc.raid_mob_predicate, true, {
		"mobs_mc:ravager",
	}),
	mcl_mobs.build_nearest_target_rule ("player", nil, nil, nil, nil),
	mcl_mobs.build_nearest_target_rule ("mobs_mc:villager", adult_villager_p,
					    nil, nil, nil),
	mcl_mobs.build_nearest_target_rule ("mobs_mc:iron_golem", {
		"mobs_mc:iron_golem",
	}, nil, nil, nil),
	mcl_mobs.build_alert_receiver_rule (),
}

------------------------------------------------------------------------
-- Ravager pathfinding & navigation.
------------------------------------------------------------------------

ravager.gwp_penalties = table.merge (mob_class.gwp_penalties, {
	LEAVES_SURFACE = 0.0,
	LEAVES = 0.0,
})

ravager.gwp_floortypes = table.merge (mob_class.gwp_floortypes, {
	LEAVES = "LEAVES_SURFACE",
})

local function any_horiz_collision (moveresult)
	for _, item in ipairs (moveresult.collisions) do
		if item.axis == "x" or item.axis == "z" then
			-- Exclude ignore nodes from collision detection.
			if item.type == "node"
				and core.get_node_or_nil (item.node_pos) then
				return true
			end
		end
	end
	return false
end

local LEAVES = {
	"group:leaves",
}

function ravager:destroy_colliding_leaves ()
	local cbox = self.collisionbox
	local self_pos = self.object:get_pos ()
	local v1 = vector.new (floor (cbox[1] - 0.2 + self_pos.x + 0.5),
			       floor (cbox[2] - 0.2 + self_pos.y + 0.5),
			       floor (cbox[3] - 0.2 + self_pos.z + 0.5))
	local v2 = vector.new (floor (cbox[4] + 0.2 + self_pos.x + 0.5),
			       floor (cbox[5] + 1.5 + self_pos.y + 0.5),
			       floor (cbox[6] + 0.2 + self_pos.z + 0.5))
	local any_dug = false
	for _, pos in ipairs (core.find_nodes_in_area (v1, v2, LEAVES)) do
		if not core.is_protected (pos, "") then
			core.dig_node (pos, self.object)
			any_dug = true
		end
	end

	return any_dug
end

function ravager:movement_step (dtime, moveresult)
	if self:ravager_no_movement () then
		self:halt_in_tracks (nil, true)
		return
	end
	if not self.dead
	-- If there is a horizontal collision...
		and any_horiz_collision (moveresult)
	-- ... don't process movement for another step, in order to
	-- decide whether the deletion of the leaves has sufficed to
	-- eliminate the obstruction.
		and self:destroy_colliding_leaves () then
		return
	end
	mob_class.movement_step (self, dtime, moveresult)
end

function ravager:gwp_initialize (targets, range, tolerance, penalties)
	local context = mob_class.gwp_initialize (self, targets, range,
						  tolerance, penalties)
	if context then
		-- Offset positions of all nodes so that they reside
		-- within their centers, to prevent ravagers from
		-- spinning endlessly if they find themselves above
		-- leaves which have been ignored by the pathfinder.
		context.y_offset = 0
		return context
	end
	return nil
end

------------------------------------------------------------------------
-- Ravager spawning.
------------------------------------------------------------------------

mcl_mobs.register_mob ("mobs_mc:ravager", ravager)

-- Spawn eggs.
mcl_mobs.register_egg ("mobs_mc:ravager", S ("Ravager"), "#757470", "#5b5049")

------------------------------------------------------------------------
-- Modern Ravager spawning.
------------------------------------------------------------------------

