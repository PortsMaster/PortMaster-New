--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes
local is_valid = mcl_util.is_valid_objectref

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class

--###################
--################### hoglin
--###################

local hoglin = {
	description = S("Hoglin"),
	type = "monster",
	_spawn_category = "monster",
	persist_in_peaceful = true,
	hp_min = 40,
	hp_max = 40,
	xp_min = 9,
	xp_max = 9,
	armor = {fleshy = 90},
	attack_type = "melee",
	melee_interval = 2,
	_attack_knockback = 1.0,
	reach = 3,
	collisionbox = {-.6, 0, -.6, .6, 1.4, .6},
	visual = "mesh",
	mesh = "extra_mobs_hoglin.b3d",
	textures = { {
		"extra_mobs_hoglin.png",
	} },
	visual_size = {x=3, y=3},
	sounds = {
		random = "extra_mobs_hoglin",
		damage = "extra_mobs_hoglin_hurt",
		death = "extra_mobs_hoglin_hurt",
		distance = 16,
	},
	makes_footstep_sound = true,
	can_ride_boat = false,
	movement_speed = 6.0,
	knockback_resistance = 0.6,
	damage = 6,
	avoid_nodes = {
		"mcl_crimson:warped_fungus",
		"mcl_flowerpots:flower_pot_warped_fungus",
		"mcl_portals:portal",
		"mcl_beds:respawn_anchor",
		"mcl_beds:respawn_anchor_charged_1",
		"mcl_beds:respawn_anchor_charged_2",
		"mcl_beds:respawn_anchor_charged_3",
		"mcl_beds:respawn_anchor_charged_4",
	},
	runaway_from = {
		"mobs_mc:piglin",
		"mobs_mc:sword_piglin",
	},
	drops = {
		{
			name = "mcl_mobitems:leather",
			chance = 1,
			min = 0,
			max = 1,
		},
		{
			name = "mcl_mobitems:porkchop",
			chance = 1,
			min = 2,
			max = 4,
		},
	},
	animation = {
		stand_start = 24, stand_end = 24, stand_speed = 15,
		walk_start = 11, walk_end = 21, walk_speed = 30,
		run_start = 1, run_end = 10, run_speed = 30,
		punch_start = 22, punch_end = 32, punch_speed = 20,
	},
	floats = 0,
	runaway_bonus_near = 0.6,
	runaway_bonus_far = 0.6,
	follow_bonus = 0.6,
	pace_bonus = 0.4,
	breed_bonus = 0.6,
	_nearby_hoglins = 0,
	_nearby_piglins = 0,
	_convert_to = "mobs_mc:zoglin",
	_nearby_piglin_list = {},
	_nearby_hoglin_list = {},
}

------------------------------------------------------------------------
-- Hoglin AI.
------------------------------------------------------------------------

function hoglin:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	if self._stay_passive_for then
		self._stay_passive_for
			= self._stay_passive_for - dtime
		if self._stay_passive_for <= 0 then
			self._stay_passive_for = nil
		end
	end
	local self_pos = self.object:get_pos ()
	self:conversion_step (self_pos, dtime)
	self:step_sensors (self_pos)
end

local function is_piglin (entity)
	return entity and (entity.name == "mobs_mc:sword_piglin"
			  or entity.name == "mobs_mc:piglin"
			  or entity.name == "mobs_mc:piglin_brute")
end

local function is_hoglin (entity)
	return entity and entity.name == "mobs_mc:hoglin"
end

function hoglin:step_sensors (self_pos)
	if not self:check_timer ("hoglin_sensing", 0.20) then
		return nil
	end

	local aa = vector.offset (self_pos, -8, -4, -8)
	local bb = vector.offset (self_pos, 8, 4, 8)
	local blocks = core.find_nodes_in_area (aa, bb, self.avoid_nodes)
	if #blocks > 0 then
		table.sort (blocks, function (a, b)
				    return vector.distance (self_pos, a)
					    < vector.distance (self_pos, b)
		end)
		self._closest_repellent = blocks[1]
		self._stay_passive_for = 10
	else
		self._closest_repellent = nil
	end

	-- Now count the number of visible nearby hoglins and hoglins.
	local hoglins = {}
	local piglins = {}
	local nearest_hoglin, distance_h = nil, 1000
	local nearest_piglin, distance_p = nil, 1000
	for object in core.objects_inside_radius (self_pos, 16) do
		local entity = object:get_luaentity ()
		if is_piglin (entity) and self:target_visible (self_pos, object) then
			table.insert (piglins, object)
			local new = vector.distance (self_pos, object:get_pos ())
			if distance_p > new then
				distance_p = new
				nearest_piglin = object
			end
		elseif is_hoglin (entity) and self:target_visible (self_pos, object) then
			table.insert (hoglins, object)
			local new = vector.distance (self_pos, object:get_pos ())
			if distance_h > new then
				distance_h = new
				nearest_hoglin = object
			end
		end
	end
	self._nearby_hoglins = #hoglins
	self._nearby_piglins = #piglins
	self._nearby_hoglin_list = hoglins
	self._nearby_piglin_list = piglins
	self._nearest_hoglin = nearest_hoglin
	self._nearest_piglin = nearest_piglin
end

function hoglin:get_staticdata_table ()
	local supertable = mob_class.get_staticdata_table (self)
	if supertable then
		supertable._nearest_hoglin = nil
		supertable._nearest_piglin = nil
		supertable._nearby_hoglin_list = nil
		supertable._nearby_piglin_list = nil
		supertable._nearby_hoglins = 0
		supertable._nearby_piglins = 0
	end
	return supertable
end

local function hoglin_avoid_repellent (self, self_pos, dtime)
	if self._avoiding_repellent then
		if self:navigation_finished () then
			self._avoiding_repellent = false
			return false
		end
		return true
	elseif self._closest_repellent
		and vector.distance (self_pos, self._closest_repellent) < 8 then
		local target
			= self:target_away_from (self_pos, self._closest_repellent)
		if target then
			self:gopath (target)
			self._avoiding_repellent = true
			return true
		end
	end
	return false
end

local function hoglin_retreat (self, self_pos, dtime)
	if self._retreating then
		self._retreat_asap = false
		self._retreat_time = self._retreat_time - dtime
		local retreat_pos = self._retreating:get_pos ()
		if self._nearby_hoglins > self._nearby_piglins
			or self._retreat_time <= 0
			or not retreat_pos
			or vector.distance (self_pos, retreat_pos) > 15 then
			self:cancel_navigation ()
			self:halt_in_tracks ()
			self._retreating = nil
			return false
		end
		if self:navigation_finished () then
			local target = self:target_away_from (self_pos, retreat_pos)
			if target then
				self:gopath (target, 1.3)
			end
		end
		return true
	elseif self._retreat_asap then
		-- Retreat from the current target if one exists.
		self._retreat_asap = false
		local piglin = self._retreat_from
			or self.attack
			or self._nearest_piglin
		if not piglin then
			return false
		end
		self._retreat_from = false
		local pos = piglin:get_pos ()
		if not pos then
			return false
		end
		local target = self:target_away_from (self_pos, pos)
		if target then
			self:gopath (target, 1.3)
			self._retreating = piglin
			self._retreat_time = math.random (5, 20)
			return "_retreating"
		end
	end
	return false
end

function hoglin:beat_a_retreat (hitter)
	self._retreat_asap = true
	self._retreat_from = hitter
	if self.child then
		return
	end
	for _, hoglin in pairs (self._nearby_hoglin_list) do
		if hoglin ~= self.object then
			local entity = hoglin:get_luaentity ()
			if entity then
				entity._retreat_asap = true
			end
		end
	end
end

function hoglin:call_group_attack (hitter)
	-- Retreat if outnumbered.
	if self.child
		or is_piglin (hitter)
			and self._nearby_piglins > self._nearby_hoglins then
		self:beat_a_retreat (hitter)
		return false
	else -- Otherwise call reinforcements.
		local entity = hitter:get_luaentity ()
		local pos = hitter:get_pos ()
		for _, hoglin in pairs (self._nearby_hoglin_list) do
			-- If the hitter isn't a hoglin or the hoglin
			-- is not retreating, retaliate.
			local hoglin = hoglin:get_luaentity ()
			if hoglin and hoglin ~= self
				and (not hoglin._retreating or not is_piglin (entity)) then
				if hoglin.attack and is_valid (hoglin.attack) then
					local hoglin_pos = hoglin.object:get_pos ()
					local attack_pos = hoglin.attack:get_pos ()
					local d1 = vector.distance (pos, hoglin_pos)
					local d2 = vector.distance (attack_pos, hoglin_pos)
					-- Don't attack if the current
					-- target is closer by four
					-- nodes.
					if d2 - d1 < 4.0 then
						hoglin:receive_attack (hitter)
					end
				else
					hoglin:receive_attack (hitter)
				end
			end
		end
		return true
	end
end

function hoglin:acceptable_pacing_target (pos)
	if self._closest_repellent then
		local pos1 = self._closest_repellent
		return vector.distance (vector.offset (pos, 0, 1, 0), pos1) <= 8.0
	end
	return true
end

function hoglin:breeding_possible ()
	return not self._stay_passive_for
end

local function get_knockback_resistance (object)
	local entity = object:get_luaentity ()
	if entity then
		return entity.knockback_resistance or 0.0
	end
	return 0.0
end

function hoglin:custom_attack ()
	self:set_animation ("punch")
	self._punch_animation_timeout = 0.52
	local damage = self.damage
	if not self.child and damage > 0 then
		damage = damage / 2.0 + math.random (0, damage - 1)
	end
	mcl_util.deal_damage (self.attack, damage, {
		type = "mob",
		source = self.object,
	})
	-- self.attack may be reset if the target dies or is removed.
	if not self.attack or not self.attack:is_valid () then
		return
	end
	local knockback = 1.0 - get_knockback_resistance (self.attack)
	if knockback > 0 and not self.child then
		local self_pos = self.object:get_pos ()
		local attack_pos = self.attack:get_pos ()
		local dx = attack_pos.x - self_pos.x
		local dz = attack_pos.z - self_pos.z
		local random = math.rad (math.random (21) - 10)
		local xz_mag = knockback * (math.random () * 0.5 + 0.2)
		local v = vector.new (dx, 0, dz)
		v = vector.normalize (v)
		v = vector.multiply (v, xz_mag * 20)
		v = vector.rotate_around_axis (v, {x = 0, y = 1, z = 0,}, random)

		if not self.attack:is_player () then
			v.y = knockback * (math.random () * 10)
		else
			v.y = math.random () * 20
		end
		if mcl_serverplayer.is_csm_capable (self.attack) then
			local v1 = vector.add (v, self.attack:get_velocity ())
			mcl_serverplayer.send_knockback (self.attack, v1)
		else
			self.attack:add_velocity (v)
		end
	end
	if is_piglin (self.attack)
		and self.child
			or self._nearby_piglins > self._nearby_hoglins then
		self:beat_a_retreat (self.attack)
	end
end

hoglin.ai_functions = {
	hoglin_avoid_repellent,
	hoglin_retreat,
	mob_class.check_breeding,
	mob_class.check_attack,
	mob_class.check_avoid,
	mob_class.follow_herd,
	mob_class.check_pace,
}

local function hoglin_check_passivity (self, _)
	return self._stay_passive_for == nil
end

local function hoglin_strategize_rule (self, self_pos, dtime, obj, is_current)
	if is_current then
		local dist = self.tracking_distance * self.tracking_distance
		return self:track_current_target (self_pos, dtime, obj, dist, 15.0)
	end

	local attacker = self:read_last_attacker ()
	local do_attack = nil
	if attacker then
		local obj_pos = attacker:get_pos ()
		-- If this attacker is a valid target.
		if self:test_object_and_restriction (attacker, obj_pos)
		-- ... and reinforcements are in fact summoned.
			and self:call_group_attack (attacker)
		-- ... and the target is within range not only of the
		-- reinforcements but also this mob.
			and vector.distance (self_pos, obj_pos) < self.view_range then
			-- .. then retaliate against it.
			do_attack = attacker
		end
	end
	return do_attack
end

hoglin._targeting_rules = {
	mcl_mobs.build_target_rule ({
		fn = hoglin_strategize_rule,
		on_complete = nil,
	}),
	mcl_mobs.build_nearest_target_rule ("player", nil, hoglin_check_passivity,
					    nil, false),
	mcl_mobs.build_alert_receiver_rule (),
}

------------------------------------------------------------------------
-- Hoglin breeding.
------------------------------------------------------------------------

function hoglin:on_rightclick (clicker)
	if self.child or not clicker or not clicker:is_player () then
		return
	end
	local item = clicker:get_wielded_item ()
	if item:get_name () == "mcl_crimson:crimson_fungus" then
		self:feed_tame (clicker, 4, true, false)
	end
end

function hoglin:on_breed (parent1)
	local pos = parent1.object:get_pos ()
	local child = core.add_entity (pos, "mobs_mc:baby_hoglin")
	if not child then
		return
	end

	mcl_mobs.effect (pos, 15, "mcl_particles_smoke.png", 1, 2, 2, 15, 5)
end

function hoglin:on_grown ()
	mcl_util.replace_mob (self.object, "mobs_mc:hoglin")
	self.object:set_detach ()
end

------------------------------------------------------------------------
-- Hoglin metamorphosis.
------------------------------------------------------------------------

function hoglin:conversion_step (self_pos, dtime)
	local dimension = mcl_worlds.pos_to_dimension (self_pos)
	if dimension == "overworld" then
		if not self._conversion_time then
			self._conversion_time = 0
		end
		self.shaking = true
		self._conversion_time
			= self._conversion_time + dtime
		if self._conversion_time > 15 then
			local object
				= mcl_util.replace_mob (self.object, self._convert_to)
			if object then
				mcl_potions.give_effect ("nausea", object, 1, 10, false)
			end
		end
	else
		self.shaking = false
		self._conversion_time = 0
	end
end

mcl_mobs.register_mob ("mobs_mc:hoglin", hoglin)

------------------------------------------------------------------------
-- Baby Hoglins.
------------------------------------------------------------------------

mcl_mobs.register_mob("mobs_mc:baby_hoglin", table.merge (hoglin, {
	description = S("Baby Hoglin"),
	collisionbox = {-.3, -0.01, -.3, .3, 0.94, .3},
	xp_min = 20,
	xp_max = 20,
	visual_size = {
		x = 1,
		y = 1,
	},
	mesh = "mobs_mc_baby_hoglin.b3d",
	textures = {
		{
			"extra_mobs_hoglin.png",
			"blank.png",
		},
	},
	movement_speed = 6.0,
	child = 1,
	reach = 1.0,
	damage = 0.5,
	melee_interval = 0.75,
	_convert_to = "mobs_mc:baby_zoglin",
	can_ride_boat = true,
}))

------------------------------------------------------------------------
-- Hoglin spawning.
------------------------------------------------------------------------

-- Spawn eggs.
mcl_mobs.register_egg("mobs_mc:hoglin", S("Hoglin"), "#85682e", "#2b2140", 0)

------------------------------------------------------------------------
-- Modern Hoglin spawning.
------------------------------------------------------------------------

local default_spawner = mcl_mobs.default_spawner
local monster_spawner = mobs_mc.monster_spawner

local hoglin_spawner = table.merge (monster_spawner, {
	name = "mobs_mc:hoglin",
	spawn_category = "monster",
	pack_min = 3,
	pack_max = 4,
	biomes = {
		"CrimsonForest",
	},
	weight = 9,
})

function hoglin_spawner:spawn (spawn_pos, _)
	if math.random () >= 0.2 then
		return core.add_entity (spawn_pos, "mobs_mc:hoglin")
	else
		return core.add_entity (spawn_pos, "mobs_mc:baby_hoglin")
	end
end

function hoglin_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache,
					     spawn_flag)
	if mcl_vars.difficulty == 0 then
		return false
	end
	local node = self:get_node (node_cache, -1, node_pos)
	return node.name ~= "mcl_nether:nether_wart_block"
		and default_spawner.test_spawn_position (self, spawn_pos,
							 node_pos, sdata,
							 node_cache,
							 spawn_flag)
end

function hoglin_spawner:describe_criteria (tbl, omit_group_details)
	monster_spawner.describe_criteria (self, tbl, omit_group_details)
	table.insert (tbl, S ("Hoglins do not spawn above Nether Wart blocks."))
	table.insert (tbl, S ("20% of Hoglins spawn as their baby variants."))
end

mcl_mobs.register_spawner (hoglin_spawner)

------------------------------------------------------------------------
-- Zoglins.
------------------------------------------------------------------------

local zoglin = table.merge (hoglin, {
	description = S("Zoglin"),
	fire_resistant = 1,
	textures = {"extra_mobs_zoglin.png"},
	lava_damage = 0,
	fire_damage = 0,
	armor = {
		undead = 90,
		fleshy = 90,
	},
	harmed_by_heal = true,
	sounds = {
		random = "extra_mobs_hoglin",
		damage = "extra_mobs_hoglin_hurt",
		death = "extra_mobs_hoglin_hurt",
		distance = 16,
	},
	ai_functions = {
		mob_class.check_attack,
		mob_class.check_pace,
	},
	group_attack = false,
	runaway_from = nil,
})

local function zoglin_attack_predicate (self, self_pos, obj, entity)
	return not entity -- Players.
		or (entity.name ~= "mobs_mc:creeper"
		    and entity.name ~= "mobs_mc:creeper_charged"
		    and entity.name ~= "mobs_mc:zoglin"
		    and entity.name ~= "mobs_mc:baby_zoglin")
end

zoglin._targeting_rules = {
	mcl_mobs.build_nearest_target_rule ("entity", zoglin_attack_predicate,
					     nil, nil, nil),
}

zoglin.ai_step = nil
zoglin.get_staticdata_table = mob_class.get_staticdata_table

mcl_mobs.register_mob ("mobs_mc:zoglin", zoglin)

------------------------------------------------------------------------
-- Baby Zoglins.
------------------------------------------------------------------------

local baby_zoglin = table.merge (hoglin, {
	collisionbox = {-.3, -0.01, -.3, .3, 0.94, .3},
	xp_min = 20,
	xp_max = 20,
	visual_size = {
		x = 1,
		y = 1,
	},
	mesh = "mobs_mc_baby_hoglin.b3d",
	movement_speed = 6.0,
	child = 1,
	reach = 1.0,
	damage = 0.5,
	melee_interval = 0.75,
	can_ride_boat = true,
	description = S("Zoglin"),
	fire_resistant = 1,
	textures = {"extra_mobs_zoglin.png"},
	lava_damage = 0,
	fire_damage = 0,
	armor = {
		undead = 90,
		fleshy = 90,
	},
	harmed_by_heal = true,
	sounds = {
		random = "extra_mobs_hoglin",
		damage = "extra_mobs_hoglin_hurt",
		death = "extra_mobs_hoglin_hurt",
		distance = 16,
	},
	ai_functions = {
		mob_class.check_attack,
		mob_class.check_pace,
	},
	group_attack = false,
	avoid_nodes = nil,
})

function baby_zoglin:tick_breeding ()
	-- Prevent this from ever growing up
end

baby_zoglin.ai_step = nil
baby_zoglin.call_group_attack = mob_class.call_group_attack
baby_zoglin.get_staticdata_table = mob_class.get_staticdata_table

mcl_mobs.register_mob ("mobs_mc:baby_zoglin", baby_zoglin)
