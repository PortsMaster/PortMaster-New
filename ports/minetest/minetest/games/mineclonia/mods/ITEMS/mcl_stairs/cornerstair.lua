-- Corner stairs handling

-- This code originally copied from the [mcstair] mod and merged into this mod.
-- This file is licensed under CC0.

mcl_stairs.cornerstair = {}

local function get_stair_param(node)
	local stair = minetest.get_item_group(node.name, "stair")
	if stair == 1 then
		return node.param2
	elseif stair == 2 then
		if node.param2 < 12 then
			return node.param2 + 4
		else
			return node.param2 - 4
		end
	elseif stair == 3 then
		if node.param2 < 12 then
			return node.param2 + 8
		else
			return node.param2 - 8
		end
	end
end

local function get_stair_from_param(param, stairs)
	if param < 12 then
		if param < 4 then
			return {name = stairs[1], param2 = param}
		elseif param < 8 then
			return {name = stairs[2], param2 = param - 4}
		else
			return {name = stairs[3], param2 = param - 8}
		end
	else
		if param >= 20 then
			return {name = stairs[1], param2 = param}
		elseif param >= 16 then
			return {name = stairs[2], param2 = param + 4}
		else
			return {name = stairs[3], param2 = param + 8}
		end
	end
end

local function stair_param_to_connect(param, ceiling)
	local out = {false, false, false, false, false, false, false, false}
	if not ceiling then
		if param == 0 then
			out[3] = true
			out[8] = true
		elseif param == 1 then
			out[2] = true
			out[5] = true
		elseif param == 2 then
			out[4] = true
			out[7] = true
		elseif param == 3 then
			out[1] = true
			out[6] = true
		elseif param == 4 then
			out[1] = true
			out[8] = true
		elseif param == 5 then
			out[2] = true
			out[3] = true
		elseif param == 6 then
			out[4] = true
			out[5] = true
		elseif param == 7 then
			out[6] = true
			out[7] = true
		elseif param == 8 then
			out[3] = true
			out[6] = true
		elseif param == 9 then
			out[5] = true
			out[8] = true
		elseif param == 10 then
			out[2] = true
			out[7] = true
		elseif param == 11 then
			out[1] = true
			out[4] = true
		end
	else
		if param == 12 then
			out[5] = true
			out[8] = true
		elseif param == 13 then
			out[3] = true
			out[6] = true
		elseif param == 14 then
			out[1] = true
			out[4] = true
		elseif param == 15 then
			out[2] = true
			out[7] = true
		elseif param == 16 then
			out[2] = true
			out[3] = true
		elseif param == 17 then
			out[1] = true
			out[8] = true
		elseif param == 18 then
			out[6] = true
			out[7] = true
		elseif param == 19 then
			out[4] = true
			out[5] = true
		elseif param == 20 then
			out[3] = true
			out[8] = true
		elseif param == 21 then
			out[1] = true
			out[6] = true
		elseif param == 22 then
			out[4] = true
			out[7] = true
		elseif param == 23 then
			out[2] = true
			out[5] = true
		end
	end
	return out
end

local function stair_connect_to_param(connect, ceiling)
	local param
	if not ceiling then
		if connect[3] and connect[8] then
			param = 0
		elseif connect[2] and connect[5] then
			param = 1
		elseif connect[4] and connect[7] then
			param = 2
		elseif connect[1] and connect[6] then
			param = 3
		elseif connect[1] and connect[8] then
			param = 4
		elseif connect[2] and connect[3] then
			param = 5
		elseif connect[4] and connect[5] then
			param = 6
		elseif connect[6] and connect[7] then
			param = 7
		elseif connect[3] and connect[6] then
			param = 8
		elseif connect[5] and connect[8] then
			param = 9
		elseif connect[2] and connect[7] then
			param = 10
		elseif connect[1] and connect[4] then
			param = 11
		end
	else
		if connect[5] and connect[8] then
			param = 12
		elseif connect[3] and connect[6] then
			param = 13
		elseif connect[1] and connect[4] then
			param = 14
		elseif connect[2] and connect[7] then
			param = 15
		elseif connect[2] and connect[3] then
			param = 16
		elseif connect[1] and connect[8] then
			param = 17
		elseif connect[6] and connect[7] then
			param = 18
		elseif connect[4] and connect[5] then
			param = 19
		elseif connect[3] and connect[8] then
			param = 20
		elseif connect[1] and connect[6] then
			param = 21
		elseif connect[4] and connect[7] then
			param = 22
		elseif connect[2] and connect[5] then
			param = 23
		end
	end
	return param
end

local function placement_prevented_inner(params)

	if params == nil or params.itemstack == nil or params.pointed_thing == nil then
		return true
	end

	local wield_name = params.itemstack:get_name()
	local ndef = minetest.registered_nodes[wield_name]
	local groups = ndef.groups or {}

	local under = params.pointed_thing.under
	local node = minetest.get_node(under)
	local above = params.pointed_thing.above
	local wdir = minetest.dir_to_wallmounted({ x = under.x - above.x, y = under.y - above.y, z = under.z - above.z })

	-- on top of upside down
	if groups.attaches_to_top and (node.param2 >= 20 and wdir == 1) then
		return false
	end

	-- on base of upright stair
	if groups.attaches_to_base and (node.param2 < 20 and wdir == 0) then
		return false
	end

	-- On back of rotated stair, corners have 2 backs
	if
		groups.attaches_to_side
		and (
			-- upright
			(node.param2 == 0 and wdir == 2)
			or (node.param2 == 0 and wdir == 5)
			or (node.param2 == 1 and wdir == 3)
			or (node.param2 == 1 and wdir == 5)
			or (node.param2 == 2 and wdir == 3)
			or (node.param2 == 2 and wdir == 4)
			or (node.param2 == 3 and wdir == 2)
			or (node.param2 == 3 and wdir == 4)
			-- upside down
			or (node.param2 == 20 and wdir == 3)
			or (node.param2 == 20 and wdir == 5)
			or (node.param2 == 21 and wdir == 2)
			or (node.param2 == 21 and wdir == 5)
			or (node.param2 == 22 and wdir == 2)
			or (node.param2 == 22 and wdir == 4)
			or (node.param2 == 23 and wdir == 3)
			or (node.param2 == 23 and wdir == 4)
		)
	then
		return false
	end

	return true
end

local function placement_prevented_outer(params)

	if params == nil or params.itemstack == nil or params.pointed_thing == nil then
		return true
	end

	local wield_name = params.itemstack:get_name()
	local ndef = minetest.registered_nodes[wield_name]
	local groups = ndef.groups or {}

	local under = params.pointed_thing.under
	local node = minetest.get_node(under)
	local above = params.pointed_thing.above
	local wdir = minetest.dir_to_wallmounted({ x = under.x - above.x, y = under.y - above.y, z = under.z - above.z })

	-- on top of upside down
	if groups.attaches_to_top and (node.param2 >= 20 and wdir == 1) then
		return false
	end

	-- on base of upright stair
	if groups.attaches_to_base and (node.param2 < 20 and wdir == 0) then
		return false
	end

	return true
end

--[[
mcl_stairs.cornerstair.add(name, stairtiles)

NOTE: This function is used internally. If you register a stair, this function is already called, no
need to call it again!

Usage:
* name is the name of the node to make corner stairs for.
* stairtiles is optional, can specify textures for inner and outer stairs. 3 data types are accepted:
    * string: one of:
        * "default": Use same textures as original node
        * "woodlike": Take first frame of the original tiles, then take a triangle piece
                      of the texture, rotate it by 90° and overlay it over the original texture
    * table: Specify textures explicitly. Table of tiles to override textures for
             inner and outer stairs. Table format:
                 { tiles_def_for_outer_stair, tiles_def_for_inner_stair }
    * nil: Equivalent to "default"
]]

local directions = {
	{ -1, 0, 0 },
	{ 1, 0, 0 },
	{ 0, 0, -1 },
	{ 0, 0, 1 },
}

local function check_sides(pos)
	local source = minetest.get_node(pos)

	local def = minetest.registered_nodes[source.name]

	for _, offset in pairs(directions) do
		local npos = vector.offset(pos, offset[1], offset[2], offset[3])
		local node = minetest.get_node(npos)
		local ndef = minetest.registered_nodes[node.name]
		local groups = ndef.groups or {}

		if groups.attaches_to_base or groups.attaches_to_side or groups.attaches_to_top then
			if
				def.placement_prevented({
					itemstack = ItemStack(node.name),
					pointed_thing = { under = pos, above = npos },
				})
			then
				mcl_attached.drop_attached_node(npos)
			end
		end
	end
end

function mcl_stairs.cornerstair.add(name, stairtiles)
	local node_def = minetest.registered_nodes[name]
	local outer_tiles
	local inner_tiles
	if stairtiles ~= nil and stairtiles ~= "default" and stairtiles ~= "woodlike" then
		outer_tiles = stairtiles[1]
		inner_tiles = stairtiles[2]
	end
	if inner_tiles == nil then inner_tiles = node_def.tiles end
	if outer_tiles == nil then outer_tiles = node_def.tiles end
	local outer_groups = table.copy(node_def.groups)
	outer_groups.not_in_creative_inventory = 1
	local inner_groups = table.copy(outer_groups)
	outer_groups.stair = 2
	outer_groups.not_in_craft_guide = 1
	inner_groups.stair = 3
	inner_groups.not_in_craft_guide = 1
	local drop = node_def.drop or name
	local function after_dig_node(pos, oldnode)
		local param = get_stair_param(oldnode)
		local ceiling
		if param < 12 then
			ceiling = false
		else
			ceiling = true
		end
		local connect = stair_param_to_connect(param, ceiling)
		local t = {
			{pos = {x = pos.x, y = pos.y, z = pos.z + 2}},
			{pos = {x = pos.x - 1, y = pos.y, z = pos.z + 1}}, {pos = {x = pos.x, y = pos.y, z = pos.z + 1}}, {pos = {x = pos.x + 1, y = pos.y, z = pos.z + 1}},
			{pos = {x = pos.x - 2, y = pos.y, z = pos.z}}, {pos = {x = pos.x - 1, y = pos.y, z = pos.z}},
			{pos = pos, connect = connect},
			{pos = {x = pos.x + 1, y = pos.y, z = pos.z}}, {pos = {x = pos.x + 2, y = pos.y, z = pos.z}},
			{pos = {x = pos.x - 1, y = pos.y, z = pos.z - 1}}, {pos = {x = pos.x, y = pos.y, z = pos.z - 1}}, {pos = {x = pos.x + 1, y = pos.y, z = pos.z - 1}},
			{pos = {x = pos.x, y = pos.y, z = pos.z - 2}}
		}
		for i,v in ipairs(t) do
			if not v.connect then
				local node = minetest.get_node(v.pos)
				local node_def = minetest.registered_nodes[node.name]
				if not node_def then
					return
				end
				if node_def.stairs then
					t[i].stairs = node_def.stairs
					t[i].connect = stair_param_to_connect(get_stair_param(node), ceiling)
				else
					t[i].connect = {false, false, false, false, false, false, false, false}
				end
			end
		end
		local function swap_stair(index, n1, n2)
			local connect = {false, false, false, false, false, false, false, false}
			connect[n1] = true
			connect[n2] = true
			local node = get_stair_from_param(stair_connect_to_param(connect, ceiling), t[index].stairs)
			minetest.swap_node(t[index].pos, node)
			check_sides(t[index].pos)
		end
		if t[3].stairs then
			if t[7].connect[1] and t[3].connect[6] then
				if t[3].connect[1] and t[1].connect[6] then
					if t[2].connect[3] then
						swap_stair(3, 1, 8)
					elseif t[4].connect[7] then
						swap_stair(3, 1, 4)
					end
				elseif t[3].connect[7] then
					swap_stair(3, 4, 7)
				elseif t[3].connect[3] then
					swap_stair(3, 3, 8)
				end
			elseif t[7].connect[2] and t[3].connect[5] then
				if t[3].connect[2] and t[1].connect[5] then
					if t[4].connect[8] then
						swap_stair(3, 2, 3)
					elseif t[2].connect[4] then
						swap_stair(3, 2, 7)
					end
				elseif t[3].connect[4] then
					swap_stair(3, 4, 7)
				elseif t[3].connect[8] then
					swap_stair(3, 3, 8)
				end
			end
		end
		if t[8].stairs then
			if t[7].connect[3] and t[8].connect[8] then
				if t[8].connect[3] and t[9].connect[8] then
					if t[4].connect[5] then
						swap_stair(8, 2, 3)
					elseif t[12].connect[1] then
						swap_stair(8, 3, 6)
					end
				elseif t[8].connect[1] then
					swap_stair(8, 1, 6)
				elseif t[8].connect[5] then
					swap_stair(8, 2, 5)
				end
			elseif t[7].connect[4] and t[8].connect[7] then
				if t[8].connect[4] and t[9].connect[7] then
					if t[12].connect[2] then
						swap_stair(8, 4, 5)
					elseif t[4].connect[6] then
						swap_stair(8, 1, 4)
					end
				elseif t[8].connect[6] then
					swap_stair(8, 1, 6)
				elseif t[8].connect[2] then
					swap_stair(8, 2, 5)
				end
			end
		end
		if t[11].stairs then
			if t[7].connect[5] and t[11].connect[2] then
				if t[11].connect[5] and t[13].connect[2] then
					if t[12].connect[7] then
						swap_stair(11, 4, 5)
					elseif t[10].connect[3] then
						swap_stair(11, 5, 8)
					end
				elseif t[11].connect[3] then
					swap_stair(11, 3, 8)
				elseif t[11].connect[7] then
					swap_stair(11, 4, 7)
				end
			elseif t[7].connect[6] and t[11].connect[1] then
				if t[11].connect[6] and t[13].connect[1] then
					if t[10].connect[4] then
						swap_stair(11, 6, 7)
					elseif t[12].connect[8] then
						swap_stair(11, 3, 6)
					end
				elseif t[11].connect[8] then
					swap_stair(11, 3, 8)
				elseif t[11].connect[4] then
					swap_stair(11, 4, 7)
				end
			end
		end
		if t[6].stairs then
			if t[7].connect[7] and t[6].connect[4] then
				if t[6].connect[7] and t[5].connect[4] then
					if t[10].connect[1] then
						swap_stair(6, 6, 7)
					elseif t[2].connect[5] then
						swap_stair(6, 2, 7)
					end
				elseif t[6].connect[5] then
					swap_stair(6, 2, 5)
				elseif t[6].connect[1] then
					swap_stair(6, 1, 6)
				end
			elseif t[7].connect[8] and t[6].connect[3] then
				if t[6].connect[8] and t[5].connect[3] then
					if t[2].connect[6] then
						swap_stair(6, 1, 8)
					elseif t[10].connect[2] then
						swap_stair(6, 5, 8)
					end
				elseif t[6].connect[2] then
					swap_stair(6, 2, 5)
				elseif t[6].connect[6] then
					swap_stair(6, 1, 6)
				end
			end
		end
	end
	minetest.override_item(name, {
		stairs = {name, name.."_outer", name.."_inner"},
		after_dig_node = function(pos, oldnode) after_dig_node(pos, oldnode) end,
		on_place = nil,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local node = minetest.get_node(pos)
			local ceiling = false
			if pointed_thing.under.y > pointed_thing.above.y then
				ceiling = true
				if node.param2 == 0 then node.param2 = 20
				elseif node.param2 == 1 then node.param2 = 23
				elseif node.param2 == 2 then node.param2 = 22
				elseif node.param2 == 3 then node.param2 = 21
				end
			end
			local connect = stair_param_to_connect(get_stair_param(node), ceiling)
			local def = minetest.registered_nodes[name]
			local t = {
				{pos = {x = pos.x - 1, y = pos.y, z = pos.z + 1}}, {pos = {x = pos.x, y = pos.y, z = pos.z + 1}}, {pos = {x = pos.x + 1, y = pos.y, z = pos.z + 1}},
				{pos = {x = pos.x - 1, y = pos.y, z = pos.z}}, {pos = pos, stairs = {name, def.stairs[2], def.stairs[3]}, connect = connect}, {pos = {x = pos.x + 1, y = pos.y, z = pos.z}},
				{pos = {x = pos.x - 1, y = pos.y, z = pos.z - 1}}, {pos = {x = pos.x, y = pos.y, z = pos.z - 1}}, {pos = {x = pos.x + 1, y = pos.y, z = pos.z - 1}},
			}
			for i,v in ipairs(t) do
				if not v.connect then
					local node = minetest.get_node(v.pos)
					local node_def = minetest.registered_nodes[node.name]
					if not node_def then
						return
					end
					if node_def.stairs then
						t[i].stairs = node_def.stairs
						t[i].connect = stair_param_to_connect(get_stair_param(node), ceiling)
					else
						t[i].connect = {false, false, false, false, false, false, false, false}
					end
				end
			end
			local function reset_node(n1, n2)
				local connect = {false, false, false, false, false, false, false, false}
				connect[n1] = true
				connect[n2] = true
				node = get_stair_from_param(stair_connect_to_param(connect, ceiling), t[5].stairs)
			end
			local function swap_stair(index, n1, n2)
				local connect = {false, false, false, false, false, false, false, false}
				connect[n1] = true
				connect[n2] = true
				local node = get_stair_from_param(stair_connect_to_param(connect, ceiling), t[index].stairs)
				t[index].connect = connect
				minetest.swap_node(t[index].pos, node)
			end
			if connect[3] then
				if t[4].connect[2] and t[4].connect[5] and t[1].connect[5] and not t[7].connect[2] then
					swap_stair(4, 2, 3)
				elseif t[4].connect[1] and t[4].connect[6] and t[7].connect[1] and not t[1].connect[6] then
					swap_stair(4, 3, 6)
				end
				if t[6].connect[1] and t[6].connect[6] and t[3].connect[6] and not t[9].connect[1] then
					swap_stair(6, 1, 8)
				elseif t[6].connect[2] and t[6].connect[5] and t[9].connect[2] and not t[3].connect[5] then
					swap_stair(6, 5, 8)
				end
				if t[4].connect[3] ~= t[6].connect[8] then
					if t[4].connect[3] then
						if t[2].connect[6] then
							reset_node(1, 8)
						elseif t[8].connect[2] then
							reset_node(5, 8)
						elseif t[2].connect[4] and t[2].connect[7] and t[1].connect[4] and not t[3].connect[7] then
							swap_stair(2, 6, 7)
							reset_node(1, 8)
						elseif t[2].connect[3] and t[2].connect[8] and t[3].connect[8] and not t[1].connect[3] then
							swap_stair(2, 3, 6)
							reset_node(1, 8)
						elseif t[8].connect[3] and t[8].connect[8] and t[9].connect[8] and not t[7].connect[3] then
							swap_stair(8, 2, 3)
							reset_node(5, 8)
						elseif t[8].connect[4] and t[8].connect[7] and t[7].connect[4] and not t[9].connect[7] then
							swap_stair(8, 2, 7)
							reset_node(5, 8)
						end
					else
						if t[2].connect[5] then
							reset_node(2, 3)
						elseif t[8].connect[1] then
							reset_node(3, 6)
						elseif t[2].connect[4] and t[2].connect[7] and t[3].connect[7] and not t[1].connect[4] then
							swap_stair(2, 4, 5)
							reset_node(2, 3)
						elseif t[2].connect[3] and t[2].connect[8] and t[1].connect[3] and not t[3].connect[8] then
							swap_stair(2, 5, 8)
							reset_node(2, 3)
						elseif t[8].connect[3] and t[8].connect[8] and t[7].connect[3] and not t[9].connect[8] then
							swap_stair(8, 1, 8)
							reset_node(3, 6)
						elseif t[8].connect[4] and t[8].connect[7] and t[9].connect[7] and not t[7].connect[4] then
							swap_stair(8, 1, 4)
							reset_node(3, 6)
						end
					end
				end
			elseif connect[2] then
				if t[2].connect[4] and t[2].connect[7] and t[3].connect[7] and not t[1].connect[4] then
					swap_stair(2, 4, 5)
				elseif t[2].connect[3] and t[2].connect[8] and t[1].connect[3] and not t[3].connect[8] then
					swap_stair(2, 5, 8)
				end
				if t[8].connect[3] and t[8].connect[8] and t[9].connect[8] and not t[7].connect[3] then
					swap_stair(8, 2, 3)
				elseif t[8].connect[4] and t[8].connect[7] and t[7].connect[4] and not t[9].connect[7] then
					swap_stair(8, 2, 7)
				end
				if t[2].connect[5] ~= t[8].connect[2] then
					if t[2].connect[5] then
						if t[6].connect[8] then
							reset_node(2, 3)
						elseif t[4].connect[4] then
							reset_node(2, 7)
						elseif t[6].connect[1] and t[6].connect[6] and t[3].connect[6] and not t[9].connect[1] then
							swap_stair(6, 1, 8)
							reset_node(2, 3)
						elseif t[6].connect[2] and t[6].connect[5] and t[9].connect[2] and not t[3].connect[5] then
							swap_stair(6, 5, 8)
							reset_node(2, 3)
						elseif t[4].connect[2] and t[4].connect[5] and t[7].connect[2] and not t[1].connect[5] then
							swap_stair(4, 4, 5)
							reset_node(2, 7)
						elseif t[4].connect[1] and t[4].connect[6] and t[1].connect[6] and not t[7].connect[1] then
							swap_stair(4, 1, 4)
							reset_node(2, 7)
						end
					else
						if t[6].connect[7] then
							reset_node(4, 5)
						elseif t[4].connect[3] then
							reset_node(5, 8)
						elseif t[6].connect[1] and t[6].connect[6] and t[9].connect[1] and not t[3].connect[6] then
							swap_stair(6, 6, 7)
							reset_node(4, 5)
						elseif t[6].connect[2] and t[6].connect[5] and t[3].connect[5] and not t[9].connect[2] then
							swap_stair(6, 2, 7)
							reset_node(4, 5)
						elseif t[4].connect[2] and t[4].connect[5] and t[1].connect[5] and not t[7].connect[2] then
							swap_stair(4, 2, 3)
							reset_node(5, 8)
						elseif t[4].connect[1] and t[4].connect[6] and t[7].connect[1] and not t[1].connect[6] then
							swap_stair(4, 3, 6)
							reset_node(5, 8)
						end
					end
				end
			elseif connect[4] then
				if t[6].connect[1] and t[6].connect[6] and t[9].connect[1] and not t[3].connect[6] then
					swap_stair(6, 6, 7)
				elseif t[6].connect[2] and t[6].connect[5] and t[3].connect[5] and not t[9].connect[2] then
					swap_stair(6, 2, 7)
				end
				if t[4].connect[2] and t[4].connect[5] and t[7].connect[2] and not t[1].connect[5] then
					swap_stair(4, 4, 5)
				elseif t[4].connect[1] and t[4].connect[6] and t[1].connect[6] and not t[7].connect[1] then
					swap_stair(4, 1, 4)
				end
				if t[4].connect[4] ~= t[6].connect[7] then
					if t[4].connect[4] then
						if t[8].connect[1] then
							reset_node(6, 7)
						elseif t[2].connect[5] then
							reset_node(2, 7)
						elseif t[8].connect[3] and t[8].connect[8] and t[7].connect[3] and not t[9].connect[8] then
							swap_stair(8, 1, 8)
							reset_node(6, 7)
						elseif t[8].connect[4] and t[8].connect[7] and t[9].connect[7] and not t[7].connect[4] then
							swap_stair(8, 1, 4)
							reset_node(6, 7)
						elseif t[2].connect[4] and t[2].connect[7] and t[3].connect[7] and not t[1].connect[4] then
							swap_stair(2, 4, 5)
							reset_node(2, 7)
						elseif t[2].connect[3] and t[2].connect[8] and t[1].connect[3] and not t[3].connect[8] then
							swap_stair(2, 5, 8)
							reset_node(2, 7)
						end
					else
						if t[8].connect[2] then
							reset_node(4, 5)
						elseif t[2].connect[6] then
							reset_node(1, 4)
						elseif t[8].connect[3] and t[8].connect[8] and t[9].connect[8] and not t[7].connect[3] then
							swap_stair(8, 2, 3)
							reset_node(4, 5)
						elseif t[8].connect[4] and t[8].connect[7] and t[7].connect[4] and not t[9].connect[7] then
							swap_stair(8, 2, 7)
							reset_node(4, 5)
						elseif t[2].connect[4] and t[2].connect[7] and t[1].connect[4] and not t[3].connect[7] then
							swap_stair(2, 6, 7)
							reset_node(1, 4)
						elseif t[2].connect[3] and t[2].connect[8] and t[3].connect[8] and not t[1].connect[3] then
							swap_stair(2, 3, 6)
							reset_node(1, 4)
						end
					end
				end
			elseif connect[1] then
				if t[8].connect[3] and t[8].connect[8] and t[7].connect[3] and not t[9].connect[8] then
					swap_stair(8, 1, 8)
				elseif t[8].connect[4] and t[8].connect[7] and t[9].connect[7] and not t[7].connect[4] then
					swap_stair(8, 1, 4)
				end
				if t[2].connect[4] and t[2].connect[7] and t[1].connect[4] and not t[3].connect[7] then
					swap_stair(2, 6, 7)
				elseif t[2].connect[3] and t[2].connect[8] and t[3].connect[8] and not t[1].connect[3] then
					swap_stair(2, 3, 6)
				end
				if t[2].connect[6] ~= t[8].connect[1] then
					if t[2].connect[6] then
						if t[4].connect[3] then
							reset_node(1, 8)
						elseif t[6].connect[7] then
							reset_node(1, 4)
						elseif t[4].connect[2] and t[4].connect[5] and t[1].connect[5] and not t[7].connect[2] then
							swap_stair(4, 2, 3)
							reset_node(1, 8)
						elseif t[4].connect[1] and t[4].connect[6] and t[7].connect[1] and not t[1].connect[6] then
							swap_stair(4, 3, 6)
							reset_node(1, 8)
						elseif t[6].connect[1] and t[6].connect[6] and t[9].connect[1] and not t[3].connect[6] then
							swap_stair(6, 6, 7)
							reset_node(1, 4)
						elseif t[6].connect[2] and t[6].connect[5] and t[3].connect[5] and not t[9].connect[2] then
							swap_stair(6, 2, 7)
							reset_node(1, 4)
						end
					else
						if t[4].connect[4] then
							reset_node(6, 7)
						elseif t[6].connect[8] then
							reset_node(3, 6)
						elseif t[4].connect[2] and t[4].connect[5] and t[7].connect[2] and not t[1].connect[5] then
							swap_stair(4, 4, 5)
							reset_node(6, 7)
						elseif t[4].connect[1] and t[4].connect[6] and t[1].connect[6] and not t[7].connect[1] then
							swap_stair(4, 1, 4)
							reset_node(6, 7)
						elseif t[6].connect[1] and t[6].connect[6] and t[3].connect[6] and not t[9].connect[1] then
							swap_stair(6, 1, 8)
							reset_node(3, 6)
						elseif t[6].connect[2] and t[6].connect[5] and t[9].connect[2] and not t[3].connect[5] then
							swap_stair(6, 5, 8)
							reset_node(3, 6)
						end
					end
				end
			end
			minetest.swap_node(pos, node)
		end
	})
	minetest.register_node(":"..name.."_outer", {
		description = node_def.description,
		_doc_items_create_entry = false,
		drawtype = "nodebox",
		tiles = outer_tiles,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = outer_groups,
		sounds = node_def.sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0, 0.5, 0.5}
			}
		},
		drop = drop,
		stairs = {name, name.."_outer", name.."_inner"},
		after_dig_node = function(pos, oldnode) after_dig_node(pos, oldnode) end,
		_mcl_hardness = node_def._mcl_hardness,
		on_rotate = false,
		placement_prevented = placement_prevented_outer,
	})
	minetest.register_node(":"..name.."_inner", {
		description = node_def.description,
		_doc_items_create_entry = false,
		drawtype = "nodebox",
		tiles = inner_tiles,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = inner_groups,
		sounds = node_def.sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
				{-0.5, 0, -0.5, 0, 0.5, 0}
			}
		},
		drop = drop,
		stairs = {name, name.."_outer", name.."_inner"},
		after_dig_node = function(pos, oldnode) after_dig_node(pos, oldnode) end,
		_mcl_hardness = node_def._mcl_hardness,
		on_rotate = false,
		placement_prevented = placement_prevented_inner,
	})

	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", name, "nodes", name.."_inner")
		doc.add_entry_alias("nodes", name, "nodes", name.."_outer")
	end
end


