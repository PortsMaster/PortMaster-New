--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

--###################
--################### IRON GOLEM
--###################

local golem = {
	description = S("Iron Golem"),
	type = "npc",
	_spawn_category = "misc",
	hp_min = 100,
	hp_max = 100,
	breath_max = -1,
	collisionbox = {-0.7, -0.01, -0.7, 0.7, 2.69, 0.7},
	doll_size_override = { x = 0.9, y = 0.9 },
	visual = "mesh",
	mesh = "mobs_mc_iron_golem.b3d",
	head_swivel = "head.control",
	bone_eye_height = 3.38,
	head_eye_height = 2.6,
	curiosity = 10,
	textures = {
		{
			-- Golem texture.
			"mobs_mc_iron_golem.png",
			-- Poppies.
			"blank.png",
		},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	can_ride_cart = false,
	can_ride_boat = false,
	sounds = {
		damage = "mobs_mc_iron_golem_hurt"
	},
	stepheight = 1.01,
	floats = 0,
	movement_speed = 5.0,
	knockback_resistance = 1.0,
	damage = 15,
	reach = 3,
	attack_type = "melee",
	drops = {
		{
			name = "mcl_core:iron_ingot",
			chance = 1,
			min = 3,
			max = 5,
		},
		{
			name = "mcl_flowers:poppy",
			chance = 1,
			min = 0,
			max = 2,
		},
	},
	fall_damage = 0,
	animation = {
		stand_start = 0, stand_end = 0, stand_speed = 15,
		walk_start = 40, walk_end = 80, walk_speed = 25,
		run_start = 40, run_end = 80, run_speed = 25,
		punch_start = 80, punch_end = 90, punch_speed = 15,
		flower_start = 100, flower_end = 100, flower_speed = 0,
	},
	pace_bonus = 0.6,
	_poppy_texture = "blank.png",
	_melee_esp = true,
}

------------------------------------------------------------------------
-- Iron Golem AI.
------------------------------------------------------------------------

local pr = PcgRandom (os.time () + 412)
local r = 1 / 2147483647
local NINETY_DEG = math.pi / 2

local function golem_seek_target (self, self_pos, dtime)
	if self._seeking_target then
		local target = self._nearest_undesirable
		if not target or not is_valid (target) then
			self._seeking_target = false
			return false
		end

		if not self:navigation_finished () then
			return true
		end
		self._seeking_target = false
		return false
	elseif self._nearest_undesirable then
		local target = self._nearest_undesirable
		if target and is_valid (target) then
			local dir = vector.direction (self_pos, target:get_pos ())
			local target
				= self:target_in_direction (self_pos, 16, 7, dir, NINETY_DEG)

			if target and self:gopath (target, 0.9) then
				self._seeking_target = true
				return "_seeking_target"
			end
		end
	end
	return false
end

local function find_nearest_village_section (section)
	-- "Mob AI uses these definitions in various cases. For
	-- example, when a villager is not in a village and needs to
	-- return to one, it sets out in the direction of increasing
	-- proximity.  When an iron golem patrols the village, it
	-- frequently looks for a village subchunk within a 5×5×5 cube
	-- of itself to walk to."
	--
	-- Ref: https://minecraft.wiki/w/Village_mechanics
	local v = vector.zero ()
	local closest, heat
	for x = -2, 2 do
		for y = -2, 2 do
			for z = -2, 2 do
				v.x = section.x + x
				v.y = section.y + y
				v.z = section.z + z
				local candidate = mcl_villages.get_poi_heat_of_section (v)
				if candidate >= 4 and (not closest or candidate >= heat) then
					heat = candidate
					closest = vector.copy (v)
				end
			end
		end
	end
	return closest
end

local function golem_seek_village (self, self_pos, dtime)
	if self._seeking_village then
		if self:navigation_finished () then
			self._seeking_village = false
			return false
		end
		return true
	else
		local section = mcl_villages.section_position (self_pos)
		local heat = mcl_villages.get_poi_heat_of_section (section)

		-- Can't seek village if already in one.
		if heat >= 5 then
			return false
		end
		local section = find_nearest_village_section (section)
		if section then
			local center = mcl_villages.center_of_section (section)
			local dir = vector.direction (self_pos, center)
			local target = self:target_in_direction (self_pos, 10, 7,
								 dir, NINETY_DEG)
			if target then
				self:gopath (target, 0.6)
				self._seeking_village = true
				return "_seeking_village"
			end
		end
		return false
	end
end

function golem:who_are_you_looking_at ()
	if self._flower_recipient then
		self._locked_object = self._flower_recipient
	else
		mob_class.who_are_you_looking_at (self)
	end
end

local function golem_extend_flower (self, self_pos, dtime)
	if self._extending_flower then
		self._extending_flower = self._extending_flower + dtime
		if self._extending_flower >= 10 then
			self._extending_flower = nil
			self._poppy_texture = "blank.png"
			self._flower_recipient = nil
			self:set_animation ("stand")
			return false
		end
		local target = self._flower_recipient
		if is_valid (target) then
			self:look_at (target:get_pos ())
			self:set_animation ("flower")
			self._poppy_texture = "mcl_flowers_poppy.png"
		end
		return true
	else
		local chance = math.round (8000 * dtime / 0.05)
		if pr:next (1, chance) == 1 then
			-- Try to locate a villager within a 6-block
			-- wide area horizontally and within line of
			-- sight.
			local aa = vector.offset (self_pos, -3.0 - 2.0, -1.0, -3.0 - 2.0)
			local bb = vector.offset (self_pos, 3.0+2.0, 1.0, 3.0+2.0)
			for object in core.objects_in_area (aa, bb) do
				local entity = object:get_luaentity ()
				if entity and entity.name == "mobs_mc:villager"
					and self:target_visible (self_pos, object) then
					self._flower_recipient = object
					self._extending_flower = 0
					return "_extending_flower"
				end
			end
		end
		return false
	end
end

local function get_knockback_resistance (object)
	local entity = object:get_luaentity ()
	if entity then
		return entity.knockback_resistance or 0.0
	end
	return 0.0
end

function golem:custom_attack ()
	if self.animation.punch_start then
		local frames
			= self.animation.punch_end - self.animation.punch_start
		local speed = self.animation.punch_speed
			or self.animation.speed_normal or 25
		local min_duration = (frames / speed - 0.09)
		self:set_animation ("punch")
		-- FIXME: this is hideous but necessary to prevent punch
		-- animations from being overwritten as this mob continues
		-- pursuing its target, having inflicted knockback.
		self._punch_animation_timeout = min_duration
	end
	self:mob_sound ("attack")

	local attack = self.attack
	local damage = self.damage

	if damage > 0 then
		damage = damage / 2.0 + pr:next (0, damage - 1)
	end
	local hp = mcl_util.get_hp (attack)
	attack:punch (self.object, 1.0, {
		full_punch_interval = 1.0,
		damage_groups = { fleshy = damage, },
	}, nil)
	if mcl_util.get_hp (attack) < hp then
		local throw = 1.0 - get_knockback_resistance (attack)
		attack:add_velocity (vector.new (0, 16 * throw, 0))
	end
end

function golem:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	if self._nearest_undesirable then
		local obj = self._nearest_undesirable
		local self_pos = self.object:get_pos ()
		if not is_valid (obj)
			or not self:should_continue_to_attack (obj)
			or vector.distance (self_pos, obj:get_pos ()) > 64 then
			self._nearest_undesirable = nil
		end
	end
end

function golem:locate_undesirable (self_pos)
	if self._creator then
		return nil
	end
	local aa = vector.offset (self_pos, -10, -10, -10)
	local bb = vector.offset (self_pos, 10, 10, 10)
	local player_rep = {}

	for object in core.objects_in_area (aa, bb) do
		local entity = object:get_luaentity ()
		if entity and entity.name == "mobs_mc:villager" then
			for name, rep in pairs (entity._reputation) do
				local value = player_rep[name] or 0
				player_rep[name] = math.min (value, rep)
			end
		end
	end

	local undesirable, dist = nil, nil
	for player, pos1 in mcl_player.iterate_connected_players (self_pos, 64) do
		if self:test_object_and_restriction (player, pos1) then
			local name = player:get_player_name ()
			local rep = player_rep[name] or 0
			if rep < -100 then
				local player_pos = player:get_pos ()
				local new_dist = vector.distance (self_pos, player_pos)
				if not undesirable or new_dist < dist then
					undesirable = player
					dist = new_dist
				end
			end
		end
	end
	return undesirable
end

function golem:pacing_target_towards_villager (pos)
	-- Attempt to reveal this mob to a villager who has not seen a
	-- golem lately.
	local villagers = {}
	local aa = vector.offset (pos, -32, -32, -32)
	local bb = vector.offset (pos, 32, 32, 32)
	local gmt = core.get_gametime ()
	for object in core.objects_in_area (aa, bb) do
		local entity = object:get_luaentity ()
		if entity and entity.name == "mobs_mc:villager"
			and not entity:seen_golem_lately (gmt) then
			table.insert (villagers, object)
		end
	end

	if #villagers > 0 then
		local villager = villagers[pr:next (1, #villagers)]
		local villager_pos = villager:get_pos ()
		local dir = vector.direction (pos, villager_pos)
		local target = self:target_in_direction (pos, 10, 7, dir, NINETY_DEG)
		return target
	end
	return nil
end

function golem:pacing_target_towards_poi (pos)
	-- Select a hot village section in a 5x5 cube around this mob
	-- horizontally, and subsequently a random POI from that
	-- section.
	local section = mcl_villages.section_position (pos)
	local sections = {}
	for x = -2, 2 do
		for y = -2, 2 do
			for z = -2, 2 do
				local v = vector.offset (section, x, y, z)
				if mcl_villages.get_poi_heat_of_section (v) == 6 then
					table.insert (sections, v)
				end
			end
		end
	end
	if #sections > 0 then
		local section = sections[pr:next (1, #sections)]
		local pois = mcl_villages.get_pois_in_section (section)
		if #pois > 0 then
			local poi = pois[pr:next (1, #pois)].min
			local dir = vector.direction (pos, poi)
			local target = self:target_in_direction (pos, 10, 7, dir,
								 NINETY_DEG)
			if target then
				return target
			end
		end
	end
end

function golem:pacing_target (pos, width, height, groups)
	local random = pr:next (0, 2147483647) * r
	if random < 0.3 then
		return mob_class.pacing_target (self, pos, width, height, groups)
	end

	if random < 0.7 then
		local target = self:pacing_target_towards_villager (pos)
		if target then
			return target
		end

		local target = self:pacing_target_towards_poi (pos)
		if target then
			return target
		end
	else
		local target = self:pacing_target_towards_poi (pos)
		if target then
			return target
		end

		local target = self:pacing_target_towards_villager (pos)
		if target then
			return target
		end
	end

	return mob_class.pacing_target (self, pos, width, height, groups)
end

golem.ai_functions = {
	mob_class.check_attack,
	golem_seek_target,
	golem_seek_village,
	mob_class.check_pace,
	golem_extend_flower,
}

local function golem_target_undesirables (self, self_pos, dtime, obj, is_current)
	if self._creator then
		return nil
	elseif is_current then
		local dist = self.tracking_distance * self.tracking_distance
		return self:track_current_target (self_pos, dtime, obj, dist, nil)
	end

	if self:check_timer ("find_undesirables", 0.5) then
		return nil
	end

	-- Locate players within a 64-node distance whose reputation
	-- is below -100 with any villager within 10 nodes, and pursue
	-- such targets aggressively.
	local undesirable = self._nearest_undesirable
	if not undesirable or not is_valid (undesirable) then
		undesirable = self:locate_undesirable (self_pos)
		self._nearest_undesirable = undesirable
	end
	if undesirable then
		local pos = undesirable:get_pos ()
		if vector.distance (self_pos, pos) < self.view_range then
			return undesirable
		end
	end
	return nil
end

local function attackable_monster_p (self, self_pos, obj, entity)
	return entity
		and entity.type == "monster"
		and entity.name ~= "mobs_mc:creeper"
		and entity.name ~= "mobs_mc:creeper_charged"
end

golem._targeting_rules = {
	mcl_mobs.build_target_rule ({
		fn = golem_target_undesirables,
		on_complete = nil,
	}),
	mcl_mobs.build_retaliation_target_rule (nil, false, nil),
	mcl_mobs.build_nearest_target_rule ("mob", attackable_monster_p, nil,
					    nil, nil),
}

------------------------------------------------------------------------
-- Iron Golem visuals.
------------------------------------------------------------------------

function golem:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	self._poppy_texture = "blank.png"
	return true
end

function golem:do_custom (dtime)
	self:crack_overlay ()
end

function golem:on_rightclick (clicker)
	if not clicker or not clicker:is_player() then
		return
	end

	local item = clicker:get_wielded_item()
	if item:get_name() == "mcl_core:iron_ingot"
		and self.health < self.object:get_properties().hp_max then
		if not core.is_creative_enabled(clicker:get_player_name()) then
			item:take_item()
			clicker:set_wielded_item(item)
		end
		self.health = math.min(self.health + 25, self.object:get_properties().hp_max)
		return
	end
end

function golem:crack_overlay ()
	local base = "mobs_mc_iron_golem.png"
	local o = "^[opacity:180)"
	local t
	if self.health >= 75 then t = base
	elseif self.health >= 50 then t = base.."^(mobs_mc_iron_golem_crack_low.png"..o
	elseif self.health >= 25 then t = base.."^(mobs_mc_iron_golem_crack_medium.png"..o
	else t = base.."^(mobs_mc_iron_golem_crack_high.png"..o end
	self:set_textures ({ t, self._poppy_texture, })
end

function golem:display_sprinting_particles ()
	local v = self.object:get_velocity ()
	return pr:next (1, 5) == 1 and v.x * v.x + v.z * v.z > 0.0025
end

------------------------------------------------------------------------
-- Iron Golem summoning.
------------------------------------------------------------------------

mcl_mobs.register_mob ("mobs_mc:iron_golem", golem)

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:iron_golem", S("Iron Golem"), "#b3b3b3", "#4d7e47", 0)

--[[ This is to be called when a pumpkin or jack'o lantern has been placed. Recommended: In the on_construct function of the node.
This summons an iron golen if placing the pumpkin created an iron golem summon pattern:

.P.
III
.I.

P = Pumpkin or jack'o lantern
I = Iron block
. = Air
]]

function mobs_mc.check_iron_golem_summon(pos, player)
	local checks = {
		-- These are the possible placement patterns, with offset from the pumpkin block.
		-- These tables include the positions of the iron blocks (1-4) and air blocks (5-8)
		-- 4th element is used to determine spawn position.
		-- If a 9th element is present, that one is used for the spawn position instead.
		-- Standing (x axis)
		{
			{x=-1, y=-1, z=0}, {x=1, y=-1, z=0}, {x=0, y=-1, z=0}, {x=0, y=-2, z=0}, -- iron blocks
			{x=-1, y=0, z=0}, {x=1, y=0, z=0}, {x=-1, y=-2, z=0}, {x=1, y=-2, z=0}, -- air
		},
		-- Upside down standing (x axis)
		{
			{x=-1, y=1, z=0}, {x=1, y=1, z=0}, {x=0, y=1, z=0}, {x=0, y=2, z=0},
			{x=-1, y=0, z=0}, {x=1, y=0, z=0}, {x=-1, y=2, z=0}, {x=1, y=2, z=0},
			{x=0, y=0, z=0}, -- Different offset for upside down pattern
		},

		-- Standing (z axis)
		{
			{x=0, y=-1, z=-1}, {x=0, y=-1, z=1}, {x=0, y=-1, z=0}, {x=0, y=-2, z=0},
			{x=0, y=0, z=-1}, {x=0, y=0, z=1}, {x=0, y=-2, z=-1}, {x=0, y=-2, z=1},
		},
		-- Upside down standing (z axis)
		{
			{x=0, y=1, z=-1}, {x=0, y=1, z=1}, {x=0, y=1, z=0}, {x=0, y=2, z=0},
			{x=0, y=0, z=-1}, {x=0, y=0, z=1}, {x=0, y=2, z=-1}, {x=0, y=2, z=1},
			{x=0, y=0, z=0},
		},

		-- Lying
		{
			{x=-1, y=0, z=-1}, {x=0, y=0, z=-1}, {x=1, y=0, z=-1}, {x=0, y=0, z=-2},
			{x=-1, y=0, z=0}, {x=1, y=0, z=0}, {x=-1, y=0, z=-2}, {x=1, y=0, z=-2},
		},
		{
			{x=-1, y=0, z=1}, {x=0, y=0, z=1}, {x=1, y=0, z=1}, {x=0, y=0, z=2},
			{x=-1, y=0, z=0}, {x=1, y=0, z=0}, {x=-1, y=0, z=2}, {x=1, y=0, z=2},
		},
		{
			{x=-1, y=0, z=-1}, {x=-1, y=0, z=0}, {x=-1, y=0, z=1}, {x=-2, y=0, z=0},
			{x=0, y=0, z=-1}, {x=0, y=0, z=1}, {x=-2, y=0, z=-1}, {x=-2, y=0, z=1},
		},
		{
			{x=1, y=0, z=-1}, {x=1, y=0, z=0}, {x=1, y=0, z=1}, {x=2, y=0, z=0},
			{x=0, y=0, z=-1}, {x=0, y=0, z=1}, {x=2, y=0, z=-1}, {x=2, y=0, z=1},
		},


	}

	for c=1, #checks do
		-- Check all possible patterns
		local ok = true
		-- Check iron block nodes
		for i=1, 4 do
			local cpos = vector.add(pos, checks[c][i])
			local node = core.get_node(cpos)
			if node.name ~= "mcl_core:ironblock" then
				ok = false
				break
			end
		end
		-- Check air nodes
		for a=5, 8 do
			local cpos = vector.add(pos, checks[c][a])
			local node = core.get_node(cpos)
			if node.name ~= "air" then
				ok = false
				break
			end
		end
		-- Pattern found!
		if ok then
			-- Remove the nodes
			core.remove_node(pos)
			core.check_for_falling(pos)
			for i=1, 4 do
				local cpos = vector.add(pos, checks[c][i])
				core.remove_node(cpos)
				core.check_for_falling(cpos)
			end
			-- Summon iron golem
			local place
			if checks[c][9] then
				place = vector.add(pos, checks[c][9])
			else
				place = vector.add(pos, checks[c][4])
			end
			place.y = place.y - 0.5
			local o = core.add_entity(place, "mobs_mc:iron_golem")
			if o then
				local l = o:get_luaentity()
				if l and player then l._creator = player:get_player_name() end
			end
			break
		end
	end
end
