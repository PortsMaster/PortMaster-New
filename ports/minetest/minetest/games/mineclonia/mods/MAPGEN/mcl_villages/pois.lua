--- Village "heat map" and POI manager.  The idea of this module is to
--- compute a ``heat'' value per-MapBlock horizontally and every two to
--- three MapBlocks vertically from its proximity to points of interest
--- and dynamically to update this map as POIs are inserted and removed.
---
--- Minecraft refers to these MapBlock-sized regions as sections, and
--- this module will utilize the same terminology.

local S = core.get_translator (core.get_current_modname())

--------------------------------------------------------------------
-- POI storage.
--------------------------------------------------------------------

local pois = AreaStore ()
local mod_storage = core.get_mod_storage ()
local str = mod_storage:get_string ("village_pois")

-- Map from section hash to POI heat.
local poi_heat = {}

if str ~= "" then
	local decoded_string
		= core.decode_base64 (str)
	if not decoded_string then
		local msg = "Village POI data was invalid and has been erased."
		core.log ("warning", "[mcl_villages]: " .. msg)
		mod_storage:set_string ("village_pois", "")
	else
		local heatmap = mod_storage:get_string ("village_poi_heatmap")
		local clock = os.clock ()
		pois:from_string (decoded_string)
		poi_heat = heatmap ~= ""
			and core.deserialize (heatmap) or {}
		for _, v in pairs (poi_heat) do
			v.ticket = nil
		end

		local aa = vector.new (-2048, -2048, -2048)
		local bb = vector.new (2047, 2047, 2047)
		local all_pois = pois:get_areas_in_area (aa, bb, true)
		core.log ("action", table.concat ({
			"[mcl_villages]: Loaded ",
			#all_pois,
			" points of interest in ",
			math.round ((os.clock () - clock) * 1000),
			" ms"
		}))
	end
else
	core.log ("action", "[mcl_villages]: World was upgraded or is pristine.")
end

core.register_on_shutdown (function ()
	local str = pois:to_string ()
	local encoded = core.encode_base64 (str)
	mod_storage:set_string ("village_pois", encoded)
end)

local hashpos = mcl_mobs.gwp_longhash

local function get_poi_section (x, y, z)
	local hash = hashpos (x, y, z)
	local node = poi_heat[hash]

	if not node then
		node = {
			x = x,
			y = y,
			z = z,
			heat = 0,
		}
		poi_heat[hash] = node
	end
	return node
end

mcl_villages.poi_heat = poi_heat

--------------------------------------------------------------------
-- POI registration and creation.
--------------------------------------------------------------------

mcl_villages.registered_pois = {}
local registered_pois = mcl_villages.registered_pois

-- Register a point of interest applicable to nodes.
-- DEF should be a table with the following fields:
--   `village_center': whether to increase the heat of of MapBlocks
--   containing instances of this POI and those adjoining.
--   `is_valid': function called to confirm the continued existence and
--   validity of a POI.
--   `on_destroy': function called to clean up after a deleted POI.
--   Not called if deleted by mcl_villages.remove_poi.

function mcl_villages.register_poi (name, def)
	mcl_villages.registered_pois[name] = def
end

local floor = math.floor

local function section_position (vec)
	return {
		x = floor (vec.x / 16),
		y = floor (vec.y / 16),
		z = floor (vec.z / 16),
	}
end

local function sort_pois_by_minpos (a, b)
	a = section_position (a.min)
	b = section_position (b.min)
	if a.x ~= b.x then
		return a.x < b.x
	end
	if a.z ~= b.z then
		return a.z < b.z
	end
	return a.y < b.y
end

function mcl_villages.insert_poi (nodepos, kind)
	local areas = pois:get_areas_for_pos (nodepos, false, true)
	if areas then
		-- Replace these POIs but log a warning message.
		for id, area in pairs (areas) do
			core.log ("warning", "Replacing POI "
				      .. area.data
				      .. "("
				      .. id
				      .. ")"
				      .. " with "
				      .. kind
				      .. " (nodepos = "
				      .. vector.to_string (nodepos)
				      .. ")")
			pois:remove_area (id)
		end
	end
	return pois:insert_area (nodepos, nodepos, kind)
end

function mcl_villages.get_poi (nodepos)
	local areas = pois:get_areas_for_pos (nodepos, false, true)
	if areas then
		for id, area in pairs (areas) do
			area.id = id
			return area
		end
	end
	return nil
end

--------------------------------------------------------------------
-- POI heat propagation.  Conceptually akin to light, and amenable to
-- the same forms of breadth-first iteration as lighting is.
--------------------------------------------------------------------

local poi_insertion_pdl = {}
local poi_deletion_pdl = {}
local poi_deletions = {}

local MAX_HEAT = 6

local function pop (pdl)
	local tem = pdl[#pdl]
	pdl[#pdl] = nil
	return tem
end

local function push (pdl, tem)
	pdl[#pdl + 1] = tem
end

local directions = {}

for x = -1, 1 do
	for y = -1, 1 do
		for z = -1, 1 do
			if x ~= 0 or y ~= 0 or z ~= 0 then
				push (directions, { x, y, z, })
			end
		end
	end
end

function mcl_villages.remove_poi (id)
	local area = pois:get_area (id, true, true)

	if area then
		pois:remove_area (id)

		local def = registered_pois[area.data]

		-- Propagate POI "lighting" reduction if necessary.
		if not def or def.village_center then
			local pos = section_position (area.min)
			local section_desc = get_poi_section (pos.x, pos.y, pos.z)

			if section_desc.heat > 0 then
				local pois = mcl_villages.get_pois_in (pos, pos)
				local heat = 0

				for _, poi in ipairs (pois) do
					def = registered_pois[poi.data]
					if def.village_center then
						heat = MAX_HEAT
					end
				end

				if heat == 0 then
					push (poi_deletion_pdl, section_desc)
				end
			end
		end
	end
end

local function propagate_poi_heat (max_iterations)
	local pdl = poi_insertion_pdl
	while max_iterations ~= 0 and #pdl > 0 do
		local section = pop (pdl)

		for _, neighbor in ipairs (directions) do
			local dx, dy, dz = unpack (neighbor)
			-- Increase the heat level of this neighbor if
			-- necessary.
			local neighbor = get_poi_section (section.x + dx,
							  section.y + dy,
							  section.z + dz)
			if neighbor.heat < section.heat - 1 then
				neighbor.heat = section.heat - 1
				-- Heat of neighbor has increased,
				-- and as such enqueue it.
				if neighbor.heat > 1 then
					push (pdl, neighbor)
				end
			end
		end
		max_iterations = max_iterations - 1
	end
	return #pdl == 0
end

local function propagate_poi_deletions (max_iterations)
	local pdl = poi_deletion_pdl
	while max_iterations ~= 0 and #pdl > 0 do
		local section = pop (pdl)

		for _, neighbor in ipairs (directions) do
			local dx, dy, dz = unpack (neighbor)
			-- Increase the heat level of this neighbor if
			-- necessary.
			local neighbor = get_poi_section (section.x + dx,
							  section.y + dy,
							  section.z + dz)
			if neighbor.heat ~= 0
			-- If the neighbor's heat value is less than
			-- this section's, it is receiving its light
			-- from the latter and should be cleared.
				and neighbor.heat < section.heat then
				push (pdl, neighbor)
			elseif neighbor.heat >= section.heat then
				-- Otherwise, it is another source of
				-- light that should be re-propagated to
				-- fill this node.
				push (poi_insertion_pdl, neighbor)
			end
		end
		section.heat = 0
		table.insert (poi_deletions, section)
		max_iterations = max_iterations - 1
	end
	return #pdl == 0
end

local NEIGHBORS_PER_STEP = 65536

-- This is a distance in MapBlocks, not nodes.
local POI_TICKING_DISTANCE = 16

local function enqueue_in_player_area (player, ticket)
	local player_pos = section_position (player:get_pos ())
	local aa = vector.offset (player_pos,
				  -POI_TICKING_DISTANCE / 2,
				  -POI_TICKING_DISTANCE / 2,
				  -POI_TICKING_DISTANCE / 2)
	local bb = vector.offset (player_pos,
				  POI_TICKING_DISTANCE / 2,
				  POI_TICKING_DISTANCE / 2,
				  POI_TICKING_DISTANCE / 2)
	local heat, section, prev_section, section_desc = 0

	for _, poi in ipairs (mcl_villages.get_pois_in (aa, bb)) do
		section = section_position (poi.min)
		local change_of_section = (not prev_section
					   or not vector.equals (prev_section,
								 section))
		if change_of_section then
			if section_desc then
				-- If this section is no longer heated, remove
				-- its influence.
				-- The current heat level is compared against
				-- MAX_HEAT in deciding whether it was previously
				-- heated, because other values may result in
				-- misfires if a POI exists within a section heated
				-- by adjacent village centers but without being a
				-- village center itself.
				if heat == 0 and section_desc.heat == MAX_HEAT then
					push (poi_deletion_pdl, section_desc)
				elseif heat > 0 and section_desc.heat < heat then
					push (poi_insertion_pdl, section_desc)
					section_desc.heat = heat
				end
			end

			-- Reset temporaries and proceed to this new
			-- section.
			heat = 0
			section_desc = get_poi_section (section.x, section.y, section.z)

			-- If this section has already been encountered,
			-- skip to the next.
			if section_desc.ticket == ticket then
				heat = -1
			else
				section_desc.ticket = ticket
			end
		end

		-- Validate this POI and apply heat if necessary.
		if heat ~= -1 then
			local poi_type = poi.data
			local def = registered_pois[poi_type]

			if not def then
				core.log ("warning", "Unknown POI type " .. poi_type)
				pois:remove_area (poi.id)
			else
				if not def.is_valid (poi.min) then
					if def.on_destroy then
						def.on_destroy (poi.min)
					end
					pois:remove_area (poi.id)
				elseif def.village_center then
					heat = MAX_HEAT
				end
			end
		end
		prev_section = section
	end

	-- Process the final section.
	if section_desc then
		-- If this section is no longer heated, remove its
		-- influence.
		if heat == 0 and section_desc.heat > 0 then
			push (poi_deletion_pdl, section_desc)
		elseif heat > 0 and section_desc.heat < heat then
			push (poi_insertion_pdl, section_desc)
			section_desc.heat = heat
		end
	end
end

local function sweep_poi_deletions (full)
	if not full then
		for _, item in pairs (poi_deletions) do
			-- This may have been resurrected by an adjacent village
			-- center.
			if item.heat == 0 then
				local k = hashpos (item.x, item.y, item.z)
				poi_heat[k] = nil
			end
		end
		poi_deletions = {}
	else
		for key, value in pairs (poi_heat) do
			if value.heat == 0 then
				poi_heat[key] = nil
			end
		end
	end
end

local dtime_total = 0
-- local steps_completed = 0
-- local step_total_time = 0
-- local step_max = 0

core.register_globalstep (function (dtime)
	dtime_total = dtime_total + dtime
	-- local clock = os.clock ()
	-- enqueue valid POIs and remove invalid ones near connected
	-- players.
	for player in mcl_util.connected_players () do
		enqueue_in_player_area (player, dtime_total)
	end
	if propagate_poi_deletions (NEIGHBORS_PER_STEP) then
		propagate_poi_heat (NEIGHBORS_PER_STEP)
	end
	sweep_poi_deletions ()
	-- local finish = os.clock ()
	-- steps_completed = steps_completed + 1
	-- step_total_time = step_total_time + (finish - clock)
	-- step_max = math.max (step_max, (finish - clock))
	-- if steps_completed >= 20 then
	-- 	local blurb = string.format ("Previous 20 cycles took %.2f ms per cycle (max %.2f)",
	-- 				     step_total_time / steps_completed * 1000,
	-- 				     step_max * 1000)
	-- 	print ("action", blurb)
	-- 	step_total_time = 0
	-- 	steps_completed = 0
	-- 	step_max = 0
	-- end
end)

core.register_on_shutdown (function ()
	propagate_poi_deletions (-1)
	propagate_poi_heat (-1)
	sweep_poi_deletions (true)
	local str = core.serialize (poi_heat)
	mod_storage:set_string ("village_poi_heatmap", str)
end)

------------------------------------------------------------------------
-- POI testing.
------------------------------------------------------------------------

mcl_villages.register_poi ("mcl_villages:demo_poi", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		if node.name == "ignore"
			or node.name == "mcl_villages:demo_poi" then
			return true
		end
		return false
	end,
	village_center = true,
	is_home = true,
})

core.register_node ("mcl_villages:demo_poi", {
	description = S ("Example POI"),
	tiles = {"blank.png"},
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {creative_breakable = 1, not_in_creative_inventory = 1, not_solid = 1},
	on_blast = function () end,
	drop = "",
	_mcl_blast_resistance = 36000008,
	_mcl_hardness = -1,
	after_place_node = function (pos, placer)
		mcl_villages.insert_poi (pos, "mcl_villages:demo_poi")
	end,
})

function mcl_villages.clear_poi_heat ()
	poi_heat = {}
	mcl_villages.poi_heat = poi_heat
end

------------------------------------------------------------------------
-- POI querying.
------------------------------------------------------------------------

function mcl_villages.get_pois_in (aa, bb)
	local aa = vector.multiply (aa, 16)
	local bb = vector.multiply (bb, 16)
	bb.x = bb.x + 15
	bb.y = bb.y + 15
	bb.z = bb.z + 15
	local list = pois:get_areas_in_area (aa, bb, false, true, true)
	local list1 = {}
	for key, value in pairs (list) do
		table.insert (list1, value)
		value.id = key
	end
	table.sort (list1, sort_pois_by_minpos)
	return list1
end

function mcl_villages.get_pois_in_by_nodepos (aa, bb)
	local list = pois:get_areas_in_area (aa, bb, false, true, true)
	local list1 = {}
	for key, value in pairs (list) do
		table.insert (list1, value)
		value.id = key
	end
	table.sort (list1, sort_pois_by_minpos)
	return list1
end

function mcl_villages.get_poi_heat (nodepos)
	local section_pos = section_position (nodepos)
	local x, y, z = section_pos.x, section_pos.y, section_pos.z
	local hash = hashpos (x, y, z)
	if poi_heat[hash] then
		return poi_heat[hash].heat
	end
	return 0
end

function mcl_villages.get_poi_heat_of_section (sectionpos)
	local x, y, z = sectionpos.x, sectionpos.y, sectionpos.z
	local hash = hashpos (x, y, z)
	if poi_heat[hash] then
		return poi_heat[hash].heat
	end
	return 0
end

mcl_villages.section_position = section_position

function mcl_villages.get_pois_in_section (sectionpos)
	return mcl_villages.get_pois_in (sectionpos, sectionpos)
end

function mcl_villages.center_of_section (sectionpos)
	return {
		x = sectionpos.x * 16 + 8,
		y = sectionpos.y * 16 + 8,
		z = sectionpos.z * 16 + 8,
	}
end

function mcl_villages.get_pois_in (aa, bb)
	local aa = vector.multiply (aa, 16)
	local bb = vector.multiply (bb, 16)
	bb.x = bb.x + 15
	bb.y = bb.y + 15
	bb.z = bb.z + 15
	local list = pois:get_areas_in_area (aa, bb, false, true, true)
	local list1 = {}
	for key, value in pairs (list) do
		table.insert (list1, value)
		value.id = key
	end
	table.sort (list1, sort_pois_by_minpos)
	return list1
end

function mcl_villages.get_pois_in_by_nodepos (aa, bb)
	local list = pois:get_areas_in_area (aa, bb, false, true, true)
	local list1 = {}
	for key, value in pairs (list) do
		table.insert (list1, value)
		value.id = key
	end
	table.sort (list1, sort_pois_by_minpos)
	return list1
end

function mcl_villages.random_poi_in (aa, bb, predicate, userdata)
	local list = mcl_villages.get_pois_in_by_nodepos (aa, bb)
	table.shuffle (list)
	for _, poi in pairs (list) do
		if not predicate or predicate (poi, userdata) then
			return poi
		end
	end
	return nil
end

local function calc_distsqr (a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return dx * dx + dy * dy + dz * dz
end

function mcl_villages.nearest_poi_in_radius (center, radius, predicate, userdata)
	local aa = vector.offset (center, -radius, -radius, -radius)
	local bb = vector.offset (center, radius, radius, radius)
	local list = mcl_villages.get_pois_in_by_nodepos (aa, bb)
	local distsqr = radius * radius
	local nearest, dist
	for _, poi in pairs (list) do
		local this_dist = calc_distsqr (center, poi.min)
		if this_dist <= distsqr
			and (not nearest or this_dist < dist)
			and (not predicate or predicate (poi, userdata)) then
			nearest = poi
			dist = this_dist
		end
	end
	return nearest, dist and math.sqrt (dist) or nil
end

function mcl_villages.pois_in_radius (center, radius, predicate, userdata)
	local aa = vector.offset (center, -radius, -radius, -radius)
	local bb = vector.offset (center, radius, radius, radius)
	local list = mcl_villages.get_pois_in_by_nodepos (aa, bb)
	local distsqr = radius * radius
	local pois = {}
	for _, poi in pairs (list) do
		local this_dist = calc_distsqr (center, poi.min)
		if this_dist <= distsqr
			and (not predicate or predicate (poi, userdata)) then
			table.insert (pois, poi)
		end
	end
	return pois
end

------------------------------------------------------------------------
-- POI creation.
------------------------------------------------------------------------

mcl_villages.register_poi ("mcl_villages:armorer", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or node.name == "mcl_blast_furnace:blast_furnace")
	end,
	village_center = true,
})

mcl_villages.register_poi ("mcl_villages:butcher", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or node.name == "mcl_smoker:smoker")
	end,
	village_center = true,
})

mcl_villages.register_poi ("mcl_villages:cartographer", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or node.name == "mcl_cartography_table:cartography_table")
	end,
	village_center = true,
})

mcl_villages.register_poi ("mcl_villages:cleric", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or core.get_item_group (node.name, "brewing_stand") > 0)
	end,
	village_center = true,
})

mcl_villages.register_poi ("mcl_villages:farmer", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or core.get_item_group (node.name, "composter") > 0)
	end,
	village_center = true,
})

mcl_villages.register_poi ("mcl_villages:fisherman", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or node.name == "mcl_barrels:barrel_closed"
			or node.name == "mcl_barrels:barrel_open")
	end,
	village_center = true,
})

mcl_villages.register_poi ("mcl_villages:fletcher", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or node.name == "mcl_fletching_table:fletching_table")
	end,
	village_center = true,
})

mcl_villages.register_poi ("mcl_villages:leatherworker", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or core.get_item_group (node.name, "cauldron") > 0)
	end,
	village_center = true,
})

mcl_villages.register_poi ("mcl_villages:librarian", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or node.name == "mcl_lectern:lectern"
			or node.name == "mcl_lectern:lectern_with_book")
	end,
	village_center = true,
})

mcl_villages.register_poi ("mcl_villages:mason", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or node.name == "mcl_stonecutter:stonecutter")
	end,
	village_center = true,
})

mcl_villages.register_poi ("mcl_villages:shepherd", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or node.name == "mcl_loom:loom")
	end,
	village_center = true,
})

mcl_villages.register_poi ("mcl_villages:toolsmith", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or node.name == "mcl_smithing_table:table")
	end,
	village_center = true,
})

mcl_villages.register_poi ("mcl_villages:weaponsmith", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or node.name == "mcl_grindstone:grindstone")
	end,
	village_center = true,
})

mcl_villages.register_poi ("mcl_villages:bed", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or core.get_item_group (node.name, "bed") > 0)
	end,
	village_center = true,
	is_home = true,
})

mcl_villages.register_poi ("mcl_villages:bell", {
	is_valid = function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or core.get_item_group (node.name, "bell") > 0)
	end,
	on_destroy = function (nodepos)
		local meta = core.get_meta (nodepos)
		if meta then
			meta:set_int ("mcl_villages:bell_users", 0)
		end
	end,
	village_center = true,
})

local function any_poi_valid ()
	return function (nodepos)
		local node = core.get_node (nodepos)
		return (node.name == "ignore"
			or node.name == "mcl_blast_furnace:blast_furnace"
			or node.name == "mcl_cartography_table:cartography_table"
			or node.name == "mcl_fletching_table:fletching_table"
			or node.name == "mcl_grindstone:grindstone"
			or node.name == "mcl_lectern:lectern"
			or node.name == "mcl_loom:loom"
			or node.name == "mcl_smithing_table:table"
			or node.name == "mcl_smoker:smoker"
			or node.name == "mcl_stonecutter:stonecutter"
			or node.name == "mcl_barrels:barrel_closed"
			or node.name == "mcl_barrels:barrel_open"
			or core.get_item_group (node.name, "composter") > 0
			or core.get_item_group (node.name, "brewing_stand") > 0
			or core.get_item_group (node.name, "cauldron") > 0)
	end
end

mcl_villages.register_poi ("mcl_villages:provisional_poi", {
	is_valid = any_poi_valid,
	village_center = false,
})

mcl_villages.register_poi ("mcl_villages:worldgen_reservation", {
	is_valid = any_poi_valid,
	village_center = false,
})
