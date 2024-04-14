local S = minetest.get_translator(minetest.get_current_modname())

local function sunlight_visible(position)
	local light_level = minetest.get_natural_light(position)
	return light_level ~= nil and light_level >= 12
end

local boxes = { -8/16, -8/16, -8/16,  8/16, -2/16, 8/16 }

-- Daylight Sensor
minetest.register_node("mesecons_solarpanel:solar_panel_on", {
	drawtype = "nodebox",
	tiles = { "jeija_solar_panel.png","jeija_solar_panel.png","jeija_solar_panel_side.png",
	"jeija_solar_panel_side.png","jeija_solar_panel_side.png","jeija_solar_panel_side.png", },
	wield_image = "jeija_solar_panel.png",
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
	drop = "mesecons_solarpanel:solar_panel_off",
	_doc_items_create_entry = false,
	groups = {handy=1,axey=1, not_in_creative_inventory = 1, material_wood=1, flammable=-1},
	sounds = mcl_sounds.node_sound_glass_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = mesecon.rules.pplate,
	}},
	on_rightclick = function(pos, node, clicker, pointed_thing)
		local protname = clicker:get_player_name()
		if minetest.is_protected(pos, protname) then
			minetest.record_protection_violation(pos, protname)
			return
		end
		minetest.swap_node(pos, {name = "mesecons_solarpanel:solar_panel_inverted_off"})
		mesecon.receptor_off(pos, mesecon.rules.pplate)
	end,
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
})

minetest.register_node("mesecons_solarpanel:solar_panel_off", {
	drawtype = "nodebox",
	tiles = { "jeija_solar_panel.png","jeija_solar_panel.png","jeija_solar_panel_side.png",
	"jeija_solar_panel_side.png","jeija_solar_panel_side.png","jeija_solar_panel_side.png", },
	wield_image = "jeija_solar_panel.png",
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
	groups = {handy=1,axey=1, material_wood=1},
	description=S("Daylight Sensor"),
	_tt_help = S("Provides redstone power when in sunlight") .. "\n" ..S("Can be inverted"),
	_doc_items_longdesc = S("Daylight sensors are redstone components which provide redstone power when they are in sunlight and no power otherwise. They can also be inverted.").."\n"..
		S("In inverted state, they provide redstone power when they are not in sunlight and no power otherwise."),
	_doc_items_usagehelp = S("Use the daylight sensor to toggle its state."),
	sounds = mcl_sounds.node_sound_glass_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = mesecon.rules.pplate,
	}},
	on_rightclick = function(pos, node, clicker, pointed_thing)
		local protname = clicker:get_player_name()
		if minetest.is_protected(pos, protname) then
			minetest.record_protection_violation(pos, protname)
			return
		end
		minetest.swap_node(pos, {name = "mesecons_solarpanel:solar_panel_inverted_on"})
		mesecon.receptor_on(pos, mesecon.rules.pplate)
	end,
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
})

minetest.register_craft({
	output = "mesecons_solarpanel:solar_panel_off",
	recipe = {
		{"mcl_core:glass", "mcl_core:glass", "mcl_core:glass"},
		{"mcl_nether:quartz", "mcl_nether:quartz", "mcl_nether:quartz"},
		{"group:wood_slab", "group:wood_slab", "group:wood_slab"},
	}
})

minetest.register_abm({
	label = "Daylight turns on solar panels",
	nodenames = {"mesecons_solarpanel:solar_panel_off"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if sunlight_visible(pos) then
			minetest.set_node(pos, {name="mesecons_solarpanel:solar_panel_on", param2=node.param2})
			mesecon.receptor_on(pos, mesecon.rules.pplate)
		end
	end,
})

minetest.register_abm({
	label = "Darkness turns off solar panels",
	nodenames = {"mesecons_solarpanel:solar_panel_on"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if not sunlight_visible(pos) then
			minetest.set_node(pos, {name="mesecons_solarpanel:solar_panel_off", param2=node.param2})
			mesecon.receptor_off(pos, mesecon.rules.pplate)
		end
	end,
})

--- Inverted Daylight Sensor

minetest.register_node("mesecons_solarpanel:solar_panel_inverted_on", {
	drawtype = "nodebox",
	tiles = { "jeija_solar_panel_inverted.png","jeija_solar_panel_inverted.png","jeija_solar_panel_side.png",
	"jeija_solar_panel_side.png","jeija_solar_panel_side.png","jeija_solar_panel_side.png", },
	wield_image = "jeija_solar_panel_inverted.png",
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
	drop = "mesecons_solarpanel:solar_panel_off",
	groups = {handy=1,axey=1, not_in_creative_inventory = 1, material_wood=1},
	_doc_items_create_entry = false,
	sounds = mcl_sounds.node_sound_glass_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = mesecon.rules.pplate,
	}},
	on_rightclick = function(pos, node, clicker, pointed_thing)
		local protname = clicker:get_player_name()
		if minetest.is_protected(pos, protname) then
			minetest.record_protection_violation(pos, protname)
			return
		end
		minetest.swap_node(pos, {name = "mesecons_solarpanel:solar_panel_off"})
		mesecon.receptor_off(pos, mesecon.rules.pplate)
	end,
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
})

minetest.register_node("mesecons_solarpanel:solar_panel_inverted_off", {
	drawtype = "nodebox",
	tiles = { "jeija_solar_panel_inverted.png","jeija_solar_panel_inverted.png","jeija_solar_panel_side.png",
	"jeija_solar_panel_side.png","jeija_solar_panel_side.png","jeija_solar_panel_side.png", },
	wield_image = "jeija_solar_panel_inverted.png",
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
	drop = "mesecons_solarpanel:solar_panel_off",
	groups = {handy=1,axey=1, not_in_creative_inventory=1, material_wood=1},
	description=S("Inverted Daylight Sensor"),
	_doc_items_create_entry = false,
	sounds = mcl_sounds.node_sound_glass_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = mesecon.rules.pplate,
	}},
	on_rightclick = function(pos, node, clicker, pointed_thing)
		local protname = clicker:get_player_name()
		if minetest.is_protected(pos, protname) then
			minetest.record_protection_violation(pos, protname)
			return
		end
		minetest.swap_node(pos, {name = "mesecons_solarpanel:solar_panel_on"})
		mesecon.receptor_on(pos, mesecon.rules.pplate)
	end,
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
})

minetest.register_abm({
	label = "Darkness turns on inverted solar panels",
	nodenames = {"mesecons_solarpanel:solar_panel_inverted_off"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if not sunlight_visible(pos) then
			minetest.set_node(pos, {name="mesecons_solarpanel:solar_panel_inverted_on", param2=node.param2})
			mesecon.receptor_on(pos, mesecon.rules.pplate)
		end
	end,
})

minetest.register_abm({
	label = "Daylight turns off inverted solar panels",
	nodenames = {"mesecons_solarpanel:solar_panel_inverted_on"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if sunlight_visible(pos) then
			minetest.set_node(pos, {name="mesecons_solarpanel:solar_panel_inverted_off", param2=node.param2})
			mesecon.receptor_off(pos, mesecon.rules.pplate)
		end
	end,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mesecons_solarpanel:solar_panel_off",
	burntime = 15
})

if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_solarpanel:solar_panel_off", "nodes", "mesecons_solarpanel:solar_panel_on")
	doc.add_entry_alias("nodes", "mesecons_solarpanel:solar_panel_off", "nodes", "mesecons_solarpanel:solar_panel_inverted_off")
	doc.add_entry_alias("nodes", "mesecons_solarpanel:solar_panel_off", "nodes", "mesecons_solarpanel:solar_panel_inverted_off")
	doc.add_entry_alias("nodes", "mesecons_solarpanel:solar_panel_off", "nodes", "mesecons_solarpanel:solar_panel_inverted_on")
end
