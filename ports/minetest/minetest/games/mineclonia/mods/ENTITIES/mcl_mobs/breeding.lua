local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

local HORNY_TIME = 30*20
local HORNY_AGAIN_TIME = 30*20 -- was 300 or 15*20
local CHILD_GROW_TIME = 24000

function mob_class:use_shears (new_textures, shears_stack)
	if core.get_item_group(shears_stack:get_name(), "shears") > 0 then
		self.base_texture = new_textures
		self:set_textures (new_textures)
		self.gotten = true
		core.sound_play("mcl_tools_shears_cut", { pos = self.object:get_pos() }, true)
		local shears_def = shears_stack:get_definition()
		shears_stack:add_wear(65535 / shears_def._mcl_diggroups.shearsy.uses)
	end
	return shears_stack
end

function mob_class:_on_dispense(dropitem)
	local item = dropitem.get_name and dropitem:get_name() or dropitem
	if self.follow and ((type(self.follow) == "table" and table.indexof(self.follow, item) ~= -1) or item == self.follow) then
		if self:feed_tame(nil, 1, true, false) then
			dropitem:take_item()
			return dropitem
		end
	end
end

function mob_class:just_tame (self_pos, owner)
	local x, z = self_pos.x, self_pos.z
	self.tamed = true
	self.owner = owner:get_player_name ()
	mcl_mobs.effect ({x = x, y = self_pos.y + 0.7, z = z},
		5, "heart.png", 2, 4, 2.0, 0.1)
end

function mob_class:feed_tame(clicker, heal, breed, tame, notake, tamechance)
	local consume_food = false
	local tamechance = tamechance or 1.0

	if clicker and tame and not self.child then
		if not self.owner or self.owner == "" then
			local pos = self.object:get_pos ()
			local x, z = pos.x, pos.z
			if math.random () <= tamechance then
				self.tamed = true
				self.owner = clicker:get_player_name()
				mcl_mobs.effect ({x = x, y = pos.y + 0.7, z = z},
					5, "heart.png", 2, 4, 2.0, 0.1)
			else
				mcl_mobs.effect ({x = x, y = pos.y + 0.7, z = z},
					math.random (7),
					"mcl_particles_mob_death.png^[colorize:#000000:255",
					2, 4, 2.0, 0.1)
			end
			consume_food = true
		end
	end

	if heal then
		local hp_max = self.object:get_properties ().hp_max
		if self.health < hp_max and not consume_food then
			consume_food = true
			self.health = math.min (self.health + heal, hp_max)
			if self.htimer < 1 then
				self.htimer = 5
			end
			self.object:set_hp(self.health)
		end
	end

	if not consume_food and self.child == true then
		consume_food = true
		self.hornytimer = self.hornytimer + ((CHILD_GROW_TIME - self.hornytimer) * 0.1)
	end

	if breed and not consume_food and self.hornytimer == 0 and not self.horny then
		if not self.breeding_possible
			or self:breeding_possible () then
			consume_food = true
			self.horny = true
			self.persistent = true
		end
	end

	self:update_tag()
	if clicker and consume_food then
		if not core.is_creative_enabled(clicker:get_player_name()) and not notake then
			local item = clicker:get_wielded_item()
			item:take_item()
			clicker:set_wielded_item(item)
		end
		self:mob_sound("eat", nil, true)
	else
		self:mob_sound("random", true)
	end


	return consume_food
end

function mcl_mobs.spawn_child(pos, mob_type)
	local staticdata = core.serialize ({
		child = true,
	})
	local child = core.add_entity (pos, mob_type, staticdata)
	if not child then
		return
	end

	mcl_mobs.effect (pos, 15, "mcl_particles_smoke.png", 1, 2, 2, 15, 5)
	return child
end

function mob_class:tick_breeding ()
	if self.child == true then
		-- When a child, hornytimer is used to count age until adulthood
		self.hornytimer = self.hornytimer + 1
		if self.hornytimer >= CHILD_GROW_TIME then
			self.child = false
			self.hornytimer = 0
			local visual_size = self.base_size
			if self.jockey_vehicle
				and is_valid (self.jockey_vehicle) then
				local props = self.jockey_vehicle:get_properties ()
				local vehicle_size = props.visual_size
				visual_size = {
					x = visual_size.x / vehicle_size.x,
					y = visual_size.y / vehicle_size.y,
				}
			end
			self:set_properties({
				mesh = self.base_mesh,
				visual_size = visual_size,
				collisionbox = self.base_colbox,
				selectionbox = self.base_selbox,
			})
			if self._adult_head_eye_height then
				self.head_eye_height = self._adult_head_eye_height
			end
			self:set_textures (self.base_texture)
			if self.on_grown then
				self.on_grown(self)
			end
			self.animation = nil
			local anim = self._current_animation
			self._current_animation = nil
			self:set_animation(anim)
		end
		return
	else
		if self.horny == true or self.hornytimer ~= 0 then
			self.hornytimer = self.hornytimer + 1

			if self.hornytimer >= HORNY_TIME + HORNY_AGAIN_TIME then
				self.hornytimer = 0
			end
			if self.hornytimer >= HORNY_TIME then
				self.horny = false
			elseif self.horny and (self.hornytimer % 20) == 0 then
				local pos = self.object:get_pos ()
				mcl_mobs.effect({x = pos.x, y = pos.y + 1, z = pos.z}, 8, "heart.png", 3, 4, 1, 0.1)
			end
		end
	end
end

function mob_class:beget_child (pos)
	local mate
	if not self.object:get_luaentity () then
		return
	end
	mate = self.mate and self.mate:get_luaentity ()
	if not mate then
		return
	end
	-- Clear both fields to guarantee that a pair of mobs can only
	-- breed once.
	self.mate = nil
	mate.mate = nil
	mcl_experience.throw_xp (pos, math.random (1, 7))
	self:set_animation ("stand")
	mate:set_animation ("stand")
	if self.on_breed then
		if self:on_breed (self, mate) == false then
			return
		end
	end
	local child = mcl_mobs.spawn_child(pos, self.name)
	if child then
		local ent_c = child:get_luaentity()
		-- Use texture of one of the parents
		local p = math.random(1, 2)
		if p == 1 then
			ent_c.base_texture = self.base_texture
		else
			ent_c.base_texture = mate.base_texture
		end
		ent_c:set_textures (ent_c.base_texture)
		ent_c.tamed = true
		ent_c.owner = self.owner
	end
end

function mob_class:can_mate (with)
	if with == self.object then
		return false
	end
	local ent = with:get_luaentity ()
	if ent and ent.horny and ent.is_mob then
		if self:same_species (ent) then
			-- Don't attempt to mate with mobs already
			-- taken.
			return not ent.mate or ent.mate == self.object
		end
	end
	return false
end

function mob_class:same_species (ent)
	-- Match different variants of one mob.
	-- FIXME: hideous code.
	local entname = string.split (ent.name, ":")
	local selfname = string.split (self.name, ":")
	if entname[1] == selfname[1] then
		entname = string.split (entname[2], "_")
		selfname = string.split (selfname[2], "_")
		if entname[1] == selfname[1] then
			return true
		end
	end
	return false
end

function mob_class:check_breeding (pos)
	if self.mate then
		if not is_valid (self.mate) then
			self:set_animation ("stand")
			self.mate = nil
			return false
		end
		local entity = self.mate:get_luaentity ()
		if entity.mate ~= self.object then
			self.mate = nil
			return false
		end
		local matepos = self.mate:get_pos ()
		if vector.distance (pos, matepos) < 3.0
			and self:target_visible (pos, self.mate)
			and self.hornytimer
			and not self.begetting then
			self.begetting = true
			core.after (5, mob_class.beget_child, self, pos)
		end
		self:gopath (matepos, self.breed_bonus)
		return true
	elseif self.horny and self.hornytimer < HORNY_TIME then
			local ax, ay, az, bx, by, bz
			ax = self.collisionbox[1]
			ay = self.collisionbox[2]
			az = self.collisionbox[3]
			bx = self.collisionbox[4]
			by = self.collisionbox[5]
			bz = self.collisionbox[6]
			local aa = { x = pos.x + ax - 8, y = pos.y + ay - 4, z = pos.z + az - 8 }
			local bb = { x = pos.x + bx + 8, y = pos.y + by + 4, z = pos.z + bz + 8 }
			local objects = core.get_objects_in_area (aa, bb)
			for _, object in ipairs (objects) do
				if self:can_mate (object) then
					local entity = object:get_luaentity ()
					entity:replace_activity ("mate")
					self.mate = object
					entity.mate = self.object
					self.begetting = false
					self.horny = false
					-- Prevent duplicate calls to
					-- core.after.
					entity.begetting = true
					-- Taken, sorry!
					entity.horny = false
					return "mate"
				end
			end
	end
end

function mob_class:follow_herd (pos)
	if self.herd_following then
		if not self.child then
			-- Mob matured.
			self.herd_following = nil
			return false
		end

		local entity = self.herd_following:get_luaentity ()
		if not entity then
			self.herd_following = nil
			return false
		end

		local target_pos = self.herd_following:get_pos ()
		if vector.distance (target_pos, pos) < 3.0
			or self:navigation_finished () then
			self.herd_following = nil
			return false
		end
		-- Recalculate path every .5 seconds, as in Minecraft.
		if self:check_timer ("check_herd", 0.5) then
			local bonus = self.follow_herd_bonus
				or self.follow_bonus
			self:gopath (target_pos, bonus)
		end
		return true
	elseif self.child and self:check_timer ("check_herd", 0.5) then
		-- Locate nearby adults to decide whether the entire
		-- herd is further than 9 blocks away.
		local ax, ay, az, bx, by, bz
		ax = self.collisionbox[1]
		ay = self.collisionbox[2]
		az = self.collisionbox[3]
		bx = self.collisionbox[4]
		by = self.collisionbox[5]
		bz = self.collisionbox[6]
		local aa = { x = pos.x + ax - 9, y = pos.y + ay - 5, z = pos.z + az - 9 }
		local bb = { x = pos.x + bx + 9, y = pos.y + by + 5, z = pos.z + bz + 9 }
		local objects = core.get_objects_in_area (aa, bb)
		local distmin, selected = 5000

		for _, object in ipairs (objects) do
			local obj_pos = object:get_pos ()
			local dist = vector.distance (pos, obj_pos)
			if dist < distmin then
				local entity = object:get_luaentity ()
				if entity and entity.is_mob and not entity.child
					and self:same_species (entity) then
					distmin = dist
					selected = object
				end
			end
		end
		-- There's no need to move towards the rest of
		-- the herd.
		if not selected or distmin < 3.0 then
			return false
		end
		local bonus = self.follow_herd_bonus
			or self.follow_bonus
		self:gopath (selected:get_pos (), bonus)
		self.herd_following = selected
		return "herd_following"
	end
end

----------------------------------------------------------------------------------
-- Tamable mob interaction with owners.  FIXME: why is this in breeding.lua?
----------------------------------------------------------------------------------

function mob_class:stay ()
	self.order = "sit"
end

function mob_class:toggle_sit(clicker,p)
	if not self.tamed or self.child  or self.owner ~= clicker:get_player_name() then
		return
	end
	local pos = self.object:get_pos()
	local particle
	if not self.order or self.order == "" or self.order == "sit" then
		particle = "mobs_mc_wolf_icon_roam.png"
		self.order = ""
	else
		particle = "mobs_mc_wolf_icon_sit.png"
		self:stay ()
	end
	local pp = vector.new(0,1.4,0)
	if p then pp = vector.offset(pp,0,p,0) end
	-- Display icon to show current order (sit or roam)
	core.add_particle({
		pos = vector.add(pos, pp),
		velocity = {x=0,y=0.2,z=0},
		expirationtime = 1,
		size = 4,
		texture = particle,
		playername = self.owner,
		glow = core.LIGHT_MAX,
	})
end

function mob_class:is_not_owner (object)
	return not object:is_player ()
		or object:get_player_name () ~= self.owner
end

function mob_class:sit_if_ordered (self_pos, dtime)
	if self.order == "sit" and self.owner then
		if core.get_item_group (self.standing_in, "water") ~= 0 then
			return false
		end
		-- If recently damaged and owner is nearby, don't
		-- activate either.
		if self._recent_attacker
			and self:is_not_owner (self._recent_attacker) then
			local player = core.get_player_by_name (self.owner)
			if player
				and vector.distance (self_pos, player:get_pos ()) < 12 then
				return false
			end
		end
		if self.animation.sit_start then
			self:set_animation ("sit")
		end
		self:halt_in_tracks ()
		self:cancel_navigation ()
		-- This field doesn't really exist; it serves to
		-- indicate that the active task has changed.
		return "sit_if_ordered"
	end
	return false
end

function mob_class:teleport_to_owner (owner, owner_pos)
	self:cancel_navigation ()
	self:halt_in_tracks ()
	-- Search for a walkable platform from among 10 random
	-- positions around the owner's position.  Reject leaves
	-- unless this mob be airborne.
	for _ = 1, 10 do
		local x = math.random (-3, 3)
		local y = math.random (-1, 1)
		local z = math.random (-3, 3)
		owner_pos.x = math.floor (owner_pos.x + 0.5)
		owner_pos.y = math.floor (owner_pos.y + 0.5)
		owner_pos.z = math.floor (owner_pos.z + 0.5)
		local pos = vector.offset (owner_pos, x, y, z)

		if self:gwp_classify_for_movement (pos) == "WALKABLE" then
			pos.y = pos.y - 1
			local node = core.get_node (pos)
			local def = core.registered_nodes [node.name]
			if def and (core.get_item_group(node.name, "leaves") == 0 or self.airborne) then
				pos.y = pos.y + 1
				self.object:move_to (pos)
				self.reset_fall_damage = 1
				self.old_y = nil
				return true
			end
		end
	end
	return false
end

function mob_class:check_travel_to_owner (self_pos, dtime)
	if self.traveling_to_owner then
		if not self.owner then
			self.traveling_to_owner = nil
			return false
		end
		local owner = core.get_player_by_name (self.owner)
		if not owner then
			self.traveling_to_owner = nil
			return false
		end

		local owner_pos = owner:get_pos ()
		local distance = vector.distance (self_pos, owner_pos)
		if distance <= self.stop_chasing_distance
			or self:navigation_finished () then
			self:cancel_navigation ()
			self:halt_in_tracks ()
			self.traveling_to_owner = nil
			return false
		end

		if self:check_timer ("pathfind_to_owner", 0.5) then
			-- Teleport if the owner is at a distance.
			if distance > 12 then
				if self:teleport_to_owner (owner, owner_pos) then
					self.traveling_to_owner = nil
					return false
				end
			else
				local penalties = table.merge (self.gwp_penalties, {
					WATER = 0.0,
				})
				self:gopath (owner_pos, nil, nil, nil, penalties)
			end
		end
		return true
	else
		local owner = self.owner and core.get_player_by_name (self.owner)
		if not owner or self.object:get_attach () or self.order == "sit" then
			return false
		end
			local owner_pos = owner:get_pos ()
			local distance = vector.distance (self_pos, owner_pos)

			-- Teleport if the owner is at a distance.
			if distance > 12 then
				if self:teleport_to_owner (owner, owner_pos) then
					self.traveling_to_owner = nil
					return false
				end
				self.traveling_to_owner = true
				return "traveling_to_owner"
			elseif distance > self.chase_owner_distance then
				local penalties = table.merge (self.gwp_penalties, {
					WATER = 0.0,
				})
				self:gopath (owner_pos, nil, nil, nil, penalties)
				self.traveling_to_owner = true
				return "traveling_to_owner"
			end
	end
	return false
end
