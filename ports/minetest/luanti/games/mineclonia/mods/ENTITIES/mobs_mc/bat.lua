--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class

local bat = {
	description = S("Bat"),
	type = "animal",
	_spawn_category = "ambient",
	can_despawn = true,
	hp_min = 6,
	hp_max = 6,
	head_eye_height = 0.45,
	collisionbox = {-0.25, 0.0, -0.25, 0.25, 0.89, 0.25},
	visual = "mesh",
	mesh = "mobs_mc_bat.b3d",
	textures = {
		{"mobs_mc_bat.png"},
	},
	sounds = {
		random = "mobs_mc_bat_idle",
		damage = "mobs_mc_bat_hurt",
		death = "mobs_mc_bat_death",
		distance = 16,
	},
	movement_speed = 14.0,
	animation = {
		stand_speed = 60,
		stand_start = 0,
		stand_end = 40,
		hang_start = 60,
		hang_end = 60,
		hang_speed = 1,
	},
	fall_damage = 0,
	fly = true,
	makes_footstep_sound = false,
	can_ride_cart = false,
	can_ride_boat = false,
	gravity_drag = 0.6,
	_apply_gravity_drag_on_ground = true,
	pushable = false,
}

------------------------------------------------------------------------
-- Bat movement and "AI".
------------------------------------------------------------------------

local function is_opaque_solid (node)
	local node = core.get_node (node)
	local def = core.registered_nodes[node.name]
	return def and def.groups.opaque and def.groups.solid
end

local function is_walkable (node)
	local node = core.get_node (node)
	local def = core.registered_nodes[node.name]
	return def and def.walkable
end

local function signum (number)
	return (number == -0.0 or number < 0) and -1
		or (number == 0.0 and 0.0 or 1)
end

local scale_chance = mcl_mobs.scale_chance

function bat:motion_step (dtime, moveresult, self_pos)
	local h_scale, v_scale
		= mob_class.motion_step (self, dtime, moveresult, self_pos)
	local old_y = self_pos.y
	local abovepos = {
		x = math.floor (self_pos.x + 0.5),
		y = math.floor (self_pos.y + 0.5) + 1,
		z = math.floor (self_pos.z + 0.5),
	}

	if self._resting then
		-- Verify that the block above is still walkable and
		-- whole.
		if not is_opaque_solid (abovepos) then
			self._resting = false
			self:set_animation ("stand")
		else
			-- Be startled off by players wihin 4 nodes.
			for player in mcl_util.connected_players (self_pos, 4) do
				self._resting = false
				self:set_animation ("stand")
				break
			end
		end

		if self._resting then
			self:set_animation ("hang")
			self.object:set_pos ({
					x = self_pos.x,
					y = abovepos.y - 0.5 - 0.9,
					z = self_pos.z,
			})
			self.object:set_velocity (vector.zero ())
			-- Rotate randomly.
			if math.random (scale_chance (200, dtime)) == 1 then
				self:set_yaw (math.random () * math.pi * 2)
			end
			return
		end
	end

	self_pos.y = self_pos.y + (self.collisionbox[5] - self.collisionbox[2]) / 2
	-- Bats feature no true AI and simply float aimlessly,
	-- applying input directly to their velocity.
	local target_pos = self._target_pos

	if not target_pos
		or is_walkable (target_pos)
		or math.random (scale_chance (30, dtime)) == 1
		or vector.distance (self_pos, target_pos) <= 2.0 then
		-- Switch target positions.
		local x = math.random (0, 6) - math.random (0, 6)
		local z = math.random (0, 6) - math.random (0, 6)
		local y = math.random (0, 5) - 2.0
		self_pos.y = old_y
		target_pos = vector.offset (self_pos, x, y, z)
		target_pos.x = math.floor (target_pos.x + 0.5)
		target_pos.y = math.floor (target_pos.y)
		target_pos.z = math.floor (target_pos.z + 0.5)
	end

	self_pos.y = old_y
	self._target_pos = target_pos
	local v = self.object:get_velocity ()
	local dx = target_pos.x + 0.5 - self_pos.x
	local dy = target_pos.y + 0.1 - self_pos.y
	local dz = target_pos.z + 0.5 - self_pos.z
	local x_mod = (signum (dx) * 10 - v.x) * 0.1 * h_scale
	local y_mod = (signum (dy) * 14 - v.y) * 0.1 * v_scale
	local z_mod = (signum (dz) * 10 - v.z) * 0.1 * h_scale
	v.x = v.x + x_mod
	v.y = v.y + y_mod
	v.z = v.z + z_mod
	self.object:set_velocity (v)
	local yaw = math.atan2 (v.z, v.x) - math.pi / 2
	self:set_yaw (yaw)

	if math.random (scale_chance (100, dtime)) == 1
		and is_opaque_solid (abovepos) then
		self._resting = true
	end
	return
end

function bat:run_ai (dtime, moveresult)
	return
end

mcl_mobs.register_mob ("mobs_mc:bat", bat)

------------------------------------------------------------------------
-- Bat spawning.
------------------------------------------------------------------------

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:bat", S("Bat"), "#4c3e30", "#0f0f0f", 0)

------------------------------------------------------------------------
-- Modern Bat spawning.
------------------------------------------------------------------------

local default_spawner = mcl_mobs.default_spawner

local bat_spawner = {
	name = "mobs_mc:bat",
	spawn_category = "ambient",
	spawn_placement = "ground",
	pack_min = 8,
	pack_max = 8,
	weight = 10,
	biomes = mobs_mc.overworld_biomes,
}

function bat_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache,
					  spawn_flag)
	if spawn_pos.y < 0 then
		local eligible
			= default_spawner.test_spawn_position (self, spawn_pos, node_pos,
							       sdata, node_cache,
							       spawn_flag)

		if eligible then
			local light = core.get_node_light (node_pos)
			local maxlight = 3

			if mcl_util.is_halloween_week () then
				maxlight = 6
			end

			return light <= maxlight
				and not mcl_weather.can_see_outdoors (node_pos)
		end
	end
	return false
end

function bat:describe_additional_spawning_criteria ()
	return S ("Spawning will only be successful between light levels of 0 and 3 at most times of the year, or 0 and 6 between 20 October and 3 November.")
end

mcl_mobs.register_spawner (bat_spawner)
