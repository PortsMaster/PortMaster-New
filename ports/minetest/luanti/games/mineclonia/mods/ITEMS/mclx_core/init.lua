local S = core.get_translator(core.get_current_modname())
local water_s = core.registered_nodes["mcl_core:water_source"]
local water_f = core.registered_nodes["mcl_core:water_flowing"]
core.register_node("mclx_core:river_water_source", table.merge(water_s, {
	description = S("River Water Source"),
	liquidtype = "source",
	groups = table.merge(water_s.groups, {river_water = water_s.groups.water}),
	liquid_range = 2,
	waving = 3,
	liquid_alternative_flowing = "mclx_core:river_water_flowing",
	liquid_alternative_source = "mclx_core:river_water_source",
	liquid_renewable = false,
	_doc_items_longdesc = S("River water has the same properties as water, but has a reduced flowing distance and is not renewable."),
	_doc_items_entry_name = S("River Water"),
	_doc_items_hidden = core.get_mapgen_setting("mg_name") ~= "valleys",
	_on_bottle_place = mcl_core.get_bottle_place_on_water("mcl_potions:river_water"),
	post_effect_color = {a=192, r=0x2c, g=0x88, b=0x8c},
	tiles = {
		{name="default_river_water_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0}}
	},
	special_tiles = {
		{
			name="default_river_water_source_animated.png",
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0},
			backface_culling = false,
		}
	},
}))

core.register_node("mclx_core:river_water_flowing", table.merge(water_f, {
	description = S("Flowing River Water"),
	groups = table.merge(water_f.groups, {river_water = water_f.groups.water}),
	liquid_range = 2,
	waving = 3,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mclx_core:river_water_flowing",
	liquid_alternative_source = "mclx_core:river_water_source",
	liquid_renewable = false,
	tiles = {"default_river_water_flowing_animated.png^[verticalframe:64:0"},
	post_effect_color = {a=192, r=0x2c, g=0x88, b=0x8c},
	_on_bottle_place = mcl_core.get_bottle_place_on_water("mcl_potions:river_water"),
	special_tiles = {
		{
			name = "default_river_water_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
		},
		{
			name = "default_river_water_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
		},
	}
}))

doc.add_entry_alias("nodes", "mclx_core:river_water_source", "nodes", "mclx_core:river_water_flowing")


mcl_liquids.register_liquid({
	name_flowing = "mclx_core:river_water_flowing",
	name_source = "mclx_core:river_water_source",

	tick_duration = 1.0 / 4.0,
	range_spread = 2,
	renewable = false,

})

