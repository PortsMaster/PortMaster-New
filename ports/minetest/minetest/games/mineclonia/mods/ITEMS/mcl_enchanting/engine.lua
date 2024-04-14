local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape

function mcl_enchanting.is_book(itemname)
	return itemname == "mcl_books:book" or itemname == "mcl_enchanting:book_enchanted" or
		itemname == "mcl_books:book_enchanted"
end

function mcl_enchanting.get_enchantments(itemstack)
	if not itemstack then
		return {}
	end
	return minetest.deserialize(itemstack:get_meta():get_string("mcl_enchanting:enchantments")) or {}
end

function mcl_enchanting.unload_enchantments(itemstack)
	local itemdef = itemstack:get_definition()
	local meta = itemstack:get_meta()
	if itemdef.tool_capabilities then
		meta:set_tool_capabilities(nil)
		meta:set_string("groupcaps_hash", "")
	end
	if meta:get_string("name") == "" then
		meta:set_string("description", "")
		meta:set_string("groupcaps_hash", "")
	end
end

function mcl_enchanting.load_enchantments(itemstack, enchantments)
	if not mcl_enchanting.is_book(itemstack:get_name()) then
		mcl_enchanting.unload_enchantments(itemstack)
		for enchantment, level in pairs(enchantments or mcl_enchanting.get_enchantments(itemstack)) do
			local enchantment_def = mcl_enchanting.enchantments[enchantment]
			if enchantment_def.on_enchant then
				enchantment_def.on_enchant(itemstack, level)
			end
		end
		mcl_enchanting.update_groupcaps(itemstack)
	end
	tt.reload_itemstack_description(itemstack)
end

function mcl_enchanting.set_enchantments(itemstack, enchantments)
	itemstack:get_meta():set_string("mcl_enchanting:enchantments", minetest.serialize(enchantments))
	mcl_enchanting.load_enchantments(itemstack)
end

function mcl_enchanting.get_enchantment(itemstack, enchantment)
	return mcl_enchanting.get_enchantments(itemstack)[enchantment] or 0
end

function mcl_enchanting.has_enchantment(itemstack, enchantment)
	return mcl_enchanting.get_enchantment(itemstack, enchantment) > 0
end

function mcl_enchanting.get_enchantment_description(enchantment, level)
	local enchantment_def = mcl_enchanting.enchantments[enchantment]
	return enchantment_def.name ..
		(enchantment_def.max_level == 1 and "" or " " .. mcl_enchanting.roman_numerals.toRoman(level))
end

function mcl_enchanting.get_colorized_enchantment_description(enchantment, level)
	return minetest.colorize(mcl_enchanting.enchantments[enchantment].curse and mcl_colors.RED or mcl_colors.GRAY,
		mcl_enchanting.get_enchantment_description(enchantment, level))
end

function mcl_enchanting.get_enchanted_itemstring(itemname)
	local def = minetest.registered_items[itemname]
	return def and def._mcl_enchanting_enchanted_tool
end

function mcl_enchanting.set_enchanted_itemstring(itemstack)
	itemstack:set_name(mcl_enchanting.get_enchanted_itemstring(itemstack:get_name()))
end

function mcl_enchanting.is_enchanted(itemname)
	return minetest.get_item_group(itemname, "enchanted") > 0
end

function mcl_enchanting.not_enchantable_on_enchanting_table(itemname)
	return mcl_enchanting.get_enchantability(itemname) == -1
end

function mcl_enchanting.is_enchantable(itemname)
	return mcl_enchanting.get_enchantability(itemname) > 0 or
		mcl_enchanting.not_enchantable_on_enchanting_table(itemname)
end

function mcl_enchanting.can_enchant_freshly(itemname)
	return mcl_enchanting.is_enchantable(itemname) and not mcl_enchanting.is_enchanted(itemname)
end

function mcl_enchanting.get_enchantability(itemname)
	return minetest.get_item_group(itemname, "enchantability")
end

function mcl_enchanting.item_supports_enchantment(itemname, enchantment, early)
	if not mcl_enchanting.is_enchantable(itemname) then
		return false
	end
	local enchantment_def = mcl_enchanting.enchantments[enchantment]
	if mcl_enchanting.is_book(itemname) then
		return true, (not enchantment_def.treasure)
	end
	local itemdef = minetest.registered_items[itemname]
	if itemdef.type ~= "tool" and enchantment_def.requires_tool then
		return false
	end
	for disallow in pairs(enchantment_def.disallow) do
		if minetest.get_item_group(itemname, disallow) > 0 then
			return false
		end
	end
	for group in pairs(enchantment_def.primary) do
		if minetest.get_item_group(itemname, group) > 0 then
			return true, true
		end
	end
	for group in pairs(enchantment_def.secondary) do
		if minetest.get_item_group(itemname, group) > 0 then
			return true, false
		end
	end
	return false
end

function mcl_enchanting.can_enchant(itemstack, enchantment, level)
	local enchantment_def = mcl_enchanting.enchantments[enchantment]
	if not enchantment_def then
		return false, "enchantment invalid"
	end
	local itemname = itemstack:get_name()
	if itemname == "" then
		return false, "item missing"
	end
	local supported, primary = mcl_enchanting.item_supports_enchantment(itemname, enchantment)
	if not supported then
		return false, "item not supported"
	end
	if not level then
		return false, "level invalid"
	end
	if level > enchantment_def.max_level then
		return false, "level too high", enchantment_def.max_level
	elseif level < 1 then
		return false, "level too small", 1
	end
	local item_enchantments = mcl_enchanting.get_enchantments(itemstack)
	local enchantment_level = item_enchantments[enchantment]
	if enchantment_level then
		return false, "incompatible", mcl_enchanting.get_enchantment_description(enchantment, enchantment_level)
	end
	if not mcl_enchanting.is_book(itemname) then
		for incompatible in pairs(enchantment_def.incompatible) do
			local incompatible_level = item_enchantments[incompatible]
			if incompatible_level then
				return false, "incompatible",
					mcl_enchanting.get_enchantment_description(incompatible, incompatible_level)
			end
		end
	end
	return true, nil, nil, primary
end

function mcl_enchanting.enchant(itemstack, enchantment, level)
	mcl_enchanting.set_enchanted_itemstring(itemstack)
	local enchantments = mcl_enchanting.get_enchantments(itemstack)
	enchantments[enchantment] = level
	mcl_enchanting.set_enchantments(itemstack, enchantments)
	return itemstack
end

function mcl_enchanting.get_prior_work_penalty(itemstack)
	local m = itemstack:get_meta()
	return m:get_int("mcl_enchanting:pwp")
end

function mcl_enchanting.add_prior_work_penalty(itemstack, amount)
	amount = amount or 1
	local m = itemstack:get_meta()
	local old_pwp = m:get_int("mcl_enchanting:pwp")
	m:set_int("mcl_enchanting:pwp", old_pwp + amount)
	return itemstack
end

function mcl_enchanting.combine(itemstack, combine_with)
	local itemname = itemstack:get_name()
	local combine_name = combine_with:get_name()
	local enchanted_itemname = mcl_enchanting.get_enchanted_itemstring(itemname)
	if not enchanted_itemname or
		enchanted_itemname ~= mcl_enchanting.get_enchanted_itemstring(combine_name) and
		not mcl_enchanting.is_book(combine_name) then
		return false
	end
	local enchantments = mcl_enchanting.get_enchantments(itemstack)
	local any_new_enchantment = false
	local incompatible_enchants = 0
	for enchantment, combine_level in pairs(mcl_enchanting.get_enchantments(combine_with)) do
		local enchantment_def = mcl_enchanting.enchantments[enchantment]
		local enchantment_level = enchantments[enchantment]
		if enchantment_level then -- The enchantment already exist in the provided item
			if enchantment_level == combine_level then
				enchantment_level = math.min(enchantment_level + 1, enchantment_def.max_level)
			else
				enchantment_level = math.max(enchantment_level, combine_level)
			end
			any_new_enchantment = any_new_enchantment or ( enchantment_level ~= enchantments[enchantment] )
		elseif mcl_enchanting.item_supports_enchantment(itemname, enchantment) then -- this is a new enchantement to try to add
			local supported = true
			for incompatible in pairs(enchantment_def.incompatible) do
				if enchantments[incompatible] then
					incompatible_enchants = incompatible_enchants + 1
					supported = false
					break
				end
			end
			if supported then
				enchantment_level = combine_level
				any_new_enchantment = true
			end
		end
		if enchantment_level and enchantment_level > 0 then
			enchantments[enchantment] = enchantment_level
		end
	end
	local level_requirement = 0
	level_requirement = level_requirement + incompatible_enchants
	if any_new_enchantment then
		itemstack = mcl_enchanting.add_prior_work_penalty(itemstack)
		itemstack:set_name(enchanted_itemname)
		for k,v in pairs(enchantments) do
			if mcl_enchanting.is_book(combine_name) then
				level_requirement = level_requirement + ( v * ((mcl_enchanting.enchantments[k] and mcl_enchanting.enchantments[k].anvil_book_cost) or 1))
			else
				level_requirement = level_requirement + ( v * ((mcl_enchanting.enchantments[k] and mcl_enchanting.enchantments[k].anvil_item_cost) or 1))
			end
		end
		mcl_enchanting.set_enchantments(itemstack, enchantments)
	end
	return any_new_enchantment, level_requirement
end

function mcl_enchanting.enchantments_snippet(_, _, itemstack)
	if not itemstack then
		return
	end
	local enchantments = mcl_enchanting.get_enchantments(itemstack)
	local text = ""
	for enchantment, level in pairs(enchantments) do
		text = text .. mcl_enchanting.get_colorized_enchantment_description(enchantment, level) .. "\n"
	end
	if text ~= "" then
		if not itemstack:get_definition()._tt_original_description then
			text = text:sub(1, text:len() - 1)
		end
		return text, false
	end
end

-- Returns the after_use callback function to use when registering an enchanted
-- item.  The after_use callback is used to update the tool_capabilities of
-- efficiency enchanted tools with outdated digging times.
--
-- It does this by calling apply_efficiency to reapply the efficiency
-- enchantment.  That function is written to use hash values to only update the
-- tool if neccessary.
--
-- This is neccessary for digging times of tools to be in sync when MineClone2
-- or mods add new hardness values.
local function get_after_use_callback(itemdef)
	if itemdef.after_use then
		-- If the tool already has an after_use, make sure to call that
		-- one too.
		return function(itemstack, user, node, digparams)
			itemdef.after_use(itemstack, user, node, digparams)
			mcl_enchanting.update_groupcaps(itemstack)
		end
	end

	-- If the tool does not have after_use, add wear to the tool as if no
	-- after_use was registered.
	return function(itemstack, user, node, digparams)
		if not minetest.is_creative_enabled(user:get_player_name()) then
			itemstack:add_wear(digparams.wear)
		end

		--local enchantments = mcl_enchanting.get_enchantments(itemstack)
		mcl_enchanting.update_groupcaps(itemstack)
	end
end

function mcl_enchanting.initialize()
	local register_tool_list = {}
	local register_item_list = {}
	for itemname, itemdef in pairs(minetest.registered_items) do
		if mcl_enchanting.can_enchant_freshly(itemname) and not mcl_enchanting.is_book(itemname) then
			local new_name = itemname .. "_enchanted"
			minetest.override_item(itemname, { _mcl_enchanting_enchanted_tool = new_name })
			local new_def = table.copy(itemdef)
			new_def.inventory_image = itemdef.inventory_image .. mcl_enchanting.overlay
			if new_def.wield_image then
				new_def.wield_image = new_def.wield_image .. mcl_enchanting.overlay
			end
			new_def.groups.not_in_creative_inventory = 1
			new_def.groups.not_in_craft_guide = 1
			new_def.groups.enchanted = 1

			if new_def._mcl_armor_texture then
				if type(new_def._mcl_armor_texture) == "string" then
					new_def._mcl_armor_texture = new_def._mcl_armor_texture .. mcl_enchanting.overlay
				end
			end

			new_def._mcl_enchanting_enchanted_tool = new_name
			new_def.after_use = get_after_use_callback(itemdef)
			local register_list = register_item_list
			if itemdef.type == "tool" then
				register_list = register_tool_list
			end
			register_list[":" .. new_name] = new_def
		end
	end
	for new_name, new_def in pairs(register_item_list) do
		minetest.register_craftitem(new_name, new_def)
	end
	for new_name, new_def in pairs(register_tool_list) do
		minetest.register_tool(new_name, new_def)
	end
end

function mcl_enchanting.random(pr, ...)
	local r = pr and pr:next(...) or math.random(...)

	if pr and not ({ ... })[1] then
		r = r / 32767
	end

	return r
end

function mcl_enchanting.get_random_enchantment(itemstack, treasure, weighted, exclude, pr)
	local possible = {}

	for enchantment, enchantment_def in pairs(mcl_enchanting.enchantments) do
		local can_enchant, _, _, primary = mcl_enchanting.can_enchant(itemstack, enchantment, 1)

		if can_enchant and (primary or treasure) and (not exclude or table.indexof(exclude, enchantment) == -1) then
			local weight = weighted and enchantment_def.weight or 1

			for i = 1, weight do
				table.insert(possible, enchantment)
			end
		end
	end

	return #possible > 0 and possible[mcl_enchanting.random(pr, 1, #possible)]
end

function mcl_enchanting.generate_random_enchantments(itemstack, enchantment_level, treasure, no_reduced_bonus_chance,
													 ignore_already_enchanted, pr)
	local itemname = itemstack:get_name()

	if (not mcl_enchanting.can_enchant_freshly(itemname) and not ignore_already_enchanted) or
		mcl_enchanting.not_enchantable_on_enchanting_table(itemname) then
		return
	end

	itemstack = ItemStack(itemstack)

	local enchantability = minetest.get_item_group(itemname, "enchantability")
	enchantability = 1 + mcl_enchanting.random(pr, 0, math.floor(enchantability / 4)) +
		mcl_enchanting.random(pr, 0, math.floor(enchantability / 4))

	enchantment_level = enchantment_level + enchantability
	enchantment_level = enchantment_level +
		enchantment_level * (mcl_enchanting.random(pr) + mcl_enchanting.random(pr) - 1) * 0.15
	enchantment_level = math.max(math.floor(enchantment_level + 0.5), 1)

	local enchantments = {}
	local description

	enchantment_level = enchantment_level * 2

	repeat
		enchantment_level = math.floor(enchantment_level / 2)

		if enchantment_level == 0 then
			break
		end

		local selected_enchantment = mcl_enchanting.get_random_enchantment(itemstack, treasure, true, nil, pr)

		if not selected_enchantment then
			break
		end

		local enchantment_def = mcl_enchanting.enchantments[selected_enchantment]
		local power_range_table = enchantment_def.power_range_table

		local enchantment_power

		for i = enchantment_def.max_level, 1, -1 do
			local power_range = power_range_table[i]
			if enchantment_level >= power_range[1] and enchantment_level <= power_range[2] then
				enchantment_power = i
				break
			end
		end

		if not description then
			if not enchantment_power then
				return
			end

			description = mcl_enchanting.get_enchantment_description(selected_enchantment, enchantment_power)
		end

		if enchantment_power then
			enchantments[selected_enchantment] = enchantment_power
			mcl_enchanting.enchant(itemstack, selected_enchantment, enchantment_power)
		end
	until not no_reduced_bonus_chance and mcl_enchanting.random(pr) >= (enchantment_level + 1) / 50

	return enchantments, description
end

function mcl_enchanting.generate_random_enchantments_reliable(itemstack, enchantment_level, treasure, no_reduced_bonus_chance, ignore_already_enchanted, pr)
	local enchantments

	repeat
		enchantments = mcl_enchanting.generate_random_enchantments(itemstack, enchantment_level, treasure,
			no_reduced_bonus_chance, ignore_already_enchanted, pr)
	until enchantments

	return enchantments
end

function mcl_enchanting.enchant_randomly(itemstack, enchantment_level, treasure, no_reduced_bonus_chance,
										 ignore_already_enchanted, pr)
	local enchantments = mcl_enchanting.generate_random_enchantments_reliable(itemstack, enchantment_level, treasure, no_reduced_bonus_chance, ignore_already_enchanted, pr)

	mcl_enchanting.set_enchanted_itemstring(itemstack)
	mcl_enchanting.set_enchantments(itemstack, enchantments)

	return itemstack
end

function mcl_enchanting.enchant_uniform_randomly(stack, exclude, pr)
	local enchantment = mcl_enchanting.get_random_enchantment(stack, true, false, exclude, pr)

	if enchantment then
		mcl_enchanting.enchant(stack, enchantment,
			mcl_enchanting.random(pr, 1, mcl_enchanting.enchantments[enchantment].max_level))
	end

	return stack
end

function mcl_enchanting.get_random_glyph_row()
	local glyphs = ""
	local x = 1.3
	for i = 1, 9 do
		glyphs = glyphs ..
			"image[" .. x .. ",0.1;0.5,0.5;mcl_enchanting_glyph_" .. math.random(18) .. ".png^[colorize:#675D49:255]"
		x = x + 0.6
	end
	return glyphs
end

function mcl_enchanting.generate_random_table_slots(itemstack, num_bookshelves)
	local base = math.random(8) + math.floor(num_bookshelves / 2) + math.random(0, num_bookshelves)
	local required_levels = {
		math.max(base / 3, 1),
		(base * 2) / 3 + 1,
		math.max(base, num_bookshelves * 2)
	}
	local slots = {}
	for i, enchantment_level in ipairs(required_levels) do
		local slot = false
		local enchantments, description = mcl_enchanting.generate_random_enchantments(itemstack, enchantment_level)
		if enchantments then
			slot = {
				enchantments = enchantments,
				description = description,
				glyphs = mcl_enchanting.get_random_glyph_row(),
				level_requirement = math.max(i, math.floor(enchantment_level)),
			}
		end
		slots[i] = slot
	end
	return slots
end

function mcl_enchanting.get_table_slots(player, itemstack, num_bookshelves)
	local itemname = itemstack:get_name()
	if (not mcl_enchanting.can_enchant_freshly(itemname)) or mcl_enchanting.not_enchantable_on_enchanting_table(itemname) then
		return { false, false, false }
	end
	local meta = player:get_meta()
	local player_slots = minetest.deserialize(meta:get_string("mcl_enchanting:slots")) or {}
	local player_bookshelves_slots = player_slots[num_bookshelves] or {}
	local player_bookshelves_item_slots = player_bookshelves_slots[itemname]
	if player_bookshelves_item_slots then
		return player_bookshelves_item_slots
	else
		player_bookshelves_item_slots = mcl_enchanting.generate_random_table_slots(itemstack, num_bookshelves)
		if player_bookshelves_item_slots then
			player_bookshelves_slots[itemname] = player_bookshelves_item_slots
			player_slots[num_bookshelves] = player_bookshelves_slots
			meta:set_string("mcl_enchanting:slots", minetest.serialize(player_slots))
			return player_bookshelves_item_slots
		else
			return { false, false, false }
		end
	end
end

function mcl_enchanting.reset_table_slots(player)
	player:get_meta():set_string("mcl_enchanting:slots", "")
end

function mcl_enchanting.show_enchanting_formspec(player)
	local C = minetest.get_color_escape_sequence
	local name = player:get_player_name()
	local meta = player:get_meta()
	local inv = player:get_inventory()
	local num_bookshelves = meta:get_int("mcl_enchanting:num_bookshelves")
	local table_name = meta:get_string("mcl_enchanting:table_name")

	local formspec = table.concat({
		"formspec_version[4]",
		"size[11.75,10.425]",

		"label[0.375,0.375;" .. F(C(mcl_formspec.label_color) .. table_name) .. "]",
		mcl_formspec.get_itemslot_bg_v4(1, 3.25, 1, 1),
		"list[current_player;enchanting_item;1,3.25;1,1]",
		mcl_formspec.get_itemslot_bg_v4(2.25, 3.25, 1, 1),
		"image[2.25,3.25;1,1;mcl_enchanting_lapis_background.png]",
		"list[current_player;enchanting_lapis;2.25,3.25;1,1]",
		"image[4.125,0.56;7.25,4.1;mcl_enchanting_button_background.png]",
		"label[0.375,4.7;" .. F(C(mcl_formspec.label_color) .. S("Inventory")) .. "]",
		mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
		"list[current_player;main;0.375,5.1;9,3;9]",

		mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
		"list[current_player;main;0.375,9.05;9,1;]",

		"listring[current_player;enchanting_item]",
		"listring[current_player;main]",
		"listring[current_player;enchanting]",
		"listring[current_player;main]",
		"listring[current_player;enchanting_lapis]",
		"listring[current_player;main]",
	})

	local itemstack = inv:get_stack("enchanting_item", 1)
	local player_levels = mcl_experience.get_level(player)
	local y = 0.65
	local any_enchantment = false
	local table_slots = mcl_enchanting.get_table_slots(player, itemstack, num_bookshelves)
	for i, slot in ipairs(table_slots) do
		any_enchantment = any_enchantment or slot
		local enough_lapis = inv:contains_item("enchanting_lapis", ItemStack({ name = "mcl_core:lapis", count = i }))
		local enough_levels = slot and slot.level_requirement <= player_levels
		local can_enchant = (slot and enough_lapis and enough_levels)
		local ending = (can_enchant and "" or "_off")
		local hover_ending = (can_enchant and "_hovered" or "_off")
		formspec = formspec
			.. "container[4.125," .. y .. "]"
			..
			(
				slot and
				"tooltip[button_" ..
				i ..
				";" ..
				C("#818181") ..
				((slot.description and F(slot.description)) or "") ..
				" " ..
				C("#FFFFFF") ..
				" . . . ?\n\n" ..
				(
					enough_levels and
					C(enough_lapis and "#818181" or "#FC5454") ..
					F(S("@1 Lapis Lazuli", i)) .. "\n" .. C("#818181") .. F(S("@1 Enchantment Levels", i)) or
					C("#FC5454") .. F(S("Level requirement: @1", slot.level_requirement))) .. "]" or "")
			..
			"style[button_" ..
			i ..
			";bgimg=mcl_enchanting_button" ..
			ending ..
			".png;bgimg_hovered=mcl_enchanting_button" ..
			hover_ending .. ".png;bgimg_pressed=mcl_enchanting_button" .. hover_ending .. ".png]"
			.. "button[0,0;7.25,1.3;button_" .. i .. ";]"
			.. (slot and "image[0,0;1.3,1.3;mcl_enchanting_number_" .. i .. ending .. ".png]" or "")
			.. (slot and "label[6.8,1;" .. C(can_enchant and "#80FF20" or "#407F10") .. slot.level_requirement .. "]" or "")
			.. (slot and slot.glyphs or "")
			.. "container_end[]"
		y = y + 1.3
	end
	formspec = formspec
		..
		"image[" ..
		(any_enchantment and 1.1 or 1.67) ..
		",1.2;" ..
		(any_enchantment and 2 or 0.87) ..
		",1.43;mcl_enchanting_book_" .. (any_enchantment and "open" or "closed") .. ".png]"
	minetest.show_formspec(name, "mcl_enchanting:table", formspec)
end

function mcl_enchanting.handle_formspec_fields(player, formname, fields)
	if formname == "mcl_enchanting:table" then
		local button_pressed
		for i = 1, 3 do
			if fields["button_" .. i] then
				button_pressed = i
			end
		end
		if not button_pressed then return end
		local name = player:get_player_name()
		local inv = player:get_inventory()
		local meta = player:get_meta()
		local num_bookshelfes = meta:get_int("mcl_enchanting:num_bookshelves")
		local itemstack = inv:get_stack("enchanting_item", 1)
		local cost = ItemStack({ name = "mcl_core:lapis", count = button_pressed })
		if not inv:contains_item("enchanting_lapis", cost) then
			return
		end
		local slots = mcl_enchanting.get_table_slots(player, itemstack, num_bookshelfes)
		local slot = slots[button_pressed]
		if not slot then
			return
		end
		local player_level = mcl_experience.get_level(player)
		if player_level < slot.level_requirement then
			return
		end
		mcl_experience.set_level(player, player_level - button_pressed)
		inv:remove_item("enchanting_lapis", cost)
		mcl_enchanting.set_enchanted_itemstring(itemstack)
		mcl_enchanting.set_enchantments(itemstack, slot.enchantments)
		inv:set_stack("enchanting_item", 1, itemstack)
		minetest.sound_play("mcl_enchanting_enchant", { to_player = name, gain = 5.0 })
		mcl_enchanting.reset_table_slots(player)
		mcl_enchanting.show_enchanting_formspec(player)
		awards.unlock(player:get_player_name(), "mcl:enchanter")
	end
end

function mcl_enchanting.initialize_player(player)
	local inv = player:get_inventory()
	inv:set_size("enchanting", 1)
	inv:set_size("enchanting_item", 1)
	inv:set_size("enchanting_lapis", 1)
end

function mcl_enchanting.is_enchanting_inventory_action(action, inventory, inventory_info)
	if inventory:get_location().type == "player" then
		local enchanting_lists = mcl_enchanting.enchanting_lists
		if action == "move" then
			local is_from = table.indexof(enchanting_lists, inventory_info.from_list) ~= -1
			local is_to = table.indexof(enchanting_lists, inventory_info.to_list) ~= -1
			return is_from or is_to, is_to
		elseif (action == "put" or action == "take") and table.indexof(enchanting_lists, inventory_info.listname) ~= -1 then
			return true
		end
	else
		return false
	end
end

function mcl_enchanting.allow_inventory_action(player, action, inventory, inventory_info)
	local is_enchanting_action, do_limit = mcl_enchanting.is_enchanting_inventory_action(action, inventory,
		inventory_info)
	if is_enchanting_action and do_limit then
		if action == "move" then
			local listname = inventory_info.to_list
			local stack = inventory:get_stack(inventory_info.from_list, inventory_info.from_index)
			if stack:get_name() == "mcl_core:lapis" and listname ~= "enchanting_item" then
				local count = stack:get_count()
				local old_stack = inventory:get_stack("enchanting_lapis", 1)
				if old_stack:get_name() ~= "" then
					count = math.min(count, old_stack:get_free_space())
				end
				return count
			elseif inventory:get_stack("enchanting_item", 1):get_count() == 0 and listname ~= "enchanting_lapis" then
				return 1
			else
				return 0
			end
		else
			return 0
		end
	end
end

function mcl_enchanting.on_inventory_action(player, action, inventory, inventory_info)
	if mcl_enchanting.is_enchanting_inventory_action(action, inventory, inventory_info) then
		if action == "move" and inventory_info.to_list == "enchanting" then
			local stack = inventory:get_stack("enchanting", 1)
			local result_list
			if stack:get_name() == "mcl_core:lapis" then
				result_list = "enchanting_lapis"
				stack:add_item(inventory:get_stack("enchanting_lapis", 1))
			else
				result_list = "enchanting_item"
			end
			inventory:set_stack(result_list, 1, stack)
			inventory:set_stack("enchanting", 1, nil)
		end
		mcl_enchanting.show_enchanting_formspec(player)
	end
end

function mcl_enchanting.schedule_book_animation(self, anim)
	self.scheduled_anim = { timer = self.anim_length, anim = anim }
end

function mcl_enchanting.set_book_animation(self, anim)
	local anim_index = mcl_enchanting.book_animations[anim]
	local start, stop = mcl_enchanting.book_animation_steps[anim_index],
		mcl_enchanting.book_animation_steps[anim_index + 1]
	self.object:set_animation({ x = start, y = stop }, mcl_enchanting.book_animation_speed, 0,
		mcl_enchanting.book_animation_loop[anim] or false)
	self.scheduled_anim = nil
	self.anim_length = (stop - start) / 40
end

function mcl_enchanting.check_animation_schedule(self, dtime)
	local schedanim = self.scheduled_anim
	if schedanim then
		schedanim.timer = schedanim.timer - dtime
		if schedanim.timer <= 0 then
			mcl_enchanting.set_book_animation(self, schedanim.anim)
		end
	end
end

function mcl_enchanting.look_at(self, pos2)
	local pos1 = self.object:get_pos()
	local vec = vector.subtract(pos1, pos2)
	local yaw = math.atan(vec.z / vec.x) - math.pi / 2
	yaw = yaw + (pos1.x >= pos2.x and math.pi or 0)
	self.object:set_yaw(yaw + math.pi)
end

function mcl_enchanting.get_bookshelves(pos)
	local absolute, relative = {}, {}
	for i, rp in ipairs(mcl_enchanting.bookshelf_positions) do
		local airp = vector.add(pos, mcl_enchanting.air_positions[i])
		local ap = vector.add(pos, rp)
		if minetest.get_node(ap).name == "mcl_books:bookshelf" and minetest.get_node(airp).name == "air" then
			table.insert(absolute, ap)
			table.insert(relative, rp)
		end
	end
	return absolute, relative
end
