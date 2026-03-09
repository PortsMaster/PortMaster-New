local S = core.get_translator(core.get_current_modname())

mcl_buttons = {}

-- Push the button
function mcl_buttons.push_button(pos, node)
	local def = core.registered_nodes[node.name]
	core.set_node(pos, {name="mcl_buttons:button_"..def._mcl_button_basename.."_on", param2=node.param2})
	core.sound_play(def._mcl_redstone_push_sound, {pos=pos}, true)
end

local function on_button_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
		-- no interaction possible with entities
		return itemstack
	end

	local under = pointed_thing.under
	local node = core.get_node(under)
	local def = core.registered_nodes[node.name]
	if not def then return end
	local groups = def.groups

	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	-- If the pointed node is buildable, let's look at the node *behind* that node
	if def.buildable_to then
		local dir = vector.subtract(pointed_thing.above, pointed_thing.under)
		local actual = vector.subtract(under, dir)
		local actualnode = core.get_node(actual)
		def = core.registered_nodes[actualnode.name]
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
	elseif
		not groups
		or not groups.solid
		or not groups.opaque
		or (def.node_box and def.node_box.type ~= "regular")
	then
		return itemstack
	end

	local idef = itemstack:get_definition()
	local itemstack, success = core.item_place_node(itemstack, placer, pointed_thing)

	if success then
		if idef.sounds and idef.sounds.place then
			core.sound_play(idef.sounds.place, {pos=pointed_thing.above, gain=1}, true)
		end
	end
	return itemstack
end

function mcl_buttons.register_button(basename, def)
	local description = def.description
	local texture = def.texture
	local recipeitem = def.recipeitem
	local groups = def.groups
	local sounds = def.sounds
	local push_by_arrow = def.push_by_arrow
	local longdesc = def.longdesc
	local push_duration = def.push_duration
	local push_sound = def.push_sound
	local burntime = def.burntime

	local push_duration_in_seconds = push_duration * mcl_redstone.tick_speed
	local tt = S("Provides redstone power when pushed")
	tt = tt .. "\n" .. S("Push duration: @1s", string.format("%.1f", push_duration_in_seconds ))
	if push_by_arrow then
		tt = tt .. "\n" .. S("Pushable by arrow")
	end
	local commdef = {
		drawtype = "nodebox",
		tiles = {texture},
		wield_image = "mesecons_button_wield_mask.png^"..texture.."^mesecons_button_wield_mask.png^[makealpha:255,126,126",
		inventory_image = "mesecons_button_wield_mask.png^"..texture.."^mesecons_button_wield_mask.png^[makealpha:255,126,126",
		wield_scale = { x=1, y=1, z=1},
		paramtype = "light",
		paramtype2 = "wallmounted",
		is_ground_content = false,
		walkable = false,
		sunlight_propagates = true,
		groups = table.merge(groups, {attached_node=1, dig_by_water=1, dig_by_piston=1, button=1, attaches_to_base=1, attaches_to_side=1, attaches_to_top=1, button_push_by_arrow = push_by_arrow and 1 or 0}),
		description = description,
		_tt_help = tt,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = S("Use the button to push it."),
		on_place = on_button_place,
		node_placement_prediction = "",
		sounds = sounds,
		_mcl_hardness = 0.5,
		_mcl_button_basename = basename,
		_mcl_burntime = burntime,
		_mcl_redstone_push_sound = push_sound or "mesecons_button_push",
		_mcl_redstone = {
			connects_to = function(node)
				return true
			end,
		},
	}

	core.register_node(":mcl_buttons:button_"..basename.."_off", table.merge(commdef, {
		node_box = {
			type = "wallmounted",
			wall_side = { -8/16, -2/16, -4/16, -6/16, 2/16, 4/16 },
			wall_bottom = { -4/16, -8/16, -2/16, 4/16, -6/16, 2/16 },
			wall_top = { -4/16, 6/16, -2/16, 4/16, 8/16, 2/16 },
		},
		groups = table.merge(commdef.groups, {button=1}),
		on_rightclick = function(pos, node)
			mcl_buttons.push_button(pos, node)
		end,
		sounds = sounds,
		_on_arrow_hit = function(pos, arrowent)
			local node = core.get_node(pos)
			local bdir = core.wallmounted_to_dir(node.param2)
			if vector.equals(vector.add(pos, bdir), arrowent._stuckin) then
				mcl_buttons.push_button(pos, node)
				return true
			end
		end,
	}))

	core.register_node(":mcl_buttons:button_"..basename.."_on", table.merge(commdef, {
		node_box = {
			type = "wallmounted",
			wall_side = { -8/16, -2/16, -4/16, -7/16, 2/16, 4/16 },
			wall_bottom = { -4/16, -8/16, -2/16, 4/16, -7/16, 2/16 },
			wall_top = { -4/16, 7/16, -2/16, 4/16, 8/16, 2/16 },
		},
		groups = table.merge(commdef.groups, {button=2, button_on=1, not_in_creative_inventory=1}),
		drop = "mcl_buttons:button_"..basename.."_off",
		_doc_items_create_entry = false,
		_mcl_redstone = table.merge(commdef._mcl_redstone, {
			get_power = function(node, dir)
				return 15, node.param2 == core.dir_to_wallmounted(dir)
			end,
			init = function(pos, node)
				mcl_redstone.after(push_duration, function()
					core.sound_play(push_sound, {pos=pos, pitch=0.9}, true)
				end)
				return {
					delay = push_duration,
					name = "mcl_buttons:button_"..basename.."_off",
					param2 = node.param2,
				}
			end,
		}),
	}))

	core.register_craft({
		output = "mcl_buttons:button_"..basename.."_off",
		recipe = {{ recipeitem }},
	})
end

mcl_buttons.register_button("stone", {
	description = S("Stone Button"),
	texture = "default_stone.png",
	recipeitem = "mcl_core:stone",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {material_stone=1,handy=1,pickaxey=1},
	push_duration = 10,
	push_by_arrow = false,
	longdesc = S("A stone button is a redstone component made out of stone which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1 second."),
	push_sound = "mesecons_button_push",
})

mcl_buttons.register_button("polished_blackstone", {
	description = S("Polished Blackstone Button"),
	texture = "mcl_blackstone_polished.png",
	recipeitem = "mcl_blackstone:blackstone_polished",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {material_stone=1,handy=1,pickaxey=1},
	push_duration = 10,
	push_by_arrow = false,
	longdesc = S("A polished blackstone button is a redstone component made out of polished blackstone which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1 second."),
	push_sound = "mesecons_button_push",
})

doc.add_entry_alias("nodes", "mcl_buttons:button_wood_off", "nodes", "mcl_buttons:button_wood_on")
doc.add_entry_alias("nodes", "mcl_buttons:button_stone_off", "nodes", "mcl_buttons:button_stone_on")
