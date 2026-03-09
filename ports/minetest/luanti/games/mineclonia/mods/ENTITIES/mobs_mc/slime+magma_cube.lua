--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator ("mobs_mc")

local slime_chunk_spawn_max = -24 -- Y=40 in Minecraft.

local only_peaceful_mobs
	= core.settings:get_bool ("only_peaceful_mobs", false)

local function in_slime_chunk (pos)
	return mcl_biome_dispatch.is_slime_chunk (pos.x, pos.z)
end

local mob_class = mcl_mobs.mob_class

------------------------------------------------------------------------
-- Slime.
------------------------------------------------------------------------

local slime = {
	description = S ("Slime"),
	type = "monster",
	_spawn_category = "monster",
	hp_min = 16,
	hp_max = 16,
	xp_min = 4,
	xp_max = 4,
	textures = {{"mobs_mc_slime.png", "mobs_mc_slime.png"}},
	visual = "mesh",
	mesh = "mobs_mc_slime.b3d",
	makes_footstep_sound = true,
	does_not_prevent_sleep = true,
	sounds = {
		jump = "green_slime_jump",
		death = "green_slime_death",
		damage = "green_slime_damage",
		attack = "green_slime_attack",
		distance = 16,
	},
	sound_params = {
		gain = 1,
	},
	damage = 4,
	reach = 3,
	armor = 100,
	drops = {},
	animation = {
		jump_start = 1,
		jump_end = 20,
		jump_speed = 24,
		jump_loop = false,
		stand_speed = 0,
		walk_speed = 0,
		stand_start = 1,
		stand_end = 1,
		walk_start = 1,
		walk_end = 1,
	},
	fall_damage = 0,
	use_texture_alpha = true,
	attack_type = "null",
	jump_delay_multiplier = 1,
	_get_slime_particle = function ()
		return "[combine:" .. math.random (3)
			.. "x" .. math.random (3) .. ":-"
			.. math.random (4) .. ",-"
			.. math.random (4) .. "=mcl_core_slime.png"
	end
}

------------------------------------------------------------------------
-- Slime mechanics.
------------------------------------------------------------------------

-- Return a function that spawns children in a circle around pos.
-- To be used as on_die callback.
-- self: mob reference
-- pos: position of "mother" mob
-- child_mod: Mob to spawn
-- spawn_distance: Spawn distance from "mother" mob
-- eject_speed: Initial speed of child mob away from "mother" mob
local spawn_children_on_die = function(child_mob, spawn_distance, eject_speed)
	return function(self, pos)
		local posadd, newpos, dir
		if not eject_speed then
			eject_speed = 1
		end
		local mndef = core.registered_nodes[core.get_node(pos).name]
		local mother_stuck = mndef and mndef.walkable
		local angle = math.random(0, math.pi*2)
		local spawn_count = math.random(2, 4)
		for _ = 1, spawn_count do
			dir = vector.new(math.cos(angle), 0, math.sin(angle))
			posadd = vector.normalize(dir) * spawn_distance
			newpos = pos + posadd
			-- If child would end up in a wall, use
			-- position of the "mother", unless the
			-- "mother" was stuck as well
			if not mother_stuck then
				local cndef = core.registered_nodes[core.get_node(newpos).name]
				if cndef and cndef.walkable then
					newpos = pos
					eject_speed = eject_speed * 0.5
				end
			end
			local mob = core.add_entity (newpos, child_mob, core.serialize({
				persist_in_peaceful = self.persist_in_peaceful,
			}))
			if mob and mob:get_pos() and not mother_stuck then
				mob:set_velocity(dir * eject_speed)
			end
		end
	end
end

------------------------------------------------------------------------
-- Slime movement.
------------------------------------------------------------------------

function slime:do_go_pos (dtime, moveresult)
	-- The target position is ignored.
	local speed = self.movement_velocity

	if not self._next_jump then
		self._next_jump = 0
	end

	local delay = math.max (0, self._next_jump - dtime)
	if delay == 0 or self._in_water
		or not (moveresult.touching_ground
			or moveresult.standing_on_object) then
		if delay == 0 then
			self._jump = true
			delay = (math.random (60) + 40) / 20 * self.jump_delay_multiplier
			if self.attack then
				delay = delay / 3
			end
		end
		self.acc_dir.z = speed / 20
		self.acc_speed = speed
	else
		self.acc_dir.z = 0
		self.acc_speed = 0
	end
	self._next_jump = delay
end

------------------------------------------------------------------------
-- Slime visuals.
------------------------------------------------------------------------

local function slime_check_particle (self, dtime, moveresult)
	if not self._slime_was_touching_ground
		and moveresult.touching_ground
		and self._get_slime_particle then
		local cbox = self.collisionbox
		local radius = (cbox[6] - cbox[3]) * 0.75
		local self_pos = self.object:get_pos ()
		local v = 1
		core.add_particlespawner ({
			amount = math.round (radius * 32),
			minpos = vector.offset (self_pos, -radius, 0, -radius),
			maxpos = vector.offset (self_pos, radius, 0, radius),
			minvel = vector.new (-v, 0, -v),
			maxvel = vector.new (v, 0, v),
			minacc = vector.new (0, 0, 0),
			maxacc = vector.new (0, 0, 0),
			texture = self._get_slime_particle (),
			time = 0.1,
			minexptime = 0.1,
			maxexptime = 0.6,
			minsize = 0.5,
			maxsize = 1.5,
			glow = self._slime_particle_glow,
		})
	end
	self._slime_was_touching_ground = moveresult.touching_ground
end

function slime:do_custom (dtime, moveresult)
	slime_check_particle (self, dtime, moveresult)
end

------------------------------------------------------------------------
-- Slime AI.
------------------------------------------------------------------------

local function slime_turn (self, dtime, self_pos)
	if not self.attack then
		local standing_on = core.registered_nodes[self.standing_on]
		local remaining = self._next_turn
		if not remaining or remaining == 0 then
			remaining = (math.random (60) + 40) / 20
		end

		if standing_on and (standing_on.walkable
				    or standing_on.liquidtype ~= "none") then
			remaining = math.max (0, remaining - dtime)
			if remaining == 0 then
				local angle = math.random () * 2 * math.pi
				self:set_yaw (angle)
			end
		end
		self._next_turn = remaining
	else
		local target_pos = self.attack:get_pos ()
		local dz, dx = target_pos.z - self_pos.z, target_pos.x - self_pos.x
		local yaw = math.atan2 (dz, dx) - math.pi / 2

		self:set_yaw (yaw)
	end
end

local function slime_jump_continuously (self)
	local factor = 1
	self._in_water = false
	if core.get_item_group (self.standing_in, "water") ~= 0
		or core.get_item_group (self.standing_in, "lava") ~= 0 then
		factor = 1.2
		self._in_water = true
	end
	self.movement_goal = "go_pos"
	self.movement_velocity = self.movement_speed * factor
	-- movement_target is disregarded by slimes.
end

local function slime_check_attack (self, self_pos, dtime)
	if not self.attack then
		return
	end
	self._attack_cooldown = math.max (self._attack_cooldown - dtime, 0)
	local target_pos = self.attack:get_pos ()
	local girth = self.collisionbox[6] - self.collisionbox[3]
	if vector.distance (target_pos, self_pos) <= girth + 0.25
	   and self._attack_cooldown == 0 then
		self:custom_attack ()
		self._attack_cooldown = 0.5
	end
end

function slime:run_ai (dtime)
	local self_pos = self.object:get_pos ()

	if self.dead then
		return
	end

	self:check_attack (self_pos, dtime)
	slime_turn (self, dtime, self_pos)
	slime_jump_continuously (self)
	slime_check_attack (self, self_pos, dtime)
end

function slime:switch_targeting_rule (fn_old, fn_new)
	mob_class.switch_targeting_rule (self, fn_old, fn_new)
	if fn_new then
		if self._next_jump then
			self._next_jump = self._next_jump / 3
		end
		self._attack_cooldown = 0.5 -- Minecraft damage immunity.
	end
end

local mathabs = math.abs

local function slime_player_attackable_p (self, self_pos, obj, _)
	-- Slimes should not notice players till they are within 4.0
	-- blocks vertically of themselves.
	return mathabs (obj:get_pos ().y - self_pos.y) <= 4.0
end

slime._targeting_rules = {
	mcl_mobs.build_nearest_target_rule ("player", slime_player_attackable_p,
					    nil, nil, nil),
	mcl_mobs.build_nearest_target_rule ("mobs_mc:iron_golem", {"mobs_mc:iron_golem",},
					    nil, nil, nil),
}

------------------------------------------------------------------------
-- Slime spawning & registration.
------------------------------------------------------------------------

local slime_big = table.merge (slime, {
	hp_min = 16,
	hp_max = 16,
	xp_min = 4,
	xp_max = 4,
	collisionbox = {-1.02, 0.0, -1.02, 1.02, 2.0, 1.02},
	visual_size = {x=12.5, y=12.5},
	can_ride_boat = false,
	movement_speed = 10, -- (0.2 + 0.1 * size) * 20
	spawn_small_alternative = "mobs_mc:slime_small",
	on_die = spawn_children_on_die ("mobs_mc:slime_small", 1.0, 1.5),
})
mcl_mobs.register_mob ("mobs_mc:slime_big", slime_big)

local slime_small = table.merge (slime, {
	sounds = table.merge (slime.sounds, {
		base_pitch = 1.15,
	}),
	hp_min = 4,
	hp_max = 4,
	xp_min = 2,
	xp_max = 2,
	collisionbox = {-0.51, 0.0, -0.51, 0.51, 1.00, 0.51},
	visual_size = {x=6.25, y=6.25},
	damage = 3,
	reach = 2.75,
	movement_speed = 6.0,
	spawn_small_alternative = "mobs_mc:slime_tiny",
	on_die = spawn_children_on_die ("mobs_mc:slime_tiny", 0.6, 1.0),
	sound_params = table.merge (slime.sound_params, {
		gain = slime.sound_params.gain / 3.0,
	}),
})
mcl_mobs.register_mob ("mobs_mc:slime_small", slime_small)

local slime_tiny = table.merge (slime, {
	sounds = table.merge (slime.sounds, {
		base_pitch = 1.3,
	}),
	hp_min = 1,
	hp_max = 1,
	xp_min = 1,
	xp_max = 1,
	collisionbox = {-0.2505, 0.0, -0.2505, 0.2505, 0.50, 0.2505},
	visual_size = {x=3.125, y=3.125},
	damage = 0,
	reach = 2.5,
	drops = {
		 {
			 name = "mcl_mobitems:slimeball",
			 chance = 1,
			 min = 0,
			 max = 2,
		 },
	},
	can_ride_boat = true,
	movement_speed = 4.0,
	sound_params = table.merge (slime.sound_params, {
		gain = slime.sound_params.gain / 9.0,
	}),
})
mcl_mobs.register_mob ("mobs_mc:slime_tiny", slime_tiny)

mcl_mobs.register_egg ("mobs_mc:slime_big", S ("Slime"), "#52a03e", "#7ebf6d")

------------------------------------------------------------------------
-- Modern Slime spawning.
------------------------------------------------------------------------

-- If the light level is equal to or less than a random integer (from 0 to 7)
-- If the fraction of the moon that is bright is greater than a random number (from 0 to 1)
-- If these conditions are met and the altitude is acceptable, there is a 50% chance of spawning a slime.
-- https://minecraft.wiki/w/Slime#Swamps

local function swamp_spawn (pos)
	local light = (core.get_node_light (pos) or core.LIGHT_MAX)
	if light > math.random (0,7) then
		return false
	end
	-- Moon phase 4 is the new moon in mcl_moon.
	if math.abs(4 - mcl_moon.get_moon_phase()) / 4 < math.random() then
		return false
	end
	if math.random(2) == 2 then
		return false
	end
	return true
end

local default_spawner = mcl_mobs.default_spawner
local slime_spawner = table.merge (default_spawner, {
	spawn_placement = "ground",
	spawn_category = "monster",
	name = "mobs_mc:slime_big", -- Nominal name; governs collision tests.
	weight = 100,
	pack_max = 4,
	pack_min = 4,
	biomes = mobs_mc.monster_biomes,
})
local swamp_or_mangrove_swamp_p

core.register_on_mods_loaded (function ()
	swamp_or_mangrove_swamp_p = mcl_biome_dispatch.make_biome_test ({
		"Swamp",
		"MangroveSwamp",
	})
end)

function slime_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache,
					    spawn_flag)
	if mcl_vars.difficulty == 0 or only_peaceful_mobs then
		return false
	end

	local name = mcl_biome_dispatch.get_biome_name (node_pos)
	if (swamp_or_mangrove_swamp_p (name) and swamp_spawn (spawn_pos))
		or spawn_flag == "spawner"
		or spawn_flag == "trial_spawner" then
		if default_spawner.test_spawn_position (self, spawn_pos,
							node_pos, sdata,
							node_cache,
							spawn_flag) then
			return true
		end
	end

	if spawn_pos.y <= slime_chunk_spawn_max + 0.5
		and math.random (1, 10) <= 6
		and in_slime_chunk (node_pos) then
		if default_spawner.test_spawn_position (self, spawn_pos,
							node_pos, sdata,
							node_cache,
							spawn_flag) then
			return true
		end
	end
	return false
end

function slime_spawner:spawn (spawn_pos, _)
	local slime_type = "mobs_mc:slime_tiny"

	local random = math.random (1, 3)
	if math.random () < 0.5 * mcl_worlds.get_special_difficulty (spawn_pos) then
		random = math.max (random + 1, 3)
	end
	if random == 2 then
		slime_type = "mobs_mc:slime_small"
	elseif random == 3 then
		slime_type = "mobs_mc:slime_big"
	end

	return core.add_entity (spawn_pos, slime_type)
end

function slime_spawner:describe_criteria (tbl, omit_group_details)
	default_spawner.describe_criteria (self, tbl, omit_group_details)
	table.insert (tbl, "Slimes spawn in one of three size variants, which is decided at random, influenced by the regional difficulty at the positions where they generate.")
	table.insert (tbl, "In Swamp and Mangrove Swamp biomes, Slimes spawn on the surface at light levels between 0 to 7 with a probability that increases with proximity to the new moon.")
	table.insert (tbl, "In other biomes, slimes spawn in 1/10 of all 16x384x16 chunks at Y levels of -24 and below, in any light level.")
end

mcl_mobs.register_spawner (slime_spawner)

------------------------------------------------------------------------
-- Magma Cube.
------------------------------------------------------------------------

local magma_cube = table.merge (slime, {
	description = S ("Magma Cube"),
	type = "monster",
	_spawn_category = "monster",
	textures = {{ "mobs_mc_magmacube.png", "mobs_mc_magmacube.png" }},
	visual = "mesh",
	mesh = "mobs_mc_magmacube.b3d",
	sounds = {
		jump = "mobs_mc_magma_cube_big",
		death = "mobs_mc_magma_cube_big",
		attack = "mobs_mc_magma_cube_attack",
		distance = 16,
	},
	sound_params = {
		gain = 1,
		max_hear_distance = 16,
	},
	damage = 6,
	reach = 3,
	armor = 53,
	drops = {
		{
			name = "mcl_mobitems:magma_cream",
			chance = 4,
			min = 1,
			max = 1,
		},
	},
	animation = {
		jump_speed = 40,
		jump_loop = false,
		stand_speed = 0,
		walk_speed = 0,
		jump_start = 0,
		jump_end = 50,
		stand_start = 0,
		stand_end = 0,
		walk_start = 0,
		walk_end = 0,
	},
	jump_delay_multiplier = 4,
	water_damage = 0,
	_mcl_freeze_damage = 5,
	lava_damage = 0,
        fire_damage = 0,
	fall_damage = 0,
	_get_slime_particle = function ()
		return "mcl_particles_fire_flame.png"
	end,
	attack_type = "null",
	_slime_particle_glow = 14,
})

-- Magma cube
local magma_cube_big = table.merge (magma_cube, {
	hp_min = 16,
	hp_max = 16,
	xp_min = 4,
	xp_max = 4,
	collisionbox = {-1.02, 0.0, -1.02, 1.02, 2.03, 1.02},
	visual_size = {x=12.5, y=12.5},
	can_ride_boat = false,
	movement_speed = 10.0,
	damage = 6,
	reach = 3,
	armor = 53,
	jump_height = 14.4,
	spawn_small_alternative = "mobs_mc:magma_cube_small",
	on_die = spawn_children_on_die ("mobs_mc:magma_cube_small", 0.8, 1.5),
	fire_resistant = true,
	_get_slime_particle = function ()
		return "mcl_particles_fire_flame.png"
	end,
	attack_type = "null",
	_slime_particle_glow = 14,
})
mcl_mobs.register_mob ("mobs_mc:magma_cube_big", magma_cube_big)

local magma_cube_small = table.merge (magma_cube, {
	sounds = {
		jump = "mobs_mc_magma_cube_small",
		death = "mobs_mc_magma_cube_small",
		attack = "mobs_mc_magma_cube_attack",
		distance = 16,
	},
	hp_min = 4,
	hp_max = 4,
	xp_min = 2,
	xp_max = 2,
	collisionbox = {-0.51, 0.0, -0.51, 0.51, 1.00, 0.51},
	visual_size = {x=6.25, y=6.25},
	movement_speed = 6.0,
	jump_height = 12.4,
	damage = 4,
	reach = 2.75,
	armor = 66,
	spawn_small_alternative = "mobs_mc:magma_cube_tiny",
	on_die = spawn_children_on_die ("mobs_mc:magma_cube_tiny", 0.6, 1.0),
	sound_params = {
		gain = 0.7,
		max_hear_distance = 16,
	},
})
mcl_mobs.register_mob ("mobs_mc:magma_cube_small", magma_cube_small)

local magma_cube_tiny = table.merge (magma_cube, {
	sounds = {
		jump = "mobs_mc_magma_cube_small",
		death = "mobs_mc_magma_cube_small",
		attack = "mobs_mc_magma_cube_attack",
		distance = 16,
		base_pitch = 1.25,
	},
	hp_min = 1,
	hp_max = 1,
	xp_min = 1,
	xp_max = 1,
	collisionbox = {-0.2505, 0.0, -0.2505, 0.2505, 0.50, 0.2505},
	visual_size = {x=3.125, y=3.125},
	can_ride_boat = true,
	movement_speed = 4.0,
	jump_height = 8.4,
	damage = 3,
	reach = 2.5,
	armor = 50,
	drops = {},
	spawn_small_alternative = nil,
	on_die = nil,
	sound_params = {
		gain = 0.25,
		max_hear_distance = 16,
	},
})

mcl_mobs.register_mob ("mobs_mc:magma_cube_tiny", magma_cube_tiny)

------------------------------------------------------------------------
-- Magma Cube spawning.
------------------------------------------------------------------------

mcl_mobs.register_egg ("mobs_mc:magma_cube_big", S ("Magma Cube"), "#350000", "#fcfc00")

------------------------------------------------------------------------
-- Modern Magma Cube spawning.
------------------------------------------------------------------------

local default_spawner = mcl_mobs.default_spawner

local magma_cube_spawner = {
	name = "mobs_mc:magma_cube_big",
	spawn_category = "monster",
	weight = 2,
	pack_min = 4,
	pack_max = 4,
	biomes = {
		"NetherWastes",
	},
}

function magma_cube_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache,
						 spawn_flag)
	return mcl_vars.difficulty > 0
		and default_spawner.test_spawn_position (self, spawn_pos,
							 node_pos, sdata,
							 node_cache, spawn_flag)
end

function magma_cube_spawner:spawn (spawn_pos, _)
	local slime_type = "mobs_mc:magma_cube_tiny"

	local random = math.random (1, 3)
	if math.random () < 0.5 * mcl_worlds.get_special_difficulty (spawn_pos) then
		random = math.max (random + 1, 3)
	end
	if random == 2 then
		slime_type = "mobs_mc:magma_cube_small"
	elseif random == 3 then
		slime_type = "mobs_mc:magma_cube_big"
	end

	return core.add_entity (spawn_pos, slime_type)
end

function magma_cube_spawner:describe_criteria (tbl, omit_group_details)
	default_spawner.describe_criteria (self, tbl, omit_group_details)
	table.insert (tbl, "Magma Cubes spawn in any light level in one of three size variants, which is decided at random, influenced by the regional difficulty at the positions where they generate.")
end

local magma_cube_spawner_basalt_delta = table.merge (magma_cube_spawner, {
	weight = 100,
	pack_min = 2,
	pack_max = 5,
	biomes = {
		"BasaltDeltas",
	},
})

local magma_cube_spawner_nether_fortress = table.merge (magma_cube_spawner, {
	weight = 3,
	pack_min = 4,
	pack_max = 4,
	biomes = {},
	structures = {
		"mcl_levelgen:nether_fortress",
	},
})

mcl_mobs.register_spawner (magma_cube_spawner)
mcl_mobs.register_spawner (magma_cube_spawner_basalt_delta)
mcl_mobs.register_spawner (magma_cube_spawner_nether_fortress)
