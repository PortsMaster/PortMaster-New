mcl_lush_caves = {}
local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)

local PARTICLE_DISTANCE = 25

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
	vector.new(0,-1,0)
}

local function vector_distance_xz(a, b)
	return vector.distance(
		{ x=a.x, y=0, z=a.z },
		{ x=b.x, y=0, z=b.z }
	)
end

dofile(modpath.."/nodes.lua")
dofile(modpath.."/crafting.lua")
dofile(modpath.."/dripleaf.lua")

core.register_abm({
	label = "Spore Blossom Particles",
	nodenames = {"mcl_lush_caves:spore_blossom"},
	interval = 25,
	chance = 10,
	action = function(pos)
		if core.get_node(vector.offset(pos, 0, -1, 0)).name ~= "air" then return end

		for pl in mcl_util.connected_players(pos, PARTICLE_DISTANCE) do
			core.add_particlespawner({
				texture = "mcl_lush_caves_spore_blossom_particle.png",
				amount = 32,
				time = 25,
				minvel = vector.zero(),
				maxvel = vector.zero(),
				minacc = vector.new(-0.2, -0.1, -0.2),
				maxacc = vector.new(0.2, -0.3, 0.2),
				minexptime = 1.5,
				maxexptime = 8.5,
				minsize = 0.1,
				maxsize= 0.4,
				glow = 4,
				collisiondetection = true,
				collision_removal = true,
				minpos = vector.offset(pos, -0.25, -0.5, -0.25),
				maxpos = vector.offset(pos, 0.25, -0.5, 0.25),
				playername = pl:get_player_name(),
			})
		end
	end
})

function mcl_lush_caves.makelake(pos, _, pr)
	local p1 = vector.offset(pos,-8,-4,-8)
	local p2 = vector.offset(pos,8,4,8)
	local nn = core.find_nodes_in_area_under_air(p1,p2,{"group:solid"})
	table.sort(nn,function(a, b)
		   return vector_distance_xz(pos, a) < vector_distance_xz(pos, b)
	end)
	if not nn[1] then return end
	for i=1,pr:next(1,#nn) do
		core.swap_node(nn[i],{name="mcl_core:water_source"})
	end
	local nnn = core.find_nodes_in_area(p1,p2,{"mcl_core:water_source"})
	for _, v in pairs(nnn) do
		for _, vv in pairs(adjacents) do
			local pp = vector.add(v,vv)
			local an = core.get_node(pp)
			if an.name ~= "mcl_core:water_source" then
				core.swap_node(pp,{name="mcl_core:clay"})
				if pr:next(1,20) == 1 then
					core.swap_node(vector.offset(pp,0,1,0),{name="mcl_lush_caves:moss_carpet"})
				end
			end
		end
	end
	return true
end

local function set_of_content_ids_by_group(group)
	local result = {}
	for name, def in pairs(core.registered_nodes) do
		if def.groups[group] then
			result[core.get_content_id(name)] = true
		end
	end
	return result
end

local CONVERTS_TO_ROOTED_DIRT = set_of_content_ids_by_group("material_stone")
CONVERTS_TO_ROOTED_DIRT[core.get_content_id("mcl_core:dirt")] = true
CONVERTS_TO_ROOTED_DIRT[core.get_content_id("mcl_core:coarse_dirt")] = true
local CONTENT_HANGING_ROOTS = core.get_content_id("mcl_lush_caves:hanging_roots")
local CONTENT_ROOTED_DIRT = core.get_content_id("mcl_lush_caves:rooted_dirt")

local function squared_average(a, b)
	local s = a + b
	return s*s/4
end

-- Azalea tree voxel manipulator buffer
local data = {}

function mcl_lush_caves.makeazalea(pos, _, pr)
	local distance = {x = 4, y = 40, z = 4}
	local airup = core.find_nodes_in_area_under_air(vector.offset(pos, 0, distance.y, 0), pos, {"mcl_core:dirt_with_grass"})
	if #airup == 0 then return end
	local surface_pos = airup[1]

	local function squared_distance(x, z)
		local dx = x - pos.x
		local dz = z - pos.z
		return dx*dx + dz*dz
	end

	local maximum_random_value = squared_average(distance.x, distance.z) + 1

	local min = vector.offset(pos, -distance.x, -1, -distance.z)
	local max = vector.offset(pos, distance.x, distance.y, distance.z)

	local vm, emin, emax = core.get_mapgen_object("voxelmanip")
	vm:get_data(data)

	local a = VoxelArea:new({MinEdge = emin, MaxEdge = emax})

	local vi, below
	for z = min.z, max.z do
		for y = min.y + 1, surface_pos.y - 1 do
			for x = min.x, max.x do
				vi = a:index(x, y, z)
				local probability_value = maximum_random_value - squared_distance(x, z)
				if CONVERTS_TO_ROOTED_DIRT[data[vi]] and pr:next(1, maximum_random_value) <= probability_value then
					data[vi] = CONTENT_ROOTED_DIRT
					below = a:index(x, y - 1, z)
					if data[below] == core.CONTENT_AIR then
						data[below] = CONTENT_HANGING_ROOTS
					end
				end
			end
		end
	end
	data[a:index(surface_pos.x, surface_pos.y, surface_pos.z)] = CONTENT_ROOTED_DIRT
	vm:set_data(data)
	core.place_schematic_on_vmanip(vm,
		vector.offset(surface_pos, -3, 1, -3),
		modpath.."/schematics/azalea1.mts",
		"random",nil,nil,
		"place_center_x place_center_z"
	)
	vm:calc_lighting()
	vm:write_to_map()
	core.log("info","[mcl_lush_caves] Azalea generated at "..core.pos_to_string(surface_pos))
	return true
end

core.register_abm({
	label = "Cave vines grow",
	nodenames = {"mcl_lush_caves:cave_vines_lit","mcl_lush_caves:cave_vines"},
	interval = 180,
	chance = 5,
	action = function(pos, node)
		local tip = mcl_util.traverse_tower(pos, -1)
		local max_vines_age = 25
		if vector.equals(pos, tip) then
			if node.param2 < max_vines_age then
				node.name = "mcl_lush_caves:cave_vines"
				if math.random() <= 0.11 then
					node.name = "mcl_lush_caves:cave_vines_lit"
				end
				mcl_crimson.grow_vines(pos, 1, node.name, -1, max_vines_age)
			end
		end
	end
})

local lushcaves = { "LushCaves", "LushCaves_underground", "LushCaves_ocean" }

mcl_structures.register_structure("clay_pool",{
	place_on = {"group:material_stone","mcl_core:gravel","mcl_lush_caves:moss","mcl_core:clay"},
	spawn_by = {"air"},
	num_spawn_by = 1,
	fill_ratio = 0.01,
	terrain_feature = true,
	flags = "all_floors",
	y_max = -10,
	biomes = lushcaves,
	place_func = mcl_lush_caves.makelake,
})

local azaleas = {}
local az_limit = 500
mcl_structures.register_structure("azalea_tree",{
	place_on = {"group:material_stone","mcl_core:gravel","mcl_lush_caves:moss","mcl_core:clay"},
	spawn_by = {"air"},
	num_spawn_by = 1,
	fill_ratio = 0.15,
	flags = "all_ceilings",
	terrain_feature = true,
	y_max =0,
	y_min = mcl_vars.mg_overworld_min + 15,
	biomes = lushcaves,
	place_func = function(pos,def,pr)
		for _,a in pairs(azaleas) do
			if vector.distance(pos,a) < az_limit then
				return true
			end
		end
		if mcl_lush_caves.makeazalea(pos,def,pr) then
			table.insert(azaleas,pos)
			return true
		end
	end
})

mcl_flowerpots.register_potted_flower("mcl_lush_caves:azalea", {
	name = "azalea",
	desc = S("Azalea Plant"),
	image = "mcl_lush_caves_azalea_side.png",
})

mcl_flowerpots.register_potted_flower("mcl_lush_caves:azalea_flowering", {
	name = "azalea_flowering",
	desc = S("Flowering Azalea Plant"),
	image = "mcl_lush_caves_azalea_flowering_side.png",
})

dofile (modpath .. "/lg_register.lua")
mcl_levelgen.register_levelgen_script (modpath .. "/lg_register.lua")
