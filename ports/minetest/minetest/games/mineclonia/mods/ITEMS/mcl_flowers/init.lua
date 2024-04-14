local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

local mod_screwdriver = minetest.get_modpath("screwdriver")
local has_mcl_flowerpots = minetest.get_modpath("mcl_flowerpots")

mcl_flowers = {}
mcl_flowers.registered_simple_flowers = {}
-- Simple flower template
local smallflowerlongdesc = S("This is a small flower. Small flowers are mainly used for dye production and can also be potted.")
local plant_usage_help = S("It can only be placed on a block on which it would also survive.")

local function on_bone_meal(itemstack,placer,pointed_thing,pos,n)
	if n.name == "mcl_flowers:rose_bush" or n.name == "mcl_flowers:rose_bush_top" then
		minetest.add_item(pos, "mcl_flowers:rose_bush")
		return true
	elseif n.name == "mcl_flowers:peony" or n.name == "mcl_flowers:peony_top" then
		minetest.add_item(pos, "mcl_flowers:peony")
		return true
	elseif n.name == "mcl_flowers:lilac" or n.name == "mcl_flowers:lilac_top" then
		minetest.add_item(pos, "mcl_flowers:lilac")
		return true
	elseif n.name == "mcl_flowers:sunflower" or n.name == "mcl_flowers:sunflower_top" then
		minetest.add_item(pos, "mcl_flowers:sunflower")
		return true
	elseif n.name == "mcl_flowers:tallgrass" then
		-- Tall Grass: Grow into double tallgrass
		local toppos = { x=pos.x, y=pos.y+1, z=pos.z }
		local topnode = minetest.get_node(toppos)
		if minetest.registered_nodes[topnode.name].buildable_to then
			minetest.set_node(pos, { name = "mcl_flowers:double_grass", param2 = n.param2 })
			minetest.set_node(toppos, { name = "mcl_flowers:double_grass_top", param2 = n.param2 })
			return true
		end
	elseif n.name == "mcl_flowers:fern" then
		-- Fern: Grow into large fern
		local toppos = { x=pos.x, y=pos.y+1, z=pos.z }
		local topnode = minetest.get_node(toppos)
		if minetest.registered_nodes[topnode.name].buildable_to then
			minetest.set_node(pos, { name = "mcl_flowers:double_fern", param2 = n.param2 })
			minetest.set_node(toppos, { name = "mcl_flowers:double_fern_top", param2 = n.param2 })
			return true
		end
	end
	return false
end

local scan_area = 9
local spawn_on = { "mcl_core:dirt", "group:grass_block" }

local function on_bone_meal_simple(itemstack, placer, pointed_thing, pos, n)
	if n.name ~= "mcl_flowers:wither_rose" then
		local nn = minetest.find_nodes_in_area_under_air(
			vector.offset(pos, -scan_area, -3, -scan_area),
			vector.offset(pos, scan_area, 3, scan_area),
			spawn_on
		)

		local any_placed = false
		if next(nn) ~= nil then
			table.shuffle(nn)
			for i = 1, math.random(1, math.min(14, #nn)) do
				if minetest.add_node(vector.offset(nn[i], 0, 1, 0), { name = n.name }) then
					any_placed = true
				end
			end
			return any_placed
		end
	end

	return false
end

local get_palette_color_from_pos = function(pos)
	local biome_data = minetest.get_biome_data(pos)
	local index = 0
	if biome_data then
		local biome = biome_data.biome
		local biome_name = minetest.get_biome_name(biome)
		local reg_biome = minetest.registered_biomes[biome_name]
		if reg_biome then
			index = reg_biome._mcl_palette_index
		end
	end
	return index
end

-- on_place function for flowers
local on_place_flower = mcl_util.generate_on_place_plant_function(function(pos, node, itemstack)
	local below = {x=pos.x, y=pos.y-1, z=pos.z}
	local soil_node = minetest.get_node_or_nil(below)
	if not soil_node then return false end

	local has_palette = minetest.registered_nodes[itemstack:get_name()].palette ~= nil
	local colorize
	if has_palette then
		colorize = get_palette_color_from_pos(pos)
	end
	if not colorize then
		colorize = 0
	end

--[[	Placement requirements:
	* Dirt, grass or moss block
	* If not flower, also allowed on podzol and coarse dirt
	* Light level >= 8 at any time or exposed to sunlight at day
]]
	local light_night = minetest.get_node_light(pos, 0.0)
	local light_day = minetest.get_node_light(pos, 0.5)
	local light_ok = false
	if (light_night and light_night >= 8) or (light_day and light_day >= minetest.LIGHT_MAX) then
		light_ok = true
	end
	if itemstack:get_name() == "mcl_flowers:wither_rose" and (  minetest.get_item_group(soil_node.name, "grass_block") > 0 or soil_node.name == "mcl_core:dirt" or soil_node.name == "mcl_core:coarse_dirt" or soil_node.name == "mcl_mud:mud" or soil_node.name == "mcl_lush_caves:moss" or soil_node.name == "mcl_nether:netherrack" or minetest.get_item_group(soil_node.name, "soul_block") > 0  ) then
		return true,colorize
	end
	local is_flower = minetest.get_item_group(itemstack:get_name(), "flower") == 1
	local ok = (soil_node.name == "mcl_core:dirt" or minetest.get_item_group(soil_node.name, "grass_block") == 1 or soil_node.name == "mcl_lush_caves:moss" or (not is_flower and (soil_node.name == "mcl_core:coarse_dirt" or soil_node.name == "mcl_core:podzol" or soil_node.name == "mcl_core:podzol_snow"))) and light_ok
	return ok, colorize
end)

function mcl_flowers.register_simple_flower(name, def)
	local newname = "mcl_flowers:"..name
	if not def._mcl_silk_touch_drop then def._mcl_silk_touch_drop = nil end
	if not def.drop then def.drop = newname end
	mcl_flowers.registered_simple_flowers[newname] = {
		name=name,
		desc=def.desc,
		image=def.image,
		simple_selection_box=def.simple_selection_box,
	}
	minetest.register_node(newname, {
		description = def.desc,
		_doc_items_longdesc = smallflowerlongdesc,
		_doc_items_usagehelp = plant_usage_help,
		drawtype = "plantlike",
		waving = 1,
		tiles = { def.image },
		inventory_image = def.image,
		wield_image = def.image,
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		drop = def.drop,
		groups = {
			attached_node = 1, deco_block = 1, dig_by_piston = 1, dig_immediate = 3,
			dig_by_water = 1, destroy_by_lava_flow = 1, enderman_takable = 1,
			plant = 1, flower = 1, place_flowerlike = 1, non_mycelium_plant = 1,
			flammable = 2, fire_encouragement = 60, fire_flammability = 100,
			compostability = 65
		},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		node_placement_prediction = "",
		on_place = on_place_flower,
		selection_box = {
			type = "fixed",
			fixed = def.selection_box,
		},
		_mcl_silk_touch_drop = def._mcl_silk_touch_drop,
		_on_bone_meal = on_bone_meal_simple,
	})
	if def.potted and has_mcl_flowerpots then
		mcl_flowerpots.register_potted_flower(newname, {
			name = name,
			desc = def.desc,
			image = def.image,
		})
	end
end

local wheat_seed_drop = {
	max_items = 1,
	items = {
		{
			items = {"mcl_farming:wheat_seeds"},
			rarity = 8,
		},
	},
}

local fortune_wheat_seed_drop = {
	discrete_uniform_distribution = true,
	items = {"mcl_farming:wheat_seeds"},
	chance = 1 / 8,
	min_count = 1,
	max_count = 1,
	factor = 2,
	overwrite = true,
}

--- Tall Grass ---
local def_tallgrass = {
	description = S("Tall Grass"),
	drawtype = "plantlike",
	_doc_items_longdesc = S("Tall grass is a small plant which often occurs on the surface of grasslands. It can be harvested for wheat seeds. By using bone meal, tall grass can be turned into double tallgrass which is two blocks high."),
	_doc_items_usagehelp = plant_usage_help,
	_doc_items_hidden = false,
	waving = 1,
	tiles = {"mcl_flowers_tallgrass.png"},
	inventory_image = "mcl_flowers_tallgrass_inv.png",
	wield_image = "mcl_flowers_tallgrass_inv.png",
	selection_box = {
		type = "fixed",
		fixed = {{ -6/16, -8/16, -6/16, 6/16, 4/16, 6/16 }},
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
		flammable = 3, fire_encouragement = 60, fire_flammability = 10, dig_by_piston = 1,
		dig_by_water = 1, destroy_by_lava_flow = 1, compostability = 30, grass_palette = 1
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	drop = wheat_seed_drop,
	_mcl_shears_drop = true,
	_mcl_fortune_drop = fortune_wheat_seed_drop,
	node_placement_prediction = "",
	on_place = on_place_flower,
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
	_on_bone_meal = on_bone_meal,
}
minetest.register_node("mcl_flowers:tallgrass", def_tallgrass)

--- Fern ---
-- The fern is very similar to tall grass, so we can copy a lot from it.
local def_fern = table.copy(def_tallgrass)
def_fern.description = S("Fern")
def_fern._doc_items_longdesc = S("Ferns are small plants which occur naturally in jungles and taigas. They can be harvested for wheat seeds. By using bone meal, a fern can be turned into a large fern which is two blocks high.")
def_fern.tiles = { "mcl_flowers_fern.png" }
def_fern.inventory_image = "mcl_flowers_fern_inv.png"
def_fern.wield_image = "mcl_flowers_fern_inv.png"
def_fern.selection_box = {
	type = "fixed",
	fixed = { -6/16, -0.5, -6/16, 6/16, 5/16, 6/16 },
}
def_fern.groups.compostability = 65

minetest.register_node("mcl_flowers:fern", def_fern)

if has_mcl_flowerpots then
	mcl_flowerpots.register_potted_flower("mcl_flowers:fern", {
		name = "fern",
		desc = S("Fern"),
		image = "mcl_flowers_fern_inv.png",
	})
end

local function add_large_plant(name, desc, longdesc, bottom_img, top_img, inv_img, selbox_radius, selbox_top_height, drop, shears_drop, is_flower, grass_color, fortune_drop, mesh)
	if not inv_img then
		inv_img = top_img
	end
	local create_entry, paramtype2, palette
	if is_flower == nil then
		is_flower = true
	end

	local bottom_groups = {
		attached_node = 1, deco_block = 1,
		dig_by_water = 1, destroy_by_lava_flow = 1, dig_by_piston = 1,
		flammable = 2, fire_encouragement = 60, fire_flammability = 100,
		plant = 1, double_plant = 1, non_mycelium_plant = 1, compostability = 65
	}
	if name == "double_grass" then
		bottom_groups.compostability = 50
	end
	if is_flower then
		bottom_groups.flower = 1
		bottom_groups.place_flowerlike = 1
		bottom_groups.dig_immediate = 3
	else
		bottom_groups.place_flowerlike = 2
		bottom_groups.handy = 1
		bottom_groups.shearsy = 1
	end
	if grass_color then
		paramtype2 = "color"
		palette = "mcl_core_palette_grass.png"
	end
	if longdesc == nil then
		bottom_groups.not_in_creative_inventory = 1
		create_entry = false
	end
	-- Drop itself by default
	local drop_bottom, drop_top
	if not drop then
		drop_top = "mcl_flowers:"..name
	else
		drop_top = drop
		drop_bottom = drop
	end
	-- Sunflower mesh and tiles
	local top_drawtype, bottom_drawtype, uta
	local bottom_tiles = {}
	if not mesh then
		top_drawtype = "plantlike"
		bottom_drawtype = "plantlike"
		table.insert(bottom_tiles, bottom_img)
	else
		top_drawtype = "airlike"
		bottom_drawtype = "mesh"
		bottom_tiles = bottom_img
		uta = "clip"
	end
	-- Bottom
	minetest.register_node("mcl_flowers:"..name, {
		description = desc,
		_doc_items_create_entry = create_entry,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = plant_usage_help,
		drawtype = bottom_drawtype,
		tiles = bottom_tiles,
		inventory_image = inv_img,
		wield_image = inv_img,
		use_texture_alpha = uta,
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = paramtype2,
		palette = palette,
		walkable = false,
		buildable_to = false,
		drop = drop_bottom,
		_mcl_shears_drop = shears_drop,
		_mcl_fortune_drop = fortune_drop,
		node_placement_prediction = "",
		selection_box = {
			type = "fixed",
			fixed = { -selbox_radius, -0.5, -selbox_radius, selbox_radius, 0.5, selbox_radius },
		},
		on_place = function(itemstack, placer, pointed_thing)
			-- We can only place on nodes
			if pointed_thing.type ~= "node" then
				return
			end

			local itemstring = "mcl_flowers:"..name

			-- Call on_rightclick if the pointed node defines it
			if placer and not placer:get_player_control().sneak then
				local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
				if rc ~= nil then return rc end --check for nil explicitly to determine if on_rightclick existed
			end

			-- Check for a floor and a space of 1×2×1
			local ptu_node = minetest.get_node(pointed_thing.under)
			local bottom
			if not minetest.registered_nodes[ptu_node.name] then
				return itemstack
			end
			if minetest.registered_nodes[ptu_node.name].buildable_to then
				bottom = pointed_thing.under
			else
				bottom = pointed_thing.above
			end
			if not minetest.registered_nodes[minetest.get_node(bottom).name] then
				return itemstack
			end
			local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
			local bottom_buildable = minetest.registered_nodes[minetest.get_node(bottom).name].buildable_to
			local top_buildable = minetest.registered_nodes[minetest.get_node(top).name].buildable_to
			local floor = minetest.get_node({x=bottom.x, y=bottom.y-1, z=bottom.z})
			if not minetest.registered_nodes[floor.name] then
				return itemstack
			end

			local light_night = minetest.get_node_light(bottom, 0.0)
			local light_day = minetest.get_node_light(bottom, 0.5)
			local light_ok = false
			if (light_night and light_night >= 8) or (light_day and light_day >= minetest.LIGHT_MAX) then
				light_ok = true
			end

			-- Placement rules:
			-- * Allowed on dirt, grass or moss block
			-- * If not a flower, also allowed on podzol and coarse dirt
			-- * Only with light level >= 8
			-- * Only if two enough space
			if (floor.name == "mcl_core:dirt" or minetest.get_item_group(floor.name, "grass_block") == 1 or floor.name == "mcl_lush_caves:moss" or (not is_flower and (floor.name == "mcl_core:coarse_dirt" or floor.name == "mcl_core:podzol" or floor.name == "mcl_core:podzol_snow"))) and bottom_buildable and top_buildable and light_ok then
				local param2
				if grass_color then
					param2 = get_palette_color_from_pos(bottom)
				end
				-- Success! We can now place the flower
				minetest.sound_play(minetest.registered_nodes[itemstring].sounds.place, {pos = bottom, gain=1}, true)
				minetest.set_node(bottom, {name=itemstring, param2=param2})
				minetest.set_node(top, {name=itemstring.."_top", param2=param2})
				if not minetest.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item()
				end
			end
			return itemstack
		end,
		after_destruct = function(pos, oldnode)
			-- Remove top half of flower (if it exists)
			local bottom = pos
			local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
			if minetest.get_node(bottom).name ~= "mcl_flowers:"..name and minetest.get_node(top).name == "mcl_flowers:"..name.."_top" then
				minetest.remove_node(top)
			end
		end,
		groups = bottom_groups,
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_on_bone_meal = on_bone_meal,
		mesh = mesh
	})

	local top_groups = table.copy(bottom_groups)
	top_groups.not_in_creative_inventory=1
	top_groups.double_plant=2
	top_groups.attached_node=nil

	-- Top
	minetest.register_node("mcl_flowers:"..name.."_top", {
		description = desc.." " .. S("(Top Part)"),
		_doc_items_create_entry = false,
		drawtype = top_drawtype,
		tiles = { top_img },
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = paramtype2,
		palette = palette,
		walkable = false,
		buildable_to = false,
		use_texture_alpha = uta,
		selection_box = {
			type = "fixed",
			fixed = { -selbox_radius, -0.5, -selbox_radius, selbox_radius, selbox_top_height, selbox_radius },
		},
		drop = drop_top,
		_mcl_shears_drop = shears_drop,
		_mcl_fortune_drop = fortune_drop,
		after_destruct = function(pos, oldnode)
			-- Remove bottom half of flower (if it exists)
			local top = pos
			local bottom = { x = top.x, y = top.y - 1, z = top.z }
			if minetest.get_node(top).name ~= "mcl_flowers:"..name.."_top" and minetest.get_node(bottom).name == "mcl_flowers:"..name then
				minetest.remove_node(bottom)
			end
		end,
		groups = top_groups,
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_on_bone_meal = on_bone_meal,
	})

	if minetest.get_modpath("doc") and longdesc then
		doc.add_entry_alias("nodes", "mcl_flowers:"..name, "nodes", "mcl_flowers:"..name.."_top")
		-- If no longdesc, help alias must be added manually
	end

end

add_large_plant("peony", S("Peony"), S("A peony is a large plant which occupies two blocks. It is mainly used in dye production."), "mcl_flowers_double_plant_paeonia_bottom.png", "mcl_flowers_double_plant_paeonia_top.png", nil, 5/16, 6/16)
add_large_plant("rose_bush", S("Rose Bush"), S("A rose bush is a large plant which occupies two blocks. It is safe to touch it. Rose bushes are mainly used in dye production."), "mcl_flowers_double_plant_rose_bottom.png", "mcl_flowers_double_plant_rose_top.png", nil, 5/16, 1/16)
add_large_plant("lilac", S("Lilac"), S("A lilac is a large plant which occupies two blocks. It is mainly used in dye production."), "mcl_flowers_double_plant_syringa_bottom.png", "mcl_flowers_double_plant_syringa_top.png", nil, 5/16, 6/16)
add_large_plant("sunflower", S("Sunflower"), S("A sunflower is a large plant which occupies two blocks. It is mainly used in dye production."), {"mcl_flowers_double_plant_sunflower_bottom.png", "mcl_flowers_double_plant_sunflower_bottom.png", "mcl_flowers_double_plant_sunflower_front.png", "mcl_flowers_double_plant_sunflower_back.png"}, nil, "mcl_flowers_double_plant_sunflower_front.png", 6/16, 6/16, "mcl_flowers:sunflower", nil, true, nil, nil, "mcl_flowers_sunflower.obj")

local longdesc_grass = S("Double tallgrass a variant of tall grass and occupies two blocks. It can be harvested for wheat seeds.")
local longdesc_fern = S("Large fern is a variant of fern and occupies two blocks. It can be harvested for wheat seeds.")

add_large_plant("double_grass", S("Double Tallgrass"), longdesc_grass, "mcl_flowers_double_plant_grass_bottom.png", "mcl_flowers_double_plant_grass_top.png", "mcl_flowers_double_plant_grass_inv.png", 6/16, 4/16, wheat_seed_drop, {"mcl_flowers:tallgrass 2"}, false, true, fortune_wheat_seed_drop)
add_large_plant("double_fern", S("Large Fern"), longdesc_fern, "mcl_flowers_double_plant_fern_bottom.png", "mcl_flowers_double_plant_fern_top.png", "mcl_flowers_double_plant_fern_inv.png", 5/16, 5/16, wheat_seed_drop, {"mcl_flowers:fern 2"}, false, true, fortune_wheat_seed_drop)

minetest.register_abm({
	label = "Pop out flowers",
	nodenames = {"group:flower"},
	interval = 12,
	chance = 2,
	action = function(pos, node)
		-- Ignore the upper part of double plants
		if minetest.get_item_group(node.name, "double_plant") == 2 then
			return
		end
		local below = minetest.get_node_or_nil({x=pos.x, y=pos.y-1, z=pos.z})
		if not below then
			return
		end
		-- Pop out flower if not on dirt, grass block or too low brightness
		if (below.name ~= "mcl_core:dirt" and minetest.get_item_group(below.name, "grass_block") ~= 1 and below.name ~= "mcl_lush_caves:moss") or (minetest.get_node_light(pos, 0.5) < 8) then
			minetest.dig_node(pos)
			return
		end
	end,
})

local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_simple
end

-- Lily Pad
minetest.register_node("mcl_flowers:waterlily", {
	description = S("Lily Pad"),
	_doc_items_longdesc = S("A lily pad is a flat plant block which can be walked on. They can be placed on water sources, ice and frosted ice."),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"flowers_waterlily.png", "flowers_waterlily.png^[transformFY"},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
	inventory_image = "flowers_waterlily.png",
	wield_image = "flowers_waterlily.png",
	liquids_pointable = true,
	walkable = true,
	sunlight_propagates = true,
	groups = {
		deco_block = 1, plant = 1, compostability = 65, destroy_by_lava_flow = 1,
		dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1, dig_by_boat = 1,
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
		local node = minetest.get_node(pointed_thing.under)
		local nodename = node.name
		local def = minetest.registered_nodes[nodename]
		local node_above = minetest.get_node(pointed_thing.above).name
		local def_above = minetest.registered_nodes[node_above]
		local player_name = placer:get_player_name()

		if def then
			if (pointed_thing.under.x == pointed_thing.above.x and pointed_thing.under.z == pointed_thing.above.z) and
					((def.liquidtype == "source" and minetest.get_item_group(nodename, "water") > 0) or
					(nodename == "mcl_core:ice") or
					(minetest.get_item_group(nodename, "frosted_ice") > 0)) and
					(def_above.buildable_to and minetest.get_item_group(node_above, "liquid") == 0) then
				if not minetest.is_protected(pos, player_name) then
					minetest.set_node(pos, {name = "mcl_flowers:waterlily", param2 = math.random(0, 3)})
					local idef = itemstack:get_definition()

					if idef.sounds and idef.sounds.place then
						minetest.sound_play(idef.sounds.place, {pos=pointed_thing.above, gain=1}, true)
					end

					if not minetest.is_creative_enabled(player_name) then
						itemstack:take_item()
					end
				else
					minetest.record_protection_violation(pos, player_name)
				end
			end
		end
		return itemstack
	end,
	on_rotate = on_rotate,
})

-- Legacy support
minetest.register_alias("mcl_core:tallgrass", "mcl_flowers:tallgrass")

-- mcimport support: re-adds missing double_plant tops in mcimported worlds.
local mg_name = minetest.get_mapgen_setting("mg_name")
local mod_mcimport = minetest.get_modpath("mcimport")

if mod_mcimport and mg_name == "singlenode" then
	local flowernames = { "peony", "rose_bush", "lilac", "sunflower", "double_fern", "double_grass" }

	minetest.register_lbm({
		label = "Add double plant tops.",
		name = "mcl_flowers:double_plant_topper",
		run_at_every_load = true,
		nodenames = { "mcl_flowers:peony", "mcl_flowers:rose_bush", "mcl_flowers:lilac", "mcl_flowers:sunflower", "mcl_flowers:double_fern", "mcl_flowers:double_grass" },
		action = function(pos, node)
			for c = 1, 6 do
				local flowername = flowernames[c]
				local bottom = pos
				local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
				if node.name == "mcl_flowers:"..flowername then
					minetest.set_node(top, {name = "mcl_flowers:"..flowername.."_top"})
				end
			end
		end,
	})
end

dofile(modpath.."/register.lua")
