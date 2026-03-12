------------------------------------------------------------------------
-- Common Illager and raid mob definitions.  This file defines logic
-- and AI behavior for mobs that participate in raids and patrol over
-- long distances.
------------------------------------------------------------------------

local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

------------------------------------------------------------------------
-- Patrols.
------------------------------------------------------------------------

local pr = PcgRandom (os.time () + 11)

local patrolling_mob = {
	_raidcaptain = false,
	_patrolling = false,
	_can_serve_as_captain = true,
	_banner_position = vector.new (0, 6, -1),
	_patrol_target = nil,
	_patrol_bonus_captain = 0.595,
	_patrol_bonus_minions = 0.7,
	_patrol_cooldown = 0,
	_patrol_n_retries = 0,
	_is_patrolling_mob = true,
	_banner_bone = "",
}

function patrolling_mob:promote_to_raidcaptain ()
	local self_pos = self.object:get_pos ()
	local entity = "mcl_raids:ominous_banner"
	local banner = core.add_entity (self_pos, entity)
	if not banner then
		return
	end
	local layers = mcl_raids.ominous_banner_layers
	local textures = {
		mcl_banners.make_banner_texture ("unicolor_white", layers)
	}
	banner:set_properties ({
			textures = textures,
	})
	banner:set_attach (self.object, self._banner_bone,
			   self._banner_position, nil, true)
	self._raidcaptain = true
	mcl_raids.promote_to_raidcaptain (self)
end

function patrolling_mob:on_spawn ()
	if not self._structure_generation_spawn
		and not self._raid_spawn
		and not self._patrol_spawn
	then
		if self._can_serve_as_captain
			and not self._raidcaptain then
			local random = pr:next (1, 100)
			if random <= 6 then
				self._raidcaptain = true
			end
		end
	end
end

function patrolling_mob:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	if self._raidcaptain then
		self:promote_to_raidcaptain ()
	end
	return true
end

function patrolling_mob:despawn_ok (d_to_closest_player)
	return not self._patrolling or d_to_closest_player > 128
end

function patrolling_mob:is_valid_in_patrol ()
	return true
end

function patrolling_mob:find_allies (self_pos)
	local allies = {}
	local aa = vector.offset (self_pos, -16, -16, -16)
	local bb = vector.offset (self_pos, 16, 16, 16)
	for object in core.objects_in_area (aa, bb) do
		if object ~= self.object then
			local entity = object:get_luaentity ()
			if entity and entity.is_valid_in_patrol
				and entity:is_valid_in_patrol () then
				table.insert (allies, entity)
			end
		end
	end

	return allies
end

local Y_AXIS = vector.new (0, 1, 0)

local function rotate (v, yaw)
	return vector.rotate_around_axis (v, Y_AXIS, yaw)
end

function patrolling_mob:select_patrol_target (self_pos)
	local x = -500 + pr:next (0, 999)
	local z = -500 + pr:next (0, 999)
	self._patrol_n_retries = 0
	self._patrol_prev_pos = self_pos
	self._patrol_target = {
		x = math.floor (self_pos.x + 0.5) + x,
		y = math.floor (self_pos.y + 0.5),
		z = math.floor (self_pos.z + 0.5) + z,
	}
end

function mobs_mc.find_surface_position (node_pos)
	if node_pos.y < mcl_vars.mg_overworld_min then
		return node_pos
	else
		-- Raycast from a position 256 blocks above the
		-- overworld to the bottom of the world, and locate
		-- the first opaque or liquid non-leaf block.

		local v = vector.copy (node_pos)
		v.y = math.max (node_pos.y, 256)
		local lim
			= math.max (mcl_vars.mg_overworld_min, node_pos.y - 512)
		while v.y >= lim do
			local node = core.get_node (v)
			local def = core.registered_nodes[node.name]
			local group_leaves = def and def.groups and def.groups.leaves or 0
			local group_liquid = def and def.groups and def.groups.liquid or 0
			if node.name ~= "ignore"
				and group_leaves == 0
				and (group_liquid ~= 0 or (def and def.walkable)) then
				break
			end
			v.y = v.y - 1
		end
		v.y = v.y + 1
		return v
	end
end

function patrolling_mob:find_surface_position (node_pos)
	return mobs_mc.find_surface_position (node_pos)
end

function patrolling_mob:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	self._patrol_cooldown
		= math.max (0, self._patrol_cooldown - dtime)
end

function patrolling_mob:drop_custom (looting_level)
	if self._raidcaptain then
		local self_pos = self.object:get_pos ()
		mcl_raids.drop_obanner (self_pos)
	end
end

function patrolling_mob:on_die (pos, mcl_reason)
	if self._raidcaptain
		and mcl_reason
		and mcl_reason.type == "player" then
		local playername = mcl_reason.source:get_player_name ()
		awards.unlock (playername, "mcl:voluntary_exile")
	end

	-- TODO
end

function patrolling_mob:patrol_unstuck (self_pos)
	local x = pr:next (-8, 8)
	local z = pr:next (-8, 8)
	local node_pos = mcl_util.get_nodepos (self_pos)
	local pos = vector.offset (node_pos, x, 0, z)
	local target = self:find_surface_position (pos)
	self:gopath (target, self._patrol_bonus_minions)
end

function patrolling_mob:check_distant_patrol (self_pos, dtime)
	if self._in_distant_patrol then
		local allies = self:find_allies (self_pos)
		local target = self._patrol_target

		if self._patrol_cooldown > 0 then
			if self:navigation_finished () then
				self._in_distant_patrol = false
				return false
			end
			return true
		end

		if not target or not self._patrolling then
			self._in_distant_patrol = false
			return false
		end
		if not self:navigation_finished () then
			return true
		end

		local prev_pos = self._patrol_prev_pos
		local distance = vector.distance (self_pos, prev_pos)
		self._patrol_prev_pos = self_pos

		if self._patrolling and #allies == 0 then
			self._patrolling = false
			self._in_distant_patrol = false
			return false
		elseif distance < 0.5 and self._patrol_n_retries > 4 then
			self._patrol_cooldown = 10
			self._patrol_n_retries = 0
			self:patrol_unstuck (self_pos)
			return true
		elseif self._raidcaptain
			and vector.distance (self_pos, target) < 10.0 then
			-- Locate a new target.
			self:select_patrol_target (self_pos)
		else
			-- If not enough motion has been registered
			-- since the previous pathfinding attempt,
			-- switch targets.
			if distance < 0.5 then
				self._patrol_n_retries
					= self._patrol_n_retries + 1
			end

			local target_surface
				= vector.subtract (target, 0, -0.5, 0)

			-- Select a position 0.4 * the distance to the
			-- target perpendicular to it.
			local away = vector.subtract (self_pos, target_surface)
			local offset = vector.multiply (rotate (away, math.pi / 2), 0.4)
			local offset_pos = vector.add (offset, target_surface)

			-- Move 10 blocks in the direction of that position.
			local dir = vector.direction (self_pos, offset_pos)
			local pos = vector.multiply (dir, 10)
			pos = vector.add (pos, self_pos)
			local node_pos = mcl_util.get_nodepos (pos)

			-- Find a position on the surface at this
			-- target position.
			node_pos = self:find_surface_position (node_pos)
			local bonus = self._patrol_bonus_captain

			if not self._raidcaptain then
				bonus = self._patrol_bonus_minions
			end
			self:gopath (node_pos, bonus)
			if self._raidcaptain then
				for _, ally in pairs (allies) do
					ally._patrol_target = node_pos
					ally._patrolling = true
				end
			end
			return true
		end
	elseif self._patrolling and self._patrol_target
		and self._patrol_cooldown == 0 then
		self._in_distant_patrol = true
		self._patrol_prev_pos = self_pos
		return "_in_distant_patrol"
	end
	return false
end

mobs_mc.patrolling_mob = patrolling_mob

------------------------------------------------------------------------
-- Raiders.
------------------------------------------------------------------------

local raid_mob_debug
	= core.settings:get_bool ("raid_mob_debug", false)

local raid_mob = table.merge (patrolling_mob, {
	_can_join_raid = false,
	_is_raid_mob = true,
	_locked_target = nil,
	_locked_target_visible_time = 0,
	_get_active_raid = function (self)
		return nil
	end,
	_visited_pois = {},
	_raid_wave_number = nil,
	_attached_to_raid = nil,
	_raid_uuid = nil,
	_time_inactive = 0.0,
	_time_outside_raid = 0.0,
	_celebrating = false,
})

function raid_mob:apply_raid_buffs (stage)
end

function raid_mob:mob_activate (staticdata, dtime)
	if not patrolling_mob.mob_activate (self, staticdata, dtime) then
		return false
	end
	self._visited_pois = {}
	return true
end

function raid_mob:attack_end ()
	mob_class.attack_end (self)
	self._locked_target = nil
end

local function is_golem (mob)
	local entity = mob:get_luaentity ()
	return entity and entity.name == "mobs_mc:iron_golem"
end

function raid_mob:ai_step (dtime)
	patrolling_mob.ai_step (self, dtime)
	-- Reset `_time_inactive' if attacking a player or iron golem.
	local attack = self.attack
	if attack and (attack:is_player () or is_golem (attack)) then
		self._time_inactive = 0.0
	else
		local t = self._time_inactive
		self._time_inactive = t + dtime
	end
	if raid_mob_debug then
		self:apply_debug_nametag ()
	end
end

function raid_mob:lock_target (target)
	self._locked_target = target
	self._locked_target_visible_time = 3
end

function raid_mob:receive_attack (attack)
	if self._active_target then
		-- If ATTACK is the locked target, then engage it now.
		if self._locked_target == attack then
			self._locked_target = nil
		end
		return false
	end
	self._alert_receiver_target = attack
	return true
end

function raid_mob:step_locked_target (self_pos, dtime)
	-- Verify that any target acquired by this patrol should
	-- continue to be attacked.
	local target = self._locked_target
	local d = self.tracking_distance
	if self.raidmob then
		target = nil
	elseif target and not is_valid (target) then
		target = nil
	elseif target then
		local target_pos = target:get_pos ()
		local dist = vector.distance (self_pos, target_pos)
		if dist > d or dist < 10.0 then
			target = nil
		elseif not self:target_visible (self_pos, target) then
			local t = self._locked_target_visible_time - dtime
			if t <= 0 then
				target = nil
			end
			self._locked_target_visible_time = t
		elseif not self:test_object_and_restriction (target, target_pos) then
			target = nil
		end
	end
	self._locked_target = target
end

function raid_mob:notify_nearby_patrolmen (self_pos, target)
	for object in core.objects_inside_radius (self_pos, 8.0) do
		local entity = object:get_luaentity ()

		if entity and entity._is_raid_mob then
			entity:lock_target (target)
		end
	end
end

function raid_mob:check_locked_target (self_pos, dtime)
	if self._suspended_for_locked_target then
		local target = self._locked_target
		local pos = target and target:get_pos ()
		if not pos then
			self._suspended_for_locked_target = false
			return false
		end
		self:cancel_navigation ()
		self:halt_in_tracks ()
		self:look_at (pos)
		return true
	elseif self._locked_target and not self.raidmob then
		self._suspended_for_locked_target = true
		return "_suspended_for_locked_target"
	end
end

local function decode_banner_item (entity)
	if entity.name ~= "__builtin:item" then
		return nil
	end
	local stack = ItemStack (entity.itemstring)
	if mcl_raids.is_banner_item (stack) then
		local def = stack:get_definition ()
		local name = stack:get_name ()
		return stack, def, name
	end
	return nil
end

function raid_mob:wave_has_captain (raid)
	local wave = self._raid_wave_number
	local raid = raid or self:get_active_raid ()
	return raid and wave and raid.waves[wave]
		and raid.waves[wave].leader
end

function raid_mob:default_pickup (object, stack, def, itemname)
	if mcl_raids.is_banner_item (stack) and self._can_serve_as_captain then
		local raid = self:_get_active_raid ()
		if raid and not self:wave_has_captain (raid) then
			local item = stack:take_item ()
			if stack:is_empty () then
				object:remove ()
			else
				local entity = object:get_luaentity ()
				entity.itemstring = stack:to_string ()
			end
			if not item:is_empty () then
				self:promote_to_raidcaptain ()
			end
			return true
		end
	end
	return mob_class.default_pickup (self, object, stack, def, itemname)
end

function raid_mob:check_recover_banner (self_pos, dtime)
	local banner = self._recovering_banner
	if banner then
		local banner = banner:get_pos ()
		if not banner then
			self._recovering_banner = nil
			self:cancel_navigation ()
			self:halt_in_tracks ()
			return false
		end
		if not self:navigation_finished () then
			if self:check_timer ("raid_recover_banner", 2.0) then
				self:gopath (banner, 1.15)
			end
			return true
		end
		if vector.distance (self_pos, banner) < 1.414 then
			for object in core.objects_inside_radius (self_pos, 4) do
				local entity = object:get_luaentity ()
				if entity then
					local stack, def, itemname
						= decode_banner_item (entity)
					if stack then
						self:default_pickup (object, stack, def, itemname)
					end
				end
			end
		end
		self._recovering_banner = nil
		return false
	elseif self._can_serve_as_captain then
		local raid = self:_get_active_raid ()
		if raid and raid.status == "ongoing"
			and not self:wave_has_captain (raid) then
			local aa = vector.offset (self_pos, -16, -8, -16)
			local bb = vector.offset (self_pos, 16, 8, 16)
			for object in core.objects_in_area (aa, bb) do
				local entity = object:get_luaentity ()
				if entity and decode_banner_item (entity) then
					local banner = object:get_pos ()
					self:gopath (banner, 1.15)
					self._recovering_banner = object
					return "_recovering_banner"
				end
			end
		end
	end
	return false
end

function raid_mob:recruit_reinforcements (self_pos, self_raid)
	local aa = vector.offset (self_pos, -16, -16, -16)
	local bb = vector.offset (self_pos, 16, 16, 16)
	for object in core.objects_in_area (self_pos, aa, bb) do
		local entity = object:get_luaentity ()
		if entity and entity._is_raid_mob then
			local raid = entity:_get_active_raid ()
			if not raid then
				mcl_raids.enroll_in_raid (self_raid, entity)
			end
		end
	end
end

local NINETY_DEG = math.pi / 2

function raid_mob:check_pathfind_to_raid (self_pos, dtime)
	local raid = self:_get_active_raid ()
	if not raid or raid.status ~= "ongoing" then
		self._raid_target_position = nil
		return false
	end
	local nodepos = {
		x = math.floor (self_pos.x + 0.5),
		y = math.floor (self_pos.y + 0.5),
		z = math.floor (self_pos.z + 0.5),
	}
	local proximity = mcl_villages.get_poi_heat (nodepos)
	if self._raid_target_position then
		if proximity >= 5 then
			self._raid_target_position = nil
			return false
		end

		if self:navigation_finished () then
			local target = self._raid_target_position
			local dir = vector.direction (self_pos, target)
			local random = self:target_in_direction (self_pos, 15, 4,
								 dir, NINETY_DEG)
			if random then
				self:gopath (random)
			end
		end

		if self:check_timer ("recruit_raiders", 1.0) then
			self:recruit_reinforcements (self_pos, raid)
		end
		return true
	elseif proximity < 5 then
		self._raid_target_position = raid.center
		return "_raid_target_position"
	end
	return false
end

function raid_mob:has_visited_poi (poi)
	if #self._visited_pois >= 3 then
		-- Remove the first element.
		local new_list = {}
		table.insert (new_list, self._visited_pois[2])
		table.insert (new_list, self._visited_pois[3])
		self._visited_pois = new_list
	end

	for _, visited_poi in pairs (self._visited_pois) do
		if vector.equals (visited_poi, poi.min) then
			return true
		end
	end
	return false
end

function raid_mob:get_village_poi (self_pos)
	local aa = vector.offset (self_pos, -48, -48, -48)
	local bb = vector.offset (self_pos, 48, 48, 48)
	local poi = mcl_villages.random_poi_in (aa, bb, function (poi)
		local def = mcl_villages.registered_pois[poi.data]

		if def and def.is_home then
			return not self:has_visited_poi (poi)
		end
	end)
	return poi and poi.min or nil
end

local function select_random_position (self, self_pos, poi)
	local dir = vector.direction (self_pos, poi)
	local t1 = self:target_in_direction (self_pos, 16, 7, dir,
					     math.pi / 10)
	if not t1 then
		t1 = self:target_in_direction (self_pos, 8, 7,
					       dir, math.pi / 2)
	end
	return t1
end

function raid_mob:check_navigate_village (self_pos, dtime)
	if self._navigating_to_poi then
		local poi = self._navigating_to_poi
		local state = self:poll_navigation_state (self_pos, dtime)
		local reached = state == "arrived"

		if reached and not self._navigating_around_poi then
			table.insert (self._visited_pois, poi)
			self._poi_reached = true
		end

		if state ~= "wait" then
			if self._poi_reached then
				self._navigating_around_poi = false
				self._navigating_to_poi = false
				return false
			else
				-- Move randomly in the vicinity of
				-- this POI.
				local t1 = select_random_position (self, self_pos, poi)
				if t1 then
					self._navigating_around_poi = true
					self:session_navigate (t1, 1.05, 1.0, nil, nil, 1, 1)
				else
					self._navigating_around_poi = false
					self._navigating_to_poi = false
					return false
				end
			end
		end

		return true
	else
		local raid = self:_get_active_raid ()
		if not raid or raid.status ~= "ongoing" then
			return false
		end
		local poi = self:get_village_poi (self_pos)
		if not poi then
			return false
		end
		self._time_inactive = 0.0
		self._navigating_around_poi = false
		self._navigating_to_poi = poi
		self:session_navigate (poi, 1.05, 1.0, nil, nil, 1, 1)
		return "_navigating_to_poi"
	end
end

function raid_mob:check_celebrate (self_pos, dtime)
	if self._celebrating then
		if not self.jockey_vehicle then
			local chance = mcl_mobs.scale_chance (50, dtime)
			if pr:next (1, chance) == 1 then
				self._jump = true
			end
			self:cancel_navigation ()
			self:halt_in_tracks ()
		end
		local raid = self:_get_active_raid ()
		if not raid then
			self._celebrating = false
			return false
		end
		return true
	else
		local raid = self:_get_active_raid ()
		if raid and raid.status == "loss"
			and not self._locked_target then
			self._celebrating = true
			return "_celebrating"
		end
		return false
	end
end

function raid_mob:receive_damage (mcl_reason, damage)
	if mob_class.receive_damage (self, mcl_reason, damage) then
		if self.raidmob then
			mcl_raids.report_mob_damage_event (self, self.health, mcl_reason)
			return true
		end
	end
	return false
end

function raid_mob:apply_debug_nametag ()
	if self._raid_uuid then
		local info = {}
		table.insert (info, self.description)
		table.insert (info, " {" .. self._raid_uuid .. "}\n")
		if self._attached_to_raid then
			local raid = self:_get_active_raid ()
			table.insert (info, "Raid: ")
			table.insert (info, self._attached_to_raid)
			if not raid then
				table.insert (info, " (inactive)\n")
			else
				table.insert (info, string.format (" (state: %s)\n",
								   raid.status))
			end
			table.insert (info, "Wave: ")
			table.insert (info, tostring (self._raid_wave_number))
			table.insert (info, "\n")
			table.insert (info, "Active activity: ")
			table.insert (info, self._active_activity or "NONE")
			table.insert (info, " ")
			table.insert (info, tostring (self[self._active_activity]))
			table.insert (info, "\n")
		end

		self.object:set_nametag_attributes ({
			text = table.concat (info),
		})
	else
		self.object:set_nametag_attributes ({
			text = nil,
		})
	end
end

mobs_mc.raid_mob = raid_mob

local function cancel_lock_target (self)
	self._locked_target = nil
end

local dist_sqr = mcl_mobs.dist_sqr
local huge = math.huge

function mobs_mc.build_raid_player_detection_rule (predicate)
	if type (predicate) == "table" then
		predicate = mcl_mobs.build_search_predicate (predicate)
	elseif not predicate then
		predicate = function (_, _, _, _)
			return true
		end
	end
	local persistence = 3.0
	local fn = function (self, self_pos, dtime, obj, is_current)
		if is_current then
			self:step_locked_target (self_pos, dtime)
			local dist = self.tracking_distance * self.tracking_distance
			return self:track_current_target (self_pos, dtime, obj, dist,
							  persistence)
		end

		if not self:check_timer ("seek_target", 0.5) then
			return false
		end

		local d = huge
		local view_range = self.view_range * self.view_range
		local target = nil
		for player, pos1 in mcl_player.iterate_connected_players () do
			local d1 = dist_sqr (self_pos, pos1)
			local m = self:detection_multiplier_for_object (player)
			if d1 <= view_range * m * m and d1 < d
				and predicate (self, self_pos, player, nil)
				and self:target_visible (self_pos, player)
				and self:test_object_and_restriction (player, pos1) then
				d = d1
				target = player
			end
		end

		if target and self._patrolling and d > 100.0 then
			-- If a player is acquired while patrolling,
			-- remain stationary till the player
			-- approaches within 10 nodes of this mob.
			-- This is enforced by the
			-- `check_locked_target' AI function.
			self:lock_target (target)
			self:notify_nearby_patrolmen (self_pos, target)
		end

		return target
	end
	return mcl_mobs.build_target_rule ({
		fn = fn,
		on_complete = cancel_lock_target,
	})
end

------------------------------------------------------------------------
-- Illagers.
------------------------------------------------------------------------

local illager = table.merge (raid_mob, {
	_is_illager = true,
})

function illager:test_object_and_restriction (object, obj_pos)
	if mob_class.test_object_and_restriction (self, object, obj_pos) then
		local entity = object:get_luaentity ()
		return not entity
			or entity.name ~= "mobs_mc:villager"
			or not entity.child
	end
	return false
end

mobs_mc.illager = illager

------------------------------------------------------------------------
-- AI utility functions.
------------------------------------------------------------------------

function mobs_mc.not_illager_predicate (self, self_pos, obj, entity)
	return not entity or not entity._is_illager
end

function mobs_mc.illager_predicate (self, self_pos, obj, entity)
	return entity and entity._is_illager
end

function mobs_mc.not_raid_mob_predicate (self, self_pos, obj, entity)
	return not entity or not entity._is_raid_mob
end

function mobs_mc.raid_mob_predicate (self, self_pos, obj, entity)
	return entity and entity._is_raid_mob
end
