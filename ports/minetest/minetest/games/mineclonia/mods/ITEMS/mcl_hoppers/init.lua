local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape
local C = minetest.colorize

--[[ BEGIN OF NODE DEFINITIONS ]]

local mcl_hoppers_formspec = table.concat({
	"formspec_version[4]",
	"size[11.75,8.175]",

	"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, S("Hopper"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(2.875, 0.75, 5, 1),
	"list[context;main;2.875,0.75;5,1;]",

	"label[0.375,2.45;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 2.85, 9, 3),
	"list[current_player;main;0.375,2.85;9,3;9]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 6.8, 9, 1),
	"list[current_player;main;0.375,6.8;9,1;]",

	"listring[context;main]",
	"listring[current_player;main]",
})

-- Downwards hopper (base definition)
local def_hopper = {
	inventory_image = "mcl_hoppers_item.png",
	wield_image = "mcl_hoppers_item.png",
	groups = { pickaxey = 1, container = 2, deco_block = 1, hopper = 1 },
	drawtype = "nodebox",
	paramtype = "light",
	-- FIXME: mcl_hoppers_hopper_inside.png is unused by hoppers.
	tiles = {"mcl_hoppers_hopper_inside.png^mcl_hoppers_hopper_top.png", "mcl_hoppers_hopper_outside.png", "mcl_hoppers_hopper_outside.png", "mcl_hoppers_hopper_outside.png", "mcl_hoppers_hopper_outside.png", "mcl_hoppers_hopper_outside.png"},
	node_box = {
		type = "fixed",
		fixed = {
			--funnel walls
			{ -0.5, 0.0, 0.4, 0.5, 0.5, 0.5 },
			{ 0.4, 0.0, -0.5, 0.5, 0.5, 0.5 },
			{ -0.5, 0.0, -0.5, -0.4, 0.5, 0.5 },
			{ -0.5, 0.0, -0.5, 0.5, 0.5, -0.4 },
			--funnel base
			{ -0.5, 0.0, -0.5, 0.5, 0.1, 0.5 },
			--spout
			{ -0.3, -0.3, -0.3, 0.3, 0.0, 0.3 },
			{ -0.1, -0.3, -0.1, 0.1, -0.5, 0.1 },
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			--funnel
			{ -0.5, 0.0, -0.5, 0.5, 0.5, 0.5 },
			--spout
			{ -0.3, -0.3, -0.3, 0.3, 0.0, 0.3 },
			{ -0.1, -0.3, -0.1, 0.1, -0.5, 0.1 },
		},
	},
	is_ground_content = false,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", mcl_hoppers_formspec)
		local inv = meta:get_inventory()
		inv:set_size("main", 5)
	end,
	after_dig_node = mcl_util.drop_items_from_meta_container({"main"}),

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return count
		end
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in mcl_hoppers at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to mcl_hoppers at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from mcl_hoppers at "..minetest.pos_to_string(pos))
	end,
	sounds = mcl_sounds.node_sound_metal_defaults(),

	_mcl_blast_resistance = 4.8,
	_mcl_hardness = 3,
}

-- Redstone variants (on/off) of downwards hopper.
-- Note a hopper is enabled when it is *not* supplied with redstone power and disabled when it is supplied with redstone power.

-- Enabled downwards hopper
local def_hopper_enabled = table.copy(def_hopper)
def_hopper_enabled.description = S("Hopper")
def_hopper_enabled._tt_help = S("5 inventory slots").."\n"..S("Collects items from above, moves items to container below").."\n"..S("Can be disabled with redstone power")
def_hopper_enabled._doc_items_longdesc = S("Hoppers are containers with 5 inventory slots. They collect dropped items from above, take items from a container above and attempt to put its items it into an adjacent container. Hoppers can go either downwards or sideways. Hoppers interact with chests, droppers, dispensers, shulker boxes, furnaces and hoppers.").."\n\n"..

S("Hoppers interact with containers the following way:").."\n"..
S("• Furnaces: Hoppers from above will put items into the source slot. Hoppers from below take items from the output slot. They also take items from the fuel slot when they can't be used as a fuel. Sideway hoppers that point to the furnace put items into the fuel slot").."\n"..
S("• Ender chests: No interaction.").."\n"..
S("• Other containers: Normal interaction.").."\n\n"..

S("Hoppers can be disabled when supplied with redstone power. Disabled hoppers don't move items.")
def_hopper_enabled._doc_items_usagehelp = S("To place a hopper vertically, place it on the floor or a ceiling. To place it sideways, place it at the side of a block. Use the hopper to access its inventory.")
def_hopper_enabled.on_place = function(itemstack, placer, pointed_thing)
	local upos  = pointed_thing.under
	local apos = pointed_thing.above

	local uposnode = minetest.get_node(upos)
	local uposnodedef = minetest.registered_nodes[uposnode.name]
	if not uposnodedef then return itemstack end

	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	local x = upos.x - apos.x
	local z = upos.z - apos.z

	local fake_itemstack = ItemStack(itemstack)
	local param2
	if x == -1 then
		fake_itemstack:set_name("mcl_hoppers:hopper_side")
		param2 = 0
	elseif x == 1 then
		fake_itemstack:set_name("mcl_hoppers:hopper_side")
		param2 = 2
	elseif z == -1 then
		fake_itemstack:set_name("mcl_hoppers:hopper_side")
		param2 = 3
	elseif z == 1 then
		fake_itemstack:set_name("mcl_hoppers:hopper_side")
		param2 = 1
	end
	local itemstack,_ = minetest.item_place_node(fake_itemstack, placer, pointed_thing, param2)
	itemstack:set_name("mcl_hoppers:hopper")
	return itemstack
end
def_hopper_enabled.mesecons = {
	effector = {
		action_on = function(pos, node)
			minetest.swap_node(pos, {name="mcl_hoppers:hopper_disabled", param2=node.param2})
		end,
	},
}

minetest.register_node("mcl_hoppers:hopper", def_hopper_enabled)

-- Disabled downwards hopper
local def_hopper_disabled = table.copy(def_hopper)
def_hopper_disabled.description = S("Disabled Hopper")
def_hopper_disabled.inventory_image = nil
def_hopper_disabled._doc_items_create_entry = false
def_hopper_disabled.groups.not_in_creative_inventory = 1
def_hopper_disabled.drop = "mcl_hoppers:hopper"
def_hopper_disabled.mesecons = {
	effector = {
		action_off = function(pos, node)
			minetest.swap_node(pos, {name="mcl_hoppers:hopper", param2=node.param2})
		end,
	},
}

minetest.register_node("mcl_hoppers:hopper_disabled", def_hopper_disabled)



local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.rotate_simple
end

-- Sidewars hopper (base definition)
local def_hopper_side = {
	_doc_items_create_entry = false,
	drop = "mcl_hoppers:hopper",
	groups = {pickaxey=1, container=2,not_in_creative_inventory=1,hopper=2},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"mcl_hoppers_hopper_inside.png^mcl_hoppers_hopper_top.png", "mcl_hoppers_hopper_outside.png", "mcl_hoppers_hopper_outside.png", "mcl_hoppers_hopper_outside.png", "mcl_hoppers_hopper_outside.png", "mcl_hoppers_hopper_outside.png"},
	node_box = {
		type = "fixed",
		fixed = {
			--funnel walls
			{ -0.5, 0.0, 0.4, 0.5, 0.5, 0.5 },
			{ 0.4, 0.0, -0.5, 0.5, 0.5, 0.5 },
			{ -0.5, 0.0, -0.5, -0.4, 0.5, 0.5 },
			{ -0.5, 0.0, -0.5, 0.5, 0.5, -0.4 },
			--funnel base
			{ -0.5, 0.0, -0.5, 0.5, 0.1, 0.5 },
			--spout
			{ -0.3, -0.3, -0.3, 0.3, 0.0, 0.3 },
			{ -0.5, -0.3, -0.1, 0.1, -0.1, 0.1 },
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			--funnel
			{ -0.5, 0.0, -0.5, 0.5, 0.5, 0.5 },
			--spout
			{ -0.3, -0.3, -0.3, 0.3, 0.0, 0.3 },
			{ -0.5, -0.3, -0.1, 0.1, -0.1, 0.1 },
		},
	},
	is_ground_content = false,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", mcl_hoppers_formspec)
		local inv = meta:get_inventory()
		inv:set_size("main", 5)
	end,
	after_dig_node = mcl_util.drop_items_from_meta_container({"main"}),

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return count
		end
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in mcl_hoppers at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to mcl_hoppers at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from mcl_hoppers at "..minetest.pos_to_string(pos))
	end,
	on_rotate = on_rotate,
	sounds = mcl_sounds.node_sound_metal_defaults(),

	_mcl_blast_resistance = 4.8,
	_mcl_hardness = 3,
}

local def_hopper_side_enabled = table.copy(def_hopper_side)
def_hopper_side_enabled.description = S("Side Hopper")
def_hopper_side_enabled.mesecons = {
	effector = {
		action_on = function(pos, node)
			minetest.swap_node(pos, {name="mcl_hoppers:hopper_side_disabled", param2=node.param2})
		end,
	},
}
minetest.register_node("mcl_hoppers:hopper_side", def_hopper_side_enabled)

local def_hopper_side_disabled = table.copy(def_hopper_side)
def_hopper_side_disabled.description = S("Disabled Side Hopper")
def_hopper_side_disabled.mesecons = {
	effector = {
		action_off = function(pos, node)
			minetest.swap_node(pos, {name="mcl_hoppers:hopper_side", param2=node.param2})
		end,
	},
}
minetest.register_node("mcl_hoppers:hopper_side_disabled", def_hopper_side_disabled)

--[[ END OF NODE DEFINITIONS ]]

local function hopper_pull_from_mc (mc_ent, dest_pos, inv_size)
	local inv = mcl_entity_invs.load_inv(mc_ent, inv_size)
	if not inv then
		return false
	end

	local dest_meta = minetest.get_meta(dest_pos)
	local dest_inv = dest_meta:get_inventory()
	if not dest_inv then
		return
	end

	for i = 1, mc_ent._inv_size,1 do
		local stack = inv:get_stack("main", i)
		if not stack:get_name() or stack:get_name() ~= "" then
			if dest_inv:room_for_item("main", stack:peek_item()) then
				dest_inv:add_item("main", stack:take_item())
				inv:set_stack("main", i, stack)
				-- Take one item and stop until next time
				return
			end
		end
	end
end

local function hopper_push_to_mc(mc_ent, dest_pos, inv_size)
	local dest_inv = mcl_entity_invs.load_inv(mc_ent, inv_size)
	if not dest_inv then
		return false
	end

	local meta = minetest.get_meta(dest_pos)
	local inv = meta:get_inventory()
	if not inv then
		return
	end
	for i = 1, mc_ent._inv_size, 1 do
		local stack = inv:get_stack("main", i)
		if not stack:get_name() or stack:get_name() ~= "" then
			if dest_inv:room_for_item("main", stack:peek_item()) then
				dest_inv:add_item("main", stack:take_item())
				inv:set_stack("main", i, stack)
				-- Take one item and stop until next time
				return
			end
		end
	end
end

--[[ BEGIN OF ABM DEFINITONS ]]

minetest.register_abm({
	label = "Hoppers pull from minecart",
	nodenames = {"mcl_hoppers:hopper","mcl_hoppers:hopper_side"},
	interval = 0.5,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.get_objects_inside_radius(pos, 3)

		if objs and #objs > 0 then
			for k,v in pairs(objs) do
				local entity = v:get_luaentity()
				if entity and entity.name then
					if entity.name == "mcl_minecarts:hopper_minecart" or entity.name == "mcl_minecarts:chest_minecart"then
						local hm_pos = entity.object:get_pos()
						local DIST_FROM_MC = 1.5
						if (hm_pos.y == pos.y + 1)
								and (hm_pos.x >= pos.x - DIST_FROM_MC and hm_pos.x <= pos.x + DIST_FROM_MC)
								and (hm_pos.z >= pos.z - DIST_FROM_MC and hm_pos.z <= pos.z + DIST_FROM_MC) then
							if entity.name == "mcl_minecarts:hopper_minecart" then
								hopper_pull_from_mc(entity, pos, 5)
							elseif entity.name == "mcl_minecarts:chest_minecart" then
								hopper_pull_from_mc(entity, pos, 27)
							end
						elseif (hm_pos.y == pos.y - 1)
							and (hm_pos.x >= pos.x - DIST_FROM_MC and hm_pos.x <= pos.x + DIST_FROM_MC)
							and (hm_pos.z >= pos.z - DIST_FROM_MC and hm_pos.z <= pos.z + DIST_FROM_MC) then
							if entity.name == "mcl_minecarts:hopper_minecart" then
								hopper_push_to_mc(entity, pos, 5)
							elseif entity.name == "mcl_minecarts:chest_minecart" then
								hopper_push_to_mc(entity, pos, 27)
							end
						end
					end
				end
			end
		end
	end,
})

-- Make hoppers suck in dropped items
minetest.register_abm({
	label = "Hoppers suck in dropped items",
	nodenames = {"mcl_hoppers:hopper","mcl_hoppers:hopper_side"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local abovenode = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
		if not minetest.registered_items[abovenode.name] then return end
		-- Don't bother checking item enties if node above is a container (should save some CPU)
		if minetest.get_item_group(abovenode.name, "container") ~= 0 then
			return
		end
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		for _,object in pairs(minetest.get_objects_inside_radius(pos, 2)) do
			if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" and not object:get_luaentity()._removed then
				if inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then
					-- Item must get sucked in when the item just TOUCHES the block above the hopper
					-- This is the reason for the Y calculation.
					-- Test: Items on farmland and slabs get sucked, but items on full blocks don't
					local posob = object:get_pos()
					local posob_miny = posob.y + object:get_properties().collisionbox[2]
					if math.abs(posob.x-pos.x) <= 0.5 and (posob_miny-pos.y < 1.5 and posob.y-pos.y >= 0.3) then
						inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
						object:get_luaentity().itemstring = ""
						object:remove()
					end
				end
			end
		end
	end,
})

-- Suck an item from the container above into the hopper
local function hopper_suck(pos)
	local uppos = vector.offset(pos,0, 1, 0)

	local upnode = minetest.get_node(uppos)
	local updef = minetest.registered_nodes[upnode.name]

	local success = false
	if updef then
		if updef._on_hopper_out then
			success = updef._on_hopper_out(uppos, pos)
		end
		if not success then
			success = mcl_util.move_item_container(uppos, pos)
		end
	end
	return success
end

-- Move an item from the hopper into container (bottom or side)
local function hopper_push(pos, to_pos)
	local to_node = minetest.get_node(to_pos)
	local to_def = minetest.registered_nodes[to_node.name]
	local cgroup = minetest.get_item_group(to_node.name, "container")

	local success = false
	if to_def then
		if to_def._on_hopper_in then
			success = to_def._on_hopper_in(pos, to_pos)
		end
		-- Move an item from the hopper into the container to which the hopper points to
		if not success and cgroup >= 2 and cgroup <= 6 then
			success = mcl_util.move_item_container(pos, to_pos)
		end
	end
	return success
end


minetest.register_abm({
	label = "Hopper/container item exchange",
	nodenames = { "mcl_hoppers:hopper" },
	neighbors = { "group:container" },
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		hopper_suck(pos)
		local to_pos = vector.offset(pos, 0, -1, 0)
		hopper_push(pos, to_pos)
	end,
})

minetest.register_abm({
	label = "Side-hopper/container item exchange",
	nodenames = { "mcl_hoppers:hopper_side" },
	neighbors = { "group:container" },
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		hopper_suck(pos)
		-- Determine to which side the hopper is facing, get nodes
		local face = minetest.get_node(pos).param2
		local front = vector.zero()
		if face == 0 then
			front = vector.offset(pos, -1, 0, 0)
		elseif face == 1 then
			front = vector.offset(pos, 0, 0, 1)
		elseif face == 2 then
			front = vector.offset(pos, 1, 0, 0)
		elseif face == 3 then
			front = vector.offset(pos, 0, 0, -1)
		end

		local frontnode = minetest.get_node(front)
		if not minetest.registered_nodes[frontnode.name] then return end

		hopper_push(pos, front)
	end
})

minetest.register_craft({
	output = "mcl_hoppers:hopper",
	recipe = {
		{"mcl_core:iron_ingot","","mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot","mcl_chests:chest","mcl_core:iron_ingot"},
		{"","mcl_core:iron_ingot",""},
	}
})

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_hoppers:hopper", "nodes", "mcl_hoppers:hopper_side")
end

-- Legacy
minetest.register_alias("mcl_hoppers:hopper_item", "mcl_hoppers:hopper")

minetest.register_lbm({
	label = "Update hopper formspecs (0.60.0",
	name = "mcl_hoppers:update_formspec_0_60_0",
	nodenames = { "group:hopper" },
	run_at_every_load = false,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", mcl_hoppers_formspec)
	end,
})

dofile(minetest.get_modpath(minetest.get_current_modname()).."/compat.lua")
