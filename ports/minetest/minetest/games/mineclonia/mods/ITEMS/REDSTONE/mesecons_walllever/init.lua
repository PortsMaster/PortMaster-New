local S = minetest.get_translator(minetest.get_current_modname())

local lever_get_output_rules = mesecon.rules.buttonlike_get

local function on_rotate(pos, node, user, mode)
	if mode == screwdriver.ROTATE_FACE then
		if node.param2 == 10 then
			node.param2 = 13
			minetest.swap_node(pos, node)
			return true
		elseif node.param2 == 13 then
			node.param2 = 10
			minetest.swap_node(pos, node)
			return true
		elseif node.param2 == 8 then
			node.param2 = 15
			minetest.swap_node(pos, node)
			return true
		elseif node.param2 == 15 then
			node.param2 = 8
			minetest.swap_node(pos, node)
			return true
		end
	end
	-- TODO: Rotate axis
	return false
end

-- LEVER
minetest.register_node("mesecons_walllever:wall_lever_off", {
	drawtype = "mesh",
	tiles = {
		"jeija_wall_lever_lever_light_on.png",
	},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	inventory_image = "jeija_wall_lever.png",
	wield_image = "jeija_wall_lever.png",
	paramtype = "light",
	paramtype2 = "facedir",
	mesh = "jeija_wall_lever_off.obj",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -4/16, 2/16, 3/16, 4/16, 8/16 },
	},
	groups = {
		handy = 1,
		dig_by_water = 1,
		destroy_by_lava_flow = 1,
		dig_by_piston = 1,
		attached_node_facedir = 1,
		attaches_to_base = 1,
		attaches_to_side = 1,
		attaches_to_top = 1
	},
	is_ground_content = false,
	description=S("Lever"),
	_tt_help = S("Provides redstone power while it's turned on"),
	_doc_items_longdesc = S("A lever is a redstone component which can be flipped on and off. It supplies redstone power to adjacent blocks while it is in the “on” state."),
	_doc_items_usagehelp = S("Use the lever to flip it on or off."),
	on_rightclick = function(pos, node)
		minetest.swap_node(pos, {name="mesecons_walllever:wall_lever_on", param2=node.param2})
		mesecon.receptor_on(pos, lever_get_output_rules(node))
		minetest.sound_play("mesecons_button_push", {pos=pos, max_hear_distance=16}, true)
	end,
	node_placement_prediction = "",
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
			-- no interaction possible with entities
			return itemstack
		end

		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local def = minetest.registered_nodes[node.name]
		if not def then return end
		local groups = def.groups

		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		-- If the pointed node is buildable, let's look at the node *behind* that node
		if def.buildable_to then
			local dir = vector.subtract(pointed_thing.above, pointed_thing.under)
			local actual = vector.subtract(under, dir)
			local actualnode = minetest.get_node(actual)
			def = minetest.registered_nodes[actualnode.name]
			groups = def.groups
		end

		-- Only allow placement on full-cube solid opaque nodes
		if type(def.placement_prevented) == "function" then
			if
				def.placement_prevented({
					itemstack = itemstack,
					placer = placer,
					pointed_thing = pointed_thing,
				})
			then
				return itemstack
			end
		elseif (not groups) or (not groups.solid) or (not groups.opaque) or (def.node_box and def.node_box.type ~= "regular") then
			return itemstack
		end

		local above = pointed_thing.above
		local dir = vector.subtract(under, above)
		local tau = math.pi*2
		local wdir = minetest.dir_to_facedir(dir, true)
		if dir.y ~= 0 then
			local yaw = placer:get_look_horizontal()
			if (yaw > tau/8 and yaw < (tau/8)*3) or (yaw < (tau/8)*7 and yaw > (tau/8)*5) then
				if dir.y == -1 then
					wdir = 13
				else
					wdir = 15
				end
			else
				if dir.y == -1 then
					wdir = 10
				else
					wdir = 8
				end
			end
		end

		local idef = itemstack:get_definition()
		local itemstack, success = minetest.item_place_node(itemstack, placer, pointed_thing, wdir)

		if success then
			if idef.sounds and idef.sounds.place then
				minetest.sound_play(idef.sounds.place, {pos=above, gain=1}, true)
			end
		end
		return itemstack
	end,

	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {receptor = {
		rules = lever_get_output_rules,
		state = mesecon.state.off
	}},
	on_rotate = on_rotate,
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})
minetest.register_node("mesecons_walllever:wall_lever_on", {
	drawtype = "mesh",
	tiles = {
		"jeija_wall_lever_lever_light_on.png",
	},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	paramtype = "light",
	paramtype2 = "facedir",
	mesh = "jeija_wall_lever_on.obj",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -4/16, 2/16, 3/16, 4/16, 8/16 },
	},
	groups = {handy=1, not_in_creative_inventory = 1, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1, attached_node_facedir=1},
	is_ground_content = false,
	drop = "mesecons_walllever:wall_lever_off",
	_doc_items_create_entry = false,
	on_rightclick = function(pos, node)
		minetest.swap_node(pos, {name="mesecons_walllever:wall_lever_off", param2=node.param2})
		mesecon.receptor_off(pos, lever_get_output_rules(node))
		minetest.sound_play("mesecons_button_push", {pos=pos, max_hear_distance=16, pitch=0.9}, true)
	end,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {receptor = {
		rules = lever_get_output_rules,
		state = mesecon.state.on
	}},
	on_rotate = on_rotate,
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

minetest.register_craft({
	output = "mesecons_walllever:wall_lever_off",
	recipe = {
		{"mcl_core:stick"},
		{"mcl_core:cobble"},
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_walllever:wall_lever_off", "nodes", "mesecons_walllever:wall_lever_on")
end
