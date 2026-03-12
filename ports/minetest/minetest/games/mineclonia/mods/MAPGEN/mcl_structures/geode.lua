local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
	vector.new(0,1,0),
	vector.new(0,-1,0)
}

local function set_node_no_bedrock(pos, node)
	if not pos then return end
	local n = core.get_node(pos)
	if n.name == "mcl_core:bedrock" then return end
	return core.swap_node(pos,node)
end

local function makegeode(pos, _, pr)
	local size = pr:next(5,7)
	local p1 = vector.offset(pos,-size,-size,-size)
	local p2 = vector.offset(pos,size,size,size)
	core.emerge_area(p1, p2, function(_, _, calls_remaining)
		if calls_remaining ~= 0 then return end
		local calcite = {}
		local nn = core.find_nodes_in_area(p1,p2,{"group:material_stone","group:dirt","mcl_core:gravel"})

		if not nn or #nn < 2 then
			core.log("action", "Not enough valid space to generate geode at pos: " .. core.pos_to_string(pos))
			return
		end

		table.sort(nn,function(a, b)
			   return vector.distance(pos, a) < vector.distance(pos, b)
		end)

		for i=1,pr:next(1, math.max(2, #nn - math.ceil(#nn/5) )) do
			set_node_no_bedrock(nn[i],{name="mcl_amethyst:amethyst_block"})
		end

		for _, v in pairs(core.find_nodes_in_area(p1,p2,{"mcl_amethyst:amethyst_block"})) do
			local all_amethyst = true
			for _, vv in pairs(adjacents) do
				local pp = vector.add(v,vv)
				local an = core.get_node(pp)
				if an.name ~= "mcl_amethyst:amethyst_block" then
					if core.get_item_group(an.name,"material_stone") > 0 then
						set_node_no_bedrock(pp,{name="mcl_amethyst:calcite"})
						table.insert(calcite,pp)
						if pr:next(1,5) == 1 then
							set_node_no_bedrock(v,{name="mcl_amethyst:budding_amethyst_block"})
						end
						all_amethyst = false
					elseif an.name ~= "mcl_amethyst:amethyst_block" and an.name ~= "air" and an.name ~= "mcl_amethyst:budding_amethyst_block" then
						all_amethyst = false
					end
				end
			end
			if all_amethyst then set_node_no_bedrock(v,{name="air"}) end
		end

		for _,v in pairs(calcite) do
			for _,vv in pairs(core.find_nodes_in_area(vector.offset(v,-1,-1,-1),vector.offset(v,1,1,1),{"group:material_stone"})) do
				set_node_no_bedrock(vv,{name="mcl_blackstone:basalt_smooth"})
			end
		end

		for _, v in pairs(core.find_nodes_in_area_under_air(p1,p2,{"mcl_amethyst:amethyst_block","mcl_amethyst:budding_amethyst_block"})) do
			local r = pr:next(1,50)
			if r < 10 then
				set_node_no_bedrock(vector.offset(v,0,1,0),{name="mcl_amethyst:amethyst_cluster",param2=1})
			end
		end
		return true
	end)
	return true
end

mcl_structures.register_structure("geode",{
	place_on = {"group:material_stone"},
	noise_params = {
		offset = 0,
		scale = 0.00022,
		spread = {x = 250, y = 250, z = 250},
		seed = 7894353,
		octaves = 3,
		persist = 0.001,
		flags = "absvalue",
	},
	flags = "force_placement",
	terrain_feature = true,
	y_max = -24,
	y_min = mcl_vars.mg_overworld_min,
	y_offset = function(pr) return pr:next(-4,-2) end,
	place_func = makegeode,
})
