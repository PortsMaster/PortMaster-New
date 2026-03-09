-- chiseled_bookshelf.lua
local S = core.get_translator(core.get_current_modname())

local infotext_verbose = core.settings:get_bool("mcl_chiseled_bookshelf_infotext_verbose", false)

-- order of these matters, because they match 4dir node facing directions.
local direction = {
	"south",
	"west",
	"north",
	"east"
}
-- Books cannot stored on up/down faces.

local top = "mcl_books_chiseled_bookshelf_top.png"
local side = "mcl_books_chiseled_bookshelf_side.png"

local function get_bits(inv)
	local bits = 0
	for i = 1, 6 do
		local count = inv:get_stack("main", i):get_count()
		if count >= 1 then
			bits = bit.bor(bits, bit.lshift(1, i - 1))
		end
	end
	return bits
end

local function get_node_name(bits)
	return "mcl_books:chiseled_bookshelf" .. (bits == 0 and "" or "_"..bit.tohex(bits, 2))
end

local function protection_check_put_take(pos, _, _, stack, player)
	local name = player:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return 0
	else
		-- a chiseled bookshelf only stores 1 item per slot, period.
		return math.max(1,stack:get_count())
	end
end

local function get_clicked_side(nodepos,hitpos)
	local pos = nodepos
	local hp = hitpos
	local clicked = "unknown"
	-- if precisely on an edge
	if hp["z"] - 0.5 == math.floor(hp["z"] - 0.5) then
		if hp["z"] < pos["z"] then
			clicked = "south"
		else
			clicked = "north"
		end
	elseif hp["x"] - 0.5 == math.floor(hp["x"] - 0.5) then
		if hp["x"] < pos["x"] then
			clicked = "west"
		else
			clicked = "east"
		end
	end
	return clicked
end

local function get_surface_sixth(nodepos,facing,hitpos)
	-- returns 1-6, which sixth of the surface was used
	local sextant = 1
	local x = nodepos["x"] - hitpos["x"] + 0.5
	local y = nodepos["y"] - hitpos["y"] + 0.5
	local z = nodepos["z"] - hitpos["z"] + 0.5
	-- got y orientation backwards?
	sextant = sextant + (3 * (y > 0.5 and 1 or 0))
	if facing == "north" then
		sextant = sextant + math.floor(x*3)
	elseif facing == "south" then
		sextant = sextant + (2 - math.floor(x*3))
	elseif facing == "west" then
		sextant = sextant + math.floor(z*3)
	elseif facing == "east" then
		sextant = sextant + (2 - math.floor(z*3))
	else
		sextant = -1
	end
	return sextant
end

local function is_allowed_itemstack(itemstack, src_inv, src_list, dst_inv, dst_list)
	if not (core.get_item_group(itemstack:get_name(), "book") ~= 0 or itemstack:get_name() == "mcl_enchanting:book_enchanted") then
		return false
	end
	return true
end

local function use_slot(pos, itemstack, sextant, player)
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()
	local target_slot = inv:get_stack("main",sextant)
	-- only 6 slots
	if sextant < 1 or sextant > 6 then return end
	if protection_check_put_take(pos, nil, nil, itemstack, player) == 0 then
		return
	end

	-- always empty the slot if it has something in it.
	if target_slot and (not target_slot:is_empty()) then
		local ret = nil

		if itemstack:item_fits(target_slot) then
			itemstack:add_item(target_slot)
			ret = ItemStack(itemstack)
		else
			local node = core.get_node(pos)
			local frontpos = pos:add(-core.fourdir_to_dir(node.param2))
			mcl_util.drop_item_stack(frontpos, target_slot)
		end

		-- just in case the function did not empty the slot.
		inv:set_stack("main", sextant, ItemStack(""))
		meta:set_float("last_slot_used", sextant)
		core.log("action", player:get_player_name() .. " removes " .. target_slot:get_name() .. " from chiseled bookshelf slot " .. sextant .. " at " .. core.pos_to_string(pos))

		return ret
	end
	-- and now remove the item from the player's hand and put it in the slot
	if (not itemstack:is_empty()) and is_allowed_itemstack(itemstack) then
		-- put item in slot
		local stack1 = itemstack:take_item()
		if stack1 and (not stack1:is_empty()) then
			core.log("action", player:get_player_name() .. " puts " .. stack1:get_name() .. " in chiseled bookshelf slot " .. sextant .. " at " .. core.pos_to_string(pos))
			inv:set_stack("main", sextant, stack1)
			meta:set_float("last_slot_used", sextant)
			return itemstack
		end
		-- removed nothing
		return nil
	end
end

local function redraw_bookshelf(node,pos)
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()
	local newnode = {name = get_node_name(get_bits(inv)), param2 = node.param2}
	-- no need to copy meta; it is preserved
	core.swap_node(pos, newnode)
	local infotext = ""
	for i = 1, 6 do
		local stack = inv:get_stack("main", i)
		-- This string still has weird escape characters from mcl_enchanting,
		-- but they are thankfully not rendered by the infotext hud
		local stack_str = stack:get_description():gsub("\n"," ")
		local stack_count = stack:get_count()
		if stack_count > 1 then
			stack_str = stack_str + " " + stack_count
		end
		if infotext_verbose then
			infotext = infotext .. i .. ": "
		end
		if stack_count > 0 or infotext_verbose then
			infotext = infotext .. stack_str .. "\n"
		end
	end
	meta:set_string("infotext", infotext)
	mcl_redstone._notify_observer_neighbours(pos)
end

local function on_chiseled_bookshelf_rightclick(pos, node, clicker, itemstack, pointed_thing)
	-- only players are allowed to place items
	if not clicker:is_player() then
		return
	end
	local hitpos = core.pointed_thing_to_face_pos(clicker, pointed_thing)
	local facing = direction[node.param2 + 1] -- param2 is zero-indexed but the table is not
	local clicked = get_clicked_side(pos,hitpos)
	if clicked ~= facing then
		return
	end
	local sextant = get_surface_sixth(pos,facing,hitpos)
	-- sextant is one-indexed, in this order:
	-- 1 2 3
	-- 4 5 6
	local remainder = use_slot(pos, itemstack, sextant, clicker)
	core.sound_play(mcl_sounds.node_sound_wood_defaults().dig, {pos = pos, gain=1}, true)
	redraw_bookshelf(node,pos)
	if remainder then
		return remainder
	end
	mcl_redstone.update_comparators(pos)
end

local function on_hopper_out(uppos, pos)
	local meta = core.get_meta(uppos)
	local inv = core.get_inventory({type="node", pos = uppos})
	local old_bits = get_bits(inv)
	local sucked = mcl_util.move_item_container(uppos, pos,"main",-1)
	local new_bits = get_bits(inv)
	-- for redstone comparator
	for i = 1, 6 do
		if bit.band(old_bits, bit.lshift(1, i - 1)) ~= bit.band(new_bits, bit.lshift(1, i - 1)) then
			meta:set_float("last_slot_used", i)
			break
		end
	end
	if sucked then
		redraw_bookshelf(core.get_node(uppos),uppos)
		mcl_redstone._notify_observer_neighbours(uppos)
	end
	return sucked
end

local function on_hopper_in(pos, to_pos)
	local meta = core.get_meta(to_pos)
	local sinv = core.get_inventory({type="node", pos = pos})
	local dinv = core.get_inventory({type="node", pos = to_pos})
	local src_slot,_ = mcl_util.get_eligible_transfer_item_slot(sinv, "main", dinv, "main", is_allowed_itemstack)
	local dst_slot = 0
	-- find first available dst_slot
	for i = 1, 6 do
		if dinv:get_stack("main",i):is_empty() then
			dst_slot = i
			break
		end
	end
	if dst_slot > 0 and src_slot then
		-- mcl_util.move_item_container(pos, to_pos, nil, nil, "main") is not good enough, because
		-- it uses the stack max for books like normal, but our stack size limit is 1.
		-- if able to move one-count item from source stack, then update source stack
		local src_stack = sinv:get_stack("main",src_slot)
		if dinv:set_stack("main",dst_slot,src_stack:take_item()) then
			sinv:set_stack("main",src_slot,src_stack)
			mcl_redstone._notify_observer_neighbours(to_pos)
		end
		-- for redstone comparator
		meta:set_float("last_slot_used", dst_slot)
		redraw_bookshelf(core.get_node(to_pos),to_pos)
		return true
	else
		return false
	end
end

-- base item
local basegroups = {
		handy = 1,
		axey = 1,
		deco_block = 1,
		material_wood = 1,
		flammable = 3,
		fire_encouragement = 30,
		fire_flammability = 20,
		container = 1
	}
local basedef = {
	description = S("Chiseled Bookshelf"),
	_doc_items_longdesc = S("Chiseled bookshelf holds up to six books."),
	drop = "",
	paramtype2 = "4dir",
	_mcl_hardness = 1.5,
	_mcl_burntime = 15,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 6)
		meta:set_float("last_slot_used", 0)
	end,
	allow_metadata_inventory_move = function() return 0 end,
	allow_metadata_inventory_take = function() return 0 end,
	allow_metadata_inventory_put = function() return 0 end,
	after_dig_node= mcl_util.drop_items_from_meta_container("main"),
	on_rightclick = on_chiseled_bookshelf_rightclick,
	_on_hopper_out = on_hopper_out,
	_on_hopper_in = on_hopper_in,
}

-- This is the dirty trick to show the different books in different slots: use a unique node
-- per possible book configuration.
for i = 0, 63 do
	local front_tile = "[combine:16x16:0,0=mcl_books_chiseled_bookshelf_empty.png"
	for j = 1, 6 do
		-- TODO: would bitshifting be more efficient?
		if bit.band(i, bit.lshift(1, j - 1)) ~= 0 then
			local x = (math.fmod(j-1,3)*5)+1
			local y = (math.floor(j/4)*8)+1
			front_tile = front_tile .. ":" .. x .. "," .. y .. "=" .. "mcl_books_book_" .. tostring(j - 1) .. ".png"
		end
	end
	local name = get_node_name(i)
	core.register_node(name, table.merge(basedef, {
		tiles = { top, top, side, side, side, front_tile },
		groups = table.merge(basegroups, {
			not_in_creative_inventory = i ~= 0 and 1 or nil
		}),
		_mcl_silk_touch_drop = { "mcl_books:chiseled_bookshelf" },
	}))
end

core.register_craft({
	output = "mcl_books:chiseled_bookshelf",
	recipe = {
		{      "group:wood",      "group:wood",      "group:wood" },
		{ "group:wood_slab", "group:wood_slab", "group:wood_slab" },
		{      "group:wood",      "group:wood",      "group:wood" },
	}
})
