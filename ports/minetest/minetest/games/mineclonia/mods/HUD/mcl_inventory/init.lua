mcl_inventory = {}
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/creative.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/survival.lua")

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
			local obj = minetest.add_item(p, itemstack)
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
		minetest.add_item(pos, itemstack)
	end
	return itemstack
end

---Return items in the given inventory list (name) to the main inventory, or drop them if there is no space left.
local function return_fields(player, name)
	local inv = player:get_inventory()

	local list = inv:get_list(name)
	if not list then return end
	for i, stack in ipairs(list) do
		return_item(stack, player, player:get_pos(), inv)
		stack:clear()
		inv:set_stack(name, i, stack)
	end
end

local function set_inventory(player, armor_change_only)
	if minetest.is_creative_enabled(player:get_player_name()) then
		if armor_change_only then
			-- Stay on survival inventory plage if only the armor has been changed
			mcl_inventory.set_creative_formspec(player, 0, 0, nil, nil, "inv")
		else
			mcl_inventory.set_creative_formspec(player, 0, 1)
		end
		return
	end

	player:set_inventory_formspec(mcl_inventory.build_survival_formspec(player))
end

function mcl_inventory.get_recipe_groups(pinv, craft)
	local grid_width = pinv:get_width("craft")
	if craft.width > grid_width or pinv:get_size("craft") < table.count(craft.items, function(_,v) return not ItemStack(v):is_empty()  end) then
		return false
	end
	local r = { "", "", "", "", "", "", "", "", "" }
	local all_found = true
	local i = 0
	for k = 1, pinv:get_size("craft") do
		local it = craft.items[k]
		if it then
			if it:sub(1,6) == "group:" then
				for _, stack in pairs(pinv:get_list("main")) do
					if minetest.get_item_group(stack:get_name(), it:sub(7)) > 0 then
						r[k+i] = stack:get_name()
					end
				end
				all_found = all_found and r[k+i]
			elseif pinv:contains_item("main", ItemStack(it)) then
				r[k+i] = it
			else
				all_found = false
			end
		end
		-- adapt from craft width to craft grid width
		if (k % craft.width) == 0 then
			i = i + grid_width - craft.width
		end
	end
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
		local recipe = mcl_inventory.get_recipe_groups(pinv, craft)
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
	for idx, stack in pairs(inv:get_list("craft")) do
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
			it:set_count(math.min(tstack:get_stack_max() - tstack:get_count(), math.floor(invcounts[name] / itcounts[name] or 1)))
			tstack:add_item(inv:remove_item("main", it))
			inv:set_stack("craft", idx, tstack)
		end
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.__mcl_crafting_fillgrid then
		mcl_inventory.fill_grid(player)
	end
end)

-- Drop items in craft grid and reset inventory on closing
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.quit then
		return_fields(player, "craft")
		return_fields(player, "enchanting_lapis")
		return_fields(player, "enchanting_item")
		if not minetest.is_creative_enabled(player:get_player_name()) and (formname == "" or formname == "main") then
			set_inventory(player)
		end
	end
end)

function mcl_inventory.reset_craft_grid(player)
	local inv = player:get_inventory()
	if inv and inv:get_size("craft") > 4 and not mcl_crafting_table.has_crafting_table(player) then
		return_fields(player, "craft")
		inv:set_width("craft", 2)
		inv:set_size("craft", 4)
	end
end

minetest.register_craft_predict(function(itemstack, player, old_craft_grid, inv)
	mcl_inventory.reset_craft_grid(player)
end)

function mcl_inventory.update_inventory_formspec(player)
	set_inventory(player)
end

-- Drop crafting grid items on leaving
minetest.register_on_leaveplayer(function(player)
	return_fields(player, "craft")
	return_fields(player, "enchanting_lapis")
	return_fields(player, "enchanting_item")
end)

minetest.register_on_joinplayer(function(player)
	--init inventory
	local inv = player:get_inventory()

	inv:set_width("main", 9)
	inv:set_size("main", 36)
	inv:set_size("offhand", 1)
	inv:set_size("sorter", 1)
	inv:set_stack("sorter", 1, ItemStack(""))

	--set hotbar size
	player:hud_set_hotbar_itemcount(9)
	--add hotbar images
	player:hud_set_hotbar_image("mcl_inventory_hotbar.png")
	player:hud_set_hotbar_selected_image("mcl_inventory_hotbar_selected.png")

	-- In Creative Mode, the initial inventory setup is handled in creative.lua
	if not minetest.is_creative_enabled(player:get_player_name()) then
		set_inventory(player)
	end

	--[[ Make sure the crafting grid is empty. Why? Because the player might have
	items remaining in the crafting grid from the previous join; this is likely
	when the server has been shutdown and the server didn't clean up the player
	inventories. ]]
	return_fields(player, "craft")
	return_fields(player, "enchanting_item")
	return_fields(player, "enchanting_lapis")
end)

function mcl_inventory.update_inventory(player)
	local player_gamemode = player:get_meta():get_string("gamemode")
	if player_gamemode == "" then player_gamemode = "survival" end

	if player_gamemode == "creative" then
		mcl_inventory.set_creative_formspec(player)
	elseif player_gamemode == "survival" then
		player:set_inventory_formspec(mcl_inventory.build_survival_formspec(player))
	end
	mcl_meshhand.update_player(player)
end

mcl_player.register_on_visual_change(mcl_inventory.update_inventory_formspec)

mcl_gamemode.register_on_gamemode_change(function(p, old_gm, gm)
	set_inventory(p)
end)
