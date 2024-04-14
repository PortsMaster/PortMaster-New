local S = minetest.get_translator(minetest.get_current_modname())
local has_doc = minetest.get_modpath("doc")

mcl_flowerpots = {}

mcl_flowerpots.registered_pots = {}

local pot_box = {
	type = "fixed",
	fixed = {
		{ -0.1875, -0.5, -0.1875, 0.1875, -0.125, 0.1875 },
	},
}

minetest.register_node("mcl_flowerpots:flower_pot", {
	description = S("Flower Pot"),
	_tt_help = S("Can hold a small flower or plant"),
	_doc_items_longdesc = S("Flower pots are decorative blocks in which flowers and other small plants can be placed."),
	_doc_items_usagehelp = S("Just place a plant on the flower pot. Flower pots can hold small flowers (not higher than 1 block), saplings, ferns, dead bushes, mushrooms and cacti. Rightclick a potted plant to retrieve the plant."),
	drawtype = "mesh",
	mesh = "flowerpot.obj",
	tiles = {
		"mcl_flowerpots_flowerpot.png",
	},
	use_texture_alpha = "clip",
	visual_scale = 0.5,
	wield_image = "mcl_flowerpots_flowerpot_inventory.png",
	paramtype = "light",
	sunlight_propagates = true,
	selection_box = pot_box,
	collision_box = pot_box,
	is_ground_content = false,
	inventory_image = "mcl_flowerpots_flowerpot_inventory.png",
	groups = { dig_immediate = 3, deco_block = 1, attached_node = 1, dig_by_piston = 1, flower_pot = 1 },
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack)
		local name = clicker:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return
		end
		local item = clicker:get_wielded_item():get_name()
		if mcl_flowerpots.registered_pots[item] then
			minetest.swap_node(pos, { name = "mcl_flowerpots:flower_pot_" .. mcl_flowerpots.registered_pots[item] })
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				itemstack:take_item()
			end
		end
	end,
})

minetest.register_craft({
	output = "mcl_flowerpots:flower_pot",
	recipe = {
		{ "mcl_core:brick", "", "mcl_core:brick" },
		{ "", "mcl_core:brick", "" },
		{ "", "", "" },
	},
})

function mcl_flowerpots.register_potted_flower(name, def)
	mcl_flowerpots.registered_pots[name] = def.name
	minetest.register_node(":mcl_flowerpots:flower_pot_" .. def.name, {
		description = def.desc .. " " .. S("Flower Pot"),
		_doc_items_create_entry = false,
		drawtype = "mesh",
		mesh = "flowerpot.obj",
		tiles = {
			"[combine:32x32:0,0=mcl_flowerpots_flowerpot.png:0,0=" .. def.image,
		},
		use_texture_alpha = "clip",
		visual_scale = 0.5,
		paramtype = "light",
		sunlight_propagates = true,
		selection_box = pot_box,
		collision_box = pot_box,
		is_ground_content = false,
		groups = { dig_immediate = 3, attached_node = 1, dig_by_piston = 1, not_in_creative_inventory = 1, flower_pot = 2 },
		sounds = mcl_sounds.node_sound_stone_defaults(),
		on_rightclick = function(pos, item, clicker)
			local player_name = clicker:get_player_name()
			if minetest.is_protected(pos, player_name) then
				minetest.record_protection_violation(pos, player_name)
				return
			end
			minetest.add_item(vector.offset(pos, 0, 0.5, 0), name)
			minetest.set_node(pos, { name = "mcl_flowerpots:flower_pot" })
		end,
		drop = {
			items = {
				{ items = { "mcl_flowerpots:flower_pot", name } },
			},
		},
	})
	-- Add entry alias for the Help
	if has_doc then
		doc.add_entry_alias("nodes", "mcl_flowerpots:flower_pot", "nodes", "mcl_flowerpots:flower_pot_" .. name)
	end
end

function mcl_flowerpots.register_potted_cube(name, def)
	mcl_flowerpots.registered_pots[name] = def.name
	minetest.register_node(":mcl_flowerpots:flower_pot_" .. def.name, {
		description = def.desc .. " " .. S("Flower Pot"),
		_doc_items_create_entry = false,
		drawtype = "mesh",
		mesh = "flowerpot_with_long_cube.obj",
		tiles = {
			def.image,
		},
		use_texture_alpha = "clip",
		visual_scale = 0.5,
		paramtype = "light",
		sunlight_propagates = true,
		selection_box = pot_box,
		collision_box = pot_box,
		is_ground_content = false,
		groups = { dig_immediate = 3, attached_node = 1, dig_by_piston = 1, not_in_creative_inventory = 1, flower_pot = 2 },
		sounds = mcl_sounds.node_sound_stone_defaults(),
		on_rightclick = function(pos, item, clicker)
			local player_name = ""
			if clicker:is_player() then
				player_name = clicker:get_player_name()
			end
			if minetest.is_protected(pos, player_name) then
				minetest.record_protection_violation(pos, player_name)
				return
			end
			minetest.add_item(vector.offset(pos, 0, 0.5, 0), name)
			minetest.set_node(pos, { name = "mcl_flowerpots:flower_pot" })
		end,
		drop = {
			items = {
				{ items = { "mcl_flowerpots:flower_pot", name } },
			},
		},
	})
	-- Add entry alias for the Help
	if has_doc then
		doc.add_entry_alias("nodes", "mcl_flowerpots:flower_pot", "nodes", "mcl_flowerpots:flower_pot_" .. def.name)
	end
end
