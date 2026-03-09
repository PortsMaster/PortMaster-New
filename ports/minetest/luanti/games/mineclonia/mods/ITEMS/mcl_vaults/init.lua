mcl_vaults = {
	registered_vaults = {}
}
local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)

dofile(modpath.."/api.lua")

local function set_potency(stack, level)
	local meta = stack:get_meta()
	meta:set_int("mcl_potions:potion_potent", level)
	tt.reload_itemstack_description(stack)
	return stack
end

local function enchant_random_level(stack, list, pr)
	if type(list) ~= "table" or #list == 0 then
		core.log("error", "[mcl_vaults] error in loot table: no enchantments for " .. stack:get_name() .. debug.traceback())
		return stack
	end
	local enchantment = list[pr:next(1, #list)]
	if not mcl_enchanting.enchantments[enchantment] then
		core.log("error", "[mcl_vaults] error in loot table: enchantment " .. enchantment .. " not found for " .. stack:get_name())
		return stack
	end
	local level = pr:next(1, mcl_enchanting.enchantments[enchantment].max_level)
	mcl_enchanting.enchant(stack, enchantment, level)
	return stack
end

mcl_vaults.register_vault("vault", {
	key = {
		name = "trial_key",
		description = S("Trial Key"),
		inventory_image = "mcl_vaults_trial_key.png",
	},
	node_off = {
		tiles = { "mcl_vaults_vault_top_off.png", "mcl_vaults_vault_bottom.png",
			"mcl_vaults_vault_side_off.png", "mcl_vaults_vault_side_off.png",
			"mcl_vaults_vault_side_off.png", "mcl_vaults_vault_front_off.png",
		},
	},
	node_on = {
		tiles = { "mcl_vaults_vault_top_on.png", "mcl_vaults_vault_bottom.png",
			"mcl_vaults_vault_side_on.png", "mcl_vaults_vault_side_on.png",
			"mcl_vaults_vault_side_on.png", "mcl_vaults_vault_front_on.png",
		},
	},
	node_ejecting = {
		tiles = { "mcl_vaults_vault_top_ejecting.png", "mcl_vaults_vault_bottom.png",
			"mcl_vaults_vault_side_ejecting.png", "mcl_vaults_vault_side_ejecting.png",
			"mcl_vaults_vault_side_ejecting.png", "mcl_vaults_vault_front_ejecting.png",
		},
	},
	loot = {
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_core:emerald", weight = 392, amount_min = 2, amount_max = 4 },
				{ itemstring = "mcl_bows:arrow", weight = 92, amount_min = 2, amount_max = 8 },
				{ itemstring = "mcl_potions:poison_arrow", weight = 92, amount_min = 2, amount_max = 8, func = function(stack) set_potency(stack, 0) end },
				{ itemstring = "mcl_core:iron_ingot", weight = 69, amount_min = 1, amount_max = 4 },
				{ itemstring = "mcl_charges:wind_charge", weight = 69, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_honey:honey_bottle", weight = 69, amount_min = 1, amount_max = 2 },
				{ itemstring = "mcl_potions:ominous", weight = 48, amount_min = 1, amount_max = 2, func = function(stack, pr) set_potency(stack, pr:next(0, 1)) end },
				{ itemstring = "mcl_shields:shield", weight = 300, amount_min = 1, amount_max = 1, wear_min = 5000, wear_max = 60000 },
				{ itemstring = "mcl_bows:bow", weight = 300, func = function(stack, pr) mcl_enchanting.enchant_randomly(stack, pr:next(5, 15), true, true, false, pr) end },
				{ itemstring = "mcl_charges:wind_charge", weight = 23, amount_min = 4, amount_max = 12 },
				{ itemstring = "mcl_mobitems:breeze_rod", weight = 23, amount_min = 1, amount_max = 3 }, -- TODO remove when breeze are added
				{ itemstring = "mcl_core:diamond", weight = 23, amount_min = 1, amount_max = 2 },
				{ itemstring = "mcl_farming:carrot_item_gold", weight = 200, amount_min = 1, amount_max = 2 },
				{ itemstring = "mcl_books:book", weight = 200, func = function(stack, pr) enchant_random_level(stack, {"mending", "riptide", "loyalty", "channeling", "impaling", }, pr) end },
				{ itemstring = "mcl_books:book", weight = 200, func = function(stack, pr) enchant_random_level(stack, {"sharpness", "bane_of_arthropods", "efficiency", "fortune", "silk_touch", "feather_falling"}, pr) end },
				{ itemstring = "mcl_bows:crossbow", weight = 200, func = function(stack, pr) mcl_enchanting.enchant_randomly(stack, pr:next(5, 20), true, true, false, pr) end },
				{ itemstring = "mcl_tools:axe_iron", weight = 200, func = function(stack, pr) mcl_enchanting.enchant_randomly(stack, pr:next(5, 15), true, true, false, pr) end },
				{ itemstring = "mcl_armor:chestplate_iron", weight = 200, func = function(stack, pr) mcl_enchanting.enchant_randomly(stack, pr:next(0, 10), true, true, false, pr) end },
				{ itemstring = "mcl_tools:axe_diamond", weight = 100, func = function(stack, pr) mcl_enchanting.enchant_randomly(stack, pr:next(5, 15), true, true, false, pr) end },
				{ itemstring = "mcl_armor:chestplate_diamond", weight = 100, func = function(stack, pr) mcl_enchanting.enchant_randomly(stack, pr:next(5, 15), true, true, false, pr) end },

			}
		},
		{
			stacks_min = 1,
			stacks_max = 3,
			items = {
				{ itemstring = "mcl_core:emerald", weight = 4, amount_min = 2, amount_max = 4 },
				{ itemstring = "mcl_bows:arrow", weight = 4, amount_min = 2, amount_max = 8 },
				{ itemstring = "mcl_potions:poison_arrow", weight = 4, amount_min = 2, amount_max = 8, func = function(stack) set_potency(stack, 0) end },
				{ itemstring = "mcl_core:iron_ingot", weight = 3, amount_min = 1, amount_max = 4 },
				{ itemstring = "mcl_charges:wind_charge", weight = 3, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_honey:honey_bottle", weight = 3, amount_min = 1, amount_max = 2 },
				{ itemstring = "mcl_potions:ominous", weight = 2, amount_min = 1, amount_max = 2, func = function(stack, pr) set_potency(stack, pr:next(0, 1)) end },
				{ itemstring = "mcl_charges:wind_charge", weight = 1, amount_min = 4, amount_max = 12 },
				{ itemstring = "mcl_mobitems:breeze_rod", weight = 1, amount_min = 1, amount_max = 3 }, -- TODO remove when breeze are added
				{ itemstring = "mcl_core:diamond", weight = 1, amount_min = 1, amount_max = 2 },
			},
		},
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ nothing = true, weight = 36 },
				{ itemstring = "mcl_core:apple_gold", weight = 4, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_armor:bolt", weight = 3, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_jukebox:record_8", weight = 2, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_banners:pattern_guster", weight = 2, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_tridents:trident", weight = 1, amount_min = 1, amount_max = 1 },
			}
		}
	}
})

mcl_vaults.register_vault("ominous_vault", {
	key = {
		name = "ominous_trial_key",
		description = S("Ominous Trial Key"),
		inventory_image = "mcl_vaults_ominous_trial_key.png",
	},
	node_off = {
		description = S("Ominous Vault"),
		tiles = { "mcl_vaults_vault_ominous_top_off.png", "mcl_vaults_vault_bottom.png",
			"mcl_vaults_vault_ominous_side_off.png", "mcl_vaults_vault_ominous_side_off.png",
			"mcl_vaults_vault_ominous_side_off.png", "mcl_vaults_vault_ominous_front_off.png",
		},
	},
	node_on = {
		tiles = { "mcl_vaults_vault_ominous_top_on.png", "mcl_vaults_vault_bottom.png",
			"mcl_vaults_vault_ominous_side_on.png", "mcl_vaults_vault_ominous_side_on.png",
			"mcl_vaults_vault_ominous_side_on.png", "mcl_vaults_vault_ominous_front_on.png",
		},
	},
	node_ejecting = {
		tiles = { "mcl_vaults_vault_ominous_top_ejecting.png", "mcl_vaults_vault_bottom.png",
			"mcl_vaults_vault_ominous_side_ejecting.png", "mcl_vaults_vault_ominous_side_ejecting.png",
			"mcl_vaults_vault_ominous_side_ejecting.png", "mcl_vaults_vault_ominous_front_ejecting.png",
		},
	},
	loot = {
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_core:emerald", weight = 145, amount_min = 4, amount_max = 10 },
				{ itemstring = "mcl_charges:wind_charge", weight = 116, amount_min = 8, amount_max = 12 },
				{ itemstring = "mcl_mobitems:breeze_rod", weight = 116, amount_min = 2, amount_max = 3 }, -- TODO remove when breeze are added
				{ itemstring = "mcl_potions:slowness_arrow", weight = 87, amount_min = 4, amount_max = 12, func = function(stack) set_potency(stack, 3) end },
				{ itemstring = "mcl_core:diamond", weight = 58, amount_min = 2, amount_max = 3 },
				{ itemstring = "mcl_potions:ominous", weight = 29, amount_min = 1, amount_max = 1, func = function(stack, pr) set_potency(stack, pr:next(2, 4)) end },
				{ itemstring = "mcl_core:emeraldblock", weight = 300, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_bows:crossbow", weight = 240, func = function(stack, pr) mcl_enchanting.enchant_randomly(stack, pr:next(10, 20), true, true, false, pr) end },
				{ itemstring = "mcl_core:ironblock", weight = 240, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_core:apple_gold", weight = 180, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_tools:axe_diamond", weight = 180, func = function(stack, pr) mcl_enchanting.enchant_randomly(stack, pr:next(10, 20), true, true, false, pr) end },
				{ itemstring = "mcl_armor:chestplate_diamond", weight = 180, func = function(stack, pr) mcl_enchanting.enchant_randomly(stack, pr:next(10, 20), true, true, false, pr) end },
				{ itemstring = "mcl_books:book", weight = 120, func = function(stack, pr) enchant_random_level(stack, {"breach", "density"}, pr) end },
				{ itemstring = "mcl_books:book", weight = 120, func = function(stack, pr) enchant_random_level(stack, {"knockback", "punch", "smite", "looting", "multishot"}, pr) end },
				{ itemstring = "mcl_books:book", weight = 120, func = function(stack, pr) mcl_enchanting.enchant(stack, "wind_burst", 1) end },
				{ itemstring = "mcl_core:diamondblock", weight = 60, amount_min = 1, amount_max = 1 },
			}
		},
		{
			stacks_min = 1,
			stacks_max = 3,
			items = {
				{ itemstring = "mcl_core:emerald", weight = 5, amount_min = 4, amount_max = 10 },
				{ itemstring = "mcl_charges:wind_charge", weight = 4, amount_min = 8, amount_max = 12 },
				{ itemstring = "mcl_mobitems:breeze_rod", weight = 4, amount_min = 2, amount_max = 3 }, -- TODO remove when breeze are added

				{ itemstring = "mcl_potions:slowness_arrow", weight = 3, amount_min = 4, amount_max = 12, func = function(stack) set_potency(stack, 3) end },
				{ itemstring = "mcl_core:diamond", weight = 2, amount_min = 2, amount_max = 3 },
				{ itemstring = "mcl_potions:ominous", weight = 1, amount_min = 1, amount_max = 1, func = function(stack, pr) set_potency(stack, pr:next(2, 4)) end },
			},
		},
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ nothing = true, weight = 10 },
				{ itemstring = "mcl_armor:flow", weight = 9, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_core:apple_gold_enchanted", weight = 9, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_banners:pattern_flow", weight = 6, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_jukebox:record_7", weight = 3, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_tools:heavy_core", weight = 3, amount_min = 1, amount_max = 1 },
			}
		}
	}
})
