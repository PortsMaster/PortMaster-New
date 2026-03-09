mcl_villages.schematic_houses = {}
mcl_villages.schematic_jobs = {}
mcl_villages.schematic_lamps = {}
mcl_villages.schematic_bells = {}
mcl_villages.schematic_wells = {}
mcl_villages.on_village_placed = {}
mcl_villages.on_villager_placed = {}
mcl_villages.mandatory_buildings = {}
mcl_villages.forced_blocks = {}

local S = core.get_translator(core.get_current_modname())

local function job_count(schem_lua)
	local jobsites_nodes = {}
	local jobsites_groups = {}
	for _, jobsite in pairs(mobs_mc.jobsites) do
		if jobsite:sub(1, 6) == "group:" then
			jobsites_groups[jobsite:sub(7)] = 1
		else
			jobsites_nodes[jobsite] = 1
		end
	end

	local count = 0
	for name in schem_lua:gmatch([[name="([^"]*)"]]) do
		local hit = jobsites_nodes[name]
		if not hit then
			jobsites_nodes[name] = 0
			for group, _ in pairs(jobsites_groups) do
				if core.get_item_group(name, group) > 0 then
					jobsites_nodes[name] = 1
					break
				end
			end
			hit = jobsites_nodes[name]
		end
		count = count + hit
	end
	return count
end

local function load_schema(name, mts)
	local schem_lua = core.serialize_schematic(mts, "lua", { lua_use_comments = false, lua_num_indent_spaces = 0 })
		.. " return schematic"
	local schematic = loadstring(schem_lua)()
	return {
		name = name,
		size = schematic.size,
		schem_lua = schem_lua,
	}
end

local all_optional = { "yadjust", "no_ground_turnip", "no_clearance" }

local function set_all_optional(record, data)
	for _, field in ipairs(all_optional) do
		if record[field] then
			data[field] = record[field]
		end
	end
end

local function set_mandatory(record, type)
	if record['is_mandatory'] then
		if not mcl_villages.mandatory_buildings[type] then
			mcl_villages.mandatory_buildings[type] = {}
		end

		table.insert(mcl_villages.mandatory_buildings[type], record["name"])
	end
end

function mcl_villages.register_lamp(record)
	local data = load_schema(record["name"], record["mts"])
	set_all_optional(record, data)
	table.insert(mcl_villages.schematic_lamps, data)
	set_mandatory(record, 'lamps')
end

function mcl_villages.register_bell(record)
	local data = load_schema(record["name"], record["mts"])
	set_all_optional(record, data)
	table.insert(mcl_villages.schematic_bells, data)
	set_mandatory(record, 'bells')
end

function mcl_villages.register_well(record)
	local data = load_schema(record["name"], record["mts"])
	set_all_optional(record, data)
	table.insert(mcl_villages.schematic_wells, data)
	set_mandatory(record, 'wells')
end

local optional_fields = { "min_jobs", "max_jobs", "num_others", "is_mandatory" }

function mcl_villages.register_building(record)
	local data = load_schema(record["name"], record["mts"])

	set_all_optional(record, data)

	for _, field in ipairs(optional_fields) do
		if record[field] then
			data[field] = record[field]
		end
	end

	-- Local copy so we don't trash the schema for other uses
	local str = data["schem_lua"]
	local num_beds = select(2, string.gsub(str, '"mcl_beds:bed_[^"]+_bottom"', ""))

	if num_beds > 0 then
		data["num_beds"] = num_beds
	end

	local job_count = job_count(data["schem_lua"])

	if job_count > 0 then
		data["num_jobs"] = job_count
		table.insert(mcl_villages.schematic_jobs, data)
		set_mandatory(record, 'jobs')
	else
		table.insert(mcl_villages.schematic_houses, data)
		set_mandatory(record, 'houses')
	end
end

local supported_crop_types = {
	"grain",
	"root",
	"gourd",
	"bush",
	"tree",
	"flower",
}

local crop_list = {}

function mcl_villages.default_crop()
	return "mcl_farming:wheat_1"
end

local weighted_crops = {}

local function adjust_weights(biome, crop_type, list)
	if weighted_crops[biome] == nil then
		weighted_crops[biome] = {}
	end

	weighted_crops[biome][crop_type] = {}

	local factor = 100 / list["total_weight"]
	local total = 0

	local nodes = {}
	for node, weight in pairs(list) do
		if node ~= "total_weight" then
			table.insert (nodes, { node = node, weight = weight, })
		end
	end

	table.sort (nodes, function (a, b)
		if a.weight < b.weight then
			return true
		elseif a.weight > b.weight then
			return false
		else
			-- Also sort by node names to guarantee
			-- independence from mod load order.
			return a.node < b.node
		end
	end)

	for _, pair in ipairs (nodes) do
		local node, weight = pair.node, pair.weight
		total = total + (math.round(weight * factor))
		table.insert (weighted_crops[biome][crop_type], { total = total, node = node })
	end

	table.sort (weighted_crops[biome][crop_type], function (a, b)
		if a.total < b.total then
			return true
		elseif a.total > b.total then
			return false
		else
			-- Also sort by node names to guarantee
			-- independence from mod load order.
			return a.node < b.node
		end
	end)
end

core.register_on_mods_loaded (function ()
	for biome, by_type in pairs (crop_list) do
		for crop_type, list in pairs (by_type) do
			adjust_weights (biome, crop_type, list)
		end
	end
	core.ipc_set ("mcl_villages:crop_types", weighted_crops)
end)

function mcl_villages.get_crop_types()
	return table.copy(supported_crop_types)
end

function mcl_villages.get_crops()
	return table.copy(crop_list)
end

function mcl_villages.get_weighted_crop(biome, crop_type, pr)
	if weighted_crops[biome] == nil then
		biome = "plains"
	end

	if weighted_crops[biome][crop_type] == nil then
		return
	end

	local rand = pr:next(1, 99)

	for _, rec in ipairs(weighted_crops[biome][crop_type]) do
		local weight = rec.total
		local node = rec.node

		if rand <= weight then
			return node
		end
	end
end

function mcl_villages.register_crop(crop_def)

	local node = crop_def.node
	local crop_type = crop_def.type

	if table.indexof(supported_crop_types, crop_type) == -1 then
		core.log("warning", S("Crop type @1 is not supported", crop_type))
		return
	end

	for biome, weight in pairs(crop_def.biomes) do
		if crop_list[biome] == nil then
			crop_list[biome] = {}
		end

		if crop_list[biome][crop_type] == nil then
			crop_list[biome][crop_type] = { total_weight = 0 }
		end

		crop_list[biome][crop_type][node] = weight
		crop_list[biome][crop_type]["total_weight"] = crop_list[biome][crop_type]["total_weight"] + weight
	end
end

function mcl_villages.register_on_village_placed(func)
	table.insert(mcl_villages.on_village_placed, func)
end

function mcl_villages.register_on_villager_spawned(func)
	table.insert(mcl_villages.on_villager_placed, func)
end
