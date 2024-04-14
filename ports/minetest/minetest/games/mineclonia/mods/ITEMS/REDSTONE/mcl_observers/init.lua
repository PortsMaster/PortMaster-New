local S = minetest.get_translator(minetest.get_current_modname())

mcl_observers = {}

local rules_flat = {
	{ x = 0, y = 0, z = -1, spread = true },
}
local function get_rules_flat(node)
	local rules = rules_flat
	for i=1, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

local rules_down = {{ x = 0, y = 1, z = 0, spread = true }}
local rules_up = {{ x = 0, y = -1, z = 0, spread = true }}

-- Scan the node in front of the observer
-- and update the observer state if needed.
-- TODO: Also scan metadata changes.
-- TODO: Ignore some node changes.
local function observer_scan(pos, initialize)
	local node = minetest.get_node(pos)
	local front
	if node.name == "mcl_observers:observer_up_off" or node.name == "mcl_observers:observer_up_on" then
		front = vector.add(pos, {x=0, y=1, z=0})
	elseif node.name == "mcl_observers:observer_down_off" or node.name == "mcl_observers:observer_down_on" then
		front = vector.add(pos, {x=0, y=-1, z=0})
	else
		front = vector.add(pos, minetest.facedir_to_dir(node.param2))
	end
	local frontnode = minetest.get_node(front)
	local meta = minetest.get_meta(pos)
	local oldnode = meta:get_string("node_name")
	local oldparam2 = meta:get_string("node_param2")
	local meta_needs_updating = false
	if oldnode ~= "" and not initialize then
		if not (frontnode.name == oldnode and tostring(frontnode.param2) == oldparam2) then
			-- Node state changed! Activate observer
			if node.name == "mcl_observers:observer_off" then
				minetest.swap_node(pos, {name = "mcl_observers:observer_on", param2 = node.param2})
				mesecon.receptor_on(pos, get_rules_flat(node))
			elseif node.name == "mcl_observers:observer_down_off" then
				minetest.swap_node(pos, {name = "mcl_observers:observer_down_on"})
				mesecon.receptor_on(pos, rules_down)
			elseif node.name == "mcl_observers:observer_up_off" then
				minetest.swap_node(pos, {name = "mcl_observers:observer_up_on"})
				mesecon.receptor_on(pos, rules_up)
			end
			meta_needs_updating = true
		end
	else
		meta_needs_updating = true
	end
	if meta_needs_updating then
		meta:set_string("node_name", frontnode.name)
		meta:set_string("node_param2", tostring(frontnode.param2))
	end
	return frontnode
end

function mcl_observers.observer_activate(pos)
	minetest.after(mcl_vars.redstone_tick, function(pos)
		local node = minetest.get_node(pos)
		if not node then
			return
		end
		local nn = node.name
		local start_timer = false
		if nn == "mcl_observers:observer_off" then
			minetest.swap_node(pos, {name = "mcl_observers:observer_on", param2 = node.param2})
			mesecon.receptor_on(pos, get_rules_flat(node))
			start_timer = true
		elseif nn == "mcl_observers:observer_down_off" then
			minetest.swap_node(pos, {name = "mcl_observers:observer_down_on"})
			mesecon.receptor_on(pos, rules_down)
			start_timer = true
		elseif nn == "mcl_observers:observer_up_off" then
			minetest.swap_node(pos, {name = "mcl_observers:observer_up_on"})
			mesecon.receptor_on(pos, rules_up)
			start_timer = true
		end

		if start_timer then
			local timer = minetest.get_node_timer(pos)
			if not timer:is_started() then
				observer_scan(pos, true)
				timer:start(mcl_vars.redstone_tick)
			end
		end
	end, {x=pos.x, y=pos.y, z=pos.z})
end

-- Vertical orientation (CURRENTLY DISABLED)
local function observer_orientate(pos, placer)
	-- Not placed by player
	if not placer then return end

	-- Placer pitch in degrees
	local pitch = placer:get_look_vertical() * (180 / math.pi)

	--local node = minetest.get_node(pos)
	if pitch > 55 then -- player looking upwards
		-- Observer looking downwards
		minetest.set_node(pos, {name="mcl_observers:observer_down_off"})
	elseif pitch < -55 then -- player looking downwards
		-- Observer looking upwards
		minetest.set_node(pos, {name="mcl_observers:observer_up_off"})
	end
end

mesecon.register_node("mcl_observers:observer", {
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		paramtype2 = "facedir",
		on_rotate = false,
		_mcl_blast_resistance = 3.5,
		_mcl_hardness = 3.5,
	}, {
		description = S("Observer"),
		_tt_help = S("Emits redstone pulse when block in front changes"),
		_doc_items_longdesc = S("An observer is a redstone component which observes the block in front of it and sends a very short redstone pulse whenever this block changes."),
		_doc_items_usagehelp = S("Place the observer directly in front of the block you want to observe with the “face” looking at the block. The arrow points to the side of the output, which is at the opposite side of the “face”. You can place your redstone dust or any other component here."),

		groups = {pickaxey=1, material_stone=1, not_opaque=1, },
		tiles = {
			"mcl_observers_observer_top.png^[transformR180", "default_furnace_bottom.png",
			"mcl_observers_observer_side.png", "mcl_observers_observer_side.png",
			"mcl_observers_observer_front.png", "mcl_observers_observer_back.png",
		},
		mesecons = {
			receptor = {
				state = mesecon.state.off,
				rules = get_rules_flat,
			},
		},
		on_construct = function(pos)
			local timer = minetest.get_node_timer(pos)
			if not timer:is_started() then
				observer_scan(pos, true)
				timer:start(mcl_vars.redstone_tick)
			end
		end,
		on_timer = function(pos, elapsed)
			observer_scan(pos)
			return true
		end,
		after_place_node = observer_orientate,
	}, {
		_doc_items_create_entry = false,
		groups = {pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
		tiles = {
			"mcl_observers_observer_top.png^[transformR180", "default_furnace_bottom.png",
			"mcl_observers_observer_side.png", "mcl_observers_observer_side.png",
			"mcl_observers_observer_front.png", "mcl_observers_observer_back_lit.png",
		},
		mesecons = {
			receptor = {
				state = mesecon.state.on,
				rules = get_rules_flat,
			}
		},

		-- VERY quickly disable observer after construction
		on_construct = function(pos)
			local timer = minetest.get_node_timer(pos)
			timer:start(mcl_vars.redstone_tick)
		end,
		on_timer = function(pos, elapsed)
			local node = minetest.get_node(pos)
			minetest.swap_node(pos, {name = "mcl_observers:observer_off", param2 = node.param2})
			mesecon.receptor_off(pos, get_rules_flat(node))
			return true
		end,
	}
)

mesecon.register_node("mcl_observers:observer_down", {
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		groups = {pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
		on_rotate = false,
		_mcl_blast_resistance = 3.5,
		_mcl_hardness = 3.5,
		drop = "mcl_observers:observer_off",
	}, {
		tiles = {
			"mcl_observers_observer_back.png", "mcl_observers_observer_front.png",
			"mcl_observers_observer_side.png^[transformR90", "mcl_observers_observer_side.png^[transformR90",
			"mcl_observers_observer_top.png", "mcl_observers_observer_top.png",
		},
		mesecons = {
			receptor = {
				state = mesecon.state.off,
				rules = rules_down,
			},
		},
		on_construct = function(pos)
			local timer = minetest.get_node_timer(pos)
			if not timer:is_started() then
				observer_scan(pos, true)
				timer:start(mcl_vars.redstone_tick)
			end
		end,
		on_timer = function(pos, elapsed)
			observer_scan(pos)
			return true
		end,
	}, {
		_doc_items_create_entry = false,
		tiles = {
			"mcl_observers_observer_back_lit.png", "mcl_observers_observer_front.png",
			"mcl_observers_observer_side.png^[transformR90", "mcl_observers_observer_side.png^[transformR90",
			"mcl_observers_observer_top.png", "mcl_observers_observer_top.png",
		},
		mesecons = {
			receptor = {
				state = mesecon.state.on,
				rules = rules_down,
			},
		},

		-- VERY quickly disable observer after construction
		on_construct = function(pos)
			local timer = minetest.get_node_timer(pos)
			timer:start(mcl_vars.redstone_tick)
		end,
		on_timer = function(pos, elapsed)
			local node = minetest.get_node(pos)
			minetest.swap_node(pos, {name = "mcl_observers:observer_down_off", param2 = node.param2})
			mesecon.receptor_off(pos, rules_down)
			return true
		end,
	}
)

mesecon.register_node("mcl_observers:observer_up", {
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		groups = {pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
		on_rotate = false,
		_mcl_blast_resistance = 3.5,
		_mcl_hardness = 3.5,
		drop = "mcl_observers:observer_off",
	}, {
		tiles = {
			"mcl_observers_observer_front.png", "mcl_observers_observer_back.png",
			"mcl_observers_observer_side.png^[transformR270", "mcl_observers_observer_side.png^[transformR270",
			"mcl_observers_observer_top.png^[transformR180", "mcl_observers_observer_top.png^[transformR180",
		},
		mesecons = {
			receptor = {
				state = mesecon.state.off,
				rules = rules_up,
			},
		},
		on_construct = function(pos)
			local timer = minetest.get_node_timer(pos)
			if not timer:is_started() then
				observer_scan(pos, true)
				timer:start(mcl_vars.redstone_tick)
			end
		end,
		on_timer = function(pos, elapsed)
			observer_scan(pos)
			return true
		end,
	}, {
		_doc_items_create_entry = false,
		tiles = {
			"mcl_observers_observer_front.png", "mcl_observers_observer_back_lit.png",
			"mcl_observers_observer_side.png^[transformR270", "mcl_observers_observer_side.png^[transformR270",
			"mcl_observers_observer_top.png^[transformR180", "mcl_observers_observer_top.png^[transformR180",
		},
		mesecons = {
			receptor = {
				state = mesecon.state.on,
				rules = rules_up,
			},
		},

		-- VERY quickly disable observer after construction
		on_construct = function(pos)
			local timer = minetest.get_node_timer(pos)
			timer:start(mcl_vars.redstone_tick)
		end,
		on_timer = function(pos, elapsed)
			minetest.swap_node(pos, {name = "mcl_observers:observer_up_off"})
			mesecon.receptor_off(pos, rules_up)
			return true
		end,
	}
)

minetest.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mcl_nether:quartz", "mesecons:redstone", "mesecons:redstone" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	},
})
minetest.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mesecons:redstone", "mesecons:redstone", "mcl_nether:quartz" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	},
})

--[[
	With the following code the observer will detect loading of areas where it is placed.
	We need to restore signal generated by it before the area was unloaded.

	Observer movement and atomic clock (one observer watches another) fails without this often.

	But it WILL cause wrong single signal for all other cases, and I hope it's nothing.
	After all, why it can't detect the loading of areas, if we haven't a better solution...
]]
minetest.register_lbm({
	name = "mcl_observers:activate_lbm",
	nodenames = {
		"mcl_observers:observer_off",
		"mcl_observers:observer_down_off",
		"mcl_observers:observer_up_off",
		"mcl_observers:observer_on",
		"mcl_observers:observer_down_on",
		"mcl_observers:observer_up_on",
	},
	run_at_every_load = true,
	action = function(pos)
		minetest.after(1, mcl_observers.observer_activate, {x=pos.x, y=pos.y, z=pos.z})
	end,
})
