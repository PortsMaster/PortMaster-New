mcl_player.player_register_model("mcl_armor_character.b3d", {
	animation_speed = 30,
	textures = {
		"character.png",
		"blank.png",
		"blank.png",
	},
	animations = {
		stand = {x=0, y=79},
		lay = {x=162, y=166},
		walk = {x=168, y=187},
		mine = {x=189, y=198},
		walk_mine = {x=200, y=219},
		sit = {x=81, y=160},
		sneak_stand = {x=222, y=302},
		sneak_mine = {x=346, y=365},
		sneak_walk = {x=304, y=323},
		sneak_walk_mine = {x=325, y=344},
		swim_walk = {x=368, y=387},
		swim_walk_mine = {x=389, y=408},
		swim_stand = {x=434, y=434},
		swim_mine = {x=411, y=430},
		run_walk	= {x=440, y=459},
		run_walk_mine	= {x=461, y=480},
		sit_mount	= {x=484, y=484},
		die	= {x=498, y=498},
		fly = {x=502, y=581},
		bow_walk = {x=650, y=670},
		bow_sneak = {x=675, y=695},
	},
})

mcl_player.player_register_model("mcl_armor_character_female.b3d", {
	animation_speed = 30,
	textures = {
		"character.png",
		"blank.png",
		"blank.png",
	},
	animations = {
		stand = {x=0, y=79},
		lay = {x=162, y=166},
		walk = {x=168, y=187},
		mine = {x=189, y=198},
		walk_mine = {x=200, y=219},
		sit = {x=81, y=160},
		sneak_stand = {x=222, y=302},
		sneak_mine = {x=346, y=365},
		sneak_walk = {x=304, y=323},
		sneak_walk_mine = {x=325, y=344},
		swim_walk = {x=368, y=387},
		swim_walk_mine = {x=389, y=408},
		swim_stand = {x=434, y=434},
		swim_mine = {x=411, y=430},
		run_walk	= {x=440, y=459},
		run_walk_mine	= {x=461, y=480},
		sit_mount	= {x=484, y=484},
		die	= {x=498, y=498},
		fly = {x=502, y=581},
		bow_walk = {x=650, y=670},
		bow_sneak = {x=675, y=695},
	},
})

function mcl_armor.update_player(player, info)
	mcl_player.player_set_armor(player, info.texture)

	local meta = player:get_meta()
	meta:set_int("mcl_armor:armor_points", info.points)

	mcl_armor.player_view_range_factors[player] = info.view_range_factors
end

local function is_armor_action(inventory_info)
	return inventory_info.from_list == "armor" or inventory_info.to_list == "armor" or inventory_info.listname == "armor"
end

local function limit_put(player, inventory, index, stack, count)
	local def = stack:get_definition()

	if not def then
		return 0
	end

	local element = def._mcl_armor_element

	if not element then
		return 0
	end

	local element_index = mcl_armor.elements[element].index

	if index ~= 1 and index ~= element_index then
		return 0
	end

	local old_stack = inventory:get_stack("armor", element_index)

	if old_stack:is_empty() or index ~= 1 and old_stack:get_name() ~= stack:get_name() and count <= 1 then
		return count
	else
		return 0
	end
end

local function limit_take(player, inventory, index, stack, count)
	if mcl_enchanting.has_enchantment(stack, "curse_of_binding") and not minetest.is_creative_enabled(player:get_player_name()) then
		return 0
	end

	return count
end

minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
	if not is_armor_action(inventory_info) then
		return
	end

	if action == "put" then
		return limit_put(player, inventory, inventory_info.index, inventory_info.stack, inventory_info.stack:get_count())
	elseif action == "take" then
		return limit_take(player, inventory, inventory_info.index, inventory_info.stack, inventory_info.stack:get_count())
	else
		if inventory_info.from_list ~= "armor" then
			return limit_put(player, inventory, inventory_info.to_index, inventory:get_stack(inventory_info.from_list, inventory_info.from_index), inventory_info.count)
		elseif inventory_info.to_list ~= "armor" then
			return limit_take(player, inventory, inventory_info.from_index, inventory:get_stack(inventory_info.from_list, inventory_info.from_index), inventory_info.count)
		else
			return 0
		end
	end
end)

local function on_put(player, inventory, index, stack)
	if index == 1 then
		mcl_armor.equip(stack, player)
		inventory:set_stack("armor", 1, nil)
	else
		mcl_armor.on_equip(stack, player)
	end
end

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	if is_armor_action(inventory_info) then
		if action == "put" then
			on_put(player, inventory, inventory_info.index, inventory_info.stack)
		elseif action == "take" then
			mcl_armor.on_unequip(inventory_info.stack, player)
		else
			local stack = inventory:get_stack(inventory_info.to_list, inventory_info.to_index)
			if inventory_info.to_list == "armor" then
				on_put(player, inventory, inventory_info.to_index, stack)
			elseif inventory_info.from_list == "armor" then
				mcl_armor.on_unequip(stack, player)
			end
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	player:get_inventory():set_size("armor", 5)
	if not minetest.global_exists("mcl_skins") then
		mcl_player.player_set_model(player, "mcl_armor_character.b3d")
	end

	minetest.after(1, function()
		if player:is_player() then
			mcl_armor.update(player)
		end
	end)
end)

minetest.register_on_leaveplayer(function(player)
	mcl_armor.player_view_range_factors[player] = nil
end)
