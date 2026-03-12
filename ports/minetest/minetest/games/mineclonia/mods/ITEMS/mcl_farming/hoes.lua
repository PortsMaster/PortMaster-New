local S = core.get_translator(core.get_current_modname())

function mcl_farming.cultivate_soil(itemstack, placer, pointed_thing)
	local pos = pointed_thing.under
	if core.get_node(vector.offset(pos, 0, 1, 0)).name == "air" then
		local node = core.get_node(pos)
		node.name = "mcl_farming:soil"
		core.set_node(pos, node)
		core.sound_play("default_dig_crumbly", { pos = pos, gain = 0.5 }, true)
		return itemstack, false
	end

	return nil
end

function mcl_farming.cultivate_dirt(itemstack, placer, pointed_thing)
	local pos = pointed_thing.under
	if core.get_node(vector.offset(pos, 0, 1, 0)).name == "air" then
		local node = core.get_node(pos)
		node.name = "mcl_core:dirt"
		core.set_node(pos, node)
		core.sound_play("default_dig_crumbly", { pos = pos, gain = 0.5 }, true)
		return itemstack, false
	end

	return nil
end

local hoe_tt = S("Turns block into farmland")
local hoe_longdesc = S("Hoes are essential tools for growing crops. They are used to create farmland in order to plant seeds on it. Hoes can also be used as very weak weapons in a pinch.")
local hoe_usagehelp = S("Use the hoe on a cultivatable block (by rightclicking it) to turn it into farmland. Dirt, grass blocks and grass paths are cultivatable blocks. Using a hoe on coarse dirt turns it into dirt.")

local hoe_common_defs = {
	longdesc = hoe_longdesc,
	usagehelp = hoe_usagehelp,
	groups = { hoe = 1, tool = 1 },
	diggroups = { hoey = {} },
	craft_shapes = {
		{
			{ "material", "material" },
			{ "mcl_core:stick", "" },
			{ "mcl_core:stick", "" }
		},
		{
			{ "material", "material" },
			{ "", "mcl_core:stick" },
			{ "", "mcl_core:stick" }
		}
	},
	_placement_def = {
		["mcl_lush_caves:rooted_dirt"] = "default",
		["mcl_core:dirt_with_grass"] = "default",
		["mcl_core:grass_path"] = "default",
		["mcl_core:dirt"] = "default",
		["mcl_core:coarse_dirt"] = "default",
		inherit = "placeable_on_actionable",
	},
}

mcl_tools.tool_place_funcs["hoe"] = mcl_tools.get_default_tool_place_func("hoe")

mcl_tools.add_to_sets("hoe", hoe_common_defs, {
	["wood"] = {
		description = S("Wood Hoe"),
		inventory_image = "farming_tool_woodhoe.png",
		tool_capabilities = {
			full_punch_interval = 1,
			damage_groups = { fleshy = 1, },
		},
		_mcl_burntime = 10,
		_doc_items_hidden = false,
	},
	["stone"] = {
		description = S("Stone Hoe"),
		inventory_image = "farming_tool_stonehoe.png",
		tool_capabilities = {
			full_punch_interval = 0.5,
			damage_groups = { fleshy = 1, },
		},
	},
	["copper"] = {
		description = S("Copper Hoe"),
		inventory_image = "mcl_copper_tool_hoe.png",
		tool_capabilities = {
			full_punch_interval = 0.5,
			damage_groups = { fleshy = 1, },
		},
		_mcl_cooking_output = "mcl_copper:copper_nugget"
	},
	["iron"] = {
		description = S("Iron Hoe"),
		inventory_image = "farming_tool_steelhoe.png",
		tool_capabilities = {
			full_punch_interval = 0.33333333,
			damage_groups = { fleshy = 1, },
		},
		_mcl_cooking_output = "mcl_core:iron_nugget"
	},
	["gold"] = {
		description = S("Golden Hoe"),
		inventory_image = "farming_tool_goldhoe.png",
		tool_capabilities = {
			full_punch_interval = 1,
			damage_groups = { fleshy = 1, },
		},
		_mcl_cooking_output = "mcl_core:gold_nugget"
	},
	["diamond"] = {
		description = S("Diamond Hoe"),
		inventory_image = "farming_tool_diamondhoe.png",
		tool_capabilities = {
			full_punch_interval = 0.25,
			damage_groups = { fleshy = 1, },
		},
		_mcl_upgradable = true,
		_mcl_upgrade_item = "mcl_farming:hoe_netherite",
	},
	["netherite"] = {
		description = S("Netherite Hoe"),
		inventory_image = "farming_tool_netheritehoe.png",
		tool_capabilities = {
			full_punch_interval = 0.25,
			damage_groups = { fleshy = 4, },
		},
	},
}, {
	_tt_help = hoe_tt,
	tool_capabilities = { max_drop_level = 0 },
})

core.register_on_mods_loaded(function()
	local place_fun = {mcl_farming.cultivate_dirt, mcl_farming.cultivate_soil}
	for name, def in pairs(core.registered_nodes) do
		local cultivatable = core.get_item_group(name, "cultivatable")
		local hoe_place = place_fun[cultivatable]
		if hoe_place and not def._on_hoe_place then
			-- no _on_hoe_place on cultivatable block -> set default
			core.override_item(name, { _on_hoe_place = hoe_place })
		end
	end
end)
