local S = core.get_translator(core.get_current_modname())

mcl_observers = {}

-- Holds positions where observer updates are scheduled.
local scheduled_observer_updates = {}

local function is_update_scheduled(pos)
	return scheduled_observer_updates[core.hash_node_position(pos)]
end
local function set_scheduled_update(pos)
	scheduled_observer_updates[core.hash_node_position(pos)] = true
end
local function clear_scheduled_update(pos)
	scheduled_observer_updates[core.hash_node_position(pos)] = nil
end

-- Holds last deactivation time. Used to prevent double pulses in
-- some circumstances when the input pulse has a 2 tick duration.
-- TODO: Should not be needed if the rest of the redstone implementation
-- invokes callbacks immediately rather than in a later separate phase.
local deactivation_time = {}

local function get_deactivation_time(pos)
	return deactivation_time[core.hash_node_position(pos)]
end
local function set_deactivation_time(pos, tick)
	deactivation_time[core.hash_node_position(pos)] = tick
end
local function clear_deactivation_time(pos)
	deactivation_time[core.hash_node_position(pos)] = nil
end

local function get_front_dir(node)
	if node.name == "mcl_observers:observer_up_off" or node.name == "mcl_observers:observer_up_on" then
		return {x=0, y=1, z=0}
	elseif node.name == "mcl_observers:observer_down_off" or node.name == "mcl_observers:observer_down_on" then
		return {x=0, y=-1, z=0}
	else
		return core.facedir_to_dir(node.param2)
	end
end

function mcl_observers.get_front_pos(pos, node)
	return vector.add(pos, get_front_dir(node))
end

local get_front_pos = mcl_observers.get_front_pos

local function on_scheduled(pos)
	local node  = core.get_node(pos)
	local is_on = core.get_item_group(node.name, "observer") == 2
	local ndef  = core.registered_nodes[node.name]

	clear_scheduled_update(pos)

	if core.get_item_group(node.name, "observer") == 0 then
		return
	end

	if is_on then
		mcl_redstone.swap_node(pos, {name = ndef._mcl_observer_off, param2 = node.param2})
		set_deactivation_time(pos, mcl_redstone._get_current_tick())
	else
		mcl_redstone.swap_node(pos, {name = ndef._mcl_observer_on, param2 = node.param2})
		set_scheduled_update(pos)
		mcl_redstone.after(1, function() on_scheduled(pos) end)
	end

	-- TODO/NOTE: Could reorder or place in mcl_redstone.swap_node.
	-- Leads to different pulse pattern for observer <-> observer clock:
	-- 3-tick on-off-off instead of 2-tick on-off (when using an ordered event queue),
	-- due to _notify_observer_neighbours being placed before mcl_redstone.after.
	mcl_redstone._notify_observer_neighbours(pos)
end

-- mcl_pistons.push makes explicit call to this after doing set_node to trigger observer after movement.
-- on_construct isn't used, since that would cause observers to trigger when placed by player.
function mcl_observers.observer_activate(pos)
	local node  = core.get_node(pos)
	local ndef  = core.registered_nodes[node.name]
	local is_on = core.get_item_group(node.name, "observer") == 2

	-- The observer might have triggered by something else 1 tick before arrival. Turn off if so.
	if is_on then
		mcl_redstone.swap_node(pos, {name = ndef._mcl_observer_off, param2 = node.param2})
		set_deactivation_time(pos, mcl_redstone._get_current_tick())
		mcl_redstone._notify_observer_neighbours(pos)
	end

	if not is_update_scheduled(pos) then
		set_scheduled_update(pos)
		mcl_redstone.after(1, function() on_scheduled(vector.copy(pos)) end)	-- TODO: vector.copy probably not needed.
	end
end

-- Vertical orientation (CURRENTLY DISABLED)
local function observer_orientate(pos, placer)
	-- Not placed by player
	if not placer then return end

	-- Placer pitch in degrees
	local pitch = placer:get_look_vertical() * (180 / math.pi)

	--local node = core.get_node(pos)
	if pitch > 55 then -- player looking upwards
		-- Observer looking downwards
		core.set_node(pos, {name="mcl_observers:observer_down_off"})
	elseif pitch < -55 then -- player looking downwards
		-- Observer looking upwards
		core.set_node(pos, {name="mcl_observers:observer_up_off"})
	end
end

local commdef = {
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rotate = false,
	groups = {pickaxey=1, material_stone=1, redstone_not_conductive=1, },
	_mcl_hardness = 3.5,
	drop = "mcl_observers:observer_off",

	after_destruct = function(pos, oldnode)
		clear_deactivation_time(pos)
		clear_scheduled_update(pos)
	end,

	_mcl_redstone = {},
}
local commdef_off = table.merge(commdef, {
	groups = table.merge(commdef.groups, {observer=1}),
	_mcl_redstone = table.merge(commdef._mcl_redstone, {
		on_observer_neighbor_change = function(pos, node, from_pos)
			if not vector.equals(get_front_pos(pos, node), from_pos) then
				return
			end

			-- Band-aid... forbid scheduling activation at same tick as deactivation,
			-- except if observing an observer. (Observer clocks won't work if not.)
			-- Needed because on_observer_neighbor_change callbacks are invoked imediately, while
			-- the redstone implementation processes update callbacks during a later separate phase.
			local frontnode   = core.get_node(from_pos)
			local is_observer = core.get_item_group(frontnode.name, "observer") ~= 0
			if not is_observer and get_deactivation_time(pos) == mcl_redstone._get_current_tick() then
				return
			end

			if not is_update_scheduled(pos) then
				set_scheduled_update(pos)
				mcl_redstone.after(1, function() on_scheduled(pos) end)
			end
		end,
	}),
})
local commdef_on = table.merge(commdef, {
	_doc_items_create_entry = false,
	groups = table.merge(commdef.groups, {observer=2}),
})

core.register_node("mcl_observers:observer_off", table.merge(commdef_off, {
	paramtype2 = "facedir",
	description = S("Observer"),
	groups = table.merge(commdef_off.groups),
	_tt_help = S("Emits redstone pulse when block in front changes"),
	_doc_items_longdesc = S("An observer is a redstone component which observes the block in front of it and sends a very short redstone pulse whenever this block changes."),
	_doc_items_usagehelp = S("Place the observer directly in front of the block you want to observe with the “face” looking at the block. The arrow points to the side of the output, which is at the opposite side of the “face”. You can place your redstone dust or any other component here."),

	tiles = {
		"mcl_observers_observer_top.png^[transformR180", "default_furnace_bottom.png",
		"mcl_observers_observer_side.png", "mcl_observers_observer_side.png",
		"mcl_observers_observer_front.png", "mcl_observers_observer_back.png",
	},
	after_place_node = observer_orientate,
	_mcl_observer_on = "mcl_observers:observer_on",
	_mcl_observer_off = "mcl_observers:observer_off",
	_mcl_redstone = table.merge(commdef_off._mcl_redstone, {
		connects_to = function(node, dir)
			local dir2 = -core.facedir_to_dir(node.param2)
			return dir2 == dir
		end,
	}),
}))
core.register_node("mcl_observers:observer_on", table.merge(commdef_on, {
	paramtype2 = "facedir",
	groups = table.merge(commdef_on.groups, {not_in_creative_inventory=1}),
	tiles = {
		"mcl_observers_observer_top.png^[transformR180", "default_furnace_bottom.png",
		"mcl_observers_observer_side.png", "mcl_observers_observer_side.png",
		"mcl_observers_observer_front.png", "mcl_observers_observer_back_lit.png",
	},
	_mcl_observer_on = "mcl_observers:observer_on",
	_mcl_observer_off = "mcl_observers:observer_off",
	_mcl_redstone = table.merge(commdef_on._mcl_redstone, {
		connects_to = function(node, dir)
			local dir2 = -core.facedir_to_dir(node.param2)
			return dir2 == dir
		end,
		get_power = function(node, dir)
			local dir2 = -core.facedir_to_dir(node.param2)
			return dir2 == dir and 15 or 0, true
		end,
	})
}))

core.register_node("mcl_observers:observer_down_off", table.merge(commdef_off, {
	_doc_items_create_entry = false,
	groups = table.merge(commdef_off.groups, {not_in_creative_inventory=1}),
	tiles = {
		"mcl_observers_observer_back.png", "mcl_observers_observer_front.png",
		"mcl_observers_observer_side.png^[transformR90", "mcl_observers_observer_side.png^[transformR90",
		"mcl_observers_observer_top.png", "mcl_observers_observer_top.png",
	},
	_mcl_observer_on = "mcl_observers:observer_down_on",
	_mcl_observer_off = "mcl_observers:observer_down_off",
}))
core.register_node("mcl_observers:observer_down_on", table.merge(commdef_on, {
	groups = table.merge(commdef_on.groups, {not_in_creative_inventory=1}),
	tiles = {
		"mcl_observers_observer_back_lit.png", "mcl_observers_observer_front.png",
		"mcl_observers_observer_side.png^[transformR90", "mcl_observers_observer_side.png^[transformR90",
		"mcl_observers_observer_top.png", "mcl_observers_observer_top.png",
	},
	_mcl_observer_on = "mcl_observers:observer_down_on",
	_mcl_observer_off = "mcl_observers:observer_down_off",
	_mcl_redstone = table.merge(commdef_on._mcl_redstone, {
		get_power = function(node, dir)
			return dir.y > 0 and 15 or 0, true
		end,
	})
}))

core.register_node("mcl_observers:observer_up_off", table.merge(commdef_off, {
	_doc_items_create_entry = false,
	groups = table.merge(commdef_off.groups, {not_in_creative_inventory=1}),
	tiles = {
		"mcl_observers_observer_front.png", "mcl_observers_observer_back.png",
		"mcl_observers_observer_side.png^[transformR270", "mcl_observers_observer_side.png^[transformR270",
		"mcl_observers_observer_top.png^[transformR180", "mcl_observers_observer_top.png^[transformR180",
	},
	_mcl_observer_on = "mcl_observers:observer_up_on",
	_mcl_observer_off = "mcl_observers:observer_up_off",
}))
core.register_node("mcl_observers:observer_up_on", table.merge(commdef_on, {
	groups = table.merge(commdef_on.groups, {not_in_creative_inventory=1}),
	tiles = {
		"mcl_observers_observer_front.png", "mcl_observers_observer_back_lit.png",
		"mcl_observers_observer_side.png^[transformR270", "mcl_observers_observer_side.png^[transformR270",
		"mcl_observers_observer_top.png^[transformR180", "mcl_observers_observer_top.png^[transformR180",
	},
	_mcl_observer_on = "mcl_observers:observer_up_on",
	_mcl_observer_off = "mcl_observers:observer_up_off",
	_mcl_redstone = table.merge(commdef_on._mcl_redstone, {
		get_power = function(node, dir)
			return dir.y < 0 and 15 or 0, true
		end,
	})
}))

core.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mcl_nether:quartz", "mcl_redstone:redstone", "mcl_redstone:redstone" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	},
})
core.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mcl_redstone:redstone", "mcl_redstone:redstone", "mcl_nether:quartz" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	},
})

core.register_lbm({
	name = "mcl_observers:turn_off",
	nodenames = {
		"mcl_observers:observer_on",
		"mcl_observers:observer_down_on",
		"mcl_observers:observer_up_on",
		"mcl_observers:observer_off",
		"mcl_observers:observer_down_off",
		"mcl_observers:observer_up_off",
	},
	run_at_every_load = true,
	action = function(pos)
		local node = core.get_node(pos)
		local ndef = core.registered_nodes[node.name]
		core.set_node(pos, { name = ndef._mcl_observer_off, param2 = node.param2 })
	end,
})

doc.add_entry_alias("nodes", "mcl_observers:observer_off", "nodes", "mcl_observers:observer_on")
doc.add_entry_alias("nodes", "mcl_observers:observer_off", "nodes", "mcl_observers:observer_down_on")
doc.add_entry_alias("nodes", "mcl_observers:observer_off", "nodes", "mcl_observers:observer_up_on")
doc.add_entry_alias("nodes", "mcl_observers:observer_off", "nodes", "mcl_observers:observer_off")
doc.add_entry_alias("nodes", "mcl_observers:observer_off", "nodes", "mcl_observers:observer_down_off")
doc.add_entry_alias("nodes", "mcl_observers:observer_off", "nodes", "mcl_observers:observer_up_off")
