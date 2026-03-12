mcl_tridents = {}

local S = core.get_translator (core.get_current_modname())
local ipairs = ipairs

------------------------------------------------------------------------
-- Tridents.
-- TODO:
-- - [X] Trident entity and discharging.
--       [X] Interactions with entities.
--       [X] Interactions with specific types of blocks.
--       [X] Item collection.
--       [X] Durability.
-- - [X] Player animations.
-- - [X] Trident melee statistics.
-- - [X] Enchantments.
--       [X] Riptide.
--       [X] Loyalty.
--       [X] Impaling.
--       [X] Channeling.
-- - [X] Trident discharging without the CSM.
-- - [ ] Riptide animations.
-- - [X] Dispenser interaction.
------------------------------------------------------------------------

local WIELD_VISUAL_SIZE = {
	x = 1.0 * 0.35,
	y = 1.0 / 6.4 * 0.35,
}

local WIELDITEM_PROP_OVERRIDES = {
	visual = "item",
	visual_size = WIELD_VISUAL_SIZE,
}

core.register_tool ("mcl_tridents:trident", {
	description = S ("Trident"),
	_tt_help = S ("Impales animals and destroys certain blocks"),
	groups = {
		weapon = 1,
		trident = 1,
		enchantability = 1,
		rarity = 2,
		offhand_item = 1,
	},
	inventory_image = "mcl_tridents_trident_item.png",
	wield_image = "blank.png^[resize:5x32^[combine:5x32:-19,0=mcl_tridents_trident_entity.png",
	wield_scale = vector.new (1.0, 6.4, 1.0),
	stack_max = 1,
	_mcl_uses = 250,
	tool_capabilities = {
		full_punch_interval = 1.1,
		max_drop_level = 1,
		damage_groups = {
			fleshy = 9,
		},
	},
	_on_set_item_entity = function (_, _)
		return nil, WIELDITEM_PROP_OVERRIDES
	end,
	_on_dispense = function (itemstack, dispenserpos, _, _, dropdir)
		local shootpos
			= vector.add (dispenserpos, vector.multiply (dropdir, 0.6))
		mcl_tridents.shoot_trident (itemstack:take_item (), nil, shootpos, nil, nil,
					    dropdir, true, 0, 1, 0.366666)
	end,
})

------------------------------------------------------------------------
-- Trident entity.
------------------------------------------------------------------------

local trident_clip = {
	initial_properties = {
		visual = "mesh",
		mesh = "mcl_tridents_trident.obj",
		textures = {
			"mcl_tridents_trident_entity_clip.png",
		},
		visual_size = {
			x = 1.0,
			y = 1.0,
		},
		pointable = false,
		physical = false,
		static_save = false,
		use_texture_alpha = false,
	},
}

function trident_clip:on_step (_, _)
	if not self.object:get_attach () then
		self.object:remove ()
		return
	end
end

function trident_clip:on_activate (_)
	self.object:set_armor_groups ({
		immortal = 1,
	})
end

core.register_entity ("mcl_tridents:trident_clip", trident_clip)

local trident_entity = {
	initial_properties = {
		visual = "mesh",
		mesh = "mcl_tridents_trident.obj",
		-- TODO: apply glint to textures of enchanted
		-- tridents.
		textures = {
			"mcl_tridents_trident_entity.png",
		},
		visual_size = {
			x = 1.0,
			y = 1.0,
		},
		collisionbox = {
			-0.25, -0.25, -0.25,
			0.25, 0.25, 0.25,
		},
		selectionbox = {
			0.0, 0.0, 0.0,
			0.0, 0.0, 0.0,
		},
		pointable = false,
		physical = true,
		collide_with_objects = false,
		static_save = true,
		use_texture_alpha = true,
	},
	_in_block = false,
	_shooter = nil,
	_prev_pos = vector.zero (),
	_objects_seen = {},
	_itemstack = ItemStack (""),
	_can_pick_up = false,
	_loyalty = 0,
	_loyalty_timer = 1.0,
	_age = 0,
	_clip_entity = nil,
}

core.register_entity ("mcl_tridents:trident", trident_entity)

local GRAVITY = vector.new (0, -24, 0)
local ZERO = vector.zero ()

function trident_entity:find_first_collision (moveresult)
	local first_collision
	local max_len = -math.huge

	for _, collision in ipairs (moveresult.collisions) do
		local len = vector.length (collision.old_velocity)
		if max_len < len then
			first_collision = collision
			max_len = len
		end
	end
	if first_collision then
		return first_collision.old_velocity,
			first_collision.new_pos,
			first_collision.node_pos
	end
	return nil
end

local function is_zero_vector (v)
	return v.x == 0 and v.y == 0 and v.z == 0
end

function trident_entity:raycast_entities (v, pos1, pos2)
	local raycast = core.raycast (pos1, pos2, true, false, nil)
	for pointed_thing in raycast do
		local object = pointed_thing.ref
		if pointed_thing.type == "object"
			and object ~= self.object
			and object ~= self._riptide_player
			and not is_zero_vector (pointed_thing.intersection_normal)
			and table.indexof (self._objects_seen, object) == -1 then
			local entity = object:get_luaentity ()
			if entity and entity.is_mob or object:is_player () then
				return vector.multiply (v, -0.175),
					object, pointed_thing.intersection_point
			end
		end
	end
	return nil
end

function trident_entity:get_shooter ()
	if type (self._shooter) == "string" then
		return core.get_player_by_name (self._shooter)
	end
	return self._shooter and self._shooter:is_valid ()
		and self._shooter or nil
end

function trident_entity:check_pickup (self_pos)
	if self._loyalty > 0 then
		local shooter = self:get_shooter ()
		if shooter then
			if self._loyalty_timer == 1 then
				core.sound_play("mcl_tridents_loyalty_"..math.random(1,3), {
					pos = shooter:get_pos(), gain = 0.5,
					max_hear_distance = 16
				}, true)
			end

			if vector.distance (self_pos, shooter:get_pos ()) < 1.65 then
				if not self._can_pick_up then
					self.object:remove ()
					return true
				else
					if shooter:is_player () then
						local inv = shooter:get_inventory ()
						if inv:room_for_item ("main", self._itemstack) then
							inv:add_item ("main", self._itemstack)
							self.object:remove ()
							return true
						end

						-- Otherwise, this trident
						-- should continue to hover by
						-- the player.
					else
						self.object:remove ()
						return true
					end
				end
			end
			return false
		end
	end

	for _, player in ipairs (core.get_connected_players ()) do
		local pos = player:get_pos ()
		if pos and vector.distance (self_pos, pos) < 1.45 then
			if not self._can_pick_up then
				self.object:remove ()
				return true
			end
			local item = core.add_item (self_pos, self._itemstack)
			if item then
				local entity = item:get_luaentity ()
				entity._insta_collect = true
				self.object:remove ()
				return true
			end
			return false
		end
	end
	return false
end

local mathpow = math.pow

local function is_sensitive_to_impaling (object)
	local entity = object:get_luaentity ()
	return entity and (entity.name == "mobs_mc:axolotl"
			   or entity.name == "mobs_mc:guardian"
			   or entity.name == "mobs_mc:guardian_elder"
			   or entity.name == "mobs_mc:cod"
			   or entity.name == "mobs_mc:pufferfish"
			   or entity.name == "mobs_mc:tropical_fish"
			   or entity.name == "mobs_mc:salmon"
			   or entity.name == "mobs_mc:dolphin"
			   or entity.name == "mobs_mc:squid"
			   or entity.name == "mobs_mc:glow_squid")
end

local function is_walkable (self_pos)
	local cid, _, _
		= core.get_node_raw (math.floor (self_pos.x + 0.5),
				     math.floor (self_pos.y + 0.5),
				     math.floor (self_pos.z + 0.5))
	local name = core.get_name_from_content_id (cid)
	local def = core.registered_nodes[name]
	return def and def.walkable
end

local function attach_elytra (player, trident_v, self_pos)
	local obj = core.add_entity(self_pos, "mcl_armor:elytra_entity")
	local ent = obj:get_luaentity()
	if obj and ent then
		player:set_pos(vector.offset(self_pos,0,1,0))
		ent:attach(player)
		ent.object:set_velocity(trident_v)
	end
end

function trident_entity:on_step (dtime, moveresult)
	local v = self.object:get_velocity ()
	local self_pos = self.object:get_pos ()

	-- If the player attached to this trident entity is no longer
	-- attached, finalize its attachment and destroy this object.
	if self._riptide_player
		and self._riptide_player:get_attach () ~= self.object then
		self:riptide_detach (self._riptide_player)
		return
	end

	if self._riptide_player
		and not mcl_serverplayer.is_csm_capable(self._riptide_player)
		and self._riptide_player:get_player_control().jump then
		attach_elytra(self._riptide_player, v, self_pos)
		self:riptide_detach (self._riptide_player)
		return
	end

	-- If this trident is not collectible, arrange to despawn it
	-- after 60 seconds.
	if not self._can_pick_up then
		self._age = self._age + dtime
		if self._age >= 60.0 then
			self.object:remove ()
			return
		end
	end

	-- Reorient entity.
	if not self._in_block then
		local v1, new_pos, node_pos
			= self:find_first_collision (moveresult)
		local prev_pos = self._prev_pos
		local v2, object, intersection_point
			= self:raycast_entities (v, prev_pos, self_pos)
		if v1 and (not v2 or (vector.distance (prev_pos, intersection_point)
				      > vector.distance (prev_pos, new_pos))) then
			local node = core.get_node (node_pos)
			local shooter = ""
			if type (self._shooter) == "string" then
				shooter = self._shooter
			end
			if core.get_item_group (node.name, "dig_by_trident") > 0
				and not core.is_protected (node_pos, shooter) then
				core.dig_node (node_pos)
				self.object:set_pos (new_pos)
				self.object:set_velocity (vector.multiply (v1, 0.30))
			else
				if node.name == "mcl_lightning_rods:rod"
					and mcl_weather.state == "thunder"
					and mcl_weather.is_outdoor (node_pos)
					and mcl_enchanting.get_enchantment (self._itemstack,
									    "channeling") > 0 then
					core.sound_play("mcl_tridents_channeling", {
						pos = node_pos, gain = 1,
						max_hear_distance = 16
					}, true)
					mcl_lightning.strike (vector.offset (node_pos, 0, 1, 0))
				end
				-- Detect buttons and like non-solid
				-- nodes that might be occupying the
				-- node in which this projectile has
				-- been halted by the collision.
				local new_nodepos
					= mcl_util.get_nodepos (new_pos)
				local node_here
					= core.get_node (new_nodepos)
				local def_here
					= core.registered_nodes[node_here.name]
				if def_here and def_here._on_arrow_hit then
					self._stuckin = node_pos
					def_here._on_arrow_hit (new_nodepos, self)
				else
					self._stuckin = node_pos
					-- Otherwise, register a hit
					-- on the node with which this
					-- projectile collided.
					local def = core.registered_nodes[node.name]
					if def and def._on_arrow_hit then
						def._on_arrow_hit (node_pos, self)
					end
				end
				self._in_block = v1
				self._objects_seen = {}
				self:rotate (v1)
				self.object:set_properties ({
					physical = false,
				})
				self.object:set_velocity (ZERO)
				self.object:set_acceleration (ZERO)
				if self._riptide_player then
					self:riptide_detach (self._riptide_player)
					return
				else
					core.sound_play("mcl_tridents_stuck", {
						pos = node_pos, gain = 0.5,
						max_hear_distance = 16
					}, true)
				end
				local delta = vector.normalize (v1)
				self.object:set_pos (vector.offset (new_pos, delta.x * 0.35,
								    delta.y * 0.35,
								    delta.z * 0.35))
			end
		elseif v2 then
			table.insert (self._objects_seen, object)
			self.object:set_pos (intersection_point)
			self.object:set_velocity (v2)
			self:rotate (v2)

			local mcl_reason = {
				type = "trident",
				source = self:get_shooter (),
				direct = self.object,
			}
			mcl_damage.finish_reason (mcl_reason)
			local damage = 8.0
			local impaling
				= mcl_enchanting.get_enchantment (self._itemstack, "impaling")
			if is_sensitive_to_impaling (object) then
				damage = damage + impaling * 2.5
			end
			local object_pos = mcl_util.get_nodepos (object:get_pos ())
			local entity = object:get_luaentity ()
			local object_type = nil
			if entity then
				object_type = entity.name
			end
			if mcl_util.deal_damage (object, damage, mcl_reason) then
				if mcl_reason.source:is_player () then
					awards.unlock (self._shooter, "mcl:a_throwaway_joke");
				end
				-- Utilize different methods of applying knockback for consistency.
				if entity and entity.is_mob then
					entity:projectile_knockback (1, vector.normalize (v))
				elseif object:is_player () then
					local dir = vector.normalize (v)
					mcl_player.player_knockback (object, self.object, dir, nil, damage)
				end
				core.sound_play("mcl_tridents_hit", {
						pos = object:get_pos(), gain = 0.5,
						max_hear_distance = 16
					}, true)
				end
			if mcl_weather.state == "thunder"
				and mcl_weather.is_outdoor (object_pos)
				and mcl_enchanting.get_enchantment (self._itemstack,
								    "channeling") > 0 then
				mcl_lightning.strike (vector.offset (object_pos, 0, 1, 0), true)
				if object_type == "mobs_mc:villager"
					and mcl_reason.source:is_player () then
					awards.unlock (self._shooter, "mcl:very_very_frightening")
				end
				core.sound_play("mcl_tridents_channeling", {
					pos = object_pos, gain = 1,
					max_hear_distance = 16
				}, true)
			end
		else
			self:rotate (v)
		end
	else
		if self:check_pickup (self_pos) then
			-- The object has been removed.
			return
		end

		local loyalty = self._loyalty
		if loyalty > 0 then
			local shooter = self:get_shooter ()
			if not shooter and self._loyalty_timer <= 0
				and not is_walkable (self_pos) then
				-- Resume moving.
				self._loyalty_timer = 1.0
				self.object:set_acceleration (GRAVITY)
				self.object:set_properties ({
					physical = true,
				})
				self._in_block = nil
			elseif shooter and self._loyalty_timer <= 0 then
				local dst_pos = shooter:get_pos ()
				local dir = vector.direction (self_pos, dst_pos)
				local speed = loyalty <= 2 and loyalty * 2.5 or loyalty * 2.4
				local drag = mathpow (0.85, dtime * 20)
				local scale = (1 - drag) / 0.15
				dir.x = v.x * drag + dir.x * speed * scale
				dir.y = v.y * drag + dir.y * speed * scale
				dir.z = v.z * drag + dir.z * speed * scale
				self.object:set_velocity (dir)
				dir.x = dir.x * -1
				dir.y = dir.y * -1
				dir.z = dir.z * -1
				self:rotate (dir)
			elseif shooter then
				local t = self._loyalty_timer - dtime * 4
				self._loyalty_timer = t
			end
		end
	end
	self._prev_pos = self_pos
end

function trident_entity:get_staticdata ()
	local data = {
		_in_block = self._in_block,
		_shooter = type (self._shooter) == "string"
			and self._shooter or nil,
		_velocity = self.object:get_velocity (),
		_itemstack = self._itemstack:to_string (),
		_can_pick_up = self._can_pick_up,
		_loyalty = self._loyalty,
	}
	return core.serialize (data)
end

function trident_entity:on_deactivate (removal)
	if self._riptide_player then
		self:riptide_detach (self._riptide_player, true)
	end
end

function trident_entity:on_activate (staticdata, dtime)
	self.object:set_armor_groups ({
		immortal = 1,
	})
	if staticdata then
		local sdata = core.deserialize (staticdata)
		if sdata then
			if sdata._in_block then
				self._in_block = vector.copy (sdata._in_block)
				self.object:set_properties ({
					physical = false,
				})
				self:rotate (self._in_block)
				self.object:set_acceleration (ZERO)
			else
				if sdata._velocity then
					self.object:set_velocity (sdata._velocity)
				end
			end
			self._loyalty = sdata._loyalty or 0
			self._shooter = sdata._shooter
			self._itemstack = ItemStack (sdata._itemstack)
			self._can_pick_up = sdata._can_pick_up
		end
	end
	if not self._in_block then
		self.object:set_acceleration (GRAVITY)
	end
	self._prev_pos = self.object:get_pos ()
	self._objects_seen = {}

	-- Attach another object that is guaranteed to remain visible
	-- even when this object is obscured by water or other
	-- semitransparent materials.
	local clip = core.add_entity (self.object:get_pos (),
				      "mcl_tridents:trident_clip")
	if clip then
		clip:set_attach (self.object, "", ZERO, ZERO)
		self._clip_entity = clip
	end
end

function trident_entity:riptide_init (player)
	self.object:set_properties ({
		static_save = false,
		pointable = false,
		textures = {
			"blank.png",
		},
	})
	if self._clip_entity then
		self._clip_entity:remove ()
	end
	player:set_attach (self.object, "", ZERO, ZERO)
	self._riptide_player = player
	if mcl_serverplayer.is_csm_at_least (player, 4) then
		mcl_serverplayer.send_trident_ctrl (player, {
			riptide_active = true,
		})
	end
end

function trident_entity:riptide_detach (player, on_deactivate)
	if player:get_attach () == self.object then
		player:set_detach ()
		if mcl_serverplayer.is_csm_at_least (player, 4) then
			mcl_serverplayer.send_trident_ctrl (player, {
				riptide_active = false,
			})
		end
	end
	if not on_deactivate then
		self.object:remove ()
	end
end

local pi = math.pi
local NINETY_DEG = pi / 2
local atan2 = math.atan2
local mathsin = math.sin
local mathcos = math.cos
local mathsqrt = math.sqrt

function trident_entity:rotate (v)
	local yaw = atan2 (v.z, v.x) - NINETY_DEG
	local pitch = atan2 (v.y, mathsqrt (v.z * v.z + v.x * v.x)) - NINETY_DEG
	if not self._riptide_player then
		local euler = vector.new (0, yaw + NINETY_DEG, -pitch)
		self.object:set_rotation (euler)
	else
		local euler = vector.new (pitch + NINETY_DEG, yaw, 0)
		self.object:set_rotation (euler)
	end
end

------------------------------------------------------------------------
-- Trident launching.
------------------------------------------------------------------------

function mcl_tridents.shoot_trident (stack, obj, pos, yaw, pitch, dir, collectable,
				     riptide_level, inaccuracy, speed)
	local dx, dy, dz
	if not dir then
		local ycos = mathcos (pitch)
		dx = -mathsin (yaw) * ycos
		dy = -mathsin (pitch)
		dz = mathcos (yaw) * ycos
	else
		local len = vector.length (dir)
		dx = dir.x / len
		dy = dir.y / len
		dz = dir.z / len
	end
	local v = vector.new (dx, dy, dz)
	v = mcl_bows.add_inaccuracy (v, inaccuracy)
	if riptide_level <= 0 then
		local speed = speed or 1.0
		v.x = v.x * 50.0 * speed
		v.y = v.y * 50.0 * speed
		v.z = v.z * 50.0 * speed
	else
		v.x = v.x * 40.0 * (1 + riptide_level) / 4.0
		v.y = v.y * 40.0 * (1 + riptide_level) / 4.0
		v.z = v.z * 40.0 * (1 + riptide_level) / 4.0
	end
	local object = core.add_entity (pos, "mcl_tridents:trident")
	if object then
		object:set_velocity (v)
		local entity = object:get_luaentity ()
		if obj and obj:is_player () then
			entity._shooter = obj:get_player_name ()
		else
			entity._shooter = obj
		end
		entity._loyalty
			= mcl_enchanting.get_enchantment (stack, "loyalty")
		mcl_util.use_item_durability (stack, 1)
		entity._itemstack = stack
		entity._can_pick_up = collectable
		if riptide_level > 0 then
			assert (obj:is_player ())
			entity:riptide_init (obj)
			core.sound_play("mcl_tridents_riptide", {
				pos = pos, gain = 1,
				max_hear_distance = 16
			}, true)
		end
		entity:rotate (v)
		core.sound_play("mcl_tridents_throw_"..math.random(1,2), {
			pos = obj:get_pos(), gain = 0.5,
			max_hear_distance = 16
		}, true)
		return true
	end

	return false
end

function mcl_tridents.remaining_durability (trident)
	local durability = mcl_util.calculate_durability (trident)
	local remaining
		= math.floor ((65535 - trident:get_wear ()) * durability / 65535)
	return remaining
end

local function player_may_launch_trident_p (player, item)
	local riptide = mcl_enchanting.get_enchantment (item, "riptide")
	if riptide > 0 then
		local attach = player:get_attach ()
		if attach then
			local entity = attach:get_luaentity ()
			return entity and entity.name == "mcl_tridents:trident"
				or entity and entity.name == "mcl_armor:elytra_entity"
		elseif not mcl_weather.is_underwater (player)
			and not mcl_tridents.weather_admits_of_riptide_p (player) then
			return false
		end
	end
	return true
end

function mcl_tridents.player_shoot (player, stack)
	local item = stack:take_item ()
	local pos = mcl_util.target_eye_pos (player)
	local yaw = player:get_look_horizontal ()
	local pitch = player:get_look_vertical ()
	local creative = core.is_creative_enabled (player:get_player_name ())

	if not player_may_launch_trident_p (player, item) then
		return false
	end

	local riptide = mcl_enchanting.get_enchantment (item, "riptide")
	if mcl_tridents.shoot_trident (item, player, pos, yaw, pitch, nil,
				       not creative, riptide, 1.0, nil) then
		if not creative and riptide <= 0 then
			player:set_wielded_item (stack)
		elseif not creative then
			mcl_util.use_item_durability (item, 1)
			player:set_wielded_item (item)
		end
		return true
	end

	return false
end

function mcl_tridents.weather_admits_of_riptide_p (player)
	local node_pos = mcl_util.get_nodepos (player:get_pos ())
	return mcl_weather.is_exposed_to_rain (node_pos)
end

------------------------------------------------------------------------
-- Server-side trident support.
------------------------------------------------------------------------

function mcl_tridents.obj_attached_to_riptide_trident_p (obj)
	local attach = obj:get_attach ()
	local entity = attach and attach:get_luaentity () or nil
	return entity and entity.name == "mcl_tridents:trident"
end

local trident_held_times = {}

core.register_on_joinplayer (function (player)
	trident_held_times[player] = -math.huge
end)

core.register_on_leaveplayer (function (player, _)
	trident_held_times[player] = nil
end)

controls.register_on_hold (function (player, key)
	if mcl_serverplayer.is_csm_at_least (player, 4) then
		return
	end
	if key ~= "RMB" then
		return
	end
	local wielditem = player:get_wielded_item ()
	local name = wielditem:get_name ()
	if core.get_item_group (name, "trident") > 0
		and player_may_launch_trident_p (player, wielditem) then
		if trident_held_times[player] == -math.huge then
			trident_held_times[player] = 0
		end
	end
end)

core.register_globalstep (function (dtime)
	for player, time in pairs (trident_held_times) do
		if time < 0.5 and time + dtime >= 0.5 then
			mcl_title.set (player, "actionbar", {
				text = S ("Trident charged.  Release RMB to launch."),
				stay = 20,
			})
		end
		trident_held_times[player] = time + dtime
	end
end)

controls.register_on_release (function (player, key)
	if mcl_serverplayer.is_csm_at_least (player, 4) then
		return
	end
	if key ~= "RMB" then
		return
	end
	local wielditem = player:get_wielded_item ()
	local name = wielditem:get_name ()
	local elytra = mcl_player.players[player].elytra
	local creative = core.is_creative_enabled (player:get_player_name ())
	if core.get_item_group (name, "trident") > 0
		and player_may_launch_trident_p (player, wielditem)
		and (trident_held_times[player] or 0) >= 0.5 then
		if elytra.active then
			elytra.riptide = 0.05
			if not creative then
				mcl_util.use_item_durability (wielditem, 1)
				player:set_wielded_item (wielditem)
			end
		else
			mcl_tridents.player_shoot (player, wielditem)
		end
	end
	trident_held_times[player] = -math.huge
end)
