------------------
---- Beehives ----
------------------

-- Variables
local S = core.get_translator(core.get_current_modname())
local abm_nodes = { "mcl_beehives:beehive", "mcl_beehives:bee_nest" }

-- Function to allow harvesting honey and honeycomb from the beehive and bee nest.
local honey_harvest = function(pos, node, player, itemstack)
	local inv = player:get_inventory()
	local shears = core.get_item_group(player:get_wielded_item():get_name(), "shears") > 0
	local bottle = player:get_wielded_item():get_name() == "mcl_potions:glass_bottle"
	local original_block = "mcl_beehives:bee_nest"
	local is_creative = core.is_creative_enabled(player:get_player_name())
	if node.name == "mcl_beehives:beehive_5" then
		original_block = "mcl_beehives:beehive"
	end

	local campfire_area = vector.offset(pos, 0, -5, 0)
	local campfire = core.find_nodes_in_area(pos, campfire_area, "group:lit_campfire")

	if bottle or shears then
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return itemstack
		end
		if bottle then
			local honey = "mcl_honey:honey_bottle"
			if inv:room_for_item("main", honey) then
				inv:add_item("main", "mcl_honey:honey_bottle")
				if not is_creative then
					itemstack:take_item()
				end
				if campfire[1] then
					awards.unlock(player:get_player_name(), "mcl:bee_our_guest")
				end
			end
		else --Must be shears
			core.add_item(pos, "mcl_honey:honeycomb 3")
		end
		--TODO: damage type = "mob" since this is supposed to be done by bee mobs which aren't a thing yet
		--Once bees exist this branch should spawn them and/or make them aggro
		if not campfire[1] then mcl_util.deal_damage(player, 10, {type = "mob"}) end
		node.name = original_block
		mcl_redstone.swap_node(pos, node)
	end
	return mcl_util.return_itemstack_if_alive(player, itemstack)
	-- returning the old itemstack here would result in it still being in hand *after* death
end

-- Dig Function for Beehives
local dig_hive = function(pos, node, _, digger)
	local wield_item = digger:get_wielded_item()
	local beehive = string.find(node.name, "mcl_beehives:beehive")
	local beenest = string.find(node.name, "mcl_beehives:bee_nest")
	local silk_touch = mcl_enchanting.has_enchantment(wield_item, "silk_touch")
	local is_creative = core.is_creative_enabled(digger:get_player_name())
	local inv = digger:get_inventory()

	if beehive then
		if not is_creative then
			if not silk_touch then
				mcl_util.deal_damage(digger, 10, {type = "mob"})
				core.add_item(pos, "mcl_beehives:beehive")
			else

				core.add_item(pos, node.name)
			end
		elseif is_creative and inv:room_for_item("main", "mcl_beehives:beehive") and not inv:contains_item("main", "mcl_beehives:beehive") then
			inv:add_item("main", "mcl_beehives:beehive")
		end
	elseif beenest then
		if not is_creative then
			if silk_touch and wield_item:get_name() ~= "mcl_enchanting:book_enchanted" then
				awards.unlock(digger:get_player_name(), "mcl:total_beelocation")
				core.add_item(pos, node.name)
			else
				mcl_util.deal_damage(digger, 10, {type = "mob"})
			end
		elseif is_creative and inv:room_for_item("main", "mcl_beehives:bee_nest") and not inv:contains_item("main", "mcl_beehives:bee_nest") then
			inv:add_item("main", "mcl_beehives:bee_nest")
		end
	end
end

-- Beehive
core.register_node("mcl_beehives:beehive", {
	description = S("Beehive"),
	_doc_items_longdesc = S("Artificial bee nest."),
	tiles = {
		"mcl_beehives_beehive_end.png", "mcl_beehives_beehive_end.png",
		"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_side.png",
		"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_front.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 5, material_wood = 1, beehive = 1, unmovable_by_piston = 1, comparator_signal = 0},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_hardness = 0.6,
	_mcl_burntime = 15,
	drop = "",
	after_dig_node = dig_hive,
})

for l = 1, 4 do
	local name = "mcl_beehives:beehive_" .. l
	table.insert(abm_nodes, name)
	core.register_node(name, {
		description = S("Beehive"),
		_doc_items_longdesc = S("Artificial bee nest."),
		tiles = {
			"mcl_beehives_beehive_end.png", "mcl_beehives_beehive_end.png",
			"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_side.png",
			"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_front.png",
		},
		paramtype2 = "facedir",
		groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 5, material_wood = 1, not_in_creative_inventory = 1, beehive = 1, honey_level = l, unmovable_by_piston = 1, comparator_signal = l},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_hardness = 0.6,
		_mcl_baseitem = "mcl_beehives:beehive",
		drop = "",
		after_dig_node = dig_hive,
	})
end

core.register_node("mcl_beehives:beehive_5", {
	description = S("Beehive"),
	_doc_items_longdesc = S("Artificial bee nest."),
	tiles = {
		"mcl_beehives_beehive_end.png", "mcl_beehives_beehive_end.png",
		"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_side.png",
		"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_front_honey.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 5, material_wood = 1, not_in_creative_inventory = 1, beehive = 1, honey_level = 5, comparator_signal = 5 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_hardness = 0.6,
	_mcl_baseitem = "mcl_beehives:beehive",
	on_rightclick = honey_harvest,
	drop = "",
	after_dig_node = dig_hive,
})

-- Bee Nest
core.register_node("mcl_beehives:bee_nest", {
	description = S("Bee Nest"),
	_doc_items_longdesc = S("A naturally generating block that houses bees and a tasty treat...if you can get it."),
	tiles = {
		"mcl_beehives_bee_nest_top.png", "mcl_beehives_bee_nest_bottom.png",
		"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_side.png",
		"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_front.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 30, bee_nest = 1, comparator_signal = 0 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_hardness = 0.3,
	_mcl_burntime = 15,
	drop = "",
	after_dig_node = dig_hive,
})

for i = 1, 4 do
	local name = "mcl_beehives:bee_nest_"..i
	table.insert(abm_nodes, name)
	core.register_node(name, {
		description = S("Bee Nest"),
		_doc_items_longdesc = S("A naturally generating block that houses bees and a tasty treat...if you can get it."),
		tiles = {
			"mcl_beehives_bee_nest_top.png", "mcl_beehives_bee_nest_bottom.png",
			"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_side.png",
			"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_front.png",
		},
		paramtype2 = "facedir",
		groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 30, not_in_creative_inventory = 1, bee_nest = 1, honey_level = i, comparator_signal = i },
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_hardness = 0.3,
		_mcl_baseitem = "mcl_beehives:bee_nest",
		drop = "",
		after_dig_node = dig_hive,
	})
end

core.register_node("mcl_beehives:bee_nest_5", {
	description = S("Bee Nest"),
	_doc_items_longdesc = S("A naturally generating block that houses bees and a tasty treat...if you can get it."),
	tiles = {
		"mcl_beehives_bee_nest_top.png", "mcl_beehives_bee_nest_bottom.png",
		"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_side.png",
		"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_front_honey.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 30, not_in_creative_inventory = 1, bee_nest = 1, honey_level = 5, comparator_signal = 5 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_hardness = 0.3,
	_mcl_honey_level = 5,
	_mcl_baseitem = "mcl_beehives:bee_nest",
	on_rightclick = honey_harvest,
	drop = "",
	after_dig_node = dig_hive,
})

-- Crafting
core.register_craft({
	output = "mcl_beehives:beehive",
	recipe = {
		{ "group:wood", "group:wood", "group:wood" },
		{ "mcl_honey:honeycomb", "mcl_honey:honeycomb", "mcl_honey:honeycomb" },
		{ "group:wood", "group:wood", "group:wood" },
	},
})

-- Temporary ABM to update honey levels
core.register_abm({
	label = "Update Beehive or Beenest Honey Levels",
	nodenames = abm_nodes, --Register for all levels but 5 so honeyed hives aren't constantly updating themselves
	interval = 75, --This is similar to what the situation would be for 2 bees (~5 to reach flower, 20 to harvest pollen, ~5 to return, 120 to process).
	chance = 1,
	action = function(pos, node)
		local flower = core.find_node_near(pos, 5, "group:flower")
		local tod = core.get_timeofday() * 24000 --Bees need to sleep (note in Minecraft, they don't in the Nether/End, which is ridiculous)
		if tod > 6000 and tod < 18000 and flower and mcl_weather.get_weather() ~= "rain" then
			local node_name = node.name
			local original_block = "mcl_beehives:bee_nest"
			if core.get_item_group(node_name, "beehive") == 1 then
				original_block = "mcl_beehives:beehive"
			end
			local honey_level = core.get_item_group(node_name, "honey_level")
			honey_level = math.min(honey_level + (math.random(100) == 100 and 2 or 1), 5)
			node.name = original_block.."_"..honey_level
			mcl_redstone.swap_node(pos, node)
		end
	end,
})
