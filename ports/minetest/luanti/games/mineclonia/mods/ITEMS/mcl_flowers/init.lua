local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)

mcl_flowers = {}
mcl_flowers.registered_simple_flowers = {}
-- Simple flower template
local smallflowerlongdesc = S("This is a small flower. Small flowers are mainly used for dye production and can also be potted.")
mcl_flowers.plant_usage_help = S("It can only be placed on a block on which it would also survive.")

function mcl_flowers.on_bone_meal(_, _, _ , pos, n)
	local neighbours = {
		vector.offset(pos, -1, -1, 0),
		vector.offset(pos, 1, -1, 0),
		vector.offset(pos, 0, -1, -1),
		vector.offset(pos, 0, -1, 1)
	}
	table.shuffle(neighbours)
	for i = 1, #neighbours do
		local under_neighbor = core.get_node(neighbours[i]).name
		local new_pos = vector.offset(neighbours[i], 0, 1, 0)
		local neighbor = core.get_node(new_pos).name
		if neighbor == "air" then
			if n.name == "mcl_flowers:bush" then
				if core.get_item_group(under_neighbor, "soil_generic_plant") > 0 then
					core.set_node(new_pos, {name = "mcl_flowers:bush", param2 = mcl_util.get_pos_p2(pos)})
					return true
				end
			elseif n.name == "mcl_flowers:tall_dry_grass" then
				if core.get_item_group(under_neighbor, "soil_generic_plant") > 0
				or core.get_item_group(under_neighbor, "hardened_clay") > 0
				or core.get_item_group(under_neighbor, "sand") > 0 then
					core.set_node(new_pos, {name = "mcl_flowers:short_dry_grass"})
					return true
				end
			elseif n.name == "mcl_flowers:firefly_bush" then
				if core.get_item_group(under_neighbor, "soil_generic_plant") > 0 then
					core.set_node(new_pos, {name = "mcl_flowers:firefly_bush"})
					return true
				end
			end
		end
	end
	return false
end

local scan_area = 3
local scan_y = 2
local spawn_on = {"group:grass_block"}
local spawn_chance = 20 -- percentile

function mcl_flowers.bone_meal_simple_flower(_, _, _, pos, n)
	local nn = core.find_nodes_in_area_under_air(
		vector.offset(pos, -scan_area, -scan_y, -scan_area),
		vector.offset(pos, scan_area, scan_y, scan_area),
		spawn_on
	)
	local flower_placed = false
	for _, pos in pairs(nn) do
		if math.random(100) <= spawn_chance then
			core.set_node(vector.offset(pos, 0, 1, 0), {name = n.name})
			flower_placed = true
		end
	end
	return flower_placed
end

function mcl_flowers.get_palette_color_from_pos(pos)
	return mcl_util.get_pos_p2 (pos)
end

-- on_place function for flowers
mcl_flowers.on_place_flower = mcl_util.generate_on_place_plant_function(function(pos, _, itemstack)
	local below = {x=pos.x, y=pos.y-1, z=pos.z}
	local soil_node = core.get_node_or_nil(below)
	if not soil_node then return false end

	local has_palette = core.registered_nodes[itemstack:get_name()].palette ~= nil
	local colorize
	if has_palette then
		colorize = mcl_flowers.get_palette_color_from_pos(pos)
	end
	if not colorize then
		colorize = 0
	end

--[[	Placement requirements:
	* Dirt, grass or moss block
	* If not flower, also allowed on podzol and coarse dirt
	* Light level >= 8 at any time or exposed to sunlight at day
]]
	local light_night = core.get_node_light(pos, 0.0)
	local light_day = core.get_node_light(pos, 0.5)
	local light_ok = false
	if (light_night and light_night >= 8) or (light_day and light_day >= core.LIGHT_MAX) then
		light_ok = true
	end
	if itemstack:get_name() == "mcl_flowers:wither_rose"
		and (
			core.get_item_group(soil_node.name, "soil_generic_plant") > 0
			or soil_node.name == "mcl_nether:netherrack"
			or core.get_item_group(soil_node.name, "soul_block") > 0
		) then
		return true,colorize
	end
	local ok = core.get_item_group(soil_node.name, "soil_flower") > 0 and light_ok
	return ok, colorize
end)

function mcl_flowers.register_simple_flower(flowername, def, node_defs)
	local nodename = "mcl_flowers:"..flowername
	local groups = {
		attached_node = 1, deco_block = 1, dig_by_piston = 1, dig_immediate = 3,
		dig_by_water = 1, destroy_by_lava_flow = 1, enderman_takable = 1,
		plant = 1, flower = 1, place_flowerlike = 1, non_mycelium_plant = 1,
		flammable = 2, fire_encouragement = 60, fire_flammability = 100,
		compostability = 65, unsticky = 1,
	}
	if def.sus_stew then
		groups.sus_stew_ingredient = 1
	end
	mcl_flowers.registered_simple_flowers[nodename] = {
		name=flowername,
		desc=def.desc,
		image=def.image,
	}
	core.register_node(":"..nodename, table.merge({
		description = def.desc,
		_doc_items_longdesc = smallflowerlongdesc,
		_doc_items_usagehelp = mcl_flowers.plant_usage_help,
		drawtype = "plantlike",
		waving = 1,
		tiles = { def.image },
		inventory_image = def.image,
		wield_image = def.image,
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		groups = groups,
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		node_placement_prediction = "",
		on_place = mcl_flowers.on_place_flower,
		selection_box = {
			type = "fixed",
			fixed = def.selection_box,
		},
	}, node_defs or {}))
	if def.potted then
		mcl_flowerpots.register_potted_flower(nodename, {
			name = flowername,
			desc = def.desc,
			image = def.image,
		})
	end
	if def.sus_stew then
		mcl_sus_stew.register_sus_stew(nodename, def.sus_stew.effect, def.sus_stew.duration)
	end
end

function mcl_flowers.register_ground_flower(flowername, def, add_def)
	local nodename = "mcl_flowers:"..flowername
	core.register_craftitem(":"..nodename, table.merge({
	description = def.desc,
	_doc_items_longdesc = def.longdesc,
	inventory_image = def.image,
	wield_image = def.image,
	groups = {
			craftitem = 1,
			attached_node = 1, deco_block = 1, dig_by_piston = 1, dig_immediate = 3,
			dig_by_water = 1, destroy_by_lava_flow = 1, enderman_takable = 1,
			plant = 1, flower = 1, place_flowerlike = 1, non_mycelium_plant = 1,
			flammable = 3, fire_encouragement = 60, fire_flammability = 100,
			compostability = 30, unsticky = 1
		},

	on_place = function(itemstack, placer, pointed_thing)
			local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
			if rc then return rc end

			local pos = pointed_thing.under
			local node = core.get_node(pos)
			local above_pos = {x=pos.x, y=pos.y+1, z=pos.z}
			local above_node = core.get_node(above_pos)
			local wildflower_group = core.get_item_group(node.name, "wildflower")
			local creative = mcl_util.is_creative(placer)

			-- Swap the node in place if it's part of the progression
			local swap_map = {
				[nodename.."_1"] = nodename.."_2",
				[nodename.."_2"] = nodename.."_3",
				[nodename.."_3"] = nodename.."_4",
			}

			if swap_map[node.name] then
				if not creative then itemstack:take_item(1) end
				core.set_node(pos, {name = swap_map[node.name]})
			else
				local max_cycle = wildflower_group > 0 and wildflower_group < 5
				-- If not already part of the cycle, place _1 above
				if above_node.name == "air" and not max_cycle and (core.get_item_group(node.name, "soil_generic_plant") > 0 or def.placeable_on_anything) then
					if not creative then itemstack:take_item(1) end
					core.set_node(above_pos, {name = nodename.."_1"})
				end
			end

			return itemstack
		end,
	}, add_def or {}))

	local mesh_prefix = "mcl_flowers_wildflower_"
	if def.mesh_prefix then
		mesh_prefix = def.mesh_prefix
	end

	for i = 1,4 do
		core.register_node(":"..nodename.."_"..i, table.merge({
			description = def.desc,
			_doc_items_create_entry = false,
			drawtype = "mesh",
			mesh = mesh_prefix..i..".obj",
			tiles = def.tiles,
			use_texture_alpha = "clip",
			paramtype = "light",
			paramtype2 = def.paramtype2 or "facedir",
			sunlight_propagates = true,
			walkable = false,
			selection_box = {type = "fixed", fixed = {-1/2, -1/2, -1/2, 1/2, -5/16, 1/2}},
			stack_max = 64,
			groups = {
				attached_node = 1, deco_block = 1, dig_by_piston = 1, dig_immediate = 3,
				dig_by_water = 1, destroy_by_lava_flow = 1, enderman_takable = 1,
				plant = 1, flower = 1, wildflower=i, place_flowerlike = 1, non_mycelium_plant = 1,
				flammable = 3, fire_encouragement = 60, fire_flammability = 100,
				compostability = 30, unsticky = 1,
				not_in_creative_inventory = 1,
				not_in_craft_guide = 1
			},
			sounds = mcl_sounds.node_sound_leaves_defaults(),
			drop = nodename.." "..i,
			node_placement_prediction = "",
			_on_bone_meal = mcl_flowers.bone_meal_simple_flower,
		}, add_def or {}))
	end
end

local tpl_large_plant_top = {
	drawtype = "plantlike",
	_doc_items_create_entry = true,
	_doc_items_usagehelp = mcl_flowers.plant_usage_help,
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_on_bone_meal = mcl_flowers.on_bone_meal,
}

local tpl_large_plant_bottom = table.merge(tpl_large_plant_top, {
	groups = {
		compostability = 65, deco_block = 1, dig_by_water = 1, destroy_by_lava_flow = 1,
		dig_by_piston = 1, flammable = 2, fire_encouragement = 60, fire_flammability = 100,
		plant = 1, double_plant = 1, non_mycelium_plant = 1, flower = 1, supported_node = 1
	},
	on_place = function(itemstack, placer, pointed_thing)
		-- We can only place on nodes
		if pointed_thing.type ~= "node" then
			return
		end

		local itemstring = itemstack:get_name()

		-- Call on_rightclick if the pointed node defines it
		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc ~= nil then return rc end --check for nil explicitly to determine if on_rightclick existed

		-- Check for a floor and a space of 1×2×1
		local ptu_node = core.get_node(pointed_thing.under)
		local bottom
		if not core.registered_nodes[ptu_node.name] then
			return itemstack
		end
		if core.registered_nodes[ptu_node.name].buildable_to then
			bottom = pointed_thing.under
		else
			bottom = pointed_thing.above
		end
		if not core.registered_nodes[core.get_node(bottom).name] then
			return itemstack
		end
		local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
		local bottom_buildable = core.registered_nodes[core.get_node(bottom).name].buildable_to
		local top_buildable = core.registered_nodes[core.get_node(top).name].buildable_to
		local floor = core.get_node({x=bottom.x, y=bottom.y-1, z=bottom.z})
		if not core.registered_nodes[floor.name] then
			return itemstack
		end

		local light_night = core.get_node_light(bottom, 0.0)
		local light_day = core.get_node_light(bottom, 0.5)
		local light_ok = false
		if (light_night and light_night >= 8) or (light_day and light_day >= core.LIGHT_MAX) then
			light_ok = true
		end

		-- Placement rules:
		-- * Allowed on dirt, grass or moss block
		-- * If not a flower, also allowed on podzol and coarse dirt
		-- * Only with light level >= 8
		-- * Only if two enough space
		if core.get_item_group(floor.name, "soil_flower") > 0 and bottom_buildable and top_buildable and light_ok then
			local param2
			local def = core.registered_nodes[floor.name]
			if def and def.paramtype2 == "color" then
				param2 = mcl_flowers.get_palette_color_from_pos(bottom)
			end
			-- Success! We can now place the flower
			core.sound_play(core.registered_nodes[itemstring].sounds.place, {pos = bottom, gain=1}, true)
			core.set_node(bottom, {name=itemstring, param2=param2})
			core.set_node(top, {name=itemstring.."_top", param2=param2})
			if not mcl_util.is_creative(placer) then
				itemstack:take_item()
			end
		end
		return itemstack
	end,
	after_destruct = function(pos, oldnode)
		-- Remove top half of flower (if it exists)
		local bottom = pos
		local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
		if core.get_node(bottom).name ~= oldnode.name and core.get_node(top).name == oldnode.name.."_top" then
			core.remove_node(top)
		end
	end,
})

function mcl_flowers.add_large_plant(plantname, def)
	local nodename = "mcl_flowers:"..plantname
	def.bottom =  def.bottom or {}
	def.bottom.groups = table.merge(tpl_large_plant_bottom.groups, def.bottom.groups or {})
	def.top = def.top or {}
	def.top.groups = def.top.groups or {}

	if def.is_flower then
		table.update(def.bottom.groups, { flower = 1, place_flowerlike = 1, dig_immediate = 3 })
	else
		table.update(def.bottom.groups, { place_flowerlike = 2, handy = 1, shearsy = 1 })
	end

	table.update(def.top.groups, { not_in_creative_inventory=1, handy = 1, shearsy = 1, double_plant=2, supported_node = 1})

	if def.grass_color then
		def.bottom.paramtype2 = "color"
		def.top.paramtype2 = "color"
		def.bottom.palette = "mcl_core_palette_grass.png"
		def.top.palette = "mcl_core_palette_grass.png"
	end

	if def.bottom._doc_items_longdesc == nil and def.longdesc == nil then
		def.bottom.groups.not_in_creative_inventory = 1
		def.bottom._doc_items_create_entry = false
	end

	local selbox_radius = def.selbox_radius or 0.5
	local selbox_top_height = def.selbox_top_height or 0.5
	local inv_img = def.inv_img or def.bottom.inventory_image or (def.tiles_top and def.tiles_top[1]) or (def.top.tiles and def.top.tiles[1])
	-- Bottom
	core.register_node(":"..nodename, table.merge(tpl_large_plant_bottom,{
		description = def.desc,
		_doc_items_longdesc = def.longdesc,
		tiles = def.tiles_bottom,
		node_placement_prediction = "",
		inventory_image = inv_img,
		wield_image = inv_img,
		drop = nodename,
		selection_box = {
			type = "fixed",
			fixed = { -selbox_radius, -0.5, -selbox_radius, selbox_radius, 0.5, selbox_radius },
		},
        _on_bone_meal = def._on_bone_meal,
	}, def.bottom or {}))

	-- Top
	core.register_node(":"..nodename.."_top", table.merge(tpl_large_plant_top, {
		description = S("@1 (Top Part)", def.desc or def.bottom.description or plantname),
		_doc_items_create_entry = false,
		selection_box = {
			type = "fixed",
			fixed = { -selbox_radius, -0.5, -selbox_radius, selbox_radius, selbox_top_height, selbox_radius },
		},
		tiles = def.tiles_top,
		drop = def.bottom.drop or nodename,
		_mcl_shears_drop = def.bottom._mcl_shears_drop,
		_mcl_fortune_drop = def.bottom._mcl_fortune_drop,
		_mcl_baseitem = nodename,
		after_destruct = function(pos, _)
			-- Remove bottom half of flower (if it exists)
			local top = pos
			local bottom = { x = top.x, y = top.y - 1, z = top.z }
			if core.get_node(top).name ~= nodename.."_top" and core.get_node(bottom).name == nodename then
				core.remove_node(bottom)
			end
		end,
        _on_bone_meal = def.bottom._on_bone_meal,
	}, def.top))

	if def.bottom._doc_items_longdesc then
		doc.add_entry_alias("nodes", nodename, "nodes", nodename.."_top")
		-- If no longdesc, help alias must be added manually
	end

end

core.register_abm({
	label = "Pop out flowers",
	nodenames = {"group:flower"},
	interval = 12,
	chance = 2,
	action = function(pos, node)
		-- Ignore the upper part of double plants
		if core.get_item_group(node.name, "double_plant") == 2 then
			return
		end
		local below = core.get_node_or_nil({x=pos.x, y=pos.y-1, z=pos.z})
		if not below then
			return
		end
		-- Pop out flower if not on dirt, or grass block.
		if core.get_item_group(below.name, "soil_flower") == 0 then
			core.dig_node(pos)
			return
		end
	end,
})

local PARTICLE_DISTANCE = 25
core.register_abm({
	label = "Firefly Bush Particles",
	nodenames = {"mcl_flowers:firefly_bush"},
	interval = 25,
	chance = 2,
	action = function(pos)
		if core.get_node_light(pos) > 13 then return end

		for pl in mcl_util.connected_players(pos, PARTICLE_DISTANCE) do
			core.add_particlespawner({
				texture = "[fill:1x1:0,0:#FAFAF2",
				amount = 32,
				time = 25,
				jitter = {
					min = vector.new(0.5, 0.5, 0.5),
					max = vector.new(-0.5, -0.5, -0.5)
				},
				minexptime = 1.5,
				maxexptime = 8.5,
				minsize = 0.2,
				maxsize= 0.6,
				glow = 15,
				collisiondetection = true,
				collision_removal = true,
				minpos = vector.offset(pos, -5, -5, -5),
				maxpos = vector.offset(pos, 5, 5, 5),
				playername = pl:get_player_name(),
			})
		end
	end
})

-- Legacy support
core.register_alias("mcl_core:tallgrass", "mcl_flowers:tallgrass")

dofile(modpath.."/register.lua")

mcl_levelgen.register_levelgen_script (modpath .. "/lg_register.lua")
