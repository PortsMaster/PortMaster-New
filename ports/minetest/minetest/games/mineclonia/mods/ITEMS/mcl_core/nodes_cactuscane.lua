-- Cactus and Sugar Cane

local S = core.get_translator(core.get_current_modname())

core.register_node("mcl_core:cactus", {
	description = S("Cactus"),
	_tt_help = S("Grows on sand").."\n"..core.colorize(mcl_colors.YELLOW, S("Contact damage: @1 per half second", 1)),
	_doc_items_longdesc = S("This is a piece of cactus commonly found in dry areas, especially deserts. Over time, cacti will grow up to 3 blocks high on sand or red sand. A cactus hurts living beings touching it with a damage of 1 HP every half second. When a cactus block is broken, all cactus blocks connected above it will break as well."),
	_doc_items_usagehelp = S("A cactus can only be placed on top of another cactus or any sand."),
	drawtype = "nodebox",
	use_texture_alpha = "clip",
	tiles = {"mcl_core_cactus_top.png", "mcl_core_cactus_bottom.png", "mcl_core_cactus_side.png"},
	groups = {
		handy = 1, attached_node = 1, deco_block = 1, dig_by_piston = 1,
		plant = 1, enderman_takable = 1, compostability = 50, unsticky = 1
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	node_placement_prediction = "",
	node_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16,  7/16, 8/16,  7/16}, -- Main body
			{-8/16, -8/16, -7/16,  8/16, 8/16, -7/16}, -- Spikes
			{-8/16, -8/16,  7/16,  8/16, 8/16,  7/16}, -- Spikes
			{-7/16, -8/16, -8/16, -7/16, 8/16,  8/16}, -- Spikes
			{7/16,  -8/16,  8/16,  7/16, 8/16, -8/16}, -- Spikes
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {-7/16, -8/16, -7/16,  7/16, 7/16,  7/16}, -- Main body. slightly lower than node box
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16, 7/16, 8/16, 7/16},
		},
	},
	-- Only allow to place cactus on sand or cactus
	on_place = mcl_util.generate_on_place_plant_function(function(pos)
		local node_below = core.get_node_or_nil({x=pos.x,y=pos.y-1,z=pos.z})
		if not node_below then return false end
		return (node_below.name == "mcl_core:cactus" or core.get_item_group(node_below.name, "sand") == 1)
	end),
	_mcl_hardness = 0.4,
	_mcl_cooking_output = "mcl_dyes:green",
	_pathfinding_class = "DAMAGE_OTHER",
})

mcl_flowerpots.register_potted_cube("mcl_core:cactus", {
	name = "cactus",
	desc = S("Cactus"),
	image = "mcl_flowerpots_cactus.png",
})

mcl_player.register_globalstep_slow(function(player)
	-- Am I near a cactus?
	local pos = player:get_pos()
	local a = vector.offset(pos,-1,0,-1)
	local b = vector.offset(pos,1,0,1)
	local nearby = core.find_nodes_in_area(a, b, {"mcl_core:cactus"})
	for _,near in pairs(nearby) do
		-- Am I touching the cactus? If so, it hurts
		local dist = vector.distance(pos, near)
		if dist < 1 then
			if player:get_hp() > 0 then
				mcl_util.deal_damage(player, 1, {type = "cactus"})
			end
		end
	end
end)

core.register_node("mcl_core:cactus_flower",
{
	description = S("Cactus Flower"),
	_tt_help = S("Grows on cacti"),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype = "plantlike",
	tiles = {"cactus_flower.png"},
	inventory_image = "cactus_flower.png",
	wield_image = "cactus_flower.png",
	groups = {
			dig_immediate = 3, deco_block = 1, dig_by_piston = 1, plant = 1, flammable = 3,
			fire_encouragement = 60, fire_flammability = 100, non_mycelium_plant = 1,
			compostability = 30, unsticky = 1, attached_node = 1
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0, 0.25}
	},
	_mcl_hardness = 0,
	_mcl_blast_resistance = 0,
	_mcl_crafting_output = {single = {output = "mcl_dyes:pink"}}
})

core.register_node("mcl_core:reeds", {
	description = S("Sugar Canes"),
	_tt_help = S("Grows on sand or dirt next to water"),
	_doc_items_longdesc = S("Sugar canes are a plant which has some uses in crafting. Sugar canes will slowly grow up to 3 blocks when they are next to water and are placed on a grass block, dirt, sand, red sand, podzol or coarse dirt. When a sugar cane is broken, all sugar canes connected above will break as well."),
	_doc_items_usagehelp = S("Sugar canes can only be placed top of other sugar canes and on top of blocks on which they would grow."),
	drawtype = "plantlike",
	paramtype2 = "color",
	tiles = {"mcl_core_papyrus.png"},
	palette = "mcl_core_palette_grass.png",
	palette_index = 0,
	inventory_image = "mcl_core_reeds.png",
	wield_image = "mcl_core_reeds.png",
	paramtype = "light",
	walkable = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16,  7/16, 8/16,  7/16}, -- Main Body
			{-8/16, -8/16, -7/16,  8/16, 8/16, -7/16}, -- Spikes
			{-8/16, -8/16,  7/16,  8/16, 8/16,  7/16}, -- Spikes
			{-7/16, -8/16, -8/16, -7/16, 8/16,  8/16}, -- Spikes
			{7/16,  -8/16,  8/16,  7/16, 8/16, -8/16}, -- Spikes
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-6/16, -8/16, -6/16, 6/16, 8/16, 6/16},
		},
	},
	groups = {
		dig_immediate = 3, craftitem = 1, deco_block = 1, dig_by_piston = 1,
		plant = 1, non_mycelium_plant = 1, compostability = 50, biomecolor = 1,
		vinelike_node = 1, unsticky = 1
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	drop = "mcl_core:reeds", -- to prevent color inheritation
	on_place = mcl_util.generate_on_place_plant_function(function(place_pos, _)
		local soil_pos = {x=place_pos.x, y=place_pos.y-1, z=place_pos.z}
		local soil_node = core.get_node_or_nil(soil_pos)
		if not soil_node then return false end
		local snn = soil_node.name -- soil node name

		-- Placement rules:
		-- * On top of group:soil_sugarcane AND next to water or frosted ice. OR
		-- * On top of sugar canes
		-- * Not inside liquid
		if snn == "mcl_core:reeds" then
			return true
		elseif core.get_item_group(snn, "soil_sugarcane") == 0 then
			return false
		end
		local place_node = core.get_node(place_pos)
		local pdef = core.registered_nodes[place_node.name]
		if pdef and pdef.liquidtype ~= "none" then
			return false
		end

		-- Legal water position rules are the same as for decoration spawn_by rules.
		-- This differs from MC, which does not allow diagonal neighbors
		-- and neighbors 1 layer above.
		local np1 = {x=soil_pos.x-1, y=soil_pos.y, z=soil_pos.z-1}
		local np2 = {x=soil_pos.x+1, y=soil_pos.y+1, z=soil_pos.z+1}
		if #core.find_nodes_in_area(np1, np2, {"group:water", "group:frosted_ice"}) > 0 then
			-- Water found! Sugar canes are happy! :-)
			return true
		end

		-- No water found! Sugar canes are not amuzed and refuses to be placed. :-(
		return false

	end),
	on_construct = function(pos)
		local node = core.get_node(pos)
		if node.param2 == 0 then
			node.param2 = mcl_core.get_grass_palette_index(pos)
			if node.param2 ~= 0 then
				core.set_node(pos, node)
			end
		end
	end,
	_on_bone_meal = function(_, _, _, pos, _)
		return mcl_core.grow_reeds(pos, 2)
	end,
	_mcl_hardness = 0,
	_mcl_crafting_output = {
		single = {output = "mcl_core:sugar"},
		line_wide3 = {output = "mcl_core:paper 3"}
	}
})
