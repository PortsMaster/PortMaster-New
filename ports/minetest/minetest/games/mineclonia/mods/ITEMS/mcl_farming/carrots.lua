local S = minetest.get_translator(minetest.get_current_modname())

local function on_bone_meal(itemstack,placer,pointed_thing,pos,node)
	return mcl_farming.on_bone_meal(itemstack,placer,pointed_thing,pos,node,"plant_carrot")
end

for i=1, 7 do
	local texture, sel_height
	if i < 3 then
		sel_height = -0.5+(2/16)
		texture = "farming_carrot_1.png"
	elseif i < 5 then
		sel_height = -0.5+(4/16)
		texture = "farming_carrot_2.png"
	else
		sel_height = -0.5+(6/16)
		texture = "farming_carrot_3.png"
	end

	local create, name, longdesc
	if i == 1 then
		create = true
		name = S("Premature Carrot Plant")
		longdesc = S("Carrot plants are plants which grow on farmland under sunlight in 8 stages, but only 4 stages can be visually told apart. On hydrated farmland, they grow a bit faster. They can be harvested at any time but will only yield a profit when mature.")
	else
		create = false
	end
	minetest.register_node("mcl_farming:carrot_"..i, {
		description = S("Premature Carrot Plant (Stage @1)", i),
		_doc_items_create_entry = create,
		_doc_items_entry_name = name,
		_doc_items_longdesc = longdesc,
		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "meshoptions",
		place_param2 = 3,
		walkable = false,
		drawtype = "plantlike",
		drop = "mcl_farming:carrot_item",
		tiles = {texture},
		inventory_image = texture,
		wield_image = texture,
		selection_box = {
			type = "fixed",
			fixed = {
				{-7/16, -0.5 ,-7/16, 7/16, sel_height ,7/16}
			},
		},
		groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0,
		_on_bone_meal = on_bone_meal,
	})
end

minetest.register_node("mcl_farming:carrot", {
	description = S("Mature Carrot Plant"),
	_doc_items_longdesc = S("Mature carrot plants are ready to be harvested for carrots. They won't grow any further."),
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "meshoptions",
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	tiles = {"farming_carrot_4.png"},
	inventory_image = "farming_carrot_4.png",
	wield_image = "farming_carrot_4.png",
	drop = {
		max_items = 1,
		items = {
			{ items = {"mcl_farming:carrot_item 4"}, rarity = 5 },
			{ items = {"mcl_farming:carrot_item 3"}, rarity = 2 },
			{ items = {"mcl_farming:carrot_item 2"}, rarity = 2 },
			{ items = {"mcl_farming:carrot_item 1"} },
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-7/16, -0.5 ,-7/16, 7/16, -0.5+(8/16) ,7/16}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_on_bone_meal = on_bone_meal,
	_mcl_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"mcl_farming:carrot_item"},
		min_count = 2,
		max_count = 4,
		cap = 5,
	}
})

minetest.register_craftitem("mcl_farming:carrot_item", {
	description = S("Carrot"),
	_tt_help = S("Grows on farmland"),
	_doc_items_longdesc = S("Carrots can be eaten and planted. Pigs and rabbits like carrots."),
	_doc_items_usagehelp = S("Hold it in your hand and rightclick to eat it. Place it on top of farmland to plant the carrot. It grows in sunlight and grows faster on hydrated farmland. Rightclick an animal to feed it."),
	inventory_image = "farming_carrot.png",
	groups = {food = 2, eatable = 3, compostability = 65},
	_mcl_saturation = 3.6,
	on_secondary_use = minetest.item_eat(3),
	on_place = function(itemstack, placer, pointed_thing)
		local new = mcl_farming:place_seed(itemstack, placer, pointed_thing, "mcl_farming:carrot_1")
		if new then
			return new
		else
			return minetest.do_item_eat(3, nil, itemstack, placer, pointed_thing)
		end
	end,
})

minetest.register_craftitem("mcl_farming:carrot_item_gold", {
	description = S("Golden Carrot"),
	_doc_items_longdesc = S("A golden carrot is a precious food item which can be eaten. It is really, really filling!"),
	inventory_image = "farming_carrot_gold.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	groups = { brewitem = 1, food = 2, eatable = 6 },
	_mcl_saturation = 14.4,
})

minetest.register_craft({
	output = "mcl_farming:carrot_item_gold",
	recipe = {
		{"mcl_core:gold_nugget", "mcl_core:gold_nugget", "mcl_core:gold_nugget"},
		{"mcl_core:gold_nugget", "mcl_farming:carrot_item", "mcl_core:gold_nugget"},
		{"mcl_core:gold_nugget", "mcl_core:gold_nugget", "mcl_core:gold_nugget"},
	}
})

mcl_farming:add_plant("plant_carrot", "mcl_farming:carrot", {"mcl_farming:carrot_1", "mcl_farming:carrot_2", "mcl_farming:carrot_3", "mcl_farming:carrot_4", "mcl_farming:carrot_5", "mcl_farming:carrot_6", "mcl_farming:carrot_7"}, 25, 20)

if minetest.get_modpath("doc") then
	for i=2,7 do
		doc.add_entry_alias("nodes", "mcl_farming:carrot_1", "nodes", "mcl_farming:carrot_"..i)
	end
end
