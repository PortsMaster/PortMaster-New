local S = core.get_translator(core.get_current_modname())
local F = core.formspec_escape
local C = core.colorize

local GAMETICK_TIME = 0.05
local HOPPER_INTERVAL_TIME = 1 * GAMETICK_TIME -- 0.050s
local HOPPER_COOLDOWN_TIME = 8 * GAMETICK_TIME -- 0.400s
local EMPTY_HOPPER_COOLDOWN_TIME = 7 * GAMETICK_TIME -- 0.350s

local FOURDIR_OFFSET = 3

-- Make hoppers collect in dropped items
local function hopper_collect(pos)
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()
	local success = false
	for object in core.objects_inside_radius(pos, 2) do
		if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" and not object:get_luaentity()._removed then
			if inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then
				-- Item must get sucked in when the item is above the hopper
				-- and just inside the block above the hopper
				local cbox = object:get_properties().collisionbox
				local radius = cbox[4]
				local posob = object:get_pos()
				local posob_miny = posob.y + cbox[2]
				if math.abs(posob.x-pos.x) <= (0.5 + radius) and
						math.abs(posob.z-pos.z) <= (0.5 + radius) and
						posob_miny-pos.y < 1.5 and posob.y-pos.y >= 0.3 then
					inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
					object:get_luaentity().itemstring = ""
					object:remove()
					success = true
				end
			end
		end
	end
	if success then
		mcl_redstone.update_comparators(pos)
	end
	return success
end

-- This tries to check if a node can be considered "full" or not. This in order
-- to make items get sucked through nodes like mud, like they are supposed to.
-- The check may erroneuosly classify some nodes as not solid.
local function is_full_solid(pos, nodename)
	local boxes = core.get_node_boxes("collision_box", pos)
	if boxes and boxes[1] and boxes[1][5] < 0.5 then return false end
	return core.get_item_group(nodename, "solid") ~= 0
end

-- Pull an item from the container above into the hopper
local function hopper_pull(pos)
	local uppos = vector.offset(pos, 0, 1, 0)

	local upnode = core.get_node(uppos)
	local updef = core.registered_nodes[upnode.name]

	local success = false
	if updef and core.get_item_group(upnode.name, "container") ~= 0 then
		if updef._on_hopper_out then
			success = updef._on_hopper_out(uppos, pos)
		end
		if not success then
			success = mcl_util.move_item_container(uppos, pos)
		end
		if success and updef._after_hopper_out then
			updef._after_hopper_out(uppos)
		end
	elseif not is_full_solid(uppos, upnode.name) then
		success = hopper_collect(pos)
	end
	return success
end

-- Move an item from the hopper into container (bottom or side)
local function hopper_push(pos, to_pos)
	local to_node = core.get_node(to_pos)
	local to_def = core.registered_nodes[to_node.name]
	local cgroup = core.get_item_group(to_node.name, "container")
	local allow_hopper_in = to_def._mcl_allow_hopper_in

	local success = false
	if to_def and (not allow_hopper_in or allow_hopper_in(pos, to_pos)) then
		local to_empty_hopper = (core.get_item_group(to_node.name, "hopper") ~= 0) and
			core.get_meta(to_pos):get_inventory():is_empty("main")

		if to_def._on_hopper_in then
			success = to_def._on_hopper_in(pos, to_pos)
		end
		-- Move an item from the hopper into the container to which the hopper points to
		if not success and cgroup >= 2 and cgroup <= 6 then
			success = mcl_util.move_item_container(pos, to_pos)
		end
		if success then
			if to_def._after_hopper_in then
				to_def._after_hopper_in(to_pos)
			end
			if to_empty_hopper then
				core.get_node_timer(to_pos):start(EMPTY_HOPPER_COOLDOWN_TIME)
			end
		end
	end
	return success
end

local function check_hopper_pull_from_mc(pos, entity, inv_size)
	local inv = mcl_entity_invs.load_inv(entity, inv_size)
	if inv then
		return inv, core.get_meta(pos):get_inventory()
	end
end

local function check_hopper_push_to_mc(pos, entity, inv_size)
	local dest_inv = mcl_entity_invs.load_inv(entity, inv_size)
	if dest_inv then
		return core.get_meta(pos):get_inventory(), dest_inv
	end
end

local function hopper_and_mc(pos, entity, mc_pos, check_function)
	local DIST_FROM_MC = 1.5
	if entity._inv_size > 0 and
		(mc_pos.x >= pos.x - DIST_FROM_MC and mc_pos.x <= pos.x + DIST_FROM_MC) and
		(mc_pos.z >= pos.z - DIST_FROM_MC and mc_pos.z <= pos.z + DIST_FROM_MC) then
		local inv, dest_inv = check_function(pos, entity, entity._inv_size)
		if not inv or not dest_inv then
			return false
		end
		-- TODO: bug? in mcl_util.move_item(inv, "main", -1, dest_inv, "main")
		for i = 1, entity._inv_size, 1 do
			local stack = inv:get_stack("main", i)
			if not stack:get_name() or stack:get_name() ~= "" then
				if dest_inv:room_for_item("main", stack:peek_item()) then
					dest_inv:add_item("main", stack:take_item())
					inv:set_stack("main", i, stack)
					mcl_redstone.update_comparators(pos)
					mcl_entity_invs.save_inv(entity)
					-- Take one item and stop until next time
					return true
				end
			end
		end
	end
	return false
end

local function hopper_timer(pos, elapsed)
	local hopper_group = core.get_item_group(core.get_node(pos).name, "hopper")
	local to_pos
	if hopper_group == 1 then
		to_pos = vector.offset(pos, 0, -1, 0)
	elseif hopper_group == 2 then
		-- Determine to which side the hopper is facing, get nodes
		to_pos = pos + core.fourdir_to_dir((core.get_node(pos).param2 + FOURDIR_OFFSET) % 4)
	else
		core.log("error", "[mcl_hoppers] Unsupported hopper_group="..hopper_group.." at "..vector.to_string(pos))
		return
	end

	-- Hopper interacts with container nodes
	local pushed = hopper_push(pos, to_pos)
	local pulled = hopper_pull(pos)

	-- Hopper interacts with minecarts
	for v in core.objects_inside_radius(pos, 3) do
		local entity = v:get_luaentity()
		if entity and (
			entity.name == "mcl_minecarts:hopper_minecart" or
			entity.name == "mcl_minecarts:chest_minecart") then
			local mc_pos = entity.object:get_pos()
			if (math.floor(mc_pos.y) == pos.y + 1) then
				pulled = hopper_and_mc(pos, entity, mc_pos, check_hopper_pull_from_mc) or pulled
			elseif (math.floor(mc_pos.y) == pos.y - 1) then
				pushed = hopper_and_mc(pos, entity, mc_pos, check_hopper_push_to_mc) or pushed
			end
		end
	end

	core.get_node_timer(pos):start((pushed or pulled) and HOPPER_COOLDOWN_TIME or HOPPER_INTERVAL_TIME)
	return false
end

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

local function redstone_update_on(nodename)
	return function(pos)
		if mcl_redstone.get_power(pos) ~= 0 then
			local node = core.get_node(pos)
			core.swap_node(pos, { name = nodename, param2 = node.param2})
		end
	end
end

local function redstone_update_off(nodename)
	return function(pos)
		if mcl_redstone.get_power(pos) == 0 then
			local node = core.get_node(pos)
			core.swap_node(pos, { name = nodename, param2 = node.param2})
			core.get_node_timer(pos):start(HOPPER_INTERVAL_TIME)
		end
	end
end

-- Downwards hopper (base definition)
local def_hopper = {
	inventory_image = "mcl_hoppers_item.png",
	wield_image = "mcl_hoppers_item.png",
	groups = { pickaxey = 1, container = 2, deco_block = 1, hopper = 1, pathfinder_partial = 2, },
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
		local meta = core.get_meta(pos)
		meta:set_string("formspec", mcl_hoppers_formspec)
		local inv = meta:get_inventory()
		inv:set_size("main", 5)
		core.get_node_timer(pos):start(HOPPER_INTERVAL_TIME)
	end,
	after_dig_node = mcl_util.drop_items_from_meta_container({"main"}),

	allow_metadata_inventory_move = function(pos, _, _, _, _, count, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		else
			return count
		end
	end,
	allow_metadata_inventory_take = function(pos, _, _, stack, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_put = function(pos, _, _, stack, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	on_metadata_inventory_move = function(pos, _, _, _, _, _, player)
		core.log("action", player:get_player_name()..
				" moves stuff in mcl_hoppers at "..core.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, _, _, _, player)
		core.log("action", player:get_player_name()..
				" moves stuff to mcl_hoppers at "..core.pos_to_string(pos))
		mcl_redstone.update_comparators(pos)
	end,
	on_metadata_inventory_take = function(pos, _, _, _, player)
		core.log("action", player:get_player_name()..
				" takes stuff from mcl_hoppers at "..core.pos_to_string(pos))
		mcl_redstone.update_comparators(pos)
	end,
	sounds = mcl_sounds.node_sound_metal_defaults(),

	_mcl_blast_resistance = 4.8,
	_mcl_hardness = 3,

	_mcl_redstone = {
		connects_to = function(node, dir)
			return true
		end,
	},
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
	local uposnode = core.get_node(pointed_thing.under)
	local uposnodedef = core.registered_nodes[uposnode.name]
	if not uposnodedef then return itemstack end

	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	local dir = vector.direction(pointed_thing.under, pointed_thing.above)
	local fake_itemstack = ItemStack(itemstack)
	local param2
	if dir.y == 0 then
		fake_itemstack:set_name("mcl_hoppers:hopper_side")
		param2 = (core.dir_to_fourdir(dir) + FOURDIR_OFFSET ) % 4
	end

	local itemstack,_ = core.item_place_node(fake_itemstack, placer, pointed_thing, param2)
	itemstack:set_name("mcl_hoppers:hopper")
	return itemstack
end
def_hopper_enabled._mcl_redstone.update = redstone_update_on("mcl_hoppers:hopper_disabled")
def_hopper_enabled.on_timer = hopper_timer

core.register_node("mcl_hoppers:hopper", def_hopper_enabled)

-- Disabled downwards hopper
local def_hopper_disabled = table.copy(def_hopper)
def_hopper_disabled.description = S("Disabled Hopper")
def_hopper_disabled.inventory_image = nil
def_hopper_disabled._doc_items_create_entry = false
def_hopper_disabled.groups.not_in_creative_inventory = 1
def_hopper_disabled.drop = "mcl_hoppers:hopper"
def_hopper_disabled._mcl_redstone.update = redstone_update_off("mcl_hoppers:hopper")

core.register_node("mcl_hoppers:hopper_disabled", def_hopper_disabled)

-- Sidewars hopper (base definition)
local def_hopper_side = table.merge(def_hopper, {
	_doc_items_create_entry = false,
	drop = "mcl_hoppers:hopper",
	groups = { pickaxey = 1, container = 2, not_in_creative_inventory = 1, hopper = 2, pathfinder_partial = 2 },
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

	on_rotate = screwdriver.rotate_simple,
})

local def_hopper_side_enabled = table.copy(def_hopper_side)
def_hopper_side_enabled.description = S("Side Hopper")
def_hopper_side_enabled._mcl_redstone.update = redstone_update_on("mcl_hoppers:hopper_side_disabled")
def_hopper_side_enabled.on_timer = hopper_timer

core.register_node("mcl_hoppers:hopper_side", def_hopper_side_enabled)

local def_hopper_side_disabled = table.copy(def_hopper_side)
def_hopper_side_disabled.description = S("Disabled Side Hopper")
def_hopper_side_disabled._mcl_redstone.update = redstone_update_off("mcl_hoppers:hopper_side")

core.register_node("mcl_hoppers:hopper_side_disabled", def_hopper_side_disabled)

--[[ END OF NODE DEFINITIONS ]]

core.register_craft({
	output = "mcl_hoppers:hopper",
	recipe = {
		{"mcl_core:iron_ingot","","mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot","mcl_chests:chest","mcl_core:iron_ingot"},
		{"","mcl_core:iron_ingot",""},
	}
})

-- Add entry aliases for the Help
doc.add_entry_alias("nodes", "mcl_hoppers:hopper", "nodes", "mcl_hoppers:hopper_side")

-- Legacy
core.register_alias("mcl_hoppers:hopper_item", "mcl_hoppers:hopper")

core.register_lbm({
	label = "Update hopper formspecs (0.60.0",
	name = "mcl_hoppers:update_formspec_0_60_0",
	nodenames = { "group:hopper" },
	run_at_every_load = false,
	action = function(pos)
		local meta = core.get_meta(pos)
		meta:set_string("formspec", mcl_hoppers_formspec)
	end,
})

core.register_lbm({
	label = "Add timers for older ABM driven hoppers",
	name = "mcl_hoppers:add_timer",
	nodenames = { "mcl_hoppers:hopper", "mcl_hoppers:hopper_side" },
	run_at_every_load = false,
	action = function(pos)
		local timer = core.get_node_timer(pos)
		if not timer:is_started() then
			timer:start(HOPPER_INTERVAL_TIME)
		end
	end
})

dofile(core.get_modpath(core.get_current_modname()).."/compat.lua")
