---------------
---- Honey ----
---------------

-- Variables
local S = core.get_translator(core.get_current_modname())

-- Honeycomb
core.register_craftitem("mcl_honey:honeycomb", {
	_dispense_into_walkable = true,
	_on_dispense = function(stack, _, droppos, dropnode)
		if not dropnode.name:find("_preserved") then
			local new_name = dropnode.name .. "_preserved"

			if core.registered_nodes[new_name] then
				mcl_copper.spawn_particles(droppos, "mcl_copper_anti_oxidation_particle.png^[colorize:#d1d553:125")
				core.swap_node(droppos, {name = new_name, param2 = dropnode.param2})
				stack:take_item()
			end
		end
		return stack
	end,
	description = S("Honeycomb"),
	_doc_items_longdesc = S("Used to craft beehives and protect copper blocks from further oxidation."),
	_doc_items_usagehelp = S("Use on copper blocks to prevent further oxidation."),
	inventory_image = "mcl_honey_honeycomb.png",
	groups = { craftitem = 1, preserves_copper = 1 },
	_mcl_crafting_output = {square2 = {output = "mcl_honey:honeycomb_block"}}
})

core.register_node("mcl_honey:honeycomb_block", {
	description = S("Honeycomb Block"),
	_doc_items_longdesc = S("Honeycomb Block. Used as a decoration."),
	tiles = {
		"mcl_honey_honeycomb_block.png"
	},
	is_ground_content = false,
	groups = { handy = 1, deco_block = 1 },
	_mcl_hardness = 0.6,
})

-- Honey
core.register_craftitem("mcl_honey:honey_bottle", {
	description = S("Honey Bottle"),
	_doc_items_longdesc = S("Honey Bottle is used to craft honey blocks and to restore hunger points."),
	_doc_items_usagehelp = S("Drinking will restore 6 hunger points. Can also be used to craft honey blocks."),
	inventory_image = "mcl_honey_honey_bottle.png",
	groups = { craftitem = 1, food = 3, eatable = 6, can_eat_when_full=1 },
	_mcl_saturation = 1.2,
	_mcl_eat_replace_with = "mcl_potions:glass_bottle",
	stack_max = 16,
	_mcl_crafting_output = {
		single = {
			output = "mcl_core:sugar 3",
			replacements = {
				{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" }
			}
		},
		square2 = {
			output = "mcl_honey:honey_block",
			replacements = {
				{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" },
				{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" },
				{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" },
				{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" },
			}
		}
	}
})

core.register_node("mcl_honey:honey_block", {
	description = S("Honey Block"),
	_doc_items_longdesc = S("Honey Block. Used as a decoration and in redstone. Is sticky on some sides."),
	tiles = {"mcl_honey_block_side.png"},
	is_ground_content = false,
	use_texture_alpha = "blend",
	groups = { handy = 1, deco_block = 1, fall_damage_add_percent = -80, pathfinder_partial = 2, },
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4, -0.4, -0.4, 0.4, 0.4, 0.4},
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		}
	},
	selection_box = {
		type = "regular",
	},
	_mcl_hardness = 0,
	_mcl_pistons_sticky = function(node, node_to, dir)
		return node_to.name ~= "mcl_core:slimeblock"
	end,
})

-- Crafting
core.register_craft({
	output = "mcl_honey:honey_bottle 4",
	recipe = {
		{ "mcl_potions:glass_bottle", "mcl_potions:glass_bottle", "mcl_honey:honey_block" },
		{ "mcl_potions:glass_bottle", "mcl_potions:glass_bottle", "" },
	},
})
