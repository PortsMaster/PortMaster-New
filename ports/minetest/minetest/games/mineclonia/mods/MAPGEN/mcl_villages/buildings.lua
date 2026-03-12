local min_jobs = tonumber(core.settings:get("mcl_villages_min_jobs")) or 1
local max_jobs = tonumber(core.settings:get("mcl_villages_max_jobs")) or 12
local placement_priority = core.settings:get("mcl_villages_placement_priority") or "jobs"

local S = core.get_translator(core.get_current_modname())

-------------------------------------------------------------------------------
-- initialize settlement_info
-------------------------------------------------------------------------------
function mcl_villages.initialize_settlement_info(pr)
	local count_buildings = {
		number_of_jobs = pr:next(min_jobs, max_jobs),
		num_jobs = 0,
		num_beds = 0,
	}

	for _, v in pairs(mcl_villages.schematic_houses) do
		count_buildings[v["name"]] = 0
		if v["group"] then count_buildings[v["group"]] = 0 end
	end
	for _, v in pairs(mcl_villages.schematic_jobs) do
		count_buildings[v["name"]] = 0
		if v["group"] then count_buildings[v["group"]] = 0 end
	end

	return count_buildings
end

-------------------------------------------------------------------------------
-- evaluate settlement_info and place schematics
-------------------------------------------------------------------------------

local function spawn_cats(pos)
	local sp=core.find_nodes_in_area_under_air(vector.offset(pos,-20,-20,-20),vector.offset(pos,20,20,20),{"group:opaque"})
	for _ = 1, math.random(5) do
		core.add_entity(vector.offset(sp[math.random(#sp)],0,1,0),"mobs_mc:cat")
	end
end

local function init_nodes(p1, p2, _, _, pr)
	for _, n in pairs(core.find_nodes_in_area(p1, p2, { "group:wall" })) do
		mcl_walls.update_wall(n)
	end

	mcl_structures.construct_nodes(p1, p2, {
		"mcl_itemframes:item_frame",
		"mcl_itemframes:glow_item_frame",
		"mcl_furnaces:furnace",
		"mcl_anvils:anvil",
		"mcl_books:bookshelf",
		"mcl_armor_stand:armor_stand",
	})

	-- Support mods with custom job sites
	local job_sites = core.find_nodes_in_area(p1, p2, mobs_mc.jobsites)
	for _, v in pairs(job_sites) do
		mcl_structures.init_node_construct(v)
	end

	local nodes = mcl_structures.construct_nodes(p1, p2, { "mcl_chests:chest_small", "mcl_chests:chest" }) or {}
	for p=1, #nodes do
		mcl_villages.fill_chest(nodes[p], pr)
	end
end

-- TODO consided using mod_storage to persist this...
local areas = AreaStore()
areas:set_cache_params({ enabled = true, block_radius = 16, limit = 100 })

local function record_building(record)
	local placement_pos = vector.copy(record.pos)

	-- Allow adjusting y axis
	if record.yadjust then
		placement_pos = vector.offset(placement_pos, 0, record.yadjust, 0)
	end

	local size = math.ceil(math.max(record.size.x, record.size.z) / 2)
	local minp = vector.offset(placement_pos, -size, -10, -size)
	local maxp = vector.offset(placement_pos, size, record.size.y + 10, size)

	areas:insert_area(minp, maxp, record.name)
end

-- TODO is there a good way to calculate this?
local squares = {
	-- center
	{ x = 0, z = 0 },

	--around center
	{ x = 1, z = 0 },
	{ x = -1, z = 0 },
	{ x = 1, z = 1 },
	{ x = -1, z = -1 },
	{ x = 1, z = -1 },
	{ x = -1, z = -1 },
	{ x = 0, z = 1 },
	{ x = 0, z = -1 },

	--one out
	{ x = 2, z = 0 },
	{ x = -2, z = 0 },

	{ x = 2, z = 1 },
	{ x = -2, z = -1 },
	{ x = 2, z = -1 },
	{ x = -2, z = 1 },

	{ x = 2, z = 2 },
	{ x = -2, z = -2 },
	{ x = 2, z = -2 },
	{ x = -2, z = 2 },

	{ x = 0, z = 2 },
	{ x = 0, z = -2 },
	{ x = 1, z = 2 },
	{ x = -1, z = -2 },
	{ x = 1, z = -2 },
	{ x = -1, z = 2 },

	--two out
	{ x = 3, z = 0 }, --25
	{ x = -3, z = 0 },

	{ x = 0, z = 3 },
	{ x = 0, z = -3 },
	{ x = 3, z = 1 },
	{ x = -3, z = -1 },

	{ x = -1, z = 3 },
	{ x = 1, z = -3 },
	{ x = 3, z = -1 },
	{ x = -3, z = 1 },

	{ x = 1, z = 3 },
	{ x = -1, z = -3 },
	{ x = 3, z = 2 },
	{ x = -3, z = -2 },
	{ x = 3, z = -2 },
	{ x = -3, z = 2 }, --40

	{ x = 3, z = -2 },
	{ x = -3, z = 2 },
	{ x = 2, z = 3 },
	{ x = -2, z = -3 },
	{ x = 3, z = 3 },
	{ x = -3, z = -3 },
	{ x = -3, z = 3 },
	{ x = 3, z = -3 },
}

local function layout_grid(_, input_settlement_info, settlement_info, _)

	local bell_schem = settlement_info[1]
	record_building(bell_schem)
	local center_surface = bell_schem.pos

	for i = 2, #input_settlement_info do
		if i > #squares then
			core.log("warning", "Too many buldings for grid layout, remaining buildings will be missing.")
			return settlement_info
		end

		local cur_schem = input_settlement_info[i]
		local placed = false
		local iter = 0

		local x_step = squares[i].x
		local z_step = squares[i].z

		local b_length = math.max(bell_schem.size.x, bell_schem.size.z)
		local c_length = math.max(cur_schem.size.x, cur_schem.size.z)

		local dist = math.ceil(b_length + c_length / 2)
		local half_dist = math.ceil(dist / 2)

		local next_x = bell_schem.pos.x + ((dist + 1) * x_step)
		local next_z = bell_schem.pos.z + ((dist + 1) * z_step)

		while not placed do
			iter = iter + 1

			local pos = vector.new(next_x, center_surface.y, next_z)
			local pos_surface, surface_material = mcl_villages.find_surface(pos)

			if pos_surface then
				pos_surface = vector.round(pos_surface)

				local minp = vector.offset(pos_surface, -half_dist, 0, -half_dist)
				local maxp = vector.offset(pos_surface, half_dist, cur_schem.size.y, half_dist)

				local collisons = areas:get_areas_in_area(minp, maxp, true, true, true)

				if table.count(collisons) == 0 then
					cur_schem.pos = vector.copy(pos_surface)
					cur_schem.surface_mat = surface_material
					record_building(cur_schem)
					table.insert(settlement_info, cur_schem)
					placed = true
				else
					local col
					-- sometimes this is a table with keys, and sometimes not ...
					for _, v in pairs(collisons) do
						col = v
						break
					end

					if z_step < 0 then
						next_z = col.max.z + half_dist + 1
					elseif z_step > 0 then
						next_z = col.min.z - half_dist - 1
					elseif x_step < 0 then
						next_x = col.min.x - half_dist - 1
					elseif x_step > 0 then
						next_x = col.max.x + half_dist + 1
					end
				end
			else
				next_x = next_x + (dist + 1 * x_step)
				next_z = next_z + (dist + 1 * z_step)
			end

			if not placed and (iter % 5 == 0) then
				x_step = squares[i + (iter % 10)].x
				z_step = squares[i + (iter % 10)].z
				next_x = bell_schem.pos.x + ((dist + 1) * x_step)
				next_z = bell_schem.pos.z + ((dist + 1) * z_step)
			end

			if not placed and iter >= 30 then
				core.log("warning", "Could not place " .. cur_schem.name)
				break
			end
		end
	end
end

local function layout_circles(pr, input_settlement_info, settlement_info, center)
	local center_surface = settlement_info[1].pos
	local size = #input_settlement_info
	local max_dist = 20 + (size * 3)

	-- Cache for chunk surfaces
	local chunks = {}
	chunks[mcl_vars.get_chunk_number(center)] = true

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
			local pos1 = vector.new(math.floor(ptx + 0.5), center_surface.y, math.floor(ptz + 0.5))

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
end

local function layout_town(minp, maxp, pr, input_settlement_info, grid)
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

	-- build settlement around center
	if not center_surface then
		core.log(
			"info",
			string.format("[mcl_villages] Cannot build village at %s", core.pos_to_string(center))
		)
		return false
	else
		core.log(
			"info",
			string.format(
				"[mcl_villages] Will build a village at position %s with surface material %s",
				core.pos_to_string(center_surface),
				surface_material
			)
		)
	end

	local bell_info = table.copy(input_settlement_info[1])
	bell_info["pos"] = vector.copy(center_surface)
	bell_info["surface_mat"] = surface_material

	table.insert(settlement_info, bell_info)

	if grid then
		layout_grid(pr, input_settlement_info, settlement_info, center)
	else
		layout_circles(pr, input_settlement_info, settlement_info, center)
	end

	return settlement_info
end

local function add_building(base_settlement_info, building_info, count_buildings)
	local cur_schem = table.copy(building_info)
	table.insert(base_settlement_info, cur_schem)

	count_buildings[cur_schem["name"]] = count_buildings[cur_schem["name"]] + 1
	count_buildings.num_jobs = count_buildings.num_jobs + (cur_schem["num_jobs"] or 0)
	count_buildings.num_beds = count_buildings.num_beds + (cur_schem["num_beds"] or 0)
	if cur_schem["group"] then
		count_buildings[cur_schem["group"]] = count_buildings[cur_schem["group"]] + 1
	end
end

local function info_for_building(bld_name, schem_table)
	for _, building_info in pairs(schem_table) do
		if building_info.name == bld_name then
			return table.copy(building_info)
		end
	end
end

function mcl_villages.create_site_plan_new(minp, maxp, pr)
	local base_settlement_info = {}

	-- initialize all settlement_info table
	local count_buildings = mcl_villages.initialize_settlement_info(pr)

	-- first building is townhall in the center
	local bindex = pr:next(1, #mcl_villages.schematic_bells)
	local bell_info = table.copy(mcl_villages.schematic_bells[bindex])

	if mcl_villages.mandatory_buildings['jobs'] then
		for _, bld_name in pairs(mcl_villages.mandatory_buildings['jobs']) do
			local building_info = info_for_building(bld_name, mcl_villages.schematic_jobs)
			add_building(base_settlement_info, building_info, count_buildings)
		end
	end

	while count_buildings.num_jobs < count_buildings.number_of_jobs do
		local rindex = pr:next(1, #mcl_villages.schematic_jobs)
		local building_info = mcl_villages.schematic_jobs[rindex]

		if
			(building_info["min_jobs"] == nil or count_buildings.number_of_jobs >= building_info["min_jobs"])
			and (building_info["max_jobs"] == nil or count_buildings.number_of_jobs <= building_info["max_jobs"])
			and (
				building_info["num_others"] == nil
				or count_buildings[building_info["group"] or building_info["name"]] == 0
				or building_info["num_others"] * count_buildings[building_info["group"] or building_info["name"]] < count_buildings.num_jobs
			)
		then
			add_building(base_settlement_info, building_info, count_buildings)
		end
	end

	if mcl_villages.mandatory_buildings['houses'] then
		for _, bld_name in pairs(mcl_villages.mandatory_buildings['houses']) do
			local building_info = info_for_building(bld_name, mcl_villages.schematic_houses)
			add_building(base_settlement_info, building_info, count_buildings)
		end
	end

	while count_buildings.num_beds <= count_buildings.num_jobs do
		local rindex = pr:next(1, #mcl_villages.schematic_houses)
		local building_info = mcl_villages.schematic_houses[rindex]

		if
			(building_info["min_jobs"] == nil or count_buildings.number_of_jobs >= building_info["min_jobs"])
			and (building_info["max_jobs"] == nil or count_buildings.number_of_jobs <= building_info["max_jobs"])
			and (
				building_info["num_others"] == nil
				or count_buildings[building_info["group"] or building_info["name"]] == 0
				or building_info["num_others"] * count_buildings[building_info["group"] or building_info["name"]] < count_buildings.num_jobs
			)
		then
			add_building(base_settlement_info, building_info, count_buildings)
		end
	end

	-- Based on number of villagers
	local num_wells = pr:next(1, math.ceil(count_buildings.num_beds / 10))
	for _ = 1, num_wells do
		local windex = pr:next(1, #mcl_villages.schematic_wells)
		local cur_schem = table.copy(mcl_villages.schematic_wells[windex])
		table.insert(base_settlement_info, pr:next(1, #base_settlement_info), cur_schem)
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

	-- More jobs increases chances of grid layout
	local grid = false
	if pr:next(1, count_buildings.num_jobs) > 4 then
		grid = true
	end

	local output_settlement_info, grid = layout_town(minp, maxp, pr, shuffled_settlement_info, grid), grid
	if output_settlement_info and #output_settlement_info <= 2 and #output_settlement_info < #shuffled_settlement_info then
		core.log("warning",
			string.format("[mcl_villages] Cannot build village at %s - %s, only %d locations",
			core.pos_to_string(minp), core.pos_to_string(maxp), #output_settlement_info))
		return nil, false
	end
	return output_settlement_info, grid
end

function mcl_villages.place_schematics_new(settlement_info, pr, blockseed)

	local bell_pos = vector.copy(settlement_info[1]["pos"])
	local bell_center_pos
	local bell_center_node_type

	for i, built_house in ipairs(settlement_info) do
		local building_all_info = built_house
		local pos = vector.copy(settlement_info[i]["pos"])
		local placement_pos = vector.copy(settlement_info[i]["pos"])

		-- Allow adjusting y axis
		if settlement_info[i]["yadjust"] then
			placement_pos = vector.offset(pos, 0, settlement_info[i]["yadjust"], 0)
		end

		local schem_lua = mcl_villages.substitute_materials(pos, settlement_info[i]["schem_lua"], pr)
		local schematic = loadstring(schem_lua)()

		local is_belltower = building_all_info["name"] == "belltower"

		local size = schematic.size

		core.place_schematic(
			placement_pos,
			schematic,
			"random",
			{ ["mcl_core:dirt_with_grass"]=schematic.surface_mat or "mcl_core:dirt" },
			true,
			{ place_center_x = true, place_center_y = false, place_center_z = true }
		)
		-- TODO: use core.after(1) to check for dropped flowers/plants in y=0?

		local x_adj = math.ceil(size.x / 2)
		local z_adj = math.ceil(size.z / 2)
		local minp = vector.offset(placement_pos, -x_adj, 0, -z_adj)
		local maxp = vector.offset(placement_pos, x_adj, size.y, z_adj)

		building_all_info.size = size
		building_all_info.minp = minp
		building_all_info.maxp = maxp

		init_nodes(minp, maxp, size, nil, pr)

		mcl_villages.store_path_ends(minp, maxp, pos, size, blockseed, bell_pos)

		if  is_belltower then
			bell_center_pos = pos
			local center_node = core.get_node(pos)
			bell_center_node_type = center_node.name
		end
	end

	local biome_data = core.get_biome_data(bell_pos)
	local biome_name = core.get_biome_name(biome_data.biome)

	mcl_villages.paths_new(blockseed, biome_name)

	core.swap_node(bell_center_pos, { name = "mcl_villages:village_block" })
	local meta = core.get_meta(bell_center_pos)
	meta:set_string("blockseed", blockseed)
	meta:set_string("node_type", bell_center_node_type)
	meta:set_string("infotext", S("The timer for this @1 has not run yet!", bell_center_node_type))
	local timer = core.get_node_timer(bell_center_pos)
	timer:start(1.0)
end

-- TODO This should be removed in the future once all villages using it have been generated.
-- Complete things that don't work when run in mapgen
function mcl_villages.post_process_building(minp, maxp, blockseed, has_beds, has_jobs, is_belltower, bell_pos)

	if (not bell_pos) or bell_pos == "" then
		core.log(
			"info",
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

	local bell = vector.offset(bell_pos, 0, 2, 0)

	if is_belltower then
		local biome_data = core.get_biome_data(bell_pos)
		local biome_name = core.get_biome_name(biome_data.biome)

		mcl_villages.paths_new(blockseed, biome_name)

		local l = core.add_entity(bell, "mobs_mc:iron_golem"):get_luaentity()
		if l then
			l._home = bell
		else
			core.log("info", "Could not create a golem!")
		end

		spawn_cats(bell)
	end

	if has_beds then
		local beds = core.find_nodes_in_area(minp, maxp, { "group:bed" })

		for _, bed in pairs(beds) do
			local bed_node = core.get_node(bed)
			local bed_group = core.get_item_group(bed_node.name, "bed")

			-- We only spawn at bed bottoms
			-- 1 is bottom, 2 is top
			if bed_group == 1 then
				local v = core.add_entity(vector.offset(bed, 0, 0.06, 0), "mobs_mc:villager")
				if v then
					local l = v:get_luaentity()
					l:claim_home (bed)
					l:claim_bell (bell)
					for _, callback in pairs(mcl_villages.on_villager_placed) do
						callback(v, blockseed)
					end
				end
			end
		end
	end
end

function mcl_villages.post_process_village(blockseed)
	local village_info = mcl_villages.get_village(blockseed)
	if not village_info then
		return
	end

	local settlement_info = village_info.data
	local jobs = {}
	local beds = {}

	local bell_pos = vector.copy(settlement_info[1]["pos"])
	local bell = vector.offset(bell_pos, 0, 2, 0)

	local l = core.add_entity(bell, "mobs_mc:iron_golem"):get_luaentity()
	if l then
		l._home = bell
	else
		core.log("info", "Could not create a golem!")
	end

	spawn_cats(bell)

	for _, building in pairs(settlement_info) do
		local has_beds = building["num_beds"] and building["num_beds"] ~= nil
		local has_jobs = building["num_jobs"] and building["num_jobs"] ~= nil

		local minp, maxp = building["minp"], building["maxp"]

		if has_jobs then
			local jobsites = core.find_nodes_in_area(minp, maxp, mobs_mc.jobsites)

			for _, job_pos in pairs(jobsites) do
				table.insert(jobs, job_pos)
			end
		end

		if has_beds then
			local bld_beds = core.find_nodes_in_area(minp, maxp, { "group:bed" })

			for _, bed_pos in pairs(bld_beds) do
				local bed_node = core.get_node(bed_pos)
				local bed_group = core.get_item_group(bed_node.name, "bed")

				-- We only spawn at bed bottoms
				-- 1 is bottom, 2 is top
				if bed_group == 1 then
					table.insert(beds, bed_pos)
				end
			end
		end
	end

	if beds then
		for _, bed_pos in pairs(beds) do
			local res = core.forceload_block(bed_pos, true)
			if res then
				mcl_villages.forced_blocks[core.pos_to_string(bed_pos)] = core.get_us_time()
			end
			local v = core.add_entity(vector.offset(bed_pos, 0, 0.06, 0), "mobs_mc:villager")
			if v then
				local l = v:get_luaentity()
				l:claim_home (bed_pos)
				l:claim_bell (bell)

				local job_pos = table.remove(jobs, 1)
				if job_pos then
					l:claim_poi (job_pos, nil)
				end

				for _, callback in pairs(mcl_villages.on_villager_placed) do
					callback(v, blockseed)
				end
			else
				core.log("info", "Could not create a villager!")
			end
		end
	end
end
