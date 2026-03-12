local S = core.get_translator(core.get_current_modname())

mcl_flowerpots = {}

mcl_flowerpots.registered_pots = {}

local pot_box = {
	type = "fixed",
	fixed = {
		{ -0.1875, -0.5, -0.1875, 0.1875, -0.125, 0.1875 },
	},
}

local tpl_pots = {
	drawtype = "mesh",
	use_texture_alpha = "clip",
	paramtype = "light",
	sunlight_propagates = true,
	selection_box = pot_box,
	collision_box = pot_box,
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults()
}

local function check_player_protection(pos, player)
	if not (player and player:is_player()) then
		return
	end
	local name = player:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return
	end
	return name
end

local function validate_pot(itemstack)
	local name = itemstack:get_name()
	local pot = mcl_flowerpots.registered_pots[name]
	if type(pot) == "string" then
		return true, pot
	end
	return false, nil
end

local function get_item_palette(itemdefs)
	local palette = itemdefs.palette
	local param2 = itemdefs.paramtype2
	if palette and palette ~= "" then
		if param2 == "color" then
			return palette, "color"
		end
	end
end

core.register_node("mcl_flowerpots:flower_pot", table.merge(tpl_pots, {
	description = S("Flower Pot"),
	_tt_help = S("Can hold a small flower or plant"),
	_doc_items_longdesc = S("Flower pots are decorative blocks in which flowers and other small plants can be placed."),
	_doc_items_usagehelp = S("Just place a plant on the flower pot. Flower pots can hold small flowers (not higher than 1 block), saplings, ferns, dead bushes, mushrooms and cacti. Rightclick a potted plant to retrieve the plant."),
	mesh = "flower_pot.obj",
	tiles = {"mcl_flowerpots_flowerpot.png"},
	wield_image = "mcl_flowerpots_flowerpot_inventory.png",
	inventory_image = "mcl_flowerpots_flowerpot_inventory.png",
	groups = { dig_immediate = 3, deco_block = 1, attached_node = 1, dig_by_piston = 1, flower_pot = 1, unsticky = 1, pathfinder_partial = 2, },
	on_rightclick = function(pos, _, clicker, itemstack)
		local player_name = check_player_protection(pos, clicker)
		if not player_name then
			return itemstack
		end
		local valid_pot, pot = validate_pot(itemstack)
		if valid_pot then
			local new_param2
			local palette, _ = get_item_palette(itemstack:get_definition())
			if palette then
				new_param2 = mcl_util.get_pos_p2(pos)
			end
			core.swap_node(pos, {name = "mcl_flowerpots:flower_pot_" .. pot, param2 = new_param2})
			if not core.is_creative_enabled(player_name) then
				itemstack:take_item()
			end
		end
		return itemstack
	end,
}))

core.register_craft({
	output = "mcl_flowerpots:flower_pot",
	recipe = {
		{ "mcl_core:brick", "", "mcl_core:brick" },
		{ "", "mcl_core:brick", "" },
	},
})

function mcl_flowerpots.register_potted_flower(name, def)
	mcl_flowerpots.registered_pots[name] = def.name
	local palette, param2 = get_item_palette(core.registered_items[name])
	core.register_node(":mcl_flowerpots:flower_pot_" .. def.name, table.merge(tpl_pots, {
		description = def.desc .. " " .. S("Flower Pot"),
		_doc_items_create_entry = false,
		mesh = "flower_pot_plant.obj",
		tiles = {
			{name = "mcl_flowerpots_flowerpot.png", color = "white"}, def.image
		},
		groups = { dig_immediate = 3, attached_node = 1, dig_by_piston = 1, not_in_creative_inventory = 1, flower_pot = 2, unsticky = 1},
		on_rightclick = function(pos, node, clicker, itemstack)
			local player_name = check_player_protection(pos, clicker)
			if not player_name then
				return itemstack
			end
			local creative = core.is_creative_enabled(player_name)
			local _, pot = validate_pot(itemstack)
			local same_pot = pot and node.name == "mcl_flowerpots:flower_pot_" .. pot
			if not same_pot or creative then
				core.swap_node(pos, {name = "mcl_flowerpots:flower_pot"})
				if not creative then
					local stack = ItemStack(name)
					local inventory = clicker:get_inventory()
					if inventory:room_for_item("main", stack) then
						inventory:add_item("main", stack)
					elseif not itemstack:is_empty() then
						core.add_item(pos, stack)
					else
						return stack
					end
					return inventory:get_stack("main", clicker:get_wield_index())
				end
			end
			return itemstack
		end,
		drop = {
			items = {
				{ items = { "mcl_flowerpots:flower_pot", name } },
			},
		},
		_mcl_baseitem = name,
		palette = palette,
		paramtype2 = param2
	}))
	doc.add_entry_alias("nodes", "mcl_flowerpots:flower_pot", "nodes", "mcl_flowerpots:flower_pot_" .. def.name)
end

function mcl_flowerpots.register_potted_cube(name, def)
	mcl_flowerpots.registered_pots[name] = def.name
	core.register_node(":mcl_flowerpots:flower_pot_" .. def.name, table.merge(tpl_pots, {
		description = def.desc .. " " .. S("Flower Pot"),
		_doc_items_create_entry = false,
		mesh = "flowerpot_with_long_cube.obj",
		tiles = {
			def.image,
		},
		groups = { dig_immediate = 3, attached_node = 1, dig_by_piston = 1, not_in_creative_inventory = 1, flower_pot = 2, unsticky = 1},
		on_rightclick = function(pos, node, clicker, itemstack)
			local player_name = check_player_protection(pos, clicker)
			if not player_name then
				return itemstack
			end
			local creative = core.is_creative_enabled(player_name)
			local _, pot = validate_pot(itemstack)
			local same_pot = pot and node.name == "mcl_flowerpots:flower_pot_" .. pot
			if not same_pot or creative then
				core.swap_node(pos, {name = "mcl_flowerpots:flower_pot"})
				if not creative then
					local stack = ItemStack(name)
					local inventory = clicker:get_inventory()
					if inventory:room_for_item("main", stack) then
						inventory:add_item("main", stack)
					elseif not itemstack:is_empty() then
						core.add_item(pos, stack)
					else
						return stack
					end
					return inventory:get_stack("main", clicker:get_wield_index())
				end
			end
			return itemstack
		end,
		drop = {
			items = {
				{ items = { "mcl_flowerpots:flower_pot", name } },
			},
		},
		_mcl_baseitem = name,
	}))
	doc.add_entry_alias("nodes", "mcl_flowerpots:flower_pot", "nodes", "mcl_flowerpots:flower_pot_" .. def.name)
end
