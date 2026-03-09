local S = core.get_translator(core.get_current_modname())

mcl_flowers.register_simple_flower("poppy", {
	desc = S("Poppy"),
	image = "mcl_flowers_poppy.png",
	selection_box = {-5/16, -0.5, -5/16, 5/16, 5/16, 5/16},
	potted = true,
	sus_stew = {effect = "night_vision", duration = 5},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:red"}},
	_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
})

mcl_flowers.register_simple_flower("dandelion", {
	desc = S("Dandelion"),
	image = "flowers_dandelion_yellow.png",
	selection_box = {-4/16, -0.5, -4/16, 4/16, 3/16, 4/16},
	potted = true,
	sus_stew = {effect = "saturation", duration = 0.5},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:yellow"}},
	_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
})

mcl_flowers.register_simple_flower("oxeye_daisy", {
	desc = S("Oxeye Daisy"),
	image = "mcl_flowers_oxeye_daisy.png",
	selection_box = {-4/16, -0.5, -4/16, 4/16, 4/16, 4/16},
	potted = true,
	sus_stew = {effect = "regeneration", duration = 8},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:silver"}},
	_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
})

mcl_flowers.register_simple_flower("tulip_orange", {
	desc = S("Orange Tulip"),
	image = "flowers_tulip.png",
	selection_box = {-3/16, -0.5, -3/16, 3/16, 5/16, 3/16},
	potted = true,
	sus_stew = {effect = "weakness", duration = 9},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:orange"}},
	_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
})

mcl_flowers.register_simple_flower("tulip_pink", {
	desc = S("Pink Tulip"),
	image = "mcl_flowers_tulip_pink.png",
	selection_box = {-3/16, -0.5, -3/16, 3/16, 5/16, 3/16},
	potted = true,
	sus_stew = {effect = "weakness", duration = 9},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:pink"}},
	_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
})

mcl_flowers.register_simple_flower("tulip_red", {
	desc = S("Red Tulip"),
	image = "mcl_flowers_tulip_red.png",
	selection_box = {-3/16, -0.5, -3/16, 3/16, 6/16, 3/16},
	potted = true,
	sus_stew = {effect = "weakness", duration = 9},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:red"}},
	_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
})

mcl_flowers.register_simple_flower("tulip_white", {
	desc = S("White Tulip"),
	image = "mcl_flowers_tulip_white.png",
	selection_box = {-3/16, -0.5, -3/16, 3/16, 4/16, 3/16},
	potted = true,
	sus_stew = {effect = "weakness", duration = 9},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:silver"}},
	_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
})

mcl_flowers.register_simple_flower("allium", {
	desc = S("Allium"),
	image = "mcl_flowers_allium.png",
	selection_box = {-3/16, -0.5, -3/16, 3/16, 6/16, 3/16},
	potted = true,
	sus_stew = {effect = "fire_resistance", duration = 4},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:magenta"}},
	_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
})

mcl_flowers.register_simple_flower("azure_bluet", {
	desc = S("Azure Bluet"),
	image = "mcl_flowers_azure_bluet.png",
	selection_box = {-5/16, -0.5, -5/16, 5/16, 3/16, 5/16},
	potted = true,
	sus_stew = {effect = "blindness", duration = 8},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:silver"}},
	_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
})

mcl_flowers.register_simple_flower("blue_orchid", {
	desc = S("Blue Orchid"),
	image = "mcl_flowers_blue_orchid.png",
	selection_box = {-5/16, -0.5, -5/16, 5/16, 7/16, 5/16},
	potted = true,
	sus_stew = {effect = "saturation", duration = 0.5},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:light_blue"}},
	_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
})

mcl_flowers.register_simple_flower("wither_rose", {
	desc = S("Wither Rose"),
	image = "mcl_flowers_wither_rose.png",
	selection_box = {-3/16, -0.5, -3/16, 3/16, 6/16, 3/16},
	potted = true,
	sus_stew = {effect = "withering", duration = 8},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:black"}},
	_on_object_in = function(_, _, obj)
		mcl_potions.give_effect("withering", obj, 1, 2)
	end,
})

mcl_flowers.register_simple_flower("lily_of_the_valley", {
	desc = S("Lily of the Valley"),
	image = "mcl_flowers_lily_of_the_valley.png",
	selection_box = {-5/16, -0.5, -5/16, 4/16, 5/16, 5/16},
	potted = true,
	sus_stew = {effect = "poison", duration = 12},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:white"}},
	_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
})

mcl_flowers.register_simple_flower("cornflower", {
	desc = S("Cornflower"),
	image = "mcl_flowers_cornflower.png",
	selection_box = {-4/16, -0.5, -4/16, 4/16, 3/16, 4/16},
	potted = true,
	sus_stew = {effect = "leaping", duration = 6},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:blue"}},
	_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
})

mcl_flowers.register_ground_flower("wildflowers", {
	desc = S("Wildflowers"),
	image = "mcl_flowers_wildflower.png",
	tiles = {"mcl_flowers_wildflower.png","mcl_flowers_wildflower_stem.png"},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:yellow"}}
})
mcl_flowers.register_ground_flower("leaf_litter", {
	desc = S("Leaf Litter"),
	paramtype2 = "color4dir",
	mesh_prefix = "mcl_flowers_leaf_litter_",
	image = "mcl_flowers_leaf_litter.png^[multiply:#A37546",
	tiles = {"mcl_flowers_leaf_litter.png^[multiply:#A37546"},
	placeable_on_anything = true
}, {
	_mcl_burntime = 5,
})
mcl_flowers.register_ground_flower("pink_petals", {
	desc = S("Pink Petals"),
	longdesc = S("Pink Petals are ground decoration of cherry grove biomes"),
	image = "mcl_cherry_blossom_pink_petals.png",
	tiles = {"mcl_cherry_blossom_pink_petals.png","mcl_flowers_wildflower_stem.png"},
}, {
	_mcl_crafting_output = {single = {output = "mcl_dyes:pink"}}
})
core.register_alias("mcl_cherry_blossom:pink_petals", "mcl_flowers:pink_petals_4")

mcl_flowers.add_large_plant("peony", {
	desc = S("Peony"),
	longdesc = S("A peony is a large plant which occupies two blocks. It is mainly used in dye production."),
	tiles_bottom = {"mcl_flowers_double_plant_paeonia_bottom.png"},
	tiles_top = {"mcl_flowers_double_plant_paeonia_top.png"},
	selbox_radius = 5/16,
	selbox_top_height = 6/16,
	is_flower = true,
	bottom = {
		_mcl_crafting_output = {single = {output = "mcl_dyes:pink 2"}},
		_on_bone_meal = function(_, _, _, pos, n)
			core.add_item(pos, "mcl_flowers:peony")
		end,
	}
})


mcl_flowers.add_large_plant("rose_bush", {
	desc = S("Rose Bush"),
	longdesc = S("A rose bush is a large plant which occupies two blocks. It is safe to touch it. Rose bushes are mainly used in dye production."),
	tiles_bottom = {"mcl_flowers_double_plant_rose_bottom.png"},
	tiles_top = {"mcl_flowers_double_plant_rose_top.png"},
	selbox_radius = 5/16,
	selbox_top_height = 1/16,
	is_flower = true,
	bottom = {
		_mcl_crafting_output = {single = {output = "mcl_dyes:red 2"}},
		_on_bone_meal = function(_, _, _, pos, n)
			core.add_item(pos, "mcl_flowers:rose_bush")
		end,
	}
})

mcl_flowers.add_large_plant("lilac", {
	desc = S("Lilac"),
	longdesc = S("A lilac is a large plant which occupies two blocks. It is mainly used in dye production."),
	tiles_bottom = {"mcl_flowers_double_plant_syringa_bottom.png"},
	tiles_top = {"mcl_flowers_double_plant_syringa_top.png"},
	selbox_radius = 5/16,
	selbox_top_height = 6/16,
	is_flower = true,
	bottom = {
		_mcl_crafting_output = {single = {output = "mcl_dyes:magenta 2"}},
		_on_bone_meal = function(_, _, _, pos, n)
			core.add_item(pos, "mcl_flowers:lilac")
		end,
	}
})

mcl_flowers.add_large_plant("sunflower", {
	desc = S("Sunflower"),
	longdesc = S("A sunflower is a large plant which occupies two blocks. It is mainly used in dye production."),
	tiles_bottom = {"mcl_flowers_double_plant_sunflower_bottom.png", "mcl_flowers_double_plant_sunflower_bottom.png", "mcl_flowers_double_plant_sunflower_front.png", "mcl_flowers_double_plant_sunflower_back.png"},
	bottom = {
		inventory_image = "mcl_flowers_double_plant_sunflower_front.png",
		drawtype = "mesh",
		mesh = "mcl_flowers_sunflower.obj",
		drop = "mcl_flowers:sunflower",
		use_texture_alpha = "clip",
		_mcl_crafting_output = {single = {output = "mcl_dyes:yellow 2"}},
		_on_bone_meal = function(_, _, _, pos, n)
			core.add_item(pos, "mcl_flowers:sunflower")
		end,
	},
	top = {
		drawtype = "airlike",
		drop = "mcl_flowers:sunflower",
	},
	selbox_radius = 5/16,
	selbox_top_height = 6/16,
	is_flower = true,
})

mcl_flowers.wheat_seed_drop = {
	max_items = 1,
	items = {
		{
			items = {"mcl_farming:wheat_seeds"},
			rarity = 8,
		},
	},
}

mcl_flowers.fortune_wheat_seed_drop = {
	discrete_uniform_distribution = true,
	items = {"mcl_farming:wheat_seeds"},
	chance = 1 / 8,
	min_count = 1,
	max_count = 1,
	factor = 2,
	overwrite = true,
}

mcl_flowers.add_large_plant("double_grass", {
	desc = S("Double Tallgrass"),
	longdesc = S("Double tallgrass a variant of tall grass and occupies two blocks. It can be harvested for wheat seeds."),
	tiles_bottom = {"mcl_flowers_double_plant_grass_bottom.png"},
	tiles_top = {"mcl_flowers_double_plant_grass_top.png"},
	inv_img = "mcl_flowers_double_plant_grass_inv.png",
	bottom = {
		groups = {compostability = 50},
		drop = mcl_flowers.wheat_seed_drop,
		_mcl_fortune_drop = mcl_flowers.fortune_wheat_seed_drop,
		_mcl_shears_drop = {"mcl_flowers:tallgrass 2"},
	},
	selbox_radius = 6/16,
	selbox_top_height = 4/16,
	grass_color = true,
})

mcl_flowers.add_large_plant("double_fern", {
	desc = S("Large Fern"),
	longdesc = S("Large fern is a variant of fern and occupies two blocks. It can be harvested for wheat seeds."),
	tiles_bottom = {"mcl_flowers_double_plant_fern_bottom.png"},
	tiles_top = {"mcl_flowers_double_plant_fern_top.png"},
	inv_img = "mcl_flowers_double_plant_fern_inv.png",
	bottom = {
		groups = {compostability = 50},
		drop = mcl_flowers.wheat_seed_drop,
		_mcl_fortune_drop = mcl_flowers.fortune_wheat_seed_drop,
		_mcl_shears_drop = {"mcl_flowers:fern 2"},
	},
	selbox_radius = 5/16,
	selbox_top_height = 5/16,
	grass_color = true,
})

local def_tallgrass = {
	description = S("Tall Grass"),
	drawtype = "plantlike",
	longdesc = S("Tall grass is a small plant which often occurs on the surface of grasslands. It can be harvested for wheat seeds. By using bone meal, tall grass can be turned into double tallgrass which is two blocks high."),
	_doc_items_usagehelp = mcl_flowers.plant_usage_help,
	_doc_items_hidden = false,
	waving = 1,
	tiles = {"mcl_flowers_tallgrass.png"},
	inventory_image = "mcl_flowers_tallgrass_inv.png",
	wield_image = "mcl_flowers_tallgrass_inv.png",
	selection_box = {
		type = "fixed",
		fixed = {{-6/16, -8/16, -6/16, 6/16, 4/16, 6/16}},
	},
	paramtype = "light",
	paramtype2 = "color",
	palette = "mcl_core_palette_grass.png",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {
		handy = 1, shearsy = 1, attached_node = 1, deco_block = 1,
		plant = 1, place_flowerlike = 2, non_mycelium_plant = 1,
		flammable = 3, fire_encouragement = 60, fire_flammability = 100, dig_by_piston = 1,
		dig_by_water = 1, destroy_by_lava_flow = 1, compostability = 30, grass_palette = 1
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	drop = mcl_flowers.wheat_seed_drop,
	_mcl_shears_drop = true,
	_mcl_fortune_drop = mcl_flowers.fortune_wheat_seed_drop,
	node_placement_prediction = "",
	on_place = mcl_flowers.on_place_flower,
	_mcl_hardness = 0,
}
core.register_node("mcl_flowers:tallgrass", table.merge(def_tallgrass, {
	_on_bone_meal = function(_, _, _ , pos, n)
		local toppos = vector.offset(pos, 0, 1, 0)
		local topnode = core.get_node(toppos)
		if core.registered_nodes[topnode.name].buildable_to then
			core.set_node(pos, {name = "mcl_flowers:double_grass", param2 = n.param2})
			core.set_node(toppos, {name = "mcl_flowers:double_grass_top", param2 = n.param2})
			return true
		end
	end,
}))

core.register_node("mcl_flowers:fern", table.merge(def_tallgrass, {
	description = S("Fern"),
	longdesc = S("Ferns are small plants which occur naturally in jungles and taigas. They can be harvested for wheat seeds. By using bone meal, a fern can be turned into a large fern which is two blocks high."),
	tiles = {"mcl_flowers_fern.png"},
	inventory_image = "mcl_flowers_fern_inv.png",
	wield_image = "mcl_flowers_fern_inv.png",
	selection_box = {
		type = "fixed",
		fixed = {-6/16, -0.5, -6/16, 6/16, 5/16, 6/16},
	},
	groups = table.merge(def_tallgrass.groups, {compostability = 65}),
	_on_bone_meal = function(_, _, _ , pos, n)
		local toppos = vector.offset(pos, 0, 1, 0)
		local topnode = core.get_node(toppos)
		if core.registered_nodes[topnode.name].buildable_to then
			core.set_node(pos, {name = "mcl_flowers:double_fern", param2 = n.param2})
			core.set_node(toppos, {name = "mcl_flowers:double_fern_top", param2 = n.param2})
			return true
		end
	end,
}))

mcl_flowerpots.register_potted_flower("mcl_flowers:fern", {
	name = "fern",
	desc = S("Fern"),
	image = "mcl_flowers_fern.png",
})

core.register_lbm({
	label = "Recolorize potted ferns",
	name = "mcl_flowers:recolorize_ferns",
	nodenames = {"mcl_flowerpots:flower_pot_fern"},
	run_at_every_load = false,
	action = function(pos, node)
		node.param2 = mcl_util.get_pos_p2(pos)
		core.swap_node(pos, node)
	end
})

core.register_node("mcl_flowers:bush", table.merge(def_tallgrass, {
	description = S("Bush"),
	drop = "",
	tiles = {"mcl_flowers_bush.png"},
	inventory_image = "mcl_flowers_bush.png^[multiply:#507A32",
	wield_image = "mcl_flowers_bush.png^[multiply:#507A32",
	selection_box = {
		type = "fixed",
		fixed = {-0.4375, -0.5, -0.4375, 0.4375, 0.25, 0.4375}
	},
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = true,
	_on_bone_meal = mcl_flowers.on_bone_meal,
}))

core.register_node("mcl_flowers:firefly_bush", table.merge(def_tallgrass, {
	description = S("Firefly Bush"),
	drop = "mcl_flowers:firefly_bush",
	tiles = {
		{
			name = "mcl_flowers_firefly_bush.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			}
		}
	},
	inventory_image = "mcl_flowers_firefly_bush_inv.png",
	wield_image = "mcl_flowers_firefly_bush_inv.png",
	palette = "",
	light_source = 2,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.4, 0.3}
	},
	_mcl_silk_touch_drop = true,
	_mcl_shears_drop = true,
	on_place = mcl_util.generate_on_place_plant_function(function(pos)
		local below = vector.offset(pos, 0, -1, 0)
		local soil = core.get_node_or_nil(below)
		if not soil then return end
		local allowed_nodes = {
			"mcl_core:dirt_with_grass", "mcl_core:mycelium", "mcl_core:podzol", "mcl_core:dirt",
			"mcl_core:coarse_dirt", "mcl_lush_caves:rooted_dirt", "mcl_farming:soil", "mcl_farming:soil_wet",
			"mcl_mud:mud", "mcl_mangrove:mangrove_mud_roots", "mcl_lush_caves:moss", "mcl_pale_oak:pale_moss"
		}

		if table.indexof(allowed_nodes, soil.name) ~= -1 then
			return true, 0
		end
	end),
	_on_bone_meal = mcl_flowers.on_bone_meal,
}))

core.register_node("mcl_flowers:short_dry_grass", table.merge(def_tallgrass, {
	description = S("Short Dry Grass"),
	drop = "",
	tiles = {"mcl_flowers_short_dry_grass.png"},
	inventory_image = "mcl_flowers_short_dry_grass.png",
	wield_image = "mcl_flowers_short_dry_grass.png",
	palette = "",
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0, 0.25}
	},
	_mcl_burntime = 5,
	_mcl_silk_touch_drop = true,
	_mcl_shears_drop = true,
	on_place = mcl_util.generate_on_place_plant_function(function(pos)
		local below = vector.offset(pos, 0, -1, 0)
		local soil = core.get_node_or_nil(below)
		if not soil then return end
		local allowed_nodes = {
			"mcl_core:dirt_with_grass", "mcl_core:mycelium", "mcl_core:podzol", "mcl_core:dirt",
			"mcl_core:coarse_dirt", "mcl_lush_caves:rooted_dirt", "mcl_farming:soil", "mcl_farming:soil_wet",
			"mcl_colorblocks:hardened_clay", "mcl_core:sand", "mcl_core:redsand", "mcl_sus_nodes:sand",
			"mcl_mud:mud", "mcl_mangrove:mangrove_mud_roots", "mcl_lush_caves:moss", "mcl_pale_oak:pale_moss"
		}

		if table.indexof(allowed_nodes, soil.name) ~= -1 then
			return true, 0
		end
	end),
	_on_bone_meal = function(_, _, _, pos)
		core.swap_node(pos, {name = "mcl_flowers:tall_dry_grass"})
		return true
	end
}))

core.register_node("mcl_flowers:tall_dry_grass", table.merge(def_tallgrass, {
	description = S("Tall Dry Grass"),
	drop = "",
	visual_scale = 0.5,
	drawtype = "mesh",
	mesh = "tall_dry_grass.obj",
	tiles = {"mcl_flowers_tall_dry_grass.png"},
	inventory_image = "mcl_flowers_tall_dry_grass.png",
	wield_image = "mcl_flowers_tall_dry_grass.png",
	palette = "",
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.25, 0.3}
	},
	_mcl_burntime = 5,
	_mcl_silk_touch_drop = true,
	_mcl_shears_drop = true,
	on_place = mcl_util.generate_on_place_plant_function(function(pos)
		local below = vector.offset(pos, 0, -1, 0)
		local soil = core.get_node_or_nil(below)
		if not soil then return end
		local allowed_nodes = {
			"mcl_core:dirt_with_grass", "mcl_core:mycelium", "mcl_core:podzol", "mcl_core:dirt",
			"mcl_core:coarse_dirt", "mcl_lush_caves:rooted_dirt", "mcl_farming:soil", "mcl_farming:soil_wet",
			"mcl_colorblocks:hardened_clay", "mcl_core:sand", "mcl_core:redsand", "mcl_sus_nodes:sand",
			"mcl_mud:mud", "mcl_mangrove:mangrove_mud_roots", "mcl_lush_caves:moss", "mcl_pale_oak:pale_moss"
		}

		if table.indexof(allowed_nodes, soil.name) ~= -1 then
			return true, 0
		end
	end),
	_on_bone_meal = mcl_flowers.on_bone_meal,
}))

core.register_node("mcl_flowers:waterlily", {
	description = S("Lily Pad"),
	_doc_items_longdesc = S("A lily pad is a flat plant block which can be walked on. They can be placed on water sources, ice and frosted ice."),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"flowers_waterlily.png", "flowers_waterlily.png^[transformFY"},
	use_texture_alpha = "clip",
	inventory_image = "flowers_waterlily.png",
	wield_image = "flowers_waterlily.png",
	pointabilities = {
		nodes = {
			["group:water"] = true,
		},
	},
	sunlight_propagates = true,
	groups = {
		deco_block = 1, plant = 1, compostability = 65, destroy_by_lava_flow = 1,
		dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1, dig_by_boat = 1, floating_node = 3
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -31/64, -0.5, 0.5, -15/32, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-7 / 16, -0.5, -7 / 16, 7 / 16, -15 / 32, 7 / 16}
	},

	on_place = function(itemstack, placer, pointed_thing)
		if not placer or not placer:is_player() then
			return itemstack
		end

		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		local pos = pointed_thing.above
		local node = core.get_node(pointed_thing.under)
		local nodename = node.name
		local def = core.registered_nodes[nodename]
		local node_above = core.get_node(pointed_thing.above).name
		local def_above = core.registered_nodes[node_above]
		local player_name = placer:get_player_name()

		if def then
			if (pointed_thing.under.x == pointed_thing.above.x and pointed_thing.under.z == pointed_thing.above.z) and
					((def.liquidtype == "source" and core.get_item_group(nodename, "water") > 0) or
					(nodename == "mcl_core:ice") or
					(core.get_item_group(nodename, "frosted_ice") > 0)) and
					(def_above.buildable_to and core.get_item_group(node_above, "liquid") == 0) then
				if not core.is_protected(pos, player_name) then
					core.set_node(pos, {name = "mcl_flowers:waterlily", param2 = math.random(0, 3)})
					local idef = itemstack:get_definition()

					if idef.sounds and idef.sounds.place then
						core.sound_play(idef.sounds.place, {pos=pointed_thing.above, gain=1}, true)
					end

					if not core.is_creative_enabled(player_name) then
						itemstack:take_item()
					end
				else
					core.record_protection_violation(pos, player_name)
				end
			end
		end
		return itemstack
	end,
	on_rotate = screwdriver.rotate_simple,
	_pathfinding_class = "TRAPDOOR",
})
