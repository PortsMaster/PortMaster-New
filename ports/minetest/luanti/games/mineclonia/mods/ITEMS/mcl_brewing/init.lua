local S = core.get_translator(core.get_current_modname())

local function active_brewing_formspec(fuel_percent, brew_percent)

	return "size[9,8.75]"..
	"background[-0.19,-0.25;9.5,9.5;mcl_brewing_inventory.png]"..
	"label[4,0;"..core.formspec_escape(core.colorize("#313131", S("Brewing Stand"))).."]"..
	"label[0,4.0;"..core.formspec_escape(core.colorize("#313131", S("Inventory"))).."]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
	"list[current_player;main;0,7.75;9,1;]"..
	mcl_formspec.get_itemslot_bg(0,7.75,9,1)..
	"list[context;fuel;0.5,1.75;1,1;]"..
	mcl_formspec.get_itemslot_bg(0.5,1.75,1,1).."image[0.5,1.75;1,1;mcl_brewing_fuel_bg.png]"..
	"list[context;input;2.75,0.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(2.75,0.5,1,1)..
	"list[context;stand;4.5,2.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(4.5,2.5,1,1).."image[4.5,2.5;1,1;mcl_brewing_bottle_bg.png]"..
	"list[context;stand;6,2.8;1,1;1]"..
	mcl_formspec.get_itemslot_bg(6,2.8,1,1).."image[6,2.8;1,1;mcl_brewing_bottle_bg.png]"..
	"list[context;stand;7.5,2.5;1,1;2]"..
	mcl_formspec.get_itemslot_bg(7.5,2.5,1,1).."image[7.5,2.5;1,1;mcl_brewing_bottle_bg.png]"..

	"image[2.7,3.33;1.28,0.41;mcl_brewing_burner.png^[lowpart:"..
	(100-fuel_percent)..":mcl_brewing_burner_active.png^[transformR270]"..

	"image[2.76,1.4;1,2.15;mcl_brewing_bubbles.png^[lowpart:"..
	(brew_percent)..":mcl_brewing_bubbles_active.png]"..

	"listring[context;stand]"..
	"listring[current_player;main]"..
	"listring[context;sorter]"..
	"listring[current_player;main]"..
	"listring[context;fuel]"..
	"listring[current_player;main]"..
	"listring[context;input]"..
	"listring[current_player;main]"

end

local brewing_formspec = "size[9,8.75]"..
	"background[-0.19,-0.25;9.5,9.5;mcl_brewing_inventory.png]"..
	"label[4,0;"..core.formspec_escape(core.colorize("#313131", S("Brewing Stand"))).."]"..
	"label[0,4.0;"..core.formspec_escape(core.colorize("#313131", S("Inventory"))).."]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
	"list[current_player;main;0,7.75;9,1;]"..
	mcl_formspec.get_itemslot_bg(0,7.75,9,1)..
	"list[context;fuel;0.5,1.75;1,1;]"..
	mcl_formspec.get_itemslot_bg(0.5,1.75,1,1).."image[0.5,1.75;1,1;mcl_brewing_fuel_bg.png]"..
	"list[context;input;2.75,0.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(2.75,0.5,1,1)..
	"list[context;stand;4.5,2.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(4.5,2.5,1,1).."image[4.5,2.5;1,1;mcl_brewing_bottle_bg.png]"..
	"list[context;stand;6,2.8;1,1;1]"..
	mcl_formspec.get_itemslot_bg(6,2.8,1,1).."image[6,2.8;1,1;mcl_brewing_bottle_bg.png]"..
	"list[context;stand;7.5,2.5;1,1;2]"..
	mcl_formspec.get_itemslot_bg(7.5,2.5,1,1).."image[7.5,2.5;1,1;mcl_brewing_bottle_bg.png]"..

	"image[2.7,3.33;1.28,0.41;mcl_brewing_burner.png^[transformR270]"..
	"image[2.76,1.4;1,2.15;mcl_brewing_bubbles.png]"..

	"listring[context;stand]"..
	"listring[current_player;main]"..
	"listring[context;sorter]"..
	"listring[current_player;main]"..
	"listring[context;fuel]"..
	"listring[current_player;main]"..
	"listring[context;input]"..
	"listring[current_player;main]"

local function brewable(inv)

	local ingredient = inv:get_stack("input",1):get_name()
	local stands = {}
	local stand_size = inv:get_size("stand")
	local was_alchemy = {false,false,false}

	local bottle, alchemy

	for i=1,stand_size do

		bottle = inv:get_stack("stand", i)
		alchemy = mcl_potions.get_alchemy(ingredient, bottle)

		if alchemy then
			stands[i] = alchemy
			was_alchemy[i] = true
		else
			stands[i] = bottle
		end

	end
	-- if any stand holds a new potion, return the list of new potions
	for i=1,#was_alchemy do
		if was_alchemy[i] then return stands end
	end

	return false
end

local BREW_TIME = 10 -- all brews brew the same
local BURN_TIME = BREW_TIME * 20

local function take_fuel (pos, meta, inv)
	-- only allow blaze powder fuel
	local fuel_name, fuel_count
	fuel_name = inv:get_stack ("fuel", 1):get_name ()
	fuel_count = inv:get_stack ("fuel", 1):get_count ()

	if fuel_name == "mcl_mobitems:blaze_powder" then -- Grab another fuel
	if (fuel_count-1) ~= 0 then
		inv:set_stack("fuel", 1, fuel_name.." "..(fuel_count-1))
	else
		inv:set_stack("fuel", 1, "")
	end
	mcl_redstone.update_comparators(pos)
	return BURN_TIME -- New value of fuel_timer_new
	else -- no fuel available
	return 0
	end
end

local function brewing_stand_timer(pos, elapsed)
	-- Inizialize metadata
	local meta = core.get_meta(pos)

	-- Number of seconds of fuel remaining to be consumed.
	local fuel_timer = meta:get_float ("fuel_timer_new")
	local stand_timer = meta:get_float ("stand_timer")
	local inv = meta:get_inventory ()
	local brew_output, d
	local input_count, formspec, fuel_percent, brew_percent

	brew_output = brewable(inv)
	if brew_output then
		if fuel_timer <= 0 then -- Is more fuel required?
		fuel_timer = take_fuel (pos, meta, inv)
		end

		-- If enough fuel remains, continue.
		if fuel_timer > 0 then
		fuel_timer = fuel_timer - elapsed
		stand_timer = stand_timer + elapsed
		d = 0.5
		core.add_particlespawner({
			amount = 4,
			time = 1,
			minpos = {x=pos.x-d, y=pos.y+0.5, z=pos.z-d},
			maxpos = {x=pos.x+d, y=pos.y+2, z=pos.z+d},
			minvel = {x=-0.1, y=0, z=-0.1},
			maxvel = {x=0.1, y=0.5, z=0.1},
			minacc = {x=-0.05, y=0, z=-0.05},
			maxacc = {x=0.05, y=.1, z=0.05},
			minexptime = 1,
			maxexptime = 2,
			minsize = 0.5,
			maxsize = 2,
			collisiondetection = true,
			vertical = false,
			texture = "mcl_brewing_bubble_sprite.png",
		})

		-- Replace the stand item with the brew result
		if stand_timer >= BREW_TIME then
			input_count = inv:get_stack("input",1):get_count()
			if (input_count-1) ~= 0 then
			local stack
				= inv:get_stack("input",1):get_name().." "..(input_count-1)
			inv:set_stack("input", 1, stack)
			else
			inv:set_stack("input", 1, "")
			end

			for i=1, inv:get_size("stand") do
			if brew_output[i] then
				core.sound_play("mcl_brewing_complete",
						{pos=pos, gain=0.4, max_hear_range=6}, true)
				inv:set_stack ("stand", i, brew_output[i])
				core.sound_play("mcl_potions_bottle_pour",
						{pos=pos, gain=0.6, max_hear_range=6}, true)
			end
			end
			stand_timer = 0
			mcl_redstone.update_comparators(pos)
		end
		end
	end

	-- The formspec must be updated after each change.
	fuel_percent = 100 - math.floor (math.max (fuel_timer, 0)
					 / BURN_TIME * 100)
	brew_percent = math.floor(stand_timer/BREW_TIME*100)
	formspec = active_brewing_formspec(fuel_percent, brew_percent*1 % 100)

	local value = true
	-- If the stand becomes inactive, as when no fuel remains or
	-- no valid recipe exists, cancel the timer.
	if fuel_timer <= 0 or not brew_output then
		core.get_node_timer (pos):stop ()
		value = false
	end

	meta:set_float("fuel_timer_new", fuel_timer)
	meta:set_float("stand_timer", stand_timer)
	meta:set_string("formspec", formspec)
	return value
end

local drop_contents = mcl_util.drop_items_from_meta_container({"fuel", "input", "stand"})

local doc_string =
	S("To use a brewing stand, rightclick it.").."\n"..
	S("To brew, you need blaze powder as fuel, a brewing material and at least 1 glass bottle filled with a liquid.").."\n"..
	S("Place the blaze powder in the left slot, the brewing material in the middle slot and 1-3 bottles in the remaining slots.").."\n"..
	S("When you have found a good combination, the brewing will commence automatically and steam starts to appear, using up the fuel and brewing material. The potions will soon be ready.").."\n"..
	S("Different combinations of brewing materials and liquids will give different results. Try to experiment!")

local function sort_stack(stack)
	if stack:get_name() == "mcl_mobitems:blaze_powder" then
		return "fuel"
	end
	if core.get_item_group(stack:get_name(), "brewing_ingredient" ) > 0 then
		return "input"
	end
	for _, g in pairs({"potion", "splash_potion", "ling_potion",
			   "empty_bottle", "water_bottle"}) do
		if core.get_item_group(stack:get_name(), g ) > 0 then
			return "stand"
		end
	end
end

local function allow_put(pos, listname, _, stack, player)
	local name = player:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return 0
	end
	local trg = sort_stack(stack)
	if listname == "stand" then
		if trg ~= "stand" then
			return 0
		end
	elseif listname == "fuel" then
		if trg ~= "fuel" then return 0 end
	elseif listname == "sorter" then
		local inv = core.get_meta(pos):get_inventory()
		if trg then
			local stack1 = ItemStack(stack):take_item()
			if inv:room_for_item(trg, stack) then
				return stack:get_count()
			elseif inv:room_for_item(trg, stack1) then
				return stack:get_stack_max() - inv:get_stack(trg, 1):get_count()
			end
		end
		return 0
	end
	return stack:get_count()
end

local function start_stand_if_not_empty(pos)
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()
	local str = ""
	for i=1, inv:get_size("stand") do
		local stack = inv:get_stack("stand", i)
		if not stack:is_empty() then
			str = str.."1"
		else str = str.."0"
		end
	end
	core.swap_node(pos, {name = "mcl_brewing:stand_"..str})
	core.get_node_timer(pos):start(1.0)
	mcl_redstone.update_comparators(pos)
end

local function on_put(pos, listname, _, stack, _)
	local meta = core.get_meta (pos)
	local inv = meta:get_inventory ()

	if listname == "sorter" then
		listname = sort_stack (stack)
		inv:add_item(listname, stack)
		inv:set_stack("sorter", 1, ItemStack(""))
	end

	if listname == "fuel" then
		-- Refuel immediately if no fuel remains.
		local fuel_timer = meta:get_float ("fuel_timer_new")
		if fuel_timer <= 0 then
		fuel_timer = take_fuel (pos, meta, inv)
		meta:set_float ("fuel_timer_new", fuel_timer)
		end
	end

	if listname == "stand" then
		start_stand_if_not_empty(pos)
		return
	end
	core.get_node_timer (pos):start (1.0)
	mcl_redstone.update_comparators(pos)
end

local function allow_move(pos, from_list, from_index, to_list, _, count, _)
	if from_list == "sorter" or to_list == "sorter" then return 0 end
	local inv = core.get_meta(pos):get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	local trg = sort_stack(stack)
	if trg == to_list then return count end
	return 0
end

local function allow_take (pos, listname, _, stack, player)
	if listname == "sorter" then return 0 end
	local name = player:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return 0
	else
		if listname == "stand" then
			awards.unlock(name, "mcl:localBrewery")
		end
		return stack:get_count()
	end
end

local function hopper_in(pos, to_pos)
	local sinv = core.get_inventory({type="node", pos = pos})
	local dinv = core.get_inventory({type="node", pos = to_pos})
	if pos.y == to_pos.y then
		local slot_id,_ = mcl_util.get_eligible_transfer_item_slot(sinv, "main", dinv, "fuel", function(itemstack)
			return itemstack:get_name() == "mcl_mobitems:blaze_powder"
		end)
		if slot_id then
			mcl_util.move_item(sinv, "main", slot_id, dinv, "fuel")
			core.get_node_timer(to_pos):start(1.0)
		else
			local slot_id,_ = mcl_util.get_eligible_transfer_item_slot(sinv, "main", dinv, "stand", function(itemstack)
				return sort_stack (itemstack) == "stand"
			end)
			if slot_id then
				mcl_util.move_item(sinv, "main", slot_id, dinv, "stand")
				core.get_node_timer(to_pos):start(1.0)
			end
		end
		return true
	end
	local slot_id,_ = mcl_util.get_eligible_transfer_item_slot(sinv, "main", dinv, "input", function(itemstack)
		return core.get_item_group(itemstack:get_name(), "brewing_ingredient" ) > 0
	end)
	if slot_id then
		mcl_util.move_item(sinv, "main", slot_id, dinv, "input")
		core.get_node_timer(to_pos):start(1.0)
	end
	return true
end

local function hopper_out(pos, to_pos)
	local sinv = core.get_inventory({type="node", pos = pos})
	local dinv = core.get_inventory({type="node", pos = to_pos})
	local slot_id,_ = mcl_util.get_eligible_transfer_item_slot(sinv, "stand", dinv, "main", nil)
	if slot_id then
		mcl_util.move_item(sinv, "stand", slot_id, dinv, "main")
	end
	return true
end

local tpl_brewing_stand = {
	description = S("Brewing Stand"),
	_doc_items_create_entry = false,
	_tt_help = S("Brew Potions"),
	groups = {pickaxey = 1, container = 1, not_in_creative_inventory = 1, not_in_craft_guide = 1,
			brewing_stand = 1, pathfinder_partial = 2},
	tiles = {
		"mcl_brewing_stand.png",
		"mcl_brewing_rack.png",
		"mcl_brewing_rack.png",
		"mcl_brewing_rack.png",
	},
	wield_image = "mcl_brewing_stand_inv.png",
	inventory_image = "mcl_brewing_stand_inv.png",
	use_texture_alpha = "clip",
	drop = "mcl_brewing:stand",
	paramtype = "light",
	light_source = 1,
	sunlight_propagates = true,
	is_ground_content = false,
	drawtype = "mesh",
	mesh = "mcl_brewing_stand.obj",
	selection_box = {
		type = "fixed",
		fixed = {
			{-6/16, -8/16, -6/16, 6/16, 6/16, 6/16}
		}
	},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_hardness = 0.5,
	_mcl_baseitem = "mcl_brewing:stand_000",
	after_dig_node = drop_contents,
	allow_metadata_inventory_take = allow_take,
	allow_metadata_inventory_put = allow_put,
	allow_metadata_inventory_move = allow_move,
	on_metadata_inventory_put = on_put,
	on_metadata_inventory_take = start_stand_if_not_empty,
	on_metadata_inventory_move = start_stand_if_not_empty,
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("fuel", 1)
		inv:set_size("stand", 3)
		inv:set_size("sorter", 1)
		local form = brewing_formspec
		meta:set_string("formspec", form)
	end,
	on_receive_fields = function(pos, _, _, sender)
		local sender_name = sender:get_player_name()
		if core.is_protected(pos, sender_name) then
			core.record_protection_violation(pos, sender_name)
			return
		end
	end,
	on_timer = brewing_stand_timer,
	on_rotate = screwdriver.rotate_simple,
	_on_hopper_in = hopper_in,
	_on_hopper_out = hopper_out,
}

core.register_node("mcl_brewing:stand_000", table.merge(tpl_brewing_stand, {
	_doc_items_longdesc = S("The stand allows you to brew potions!"),
	_doc_items_create_entry = true,
	_doc_items_usagehelp = doc_string,
	groups = {handy=1, pickaxey = 1, brewitem = 1, container = 1, brewing_stand = 1,
			pathfinder_partial = 2,},
}))
core.register_node("mcl_brewing:stand_100", table.merge(tpl_brewing_stand, {
	tiles = {
		"mcl_brewing_stand.png",
		"mcl_brewing_rack_bottle.png",
		"mcl_brewing_rack.png",
		"mcl_brewing_rack.png",
	}
}))
core.register_node("mcl_brewing:stand_010", table.merge(tpl_brewing_stand, {
	tiles = {
		"mcl_brewing_stand.png",
		"mcl_brewing_rack.png",
		"mcl_brewing_rack_bottle.png",
		"mcl_brewing_rack.png",
	}
}))
core.register_node("mcl_brewing:stand_001", table.merge(tpl_brewing_stand, {
	tiles = {
		"mcl_brewing_stand.png",
		"mcl_brewing_rack.png",
		"mcl_brewing_rack.png",
		"mcl_brewing_rack_bottle.png",
	}
}))
core.register_node("mcl_brewing:stand_110", table.merge(tpl_brewing_stand, {
	tiles = {
		"mcl_brewing_stand.png",
		"mcl_brewing_rack_bottle.png",
		"mcl_brewing_rack_bottle.png",
		"mcl_brewing_rack.png",
	}
}))
core.register_node("mcl_brewing:stand_101", table.merge(tpl_brewing_stand, {
	tiles = {
		"mcl_brewing_stand.png",
		"mcl_brewing_rack_bottle.png",
		"mcl_brewing_rack.png",
		"mcl_brewing_rack_bottle.png",
	}
}))
core.register_node("mcl_brewing:stand_011", table.merge(tpl_brewing_stand, {
	tiles = {
		"mcl_brewing_stand.png",
		"mcl_brewing_rack.png",
		"mcl_brewing_rack_bottle.png",
		"mcl_brewing_rack_bottle.png",
	}
}))
core.register_node("mcl_brewing:stand_111", table.merge(tpl_brewing_stand, {
	tiles = {
		"mcl_brewing_stand.png",
		"mcl_brewing_rack_bottle.png",
		"mcl_brewing_rack_bottle.png",
		"mcl_brewing_rack_bottle.png",
	}
}))
core.register_craft({
	output = "mcl_brewing:stand_000",
	recipe = {
		{ "", "mcl_mobitems:blaze_rod", "" },
		{ "group:cobble", "group:cobble", "group:cobble" },
	}
})

core.register_alias("mcl_brewing:stand", "mcl_brewing:stand_000")

doc.add_entry_alias("nodes", "mcl_brewing:stand_000", "nodes", "mcl_brewing:stand_001")
doc.add_entry_alias("nodes", "mcl_brewing:stand_000", "nodes", "mcl_brewing:stand_010")
doc.add_entry_alias("nodes", "mcl_brewing:stand_000", "nodes", "mcl_brewing:stand_011")
doc.add_entry_alias("nodes", "mcl_brewing:stand_000", "nodes", "mcl_brewing:stand_100")
doc.add_entry_alias("nodes", "mcl_brewing:stand_000", "nodes", "mcl_brewing:stand_101")
doc.add_entry_alias("nodes", "mcl_brewing:stand_000", "nodes", "mcl_brewing:stand_110")
doc.add_entry_alias("nodes", "mcl_brewing:stand_000", "nodes", "mcl_brewing:stand_111")

core.register_lbm({
	label = "Update brewing stand formspecs and invs to allow new sneak+click behavior",
	name = "mcl_brewing:update_coolsneak",
	nodenames = { "group:brewing_stand" },
	run_at_every_load = false,
	action = function(pos)
		local m = core.get_meta(pos)
		m:get_inventory():set_size("sorter", 1)
		m:set_string("formspec", brewing_formspec)
	end,
})

core.register_lbm({
	label = "Update fuel timers to new non-inverted format",
	name = "mcl_brewing:update_inverted_fueltimer",
	nodenames = { "group:brewing_stand" },
	run_at_every_load = false,
	action = function(pos)
		local m = core.get_meta (pos)
		local old_fuel = m:get_int ("fuel")
		local old_burntime = m:get_int ("fuel_timer")

		if old_fuel ~= 0 then
		m:set_int ("fuel_timer_new", old_burntime - BURN_TIME)
		end
		-- Clear obsolete fields.
		m:set_int ("fuel", 0)
		m:set_int ("fuel_timer", 0)
	end,
})
