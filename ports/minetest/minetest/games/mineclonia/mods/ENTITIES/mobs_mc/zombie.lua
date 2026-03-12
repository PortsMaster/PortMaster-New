--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class
local posing_humanoid = mcl_mobs.posing_humanoid

--###################
--################### ZOMBIE
--###################

local drops_common = {
	{
		name = "mcl_mobitems:rotten_flesh",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",
	},
	{
		name = "mcl_core:iron_ingot",
		chance = 120, -- 2.5% / 3
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 3,
	},
	{
		name = "mcl_farming:carrot_item",
		chance = 120, -- 2.5% / 3
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 3,
	},
	{
		name = "mcl_farming:potato_item",
		chance = 120, -- 2.5% / 3
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 3,
	},
}

local drops_zombie = table.copy (drops_common)
table.insert (drops_zombie, {
	name = "mcl_heads:zombie",
	chance = 1,
	min = 0,
	max = 0,
	mob_head = true,
})

------------------------------------------------------------------------
-- Zombie.
------------------------------------------------------------------------

local zombie = table.merge (posing_humanoid, {
	description = S("Zombie"),
	type = "monster",
	_spawn_category = "monster",
	hp_min = 20,
	hp_max = 20,
	xp_min = 5,
	xp_max = 5,
	head_swivel = "head.control",
	bone_eye_height = 6.3,
	head_eye_height = 1.74,
	curiosity = 7,
	head_pitch_multiplier=-1,
	breath_max = -1,
	wears_armor = "no_pickup",
	_head_armor_bone = "head",
	_head_armor_position = vector.new (0, 4.25, 0),
	_head_armor_visual_scale = 1.2,
	armor_drop_probability = {
		head = 0.085,
		torso = 0.085,
		legs = 0.085,
		feet = 0.085,
	},
	wielditem_drop_probability = 0.085,
	armor = {
		undead = 90,
		fleshy = 90,
	},
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.95, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_zombie.b3d",
	visual_size = {
		x = 1,
		y = 1.1,
	},
	textures = {
		{
			"mobs_mc_empty.png", -- armor
			"mobs_mc_zombie.png", -- texture
		}
	},
	makes_footstep_sound = true,
	sounds = {
		random = {name="mobs_mc_zombie_growl", gain=0.5},
		war_cry = {name="mobs_mc_zombie_growl", gain=0.5},
		death = "mobs_mc_zombie_death",
		damage = "mobs_mc_zombie_hurt",
	},
	sound_params = {
		max_hear_distance = 16,
		gain = 0.5,
	},
	movement_speed = 4.6,
	damage = 3,
	reach = 2,
	drops = drops_zombie,
	animation = {
		stand_start = 40, stand_end = 49, stand_speed = 2,
		walk_start = 0, walk_end = 39, speed_normal = 25,
		punch_start = 50, punch_end = 59, punch_speed = 20,
	},
	ignited_by_sunlight = true,
	floats = 0,
	attack_type = "melee",
	harmed_by_heal = true,
	attack_npcs = true,
	can_wield_items = "no_pickup",
	wielditem_info = {
		bone = "arm.right",
		position = {
			x = 0.7,
			y = 6.0,
			z = 0.0,
		},
		rotation = {
			x = 0,
			y = 0,
			z = 0,
		},
		toollike_position = {
			x = 0.0,
			y = 5.0,
			z = 4.0,
		},
		toollike_rotation = {
			x = 90,
			y = -45,
			z = -90,
		},
		blocklike_position = {
			x = 0,
			y = 6.0,
			z = 0,
		},
		blocklike_rotation = {
			x = 0,
			y = 180,
			z = 45,
		},
		crossbow_position = {
			x = 0,
			y = 6.0,
			z = 0,
		},
		crossbow_rotation = {
			x = 0,
			y = 180,
			z = 45,
		},
		bow_position = {
			x = 0,
			y = 6.0,
			z = 0,
		},
		bow_rotation = {
			x = 90,
			y = 130,
			z = 115,
		},
		trident_position = {
			x = 0,
			y = 5.0,
			z = 0,
		},
		trident_rotation = {
			x = 90,
			y = 0,
			z = 0,
		},
	},
	ignite_targets_while_burning = true,
	can_open_doors = false,
	_can_break_doors = false,
	tracking_distance = 35.0,
	view_range = 35.0,
	_persistent_physics_factors = {
		["mobs_mc:zombie_knockback_resistance"] = true,
		["mobs_mc:zombie_view_range_bonus"] = true,
		["mobs_mc:zombie_tracking_distance_bonus"] = true,
		["mobs_mc:zombie_spawn_reinforcements_chance"] = true,
		["mobs_mc:zombie_reinforcement_caller_attenuation"] = true,
		["mobs_mc:zombie_reinforcement_callee_attenuation"] = true,
	},
	_spawn_reinforcements_chance = 0.0,
	_zombie_punch_animation_timeout = 0,
	_humanoid_superclass = mob_class,
	_reinforcement_type = "mobs_mc:zombie",
	_convert_to = "mobs_mc:drowned",
	_time_submerged = 0,
})

mobs_mc.zombie = zombie

------------------------------------------------------------------------
-- Zombie visuals.
------------------------------------------------------------------------

local zombie_poses = {
	default = {
		["arm.left.001"] = {},
		["arm.right.001"] = {},
	},
	aggressive = {
		["arm.left.001"] = {
			nil,
			vector.new (90, -70, -89),
			nil,
		},
		["arm.right.001"] = {
			nil,
			vector.new (90, -70, -89),
			nil,
		},
	},
}

mcl_mobs.define_composite_pose (zombie_poses, "jockey", {
	["leg.right"] = {
		nil,
		vector.new (-110, 35, 0),
	},
	["leg.left"] = {
		nil,
		vector.new (-110, -35, 0),
	},
})

zombie._arm_poses = zombie_poses

function zombie:select_arm_pose ()
	local basic_pose = "default"

	if self.attack
		and self._attack_delay
		and (self._attack_delay < self.melee_interval / 2) then
		basic_pose = "aggressive"
	end
	if self.jockey_vehicle then
		return "jockey_" .. basic_pose
	else
		return basic_pose
	end
end

------------------------------------------------------------------------
-- Zombie mechanics.
------------------------------------------------------------------------

function zombie:validate_attribute (field, value)
	if value == nil then
		value = 0.0
	end

	if field == "_spawn_reinforcements_chance" then
		return math.min (1, math.max (0, value))
	else
		return mob_class.validate_attribute (self, field, value)
	end
end

function zombie:zombie_post_spawn ()
	self:set_physics_factor_base ("_spawn_reinforcements_chance", math.random () * 0.1)
end

local CHICKEN_ATTACHMENT_POS = vector.new (0, 1.76, 0)

function zombie:find_chicken ()
	local self_pos = self.object:get_pos ()
	for object in core.objects_inside_radius (self_pos, 8) do
		local entity = object:get_luaentity ()
		if entity and entity.name == "mobs_mc:chicken"
			and not entity.dead
			and not entity._jockey_rider then
			return object
		end
	end
	return nil
end

function zombie:on_spawn ()
	local self_pos = self.object:get_pos ()
	local mob_factor = mcl_worlds.get_special_difficulty (self_pos)
	-- Enable picking up armor for a random subset of
	-- skeletons.
	if math.random () < 0.55 * mob_factor then
		self.wears_armor = true
		self.can_wield_items = true
	end
	self:generate_default_equipment (mob_factor, true, true)
	if mcl_util.is_halloween ()
		and self.armor_list.head == ""
		and math.random () < 0.25 then
		if math.random () < 0.1 then
			self.armor_list.head = "mcl_farming:pumpkin_face_light"
		else
			self.armor_list.head = "mcl_farming:pumpkin_face"
		end
		self:set_armor_texture ()
	end

	-- Randomize initial attributes.
	self:add_physics_factor ("knockback_resistance",
				 "mobs_mc:zombie_knockback_resistance",
				 math.random () * 0.05, "add")
	local d = mob_factor * 1.5 * math.random ()
	if d > 1.0 then
		self:add_physics_factor ("view_range", "mobs_mc:zombie_view_range_bonus",
					 d, "add_multiplied_total")
		self:add_physics_factor ("tracking_distance", "mobs_mc:zombie_tracking_distance_bonus",
					 d, "add_multiplied_total")
	end
	if math.random () < mob_factor * 0.05 then
		local chance = math.random () * 0.25 + 0.5
		self:add_physics_factor ("_spawn_reinforcements_chance",
					 "mobs_mc:zombie_spawn_reinforcements_chance",
					 chance, "add")
		-- https://bugs.mojang.com/browse/MC-219981:
		-- reinforcement-spawning zombies are supposed to
		-- receive a health bonus but it does not affect their
		-- current health.
		local health = math.random () * 3.0 + 1.0
		self._zombie_health_bonus = health
		self.object:set_properties ({
			hp_max = 20 + 20 * self._zombie_health_bonus,
		})

		-- Enable these zombies to spawn reinforcements.
		self._can_break_doors = true
	end
	if not self._no_chicken_jockeys then
		if self.child and math.random (100) <= 5 then
			local chicken = self:find_chicken ()
			if chicken then
				self:jock_to_existing (chicken, "", CHICKEN_ATTACHMENT_POS)
				local entity = chicken:get_luaentity ()
				entity._is_chicken_jockey = true
			end
		elseif self.child and math.random (100) <= 5 then
			local chicken = self:jock_to ("mobs_mc:chicken", CHICKEN_ATTACHMENT_POS)
			if chicken then
				local entity = chicken:get_luaentity ()
				entity._is_chicken_jockey = true
			end
		end
	end
	self:zombie_post_spawn ()
end

function zombie:mob_activate (staticdata, dtime)
	if not posing_humanoid.mob_activate (self, staticdata, dtime) then
		return false
	end
	self._visited_pois = {}
	if self._zombie_health_bonus then
		self.object:set_properties ({
			hp_max = 20 + 20 * self._zombie_health_bonus,
		})
	end
	if self.child then
		self:add_physics_factor ("movement_speed", "mobs_mc:baby_zombie_speed",
						0.5, "add_multiplied_base")
	end
	return true
end

------------------------------------------------------------------------
-- Zombie-door interaction.
------------------------------------------------------------------------

local DOOR_BREAK_TIME = 12

-- Zombies should not close broken doors.
function zombie:gwp_memorize_door (door_node)
end

function zombie:gwp_close_memorized_doors ()
end

function zombie:check_jump (self_pos, moveresult)
	if mob_class.check_jump (self, self_pos, moveresult) then
		-- Verify that no door is being broken...
		local door = self._breaking_door
		if door then
			local above = vector.offset (door, 0, 1, 0)
			local below = vector.offset (door, 0, -1, 0)
			for _, item in pairs (moveresult.collisions) do
				if item.type == "node"
					and (vector.equals (above, item.node_pos)
						or vector.equals (door, item.node_pos)
						or vector.equals (below, item.node_pos)) then
					return false
				end
			end
		end

		return true
	end
	return false
end

function zombie:do_custom (dtime)
	posing_humanoid.do_custom (self, dtime)
	local t = self._zombie_punch_animation_timeout - dtime
	self._zombie_punch_animation_timeout = math.max (0.0, t)

	if self._convert_to then
		self:step_conversion (dtime)
	end
end

function zombie:set_animation (anim, custom_frame)
	if self._zombie_punch_animation_timeout > 0.0 then
		anim = "punch"
	end
	mob_class.set_animation (self, anim, custom_frame)
end

function zombie:gwp_open_door (door_node, nodedef, dtime)
	if self._breaking_door == nil then
		self._breaking_door = door_node
		self._door_break_time = 0
		self._door_break_progress = 0
	end
end

function zombie:reset_door_animation (velocity)
	if vector.length (velocity) > 0.1 then
		self:set_animation ("walk")
	else
		self:set_animation ("stand")
	end
end

function zombie:break_door_step (door_node, dtime, velocity)
	local t = self._door_break_time + dtime
	self._door_break_time = t
	self.ai_idle_time = 0

	if t >= DOOR_BREAK_TIME and not core.is_protected (door_node, "") then
		core.dig_node (door_node)
		core.sound_play ("default_dig_choppy", {
			pos = door_node,
			gain = 0.5,
		})
		self._breaking_door = nil
		self._door_break_time = nil
		self._door_break_progress = nil
		self:set_animation ("walk")
	else
		local progress = math.floor (t / 12 * 10)
		if progress ~= self._door_break_progress then
			self._door_break_progress = progress
			core.sound_play ("mobs_mc_zombie_door_break", {
				     pos = door_node,
				     gain = 0.5,
			})
		end
		self:reset_door_animation (velocity)
		if math.random (1, 20) == 1
			and self._current_animation ~= "punch" then
			self:set_animation ("punch")
			self._zombie_punch_animation_timeout = 0.45
		end
	end
end

local function is_closed_wooden_door (pos)
	local node = core.get_node (pos)
	return core.get_item_group (node.name, "door") > 0
		and core.get_item_group (node.name, "door_iron") == 0
		and not mcl_doors.is_open (node)
end

local COS_100_DEG = math.cos (100)

local function is_moving_away_from_door (self, self_pos, door, velocity)
	-- First test that the mob is further away than .5 blocks from
	-- the center.
	local dir = vector.subtract (door, self_pos)
	dir.y = 0
	if vector.length (dir) < 0.05 then
		return false
	end

	-- Next test that the mob is not moving away from the center
	-- of the door.
	dir = vector.normalize (dir)
	return vector.length (velocity) > 1.0
		and vector.dot (dir, vector.normalize (velocity)) < -COS_100_DEG
end

local function horiz_distance (a, b)
	local dx = a.x - b.x
	local dz = a.z - b.z
	return math.sqrt (dx * dx + dz * dz)
end

local function vertical_distance (a, b)
	return math.abs (a.y - b.y)
end

local door_penalties = table.merge (mob_class.gwp_penalties, {
	DOOR_WOOD_CLOSED = 0.0,
})

function zombie:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	self.can_open_doors
		= self._can_break_doors and mcl_vars.difficulty == 3
	if self.can_open_doors then
		self.gwp_penalties = door_penalties
	else
		self.gwp_penalties = mob_class.gwp_penalties
	end

	-- Doors are broken asynchronously as in Minecraft, and while
	-- door breaking does not affect line of sight or targeting in
	-- general, it does suppress pacing until the door is broken.
	if self._breaking_door then
		local self_pos = self.object:get_pos ()
		local floor = vector.offset (self._breaking_door, 0, -0.5, 0)
		local velocity = self._old_velocity
		if horiz_distance (self_pos, floor) >= 1.25
			or vertical_distance (self_pos, floor) >= 1.5
			or not is_closed_wooden_door (self._breaking_door)
			or is_moving_away_from_door (self, self_pos,
						self._breaking_door, velocity) then
			self._breaking_door = nil
			self._door_break_time = nil
			self._door_break_progress = nil
		else
			local door_node = self._breaking_door
			self:break_door_step (door_node, dtime, velocity)
		end
	end
end

function zombie:get_staticdata_table ()
	local supertable = mob_class.get_staticdata_table (self)
	if supertable then
		supertable._breaking_door = nil
		supertable._door_break_progress = nil
		supertable._door_break_time = nil
		supertable._zombie_punch_animation_timeout = nil
		supertable._visited_pois = nil
	end
	return supertable
end

------------------------------------------------------------------------
-- Zombie AI.
------------------------------------------------------------------------

function zombie:step_conversion (dtime)
	if self._immersion_depth > self:get_eye_height () then
		self._time_submerged = self._time_submerged + dtime
		if self._time_submerged > 30 then
			self.shaking = true
			if self._time_submerged > 45 then
				self:replace_with (self._convert_to, true)
				return false
			end
		end
	else
		self._time_submerged = 0
		self.shaking = false
	end
end

function zombie:gwp_initialize (targets, range, tolerance, penalties)
	-- Limit the pathfinding distance of zombies to 24, as greater
	-- values are not sustainable by this Lua pathfinder.
	if not range or range > 24.0 then
		range = 24.0
	end
	return mob_class.gwp_initialize (self, targets, range, tolerance, penalties)
end

function zombie:can_spawn_reinforcements (mcl_reason)
	local source = self.attack or mcl_reason.source
	local entity = source and source:get_luaentity ()
	return (source and source:is_player ()) or entity and entity.is_mob
end

local function is_free_of_living_players (pos, radius)
	for player in mcl_util.connected_players (pos, radius) do
		if player:get_hp () > 0 then
			return false
		end
	end
	return true
end

local function is_living_entity (object)
	if not object then
		return nil
	end

	local entity = object:get_luaentity ()
	return object:is_player () or (entity and entity.is_mob)
end

function zombie:receive_damage (mcl_reason, damage)
	if not mob_class.receive_damage (self, mcl_reason, damage) then
		return false
	end

	if mcl_vars.difficulty >= 3 -- Hard
		and is_living_entity (self.attack or mcl_reason.source)
		and math.random () < self._spawn_reinforcements_chance
		and self:can_spawn_reinforcements (mcl_reason) then
		-- Perform 50 attempts to spawn reinforcements on
		-- positions between 7 to 40 blocks removed on some
		-- axes.
		local self_pos = self.object:get_pos ()
		local node_pos = mcl_util.get_nodepos (self_pos)

		for i = 1, 50 do
			local dx = math.random (7, 40) * math.random (-1, 1)
			local dy = math.random (7, 40) * math.random (-1, 1)
			local dz = math.random (7, 40) * math.random (-1, 1)
			local pos = vector.offset (node_pos, dx, dy, dz)

			if is_free_of_living_players (pos, 7.0) then
				local object = mcl_mobs.spawn_abnormally (pos, self._reinforcement_type,
									  nil, "reinforcement")
				if object then
					local entity = object:get_luaentity ()
					self:add_physics_factor ("_spawn_reinforcements_chance",
								 "mobs_mc:zombie_reinforcement_caller_attenuation",
								 -0.05, "add", true)
					entity:add_physics_factor ("_spawn_reinforcements_chance",
								   "mobs_mc:zombie_reinforcement_callee_attenuation",
								   -0.05, "add", true)
					entity:receive_attack (self.attack)
				end
			end
		end
	end
	return true
end

local function has_not_visited (poi, self)
	for _, visited in pairs (self._visited_pois) do
		if vector.equals (poi.min, visited) then
			return false
		end
	end
	return true
end

local function test_proximity_to_poi (a, b)
	return (a[3] or math.huge) < (b[3] or math.huge)
end

function zombie:poi_pacing_target (pos, width, height)
	local candidates = {}

	for i = 1, 10 do
		local dx = math.random (-width, width)
		local dy = math.random (-height, height)
		local dz = math.random (-width, width)
		local random_node = vector.offset (pos, dx, dy, dz)
		if mcl_villages.get_poi_heat (random_node) >= 1.0 then
			local poi, distance
				= mcl_villages.nearest_poi_in_radius (pos, 10.0,
								has_not_visited, self)
			table.insert (candidates, {
				random_node,
				poi and poi.min,
				distance,
			})
		end
	end
	table.sort (candidates, test_proximity_to_poi)
	return #candidates > 0 and candidates[1] or nil
end

local function zombie_navigate_village (self, self_pos, dtime)
	if self._navigating_village then
		local state = self:poll_navigation_state (self_pos, dtime)
		if state ~= "wait" then
			local poi = self._navigating_village
			table.insert (self._visited_pois, poi)
			self._navigating_village = nil
			return false
		end
		return true
	elseif self:check_timer ("check_navigate_village", 1.0)
		and (not mcl_util.is_daytime ()
			or mcl_worlds.pos_to_dimension (self_pos)
				~= "overworld") then
		local node_pos = mcl_util.get_nodepos (self_pos)
		local heat = mcl_villages.get_poi_heat (node_pos)

		if heat >= 3 then
			local target = self:poi_pacing_target (node_pos, 15, 7)
			if not target then
				return false
			end
			local _, poi, _ = unpack (target)
			if poi then
				self:session_navigate (poi, 1.0, 1.0, nil, nil, 1, 1)
				self._navigating_village = poi
				return "_navigating_village"
			end
		end
	end
end

function zombie:custom_attack ()
	mob_class.custom_attack (self)
	if self.child and math.random (2) == 1 then
		-- Baby zombies should potentially attempt to pace
		-- immediately after an attack.
		self._timers.seek_target = 0.5
		self._pace_asap = true
		self.attack = nil
		self:attack_end ()
	end
end

zombie.ai_functions = {
	mob_class.check_attack,
	zombie_navigate_village,
	mob_class.check_pace,
}

zombie._targeting_rules = {
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
	mcl_mobs.build_nearest_target_rule ("mobs_mc:iron_golem", {
		"mobs_mc:iron_golem",
	}, nil, nil, false),
	mcl_mobs.build_alert_receiver_rule (),
}

mcl_mobs.register_mob ("mobs_mc:zombie", zombie)

------------------------------------------------------------------------
-- Baby zombie.
-- A smaller and more dangerous variant of the zombie
------------------------------------------------------------------------

local baby_zombie = table.merge (zombie, {
	description = S("Baby Zombie"),
	visual_size = { x = 0.5, y = 0.5, z = 0.5 },
	collisionbox = {-0.25, 0.0, -0.25, 0.25, 0.99, 0.25},
	xp_min = 12,
	xp_max = 12,
	child = 1,
	reach = 1,
	movement_speed = zombie.movement_speed,
	animation = {
		stand_start = 100, stand_end = 109, stand_speed = 2,
		walk_start = 60, walk_end = 99, speed_normal = 40,
		run_start = 60, run_end = 99, speed_run = 80,
		punch_start = 109, punch_end = 119
	},
	head_eye_height = 0.93,
	_convert_to = "mobs_mc:baby_drowned",
})

mcl_mobs.register_mob ("mobs_mc:baby_zombie", baby_zombie)

------------------------------------------------------------------------
-- Husk.
-- Desert variant of the zombie
------------------------------------------------------------------------

local husk = table.merge (zombie, {
	description = S ("Husk"),
	textures = {
		"mobs_mc_empty.png", -- armor
		"mobs_mc_husk.png", -- texture
	},
	ignited_by_sunlight = false,
	drops = drops_common,
	dealt_effect = {
		name = "hunger",
		dur = 7,
		level = 1,
		respect_local_difficulty = true,
	},
	_reinforcement_type = "mobs_mc:husk",
	_convert_to = "mobs_mc:zombie",
})

------------------------------------------------------------------------
-- Husk conversion.
------------------------------------------------------------------------

mcl_mobs.register_mob ("mobs_mc:husk", husk)

------------------------------------------------------------------------
-- Baby husk.
-- A smaller and more dangerous variant of the husk.
------------------------------------------------------------------------

local baby_husk = table.merge (baby_zombie, {
	description = S("Baby Husk"),
	textures = {{
		"mobs_mc_empty.png", -- wielded_item
		"mobs_mc_husk.png", -- texture
	}},
	ignited_by_sunlight = false,
	drops = drops_common,
	dealt_effect = {
		name = "hunger",
		dur = 7,
		level = 1,
		respect_local_difficulty = true,
	},
	_reinforcement_type = "mobs_mc:husk",
	_convert_to = "mobs_mc:baby_zombie",
})

mcl_mobs.register_mob ("mobs_mc:baby_husk", baby_husk)

------------------------------------------------------------------------
-- Zombie and variant spawning.
------------------------------------------------------------------------

-- Spawn eggs
mcl_mobs.register_egg ("mobs_mc:husk", S("Husk"), "#777361", "#ded88f", 0)
mcl_mobs.register_egg ("mobs_mc:zombie", S("Zombie"), "#00afaf", "#799c66", 0)

------------------------------------------------------------------------
-- Modern Zombie & Husk spawning.
------------------------------------------------------------------------

local non_desert_biomes = {}

for _, biome in pairs (mobs_mc.monster_biomes) do
	if biome ~= "Desert" then
		table.insert (non_desert_biomes, biome)
	end
end

local monster_spawner = mobs_mc.monster_spawner
local zombie_spawner = table.merge (monster_spawner, {
	name = "mobs_mc:zombie",
	weight = 95,
	pack_max = 4,
	pack_min = 4,
	biomes = non_desert_biomes,
})

function zombie_spawner:spawn (spawn_pos, idx, sdata, pack_size)
	local is_baby = sdata and sdata._is_baby_zombie
	if is_baby or math.random () < 0.05 then
		return core.add_entity (spawn_pos, "mobs_mc:baby_zombie")
	else
		return core.add_entity (spawn_pos, "mobs_mc:zombie")
	end
end

function zombie_spawner:describe_criteria (tbl, omit_group_details)
	monster_spawner.describe_criteria (self, tbl, omit_group_details)
	table.insert (tbl, S ("5% of Zombies will spawn as their baby variants."))
end

local zombie_spawner_desert = table.merge (zombie_spawner, {
	weight = 19,
	biomes = {
		"Desert",
	},
})

local husk_spawner = table.merge (monster_spawner, {
	name = "mobs_mc:husk",
	weight = 80,
	pack_max = 4,
	pack_min = 4,
	biomes = {
		"Desert",
	},
})

function husk_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache,
					   spawn_flag)
	return (mcl_weather.is_outdoor (spawn_pos) or spawn_flag == "trial_spawner")
		and monster_spawner.test_spawn_position (self, spawn_pos,
							 node_pos, sdata,
							 node_cache,
							 spawn_flag)
end

function husk_spawner:spawn (spawn_pos, idx, sdata, pack_size)
	if math.random () < 0.05 then
		return core.add_entity (spawn_pos, "mobs_mc:baby_husk")
	else
		return core.add_entity (spawn_pos, "mobs_mc:husk")
	end
end

function husk_spawner:describe_criteria (tbl, omit_group_details)
	monster_spawner.describe_criteria (self, tbl, omit_group_details)
	table.insert (tbl, S ("5% of Husks will spawn as their baby variants."))
	table.insert (tbl, S ("Husks will only spawn on nodes that are exposed to sky."))
end

mcl_mobs.register_spawner (zombie_spawner)
mcl_mobs.register_spawner (zombie_spawner_desert)
mcl_mobs.register_spawner (husk_spawner)
