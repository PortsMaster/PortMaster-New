-- Table that holds/caches tree (schematic) dimensions. Indexed by file name.
local tree_size_cache = {}

-- Returns tree (schematic) size as a vector. Caches result.
local function get_tree_size(schem_file_name)
	local size = tree_size_cache[schem_file_name]

	if size == nil then
		-- Serialize and return schematic as Lua table. Expensive!
		local schem_lua = loadstring(
			core.serialize_schematic(schem_file_name, "lua",
			{ lua_use_comments = false, lua_num_indent_spaces = 0 })
				.. " return schematic"
		)()

		if not schem_lua then
			return nil
		end

		size = vector.copy(schem_lua.size)
		tree_size_cache[schem_file_name] = size
	end

	return size
end

function mcl_trees.strip_tree(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then return end

	local node = core.get_node(pointed_thing.under)
	local noddef = core.registered_nodes[node.name]

	if noddef._mcl_stripped_variant and core.registered_nodes[noddef._mcl_stripped_variant] then
		core.swap_node(pointed_thing.under, {name=noddef._mcl_stripped_variant, param2=node.param2})
	end
	return itemstack
end

function mcl_trees.rotate_climbable(pos, node, _, mode)
	if mode == screwdriver.ROTATE_FACE then
		local r = screwdriver.rotate.wallmounted(pos, node, mode)
		node.param2 = r
		core.swap_node(pos, node)
		return true
	end
	return false
end

-- Check if a node stops a tree from growing.  Torches, plants, wood, tree,
-- leaves and dirt does not affect tree growth.
local function node_stops_growth(node)
	if node.name == "air" then
		return false
	end

	local def = core.registered_nodes[node.name]
	if not def then
		return true
	end

	local groups = def.groups or {}
	if (groups.plant or 0) ~= 0 or
			(groups.torch or 0) ~= 0 or
			(groups.dirt or 0) ~= 0 or
			(groups.dig_by_water or 0) ~= 0 or
			(groups.tree or 0) ~= 0 or
			(groups.bark or 0) ~= 0 or
			(groups.leaves or 0) ~= 0 or
			(groups.wood or 0) ~= 0 or
			def.buildable_to then
		return false
	end

	return true
end

-- Check the center column starting one node above the sapling
function mcl_trees.check_growth_simple(pos, height)
	for y = 1, height - 1 do
		local np = vector.offset(pos, 0, y, 0)
		if node_stops_growth(core.get_node(np)) then
			return false
		end
	end
	return true
end

-- check 6x6 area starting at sapling level
-- Assumes pos is "north east" sapling
function mcl_trees.check_growth_giant(pos, height)
	for x = -3, 2 do
		for z = -3, 2 do
			for y = 0, height - 1 do
				local np = vector.offset(pos, x, y, z)
				if node_stops_growth(core.get_node(np)) then
					return false
				end
			end
		end
	end
	return true
end

local function check_schem_growth(pos, file, giant)
	if file then
		local size = get_tree_size(file)
		if size then
			local h = size.y
			if giant then
				return mcl_trees.check_growth_giant(pos, h)
			else
				return mcl_trees.check_growth_simple(pos, h)
			end
		end
	end

	return false
end

local diagonals = {
	vector.new(1,0,1),
	vector.new(-1,0,1),
	vector.new(1,0,-1),
	vector.new(-1,0,-1),
}

local function check_2by2_saps(pos, node)
	local n = node.name
	-- quick check if at all there are sufficient saplings nearby
	if #core.find_nodes_in_area_under_air({x=pos.x-1, y=pos.y, z=pos.z-1}, {x=pos.x+1, y=pos.y, z=pos.z+1}, n) == 0 then return end
	-- we need to check 4 possible 2x2 squares on the x/z plane each uniquely defined by one of the
	-- diagonals of the position we're checking:
	for _,v in pairs(diagonals) do
		local d = vector.add(pos,v) --one of the 4 diagonal positions from this node
		local xp = vector.new(d.x,d.y,d.z-v.z) --go "back" towards our position on the z axis
		local zp = vector.new(d.x-v.x,d.y,d.z) --go "back" towards our position on the x axis

		local dn = core.get_node(d).name
		local xn = core.get_node(xp).name
		local zn = core.get_node(zp).name
		if n == dn and n == xn and n == zn then
			--if all the 3 acquired positions have the same nodename as the original node it must be a square
			local ne = pos
			for _,p in pairs({pos,d,xp,zp}) do
				if p.x > ne.x or p.z > ne.z then ne = p end
			end --find northeasternmost node
			return {d,xp,zp}, ne
		end
	end
end

-- Wrapper around core.place_schematic in order to update observers
local function place_tree(place_at, schem)
	-- Work out bounding box coordinates. +1 in all directions.
	local size = get_tree_size(schem.file)
	local x    = place_at.x - math.floor((size.x - 1) / 2)
	local z    = place_at.z - math.floor((size.z - 1) / 2)
	local p1   = vector.new(x - 1, place_at.y - 1, z - 1)   -- Note: ground just below tree might not be needed
	local p2   = vector.new(x    , place_at.y    , z    ) + size

	-- Locate observers
	local nodes = core.find_nodes_in_area(p1, p2, "group:observer")

	-- Store observed (air) positions
	local observed_positions = {}
	for _, pos in pairs(nodes) do
		local node          = core.get_node(pos)
		local observed_pos  = mcl_observers.get_front_pos(pos, node)
		local observed_node = core.get_node(observed_pos)
		if observed_node.name == "air" then
			observed_positions[core.hash_node_position(observed_pos)] = observed_pos
		end
	end

	-- Place tree
	core.place_schematic(
		place_at,
		schem.file,
		"random",
		nil,
		false,
		{ place_center_x = true, place_center_y = false, place_center_z = true }
	)

	for _, pos in pairs(core.find_nodes_in_area(vector.new(p1.x, p1.y,p1.z), vector.new(p2.x, p2.y + size.y, p2.z), {"group:leaves"})) do
		local biome_p2 = mcl_util.get_pos_p2(pos, true)
		local node = core.get_node(pos)
		node.param2 = math.floor(node.param2 / 32) * 32 + biome_p2
		core.set_node(pos, node)
	end


	-- Notify observers
	for _, pos in pairs(observed_positions) do
		local node = core.get_node(pos)
		if node.name ~= "air" then
			mcl_redstone._notify_observer_neighbours(pos)
		end
	end
end

function mcl_trees.grow_tree(pos, node)
	local name = node.name:gsub("mcl_trees:sapling_", "")
	if node.name:find("propagule") then
		name = "mangrove"
	end
	if not mcl_trees.woods[name] or ( not mcl_trees.woods[name].tree_schems and not mcl_trees.woods[name].tree_schems_2x2 ) then
		return
	end

	local schem, can_grow, tbt, ne
	local place_at = pos
	local is_2by2 = false
	if mcl_trees.woods[name].tree_schems_2x2  then
		tbt, ne = check_2by2_saps(pos, node)
		if tbt then
			table.shuffle(mcl_trees.woods[name].tree_schems_2x2)
			schem = mcl_trees.woods[name].tree_schems_2x2[1]
			can_grow = check_schem_growth(ne, schem.file, true)
			place_at = ne
			is_2by2 = true
		end
	end

	if not tbt and mcl_trees.woods[name].tree_schems then
		table.shuffle(mcl_trees.woods[name].tree_schems)
		schem = mcl_trees.woods[name].tree_schems[1]
		can_grow = check_schem_growth(place_at, schem.file, false)
	end

	if not schem then return end

	if can_grow then

		local offset = schem.offset
		core.remove_node(pos)
		if tbt then
			for _, v in pairs(tbt) do
				core.remove_node(v)
			end

			place_at = ne

			-- Assume trunk is in the center of the schema.
			-- Overide this in tree_schems if it isn't.
			if not offset then
				offset = vector.new(1, 0, 1)
			end
		end

		if offset then
			place_at = vector.subtract(place_at, offset)
		end

		place_tree(place_at, schem)

		local after_grow = core.registered_nodes[node.name]._after_grow
		if after_grow then
			after_grow(place_at, schem, is_2by2)
		end
	end
end

local nest_dirs = {vector.new(1, 0, 0), vector.new(-1, 0, 0), vector.new(0, 0, -1)}

function mcl_trees.add_bee_nest(pos)
	local col = vector.add(pos, nest_dirs[math.random(3)])
	for i = 2, 8 do
		local nestpos = vector.offset(col, 0, i -1 , 0)
		local abovename = core.get_node(vector.offset(col, 0, i, 0)).name
		if core.get_node(nestpos).name == "air" and
				(core.get_item_group(abovename, "leaves") > 0 or core.get_item_group(abovename, "tree") > 0) then
			core.set_node(nestpos, {name = "mcl_beehives:bee_nest"})
			-- TODO: spawn bee mobs in nest
			return
		end
	end
end

function mcl_trees.sapling_add_bee_nest(pos)
	if #core.find_nodes_in_area(vector.offset(pos,-2, 0 ,-2), vector.offset(pos, 2, 0, 2), {"group:flower"}) == 0 then return end
	if math.random(20) == 1 then
		mcl_trees.add_bee_nest(pos)
	end
end
