local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)

mcl_potions = {}

-- duration effects of redstone are a factor of 8/3
-- duration effects of glowstone are a time factor of 1/2, expect with
-- slowness
-- splash potion duration effects are reduced by a factor of 3/4

mcl_potions.POTENT_FACTOR = 2
mcl_potions.PLUS_FACTOR = 8/3
mcl_potions.INV_FACTOR = 0.50

mcl_potions.DURATION = 180
mcl_potions.DURATION_INV = mcl_potions.DURATION * mcl_potions.INV_FACTOR
mcl_potions.DURATION_POISON = 45

mcl_potions.II_FACTOR = mcl_potions.POTENT_FACTOR -- TODO remove at some point
mcl_potions.DURATION_PLUS = mcl_potions.DURATION * mcl_potions.PLUS_FACTOR -- TODO remove at some point
mcl_potions.DURATION_2 = mcl_potions.DURATION / mcl_potions.II_FACTOR -- TODO remove at some point

mcl_potions.LINGERING_FACTOR = 0.25
mcl_potions.TIPPED_FACTOR = 0.125

dofile(modpath .. "/functions.lua")
dofile(modpath .. "/commands.lua")
dofile(modpath .. "/splash.lua")
dofile(modpath .. "/lingering.lua")
dofile(modpath .. "/tipped_arrow.lua")
dofile(modpath .. "/potions.lua")
local potions = mcl_potions.registered_potions

core.register_craftitem("mcl_potions:fermented_spider_eye", {
	description = S("Fermented Spider Eye"),
	_doc_items_longdesc = S("Try different combinations to create potions."),
	wield_image = "mcl_potions_spider_eye_fermented.png",
	inventory_image = "mcl_potions_spider_eye_fermented.png",
	groups = { brewitem = 1, },
})

core.register_craft({
	type = "shapeless",
	output = "mcl_potions:fermented_spider_eye",
	recipe = { "mcl_mushrooms:mushroom_brown", "mcl_core:sugar", "mcl_mobitems:spider_eye" },
})

core.register_craftitem("mcl_potions:glass_bottle", {
	_dispense_into_walkable = true,
	_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
		local new_stack
		local node_name = dropnode.name
		local inv = core.get_meta(pos):get_inventory()
		if core.get_item_group(node_name, "honey_level") == 5 then
			core.swap_node(droppos, {name = node_name:gsub("_5", ""), param2 = dropnode.param2})
			new_stack = ItemStack("mcl_honey:honey_bottle")
			droppos = vector.add(droppos, dropdir)
		elseif core.get_item_group(node_name, "water") ~= 0 then
			local water_type = "water"
			local defs = core.registered_nodes[node_name]
			local is_source = defs and defs.liquidtype == "source"
			if core.get_item_group(node_name, "river_water") ~= 0 then water_type = "river_water" end
			if is_source then new_stack = ItemStack("mcl_potions:" .. water_type) end
		end
		if new_stack then
			if inv:room_for_item("main", new_stack) then
				inv:add_item("main", new_stack)
			else
				core.add_item(droppos, new_stack)
			end
			stack:take_item()
		end
		return stack
	end,
	description = S("Glass Bottle"),
	_tt_help = S("Liquid container"),
	_doc_items_longdesc = S("A glass bottle is used as a container for liquids and can be used to collect water directly."),
	_doc_items_usagehelp = S("To collect water, use it on a cauldron with water (which removes a level of water) or any water source (which removes no water)."),
	inventory_image = "mcl_potions_potion_bottle.png",
	wield_image = "mcl_potions_potion_bottle.png",
	groups = {brewitem=1, empty_bottle = 1},
	pointabilities = {
		nodes = {
			["group:liquid_source"] = true,
		},
	},
	on_place = function(itemstack, placer, pointed_thing)
		local node = core.get_node(pointed_thing.under)
		local def = core.registered_nodes[node.name]

		if def and def._on_bottle_place then
			local r = def._on_bottle_place(itemstack, placer, pointed_thing)
			if r then return r end
		end

		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end
		return itemstack
	end,
})

core.register_craft( {
	output = "mcl_potions:glass_bottle 3",
	recipe = {
		{ "mcl_core:glass", "", "mcl_core:glass" },
		{ "", "mcl_core:glass", "" }
	}
})

-- Template function for creating images of filled potions
-- - colorstring must be a ColorString of form “#RRGGBB”, e.g. “#0000FF” for blue.
-- - opacity is optional opacity from 0-255 (default: 127)
local function potion_image(colorstring)
	return "mcl_potions_potion_overlay.png^[multiply:"..colorstring.."^mcl_potions_potion_bottle.png"
end

-- function to set node and empty water bottle (used for cauldrons and mud)
function mcl_potions.set_node_empty_bottle(itemstack, placer, pointed_thing, newitemstring, old_param2)
	local pname = placer:get_player_name()
	if core.is_protected(pointed_thing.under, pname) then
		core.record_protection_violation(pointed_thing.under, pname)
		return itemstack
	end

	-- set the node to `itemstring`
	core.set_node(pointed_thing.under, {name = newitemstring, param2 = old_param2 or 0})

	-- play sound
	core.sound_play("mcl_potions_bottle_pour", {pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)

	if core.is_creative_enabled(placer:get_player_name()) then
		return itemstack
	end
	return ItemStack("mcl_potions:glass_bottle")
end

-- used for water bottles and river water bottles
local function dispense_water_bottle(stack, _, droppos)
	local node = core.get_node(droppos)
	if core.get_item_group(node.name, "converts_to_mud") ~= 0 then
		core.set_node(droppos, {name = "mcl_mud:mud"})
		core.sound_play("mcl_potions_bottle_pour", {pos=droppos, gain=0.5, max_hear_range=16}, true)

		return ItemStack("mcl_potions:glass_bottle")
	else
		return stack
	end
end

-- on_place function for `mcl_potions:water` and `mcl_potions:river_water`

local function water_bottle_on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		local def = core.registered_nodes[core.get_node(pointed_thing.under).name]
		if def and def._on_bottle_place then
			local r = def._on_bottle_place(itemstack, placer, pointed_thing)
			if r then return r end
		end

	end
	-- Drink the water by default
	return core.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, placer, pointed_thing)
end

-- Itemstring of potions is “mcl_potions:<NBT Potion Tag>”

core.register_craftitem("mcl_potions:water", {
	description = S("Water Bottle"),
	_tt_help = S("No effect"),
	_doc_items_longdesc = S("Water bottles can be used to fill cauldrons. Drinking water has no effect."),
	_doc_items_usagehelp = S("Use the “Place” key to drink. Place this item on a cauldron to pour the water into the cauldron."),
	stack_max = 1,
	inventory_image = potion_image("#8091ff"),
	wield_image = potion_image("#8091ff"),
	groups = {brewitem=1, food=3, eatable=0, can_eat_when_full=1, water_bottle=1},
	on_place = water_bottle_on_place,
	_on_dispense = dispense_water_bottle,
	_placement_def = {
		inherit = "victuals",
		["mcl_core:dirt"] = "default",
		["mcl_core:coarse_dirt"] = "default",
		["mcl_lush_caves:rooted_dirt"] = "default",
		["mcl_cauldrons:cauldron"] = "default",
		["mcl_cauldrons:cauldron_1"] = "default",
		["mcl_cauldrons:cauldron_2"] = "default",
	},
	_dispense_into_walkable = true,
	_mcl_cauldrons_liquid = "water",
	_mcl_eat_replace_with = "mcl_potions:glass_bottle"
})


core.register_craftitem("mcl_potions:river_water", {
	description = S("River Water Bottle"),
	_tt_help = S("No effect"),
	_doc_items_longdesc = S("River water bottles can be used to fill cauldrons. Drinking it has no effect."),
	_doc_items_usagehelp = S("Use the “Place” key to drink. Place this item on a cauldron to pour the river water into the cauldron."),

	stack_max = 1,
	inventory_image = potion_image("#80a3ff"),
	wield_image = potion_image("#80a3ff"),
	groups = {brewitem=1, food=3, eatable=0, can_eat_when_full=1, water_bottle=1},
	on_place = water_bottle_on_place,
	_on_dispense = dispense_water_bottle,
	_dispense_into_walkable = true,
	_mcl_cauldrons_liquid = "river_water",
	_mcl_eat_replace_with = "mcl_potions:glass_bottle"
})

mcl_potions.register_splash("water", S("Splash Water Bottle"), "#8091ff", {
	tt=S("Extinguishes fire and hurts some mobs"),
	longdesc=S("A throwable water bottle that will shatter on impact, where it extinguishes nearby fire and hurts mobs that are vulnerable to water."),
	no_effect=true,
	base_potion = "mcl_potions:water",
	stack_max = 1,
	on_splash = function (pos, _)
		mcl_potions._water_effect (pos, 4)
	end,
	effect=1
})
mcl_potions.register_lingering("water", S("Lingering Water Bottle"), "#80a3ff", {
	tt=S("Extinguishes fire and hurts some mobs"),
	longdesc=S("A throwable water bottle that will shatter on impact, where it creates a cloud of water vapor that lingers on the ground for a while. This cloud extinguishes fire and hurts mobs that are vulnerable to water."),
	base_potion = "mcl_potions:water",
	stack_max = 1,
	no_effect=true,
	effect=1
})

core.register_craftitem("mcl_potions:speckled_melon", {
	description = S("Glistering Melon"),
	_doc_items_longdesc = S("This shiny melon is full of tiny gold nuggets and would be nice in an item frame. It isn't edible and not useful for anything else."),
	groups = { brewitem = 1, },
	inventory_image = "mcl_potions_melon_speckled.png",
})

core.register_craft({
	output = "mcl_potions:speckled_melon",
	recipe = {
		{"mcl_core:gold_nugget", "mcl_core:gold_nugget", "mcl_core:gold_nugget"},
		{"mcl_core:gold_nugget", "mcl_farming:melon_item", "mcl_core:gold_nugget"},
		{"mcl_core:gold_nugget", "mcl_core:gold_nugget", "mcl_core:gold_nugget"},
	}
})



local output_table = { }

-- API
-- registers a potion that can be combined with multiple ingredients
-- for different outcomes out_table contains the recipes for those
-- outcomes
function mcl_potions.register_ingredient_potion(input, out_table)
	assert (not output_table[input],
		"Attempt to register the same ingredient twice!")
	assert (type(input) == "string", "input must be a string")
	assert (type(out_table) == "table", "out_table must be a table")
	output_table[input] = out_table
end

local function potion_has_splash (potion)
	return potion == "mcl_potions:water"
	or (potions[potion] and potions[potion].has_splash)
end

local function potion_has_lingering (potion)
	return potion == "mcl_potions:water"
	or (potions[potion] and potions[potion].has_lingering)
end

local function complete_output_table (input, out_table, copy)
	-- Generate entries for splash and lingering variants of `input'.
	local tbl_splash = {}
	local tbl_lingering = {}

	if not potion_has_splash (input)
	and not potion_has_lingering (input) then
	return
	end

	for k, v in pairs (out_table) do
	if potion_has_splash (v) then
		tbl_splash[k] = v .. "_splash"
	end

	if potion_has_lingering (v) then
		tbl_lingering[k] = v .. "_lingering"
	end
	end
	copy[input .. "_lingering"] = tbl_lingering
	copy[input .. "_splash"] = tbl_splash
end

core.register_on_mods_loaded (function ()
	local splash_table = {}
	local lingering_table = {}
	for potion, def in pairs(potions) do
		if def.has_splash then
			splash_table[potion] = potion.."_splash"
			if def.has_lingering then
				lingering_table[potion.."_splash"] = potion.."_lingering"
			end
		end
	end
	mcl_potions.register_table_modifier("mcl_mobitems:gunpowder", splash_table)
	mcl_potions.register_table_modifier("mcl_potions:dragon_breath", lingering_table)
	local copy = {}
	for k, v in pairs (output_table) do
		complete_output_table (k, v, copy)
	end
	output_table = table.merge (output_table, copy)
end)

local water_table = {
	["mcl_nether:nether_wart_item"] = "mcl_potions:awkward",
	["mcl_potions:fermented_spider_eye"] = "mcl_potions:weakness",
	["mcl_potions:speckled_melon"] = "mcl_potions:mundane",
	["mcl_core:sugar"] = "mcl_potions:mundane",
	["mcl_mobitems:magma_cream"] = "mcl_potions:mundane",
	["mcl_mobitems:blaze_powder"] = "mcl_potions:mundane",
	["mcl_redstone:redstone"] = "mcl_potions:mundane",
	["mcl_mobitems:ghast_tear"] = "mcl_potions:mundane",
	["mcl_mobitems:spider_eye"] = "mcl_potions:mundane",
	["mcl_mobitems:rabbit_foot"] = "mcl_potions:mundane",
	["mcl_nether:glowstone_dust"] = "mcl_potions:thick",
	["mcl_mobitems:gunpowder"] = "mcl_potions:water_splash"
}
-- API
-- register a potion recipe brewed from water
function mcl_potions.register_water_brew(ingr, potion)
	assert (not water_table[ingr],
		"Attempt to register the same ingredient twice!")
	assert (type(ingr) == "string", "ingr must be a string")
	assert (type(potion) == "string", "potion must be a string")
	water_table[ingr] = potion
end
mcl_potions.register_ingredient_potion("mcl_potions:river_water", water_table)
mcl_potions.register_ingredient_potion("mcl_potions:water", water_table)

local awkward_table = {
	["mcl_potions:speckled_melon"] = "mcl_potions:healing",
	["mcl_farming:carrot_item_gold"] = "mcl_potions:night_vision",
	["mcl_core:sugar"] = "mcl_potions:swiftness",
	["mcl_mobitems:magma_cream"] = "mcl_potions:fire_resistance",
	["mcl_mobitems:blaze_powder"] = "mcl_potions:strength",
	["mcl_fishing:pufferfish_raw"] = "mcl_potions:water_breathing",
	["mcl_mobitems:ghast_tear"] = "mcl_potions:regeneration",
	["mcl_mobitems:spider_eye"] = "mcl_potions:poison",
	["mcl_mobitems:rabbit_foot"] = "mcl_potions:leaping",
	["mcl_mobitems:phantom_membrane"] = "mcl_potions:slow_falling", -- TODO add phantom membranes
	["mcl_core:stone"] = "mcl_potions:infestation",
	["mcl_core:slimeblock"] = "mcl_potions:oozing",
	["mcl_core:cobweb"] = "mcl_potions:weaving",
	["mcl_mobitems:breeze_rod"] = "mcl_potions:wind_charged"
}

-- API
-- register a potion recipe brewed from awkward potion
function mcl_potions.register_awkward_brew(ingr, potion)
	assert (not water_table[ingr],
		"Attempt to register the same ingredient twice!")
	assert (type(ingr) == "string", "ingr must be a string")
	assert (type(potion) == "string", "potion must be a string")
	awkward_table[ingr] = potion
end
mcl_potions.register_ingredient_potion("mcl_potions:awkward", awkward_table)

local mundane_table = {
	["mcl_potions:fermented_spider_eye"] = "mcl_potions:weakness",
}
-- API
-- register a potion recipe brewed from mundane potion
function mcl_potions.register_mundane_brew(ingr, potion)
	assert (not mundane_table[ingr],
		"Attempt to register the same ingredient twice!")
	assert (type(ingr) == "string", "ingr must be a string")
	assert (type(potion) == "string", "potion must be a string")
	mundane_table[ingr] = potion
end
mcl_potions.register_ingredient_potion("mcl_potions:mundane", mundane_table)

local thick_table = {
	-- Nothing here but crickets...
}
-- API
-- register a potion recipe brewed from thick potion
function mcl_potions.register_thick_brew(ingr, potion)
	assert (not awkward_table[ingr],
		"Attempt to register the same ingredient twice!")
	assert (type(ingr) == "string", "ingr must be a string")
	assert (type(potion) == "string", "potion must be a string")
	thick_table[ingr] = potion
end
mcl_potions.register_ingredient_potion("mcl_potions:thick", thick_table)


local mod_table = { }

-- API
-- registers a brewing recipe altering the potion using a table
-- this is supposed to substitute one item with another
function mcl_potions.register_table_modifier(ingr, modifier)
	assert (not mod_table[ingr],
		"Attempt to register the same ingredient twice!")
	assert (type(ingr) == "string", "ingr must be a string")
	assert (type(modifier) == "table", "modifier must be a table")
	mod_table[ingr] = modifier
end

core.register_on_mods_loaded(function()
	for k, _ in pairs(table.merge(awkward_table, water_table)) do
		local def = core.registered_items[k]
		if def then
			core.override_item(k, {
				groups = table.merge(def.groups, {brewing_ingredient = 1})
			})
		end
	end
end)

local inversion_table = {
	["mcl_potions:healing"] = "mcl_potions:harming",
	["mcl_potions:swiftness"] = "mcl_potions:slowness",
	["mcl_potions:leaping"] = "mcl_potions:slowness",
	["mcl_potions:night_vision"] = "mcl_potions:invisibility",
	["mcl_potions:poison"] = "mcl_potions:harming",
	["mcl_potions:luck"] = "mcl_potions:bad_luck",
}
-- API
function mcl_potions.register_inversion_recipe(input, output)
	assert (not inversion_table[input],
		"Attempt to register the same input twice!")
	assert (type (input) == string, "input must be a string")
	assert (type (output) == string, "output must be a string")
	inversion_table[input] = output
end
local function fill_inversion_table() -- autofills with splash and lingering inversion recipes
	local filling_table = { }
	for input, output in pairs(inversion_table) do
		if potions[input].has_splash and potions[output].has_splash then
			filling_table[input.."_splash"] = output .. "_splash"
			if potions[input].has_lingering and potions[output].has_lingering then
				filling_table[input.."_lingering"] = output .. "_lingering"
			end
		end
	end
	table.update(inversion_table, filling_table)
	mcl_potions.register_table_modifier("mcl_potions:fermented_spider_eye", inversion_table)
end
core.register_on_mods_loaded(fill_inversion_table)



local meta_mod_table = { }

-- API
-- registers a brewing recipe altering the potion using a function
-- this is supposed to be a recipe that changes metadata only
function mcl_potions.register_meta_modifier(ingr, mod_func)
	assert (not meta_mod_table[ingr],
		"Attempt to register the same ingredient twice!")
	assert (type (ingr) == "string", "ingr must be a string")
	assert (type (mod_func) == "function", "mod_func must be a function")
	meta_mod_table[ingr] = mod_func
end

local function extend_dur(potionstack)
	local name = potionstack:get_name ()
	local item_def = core.registered_items[name]
	local def = potions[item_def._base_potion or name]
	if not def then return false end
	if not def.has_plus then return false end -- bail out if can't be extended
	local potionstack = ItemStack(potionstack)
	local meta = potionstack:get_meta()
	local potent = meta:get_int("mcl_potions:potion_potent")
	local plus = meta:get_int("mcl_potions:potion_plus")
	if plus == 0 then
		if potent ~= 0 then
			meta:set_int("mcl_potions:potion_potent", 0)
		end
		meta:set_int("mcl_potions:potion_plus", def._default_extend_level)
		tt.reload_itemstack_description(potionstack)
		return potionstack
	end
	return false
end
mcl_potions.register_meta_modifier("mcl_redstone:redstone", extend_dur)

local function enhance_pow(potionstack)
	local name = potionstack:get_name ()
	local item_def = core.registered_items[name]
	local def = potions[item_def._base_potion or name]
	if not def then return false end
	if not def.has_potent then return false end -- bail out if has no potent variant
	local potionstack = ItemStack(potionstack)
	local meta = potionstack:get_meta()
	local potent = meta:get_int("mcl_potions:potion_potent")
	local plus = meta:get_int("mcl_potions:potion_plus")
	if potent == 0 then
		if plus ~= 0 then
			meta:set_int("mcl_potions:potion_plus", 0)
		end
		meta:set_int("mcl_potions:potion_potent", def._default_potent_level-1)
		tt.reload_itemstack_description(potionstack)
		return potionstack
	end
	return false
end
mcl_potions.register_meta_modifier("mcl_nether:glowstone_dust", enhance_pow)

-- Find an alchemical recipe for given ingredient and potion
-- returns outcome
function mcl_potions.get_alchemy(ingr, pot)
	local potion = pot:get_name ()
	local brew_selector = output_table[potion]
	if brew_selector and brew_selector[ingr] then
		local meta = pot:get_meta():to_table()
		local name = brew_selector[ingr]
		local alchemy = ItemStack(name)
		local metaref = alchemy:get_meta()
		metaref:from_table(meta)

		tt.reload_itemstack_description(alchemy)
		return alchemy
	end

	brew_selector = mod_table[ingr]
	if brew_selector then
		local brew = brew_selector[potion]
		if brew then
			local meta = pot:get_meta():to_table()
			local alchemy = ItemStack(brew)
			local metaref = alchemy:get_meta()
			metaref:from_table(meta)
			tt.reload_itemstack_description(alchemy)
			return alchemy
		end
	end

	if meta_mod_table[ingr] then
		local brew_func = meta_mod_table[ingr]
		local alchemy = brew_func (pot)
		if brew_func then
			return alchemy
		end
	end

	return false
end

mcl_wip.register_wip_item("mcl_potions:night_vision")
mcl_wip.register_wip_item("mcl_potions:night_vision_splash")
mcl_wip.register_wip_item("mcl_potions:night_vision_lingering")
mcl_wip.register_wip_item("mcl_potions:night_vision_arrow")
