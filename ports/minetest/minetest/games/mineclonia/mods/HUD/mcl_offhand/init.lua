mcl_offhand = {}

local max_offhand_px = 128
-- only supports up to 128px textures

function mcl_offhand.get_offhand(player)
	return player:get_inventory():get_stack("offhand", 1)
end

function mcl_offhand.set_offhand(player, itemstack)
	return player:get_inventory():set_stack("offhand", 1, itemstack)
end

function mcl_offhand.place(placer, pointed_thing)
	local offhand = mcl_offhand.get_offhand(placer)
	if offhand and core.get_item_group(offhand:get_name(), "offhand_placeable") ~= 0 and pointed_thing.above then
		local new_stack
		local odef = offhand:get_definition()
		if odef.on_place then
			new_stack = odef.on_place(offhand, placer,pointed_thing)
		else
			new_stack = core.item_place_node(offhand, placer, pointed_thing)
		end
		if not new_stack then
			offhand:set_count(offhand:get_count() - 1)
		else
			mcl_offhand.set_offhand(placer, new_stack)
		end
		return true
	end

	return false
end

local old_hand_op = core.registered_items[""].on_place
core.override_item("", {
	on_place = function(itemstack, placer, pointed_thing)
		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end
		if not mcl_offhand.place(placer, pointed_thing) and old_hand_op then
			return old_hand_op(itemstack, placer, pointed_thing)
		end
	end
})

local function offhand_get_wear(player)
	return mcl_offhand.get_offhand(player):get_wear()
end

local function offhand_get_count(player)
	return mcl_offhand.get_offhand(player):get_count()
end

local function remove_hud(player, hud)
	local offhand_hud = mcl_offhand[player].hud[hud]
	if offhand_hud then
		player:hud_remove(offhand_hud)
		mcl_offhand[player].hud[hud] = nil
	end
end

local function rgb_to_hex(r, g, b)
	return string.format("%02x%02x%02x", r, g, b)
end

local function update_wear_bar(player, itemstack)
	local wear_bar_percent = (65535 - offhand_get_wear(player)) / 65535

	local color
	local wear = itemstack:get_wear() / 65535;
	local wear_i = math.min(math.floor(wear * 600), 511);
	wear_i = math.min(wear_i + 10, 511);
	if wear_i <= 255 then
		color = {wear_i, 255, 0}
	else
		color = {255, 511 - wear_i, 0}
	end
	local wear_bar = mcl_offhand[player].hud.wear_bar
	player:hud_change(wear_bar, "text", "mcl_wear_bar.png^[colorize:#" .. rgb_to_hex(color[1], color[2], color[3]))
	player:hud_change(wear_bar, "scale", {x = 40 * wear_bar_percent, y = 3})
	player:hud_change(wear_bar, "offset", {x = -320 - (20 - player:hud_get(wear_bar).scale.x / 2), y = -13})
end

mcl_player.register_globalstep(function(player)
	if not mcl_offhand[player] then
		mcl_offhand[player] = {
			hud = {},
			last_wear = offhand_get_wear(player),
			last_count = offhand_get_count(player),
		}
	end

	local itemstack = mcl_offhand.get_offhand(player)
	local offhand_item = itemstack:get_name()
	local offhand = mcl_offhand[player]
	local offhand_hud = offhand.hud
	local item = core.registered_items[offhand_item]
	if offhand_item ~= "" and item then
		local meta_texture = itemstack:get_meta():get_string("inventory_overlay")
		if not meta_texture or meta_texture == "" then meta_texture = item.inventory_image end
		local item_texture = meta_texture .. "^[resize:" .. max_offhand_px .. "x" .. max_offhand_px
		local position = {x = 0.5, y = 1}
		local offset = {x = -320, y = -32}

		if not offhand_hud.slot then
			offhand_hud.slot = player:hud_add({
				type = "image",
				position = position,
				offset = offset,
				scale = {x = 0.46875, y = 0.46875},
				text = "mcl_offhand_slot.png" .. "^[resize:" .. max_offhand_px .. "x" .. max_offhand_px,
				z_index = 0,
			})
		end
		if not offhand_hud.item then
			offhand_hud.item = player:hud_add({
				type = "image",
				position = position,
				offset = offset,
				scale = {x = 0.375, y = 0.375},
				text = item_texture,
				z_index = 1,
			})
		else
			local item_hud = player:hud_get(offhand_hud.item)
			if item_hud and item_hud.text ~= item_texture then
				player:hud_change(offhand_hud.item, "text", item_texture)
			elseif not item_hud then
				offhand_hud.item = nil
			end
		end
		if not offhand_hud.wear_bar_bg and core.registered_tools[offhand_item] then
			if offhand_get_wear(player) > 0 then
				local texture = "mcl_wear_bar.png^[colorize:#000000"
				offhand_hud.wear_bar_bg = player:hud_add({
					type = "image",
					position = {x = 0.5, y = 1},
					offset = {x = -320, y = -13},
					scale = {x = 40, y = 3},
					text = texture,
					z_index = 2,
				})
				offhand_hud.wear_bar = player:hud_add({
					type = "image",
					position = {x = 0.5, y = 1},
					offset = {x = -320, y = -13},
					scale = {x = 10, y = 3},
					text = texture,
					z_index = 3,
				})
				update_wear_bar(player, itemstack)
			end
		end

		if not offhand_hud.item_count and offhand_get_count(player) > 1 then
			offhand_hud.item_count = player:hud_add({
				type = "text",
				position = {x = 0.5, y = 1},
				offset = {x = -298, y = -18},
				scale = {x = 1, y = 1},
				alignment = {x = -1, y = 0},
				text = offhand_get_count(player),
				z_index = 4,
				number = 0xFFFFFF,
			})
		end

		if offhand_hud.wear_bar then
			if offhand.last_wear ~= offhand_get_wear(player) then
				update_wear_bar(player, itemstack)
				offhand.last_wear = offhand_get_wear(player)
			end
			if offhand_get_wear(player) <= 0 or not core.registered_tools[offhand_item] then
				remove_hud(player, "wear_bar_bg")
				remove_hud(player, "wear_bar")
			end
		end

		if offhand_hud.item_count then
			if offhand.last_count ~= offhand_get_count(player) then
				player:hud_change(offhand_hud.item_count, "text", offhand_get_count(player))
				offhand.last_count = offhand_get_count(player)
			end
			if offhand_get_count(player) <= 1 then
				remove_hud(player, "item_count")
			end
		end

	elseif offhand_hud.slot then
		for index, _ in pairs(mcl_offhand[player].hud) do
			remove_hud(player, index)
		end
	end
end)

core.register_allow_player_inventory_action(function(_, action, inventory, inventory_info)
	if action == "move" and inventory_info.to_list == "offhand" then
		local itemstack = inventory:get_stack(inventory_info.from_list, inventory_info.from_index)
		if core.get_item_group(itemstack:get_name(), "offhand_item") <= 0  then
			return 0
		else
			return itemstack:get_stack_max()
		end
	end
end)

core.register_on_player_inventory_action(function(player, action, _, inventory_info)
	local from_offhand = inventory_info.from_list == "offhand"
	local to_offhand = inventory_info.to_list == "offhand"
	if action == "move" and from_offhand or to_offhand then
		mcl_inventory.update_inventory_formspec(player)
	end
end)
