local S = core.get_translator(core.get_current_modname())
local modpath = core.get_modpath(core.get_current_modname())

local on_place = mcl_util.generate_on_place_plant_function(function(place_pos, _)
	local soil_node = core.get_node_or_nil({x=place_pos.x, y=place_pos.y-1, z=place_pos.z})
	if not soil_node then return false end
	local snn = soil_node.name -- soil node name

	-- Placement rules:
	-- * Always allowed on podzol or mycelimu
	-- * Otherwise, must be solid, opaque and have daylight light level <= 12
	local light = core.get_node_light(place_pos, 0.5)
	local light_ok = false
	if light and light <= 12 then
		light_ok = true
	end
	return (core.get_item_group(snn, "supports_mushrooms") == 1 or (light_ok and core.get_item_group(snn, "solid") == 1 and core.get_item_group(snn, "opaque") == 1))
end)

local longdesc_intro_brown = S("Brown mushrooms are fungi which grow and spread in darkness, but are sensitive to light. They are inedible as such, but they can be used to craft food items.")
local longdesc_intro_red = S("Red mushrooms are fungi which grow and spread in darkness, but are sensitive to light. They are inedible as such, but they can be used to craft food items.")

local longdesc_append = S("A single mushroom of this species will slowly spread over time towards a random solid opaque block with a light level of 12 or lower in a 3×3×3 cube around the mushroom. It stops spreading when there are 5 or more mushrooms of the same species within an area of 9×3×9 blocks around the mushroom.").."\n"..
S("Mushrooms will eventually uproot at a light level of 12 or higher. On mycelium or podzol, they survive and spread at any light level.")

local tt_help = S("Grows on podzol, mycelium and other blocks").."\n"..S("Spreads in darkness")

local usagehelp = S("This mushroom can be placed on mycelium and podzol at any light level. It can also be placed on blocks which are both solid and opaque, as long as the light level at daytime is not higher than 12.")

local function on_bone_meal(_, _, _, pos, n)
	if math.random(1, 100) > 40 then return end --40% chance

	local bn = core.get_node(vector.offset(pos,0,-1,0)).name
	if bn ~= "mcl_core:mycelium" and bn ~= "mcl_core:dirt" and core.get_item_group(bn, "grass_block") ~= 1 and bn ~= "mcl_core:coarse_dirt" and bn ~= "mcl_core:podzol" then
		return
	end

	-- Select schematic
	local schematic, stem, wide
	local schem_height = 5
	if n.name == "mcl_mushrooms:mushroom_brown" then
		schematic = modpath .. "/schematics/mcl_mushrooms_huge_brown.mts"
    stem = "mcl_mushrooms:brown_mushroom_block_stem"
    wide = 3
	elseif n.name == "mcl_mushrooms:mushroom_red" then
		schematic = modpath .. "/schematics/mcl_mushrooms_huge_red.mts"
    stem = "mcl_mushrooms:red_mushroom_block_stem"
    wide = 2
	else
		return
	end

  local base_height = math.random(0, 2)
  if math.random(1, 12) == 1 then
    -- has 1/12 chance grow twice as high (minus 1 block)
    base_height = base_height * 2 + schem_height - 1
  end
  local minp, maxp = vector.offset(pos,-wide,1,-wide), vector.offset(pos,wide,base_height + schem_height,wide)

  -- Find lowest possible height
  local obstacles = core.find_nodes_in_area(minp, maxp, {"group:opaque"})
  local lowest_y = maxp.y
  for _, o in pairs(obstacles) do
    if o.y < lowest_y then
      lowest_y = o.y
    end
  end
  local minimum_y = vector.offset(pos,0,schem_height,0).y
  maxp.y = lowest_y
  if maxp.y < minimum_y then
    return
  end

	-- Check space requirements
  local goodnodes = core.find_nodes_in_area(minp, maxp, {"air", "group:leaves"})
  local diff = vector.subtract(maxp, minp)
  local totalnodes = diff.x * diff.y * diff.z
  if #goodnodes < totalnodes then
    return
  end

  -- Place the huge mushroom
  core.remove_node(pos)
  local ok = core.place_schematic(vector.new(minp.x, maxp.y - schem_height, minp.z), schematic, 0, nil, false)
  for i=0,base_height do
    core.set_node(vector.offset(pos,0,i,0), {name=stem})
  end
  return ok ~= nil
end

core.register_node("mcl_mushrooms:mushroom_brown", {
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
		dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1, unsticky = 1,
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
	_mcl_hardness = 0,
})

core.register_node("mcl_mushrooms:mushroom_red", {
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
		dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1, unsticky = 1,
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
	_mcl_hardness = 0,
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

core.register_craftitem("mcl_mushrooms:mushroom_stew", {
	description = S("Mushroom Stew"),
	_doc_items_longdesc = S("Mushroom stew is a healthy soup which can be consumed to restore some hunger points."),
	inventory_image = "farming_mushroom_stew.png",
	groups = { food = 2, eatable = 6 },
	_mcl_saturation = 7.2,
	_mcl_eat_replace_with = "mcl_core:bowl",
	stack_max = 1,
})

core.register_craft({
	type = "shapeless",
	output = "mcl_mushrooms:mushroom_stew",
	recipe = {"mcl_core:bowl", "mcl_mushrooms:mushroom_brown", "mcl_mushrooms:mushroom_red"}
})

--[[ Mushroom spread and death
Code based on information gathered from Minecraft Wiki
<http://minecraft.gamepedia.com/Tutorials/Mushroom_farming#Videos>
]]
core.register_abm({
	label = "Mushroom spread and death",
	nodenames = {"mcl_mushrooms:mushroom_brown", "mcl_mushrooms:mushroom_red"},
	interval = 11,
	chance = 50,
	action = function(pos, node)
		local node_soil = core.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
		-- Mushrooms uproot in light except on nodes of the "supports_mushrooms" group
			if core.get_item_group(node_soil, "supports_mushrooms") == 0 and core.get_node_light(pos, nil) > 12 then
				core.dig_node(pos)
			return
		end

		local pos0 = vector.offset(pos, -4, -1, -4)
		local pos1 = vector.offset(pos, 4, 1, 4)

		-- Stop mushroom spread if a 9×3×9 box is too crowded
		if #core.find_nodes_in_area(pos0, pos1, {"group:mushroom"}) >= 5 then
			return
		end

		local selected_pos = table.copy(pos)

		-- Do two random selections which may place the new mushroom in a 5×5×5 cube
		local rnd = vector.new(
			selected_pos.x + math.random(-1, 1),
			selected_pos.y + math.random(0, 1) - math.random(0, 1),
			selected_pos.z + math.random(-1, 1)
		)
		local random_node = core.get_node_or_nil(rnd)
		if not random_node or random_node.name ~= "air" then
			return
		end
		local node_under = core.get_node_or_nil(vector.offset(rnd, 0, -1, 0))
		if not node_under then
			return
		end

		if core.get_node_light(rnd, 0.5) > 12 or (core.get_item_group(node_under.name, "opaque") == 0) then
			return
		end
		local rnd2 = vector.new(
			rnd.x + math.random(-1, 1),
			rnd.y,
			rnd.z + math.random(-1, 1)
		)
		random_node = core.get_node_or_nil(rnd2)
		if not random_node or random_node.name ~= "air" then
			return
		end
		node_under = core.get_node_or_nil(vector.offset(rnd2, 0, -1, 0))
		if not node_under then
			return
		end
		if core.get_node_light(rnd2, 0.5) > 12 or (core.get_item_group(node_under.name, "opaque") == 0) or (core.get_item_group(node_under.name, "solid") == 0) then
			return
		end

		core.set_node(rnd2, {name = node.name})
	end
})
