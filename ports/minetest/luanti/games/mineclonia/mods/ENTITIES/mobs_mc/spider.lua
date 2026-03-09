--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class

--###################
--################### SPIDER
--###################

-- Spider by AspireMint (fishyWET (CC-BY-SA 3.0 license for texture)
core.register_entity("mobs_mc:spider_eyes", {
	initial_properties = {
		pointable = false,
		visual = "mesh",
		mesh = "mobs_mc_spider.b3d",
		visual_size = {x=1.01/3, y=1.01/3},
		glow = 50,
		textures = {
			"mobs_mc_spider_eyes.png^[opacity:180",
		},
		selectionbox = {
			0, 0, 0, 0, 0, 0,
		},
		use_texture_alpha = true,
	},
	on_step = function(self)
		if self and self.object then
			if not self.object:get_attach() then
				self.object:remove()
			end
		end
	end,
})

local spider = {
	description = S("Spider"),
	type = "monster",
	_spawn_category = "monster",
	attack_type = "melee",
	_melee_esp = true,
	damage = 2,
	reach = 2,
	hp_min = 16,
	hp_max = 16,
	xp_min = 5,
	xp_max = 5,
	head_eye_height = 0.65,
	armor = {
		fleshy = 100,
		arthropod = 100,
	},
	head_swivel = "Head_Control",
	bone_eye_height = 1,
	curiosity = 10,
	head_yaw = "z",
	collisionbox = {-0.7, 0.0, -0.7, 0.7, 0.9, 0.7},
	visual = "mesh",
	mesh = "mobs_mc_spider.b3d",
	textures = {
		{"mobs_mc_spider.png"},
	},
	visual_size = {x=1, y=1},
	makes_footstep_sound = false,
	can_ride_boat = false,
	sounds = {
		random = "mobs_mc_spider_random",
		attack = "mobs_mc_spider_attack",
		damage = "mobs_mc_spider_hurt",
		death = "mobs_mc_spider_death",
		-- TODO: sounds: walk
		distance = 16,
	},
	movement_speed = 6.0,
	floats = 1,
	drops = {
		{
			name = "mcl_mobitems:string",
			chance = 1, min = 0, max = 2,
			looting = "common",
		},
		{
			name = "mcl_mobitems:spider_eye",
			chance = 3, min = 1, max = 1,
			looting = "common",
			looting_chance_function = function(lvl)
				return 1 - 2 / (lvl + 3)
			end,
		},
	},
	animation = {
		stand_speed = 10,
		walk_speed = 25,
		stand_start = 20,
		stand_end = 40,
		walk_start = 0,
		walk_end = 20,
	},
	always_climb = true,
	pace_bonus = 0.8,
	_saved_light_value = nil,
}

------------------------------------------------------------------------
-- Spider movement and physics.
------------------------------------------------------------------------

spider.slowdown_nodes = table.copy (mob_class.slowdown_nodes)
spider.slowdown_nodes["mcl_core:cobweb"] = nil

function spider:gopath_internal (target, speed_bonus, animation, tolerance, penalties)
	-- Record the destination so that this spider may attempt to
	-- scale walls obstructing movement to it.
	local rc = mob_class.gopath_internal (self, target, speed_bonus,
						animation, tolerance, penalties)
	if rc then
		self._gopath_destination
			= mcl_util.get_nodepos (target)
		return rc
	else
		return nil
	end
end

-- Prevent animations from being reset if an obstruction is being
-- climbed.
function spider:set_animation (anim, fixed_frame)
	if self._climbing_obstruction then
		anim = "walk"
	end
	mob_class.set_animation (self, anim, fixed_frame)
end

function spider:navigation_step (dtime, moveresult)
	mob_class.navigation_step (self, dtime, moveresult)

	if self:navigation_finished () then
		-- If navigation has completed but this spider is
		-- still separated from its target by an obstruction,
		-- continuing moving forward so as to climb over the
		-- obstruction.

		if self._gopath_destination then
			self._climbing_obstruction = true

			-- This renders spiders liable to cross
			-- hazards or stupidly run into obstructions
			-- if they fail to navigate to a target
			-- location.  Identical behavior may be
			-- observed in Minecraft.
			local dest = vector.offset (self._gopath_destination, 0, -0.5, 0)
			local self_pos = self.object:get_pos ()
			local dx = self_pos.x - dest.x
			local dz = self_pos.z - dest.z
			local bb_width = (self.collisionbox[4] - self.collisionbox[1]) / 2
			local dist_xz = math.sqrt (dx * dx + dz * dz)
			if ((self_pos.y <= dest.y and dist_xz > bb_width / 2)
				or dist_xz > bb_width) then
				self.movement_goal = "go_pos"
				self.movement_target = dest
				self.movement_velocity
					= self.gowp_velocity or self.movement_speed
			else
				self._climbing_obstruction = false
				self._gopath_destination = nil
				self:halt_in_tracks ()
			end
		end
	end
end

------------------------------------------------------------------------
-- Spider mechanics.
------------------------------------------------------------------------

local spider_effects = {
	"swiftness",
	"strength",
	"regeneration",
	"invisibility",
}

function spider:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	core.add_entity(self.object:get_pos (), "mobs_mc:spider_eyes")
		:set_attach(self.object, "body.head", vector.new(0,-0.98,2), vector.new(90,180,180))
	return true
end

function spider:on_spawn ()
	-- Spawn as jockeys ridden by skeletons 1% of the time.
	local self_pos = self.object:get_pos ()
	if math.random (100) == 1 then
		local skelly = core.add_entity (self_pos,
						"mobs_mc:skeleton")
		if skelly then
			local entity = skelly:get_luaentity ()
			local v = vector.zero ()
			entity:jock_to_existing (self.object, "", v, v)
		end
	end

	-- Occasionally spawn with various beneficial status effects
	-- on hard difficulty.
	if mcl_vars.difficulty == 3 then
		local random = math.random ()
		if random < 0.1 * mcl_worlds.get_special_difficulty (self_pos) then
			local effect = spider_effects[math.random (#spider_effects)]
			mcl_potions.give_effect (effect, self.object, 1, math.huge)
		end
	end
end

local r = 1.0 / 15.0

local function mc_light_value (self)
	local brightness, value
	local pos = self.object:get_pos ()
	brightness = (core.get_node_light (pos) or 0) * r
	value = brightness / (4 - 3 * brightness)
	return value
end

------------------------------------------------------------------------
-- Spider AI.
------------------------------------------------------------------------

function spider:attack_melee (self_pos, dtime, target_pos, line_of_sight)
	if not self.attacking then
		self._leaping = false
	end

	local moveresult = self._moveresult
	if self._leaping then
		if moveresult.touching_ground
			or moveresult.standing_on_object then
			self._leaping = false
		end
		-- Trigger a repath after leaping.
		self._target_pos = nil
		self._attack_delay = 0
		return
	end

	-- Possibly leap at the target.
	local dist = vector.distance (self_pos, target_pos)
	local chance = math.round (5 * dtime / 0.05)
	local r = math.random (chance)

	if self.attacking
		and dist > 2 and dist < 4 and r == 1
		and moveresult.touching_ground
			or moveresult.standing_on_object then
		self._leaping = true
		self:cancel_navigation ()
		self:halt_in_tracks ()
		local leap = vector.direction (self_pos, target_pos)
		local v = self.object:get_velocity ()
		leap.x = leap.x * 8.0 + v.x * 0.2
		leap.y = 8.0
		leap.z = leap.z * 8.0 + v.z * 0.2
		self:set_yaw (math.atan2 (leap.z, leap.x) - math.pi / 2)
		self.object:set_velocity (leap)
		return
	end

	mob_class.attack_melee (self, self_pos, dtime, target_pos, line_of_sight)
end

function spider:track_current_target (self_pos, dtime, obj, dist, persistence)
	local result = mob_class.track_current_target (self, self_pos, dtime,
						       obj, dist, persistence)
	if not result then
		return nil
	end
	-- Terminate aggression in daylight with a random probability,
	-- unless the target has actually provoked this mob.
	if persistence <= 3.0
		and math.random (100) == 1
		and self._saved_light_value >= 0.5 then
		return nil
	end
	return result
end

function spider:get_staticdata_table ()
	local tbl = mob_class.get_staticdata_table (self)
	if tbl then
		tbl._saved_light_value = nil
	end
	return tbl
end

function spider:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	if not self._saved_light_value
		or self:check_timer ("seek_target", 0.5) then
		self._saved_light_value = mc_light_value (self)
	end
end

local function spider_not_neutral_p (self)
	return self._saved_light_value < 0.5
end

spider.ai_functions = {
	mob_class.check_attack,
	mob_class.check_pace,
}

spider._targeting_rules = {
	mcl_mobs.build_retaliation_target_rule (),
	mcl_mobs.build_nearest_target_rule ("player", nil, spider_not_neutral_p,
					    nil, nil),
	mcl_mobs.build_nearest_target_rule ("mobs_mc:iron_golem", {
		"mobs_mc:iron_golem",
	}, spider_not_neutral_p, nil, nil),
}

mcl_mobs.register_mob ("mobs_mc:spider", spider)

------------------------------------------------------------------------
-- Cave spider.
------------------------------------------------------------------------

local cave_spider = table.merge (spider, {
	description = S("Cave Spider"),
	textures = {
		{"mobs_mc_cave_spider.png^(mobs_mc_spider_eyes.png^[makealpha:0,0,0)"}
	},
	hp_min = 12,
	hp_max = 12,
	head_eye_height = 0.5625,
	collisionbox = {-0.35, 0.0, -0.35, 0.35, 0.47, 0.35},
	visual_size = {
		x=0.55,
		y=0.5,
	},
	sounds = table.merge (spider.sounds, {
		base_pitch = 1.25,
	}),
	animation = table.merge (spider.animation, {
		walk_speed = 40,
	}),
	dealt_effect = {
		name = "poison",
		level = 1,
		dur_easy = 0,
		dur = 7,
		dur_hard = 15,
	},
})

function cave_spider:on_spawn ()
	-- Cave spiders cannot receive special status effects or spawn
	-- as jockeys.
end

mcl_mobs.register_mob ("mobs_mc:cave_spider", cave_spider)

------------------------------------------------------------------------
-- Spider spawning.
------------------------------------------------------------------------

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:spider", S("Spider"), "#342d26", "#a80e0e", 0)
mcl_mobs.register_egg("mobs_mc:cave_spider", S("Cave Spider"), "#0c424e", "#a80e0e", 0)

---------------------------------------------------------------
-- Modern Spider spawning.
---------------------------------------------------------------

local spider_spawner = table.merge (mobs_mc.monster_spawner, {
	name = "mobs_mc:spider",
	weight = 100,
	pack_max = 4,
	pack_min = 4,
	biomes = mobs_mc.monster_biomes,
})

mcl_mobs.register_spawner (spider_spawner)

local cave_spider_spawner = table.merge (mobs_mc.monster_spawner, {
	name = "mobs_mc:cave_spider",
	biomes = {},
	is_canonical = true,
})

mcl_mobs.register_spawner (cave_spider_spawner)
