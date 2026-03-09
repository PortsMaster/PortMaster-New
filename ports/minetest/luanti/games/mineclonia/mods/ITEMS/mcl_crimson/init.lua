local modname = core.get_current_modname()
local S = core.get_translator(modname)
local modpath = core.get_modpath(modname)

mcl_crimson = {}

-- possible plants for each nylium type
-- give plants a probablity of being chosen totalling 100%
local nether_plants = {
	["mcl_crimson:crimson_nylium"] = {
		{ name = "mcl_crimson:warped_fungus", chance = 10 },
		{ name = "mcl_crimson:crimson_fungus", chance = 20 },
		{ name = "mcl_crimson:crimson_roots", chance = 70 },
	},
	["mcl_crimson:warped_nylium"] = {
		{ name = "mcl_crimson:crimson_fungus", chance = 10 },
		{ name = "mcl_crimson:warped_fungus", chance = 20 },
		{ name = "mcl_crimson:warped_roots", chance = 30 },
		{ name = "mcl_crimson:nether_sprouts", chance = 30 },
		{ name = "mcl_crimson:twisting_vines", chance = 10 },
	},
}

local place_fungus = mcl_util.generate_on_place_plant_function(function(pos)
	return core.get_item_group(core.get_node(vector.offset(pos,0,-1,0)).name, "soil_fungus") > 0
end)

local function spread_nether_plants(pos,node)
	local apply_to = node.name
	local targets = core.find_nodes_in_area_under_air( vector.offset(pos,-2,-2,-2),vector.offset(pos,2,2,2),{apply_to} )
	if #targets == 0 then
		-- give back the unapplied bonemeal
		core.add_item(pos, "mcl_bone_meal:bone_meal")
		core.check_for_falling(pos)
		return
	end
	table.shuffle(targets)
	-- find clicked node and move to the beginning of the targets
	for i, v in ipairs(targets) do
		-- only move clicked node if it is a viable target
		if v == pos then
			table.remove(targets, i)
			table.insert(targets, 1, v)
		end
	end
	-- create distribution table based on likelyhood to occur in biome
	local likelyhood = {}
	local tally = 0
	for i=1, #nether_plants[apply_to] do
		likelyhood[i] = nether_plants[apply_to][i].chance + tally
		tally = likelyhood[i]
	end
	for i=1, math.random(1, math.min(#targets,8)) do
		local p = vector.offset(targets[i],0,1,0)
		if core.get_node(p).name == "air" then
			local plant_roll = math.random(100)
			for ch=1, #likelyhood do
				if plant_roll <= likelyhood[ch] then
					core.set_node(p,{name = nether_plants[apply_to][ch].name})
					break
				end
			end
		end
	end
end

local function on_bone_meal(_, _, pt, _, node)
	if pt.type ~= "node" then return end
	if node.name == "mcl_crimson:warped_nylium" or node.name == "mcl_crimson:crimson_nylium" then
		spread_nether_plants(pt.under,node)
	end
end

local function check_for_bedrock(pos)
	local br = core.find_nodes_in_area(pos, vector.offset(pos, 0, 12, 0), {"mcl_core:bedrock"})
	return br and #br > 0
end

local function generate_fungus_tree(pos, typ)
	return core.place_schematic(pos,modpath.."/schematics/"..typ.."_fungus_"..tostring(math.random(1,3))..".mts","random",nil,false,"place_center_x,place_center_z")
end

local max_vines_age = 25
local grow_vines_direction = {[1] = 1, [2] = -1}

function mcl_crimson.grow_vines(pos, amount, vine, dir, max_age)
	dir = dir or grow_vines_direction[core.get_item_group(vine, "vinelike_node")] or 1
	local tip = mcl_util.traverse_tower(pos, dir)
	local node_tip = core.get_node(tip)
	local age = node_tip.param2
	amount = math.min(amount, max_age and max_age - age or amount)
	for i=1, amount do
		local p = vector.offset(tip,0,dir*i,0)
		if core.get_node(p).name == "air" then
			core.set_node(p,{name=vine, param2=age +i})
		else
			return i-1
		end
	end
	return amount
end

local nether_wood_groups = { handy = 1, axey = 1, material_wood = 1, building_block = 1}

mcl_trees.register_wood("crimson",{
	readable_name="Crimson",
	sign = {_mcl_burntime = 0 },
	sign_color="#810000",
	boat=false,
	chest_boat=false,
	sapling=false,
	leaves=false,
	tree = {
		tiles = {"crimson_hyphae.png", "crimson_hyphae.png","crimson_hyphae_side.png" },
		groups = table.merge(nether_wood_groups,{tree = 1}),
		_mcl_burntime = 0,
		_mcl_cooking_output = ""
	},
	bark = {
		tiles = {"crimson_hyphae_side.png"},
		groups = table.merge(nether_wood_groups,{tree = 1, bark = 1}),
		_mcl_burntime = 0,
		_mcl_cooking_output = ""
	},
	wood = {
		tiles = {"crimson_hyphae_wood.png"},
		groups = table.merge(nether_wood_groups,{wood = 1}),
		_mcl_burntime = 0
	},
	stripped = {
		tiles = {"stripped_crimson_stem_top.png", "stripped_crimson_stem_top.png","stripped_crimson_stem_side.png"},
		groups = table.merge(nether_wood_groups,{tree = 1}),
		_mcl_burntime = 0,
		_mcl_cooking_output = ""
	},
	stripped_bark = {
		tiles = {"stripped_crimson_stem_side.png"},
		groups = table.merge(nether_wood_groups,{tree = 1, bark = 1}),
		_mcl_burntime = 0,
		_mcl_cooking_output = ""
	},
	fence = {
		tiles = { "mcl_crimson_crimson_fence.png" },
		_mcl_burntime = 0
	},
	fence_gate = {
		tiles = { "mcl_crimson_crimson_fence.png" },
		_mcl_burntime = 0
	},
	door = {
		inventory_image = "mcl_crimson_crimson_door.png",
		tiles_bottom = {"mcl_crimson_crimson_door_bottom.png","mcl_doors_door_crimson_side_upper.png"},
		tiles_top = {"mcl_crimson_crimson_door_top.png","mcl_doors_door_crimson_side_upper.png"},
		_mcl_burntime = 0
	},
	trapdoor = {
		tile_front = "mcl_crimson_crimson_trapdoor.png",
		tile_side = "mcl_crimson_crimson_trapdoor_side.png",
		wield_image = "mcl_crimson_crimson_trapdoor.png",
		_mcl_burntime = 0
	},
	button = { _mcl_burntime = 0 },
	pressure_plate = { _mcl_burntime = 0 },
	stairs = { overrides = { _mcl_burntime = 0 }},
	slab = { overrides = { _mcl_burntime = 0 }},
	hanging_sign = {_mcl_burntime = 0, },
})

mcl_trees.register_wood("warped",{
	readable_name="Warped",
	sign = {_mcl_burntime = 0 },
	sign_color="#0E4C4C",
	boat=false,
	chest_boat=false,
	sapling=false,
	leaves=false,
	tree = {
		tiles = {"warped_hyphae.png", "warped_hyphae.png","warped_hyphae_side.png" },
		groups = table.merge(nether_wood_groups,{tree = 1}),
		_mcl_burntime = 0,
		_mcl_cooking_output = ""
	},
	bark = {
		tiles = {"warped_hyphae_side.png"},
		groups = table.merge(nether_wood_groups,{tree = 1, bark = 1}),
		_mcl_burntime = 0,
		_mcl_cooking_output = ""
	},
	wood = {
		tiles = {"warped_hyphae_wood.png"},
		groups = table.merge(nether_wood_groups,{wood = 1}),
		_mcl_burntime = 0
	},
	stripped = {
		tiles = {"stripped_warped_stem_top.png", "stripped_warped_stem_top.png","stripped_warped_stem_side.png"},
		groups = table.merge(nether_wood_groups,{tree = 1}),
		_mcl_burntime = 0,
		_mcl_cooking_output = ""
	},
	stripped_bark = {
		tiles = {"stripped_warped_stem_side.png"},
		groups = table.merge(nether_wood_groups,{tree = 1, bark = 1}),
		_mcl_burntime = 0,
		_mcl_cooking_output = ""
	},
	fence = {
		tiles = { "mcl_crimson_warped_fence.png" },
		_mcl_burntime = 0
	},
	fence_gate = {
		tiles = { "mcl_crimson_warped_fence.png" },
		_mcl_burntime = 0
	},
	door = {
		inventory_image = "mcl_crimson_warped_door.png",
		tiles_bottom = {"mcl_crimson_warped_door_bottom.png","mcl_doors_door_warped_side_upper.png"},
		tiles_top = {"mcl_crimson_warped_door_top.png","mcl_doors_door_warped_side_upper.png"},
		_mcl_burntime = 0
	},
	trapdoor = {
		tile_front = "mcl_crimson_warped_trapdoor.png",
		tile_side = "mcl_crimson_warped_trapdoor_side.png",
		wield_image = "mcl_crimson_warped_trapdoor.png",
		_mcl_burntime = 0
	},
	button = { _mcl_burntime = 0 },
	pressure_plate = { _mcl_burntime = 0 },
	stairs = { overrides = { _mcl_burntime = 0 }},
	slab = { overrides = { _mcl_burntime = 0 }},
	hanging_sign = {_mcl_burntime = 0, },
})

core.register_node("mcl_crimson:warped_fungus", {
	description = S("Warped Fungus"),
	_tt_help = S("Warped fungus is a mushroom found in the nether's warped forest."),
	_doc_items_longdesc = S("Warped fungus is a mushroom found in the nether's warped forest."),
	drawtype = "plantlike",
	tiles = { "farming_warped_fungus.png" },
	inventory_image = "farming_warped_fungus.png",
	wield_image = "farming_warped_fungus.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,mushroom=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,enderman_takable=1,deco_block=1,compostability=65},
	light_source = 1,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, 7/16, 3/16 },
	},
	node_placement_prediction = "",
	on_place = place_fungus,
	_on_bone_meal = function(_, _, _, pos)
		if core.get_node_or_nil(vector.offset(pos,0,-1,0)).name == "mcl_crimson:warped_nylium" then
			if math.random() > 0.40 then return end --fungus has a 40% chance to grow when bone mealing
			if check_for_bedrock(pos) then return false end
			core.remove_node(pos)
			return generate_fungus_tree(pos, "warped")
		end
	end,
	_mcl_hardness = 0,
})

mcl_flowerpots.register_potted_flower("mcl_crimson:warped_fungus", {
	name = "warped_fungus",
	desc = S("Warped Fungus"),
	image = "farming_warped_fungus.png",
})

local call_on_place = function(itemstack, placer, pointed_thing)
	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	local dir = vector.direction(pointed_thing.under, pointed_thing.above).y
	local node = core.get_node(pointed_thing.under)
	local idef = itemstack:get_definition()

	local grow_dir = grow_vines_direction[core.get_item_group(idef.name, "vinelike_node")]
	local pos = vector.offset(pointed_thing.under, 0, grow_dir, 0)
	if mcl_util.check_position_protection(pos, placer) then return itemstack end

	if node.name == idef.name then
		if mcl_crimson.grow_vines(pointed_thing.under, 1, node.name) == 0 then return end
	elseif grow_dir == dir and core.get_item_group(node.name, "solid") ~= 0 then
		core.item_place_node(itemstack, placer, pointed_thing, 0)
	else
		return itemstack
	end

	if idef.sounds and idef.sounds.place then
		core.sound_play(idef.sounds.place, {pos=pointed_thing.above, gain=1}, true)
	end
	if not core.is_creative_enabled(placer:get_player_name()) then
		itemstack:take_item(1)
	end
	return itemstack
end

local function register_vines(name, def, extra_groups)
	local groups = table.merge({
		dig_immediate=3, shearsy=1, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1, deco_block=1, compostability=50
	}, extra_groups or {})
	core.register_node(name, table.merge({
		drawtype = "plantlike",
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		climbable = true,
		groups = groups,
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		node_placement_prediction = "",
		on_place = call_on_place,
		drop = {
			max_items = 1,
			items = {
				{items = {name}, rarity = 3},
			},
		},
		_mcl_shears_drop = true,
		_mcl_silk_touch_drop = true,
		_mcl_fortune_drop = {
			items = {
				{items = {name}, rarity = 3},
				{items = {name}, rarity = 1.8181818181818181},
			},
			name,
			name,
		},
		_mcl_hardness = 0,
		_on_bone_meal = function(_, _, _, pos)
			mcl_crimson.grow_vines(pos, math.random(1, 3), name, nil, max_vines_age)
		end,

		_on_shears_place = function(itemstack, placer, pointed_thing)
			local pos = pointed_thing.under
			local dir = grow_vines_direction[core.get_item_group(
				name, "vinelike_node")] or 1
			local tip = mcl_util.traverse_tower(pos, dir)

			if vector.equals(pos, tip) then
				core.sound_play("mcl_tools_shears_cut", {pos = pos}, true)
				local node = core.get_node(pos)
				node.param2 = 25
				core.swap_node(pos,node)
				return itemstack
			end
			return itemstack, true
		end
	}, def or {}))
end

register_vines("mcl_crimson:twisting_vines", {
	description = S("Twisting Vines"),
	tiles = { "twisting_vines_plant.png" },
	inventory_image = "twisting_vines.png",
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, 0.5, 3/16 },
	},
}, {vinelike_node=1})

register_vines("mcl_crimson:weeping_vines", {
	description = S("Weeping Vines"),
	tiles = { "mcl_crimson_weeping_vines.png" },
	inventory_image = "mcl_crimson_weeping_vines.png",

	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, 0.5, 3/16 },
	},
}, {vinelike_node=2})

core.register_node("mcl_crimson:nether_sprouts", {
	description = S("Nether Sprouts"),
	drawtype = "plantlike",
	tiles = { "nether_sprouts.png" },
	inventory_image = "nether_sprouts.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {
		shearsy=1, deco_block=1, attached_node=1,
		dig_immediate=3, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1, compostability=50
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -4/16, -0.5, -4/16, 4/16, 0, 4/16 },
	},
	node_placement_prediction = "",
	drop = "",
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = false,
	_mcl_hardness = 0,
})

core.register_node("mcl_crimson:warped_roots", {
	description = S("Warped Roots"),
	drawtype = "plantlike",
	tiles = { "warped_roots.png" },
	inventory_image = "warped_roots.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {
		shearsy=1, deco_block=1, attached_node=1,
		dig_immediate=3, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1, compostability=65
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -0.5, -6/16, 6/16, -4/16, 6/16 },
	},
	node_placement_prediction = "",
	_mcl_silk_touch_drop = false,
	_mcl_hardness = 0,
})

mcl_flowerpots.register_potted_flower("mcl_crimson:warped_roots", {
	name = "warped_roots",
	desc = S("Warped Roots"),
	image = "warped_roots.png",
})


core.register_node("mcl_crimson:warped_wart_block", {
	description = S("Warped Wart Block"),
	tiles = {"warped_wart_block.png"},
	groups = {handy = 1, hoey = 7, swordy = 1, deco_block = 1, compostability = 85},
	_mcl_hardness = 1,
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_leaves_defaults({
			footstep={name="default_dirt_footstep", gain=0.7},
			dug={name="default_dirt_footstep", gain=1.5},
	}),
})

core.register_node("mcl_crimson:shroomlight", {
	description = S("Shroomlight"),
	tiles = {"shroomlight.png"},
	groups = {handy = 1, hoey = 7, swordy = 1, deco_block = 1, compostability = 65},
	light_source = core.LIGHT_MAX,
	paramtype = "light",
	_mcl_hardness = 1,
	sounds = mcl_sounds.node_sound_leaves_defaults({
			footstep={name="default_dirt_footstep", gain=0.7},
			dug={name="default_dirt_footstep", gain=1.5},
	}),
})

core.register_node("mcl_crimson:warped_nylium", {
	description = S("Warped Nylium"),
	tiles = {
		"warped_nylium.png",
		"mcl_nether_netherrack.png",
		"mcl_nether_netherrack.png^warped_nylium_side.png",
		"mcl_nether_netherrack.png^warped_nylium_side.png",
		"mcl_nether_netherrack.png^warped_nylium_side.png",
		"mcl_nether_netherrack.png^warped_nylium_side.png",
	},
	drop = "mcl_nether:netherrack",
	groups = {pickaxey=1, soil_fungus=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_hardness = 0.4,
	_mcl_silk_touch_drop = true,
	_on_bone_meal = on_bone_meal,
})

core.register_node("mcl_crimson:crimson_fungus", {
	description = S("Crimson Fungus"),
	_tt_help = S("Crimson fungus is a mushroom found in the nether's crimson forest."),
	_doc_items_longdesc = S("Crimson fungus is a mushroom found in the nether's crimson forest."),
	drawtype = "plantlike",
	tiles = { "farming_crimson_fungus.png" },
	inventory_image = "farming_crimson_fungus.png",
	wield_image = "farming_crimson_fungus.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3 ,mushroom=1 ,attached_node=1 ,dig_by_water=1 ,destroy_by_lava_flow=1 ,dig_by_piston=1 ,enderman_takable=1, deco_block=1, compostability=65},
	light_source = 1,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, 7/16, 3/16 },
	},
	node_placement_prediction = "",
	on_place = place_fungus,
	_on_bone_meal = function(_, _, _, pos)
		if core.get_node(vector.offset(pos,0,-1,0)).name == "mcl_crimson:crimson_nylium" then
			if math.random() > 0.40 then return end --fungus has a 40% chance to grow when bone mealing
			if check_for_bedrock(pos) then return false end
			core.remove_node(pos)
			return generate_fungus_tree(pos, "crimson")
		end
	end,
	_mcl_hardness = 0,
})

mcl_flowerpots.register_potted_flower("mcl_crimson:crimson_fungus", {
	name = "crimson_fungus",
	desc = S("Crimson Fungus"),
	image = "farming_crimson_fungus.png",
})

core.register_node("mcl_crimson:crimson_roots", {
	description = S("Crimson Roots"),
	drawtype = "plantlike",
	tiles = { "crimson_roots.png" },
	inventory_image = "crimson_roots.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {
		shearsy=1, deco_block=1, attached_node=1,
		dig_immediate=3 ,dig_by_water=1 ,destroy_by_lava_flow=1 ,dig_by_piston=1, compostability=65
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -0.5, -6/16, 6/16, -4/16, 6/16 },
	},
	node_placement_prediction = "",
	_mcl_silk_touch_drop = false,
	_mcl_hardness = 0,
})

mcl_flowerpots.register_potted_flower("mcl_crimson:crimson_roots", {
	name = "crimson_roots",
	desc = S("Crimson Roots"),
	image = "crimson_roots.png",
})

core.register_node("mcl_crimson:crimson_nylium", {
	description = S("Crimson Nylium"),
	tiles = {
		"crimson_nylium.png",
		"mcl_nether_netherrack.png",
		"mcl_nether_netherrack.png^crimson_nylium_side.png",
		"mcl_nether_netherrack.png^crimson_nylium_side.png",
		"mcl_nether_netherrack.png^crimson_nylium_side.png",
		"mcl_nether_netherrack.png^crimson_nylium_side.png",
	},
	groups = {pickaxey=1, soil_fungus=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	drop = "mcl_nether:netherrack",
	_mcl_hardness = 0.4,
	_mcl_silk_touch_drop = true,
	_on_bone_meal = on_bone_meal,
})

core.register_abm({
	label = "Turn Crimson Nylium and Warped Nylium below solid block into Netherrack",
	nodenames = {"mcl_crimson:crimson_nylium","mcl_crimson:warped_nylium"},
	neighbors = {"group:solid"},
	interval = 8,
	chance = 50,
	action = function(pos, node)
		if core.get_item_group(core.get_node(vector.offset(pos, 0, 1, 0)).name, "solid") > 0 then
			node.name = "mcl_nether:netherrack"
			core.swap_node(pos, node)
		end
	end
})

core.register_abm({
	label = "Weeping Vines and Twisting Vines growth",
	nodenames = { "mcl_crimson:weeping_vines", "mcl_crimson:twisting_vines" },
	interval = 47 * 2.5,
	chance = 4,
	action = function(pos, node)
		if grow_vines_direction[core.get_item_group(node.name, "vinelike_node")] and node.param2 < max_vines_age then
			mcl_crimson.grow_vines(pos, 1, node.name, nil, max_vines_age)
		end
	end
})

mcl_levelgen.register_levelgen_script (modpath .. "/lg_register.lua")
