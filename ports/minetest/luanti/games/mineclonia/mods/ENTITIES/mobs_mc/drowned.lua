local S = core.get_translator ("mobs_mc")
local mob_class = mcl_mobs.mob_class
local posing_humanoid = mcl_mobs.posing_humanoid
local zombie = mobs_mc.zombie

------------------------------------------------------------------------
-- Drowned.
-- TODO:
--  [X] Wielditem and pose testing.
--  [X] Physics and pathfinding.
--  [X] AI.
--  [X] Item pickup.
--  [X] Baby Drowned.
--  [X] Conversion.
--  [X] Spawning.
--  [X] Introduce references where required in other files.
------------------------------------------------------------------------

local formspec_escapes = {
	["\\"] = "\\\\",
	["^"] = "\\^",
	[":"] = "\\:",
}

local function modifier_escape (text)
	return string.gsub (text, "[\\^:]", formspec_escapes)
end

local drowned = table.merge (zombie, {
	description = S ("Drowned"),
	gwp_penalties = table.merge (mob_class.gwp_penalties, {
		WATER = 0.0,
	}),
	head_eye_height = 1.74,
	bone_eye_height = 6.0784,
	visual = "mesh",
	mesh = "mobs_mc_drowned.b3d",
	head_swivel = "head",
	visual_size = {
		x = 1,
		y = 1,
	},
	textures = {
		{
			"mobs_mc_drowned.png",
			"mobs_mc_drowned_overlay.png",
			"blank.png", -- Armor layer 1.
			"blank.png", -- Armor layer 2.
		},
	},
	_armor_texture_slots = {
		[3] = {
			"head",
			"torso",
			"feet",
		},
		[4] = {
			"legs",
		},
	},
	_armor_transforms = {
		head = function (texture)
			return table.concat ({
				"[combine:64x32:-32,0=",
				"(",
				modifier_escape (texture),
				")",
			})
		end,
	},
	_head_armor_bone = "head",
	_head_armor_position = vector.new (0, 8, 0),
	_head_armor_visual_scale = 2.0,
	wielditem_info = {
		toollike_position = vector.new (0, 5.0, 0),
		toollike_rotation = vector.new (0, 0, 45),
		bow_position = vector.new (0, 0, 0),
		bow_rotation = vector.new (0, 0, -135),
		crossbow_position = vector.new (0, 2.35, 0),
		crossbow_rotation = vector.new (-90, 45, 180),
		blocklike_position = vector.new (0, 4.0, 0),
		blocklike_rotation = vector.new (-5, -45, -97),
		trident_position = vector.new (0, 3.5, 0),
		trident_rotation = vector.new (0, 90, 0),
		position = vector.new (0, 3.5, 0),
		rotation = vector.new (0, 90, 0),
		-- FIXME: the bones are not properly named in the
		-- model.
		bone = "offhand_item",
	},
	_offhand_wielditem_info = {
		toollike_position = vector.new (0, 5.0, 0),
		toollike_rotation = vector.new (0, 0, 45),
		bow_position = vector.new (0, 0, 0),
		bow_rotation = vector.new (0, 0, -135),
		crossbow_position = vector.new (0, 2.35, 0),
		crossbow_rotation = vector.new (-90, 45, 180),
		blocklike_position = vector.new (0, 4.0, 0),
		blocklike_rotation = vector.new (-5, -45, -97),
		trident_position = vector.new (0, 3.5, 0),
		trident_rotation = vector.new (0, 90, 0),
		position = vector.new (0, 3.5, 0),
		rotation = vector.new (0, 90, 0),
		bone = "wielditem",
	},
	animation = {
		stand_start = 0,
		stand_end = 60,
		stand_speed = 10,
		walk_start = 80,
		walk_end = 140,
		walk_speed = 15,
		swim_start = 150,
		swim_end = 180,
		swim_speed = 10,
	},
	makes_footstep_sound = true,
	frame_speed_multiplier = 0.6,
	drops = {
		{
			name = "mcl_mobitems:rotten_flesh",
			chance = 1,
			min = 0,
			max = 2,
			looting = "common",
		},
		{
			name = "mcl_copper:copper_ingot",
			chance = 100 / 11,
			min = 1,
			max = 1,
			looting = "rare",
			looting_factor = 0.02,
		},
	},
	head_pitch_multiplier = -1,
	_swimming = false,
	_swim_up = false,
	_swims_specially = true,
	stepheight = 1.01,
	ranged_interval_min = 2.0,
	ranged_interval_max = 2.0,
	ranged_attack_radius = 10.0,
	-- Drowned are capable of surfacing by day and catching fire
	-- in Minecraft.  This appears to be an oversight on Mojang's
	-- part, but absent any indications to that effect it should
	-- be reproduced none the less.
	pacing_target = mob_class.amphibious_pacing_target,
	_is_idle_activity = {
		pacing = true,
		_attempting_to_surface = true,
	},
	_convert_to = false,
	_reinforcement_type = "mobs_mc:drowned",
})

------------------------------------------------------------------------
-- Drowned visuals.
------------------------------------------------------------------------

local TRIDENT_AGGRESSIVE_ROT = vector.new (0, 0, 180)
local TRIDENT_AGGRESSIVE_POS = vector.new (0, 3.5, 0)

function drowned:wielditem_transform (info, stack)
	local rot, pos, size
		= mob_class.wielditem_transform (self, info, stack)
	size.x = size.x * 1.6
	size.y = size.y * 1.6
	if self._arm_pose == "trident_aggressive"
		or self._arm_pose == "jockey_trident_aggressive" then
		return TRIDENT_AGGRESSIVE_ROT,
			TRIDENT_AGGRESSIVE_POS, size
	end
	return rot, pos, size
end

local drowned_poses = {
	default = {
		["arm.right"] = {},
		["arm.left"] = {},
	},
	aggressive = {
		["arm.right"] = {
			nil,
			vector.new (0, 0, 30),
		},
		["arm.left"] = {
			nil,
			vector.new (0, 0, 30),
		},
	},
	trident_aggressive = {
		["arm.right"] = {
			nil,
			vector.new (0, 0, 125),
		},
		["arm.left"] = {
			nil,
			vector.new (0, 0, 30),
		},
	},
}

mcl_mobs.define_composite_pose (drowned_poses, "jockey", {
	["leg.right"] = {
		nil,
		vector.new (-127.7, 16.3, -101.8),
	},
	["leg.left"] = {
		nil,
		vector.new (-53.3, 16.3, -78.2),
	},
})

drowned._arm_poses = drowned_poses

function drowned:pose_bone_absolute_p (bone)
	return bone == "leg.left" or bone == "leg.right"
end

function drowned:set_animation (anim)
	if self._swimming then
		return false
	end

	mob_class.set_animation (self, anim)
end

function drowned:select_arm_pose ()
	local basic_pose = "default"

	if self.attack
		and self.attack_type == "melee"
		and self._attack_delay
		and (self._attack_delay < self.melee_interval / 2) then
		basic_pose = "aggressive"
	elseif self.attack and self.attack_type == "ranged" then
		basic_pose = "trident_aggressive"
	end

	if self.jockey_vehicle then
		return "jockey_" .. basic_pose
	else
		return basic_pose
	end
end

function drowned:apply_arm_pose (pose)
	posing_humanoid.apply_arm_pose (self, pose)
	-- Update the trident wielditem when switching to or from an
	-- aggressive pose.
	if self.attack_type == "ranged" then
		self:display_wielditem (false)
	end
end

local v = vector.zero ()
local PITCH_BONE_OVERRIDE = {
	rotation = {
		vec = v,
		absolute = false,
		interpolation = 0.05,
	},
}

function drowned:set_pitch (pitch)
	if self._pitch ~= pitch then
		v.x = pitch
		self.object:set_bone_override ("root", PITCH_BONE_OVERRIDE)
	end
	self._pitch = pitch
end

------------------------------------------------------------------------
-- Drowned physics.
------------------------------------------------------------------------

function drowned:get_staticdata_table ()
	local tbl = mob_class.get_staticdata_table (self)
	if tbl then
		tbl._swimming = nil
		tbl._swim_up = nil
	end
	return tbl
end

local ZERO = vector.zero ()

function drowned:check_water_flow ()
	if self._swimming then
		return ZERO
	else
		return mob_class.check_water_flow (self)
	end
end

function drowned:set_swimming (swimming)
	if swimming ~= self._swimming then
		if swimming then
			self:set_animation ("swim")
			self:cancel_navigation ()
			-- Intentionally does not take effect with
			-- jockeys.
			self:gwp_configure_aquatic_mob ()
			self.pacing_target = mob_class.aquatic_pacing_target
		else
			if self:navigation_finished () then
				self:set_animation ("stand")
			else
				self:set_animation ("walk")
			end
			self:cancel_navigation ()
			self:gwp_configure_default_mob ()
			self.pacing_target = mob_class.amphibious_pacing_target
		end
		self._swimming = swimming
	end
end

local DROWNED_SWIM_SPEED = 0.2
local DROWNED_SWIM_FRICTION = 0.9
local AIR_DRAG = 0.98

local pow_by_step = mcl_mobs.pow_by_step

function drowned:motion_step (dtime, moveresult, self_pos)
	if self._swimming and self._immersion_depth > 0 then
		local p = pow_by_step (AIR_DRAG, dtime)
		local acc_dir = self.acc_dir
		acc_dir.x = acc_dir.x * p
		acc_dir.z = acc_dir.z * p

		local v = self.object:get_velocity ()
		local p = pow_by_step (DROWNED_SWIM_FRICTION, dtime)
		local scale = (1 - p) / (1 - DROWNED_SWIM_FRICTION)
		local f_x, f_y, f_z
			= self:accelerate_relative (acc_dir,
						    DROWNED_SWIM_SPEED * scale,
						    DROWNED_SWIM_SPEED * scale)
		v.x = v.x * p + f_x
		v.y = v.y * p + f_y
		v.z = v.z * p + f_z
		if not self._previously_floating then
			self.object:set_properties ({stepheight = 1.01,})
			self._previously_floating = true
		end
		self._was_touching_ground = false
		self.object:set_velocity (v)
	else
		self:set_pitch (0)
		mob_class.motion_step (self, dtime, moveresult, self_pos)
	end
end

local DROWNED_CLIMB_BONUS = 0.04
local DROWNED_SWIM_SPEED_1 = 0.01
local DROWNED_SWIM_SPEED_2 = 2.0
local atan2 = math.atan2
local mathsqrt = math.sqrt

function drowned:movement_step (dtime, moveresult)
	if self.movement_goal == nil
		and self._swimming
		and self._immersion_depth > 0 then
		self.object:set_velocity (ZERO)
	end
	mob_class.movement_step (self, dtime, moveresult)
end

local function lerp1d (u, s1, s2)
	return (s2 - s1) * u + s1
end

local pi = math.pi

local function lerp_angle (u, s1, s2)
	local diff = mcl_util.norm_radians (s2 - s1)
	return mcl_util.norm_radians (s1 + diff * u)
end

function drowned:do_go_pos (dtime, moveresult)
	if self._immersion_depth > 0 and self._swimming then
		local target = self.attack
		local self_pos = self.object:get_pos ()
		local v = self.object:get_velocity ()
		local p = pow_by_step (DROWNED_SWIM_FRICTION, dtime)
		local scale = (1 - p) / (1 - DROWNED_SWIM_FRICTION)
		local vel = self.movement_velocity

		if (target and target:is_valid () and target:get_pos ().y > self_pos.y)
			or self._swim_up then
			v.y = v.y + DROWNED_CLIMB_BONUS * scale
		end

		local target_pos = self.movement_target or ZERO
		local dx = target_pos.x - self_pos.x
		local dy = target_pos.y - self_pos.y
		local dz = target_pos.z - self_pos.z
		local magnitude = mathsqrt (dx * dx + dy * dy + dz * dz)
		local dy_scaled = magnitude > 0.05 and dy / magnitude or 0.0
		local yaw = atan2 (dz, dx) - pi / 2
		self:set_yaw (yaw)
		local lerp_factor = pow_by_step (0.125, dtime)
		self:set_velocity (lerp1d (lerp_factor, self.acc_speed, vel))
		scale = scale * self.acc_speed * 0.05
		v.x = v.x + dx * DROWNED_SWIM_SPEED_1 * scale
		v.y = v.y + dy_scaled * DROWNED_SWIM_SPEED_2 * scale
		v.z = v.z + dz * DROWNED_SWIM_SPEED_1 * scale
		self.object:set_velocity (v)

		local pitch = atan2 (dy, mathsqrt (dx * dx + dz * dz))
		self:set_pitch (lerp_angle (lerp_factor, self._pitch, pitch * 0.5))
	else
		mob_class.do_go_pos (self, dtime, moveresult)
	end
end

------------------------------------------------------------------------
-- Drowned mechanics.
------------------------------------------------------------------------

function drowned:generate_default_equipment ()
	if math.random () > 0.9 then
		local chance = math.random (0, 15)
		if chance < 10 then
			self:set_wielditem (ItemStack ("mcl_tridents:trident"))
		else
			self:set_wielditem (ItemStack ("mcl_fishing:fishing_rod"))
		end
	end

	if math.random () < 0.03 then
		self:set_offhand_item (ItemStack ("mcl_mobitems:nautilus_shell"), 1.0)
	end
end

function drowned:wielditem_better_than (stack, current)
	local current_name = current:get_name ()
	if current_name == "mcl_mobitems:nautilus_shell" then
		return false
	else
		return (core.get_item_group (current_name, "trident") == 0)
			and (core.get_item_group (stack:get_name (), "trident") > 0
			     or mob_class.wielditem_better_than (self, stack, current))
	end
end

------------------------------------------------------------------------
-- Drowned AI.
------------------------------------------------------------------------

local waterbound_gwp_basic_classify
	= mcl_mobs.waterbound_gwp_basic_classify
local hashpos = mcl_mobs.gwp_hashpos

local function drowned_gwp_classify_node (self, context, pos)
	local hash = hashpos (context, pos.x, pos.y, pos.z)
	local cache = context.class_cache[hash]

	if cache then
		return cache
	end

	-- Don't consider the node above a position, as partially
	-- surfaced drowned should be capable of continuing to swim.
	local class = waterbound_gwp_basic_classify (pos)
	context.class_cache[hash] = class
	if class then
		return class
	end
	context.class_cache[hash] = "WATER"
	return "WATER"
end

function drowned:gwp_configure_aquatic_mob (nocopy)
	mob_class.gwp_configure_aquatic_mob (self, nocopy)
	self.gwp_classify_node = drowned_gwp_classify_node
end

function drowned:reconfigure_attack_type (wielditem)
	local name = wielditem:get_name ()

	if name ~= "" and core.get_item_group (name, "trident") > 0 then
		self:reset_attack_type ("ranged")
	else
		self:reset_attack_type ("melee")
	end
end

function drowned:mob_activate (staticdata, dtime)
	if not zombie.mob_activate (self, staticdata, dtime) then
		return false
	end
	self:reconfigure_attack_type (self:get_wielditem ())
	return true
end

function drowned:set_wielditem (stack, drop_probability)
	mob_class.set_wielditem (self, stack, drop_probability)
	self:reconfigure_attack_type (stack)
end

local floor = math.floor

local cid_water_source = core.get_content_id ("mcl_core:water_source")
local cid_water_flowing = core.get_content_id ("mcl_core:water_flowing")

local function object_submerged_p (object, pos)
	if object:get_attach () then
		-- Boats and like attachments should exempt players
		-- from targeting.
		return false
	end

	local cid, _, _ = core.get_node_raw (floor (pos.x + 0.5),
					     floor (pos.y + 0.5),
					     floor (pos.z + 0.5))
	return cid == cid_water_source
		or cid == cid_water_flowing
end

function drowned:should_swim ()
	if self._swim_up then
		return true
	end
	local attack = self.attack
	return self._immersion_depth >= 1.0
		and attack
		and attack:is_valid ()
		and object_submerged_p (attack, attack:get_pos ())
end

function drowned:test_swimming ()
	if self:should_swim () then
		self:set_swimming (true)
	else
		self:set_swimming (false)
	end
end

function drowned:run_ai (dtime, moveresult)
	self:test_swimming ()
	mob_class.run_ai (self, dtime, moveresult)
end

local function object_targetable_p (object, pos)
	if mcl_util.is_daytime () then
		return object_submerged_p (object, pos)
	end
	return true
end

function drowned:discharge_ranged (self_pos, target_pos)
	local stack = self:get_wielditem ()
	local inaccuracy = 14 - mcl_vars.difficulty * 4
	local diff = vector.subtract (target_pos, self_pos)
	local shoot_pos = mcl_util.target_eye_pos (self.object)
	mcl_tridents.shoot_trident (stack, self.object, shoot_pos, nil, nil, diff,
				    false, 0, inaccuracy, nil)
end

local function drowned_find_water_1 (self_pos)
	local node_x = floor (self_pos.x + 0.5)
	local node_y = floor (self_pos.y + 0.5)
	local node_z = floor (self_pos.z + 0.5)

	for i = 1, 10 do
		local x = node_x + math.random (-10, 9)
		local y = node_y + math.random (-5, 0)
		local z = node_z + math.random (-10, 9)
		local cid, _, _ = core.get_node_raw (x, y, z)
		if cid == cid_water_source or cid == cid_water_flowing then
			return vector.new (x, y, z)
		end
	end
	return nil
end

local function drowned_find_water (self, self_pos, dtime, moveresult)
	if self._seeking_water then
		if self:navigation_finished () then
			self._seeking_water = nil
			return false
		elseif self:check_timer ("drowned_repath", 1.0) then
			self:gopath (self._seeking_water, 1.0)
		end
		return true
	elseif self:check_timer ("drowned_survey_water", 0.5)
		and mcl_util.is_daytime ()
		and self._immersion_depth < 0.5 then
		local dest_pos = drowned_find_water_1 (self_pos)
		if dest_pos then
			self:gopath (dest_pos, 1.0)
			self._seeking_water = dest_pos
			return "_seeking_water"
		end
		return false
	end
end

local function is_node_solid (v)
	v.y = v.y - 1
	local node = core.get_node (v)
	v.y = v.y + 1
	return core.get_item_group (node.name, "solid") > 0
end

local SOLIDS = { "group:solid", }
local mathmin = math.min
local cid_air = core.CONTENT_AIR

local function drowned_find_land_1 (self_pos)
	local x = floor (self_pos.x + 0.5)
	local y = floor (self_pos.y + 0.5)
	local z = floor (self_pos.z + 0.5)
	local nodes_under_air
		= core.find_nodes_in_area_under_air (vector.new (x - 8, y - 8, z - 8),
						     vector.new (x + 8, y + 8, z + 8),
						     SOLIDS)
	table.shuffle (nodes_under_air)
	for i = 1, mathmin (#nodes_under_air, 10) do
		local pos = nodes_under_air[i]
		local cid, _, _ = core.get_node_raw (pos.x, pos.y + 2, pos.z)
		if cid == cid_air then
			pos.y = pos.y + 1
			return pos
		end
	end
	return nil
end

local function drowned_find_land (self, self_pos, dtime, moveresult)
	if self._seeking_land then
		if self._immersion_depth == 0.0 then
			self._dry_time = self._dry_time + dtime
		else
			self._dry_time = 0.0
		end
		if self:navigation_finished () then
			self._seeking_land = nil
			return false
		elseif not is_node_solid (self._seeking_land)
			or self._dry_time > 1.0 then
			self:cancel_navigation ()
			self:halt_in_tracks ()
			return false
		elseif self:check_timer ("drowned_repath", 1.0) then
			self:gopath (self._seeking_land, 1.0)
		end
		return true
	elseif self:check_timer ("drowned_survey_beach", 1.0)
		and floor (self_pos.y + 0.5) >= -3
		and self._immersion_depth >= 1.0 then
		local land_pos = drowned_find_land_1 (self_pos)
		-- Apply any alterations to the pathfinder state
		-- immediately.
		self._swim_up = false
		self:test_swimming ()
		if land_pos then
			self:gopath (land_pos, 1.0)
			self._dry_time = 0.0
			self._seeking_land = land_pos
			return "_seeking_land"
		end
		return false
	end
end

local function drowned_surface (self, self_pos, dtime, moveresult)
	if self._swim_up then
		if self_pos.y >= -1.5 or mcl_util.is_daytime () then
			self._swim_up = false
			return false
		else
			local target = self._surface_target
			if not target
				or self:navigation_finished ()
				or (target and vector.distance (target, self_pos) <= 2.0) then
				local node_pos = mcl_util.get_nodepos (self_pos)
				local desired_pos = vector.new (node_pos.x, -1.5, node_pos.z)
				local dir = vector.direction (node_pos, desired_pos)
				local next_pos = self:target_in_direction (node_pos,
									   4, 8, dir,
									   pi / 2)
				if not next_pos then
					self._swim_up = false
					return false
				end
				self:gopath (next_pos, 1.0)
				self._surface_target = next_pos
				return true
			end
			return true
		end
	elseif self:check_timer ("drowned_surface_attempt", 0.5)
		and not mcl_util.is_daytime ()
		and self_pos.y < -2.5 then
		self._swim_up = true
		self._surface_target = nil
		return "_swim_up"
	end
	return false
end

drowned.ai_functions = {
	drowned_find_water,
	mob_class.check_attack,
	drowned_find_land,
	drowned_surface,
	mob_class.check_pace,
}

function drowned:test_object_and_restriction (obj, pos)
	return mob_class.test_object_and_restriction (self, obj, pos)
		and object_targetable_p (obj, pos)
end

drowned._targeting_rules = {
	mcl_mobs.build_retaliation_target_rule (nil, true, {
		"mobs_mc:zombie",
		"mobs_mc:baby_zombie",
		"mobs_mc:husk",
		"mobs_mc:baby_husk",
		"mobs_mc:zombified_piglin",
		"mobs_mc:villager_zombie",
		"mobs_mc:drowned",
		"mobs_mc:baby_drowned",
	}),
	mcl_mobs.build_nearest_target_rule ("player", nil, nil, nil, false),
	mcl_mobs.build_nearest_target_rule ("mobs_mc:villager", {
		"mobs_mc:villager",
		"mobs_mc:wandering_trader",
	}, nil, nil, false),
	mcl_mobs.build_nearest_target_rule ("mobs_mc:iron_golem",
					    { "mobs_mc:iron_golem", },
					    nil, nil, false),
	mcl_mobs.build_nearest_target_rule ("mobs_mc:axolotl",
					    { "mobs_mc:axolotl", },
					    nil, nil, false),
	mcl_mobs.build_alert_receiver_rule (),
}

mcl_mobs.register_mob ("mobs_mc:drowned", drowned)

------------------------------------------------------------------------
-- Baby Drowned.
------------------------------------------------------------------------

local baby_drowned = table.merge (drowned, {
	description = S ("Baby Drowned"),
	visual_size = {
		x = 1.0, y = 1.0, z = 1.0,
	},
	collisionbox = {
		-0.25, 0.0, -0.25,
		0.25, 0.99, 0.25,
	},
	xp_min = 12,
	xp_max = 12,
	child = 1,
	reach = 1,
	head_eye_height = 0.93,
	mesh = "mobs_mc_baby_drowned.b3d",
	_convert_to = false,
})

mcl_mobs.register_mob ("mobs_mc:baby_drowned", baby_drowned)

------------------------------------------------------------------------
-- Modern Zombie & Husk spawning.
------------------------------------------------------------------------

local monster_spawner = mobs_mc.monster_spawner
local drowned_spawner = table.merge (monster_spawner, {
	name = "mobs_mc:drowned",
	spawn_placement = "aquatic",
	pack_min = 1,
	pack_max = 1,
	weight = 5,
	biomes = {
		"#is_ocean",
	},
})

mcl_levelgen.modify_biome_groups ({"#is_river",}, {
	more_frequent_drowned_spawns = true,
})

local more_frequent_drowned_spawns_p

core.register_on_mods_loaded (function ()
	more_frequent_drowned_spawns_p = mcl_biome_dispatch.make_biome_test ({
		"#more_frequent_drowned_spawns",
	})
end)

function drowned_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache,
					      spawn_flag)
	if monster_spawner.test_spawn_position (self, spawn_pos, node_pos, sdata, node_cache,
						spawn_flag) then
		local node = self:get_node (node_cache, -1, node_pos)
		if node.name ~= "mcl_core:water_source"
			and node.name ~= "mcl_core:water_flowing" then
			return false
		else
			local biome
				= mcl_biome_dispatch.get_biome_name_nosample (node_pos)
			if more_frequent_drowned_spawns_p (biome) then
				return math.random (2) == 1
			else
				return math.random (6) == 1 and node_pos.y < -5
			end
		end
	end

	return false
end

function drowned_spawner:spawn (spawn_pos, idx, sdata, pack_size)
	if math.random () < 0.05 then
		return core.add_entity (spawn_pos, "mobs_mc:baby_drowned")
	else
		return core.add_entity (spawn_pos, "mobs_mc:drowned")
	end
end

local drowned_spawner_river = table.merge (drowned_spawner, {
	biomes = {
		"River",
	},
	weight = 100,
	pack_min = 1,
	pack_max = 1,
	describe_additional_spawning_criteria = function (self)
		return monster_spawner.describe_additional_spawning_criteria (self)
			.. "  "
			.. S ("Drowned will spawn more frequently in this biome.")
	end,
})

local drowned_spawner_frozen_river = table.merge (drowned_spawner, {
	biomes = {
		"FrozenRiver",
	},
	weight = 1,
	pack_min = 1,
	pack_max = 1,
})

local drowned_spawner_dripstone_caves = table.merge (drowned_spawner, {
	biomes = {
		"DripstoneCaves",
	},
	weight = 95,
	pack_min = 4,
	pack_max = 4,
})

mcl_mobs.register_spawner (drowned_spawner)
mcl_mobs.register_spawner (drowned_spawner_river)
mcl_mobs.register_spawner (drowned_spawner_frozen_river)
mcl_mobs.register_spawner (drowned_spawner_dripstone_caves)

mcl_mobs.register_egg ("mobs_mc:drowned", S ("Drowned"), "#8ff1d7", "#799c65", 0)
