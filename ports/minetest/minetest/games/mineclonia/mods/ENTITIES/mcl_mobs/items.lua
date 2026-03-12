local mob_class = mcl_mobs.mob_class

------------------------------------------------------------------------
-- Equipment mechanics.
------------------------------------------------------------------------

local function get_armor_texture (obj, stack)
	local def = stack:get_definition ()
	if not def then
		return nil
	end
	local t = def._mcl_armor_texture or "blank.png"
	if type (def._mcl_armor_texture) == "function" then
		t = def._mcl_armor_texture (obj, stack)
	end
	return t
end

function mob_class:initialize_armor_enchantments ()
	-- Recompute physics modifiers that are derived from armor
	-- enchantments.
	local depth_strider, soul_speed
		= mcl_enchanting.mob_physics_enchantment_levels (self)
	self._depth_strider_level = depth_strider
	if soul_speed ~= self._soul_speed_level then
		self._soul_speed_level = soul_speed
		self:reapply_soul_speed_modifiers ()
	end
end

function mob_class:set_armor_texture ()
	if not self.wears_armor then
		return
	end

	if self.armor_list then
		local obj = self.object
		for slot, keys in pairs (self._armor_texture_slots) do
			local list = {}
			for _, armor in ipairs (keys) do
				local stack = ItemStack (self.armor_list[armor])
				if not stack:is_empty () then
					local str = get_armor_texture (obj, stack)
					if str then
						local fn = self._armor_transforms[armor]
						if fn then
							str = fn (str)
						end
						table.insert (list, str)
					end
				end
			end
			local texture = #list > 0 and table.concat (list, "^") or "blank.png"
			self.base_texture[slot] = texture
		end
		self:set_textures (self.base_texture)
		-- XXX: this function's responsibilities extend beyond
		-- applying armor textures already and it is invoked
		-- wherever the armor list is altered, but it could be
		-- more elegant to call
		-- `initialize_armor_enchantments' separately.
		self:initialize_armor_enchantments ()
	end
	mcl_armor.head_entity_equip (self.object)
end

function mob_class:effective_drop_probability (armor_slot)
	if not self._armor_drop_probabilities then
		return 0
	end
	return self._armor_drop_probabilities[armor_slot] or 0
end

function mob_class:set_armor_drop_probability (armor_slot, probability)
	if not self._armor_drop_probabilities then
		self._armor_drop_probabilities = {
			[armor_slot] = probability
		}
		return
	end
	self._armor_drop_probabilities[armor_slot] = probability
end

function mob_class:armor_better_than (stack, current)
	local def = current:get_definition ()
	if not def then
		return true
	end

	if current:is_empty () then
		return true
	end

	local itemname = stack:get_name ()
	local curname = current:get_name ()

	if mcl_enchanting.has_enchantment (current, "curse_of_binding") then
		return false
	end

	if core.get_item_group (curname, "mcl_armor_points")
		< core.get_item_group (itemname, "mcl_armor_points") then
		return true
	elseif core.get_item_group (curname, "mcl_armor_toughness")
		< core.get_item_group (itemname, "mcl_armor_toughness") then
		return true
	else
		-- TODO: the MC Wiki states that Minecraft also
		-- replaces items without "NBT values" with those
		-- which have them.
		local dur_old = mcl_util.calculate_durability (current)
		local dur_new = mcl_util.calculate_durability (stack)
		if dur_old < dur_new then
			return true
		end
		-- Prefer enchanted to non-enchanted items.
		if core.get_item_group (curname, "enchanted") == 0
			and core.get_item_group (itemname, "enchanted") ~= 0 then
			return true
		end
	end
end

function mob_class:wielditem_better_than (stack, current)
	-- Always prefer swords to non-sword items.
	local cap_new, cap_old

	if current:is_empty () then
		return true
	end

	local itemname = stack:get_name ()
	local curname = current:get_name ()

	if core.get_item_group (itemname, "sword") > 0 then
		if core.get_item_group (curname, "sword") == 0 then
			return true
		end
	end

	if core.get_item_group (itemname, "tool") ~= 0
		or core.get_item_group (itemname, "weapon") ~= 0 then
		cap_new = stack:get_tool_capabilities ()
		cap_old = current:get_tool_capabilities ()
		if core.get_item_group (curname, "tool") == 0
			and core.get_item_group (curname, "weapon") == 0 then
			return true
		end
		if (cap_new.damage_groups.fleshy or 0)
			> (cap_old.damage_groups.fleshy or 0) then
			return true
		end
		local dur_old = mcl_util.calculate_durability (stack)
		local dur_new = mcl_util.calculate_durability (current)
		if dur_old < dur_new then
			return true
		end
		-- Prefer enchanted to non-enchanted items.
		if core.get_item_group (curname, "enchanted") == 0
			and core.get_item_group (itemname, "enchanted") ~= 0 then
			return true
		end
	end
	return false
end

function mob_class:evaluate_new_item (item)
	local def = item:get_definition ()
	if not def then
		return false
	end
	local itemname = item:get_name ()
	if self.wears_armor
		and def._mcl_armor_element
		and core.get_item_group (itemname, "armor") > 0 then
		local slot = def._mcl_armor_element
		local current = self.armor_list[slot]
		return self:armor_better_than (item, ItemStack (current))
	elseif self.can_wield_items then
		local current = self:get_wielditem ()
		return self:wielditem_better_than (item, current)
	end
	return false
end

function mob_class:try_equip_item (stack, def, itemname)
	if self.wears_armor
		and self.wears_armor ~= "no_pickup"
		and core.get_item_group (itemname, "armor") > 0
		and def._mcl_armor_element then
		-- Potentially drop any existing piece of armor in
		-- this slot.
		local slot = def._mcl_armor_element
		local current = self.armor_list[slot]
		local self_pos = self.object:get_pos ()
		if current and current ~= "" then
			if not self:armor_better_than (stack, ItemStack (current)) then
				return false
			end
			local random = math.random () - 0.1
			if math.max (0, random)
				< self:effective_drop_probability (slot) then
				core.add_item (self_pos, ItemStack (current))
			end
		end
		self.armor_list[slot] = stack:to_string ()
		-- This indicates that the item was collected from a
		-- player.
		self:set_armor_drop_probability (slot, 2.0)
		self:set_armor_texture ()
		self.persistent = true
		return true
	elseif self.can_wield_items
		and self.can_wield_items ~= "no_pickup" then
		local item = self:get_wielditem ()
		if self:wielditem_better_than (stack, item) then
			self:drop_wielditem (0)
			self:set_wielditem (stack, 2.0)
			return true
		end
	end
	return false
end

function mob_class:scale_durability_for_drop (stack, drop_probability)
	-- Randomize the durability of generated equipment dropped by
	-- mobs.

	if drop_probability <= 1.0 then
		local uses = mcl_util.calculate_durability (stack)
		if uses > 0 then
			local max = math.random (0, math.max (uses - 4, 0))
			local amount = math.random (0, max)
			stack:add_wear (65535 / uses * amount)
		end
	end
end

function mob_class:drop_armor (bonus, min_probability)
	if not self._armor_drop_probabilities then
		return
	end
	local self_pos = self.object:get_pos ()
	for name, item in pairs (self.armor_list) do
		local probability = self:effective_drop_probability (name)
		if probability > 0 and item and item ~= ""
			and (probability + bonus) >= (min_probability or 0)
			and math.random () <= probability + bonus then
			local stack = ItemStack (item)

			if not mcl_enchanting.has_enchantment (stack, "curse_of_vanishing") then
				self:scale_durability_for_drop (stack, probability)
				mcl_util.drop_item_stack (self_pos, stack)
			end
		end
	end
end

function mob_class:default_pickup (object, stack, def, itemname)
	if self:try_equip_item (stack, def, itemname) then
		object:remove ()
		return true
	end
	return false
end

function mob_class:check_item_pickup ()
	if self.can_wield_items	or self._inventory_size
		or (self.wears_armor and self.wears_armor ~= "no_pickup") then
		local self_pos = self.object:get_pos ()
		for object in core.objects_inside_radius (self_pos, 1.95) do
			local entity = object:get_luaentity ()
			if entity
				and entity.name == "__builtin:item"
				and entity.age >= 1.0 then
				local stack = ItemStack (entity.itemstring)
				local def = stack:get_definition ()
				local itemname = stack:get_name ()
				self:default_pickup (object, stack, def, itemname)
			end
		end
	end
end

------------------------------------------------------------------------
-- Inventories.
------------------------------------------------------------------------

-- Return whether there is sufficient space in this mob's inventory to
-- insert STACK whole, i.e., without dividing it between multiple
-- slots.

function mob_class:has_inventory_space (stack)
	if not self._inventory_size then
		return false
	elseif not self._inventory then
		return true
	end
	for _, slot in pairs (self._inventory) do
		if ItemStack (slot):item_fits (stack) then
			return true
		end
	end
	return false
end

function mob_class:add_to_inventory (stack)
	if not self._inventory_size then
		return stack
	elseif not self._inventory then
		self._inventory = {}
		for i = 1, self._inventory_size do
			self._inventory[i] = ""
		end
	end

	local remainder = stack
	for i = 1, #self._inventory do
		local stack = ItemStack (self._inventory[i])
		remainder = stack:add_item (remainder)
		self._inventory[i] = stack:to_string ()
		if remainder:is_empty () then
			break
		end
	end
	return remainder
end

function mob_class:has_items (name, rem)
	if not self._inventory then
		return false
	end

	for _, slot in ipairs (self._inventory) do
		local item = ItemStack (slot)
		if name == item:get_name () then
			local count = item:get_count ()

			rem = rem - math.min (rem, count)
			if rem == 0 then
				return true
			end
		end
	end
	return false
end

function mob_class:count_items (name)
	if not self._inventory then
		return 0
	end

	local count = 0
	for _, slot in ipairs (self._inventory) do
		local item = ItemStack (slot)
		if name == item:get_name () then
			count = count + item:get_count ()
		end
	end
	return count
end

function mob_class:remove_item (name, wanted)
	if not self._inventory then
		return 0
	end

	local stack = ItemStack ()
	for i, slot in ipairs (self._inventory) do
		local item = ItemStack (slot)
		if not item:is_empty ()
			and item:get_name () == name then
			local count = item:get_count ()
			local n = math.min (wanted, count)
			local taken = item:take_item (n)
			local remainder = stack:add_item (taken)
			local rem = remainder:get_count ()
			item:add_item (remainder)
			wanted = wanted - (n - rem)
			self._inventory[i] = item:to_string ()
		end

		if wanted <= 0 then
			break
		end
	end
	return stack
end

function mob_class:drop_inventory (self_pos)
	if self._inventory then
		for _, item in pairs (self._inventory) do
			local stack = ItemStack (item)
			if not stack:is_empty () then
				mcl_util.drop_item_stack (self_pos, stack)
			end
		end
	end
end
