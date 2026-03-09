--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class

local rabbit = {
	description = S("Rabbit"),
	type = "animal",
	_spawn_category = "creature",
	reach = 1,
	hp_min = 3,
	hp_max = 3,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.2, 0.0, -0.2, 0.2, 0.5, 0.2},
	head_swivel = "head.control",
	bone_eye_height = 2,
	head_eye_height = 0.5,
	horizontal_head_height = -.3,
	curiosity = 20,
	head_yaw = "z",
	visual = "mesh",
	mesh = "mobs_mc_rabbit.b3d",
	textures = {
		{"mobs_mc_rabbit_brown.png"},
		{"mobs_mc_rabbit_gold.png"},
		{"mobs_mc_rabbit_white.png"},
		{"mobs_mc_rabbit_white_splotched.png"},
		{"mobs_mc_rabbit_salt.png"},
		{"mobs_mc_rabbit_black.png"},
	},
	sounds = {
		random = "mobs_mc_rabbit_random",
		damage = "mobs_mc_rabbit_hurt",
		death = "mobs_mc_rabbit_death",
		attack = "mobs_mc_rabbit_attack",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	makes_footstep_sound = false,
	movement_speed = 6.0,
	runaway_from = {
		"mobs_mc:wolf",
		"players",
		"monsters",
	},
	runaway_view_range = 10.0,
	_runaway_player_view_range = 8.0,
	_runaway_monster_view_range = 4.0,
	runaway = true,
	drops = {
		{
			name = "mcl_mobitems:rabbit",
			chance = 1, min = 0, max = 1,
			looting = "common",
		},
		{
			name = "mcl_mobitems:rabbit_hide",
			chance = 1, min = 0, max = 1,
			looting = "common",
		},
		{
			name = "mcl_mobitems:rabbit_foot",
			chance = 10, min = 0, max = 1,
			looting = "rare",
			looting_factor = 0.03,
		},
	},
	animation = {
		stand_start = 0, stand_end = 0,
		jump_start = 0, jump_end = 20, jump_speed = 40,
		jump_loop = false,
	},
	_child_animations = {
		stand_start = 21, stand_end = 21,
		walk_start = 21, walk_end = 41, walk_speed = 30,
		run_start = 21, run_end = 41, run_speed = 45,
	},
	-- Follow (yellow) dangelions, carrots and golden carrots
	follow = {
		"mcl_flowers:dandelion",
		"mcl_farming:carrot_item",
		"mcl_farming:carrot_item_gold",
	},
	climb_powder_snow = true,
	follow_bonus = 1.0,
	pursuit_bonus = 1.4,
	run_bonus = 2.2,
	breed_bonus = 0.8,
	pace_bonus = 0.6,
	runaway_bonus_near = 2.2,
	runaway_bonus_far = 2.2,
	_speed_modifier = 1.0,
	_jump_delay = 0,
	pace_interval = 0,
	_grief_time = 0,
}

------------------------------------------------------------------------
-- Rabbit mechanics.
------------------------------------------------------------------------

function rabbit:on_rightclick (clicker)
	if self:follow_holding (clicker) then
		self:feed_tame (clicker, 4, true, false)
	end
end

function rabbit:actionable_on_rightclick (clicker)
	local wielditem = clicker:get_wielded_item ()
	return table.indexof(self.follow, wielditem:get_name ()) ~= -1
end

function rabbit:set_nametag (nametag)
	if mob_class.set_nametag (self, nametag) then
		-- MC Easter egg: Change texture if rabbit is named
		-- "Toast."
		if nametag == "Toast" and not self._has_toast_texture then
			self._original_rabbit_texture = self.base_texture
			self.base_texture = { "mobs_mc_rabbit_toast.png" }
			self:set_textures (self.base_texture)
			self._has_toast_texture = true
		elseif nametag ~= "Toast" and self._has_toast_texture then
			self.base_texture = self._original_rabbit_texture
			self:set_textures (self.base_texture)
			self._has_toast_texture = false
		end
	end
end

local spawns_white_rabbits_p, spawns_gold_rabbits_p

core.register_on_mods_loaded (function ()
	spawns_white_rabbits_p = mcl_biome_dispatch.make_biome_test ({
		"FrozenOcean",
		"FrozenPeaks",
		"FrozenRiver",
		"Grove",
		"IceSpikes",
		"JaggedPeaks",
		"SnowyBeach",
		"SnowyPlains",
		"SnowySlopes",
		"SnowyTaiga",
	})
	spawns_gold_rabbits_p = mcl_biome_dispatch.make_biome_test ({
		"Desert",
	})
end)

function rabbit:on_spawn ()
	local texture = self._spawn_texture

	if not texture then
		local self_pos = self.object:get_pos ()
		local random = math.random (100)
		local name = mcl_biome_dispatch.get_biome_name (self_pos)

		if spawns_white_rabbits_p (name) then
			if random < 80 then
				texture = "mobs_mc_rabbit_white.png"
			else
				texture = "mobs_mc_rabbit_white_splotched.png"
			end
		elseif spawns_gold_rabbits_p (name) then
			texture = "mobs_mc_rabbit_gold.png"
		elseif random < 50 then
			texture = "mobs_mc_rabbit_brown.png"
		elseif random < 90 then
			texture = "mobs_mc_rabbit_salt.png"
		else
			texture = "mobs_mc_rabbit_black.png"
		end
	end
	self.base_texture[1] = texture
	self:set_textures (self.base_texture)
end

------------------------------------------------------------------------
-- Rabbit movement.
------------------------------------------------------------------------

function rabbit:get_jump_force (moveresult)
	local collides = mcl_mobs.horiz_collision (moveresult)
	local self_pos = self.object:get_pos ()
	local v = 0.3

	if collides then
		v = 0.5
	elseif self.movement_goal == "go_pos"
		and self.movement_target
		and self.movement_target.y > self_pos.y + 0.5 then
		v = 0.5
	elseif self.waypoints
		and #self.waypoints >= 1
		and self.waypoints[#self.waypoints].y > self_pos.y + 0.5 then
		v = 0.5
	elseif self.pacing then
		v = 0.2
	end
	return self.jump_height * (v / 0.42)
end

function rabbit:jump_actual (v, jump_force)
	local v = mob_class.jump_actual (self, v, jump_force)
	local sqr = v.x * v.x + v.z * v.z

	-- Jump forward if immobile.
	if sqr < 0.01 then
		local yaw = self:get_yaw ()
		local x = -math.sin (yaw)
		local z = math.cos (yaw)

		v.x = v.x + 2.0 * x
		v.z = v.z + 2.0 * z
	end
	return v
end

function rabbit:do_go_pos (dtime, moveresult)
	local on_ground = moveresult.touching_ground
		or moveresult.standing_on_object

	if on_ground and not self._jump then
		self.acc_dir.z = 0
		self.acc_dir.x = 0
		self.acc_dir.y = 0
	else
		local depth = self._immersion_depth
		local factor = 1.0
		if depth > self.head_eye_height then
			factor = 1.5
		end

		local target = self.movement_target or vector.zero ()
		local vel = self.movement_velocity * factor
		local pos = self.object:get_pos ()
		local dist = vector.distance (pos, target)

		if dist < 0.0005 then
			self.acc_dir.z = 0
			return
		end

		self:look_at (target, math.pi / 2 * (dtime / 0.05))
		self:set_velocity (vel)
	end
end

function rabbit:movement_step (dtime, moveresult)
	local moveresult = self._moveresult
	local on_ground = moveresult.touching_ground
		or moveresult.standing_on_object

	self._jump_delay
		= math.max (self._jump_delay - dtime, 0.0)

	if on_ground then
		if not self._previously_on_ground then
			self._jump = false
			self._want_sprinting_particles = true

			if not self.frightened and not self.avoiding then
				self._jump_delay = 0.5
			else
				self._jump_delay = 0.048 -- Just under one tick.
			end
		end

		if self.movement_goal == "go_pos"
			and self._jump_delay == 0 then
			local target = self.movement_target or vector.zero ()
			self:look_at (target)
			self._jump = true
		end
	end
	self._previously_on_ground = on_ground
	mob_class.movement_step (self, dtime, moveresult)
end

function rabbit:display_sprinting_particles ()
	local display_particles = self._want_sprinting_particles
	self._want_sprinting_particles = false
	return display_particles
end

------------------------------------------------------------------------
-- Rabbit AI.
------------------------------------------------------------------------

local mob_griefing = mobs_mc.is_mob_griefing_enabled("rabbit")

function rabbit:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	self._grief_time
		= math.max (self._grief_time - dtime, 0.0)
end

local function manhattan3d (v1, v2)
	return math.abs (v1.x - v2.x)
		+ math.abs (v1.y - v2.y)
		+ math.abs (v1.z - v2.z)
end

local function rabbit_griefable (name)
	local age = core.get_item_group (name, "carrot")
	return age > 1 and age or nil
end

local function previous_stage (age)
	if age >= 7 then
		return 5
	elseif age >= 5 then
		return 3
	else
		return 1
	end
end

local function rabbit_grief_garden (self, self_pos, dtime)
	if not mob_griefing then
		return false
	end
	if self._griefing_garden then
		local target = self._grief_target
		local node = core.get_node (target)
		local age = rabbit_griefable (node.name)
		if not age then
			self:cancel_navigation ()
			self:halt_in_tracks ()
			self._griefing_garden = nil
			return false
		end
		local distance = vector.distance (self_pos, target)

		if distance < 1.0 then
			if not self:navigation_finished () then
				self:cancel_navigation ()
				self:halt_in_tracks ()
			end

			-- Grief this carrot block and wait a random
			-- period before proceeding to do so again.
			if core.remove_node (target) then
				core.sound_play ("default_grass_footstep", {
					pos = target,
				}, true)

				local carrot = "mcl_farming:carrot_"
					.. previous_stage (age)
				core.place_node (target, {
					name = carrot,
					param2 = 3,
				}, self.object)
			end

			local next_start_time = math.random (200, 400) / 20
			local rabbit_time = math.random (20, 120) / 20
			self._grief_time = next_start_time + rabbit_time
			self._griefing_garden = false
			return false
		end

		if self._griefing_garden > 60 then
			self._griefing_garden = nil
			self:cancel_navigation ()
			self:halt_in_tracks ()
			return false
		end

		self._griefing_garden = self._griefing_garden + dtime
		if self:check_timer ("rabbit_repath", 2.0) then
			self:gopath (target, 0.7)
		end
		return true
	elseif self._grief_time == 0 then
		if not self:check_timer ("grief_carrots", 0.5) then
			return false
		end
		-- Locate carrot blocks within a 16 block horizontal
		-- area.
		local nodepos = mcl_util.get_nodepos (self_pos)
		local aa = vector.offset (nodepos, -8, 0, -8)
		local bb = vector.offset (nodepos, 8, 1, 8)
		local carrots = core.find_nodes_in_area (aa, bb, {
			"group:carrot",
		})
		if #carrots == 0 then
			return false
		end
		table.sort (carrots, function (a, b)
			return manhattan3d (a, nodepos)
				< manhattan3d (b, nodepos)
		end)
		for i = 1, #carrots do
			local carrot = carrots[i]
			local node = core.get_node (carrot)
			if rabbit_griefable (node.name) then
				self._grief_target = carrot
				self._griefing_garden = 0.0
				self:gopath (carrot, 0.7)
				return "_griefing_garden"
			end
		end
		return false
	end
	return false
end

rabbit.ai_functions = {
	mob_class.ascend_in_powder_snow,
	mob_class.check_frightened,
	mob_class.check_breeding,
	mob_class.check_following,
	mob_class.check_avoid,
	rabbit_grief_garden,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:rabbit", rabbit)

------------------------------------------------------------------------
-- Killer bunny.
------------------------------------------------------------------------

local killer_bunny = table.merge (rabbit, {
	description = S("Killer Bunny"),
	attack_type = "melee",
	damage = 8,
	does_not_prevent_sleep = true,
	-- 8 armor points
	armor = 50,
	textures = {
		"mobs_mc_rabbit_caerbannog.png",
	},
	runaway = false,
})

function killer_bunny:on_spawn ()
	self:set_nametag ("The Killer Bunny")
end

killer_bunny.ai_functions = {
	mob_class.ascend_in_powder_snow,
	mob_class.check_attack,
	mob_class.check_breeding,
	mob_class.check_following,
	rabbit_grief_garden,
	mob_class.check_pace,
}

killer_bunny._targeting_rules = {
	mcl_mobs.build_retaliation_target_rule (nil, true, {"mobs_mc:killer_bunny",}),
	mcl_mobs.build_nearest_target_rule ("player", nil, nil, nil, nil),
	mcl_mobs.build_nearest_target_rule ("mobs_mc:wolf", {"mobs_mc:wolf",},
					    nil, nil, nil),
	mcl_mobs.build_alert_receiver_rule (),
}

mcl_mobs.register_mob ("mobs_mc:killer_bunny", killer_bunny)

------------------------------------------------------------------------
-- Rabbit spawning.
------------------------------------------------------------------------
-- Mob spawning rules.
-- Different skins depending on spawn location.

-- Spawn egg
mcl_mobs.register_egg("mobs_mc:rabbit", S("Rabbit"), "#995f40", "#734831", 0)

------------------------------------------------------------------------
-- Modern Rabbit spawning.
------------------------------------------------------------------------

local rabbit_spawner_woody = table.merge (mobs_mc.animal_spawner, {
	name = "mobs_mc:rabbit",
	weight = 4,
	pack_min = 2,
	pack_max = 3,
	biomes = {
		"FlowerForest",
		"OldGrowthPineTaiga",
		"OldGrowthSpruceTaiga",
		"Taiga",
	},
})

function rabbit_spawner_woody:test_supporting_node (node)
	return core.get_item_group (node.name, "grass_block") > 0
		or node.name == "mcl_core:sand"
		or node.name == "mcl_core:snowblock"
end

function rabbit_spawner_woody:prepare_to_spawn (pack_size, center)
	-- Select a variant for the entire pack.
	local texture
	local random = math.random (100)
	local name = mcl_biome_dispatch.get_biome_name (center)

	if spawns_white_rabbits_p (name) then
		if random < 80 then
			texture = "mobs_mc_rabbit_white.png"
		else
			texture = "mobs_mc_rabbit_white_splotched.png"
		end
	elseif spawns_gold_rabbits_p (name) then
		texture = "mobs_mc_rabbit_gold.png"
	elseif random < 50 then
		texture = "mobs_mc_rabbit_brown.png"
	elseif random < 90 then
		texture = "mobs_mc_rabbit_salt.png"
	else
		texture = "mobs_mc_rabbit_black.png"
	end

	return {
		_spawn_texture = texture,
	}
end

local rabbit_spawner_meadow_or_cherry_grove = table.merge (rabbit_spawner_woody, {
	weight = 2,
	pack_min = 2,
	pack_max = 3,
	biomes = {
		"Meadow",
		"CherryGrove",
	},
})

local rabbit_spawner_snowy = table.merge (rabbit_spawner_woody, {
	weight = 10,
	pack_min = 2,
	pack_max = 3,
	biomes = {
		"FrozenOcean",
		"FrozenRiver",
		"IceSpikes",
		"SnowyBeach",
		"SnowyPlains",
		"SnowySlopes",
		"SnowyTaiga",
	},
})

local rabbit_spawner_grove = table.merge (rabbit_spawner_woody, {
	weight = 8,
	pack_min = 2,
	pack_max = 3,
	biomes = {
		"Grove",
	},
})

local rabbit_spawner_desert = table.merge (rabbit_spawner_woody, {
	weight = 4,
	pack_min = 2,
	pack_max = 3,
	biomes = {
		"Desert",
	},
})

mcl_mobs.register_spawner (rabbit_spawner_woody)
mcl_mobs.register_spawner (rabbit_spawner_meadow_or_cherry_grove)
mcl_mobs.register_spawner (rabbit_spawner_snowy)
mcl_mobs.register_spawner (rabbit_spawner_grove)
mcl_mobs.register_spawner (rabbit_spawner_desert)
