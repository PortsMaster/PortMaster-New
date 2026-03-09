mcl_inventory = {}

local modname = core.get_current_modname()
local path = core.get_modpath(modname)
local S = core.get_translator(modname)

dofile(path .. "/creative.lua")
dofile(path .. "/survival.lua")

---Returns a single itemstack in the given inventory to the main inventory, or drop it when there's no space left.
local function return_item(itemstack, dropper, pos, inv)
	if dropper:is_player() then
		-- Return to main inventory
		if inv:room_for_item("main", itemstack) then
			inv:add_item("main", itemstack)
		else
			-- Drop item on the ground
			local v = dropper:get_look_dir()
			local p = vector.offset(pos, 0, 1.2, 0)
			p.x = p.x + (math.random(1, 3) * 0.2)
			p.z = p.z + (math.random(1, 3) * 0.2)
			local obj = core.add_item(p, itemstack)
			if obj then
				v.x = v.x * 4
				v.y = v.y * 4 + 2
				v.z = v.z * 4
				obj:set_velocity(v)
				obj:get_luaentity()._insta_collect = false
			end
		end
	else
		-- Fallback for unexpected cases
		core.add_item(pos, itemstack)
	end
	return itemstack
end

---Return items in the given inventory list (name) to the main inventory, or drop them if there is no space left.
local function return_fields(player, name)
	if not player or not player:get_pos() then return end -- make sure player is still there
	local inv = player:get_inventory()

	local list = inv:get_list(name)
	if not list then return end
	for i, stack in ipairs(list) do
		return_item(stack, player, player:get_pos(), inv)
		stack:clear()
		inv:set_stack(name, i, stack)
	end
end

local function return_fields_from_temp_player_inventories(player)
	return_fields(player, "craft")
	return_fields(player, "enchanting_lapis")
	return_fields(player, "enchanting_item")
end

local function set_inventory(player)
	if core.is_creative_enabled(player:get_player_name()) then
		mcl_inventory.set_creative_formspec(player)
		return
	end

	local formspec = mcl_inventory.build_survival_formspec (player)
	mcl_player.set_inventory_formspec (player, formspec, 0)
end

function mcl_inventory.get_recipe_groups(player, craft, optional_width, optional_height)
	return_fields(player, "craft")
	local pinv = player:get_inventory()
	local grid_width = optional_width or pinv:get_width("craft")
	local grid_height = optional_height or math.ceil(pinv:get_size("craft") / grid_width)
	local craft_size = table.max_index(craft.items)
	local craft_width = craft.width
	if craft_width == 0 then
		craft_width = craft_size <= 4 and 2 or 3
	end

	if craft_width > grid_width or math.ceil(craft_size / craft_width) > grid_height then
		return false
	end
	local list = "_mcl_inventory_recipe_groups"
	pinv:set_size(list, pinv:get_size("main"))
	pinv:set_list(list, pinv:get_list("main"))
	local r = {}
	local all_found = true
	local i = 0
	for k = 1, craft_size do
		local it = craft.items[k]
		local ki = k+i
		if it then
			if it:sub(1,6) == "group:" then
				local group = it:sub(7)
				for index, stack in pairs(pinv:get_list(list)) do
					local name = stack:get_name()
					if core.get_item_group(name, group) > 0 then
						r[ki] = name
						stack:take_item(1)
						pinv:set_stack(list, index, stack)
					end
				end
				if not r[ki] then
					all_found = false
					break
				end
			elseif pinv:contains_item(list, ItemStack(it)) then
				r[ki] = it
				pinv:remove_item(list, ItemStack(it))
			else
				all_found = false
				break
			end
		else
			r[ki] = ""
		end
		-- adapt from craft width to craft grid width
		if (k % craft_width) == 0 then
			for _ = 1, grid_width - craft_width do
				i = i + 1
				r[k+i] = ""
			end
		end
	end
	pinv:set_size(list, 0)
	if all_found then
		return r
	else
		return false
	end
end

local function get_count_from_inv(itname, inv, list)
	list = list or "main"
	local c = 0
	for _, stack in pairs(inv:get_list(list)) do
		if stack:get_name() == itname then
			c = c + stack:get_count()
		end
	end
	return c
end

function mcl_inventory.to_craft_grid(player, craft)
	return_fields(player, "craft")
	local pinv = player:get_inventory()
	if craft.type == "normal" then
		local recipe = mcl_inventory.get_recipe_groups(player, craft)
		if recipe then
			for k,it in pairs(recipe) do
				local pit = ItemStack(it)
				if pinv:room_for_item("craft", pit) then
					local stack = pinv:remove_item("main", pit)
					pinv:set_stack("craft", k, stack)
				end
			end
		end
	end
end

function mcl_inventory.fill_grid(player)
	local inv = player:get_inventory()
	local itcounts = {}
	local invcounts = {}
	for _, stack in pairs(inv:get_list("craft")) do
		local name = stack:get_name()
		if name ~= "" then
			itcounts[name] = (itcounts[name] or 0) + 1
			invcounts[name] = get_count_from_inv(name, inv)
		end
	end
	for idx, tstack in pairs(inv:get_list("craft")) do
		local name = tstack:get_name()
		if itcounts[name] and invcounts[name] then
			local it = ItemStack(name)
			it:set_count(math.min(tstack:get_stack_max() - tstack:get_count(), math.floor(invcounts[name] / (itcounts[name] or 1))))
			tstack:add_item(inv:remove_item("main", it))
			inv:set_stack("craft", idx, tstack)
		end
	end
end

function mcl_inventory.show_inventory(player)
	core.show_formspec(player:get_player_name(), "", player:get_inventory_formspec())
end

mcl_player.register_player_settings_button({
	field = "__mcl_inventory",
	icon = "crafting_creative_prev.png",
	description = S("Return to player inventory"),
	priority = math.huge, -- first
})

core.register_on_player_receive_fields(function(player, _, fields)
	if fields.__mcl_crafting_fillgrid then
		mcl_inventory.fill_grid(player)
	elseif fields.__mcl_inventory then
		mcl_inventory.show_inventory(player)
		return false
	elseif fields.quit then
		-- Drop items from special player inventories on formspec closing
		return_fields_from_temp_player_inventories(player)
	end
end)

core.register_craft_predict(function(itemstack, player, old_craft_grid, inv) ---@diagnostic disable-line: unused-local
	if not player or not player:get_pos() then return end -- can apparently be called when player has already left !?
	if inv and inv:get_size("craft") > 4 and not mcl_crafting_table.has_crafting_table(player) then
		return_fields(player, "craft")
		core.chat_send_player(player:get_player_name(), S("Crafting table out of range!"))
	end
end)

function mcl_inventory.update_inventory_formspec(player)
	set_inventory(player)
end

-- Drop crafting grid items on leaving
core.register_on_leaveplayer(function(player)
	return_fields_from_temp_player_inventories(player)
end)

core.register_on_joinplayer(function(player)
	-- Make sure the player's temporary inv lists are empty. Why? Because
	-- the player might have items remaining from the previous join; this is
	-- likely when the server has been shutdown and the server didn't clean
	-- up the player inventories.
	return_fields_from_temp_player_inventories(player)

	--init inventory
	local inv = player:get_inventory()

	inv:set_width("main", 9)
	inv:set_size("main", 36)
	inv:set_width("craft", 2)
	inv:set_size("craft", 4)
	inv:set_size("offhand", 1)
	inv:set_size("sorter", 1)
	inv:set_stack("sorter", 1, ItemStack(""))

	--set hotbar size
	player:hud_set_hotbar_itemcount(9)
	--add hotbar images
	player:hud_set_hotbar_image("mcl_inventory_hotbar.png")
	player:hud_set_hotbar_selected_image("mcl_inventory_hotbar_selected.png")

	--build survival inventory formspec (this is handled in creative.lua for creative mode)
	if not core.is_creative_enabled(player:get_player_name()) then
		set_inventory(player)
	end

end)

function mcl_inventory.update_inventory(player)
	local player_gamemode = player:get_meta():get_string("gamemode")
	if player_gamemode == "" then player_gamemode = "survival" end

	if player_gamemode == "creative" then
		mcl_inventory.set_creative_formspec(player)
	elseif player_gamemode == "survival" then
		local formspec = mcl_inventory.build_survival_formspec (player)
		mcl_player.set_inventory_formspec (player, formspec, 0)
	end
	mcl_meshhand.update_player(player)
end

mcl_player.register_on_visual_change(mcl_inventory.update_inventory_formspec)

mcl_gamemode.register_on_gamemode_change(function(p, old_gm, gm) ---@diagnostic disable-line: unused-local
	set_inventory(p)
end)

-- Handles replacing the item wielded in an interaction with another item
--
-- Replaces the wielded stack with the reward stack if the wielded stack is
-- empty after the interaction, and otherwise tries to add the reward stack into
-- the player's inventory and drops it at the player's position if there is no
-- room.
--
-- Creative behavior specifies how to handle creative mode for this interaction:
-- "nothing": neither give nor take any items
-- "give": don't take item from wielded stack, but give reward
-- "give_new": like "give", but only give reward, if it isn't already in player's inventory (default)
-- "both": give and take item like in non creative mode

function mcl_inventory.give_and_take(player, wield_stack, reward_stack, creative_behavior)
	if not player then return nil end
	local creative = core.is_creative_enabled(player:get_player_name())
	creative_behavior = creative_behavior or "give_new"
	if creative and creative_behavior == "nothing" then
		return wield_stack
	end
	if not creative or creative_behavior == "both" then
		wield_stack:take_item()
	end
	local inv = player:get_inventory()
	local contains = inv:contains_item("main", reward_stack, true)
	if not creative or creative_behavior ~= "give_new" or not contains then
		if wield_stack:is_empty() then
			return reward_stack
		elseif inv:room_for_item("main", reward_stack) then
			inv:add_item("main", reward_stack)
			return wield_stack
		else
			core.add_item(player:get_pos(), reward_stack)
			return wield_stack
		end
	end
end
