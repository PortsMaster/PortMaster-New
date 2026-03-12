local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref
local ipairs = ipairs

------------------------------------------------------------------------
-- Target acquisition.
------------------------------------------------------------------------

function mob_class:is_valid_target (obj)
	return not self.dead and obj ~= self.object
end

function mob_class:run_targeting_rules (dtime, self_pos)
	local active_targeting_rule = self._active_targeting_rule
	local obj = self._active_target
	if obj and not obj:is_valid () then
		self._active_target = nil
		active_targeting_rule = nil
		obj = nil
	end

	self._active_targeting_rule = nil
	self._active_target = nil
	self._object_search_lists = {}

	for _, fn in ipairs (self._targeting_rules) do
		local is_current = active_targeting_rule == fn
		local value = fn (self, self_pos, dtime, obj, is_current)
		if value and value:is_valid ()
			and self:is_valid_target (value) then
			self._active_targeting_rule = fn
			self._active_target = value
			break
		end
	end

	-- N.B.: the same targeting rule is liable to be considered to
	-- have been reactivated if it yields a different object than
	-- is currently active.
	if obj ~= self._active_target then
		-- Run callbacks to adjust state associated with the
		-- previous targeting rule.
		self:switch_targeting_rule (active_targeting_rule,
					    self._active_targeting_rule)
	end
end

local targeting_exit_callbacks = {}

function mob_class:switch_targeting_rule (fn_old, fn_new)
	if fn_new then
		self.target_invisible_time = nil
	end
	local cb_exit = targeting_exit_callbacks[fn_old]
	if cb_exit then
		cb_exit (self, fn_old, fn_new)
	end
end

local v1, v2 = vector.zero (), vector.zero ()

function mob_class:objects_for_targeting (self_pos, range)
	if self._object_search_lists[range] then
		return self._object_search_lists[range]
	end

	v1.x = self_pos.x + self.collisionbox[1] - range
	v1.y = self_pos.y + self.collisionbox[2] - range
	v1.z = self_pos.z + self.collisionbox[3] - range
	v2.x = self_pos.x + self.collisionbox[4] + range
	v2.y = self_pos.y + self.collisionbox[5] + range
	v2.z = self_pos.z + self.collisionbox[6] + range
	local list = core.get_objects_in_area (v1, v2)
	self._object_search_lists[range] = list
	return list
end

local function objects_equivalent_p (luaentity, mob_name)
	-- A `luaentity' of nil indicates that this object is a
	-- player.
	if mob_name == "player" then
		return not luaentity
	elseif mob_name == "monster" then
		return luaentity and luaentity.type == "monster"
	elseif luaentity then
		return mob_name == luaentity.name
	end
	return false
end

local function object_targetable_p (obj)
	local luaentity = obj:get_luaentity ()
	return obj:is_valid ()
		and ((luaentity and luaentity.is_mob) or obj:is_player ())
end

mcl_mobs.object_targetable_p = object_targetable_p

local function dist_sqr (a, b)
	local dx = b.x - a.x
	local dy = b.y - a.y
	local dz = b.z - a.z
	return dx * dx + dy * dy + dz * dz
end

mcl_mobs.dist_sqr = dist_sqr

function mcl_mobs.build_search_predicate (mob_names)
	return function (self, self_pos, obj, luaentity)
		for _, name in ipairs (mob_names) do
			if objects_equivalent_p (luaentity, name) then
				return true
			end
		end
		return false
	end
end

local SIGHT_PERSISTENCE = 3.0
local huge = math.huge

function mcl_mobs.build_target_rule (tbl)
	assert (type (tbl.fn) == "function")
	assert (tbl.on_complete == nil
		or type (tbl.on_complete) == "function")
	if targeting_exit_callbacks[tbl.fn]
		and targeting_exit_callbacks[tbl.fn] ~= tbl.on_complete then
		error ("Targeting rule redefined with a different `on_complete' callback")
	end
	targeting_exit_callbacks[tbl.fn] = tbl.on_complete
	return tbl.fn
end

function mob_class:track_current_target (self_pos, dtime, obj, dist, persistence)
	-- This object is the current target; decide whether or not to
	-- cease attacking it for having moved out of range...
	local pos = obj:get_pos ()
	if dist_sqr (self_pos, pos) > dist
		or not self:test_object_and_restriction (obj, pos) then
		return nil
	end
	if persistence then
		-- ... or having been invisible for
		-- too long.
		local line_of_sight = self:target_visible (self_pos, obj)
		if not line_of_sight then
			local t = (self.target_invisible_time or persistence)
			self.target_invisible_time = t - dtime

			if t < 0 then
				return nil
			end
		else
			self.target_invisible_time = persistence
		end
	end
	return obj
end

function mcl_mobs.build_nearest_target_rule (base_type, predicate, start_predicate, range,
					     esp_or_persistence)
	if type (predicate) == "table" then
		predicate = mcl_mobs.build_search_predicate (predicate)
	elseif not predicate then
		predicate = function (_, _, _, _)
			return true
		end
	end
	local persistence
	if type (esp_or_persistence) == "number" then
		persistence = esp_or_persistence
	else
		persistence = not esp_or_persistence and SIGHT_PERSISTENCE or nil
	end
	local range_fn
	if type (range) == "number" then
		range_fn = function (view_range) return view_range end
	elseif not range then
		range_fn = function (view_range) return view_range end
	else
		assert (type (range) == "function")
		range_fn = range
	end
	local fn = function (self, self_pos, dtime, obj, is_current)
		if start_predicate
			and not start_predicate (self, self_pos) then
			return nil
		end

		if is_current then
			local dist = range_fn (self.tracking_distance)
			return self:track_current_target (self_pos, dtime, obj,
							  dist * dist, persistence)
		end

		if not self:check_timer ("seek_target", 0.5) then
			return false
		end

		local target = nil
		local range = range_fn (self.view_range)
		local view_range = range * range
		if base_type ~= "player" then
			local objects = self:objects_for_targeting (self_pos, range)
			local d = huge
			for _, obj in ipairs (objects) do
				if object_targetable_p (obj) and obj ~= self.object then
					local luaentity = obj:get_luaentity ()
					if predicate (self, self_pos, obj, luaentity)
						and self:target_visible (self_pos, obj) then
						local pos = obj:get_pos ()
						if self:test_object_and_restriction (obj, pos) then
							local d1 = dist_sqr (self_pos, pos)
							local m = self:detection_multiplier_for_object (obj)
							if d1 <= view_range * m * m and d1 < d then
								d = d1
								target = obj
							end
						end
					end
				end
			end
		else
			local d = huge
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
		end

		return target
	end
	return mcl_mobs.build_target_rule ({
		fn = fn,
		on_complete = nil,
	})
end

local RETALIATION_PERSISTENCE = 15

local function run_mob_predicate (self, self_pos, predicate, obj)
	if obj:is_valid () then
		local luaentity = obj:get_luaentity ()
		return (obj:is_player () or luaentity)
			and predicate (self, self_pos, obj, luaentity)
	end
	return false
end

function mob_class:broadcast_attack (self_pos, target, objects, alert_predicate)
	for _, object in ipairs (objects) do
		if object ~= self.object
			and run_mob_predicate (self, self_pos, alert_predicate,
					       object) then
			local entity = object:get_luaentity ()
			assert (entity)
			entity:receive_attack (target)
		end
	end
end

function mob_class:read_last_attacker ()
	local id = self._last_attack_id
	if self._last_recorded_attack_id ~= id then
		local obj = self._last_attacker
		self._last_recorded_attack_id = id
		if obj then
			return object_targetable_p (obj) and obj or nil
		end
	end
	return nil
end

function mcl_mobs.build_retaliation_target_rule (ignore, alert_others, alert_predicate)
	if type (ignore) == "table" then
		ignore = mcl_mobs.build_search_predicate (ignore)
	elseif not ignore then
		ignore = function (_, _, _, _)
			return false
		end
	end
	if type (alert_predicate) == "table" then
		alert_predicate
			= mcl_mobs.build_search_predicate (alert_predicate)
	elseif not alert_predicate then
		alert_predicate = function (_, _, _, _)
			return false
		end
	end

	local fn = function (self, self_pos, dtime, obj, is_current)
		-- Don't be distracted by other attackers when one is
		-- already being pursued.
		if is_current then
			local dist = self.tracking_distance * self.tracking_distance
			return self:track_current_target (self_pos, dtime, obj, dist,
							  RETALIATION_PERSISTENCE)
		end

		local attacker = self:read_last_attacker ()
		if attacker then
			local luaentity = attacker:get_luaentity ()
			if not ignore (self, self_pos, attacker, luaentity) then
				local obj_pos = attacker:get_pos ()
				if self:test_object_and_restriction (attacker, obj_pos)
					and not self:target_owner_p (attacker) then
					if alert_others then
						local range = self.view_range
						local objects
							= self:objects_for_targeting (self_pos, range)
						self:broadcast_attack (self_pos, attacker, objects,
								       alert_predicate)
					end
					local dist = self.tracking_distance
					if vector.distance (self_pos, obj_pos) < dist then
						return attacker
					end
				end
			end
		end
		return
	end
	return mcl_mobs.build_target_rule ({
		fn = fn,
		on_complete = nil,
	})
end

function mob_class:target_owner_p (target)
	if self.tamed and self.owner
		and core.get_player_by_name (self.owner) == target then
		return true
	end
	return false
end

function mob_class:receive_attack (target)
	if self:target_owner_p (target) or self._active_target then
		return false
	end
	self._alert_receiver_target = target
	return true
end

local function alert_receiver_rule (self, self_pos, dtime, obj, is_current)
	if is_current then
		local t = self._alert_receiver_time - dtime
		self._alert_receiver_time = t
		if t > 0 then
			return self:track_current_target (self_pos, dtime, obj, 5184.0,
							  RETALIATION_PERSISTENCE)
		else
			local dist = self.tracking_distance * self.tracking_distance
			return self:track_current_target (self_pos, dtime, obj, dist,
							  RETALIATION_PERSISTENCE)
		end
	else
		local target = self._alert_receiver_target
		if target and object_targetable_p (target) then
			local target_pos = target:get_pos ()
			if self:test_object_and_restriction (target, target_pos)
				and dist_sqr (self_pos, target_pos) < 5184.0 then
				-- Afford this mob a maximum of 20
				-- seconds to approach within
				-- tracking_distance of the object,
				-- after which the increased distance
				-- of 72 nodes ceases to apply.
				self._alert_receiver_time = 20.0
				self._alert_receiver_target = nil
				return target
			end
		end
		self._alert_receiver_target = nil
	end
	return nil
end

local function alert_receiver_complete (self)
	self._alert_receiver_target = nil
	self._alert_receiver_time = nil
end

function mcl_mobs.build_alert_receiver_rule ()
	return mcl_mobs.build_target_rule ({
		fn = alert_receiver_rule,
		on_complete = alert_receiver_complete,
	})
end

------------------------------------------------------------------------
-- Generic combat routines.
------------------------------------------------------------------------

function mob_class:attack_player_allowed (player)
	return mcl_vars.difficulty ~= 0
		and mcl_gamemode.get_gamemode (player) ~= "creative"
		and player:get_hp () > 0
end

function mob_class:standing_on_walkable ()
	local def = core.registered_nodes [self.standing_on]
	return def and def.walkable
end

-- Apply projectile knockback.
function mob_class:projectile_knockback (factor, dir)
	local velocity = self.object:get_velocity ()
	local standing = self:standing_on_walkable ()
	local resistance = self.knockback_resistance
	local knockback
		= mcl_util.calculate_knockback (velocity, factor * 0.5,
						resistance,
						standing, dir.x, dir.z)
	self.object:set_velocity (knockback)
end

local function source_is_player_or_tamed_wolf (mcl_reason)
	local source = mcl_reason.source
	if source:is_player () then
		return source:get_player_name ()
	else
		local entity = source:get_luaentity ()
		if entity and entity.name == "mobs_mc:wolf"
			and entity.tamed then
			return entity.owner
		end
	end
	return nil
end

-- Register damage delivered by punches or other means, and report the
-- same to callbacks and targeting rules.

local attack_id = 0

function mob_class:receive_damage (mcl_reason, damage)
	local source = mcl_reason.source
	self.health = self.health - damage

	if not source then
		self:check_for_death (mcl_reason, damage)
		return true
	end

	local name = source_is_player_or_tamed_wolf (mcl_reason)
	if name then
		self.last_player_hit_time = core.get_gametime ()
		self.last_player_hit_name = name
	end

	if source:is_player () and source:get_player_name () == self.owner then
		self:check_for_death (mcl_reason, damage)
		return true
	end

	if damage < 0 then
		-- Healing.
		return true
	end

	if source then
		self._recent_attacker = source
		self._recent_attacker_age = 0
	end
	self._last_attacker = source
	self._last_attack_id = attack_id + 1
	attack_id = attack_id + 1

	-- Alert others to the attack.
	if source and source:is_valid () and self.health > 0
	-- But not if the source is this mob itself, as when damage is
	-- inflicted by a deflected trident.
		and source ~= self.object then
		if self.runaway then
			self:do_runaway (source)
		end
	end
	self:check_for_death (mcl_reason, damage)
	self._inactivity_timer = 0
	return true
end

-- deal damage and effects when mob punched
function mob_class:on_punch(hitter, tflp, tool_capabilities, dir)
	local is_player = hitter and hitter:is_player()
	local hitter_playername = is_player and hitter:get_player_name()
	if hitter_playername and hitter_playername ~= "" then
		doc.mark_entry_as_revealed(hitter_playername, "mobs", self.name)
		mcl_potions.update_haste_and_fatigue(hitter)
	end

	if self.do_punch then
		if self.do_punch(self, hitter, tflp, tool_capabilities, dir) == false then
			return
		end
	end

	-- error checking when mod profiling is enabled
	if not tool_capabilities then
		core.log("warning", "[mobs] Mod profiling enabled, damage not enabled")
		return
	end

	if is_player then
		-- is mob protected?
		if self.protected and core.is_protected(self.object:get_pos(), hitter_playername) then
			return
		end
	end


	-- punch interval
	local weapon = hitter and mcl_util.get_wielditem (hitter)
	local punch_interval = 0.5

	-- exhaust attacker
	if is_player then
		mcl_hunger.exhaust(hitter_playername, mcl_hunger.EXHAUST_ATTACK)
	end

	-- calculate mob damage
	local damage = 0
	local armor = self.object:get_armor_groups() or {}

	for group,_ in pairs( (tool_capabilities.damage_groups or {}) ) do

		local tmp = tflp / (tool_capabilities.full_punch_interval or 1.4)

		if tmp < 0 then
			tmp = 0.0
		elseif tmp > 1 then
			tmp = 1.0
		end

		damage = damage + (tool_capabilities.damage_groups[group] or 0)
			* tmp * ((armor[group] or 0) / 100.0)
	end

	-- strength and weakness effects
	local strength = mcl_potions.get_effect(hitter, "strength")
	local weakness = mcl_potions.get_effect(hitter, "weakness")
	local str_fac = strength and strength.factor or 1
	local weak_fac = weakness and weakness.factor or 1
	damage = damage * str_fac * weak_fac

	if weapon then
		local fire_aspect_level = mcl_enchanting.get_enchantment(weapon, "fire_aspect")
		if fire_aspect_level > 0 then
			mcl_burning.set_on_fire(self.object, fire_aspect_level * 4)
		end
	end

	-- healing
	if damage <= -1 then
		self.health = self.health - damage
		return
	end

	-- To enable our custom health handling ("health" property) we use the
	-- "immortal" group to disable engine damage and wear handling, so we
	-- need to roll our own.
	if is_player
	and core.is_creative_enabled(hitter_playername) ~= true
	and tool_capabilities
	and tool_capabilities.punch_attack_uses
	and tool_capabilities.punch_attack_uses > 0
	and weapon then
		local wear = math.floor(65535/tool_capabilities.punch_attack_uses)
		weapon:add_wear(wear)
		hitter:set_wielded_item(weapon)
	end

	if damage >= 0 then
		if damage > 0 then
			-- weapon sounds
			if weapon and weapon:get_definition().sounds ~= nil then

				local s = math.random(0, #weapon:get_definition().sounds)

				core.sound_play(weapon:get_definition().sounds[s], {
							    object = self.object, --hitter,
							    max_hear_distance = 8
										       }, true)
			else
				core.sound_play("default_punch", {
							    object = self.object,
							    max_hear_distance = 5
								     }, true)
			end
		end

		-- Deal damage and run callbacks, e.g. to retaliate.
		local mcl_reason = {}
		mcl_damage.from_punch(mcl_reason, hitter)
		mcl_damage.finish_reason(mcl_reason)
		local damage = mcl_util.deal_damage(self.object, damage, mcl_reason)
		if damage > 0 then
			self:damage_effect (damage)
		end
	end -- END if damage

	-- knock back effect (only on full punch)
	if (damage >= 0 or tool_capabilities.damage_groups.snowball_vulnerable
		or tool_capabilities.damage_groups.egg_vulnerable)
		and (self.knock_back and tflp >= punch_interval) then
		-- Verify that DIR is valid.
		dir = dir or vector.zero ()

		local v = self.object:get_velocity ()
		if not v then return end
		local r = 1.4 - math.min(punch_interval, 1.4)
		local kb = r

		-- check if tool already has specific knockback value
		if tool_capabilities.damage_groups["knockback"] then
			kb = tool_capabilities.damage_groups["knockback"]
		else
			kb = kb * 1.5
		end

		local wielditem = hitter
			and mcl_util.get_wielditem (hitter)
			or ItemStack ()
		if hitter then
			kb = kb + mcl_util.get_additional_knockback (hitter)
		end
		kb = kb + mcl_enchanting.get_enchantment (wielditem, "knockback")
		local standing = self:standing_on_walkable ()
		v = mcl_util.calculate_knockback (v, kb * 0.5, self.knockback_resistance,
						standing, dir.x, dir.z)
		self.object:set_velocity (v)
	end
end

function mob_class:do_runaway ()
	self.runaway_timer = 5
end

function mob_class:test_object_and_restriction (object, obj_pos)
	if object:is_player ()
		and not self:attack_player_allowed (object) then
		return false
	elseif self._restriction_center
		and not self:node_in_restriction (obj_pos) then
		return false
	end
	local entity = object:get_luaentity ()
	if entity and entity.is_mob
		and (entity.dead or not entity:valid_enemy ()) then
		return false
	end
	return object:get_hp () > 0
end

function mob_class:should_continue_to_attack (object)
	return self:test_object_and_restriction (object, object:get_pos ())
end

------------------------------------------------------------------------
-- Combat mechanics.
------------------------------------------------------------------------

function mob_class:get_eye_height ()
	if not self.jockey_vehicle then
		return self.head_eye_height
	else
		return self.head_eye_height + self._jockey_eye_offset
	end
end

function mob_class:get_shoot_offset ()
	if not self.jockey_vehicle then
		return self.shoot_offset
	else
		return self.shoot_offset + self._jockey_eye_offset
	end
end

function mob_class:attack_bowshoot (self_pos, dtime, target_pos, line_of_sight)
	if not self.attacking then
		-- Initialize parameters consulted during the attack.
		self._target_visible_time = 0
		self._strafe_time = -1 -- Don't strafe.
		self._z_strafe = 1
		self._x_strafe = 1
		self._shoot_timer = 0
		self.attacking = true
	end
	local vistime = self._target_visible_time
	local dist = vector.distance (self_pos, target_pos)
	local shoot_pos = {
		x = self_pos.x,
		y = self_pos.y + self:get_shoot_offset (),
		z = self_pos.z,
	}
	local target_bb = self.attack:get_properties ()
	local collisionbox = target_bb.collisionbox
	local target = {
		x = target_pos.x,
		y = target_pos.y + (collisionbox[5] - collisionbox[2]) * 0.33,
		z = target_pos.z,
	}

	if line_of_sight then
		if vistime < 0 then
			vistime = 0
		end
		vistime = vistime + dtime
	else
		if vistime > 0 then
			vistime = 0
		end
		vistime = vistime - dtime
	end

	-- Stop if the target is in range and has been for a second.
	if dist < 15 and vistime >= 1 then
		if not self:navigation_finished () then
			self:cancel_navigation ()
			self:halt_in_tracks ()
		end
		self._strafe_time = self._strafe_time + dtime
		self._timers.bowshoot_pathfind = 0
	else
		if self.movement_goal == "strafe" then
			self:halt_in_tracks ()
		end
		if self:check_timer ("bowshoot_pathfind", 0.5) then
			self:gopath (target_pos, self.pursuit_bonus)
		end
		self._strafe_time = -1
	end

	-- Potentially switch directions after having strafed
	-- for 1 second.
	if self._strafe_time >= 1 then
		if math.random (10) <= 3 then
			self._z_strafe = -self._z_strafe
		end
		if math.random (10) <= 3 then
			self._x_strafe = -self._x_strafe
		end
		self._strafe_time = 0
	end
	local mover = self:mob_controlling_movement ()
	-- Target in range?
	if self._strafe_time > -1 then
		-- Don't allow target to approach too close or move
		-- too far.
		if dist > 15 * 0.75 then
			self._z_strafe = 1
		elseif dist < 15 * 0.55 then
			self._z_strafe = -1
		end

		mover.movement_goal = "strafe"
		mover.movement_velocity = mover.movement_speed * 0.25
		mover.strafe_direction = {
			x = self._x_strafe * 0.5,
			z = self._z_strafe * 0.5,
		}
		self:look_at (target_pos)
		mover:set_animation ("walk")
	end

	if self._using_wielditem then
		if not line_of_sight and vistime < -3 then
			self:release_wielditem ()
		elseif line_of_sight then
			if self._using_wielditem > 1.0 then
				self:release_wielditem ()
				local vec = {
					x = target.x - shoot_pos.x,
					y = target.y - shoot_pos.y,
					z = target.z - shoot_pos.z,
				}

				-- Offset by distance.
				vec.y = vec.y + 0.12 * vector.length (vec)

				if self.shoot_arrow then
					local offset = self:get_shoot_offset ()
					local origin = vector.offset (self_pos, 0, offset, 0)
					vec = vector.normalize (vec)
					self:shoot_arrow (origin, vec)
				end
				self._shoot_timer = self.shoot_interval
			end
		end
	else
		self._shoot_timer = math.max (0, self._shoot_timer - dtime)
		if self._shoot_timer <= 0 then
			self:use_wielditem ()
		end
	end

	self._target_visible_time = vistime
end

function mob_class:custom_attack ()
	-- Punch target.
	local attack = self.attack
	local wielditem = self:get_wielditem ()
	local damage = {
		full_punch_interval = 1.0,
		damage_groups = {fleshy = self.damage},
	}
	if not wielditem:is_empty () then
		damage = table.copy (wielditem:get_tool_capabilities ())
		damage.damage_groups = damage.damage_groups
			and table.copy (damage.damage_groups) or {}
		-- Wielditems used by mobs don't sustain wear in
		-- Minecraft, and their attack damage is combined with
		-- the mob's base attack damage.
		local tool_damage = damage.damage_groups.fleshy
		if not tool_damage then
			damage.damage_groups.fleshy = self.damage
		else
			-- 1 must be subtracted from the total,
			-- because damage values in minetest tool
			-- definitions include that inflicted by the
			-- player's hand.
			tool_damage = math.max (tool_damage - 1, 0)
			damage.damage_groups.fleshy = tool_damage + self.damage
		end
	end
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
	attack:punch (self.object, 1.0, damage, nil)

	if self.ignite_targets_while_burning
		and mcl_burning.is_burning (self.object) then
		if self:get_wielditem ():is_empty () then
			local self_pos = self.object:get_pos ()
			local difficulty
				= mcl_worlds.get_regional_difficulty (self_pos)
			if math.random () < difficulty * 0.3 then
				mcl_burning.set_on_fire (attack, difficulty * 2)
			end
		end
	end

	if self.dealt_effect then
		local duration = self.dealt_effect.dur
		if mcl_vars.difficulty <= 1 and self.dealt_effect.dur_easy then
			duration = self.dealt_effect.dur_easy
		elseif mcl_vars.difficulty > 2 and self.dealt_effect.dur_hard then
			duration = self.dealt_effect.dur_hard
		end

		if self.dealt_effect.respect_local_difficulty then
			local self_pos = self.object:get_pos ()
			local factor = mcl_worlds.get_regional_difficulty (self_pos)
			duration = duration * factor
		end
		if duration > 0 then
			mcl_potions.give_effect_by_level (self.dealt_effect.name, attack,
							  self.dealt_effect.level, duration)
		end
	end
end

function mob_class:pre_melee_attack (distance, delay, line_of_sight)
	return distance <= self.reach and delay == 0 and line_of_sight
end

function mob_class:attack_melee (self_pos, dtime, target_pos, line_of_sight)
	local initial_attack = false
	if not self.attacking then
		-- Initialize attack parameters.
		self._target_pos = nil
		self._gopath_delay = 0
		self._attack_delay = 0
		self.attacking = true
		self._punch_animation_timeout = 0
		initial_attack = true
	end

	if self._punch_animation_timeout then
		self._punch_animation_timeout
			= math.max (self._punch_animation_timeout - dtime, 0)
		if self._punch_animation_timeout == 0 then
			if self:navigation_finished () then
				self:set_animation ("stand")
			else
				self:set_animation ("walk")
			end
			self._punch_animation_timeout = nil
		end
	end

	local delay = math.max (self._gopath_delay - dtime, 0)
	local distance = vector.distance (self_pos, target_pos)

	-- If the target is detectable or this attack has just
	-- commenced...
	if (self._melee_esp or line_of_sight or initial_attack)
		-- ...and the navigation timeout has elapsed...
		and delay == 0
		-- ..and this mob has yet to arrive at its target, or
		-- the path should be recomputed...
		and (not self._target_pos
			or vector.distance (target_pos, self._target_pos) >= 1
			or math.random (100) <= 5) then
		self._target_pos = target_pos

		delay = (4 + math.random (8) - 1) / 20.0

		-- How distant is the target?
		if distance > 32 then
			delay = delay + 0.5
		elseif distance > 16 then
			delay = delay + 0.25
		end

		-- Try to pathfind.
		if not self:gopath (target_pos, self.pursuit_bonus) then
			delay = delay + 0.75
		end
	end
	self._gopath_delay = delay

	-- Can the target be attacked?
	local delay = math.max (self._attack_delay - dtime, 0)
	if self:pre_melee_attack (distance, delay, line_of_sight) then
		self:look_at (target_pos)
		self:custom_attack ()
		delay = self.melee_interval
	end
	self._attack_delay = delay
end

function mob_class:discharge_ranged (self_pos, target_pos)
	local p = target_pos
	local cb_center = (self.collisionbox[2] + self.collisionbox[5]) / 2
	local shoot_offset = cb_center + self:get_shoot_offset ()
	local s = vector.offset (self_pos, 0, shoot_offset, 0)
	local vec = vector.subtract (p, s)

	self:mob_sound ("shoot_attack")
	-- Shoot arrow
	if core.registered_entities[self.arrow] or self.shoot_arrow then
		if self._projectile_gravity then
			-- Offset by distance.
			vec.y = vec.y + 0.12 * vector.length (vec)
		end

		vec = vector.normalize (vec)

		if self.shoot_arrow then
			self:shoot_arrow (s, vec)
		else
			local arrow = core.add_entity (s, self.arrow)
			if not arrow then
				return
			end
			self.firing = true
			core.after(1, function(self)
					       self.firing = false
			end, self)
			local ent = arrow:get_luaentity()
			ent.switch = 1
			ent.owner_id = tostring(self.object) -- add unique owner id to arrow

			-- important for mcl_shields
			arrow:set_velocity (vector.multiply (vec, ent.velocity))
			ent._shooter = self.object
			ent._saved_shooter_pos = self.object:get_pos()
			if ent.homing then
				ent._target = self.attack
			end
		end
	end
end

function mob_class:attack_ranged (self_pos, dtime, target_pos, line_of_sight)
	local vistime, min_distance
	if not self.attacking then
		self._target_visible_time = 0
		self._shoot_timer = self.ranged_interval_min
		self.attacking = true
	end
	vistime = self._target_visible_time

	if line_of_sight then
		vistime = vistime + dtime
	else
		vistime = 0
	end
	self._target_visible_time = vistime
	min_distance = self.ranged_attack_radius

	local distance = vector.distance (self_pos, target_pos)
	if distance < min_distance and vistime > 0.25 then
		self:cancel_navigation ()
		self:halt_in_tracks ()
	else
		if self:check_timer ("ranged_pathfind", 0.5) then
			self:gopath (target_pos, self.pursuit_bonus)
		end
	end
	local shoot_time = self._shoot_timer
	shoot_time = math.max (0, shoot_time - dtime)
	if line_of_sight and self:navigation_finished () then
		self:look_at (target_pos)
	end
	if shoot_time == 0 then
		if line_of_sight then
			-- Attack target.
			self:discharge_ranged (self_pos, target_pos)

			-- Derive the delay from the distance to the
			-- target.
			local rem = distance / min_distance
			local rem = math.max (0.1, math.min (1.0, rem))
			self._shoot_timer = rem * (self.ranged_interval_max
							- self.ranged_interval_min)
				+ self.ranged_interval_min
			return
		end

		-- Likewise, but don't confine it to a fixed
		-- range.
		local rem = distance / min_distance
		self._shoot_timer = rem * (self.ranged_interval_max
					   - self.ranged_interval_min)
			+ self.ranged_interval_min
	else
		self._shoot_timer = shoot_time
	end
end

function mob_class:load_crossbow ()
	local loaded = ItemStack (self._wielditem)
	local name = "mcl_bows:crossbow_loaded"
	if loaded:get_name () == "mcl_bows:crossbow_enchanted" then
		name = "mcl_bows:crossbow_loaded_enchanted"
	end
	loaded:set_name (name)
	self:set_wielditem (loaded)
end

function mob_class:unload_crossbow ()
	local loaded = ItemStack (self._wielditem)
	local name = "mcl_bows:crossbow"
	if loaded:get_name () == "mcl_bows:crossbow_loaded_enchanted" then
		name = "mcl_bows:crossbow_enchanted"
	end
	loaded:set_name (name)
	self:set_wielditem (loaded)
end

function mob_class:is_crossbow_loaded ()
	local loaded = ItemStack (self._wielditem)
	local name = loaded:get_name ()
	return name == "mcl_bows:crossbow_loaded"
		or name == "mcl_bows:crossbow_loaded_enchanted"
end

function mob_class:attack_crossbow (self_pos, dtime, target_pos, line_of_sight)
	if not self.attacking then
		self._vistime = 0
		self._time_to_next_repath = 0
		self._shoot_delay = 0
		-- 0: uncharged, 1: charging, 2: charged, 3: ready to attack.
		self._crossbow_state = 0
		self.attacking = true

		if self:is_crossbow_loaded () then
			self._crossbow_state = 2
			self._shoot_delay = 1 + math.random (0, 20) * 0.05
		end
	end

	local vistime = self._vistime

	if line_of_sight then
		vistime = math.max (vistime, 0) + dtime
	else
		vistime = math.min (vistime, 0) - dtime
	end

	local dist = vector.distance (self_pos, target_pos)
	local should_pathfind = vistime < 0.25 or dist > self.ranged_attack_radius

	if self._crossbow_backoff_threshold
		and dist < self._crossbow_backoff_threshold
		and line_of_sight then
		self:cancel_navigation ()
		local mover = self:mob_controlling_movement ()
		mover.movement_goal = "strafe"
		mover.movement_velocity = mover.movement_speed * 0.25
		mover.strafe_direction = {
			x = 0,
			z = -1.0,
		}
		self:look_at (target_pos)
		self:set_animation ("walk")
	elseif should_pathfind then
		self._time_to_next_repath
			= self._time_to_next_repath - dtime
		if self._time_to_next_repath <= 0 then
			local speed = self.pursuit_bonus
			if self._crossbow_state > 0 then
				speed = speed * 0.5
			end
			self:gopath (target_pos, speed)
			self._time_to_next_repath = math.random (2)
		end
	else
		self._time_to_next_repath = 0
		self:cancel_navigation ()
		self:halt_in_tracks ()
		self:look_at (target_pos)
	end

	if self._crossbow_state == 0 then
		if not should_pathfind then
			self._crossbow_state = 1
			self:use_wielditem ()
		end
	elseif self._crossbow_state == 1 then
		if not self._using_wielditem then
			self._crossbow_state = 0
		else
			if self._using_wielditem
				>= mcl_bows.CROSSBOW_CHARGE_TIME_FULL then
				self:load_crossbow ()
				self._crossbow_state = 2
				self._shoot_delay = 1 + math.random (0, 20) * 0.05
			end
		end
	elseif self._crossbow_state == 2 then
		self._shoot_delay = self._shoot_delay - dtime
		if self._shoot_delay <= 0 then
			self._crossbow_state = 3
		end
	elseif self._crossbow_state == 3 and line_of_sight then
		self._crossbow_state = 0
		self:unload_crossbow ()
		self:discharge_ranged (self_pos, target_pos)
	end

	self._vistime = vistime
end

function mob_class:reset_attack_type (newtype)
	if newtype == self.attack_type then
		return
	end

	self.attack_type = newtype
	if self.attack then
		self.attacking = false
		self:attack_end ()
		self:cancel_navigation ()
		self:halt_in_tracks ()
	end
end

------------------------------------------------------------------------
-- Target acquisition.
------------------------------------------------------------------------

-- Ref: https://minecraft.wiki/w/Invisibility
function mob_class:detection_multiplier_for_object (object)
	local factor = 1.0

	if mcl_potions.get_effect (object, "invisibility") then
		factor = mcl_armor.get_armor_coverage (object)
		if factor < 0.1 then
			factor = 0.1
		end
		factor = factor * 0.7
	end

	factor = factor * mcl_armor.get_headpiece_factor (object, self.name)
	return factor
end

function mob_class:valid_enemy ()
	return true
end

function mob_class:default_rangecheck (self_pos, object)
	local pos = object:get_pos ()
	local factor = self:detection_multiplier_for_object (object)
	local distance = vector.distance (self_pos, pos)
	return distance <= self.view_range * factor
end

function mob_class:attack_end ()
	self:release_wielditem ()
end

function mob_class:get_active_target (self_pos)
	return self._active_target
end

function mob_class:check_attack (self_pos, dtime)
	if not self.attack_type then
		return false
	end
	if not self.attack then
		local target = self:get_active_target (self_pos)
		if target then
			self.attack = target
			self.attacking = false
			return "attack"
		end
	else
		local target_pos
		if not is_valid (self.attack)
			or self:get_active_target (self_pos) ~= self.attack then
			self.attack = nil
			self:attack_end ()
			return true
		end
		target_pos = self.attack:get_pos ()
		local line_of_sight = self:target_visible (self_pos, self.attack)
		local attack_type = self.attack_type
		if attack_type == "null" then
			if self.attack_null then
				self:attack_null (self_pos, dtime, target_pos, line_of_sight)
			end
		elseif attack_type == "bowshoot" then
			self:attack_bowshoot (self_pos, dtime, target_pos,
					      line_of_sight)
		elseif attack_type == "crossbow" then
			self:attack_crossbow (self_pos, dtime, target_pos,
					      line_of_sight)
		elseif attack_type == "ranged" then
			self:attack_ranged (self_pos, dtime, target_pos, line_of_sight)
		elseif attack_type == "melee" then
			self:attack_melee (self_pos, dtime, target_pos, line_of_sight)
		else
			core.log ("warning", "unknown attack type " .. self.attack_type)
		end

		return true
	end
	return false
end

------------------------------------------------------------------------
-- Item wielding.
------------------------------------------------------------------------

local wielditem_props = {
	visual = "wielditem",
	visual_size = {
		x = 0.21, y = 0.21,
	},
	physical = false,
	pointable = false,
	static_save = false,
	wield_item = "mcl_core:barrier",
}

local wielditem_entity = {
	initial_properties = wielditem_props,
	on_step = function (self)
		local parent = self.object:get_attach ()
		if not parent then
			self.object:remove ()
			return
		end
	end,
}

core.register_entity ("mcl_mobs:wielditem", wielditem_entity)

function mob_class:wielditem_transform (info, stack)
	local rot = info.rotation
	local pos = info.position
	local name = stack:get_name ()
	local def = stack:get_definition ()

	if info.toollike_position
		and def and def._mcl_toollike_wield then
		rot = info.toollike_rotation
		pos = info.toollike_position
	elseif info.bow_position
		and core.get_item_group (name, "bow") > 0 then
		rot = info.bow_rotation
		pos = info.bow_position
	elseif info.crossbow_position
		and core.get_item_group (name, "crossbow") > 0 then
		rot = info.crossbow_rotation
		pos = info.crossbow_position
	elseif info.blocklike_position
		and def and def.inventory_image == "" then
		rot = info.blocklike_rotation
		pos = info.blocklike_position
	elseif info.trident_position
		and core.get_item_group (name, "trident") > 0 then
		rot = info.trident_rotation
		pos = info.trident_position
	end
	return rot, pos, table.copy (wielditem_props.visual_size)
end

function mob_class:display_wielditem (offhand)
	local info = offhand and self._offhand_wielditem_info
		or self.wielditem_info
	if not info then
		return
	end
	local objectname = "_wielditem_object"
	if offhand then
		objectname = "_offhand_object"
	end
	local itemname = "_wielditem"
	if offhand then
		itemname = "_offhand_item"
	end
	assert (info.bone)
	if not self[itemname]
		or ItemStack (self[itemname]):is_empty () then
		if self[objectname] ~= nil then
			self[objectname]:remove ()
			self[objectname] = nil
		end
		return
	end

	if not self[objectname]
		or not is_valid (self[objectname]) then
		local self_pos = self.object:get_pos ()
		self[objectname]
			= core.add_entity (self_pos, "mcl_mobs:wielditem")
	end

	-- Apply rotation and position according to item type.
	local stack = ItemStack (self[itemname])
	local rot, pos, size = self:wielditem_transform (info, stack)
	if not info.rotate_bone then
		self[objectname]:set_attach (self.object, info.bone, pos, rot)
	else
		self[objectname]:set_attach (self.object, info.bone)
		mcl_util.set_bone_position (self.object, info.bone, pos, rot)
	end
	local name = self:get_visual_wielditem (stack)
	self[objectname]:set_properties ({
		wield_item = name,
		visual_size = size,
	})
end

function mob_class:set_wielditem (stack, drop_probability)
	if not self.can_wield_items then
		return
	end

	local stack_string
	if not stack or stack:is_empty () then
		stack_string = nil
	else
		stack_string = stack:to_string ()
	end

	self._using_wielditem = nil
	self._wielditem = stack_string
	self._effective_wielditem_drop_probability
		= drop_probability or self.wielditem_drop_probability
	self:display_wielditem (false)
end

function mob_class:drop_wielditem (bonus, min_probability)
	local self_pos = self.object:get_pos ()
	if self._effective_wielditem_drop_probability
		and self._wielditem then
		local probability = self._effective_wielditem_drop_probability
		local item = self._wielditem
		if probability > 0 and item and item ~= ""
			and (probability + bonus) >= (min_probability or 0)
			and math.random () <= probability + bonus then
			local stack = ItemStack (self._wielditem)

			if not mcl_enchanting.has_enchantment (stack, "curse_of_vanishing") then
				self:scale_durability_for_drop (stack, probability)
				mcl_util.drop_item_stack (self_pos, stack)
			end
		end
		self:set_wielditem (ItemStack ())
	end
end

function mob_class:get_wielditem ()
	return ItemStack (self._wielditem)
end

function mob_class:use_wielditem ()
	if self._wielditem ~= "" then
		self._using_wielditem = 0.0
	end
end

function mob_class:release_wielditem ()
	if self._using_wielditem then
		self._using_wielditem = nil

		local object = self._wielditem_object
		if object and is_valid (object) then
			local stack = ItemStack (self._wielditem)
			local name = self:get_visual_wielditem (stack)

			object:set_properties ({
				wield_item = name,
			})
		end
	end
end

local wielditem_variants_by_duration = {}

core.register_on_mods_loaded (function ()
	wielditem_variants_by_duration = {
		["mcl_bows:bow"] = {
			half_time = mcl_bows.BOW_CHARGE_TIME_HALF,
			full_time = mcl_bows.BOW_CHARGE_TIME_FULL,
			start = "mcl_bows:bow_0",
			half = "mcl_bows:bow_1",
			full = "mcl_bows:bow_2",
		},
		["mcl_bows:bow_enchanted"] = {
			half_time = mcl_bows.BOW_CHARGE_TIME_HALF,
			full_time = mcl_bows.BOW_CHARGE_TIME_FULL,
			start = "mcl_bows:bow_0_enchanted",
			half = "mcl_bows:bow_1_enchanted",
			full = "mcl_bows:bow_2_enchanted",
		},
		-- TODO: Quick Charge?
		["mcl_bows:crossbow"] = {
			half_time = mcl_bows.CROSSBOW_CHARGE_TIME_HALF,
			full_time = mcl_bows.CROSSBOW_CHARGE_TIME_FULL,
			start = "mcl_bows:crossbow_0",
			half = "mcl_bows:crossbow_1",
			full = "mcl_bows:crossbow_2",
		},
		["mcl_bows:crossbow_enchanted"] = {
			half_time = mcl_bows.CROSSBOW_CHARGE_TIME_HALF,
			full_time = mcl_bows.CROSSBOW_CHARGE_TIME_FULL,
			start = "mcl_bows:crossbow_0_enchanted",
			half = "mcl_bows:crossbow_1_enchanted",
			full = "mcl_bows:crossbow_2_enchanted",
		},
	}
end)

function mob_class:get_visual_wielditem (stack)
	local name = stack:get_name ()
	if not self._using_wielditem then
		return name
	else
		local variants = wielditem_variants_by_duration[name]
		if not variants then
			return name
		else
			if self._using_wielditem >= variants.full_time then
				return variants.full
			elseif self._using_wielditem >= variants.half_time then
				return variants.half
			else
				return variants.start
			end
		end
	end
end

function mob_class:wielditem_step (dtime)
	if self._using_wielditem then
		self._using_wielditem
			= self._using_wielditem + dtime

		local object = self._wielditem_object
		if object and is_valid (object) then
			local stack = ItemStack (self._wielditem)
			local name = self:get_visual_wielditem (stack)

			object:set_properties ({
				wield_item = name,
			})
		end
	end
end

local armor_types = { "head", "torso", "legs", "feet", }
local armor_table = {
	head = {
		"mcl_armor:helmet_leather",
		"mcl_armor:helmet_copper",
		"mcl_armor:helmet_gold",
		"mcl_armor:helmet_chain",
		"mcl_armor:helmet_iron",
		"mcl_armor:helmet_diamond",
	},
	torso = {
		"mcl_armor:chestplate_leather",
		"mcl_armor:chestplate_copper",
		"mcl_armor:chestplate_gold",
		"mcl_armor:chestplate_chain",
		"mcl_armor:chestplate_iron",
		"mcl_armor:chestplate_diamond",
	},
	legs = {
		"mcl_armor:leggings_leather",
		"mcl_armor:leggings_copper",
		"mcl_armor:leggings_gold",
		"mcl_armor:leggings_chain",
		"mcl_armor:leggings_iron",
		"mcl_armor:leggings_diamond",
	},
	feet = {
		"mcl_armor:boots_leather",
		"mcl_armor:boots_copper",
		"mcl_armor:boots_gold",
		"mcl_armor:boots_chain",
		"mcl_armor:boots_iron",
		"mcl_armor:boots_diamond",
	},
}

function mob_class:enchant_default_armor (mob_factor, pr)
	for slot, item in pairs (self.armor_list) do
		local stack = ItemStack (item)
		if not stack:is_empty () then
			if math.random () < 0.5 * mob_factor then
				local level = 5.0 + mob_factor * pr:next (1, 18)
				level = math.floor (level)
				mcl_enchanting.enchant_randomly (stack, level, false, false, true)
			end
			self.armor_list[slot] = stack:to_string ()
		end
	end
end

function mob_class:enchant_default_weapon (mob_factor, pr)
	local stack = self:get_wielditem ()
	if stack:is_empty () then
		return
	end
	if math.random () < 0.25 * mob_factor then
		local level = 5.0 + mob_factor * pr:next (1, 18)
		level = math.floor (level)
		mcl_enchanting.enchant_randomly (stack, level, false, false, true)
	end
	self:set_wielditem (stack)
end

function mob_class:generate_default_equipment (mob_factor, do_armor, do_wielditems)
	if do_armor and math.random () < mob_factor * 0.15 then
		-- Decide what armor material this mob will
		-- wear.
		local base_level = math.random (3)
		if math.random () < 0.095 then
			base_level = base_level + 1
		end
		if math.random () < 0.095 then
			base_level = base_level + 1
		end
		if math.random () < 0.095 then
			base_level = base_level + 1
		end
		local armor_generated = false
		local stop_chance = 4
		if mcl_vars.difficulty == 3 then
			stop_chance = 10
		end
		for _, slot in ipairs (armor_types) do
			if not armor_generated and math.random (stop_chance) == 1 then
				break
			end
			local stack = ItemStack (armor_table[slot][base_level])
			if math.random () < 0.5 * mob_factor then
				local level = 5.0 + mob_factor * math.random (18)
				level = math.floor (level)
				mcl_enchanting.enchant_randomly (stack, level, false, false, true)
			end
			self.armor_list[slot] = stack:to_string ()
			local probability = self.armor_drop_probability[slot]
			self:set_armor_drop_probability (slot, probability)
		end
		self:set_armor_texture ()
	end
	if do_wielditems then
		local chance = (mcl_vars.difficulty == 3) and 20 or 100
		if math.random (chance) == 1 then
			local stack
			if math.random (3) == 1 then
				stack = ItemStack ("mcl_tools:sword_iron")
			else
				stack = ItemStack ("mcl_tools:shovel_iron")
			end
			if math.random () < 0.25 * mob_factor then
				local level = 5.0 + mob_factor * math.random (18)
				level = math.floor (level)
				mcl_enchanting.enchant_randomly (stack, level, false, false, true)
			end
			self:set_wielditem (stack)
		end
	end
end

------------------------------------------------------------------------
-- Offhand item wielding.
------------------------------------------------------------------------

function mob_class:drop_offhand_item (bonus, min_probability)
	local self_pos = self.object:get_pos ()
	if self._effective_offhand_drop_probability
		and self._offhand_item then
		local probability = self._effective_offhand_drop_probability
		local item = self._offhand_item
		if probability > 0 and item and item ~= ""
			and (probability + bonus) >= (min_probability or 0)
			and math.random () <= probability + bonus then
			local stack = ItemStack (self._offhand_item)

			if not mcl_enchanting.has_enchantment (stack, "curse_of_vanishing") then
				self:scale_durability_for_drop (stack, probability)
				mcl_util.drop_item_stack (self_pos, stack)
			end
		end
		self:set_offhand_item (ItemStack (""))
	end
end

function mob_class:set_offhand_item (stack, drop_probability)
	if not self._offhand_wielditem_info then
		return
	end

	if not stack then
		self._offhand_item = ""
	else
		self._offhand_item = stack:to_string ()
	end

	self._effective_offhand_drop_probability
		= drop_probability or self.wielditem_drop_probability
	self:display_wielditem (true)
end

function mob_class:get_offhand_item ()
	return ItemStack (self._offhand_item)
end

------------------------------------------------------------------------
-- Callbacks.
------------------------------------------------------------------------

function mob_class:shield_impact (object, mcl_reason)
end
