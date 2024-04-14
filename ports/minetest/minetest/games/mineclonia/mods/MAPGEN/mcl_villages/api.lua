mcl_villages.schematic_houses = {}
mcl_villages.schematic_jobs = {}
mcl_villages.schematic_lamps = {}
mcl_villages.schematic_bells = {}
mcl_villages.schematic_wells = {}

local S = minetest.get_translator(minetest.get_current_modname())

local function job_count(schem_lua)
	-- Local copy so we don't trash the schema for other uses, because apparently
	-- there isn't a non-destructive way to count occurrences of a string :(
	local str = schem_lua
	local count = 0

	for _, n in pairs(mobs_mc.jobsites) do
		if string.find(n, "^group:") then
			if n == "group:cauldron" then
				count = count + select(2, string.gsub(str, '"mcl_cauldrons:cauldron', ""))
			else
				minetest.log("warning", string.format("[mcl_villages] Don't know how to handle group %s counting it as 1 job site", n))
				count = count + 1
			end
		else
			count = count + select(2, string.gsub(str, '{name="' .. n .. '"', ""))
		end
	end

	return count
end

local function load_schema(name, mts)
	local schem_lua = minetest.serialize_schematic(mts, "lua", { lua_use_comments = false, lua_num_indent_spaces = 0 })
		.. " return schematic"

	local schematic = loadstring(schem_lua)()

	local data = {
		name = name,
		size = schematic.size,
		schem_lua = schem_lua,
	}

	return data
end

function mcl_villages.register_lamp(record)
	local data = load_schema(record["name"], record["mts"])
	if record["yadjust"] then
		data["yadjust"] = record["yadjust"]
	end
	table.insert(mcl_villages.schematic_lamps, data)
end

function mcl_villages.register_bell(record)
	local data = load_schema(record["name"], record["mts"])
	if record["yadjust"] then
		data["yadjust"] = record["yadjust"]
	end
	table.insert(mcl_villages.schematic_bells, data)
end

function mcl_villages.register_well(record)
	local data = load_schema(record["name"], record["mts"])
	if record["yadjust"] then
		data["yadjust"] = record["yadjust"]
	end
	table.insert(mcl_villages.schematic_wells, data)
end

local optional_fields = { "min_jobs", "max_jobs", "yadjust", "num_others" }

function mcl_villages.register_building(record)
	local data = load_schema(record["name"], record["mts"])

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
	else
		table.insert(mcl_villages.schematic_houses, data)
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

local function adjust_weights(biome, crop_type)
	if weighted_crops[biome] == nil then
		weighted_crops[biome] = {}
	end

	weighted_crops[biome][crop_type] = {}

	local factor = 100 / crop_list[biome][crop_type]["total_weight"]
	local total = 0

	for node, weight in pairs(crop_list[biome][crop_type]) do
		if node ~= "total_weight" then
			total = total + (math.round(weight * factor))
			table.insert(weighted_crops[biome][crop_type], { total = total, node = node })
		end
	end

	table.sort(weighted_crops[biome][crop_type], function(a, b)
		return a.total < b.total
	end)
end

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

	for i, rec in ipairs(weighted_crops[biome][crop_type]) do
		local weight = rec.total
		local node = rec.node

		if rand <= weight then
			return node
		end
	end

	return
end

function mcl_villages.register_crop(crop_def)

	local node = crop_def.node
	local crop_type = crop_def.type

	if table.indexof(supported_crop_types, crop_type) == -1 then
		minetest.log(S("Crop type @1 is not supported", crop_type))
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
		adjust_weights(biome, crop_type)
	end
end
