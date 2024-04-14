local min_jobs = tonumber(minetest.settings:get("mcl_villages_min_jobs")) or 1
local max_jobs = tonumber(minetest.settings:get("mcl_villages_max_jobs")) or 12
local placement_priority = minetest.settings:get("mcl_villages_placement_priority") or "random"

local S = minetest.get_translator(minetest.get_current_modname())

-------------------------------------------------------------------------------
-- initialize settlement_info
-------------------------------------------------------------------------------
function mcl_villages.initialize_settlement_info(pr)
	local count_buildings = {}

	for k, v in pairs(mcl_villages.schematic_houses) do
		count_buildings[v["name"]] = 0
	end
	for k, v in pairs(mcl_villages.schematic_jobs) do
		count_buildings[v["name"]] = 0
	end

	-- For new villages this is the number of jobs
	local number_of_buildings = pr:next(min_jobs, max_jobs)

	local number_built = 1
	mcl_villages.debug("Village ".. number_of_buildings)

	return count_buildings, number_of_buildings, number_built
end

-------------------------------------------------------------------------------
-- evaluate settlement_info and place schematics
-------------------------------------------------------------------------------
-- Initialize node
local function construct_node(p1, p2, name)
	local r = minetest.registered_nodes[name]
	if r then
		if r.on_construct then
			local nodes = minetest.find_nodes_in_area(p1, p2, name)
			for p=1, #nodes do
				local pos = nodes[p]
				r.on_construct(pos)
			end
			return nodes
		end
		minetest.log("warning", "[mcl_villages] No on_construct defined for node name " .. name)
		return
	end
	minetest.log("warning", "[mcl_villages] Attempt to 'construct' inexistant nodes: " .. name)
end

local function spawn_cats(pos)
	local sp=minetest.find_nodes_in_area_under_air(vector.offset(pos,-20,-20,-20),vector.offset(pos,20,20,20),{"group:opaque"})
	for i=1,math.random(5) do
		minetest.add_entity(vector.offset(sp[math.random(#sp)],0,1,0),"mobs_mc:cat")
	end
end

local function init_nodes(p1, p2, size, rotation, pr)

	for _, n in pairs(minetest.find_nodes_in_area(p1, p2, { "group:wall" })) do
		mcl_walls.update_wall(n)
	end

	construct_node(p1, p2, "mcl_itemframes:item_frame")
	construct_node(p1, p2, "mcl_furnaces:furnace")
	construct_node(p1, p2, "mcl_anvils:anvil")

	construct_node(p1, p2, "mcl_books:bookshelf")
	construct_node(p1, p2, "mcl_armor_stand:armor_stand")

	-- Support mods with custom job sites
	local job_sites = minetest.find_nodes_in_area(p1, p2, mobs_mc.jobsites)
	for _, v in pairs(job_sites) do
		mcl_structures.init_node_construct(v)
	end

	-- Do new chest nodes first
	local cnodes = construct_node(p1, p2, "mcl_chests:chest_small")

	if cnodes and #cnodes > 0 then
		for p = 1, #cnodes do
			local pos = cnodes[p]
			mcl_villages.fill_chest(pos, pr)
		end
	end

	-- Do old chest nodes after
	local nodes = construct_node(p1, p2, "mcl_chests:chest")
	if nodes and #nodes > 0 then
		for p=1, #nodes do
			local pos = nodes[p]
			mcl_villages.fill_chest(pos, pr)
		end
	end
end

local function layout_town(minp, maxp, pr, input_settlement_info)
	local settlement_info = {}
	local xdist = math.abs(minp.x - maxp.x)
	local zdist = math.abs(minp.z - maxp.z)

	-- find center of village within interior of chunk
	local center = vector.new(
		minp.x + pr:next(math.floor(xdist * 0.2), math.floor(xdist * 0.8)),
		maxp.y,
		minp.z + pr:next(math.floor(zdist * 0.2), math.floor(zdist * 0.8))
	)

	-- find center_surface of village
	local center_surface, surface_material = mcl_villages.find_surface(center, true)

	-- Cache for chunk surfaces
	local chunks = {}
	chunks[mcl_vars.get_chunk_number(center)] = true

	-- build settlement around center
	if not center_surface then
		minetest.log("action", string.format("[mcl_villages] Cannot build village at %s", minetest.pos_to_string(center)))
		return false
	else
		minetest.log(
			"action",
			string.format(
				"[mcl_villages] Will build a village at position %s with surface material %s",
				minetest.pos_to_string(center_surface),
				surface_material
			)
		)
	end

	local bell_info = table.copy(input_settlement_info[1])
	bell_info["pos"] = vector.copy(center_surface)
	bell_info["surface_mat"] = surface_material

	table.insert(settlement_info, bell_info)

	local size = #input_settlement_info
	local max_dist = 20 + (size * 3)

	for i = 2, size do
		local cur_schem = input_settlement_info[i]

		local placed = false
		local iter = 0
		local step = math.max(cur_schem["size"]["x"], cur_schem["size"]["z"]) + 2
		local degrs = pr:next(0, 359)
		local angle = degrs * math.pi / 180
		local r = step

		while not placed do
			iter = iter + 1
			r = r + step

			if r > max_dist then
				degrs = pr:next(0, 359)
				angle = degrs * math.pi / 180
				r = step
			end

			local ptx, ptz = center.x + r * math.cos(angle), center.z + r * math.sin(angle)
			ptx = mcl_villages.round(ptx, 0)
			ptz = mcl_villages.round(ptz, 0)
			local pos1 = vector.new(ptx, center_surface.y, ptz)

			local chunk_number = mcl_vars.get_chunk_number(pos1)
			local pos_surface, surface_material

			if chunks[chunk_number] then
				pos_surface, surface_material = mcl_villages.find_surface(pos1, false, true)
			else
				chunks[chunk_number] = true
				pos_surface, surface_material = mcl_villages.find_surface(pos1, true, true)
			end

			if pos_surface then
				local distance_to_other_buildings_ok, next_step =
					mcl_villages.check_radius_distance(settlement_info, pos_surface, cur_schem)

				if distance_to_other_buildings_ok then
					cur_schem["pos"] = vector.copy(pos_surface)
					cur_schem["surface_mat"] = surface_material
					table.insert(settlement_info, cur_schem)
					iter = 0
					placed = true
				else
					step = next_step
				end
			end

			-- Try another direction every so often
			if not placed and iter % 10 == 0 then
				degrs = pr:next(0, 359)
				angle = degrs * math.pi / 180
				r = step
			end

			if not placed and iter == 20 and input_settlement_info[i - 1] and input_settlement_info[i - 1]["pos"] then
				center = input_settlement_info[i - 1]["pos"]
			end
			if not placed and iter >= 30 then
				break
			end
		end
	end

	return settlement_info
end

function mcl_villages.create_site_plan_new(minp, maxp, pr)
	local base_settlement_info = {}

	-- initialize all settlement_info table
	local count_buildings, number_of_jobs = mcl_villages.initialize_settlement_info(pr)

	-- first building is townhall in the center
	local bindex = pr:next(1, #mcl_villages.schematic_bells)
	local bell_info = table.copy(mcl_villages.schematic_bells[bindex])

	local num_jobs = 0
	local num_beds = 0

	while num_jobs < number_of_jobs do
		local rindex = pr:next(1, #mcl_villages.schematic_jobs)
		local building_info = mcl_villages.schematic_jobs[rindex]

		if
			(building_info["min_jobs"] == nil or number_of_jobs >= building_info["min_jobs"])
			and (building_info["max_jobs"] == nil or number_of_jobs <= building_info["max_jobs"])
			and (
				building_info["num_others"] == nil
				or count_buildings[building_info["name"]] == 0
				or building_info["num_others"] * count_buildings[building_info["name"]] < num_jobs
			)
		then
			local cur_schem = table.copy(building_info)
			table.insert(base_settlement_info, cur_schem)
			num_jobs = num_jobs + cur_schem["num_jobs"]
			count_buildings[cur_schem["name"]] = count_buildings[cur_schem["name"]] + 1

			if cur_schem["num_beds"] then
				num_beds = num_beds + cur_schem["num_beds"]
			end
		end
	end

	while num_beds <= num_jobs do
		local rindex = pr:next(1, #mcl_villages.schematic_houses)
		local building_info = mcl_villages.schematic_houses[rindex]

		if
			(building_info["min_jobs"] == nil or number_of_jobs >= building_info["min_jobs"])
			and (building_info["max_jobs"] == nil or number_of_jobs <= building_info["max_jobs"])
			and (
				building_info["num_others"] == nil
				or count_buildings[building_info["name"]] == 0
				or building_info["num_others"] * count_buildings[building_info["name"]] < num_jobs
			)
		then
			local cur_schem = table.copy(building_info)
			table.insert(base_settlement_info, cur_schem)
			count_buildings[cur_schem["name"]] = count_buildings[cur_schem["name"]] + 1
			if cur_schem["num_beds"] then
				num_beds = num_beds + cur_schem["num_beds"]
			end
		end
	end

	-- Based on number of villagers
	local num_wells = pr:next(1, math.ceil(num_beds / 10))
	for i = 1, num_wells do
		local windex = pr:next(1, #mcl_villages.schematic_wells)
		local cur_schem = table.copy(mcl_villages.schematic_wells[windex])
		table.insert(base_settlement_info, cur_schem)
	end

	local shuffled_settlement_info
	if placement_priority == "jobs" then
		shuffled_settlement_info = table.copy(base_settlement_info)
	elseif placement_priority == "houses" then
		shuffled_settlement_info = table.copy(base_settlement_info)
		table.reverse(shuffled_settlement_info)
	else
		shuffled_settlement_info = mcl_villages.shuffle(base_settlement_info, pr)
	end

	table.insert(shuffled_settlement_info, 1, bell_info)

	return layout_town(minp, maxp, pr, shuffled_settlement_info)
end

function mcl_villages.place_schematics_new(settlement_info, pr, blockseed)

	local bell_pos = vector.copy(settlement_info[1]["pos"])

	for i, built_house in ipairs(settlement_info) do
		local building_all_info = built_house
		local pos = vector.copy(settlement_info[i]["pos"])
		local placement_pos = vector.copy(settlement_info[i]["pos"])

		-- Allow adjusting y axis
		if settlement_info[i]["yadjust"] then
			placement_pos = vector.offset(pos, 0, settlement_info[i]["yadjust"], 0)
		end

		local schem_lua = mcl_villages.substitue_materials(pos, settlement_info[i]["schem_lua"], pr)
		local schematic = loadstring(schem_lua)()

		local is_belltower = building_all_info["name"] == "belltower"

		local has_beds = building_all_info["num_beds"] and building_all_info["num_beds"] ~= nil
		local has_jobs = building_all_info["num_jobs"] and building_all_info["num_jobs"] ~= nil
		local stype = building_all_info["name"]

		local size = schematic.size

		minetest.place_schematic(
			placement_pos,
			schematic,
			"random",
			nil,
			true,
			{ place_center_x = true, place_center_y = false, place_center_z = true }
		)

		local x_adj = math.ceil(size.x / 2)
		local z_adj = math.ceil(size.z / 2)
		local minp = vector.offset(placement_pos, -x_adj, 0, -z_adj)
		local maxp = vector.offset(placement_pos, x_adj, size.y, z_adj)

		init_nodes(minp, maxp, size, nil, pr)

		mcl_villages.store_path_ends(minp, maxp, pos, size, blockseed, bell_pos)

		if is_belltower or has_beds then
			local center_node = minetest.get_node(pos)
			minetest.set_node(pos, { name = "mcl_villages:building_block" })
			local meta = minetest.get_meta(pos)
			meta:set_string("minp", minetest.pos_to_string(minp))
			meta:set_string("maxp", minetest.pos_to_string(maxp))
			meta:set_string("node_type", center_node.name)
			meta:set_string("blockseed", blockseed)
			meta:set_string("stype", stype)
			meta:set_int("has_beds", has_beds and 1 or 0)
			meta:set_int("has_jobs", has_jobs and 1 or 0)
			meta:set_int("is_belltower", is_belltower and 1 or 0)
			meta:set_string("infotext", S("The timer for this @1 has not run yet!", stype))
			meta:set_string("bell_pos", minetest.pos_to_string(bell_pos))
			local timer = minetest.get_node_timer(pos)
			if is_belltower then
				timer:start(4.0)
			else
				timer:start(2.0)
			end
		end
	end
end

-- Complete things that don't work when run in mapgen
function mcl_villages.post_process_building(minp, maxp, blockseed, has_beds, has_jobs, is_belltower, bell_pos)

	if (not bell_pos) or bell_pos == "" then
		minetest.log(
			"warning",
			string.format(
				"No bell position for village building. blockseed: %s, has_bends: %s, has_jobs: %s, is_belltower: %s",
				tostring(blockseed),
				tostring(has_beds),
				tostring(has_jobs),
				tostring(is_belltower)
			)
		)
		return
	end

	local bell = vector.offset(bell_pos, 0, 1, 0)

	if is_belltower then
		local biome_data = minetest.get_biome_data(bell_pos)
		local biome_name = minetest.get_biome_name(biome_data.biome)

		mcl_villages.paths_new(blockseed, biome_name)

		local l = minetest.add_entity(bell, "mobs_mc:iron_golem"):get_luaentity()
		if l then
			l._home = bell
		else
			minetest.log("warning", "Could not create a golem!")
		end

		spawn_cats(bell)
	end

	if has_beds then
		local beds = minetest.find_nodes_in_area(minp, maxp, { "group:bed" })

		for _, bed in pairs(beds) do
			local bed_node = minetest.get_node(bed)
			local bed_group = core.get_item_group(bed_node.name, "bed")

			-- We only spawn at bed bottoms
			-- 1 is bottom, 2 is top
			if bed_group == 1 then
				local m = minetest.get_meta(bed)
				m:set_string("bell_pos", minetest.pos_to_string(bell))
				if m:get_string("villager") == "" then
					local v = minetest.add_entity(bed, "mobs_mc:villager")
					if v then
						local l = v:get_luaentity()
						l._bed = bed
						l._bell = bell
						m:set_string("villager", l._id)
						m:set_string("infotext", S("A villager sleeps here"))
					else
						minetest.log("warning", "Could not create a villager!")
					end
				end
			end
		end
	end
end
