local S = minetest.get_translator(minetest.get_current_modname())

local on_place = mcl_util.generate_on_place_plant_function(function(place_pos, place_node)
	local soil_node = minetest.get_node_or_nil({x=place_pos.x, y=place_pos.y-1, z=place_pos.z})
	if not soil_node then return false end
	local snn = soil_node.name -- soil node name

	-- Placement rules:
	-- * Always allowed on podzol or mycelimu
	-- * Otherwise, must be solid, opaque and have daylight light level <= 12
	local light = minetest.get_node_light(place_pos, 0.5)
	local light_ok = false
	if light and light <= 12 then
		light_ok = true
	end
	return ((snn == "mcl_core:podzol" or snn == "mcl_core:podzol_snow" or snn == "mcl_core:mycelium" or snn == "mcl_core:mycelium_snow") or (light_ok and minetest.get_item_group(snn, "solid") == 1 and minetest.get_item_group(snn, "opaque") == 1))
end)

local longdesc_intro_brown = S("Brown mushrooms are fungi which grow and spread in darkness, but are sensitive to light. They are inedible as such, but they can be used to craft food items.")
local longdesc_intro_red = S("Red mushrooms are fungi which grow and spread in darkness, but are sensitive to light. They are inedible as such, but they can be used to craft food items.")

local longdesc_append = S("A single mushroom of this species will slowly spread over time towards a random solid opaque block with a light level of 12 or lower in a 3×3×3 cube around the mushroom. It stops spreading when there are 5 or more mushrooms of the same species within an area of 9×3×9 blocks around the mushroom.").."\n"..
S("Mushrooms will eventually uproot at a light level of 12 or higher. On mycelium or podzol, they survive and spread at any light level.")

local tt_help = S("Grows on podzol, mycelium and other blocks").."\n"..S("Spreads in darkness")

local usagehelp = S("This mushroom can be placed on mycelium and podzol at any light level. It can also be placed on blocks which are both solid and opaque, as long as the light level at daytime is not higher than 12.")

local function on_bone_meal(itemstack,placer,pointed_thing,pos,n)
	if math.random(1, 100) > 40 then return false end --40% chance

	local bn = minetest.get_node(vector.offset(pos,0,-1,0)).name
	if bn ~= "mcl_core:mycelium" and bn ~= "mcl_core:dirt" and minetest.get_item_group(bn, "grass_block") ~= 1 and bn ~= "mcl_core:coarse_dirt" and bn ~= "mcl_core:podzol" then
		return false
	end

	-- Select schematic
	local schematic, offset, height
	height = 8
	if n.name == "mcl_mushrooms:mushroom_brown" then
		schematic = minetest.get_modpath("mcl_mushrooms").."/schematics/mcl_mushrooms_huge_brown.mts"
		offset = vector.new(-3,-1,-3)
	elseif n.name == "mcl_mushrooms:mushroom_red" then
		schematic = minetest.get_modpath("mcl_mushrooms").."/schematics/mcl_mushrooms_huge_red.mts"
		offset = vector.new(-2,-1,-2)
	else
		return false
	end
	-- Check space requirements
	for i=1,3 do
		local cpos = vector.add(pos, {x=0, y=i, z=0})
		if minetest.get_node(cpos).name ~= "air" then
			return false
		end
	end
	local yoff = 3
	local minp, maxp = vector.offset(pos,-3,yoff,-3), vector.offset(pos,3,yoff+(height-3),3)
	local diff = vector.subtract(maxp, minp)
	diff = vector.add(diff, vector.new(1,1,1))
	local totalnodes = diff.x * diff.y * diff.z
	local goodnodes = minetest.find_nodes_in_area(minp, maxp, {"air", "group:leaves"})
	if #goodnodes < totalnodes then
		return false
	end

	-- Place the huge mushroom
	minetest.remove_node(pos)
	local place_pos = vector.add(pos, offset)
	local ok = minetest.place_schematic(place_pos, schematic, 0, nil, false)
	return ok ~= nil
end

minetest.register_node("mcl_mushrooms:mushroom_brown", {
	description = S("Brown Mushroom"),
	_doc_items_longdesc = longdesc_intro_brown .. "\n\n" .. longdesc_append,
	_doc_items_usagehelp = usagehelp,
	_tt_help = tt_help,
	drawtype = "plantlike",
	tiles = { "farming_mushroom_brown.png" },
	inventory_image = "farming_mushroom_brown.png",
	wield_image = "farming_mushroom_brown.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {
		attached_node = 1, deco_block = 1, destroy_by_lava_flow = 1,
		dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1,
		mushroom = 1, enderman_takable = 1, compostability = 65
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	light_source = 1,
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, -2/16, 3/16 },
	},
	node_placement_prediction = "",
	on_place = on_place,
	_on_bone_meal = on_bone_meal,
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_mushrooms:mushroom_red", {
	description = S("Red Mushroom"),
	_doc_items_longdesc = longdesc_intro_red .. "\n\n" .. longdesc_append,
	_doc_items_usagehelp = usagehelp,
	_tt_help = tt_help,
	drawtype = "plantlike",
	tiles = { "farming_mushroom_red.png" },
	inventory_image = "farming_mushroom_red.png",
	wield_image = "farming_mushroom_red.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {
		attached_node = 1, deco_block = 1, destroy_by_lava_flow = 1,
		dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1,
		mushroom = 1, enderman_takable = 1, compostability = 65
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, -2/16, 3/16 },
	},
	node_placement_prediction = "",
	on_place = on_place,
	_on_bone_meal = on_bone_meal,
	_mcl_blast_resistance = 0,
})

mcl_flowerpots.register_potted_flower("mcl_mushrooms:mushroom_brown", {
	name = "mushroom_brown",
	desc = S("Brown Mushroom"),
	image = "farming_mushroom_brown.png",
})

mcl_flowerpots.register_potted_flower("mcl_mushrooms:mushroom_red", {
	name = "mushroom_red",
	desc = S("Red Mushroom"),
	image = "farming_mushroom_red.png",
})

minetest.register_craftitem("mcl_mushrooms:mushroom_stew", {
	description = S("Mushroom Stew"),
	_doc_items_longdesc = S("Mushroom stew is a healthy soup which can be consumed to restore some hunger points."),
	inventory_image = "farming_mushroom_stew.png",
	on_place = minetest.item_eat(6, "mcl_core:bowl"),
	on_secondary_use = minetest.item_eat(6, "mcl_core:bowl"),
	groups = { food = 3, eatable = 6 },
	_mcl_saturation = 7.2,
	stack_max = 1,
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_mushrooms:mushroom_stew",
	recipe = {"mcl_core:bowl", "mcl_mushrooms:mushroom_brown", "mcl_mushrooms:mushroom_red"}
})

--[[ Mushroom spread and death
Code based on information gathered from Minecraft Wiki
<http://minecraft.gamepedia.com/Tutorials/Mushroom_farming#Videos>
]]
minetest.register_abm({
	label = "Mushroom spread and death",
	nodenames = {"mcl_mushrooms:mushroom_brown", "mcl_mushrooms:mushroom_red"},
	interval = 11,
	chance = 50,
	action = function(pos, node)
		local node_soil = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
		-- Mushrooms uproot in light except on nodes of the "supports_mushrooms" group
			if minetest.get_item_group(node_soil, "supports_mushrooms") == 0 and minetest.get_node_light(pos, nil) > 12 then
				minetest.dig_node(pos)
			return
		end

		local pos0 = vector.offset(pos, -4, -1, -4)
		local pos1 = vector.offset(pos, 4, 1, 4)

		-- Stop mushroom spread if a 9×3×9 box is too crowded
		if #minetest.find_nodes_in_area(pos0, pos1, {"group:mushroom"}) >= 5 then
			return
		end

		local selected_pos = table.copy(pos)

		-- Do two random selections which may place the new mushroom in a 5×5×5 cube
		local rnd = vector.new(
			selected_pos.x + math.random(-1, 1),
			selected_pos.y + math.random(0, 1) - math.random(0, 1),
			selected_pos.z + math.random(-1, 1)
		)
		local random_node = minetest.get_node_or_nil(rnd)
		if not random_node or random_node.name ~= "air" then
			return
		end
		local node_under = minetest.get_node_or_nil(vector.offset(rnd, 0, -1, 0))
		if not node_under then
			return
		end

		if minetest.get_node_light(rnd, 0.5) > 12 or (minetest.get_item_group(node_under.name, "opaque") == 0) then
			return
		end
		local rnd2 = vector.new(
			rnd.x + math.random(-1, 1),
			rnd.y,
			rnd.z + math.random(-1, 1)
		)
		random_node = minetest.get_node_or_nil(rnd2)
		if not random_node or random_node.name ~= "air" then
			return
		end
		node_under = minetest.get_node_or_nil(vector.offset(rnd2, 0, -1, 0))
		if not node_under then
			return
		end
		if minetest.get_node_light(rnd2, 0.5) > 12 or (minetest.get_item_group(node_under.name, "opaque") == 0) or (minetest.get_item_group(node_under.name, "solid") == 0) then
			return
		end

		minetest.set_node(rnd2, {name = node.name})
	end
})
