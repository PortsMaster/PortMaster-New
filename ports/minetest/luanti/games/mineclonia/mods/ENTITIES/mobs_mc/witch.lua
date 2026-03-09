--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class
local raid_mob = mobs_mc.raid_mob

--###################
--################### WITCH
--###################

local WIELD_POSITION = vector.copy ({
	x = 0,
	y = 1.26138 + math.sin (math.rad (-135)) * -0.4,
	z = math.cos (math.rad (-135)) * -0.4,
})

local witch_base_drops = {
	{
		name = "mcl_potions:glass_bottle",
		chance = 8, min = 0, max = 2,
		looting = "common",
	},
	{
		name = "mcl_nether:glowstone_dust",
		chance = 8, min = 0, max = 2,
		looting = "common",
	},
	{
		name = "mcl_mobitems:gunpowder",
		chance = 8, min = 0, max = 2,
		looting = "common",
	},
	{
		name = "mcl_redstone:redstone",
		chance = 1, min = 4, max = 8,
		looting = "common",
	},
	{
		name = "mcl_mobitems:spider_eye",
		chance = 8, min = 0, max = 2,
		looting = "common",
	},
	{
		name = "mcl_core:sugar",
		chance = 8, min = 0, max = 2,
		looting = "common",
	},
	{
		name = "mcl_core:stick",
		chance = 4, min = 0, max = 2,
		looting = "common",
	},
}

local witch = table.merge (raid_mob, {
	description = S("Witch"),
	type = "monster",
	_spawn_category = "monster",
	can_despawn = true,
	hp_min = 26,
	hp_max = 26,
	xp_min = 5,
	xp_max = 5,
	collisionbox = {-0.3, 0.00, -0.3, 0.3, 1.95, 0.3},
	doll_size_override = {
		x = 0.95,
		y = 0.95,
	},
	visual = "mesh",
	mesh = "mobs_mc_witch.b3d",
	textures = {
		{"mobs_mc_witch.png"},
	},
	visual_size = {
		x = 2.75,
		y = 2.75,
	},
	head_eye_height = 1.62,
	makes_footstep_sound = true,
	damage = 2,
	reach = 2,
	movement_speed = 5.0,
	attack_type = "ranged",
	ranged_interval_min = 3.0,
	ranged_interval_max = 3.0,
	shoot_offset = 0.5,
	max_drops = 3,
	drops = witch_base_drops,
	animation = {
		speed_normal = 30,
		speed_run = 60,
		stand_start = 0,
		stand_end = 0,
		walk_start = 0,
		walk_end = 40,
		run_start = 0,
		run_end = 40,
		hurt_start = 85,
		hurt_end = 115,
		death_start = 117,
		death_end = 145,
		shoot_start = 50,
		shoot_end = 82,
	},
	ranged_attack_radius = 10.0,
	_witch_potion_check = 0,
	can_wield_items = "no_pickup",
	wielditem_info = {
		position = WIELD_POSITION,
		rotation = vector.new (135, 0, 0),
		bone = "arm",
	},
	wielditem_drop_probability = 0.085,
	_can_serve_as_captain = false,
})

------------------------------------------------------------------------
-- Witch visuals.
------------------------------------------------------------------------

function witch:wielditem_transform (info, stack)
	local rot, pos, size
		= mob_class.wielditem_transform (self, info, stack)
	size.x = size.x / 2.75
	size.y = size.y / 2.75
	return rot, pos, size
end

------------------------------------------------------------------------
-- Witch AI.
------------------------------------------------------------------------

local function witch_equip_potion (self, stack)
	self:add_physics_factor ("movement_speed", "mobs_mc:witch_potion_penalty", 0.75)
	self:set_wielditem (stack)
end

local function witch_consume_potion (self, wielditem)
	self:remove_physics_factor ("movement_speed", "mobs_mc:witch_potion_penalty")

	local potion = wielditem:get_name ()
	mcl_potions.consume_potion (self.object, potion, 0, 0)
	self:set_wielditem (ItemStack ())
	 -- Play a sound.
	mcl_hunger.play_drinking_sound(self.object)
end

local witch_potion_items = {
	{
		potion = "mcl_potions:water_breathing",
		test = function (self)
			local head_nodedef = core.registered_nodes[self.head_in]
			return (not mcl_potions.has_effect (self.object, "water_breathing")
				and head_nodedef and head_nodedef.drowning > 0)
		end,
		chance = 15,
	},
	{
		potion = "mcl_potions:fire_resistance",
		test = function (self)
			return (mcl_burning.is_burning (self.object)
				and not mcl_potions.has_effect (self.object,
								"fire_resistance"))
		end,
		chance = 15,
	},
	{
		potion = "mcl_potions:healing",
		test = function (self)
			return self.health < self.object:get_properties ().hp_max
		end,
		chance = 5,
	},
	{
		potion = "mcl_potions:swiftness",
		test = function (self)
			if self.attack then
				if mcl_potions.has_effect (self.object, "swiftness") then
					return false
				end
				local pos = self.attack:get_pos ()
				local dist
					= pos and vector.distance (pos, self.object:get_pos ())
				if pos and dist > 11 then
					return true
				end
				return false
			end
		end,
		chance = 50,
	},
}

local function check_behind (self, obj_pos, target_pos)
	 local look_dir = self:get_yaw ()
	 local v = { z = math.cos (look_dir), y = 0, x = -math.sin (look_dir), }
	 v = vector.normalize (v)
	 local x = vector.direction (obj_pos, target_pos)

	 -- Dot product.
	 return vector.dot (v, x) <= 0
end

function witch:receive_damage (mcl_reason, damage)
	local factor = 1
	if mcl_reason.type == "magic" then
		factor = 0.15
	end
	return mob_class.receive_damage (self, mcl_reason, damage * factor)
end

function witch:shoot_arrow (p, vec)
	local effect_potion = "mcl_potions:harming_splash"
	local target_hp, target_pos

	if not self.attack or not self:get_wielditem ():is_empty () then
		return
	end

	-- Throw splash potions of harming at players by default.  If
	-- they've yet to receive poison and are at 4 hearts or
	-- better, throw poison, and if they are beyond 8 blocks, try
	-- to slow them with slowness potion.  If players approach too
	-- near, disable them with weakness 25% of the time.
	local entity
	target_hp = self.attack:is_player () and self.attack:get_hp ()
	target_pos = self.attack:get_pos ()
	if not target_hp then
		entity = self.attack:get_luaentity ()
		target_hp = entity.is_mob and entity.health or 0
	end

	-- Ref: https://minecraft.wiki/w/Witch#Behavior
	local pos = self.object:get_pos ()
	local dist = vector.distance (target_pos, pos)
	if entity and entity._is_raid_mob then
		-- If it's a raid mob who is being attacked, give it
		-- either regeneration or instant health subject to
		-- its remaining health.
		if target_hp and target_hp <= 4.0 then
			effect_potion = "mcl_potions:healing_splash"
		else
			effect_potion = "mcl_potions:regeneration_splash"
		end
	elseif dist >= 8
		and not mcl_potions.has_effect (self.attack, "slowness") then
		effect_potion = "mcl_potions:slowness_splash"
	elseif target_hp >= 8
		and not mcl_potions.has_effect (self.attack, "poison") then
		effect_potion = "mcl_potions:poison_splash"
	elseif dist <= 3
		and not mcl_potions.has_effect (self.attack, "weakness")
		and math.random (1, 4) == 1 then
		effect_potion = "mcl_potions:weakness_splash"
	end

	-- Adjust for deceleration and entity movement.
	local movement = self.attack:get_velocity ()
	movement.y = 0 -- But don't compensate for vertical movement.
	local pos_adj = target_pos + movement

	-- But never throw potions behind oneself.
	if not check_behind (self, pos, pos_adj) then
		target_pos = pos_adj
	end

	local d = vector.subtract (target_pos, p)
	d.y = d.y + 0.25 + vector.length (d) * 0.25
	mcl_potions.throw_splash (effect_potion, vector.normalize (d), p, self.object, 0, 0)
end

function witch:ai_step (dtime)
	raid_mob.ai_step (self, dtime)

	-- Decrement illager cooldown period and ascertain whether it
	-- has elapsed.  Minecraft's period appears to be 200 ticks
	-- divided by two, i.e., 5 seconds.  During this interval,
	-- which begins after a Witch acquires an Illager target,
	-- Witches will not attempt either to attack players or to
	-- heal Illagers.
	if self._raider_cooldown then
		self._raider_cooldown = self._raider_cooldown - dtime
		if self._raider_cooldown <= 0 then
			self._raider_cooldown = nil
		end
	end

	-- Consume any wielditem currently held.
	local wielditem = self:get_wielditem ()
	if not wielditem:is_empty () then
		if not self._using_wielditem then
			self:use_wielditem ()
		elseif self._using_wielditem > 1.5 then
			witch_consume_potion (self, wielditem)
		end
		return
	end

	-- Check for potions to consume every minecraft tick.
	self._witch_potion_check = self._witch_potion_check + dtime
	if self._witch_potion_check < 0.05 then
		return
	end
	self._witch_potion_check = 0
	for _, item in ipairs (witch_potion_items) do
		local random = math.random (1, 100)
		if item.chance >= random and item.test (self) then
			witch_equip_potion (self, ItemStack (item.potion))
			break
		end
	end
end

witch.ai_functions = {
	raid_mob.check_recover_banner,
	mob_class.check_attack,
	raid_mob.check_navigate_village,
	raid_mob.check_distant_patrol,
	mob_class.check_pace,
	raid_mob.check_celebrate,
}

local dist_sqr = mcl_mobs.dist_sqr
local huge = math.huge

local function is_raid_mob (obj)
	local entity = obj:get_luaentity ()
	if entity
		and entity._is_raid_mob
		and entity.name ~= "mobs_mc:witch" then
		local raid = entity:_get_active_raid ()
		return raid and raid.status == "ongoing"
	end
	return false
end

local function witch_heal_raider_rule (self, self_pos, dtime, obj, is_current)
	if obj and is_current then
		local dist = self.tracking_distance * self.tracking_distance
		return self:track_current_target (self_pos, dtime, obj, dist,
						  3.0)
	elseif not self._raider_cooldown then
		local raid = self:_get_active_raid ()
		if raid	and raid.status == "ongoing"
			and self:check_timer ("seek_target", 0.5) then
			local range = self.view_range
			local objects = self:objects_for_targeting (self_pos, range)
			local d = huge
			local target = nil
			for _, obj in ipairs (objects) do
				if self.object ~= obj and is_raid_mob (obj) then
					local obj_pos = obj:get_pos ()
					if self:test_object_and_restriction (obj, obj_pos)
						and self:target_visible (self_pos, obj) then
						local d1 = dist_sqr (self_pos, obj_pos)
						if d1 <= range * range and d1 < d then
							d, target = d1, obj
						end
					end
				end
			end
			if target then
				-- Prevent all manner of target
				-- acquisition for 10 seconds after a
				-- raider is locked.
				self._raider_cooldown = 10.0
			end
			return target
		end
	end
end

local function witch_attack_player_p (self)
	return self._raider_cooldown == nil
end

witch._targeting_rules = {
	mcl_mobs.build_retaliation_target_rule (mobs_mc.raid_mob_predicate,
						nil, nil),
	mcl_mobs.build_target_rule ({
		fn = witch_heal_raider_rule,
		on_complete = nil,
	}),
	mcl_mobs.build_nearest_target_rule ("player", nil, witch_attack_player_p,
					    nil, nil),
}

mcl_mobs.register_mob ("mobs_mc:witch", witch)

------------------------------------------------------------------------
-- Witch spawning.
------------------------------------------------------------------------

mcl_mobs.register_egg ("mobs_mc:witch", S("Witch"), "#340000", "#51a03e", 0)

------------------------------------------------------------------------
-- Modern Witch spawning.
------------------------------------------------------------------------

local witch_spawner = table.merge (mobs_mc.monster_spawner, {
	name = "mobs_mc:witch",
	weight = 5,
	pack_max = 1,
	pack_min = 1,
	biomes = mobs_mc.monster_biomes,
})

mcl_mobs.register_spawner (witch_spawner)

local witch_spawner_swamp_hut = table.merge (witch_spawner, {
	weight = 1,
	biomes = {},
	structures = {
		"mcl_levelgen:swamp_hut",
	},
})

mcl_mobs.register_spawner (witch_spawner_swamp_hut)

------------------------------------------------------------------------
-- Legacy Witch wielditem entity.  This entity is retained to avoid
-- depositing invalid objects in old worlds.
------------------------------------------------------------------------

local potion_props = {
	visual = "wielditem",
	physical = false,
	pointable = false,
	static_save = false,
	wield_item = "mcl_potions:water",
}

local witch_potion_entity = {
	initial_properties = potion_props,
	on_activate = function (self, staticdata, dtime)
		self.object:remove ()
	end,
}

core.register_entity ("mobs_mc:witch_potion", witch_potion_entity)
