-- Based on core.rotate_and_place

--[[
Attempt to predict the desired orientation of the pillar-like node
defined by `itemstack`, and place it accordingly in one of 3 possible
orientations (X, Y or Z).

Stacks are handled normally if the `infinitestacks`
field is false or omitted (else, the itemstack is not changed).
* `invert_wall`: if `true`, place wall-orientation on the ground and ground-
  orientation on wall

This function is a simplified version of core.rotate_and_place.
The Minetest function is seen as inappropriate because this includes mirror
images of possible orientations, causing problems with pillar shadings.
]]
function mcl_util.rotate_axis_and_place(itemstack, placer, pointed_thing, infinitestacks, _)
	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	local wield_name = itemstack:get_name()

	local above = pointed_thing.above
	local under = pointed_thing.under
	local is_x = (above.x ~= under.x)
	local is_y = (above.y ~= under.y)
	local is_z = (above.z ~= under.z)

	local unode = core.get_node_or_nil(under)
	if not unode then
		return
	end

	local anode = core.get_node_or_nil(above)
	if not anode then
		return
	end
	local pos = pointed_thing.above
	local node = anode

	local undef = core.registered_nodes[unode.name]
	if undef and undef.buildable_to then
		pos = pointed_thing.under
		node = unode
	end

	if core.is_protected(pos, placer:get_player_name()) then
		core.record_protection_violation(pos, placer:get_player_name())
		return
	end

	local ndef = core.registered_nodes[node.name]
	if not ndef or not ndef.buildable_to then
		return
	end

	local p2
	if is_y then
		p2 = 0
	elseif is_x then
		p2 = 12
	elseif is_z then
		p2 = 6
	end
	core.set_node(pos, {name = wield_name, param2 = p2})

	if not infinitestacks then
		itemstack:take_item()
		return itemstack
	end
end

-- Wrapper of above function for use as `on_place` callback (Recommended).
-- Similar to core.rotate_node.
function mcl_util.rotate_axis(itemstack, placer, pointed_thing)
	if placer and placer:is_player() then
		return mcl_util.rotate_axis_and_place(itemstack, placer, pointed_thing,
			core.is_creative_enabled(placer:get_player_name()),
			placer:get_player_control().sneak)
	end

	return itemstack
end

-- Returns position of the neighbor of a double chest node
-- or nil if node is invalid.
-- This function assumes that the large chest is actually intact
-- * pos: Position of the node to investigate
-- * param2: param2 of that node
-- * side: Which "half" the investigated node is. "left" or "right"
function mcl_util.get_double_container_neighbor_pos(pos, param2, side)
	if side == "right" then
		if param2 == 0 then
			return vector.offset(pos, -1, 0, 0)
		elseif param2 == 1 then
			return vector.offset(pos, 0, 0, 1)
		elseif param2 == 2 then
			return vector.offset(pos, 1, 0, 0)
		elseif param2 == 3 then
			return vector.offset(pos, 0, 0, -1)
		end
	else
		if param2 == 0 then
			return vector.offset(pos, 1, 0, 0)
		elseif param2 == 1 then
			return vector.offset(pos, 0, 0, -1)
		elseif param2 == 2 then
			return vector.offset(pos, -1, 0, 0)
		elseif param2 == 3 then
			return vector.offset(pos, 0, 0, 1)
		end
	end
end

-- Iterates through all items in the given inventory and
-- returns the slot of the first item which matches a condition.
-- Returns nil if no item was found.
--- source_inventory: Inventory to take the item from
--- source_list: List name of the source inventory from which to take the item
--- destination_inventory: Put item into this inventory
--- destination_list: List name of the destination inventory to which to put the item into
--- condition: Function which takes an itemstack and returns true if it matches the desired item condition.
---            If set to nil, the slot of the first item stack will be taken unconditionally.
-- dst_inventory and dst_list can also be nil if condition is nil.
function mcl_util.get_eligible_transfer_item_slot(src_inventory, src_list, dst_inventory, dst_list, condition)
	local size = src_inventory:get_size(src_list)
	local stack
	for i = 1, size do
		stack = src_inventory:get_stack(src_list, i)
		if not stack:is_empty() and (condition == nil or condition(stack, src_inventory, src_list, dst_inventory, dst_list)) then
			return i
		end
	end
	return nil
end

-- Returns true if itemstack is a shulker box
local function is_not_shulker_box(itemstack)
	local g = core.get_item_group(itemstack:get_name(), "shulker_box")
	return g == 0 or g == nil
end

local function is_room_for_item(stack, src_inventory, src_list, dst_inventory, dst_list)
	local new_stack = ItemStack(stack)
	new_stack:set_count(1)
	return dst_inventory:room_for_item(dst_list, new_stack)
end

-- Moves a single item from one inventory to another.
--- source_inventory: Inventory to take the item from
--- source_list: List name of the source inventory from which to take the item
--- source_stack_id: The inventory position ID of the source inventory to take the item from (-1 for first occupied slot)
--- destination_inventory: Put item into this inventory
--- destination_list: List name of the destination inventory to which to put the item into

-- Returns true on success and false on failure
-- Possible failures: No item in source slot, destination inventory full
function mcl_util.move_item(source_inventory, source_list, source_stack_id, destination_inventory, destination_list)
	if source_stack_id == -1 then
		source_stack_id =  mcl_util.get_eligible_transfer_item_slot(source_inventory, source_list)
		if source_stack_id == nil then
			return false
		end
	end

	if not source_inventory:is_empty(source_list) then
		local stack = source_inventory:get_stack(source_list, source_stack_id)
		if not stack:is_empty() then
			local new_stack = ItemStack(stack)
			new_stack:set_count(1)
			if not destination_inventory:room_for_item(destination_list, new_stack) then
				return false
			end
			stack:take_item()
			source_inventory:set_stack(source_list, source_stack_id, stack)
			destination_inventory:add_item(destination_list, new_stack)
			local source_location = source_inventory:get_location()
			if source_location and source_location.type == "node" then
				mcl_redstone.update_comparators(source_location.pos)
			end
			local destination_location = destination_inventory:get_location()
			if destination_location.type == "node" then
				mcl_redstone.update_comparators(destination_location.pos)
			end
			return true
		end
	end
	return false
end

-- Moves a single item from one container node into another. Performs a variety of high-level
-- checks to prevent invalid transfers such as shulker boxes into shulker boxes
--- source_pos: Position ({x,y,z}) of the node to take the item from
--- destination_pos: Position ({x,y,z}) of the node to put the item into
--- source_list (optional): List name of the source inventory from which to take the item. Default is normally "main"; "dst" for furnace
--- source_stack_id (optional): The inventory position ID of the source inventory to take the item from (-1 for slot of the first valid item; -1 is default)
--- destination_list (optional): List name of the destination inventory. Default is normally "main"; "src" for furnace
-- Returns true on success and false on failure.
function mcl_util.move_item_container(source_pos, destination_pos, source_list, source_stack_id, destination_list)
	local dpos = table.copy(destination_pos)
	local spos = table.copy(source_pos)
	local snode = core.get_node(spos)
	local dnode = core.get_node(dpos)

	local dctype = core.get_item_group(dnode.name, "container")
	local sctype = core.get_item_group(snode.name, "container")

	-- Container type 7 does not allow any movement
	if sctype == 7 then
		return false
	end

	-- Normalize double container by forcing to always use the left segment first
	local function normalize_double_container(pos, node, ctype)
		if ctype == 6 then
			pos = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "right")
			if not pos then
				return false
			end
			node = core.get_node(pos)
			ctype = core.get_item_group(node.name, "container")
			-- The left segment seems incorrect? We better bail out!
			if ctype ~= 5 then
				return false
			end
		end
		return pos, node, ctype
	end

	spos, snode, sctype = normalize_double_container(spos, snode, sctype)
	dpos, dnode, dctype = normalize_double_container(dpos, dnode, dctype)
	if not spos or not dpos then return false end

	local smeta = core.get_meta(spos)
	local dmeta = core.get_meta(dpos)

	local sinv = smeta:get_inventory()
	local dinv = dmeta:get_inventory()

	-- Default source lists
	if not source_list then
		-- Main inventory for most container types
		if sctype == 2 or sctype == 3 or sctype == 5 or sctype == 6 or sctype == 7 then
			source_list = "main"
			-- Furnace: output
		elseif sctype == 4 then
			source_list = "dst"
			-- Unknown source container type. Bail out
		else
			return false
		end
	end

	-- Automatically select a destination list if omitted
	if not destination_list then
		-- Main inventory for most container types
		if dctype == 2 or dctype == 3 or dctype == 5 or dctype == 6 or dctype == 7 then
			destination_list = "main"
			-- Furnace source slot
		elseif dctype == 4 then
			destination_list = "src"
		end
	end

	-- Automatically select stack slot ID if set to automatic
	if not source_stack_id then
		source_stack_id = -1
	end
	if source_stack_id == -1 then
		local cond = nil
		-- Prevent shulker box inception
		if dctype == 3 then
			cond = is_not_shulker_box
		elseif core.get_item_group(dnode.name, "hopper") > 0 then
			cond = is_room_for_item
		end
		source_stack_id = mcl_util.get_eligible_transfer_item_slot(sinv, source_list, dinv, destination_list, cond)
		if not source_stack_id then
			-- Try again if source is a double container
			if snode and sctype == 5 then
				spos = mcl_util.get_double_container_neighbor_pos(spos, snode.param2, "left")
				smeta = core.get_meta(spos)
				sinv = smeta:get_inventory()

				source_stack_id = mcl_util.get_eligible_transfer_item_slot(sinv, source_list, dinv, destination_list, cond)
				if not source_stack_id then
					return false
				end
			else
				return false
			end
		end
	end

	-- Abort transfer if shulker box wants to go into shulker box
	if dctype == 3 then
		local stack = sinv:get_stack(source_list, source_stack_id)
		if stack and core.get_item_group(stack:get_name(), "shulker_box") == 1 then
			return false
		end
	end
	-- Container type 7 does not allow any placement
	if dctype == 7 then
		return false
	end

	-- If it's a container, put it into the container
	if dctype ~= 0 then
		if destination_list then
			-- Move item
			local ok = mcl_util.move_item(sinv, source_list, source_stack_id, dinv, destination_list)

			-- Try transfer to neighbor node if transfer failed and double container
			if dnode and not ok and dctype == 5 then
				dpos = mcl_util.get_double_container_neighbor_pos(dpos, dnode.param2, "left")
				dmeta = core.get_meta(dpos)
				dinv = dmeta:get_inventory()

				ok = mcl_util.move_item(sinv, source_list, source_stack_id, dinv, destination_list)
			end

			-- Update furnace
			if ok and dctype == 4 then
				-- Start furnace's timer function, it will sort out whether furnace can burn or not.
				core.get_node_timer(dpos):start(1.0)
			end

			return ok
		end
	end
	return false
end

local function drop_item_stack(pos, stack)
	if not stack or stack:is_empty() then return end
	local drop_offset = vector.new(math.random() - 0.5, 0, math.random() - 0.5)
	core.add_item(vector.add(pos, drop_offset), stack)
end

mcl_util.drop_item_stack = drop_item_stack

function mcl_util.drop_items_from_meta_container(lists)
	if type(lists) ~= "table" then
	--this check is provided as compatibility to the old (pre 0.90) behavior which would essentially always assume "main" as the list to drop
		lists = { (lists or "main") }
	end
	return function(pos, _, oldmetadata)
		if oldmetadata and oldmetadata.inventory then
			for _,listname in pairs(lists) do
				-- process in after_dig_node callback
				local list = oldmetadata.inventory[listname]
				if list then
					for _, stack in pairs(list) do
						drop_item_stack(pos, stack)
					end
				end
			end
		else
			local meta = core.get_meta(pos)
			local inv = meta:get_inventory()
			for _, listname in pairs(lists) do
				for i = 1, inv:get_size(listname) do
					drop_item_stack(pos, inv:get_stack(listname, i))
				end
			end
			meta:from_table()
		end
	end
end

-- Returns a on_place function for plants
-- * condition: function(pos, node, itemstack)
--    * A function which is called by the on_place function to check if the node can be placed
--    * Must return true, if placement is allowed, false otherwise.
--    * If it returns a string, placement is allowed, but will place this itemstring as a node instead
--    * pos, node: Position and node table of plant node
--    * itemstack: Itemstack to place
function mcl_util.generate_on_place_plant_function(condition)
	return function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			-- no interaction possible with entities
			return itemstack
		end

		-- Call on_rightclick if the pointed node defines it
		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc ~= nil then return rc end

		local place_pos
		local node = core.get_node(pointed_thing.under)
		local def_under = core.registered_nodes[core.get_node(pointed_thing.under).name]
		local def_above = core.registered_nodes[core.get_node(pointed_thing.above).name]
		if not def_under or not def_above then
			return itemstack
		end
		if def_under.buildable_to then
			place_pos = pointed_thing.under
		elseif def_above.buildable_to then
			place_pos = pointed_thing.above
		else
			return itemstack
		end

		-- Check placement rules
		local result, param2 = condition(place_pos, node, itemstack)
		if result == true then
			local idef = itemstack:get_definition()
			local new_itemstack, success = core.item_place_node(itemstack, placer, pointed_thing, param2)

			if success then
				if idef.sounds and idef.sounds.place then
					core.sound_play(idef.sounds.place, {pos = pointed_thing.above, gain = 1}, true)
				end
			end
			itemstack = new_itemstack
		end

		return itemstack
	end
end

function core.item_place(itemstack, placer, pointed_thing, param2)
	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc ~= nil then
		return rc, nil
	end

	if itemstack:get_definition().type == "node" then
		return core.item_place_node(itemstack, placer, pointed_thing, param2)
	end

	return itemstack, nil
end

function mcl_util.call_on_rightclick(itemstack, player, pointed_thing)
	-- Call on_rightclick if the pointed node defines it
	if pointed_thing and pointed_thing.type == "node" then
		local pos = pointed_thing.under
		local node = core.get_node(pos)
		if player and player:is_player() then
			local nodedef = core.registered_nodes[node.name]
			local on_rightclick_optional = nodedef and nodedef._mcl_on_rightclick_optional
			if on_rightclick_optional then
				local rc = on_rightclick_optional(pos, node, player, itemstack, pointed_thing)
				if rc ~= nil then
					mcl_hunger.prevent_eating (player)
					return rc
				end
			end
			local on_rightclick = nodedef and nodedef.on_rightclick
			if not player:get_player_control().sneak and on_rightclick then
				mcl_hunger.prevent_eating (player)
				return on_rightclick(pos, node, player, itemstack, pointed_thing) or itemstack
			end
		end
	end
	-- Prevent itemstack on_rightclick invoked when interact with certain mobs
	if pointed_thing and pointed_thing.type == "object" then
		local ent = pointed_thing.ref:get_luaentity()
		if ent then
			local def = core.registered_entities[ent.name]
			if not def._unplaceable_by_default
			and (ent.actionable_on_rightclick and ent:actionable_on_rightclick (player)) then
				mcl_hunger.prevent_eating (player)
				return itemstack
			end
		end
	end
end

-- This function is essentially a wrapper around core.raycast to get the currently pointed at "pointed_thing"
-- The last "ignore" argument is either a table of nodename to ignore in the raycast or a func(pointed_thing) that
-- returns true if that position in the ray shall be discounted.
function mcl_util.get_pointed_thing(player, objects, liquid, ignore)
	local pos = vector.offset(player:get_pos(), 0, player:get_properties().eye_height, 0)
	local def = player:get_wielded_item():get_definition()
	local range = math.ceil(def and def.range or ItemStack():get_definition().range or tonumber(core.settings:get("mcl_hand_range")) or 4.5)
	local look_dir = vector.multiply(player:get_look_dir(), range)
	local pos2 = vector.add(pos, look_dir)
	local ray = core.raycast(pos, pos2, objects, liquid)

	for pointed_thing in ray do
		if pointed_thing.ref ~= player then
			if not ignore or
				(type(ignore) == "table" and table.indexof(ignore, core.get_node(pointed_thing.under).name) == -1) or
				(type(ignore) == "function" and not ignore(pointed_thing))
			then
				return pointed_thing
			end
		end
	end
end

---Return a function to use in `on_place`.
---
---Allow to bypass the `buildable_to` node field in a `on_place` callback.
---
---You have to make sure that the nodes you return true for have `buildable_to = true`.
-- Arguemnt is a function with the node name as argument. it should return true if the
-- node should not replace a "buildable_to" node.
function mcl_util.bypass_buildable_to(func)
	--------------------------
	-- MINETEST CODE: UTILS --
	--------------------------

	local function copy_pointed_thing(pointed_thing)
		return {
			type  = pointed_thing.type,
			above = pointed_thing.above and vector.copy(pointed_thing.above),
			under = pointed_thing.under and vector.copy(pointed_thing.under),
			ref   = pointed_thing.ref,
		}
	end

	local function user_name(user)
		return user and user:get_player_name() or ""
	end

	local function log(name, ...)
		return name ~= "" and core.log(...)
	end

	local function check_attached_node(p, n, group_rating)
		local def = core.registered_nodes[n.name]
		local d = vector.zero()
		if group_rating == 3 then
			-- always attach to floor
			d.y = -1
		elseif group_rating == 4 then
			-- always attach to ceiling
			d.y = 1
		elseif group_rating == 2 then
			-- attach to facedir or 4dir direction
			if (def.paramtype2 == "facedir" or
				def.paramtype2 == "colorfacedir") then
				-- Attach to whatever facedir is "mounted to".
				-- For facedir, this is where tile no. 5 point at.

				-- The fallback vector here is in case 'facedir to dir' is nil due
				-- to voxelmanip placing a wallmounted node without resetting a
				-- pre-existing param2 value that is out-of-range for facedir.
				-- The fallback vector corresponds to param2 = 0.
				d = core.facedir_to_dir(n.param2) or vector.new(0, 0, 1)
			elseif (def.paramtype2 == "4dir" or
				def.paramtype2 == "color4dir") then
				-- Similar to facedir handling
				d = core.fourdir_to_dir(n.param2) or vector.new(0, 0, 1)
			end
		elseif def.paramtype2 == "wallmounted" or
			def.paramtype2 == "colorwallmounted" then
			-- Attach to whatever this node is "mounted to".
			-- This where tile no. 2 points at.

			-- The fallback vector here is used for the same reason as
			-- for facedir nodes.
			d = core.wallmounted_to_dir(n.param2) or vector.new(0, 1, 0)
		else
			d.y = -1
		end
		local p2 = vector.add(p, d)
		local nn = core.get_node(p2).name
		local def2 = core.registered_nodes[nn]
		if def2 and not def2.walkable then
			return false
		end
		return true
	end

	return function(itemstack, placer, pointed_thing, param2)
		-------------------
		-- MINETEST CODE --
		-------------------
		local def = itemstack:get_definition()
		if def.type ~= "node" or pointed_thing.type ~= "node" then
			return itemstack
		end

		local under = pointed_thing.under
		local oldnode_under = core.get_node_or_nil(under)
		local above = pointed_thing.above
		local oldnode_above = core.get_node_or_nil(above)
		local playername = user_name(placer)

		if not oldnode_under or not oldnode_above then
			log("info", playername .. " tried to place"
				.. " node in unloaded position " .. core.pos_to_string(above))
			return itemstack
		end

		local olddef_under = core.registered_nodes[oldnode_under.name]
		olddef_under = olddef_under or core.nodedef_default
		local olddef_above = core.registered_nodes[oldnode_above.name]
		olddef_above = olddef_above or core.nodedef_default

		if not olddef_above.buildable_to and not olddef_under.buildable_to then
			log("info", playername .. " tried to place"
				.. " node in invalid position " .. core.pos_to_string(above)
				.. ", replacing " .. oldnode_above.name)
			return itemstack
		end

		---------------------
		-- CUSTOMIZED CODE --
		---------------------

		-- Place above pointed node
		local place_to = vector.copy(above)

		-- If node under is buildable_to, check for callback result and place into it instead
		if olddef_under.buildable_to and not func(oldnode_under.name) then
			log("info", "node under is buildable to")
			place_to = vector.copy(under)
		end

		-------------------
		-- MINETEST CODE --
		-------------------

		if core.is_protected(place_to, playername) then
			log("action", playername
				.. " tried to place " .. def.name
				.. " at protected position "
				.. core.pos_to_string(place_to))
			core.record_protection_violation(place_to, playername)
			return itemstack
		end

		local oldnode = core.get_node(place_to)
		local newnode = {name = def.name, param1 = 0, param2 = param2 or 0}

		-- Calculate direction for wall mounted stuff like torches and signs
		if def.place_param2 ~= nil then
			newnode.param2 = def.place_param2
		elseif (def.paramtype2 == "wallmounted" or
			def.paramtype2 == "colorwallmounted") and not param2 then
			local dir = vector.subtract(under, above)
			newnode.param2 = core.dir_to_wallmounted(dir)
			-- Calculate the direction for furnaces and chests and stuff
		elseif (def.paramtype2 == "facedir" or
			def.paramtype2 == "colorfacedir" or
			def.paramtype2 == "4dir" or
			def.paramtype2 == "color4dir") and not param2 then
			local placer_pos = placer and placer:get_pos()
			if placer_pos then
				local dir = vector.subtract(above, placer_pos)
				newnode.param2 = core.dir_to_facedir(dir)
				log("info", "facedir: " .. newnode.param2)
			end
		end

		local metatable = itemstack:get_meta():to_table().fields

		-- Transfer color information
		if metatable.palette_index and not def.place_param2 then
			local color_divisor = nil
			if def.paramtype2 == "color" then
				color_divisor = 1
			elseif def.paramtype2 == "colorwallmounted" then
				color_divisor = 8
			elseif def.paramtype2 == "colorfacedir" then
				color_divisor = 32
			elseif def.paramtype2 == "color4dir" then
				color_divisor = 4
			elseif def.paramtype2 == "colordegrotate" then
				color_divisor = 32
			end
			if color_divisor then
				local color = math.floor(metatable.palette_index / color_divisor)
				local other = newnode.param2 % color_divisor
				newnode.param2 = color * color_divisor + other
			end
		end

		-- Check if the node is attached and if it can be placed there
		local an = core.get_item_group(def.name, "attached_node")
		if an ~= 0 and
			not check_attached_node(place_to, newnode, an) then
			log("action", "attached node " .. def.name ..
				" cannot be placed at " .. core.pos_to_string(place_to))
			return itemstack
		end

		log("action", playername .. " places node "
			.. def.name .. " at " .. core.pos_to_string(place_to))

		-- Add node and update
		core.set_node(place_to, newnode)

		-- Play sound if it was done by a player
		if playername ~= "" and def.sounds and def.sounds.place then
			core.sound_play(def.sounds.place, {
				pos = place_to,
				exclude_player = playername,
			}, true)
		end

		local take_item = true

		-- Run callback
		if def.after_place_node then
			-- Deepcopy place_to and pointed_thing because callback can modify it
			local place_to_copy = vector.copy(place_to)
			local pointed_thing_copy = copy_pointed_thing(pointed_thing)
			if def.after_place_node(place_to_copy, placer, itemstack,
				pointed_thing_copy) then
				take_item = false
			end
		end

		-- Run script hook
		for _, callback in ipairs(core.registered_on_placenodes) do
			-- Deepcopy pos, node and pointed_thing because callback can modify them
			local place_to_copy = vector.copy(place_to)
			local newnode_copy = {name = newnode.name, param1 = newnode.param1, param2 = newnode.param2}
			local oldnode_copy = {name = oldnode.name, param1 = oldnode.param1, param2 = oldnode.param2}
			local pointed_thing_copy = copy_pointed_thing(pointed_thing)
			if callback(place_to_copy, newnode_copy, placer, oldnode_copy, itemstack, pointed_thing_copy) then
				take_item = false
			end
		end

		if take_item then
			itemstack:take_item()
		end
		return itemstack
	end
end

--Check for a protection violation on a single position.
function mcl_util.check_position_protection(position, player)
	local name = player and player:get_player_name() or ""

	if core.is_protected(position, name) then
		core.record_protection_violation(position, name)
		return true
	end

	return false
end

function mcl_util.safe_place(pos, node, player, itemstack)
	local name = player and player:get_player_name() or ""
	local nnode = node or (itemstack and {name = itemstack:get_name()}) or nil
	if not nnode then return itemstack end
	if mcl_util.check_position_protection(pos,player) then return itemstack end

	core.set_node(pos, nnode)

	if itemstack and not core.is_creative_enabled(name) then
		itemstack:take_item(1)
		return itemstack
	end
	return itemstack or true
end

function mcl_util.get_pos_p2(pos, for_trees)
	if not mcl_levelgen.levelgen_enabled then
		local biomedef = core.registered_biomes[core.get_biome_name(core.get_biome_data(pos).biome)]
		return biomedef and biomedef._mcl_palette_index or 0
	else
		local biome = mcl_levelgen.get_biome (pos, true)
		local biomedef = mcl_levelgen.registered_biomes[biome]
		if not for_trees then
			return (biomedef and biomedef.grass_palette_index) or 0
		else
			return (biomedef and biomedef.leaves_palette_index) or 0
		end
	end
end

function mcl_util.traverse_tower(pos, dir, callback)
	local node = core.get_node(pos)
	local i = 0
	while core.get_node(pos).name == node.name do
		if callback and callback(pos, dir, node) then
			return pos,i,true
		end
		i = i + 1
		pos = vector.offset(pos, 0, dir, 0)
	end
	return vector.offset(pos, 0, -dir, 0), i
end

function mcl_util.traverse_tower_group(pos, dir, group, callback)
	local node = core.get_node(pos)
	local nodegroup = core.get_item_group(node.name, group)
	local i = 0
	while core.get_item_group(core.get_node(pos).name, group) == nodegroup do
		if callback and callback(pos, dir, node) then
			return pos,i,true
		end
		i = i + 1
		pos = vector.offset(pos, 0, dir, 0)
	end
	return vector.offset(pos, 0, -dir, 0), i
end

-- Voxel manip function to replace a node type with another in an area
function mcl_util.replace_node_vm(pos1, pos2, mat_from, mat_to, is_group)
	local c_to = core.get_content_id(mat_to)

	local group_name
	local c_from

	if is_group then
		group_name = string.match(mat_from, "group:(.+)")
	else
		c_from = core.get_content_id(mat_from)
	end

	local vm = core.get_voxel_manip()
	local emin, emax = vm:read_from_map(pos1, pos2)
	local a = VoxelArea:new({
		MinEdge = emin,
		MaxEdge = emax,
	})
	local data = vm:get_data()

	-- Modify data
	for z = pos1.z, pos2.z do
		for y = pos1.y, pos2.y do
			for x = pos1.x, pos2.x do
				local vi = a:index(x, y, z)
				if is_group then
					local node_name = core.get_name_from_content_id(data[vi])
					if core.get_item_group(node_name, group_name) > 0 then
						data[vi] = c_to
					end
				else
					if data[vi] == c_from then
						data[vi] = c_to
					end
				end
			end
		end
	end

	-- Write data
	vm:set_data(data)
	vm:write_to_map(true)
end

-- TODO: Remove and use core.bulk_swap_node directly after abandoning
-- compatibility with Minetest versions were it is not present.
mcl_util.bulk_swap_node = core.bulk_swap_node or function(positions, node)
	for _, pos in pairs(positions) do
		core.swap_node(pos, node)
	end
end

-- Voxel manip function to change nodes if they don't match in an area.
function mcl_util.bulk_set_node_vm(pos1, pos2, mat_to)
	local c_to = core.get_content_id(mat_to)

	local vm = core.get_voxel_manip()
	local emin, emax = vm:read_from_map(pos1, pos2)
	local a = VoxelArea:new({
		MinEdge = emin,
		MaxEdge = emax,
	})
	local data = vm:get_data()

	-- Modify data
	for z = pos1.z, pos2.z do
		for y = pos1.y, pos2.y do
			for x = pos1.x, pos2.x do
				local vi = a:index(x, y, z)
				if data[vi] ~= c_to then
					data[vi] = c_to
				end
			end
		end
	end

	-- Write data
	vm:set_data(data)
	vm:write_to_map(true)
end

-- Voxel manip function to change nodes if they don't match in a circle.
-- Will also set param2 on changed nodes if provided.
function mcl_util.circle_bulk_set_node_vm(radius, pos, y, mat_to, param2)
	local c_to = core.get_content_id(mat_to)

	-- Using new as y is not relative
	local pos1 = vector.new(pos.x - radius, y, pos.z - radius)
	local pos2 = vector.new(pos.x + radius, y, pos.z + radius)

	local vm = core.get_voxel_manip()
	local emin, emax = vm:read_from_map(pos1, pos2)
	local a = VoxelArea:new({
		MinEdge = emin,
		MaxEdge = emax,
	})
	local data = vm:get_data()

	local param2data

	if param2 then
		param2data = vm:get_param2_data()
	end

	for z = -radius, radius do
		for x = -radius, radius do
			if x * x + z * z <= radius * radius + radius * 0.8 then
				--if x * x + z * z <= radius * radius + radius then
				local vi = a:index(math.floor(pos.x + x), y, math.floor(pos.z + z))
				if data[vi] ~= c_to then
					data[vi] = c_to
					if param2 then
						param2data[vi] = param2
					end
				end
			end
		end
	end

	-- Write data
	vm:set_data(data)
	if param2 then
		vm:set_param2_data(param2data)
	end
	vm:write_to_map(true)
end

local ground_padding = tonumber(core.settings:get("mcl_ground_padding")) or 1

-- This function creates a turnip shape under the selected positon.
-- The biome for the position will be used to select the top and filler layers.
-- The shape is slightly altered for sandy top layers.
-- The radius of the top layer is max(fwidth, fdepth) / 2 + ground_padding
function mcl_util.create_ground_turnip(pos, fwidth, fdepth)
	local biome_data = core.get_biome_data(pos)
	local biome_name = core.get_biome_name(biome_data.biome)
	local reg_biome = core.registered_biomes[biome_name]

	local mat = "mcl_core:dirt"
	local filler = "mcl_core:dirt"
	local grass_idx = 0

	-- Use biome info if we have it
	if reg_biome and reg_biome.node_top then
		mat = reg_biome.node_top
		grass_idx = reg_biome._mcl_palette_index or 0
		if reg_biome.node_filler then
			filler = reg_biome.node_filler
			if core.get_item_group(filler, "material_sand") > 0 then
				if reg_biome.node_stone then
					filler = reg_biome.node_stone
				end
			end
		elseif reg_biome.node_stone then
			filler = reg_biome.node_stone
		end
	end

	local y = pos.y

	local radius = math.floor(((math.max(fwidth, fdepth)) / 2)) + ground_padding
	if radius <= 0 then
		return
	end

	-- usually we add 2 layers, each 2 blocks wider, then fill smaller layers below
	-- but for sand we add 2 layers 1 wider and then make the first fill layer wider
	-- otherwsie the sand can collapse and as funny as it is, it is annoying
	local needs_support = core.get_item_group(mat, "material_sand") > 0

	if needs_support then
		radius = radius + 1
	end

	for _ = 1, 2 do
		if not needs_support then
			radius = radius + 2
		else
			radius = radius + 1
		end

		mcl_util.circle_bulk_set_node_vm(radius, pos, y, mat, grass_idx)
		y = y - 1
	end

	if needs_support then
		radius = radius + 2
	end

	for _ = 1, 5 do
		radius = radius - 1

		if radius <= 2 then
			break
		end

		mcl_util.circle_bulk_set_node_vm(radius, pos, y, filler)
		y = y - 1
	end
end

local old_get_natural_light = core.get_natural_light

function core.get_natural_light(pos,tod)
	--pcall the elusive get_light "out of bounds error" bug
	-- TODO: remove this hack when this is fixed in core.
	local st,res = xpcall(function() return old_get_natural_light(pos, tod) end, debug.traceback)
	if st then return res end
	core.log("error","["..tostring(core.get_current_modname()).."] core.get_natural_light would have crashed: \n https://codeberg.org/mineclonia/mineclonia/issues/17\n".. tostring(res))
	return 0
end

function mcl_util.get_2d_block_direction (yaw)
	local d = math.floor (yaw / (math.pi / 2) + 0.5) % 4
	if d == 0 then
		return 0, 1
	elseif d == 1 then
		return -1, 0
	elseif d == 2 then
		return 0, -1
	else -- if d == 3 then
		return 1, 0
	end
end

function mcl_util.is_daytime()
	local time = core.get_timeofday()
	return time <= 0.76 and time >= 0.24
end

local is_halloween_week, is_halloween, is_christmas

local function update_calendar_events ()
	local date = os.date ("*t")
	if (date.month == 10 and date.day == 31) or mcl_util.force_halloween then
		is_halloween = true
	else
		is_halloween = false
	end
	if (date.month == 10 and date.day >= 20)
		or (date.month == 11 and date.day <= 3)
		or mcl_util.force_halloween_week then
		is_halloween_week = true
	else
		is_halloween_week = false
	end
	if (date.month == 12 and date.day >= 24 and date.day <= 26)
		or mcl_util.force_christmas then
		is_christmas = true
	else
		is_christmas = false
	end
end

function mcl_util.is_halloween_week ()
	return is_halloween_week
end

function mcl_util.is_halloween ()
	return is_halloween
end

function mcl_util.is_christmas ()
	return is_christmas
end

local current_day_night_ratio = 1.0

-- This enables frequently invoked callers (such as the surface
-- freezing ABMs) to avoid invoking Luanti C++ API functions.
function mcl_util.get_current_day_night_ratio ()
	return current_day_night_ratio
end

core.register_globalstep (function ()
	update_calendar_events ()
	local tod = core.get_timeofday ()
	current_day_night_ratio = core.time_to_day_night_ratio (tod)
end)
