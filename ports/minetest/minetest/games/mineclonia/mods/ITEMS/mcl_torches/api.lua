local function chech_valid_nodes(name)
	local valid_nodes = {
		"mcl_core:barrier",
		"mcl_core:ice",
		"mcl_end:chorus_flower",
		"mcl_end:chorus_flower_dead",
		"mcl_mobspawners:spawner",
		"mcl_nether:soul_sand"
	}
	local valid_groups = {"glass", "opaque", "solid"}

	for _, n in pairs(valid_nodes) do
		if n == name then return true end
	end

	for _, g in pairs(valid_groups) do
		if core.get_item_group(name, g) ~= 0 then return true end
	end

	return false
end

local function check_wdir1_exceptions(name, facedir)
	local valid_nodes = {
		"mcl_end:dragon_egg",
		"mcl_portals:end_portal_frame_eye"
	}
	local valid_groups = {"anvil", "fence", "pane", "slab_top", "wall"}

	for _, n in pairs(valid_nodes) do
		if n == name then return true end
	end

	for _, g in pairs(valid_groups) do
		if core.get_item_group(name, g) ~= 0 then return true end
	end

	if core.get_item_group(name, "stairs") == 1 and core.facedir_to_dir(facedir).y ~= 0 then
		return true
	end

	return false
end
-- Check if placement at given node is allowed
local function check_placement_allowed(node, wdir)
	-- Torch placement rules: Disallow placement on some nodes. General rule: Solid, opaque, full cube collision box nodes are allowed.
	-- Special allowed nodes:
	-- * soul sand
	-- * mob spawner
	-- * chorus flower
	-- * glass, barrier, ice
	-- * Fence, wall, end portal frame with ender eye: Only on top
	-- * Slab, stairs: Only on top if upside down

	-- Special forbidden nodes:
	-- * Piston, sticky piston
	local name = node.name
	local defs = core.registered_nodes[name]

	if not defs or core.get_item_group(name, "piston") >= 1 then
		return false
	end

	if wdir == 0 then
		return false
	elseif not defs.buildable_to then
		if not chech_valid_nodes(name) then
			if wdir == 1 then
				return check_wdir1_exceptions(name, node.param2)
			end
		else
			return true
		end
	end

	return true
end

function mcl_torches.register_torch(def)
	local itemstring = core.get_current_modname() .. ":" .. def.name
	local itemstring_wall = itemstring .. "_wall"

	def.light = def.light or 14
	def.mesh_floor = def.mesh_floor or "mcl_torches_torch_floor.obj"
	def.mesh_wall = def.mesh_wall or "mcl_torches_torch_wall.obj"
	def.flame_type = def.flame_type or 1

	local groups = def.groups or {}

	groups.attached_node = 1
	groups.torch = 1
	groups.torch_particles = def.particles and 1
	groups.dig_by_water = 1
	groups.destroy_by_lava_flow = 1
	groups.dig_by_piston = 1
	groups.unsticky = 1
	groups.flame_type = def.flame_type or 1
	groups.attaches_to_top = 1
	groups.attaches_to_side = 1
	groups.offhand_item = 1
	groups.offhand_placeable = 1

	local floordef = {
		description = def.description,
		_doc_items_longdesc = def.doc_items_longdesc,
		_doc_items_usagehelp = def.doc_items_usagehelp,
		_doc_items_hidden = def.doc_items_hidden,
		_doc_items_create_entry = def._doc_items_create_entry,
		drawtype = "mesh",
		mesh = def.mesh_floor,
		inventory_image = def.icon,
		wield_image = def.icon,
		tiles = def.tiles,
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		light_source = def.light,
		groups = groups,
		drop = def.drop or itemstring,
		use_texture_alpha = "clip",
		selection_box = {
			type = "wallmounted",
			wall_bottom = {-2/16, -0.5, -2/16, 2/16, 1/16, 2/16},
		},
		sounds = def.sounds,
		node_placement_prediction = "",
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				-- no interaction possible with entities, for now.
				return itemstack
			end

			local under = pointed_thing.under
			local node = core.get_node(under)
			local def = core.registered_nodes[node.name]
			if not def then return itemstack end

			-- Call on_rightclick if the pointed node defines it
			local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
			if rc ~= nil then return rc end --check for nil explicitly to determine if on_rightclick existed

			local above = pointed_thing.above
			local wdir = core.dir_to_wallmounted({x = under.x - above.x, y = under.y - above.y, z = under.z - above.z})

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
			elseif check_placement_allowed(node, wdir) == false then
				return itemstack
			end

			local itemstring = itemstack:get_name()
			local fakestack = ItemStack(itemstack)
			local idef = fakestack:get_definition()
			local retval

			if wdir == 1 then
				retval = fakestack:set_name(itemstring)
			else
				retval = fakestack:set_name(itemstring_wall)
			end
			if not retval then
				return itemstack
			end

			local success
			itemstack, success = core.item_place_node(fakestack, placer, pointed_thing, wdir)
			itemstack:set_name(itemstring)

			if success and idef.sounds and idef.sounds.place then
				core.sound_play(idef.sounds.place, {pos=under, gain=1}, true)
			end
			return itemstack
		end,
		on_rotate = false,
	}
	core.register_node(itemstring, floordef)

	local groups_wall = table.copy(groups)
	groups_wall.torch = 2
	groups_wall.not_in_creative_inventory = 1

	local walldef = {
		drawtype = "mesh",
		mesh = def.mesh_wall,
		tiles = def.tiles,
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		light_source = def.light,
		groups = groups_wall,
		drop = def.drop or itemstring,
		use_texture_alpha = "clip",
		_mcl_baseitem = itemstring,
		selection_box = {
			type = "wallmounted",
			wall_side = {-0.5, -0.3, -0.1, -0.2, 0.325, 0.1},
		},
		sounds = def.sounds,
		on_rotate = false,
	}
	core.register_node(itemstring_wall, walldef)

	doc.add_entry_alias("nodes", itemstring, "nodes", itemstring_wall)
end
