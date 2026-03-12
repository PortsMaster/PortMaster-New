local S = core.get_translator(core.get_current_modname())

local boxes = { -8/16, -8/16, -8/16,  8/16, -2/16, 8/16 }
local toggle_inverted = {
	["mcl_daylight_detector:daylight_detector"] = "mcl_daylight_detector:daylight_detector_inverted",
	["mcl_daylight_detector:daylight_detector_inverted"] = "mcl_daylight_detector:daylight_detector",
}

local function update_detector(pos)
	mcl_redstone.swap_node(pos, {
		name = core.get_node(pos).name,
		param2 = core.get_natural_light(pos),
	})
	mcl_redstone._notify_observer_neighbours(pos)
end

local commdef = {
	drawtype = "nodebox",
	wield_scale = { x=1, y=1, z=3 },
	paramtype = "light",
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = boxes
	},
	node_box = {
		type = "fixed",
		fixed = boxes
	},
	groups = {handy=1,axey=1, material_wood=1, flammable=-1, daylight_detector=1, unmovable_by_piston = 1},
	sounds = mcl_sounds.node_sound_glass_defaults(),
	on_construct = function(pos)
		update_detector(pos)
	end,
	on_rightclick = function(pos, node, clicker, pointed_thing)
		local protname = clicker:get_player_name()
		if core.is_protected(pos, protname) then
			core.record_protection_violation(pos, protname)
			return
		end
		mcl_redstone.swap_node(pos, {name = toggle_inverted[node.name], param2 = node.param2})
		mcl_redstone._notify_observer_neighbours(pos)
	end,
	_mcl_hardness = 0.2,
	_mcl_redstone = {
		connects_to = function(node, dir)
			return true
		end,
	},
}

core.register_node("mcl_daylight_detector:daylight_detector", table.merge(commdef, {
	tiles = { "jeija_solar_panel.png","jeija_solar_panel.png","jeija_solar_panel_side.png",
		"jeija_solar_panel_side.png","jeija_solar_panel_side.png","jeija_solar_panel_side.png", },
	wield_image = "jeija_solar_panel.png",
	description=S("Daylight Sensor"),
	_tt_help = S("Provides redstone power when in sunlight") .. "\n" ..S("Can be inverted"),
	_doc_items_longdesc = S("Daylight detectors are redstone components which provide redstone power when they are in sunlight and no power otherwise. They can also be inverted.").."\n"..
		S("In inverted state, they provide redstone power when they are not in sunlight and no power otherwise."),
	_doc_items_usagehelp = S("Use the daylight detector to toggle its state."),
	_mcl_redstone = table.merge(commdef._mcl_redstone, {
		get_power = function(node, dir)
			return node.param2, false
		end,
	}),
}))


core.register_node("mcl_daylight_detector:daylight_detector_inverted", table.merge(commdef, {
	tiles = { "jeija_solar_panel_inverted.png","jeija_solar_panel_inverted.png","jeija_solar_panel_side.png",
	"jeija_solar_panel_side.png","jeija_solar_panel_side.png","jeija_solar_panel_side.png", },
	wield_image = "jeija_solar_panel_inverted.png",
	drop = "mcl_daylight_detector:daylight_detector",
	groups = table.merge(commdef.groups, {not_in_creative_inventory=1}),
	description=S("Inverted Daylight Sensor"),
	_doc_items_create_entry = false,
	_mcl_redstone = table.merge(commdef._mcl_redstone, {
		get_power = function(node, dir)
			return 15 - node.param2
		end,
	}),
}))


core.register_craft({
	output = "mcl_daylight_detector:daylight_detector",
	recipe = {
		{"mcl_core:glass", "mcl_core:glass", "mcl_core:glass"},
		{"mcl_nether:quartz", "mcl_nether:quartz", "mcl_nether:quartz"},
		{"group:wood_slab", "group:wood_slab", "group:wood_slab"},
	}
})

core.register_abm({
	label = "Update daylight detectors",
	nodenames = {"group:daylight_detector"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		update_detector(pos)
	end,
})

core.register_craft({
	type = "fuel",
	recipe = "mcl_daylight_detector:daylight_detector",
	burntime = 15
})

doc.add_entry_alias("nodes", "mcl_daylight_detector:daylight_detector", "nodes", "mcl_daylight_detector:solar_panel_on")
doc.add_entry_alias("nodes", "mcl_daylight_detector:daylight_detector", "nodes", "mcl_daylight_detector:solar_panel_inverted_off")
doc.add_entry_alias("nodes", "mcl_daylight_detector:daylight_detector", "nodes", "mcl_daylight_detector:solar_panel_inverted_on")
