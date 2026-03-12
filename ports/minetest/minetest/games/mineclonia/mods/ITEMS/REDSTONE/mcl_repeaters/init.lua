local S = core.get_translator(core.get_current_modname())

local boxes = {
	{
		{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 }, -- the main slab
		{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16}, -- still torch
		{ -1/16, -6/16, 0/16, 1/16, -1/16, 2/16}, -- moved torch
	},
	{
		{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 }, -- the main slab
		{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16}, -- still torch
		{ -1/16, -6/16, -2/16, 1/16, -1/16, 0/16}, -- moved torch
	},
	{
		{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 }, -- the main slab
		{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16}, -- still torch
		{ -1/16, -6/16, -4/16, 1/16, -1/16, -2/16}, -- moved torch
	},
	{
		{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 }, -- the main slab
		{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16}, -- still torch
		{ -1/16, -6/16, -6/16, 1/16, -1/16, -4/16}, -- moved torch
	},
}

local function is_repeater_or_comparator(node)
	return core.get_item_group(node.name, "redstone_repeater") > 0 or
	       core.get_item_group(node.name, "redstone_comparator") > 0
end

local function check_locked(pos, node)
	local front = core.fourdir_to_dir(node.param2)
	local right = front:cross(vector.new(0, 1, 0))
	local left = front:cross(vector.new(0, -1, 0))
	local right_node = core.get_node(pos:add(right))
	local left_node = core.get_node(pos:add(left))

	if is_repeater_or_comparator(right_node) and mcl_redstone.get_power(pos, right) > 0 then
		return true
	end
	if is_repeater_or_comparator(left_node) and mcl_redstone.get_power(pos, left) > 0 then
		return true
	end
	return false
end

local commdef = {
	drawtype = "nodebox",
	walkable = false, -- Workaround until https://github.com/luanti-org/luanti/issues/16432 is resolved
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
	},
	collision_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
	},
	groups = {dig_immediate = 3, dig_by_water = 1, destroy_by_lava_flow = 1, dig_by_piston = 1, unsticky = 1, attached_node = 1},
	paramtype = "light",
	paramtype2 = "4dir",
	sunlight_propagates = false,
	is_ground_content = false,
	drop = "mcl_repeaters:repeater_off_1",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rotate = screwdriver.disallow,
	_mcl_redstone = {
		connects_to = function(node, dir)
			local fourdir = core.dir_to_fourdir(dir)
			return node.param2 % 4 == fourdir or (node.param2 + 2) % 4 == fourdir
		end,
		update = function(pos, node)
			local was_locked = core.get_item_group(node.name, "redstone_repeater") == 5
			local on = mcl_redstone.get_power(pos, -core.fourdir_to_dir(node.param2)) ~= 0
			local locked = check_locked(pos, node)
			local delay = was_locked and
				math.min(4, math.max(1, math.floor(node.param2 / 4))) or
				core.get_item_group(node.name, "redstone_repeater")

			if delay == 0 then
				error(node.name)
			end

			if on and locked and not was_locked then
				return {
					delay = delay,
					priority = 1,
					name = "mcl_repeaters:repeater_on_locked",
					param2 = delay * 4 + node.param2 % 4,
				}
			end
			if not on and locked and not was_locked then
				return {
					delay = delay,
					priority = 1,
					name = "mcl_repeaters:repeater_off_locked",
					param2 = delay * 4 + node.param2 % 4,
				}
			end
			if on and not locked then
				return {
					delay = delay,
					priority = 1,
					name = "mcl_repeaters:repeater_on_"..delay,
					param2 = node.param2 % 4,
				}
			end
			if not on and not locked then
				return {
					delay = delay,
					name = "mcl_repeaters:repeater_off_"..delay,
					param2 = node.param2 % 4,
				}
			end
		end,
	},
}

for delay = 1, 4 do
	local normaldef = table.merge(commdef, {
		node_box = {
			type = "fixed",
			fixed = boxes[delay]
		},
		groups = table.merge(commdef.groups, {redstone_repeater = delay}),
		on_rightclick = function(pos, node, clicker)
			local protname = clicker:get_player_name()
			if core.is_protected(pos, protname) then
				core.record_protection_violation(pos, protname)
				return
			end
			local ndef = core.registered_nodes[node.name]
			local next_setting = delay % 4 + 1
			local powered = ndef._mcl_redstone and ndef._mcl_redstone.get_power and "on" or "off"

			core.set_node(pos, {
				name = "mcl_repeaters:repeater_"..powered.."_"..tostring(next_setting),
				param2 = node.param2
			})
		end,
	})

	core.register_node("mcl_repeaters:repeater_off_"..delay, table.merge(normaldef, {
		description = delay == 1 and S("Redstone Repeater") or S("Redstone Repeater (Delay @1)", delay),
		inventory_image = delay == 1 and "mesecons_delayer_item.png" or nil,
		wield_image = delay == 1 and "mesecons_delayer_item.png" or nil,
		_tt_help = delay == 1 and (
			S("Transmits redstone power only in one direction").."\n"..
			S("Delays signal").."\n"..
			S("Output locks when getting active redstone repeater signal from the side")
		) or nil,
		_doc_items_usagehelp = delay == 1 and (
			S("To power a redstone repeater, send a signal in “arrow” direction (the input). The signal goes out on the opposite side (the output) with a delay. To change the delay, use the redstone repeater. The delay is between 0.1 and 0.4 seconds long and can be changed in steps of 0.1 seconds. It is indicated by the position of the moving redstone torch.").."\n"..
			S("To lock a repeater, send a signal from an adjacent repeater into one of its sides. While locked, the moving redstone torch disappears, the output doesn't change and the input signal is ignored.")
		) or nil,
		_doc_items_longdesc = delay == 1 and S("Redstone repeaters are versatile redstone components with multiple purposes: 1. They only allow signals to travel in one direction. 2. They delay the signal. 3. Optionally, they can lock their output in one state.") or nil,
		_doc_items_create_entry = delay == 1,
		tiles = {
			"mesecons_delayer_off.png",
			"mcl_stairs_stone_slab_top.png",
			"mesecons_delayer_sides_off.png",
			"mesecons_delayer_sides_off.png",
			"mesecons_delayer_ends_off.png",
			"mesecons_delayer_ends_off.png",
		},
		groups = table.merge(normaldef.groups, {not_in_creative_inventory = delay ~= 1 and 1 or 0}),
	}))

	core.register_node("mcl_repeaters:repeater_on_"..delay, table.merge(normaldef, {
		description = S("Redstone Repeater (Delay @1, Powered)", delay),
		_doc_items_create_entry = false,
		tiles = {
			"mesecons_delayer_on.png",
			"mcl_stairs_stone_slab_top.png",
			"mesecons_delayer_sides_on.png",
			"mesecons_delayer_sides_on.png",
			"mesecons_delayer_ends_on.png",
			"mesecons_delayer_ends_on.png",
		},
		groups = table.merge(normaldef.groups, {redstone_repeater_on = 1, not_in_creative_inventory = 1}),
		_mcl_redstone = table.merge(normaldef._mcl_redstone, {
			get_power = function(node, dir)
				local fourdir = core.dir_to_fourdir(dir)
				if not fourdir or dir.y ~= 0 then
					return 0
				end
				return node.param2 == fourdir and 15 or 0, true
			end,
		}),
	}))

	if delay ~= 1 then
		doc.add_entry_alias("nodes", "mcl_repeaters:repeater_off_1", "nodes", "mcl_repeaters:repeater_off_"..delay)
	end
	doc.add_entry_alias("nodes", "mcl_repeaters:repeater_off_1", "nodes", "mcl_repeaters:repeater_on_"..delay)
end

local lockeddef = table.merge(commdef, {
	_doc_items_create_entry = false,
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 }, -- the main slab
			{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16}, -- still torch
			{ -6/16, -6/16, -1/16, 6/16, -4/16, 1/16}, -- lock
		}
	},
	groups = table.merge(commdef.groups, {redstone_repeater = 5, not_in_creative_inventory = 1}),
})

core.register_node("mcl_repeaters:repeater_off_locked", table.merge(lockeddef, {
	description = S("Redstone Repeater (Locked)"),
	tiles = {
		"mesecons_delayer_locked_off.png",
		"mcl_stairs_stone_slab_top.png",
		"mesecons_delayer_sides_locked_off.png",
		"mesecons_delayer_sides_locked_off.png",
		"mesecons_delayer_front_locked_off.png",
		"mesecons_delayer_end_locked_off.png",
	},
}))

core.register_node("mcl_repeaters:repeater_on_locked", table.merge(lockeddef, {
	description = S("Redstone Repeater (Locked, Powered)"),
	tiles = {
		"mesecons_delayer_locked_on.png",
		"mcl_stairs_stone_slab_top.png",
		"mesecons_delayer_sides_locked_on.png",
		"mesecons_delayer_sides_locked_on.png",
		"mesecons_delayer_front_locked_on.png",
		"mesecons_delayer_end_locked_on.png",
	},
	groups = table.merge(lockeddef.groups, {redstone_repeater_on = 1}),
	_mcl_redstone = table.merge(lockeddef._mcl_redstone, {
		get_power = function(node, dir)
			local fourdir = core.dir_to_fourdir(dir)
			if not fourdir or dir.y ~= 0 then
				return 0
			end
			return node.param2 % 4 == fourdir and 15 or 0, true
		end,
	})
}))

core.register_craft({
	output = "mcl_repeaters:repeater_off_1",
	recipe = {
		{ "",      "", ""      },
		{ "mcl_redstone_torch:redstone_torch_on", "mcl_redstone:redstone",  "mcl_redstone_torch:redstone_torch_on" },
		{ "mcl_core:stone",   "mcl_core:stone",   "mcl_core:stone"   },
	}
})

doc.add_entry_alias("nodes", "mcl_repeaters:repeater_off_1", "nodes", "mcl_repeaters:repeater_off_locked")
doc.add_entry_alias("nodes", "mcl_repeaters:repeater_off_1", "nodes", "mcl_repeaters:repeater_on_locked")
