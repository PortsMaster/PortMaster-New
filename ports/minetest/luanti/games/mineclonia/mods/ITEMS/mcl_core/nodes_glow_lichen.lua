------------------------------------------------------------------------
-- Glow Lichen.
------------------------------------------------------------------------

local S = core.get_translator(core.get_current_modname())

local SOLID_FACE = mcl_util.decompose_AABBs ({{
	-0.5, -0.5, -0.5,
	0.5, 0.5, 0.5,
}})

local function test_wallmounted_face (pos, axis, dir)
	local node = core.get_node (pos)
	local def = core.registered_nodes[node.name]
	if not def or not def.walkable then
		return false
	end

	local boxes = core.get_node_boxes ("collision_box", pos)
	local shape = mcl_util.decompose_AABBs (boxes)
	local face = shape and shape:select_face (axis, dir * 0.5)
	return face and face:equal_p (SOLID_FACE)
end

function mcl_core.test_wallmounted_face (pointed_thing)
	local dir = vector.subtract (pointed_thing.under,
				     pointed_thing.above)
	local axis, param2

	if dir.x == 1 then
		axis, dir = "x", -1
		param2 = 2
	elseif dir.x == -1 then
		axis, dir = "x", 1
		param2 = 3
	elseif dir.z == 1 then
		axis, dir = "z", -1
		param2 = 4
	elseif dir.z == -1 then
		axis, dir = "z", 1
		param2 = 5
	elseif dir.y == 1 then
		axis, dir = "y", -1
		param2 = 0
	elseif dir.y == -1 then
		axis, dir = "y", 1
		param2 = 1
	else
		return nil
	end

	if test_wallmounted_face (pointed_thing.under, axis, dir) then
		return param2
	else
		return nil
	end
end

local tpl = {
	description = S ("Glow Lichen"),
	_doc_items_longdesc = S ("Naturally generating non-solid block that emits a faint light and can attach to any surface of a solid block."),
	inventory_image = "mcl_core_glow_lichen.png",
	wield_image = "mcl_core_glow_lichen.png",
	tiles = {"mcl_core_glow_lichen.png",},
	drawtype = "nodebox",
	use_texture_alpha = "clip",
	walkable = false,
	paramtype2 = "wallmounted",
	selection_box = {
		type = "fixed",
		fixed = {
			-0.5, -0.5, -0.5,
			0.5, -0.495, 0.5,
		},
	},
	node_box = {
		type = "fixed",
		fixed = {
			-0.5, -0.5, -0.5,
			0.5, -0.495, 0.5,
		},
	},
	groups = {
		handy = 1, axey = 1, shearsy = 1, swordy = 1, deco_block = 1,
		attached_node = 1, dig_by_piston = 1,
		compostability = 50, flammable = 2, fire_encouragement = 15,
		fire_flammability = 100, unsticky = 1, glow_lichen = 1,
	},
	sounds = mcl_sounds.node_sound_leaves_defaults (),
	drop = "",
	_mcl_shears_drop = true,
	node_placement_prediction = "",
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 7,
	_mcl_hardness = 0.2,
}

local dirs = {
	{ 1, 0, 0, 1, "z", -1, 3, }, -- Spread north, attaching to a south face.
	{ 2, -1, 0, 0, "x", 1, 4, }, -- Spread west, attaching to an east face.
	{ 3, 0, 0, -1, "z", 1, 1, }, -- Spread south, attaching to a north face.
	{ 4, 1, 0, 0, "x", -1, 2, }, -- Spread east, attaching to a west face.
	{ 5, 0, 1, 0, "y", -1, 6, }, -- Spread down, attaching to a top face.
	{ 6, 0, -1, 0, "y", 1, 5, }, -- Spread up, attaching to a bottom face.
}

local attachments = {
	{ true, false, false, false, false, false, },
	{ false, true, false, false, false, false, },
	{ false, false, true, false, false, false, },
	{ false, false, false, true, false, false, },
	{ false, false, false, false, true, false, },
	{ false, false, false, false, false, true, },
}

local function wallmounted_to_faces (param2)
	if param2 == 4 then
		return true, false, false, false, false, false
	elseif param2 == 5 then
		return false, false, true, false, false, false
	elseif param2 == 2 then
		return false, false, false, true, false, false
	elseif param2 == 3 then
		return false, true, false, false, false, false
	elseif param2 == 0 then
		return false, false, false, false, true, false
	else
		return false, false, false, false, false, true
	end
end

local function glow_lichen_attachments (node)
	local north, west, south, east, up, down
	local def = core.registered_nodes[node.name]
	if def._mcl_glow_lichen_faces then
		north, west, south, east, up, down
			= unpack (def._mcl_glow_lichen_faces)
	else
		north, west, south, east, up, down
			= wallmounted_to_faces (node.param2)
	end
	return {
		north, west, south, east, up, down,
	}
end

local function glow_lichen_params (north, west, south, east, up, down)
	local cnt = 0
	if north then
		cnt = cnt + 1
	end
	if south then
		cnt = cnt + 1
	end
	if west then
		cnt = cnt + 1
	end
	if east then
		cnt = cnt + 1
	end
	if up then
		cnt = cnt + 1
	end
	if down then
		cnt = cnt + 1
	end

	if cnt < 2 then
		local param2
		if north then
			param2 = 4
		elseif south then
			param2 = 5
		elseif east then
			param2 = 2
		elseif west then
			param2 = 3
		elseif up then
			param2 = 0
		else
			param2 = 1
		end
		return "mcl_core:glow_lichen", param2
	else
		local name = "mcl_core:glow_lichen_"
		if north then
			name = name .. "n"
		end
		if west then
			name = name .. "w"
		end
		if south then
			name = name .. "s"
		end
		if east then
			name = name .. "e"
		end
		if up then
			name = name .. "u"
		end
		if down then
			name = name .. "d"
		end
		return name, 0
	end
end

function tpl._on_bone_meal (itemstack, placer, pointed_thing, pos, node)
	local params = glow_lichen_attachments (node)
	local spread_poses = {}

	-- Evaluate where this glow lichen block may spread.  A glow
	-- lichen block is permitted to spread from its current
	-- position to a contacting face or to the sides of any block
	-- to which it is attached except along the axis of its
	-- attachment.

	for i = 1, #dirs do
		local dir = dirs[i]
		if not params[dir[1]] then
			-- Attempt to spread to an adjacent face.
			local off = vector.offset (pos, dir[2], dir[3], dir[4])
			if test_wallmounted_face (off, dir[5], dir[6]) then
				table.insert (spread_poses, {
					position = pos,
					spread_dir = i,
				})
			end
		else
			-- Or faces around this node.
			local pos_behind = vector.offset (pos, dir[2], dir[3], dir[4])
			for j = 1, #dirs do
				local dir1 = dirs[j]
				-- But not behind it.
				if j ~= i then
					-- Spread around this node.
					if test_wallmounted_face (pos_behind, dir1[5], dir1[6]) then
						table.insert (spread_poses, {
							position = vector.offset (pos_behind, -dir1[2],
										  -dir1[3], -dir1[4]),
							spread_dir = j,
						})
					end

					-- Spread crosswise.
					local off = vector.offset (pos_behind, dir1[2],
								   dir1[3], dir1[4])
					if test_wallmounted_face (off, dir[5], dir[6]) then
						local off_parallel_above
							= vector.offset (off, -dir[2], -dir[3],
									 -dir[4])
						table.insert (spread_poses, {
							position = off_parallel_above,
							spread_dir = i,
						})
					end
				end
			end
		end
	end

	if #spread_poses == 0 then
		return false
	end

	table.shuffle (spread_poses)

	-- Iterate through each eligible position and attempt to add a
	-- lichen attachment at that position and in the direction
	-- specified.
	for _, attachment in ipairs (spread_poses) do
		local node = core.get_node (attachment.position)
		local attachments = attachments[attachment.spread_dir]
		if core.get_item_group (node.name, "glow_lichen") > 0 then
			-- Merge attachments.
			local current = glow_lichen_attachments (node)
			for i = 1, #attachments do
				current[i] = attachments[i] or current[i]
			end
			local name, param2 = glow_lichen_params (unpack (current))
			if name ~= node.name or param2 ~= node.param2 then
				core.set_node (attachment.position, {
						       name = name,
						       param2 = param2,
				})
				return true
			end
		elseif node.name == "air" then
			local name, param2 = glow_lichen_params (unpack (attachments))
			core.set_node (attachment.position, {
					       name = name,
					       param2 = param2,
			})
			return true
		end
	end

	return false
end

local nodebox_north = {
	-0.5, -0.5, 0.495,
	0.5, 0.5, 0.500,
}

local nodebox_south = {
	-0.5, -0.5, -0.500,
	0.5, 0.5, -0.495,
}

local nodebox_west = {
	-0.500, -0.5, -0.5,
	-0.495, 0.5, 0.5,
}

local nodebox_east = {
	0.495, -0.5, -0.5,
	0.500, 0.5, 0.5,
}

local nodebox_up = {
	-0.5, 0.495, -0.5,
	0.5, 0.500, 0.5,
}

local nodebox_down = {
	-0.5, -0.500, -0.5,
	0.5, -0.495, 0.5,
}

local function register_glow_lichen (north, west, south, east, up, down)
	if north or west or south or east or up or down then
		local name = "mcl_core:glow_lichen_"
		local boxes = {}
		local shears_drops = {}
		local drop_name = "mcl_core:glow_lichen"
		if north then
			name = name .. "n"
			table.insert (boxes, nodebox_north)
			table.insert (shears_drops, drop_name)
		end
		if west then
			name = name .. "w"
			table.insert (boxes, nodebox_west)
			table.insert (shears_drops, drop_name)
		end
		if south then
			name = name .. "s"
			table.insert (boxes, nodebox_south)
			table.insert (shears_drops, drop_name)
		end
		if east then
			name = name .. "e"
			table.insert (boxes, nodebox_east)
			table.insert (shears_drops, drop_name)
		end
		if up then
			name = name .. "u"
			table.insert (boxes, nodebox_up)
			table.insert (shears_drops, drop_name)
		end
		if down then
			name = name .. "d"
			table.insert (boxes, nodebox_down)
			table.insert (shears_drops, drop_name)
		end
		local tbl = table.merge (tpl, {
			groups = table.merge (tpl.groups, {
				attached_node = 0,
				not_in_creative_inventory = 1,
			}),
			paramtype2 = "none",
			drawtype = "nodebox",
			node_box = {
				type = "fixed",
				fixed = boxes,
			},
			selection_box = {
				type = "fixed",
				fixed = boxes,
			},
			_mcl_shears_drop = shears_drops,
			_mcl_glow_lichen_faces = {
				north,
				west,
				south,
				east,
				up,
				down,
			},
		})
		core.register_node (name, tbl)
	end
end

for n = 0, 1 do
	for w = 0, 1 do
		for s = 0, 1 do
			for e = 0, 1 do
				for u = 0, 1 do
					for d = 0, 1 do
						register_glow_lichen (n > 0,
								      w > 0,
								      s > 0,
								      e > 0,
								      u > 0,
								      d > 0)
					end
				end
			end
		end
	end
end

local function glow_lichen_merge (node, itemstack, pos, param2, placer)
	if placer:is_player () then
		local name = placer:get_player_name ()
		if core.is_protected (pos, name) then
			core.record_protection_violation (pos, name)
			return itemstack
		end
	end

	local def = core.registered_nodes[node.name]
	local north, west, south, east, up, down
	local north1, west1, south1, east1, up1, down1
	assert (def)
	if def._mcl_glow_lichen_faces then
		north, west, south, east, up, down
			= unpack (def._mcl_glow_lichen_faces)
	else
		north, west, south, east, up, down
			= wallmounted_to_faces (node.param2)
	end
	north1, west1, south1, east1, up1, down1
		= wallmounted_to_faces (param2)

	if (north1 or north) ~= north
		or (south1 or south) ~= south
		or (west1 or west) ~= west
		or (east1 or east) ~= east
		or (up1 or up) ~= up
		or (down1 or down) ~= down then
		local name = placer:get_player_name ()
		if not placer:is_player ()
			or not core.is_creative_enabled (name) then
			itemstack:take_item ()
		end
		local name, param2 = glow_lichen_params (north1 or north,
							 west1 or west,
							 south1 or south,
							 east1 or east,
							 up1 or up,
							 down1 or down)
		core.set_node (pos, {
			name = name,
			param2 = param2,
		})
	end
	return itemstack
end

local glow_lichen_item = table.copy (tpl)

function glow_lichen_item.on_place (itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		-- No interaction possible with entities.
		return itemstack
	end

	local name = core.get_node (pointed_thing.under).name
	local def = core.registered_nodes[name]
	if not (def and def.walkable) then
		return itemstack
	end
	local param2 = mcl_core.test_wallmounted_face (pointed_thing)
	if not param2 then
		return itemstack
	end
	local node_at_pos = core.get_node (pointed_thing.above)
	if core.get_item_group (node_at_pos.name, "glow_lichen") > 0 then
		itemstack = glow_lichen_merge (node_at_pos, itemstack,
					       pointed_thing.above, param2,
					       placer)
		return itemstack
	end
	return core.item_place_node (itemstack, placer,
				     pointed_thing, param2)
end

core.register_node ("mcl_core:glow_lichen", glow_lichen_item)
