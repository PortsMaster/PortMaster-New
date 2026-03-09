local S = core.get_translator("mcl_lightning_rods")
local D = mcl_util.get_dynamic_translator()

local cbox = {
	type = "fixed",
	fixed = {
		{ -0.0625, -0.5, -0.0625, 0.0625, 0.25, 0.0625 },
		{ -0.125, 0.25, -0.125, 0.125, 0.5, 0.125 },
	},
}

local rod_def = {
	description = S("Lightning Rod"),
	_doc_items_longdesc = S("A block that attracts lightning"),
	tiles = { "mcl_lightning_rods_rod.png" },
	drawtype = "mesh",
	mesh = "mcl_lightning_rods_rod.obj",
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { pickaxey = 2, attracts_lightning = 1 },
	sounds = mcl_sounds.node_sound_metal_defaults(),
	selection_box = cbox,
	collision_box = cbox,
	node_placement_prediction = "",
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local param2 = 0

		local placer_pos = placer:get_pos()
		if placer_pos then
			param2 = core.dir_to_facedir(vector.subtract(p1, placer_pos))
		end

		if p0.y - 1 == p1.y then
			param2 = 20
		elseif p0.x - 1 == p1.x then
			param2 = 16
		elseif p0.x + 1 == p1.x then
			param2 = 12
		elseif p0.z - 1 == p1.z then
			param2 = 8
		elseif p0.z + 1 == p1.z then
			param2 = 4
		end

		return core.item_place(itemstack, placer, pointed_thing, param2)
	end,

	_mcl_blast_resistance = 6,
	_mcl_hardness = 3,

	_mcl_rod_powered_variant = "mcl_lightning_rods:rod_powered"
}

local rod_powered_def = {
	tiles = { "mcl_lightning_rods_rod.png^[brighten" },
	groups = {pickaxey = 2, attracts_lightning = 1, not_in_creative_inventory = 1},
	_mcl_redstone = {
		init = function(pos, node)
			local ndef = core.registered_nodes[node.name]
			return {
				delay = 4,
				name = ndef._mcl_rod_unpowered_variant
			}
		end,
		get_power = function(node, dir)
			return 15, true
		end
	},
	_mcl_rod_unpowered_variant = "mcl_lightning_rods:rod"
}

mcl_lightning.register_on_strike(function(pos, pos2, objects, for_trap)
	if for_trap then
		return false
	end
	local lr = core.find_nodes_in_area_under_air(vector.offset(pos, -64, -32, -64), vector.offset(pos, 64, 64, 64), { "group:attracts_lightning" }, true)
	lr = (lr and #lr > 0 and lr[1]) or false
	if lr then
		local node = core.get_node(lr)
		local ndef = core.registered_nodes[node.name]

		if ndef._mcl_rod_powered_variant then
			node.name = ndef._mcl_rod_powered_variant
			core.set_node(lr, node)
		end
	end

	return lr, nil
end)

core.register_node("mcl_lightning_rods:rod", rod_def)

core.register_node("mcl_lightning_rods:rod_powered", table.merge(rod_def, rod_powered_def))

core.register_node("mcl_lightning_rods:rod_exposed", table.merge(rod_def, {
	description = D("Exposed Lightning Rod"),
	tiles = { "mcl_lightning_rods_rod_exposed.png" },
	_mcl_rod_powered_variant = "mcl_lightning_rods:rod_exposed_powered"
}))

core.register_node("mcl_lightning_rods:rod_exposed_powered", table.merge(rod_def, rod_powered_def, {
	tiles = { "mcl_lightning_rods_rod_exposed.png^[brighten" },
	_mcl_rod_unpowered_variant = "mcl_lightning_rods:rod_exposed"
}))

core.register_node("mcl_lightning_rods:rod_weathered", table.merge(rod_def, {
	description = D("Weathered Lightning Rod"),
	tiles = { "mcl_lightning_rods_rod_weathered.png" },
	_mcl_rod_powered_variant = "mcl_lightning_rods:rod_weathered_powered"
}))

core.register_node("mcl_lightning_rods:rod_weathered_powered", table.merge(rod_def, rod_powered_def, {
	tiles = { "mcl_lightning_rods_rod_weathered.png^[brighten" },
	_mcl_rod_unpowered_variant = "mcl_lightning_rods:rod_weathered"
}))

-- Oxidized Lightning Rod
core.register_node("mcl_lightning_rods:rod_oxidized", table.merge(rod_def, {
	description = D("Oxidized Lightning Rod"),
	tiles = { "mcl_lightning_rods_rod_oxidized.png" },
	_mcl_rod_powered_variant = "mcl_lightning_rods:rod_oxidized_powered"
}))

core.register_node("mcl_lightning_rods:rod_oxidized_powered", table.merge(rod_def, rod_powered_def, {
	tiles = { "mcl_lightning_rods_rod_oxidized.png^[brighten" },
	_mcl_rod_unpowered_variant = "mcl_lightning_rods:rod_oxidized"
}))

mcl_copper.register_decaychain("lightning_rod",{
	preserve_group = "preserves_copper",
	unpreserve_callback = "_on_axe_place",
	undecay_callback = "_on_axe_place",
	nodes = {
			"mcl_lightning_rods:rod",
			"mcl_lightning_rods:rod_exposed",
			"mcl_lightning_rods:rod_weathered",
			"mcl_lightning_rods:rod_oxidized",
	},
})
