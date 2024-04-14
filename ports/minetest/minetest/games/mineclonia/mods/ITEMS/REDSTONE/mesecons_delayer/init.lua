local S = minetest.get_translator(minetest.get_current_modname())

local DELAYS = { 0.1, 0.2, 0.3, 0.4 }
local DEFAULT_DELAY = DELAYS[1]

-- Function that get the input/output rules of the delayer
local function delayer_get_output_rules(node)
	local rules = {{x = -1, y = 0, z = 0, spread=true}}
	for i = 0, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

local function delayer_get_input_rules(node)
	local rules = {{x = 1, y = 0, z = 0}}
	for i = 0, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

-- Return the sides of a delayer.
-- Those are used to toggle the lock state.
local function delayer_get_sides(node)
	local rules = {
		{x = 0, y = 0, z = -1},
		{x = 0, y = 0, z =  1},
	}
	for i = 0, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

-- Make the repeater at pos try to lock any repeater it faces.
-- Returns true if a repeater was locked.
local function check_lock_repeater(pos, node)
	-- Check the repeater at pos and look if it faces
	-- a repeater placed sideways.
	-- If yes, lock the second repeater.
	local r = delayer_get_output_rules(node)[1]
	local lpos = vector.add(pos, r)
	local lnode = minetest.get_node(lpos)
	local ldef = minetest.registered_nodes[lnode.name]
	local g = minetest.get_item_group(lnode.name, "redstone_repeater")
	if g >= 1 and g <= 4 then
		local lrs = delayer_get_input_rules(lnode)
		local fail = false
		for _, lr in pairs(lrs) do
			if lr.x == r.x or lr.z == r.z then
				fail = true
				break
			end
		end
		if not fail then
			minetest.set_node(lpos, {name=ldef.delayer_lockstate, param2=lnode.param2})
			local meta = minetest.get_meta(lpos)
			-- Metadata: delay. Used to remember the delay for locked repeaters.
			-- The number is the torch position (1-4).
			meta:set_int("delay", g)
			return true
		end
	end
	return false
end

-- Make the repeater at pos try to unlock any repeater it faces.
-- Returns true if a repeater was unlocked.
local function check_unlock_repeater(pos, node)
	-- Check the repeater at pos and look if it faces
	-- a repeater placed sideways.
	-- If yes, also check if the second repeater doesn't receive
	-- a locking signal on the other side. If not, unlock the second repeater.
	local r = delayer_get_output_rules(node)[1]
	local lpos = vector.add(pos, r)
	local lnode = minetest.get_node(lpos)
	local ldef = minetest.registered_nodes[lnode.name]
	local g = minetest.get_item_group(lnode.name, "redstone_repeater")
	-- Are we facing a locked repeater?
	if g == 5 then
		-- First check the orientation of the faced repeater
		local lrs = delayer_get_input_rules(lnode)
		for _, lr in pairs(lrs) do
			if lr.x == r.x or lr.z == r.z then
				-- Invalid orientation. Do nothing
				return false
			end
		end
		-- Now we check if there's a powered repeater on the other side of the
		-- locked repeater.
		-- To get to the other side, we just take another step in the direction which we already face.
		local other_side = vector.add(lpos, r)
		local other_node = minetest.get_node(other_side)
		if minetest.get_item_group(other_node.name, "redstone_repeater") ~= 0 and mesecon.is_receptor_on(other_node.name) then
			-- Final check: The other repeater must also face the right way
			local other_face = delayer_get_output_rules(other_node)[1]
			local other_facing_pos = vector.add(other_side, other_face)
			if vector.equals(other_facing_pos, lpos) then
				-- Powered repeater found AND it's facing the locked repeater. Do NOT unlock!
				return false
			end
		end
		local lmeta = minetest.get_meta(lpos)
		local ldelay = lmeta:get_int("delay")
		if tonumber(ldelay) == nil or ldelay < 1 or ldelay > 4 then
			ldelay = 1
		end
		if mesecon.is_powered(lpos, delayer_get_input_rules(lnode)[1]) then
			minetest.set_node(lpos, {name="mesecons_delayer:delayer_on_"..ldelay, param2=lnode.param2})
			mesecon.queue:add_action(lpos, "receptor_on", {delayer_get_output_rules(lnode)}, ldef.delayer_time, nil)
		else
			minetest.set_node(lpos, {name="mesecons_delayer:delayer_off_"..ldelay, param2=lnode.param2})
			mesecon.queue:add_action(lpos, "receptor_off", {delayer_get_output_rules(lnode)}, ldef.delayer_time, nil)
		end
		return true
	end
	return false
end

-- Functions that are called after the delay time
local function delayer_activate(pos, node)
	local def = minetest.registered_nodes[node.name]
	local time = def.delayer_time
	minetest.set_node(pos, {name=def.delayer_onstate, param2=node.param2})
	mesecon.queue:add_action(pos, "receptor_on", {delayer_get_output_rules(node)}, time, nil)
	check_lock_repeater(pos, node)
end

local function delayer_deactivate(pos, node)
	local def = minetest.registered_nodes[node.name]
	local time = def.delayer_time
	minetest.set_node(pos, {name=def.delayer_offstate, param2=node.param2})
	mesecon.queue:add_action(pos, "receptor_off", {delayer_get_output_rules(node)}, time, nil)
	check_unlock_repeater(pos, node)
end

local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.disallow
end

-- Register the 2 (states) x 4 (delay times) delayers

for i = 1, 4 do
	local groups
	if i == 1 then
		groups = {dig_immediate=3,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,attached_node=1,redstone_repeater=i}
	else
		groups = {dig_immediate=3,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,attached_node=1,redstone_repeater=i,not_in_creative_inventory=1}
	end

	local delaytime = DELAYS[i]

	local boxes
	if i == 1 then
		boxes = {
			{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },		-- the main slab
			{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16},     -- still torch
			{ -1/16, -6/16, 0/16, 1/16, -1/16, 2/16},     -- moved torch
		}
	elseif i == 2 then
		boxes = {
			{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },		-- the main slab
			{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16},     -- still torch
			{ -1/16, -6/16, -2/16, 1/16, -1/16, 0/16},     -- moved torch
		}
	elseif i == 3 then
		boxes = {
			{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },		-- the main slab
			{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16},     -- still torch
			{ -1/16, -6/16, -4/16, 1/16, -1/16, -2/16},     -- moved torch
		}
	elseif i == 4 then
		boxes = {
			{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },		-- the main slab
			{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16},     -- still torch
			{ -1/16, -6/16, -6/16, 1/16, -1/16, -4/16},     -- moved torch
		}
	end

	local help, tt, longdesc, usagehelp, icon, on_construct
	if i == 1 then
		help = true
		tt = S("Transmits redstone power only in one direction").."\n"..
			S("Delays signal").."\n"..
			S("Output locks when getting active redstone repeater signal from the side")
		longdesc = S("Redstone repeaters are versatile redstone components with multiple purposes: 1. They only allow signals to travel in one direction. 2. They delay the signal. 3. Optionally, they can lock their output in one state.")
		usagehelp = S("To power a redstone repeater, send a signal in “arrow” direction (the input). The signal goes out on the opposite side (the output) with a delay. To change the delay, use the redstone repeater. The delay is between 0.1 and 0.4 seconds long and can be changed in steps of 0.1 seconds. It is indicated by the position of the moving redstone torch.").."\n"..
				S("To lock a repeater, send a signal from an adjacent repeater into one of its sides. While locked, the moving redstone torch disappears, the output doesn't change and the input signal is ignored.")
		icon = "mesecons_delayer_item.png"
		-- Check sides of constructed repeater and lock it, if required
		on_construct = function(pos)
			local node = minetest.get_node(pos)
			local sides = delayer_get_sides(node)
			for s=1, #sides do
				local spos = vector.add(pos, sides[s])
				local snode = minetest.get_node(spos)
				-- Is there a powered repeater at one of our sides?
				local g = minetest.get_item_group(snode.name, "redstone_repeater")
				if g ~= 0 and mesecon.is_receptor_on(snode.name) then
					-- The other repeater must also face towards the constructed node
					local sface = delayer_get_output_rules(snode)[1]
					local sface_pos = vector.add(spos, sface)
					if vector.equals(sface_pos, pos) then
						-- Repeater is facing towards us! Now we just need to lock the costructed node
						if mesecon.is_powered(pos, delayer_get_input_rules(node)[1]) ~= false then
							local newnode = {name="mesecons_delayer:delayer_on_locked", param2 = node.param2}
							minetest.set_node(pos, newnode)
							mesecon.queue:add_action(pos, "receptor_on", {delayer_get_output_rules(newnode)}, DEFAULT_DELAY, nil)
						else
							minetest.set_node(pos, {name="mesecons_delayer:delayer_off_locked", param2 = node.param2})
						end
						break
					end
				end
			end
		end
	else
		help = false
	end

	local desc_off
	if i == 1 then
		desc_off = S("Redstone Repeater")
	else
		desc_off = S("Redstone Repeater (Delay @1)", i)
	end

	minetest.register_node("mesecons_delayer:delayer_off_"..tostring(i), {
		description = desc_off,
		inventory_image = icon,
		wield_image = icon,
		_tt_help = tt,
		_doc_items_create_entry = help,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		drawtype = "nodebox",
		tiles = {
			"mesecons_delayer_off.png",
			"mcl_stairs_stone_slab_top.png",
			"mesecons_delayer_sides_off.png",
			"mesecons_delayer_sides_off.png",
			"mesecons_delayer_ends_off.png",
			"mesecons_delayer_ends_off.png",
		},
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
		--wield_image = "mesecons_delayer_off.png",
		walkable = true,
		selection_box = {
			type = "fixed",
			fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
		},
		collision_box = {
			type = "fixed",
			fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
		},
		node_box = {
			type = "fixed",
			fixed = boxes
		},
		groups = groups,
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = false,
		is_ground_content = false,
		drop = "mesecons_delayer:delayer_off_1",
		on_rightclick = function(pos, node, clicker)
			local protname = clicker:get_player_name()
			if minetest.is_protected(pos, protname) then
				minetest.record_protection_violation(pos, protname)
				return
			end
			if node.name=="mesecons_delayer:delayer_off_1" then
				minetest.set_node(pos, {name="mesecons_delayer:delayer_off_2", param2=node.param2})
			elseif node.name=="mesecons_delayer:delayer_off_2" then
				minetest.set_node(pos, {name="mesecons_delayer:delayer_off_3", param2=node.param2})
			elseif node.name=="mesecons_delayer:delayer_off_3" then
				minetest.set_node(pos, {name="mesecons_delayer:delayer_off_4", param2=node.param2})
			elseif node.name=="mesecons_delayer:delayer_off_4" then
				minetest.set_node(pos, {name="mesecons_delayer:delayer_off_1", param2=node.param2})
			end
		end,
		on_construct = on_construct,
		delayer_time = delaytime,
		delayer_onstate = "mesecons_delayer:delayer_on_"..tostring(i),
		delayer_lockstate = "mesecons_delayer:delayer_off_locked",
		sounds = mcl_sounds.node_sound_stone_defaults(),
		mesecons = {
			receptor = {
				state = mesecon.state.off,
				rules = delayer_get_output_rules,
			},
			effector = {
				rules = delayer_get_input_rules,
				action_on = delayer_activate,
			},
		},
		on_rotate = on_rotate,
	})

	minetest.register_node("mesecons_delayer:delayer_on_"..tostring(i), {
		description = S("Redstone Repeater (Delay @1, Powered)", i),
		_doc_items_create_entry = false,
		drawtype = "nodebox",
		tiles = {
			"mesecons_delayer_on.png",
			"mcl_stairs_stone_slab_top.png",
			"mesecons_delayer_sides_on.png",
			"mesecons_delayer_sides_on.png",
			"mesecons_delayer_ends_on.png",
			"mesecons_delayer_ends_on.png",
		},
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
		walkable = true,
		selection_box = {
			type = "fixed",
			fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
		},
		collision_box = {
			type = "fixed",
			fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
		},
		node_box = {
			type = "fixed",
			fixed = boxes
		},
		groups = {dig_immediate = 3, dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1, attached_node=1, redstone_repeater=i, not_in_creative_inventory = 1},
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = false,
		is_ground_content = false,
		drop = "mesecons_delayer:delayer_off_1",
		on_rightclick = function(pos, node, clicker)
			local protname = clicker:get_player_name()
			if minetest.is_protected(pos, protname) then
				minetest.record_protection_violation(pos, protname)
				return
			end
			--HACK! we already know the node name, so we should generate the function to avoid multiple checks
			if node.name=="mesecons_delayer:delayer_on_1" then
				minetest.set_node(pos, {name="mesecons_delayer:delayer_on_2",param2=node.param2})
			elseif node.name=="mesecons_delayer:delayer_on_2" then
				minetest.set_node(pos, {name="mesecons_delayer:delayer_on_3",param2=node.param2})
			elseif node.name=="mesecons_delayer:delayer_on_3" then
				minetest.set_node(pos, {name="mesecons_delayer:delayer_on_4",param2=node.param2})
			elseif node.name=="mesecons_delayer:delayer_on_4" then
				minetest.set_node(pos, {name="mesecons_delayer:delayer_on_1",param2=node.param2})
			end
		end,
		after_dig_node = function(pos, oldnode)
			check_unlock_repeater(pos, oldnode)
		end,
		delayer_time = delaytime,
		delayer_offstate = "mesecons_delayer:delayer_off_"..tostring(i),
		delayer_lockstate = "mesecons_delayer:delayer_on_locked",
		sounds = mcl_sounds.node_sound_stone_defaults(),
		mesecons = {
			receptor = {
				state = mesecon.state.on,
				rules = delayer_get_output_rules,
			},
			effector = {
				rules = delayer_get_input_rules,
				action_off = delayer_deactivate,
			},
		},
		on_rotate = on_rotate,
	})
end


-- Locked repeater

minetest.register_node("mesecons_delayer:delayer_off_locked", {
	description = S("Redstone Repeater (Locked)"),
	_doc_items_create_entry = false,
	drawtype = "nodebox",
	-- FIXME: Textures of torch and the lock bar overlap. Nodeboxes are (sadly) not suitable for this.
	-- So this needs to be turned into a mesh.
	tiles = {
		"mesecons_delayer_locked_off.png",
		"mcl_stairs_stone_slab_top.png",
		"mesecons_delayer_sides_locked_off.png",
		"mesecons_delayer_sides_locked_off.png",
		"mesecons_delayer_front_locked_off.png",
		"mesecons_delayer_end_locked_off.png",
	},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	wield_image = "mesecons_delayer_locked_off.png",
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
	},
	collision_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 }, -- the main slab
			{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16}, -- still torch
			{ -6/16, -6/16, -1/16, 6/16, -4/16, 1/16}, -- lock
		}
	},
	groups = {dig_immediate = 3, dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1, attached_node=1, redstone_repeater=5, not_in_creative_inventory = 1},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = false,
	is_ground_content = false,
	drop = "mesecons_delayer:delayer_off_1",
	delayer_time = DEFAULT_DELAY,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {
		receptor =
		{
			state = mesecon.state.off,
			rules = delayer_get_output_rules
		},
		effector =
		{
			rules = delayer_get_input_rules,
		}
	},
	on_rotate = on_rotate,
})

minetest.register_node("mesecons_delayer:delayer_on_locked", {
	description = S("Redstone Repeater (Locked, Powered)"),
	_doc_items_create_entry = false,
	drawtype = "nodebox",
	tiles = {
		"mesecons_delayer_locked_on.png",
		"mcl_stairs_stone_slab_top.png",
		"mesecons_delayer_sides_locked_on.png",
		"mesecons_delayer_sides_locked_on.png",
		"mesecons_delayer_front_locked_on.png",
		"mesecons_delayer_end_locked_on.png",
	},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
	},
	collision_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 }, -- the main slab
			{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16}, -- still torch
			{ -6/16, -6/16, -1/16, 6/16, -4/16, 1/16}, -- lock
		}
	},
	after_dig_node = function(pos, oldnode)
		check_unlock_repeater(pos, oldnode)
	end,
	groups = {dig_immediate = 3, dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1, attached_node=1, redstone_repeater=5, not_in_creative_inventory = 1},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = false,
	is_ground_content = false,
	drop = "mesecons_delayer:delayer_off_1",
	delayer_time = DEFAULT_DELAY,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {
		receptor =
		{
			state = mesecon.state.on,
			rules = delayer_get_output_rules
		},
		effector =
		{
			rules = delayer_get_input_rules,
		}
	},
	on_rotate = on_rotate,
})

minetest.register_craft({
	output = "mesecons_delayer:delayer_off_1",
	recipe = {
		{"mesecons_torch:mesecon_torch_on", "mesecons:redstone", "mesecons_torch:mesecon_torch_on"},
		{"mcl_core:stone","mcl_core:stone", "mcl_core:stone"},
	}
})

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_delayer:delayer_off_1", "nodes", "mesecons_delayer:delayer_off_2")
	doc.add_entry_alias("nodes", "mesecons_delayer:delayer_off_1", "nodes", "mesecons_delayer:delayer_off_3")
	doc.add_entry_alias("nodes", "mesecons_delayer:delayer_off_1", "nodes", "mesecons_delayer:delayer_off_4")
	doc.add_entry_alias("nodes", "mesecons_delayer:delayer_off_1", "nodes", "mesecons_delayer:delayer_off_locked")
	doc.add_entry_alias("nodes", "mesecons_delayer:delayer_off_1", "nodes", "mesecons_delayer:delayer_on_1")
	doc.add_entry_alias("nodes", "mesecons_delayer:delayer_off_1", "nodes", "mesecons_delayer:delayer_on_2")
	doc.add_entry_alias("nodes", "mesecons_delayer:delayer_off_1", "nodes", "mesecons_delayer:delayer_on_3")
	doc.add_entry_alias("nodes", "mesecons_delayer:delayer_off_1", "nodes", "mesecons_delayer:delayer_on_4")
	doc.add_entry_alias("nodes", "mesecons_delayer:delayer_off_1", "nodes", "mesecons_delayer:delayer_on_locked")
end
