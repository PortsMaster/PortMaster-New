function mcl_armor.play_equip_sound(stack, obj, pos, unequip)
	local def = stack:get_definition()
	local estr = "equip"
	if unequip then
		estr = "unequip"
	end
	local snd = def.sounds and def.sounds["_mcl_armor_" .. estr]
	if not snd then
		-- Fallback sound
		snd = { name = "mcl_armor_" .. estr .. "_generic" }
	end
	if snd then
		local dist = 8
		if pos then
			dist = 16
		end
		minetest.sound_play(snd, {object = obj, pos = pos, gain = 0.5, max_hear_distance = dist}, true)
	end
end

function mcl_armor.on_equip(itemstack, obj)
	local def = itemstack:get_definition()
	mcl_armor.play_equip_sound(itemstack, obj)
	if def._on_equip then
		def._on_equip(obj, itemstack)
	end
	mcl_armor.update(obj)
end

function mcl_armor.on_unequip(itemstack, obj)
	local def = itemstack:get_definition()
	mcl_armor.play_equip_sound(itemstack, obj, nil, true)
	if def._on_unequip then
		def._on_unequip(obj, itemstack)
	end
	mcl_armor.update(obj)
end

function mcl_armor.equip(itemstack, obj, swap)
	local def = itemstack:get_definition()

	if not def then
		return itemstack
	end

	local inv = mcl_util.get_inventory(obj, true)

	if not inv or inv:get_size("armor") == 0 then
		return itemstack
	end

	local element = mcl_armor.elements[def._mcl_armor_element or ""]

	if element then
		local old_stack = inv:get_stack("armor", element.index)

		if swap or old_stack:is_empty() then
			local new_stack

			if swap then
				new_stack = itemstack
				itemstack = old_stack
			else
				new_stack = itemstack:take_item()
			end

			inv:set_stack("armor", element.index, new_stack)
			mcl_armor.on_equip(new_stack, obj)
		end
	end

	return itemstack
end

function mcl_armor.equip_on_use(itemstack, player, pointed_thing)
	if not player or not player:is_player() then
		return itemstack
	end

	local new_stack = mcl_util.call_on_rightclick(itemstack, player, pointed_thing)
	if new_stack then
		return new_stack
	end

	return mcl_armor.equip(itemstack, player, true)
end

local function get_armor_texture(textures, name, modname, itemname, itemstring)
	local core_texture = textures[name] or modname .. "_" .. itemname .. ".png"
	if type(core_texture) == "function" then return core_texture end
	mcl_armor.trims.core_textures[itemstring] = core_texture
	local func = function(obj, itemstack)
		local overlay = itemstack:get_meta():get_string("mcl_armor:trim_overlay")
		local stack_name = mcl_grindstone.remove_enchant_name(itemstack) -- gets original itemstring if enchanted, no need to store (nearly) identical values
		local core_armor_texture = mcl_armor.trims.core_textures[stack_name]

		if mcl_enchanting.is_enchanted(itemstack:get_name()) then -- working with the original stack to know wether to apply enchanting overlay or not
			--  Far, Far in the future we may no longer _enchanted itemstrings...
			--  To fix this code, simply put the unmodified itemstring in stack_name's place
			--  DO NOT REMOVE THIS if UNLESS YOU KNOW WHAT YOU'RE TRYING TO ACHIEVE!
			core_armor_texture = core_armor_texture .. mcl_enchanting.overlay
		end

		if overlay == "" then return core_armor_texture end -- key not present; armor not trimmed

		return core_armor_texture .. overlay
	end

	return func
end

function mcl_armor.register_set(def)
	local modname = minetest.get_current_modname()
	local groups = def.groups or {}
	local on_equip_callbacks = def.on_equip_callbacks or {}
	local on_unequip_callbacks = def.on_unequip_callbacks or {}
	local on_break_callbacks = def.on_break_callbacks or {}
	local textures = def.textures or {}
	local durabilities = def.durabilities or {}
	local element_groups = def.element_groups or {}

	-- backwards compatibility
	local descriptions = def.descriptions or {}
	if def.description then
		minetest.log("warning", "[mcl_armor] using the description field of armor set definitions is deprecated, please provide the localized strings in def.descriptions instead. Currently processing " .. def.name)
		local S = minetest.get_translator(modname)
		for name, element in pairs(mcl_armor.elements) do
			descriptions[name] = S(def.description .. " " .. (descriptions[name] or element.description))
		end
	end

	for name, element in pairs(mcl_armor.elements) do
		local itemname = element.name .. "_" .. def.name
		local itemstring = modname .. ":" .. itemname

		local groups = table.copy(groups)
		groups["armor_" .. name] = 1
		groups["combat_armor_" .. name] = 1
		groups["armor_" .. def.name] = 1
		groups.armor = 1
		groups.combat_armor = 1
		groups.mcl_armor_points = def.points[name]
		groups.mcl_armor_toughness = def.toughness
		groups.mcl_armor_uses = (durabilities[name] or math.floor(def.durability * element.durability)) + 1
		groups.enchantability = def.enchantability

		for k, v in pairs(element_groups) do
			groups[k] = v
		end
		local upgrade_item = nil
		if def._mcl_upgradable and def._mcl_upgrade_item_material then
			upgrade_item = itemstring:gsub("_[%l%d]*$",def._mcl_upgrade_item_material)
		end

		minetest.register_tool(itemstring, {
			description = descriptions[name],
			_doc_items_longdesc = mcl_armor.longdesc,
			_doc_items_usagehelp = mcl_armor.usage,
			inventory_image = modname .. "_inv_" .. itemname .. ".png",
			_repair_material = def.repair_material or def.craft_material,
			groups = groups,
			sounds = {
				_mcl_armor_equip = def.sound_equip or modname .. "_equip_" .. def.name,
				_mcl_armor_unequip = def.sound_unequip or modname .. "_unequip_" .. def.name,
			},
			on_place = mcl_armor.equip_on_use,
			on_secondary_use = mcl_armor.equip_on_use,
			_on_equip = on_equip_callbacks[name] or def.on_equip,
			_on_unequip = on_unequip_callbacks[name] or def.on_unequip,
			_on_break = on_break_callbacks[name] or def.on_break,
			_mcl_armor_element = name,
			_mcl_armor_texture = get_armor_texture(textures, name, modname, itemname, itemstring),
			_mcl_upgradable = def._mcl_upgradable,
			_mcl_upgrade_item = upgrade_item
		})

		if def.craft_material then
			minetest.register_craft({
				output = itemstring,
				recipe = element.craft(def.craft_material),
			})
		end

		if def.cook_material then
			minetest.register_craft({
				type = "cooking",
				output = def.cook_material,
				recipe = itemstring,
				cooktime = 10,
			})
		end
	end
end

mcl_armor.protection_enchantments = {
	flags = {},
	types = {},
	wildcard = {},
}

function mcl_armor.register_protection_enchantment(def)
	local prot_def = {id = def.id, factor = def.factor}
	if def.damage_flag then
		local tbl = mcl_armor.protection_enchantments.flags[def.damage_flag] or {}
		table.insert(tbl, prot_def)
		mcl_armor.protection_enchantments.flags = tbl
	elseif def.damage_type then
		local tbl = mcl_armor.protection_enchantments.types[def.damage_type] or {}
		table.insert(tbl, prot_def)
		mcl_armor.protection_enchantments.types = tbl
	else
		table.insert(mcl_armor.protection_enchantments.wildcard, prot_def)
	end
	mcl_enchanting.enchantments[def.id] = {
		name = def.name,
		max_level = def.max_level or 4,
		primary = def.primary or {combat_armor = true},
		secondary = {},
		disallow = {},
		incompatible = def.incompatible or {},
		weight = def.weight or 5,
		description = def.description,
		curse = false,
		on_enchant = function() end,
		requires_tool = false,
		treasure = def.treasure or false,
		power_range_table = def.power_range_table,
		inv_combat_tab = true,
		inv_tool_tab = false,
		anvil_item_factor = def.anvil_item_factor or 1,
		anvil_book_factor = def.anvil_book_factor or 1,
	}
end

function mcl_armor.update(obj)
	local info = {points = 0, view_range_factors = {}}

	local inv = mcl_util.get_inventory(obj)

	if inv then
		for i = 2, 5 do
			local itemstack = inv:get_stack("armor", i)

			local itemname = itemstack:get_name()
			if minetest.registered_aliases[itemname] then
				itemname = minetest.registered_aliases[itemname]
			end

			if not itemstack:is_empty() then
				local def = itemstack:get_definition()

				local texture = def._mcl_armor_texture

				if texture then
					if type(texture) == "function" then
						texture = texture(obj, itemstack)
					end
					if texture then
						info.texture = "(" .. texture .. ")" .. (info.texture and "^" .. info.texture or "")
					end
				end

				info.points = info.points + minetest.get_item_group(itemname, "mcl_armor_points")

				local mob_range_mob = def._mcl_armor_mob_range_mob

				if mob_range_mob then
					local factor = info.view_range_factors[mob_range_mob]

					if factor then
						if factor > 0 then
							info.view_range_factors[mob_range_mob] = factor * def._mcl_armor_mob_range_factor
						end
					else
						info.view_range_factors[mob_range_mob] = def._mcl_armor_mob_range_factor
					end
				end
			end
		end
	end

	info.texture = info.texture or "blank.png"

	if obj:is_player() then
		mcl_armor.update_player(obj, info)
	else
		local luaentity = obj:get_luaentity()

		if luaentity.update_armor then
			luaentity:update_armor(info)
		end
	end
end

function mcl_armor.trim(itemstack, overlay, color_string)
	local def = itemstack:get_definition()
	if not def._mcl_armor_texture and not mcl_armor.trims.blacklisted[itemstack:get_name()] then return end
	local meta = itemstack:get_meta()

	local piece_overlay = overlay
	local inv_overlay = ""
	local piece_type = def._mcl_armor_element

	if piece_type == "head" then --helmet
		inv_overlay = "^(helmet_trim.png"
		piece_overlay = piece_overlay .. "_helmet"
	elseif piece_type == "torso" then --chestplate
		inv_overlay = "^(chestplate_trim.png"
		piece_overlay = piece_overlay .. "_chestplate"
	elseif piece_type == "legs" then --leggings
		inv_overlay = "^(leggings_trim.png"
		piece_overlay = piece_overlay .. "_leggings"
	elseif piece_type == "feet" then --boots
		inv_overlay = "^(boots_trim.png"
		piece_overlay = piece_overlay .. "_boots"
	end
	local color = mcl_armor.trims.colors[color_string]
	inv_overlay = inv_overlay .. "^[colorize:" .. color .. ":150)"
	piece_overlay = piece_overlay .. ".png"

	piece_overlay = "^(" .. piece_overlay .. "^[colorize:" .. color .. ":150)"

	meta:set_string("mcl_armor:trim_overlay" , piece_overlay) -- set textures to render on the player, will work for clients below 5.8 as well
	meta:set_string("mcl_armor:inv", inv_overlay) -- make 5.8+ clients display the fancy inv image, older ones will see no change in the *inventory* image
	meta:set_string("inventory_image", def.inventory_image .. inv_overlay) -- dont use reload_inv_image as it's a one liner in this enviorment
end

function mcl_armor.reload_trim_inv_image(itemstack)
	local meta = itemstack:get_meta()
	local inv_overlay = meta:get_string("mcl_armor:inv")
	local def = itemstack:get_definition()
	if inv_overlay == "" then return end
	meta:set_string("inventory_image", def.inventory_image .. inv_overlay)
end

tt.register_snippet(function(itemstring, toolcaps, stack)
	if not stack then return nil end
	local meta = stack:get_meta()
	if not mcl_armor.is_trimmed(stack) then return nil end
	-- we need to get the part of the overlay image between the overlay begin ( and the trim name end _
	-- we COULD easily store this info in meta, but that would bloat the meta storage, as the same few values would be stored over and over again on every trimmed item
	-- this is fine here as this code gets only executed when you put armor and a trim in a smithing table
	local full_overlay = meta:get_string("mcl_armor:trim_overlay")
	local trim_name = full_overlay:match("%((.-)%_")
	return "Upgrade:\n " .. trim_name:gsub("^%l", string.upper) .. " Armor Trim"
end)

function mcl_armor.is_trimmed(itemstack)
	return itemstack:get_meta():get_string("mcl_armor:trim_overlay") ~= ""
end
