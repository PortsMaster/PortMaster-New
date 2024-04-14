local S = minetest.get_translator(minetest.get_current_modname())

local function create_soil(pos, inv)
	if pos == nil then
		return false
	end
	local node = minetest.get_node(pos)
	local name = node.name
	local above = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
	if minetest.get_item_group(name, "cultivatable") == 2 then
		if above.name == "air" then
			node.name = "mcl_farming:soil"
			minetest.set_node(pos, node)
			minetest.sound_play("default_dig_crumbly", { pos = pos, gain = 0.5 }, true)
			return true
		end
	elseif minetest.get_item_group(name, "cultivatable") == 1 then
		if above.name == "air" then
			node.name = "mcl_core:dirt"
			minetest.set_node(pos, node)
			minetest.sound_play("default_dig_crumbly", { pos = pos, gain = 0.6 }, true)
			return true
		end
	end
	return false
end

local hoe_on_place_function = function(wear_divisor)
	return function(itemstack, user, pointed_thing)

		local rc = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
		if rc then return rc end

		if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
			minetest.record_protection_violation(pointed_thing.under, user:get_player_name())
			return itemstack
		end

		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:add_wear(65535/wear_divisor)
			end
			return itemstack
		end
	end
end

local uses = {
	wood = 60,
	stone = 132,
	iron = 251,
	gold = 33,
	diamond = 1562,
	netherite = 2031,
}

local hoe_tt = S("Turns block into farmland")
local hoe_longdesc = S("Hoes are essential tools for growing crops. They are used to create farmland in order to plant seeds on it. Hoes can also be used as very weak weapons in a pinch.")
local hoe_usagehelp = S("Use the hoe on a cultivatable block (by rightclicking it) to turn it into farmland. Dirt, grass blocks and grass paths are cultivatable blocks. Using a hoe on coarse dirt turns it into dirt.")

minetest.register_tool("mcl_farming:hoe_wood", {
	description = S("Wood Hoe"),
	_tt_help = hoe_tt.."\n"..S("Uses: @1", uses.wood),
	_doc_items_longdesc = hoe_longdesc,
	_doc_items_usagehelp = hoe_usagehelp,
	_doc_items_hidden = false,
	inventory_image = "farming_tool_woodhoe.png",
	wield_scale = mcl_vars.tool_wield_scale,
	on_place = hoe_on_place_function(uses.wood),
	groups = { tool=1, hoe=1, enchantability=15 },
	tool_capabilities = {
		full_punch_interval = 1,
		damage_groups = { fleshy = 1, },
		punch_attack_uses = uses.wood,
	},
	_repair_material = "group:wood",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		hoey = { speed = 2, level = 1, uses = 60 }
	},
})

minetest.register_craft({
	output = "mcl_farming:hoe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:hoe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_farming:hoe_wood",
	burntime = 10,
})

minetest.register_tool("mcl_farming:hoe_stone", {
	description = S("Stone Hoe"),
	_tt_help = hoe_tt.."\n"..S("Uses: @1", uses.stone),
	_doc_items_longdesc = hoe_longdesc,
	_doc_items_usagehelp = hoe_usagehelp,
	inventory_image = "farming_tool_stonehoe.png",
	wield_scale = mcl_vars.tool_wield_scale,
	on_place = hoe_on_place_function(uses.stone),
	groups = { tool=1, hoe=1, enchantability=5 },
	tool_capabilities = {
		full_punch_interval = 0.5,
		damage_groups = { fleshy = 1, },
		punch_attack_uses = uses.stone,
	},
	_repair_material = "group:cobble",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		hoey = { speed = 4, level = 3, uses = 132 }
	},
})

minetest.register_craft({
	output = "mcl_farming:hoe_stone",
	recipe = {
		{"group:cobble", "group:cobble"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:hoe_stone",
	recipe = {
		{"group:cobble", "group:cobble"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})

minetest.register_tool("mcl_farming:hoe_iron", {
	description = S("Iron Hoe"),
	_tt_help = hoe_tt.."\n"..S("Uses: @1", uses.iron),
	_doc_items_longdesc = hoe_longdesc,
	_doc_items_usagehelp = hoe_usagehelp,
	inventory_image = "farming_tool_steelhoe.png",
	wield_scale = mcl_vars.tool_wield_scale,
	on_place = hoe_on_place_function(uses.iron),
	groups = { tool=1, hoe=1, enchantability=14 },
	tool_capabilities = {
		-- 1/3
		full_punch_interval = 0.33333333,
		damage_groups = { fleshy = 1, },
		punch_attack_uses = uses.iron,
	},
	_repair_material = "mcl_core:iron_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		hoey = { speed = 6, level = 4, uses = 251 }
	},
})

minetest.register_craft({
	output = "mcl_farming:hoe_iron",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:hoe_iron",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:iron_nugget",
	recipe = "mcl_farming:hoe_iron",
	cooktime = 10,
})

minetest.register_tool("mcl_farming:hoe_gold", {
	description = S("Golden Hoe"),
	_tt_help = hoe_tt.."\n"..S("Uses: @1", uses.gold),
	_doc_items_longdesc = hoe_longdesc,
	_doc_items_usagehelp = hoe_usagehelp,
	inventory_image = "farming_tool_goldhoe.png",
	wield_scale = mcl_vars.tool_wield_scale,
	on_place = hoe_on_place_function(uses.gold),
	groups = { tool=1, hoe=1, enchantability=22 },
	tool_capabilities = {
		full_punch_interval = 1,
		damage_groups = { fleshy = 1, },
		punch_attack_uses = uses.gold,
	},
	_repair_material = "mcl_core:gold_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		hoey = { speed = 12, level = 2, uses = 33 }
	},
})

minetest.register_craft({
	output = "mcl_farming:hoe_gold",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:hoe_gold",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})



minetest.register_craft({
	type = "cooking",
	output = "mcl_core:gold_nugget",
	recipe = "mcl_farming:hoe_gold",
	cooktime = 10,
})

minetest.register_tool("mcl_farming:hoe_diamond", {
	description = S("Diamond Hoe"),
	_tt_help = hoe_tt.."\n"..S("Uses: @1", uses.diamond),
	_doc_items_longdesc = hoe_longdesc,
	_doc_items_usagehelp = hoe_usagehelp,
	inventory_image = "farming_tool_diamondhoe.png",
	wield_scale = mcl_vars.tool_wield_scale,
	on_place = hoe_on_place_function(uses.diamond),
	groups = { tool=1, hoe=1, enchantability=10 },
	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 1, },
		punch_attack_uses = uses.diamond,
	},
	_repair_material = "mcl_core:diamond",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		hoey = { speed = 8, level = 5, uses = 1562 }
	},
	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_farming:hoe_netherite"
})

minetest.register_craft({
	output = "mcl_farming:hoe_diamond",
	recipe = {
		{"mcl_core:diamond", "mcl_core:diamond"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:hoe_diamond",
	recipe = {
		{"mcl_core:diamond", "mcl_core:diamond"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})

minetest.register_tool("mcl_farming:hoe_netherite", {
	description = S("Netherite Hoe"),
	_tt_help = hoe_tt.."\n"..S("Uses: @1", uses.netherite),
	_doc_items_longdesc = hoe_longdesc,
	_doc_items_usagehelp = hoe_usagehelp,
	inventory_image = "farming_tool_netheritehoe.png",
	wield_scale = mcl_vars.tool_wield_scale,
	on_place = hoe_on_place_function(uses.netherite),
	groups = { tool=1, hoe=1, enchantability=10, fire_immune=1 },
	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 4, },
		punch_attack_uses = uses.netherite,
	},
	_repair_material = "mcl_nether:netherite_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		hoey = { speed = 8, level = 5, uses = uses.netherite }
	},
})
