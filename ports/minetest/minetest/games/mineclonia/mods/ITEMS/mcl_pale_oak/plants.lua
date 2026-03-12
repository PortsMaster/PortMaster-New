local S = core.get_translator("mcl_pale_oak")

local function grow_hanging_moss(pos)
	local last_pos = pos
	local pos_iterator = vector.offset(pos, 0, -1, 0)
	local node = core.get_node(pos_iterator)

	while node.name ~= "air" do
		last_pos = pos_iterator
		pos_iterator = vector.offset(pos_iterator, 0, -1, 0)
		node = core.get_node(pos_iterator)
	end

	core.swap_node(last_pos, {name = "mcl_pale_oak:hanging_moss"})
	core.swap_node(pos_iterator, {name = "mcl_pale_oak:hanging_moss_tip"})
end

local hanging_moss_tpl = {
	description = S("Pale Hanging Moss"),
	groups = {
		dig_immediate = 3, shearsy = 1, dig_by_water = 1, destroy_by_lava_flow = 1, dig_by_piston = 1, deco_block = 1,
		compostability= 30, pale_hanging_moss = 1, attached_node = 4, fire_encouragement = 5, fire_flammability = 100
	},
	tiles = {"mcl_pale_oak_hanging_moss.png"},
	inventory_image = "mcl_pale_oak_hanging_moss.png",
	drawtype = "plantlike",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	drop = "",
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = true,
	_mcl_hardness = 0,
	_on_bone_meal = function(_, _, _, pos)
		grow_hanging_moss(pos)
	end,
	on_construct = function(pos)
		local above_pos = vector.offset(pos, 0, 1, 0)
		if core.get_node(above_pos).name == "mcl_pale_oak:hanging_moss_tip" then
			core.swap_node(above_pos, {name = "mcl_pale_oak:hanging_moss"})
		end

		core.swap_node(pos, {name = "mcl_pale_oak:hanging_moss_tip"})
	end,
	on_destruct = function(pos)
		local above_pos = vector.offset(pos, 0, 1, 0)
		if core.get_item_group(core.get_node(above_pos).name, "pale_hanging_moss") > 0 then
			core.swap_node(above_pos, {name = "mcl_pale_oak:hanging_moss_tip"})
		end

		local iterator_pos = vector.copy(pos)
		iterator_pos.y = iterator_pos.y - 1
		local node = core.get_node(iterator_pos)

		while core.get_item_group(node.name, "pale_hanging_moss") > 0 do
			core.swap_node(iterator_pos, {name = "air"})
			iterator_pos.y = iterator_pos.y - 1
			node = core.get_node(iterator_pos)
		end
	end
}

core.register_node("mcl_pale_oak:hanging_moss", hanging_moss_tpl)
core.register_node("mcl_pale_oak:hanging_moss_tip", table.merge(hanging_moss_tpl, {
	tiles = {"mcl_pale_oak_hanging_moss_tip.png"},
	groups = table.merge(hanging_moss_tpl.groups, { not_in_creative_inventory = 1 })
}))

local eyeblossom_selection_box = { -5/16, -0.5, -5/16, 5/16, 7/16, 5/16 }

mcl_flowers.register_simple_flower("eyeblossom", {
	desc = S("Closed Eyeblossom"),
	image = "mcl_pale_oak_eyeblossom.png",
	selection_box = eyeblossom_selection_box,
	potted = true,
	sus_stew = {effect = "nausea", duration = 8},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:grey"}},
	_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
})

mcl_flowers.register_simple_flower("eyeblossom_open", {
	desc = S("Open Eyeblossom"),
	image = "mcl_pale_oak_eyeblossom_open.png",
	selection_box = eyeblossom_selection_box,
	potted = true,
	sus_stew = {effect = "blindness", duration = 8},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:orange"}},
	_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
})

local function is_night()
	local timeofday = core.get_timeofday()
	return timeofday <= 0.2 or timeofday >= 0.8
end

core.register_abm({
	label = S("Eyeblossom activation"),
	chance = 2,
	interval = 2,
	nodenames = {"mcl_flowers:eyeblossom"},
	action = function(pos)
		if is_night() then
			core.swap_node(pos, {name = "mcl_flowers:eyeblossom_open"})
		end
	end
})

core.register_abm({
	label = S("Eyeblossom in a pot activation"),
	chance = 2,
	interval = 2,
	nodenames = {"mcl_flowerpots:flower_pot_eyeblossom"},
	action = function(pos)
		if is_night() then
			core.swap_node(pos, {name = "mcl_flowerpots:flower_pot_eyeblossom_open"})
		end
	end
})

core.register_abm({
	label = S("Eyeblossom deactivation"),
	chance = 2,
	interval = 2,
	nodenames = {"mcl_flowers:eyeblossom_open"},
	action = function(pos)
		if not is_night() then
			core.swap_node(pos, {name = "mcl_flowers:eyeblossom"})
		end
	end
})

core.register_abm({
	label = S("Eyeblossom in a pot deactivation"),
	chance = 2,
	interval = 2,
	nodenames = {"mcl_flowerpots:flower_pot_eyeblossom_open"},
	action = function(pos)
		if not is_night() then
			core.swap_node(pos, {name = "mcl_flowerpots:flower_pot_eyeblossom"})
		end
	end
})

local function random_moss_vegetation()
	local x = math.random()
	if x < 0.5882 then
		return "mcl_flowers:tallgrass"
	elseif x < 0.8823 then
		return "mcl_pale_oak:pale_moss_carpet"
	else
		return "mcl_flowers:double_grass"
	end
end

local function set_moss_with_chance_vegetation(pos)
	core.set_node(pos, { name = "mcl_pale_oak:pale_moss" })
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

local function bone_meal_moss(_, _, _, pos)
	if core.get_node(vector.offset(pos, 0, 1, 0)).name ~= "air" then
		return false
	end

	local x_max = math.random(2, 3)
	local z_max = math.random(2, 3)
	local area_positions = core.find_nodes_in_area_under_air(
		vector.offset(pos, -x_max, -6, -z_max),
		vector.offset(pos, x_max, 4, z_max),
		{ "group:converts_to_moss", "mcl_lush_caves:moss" }
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

core.register_node("mcl_pale_oak:pale_moss", {
	description = S("Pale Moss"),
	_doc_items_longdesc = S("Moss is a grey block found in pale garden"),
	_doc_items_entry_name = S("Pale Moss"),
	_doc_items_hidden = false,
	tiles = {"mcl_pale_oak_moss.png"},
	groups = {
		handy=1, hoey=2, dirt=1, soil=1, soil_flower=1, soil_generic_plant=1, soil_bamboo=1, soil_sapling=2, soil_sugarcane=1, soil_fungus=1,
		enderman_takable=1, building_block=1, grass_block_no_snow=1, compostability=65, dig_by_piston=1,
		fire_encouragement = 5, fire_flammability = 100
	},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_hardness = 0.1,
	_on_bone_meal = bone_meal_moss
})

core.register_node("mcl_pale_oak:pale_moss_carpet", {
	description = S("Pale Moss Carpet"),
	_doc_items_longdesc = S("A pale moss carpet is a flat variant of the pale moss block."),
	is_ground_content = false,
	tiles = {"mcl_pale_oak_moss.png"},
	wield_image = "mcl_pale_oak_moss.png",
	wield_scale = { x=1, y=1, z=0.5 },
	groups = {
		handy=1, carpet=1, supported_node=1, deco_block=1, compostability=30, dig_by_water=1,
		dig_by_piston=1, fire_encouragement = 5, fire_flammability = 100
	},
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
	output = "mcl_pale_oak:pale_moss_carpet 3",
	recipe = {{"mcl_pale_oak:pale_moss", "mcl_pale_oak:pale_moss"}},
})
