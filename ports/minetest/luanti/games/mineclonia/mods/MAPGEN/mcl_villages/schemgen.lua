local ipairs = ipairs

------------------------------------------------------------------------
-- Village template component generation.
------------------------------------------------------------------------

-- Post-process a bell-like schematic with connecting positions, i.e.,
-- load SCHEM_NAME and substitute ignore for all no_paths nodes and
-- convert path endpoints into exits towards the opposite direction.

local floor = math.floor
local mathabs = math.abs
local ipos3 = mcl_levelgen.ipos3

local function is_job_site (name)
	for _, poitype in ipairs (mobs_mc.jobsites) do
		if poitype == name then
			return true
		elseif poitype:sub (1, 6) == "group:" then
			local len = #poitype
			local group = poitype:sub (7, len)

			if core.get_item_group (name, group) > 0 then
				return true
			end
		end
	end
	return false
end

local function is_walkable (name)
	local def = core.registered_nodes[name]
	return def and def.walkable
end

local function generate_bell_schematic (schem_name)
	local schematic = core.read_schematic (schem_name, {})
	if not schematic then
		error ("Could not load schematic: " .. schem_name)
	end

	local size = schematic.size
	local xstride = 1
	local ystride = size.x
	local zstride = size.x * size.y
	local ndata = schematic.data
	local endpoints = {}
	local bell_x, bell_y, bell_z

	for x, y, z in ipos3 (0, 0, 0, size.x - 1, size.y - 1, size.z - 1) do
		local idx = z * zstride + y * ystride + x * xstride + 1
		if ndata[idx].name == "mcl_villages:no_paths" then
			ndata[idx].name = "air"
		elseif ndata[idx].name == "mcl_villages:path_endpoint" then
			ndata[idx].name = "air"
			table.insert (endpoints, { x, y, z, })
		elseif core.get_item_group (ndata[idx].name, "bell") >= 1 then
			bell_x, bell_y, bell_z = x, y, z
			schematic.bell = { x, y, size.z - z - 1, }
		end
	end

	local cx = floor (size.x / 2)
	local cy = floor (size.y / 2)
	local cz = floor (size.z / 2)

	if cx == 0 or cy == 0 or cz == 0 then
		error ("Bell schematic is too small to "
		       .. "derive any useful orientation from")
	end

	schematic.exits = {}
	schematic.beds = {}
	schematic.pois = {}
	if not schematic.bell then
		error ("Bell schematic failed to define bell")
	end
	schematic.connecting = nil

	local function get_block (x, y, z)
		if x < 0 or y < 0 or z < 0
			or x >= size.x
			or y >= size.y
			or z >= size.z then
			return nil
		end

		local idx = z * zstride + y * ystride + x * xstride + 1
		return ndata[idx].name
	end

	local function find_surface (x, y, z)
		for y = y, y + 6 do
			local block = get_block (x, y, z)
			if not block then
				return nil, nil, nil
			end
			if is_walkable (block) then
				return x, y, z
			end
		end
		return nil, nil, nil
	end

	local function test_clearance (x, y, z)
		local block = get_block (x, y, z)
		local block_1 = get_block (x, y + 1, z)
		if not block then
			return false
		end
		return not is_walkable (block) and not is_walkable (block_1)
	end

	-- Decide where in the bell to spawn a golem.  Search a 6x6x6
	-- area around the bell for a solid surface with two blocks of
	-- clearance along either axis, and spawn golems in the center
	-- of the clearance.

	local maxdist = math.huge
	local bell_spawn_x, bell_spawn_y, bell_spawn_z
	for x, y, z in ipos3 (bell_x - 6, bell_y - 6, bell_z - 6,
			      bell_x + 6, bell_y, bell_z + 6) do
		local sx, sy, sz = find_surface (x, y, z)
		if sx then
			if test_clearance (sx, sy + 1, sz)
				and test_clearance (sx + 1, sy + 1, sz)
				and test_clearance (sx, sy + 1, sz + 1)
				and test_clearance (sx + 1, sy + 1, sz + 1) then
				local x = sx + 0.5
				local z = sz + 0.5
				local y = sy + 1

				local dx = (x - bell_x)
				local dz = (z - bell_z)
				if dx * dx + dz * dz < maxdist then
					maxdist = dx * dx + dz * dz
					bell_spawn_x = x
					bell_spawn_y = y
					bell_spawn_z = z
				end
			end
		end
	end
	if not bell_spawn_x then
		error ("No valid positions exist in bell schematic in which golems may spawn")
	end
	schematic.bell_spawn = {
		bell_spawn_x,
		bell_spawn_y,
		size.z - bell_spawn_z - 1,
	}

	for _, pos in ipairs (endpoints) do
		local x, y, z = unpack (pos)
		local dx, dz = x - cx, z - cz
		local orientation

		if mathabs (dx) >= mathabs (dz) then
			orientation = dx >= 0 and "90" or "270"
		else
			orientation = dz > 0 and "0" or "180"
		end

		table.insert (schematic.exits, {
			orientation = orientation,
			x = x,
			y = y,
			z = size.z - z - 1,
		})
	end

	return schematic
end

-- Post-process a building-like schematic, i.e., load SCHEM_NAME, and,
-- assuming that only a single path endpoint exists, substitute ignore
-- for all no_paths nodes and convert the solitary path endpoint into
-- an entrance.

local function generate_buildinglike_schematic (schem_name)
	local schematic = core.read_schematic (schem_name, {})
	if not schematic then
		error ("Could not load schematic: " .. schem_name)
	end

	local size = schematic.size
	local xstride = 1
	local ystride = size.x
	local zstride = size.x * size.y
	local ndata = schematic.data
	local endpoints = {}
	local beds = {}
	local pois = {}

	for x, y, z in ipos3 (0, 0, 0, size.x - 1, size.y - 1, size.z - 1) do
		local idx = z * zstride + y * ystride + x * xstride + 1
		if ndata[idx].name == "mcl_villages:no_paths" then
			ndata[idx].name = "air"
		elseif ndata[idx].name == "mcl_villages:path_endpoint" then
			ndata[idx].name = "air"
			table.insert (endpoints, { x, y, z, })
		elseif core.get_item_group (ndata[idx].name, "bed_bottom") >= 1 then
			table.insert (beds, { x, y, size.z - z - 1, })
		elseif is_job_site (ndata[idx].name) then
			table.insert (pois, {
				x, y, size.z - z - 1,
				ndata[idx].name,
			})
		end
	end

	local cx = floor (size.x / 2)
	local cy = floor (size.y / 2)
	local cz = floor (size.z / 2)

	if cx == 0 or cy == 0 or cz == 0 then
		error ("Building schematic is too small to "
		       .. "derive any useful orientation from")
	elseif #endpoints ~= 1 then
		error ("Expected one connecting block, but received "
		       .. #endpoints .. " (file = " .. schem_name .. ")")
	end

	schematic.exits = {}
	schematic.beds = beds
	schematic.pois = pois

	local x, y, z = unpack (endpoints[1])
	local dx, dz = x - cx, z - cz
	local orientation

	if mathabs (dx) >= mathabs (dz) then
		orientation = dx >= 0 and "90" or "270"
	else
		orientation = dz > 0 and "0" or "180"
	end
	schematic.connecting = {
		orientation = orientation,
		x = x,
		y = y,
		z = size.z - z - 1,
	}
	return schematic
end

-- Post-process a junction schematic, i.e., load SCHEM_NAME,
-- substitute ignore for all no_paths nodes, convert the only path
-- endpoint to the north into an entrance, and the remainder into
-- exits.  If there are no entrances to the north, arrange to select a
-- random exit to serve as an entrance.

local function generate_junction_schematic (schem_name)
	local schematic = core.read_schematic (schem_name, {})
	if not schematic then
		error ("Could not load schematic: " .. schem_name)
	end

	local size = schematic.size
	local xstride = 1
	local ystride = size.x
	local zstride = size.x * size.y
	local ndata = schematic.data
	local endpoints = {}
	local beds = {}
	local pois = {}

	for x, y, z in ipos3 (0, 0, 0, size.x - 1, size.y - 1, size.z - 1) do
		local idx = z * zstride + y * ystride + x * xstride + 1
		if ndata[idx].name == "mcl_villages:no_paths" then
			ndata[idx].name = "air"
		elseif ndata[idx].name == "mcl_villages:path_endpoint" then
			ndata[idx].name = "air"
			table.insert (endpoints, { x, y, z, })
		elseif core.get_item_group (ndata[idx].name, "bed_bottom") >= 1 then
			table.insert (beds, { x, y, size.z - z - 1, })
		elseif is_job_site (ndata[idx].name) then
			table.insert (pois, {
				x, y, size.z - z - 1,
				ndata[idx].name,
			})
		end
	end

	local cx = floor (size.x / 2)
	local cy = floor (size.y / 2)
	local cz = floor (size.z / 2)

	if cx == 0 or cy == 0 or cz == 0 then
		error ("Building schematic is too small to "
		       .. "derive any useful orientation from")
	end

	schematic.exits = {}
	schematic.beds = beds
	schematic.pois = pois

	for _, endpoint in ipairs (endpoints) do
		local x, y, z = unpack (endpoint)
		local dx, dz = x - cx, z - cz
		local orientation

		if mathabs (dx) >= mathabs (dz) then
			orientation = dx >= 0 and "90" or "270"
		else
			orientation = dz > 0 and "0" or "180"
		end

		if orientation == "0" then
			if schematic.connecting then
				error ("Multiple connecting nodes in junction schematic")
			end

			schematic.connecting = {
				orientation = orientation,
				x = x,
				y = y,
				z = size.z - z - 1,
			}
		else
			table.insert (schematic.exits, {
				orientation = orientation,
				x = x,
				y = y,
				z = size.z - z - 1,
			})
		end
	end
	if not schematic.connecting then
		schematic.connecting = "random_exit"
	end
	return schematic
end

local plains_village_template = {
	meeting_points = {
		"mcl_villages:new_villages/belltower",
	},
	job_buildings = {
		"mcl_villages:new_villages/butcher",
		"mcl_villages:new_villages/cartographer",
		"mcl_villages:new_villages/church",
		"mcl_villages:new_villages/chapel",
		"mcl_villages:new_villages/farm",
		"mcl_villages:new_villages/fishery_levelgen",
		"mcl_villages:new_villages/fletcher",
		"mcl_villages:fletcher_tiny",
		"mcl_villages:church_european",
		"mcl_villages:new_villages/leather_worker",
		"mcl_villages:new_villages/library",
		"mcl_villages:new_villages/mason",
		"mcl_villages:new_villages/mill",
		"mcl_villages:librarian",
		"mcl_villages:new_villages/toolsmith",
		"mcl_villages:new_villages/weaponsmith",
	},
	house_buildings = {
		"mcl_villages:new_villages/house_1_bed",
		"mcl_villages:new_villages/house_2_bed",
		"mcl_villages:new_villages/house_3_bed",
		"mcl_villages:new_villages/house_3_bed",
		"mcl_villages:new_villages/house_4_bed",
		"mcl_villages:new_villages/house_4_bed",
		"mcl_villages:house_chimney",
	},
	street_decor = {
		"mcl_villages:new_villages/lamp_1",
		"mcl_villages:new_villages/lamp_2",
		"mcl_villages:new_villages/lamp_3",
		"mcl_villages:new_villages/lamp_4",
		"mcl_villages:new_villages/lamp_5",
		"mcl_villages:new_villages/lamp_6",
	},
	farms = {
		"mcl_villages:new_villages/farm_large_1",
		"mcl_villages:new_villages/farm_small_1",
		"mcl_villages:new_villages/farm_small_2",
	},
	well = {
		"mcl_villages:new_villages/well",
	},
	piles = {
		"mcl_villages:pile_hay",
	},
}

local desert_village_template = {
	meeting_points = {
		"mcl_villages:new_villages/belltower",
	},
	job_buildings = {
		"mcl_villages:new_villages/butcher",
		"mcl_villages:new_villages/cartographer",
		"mcl_villages:new_villages/church",
		"mcl_villages:new_villages/chapel",
		"mcl_villages:new_villages/farm",
		"mcl_villages:new_villages/fishery_levelgen",
		"mcl_villages:new_villages/fletcher",
		"mcl_villages:new_villages/leather_worker",
		"mcl_villages:new_villages/library",
		"mcl_villages:new_villages/mason",
		"mcl_villages:new_villages/mill",
		"mcl_villages:new_villages/toolsmith",
		"mcl_villages:new_villages/weaponsmith",
	},
	house_buildings = {
		"mcl_villages:new_villages/house_1_bed",
		"mcl_villages:new_villages/house_2_bed",
		"mcl_villages:new_villages/house_3_bed",
		"mcl_villages:new_villages/house_3_bed",
		"mcl_villages:new_villages/house_4_bed",
		"mcl_villages:new_villages/house_4_bed",
	},
	street_decor = {
		"mcl_villages:new_villages/lamp_1",
		"mcl_villages:new_villages/lamp_2",
		"mcl_villages:new_villages/lamp_3",
		"mcl_villages:new_villages/lamp_4",
		"mcl_villages:new_villages/lamp_5",
		"mcl_villages:new_villages/lamp_6",
	},
	farms = {
		"mcl_villages:new_villages/farm_large_1",
		"mcl_villages:new_villages/farm_small_1",
		"mcl_villages:new_villages/farm_small_2",
	},
	well = {
		"mcl_villages:new_villages/well",
	},
	piles = {
		"mcl_villages:pile_hay",
	},
}

local snowy_village_template = {
	meeting_points = {
		"mcl_villages:new_villages/belltower",
	},
	job_buildings = {
		"mcl_villages:new_villages/butcher",
		"mcl_villages:new_villages/cartographer",
		"mcl_villages:new_villages/church",
		"mcl_villages:new_villages/chapel",
		"mcl_villages:new_villages/farm",
		"mcl_villages:new_villages/fishery_levelgen",
		"mcl_villages:new_villages/fletcher",
		"mcl_villages:fletcher_tiny",
		"mcl_villages:church_european",
		"mcl_villages:new_villages/leather_worker",
		"mcl_villages:new_villages/library",
		"mcl_villages:new_villages/mason",
		"mcl_villages:new_villages/mill",
		"mcl_villages:librarian",
		"mcl_villages:new_villages/toolsmith",
		"mcl_villages:new_villages/weaponsmith",
	},
	house_buildings = {
		"mcl_villages:new_villages/house_1_bed",
		"mcl_villages:new_villages/house_2_bed",
		"mcl_villages:new_villages/house_3_bed",
		"mcl_villages:new_villages/house_3_bed",
		"mcl_villages:new_villages/house_4_bed",
		"mcl_villages:new_villages/house_4_bed",
		"mcl_villages:house_chimney",
	},
	street_decor = {
		"mcl_villages:new_villages/lamp_1",
		"mcl_villages:new_villages/lamp_2",
		"mcl_villages:new_villages/lamp_3",
		"mcl_villages:new_villages/lamp_4",
		"mcl_villages:new_villages/lamp_5",
		"mcl_villages:new_villages/lamp_6",
	},
	farms = {
		"mcl_villages:new_villages/farm_large_1",
		"mcl_villages:new_villages/farm_small_1",
		"mcl_villages:new_villages/farm_small_2",
	},
	well = {
		"mcl_villages:new_villages/well",
	},
	piles = {
		"mcl_villages:pile_ice",
		"mcl_villages:pile_snow",
	},
}

local savannah_village_template = {
	meeting_points = {
		"mcl_villages:new_villages/belltower",
	},
	job_buildings = {
		"mcl_villages:new_villages/butcher",
		"mcl_villages:new_villages/cartographer",
		"mcl_villages:new_villages/church",
		"mcl_villages:new_villages/chapel",
		"mcl_villages:new_villages/farm",
		"mcl_villages:new_villages/fishery_levelgen",
		"mcl_villages:new_villages/fletcher",
		"mcl_villages:fletcher_tiny",
		"mcl_villages:church_european",
		"mcl_villages:new_villages/leather_worker",
		"mcl_villages:new_villages/library",
		"mcl_villages:new_villages/mason",
		"mcl_villages:new_villages/mill",
		"mcl_villages:librarian",
		"mcl_villages:new_villages/toolsmith",
		"mcl_villages:new_villages/weaponsmith",
	},
	house_buildings = {
		"mcl_villages:new_villages/house_1_bed",
		"mcl_villages:new_villages/house_2_bed",
		"mcl_villages:new_villages/house_3_bed",
		"mcl_villages:new_villages/house_3_bed",
		"mcl_villages:new_villages/house_4_bed",
		"mcl_villages:new_villages/house_4_bed",
		"mcl_villages:house_chimney",
	},
	street_decor = {
		"mcl_villages:new_villages/lamp_1",
		"mcl_villages:new_villages/lamp_2",
		"mcl_villages:new_villages/lamp_3",
		"mcl_villages:new_villages/lamp_4",
		"mcl_villages:new_villages/lamp_5",
		"mcl_villages:new_villages/lamp_6",
	},
	farms = {
		"mcl_villages:new_villages/farm_large_1",
		"mcl_villages:new_villages/farm_small_1",
		"mcl_villages:new_villages/farm_small_2",
	},
	well = {
		"mcl_villages:new_villages/well",
	},
	piles = {
		"mcl_villages:pile_hay",
		"mcl_villages:pile_melon",
	},
}

local taiga_village_template = {
	meeting_points = {
		"mcl_villages:new_villages/belltower",
	},
	job_buildings = {
		"mcl_villages:new_villages/butcher",
		"mcl_villages:new_villages/cartographer",
		"mcl_villages:new_villages/church",
		"mcl_villages:new_villages/chapel",
		"mcl_villages:new_villages/farm",
		"mcl_villages:new_villages/fishery_levelgen",
		"mcl_villages:new_villages/fletcher",
		"mcl_villages:fletcher_tiny",
		"mcl_villages:church_european",
		"mcl_villages:new_villages/leather_worker",
		"mcl_villages:new_villages/library",
		"mcl_villages:new_villages/mason",
		"mcl_villages:new_villages/mill",
		"mcl_villages:librarian",
		"mcl_villages:new_villages/toolsmith",
		"mcl_villages:new_villages/weaponsmith",
	},
	house_buildings = {
		"mcl_villages:new_villages/house_1_bed",
		"mcl_villages:new_villages/house_2_bed",
		"mcl_villages:new_villages/house_3_bed",
		"mcl_villages:new_villages/house_3_bed",
		"mcl_villages:new_villages/house_4_bed",
		"mcl_villages:new_villages/house_4_bed",
		"mcl_villages:house_chimney",
	},
	street_decor = {
		"mcl_villages:new_villages/lamp_1",
		"mcl_villages:new_villages/lamp_2",
		"mcl_villages:new_villages/lamp_3",
		"mcl_villages:new_villages/lamp_4",
		"mcl_villages:new_villages/lamp_5",
		"mcl_villages:new_villages/lamp_6",
	},
	farms = {
		"mcl_villages:new_villages/farm_large_1",
		"mcl_villages:new_villages/farm_small_1",
		"mcl_villages:new_villages/farm_small_2",
	},
	well = {
		"mcl_villages:new_villages/well",
	},
	piles = {
		"mcl_villages:pile_pumpkin",
	},
}

local village_templates = {
	plains = plains_village_template,
	desert = desert_village_template,
	snowy = snowy_village_template,
	savannah = savannah_village_template,
	taiga = taiga_village_template,
}

local names_bell = {
	"new_villages/belltower",
}
local names_building = {
	"new_villages/blacksmith",
	"new_villages/butcher",
	"new_villages/cartographer",
	"new_villages/church",
	"new_villages/house_1_bed",
	"new_villages/house_2_bed",
	"new_villages/house_3_bed",
	"new_villages/house_4_bed",
	"new_villages/leather_worker",
	"new_villages/library",
	"new_villages/mason",
	"new_villages/mill",
	"new_villages/toolsmith",
	"new_villages/weaponsmith",

	"fletcher_tiny",
	"house_chimney",
	"librarian",
}
local names_junction = {
	"new_villages/chapel",
	"new_villages/farm",
	"new_villages/farm_large_1",
	"new_villages/farm_small_1",
	"new_villages/farm_small_2",
	"new_villages/fishery_levelgen",
	"new_villages/fletcher",
	"new_villages/well",

	"church_european",
}
local names_standalone = {
	"new_villages/lamp_1",
	"new_villages/lamp_2",
	"new_villages/lamp_3",
	"new_villages/lamp_4",
	"new_villages/lamp_5",
	"new_villages/lamp_6",
}

local schematic_meta = {}

function mcl_villages.load_default_schematics ()
	for _, name in ipairs (names_bell) do
		local id = "mcl_villages:" .. name
		local file = mcl_villages.modpath .. "/schematics/" .. name .. ".mts"
		local schematic = generate_bell_schematic (file)
		mcl_levelgen.register_portable_schematic (id, schematic, true)
		local meta = {
			connecting = schematic.connecting,
			exits = schematic.exits,
			bell = schematic.bell,
			bell_spawn = schematic.bell_spawn,
			beds = schematic.beds,
			pois = schematic.pois,
		}
		schematic_meta[id] = meta
	end

	for _, name in ipairs (names_building) do
		local id = "mcl_villages:" .. name
		local file = mcl_villages.modpath .. "/schematics/" .. name .. ".mts"
		local schematic = generate_buildinglike_schematic (file)
		mcl_levelgen.register_portable_schematic (id, schematic, true)
		local meta = {
			connecting = schematic.connecting,
			exits = schematic.exits,
			beds = schematic.beds,
			pois = schematic.pois,
		}
		schematic_meta[id] = meta
	end

	for _, name in ipairs (names_junction) do
		local id = "mcl_villages:" .. name
		local file = mcl_villages.modpath .. "/schematics/" .. name .. ".mts"
		local schematic = generate_junction_schematic (file)
		mcl_levelgen.register_portable_schematic (id, schematic, true)
		local meta = {
			connecting = schematic.connecting,
			exits = schematic.exits,
			beds = schematic.beds,
			pois = schematic.pois,
		}
		schematic_meta[id] = meta
	end

	for _, name in ipairs (names_standalone) do
		local id = "mcl_villages:" .. name
		local file = mcl_villages.modpath .. "/schematics/" .. name .. ".mts"
		mcl_levelgen.register_portable_schematic (id, file, true)
		schematic_meta[id] = {
			connecting = nil,
			exits = {},
		}
	end
end

mcl_villages.load_default_schematics ()

core.register_on_mods_loaded (function ()
	core.ipc_set ("mcl_villages:schematic_meta", schematic_meta)
	mcl_villages.finalize_building_definitions ()
end)

------------------------------------------------------------------------
-- Village callbacks.
------------------------------------------------------------------------

local village_armorer = {
	stacks_min = 1,
	stacks_max = 5,
	items = {
		{
			weight = 2,
			itemstring = "mcl_core:iron_ingot",
			amount_min = 1,
			amount_max = 10,
		},
		{
			weight = 4,
			itemstring = "mcl_farming:bread",
			amount_min = 1,
			amount_max = 4,
		},
		{
			itemstring = "mcl_armor:helmet_iron",
		},
		{
			itemstring = "mcl_core:emerald",
		},
	},
}

local village_butcher = {
	stacks_min = 1,
	stacks_max = 5,
	items = {
		{
			itemstring = "mcl_core:emerald",
		},
		{
			itemstring = "mcl_mobitems:porkchop",
			amount_min = 1,
			amount_max = 3,
		},
		{
			itemstring = "mcl_farming:wheat_item",
			amount_min = 1,
			amount_max = 3,
		},
		{
			itemstring = "mcl_mobitems:beef",
			amount_min = 1,
			amount_max = 3,
		},
		{
			itemstring = "mcl_mobitems:mutton",
			amount_min = 1,
			amount_max = 3,
		},
	},
}

local village_cartographer = {
	stacks_min = 1,
	stacks_max = 5,
	items = {
		{
			itemstring = "mcl_maps:empty_map",
			amount_min = 1.0,
			amount_max = 3.0,
			weight = 10,
		},
		{
			itemstring = "mcl_core:paper",
			amount_min = 1.0,
			amount_max = 5.0,
			weight = 15,
		},
		{
			itemstring = "mcl_compass:compass",
			weight = 5,
		},
		{
			itemstring = "mcl_farming:bread",
			weight = 15,
		},
		{
			itemstring = "mcl_core:stick",
			amount_max = 2.0,
			amount_min = 1.0,
			weight = 5,
		},
	},
}

local village_desert_house = {
	stacks_min = 3,
	stacks_max = 8,
	items = {
		{
			itemstring = "mcl_core:clay_lump",
		},
		{
			itemstring = "mcl_dyes:green",
		},
		{
			itemstring = "mcl_core:cactus",
			amount_min = 1,
			amount_max = 4,
			weight = 10,
		},
		{
			itemstring = "mcl_farming:bread",
			amount_min = 1,
			amount_max = 4,
			weight = 10,
		},
		{
			itemstring = "mcl_books:book",
		},
		{
			itemstring = "mcl_core:deadbush",
			amount_min = 1,
			amount_max = 3,
			weight = 2,
		},
		{
			itemstring = "mcl_core:emerald",
			amount_min = 1,
			amount_max = 3,
		},
	},
}

local village_fisher = {
	stacks_min = 1,
	stacks_max = 5,
	items = {
		{
			itemstring = "mcl_core:emerald",
		},
		{
			itemstring = "mcl_fishing:fish_raw",
			amount_max = 3.0,
			amount_min = 1.0,
			weight = 2,
		},
		{
			itemstring = "mcl_fishing:salmon_raw",
			amount_max = 3.0,
			amount_min = 1.0,
		},
		{
			itemstring = "mcl_buckets:bucket_water",
			amount_max = 3.0,
			amount_min = 1.0,
		},
		{
			itemstring = "mcl_barrels:barrel_closed",
			amount_max = 3.0,
			amount_min = 1.0,
		},
		{
			itemstring = "mcl_core:coal_lump",
			amount_max = 3.0,
			amount_min = 2.0,
			weight = 2,
		},
	},
}

local village_fletcher = {
	stacks_min = 1,
	stacks_max = 5,
	items = {
		{
			itemstring = "mcl_bows:arrow",
			amount_max = 3.0,
			amount_min = 1.0,
			weight = 2,
		},
		{
			itemstring = "mcl_mobitems:feather",
			amount_max = 3.0,
			amount_min = 1.0,
			weight = 6,
		},
		{
			itemstring = "mcl_throwing:egg",
			amount_max = 3.0,
			amount_min = 1.0,
			weight = 6,
		},
		{
			itemstring = "mcl_core:flint",
			amount_max = 3.0,
			amount_min = 1.0,
			weight = 6,
		},
		{
			itemstring = "mcl_core:stick",
			amount_max = 3.0,
			amount_min = 1.0,
			weight = 6,
		},
	},
}

local village_mason = {
	stacks_min = 1,
	stacks_max = 5,
	items = {
		{
			itemstring = "mcl_core:clay_lump",
			amount_max = 3.0,
			amount_min = 1.0,
		},
		{
			itemstring = "mcl_flowerpots:flower_pot",
		},
		{
			itemstring = "mcl_core:stone",
			weight = 2,
		},
		{
			itemstring = "mcl_core:stonebrick",
			weight = 2,
		},
		{
			itemstring = "mcl_farming:bread",
			amount_max = 4.0,
			amount_min = 1.0,
			weight = 4,
		},
		{
			itemstring = "mcl_dyes:yellow",
		},
		{
			itemstring = "mcl_core:stone_smooth",
		},
		{
			itemstring = "mcl_core:emerald",
		},
	},
}

local village_plains_house = {
	stacks_min = 3,
	stacks_max = 8,
	items = {
		{
			itemstring = "mcl_core:gold_nugget",
			amount_min = 1,
			amount_max = 3,
		},
		{
			itemstring = "mcl_flowers:dandelion",
			weight = 2,
		},
		{
			itemstring = "mcl_flowers:poppy",
		},
		{
			itemstring = "mcl_farming:potato_item",
			amount_min = 1,
			amount_max = 7,
			weight = 10,
		},
		{
			itemstring = "mcl_farming:bread",
			amount_min = 1,
			amount_max = 4,
			weight = 10,
		},
		{
			itemstring = "mcl_core:apple",
			amount_min = 1,
			amount_max = 5,
			weight = 10,
		},
		{
			itemstring = "mcl_books:book",
		},
		{
			itemstring = "mcl_mobitems:feather",
		},
		{
			itemstring = "mcl_core:emerald",
			amount_min = 1,
			amount_max = 4,
			weight = 2,
		},
		{
			itemstring = "mcl_trees:sapling_oak",
			amount_min = 1,
			amount_max = 2,
			weight = 5,
		},
	},
}

local village_savannah_house = {
	stacks_min = 3,
	stacks_max = 8,
	items = {
		{
			itemstring = "mcl_core:gold_nugget",
			amount_min = 1,
			amount_max = 3,
		},
		{
			itemstring = "mcl_flowers:tallgrass",
			weight = 5,
		},
		{
			itemstring = "mcl_flowers:double_grass",
			weight = 5,
		},
		{
			itemstring = "mcl_farming:bread",
			amount_min = 1,
			amount_max = 4,
			weight = 10,
		},
		{
			itemstring = "mcl_farming:wheat_seeds",
			amount_min = 1,
			amount_max = 4,
			weight = 10,
		},
		{
			itemstring = "mcl_core:emerald",
			amount_min = 1,
			amount_max = 4,
			weight = 2,
		},
		{
			itemstring = "mcl_trees:sapling_acacia",
			amount_min = 1,
			amount_max = 2,
			weight = 10,
		},
		{
			itemstring = "mcl_mobitems:saddle",
		},
		{
			itemstring = "mcl_torches:torch",
			amount_min = 1,
			amount_max = 2,
		},
		{
			itemstring = "mcl_buckets:bucket_empty",
		},
	},
}

local village_shepherd = {
	stacks_min = 1,
	stacks_max = 5,
	items = {
		{
			itemstring = "mcl_wool:white",
			amount_max = 8.0,
			amount_min = 1.0,
			weight = 6,
		},
		{
			itemstring = "mcl_wool:black",
			amount_max = 3.0,
			amount_min = 1.0,
			weight = 3,
		},
		{
			itemstring = "mcl_wool:grey",
			amount_max = 3.0,
			amount_min = 1.0,
			weight = 2,
		},
		{
			itemstring = "mcl_wool:silver",
			amount_max = 3.0,
			amount_min = 1.0,
			weight = 2,
		},
		{
			itemstring = "mcl_core:emerald",
		},
		{
			itemstring = "mcl_tools:shears",
		},
	},
}

local village_snowy_house = {
	stacks_min = 3,
	stacks_max = 8,
	items = {
		{
			itemstring = "mcl_core:blue_ice",
		},
		{
			itemstring = "mcl_core:snowblock",
			weight = 4,
		},
		{
			itemstring = "mcl_farming:potato_item",
			amount_min = 1,
			amount_max = 7,
			weight = 10,
		},
		{
			itemstring = "mcl_farming:bread",
			amount_min = 1,
			amount_max = 4,
			weight = 10,
		},
		{
			itemstring = "mcl_farming:beetroot_seeds",
			amount_min = 1,
			amount_max = 5,
			weight = 10,
		},
		{
			itemstring = "mcl_farming:beetroot_soup",
		},
		{
			itemstring = "mcl_furnaces:furnace",
		},
		{
			itemstring = "mcl_core:emerald",
			amount_min = 1,
			amount_max = 4,
			weight = 2,
		},
		{
			itemstring = "mcl_throwing:snowball",
			amount_min = 1,
			amount_max = 7,
			weight = 10,
		},
		{
			itemstring = "mcl_core:coal_lump",
			amount_min = 1,
			amount_max = 4,
			weight = 5,
		},
	},
}

local village_taiga_house = {
	stacks_min = 3,
	stacks_max = 8,
	items = {
		{
			itemstring = "mcl_core:iron_nugget",
			amount_min = 1.0,
			amount_max = 5.0,
		},
		{
			itemstring = "mcl_flowers:fern",
			weight = 2,
		},
		{
			itemstring = "mcl_flowers:double_fern",
			weight = 2,
		},
		{
			itemstring = "mcl_farming:potato_item",
			amount_min = 1,
			amount_max = 7,
			weight = 10,
		},
		{
			itemstring = "mcl_farming:sweet_berry",
			amount_min = 1,
			amount_max = 7,
			weight = 5,
		},
		{
			itemstring = "mcl_farming:bread",
			amount_min = 1,
			amount_max = 4,
			weight = 10,
		},
		{
			itemstring = "mcl_farming:pumpkin_seeds",
			amount_min = 1,
			amount_max = 5,
			weight = 5,
		},
		{
			itemstring = "mcl_core:emerald",
			amount_min = 1,
			amount_max = 4,
			weight = 2,
		},
		{
			itemstring = "mcl_trees:sapling_spruce",
			amount_min = 1,
			amount_max = 5,
			weight = 5,
		},
		{
			itemstring = "mcl_signs:wall_sign_spruce",
		},
		{
			itemstring = "mcl_trees:wood_spruce",
			amount_min = 1,
			amount_max = 5,
			weight = 10,
		},
	},
}

local village_tannery = {
	stacks_min = 1,
	stacks_max = 5,
	items = {
		{
			itemstring = "mcl_mobitems:leather",
			amount_min = 1.0,
			amount_max = 3.0,
		},
		{
			itemstring = "mcl_armor:chestplate_leather",
			weight = 2,
		},
		{
			itemstring = "mcl_armor:boots_leather",
			weight = 2,
		},
		{
			itemstring = "mcl_armor:helmet_leather",
			weight = 2,
		},
		{
			itemstring = "mcl_farming:bread",
			amount_min = 1,
			amount_max = 4,
			weight = 5,
		},
		{
			itemstring = "mcl_armor:leggings_leather",
		},
		{
			itemstring = "mcl_mobitems:saddle",
		},
		{
			itemstring = "mcl_core:emerald",
			amount_min = 1,
			amount_max = 4,
		},
	},
}

local village_temple = {
	stacks_min = 1,
	stacks_max = 8,
	items = {
		{
			itemstring = "mcl_redstone:redstone",
			amount_min = 1,
			amount_max = 4,
			weight = 2,
		},
		{
			itemstring = "mcl_farming:bread",
			amount_min = 1,
			amount_max = 4,
			weight = 7,
		},
		{
			itemstring = "mcl_mobitems:rotten_flesh",
			amount_min = 1,
			amount_max = 4,
			weight = 7,
		},
		{
			itemstring = "mcl_core:lapis",
			amount_min = 1,
			amount_max = 4,
		},
		{
			itemstring = "mcl_core:gold_ingot",
			amount_min = 1,
			amount_max = 4,
		},
		{
			itemstring = "mcl_core:emerald",
			amount_min = 1,
			amount_max = 4,
		},
	},
}

local village_toolsmith = {
	stacks_min = 3.0,
	stacks_max = 8.0,
	items = {
		{
			itemstring = "mcl_core:diamond",
			amount_min = 1,
			amount_max = 3,
		},
		{
			itemstring = "mcl_core:iron_ingot",
			amount_min = 1,
			amount_max = 5,
			weight = 5,
		},
		{
			itemstring = "mcl_core:gold_ingot",
			amount_min = 1,
			amount_max = 3,
		},
		{
			itemstring = "mcl_farming:bread",
			amount_min = 1,
			amount_max = 3,
			weight = 15,
		},
		{
			itemstring = "mcl_core:coal_lump",
			amount_min = 1,
			amount_max = 3,
		},
		{
			itemstring = "mcl_core:stick",
			amount_min = 1,
			amount_max = 3,
			weight = 20,
		},
		{
			itemstring = "mcl_tools:shovel_iron",
			weight = 5,
		},
	},
}

local village_weaponsmith = {
	stacks_min = 3.0,
	stacks_max = 8.0,
	items = {
		{
			itemstring = "mcl_core:diamond",
			amount_min = 1,
			amount_max = 3,
		},
		{
			itemstring = "mcl_core:iron_ingot",
			amount_min = 1,
			amount_max = 5,
			weight = 5,
		},
		{
			itemstring = "mcl_core:gold_ingot",
			amount_min = 1,
			amount_max = 3,
		},
		{
			itemstring = "mcl_farming:bread",
			amount_min = 1,
			amount_max = 3,
			weight = 15,
		},
		{
			itemstring = "mcl_core:apple",
			amount_min = 1,
			amount_max = 3,
			weight = 15,
		},
		{
			itemstring = "mcl_tools:pick_iron",
			weight = 5,
		},
		{
			itemstring = "mcl_tools:sword_iron",
			weight = 5,
		},
		{
			itemstring = "mcl_armor:chestplate_iron",
			weight = 5,
		},
		{
			itemstring = "mcl_armor:helmet_iron",
			weight = 5,
		},
		{
			itemstring = "mcl_armor:leggings_iron",
			weight = 5,
		},
		{
			itemstring = "mcl_armor:boots_iron",
			weight = 5,
		},
		{
			itemstring = "mcl_core:obsidian",
			amount_min = 3,
			amount_max = 7,
			weight = 5,
		},
		{
			itemstring = "mcl_trees:sapling_oak",
			amount_min = 3,
			amount_max = 7,
			weight = 5,
		},
		{
			itemstring = "mcl_mobitems:saddle",
			weight = 3,
		},
		{
			itemstring = "mcl_mobitems:iron_horse_armor",
		},
		{
			itemstring = "mcl_mobitems:gold_horse_armor",
		},
		{
			itemstring = "mcl_mobitems:diamond_horse_armor",
		},
	},
}

local schematic_loot_tables = {
	["mcl_villages:new_villages/blacksmith"] = village_armorer,
	["mcl_villages:new_villages/butcher"] = village_butcher,
	["mcl_villages:new_villages/cartographer"] = village_cartographer,
	["mcl_villages:new_villages/chapel"] = village_temple,
	["mcl_villages:new_villages/church"] = village_temple,
	["mcl_villages:new_villages/fishery_levelgen"] = village_fisher,
	["mcl_villages:new_villages/fletcher"] = village_fletcher,
	["mcl_villages:new_villages/leather_worker"] = village_tannery,
	["mcl_villages:new_villages/mason"] = village_mason,
	["mcl_villages:new_villages/mill"] = village_shepherd,
	["mcl_villages:new_villages/toolsmith"] = village_toolsmith,
	["mcl_villages:new_villages/weaponsmith"] = village_weaponsmith,
}

local type_loot_tables = {
	plains = village_plains_house,
	savannah = village_savannah_house,
	desert = village_desert_house,
	taiga = village_taiga_house,
	snowy = village_snowy_house,
}

local function verify_loot_table (name, loot)
	if loot.stacks_max < loot.stacks_min then
		local blurb = string.format ("Invalid loot table %s; stack_max %d < stack_min %d",
					     name, loot.stacks_max, loot.stacks_min)
		core.log ("error", blurb)
	end

	for i, item in ipairs (loot.items) do
		if item.amount_min or item.amount_max then
			if not item.amount_max or not item.amount_min then
				local blurb = "Item %d in loot table %s defines an incomplete stack size range"
				core.log ("error", string.format (blurb, i, loot))
			end
		end

		local stack = ItemStack (item.itemstring)
		if not core.registered_items[stack:get_name ()] then
			core.log ("error", "Item does not exist: " .. stack:get_name ())
		end
	end
end

for name, loot in pairs (schematic_loot_tables) do
	verify_loot_table (name, loot)
end

for name, loot in pairs (type_loot_tables) do
	verify_loot_table (name, loot)
end

local level_to_minetest_position = mcl_levelgen.level_to_minetest_position
local v = vector.zero ()

local function handle_village_chest (_, data)
	local x, y, z = level_to_minetest_position (data.x, data.y, data.z)
	local loot_table = schematic_loot_tables[data.schematic]
		or type_loot_tables[data.type]
		or village_plains_house
	v.x = x
	v.y = y
	v.z = z
	core.load_area (v)
	local node = core.get_node (v)
	if node.name == "mcl_chests:chest_small" then
		local pr = PcgRandom (data.loot_seed)
		local loot = mcl_loot.get_loot (loot_table, pr)
		local meta = core.get_meta (v)
		local inv = meta:get_inventory ()
		mcl_structures.construct_nodes (v, v, {"mcl_chests:chest_small",})
		mcl_loot.fill_inventory (inv, "main", loot, pr)
	end
end

mcl_levelgen.register_notification_handler ("mcl_villages:village_chest",
					    handle_village_chest)

local v0 = vector.zero ()
local v1 = vector.zero ()
local v2 = vector.zero ()

local rng

if mcl_levelgen.levelgen_enabled or mcl_levelgen.enable_ersatz then
	rng = mcl_levelgen.overworld_preset.factory ("mcl_villages:zombie_villager_spawning")
	rng = rng:fork_positional ():create_reseedable ()
end

local on_villager_placed = mcl_villages.on_villager_placed

local function handle_villager (_, data)
	local bed, bell, poi = data.bed, data.bell, data.poi
	v0.x, v0.y, v0.z
		= level_to_minetest_position (bed[1], bed[2], bed[3])
	v1.x, v1.y, v1.z
		= level_to_minetest_position (bell[1], bell[2], bell[3])
	if poi then
		v2.x, v2.y, v2.z
			= level_to_minetest_position (poi[1], poi[2], poi[3])
	end
	core.load_area (v0)

	if data.is_zombie then
		rng:reseed_positional (v0.x, v0.y, v0.z)
		local value = rng:next_within (5)
		if value == 0 then
			core.add_entity (vector.offset (v0, 0, -0.1, 0),
					 "mobs_mc:villager_zombie",
					 core.serialize ({ persistent = true, }))
		end
		return
	end

	local reservation = mcl_villages.get_poi (v0)
	if not reservation
		or reservation.data ~= "mcl_villages:worldgen_reservation" then
		core.log ("warning", ("[mcl_villages]: Existing or unreserved bed at "
				      .. vector.to_string (v0) .. " assigned to villager"))
		return
	end
	mcl_villages.remove_poi (reservation.id)
	local object = core.add_entity (vector.offset (v0, 0, -0.1, 0),
					"mobs_mc:villager")
	if not object then
		return
	end
	local villager = object:get_luaentity ()
	villager:claim_home (v0)
	villager:claim_bell (v1)

	if poi then
		local reservation = mcl_villages.get_poi (v2)
		if not reservation
			or reservation.data ~= "mcl_villages:worldgen_reservation" then
			core.log ("warning", ("[mcl_villages]: Existing or unreserved POI at "
					      .. vector.to_string (v2) .. " assigned to villager"))
			return
		end
		mcl_villages.remove_poi (reservation.id)
		villager:claim_poi (v2, {
			name = poi[4],
			param2 = 0,
		})
	end

	if #on_villager_placed > 0 then
		rng:reseed_positional (v0.x, v0.y, v0.z)
		local ull = rng:next_long ()
		for _, callback in ipairs (on_villager_placed) do
			callback (villager, ull)
		end
	end
end

mcl_levelgen.register_notification_handler ("mcl_villages:villager", handle_villager)

local function handle_village_start_available (_, data)
	for _, poi in ipairs (data) do
		v2.x, v2.y, v2.z
			= level_to_minetest_position (poi[1], poi[2], poi[3])
		local poi = mcl_villages.get_poi (v2)
		if not poi then
			mcl_villages.insert_poi (v2, "mcl_villages:worldgen_reservation")
		end
	end
end

mcl_levelgen.register_notification_handler ("mcl_villages:village_start_available",
					    handle_village_start_available)

local function handle_spawn_iron_golem (_, data)
	local x, y, z = data[1], data[2], data[3]
	v0.x, v0.y, v0.z
		= level_to_minetest_position (x, y - 0.5, z)
	core.add_entity (v0, "mobs_mc:iron_golem")
end

mcl_levelgen.register_notification_handler ("mcl_villages:spawn_iron_golem",
					    handle_spawn_iron_golem)

core.ipc_set ("mcl_villages:material_substitutions",
	      mcl_villages.material_substitions) -- XXX: typo...

------------------------------------------------------------------------
-- POI construction LBMs.
-- Register LBMs to construct certain types of job site blocks that
-- were not constructed by previous versions of the level generator.
------------------------------------------------------------------------

if mcl_levelgen.levelgen_enabled or mcl_levelgen.enable_ersatz then
	core.register_lbm ({
		label = "Construct generated POIs with formspecs",
		name = "mcl_villages:construct_pois",
		nodenames = {
			"group:brewing_stand",
			"group:furnace",
			"mcl_grindstone:grindstone",
			"mcl_smithing_table:table",
			"mcl_stonecutter:stonecutter",
		},
		run_at_every_load = true,
		bulk_action = function (pos_list, _)
			for _, pos in ipairs (pos_list) do
				local meta = core.get_meta (pos)
				if meta:get_string ("formspec") == "" then
					local node = core.get_node (pos)
					local def = core.registered_nodes[node.name]
					if def then
						def.on_construct (pos)
					end
				end
			end
		end,
	})
end

------------------------------------------------------------------------
-- Modding interface.
------------------------------------------------------------------------

-- Load and register a village building schematic identified by NAME.
-- DEF must be a table with the following elements:
--
--    `type' identifies the type of village building schematic that is
--    being registered, decides the manner in which building path
--    endpoint nodes are treated by the schematic post-processor, and
--    must be one of the strings enumerated here:
--
--      - "bell"
--        Each path endpoint is treated as the origin of a village
--        path extending from its position in the cardinal direction
--        in which it stands in relation to the center of the
--        schematic, which must be a village bell.  Village buildings
--        will generate along the waysides.
--
--      - "building"
--        The solitary path endpoint in this schematic treated as the
--	  entrance to this building, which will generate with the side
--	  containing this endpoint facing the path which gave rise to
--	  it.
--
--      - "junction"
--	  One path endpoint is reserved as the entrance to the
--	  schematic and affects generation in the same manner as in
--	  the case of "building".  By default, this is the solitary
--	  endpoint on the north side of the schematic, but one is
--	  selected at random if no such endpoint exists.
--
--    `list' identifies the type of village building as which this
--    schematic should be capable of generating.  It must be one of
--    the following strings:
--
--      - "meeting_points"
--	  Village meeting points; the `type' of such a schematic must
--	  be defined to "bell".  Village generation will commence from
--	  schematics selected from this list, with paths radiating
--	  outward from its endpoints.
--
--      - "job_buildings"
--	  Village job buildings; these buildings are expected to
--	  incorporate villager work sites.
--
--      - "house_buildings"
--	  Village house buildings; these buildings are expected to
--	  incorporate residences and beds for generated villagers.
--
--      - "farms"
--	  Village farm buildings; these schematics are expected to
--	  incorporate farms and job sites for farmer villagers.
--
--	- "well"
--	  Village well buildings; these schematics are purely
--	  decorative and attempt to generate less frequently than
--	  other buildings (but generate successfully oftener, as they
--	  are generally smaller).
--
--    `file' provides the path to the .mts file from which this
--    village schematic will be loaded.
--
--    `variants' is any subset of the strings { "plains", "taiga",
--    "desert", "snowy", and "savannah", } specifying in which village
--    variants this schematic should generate.
--
--    `loot_table', if non-nil, specifies a loot table that will
--    supersede the village variant's default loot table during the
--    generation of chests in this schematic.
--
--    `weight', if non-nil, decides the relative weight of this
--    building to others registered with the same `list', i.e., the
--    number of occurrences of this schematic in that list; it may
--    also be a table indiced by village variant providing specific
--    values for each variant.
--
--  If this building's schematic incorporates job site nodes that
--  should be assigned to villagers at the time of generation, then
--  this function must be invoked _after_ the pertinent job sites are
--  defined with `mobs_mc.register_villager'.

local supplemental_building_definitions = {}

function mcl_villages.register_building_v2 (name, def)
	if schematic_meta[name] then
		error ("The building schematic `" ..
		       name .. "' has already been defined")
	end
	local schematic, meta

	if def.type == "bell" then
		schematic = generate_bell_schematic (def.file)
		meta = {
			connecting = schematic.connecting,
			exits = schematic.exits,
			bell = schematic.bell,
			bell_spawn = schematic.bell_spawn,
			beds = schematic.beds,
			pois = schematic.pois,
		}
	elseif def.type == "building" then
		schematic = generate_buildinglike_schematic (def.file)
		meta = {
			connecting = schematic.connecting,
			exits = schematic.exits,
			beds = schematic.beds,
			pois = schematic.pois,
		}
	elseif def.type == "junction" then
		schematic = generate_junction_schematic (def.file)
		meta = {
			connecting = schematic.connecting,
			exits = schematic.exits,
			beds = schematic.beds,
			pois = schematic.pois,
		}
	else
		error ("Invalid village building type: " .. def.type)
	end
	schematic_meta[name] = meta
	mcl_levelgen.register_portable_schematic (name, schematic, true)
	for _, variant in ipairs (def.variants) do
		assert (variant == "plains" or variant == "taiga"
			or variant == "desert" or variant == "snowy"
			or variant == "savannah",
			"Invalid village variant: " .. variant)
	end
	if def.list ~= "meeting_points"
		and def.list ~= "job_buildings"
		and def.list ~= "house_buildings"
		and def.list ~= "farms"
		and def.list ~= "well" then
		error ("Invalid building list: " .. def.list)
	end
	table.insert (supplemental_building_definitions, {
		id = name,
		list = def.list,
		variants = def.variants,
		weight = def.weight or 1,
	})
	schematic_loot_tables[name] = def.loot_table
end

local function compare_ids (a, b)
	return a.id < b.id
end

function mcl_villages.finalize_building_definitions ()
	table.sort (supplemental_building_definitions, compare_ids)
	for _, def in ipairs (supplemental_building_definitions) do
		for _, variant in ipairs (def.variants) do
			local list = village_templates[variant][def.list]
			local weight = type (def.weight == "table")
				and def.weight[variant] or def.weight
			for i = 1, weight do
				table.insert (list, def.id)
			end
		end
	end
	core.ipc_set ("mcl_villages:village_templates", village_templates)
end
