local interval = 10
local chance = 5

local function grow(pos, node)
	local def = minetest.registered_nodes[node.name]
	local next_gen = def._mcl_amethyst_next_grade
	if not next_gen then return end

	local dir = minetest.wallmounted_to_dir(node.param2)
	local ba_pos = vector.add(pos, dir)
	local ba_node = minetest.get_node(ba_pos)
	if ba_node.name ~= "mcl_amethyst:budding_amethyst_block" then return end

	local swap_result = table.copy(node)
	swap_result.name = next_gen
	minetest.swap_node(pos, swap_result)
end

minetest.register_abm({
	label = "Amethyst Bud Growth",
	nodenames = {"group:amethyst_buds"},
	neighbors = {"mcl_amethyst:budding_amethyst_block"},
	interval = interval,
	chance = chance,
	action = grow,
})

local all_directions = {
	vector.new(1, 0, 0),
	vector.new(0, 1, 0),
	vector.new(0, 0, 1),
	vector.new(-1, 0, 0),
	vector.new(0, -1, 0),
	vector.new(0, 0, -1),
}

minetest.register_abm({
	label = "Spawn Amethyst Bud",
	nodenames = {"mcl_amethyst:budding_amethyst_block"},
	neighbors = {"air", "group:water"},
	interval = 35,
	chance = 2,
	action = function(pos)
		local check_pos = vector.add(all_directions[math.random(1, #all_directions)], pos)
		local check_node = minetest.get_node(check_pos)
		local check_node_name = check_node.name
		if check_node_name ~= "air" and minetest.get_item_group(check_node_name, "water") == 0 then return end
		local param2 = minetest.dir_to_wallmounted(vector.subtract(pos, check_pos))
		local new_node = {name = "mcl_amethyst:small_amethyst_bud", param2 = param2}
		minetest.swap_node(check_pos, new_node)
	end,
})
