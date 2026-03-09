--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

--###################
--################### VEX
--###################

local vex = {
	description = S("Vex"),
	type = "monster",
	_spawn_category = "monster",
	attack_type = "null",
	physical = false,
	hp_min = 14,
	hp_max = 14,
	xp_min = 6,
	xp_max = 6,
	head_eye_height = 0.51875,
	bone_eye_height = 2.39532,
	head_swivel = "head",
	collisionbox = {-0.2, 0.0, -0.2, 0.2, 0.8, 0.2},
	visual = "mesh",
	mesh = "mobs_mc_vex.b3d",
	textures = {
		{
			"mobs_mc_vex.png",
		},
	},
	visual_size = {
		x = 1.0,
		y = 1.25,
	},
	damage = 4,
	reach = 0.5,
	movement_speed = 14,
	sounds = {
		death = "mobs_mc_vex_death",
		damage = "mobs_mc_vex_hurt",
		distance = 16,
	},
	animation = {
		stand_speed = 25,
		stand_start = 0,
		stand_end = 40,
	},
	fly = true,
	makes_footstep_sound = false,
	can_wield_items = "no_pickup",
	wielditem_drop_probability = 0.0,
	wielditem_info = {
		toollike_position = vector.new (0, 1.8, -1.2),
		toollike_rotation = vector.new (-90, 45, -90),
		bow_position = vector.new (0, 1.8, 0),
		bow_rotation = vector.new (-90, 45, -90),
		crossbow_position = vector.new (0, 2.0, -0.44),
		crossbow_rotation = vector.new (0, 0, -45),
		blocklike_position = vector.new (0, 1.8, -0.5),
		blocklike_rotation = vector.new (0, 45, 180),
		position = vector.new (0.2, 1.8, -0.7),
		rotation = vector.new (90, 0, 0),
		bone = "wield_item",
		rotate_bone = true,
	},
	suffocation = false,
	-- Yes, vexes really ascend in water.
	floats = 1,
}

------------------------------------------------------------------------
-- Vex visuals.
------------------------------------------------------------------------

function vex:do_custom (dtime)
	-- Glow red while attacking
	if self.attack then
		if self._active_texture_list[1] ~= "mobs_mc_vex_charging.png" then
			self:set_textures ({
				"mobs_mc_vex_charging.png",
			})
		end
	else
		if self._active_texture_list[1] == "mobs_mc_vex_charging.png" then
			self:set_textures ({
				"mobs_mc_vex.png"
			})
		end
	end
end

function vex:wielditem_transform (info, stack)
	local rot, pos, size
		= mob_class.wielditem_transform (self, info, stack)

	size.x = size.x / 3
	size.y = size.y / 3
	return rot, pos, size
end

------------------------------------------------------------------------
-- Vex mechanics.
------------------------------------------------------------------------

local pr = PcgRandom (os.time () - 30)

function vex:on_spawn ()
	local self_pos = self.object:get_pos ()
	local mob_factor = mcl_worlds.get_special_difficulty (self_pos)
	self:set_wielditem (ItemStack ("mcl_tools:sword_iron"))
	self:enchant_default_weapon (mob_factor, pr)
end

------------------------------------------------------------------------
-- Vex movement.
------------------------------------------------------------------------

-- Vexes do not sustain environmental damage from any source, whether
-- lava, drowning, or suffocation.

function vex:do_env_damage ()
	return false
end

local AIR_FRICTION = mcl_mobs.AIR_FRICTION
local AIR_FRICTION_Y = 0.98
local pow_by_step = mcl_mobs.pow_by_step

function vex:motion_step (dtime, moveresult, self_pos)
	if not moveresult then
		return
	end
	local v = self.object:get_velocity ()
	local p, f

	p = pow_by_step (AIR_FRICTION, dtime)
	f = pow_by_step (AIR_FRICTION_Y, dtime)

	v.x = v.x * p
	v.y = v.y * f
	v.z = v.z * p
	self.object:set_velocity (v)
end

function vex:do_go_pos (dtime, moveresult)
	local self_pos = self.object:get_pos ()
	local target = self.movement_target or vector.zero ()
	local d = vector.distance (target, self_pos)

	local v = self.object:get_velocity ()
	if d <= 0.5 then
		self.object:set_velocity (vector.multiply (v, 0.5))
		self.movement_goal = nil
	else
		local modifier = self.movement_velocity
			/ self.movement_speed
		local dir = vector.direction (self_pos, target)
		local p = pow_by_step (AIR_FRICTION, dtime)
		local h_scale = (1 - p) / (1 - AIR_FRICTION)
		local f = pow_by_step (AIR_FRICTION_Y, dtime)
		local v_scale = (1 - f) / (1 - AIR_FRICTION_Y)
		local scale = vector.new (h_scale, v_scale, h_scale)
		local fv = vector.multiply (dir, vector.multiply (scale, modifier))
		self.object:add_velocity (fv)

		if self.attack and is_valid (self.attack) then
			self:look_at (self.attack:get_pos ())
		else
			local v = vector.add (fv, v)
			local yaw = math.atan2 (v.z, v.x) - math.pi / 2
			self:set_yaw (yaw)
		end
	end
end

------------------------------------------------------------------------
-- Vex AI.
------------------------------------------------------------------------

local pr = PcgRandom (os.time () + 40)

function vex:attack_null (self_pos, dtime, target_pos, line_of_sight)
	local target = self.attack
	local eye_pos = mcl_util.target_eye_pos (target)

	if not self.attacking then
		self.attacking = true
		self:go_to_stupidly (eye_pos, 1.0)
	end

	local d = vector.distance (self_pos, eye_pos)
	if d <= self.reach then
		self:custom_attack ()
		self.attack = nil
		self:attack_end ()
		return
	end

	self:go_to_stupidly (eye_pos, 1.0)
end

function vex:ai_step (dtime)
	mob_class.ai_step (self, dtime)

	if self._summoned_by and not is_valid (self._summoned_by) then
		self._summoned_by = nil
	end

	-- Take constant damage if the vex' life clock ran out
	-- (only for vexes summoned by evokers)
	if self._summoned then
		if not self._lifetimer then
			self._lifetimer = (20 * (30 + math.random (90))) / 20
		end
		self._lifetimer = self._lifetimer - dtime
		if self._lifetimer <= 0 then
			if self._damagetimer then
				self._damagetimer = self._damagetimer - 1
			end
			self:damage_mob ("starve", 1)
			self._damagetimer = 1
		end
	end
end

local function is_clear (node)
	local node = core.get_node (node)
	local def = core.registered_nodes[node.name]
	return def and not def.walkable and def.liquidtype == "none"
end

function vex:get_pace_pos (self_pos)
	local basis = self._restriction_center
		or mcl_util.get_nodepos (self_pos)

	for i = 1, 3 do
		local x = basis.x + pr:next (-7, 7)
		local y = basis.y + pr:next (-5, 5)
		local z = basis.z + pr:next (-7, 7)
		local node = vector.new (x, y, z)

		if is_clear (node) then
			node.y = node.y - 0.5
			return node
		end
	end
	return nil
end

local scale_chance = mcl_mobs.scale_chance

local function vex_pace (self, self_pos, dtime)
	local rc = false
	if self._vex_pacing then
		if self:navigation_finished () then
			self._vex_pacing = false
			return false
		end

		return true
	end

	self._did_check = not self._did_check
	local frequency = scale_chance (4, dtime)
	if self._did_check and pr:next (1, frequency) == 1 then
		local pos = self:get_pace_pos (self_pos)
		if pos then
			self:go_to_stupidly (pos, 0.25)
			if not rc then
				self._vex_pacing = true
				rc = "_vex_pacing"
			end
		end
	end
	return rc
end

vex.ai_functions = {
	mob_class.check_attack,
	vex_pace,
}

local function vex_adopt_owner_target (self, self_pos, dtime, obj, is_current)
	if is_current then
		local dist = self.tracking_distance * self.tracking_distance
		return self:track_current_target (self_pos, dtime, obj, dist, nil)
	elseif self._summoned_by and self._summoned_by:is_valid () then
		local entity = self._summoned_by:get_luaentity ()
		local target = entity._active_target
		local pos = target and target:get_pos ()
		if pos
			and self:test_object_and_restriction (target, pos)
			and vector.distance (self_pos, pos) < self.view_range then
			return target
		end
	end

	return nil
end

vex._targeting_rules = {
	mcl_mobs.build_retaliation_target_rule (mobs_mc.raid_mob_predicate,
						true, {"mobs_mc:vex",}),
	mcl_mobs.build_target_rule ({
		fn = vex_adopt_owner_target,
		on_complete = nil,
	}),
	mcl_mobs.build_nearest_target_rule ("player", nil, nil, nil, nil),
	mcl_mobs.build_alert_receiver_rule (),
}

mcl_mobs.register_mob ("mobs_mc:vex", vex)

------------------------------------------------------------------------
-- Vex spawning.
------------------------------------------------------------------------

-- spawn eggs
mcl_mobs.register_egg ("mobs_mc:vex", S("Vex"), "#7a90a4", "#e8edf1", 0)
