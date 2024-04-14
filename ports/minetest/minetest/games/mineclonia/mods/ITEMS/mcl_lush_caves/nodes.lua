local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

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
	minetest.set_node(pos, { name = "mcl_lush_caves:moss" })
	if math.random() < 0.6 then
		local vegetation = random_moss_vegetation()
		local pos_up = vector.offset(pos, 0, 1, 0)
		if vegetation == "mcl_flowers:double_grass" then
			local pos_up2 = vector.offset(pos, 0, 2, 0)
			if minetest.registered_nodes[minetest.get_node(pos_up2).name].buildable_to then
				minetest.set_node(pos_up, { name = "mcl_flowers:double_grass" })
				minetest.set_node(pos_up2, { name = "mcl_flowers:double_grass_top" })
			else
				minetest.set_node(pos_up, { name = "mcl_flowers:tallgrass" })
			end
		else
			minetest.set_node(pos_up, { name = vegetation })
		end
	end
end

function mcl_lush_caves.bone_meal_moss(itemstack, placer, pointed_thing, pos)
	if minetest.get_node(vector.offset(pos, 0, 1, 0)).name ~= "air" then
		return false
	end

	local x_max = math.random(2, 3)
	local z_max = math.random(2, 3)
	local area_positions = minetest.find_nodes_in_area_under_air(
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

minetest.register_node("mcl_lush_caves:moss", {
	description = S("Moss"),
	_doc_items_longdesc = S("Moss is a green block found in lush caves"),
	_doc_items_entry_name = "moss",
	_doc_items_hidden = false,
	tiles = {"mcl_lush_caves_moss_block.png"},
	groups = { handy=1, hoey=2, dirt=1, soil=1, soil_bamboo=1, soil_sapling=2, soil_sugarcane=1, enderman_takable=1, building_block=1, flammable=1, fire_encouragement=60, fire_flammability=20, grass_block_no_snow = 1 },
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.1,
	_mcl_hardness = 0.1,
	_on_bone_meal = mcl_lush_caves.bone_meal_moss,
})

minetest.register_node("mcl_lush_caves:moss_carpet", {
	description = S("Moss carpet"),
	_doc_items_longdesc = S("Moss carpet"),
	_doc_items_entry_name = "moss_carpet",

	is_ground_content = false,
	tiles = {"mcl_lush_caves_moss_carpet.png"},
	wield_image ="mcl_lush_caves_moss_carpet.png",
	wield_scale = { x=1, y=1, z=0.5 },
	groups = {handy=1, carpet=1,supported_node=1,flammable=1,fire_encouragement=60, fire_flammability=20, deco_block=1, dig_by_water=1 },
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
	_mcl_blast_resistance = 0.1,
})

minetest.register_node("mcl_lush_caves:hanging_roots", {
	description = S("Hanging roots"),
	_doc_items_create_entry = S("Hanging roots"),
	_doc_items_entry_name = S("Hanging roots"),
	_doc_items_longdesc = S("Hanging roots"),
	paramtype = "light",
	--paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	--drop = "mcl_farming:wheat_seeds",
	tiles = {"mcl_lush_caves_hanging_roots.png"},
	inventory_image = "mcl_lush_caves_hanging_roots.png",
	wield_image = "mcl_lush_caves_hanging_roots.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		},
	},
	groups = { shearsy = 1, dig_immediate=3, plant=1, supported_node=0,	dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1, cultivatable=1 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 0,
})

minetest.register_node("mcl_lush_caves:cave_vines", {
	description = S("Cave vines"),
	_doc_items_create_entry = S("Cave vines"),
	_doc_items_entry_name = S("Cave vines"),
	_doc_items_longdesc = S("Cave vines"),
	paramtype = "light",
	--paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	--drop = "mcl_farming:wheat_seeds",
	tiles = {"mcl_lush_caves_cave_vines.png"},
	inventory_image = "mcl_lush_caves_cave_vines.png",
	wield_image = "mcl_lush_caves_cave_vines.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		},
	},
	groups = { shearsy = 1, dig_immediate=3, plant=1, supported_node=0, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1, cultivatable=1, converts_to_moss = 1 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 0,
})

minetest.register_node("mcl_lush_caves:cave_vines_lit", {
	description = S("Cave vines"),
	_doc_items_create_entry = S("Cave vines"),
	_doc_items_entry_name = S("Cave vines"),
	_doc_items_longdesc = S("Cave vines"),
	paramtype = "light",
	--paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	--drop = "mcl_farming:wheat_seeds",
	light_source = 9,
	tiles = {"mcl_lush_caves_cave_vines_lit.png"},
	inventory_image = "mcl_lush_caves_cave_vines_lit.png",
	wield_image = "mcl_lush_caves_cave_vines_lit.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		},
	},
	groups = { shearsy = 1, handy = 1, plant=1, supported_node=0, dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 1,
	_mcl_shears_drop = true,
	 drop = {
		max_items = 2,
		items = {
			{
				items = {
				"mcl_lush_caves:glow_berry ",
				"mcl_lush_caves:cave_vines",
				},
			},
		},
	},
	on_rightclick = function(pos)
		minetest.add_item(pos,"mcl_lush_caves:glow_berry")
		minetest.set_node(pos,{name="mcl_lush_caves:cave_vines"})
	end,
})

minetest.register_node("mcl_lush_caves:rooted_dirt", {
	description = S("Rooted dirt"),
	_doc_items_longdesc = S("Rooted dirt"),
	_doc_items_hidden = false,
	tiles = {"mcl_lush_caves_rooted_dirt.png"},
	groups = {handy=1, shovely=1, dirt=1, building_block=1, path_creation_possible=1, converts_to_moss = 1},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

minetest.register_craftitem("mcl_lush_caves:glow_berry", {
	description = S("Glow berry"),
	_doc_items_longdesc = S("This is a food item which can be eaten."),
	inventory_image = "mcl_lush_caves_glow_berries.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = {food = 2, eatable = 2, compostability = 50},
	_mcl_saturation = 1.2,
})


local function register_leaves(subname, def)
	def.palette = ""
	def.paramtype2 = "none"
	local d = mcl_trees.generate_leaves_def(
		"mcl_lush_caves:", subname, def,
		{"mcl_lush_caves:azalea_flowering", "mcl_lush_caves:azalea"}, false, {20, 16, 12, 10})
	d.leaves_def.groups.biomecolor = nil
	d.orphan_leaves_def.groups.biomecolor = nil
	minetest.register_node(d["leaves_id"], d["leaves_def"])
	minetest.register_node(d["orphan_leaves_id"], d["orphan_leaves_def"])
end

register_leaves(
	"azalea_leaves",
	{
		description = S("Azalea Leaves"),
		_doc_items_longdesc = S("Leaves of an Azalea tree"),
		tiles = { "mcl_lush_caves_azalea_leaves.png" },
	}
)

register_leaves(
	"azalea_leaves_flowering",
	{
		description = S("Flowering Azalea Leaves"),
		_doc_items_longdesc = S("The Flowering Leaves of an Azalea tree"),
		tiles = { "mcl_lush_caves_azalea_leaves_flowering.png" },
	}
)


minetest.register_node("mcl_lush_caves:spore_blossom", {
	description = S("Spore blossom"),
	_doc_items_longdesc = S("Spore blossom"),
	_doc_items_hidden = false,
	tiles = {"mcl_lush_caves_spore_blossom.png"},
	drawtype = "plantlike",
	param2type = "meshoptions",
	place_param2 = 4,
	groups = {handy = 1, plant = 1},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {{ -3/16, -2/16, -3/16, 3/16, 8/16, 3/16 }},
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	node_placement_prediction = "",
	on_place = mcl_util.generate_on_place_plant_function(function(place_pos, place_node,stack)
		local above = vector.offset(place_pos,0,1,0)
		local snn = minetest.get_node_or_nil(above).name
		if not snn then return false end
		if minetest.get_item_group(snn,"soil_sapling") > 0 then
			return true
		end
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
		flammable = 2, fire_encouragement = 15, fire_flammability = 40,
		deco_block = 1,
	},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
	use_texture_alpha = "clip",
	node_placement_prediction = "",
	on_place = mcl_util.generate_on_place_plant_function(function(pos, node, itemstack)
			local floor_name = minetest.get_node_or_nil(vector.offset(pos, 0, -1, 0)).name
			if not floor_name then return false end
			if minetest.get_item_group(floor_name, "soil_sapling") > 0 or floor_name == "mcl_lush_caves:rooted_dirt" or floor_name == "mcl_mangrove:mangrove_mud_roots" or floor_name == "mcl_mud:mud" or floor_name == "mcl_core:clay" then
				return true
			end
	end),
  _on_bone_meal = function(itemstack, placer, pointed_thing, pos)
		if math.random() > 0.45 or not mcl_trees.check_growth_simple(pos, 6) then return end
		minetest.set_node(vector.offset(pos, 0, -1, 0), { name = "mcl_lush_caves:rooted_dirt" })
    minetest.remove_node(pos)
    minetest.place_schematic(
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
		_doc_items_entry_name = "azalea",
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
minetest.register_node("mcl_lush_caves:azalea", azalea)

local azalea_flowering = table.merge(
	tpl_azalea, {
		description = S("Flowering Azalea"),
		_doc_items_longdesc = S("Flowering azalea is a small plant which often occurs in lush caves. It can be broken by hand or any tool. By using bone meal, flowering azalea can be turned into an azalea tree."),
		_doc_items_entry_name = "azalea_flowering",
		tiles = {
			"mcl_lush_caves_azalea_flowering_top.png",
			"mcl_lush_caves_azalea_flowering_bottom.png",
			"mcl_lush_caves_azalea_flowering_side.png",
			"mcl_lush_caves_azalea_flowering_side.png",
			"mcl_lush_caves_azalea_flowering_side.png",
			"mcl_lush_caves_azalea_flowering_side.png",
		},
})
azalea_flowering.groups.compostability = 85
minetest.register_node("mcl_lush_caves:azalea_flowering", azalea_flowering)

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_lush_caves:azalea",
	burntime = 32,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_lush_caves:azalea_flowering",
	burntime = 32,
})
