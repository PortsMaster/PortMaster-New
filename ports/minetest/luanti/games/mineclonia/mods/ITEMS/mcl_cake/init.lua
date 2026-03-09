local S = core.get_translator(core.get_current_modname())

local CAKE_HUNGER_POINTS = 2
local CAKE_SATURATION_POINTS = 0.4

local cake_boxes = {
	slices = {
		{-0.4375, -0.5, -0.4375, -0.3125, 0, 0.4375},
		{-0.4375, -0.5, -0.4375, -0.1875, 0, 0.4375},
		{-0.4375, -0.5, -0.4375, -0.0625, 0, 0.4375},
		{-0.4375, -0.5, -0.4375, 0.0625, 0, 0.4375},
		{-0.4375, -0.5, -0.4375, 0.1875, 0, 0.4375},
		{-0.4375, -0.5, -0.4375, 0.3125, 0, 0.4375}
	},
	full_cake = {-0.4375, -0.5, -0.4375, 0.4375, 0, 0.4375}
}

local cake_groups = {
	handy = 1, attached_node = 1, dig_by_piston = 1, unsticky = 1
}

local tpl_cake = {
	description = S("Cake"),
	paramtype = "light",
	is_ground_content = false,
	drawtype = "nodebox",
	stack_max = 1,
	drop = "",
	sounds = mcl_sounds.node_sound_wool_defaults(),
	_mcl_saturation = CAKE_SATURATION_POINTS,
	_mcl_hardness = 0.5,
	on_rightclick = function(pos, node, clicker)
		if not mcl_util.check_position_protection(pos, clicker) then
			local name = clicker:get_player_name()
			local cake = core.get_item_group(node.name, "cake")

			-- Eat only when you are hungry or in creative mode
			if not mcl_hunger.is_player_full(clicker) or core.is_creative_enabled(name) then
				if cake == 1 then
					core.remove_node(pos)
					core.check_for_falling(pos)
					mcl_redstone.update_comparators(pos)
				else
					mcl_redstone.swap_node(pos, {name = "mcl_cake:cake_" .. cake - 1})
				end

				core.do_item_eat(CAKE_HUNGER_POINTS, nil, ItemStack(node.name), clicker, {type = "nothing"})
			end
		end
	end,
	_mcl_spawn_food_particles = false,
}

core.register_node("mcl_cake:cake", table.merge(tpl_cake, {
	_tt_help = S("With 7 tasty slices! Hunger points: +@1 per slice", CAKE_HUNGER_POINTS),
	_doc_items_longdesc = S("Cakes can be placed and eaten to restore hunger points. A cake has 7 slices. Each slice restores @1 hunger points and @2 saturation points. Cakes will be destroyed when dug or when the block below them is broken.", CAKE_HUNGER_POINTS, CAKE_SATURATION_POINTS),
	_doc_items_usagehelp = S("Place the cake anywhere, then rightclick it to eat a single slice. You can't eat from the cake when your hunger bar is full."),
	tiles = {"cake_top.png", "cake_bottom.png", "cake_side.png"},
	inventory_image = "cake.png",
	wield_image = "cake.png",
	selection_box = {
		type = "fixed",
		fixed = cake_boxes.full_cake
	},
	node_box = {
		type = "fixed",
		fixed = cake_boxes.full_cake
	},
	groups = table.merge(cake_groups, {comparator_signal = 14, cake = 7, compostability = 100})
}))

for i = 1, 6 do
	local name = "mcl_cake:cake_"..i

	core.register_node(name, table.merge(tpl_cake, {
		_doc_items_create_entry = false,
		tiles = {"cake_top.png", "cake_bottom.png", "cake_inner.png", "cake_side.png"},
		selection_box = {
			type = "fixed",
			fixed = cake_boxes.slices[i]
		},
		node_box = {
			type = "fixed",
			fixed = cake_boxes.slices[i]
		},
		groups = table.merge(cake_groups, {
			comparator_signal = i * 2, not_in_creative_inventory = 1, cake = i
		})
	}))

	doc.add_entry_alias("nodes", "mcl_cake:cake", "nodes", name)
end

core.register_craft({
	output = "mcl_cake:cake",
	recipe = {
		{"mcl_mobitems:milk_bucket", "mcl_mobitems:milk_bucket", "mcl_mobitems:milk_bucket"},
		{"mcl_core:sugar", "mcl_throwing:egg", "mcl_core:sugar"},
		{"mcl_farming:wheat_item", "mcl_farming:wheat_item", "mcl_farming:wheat_item"},
	},
	replacements = {
		{"mcl_mobitems:milk_bucket", "mcl_buckets:bucket_empty"},
		{"mcl_mobitems:milk_bucket", "mcl_buckets:bucket_empty"},
		{"mcl_mobitems:milk_bucket", "mcl_buckets:bucket_empty"},
	}
})
