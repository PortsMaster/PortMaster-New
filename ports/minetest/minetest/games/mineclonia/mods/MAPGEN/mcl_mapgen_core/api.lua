local registered_generators = {}

local lvm, nodes, param2 = 0, 0, 0
local lvm_buffer = {}

local seed = minetest.get_mapgen_setting("seed")

local logging = minetest.settings:get_bool("mcl_logging_mapgen",false)

local function roundN(n, d)
	if type(n) ~= "number" then return n end
    local m = 10^d
    return math.floor(n * m + 0.5) / m
end

minetest.register_on_generated(function(minp, maxp, blockseed)
	local t1 = os.clock()
	local p1, p2 = {x=minp.x, y=minp.y, z=minp.z}, {x=maxp.x, y=maxp.y, z=maxp.z}
	if lvm > 0 then
		local lvm_used, shadow, deco_used, deco_table, ore_used, ore_table = false, false, false, false, false, false
		local lb2 = {} -- param2
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local e1, e2 = {x=emin.x, y=emin.y, z=emin.z}, {x=emax.x, y=emax.y, z=emax.z}
		local data2
		local data = vm:get_data(lvm_buffer)
		if param2 > 0 then
			data2 = vm:get_param2_data(lb2)
		end
		local area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})

		for _, rec in ipairs(registered_generators) do
			if rec.vf then
				local lvm_used0, shadow0, deco, ore = rec.vf(vm, data, data2, e1, e2, area, p1, p2, blockseed)
				if lvm_used0 then
					lvm_used = true
				end
				if shadow0 then
					shadow = true
				end
				if deco and type(deco) == "table" then
					deco_table = deco
				elseif deco then
					deco_used = true
				end
				if ore and type(ore) == "table" then
					ore_table = ore
				elseif deco then
					ore_used = true
				end
			end
		end

		if lvm_used then
			-- Write stuff
			vm:set_data(data)
			if param2 > 0 then
				vm:set_param2_data(data2)
			end
			if deco_table then
				minetest.generate_decorations(vm,vector.new(minp.x,deco_table.min,minp.z),vector.new(maxp.x,deco_table.max,maxp.z))
			elseif deco_used then
				minetest.generate_decorations(vm)
			end
			if ore_table then
				minetest.generate_ores(vm,vector.new(minp.x,ore_table.min,minp.z),vector.new(maxp.x,ore_table.max,maxp.z))
			elseif ore_used then
				minetest.generate_ores(vm)
			end
			vm:calc_lighting(p1, p2, shadow)
			vm:write_to_map()
			vm:update_liquids()
		end
	end

	if nodes > 0 then
		for _, rec in ipairs(registered_generators) do
			if rec.nf then
				rec.nf(p1, p2, blockseed)
			end
		end
	end

	mcl_vars.add_chunk(minp)
	if logging then
		minetest.log("action", "[mcl_mapgen_core] Generating chunk " .. minetest.pos_to_string(minp) .. " ... " .. minetest.pos_to_string(maxp).."..."..tostring(roundN(((os.clock() - t1)*1000),2)).."ms")
	end
end)

function minetest.register_on_generated(node_function)
	mcl_mapgen_core.register_generator("mod_"..minetest.get_current_modname().."_"..tostring(#registered_generators+1), nil, node_function)
end

function mcl_mapgen_core.register_generator(id, lvm_function, node_function, priority, needs_param2)
	if not id then return end

	local priority = priority or 5000

	if lvm_function then lvm = lvm + 1 end
	if node_function then nodes = nodes + 1 end
	if needs_param2 then param2 = param2 + 1 end

	local new_record = {
		id = id,
		i = priority,
		vf = lvm_function,
		nf = node_function,
		needs_param2 = needs_param2,
	}

	table.insert(registered_generators, new_record)
	table.sort(registered_generators, function(a, b)
		return (a.i < b.i) or ((a.i == b.i) and a.vf and (b.vf == nil))
	end)
end

function mcl_mapgen_core.unregister_generator(id)
	local index
	for i, gen in ipairs(registered_generators) do
		if gen.id == id then
			index = i
			break
		end
	end
	if not index then return end
	local rec = registered_generators[index]
	table.remove(registered_generators, index)
	if rec.vf then lvm = lvm - 1 end
	if rec.nf then nodes = nodes - 1 end
	if rec.needs_param2 then param2 = param2 - 1 end
	--if rec.needs_level0 then level0 = level0 - 1 end
end

function mcl_mapgen_core.get_block_seed(pos)
	return ((seed + minetest.hash_node_position(pos)) * 0x9e3779b1) % 0x100000000
end
