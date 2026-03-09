local modname = core.get_current_modname()
local S = core.get_translator(modname)

local dripleaf_allowed = {
	"mcl_core:dirt",
	"mcl_core:coarse_dirt",
	"mcl_core:dirt_with_grass",
	"mcl_core:podzol",
	"mcl_core:mycelium",
	"mcl_lush_caves:rooted_dirt",
	"mcl_lush_caves:moss",
	"mcl_farming:soil",
	"mcl_farming:soil_wet",
	"mcl_core:clay",
	"mcl_mud:mud",
}

function mcl_lush_caves.grow_big_dripleaf(pos)
	local pos_above = vector.offset(pos,0,1,0)
	local node = core.get_node(pos)
	local dir = node.param2
	if core.get_node(pos_above).name ~= "air" then return end
	core.remove_node(pos)
	core.set_node(pos_above, {name="mcl_lush_caves:dripleaf_big", param2=dir})
	core.set_node(pos, {name="mcl_lush_caves:dripleaf_big_stem", param2=dir})
	core.sound_play({name="default_grass_footstep", gain=0.4}, {
		pos = pos,
		gain= 0.4,
		max_hear_distance = 16,
	}, true)
end

local function dig_adjacent(pos)
	core.after(0.05, function ()
		local above = vector.offset(pos,0,1,0)
		if core.get_item_group(core.get_node(above).name, "dripleaf") == 1 then
			core.dig_node(above)
		end
		local below = vector.offset(pos,0,-1,0)
		if core.get_item_group(core.get_node(below).name, "dripleaf") == 1 then
			core.dig_node(below)
		end
	end)
end

local v = vector.zero ()

local function dripleaf_stem_flood (pos, oldnode, new_node)
	v.x = pos.x
	v.y = pos.y - 1
	v.z = pos.z
	if core.get_item_group (new_node.name, "lava") > 0 then
		return mcl_core.basic_flood (pos, oldnode, new_node)
	else
		local node = core.get_node (v)
		if node.name == oldnode.name then
			-- Permit flooding if this is not the
			-- bottommost node in a column.
			return mcl_core.basic_flood (pos, oldnode, new_node)
		else
			-- Otherwise forbid flooding as a substitute
			-- for true waterlogging.
			return true
		end
	end
end

local function dripleaf_leaf_flood (pos, oldnode, new_node)
	v.x = pos.x
	v.y = pos.y - 1
	v.z = pos.z
	if core.get_item_group (new_node.name, "lava") > 0 then
		return mcl_core.basic_flood (pos, oldnode, new_node)
	else
		local node = core.get_node (v)
		if core.get_item_group (node, "dripleaf") == 1 then
			-- Permit flooding if this is not the
			-- bottommost node in a column.
			return mcl_core.basic_flood (pos, oldnode, new_node)
		else
			-- Otherwise forbid flooding as a substitute
			-- for true waterlogging.
			return true
		end
	end
end

--
-- Small Dripleaf
--

core.register_node("mcl_lush_caves:dripleaf_small_stem", {
	groups = {
		shearsy=1, handy=1, plant=1,
		dig_by_piston=1, dripleaf=1,
		not_in_creative_inventory=1
	},
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "4dir",
	mesh = "dripleaf_small_stem.obj",
	use_texture_alpha = "clip",
	tiles = {"mcl_lush_caves_dripleaf_small.png"},
	walkable = false,
	drop = "",
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	after_dig_node = dig_adjacent,
	floodable = true,
	on_flood = dripleaf_stem_flood,
})

core.register_node("mcl_lush_caves:dripleaf_small", {
	description = S("Small Dripleaf"),
	_doc_items_create_entry = S("Small Dripleaf"),
	_doc_items_entry_name = S("Small Dripleaf"),
	_doc_items_longdesc = S("Small Dripleaf"),
	groups = {
		shearsy=1, handy=1, plant=1, compostability = 30,
		dig_by_piston=1, dripleaf=1,
	},
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "4dir",
	mesh = "dripleaf_small.obj",
	use_texture_alpha = "clip",
	tiles = {"mcl_lush_caves_dripleaf_small.png"},
	selection_box = {
		type = "fixed",
		fixed = {-0.5,-1.5,-0.5, 0.5,0.5,0.5}
	},
	walkable = false,
	drop = "",
	_mcl_shears_drop = true,
	node_placement_prediction = "",
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	on_place = mcl_util.generate_on_place_plant_function(function (pos)
		local node = core.get_node(vector.offset(pos,0,-1,0))
		if table.indexof(dripleaf_allowed, node.name) == -1 then
			return false
		end
		return true
	end),
	after_place_node = function (pos)
		local above = vector.offset(pos,0,1,0)
		local dir = core.get_node(pos).param2
		core.swap_node(above, {name="mcl_lush_caves:dripleaf_small", param2=dir})
		core.swap_node(pos, {name="mcl_lush_caves:dripleaf_small_stem", param2=dir})
	end,
	after_dig_node = dig_adjacent,
	_on_bone_meal = function (_, _, _, pos)
		local base = vector.offset(pos,0,-1,0)
		local node = core.get_node(pos)
		local dir = node.param2
		core.swap_node(base, {name="mcl_lush_caves:dripleaf_big_stem", param2=dir})
		core.swap_node(pos, {name="mcl_lush_caves:dripleaf_big_stem", param2=dir})
		local i = 0
		while i < math.random(0,3) do
			local p = vector.offset(pos,0,i,0)
			if core.get_node(p).name ~= "air"
				and core.get_item_group(node.name, "dripleaf") ~= 1 then break end
			core.swap_node(p, {name="mcl_lush_caves:dripleaf_big_stem", param2=dir})
			i = i + 1
		end
		core.swap_node(vector.new(pos.x, pos.y+i, pos.z), {name="mcl_lush_caves:dripleaf_big", param2=dir})
	end,
	floodable = true,
	on_flood = dripleaf_leaf_flood,
})

--
-- Big dripleaf
--

core.register_node("mcl_lush_caves:dripleaf_big_stem", {
	groups = {
		shearsy=1, handy=1, plant=1,
		dig_by_piston=1, dripleaf=1,
		not_in_creative_inventory=1,
	},
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "4dir",
	mesh = "dripleaf_big_stem.obj",
	use_texture_alpha = "clip",
	tiles = {"mcl_lush_caves_dripleaf_big.png"},
	drop = "mcl_lush_caves:dripleaf_big",
	selection_box = {
		type = "fixed",
		fixed = {-0.175, -0.5, 0.075, 0.175, 0.5, 0.425}
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	after_dig_node = dig_adjacent,
	_on_bone_meal = function (_, _, _, pos)
		local top = mcl_util.traverse_tower_group(pos, 1, "dripleaf")
		mcl_lush_caves.grow_big_dripleaf(top)
	end,
	walkable = false,
	floodable = true,
	on_flood = dripleaf_stem_flood,
})

local dripleaf_big = {
	description = S("Big Dripleaf"),
	_doc_items_create_entry = S("Big Dripleaf"),
	_doc_items_entry_name = S("Big Dripleaf"),
	_doc_items_longdesc = S("Big Dripleaf"),
	groups = {
		shearsy=1, handy=1, plant=1, compostability = 65,
		dig_by_piston=1, pathfinder_partial = 2, dripleaf=1
	},
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "4dir",
	mesh = "dripleaf_big.obj",
	use_texture_alpha = "clip",
	tiles = {"mcl_lush_caves_dripleaf_big.png"},
	collision_box = {
		type = "fixed",
		fixed = {-0.5, 0.45, -0.5, 0.5, 0.5, 0.5}
	},
	node_placement_prediction = "",
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	on_place = mcl_util.generate_on_place_plant_function(function (pos)
		local below = core.get_node(vector.offset(pos,0,-1,0))
		local allowed = table.copy(dripleaf_allowed)
		allowed[#allowed+1] = "mcl_lush_caves:dripleaf_big"
		if table.indexof(allowed, below.name) == -1 then
			return false
		end
		local param2
		if below.name == "mcl_lush_caves:dripleaf_big" then
			param2 = below.param2
		end
		return true, param2
	end),
	after_place_node = function (pos)
		local below = core.get_node(vector.offset(pos,0,-1,0))
		if below.name == "mcl_lush_caves:dripleaf_big" then
			core.swap_node(vector.offset(pos,0,-1,0),
				{name="mcl_lush_caves:dripleaf_big_stem", param2=below.param2})
		end
	end,
	after_dig_node = dig_adjacent,
	_on_bone_meal = function (_, _, _, pos)
		mcl_lush_caves.grow_big_dripleaf(pos)
	end,
	floodable = true,
	on_flood = dripleaf_leaf_flood,
}

local dripleaf_big_tipped_half = table.merge(dripleaf_big, {
	groups = {not_in_creative_inventory=1},
	mesh = "dripleaf_big_tipped_half.obj",
	on_timer = function(pos)
		local n = core.get_node(pos)
		core.swap_node(pos, {name="mcl_lush_caves:dripleaf_big_tipped_full", param2=n.param2})
		local t = core.get_node_timer(pos)
		t:start(3)
	end,
})

local dripleaf_big_tipped_full = table.merge(dripleaf_big, {
	groups = {not_in_creative_inventory=1},
	walkable= false,
	mesh = "dripleaf_big_tipped_full.obj",
	on_timer = function(pos)
		local n = core.get_node(pos)
		core.swap_node(pos, {name="mcl_lush_caves:dripleaf_big", param2=n.param2})
	end,
})

core.register_node("mcl_lush_caves:dripleaf_big", dripleaf_big)
core.register_node("mcl_lush_caves:dripleaf_big_tipped_half", dripleaf_big_tipped_half)
core.register_node("mcl_lush_caves:dripleaf_big_tipped_full", dripleaf_big_tipped_full)

local player_dripleaf = {}
core.register_globalstep(function(dtime)
	for _,p in pairs(core.get_connected_players()) do
		local pos = vector.offset(p:get_pos(),0,-1,0)
		local node = core.get_node(pos)
		if node and node.name == "mcl_lush_caves:dripleaf_big"
			and mcl_redstone.get_power(pos) == 0 then
			if not player_dripleaf[p] then player_dripleaf[p] = 0 end
			player_dripleaf[p] = player_dripleaf[p] + dtime
			if player_dripleaf[p] > 0.5 then
				core.swap_node(pos,{name = "mcl_lush_caves:dripleaf_big_tipped_half", param2 = node.param2})
				player_dripleaf[p] = nil
				local t = core.get_node_timer(pos)
				t:start(0.5)
			end
		end
	end
end)
