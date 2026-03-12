local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)

-- Return a vegetation type with the following chances
--   Tall Grass: 52.08%
--   Moss Carpet: 26.04%
--   Double Grass: 10.42%
--   Azalea: 7.29%
--   Flowering Azalea: 4.17%
local function random_moss_vegetation()
	local x = math.random()
	if x < 0.5208 then
		return "mcl_flowers:tallgrass"
	elseif x < 0.7812 then
		return "mcl_lush_caves:moss_carpet"
	elseif x < 0.8854 then
		return "mcl_flowers:double_grass"
	elseif x < 0.9583 then
		return "mcl_lush_caves:azalea"
	else
		return "mcl_lush_caves:azalea_flowering"
	end
end

-- sets the node at 'pos' to moss and with a 60% chance sets the node above to
-- vegatation
local function set_moss_with_chance_vegetation(pos)
	core.set_node(pos, { name = "mcl_lush_caves:moss" })
	if math.random() < 0.6 then
		local vegetation = random_moss_vegetation()
		local pos_up = vector.offset(pos, 0, 1, 0)
		if vegetation == "mcl_flowers:double_grass" then
			local pos_up2 = vector.offset(pos, 0, 2, 0)
			if core.registered_nodes[core.get_node(pos_up2).name].buildable_to then
				core.set_node(pos_up, { name = "mcl_flowers:double_grass" })
				core.set_node(pos_up2, { name = "mcl_flowers:double_grass_top" })
			else
				core.set_node(pos_up, { name = "mcl_flowers:tallgrass" })
			end
		else
			core.set_node(pos_up, { name = vegetation })
		end
	end
end

function mcl_lush_caves.bone_meal_moss(_, _, _, pos)
	if core.get_node(vector.offset(pos, 0, 1, 0)).name ~= "air" then
		return false
	end

	local x_max = math.random(2, 3)
	local z_max = math.random(2, 3)
	local area_positions = core.find_nodes_in_area_under_air(
		vector.offset(pos, -x_max, -6, -z_max),
		vector.offset(pos, x_max, 4, z_max),
		{ "group:converts_to_moss" }
	)

	for _, conversion_pos in pairs(area_positions) do
		local x_distance = math.abs(pos.x - conversion_pos.x)
		local z_distance = math.abs(pos.z - conversion_pos.z)

		if not ( x_distance == x_max and z_distance == z_max ) then
			if x_distance == x_max or z_distance == z_max then
				if math.random() < 0.75 then
					set_moss_with_chance_vegetation(conversion_pos)
				end
			else
				set_moss_with_chance_vegetation(conversion_pos)
			end
		end
	end
	return true
end

core.register_node("mcl_lush_caves:moss", {
	description = S("Moss"),
	_doc_items_longdesc = S("Moss is a green block found in lush caves"),
	_doc_items_entry_name = S("Moss"),
	_doc_items_hidden = false,
	tiles = {"mcl_lush_caves_moss_block.png"},
	groups = {handy=1, hoey=2, dirt=1, soil=1, soil_flower=1, soil_generic_plant=1, soil_bamboo=1, soil_sapling=2, soil_sugarcane=1, soil_fungus=1, enderman_takable=1, building_block=1, grass_block_no_snow=1, compostability=65, dig_by_piston=1},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_hardness = 0.1,
	_on_bone_meal = mcl_lush_caves.bone_meal_moss,
})

core.register_node("mcl_lush_caves:moss_carpet", {
	description = S("Moss Carpet"),
	_doc_items_longdesc = S("A moss carpet is a flat variant of the moss block."),
	is_ground_content = false,
	tiles = {"mcl_lush_caves_moss_carpet.png"},
	wield_image ="mcl_lush_caves_moss_carpet.png",
	wield_scale = { x=1, y=1, z=0.5 },
	groups = {handy=1, carpet=1, supported_node=1, deco_block=1, compostability=30, dig_by_water=1, dig_by_piston=1},
	sounds = mcl_sounds.node_sound_wool_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
		},
	},
	_mcl_hardness = 0.1,
})
core.register_craft({
	output = "mcl_lush_caves:moss_carpet 3",
	recipe = {{"mcl_lush_caves:moss", "mcl_lush_caves:moss"}},
})

core.register_node("mcl_lush_caves:hanging_roots", {
	description = S("Hanging roots"),
	_doc_items_create_entry = S("Hanging roots"),
	_doc_items_entry_name = S("Hanging roots"),
	_doc_items_longdesc = S("Hanging roots are a decorative block found hanging from rooted dirt in lush caves."),
	_doc_items_hidden = false,
	paramtype = "light",
	on_place = function(itemstack, placer, pointed_thing)
		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		if pointed_thing.under.y > pointed_thing.above.y then
			return core.item_place_node(itemstack, placer, pointed_thing)
		end
	end,
	node_placement_prediction = "",
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	tiles = {"mcl_lush_caves_hanging_roots.png"},
	inventory_image = "mcl_lush_caves_hanging_roots.png",
	wield_image = "mcl_lush_caves_hanging_roots.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		},
	},
	groups = {handy=1, plant=1, flammable=2, fire_encouragement=30, fire_flammability=60, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1, compostability=30, attached_node=4, deco_block=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_hardness = 0,
	drop = "",
	_mcl_shears_drop = true,
})

core.register_node("mcl_lush_caves:cave_vines", {
	description = S("Cave vines"),
	_doc_items_create_entry = S("Cave vines"),
	_doc_items_entry_name = S("Cave vines"),
	_doc_items_longdesc = S("Cave vines are decorative blocks growing from the ceiling of lush caves."),
	_doc_items_hidden = false,
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	climbable = true,
	drawtype = "plantlike",
	tiles = {"mcl_lush_caves_cave_vines.png"},
	inventory_image = "mcl_lush_caves_cave_vines.png",
	wield_image = "mcl_lush_caves_cave_vines.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-7/16, -0.5, -7/16, 7/16, 0.5, 7/16}
		},
	},
	groups = {
		handy=1, plant=1, vinelike_node=2,
		dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1,
		deco_block=1, not_in_creative_inventory=1
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_hardness = 0,
	drop = "",
	_on_bone_meal = function(_, _, _, pos, node)
		core.set_node(pos,{name="mcl_lush_caves:cave_vines_lit",
			param2=node.param2})
		return true
	end,

	_on_shears_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.under
		local tip = mcl_util.traverse_tower(pos, -1)

		if vector.equals(pos, tip) then
			core.sound_play("mcl_tools_shears_cut", {pos = pos}, true)
			local node = core.get_node(pos)
			node.param2 = 25
			core.swap_node(pos,node)
			return itemstack
		end
		return itemstack, true
	end
})

core.register_node("mcl_lush_caves:cave_vines_lit", {
	description = S("Lit Cave vines"),
	_doc_items_create_entry = S("Lit Cave vines"),
	_doc_items_entry_name = S("Lit Cave vines"),
	_doc_items_longdesc = S("Lit cave vines are light emitting decorative blocks growing from the ceiling of lush caves."),
	_doc_items_hidden = false,
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	climbable = true,
	drawtype = "plantlike",
	light_source = 14,
	tiles = {"mcl_lush_caves_cave_vines_lit.png"},
	inventory_image = "mcl_lush_caves_cave_vines_lit.png",
	wield_image = "mcl_lush_caves_cave_vines_lit.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-7/16, -0.5, -7/16, 7/16, 0.5, 7/16}
		},
	},
	groups = {
		handy=1, plant=1, vinelike_node=2,
		dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1,
		deco_block=1, not_in_creative_inventory=1
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_hardness = 0,
	drop = "mcl_lush_caves:glow_berry",
	on_rightclick = function(pos, node)
		core.add_item(pos,"mcl_lush_caves:glow_berry")
		core.set_node(pos,{name="mcl_lush_caves:cave_vines",
			param2=node.param2})
	end,
})

core.register_node("mcl_lush_caves:rooted_dirt", {
	description = S("Rooted dirt"),
	_doc_items_longdesc = S("Rooted dirt is type of dirt found in lush caves."),
	_doc_items_hidden = false,
	tiles = {"mcl_lush_caves_rooted_dirt.png"},
	groups = {handy=1, shovely=1, dirt=1, soil_flower=1, soil_generic_plant=1, soil_fungus=1, building_block=1, path_creation_possible=1, converts_to_moss=1, cultivatable=1, converts_to_mud=1},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_hardness = 0.5,
	_on_bottle_place = mcl_core.bottle_dirt,
	_on_bone_meal = function(_, _, _, pos, _)
		local under = vector.offset(pos, 0, -1, 0)
		if core.get_node(under).name == "air" then
			core.swap_node(under, {name = "mcl_lush_caves:hanging_roots"})
			return true
		end
		return false
	end,
	_on_hoe_place = function(itemstack, placer, pointed_thing)
		local rc, no_wear = mcl_farming.cultivate_dirt(itemstack, placer, pointed_thing)
		if rc then
			local below = vector.offset(pointed_thing.under, 0, -1, 0)
			if core.get_node(below).name == "mcl_lush_caves:hanging_roots" then
				core.remove_node(below)
				if not core.is_creative_enabled(placer:get_player_name()) then
					core.add_item(below, ItemStack("mcl_lush_caves:hanging_roots"))
				end
			end
		end

		return rc, no_wear
	end,
})

core.register_craftitem("mcl_lush_caves:glow_berry", {
	description = S("Glow berry"),
	_doc_items_longdesc = S("This is a food item which can be eaten."),
	_doc_items_hidden = false,
	inventory_image = "mcl_lush_caves_glow_berries.png",
	groups = {food = 2, eatable = 2, compostability = 50},
	_mcl_saturation = 1.2,
	on_place = function(itemstack, placer, pointed_thing)
		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		if not pointed_thing.under
			or vector.direction (pointed_thing.under, pointed_thing.above).y ~= -1 then
			return core.do_item_eat(2, nil, itemstack, placer, pointed_thing)
		end

		if mcl_util.check_position_protection(pointed_thing.above, placer) then return end

		local vine = "mcl_lush_caves:cave_vines"

		local node = core.get_node(pointed_thing.under)

		if core.get_item_group(node.name, "vinelike_node") == 2
		and node.name ~= vine then return end

		local age = node.param2 + 1
		if node.name ~= vine then age = 0 end

		core.place_node(pointed_thing.under, {name=vine}, placer)

		-- Grow berry if lucky
		if math.random() <= 0.11 then
			vine = "mcl_lush_caves:cave_vines_lit"
		end

		core.swap_node(vector.offset(pointed_thing.under,0,-1,0),
			{name=vine, param2=age})

		core.sound_play(core.registered_nodes[vine].sounds.place, {pos=pointed_thing.above, gain=1}, true)
		if not core.is_creative_enabled(placer:get_player_name()) then
			itemstack:take_item(1)
		end
		return itemstack
	end
})


local function register_leaves(subname, def)
	def.palette = ""
	def.paramtype2 = "none"
	local d = mcl_trees.generate_leaves_def(
		"mcl_trees:", subname, def,
		{"mcl_lush_caves:azalea_flowering", "mcl_lush_caves:azalea"}, false, {20, 16, 12, 10})
	d.leaves_def.groups.biomecolor = nil
	d.orphan_leaves_def.groups.biomecolor = nil
	core.register_node(":"..d["leaves_id"], d["leaves_def"])
	core.register_node(":"..d["orphan_leaves_id"], d["orphan_leaves_def"])
end

register_leaves(
	"leaves_azalea",
	{
		description = S("Azalea Leaves"),
		_doc_items_longdesc = S("Leaves of an Azalea tree"),
		_doc_items_hidden = false,
		tiles = { "mcl_lush_caves_azalea_leaves.png" },
	}
)

register_leaves(
	"leaves_azalea_flowering",
	{
		description = S("Flowering Azalea Leaves"),
		_doc_items_longdesc = S("The Flowering Leaves of an Azalea tree"),
		_doc_items_hidden = false,
		tiles = { "mcl_lush_caves_azalea_leaves_flowering.png" },
	}
)

core.register_alias("mcl_lush_caves:azalea_leaves", "mcl_trees:leaves_azalea")
core.register_alias("mcl_lush_caves:azalea_leaves_flowering", "mcl_trees:leaves_azalea_flowering")

core.register_node("mcl_lush_caves:spore_blossom", {
	description = S("Spore blossom"),
	_doc_items_longdesc = S("Spore blossoms are a type of flower found in lush caves."),
	_doc_items_hidden = false,
	tiles = {"mcl_lush_caves_spore_blossom_base.png", "mcl_lush_caves_spore_blossom.png"},
	drawtype = "mesh",
	mesh = "mcl_lush_caves_spore_blossom.obj",
	use_texture_alpha = "clip",
	paramtype = "light",
	groups = {handy = 1, plant = 1, deco_block = 1, attached_node = 4},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.375, 0.3125, -0.375, 0.375, 0.5, 0.375},
	},
	_mcl_hardness = 0.5,
	node_placement_prediction = "",
	on_place = mcl_util.generate_on_place_plant_function(function(place_pos)
		local above = vector.offset(place_pos,0,1,0)
		local node_above = core.get_node_or_nil(above)
		if not node_above then return false end
		local node_above_name = node_above.name
		if not node_above_name then return false end
		local is_opaque = core.get_item_group(node_above_name,"opaque") > 0
		local is_upright_stair = core.get_item_group(node_above_name,"stair") > 0 and node_above.param2 < 20
		local is_bottom_slab = core.get_item_group(node_above_name, "slab") > 0 and core.get_item_group(node_above_name, "slab_top") == 0
		local is_valid = is_opaque or is_upright_stair or is_bottom_slab
		return is_valid
	end)
})

local tpl_azalea = {
	_tt_help = S("Needs soil and bone meal to grow"),
	_doc_items_hidden = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -4/16, -8/16, 8/16, 8/16, 8/16 },
			{ -2/16, -8/16, -2/16, 2/16, -4/16, 2/16 },
		}
	},
	is_ground_content = false,
	groups = {
		handy = 1, shearsy = 1,
		plant = 1, non_mycelium_plant = 1,
		dig_by_piston = 1, dig_by_water = 1,
		flammable = 2, fire_encouragement = 30, fire_flammability = 60,
		deco_block = 1, pathfinder_partial = 2, attached_node = 3
	},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	_mcl_hardness = 0,
	_mcl_burntime = 5,
	use_texture_alpha = "clip",
	node_placement_prediction = "",
	on_place = mcl_util.generate_on_place_plant_function(function(pos)
			local floor_name = core.get_node_or_nil(vector.offset(pos, 0, -1, 0)).name
			if not floor_name then return false end
			if core.get_item_group(floor_name, "soil_flower") > 0 then
				return true
			end
	end),
	_on_bone_meal = function(_, _, _, pos)
		if math.random() > 0.45 or not mcl_trees.check_growth_simple(pos, 6) then return end
		core.set_node(vector.offset(pos, 0, -1, 0), { name = "mcl_lush_caves:rooted_dirt" })
		core.remove_node(pos)
		core.place_schematic(
			vector.offset(pos, -3, 0, -3),
			modpath.."/schematics/azalea1.mts",
			"random",
			nil,
			false,
			"place_center_x place_center_z"
		)
		return true
	end
}

local azalea = table.merge(
	tpl_azalea, {
		description = S("Azalea"),
		_doc_items_longdesc = S("Azalea is a small plant which often occurs in lush caves. It can be broken by hand or any tool. By using bone meal, azalea can be turned into an azalea tree."),
		_doc_items_hidden = false,
		tiles = {
			"mcl_lush_caves_azalea_top.png",
			"mcl_lush_caves_azalea_bottom.png",
			"mcl_lush_caves_azalea_side.png",
			"mcl_lush_caves_azalea_side.png",
			"mcl_lush_caves_azalea_side.png",
			"mcl_lush_caves_azalea_side.png",
		},
})
azalea.groups.compostability = 65
core.register_node("mcl_lush_caves:azalea", azalea)

local azalea_flowering = table.merge(
	tpl_azalea, {
		description = S("Flowering Azalea"),
		_doc_items_longdesc = S("Flowering azalea is a small plant which often occurs in lush caves. It can be broken by hand or any tool. By using bone meal, flowering azalea can be turned into an azalea tree."),
		_doc_items_entry_name = S("Flowering Azalea"),
		_doc_items_hidden = false,
		tiles = {
			"mcl_lush_caves_azalea_flowering_top.png",
			"mcl_lush_caves_azalea_flowering_bottom.png",
			"mcl_lush_caves_azalea_flowering_side.png",
			"mcl_lush_caves_azalea_flowering_side.png",
			"mcl_lush_caves_azalea_flowering_side.png",
			"mcl_lush_caves_azalea_flowering_side.png",
		},
		groups = table.merge(tpl_azalea.groups, {flower = 1}),
})
azalea_flowering.groups.compostability = 85
core.register_node("mcl_lush_caves:azalea_flowering", azalea_flowering)
