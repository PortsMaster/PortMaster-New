------------------
---- Beehives ----
------------------

-- Variables
local S = minetest.get_translator(minetest.get_current_modname())

-- Function to allow harvesting honey and honeycomb from the beehive and bee nest.
local honey_harvest = function(pos, node, player, itemstack, pointed_thing)
	local inv = player:get_inventory()
	local shears = minetest.get_item_group(player:get_wielded_item():get_name(), "shears") > 0
	local bottle = player:get_wielded_item():get_name() == "mcl_potions:glass_bottle"
	local beehive = "mcl_beehives:beehive"
	local is_creative = minetest.is_creative_enabled(player:get_player_name())

	if node.name == "mcl_beehives:beehive_5" then
		beehive = "mcl_beehives:beehive"
	elseif node.name == "mcl_beehives:bee_nest_5" then
		beehive = "mcl_beehives:bee_nest"
	end

	local campfire_area = vector.offset(pos, 0, -5, 0)
	local campfire = minetest.find_nodes_in_area(pos, campfire_area, "group:lit_campfire")

	if bottle then
		local honey = "mcl_honey:honey_bottle"
		if inv:room_for_item("main", honey) then
			node.name = beehive
			minetest.set_node(pos, node)
			inv:add_item("main", "mcl_honey:honey_bottle")
			if not is_creative then
				itemstack:take_item()
			end
			if not campfire[1] then
				mcl_util.deal_damage(player, 10, {type = "mob"})
				--TODO: damage type = "mob" since this is supposed to be done by bee mobs which aren't a thing yet
				--Once bees exist this branch should spawn them and/or make them aggro
			else
				awards.unlock(player:get_player_name(), "mcl:bee_our_guest")
			end
		end
	elseif shears then
		minetest.add_item(pos, "mcl_honey:honeycomb 3")
		node.name = beehive
		minetest.set_node(pos, node)
		if not campfire[1] then mcl_util.deal_damage(player, 10, {type = "mob"}) end
	end
end

-- Dig Function for Beehives
local dig_hive = function(pos, node, oldmetadata, digger)
	local wield_item = digger:get_wielded_item()
	local beehive = string.find(node.name, "mcl_beehives:beehive")
	local beenest = string.find(node.name, "mcl_beehives:bee_nest")
	local silk_touch = mcl_enchanting.has_enchantment(wield_item, "silk_touch")
	local is_creative = minetest.is_creative_enabled(digger:get_player_name())
	local inv = digger:get_inventory()

	if beehive then
		if not is_creative then
			minetest.add_item(pos, "mcl_beehives:beehive")
			if not silk_touch then mcl_util.deal_damage(digger, 10, {type = "mob"}) end
		elseif is_creative and inv:room_for_item("main", "mcl_beehives:beehive") and not inv:contains_item("main", "mcl_beehives:beehive") then
			inv:add_item("main", "mcl_beehives:beehive")
		end
	elseif beenest then
		if not is_creative then
			if silk_touch then
				minetest.add_item(pos, "mcl_beehives:bee_nest")
				awards.unlock(digger:get_player_name(), "mcl:total_beelocation")
			else
				mcl_util.deal_damage(digger, 10, {type = "mob"})
			end
		elseif is_creative and inv:room_for_item("main", "mcl_beehives:bee_nest") and not inv:contains_item("main", "mcl_beehives:bee_nest") then
			inv:add_item("main", "mcl_beehives:bee_nest")
		end
	end
end

-- Beehive
minetest.register_node("mcl_beehives:beehive", {
	description = S("Beehive"),
	_doc_items_longdesc = S("Artificial bee nest."),
	tiles = {
		"mcl_beehives_beehive_end.png", "mcl_beehives_beehive_end.png",
		"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_side.png",
		"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_front.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 5, material_wood = 1, beehive = 1 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
	drop = "",
	after_dig_node = dig_hive,
})

for l = 1, 4 do
	minetest.register_node("mcl_beehives:beehive_" .. l, {
		description = S("Beehive"),
		_doc_items_longdesc = S("Artificial bee nest."),
		tiles = {
			"mcl_beehives_beehive_end.png", "mcl_beehives_beehive_end.png",
			"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_side.png",
			"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_front.png",
		},
		paramtype2 = "facedir",
		groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 5, material_wood = 1, not_in_creative_inventory = 1, beehive = 1 },
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_blast_resistance = 0.6,
		_mcl_hardness = 0.6,
		drop = "",
		after_dig_node = dig_hive,
	})
end

minetest.register_node("mcl_beehives:beehive_5", {
	description = S("Beehive"),
	_doc_items_longdesc = S("Artificial bee nest."),
	tiles = {
		"mcl_beehives_beehive_end.png", "mcl_beehives_beehive_end.png",
		"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_side.png",
		"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_front_honey.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 5, material_wood = 1, not_in_creative_inventory = 1, beehive = 1 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
	on_rightclick = honey_harvest,
	drop = "",
	after_dig_node = dig_hive,
})

-- Bee Nest
minetest.register_node("mcl_beehives:bee_nest", {
	description = S("Bee Nest"),
	_doc_items_longdesc = S("A naturally generating block that houses bees and a tasty treat...if you can get it."),
	tiles = {
		"mcl_beehives_bee_nest_top.png", "mcl_beehives_bee_nest_bottom.png",
		"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_side.png",
		"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_front.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 30, bee_nest = 1 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 0.3,
	_mcl_hardness = 0.3,
	drop = "",
	after_dig_node = dig_hive,
})

for i = 1, 4 do
	minetest.register_node("mcl_beehives:bee_nest_"..i, {
		description = S("Bee Nest"),
		_doc_items_longdesc = S("A naturally generating block that houses bees and a tasty treat...if you can get it."),
		tiles = {
			"mcl_beehives_bee_nest_top.png", "mcl_beehives_bee_nest_bottom.png",
			"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_side.png",
			"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_front.png",
		},
		paramtype2 = "facedir",
		groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 30, not_in_creative_inventory = 1, bee_nest = 1 },
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_blast_resistance = 0.3,
		_mcl_hardness = 0.3,
		drop = "",
		after_dig_node = dig_hive,
	})
end

minetest.register_node("mcl_beehives:bee_nest_5", {
	description = S("Bee Nest"),
	_doc_items_longdesc = S("A naturally generating block that houses bees and a tasty treat...if you can get it."),
	tiles = {
		"mcl_beehives_bee_nest_top.png", "mcl_beehives_bee_nest_bottom.png",
		"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_side.png",
		"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_front_honey.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 30, not_in_creative_inventory = 1, bee_nest = 1 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 0.3,
	_mcl_hardness = 0.3,
	on_rightclick = honey_harvest,
	drop = "",
	after_dig_node = dig_hive,
})

-- Crafting
minetest.register_craft({
	output = "mcl_beehives:beehive",
	recipe = {
		{ "group:wood", "group:wood", "group:wood" },
		{ "mcl_honey:honeycomb", "mcl_honey:honeycomb", "mcl_honey:honeycomb" },
		{ "group:wood", "group:wood", "group:wood" },
	},
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:bee_nest",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:beehive",
	burntime = 15,
})

-- Temporary ABM to update honey levels
minetest.register_abm({
	label = "Update Beehive Honey Levels",
	nodenames = "group:beehive",
	interval = 500,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local beehive = "mcl_beehives:beehive"
		if node.name == beehive then
			node.name = beehive.."_1"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_1" then
			node.name = beehive.."_2"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_2" then
			node.name = beehive.."_3"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_3" then
			node.name = beehive.."_4"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_4" then
			node.name = beehive.."_5"
			minetest.set_node(pos, node)
		end
	end,
})

minetest.register_abm({
	label = "Update Bee Nest Honey Levels",
	nodenames = "group:bee_nest",
	interval = 500,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local beehive = "mcl_beehives:bee_nest"
		if node.name == beehive then
			node.name = beehive.."_1"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_1" then
			node.name = beehive.."_2"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_2" then
			node.name = beehive.."_3"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_3" then
			node.name = beehive.."_4"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_4" then
			node.name = beehive.."_5"
			minetest.set_node(pos, node)
		end
	end,
})
