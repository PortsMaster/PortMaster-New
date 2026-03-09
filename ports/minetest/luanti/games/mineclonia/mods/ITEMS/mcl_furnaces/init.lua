mcl_furnaces = {}
local modname = core.get_current_modname()
local S = core.get_translator(modname)
local C = core.colorize
local F = core.formspec_escape

local LIGHT_ACTIVE_FURNACE = 13

--
-- Formspecs
--

local function get_active_formspec(fuel_percent, item_percent, name)
	return table.concat({
		"formspec_version[4]",
		"size[11.75,10.425]",
		"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, name)) .. "]",
		mcl_formspec.get_itemslot_bg_v4(3.5, 0.75, 1, 1),
		"list[context;src;3.5,0.75;1,1;]",

		"image[3.5,2;1,1;default_furnace_fire_bg.png^[lowpart:" ..
		(100 - fuel_percent) .. ":default_furnace_fire_fg.png]",

		mcl_formspec.get_itemslot_bg_v4(3.5, 3.25, 1, 1),
		"list[context;fuel;3.5,3.25;1,1;]",

		"image[5.25,2;1.5,1;gui_furnace_arrow_bg.png^[lowpart:" ..
		(item_percent) .. ":gui_furnace_arrow_fg.png^[transformR270]",
		mcl_formspec.get_itemslot_bg_v4(7.875, 2, 1, 1, 0.2),
		"list[context;dst;7.875,2;1,1;]",

		"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",
		mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
		"list[current_player;main;0.375,5.1;9,3;9]",

		mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
		"list[current_player;main;0.375,9.05;9,1;]",

		"image_button[7.85,0.6;1,1;craftguide_book.png;craftguide;]"..
		"tooltip[craftguide;"..core.formspec_escape(S("Recipe book")).."]"..

		"listring[context;dst]",
		"listring[current_player;main]",
		"listring[context;sorter]",
		"listring[current_player;main]",
		"listring[context;src]",
		"listring[current_player;main]",
		"listring[context;fuel]",
		"listring[current_player;main]",
	})
end

local function get_inactive_formspec(name)
	return table.concat({
		"formspec_version[4]",
		"size[11.75,10.425]",
		"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, name)) .. "]",
		mcl_formspec.get_itemslot_bg_v4(3.5, 0.75, 1, 1),
		"list[context;src;3.5,0.75;1,1;]",

		"image[3.5,2;1,1;default_furnace_fire_bg.png]",

		mcl_formspec.get_itemslot_bg_v4(3.5, 3.25, 1, 1),
		"list[context;fuel;3.5,3.25;1,1;]",

		"image[5.25,2;1.5,1;gui_furnace_arrow_bg.png^[transformR270]",

		mcl_formspec.get_itemslot_bg_v4(7.875, 2, 1, 1, 0.2),
		"list[context;dst;7.875,2;1,1;]",

		"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",
		mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
		"list[current_player;main;0.375,5.1;9,3;9]",

		mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
		"list[current_player;main;0.375,9.05;9,1;]",

		"image_button[7.85,0.6;1,1;craftguide_book.png;craftguide;]"..
		"tooltip[craftguide;"..core.formspec_escape(S("Recipe book")).."]"..

		"listring[context;dst]",
		"listring[current_player;main]",
		"listring[context;sorter]",
		"listring[current_player;main]",
		"listring[context;src]",
		"listring[current_player;main]",
		"listring[context;fuel]",
		"listring[current_player;main]",
	})
end


function mcl_furnaces.receive_fields(_, _, fields, sender)
	if fields.craftguide then
		mcl_craftguide.show(sender:get_player_name())
	end
end

function mcl_furnaces.give_xp(pos, player)
	local meta = core.get_meta(pos)
	local dir = vector.divide(core.facedir_to_dir(core.get_node(pos).param2), -1.95)
	local xp = meta:get_int("xp")
	if xp > 0 then
		if player then
			mcl_experience.add_xp(player, xp)
		else
			mcl_experience.throw_xp(vector.add(pos, dir), xp)
		end
		meta:set_int("xp", 0)
	end
end

--
-- Node callback functions that are the same for active and inactive furnace
--
function mcl_furnaces.is_cookable(stack, pos)
	if pos then
		local def = core.registered_nodes[core.get_node(pos).name]
		if def and def._mcl_furnaces_cook_group and core.get_item_group(stack:get_name(), def._mcl_furnaces_cook_group) == 0 then return false end
	end
	return core.get_craft_result({method = "cooking", width = 1, items = {stack}}).time ~= 0
end

local function sort_stack(stack, pos)
	if mcl_furnaces.is_cookable(stack, pos) then
		if mcl_util.is_fuel(stack) and not core.get_meta(pos):get_inventory():room_for_item("src", stack) then
			return "fuel"
		end
		return "src"
	elseif mcl_util.is_fuel(stack) or ( mcl_furnaces.is_cookable(ItemStack("mcl_sponges:sponge_wet"), pos) and stack:get_name() == "mcl_buckets:bucket_empty" ) then
		return "fuel"
	end
end

function mcl_furnaces.allow_metadata_inventory_put(pos, listname, index, stack, player)
	local name = player:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return 0
	end
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "fuel" then
		-- Special case: empty bucket (not a fuel, but used for sponge drying)
		if stack:get_name() == "mcl_buckets:bucket_empty" then
			return inv:get_stack(listname, index):get_count() == 0 and 1 or 0
		end

		-- Test stack with size 1 because we burn one fuel at a time
		local teststack = ItemStack(stack)
		teststack:set_count(1)
		local output, decremented_input = core.get_craft_result({ method = "fuel", width = 1, items = { teststack } })
		if output.time ~= 0 then
			-- Only allow to place 1 item if fuel get replaced by recipe.
			-- This is the case for lava buckets.
			local replace_item = decremented_input.items[1]
			if replace_item:is_empty() then
				-- For most fuels, just allow to place everything
				return stack:get_count()
			else
				if inv:get_stack(listname, index):get_count() == 0 then
					return 1
				else
					return 0
				end
			end
		else
			return 0
		end
	elseif listname == "src" then
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	elseif listname == "sorter" then
		local inv = core.get_meta(pos):get_inventory()
		local trg = sort_stack(stack, pos)
		if trg then
			local stack1 = ItemStack(stack):take_item()
			if inv:room_for_item(trg, stack) then
				if stack:get_name() == "mcl_buckets:bucket_empty" then
					return inv:get_stack("fuel", 1):get_count() == 0 and 1 or 0
				end
				return stack:get_count()
			elseif inv:room_for_item(trg, stack1) then
				local tc = inv:get_stack(trg, 1):get_count()
				return stack:get_stack_max() - tc
			end
		end
		return 0
	end
end

function mcl_furnaces.allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, _, player)
	if from_list == "sorter" or to_list == "sorter" then return 0 end
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return mcl_furnaces.allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

function mcl_furnaces.allow_metadata_inventory_take(pos, listname, _, stack, player)
	if listname == "sorter" then return 0 end
	local name = player:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return 0
	end
	return stack:get_count()
end

function mcl_furnaces.on_metadata_inventory_take(pos, listname, _, stack, player)
	-- Award smelting achievements
	if listname == "dst" then
		if stack:get_name() == "mcl_core:iron_ingot" then
			awards.unlock(player:get_player_name(), "mcl:acquireIron")
		elseif stack:get_name() == "mcl_fishing:fish_cooked" then
			awards.unlock(player:get_player_name(), "mcl:cookFish")
		elseif stack:get_name() == "mcl_fishing:salmon_cooked" then
			awards.unlock(player:get_player_name(), "mcl:cookFish")
		end
		mcl_furnaces.give_xp(pos, player)
	end
	mcl_redstone.update_comparators(pos)
end

function mcl_furnaces.on_metadata_inventory_move(pos, from_list, _, _, _, _, player)
	if from_list == "dst" then
		mcl_furnaces.give_xp(pos, player)
	end
end

function mcl_furnaces.on_metadata_inventory_put(pos, listname, _, stack, _)
	if listname == "sorter" then
		local inv = core.get_meta(pos):get_inventory()
		inv:add_item(sort_stack(stack, pos), stack)
		inv:set_stack("sorter", 1, ItemStack(""))
	end
	mcl_redstone.update_comparators(pos)
end

function mcl_furnaces.swap_node(pos, name)
	local node = core.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	core.swap_node(pos, node)
end

function mcl_furnaces.furnace_reset_delta_time(pos)
	local meta = core.get_meta(pos)
	local time_speed = tonumber(core.settings:get("time_speed")) or 72
	if (time_speed < 0.1) then
		return
	end
	local time_multiplier = 86400 / time_speed
	local current_game_time = .0 + ((core.get_day_count() + core.get_timeofday()) * time_multiplier)

	-- TODO: Change meta:get/set_string() to get/set_float() for "last_gametime".
	-- In Windows *_float() works OK but under Linux it returns rounded unusable values like 449540.000000000
	local last_game_time = meta:get_string("last_gametime")
	if last_game_time then
		last_game_time = tonumber(last_game_time)
	end
	if not last_game_time or last_game_time < 1 or math.abs(last_game_time - current_game_time) <= 1.5 then
		return
	end

	meta:set_string("last_gametime", tostring(current_game_time))
end

function mcl_furnaces.furnace_get_delta_time(pos, elapsed)
	local meta = core.get_meta(pos)
	local time_speed = tonumber(core.settings:get("time_speed") or 72)
	local current_game_time
	if (time_speed < 0.1) then
		return meta, elapsed
	else
		local time_multiplier = 86400 / time_speed
		current_game_time = .0 + ((core.get_day_count() + core.get_timeofday()) * time_multiplier)
	end

	local last_game_time = meta:get_string("last_gametime")
	if last_game_time then
		last_game_time = tonumber(last_game_time)
	end
	if not last_game_time or last_game_time < 1 then
		last_game_time = current_game_time - 0.1
	elseif last_game_time == current_game_time then
		current_game_time = current_game_time + 1.0
	end

	local elapsed_game_time = .0 + current_game_time - last_game_time

	meta:set_string("last_gametime", tostring(current_game_time))

	return meta, elapsed_game_time
end

function mcl_furnaces.get_timer_function(node_normal, node_active, factor, group)
	return function(pos, elapsed)
		local meta, elapsed_game_time = mcl_furnaces.furnace_get_delta_time(pos, elapsed)

		local fuel_time = meta:get_float("fuel_time") or 0
		local src_time = meta:get_float("src_time") or 0
		local src_item = meta:get_string("src_item") or ""
		local fuel_totaltime = meta:get_float("fuel_totaltime") or 0

		local inv = meta:get_inventory()
		local srclist, fuellist

		local cookable, cooked
		local active = true
		local fuel

		srclist = inv:get_list("src")
		fuellist = inv:get_list("fuel")

		-- Check if src item has been changed
		if srclist[1]:get_name() ~= src_item then
			-- Reset cooking progress in this case
			src_time = 0
			src_item = srclist[1]:get_name()
		end

		local update = true
		local inv_changed = false
		while elapsed_game_time > 0.00001 and update do
			--
			-- Cooking
			--

			local el = elapsed_game_time * factor

			-- Check if we have cookable content: cookable
			local aftercooked
			cooked, aftercooked = core.get_craft_result({ method = "cooking", width = 1, items = srclist })
			cookable = cooked.time ~= 0
			if group then
				cookable = cookable and core.get_item_group(inv:get_stack("src", 1):get_name(), group) > 0
			end
			if cookable then
				-- Successful cooking requires space in dst slot and time
				if not inv:room_for_item("dst", cooked.item) then
					cookable = false
				end
			end

			if cookable then -- fuel lasts long enough, adjust el to cooking duration
				el = math.min(el, cooked.time - src_time)
			end

			-- Check if we have enough fuel to burn
			active = fuel_time < fuel_totaltime
			if cookable and not active then
				-- We need to get new fuel
				local afterfuel
				fuel, afterfuel = core.get_craft_result({ method = "fuel", width = 1, items = fuellist })

				if fuel.time == 0 then
					-- No valid fuel in fuel list -- stop
					fuel_totaltime = 0
					src_time = 0
					update = false
				else
					-- Take fuel from fuel list
					inv:set_stack("fuel", 1, afterfuel.items[1])
					fuel_time = 0
					fuel_totaltime = fuel.time
					el = math.min(el, fuel_totaltime)
					active = true
					fuellist = inv:get_list("fuel")
					inv_changed = true
				end
			elseif active then
				el = math.min(el, fuel_totaltime - fuel_time)
				-- The furnace is currently active and has enough fuel
				fuel_time = fuel_time + el
			end

			-- If there is a cookable item then check if it is ready yet
			if cookable and active then
				src_time = src_time + el
				-- Place result in dst list if done
				if src_time >= cooked.time then
					inv:add_item("dst", cooked.item)
					inv:set_stack("src", 1, aftercooked.items[1])

					-- Unique recipe: Pour water into empty bucket after cooking wet sponge successfully
					if inv:get_stack("fuel", 1):get_name() == "mcl_buckets:bucket_empty" then
						if srclist[1]:get_name() == "mcl_sponges:sponge_wet" then
							inv:set_stack("fuel", 1, "mcl_buckets:bucket_water")
							fuellist = inv:get_list("fuel")
							-- Also for river water
						elseif srclist[1]:get_name() == "mcl_sponges:sponge_wet_river_water" then
							inv:set_stack("fuel", 1, "mcl_buckets:bucket_river_water")
							fuellist = inv:get_list("fuel")
						end
					end

					srclist = inv:get_list("src")
					src_time = 0

					meta:set_int("xp", meta:get_int("xp") + 1) -- ToDo give each recipe an idividial XP count
					inv_changed = true
				end
			end

			elapsed_game_time = elapsed_game_time - el
		end

		if inv_changed then
			mcl_redstone.update_comparators(pos)
		end

		if fuel and fuel_totaltime > fuel.time then
			fuel_totaltime = fuel.time
		end
		if srclist and srclist[1]:is_empty() then
			src_time = 0
		end

		local def = core.registered_nodes[node_normal]
		local name = S("Furnace")
		if def and def.description then
			name = def._tt_original_description or def.description
		end

		local formspec
		if def._mcl_furnaces_get_inactive_formspec then
			formspec = def._mcl_furnaces_get_inactive_formspec(name)
		else
			formspec = get_inactive_formspec(name)
		end
		local item_percent = 0
		if cookable then
			item_percent = math.floor(src_time / cooked.time * 100)
		end

		local result = false

		if active then
			local fuel_percent = 0
			if fuel_totaltime > 0 then
				fuel_percent = math.floor(fuel_time / fuel_totaltime * 100)
			end
			if def._mcl_furnaces_get_active_formspec then
				formspec = def._mcl_furnaces_get_active_formspec(fuel_percent, item_percent, name)
			else
				formspec = get_active_formspec(fuel_percent, item_percent, name)
			end
			mcl_furnaces.swap_node(pos, node_active)
			-- make sure timer restarts automatically
			result = true
		else
			mcl_furnaces.swap_node(pos, node_normal)
			-- stop timer on the inactive furnace
			core.get_node_timer(pos):stop()
		end

		--
		-- Set meta values
		--
		meta:set_float("fuel_totaltime", fuel_totaltime)
		meta:set_float("fuel_time", fuel_time)
		meta:set_float("src_time", src_time)
		if srclist then
			meta:set_string("src_item", src_item)
		else
			meta:set_string("src_item", "")
		end
		meta:set_string("formspec", formspec)

		return result
	end
end

mcl_furnaces.furnace_node_timer = mcl_furnaces.get_timer_function()

mcl_furnaces.on_rotate = screwdriver.rotate_simple

-- Returns true if itemstack is fuel, but not for lava bucket if destination already has one
function mcl_furnaces.is_transferrable_fuel(itemstack, _, _, dst_inventory, dst_list)
	if mcl_util.is_fuel(itemstack) then
		if itemstack:get_name() == "mcl_buckets:bucket_lava" then
			return dst_inventory:is_empty(dst_list)
		else
			return true
		end
	else
		return false
	end
end

function mcl_furnaces.on_hopper_out(uppos, pos)
	local sucked = mcl_util.move_item_container(uppos, pos)

	-- Also suck in non-fuel items from furnace fuel slot
	if not sucked then
		local finv = core.get_inventory({type="node", pos=uppos})
		if finv and not mcl_util.is_fuel(finv:get_stack("fuel", 1)) then
			sucked = mcl_util.move_item_container(uppos, pos, "fuel")
		end
	end
	return sucked
end

function mcl_furnaces.on_hopper_in(pos, to_pos)
	if pos.y == to_pos.y then
		-- Put fuel into fuel slot
		local sinv = core.get_inventory({type="node", pos = pos})
		local dinv = core.get_inventory({type="node", pos = to_pos})
		local slot_id,_ = mcl_util.get_eligible_transfer_item_slot(sinv, "main", dinv, "fuel", mcl_furnaces.is_transferrable_fuel)
		if slot_id then
			mcl_util.move_item_container(pos, to_pos, nil, slot_id, "fuel")
		end
		return true
	end
end

mcl_furnaces.tpl_furnace_node = {
	paramtype2 = "facedir",
	paramtype = "light",
	groups = { pickaxey = 1, container = 4, deco_block = 1, material_stone = 1, furnace = 1, unmovable_by_piston = 1},
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_hardness = 3.5,

	after_dig_node = mcl_util.drop_items_from_meta_container({"src","dst","fuel","sorter"}),
	on_destruct = function(pos)
		mcl_furnaces.give_xp(pos)
	end,

	allow_metadata_inventory_put = mcl_furnaces.allow_metadata_inventory_put,
	allow_metadata_inventory_move = mcl_furnaces.allow_metadata_inventory_move,
	allow_metadata_inventory_take = mcl_furnaces.allow_metadata_inventory_take,
	on_metadata_inventory_move = mcl_furnaces.on_metadata_inventory_move,
	on_metadata_inventory_take = mcl_furnaces.on_metadata_inventory_take,
	on_metadata_inventory_put = mcl_furnaces.on_metadata_inventory_put,
	on_receive_fields = mcl_furnaces.receive_fields,
	_on_hopper_in = mcl_furnaces.on_hopper_in,
	_on_hopper_out = mcl_furnaces.on_hopper_out,
	on_rotate = mcl_furnaces.on_rotate,
}

mcl_furnaces.tpl_furnace_node_normal = table.merge(mcl_furnaces.tpl_furnace_node,{
	_doc_items_hidden = false,

	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		-- Reset accumulated game time when player works with furnace:
		mcl_furnaces.furnace_reset_delta_time(pos)
		core.get_node_timer(pos):start(1.0)

		mcl_furnaces.on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		-- Reset accumulated game time when player works with furnace:
		mcl_furnaces.furnace_reset_delta_time(pos)
		-- start timer function, it will sort out whether furnace can burn or not.
		core.get_node_timer(pos):start(1.0)

		mcl_furnaces.on_metadata_inventory_put(pos, listname, index, stack, player)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		-- Reset accumulated game time when player works with furnace:
		mcl_furnaces.furnace_reset_delta_time(pos)
		-- start timer function, it will helpful if player clears dst slot
		core.get_node_timer(pos):start(1.0)

		mcl_furnaces.on_metadata_inventory_take(pos, listname, index, stack, player)
	end,
})

mcl_furnaces.tpl_furnace_node_active = table.merge(mcl_furnaces.tpl_furnace_node,{
	groups = { pickaxey = 1, container = 4, deco_block = 1, material_stone = 1, furnace = 1, furnace_active = 1, not_in_creative_inventory = 1, unmovable_by_piston = 1 },
	_doc_items_create_entry = false,
	light_source = LIGHT_ACTIVE_FURNACE,
})

function mcl_furnaces.register_furnace(nodename, def)
	local timer_func = mcl_furnaces.get_timer_function(nodename, nodename.."_active", (def.factor or 1), def.cook_group)
	core.register_node(nodename, table.merge(mcl_furnaces.tpl_furnace_node_normal,{
		on_construct = function(pos)
			local meta = core.get_meta(pos)
			local name = S("Furnace")
			local def = core.registered_nodes[nodename]
			if def and def.description then
				name = def._tt_original_description or def.description
			end
			if def.get_inactive_formspec then
				meta:set_string("formspec", def.get_inactive_formspec(name))
			else
				meta:set_string("formspec", get_inactive_formspec(name))
			end
			local inv = meta:get_inventory()
			inv:set_size("sorter", 1)
			inv:set_size("src", 1)
			inv:set_size("fuel", 1)
			inv:set_size("dst", 1)
		end,
		on_timer = timer_func,
		_mcl_furnaces_cook_group = def.cook_group,
		_mcl_furnaces_get_active_formspec = def.get_active_formspec,
		_mcl_furnaces_get_inactive_formspec = def.get_inactive_formspec,
	},def.node_normal))
	core.register_node(nodename.."_active", table.merge(mcl_furnaces.tpl_furnace_node_active,{
		on_timer = timer_func,
		drop = nodename,
		_mcl_baseitem = nodename,
	},def.node_active))
end

mcl_furnaces.register_furnace("mcl_furnaces:furnace",{
	node_normal = {
		description = S("Furnace"),
		_tt_help = S("Uses fuel to smelt or cook items"),
		_doc_items_longdesc = S("Furnaces cook or smelt several items, using a furnace fuel, into something else."),
		_doc_items_usagehelp =
		S("Use the furnace to open the furnace menu.") .. "\n" ..
		S("Place a furnace fuel in the lower slot and the source material in the upper slot.") .. "\n" ..
		S("The furnace will slowly use its fuel to smelt the item.") .. "\n" ..
		S("The result will be placed into the output slot at the right side.") .. "\n" ..
		S("Use the recipe book to see what you can smelt, what you can use as fuel and how long it will burn."),
		tiles = {
			"default_furnace_top.png", "default_furnace_bottom.png",
			"default_furnace_side.png", "default_furnace_side.png",
			"default_furnace_side.png", "default_furnace_front.png"
		},
	},
	node_active = {
		description = S("Burning Furnace"),
		tiles = {
			"default_furnace_top.png", "default_furnace_bottom.png",
			"default_furnace_side.png", "default_furnace_side.png",
			"default_furnace_side.png", "default_furnace_front_active.png",
		},
	},
})


core.register_craft({
	output = "mcl_furnaces:furnace",
	recipe = {
		{ "group:cobble", "group:cobble", "group:cobble" },
		{ "group:cobble", "",             "group:cobble" },
		{ "group:cobble", "group:cobble", "group:cobble" },
	}
})

doc.add_entry_alias("nodes", "mcl_furnaces:furnace", "nodes", "mcl_furnaces:furnace_active")

core.register_lbm({
	label = "Update Furnace formspecs and invs to allow new sneak+click behavior",
	name = "mcl_furnaces:update_coolsneak",
	nodenames = { "group:furnace", "group:furnace_active" },
	run_at_every_load = false,
	action = function(pos, node)
		local m = core.get_meta(pos)
		local inv = m:get_inventory()
		inv:set_size("sorter", 1)

		if core.get_item_group(node.name, "furnace_active") == 0 then --active furnaces update the formspec every second by themselves
			local def = core.registered_nodes[node.name]
			local name = S("Furnace")
			if def and def.description then
				name = def._tt_original_description or def.description
			end
			if def._mcl_furnaces_get_inactive_formspec then
				m:set_string("formspec", def._mcl_furnaces_get_inactive_formspec(name))
			else
				m:set_string("formspec", get_inactive_formspec(name))
			end
		end
	end,
})
