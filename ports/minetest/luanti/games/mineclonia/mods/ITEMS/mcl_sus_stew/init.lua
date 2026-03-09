mcl_sus_stew = {}
local S = core.get_translator(core.get_current_modname())

local flower_effects = {}
local effect_durations = {}

function mcl_sus_stew.register_sus_stew(ingredient, effect, duration)
	if not mcl_potions.registered_effects[effect] then
		error("Unknown potion effect.")
	end
	flower_effects[ingredient] = effect
	effect_durations[effect] = duration
end

function mcl_sus_stew.get_sus_stew(ingredient)
	local effect = flower_effects[ingredient]
	if not effect then
		error("Invalid suspicious stew ingredient.")
	end
	local itemstack = ItemStack("mcl_sus_stew:stew")
	itemstack:get_meta():set_string("effect", effect)
	return itemstack
end

core.register_craftitem("mcl_sus_stew:stew",{
	description = S("Suspicious Stew"),
	inventory_image = "sus_stew.png",
	stack_max = 1,
	groups = { food = 2, eatable = 6, can_eat_when_full = 1, not_in_creative_inventory=1,},
	_mcl_saturation = 7.2,
	_mcl_eat_replace_with = "mcl_core:bowl",
	_mcl_eat_effect = function (itemstack, placer, pointed_thing)
		local effect = itemstack:get_meta():get_string("effect")
		if effect == "jump" then
			-- some old sus stew items may still have a legacy effect name.
			effect = "leaping"
		end
		if mcl_potions.registered_effects[effect] then
			mcl_potions.give_effect(effect, placer, 1, effect_durations[effect])
		end
	end,
})

core.register_craft({
	type = "shapeless",
	output = "mcl_sus_stew:stew",
	recipe = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown", "mcl_core:bowl", "group:sus_stew_ingredient"},
})

core.register_on_craft(function(itemstack, _, old_craft_grid, _)
	if itemstack:get_name() ~= "mcl_sus_stew:stew" then return end
	for _, item in pairs(old_craft_grid) do
		local name = item:get_name()
		if core.get_item_group(name, "sus_stew_ingredient") == 1 then
			return mcl_sus_stew.get_sus_stew(name)
		end
	end
end)
