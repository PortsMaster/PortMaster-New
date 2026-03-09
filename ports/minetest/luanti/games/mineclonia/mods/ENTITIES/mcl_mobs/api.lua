local S = core.get_translator("mcl_mobs")

local pairs = pairs
local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

local only_peaceful_mobs = core.settings:get_bool("only_peaceful_mobs", false)

-- Invisibility mod check
mcl_mobs.invis = {}

function mob_class:set_properties(prop)
	mcl_util.set_properties(self.object, prop)
end

function mob_class:safe_remove()
	self.removed = true
	core.after(0,function(obj)
		if obj and obj:get_pos() then
			mcl_burning.extinguish(obj)
			obj:remove()
		end
	end,self.object)
end

function mob_class:replace_with (successor_type, propagate_equipment, mob_staticdata)
	local default_staticdata = {
		child = self.child,
		nametag = self.nametag,
		persistent = self.persistent,
	}
	if mob_staticdata then
		default_staticdata
			= table.merge (default_staticdata, mob_staticdata)
	end
	local self_pos = self.object:get_pos ()
	local staticdata = core.serialize (default_staticdata)
	local new = core.add_entity (self_pos, successor_type, staticdata)
	if not new then
		return nil
	end
	local luaentity = new:get_luaentity ()
	local yaw = self.object:get_yaw ()
	assert (luaentity.is_mob)

	-- Only transfer this mob's ability to equip dropped armor or
	-- items if the new mob is capable of wearing armor.
	if propagate_equipment then
		if luaentity.wears_armor then
			luaentity.wears_armor = self.wears_armor
		end
		if luaentity.can_wield_items then
			luaentity.can_wield_items = self.can_wield_items
		end

		if luaentity.can_wield_items then
			local item = self:get_wielditem ()
			local offhand = self:get_offhand_item ()

			self:set_wielditem (ItemStack ())
			self:set_offhand_item (ItemStack ())
			luaentity:set_wielditem (item)
			luaentity:set_offhand_item (offhand)
			luaentity._effective_wielditem_drop_probability
				= self._effective_wielditem_drop_probability
			luaentity._effective_offhand_drop_probability
				= self._effective_offhand_drop_probability
		end
		if luaentity.wears_armor and self.armor_list then
			luaentity.armor_list = table.copy (self.armor_list)
			self.armor_list = {
				head = "",
				torso = "",
				feet = "",
				legs = "",
			}
			luaentity:set_armor_texture ()
			luaentity.armor_drop_probability
				= table.copy (self.armor_drop_probability)
		end
	end

	if self.jockey_vehicle then
		local vehicle = self.jockey_vehicle
		local bone = vehicle._jockey_bone
		local pos = vehicle._jockey_pos
		local rot = vehicle._jockey_rot
		local fix_eye_height = vehicle._jockey_fix_eye_height
		self:dismount_jockey ()
		luaentity:jock_to_existing (vehicle, bone, pos, rot,
					    fix_eye_height)
	end
	luaentity:set_yaw (yaw)
	self:safe_remove ()
	return new
end

function mob_class:get_nametag()
	return self.nametag or ""
end

function mob_class:update_tag() --update nametag and/or the debug box
	self:set_properties({
		nametag = self:get_nametag(),
	})
end

function mob_class:update_timers (dtime)
	for k, v in pairs (self._timers) do
		self._timers[k] = v - dtime
		self._timers_fired[k] = nil
	end
end

function mob_class:check_timer (timer, interval)
	local timers = self._timers
	if not timers[timer] then
		-- Start with a random time to avoid many timers
		-- firing simultaneously.
		timers[timer] = math.random () * interval
	end
	if timers[timer] <= 0 then
		timers[timer] = interval
		-- Permit timers triggered during this globalstep to
		-- be reported as such by subsequent invocations of
		-- this function.
		self._timers_fired[timer] = true
		return true
	end
	return self._timers_fired[timer] or false
end

function mob_class:get_staticdata_table ()
	local pos = self.object:get_pos ()
	if not pos then
		self.object:remove ()
		return nil
	end

	local tmp = {}

	for tag, stat in pairs(self) do
		local t = type(stat)
		if t ~= "function" and t ~= "nil" and t ~= "userdata" then
			tmp[tag] = self[tag]
		end
	end

	-- Erase state variables that mustn't be preserved.
	tmp.pathfinding_context = nil
	tmp.waypoints = nil
	tmp._navigation_session = nil
	tmp._gwp_did_timeout = nil
	tmp._targets_visible = nil
	tmp._leader = nil
	tmp._school = nil
	tmp.head_eye_height = nil
	tmp._adult_head_eye_height = nil
	tmp._old_head_swivel_vector = nil
	tmp._old_head_swivel_pos = nil
	tmp._head_swivel_pos = nil
	tmp._activated = nil
	tmp._water_current = nil
	tmp._stuck_in = nil
	tmp._liquidtype = nil
	tmp._last_standing_in = nil
	tmp._last_standing_on = nil
	tmp._last_liquidtype = nil
	tmp._reloaded = true
	tmp._soul_speed_level = nil
	tmp._last_soul_speed_bonus = nil
	tmp._depth_strider_level = nil
	tmp._active_targeting_rule = nil
	tmp._active_target = nil
	tmp._object_search_lists = nil
	tmp._last_attack_id = nil
	tmp._last_recorded_attack_id = nil
	tmp._timers_fired = nil
	tmp._timers = nil
	tmp._alert_receiver_time = nil
	tmp._alert_receiver_target = nil

	-- Remove physics factors that are not persistent and revert
	-- fields that were modified and disapply them.
	tmp._physics_factors = table.copy (self._physics_factors or {})
	for field, factors in pairs (tmp._physics_factors) do
		tmp[field] = factors.base

		for id, factor in pairs (factors) do
			if id ~= "base"
				and not self._persistent_physics_factors[id]
				and not mcl_mobs.persistent_physics_factors[id] then
				factors[id] = nil
			end
		end
	end

	if self._mcl_potions then
		tmp._mcl_potions = self._mcl_potions
		for name_raw, data in pairs(tmp._mcl_potions) do
			data.spawner = nil
			local def = mcl_potions.registered_effects[name_raw:match("^_EF_(.+)$")]
			if def and def.on_save_effect then def.on_save_effect(self.object) end
		end
	else
		tmp._mcl_potions = {}
	end

	-- If fortunately the jockey rider is still present, prefer
	-- staticdata derived "from the horse's mouth" to any saved by
	-- prior on_deactivate callbacks.
	--
	-- If rider(s) have been deactivated first, their staticdata
	-- will none the less have been preserved by on_deactivate and
	-- suchlike.
	if self._jockey_rider and is_valid (self._jockey_rider) then
		local entity = self._jockey_rider:get_luaentity ()
		local rider_data = entity:get_staticdata_table ()
		rider_data.name = entity.name
		tmp._jockey_staticdata = rider_data
	end
	return tmp
end

--[[
NOTE: This function is not called when something is about to despawn.

It is called every 18 seconds.

DO NOT change the state of the mob in this function!

Edit the copied state so it's serialized in the state you need to.
]]
function mob_class:get_staticdata()
	local data = self:get_staticdata_table ()
	return core.serialize (data)
end

function mob_class:valid_texture(def_textures)
	if not self.base_texture then
		return false
	end

	if self.texture_selected then
		if #def_textures < self.texture_selected then
			self.texture_selected = nil
		else
			return true
		end
	end
	return false
end

function mob_class:update_textures()
	local def = mcl_mobs.registered_mobs[self.name]
	--If textures in definition change, reload textures
	if not self:valid_texture(def.texture_list) then

		-- compatiblity with old simple mobs textures
		if type(def.texture_list[1]) == "string" then
			def.texture_list = {def.texture_list}
		end

		if not self.texture_selected then
			local c = 1
			if #def.texture_list > c then c = #def.texture_list end
			self.texture_selected = math.random(c)
		end

		-- Otherwise set_armor_texture will modify the texture
		-- list in the metatable, which eventually appears in
		-- mob spawners.
		self.base_texture = table.copy (def.texture_list[self.texture_selected])
		self.base_mesh = def.initial_properties.mesh
		self.base_size = def.initial_properties.visual_size
		self.base_colbox = table.copy (def.initial_properties.collisionbox)
		self.base_selbox = def.initial_properties.selectionbox
	end
end

function mob_class:scale_size_of_child (scale)
	local collisionbox = {
		self.base_colbox[1] * scale,
		self.base_colbox[2] * scale,
		self.base_colbox[3] * scale,
		self.base_colbox[4] * scale,
		self.base_colbox[5] * scale,
		self.base_colbox[6] * scale,
	}
	self.collisionbox = collisionbox
	local initial_size = self.initial_properties.visual_size
	self:set_properties ({
		visual_size = self._child_mesh and initial_size or {
			x = self.base_size.x * scale,
			y = self.base_size.y * scale,
		},
		collisionbox = collisionbox,
		selectionbox = {
			self.base_selbox[1] * scale,
			self.base_selbox[2] * scale,
			self.base_selbox[3] * scale,
			self.base_selbox[4] * scale,
			self.base_selbox[5] * scale,
			self.base_selbox[6] * scale,
		},
		mesh = self._child_mesh or self.base_mesh,
	})
	-- This presumes that the collision box does not extend much
	-- beneath the mob origin.
	self._adult_head_eye_height = self.head_eye_height
	self.head_eye_height = self.head_eye_height * scale
end

function mob_class:post_load_staticdata ()
	-- Initialize this mob's list of physics factors if none
	-- already exists.
	if self._physics_factors == nil then
		self._physics_factors = {}
		self:randomize_attributes ()
	else
		self:restore_physics_factors ()
	end

	-- Remove invalid entries in doors_to_close. See
	-- https://codeberg.org/mineclonia/mineclonia/issues/3286 for more
	-- information.
	if self.doors_to_close then
		local newtable = {}
		for _, v in pairs(self.doors_to_close) do
			if v.x then
				table.insert(newtable, v)
			else
				core.log("error", "Found invalid doors to close in mob, removing to prevent crash")
			end
		end
		self.doors_to_close = newtable
	end

	-- Erase timers.
	self._timers = {}
	self._timers_fired = {}
	if not self.texture_mods then
		self.texture_mods = {}
	end

	-- Enroll this mob in any active raid to which it might
	-- belong.
	if self.raidmob then
		mcl_raids.load_raidmob (self)
	end
end

function mob_class:mob_activate (staticdata, dtime)
	if not self.object:get_pos() or staticdata == "remove" then
		mcl_burning.extinguish(self.object)
		self.object:remove()
		return false
	end

	if staticdata then
		local tmp = core.deserialize(staticdata)
		if tmp then
			for _,stat in pairs(tmp) do
				self[_] = stat
			end
		end
	end

	self:post_load_staticdata ()
	self.acc_dir = vector.zero ()
	self.acc_speed = 0
	self._water_current = vector.zero ()
	self._initial_step_height = self.initial_properties.stepheight
	self._previously_floating = nil
	self._active_texture_list = nil
	self._mob_invisible = false
	self._was_stuck = false
	self._sprinting = false
	self._crouching = false
	self._was_touching_ground = true
	self._old_head_swivel_vector = nil
	self._old_head_swivel_pos = nil
	self._csm_driving = false
	self._driving_sent = nil

	if self.head_swivel then
		self._head_swivel_pos
			= vector.new (0, self.bone_eye_height, self.horizontal_head_height)
	end

	if self.dead then
		self:safe_remove()
		return false
	end

	if (mcl_vars.difficulty <= 0 or only_peaceful_mobs) and not self.persist_in_peaceful then
		mcl_burning.extinguish(self.object)
		self.object:remove()
		return false
	end

	self:update_textures()

	if not self.base_selbox then
		self.base_selbox = self.initial_properties.selectionbox or self.base_colbox
	end

	if self.gotten == true and self.gotten_mesh then
		self:set_properties({mesh = self.gotten_mesh})
	end

	local def = mcl_mobs.registered_mobs[self.name]
	self.collisionbox = self.initial_properties.collisionbox
	if self.child == true then
		self:scale_size_of_child (0.5)
		if def.child_texture then
			self.base_texture = def.child_texture[1]
		end
		-- This is cleared when the mob matures.
		if self._child_animations then
			self.animation = self._child_animations
		end
	end

	if self.health == 0 then
		self.health = math.random (self.hp_min, self.object:get_properties().hp_max)
	end
	if self.breath == nil then
		self.breath = self.object:get_properties().breath_max
	end

	-- Armor groups
	-- immortal=1 because we use custom health
	-- handling (using "health" property)
	local armor
	if type(self.armor) == "table" then
		armor = table.copy(self.armor)
		armor.immortal = 1
	else
		armor = {immortal=1, fleshy = self.armor}
	end
	self.object:set_armor_groups(armor)
	self.sounds.distance = self.sounds.distance or 10

	self.object:set_texture_mod("")

	if not self.nametag then
		self.nametag = def.nametag
	end

	self.base_size = self.base_size or {x = 1, y = 1, z = 1}

	if self.base_texture then
		self:set_textures (self.base_texture)
	end

	self:set_yaw ((math.random(0, 360) - 180) / 180 * math.pi)
	self:update_tag()
	self._current_animation = nil
	self:set_animation( "stand")

	if self.riden_by_jock then --- Old-style jockeys.
		self.object:remove()
		return
	end
	self:restore_jockey ()

	self:init_ai ()
	self:display_wielditem (false)
	self:display_wielditem (true)

	if type (self._armor_texture_slots) == "number" then
		self._armor_texture_slots = {
			[self._armor_texture_slots] = {
				"head",
				"torso",
				"legs",
				"feet",
			},
		}
	end

	if not self.wears_armor and self.armor_list then
		self.armor_list = nil
	elseif not self._run_armor_init and self.wears_armor then
		self.armor_list = { head = "", torso = "", feet = "", legs = "" }
		self:set_armor_texture ()
		self._run_armor_init = true
	else
		mcl_armor.head_entity_equip (self.object)
		self:initialize_armor_enchantments ()
	end

	if self.on_spawn and not self.on_spawn_run then
		if self:on_spawn() == false then
			self:safe_remove()
			return
		else
			self.on_spawn_run = true
		end
	end

	if not self._mcl_potions then
		self._mcl_potions = {}
	end
	mcl_potions._load_entity_effects(self)

	if def.after_activate then
		def.after_activate(self, staticdata, def, dtime)
	end
	self:remove_texture_mod ("^[colorize:#d42222:175")

	-- Record this mob's presence for spawning.
	if not self.persistent or self.tamed then
		-- Under unknown circumstances, it is possible for a
		-- mob to be created by spawning routines before it is
		-- activated and mob caps are updated.  Mob caps are
		-- adjusted and _activated is set by the mob spawning
		-- process in these situations, after which it is
		-- essential to avoid doubly incrementing them.
		if not self._activated then
			if self:announce_for_spawning () then
				return false
			end
		end
	end
	return true
end

function mob_class:actionable_on_rightclick (player)
	return self.tamed
end

local scale_chance = mcl_mobs.scale_chance

local MAX_PHYSICS_DTIME = 0.075
local is_limbo_pos = mcl_biome_dispatch.is_limbo_pos
local floor = math.floor
local node_name_with_fallback = mcl_mobs.node_name_with_fallback

function mob_class:on_step (dtime, moveresult)
	local pos = self.object:get_pos ()
	if not pos or self.removed then
		self:safe_remove()
		return
	end
	self._targets_visible = {}
	local should_drive = self:should_drive ()

	if self._csm_driving then
		if should_drive and not self._driving_sent then
			self._driving_sent = true
			mcl_serverplayer.update_vehicle (self.driver, {
				_driving = true,
			})
		elseif not should_drive and self._driving_sent then
			self._driving_sent = false
			if self.driver then
			    mcl_serverplayer.update_vehicle (self.driver, {
				    _driving = false,
			    }, pos, self.object:get_velocity ())
			end
		end
	end

	if self:check_despawn (pos, dtime)
		or self:update_mob_caps ()
		or self:check_proto_chunk (pos, dtime)
		or is_limbo_pos (pos) then
		return
	end

	-- Objects which are attached and those which are not physical
	-- don't receive moveresults.  Create a placeholder object to
	-- prevent crashes further down the line.
	if not moveresult then
		moveresult = {
			touching_ground = false,
			collides = false,
			standing_on_object = false,
			collisions = { },
		}
	end

	-- These represent the results of collision detection.
	self._moveresult = moveresult
	self._old_velocity = self.object:get_velocity ()

	-- Clear remaining momentum if stuck in a cobweb or analogous
	-- node.
	if self._was_stuck then
		self.object:set_velocity (vector.zero ())
		self._was_stuck = false
	end

	-- Get nodes early for use in other functions
	local cbox = self.collisionbox
	local feet = vector.copy (pos)
	local bbase = pos.y + self.collisionbox[2] + 0.5
	feet.y = floor (bbase + 1.0e-2)
	if bbase - feet.y <= 1.0e-2 then
		local name, _ = node_name_with_fallback (feet, "air")
		self.standing_in = name
		feet.y = feet.y - 1
		local name, param2 = node_name_with_fallback (feet, "air")
		self.standing_on = name
		self.standing_on_param2 = param2
	else
		local name, param2 = node_name_with_fallback (feet, "air")
		self.standing_in = name
		self.standing_on = self.standing_in
		self.standing_on_param2 = param2
	end
	local head_y = cbox[2] + (cbox[5] - cbox[2]) * 0.75
	local pos_head = vector.offset (pos, 0, head_y, 0)
	self.head_in = node_name_with_fallback (pos_head, "air")

	if self:check_jockey_status () then
		return
	end
	self:falling (pos)
	self:check_dying (dtime)

	if self.stupefied then
		-- self.object:set_animation_frame_speed (0)
		if self.waypoints then
			self:navigation_step (dtime, moveresult)
			self:movement_step (dtime, moveresult)
		else
			self:halt_in_tracks ()
		end
		self:pre_motion_step (dtime)
		self:motion_step (dtime, moveresult, pos)
		self:rotate_step (dtime)
		return
	end

	-- Compute fluid immersion.
	local immersion_depth, liquidtype = self:check_standin (pos)
	self._immersion_depth = immersion_depth
	self._liquidtype = liquidtype

	if not should_drive then
		local phys_dtime = math.min (dtime, MAX_PHYSICS_DTIME)
		self:navigation_step (dtime, moveresult)
		self:movement_step (dtime, moveresult)
		self:pre_motion_step (dtime)
		self:motion_step (phys_dtime, moveresult, pos)
	else
		-- At times damage is applied and kills this mob
		-- (removing its driver) between `should_drive' and
		-- the call to `drive' itself.
		if self.driver then
			self:drive ("walk", "stand", false, dtime, moveresult)
		end
	end

	self:post_motion_step (pos, dtime, moveresult)

	self:update_timers (dtime)
	self:ai_step (dtime)

	if not self.fire_resistant then
		mcl_burning.tick (self.object, dtime, self)
	end

	if self.dead then
		return
	end

	self:rotate_step (dtime)
	self:set_animation_speed ()
	self:check_head_swivel (pos, dtime)

	-- Expel drivers riding submerged mobs.
	self:expel_underwater_drivers ()

	if self.do_custom then
		if self.do_custom(self, dtime, moveresult) == false then
			return
		end
	end

	if self._just_portaled then
		self._just_portaled = self._just_portaled - dtime
		if self._just_portaled < 0 then
			self._just_portaled = nil
		end
	end

	if should_drive then
		self:env_damage (pos)
		return
	end

	self:check_particlespawners(dtime)
	self:check_item_pickup()

	-- Mob plays random sound at times.
	local chance = scale_chance (70, dtime)
	if math.random (1, chance) == 1 then
		self:mob_sound("random", true)
	end

	if self:env_damage (pos) then
		return
	end
	self:run_targeting_rules (dtime, pos)
	self:run_ai (dtime, moveresult)
end

core.register_chatcommand("clearmobs",{
	privs = { maphack = true },
	params = "[<all> | <nametagged> | <tamed>] [<range>]",
	description=S("Remove all, nametagged or tamed mobs within the specified distance or everywhere. When unspecified remove all mobs except tamed and nametagged ones."),
	func=function(n,param)
		local sparam = param:split(" ")
		local p = core.get_player_by_name(n)

		local typ
		local range
		if sparam[1] then
			typ = sparam[1]
			if typ ~= "all" and typ ~= "nametagged" and typ ~= "tamed" then
				typ = nil
				range = tonumber(sparam[1])
				if not range then
					return false, S("Invalid syntax.")
				end
			end
		end
		if sparam[2] then
			range = tonumber(sparam[2])
			if not range then
				return false, S("Invalid syntax.")
			end
		end

		for _, o in pairs(core.luaentities) do
			if o.is_mob then
				if not range or vector.distance(p:get_pos(), o.object:get_pos()) <= range then
					if typ == "all" or
						(typ == "nametagged" and o.nametag) or
						(typ == "tamed" and o.tamed and not o.nametag) or
						(not typ and not o.nametag and not o.tamed) then
						o:safe_remove()
					end
				end
			end
		end
end})
