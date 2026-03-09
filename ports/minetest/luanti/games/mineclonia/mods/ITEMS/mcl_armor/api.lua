local S = core.get_translator(core.get_current_modname())

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
		core.sound_play(snd, {object = obj, pos = pos, gain = 0.5, max_hear_distance = dist}, true)
	end
end

local PLAYER_ARMOR_ATTACHMENT = {x=0, y=4, z=0}
local ZERO_VECTOR = {x=0, y=0, z=0}

function mcl_armor.head_entity_equip(obj)
	local luaentity = obj:get_luaentity()
	local entity_name = luaentity and luaentity.name or nil
	local inv, head

	if entity_name == "mcl_armor_stand:armor_entity"
		or obj:is_player() then
		inv = mcl_util.get_inventory(obj, true)
		head = inv:get_stack("armor", 2)
	else
		inv = luaentity.armor_list
		if not inv then return end
		head = ItemStack(inv["head"])
	end

	local def = core.registered_nodes[head:get_name()]
	if def and def._mcl_armor_entity ~= nil then
		local entity = core.add_entity(obj:get_pos(), def._mcl_armor_entity)
		if not entity then return end
		entity:set_properties({is_visible = true})
		if obj:is_player() then
			entity:set_attach(obj, "Head", PLAYER_ARMOR_ATTACHMENT,
					  ZERO_VECTOR)
			mcl_armor.head_entity[obj:get_player_name()] = entity
		else
			local luaentity = obj:get_luaentity ()
			if luaentity and luaentity._head_armor_bone then
				local bone = luaentity._head_armor_bone
				local pos = luaentity._head_armor_position
				local scale = luaentity._head_armor_visual_scale
				local rot = luaentity._head_armor_rotation
				entity:set_attach (obj, bone, pos, rot or ZERO_VECTOR)
				if scale then
					entity:set_properties (obj, {
						visual_size = vector.new (scale * 8.1,
									  scale * 8.1,
									  scale * 8.1),
					})
				end
				mcl_armor.head_entity[obj] = entity
			end
		end
	else
		mcl_armor.head_entity_unequip (obj)
	end
end

function mcl_armor.head_entity_unequip(obj)
	local id = obj:is_player()
		and obj:get_player_name() or obj
	if mcl_armor.head_entity[id] then
		mcl_armor.head_entity[id]:remove()
		mcl_armor.head_entity[id] = nil
	end
end

function mcl_armor.on_equip(itemstack, obj)
	local def = itemstack:get_definition()
	mcl_armor.play_equip_sound(itemstack, obj)
	if def._on_equip then
		def._on_equip(obj, itemstack)
	end
	mcl_armor.head_entity_equip(obj)
	mcl_armor.update(obj)
end

function mcl_armor.on_unequip(itemstack, obj)
	local def = itemstack:get_definition()
	mcl_armor.play_equip_sound(itemstack, obj, nil, true)
	if def._on_unequip then
		def._on_unequip(obj, itemstack)
	end
	mcl_armor.head_entity_unequip(obj)
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

		if mcl_enchanting.has_enchantment(old_stack, "curse_of_binding") then
			return itemstack
		end

		if swap or old_stack:is_empty() then
			local new_stack

			if swap then
				new_stack = itemstack
				itemstack = old_stack
				mcl_armor.on_unequip(old_stack, obj)
			else
				new_stack = itemstack:take_item()
			end

			inv:set_stack("armor", element.index, new_stack)
			mcl_armor.on_equip(new_stack, obj)
		end
	end

	return itemstack
end

function mcl_armor.has_piece(obj, armor_index)
	local inv = mcl_util.get_inventory(obj)

	if not inv or inv:get_size("armor") == 0 then
		return
	end

	return inv:get_stack("armor", armor_index):get_name() ~= ""
end

function mcl_armor.unequip(obj, armor_index)
	local inv = mcl_util.get_inventory(obj)

	if not inv or inv:get_size("armor") == 0 then
		return
	end

	local stack = inv:get_stack("armor", armor_index)

	if stack and stack:get_name() ~= "" then
		inv:set_stack("armor", armor_index, "")
		mcl_armor.on_unequip(stack, obj)
	end

	return stack
end

function mcl_armor.equip_on_use(itemstack, player, pointed_thing)
	if not player or not player:is_player() then
		return itemstack
	end

	local new_stack = mcl_util.call_on_rightclick(itemstack, player, pointed_thing)
	if new_stack then
		return new_stack
	end

	return mcl_armor.equip(itemstack, player, itemstack:get_count() == 1)
end

local function get_armor_texture(textures, name, modname, itemname, itemstring)
	local core_texture = textures[name] or modname .. "_" .. itemname .. ".png"
	if type(core_texture) == "function" then return core_texture end
	mcl_armor.trims.core_textures[itemstring] = core_texture
	local func = function(_, itemstack)
		local meta = itemstack:get_meta()
		local color = meta:get_string("mcl_armor:color")
		local overlay = meta:get_string("mcl_armor:trim_overlay")
		local stack_name = mcl_grindstone.remove_enchant_name(itemstack) -- gets original itemstring if enchanted, no need to store (nearly) identical values

		if core.registered_aliases[stack_name] then
			stack_name = core.registered_aliases[stack_name]
		end

		local core_armor_texture = mcl_armor.trims.core_textures[stack_name]

		if color ~= "" and color ~= nil then
			core_armor_texture = core_armor_texture:gsub("_leather.png$", "_leather_desat.png").."^[multiply:"..color
		end

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
	local modname = core.get_current_modname()
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
		core.log("warning", "[mcl_armor] using the description field of armor set definitions is deprecated, please provide the localized strings in def.descriptions instead. Currently processing " .. def.name)
		local S = core.get_translator(modname)
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

		local on_place = mcl_armor.equip_on_use
		if def.on_place then
			on_place = function(itemstack, placer, pointed_thing)
				if def.on_place then
					local op = def.on_place(itemstack, placer, pointed_thing)
					if op then return op end
				end
				return mcl_armor.equip_on_use(itemstack, placer, pointed_thing)
			end
		end

		core.register_tool(itemstring, {
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
			on_place =  on_place,
			on_secondary_use = mcl_armor.equip_on_use,
			_on_equip = on_equip_callbacks[name] or def.on_equip,
			_on_unequip = on_unequip_callbacks[name] or def.on_unequip,
			_on_break = on_break_callbacks[name] or def.on_break,
			_mcl_armor_element = name,
			_mcl_armor_texture = get_armor_texture(textures, name, modname, itemname, itemstring),
			_mcl_upgradable = def._mcl_upgradable,
			_mcl_upgrade_item = upgrade_item,
			_mcl_cooking_output = def.cook_material
		})

		if def.craft_material then
			core.register_craft({
				output = itemstring,
				recipe = element.craft(def.craft_material),
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

function mcl_armor.elytra_usable (elytra)
	local durability = mcl_util.calculate_durability (elytra)
	local remaining = math.floor ((65536 - elytra:get_wear ())
					* durability / 65536)
	return remaining > 1
end

function mcl_armor.disable_elytra (elytra)
	local meta = elytra:get_meta ()
	if elytra:get_name () == "mcl_armor:elytra_enchanted" then
		local img = "mcl_armor_broken_elytra.png" .. mcl_enchanting.overlay
		meta:set_string ("inventory_image", img)
	else
		meta:set_string ("inventory_image", "mcl_armor_broken_elytra.png")
	end
end

function mcl_armor.reenable_elytra (elytra)
	if mcl_armor.elytra_usable (elytra) then
		local meta = elytra:get_meta ()
		if elytra:get_name () == "mcl_armor:elytra_enchanted" then
			local img = "mcl_armor_inv_elytra.png" .. mcl_enchanting.overlay
			meta:set_string ("inventory_image", img)
		else
			meta:set_string ("inventory_image", "mcl_armor_inv_elytra.png")
		end
	end
end

function mcl_armor.update(obj)
	local info = {
		points = 0,
		view_range_factors = {},
		elytra_present = false,
		depth_strider_level = 0,
		soul_speed_level = 0,
	}
	local resp_lv = 0

	local inv = mcl_util.get_inventory(obj)

	if inv then
		for i = 2, 5 do
			local itemstack = inv:get_stack("armor", i)

			local itemname = itemstack:get_name()
			if core.registered_aliases[itemname] then
				itemname = core.registered_aliases[itemname]
			end

			if not itemstack:is_empty() then
				if core.get_item_group (itemname, "elytra") > 0
					and mcl_armor.elytra_usable (itemstack) then
					info.elytra_present = true
				end
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

				info.points = info.points + core.get_item_group(itemname, "mcl_armor_points")

				if i == 2 then -- Head Armor; view range code assumes single piece
					resp_lv = mcl_enchanting.get_enchantments(itemstack).respiration or resp_lv

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
				if i == 5 then
					info.depth_strider_level
						= mcl_enchanting.get_enchantment (itemstack, "depth_strider")
					info.soul_speed_level
						= mcl_enchanting.get_enchantment (itemstack, "soul_speed")
				end
			end
		end
	end

	info.texture = info.texture or "blank.png"

	if obj:is_player() then
		mcl_enchanting.update_respiration(obj, resp_lv)
		mcl_armor.update_player(obj, info)
	else
		local luaentity = obj:get_luaentity()

		if luaentity.update_armor then
			luaentity:update_armor(info)
		end
	end
end

function mcl_armor.trim(itemstack, overlay, trim_material)
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
	local color = trim_material:get_definition()._mcl_armor_trim_color

	inv_overlay = inv_overlay .. "^[colorize:" .. color .. ":150)"
	piece_overlay = piece_overlay .. ".png"

	piece_overlay = "^(" .. piece_overlay .. "^[colorize:" .. color .. ":150)"

	meta:set_string("mcl_armor:trim_overlay" , piece_overlay) -- set textures to render on the player, will work for clients below 5.8 as well
	meta:set_string("mcl_armor:trim_material", trim_material:get_name())
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

tt.register_snippet(function(_, _, stack)
	if not stack then return nil end
	local meta = stack:get_meta()
	if not mcl_armor.is_trimmed(stack) then return nil end
	-- we need to get the part of the overlay image between the overlay begin ( and the trim name end _
	-- we COULD easily store this info in meta, but that would bloat the meta storage, as the same few values would be stored over and over again on every trimmed item
	-- this is fine here as this code gets only executed when you put armor and a trim in a smithing table
	local overlay = meta:get_string("mcl_armor:trim_overlay"):match("%((.-)%_")
	local template_desc = core.strip_colors(ItemStack("mcl_armor:" .. overlay):get_short_description())
	local trim_material = meta:get_string("mcl_armor:trim_material")
	local upgrade = S("Upgrade:") .. "\n "

	if trim_material == "" then
		return upgrade .. template_desc
	end

	local trim_mat_color = core.registered_items[trim_material]._mcl_armor_trim_color
	local trim_mat_desc = core.registered_items[trim_material]._mcl_armor_trim_desc

	return upgrade .. core.colorize(trim_mat_color, template_desc) .. "\n " ..
	core.colorize(trim_mat_color, trim_mat_desc)
end)

function mcl_armor.is_trimmed(itemstack)
	return itemstack:get_meta():get_string("mcl_armor:trim_overlay") ~= ""
end

function mcl_armor.get_armor_coverage (object)
	local entity = object:get_luaentity ()
	local factor
	if entity and entity.is_mob then
		if not entity.armor_list then
			return 0
		end
		local npieces = 0
		for _, item in pairs (entity.armor_list) do
			if item ~= "" then
				npieces = npieces + 1
			end
		end
		factor = npieces / 4
	else
		local npieces = 0
		local inv = mcl_util.get_inventory (object, true)

		if not inv then
			return 0
		end

		for _, desc in pairs (mcl_armor.elements) do
			if inv and not inv:get_stack ("armor", desc.index):is_empty () then
				npieces = npieces + 1
			end
		end
		factor = npieces / 4
	end
	return factor
end

function mcl_armor.get_headpiece_factor (object, mob_name)
	if object:is_player () then
		local factors = mcl_armor.player_view_range_factors[object]
		return (factors and factors[mob_name]) or 1.0
	end

	local luaentity = object:get_luaentity ()

	if luaentity
		and luaentity.is_mob
		and luaentity.armor_list
		and luaentity.armor_list.head
		and luaentity.armor_list.head ~= "" then
		local stack = ItemStack (luaentity.armor_list.head)
		local def = stack:get_definition ()
		if def and mob_name == def._mcl_armor_mob_range_factor
			and def._mcl_armor_mob_range_factor then
			return def._mcl_armor_mob_range_factor
		end
	end
	return 1.0
end
