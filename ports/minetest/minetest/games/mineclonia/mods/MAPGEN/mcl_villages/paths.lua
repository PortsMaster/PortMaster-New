-------------------------------------------------------------------------------
-- generate paths between buildings
-------------------------------------------------------------------------------

local light_threshold = tonumber(minetest.settings:get("mcl_villages_light_threshold")) or 6

function mcl_villages.paths(settlement_info)
	local starting_point
	local end_point
	local distance
	starting_point = settlement_info[1]["pos"]

	for o,p in pairs(settlement_info) do

		end_point = settlement_info[o]["pos"]
		if starting_point ~= end_point then
			-- loop until end_point is reched (distance == 0)
			while true do
				-- define surrounding pos to starting_point
				local north_p = {x=starting_point.x+1, y=starting_point.y, z=starting_point.z}
				local south_p = {x=starting_point.x-1, y=starting_point.y, z=starting_point.z}
				local west_p = {x=starting_point.x, y=starting_point.y, z=starting_point.z+1}
				local east_p = {x=starting_point.x, y=starting_point.y, z=starting_point.z-1}
				-- measure distance to end_point
				local dist_north_p_to_end = math.sqrt(
					((north_p.x - end_point.x)*(north_p.x - end_point.x))+
					((north_p.z - end_point.z)*(north_p.z - end_point.z))
				)
				local dist_south_p_to_end = math.sqrt(
					((south_p.x - end_point.x)*(south_p.x - end_point.x))+
					((south_p.z - end_point.z)*(south_p.z - end_point.z))
				)
				local dist_west_p_to_end = math.sqrt(
					((west_p.x - end_point.x)*(west_p.x - end_point.x))+
					((west_p.z - end_point.z)*(west_p.z - end_point.z))
				)
				local dist_east_p_to_end = math.sqrt(
					((east_p.x - end_point.x)*(east_p.x - end_point.x))+
					((east_p.z - end_point.z)*(east_p.z - end_point.z))
				)
				-- evaluate which pos is closer to the end_point
				if dist_north_p_to_end <= dist_south_p_to_end and
					dist_north_p_to_end <= dist_west_p_to_end and
					dist_north_p_to_end <= dist_east_p_to_end
				then
					starting_point = north_p
					distance = dist_north_p_to_end
				elseif dist_south_p_to_end <= dist_north_p_to_end and
					dist_south_p_to_end <= dist_west_p_to_end and
					dist_south_p_to_end <= dist_east_p_to_end
				then
					starting_point = south_p
					distance = dist_south_p_to_end

				elseif dist_west_p_to_end <= dist_north_p_to_end and
					dist_west_p_to_end <= dist_south_p_to_end and
					dist_west_p_to_end <= dist_east_p_to_end
				then
					starting_point = west_p
					distance = dist_west_p_to_end
				elseif dist_east_p_to_end <= dist_north_p_to_end and
					dist_east_p_to_end <= dist_south_p_to_end and
					dist_east_p_to_end <= dist_west_p_to_end
				then
					starting_point = east_p
					distance = dist_east_p_to_end
				end

				-- find surface of new starting point
				local surface_point, surface_mat = mcl_villages.find_surface(starting_point)
				-- replace surface node with mcl_core:grass_path
				if surface_point then
					if surface_mat == "mcl_core:sand" or surface_mat == "mcl_core:redsand" then
						minetest.swap_node(surface_point,{name="mcl_core:sandstonesmooth2"})
					else
						minetest.swap_node(surface_point,{name="mcl_core:grass_path"})
					end
					-- don't set y coordinate, surface might be too low or high
					starting_point.x = surface_point.x
					starting_point.z = surface_point.z
				end
				if distance <= 1 or starting_point == end_point then
					break
				end
			end
		end
	end
end

-- This ends up being a nested table.
-- 1st level is the blockseed which is the village
-- 2nd is the distance of the building from the bell
-- 3rd is the pos of the end points
local path_ends = {}

-- helper function to log the path table
function mcl_villages.dump_path_ends()
	minetest.log("[mcl_villages] " .. dump(path_ends))
end

-- Insert end points in to the nested tables
function mcl_villages.store_path_ends(minp, maxp, pos, size, blockseed, bell_pos)
	local path_end_nodes = minetest.find_nodes_in_area(
		vector.offset(minp, -4, -4, -4),
		vector.offset(maxp, 4, 4, 4),
		"mcl_villages:path_endpoint"
	)

	-- We store by distance because we cerate paths far away from the bell first
	local dist = vector.distance(bell_pos, pos)

	-- "block_" is used because lua doesn't like using integers for keys
	if path_ends["block_" .. blockseed] == nil then
		path_ends["block_" .. blockseed] = {}
	end
	if path_ends["block_" .. blockseed][dist] == nil then
		path_ends["block_" .. blockseed][dist] = {}
	end

	for _, epos in pairs(path_end_nodes) do
		table.insert(path_ends["block_" .. blockseed][dist], minetest.pos_to_string(epos))
		minetest.set_node(epos, { name = "air" })
	end
end

local function place_lamp(pos, pr)
	local lamp_index = pr:next(1, #mcl_villages.schematic_lamps)
	local building_all_info = mcl_villages.schematic_lamps[lamp_index]
	local schem_lua = mcl_villages.substitue_materials(pos, building_all_info["schem_lua"], pr)
	local schematic = loadstring(schem_lua)()

	minetest.place_schematic(
		vector.offset(pos, 0, 1, 0),
		schematic,
		"0",
		nil,
		true,
		{ place_center_x = true, place_center_y = false, place_center_z = true }
	)
end

local function place_path(path, pr, stair, slab)

	-- Smooth out bumps in path or stairs can look naf
	for i = 2, #path - 1 do
		local prev_y = path[i - 1].y
		local y = path[i].y
		local next_y = path[i + 1].y
		local bump_node = minetest.get_node(path[i])

		if minetest.get_item_group(bump_node.name, "water") ~= 0 then
			-- Find air
			local found_surface = false
			local up_pos = path[i]
			while not found_surface do
				up_pos = vector.offset(up_pos, 0, 1, 0)
				local up_node = minetest.get_node(up_pos)
				if up_node and minetest.get_item_group(up_node.name, "water") == 0 then
					found_surface = true
					minetest.swap_node(up_pos, { name = "air" })
					path[i] = up_pos
				end
			end
		elseif y < prev_y and y < next_y then
			-- Fill in dip to flatten path
			minetest.swap_node(path[i], { name = "mcl_core:dirt" })
			path[i] = vector.offset(path[i], 0, 1, 0)
		elseif y > prev_y and y > next_y then
			-- Remove peak to flatten path
			local under_pos = vector.offset(path[i], 0, -1, 0)
			minetest.swap_node(under_pos, { name = "air" })
			path[i] = under_pos
		end
	end

	for i, pos in ipairs(path) do
		-- replace decorations, grass and flowers, with air
		local n0 = minetest.get_node(pos)
		if n0.name ~= "air" then
			minetest.swap_node(pos, { name = "air" })
		end

		local under_pos = vector.offset(pos, 0, -1, 0)
		local n = minetest.get_node(under_pos)
		local done = false
		local is_stair

		-- TODO stairs should always face the lower node so they are easy to walk up

		if i > 1 and pos.y < path[i - 1].y then
			-- stairs down
			local n2 = minetest.get_node(vector.offset(path[i - 1], 0, -1, 0))
			is_stair = minetest.get_item_group(n2.name, "stair") ~= 0
			if not is_stair then
				done = true
				local param2 = minetest.dir_to_facedir(vector.subtract(path[i - 1], pos))
				minetest.add_node(pos, { name = stair, param2 = param2 })
			end
		elseif i > 1 and pos.y > path[i - 1].y then
			-- stairs up
			is_stair = minetest.get_item_group(n.name, "stair") ~= 0
			if not is_stair then
				done = true
				local param2 = minetest.dir_to_facedir(vector.subtract(pos, path[i - 1]))
				minetest.swap_node(under_pos, { name = stair, param2 = param2 })
			end
		end

		-- flat
		if not done then
			if minetest.get_item_group(n.name, "water") ~= 0 then
				minetest.add_node(under_pos, { name = slab })
			elseif n.name == "mcl_core:sand" or n.name == "mcl_core:redsand" then
				minetest.swap_node(under_pos, { name = "mcl_core:sandstonesmooth2" })
			elseif minetest.get_item_group(n.name, "soil") > 0
				and minetest.get_item_group(n.name, "dirtifies_below_solid") == 0
				then
					minetest.swap_node(under_pos, { name = "mcl_core:grass_path" })
				end
			end

		-- Clear space for villagers to walk
		for j = 1, 2 do
			local over_pos = vector.offset(pos, 0, j, 0)
			local m = minetest.get_node(over_pos)
			if m.name ~= "air" then
				minetest.swap_node(over_pos, { name = "air" })
			end
		end
	end

	-- Do lamps afterwards so we don't put them where a path will be laid
	for _, pos in ipairs(path) do
		if minetest.get_node_light(pos, 0) < light_threshold then
			local nn = minetest.find_nodes_in_area_under_air(
				vector.offset(pos, -1, -1, -1),
				vector.offset(pos, 1, 1, 1),
				{ "group:material_sand", "group:material_stone", "group:grass_block", "group:wood_slab" }
			)
			for _, npos in ipairs(nn) do
				local node = minetest.get_node(npos)
				if node.name ~= "mcl_core:grass_path" and minetest.get_item_group(node.name, "stair") == 0 then
					if minetest.get_item_group(node.name, "wood_slab") ~= 0 then
						local over_pos = vector.offset(npos, 0, 1, 0)
						minetest.add_node(over_pos, { name = "mcl_torches:torch", param2 = 1 })
					else
						place_lamp(npos, pr)
					end
					break
				end
			end
		end
	end
end

-- Work out which end points should be connected
-- works from the outside of the village in
function mcl_villages.paths_new(blockseed, biome_name)
	local pr = PseudoRandom(blockseed)

	if path_ends["block_" .. blockseed] == nil then
		minetest.log("warning", string.format("[mcl_villages] Tried to set paths for block seed that doesn't exist %d", blockseed))
		return
	end

	-- Use the same stair and slab throughout the entire village
	local stair = '"mcl_stairs:stair_oak"'
	local slab = '"mcl_stairs:slab_oak_top"'

	-- Change stair and slab for biome
	if mcl_villages.biome_map[biome_name] and mcl_villages.material_substitions[mcl_villages.biome_map[biome_name]] then
		for _, sub in pairs(mcl_villages.material_substitions[mcl_villages.biome_map[biome_name]]) do
			stair = stair:gsub(sub[1], sub[2])
			slab = slab:gsub(sub[1], sub[2])
		end
	end
	-- The quotes are to match what is in schemas, but we don't want them now
	stair = stair:gsub('"', "")
	slab = slab:gsub('"', "")

	-- Keep track of connections
	local connected = {}

	-- get a list of reverse sorted keys, which are distances
	local dist_keys = {}
	for k in pairs(path_ends["block_" .. blockseed]) do
		table.insert(dist_keys, k)
	end
	table.sort(dist_keys, function(a, b)
		return a > b
	end)

	for i, from in ipairs(dist_keys) do
		-- ep == end_point
		for _, from_ep in ipairs(path_ends["block_" .. blockseed][from]) do
			local from_ep_pos = minetest.string_to_pos(from_ep)
			local closest_pos
			local closest_bld
			local best = 10000000

			local ok = true
			if from == 0 then
				local path_nodes = minetest.find_nodes_in_area(
					vector.offset(from_ep_pos, 1, 0, 1),
					vector.offset(from_ep_pos, -1, 0, -1),
					"mcl_core:grass_path"
				)
				if path_nodes and #path_nodes then
					ok = false
				end
			end

			if ok then
				-- Most buildings only do other buildings that are closer to the bell
				-- for the bell do any end points that don't have paths near them
				local lindex = i + 1
				if i == 0 then
					lindex = 1
				end

				for j = lindex, #dist_keys do
					local to = dist_keys[j]
					if from ~= to and connected[from .. "-" .. to] == nil and connected[to .. "-" .. from] == nil then
						for _, to_ep in ipairs(path_ends["block_" .. blockseed][to]) do
							local to_ep_pos = minetest.string_to_pos(to_ep)

							local dist = vector.distance(from_ep_pos, to_ep_pos)
							if dist < best then
								best = dist
								closest_pos = to_ep_pos
								closest_bld = to
							end
						end
					end
				end

				if closest_pos then
					local path = minetest.find_path(from_ep_pos, closest_pos, 64, 1, 1)
					if path and #path > 0 then
						place_path(path, pr, stair, slab)
						connected[from .. "-" .. closest_bld] = 1
					else
						minetest.log(
							"warning",
							string.format(
								"[mcl_villages] No path from %s to %s, distance %d",
								minetest.pos_to_string(from_ep_pos),
								minetest.pos_to_string(closest_pos),
								vector.distance(from_ep_pos, closest_pos)
							)
						)
					end
				end
			end
		end
	end

	-- Loop again to blow away no path nodes
	for _, from in ipairs(dist_keys) do
		for _, from_ep in ipairs(path_ends["block_" .. blockseed][from]) do
			local from_ep_pos = minetest.string_to_pos(from_ep)
			local no_paths_nodes = minetest.find_nodes_in_area(
				vector.offset(from_ep_pos, -32, -32, -32),
				vector.offset(from_ep_pos, 32, 32, 32),
				{ "mcl_villages:no_paths" }
			)
			if #no_paths_nodes > 0 then
				minetest.bulk_set_node(no_paths_nodes, { name = "air" })
			end
		end
	end

	path_ends["block_" .. blockseed] = nil
end
