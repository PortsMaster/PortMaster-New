local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)
mcl_tools = {}

-- mods/default/tools.lua

--
-- Tool definition
--

--[[
dig_speed_class group:
- 1: Painfully slow
- 2: Very slow
- 3: Slow
- 4: Fast
- 5: Very fast
- 6: Extremely fast
- 7: Instantaneous
]]

-- Help texts
local pickaxe_longdesc = S("Pickaxes are mining tools to mine hard blocks, such as stone. A pickaxe can also be used as weapon, but it is rather inefficient.")
local axe_longdesc = S("An axe is your tool of choice to cut down trees, wood-based blocks and other blocks. Axes deal a lot of damage as well, but they are rather slow.")
local sword_longdesc = S("Swords are great in melee combat, as they are fast, deal high damage and can endure countless battles. Swords can also be used to cut down a few particular blocks, such as cobwebs.")
local shovel_longdesc = S("Shovels are tools for digging coarse blocks, such as dirt, sand and gravel. They can also be used to turn grass blocks to grass paths. Shovels can be used as weapons, but they are very weak.")
local shovel_use = S("To turn a grass block into a grass path, hold the shovel in your hand, then use (rightclick) the top or side of a grass block. This only works when there's air above the grass block.")
local shears_longdesc = S("Shears are tools to shear sheep and to mine a few block types. Shears are a special mining tool and can be used to obtain the original item from grass, leaves and similar blocks that require cutting.")
local shears_use = S("To shear sheep or carve faceless pumpkins, use the “place” key on them. Faces can only be carved at the side of faceless pumpkins. Mining works as usual, but the drops are different for a few blocks.")

local wield_scale = mcl_vars.tool_wield_scale

local function on_tool_place(itemstack, placer, pointed_thing, tool)
	if pointed_thing.type ~= "node" then return end

	local node = minetest.get_node(pointed_thing.under)
	local ndef = minetest.registered_nodes[node.name]
	if not ndef then
		return
	end

	if not placer:get_player_control().sneak and ndef.on_rightclick then
		return minetest.item_place(itemstack, placer, pointed_thing)
	end
	if minetest.is_protected(pointed_thing.under, placer:get_player_name()) then
		minetest.record_protection_violation(pointed_thing.under, placer:get_player_name())
		return itemstack
	end

	if itemstack and type(ndef["_on_"..tool.."_place"]) == "function" then
		local itemstack, no_wear = ndef["_on_"..tool.."_place"](itemstack, placer, pointed_thing)
		if minetest.is_creative_enabled(placer:get_player_name()) or no_wear or not itemstack then
			return itemstack
		end

		-- Add wear using the usages of the tool defined in
		-- _mcl_diggroups. This assumes the tool only has one diggroups
		-- (which is the case in Mineclone).
		local tdef = minetest.registered_tools[itemstack:get_name()]
		if tdef and tdef._mcl_diggroups then
			for group, _ in pairs(tdef._mcl_diggroups) do
				itemstack:add_wear(mcl_autogroup.get_wear(itemstack:get_name(), group))
				return itemstack
			end
		end
		return itemstack
	end

	mcl_offhand.place(placer, pointed_thing)

	return itemstack
end

mcl_tools.tool_place_funcs = {}

for _,tool in pairs({"shovel","shears","axe","sword","pick"}) do
	mcl_tools.tool_place_funcs[tool] = function(itemstack,placer,pointed_thing)
		return on_tool_place(itemstack,placer,pointed_thing,tool)
	end
end

-- Picks
minetest.register_tool("mcl_tools:pick_wood", {
	description = S("Wooden Pickaxe"),
	_doc_items_longdesc = pickaxe_longdesc,
	_doc_items_hidden = false,
	inventory_image = "default_tool_woodpick.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=2, enchantability=15 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=1,
		damage_groups = {fleshy=2},
		punch_attack_uses = 30,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = mcl_tools.tool_place_funcs.pick,
	_repair_material = "group:wood",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 2, level = 1, uses = 60 }
	},
})
minetest.register_tool("mcl_tools:pick_stone", {
	description = S("Stone Pickaxe"),
	_doc_items_longdesc = pickaxe_longdesc,
	inventory_image = "default_tool_stonepick.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=3, enchantability=5 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=3,
		damage_groups = {fleshy=3},
		punch_attack_uses = 66,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = mcl_tools.tool_place_funcs.pick,
	_repair_material = "group:cobble",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 4, level = 3, uses = 132 }
	},
})
minetest.register_tool("mcl_tools:pick_iron", {
	description = S("Iron Pickaxe"),
	_doc_items_longdesc = pickaxe_longdesc,
	inventory_image = "default_tool_steelpick.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=4, enchantability=14 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=4,
		damage_groups = {fleshy=4},
		punch_attack_uses = 126,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = mcl_tools.tool_place_funcs.pick,
	_repair_material = "mcl_core:iron_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 6, level = 4, uses = 251 }
	},
})
minetest.register_tool("mcl_tools:pick_gold", {
	description = S("Golden Pickaxe"),
	_doc_items_longdesc = pickaxe_longdesc,
	inventory_image = "default_tool_goldpick.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=6, enchantability=22 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=2,
		damage_groups = {fleshy=2},
		punch_attack_uses = 17,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = mcl_tools.tool_place_funcs.pick,
	_repair_material = "mcl_core:gold_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 12, level = 2, uses = 33 }
	},
})
minetest.register_tool("mcl_tools:pick_diamond", {
	description = S("Diamond Pickaxe"),
	_doc_items_longdesc = pickaxe_longdesc,
	inventory_image = "default_tool_diamondpick.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=5, enchantability=10 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=5,
		damage_groups = {fleshy=5},
		punch_attack_uses = 781,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = mcl_tools.tool_place_funcs.pick,
	_repair_material = "mcl_core:diamond",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 8, level = 5, uses = 1562 }
	},
	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_tools:pick_netherite"
})

minetest.register_tool("mcl_tools:pick_netherite", {
	description = S("Netherite Pickaxe"),
	_doc_items_longdesc = pickaxe_longdesc,
	inventory_image = "default_tool_netheritepick.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=6, enchantability=10, fire_immune=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=5,
		damage_groups = {fleshy=6},
		punch_attack_uses = 1016,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = mcl_tools.tool_place_funcs.pick,
	_repair_material = "mcl_nether:netherite_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 9.5, level = 6, uses = 2031 }
	},
})

-- Shovels
minetest.register_tool("mcl_tools:shovel_wood", {
	description = S("Wooden Shovel"),
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	_doc_items_hidden = false,
	inventory_image = "default_tool_woodshovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=2, enchantability=15 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=1,
		damage_groups = {fleshy=2},
		punch_attack_uses = 30,
	},
	on_place = mcl_tools.tool_place_funcs.shovel,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:wood",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 2, level = 2, uses = 60 }
	},
})
minetest.register_tool("mcl_tools:shovel_stone", {
	description = S("Stone Shovel"),
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	inventory_image = "default_tool_stoneshovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=3, enchantability=5 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=3,
		damage_groups = {fleshy=3},
		punch_attack_uses = 66,
	},
	on_place = mcl_tools.tool_place_funcs.shovel,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:cobble",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 4, level = 3, uses = 132 }
	},
})
minetest.register_tool("mcl_tools:shovel_iron", {
	description = S("Iron Shovel"),
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	inventory_image = "default_tool_steelshovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=4, enchantability=14 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=4,
		damage_groups = {fleshy=4},
		punch_attack_uses = 126,
	},
	on_place = mcl_tools.tool_place_funcs.shovel,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:iron_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 6, level = 4, uses = 251 }
	},
})
minetest.register_tool("mcl_tools:shovel_gold", {
	description = S("Golden Shovel"),
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	inventory_image = "default_tool_goldshovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=6, enchantability=22 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=2,
		damage_groups = {fleshy=2},
		punch_attack_uses = 17,
	},
	on_place = mcl_tools.tool_place_funcs.shovel,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:gold_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 12, level = 2, uses = 33 }
	},
})
minetest.register_tool("mcl_tools:shovel_diamond", {
	description = S("Diamond Shovel"),
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	inventory_image = "default_tool_diamondshovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=5, enchantability=10 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=5,
		damage_groups = {fleshy=5},
		punch_attack_uses = 781,
	},
	on_place = mcl_tools.tool_place_funcs.shovel,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:diamond",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 8, level = 5, uses = 1562 }
	},
	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_tools:shovel_netherite"
})

minetest.register_tool("mcl_tools:shovel_netherite", {
	description = S("Netherite Shovel"),
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	inventory_image = "default_tool_netheriteshovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=6, enchantability=10, fire_immune=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=5,
		damage_groups = {fleshy=5},
		punch_attack_uses = 1016,
	},
	on_place = mcl_tools.tool_place_funcs.shovel,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_nether:netherite_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 9, level = 6, uses = 2031 }
	},
})

-- Axes
minetest.register_tool("mcl_tools:axe_wood", {
	description = S("Wooden Axe"),
	_doc_items_longdesc = axe_longdesc,
	_doc_items_hidden = false,
	inventory_image = "default_tool_woodaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=2, enchantability=15 },
	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level=1,
		damage_groups = {fleshy=7},
		punch_attack_uses = 30,
	},
	on_place = mcl_tools.tool_place_funcs.axe,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:wood",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 2, level = 1, uses = 60 }
	},
})
minetest.register_tool("mcl_tools:axe_stone", {
	description = S("Stone Axe"),
	_doc_items_longdesc = axe_longdesc,
	inventory_image = "default_tool_stoneaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=3, enchantability=5 },
	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level=3,
		damage_groups = {fleshy=9},
		punch_attack_uses = 66,
	},
	on_place = mcl_tools.tool_place_funcs.axe,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:cobble",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 4, level = 3, uses = 132 }
	},
})
minetest.register_tool("mcl_tools:axe_iron", {
	description = S("Iron Axe"),
	_doc_items_longdesc = axe_longdesc,
	inventory_image = "default_tool_steelaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=4, enchantability=14 },
	tool_capabilities = {
		-- 1/0.9
		full_punch_interval = 1.11111111,
		max_drop_level=4,
		damage_groups = {fleshy=9},
		punch_attack_uses = 126,
	},
	on_place = mcl_tools.tool_place_funcs.axe,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:iron_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 6, level = 4, uses = 251 }
	},
})
minetest.register_tool("mcl_tools:axe_gold", {
	description = S("Golden Axe"),
	_doc_items_longdesc = axe_longdesc,
	inventory_image = "default_tool_goldaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=6, enchantability=22 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=2,
		damage_groups = {fleshy=7},
		punch_attack_uses = 17,
	},
	on_place = mcl_tools.tool_place_funcs.axe,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:gold_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 12, level = 2, uses = 33 }
	},
})
minetest.register_tool("mcl_tools:axe_diamond", {
	description = S("Diamond Axe"),
	_doc_items_longdesc = axe_longdesc,
	inventory_image = "default_tool_diamondaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=5, enchantability=10 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=5,
		damage_groups = {fleshy=9},
		punch_attack_uses = 781,
	},
	on_place = mcl_tools.tool_place_funcs.axe,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:diamond",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 8, level = 5, uses = 1562 }
	},
	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_tools:axe_netherite"
})

minetest.register_tool("mcl_tools:axe_netherite", {
	description = S("Netherite Axe"),
	_doc_items_longdesc = axe_longdesc,
	inventory_image = "default_tool_netheriteaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=6, enchantability=10, fire_immune=1 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=5,
		damage_groups = {fleshy=10},
		punch_attack_uses = 1016,
	},
	on_place = mcl_tools.tool_place_funcs.axe,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_nether:netherite_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 9, level = 6, uses = 2031 }
	},
})

-- Swords
minetest.register_tool("mcl_tools:sword_wood", {
	description = S("Wooden Sword"),
	_doc_items_longdesc = sword_longdesc,
	_doc_items_hidden = false,
	inventory_image = "default_tool_woodsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=2, enchantability=15 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=1,
		damage_groups = {fleshy=4},
		punch_attack_uses = 60,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = mcl_tools.tool_place_funcs.sword,
	_repair_material = "group:wood",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = 60 },
		swordy_cobweb = { speed = 2, level = 1, uses = 60 }
	},
})
minetest.register_tool("mcl_tools:sword_stone", {
	description = S("Stone Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_stonesword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=3, enchantability=5 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=3,
		damage_groups = {fleshy=5},
		punch_attack_uses = 132,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = mcl_tools.tool_place_funcs.sword,
	_repair_material = "group:cobble",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 4, level = 3, uses = 132 },
		swordy_cobweb = { speed = 4, level = 3, uses = 132 }
	},
})
minetest.register_tool("mcl_tools:sword_iron", {
	description = S("Iron Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_steelsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=4, enchantability=14 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=4,
		damage_groups = {fleshy=6},
		punch_attack_uses = 251,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = mcl_tools.tool_place_funcs.sword,
	_repair_material = "mcl_core:iron_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 6, level = 4, uses = 251 },
		swordy_cobweb = { speed = 6, level = 4, uses = 251 }
	},
})
minetest.register_tool("mcl_tools:sword_gold", {
	description = S("Golden Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_goldsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=6, enchantability=22 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=2,
		damage_groups = {fleshy=4},
		punch_attack_uses = 33,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = mcl_tools.tool_place_funcs.sword,
	_repair_material = "mcl_core:gold_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 12, level = 2, uses = 33 },
		swordy_cobweb = { speed = 12, level = 2, uses = 33 }
	},
})
minetest.register_tool("mcl_tools:sword_diamond", {
	description = S("Diamond Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_diamondsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=5, enchantability=10 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=5,
		damage_groups = {fleshy=7},
		punch_attack_uses = 1562,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = mcl_tools.tool_place_funcs.sword,
	_repair_material = "mcl_core:diamond",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 8, level = 5, uses = 1562 },
		swordy_cobweb = { speed = 8, level = 5, uses = 1562 }
	},
	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_tools:sword_netherite"
})
minetest.register_tool("mcl_tools:sword_netherite", {
	description = S("Netherite Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_netheritesword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=5, enchantability=10, fire_immune=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=5,
		damage_groups = {fleshy=9},
		punch_attack_uses = 2031,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = mcl_tools.tool_place_funcs.sword,
	_repair_material = "mcl_nether:netherite_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 8, level = 5, uses = 2031 },
		swordy_cobweb = { speed = 8, level = 5, uses = 2031 }
	},
})

--Shears
minetest.register_tool("mcl_tools:shears", {
	description = S("Shears"),
	_doc_items_longdesc = shears_longdesc,
	_doc_items_usagehelp = shears_use,
	inventory_image = "default_tool_shears.png",
	wield_image = "default_tool_shears.png",
	stack_max = 1,
	groups = { tool=1, shears=1, dig_speed_class=4, enchantability=-1, },
	tool_capabilities = {
			full_punch_interval = 0.5,
			max_drop_level=1,
	},
	on_place = mcl_tools.tool_place_funcs.shears,
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shearsy = { speed = 1.5, level = 1, uses = 238 },
		shearsy_wool = { speed = 5, level = 1, uses = 238 },
		shearsy_cobweb = { speed = 15, level = 1, uses = 238 }
	},
})


dofile(modpath.."/crafting.lua")
