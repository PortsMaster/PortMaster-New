local S = minetest.get_translator(minetest.get_current_modname())

local mod_doc = minetest.get_modpath("doc")

-- List of supported surfaces for seagrass
local surfaces = {
	{ "dirt", "mcl_core:dirt" },
	{ "sand", "mcl_core:sand", 1 },
	{ "redsand", "mcl_core:redsand", 1 },
	{ "gravel", "mcl_core:gravel", 1 },
}

local function seagrass_on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer then
		return itemstack
	end

	local player_name = placer:get_player_name()
	local pos_under = pointed_thing.under
	local pos_above = pointed_thing.above
	local node_under = minetest.get_node(pos_under)
	local node_above = minetest.get_node(pos_above)
	local def_above = minetest.registered_nodes[node_above.name]

	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	if pos_under.y >= pos_above.y then
		return itemstack
	end

	-- Placement rules:
	-- Seagrass can only be placed on top of dirt inside water
	local g_above_water = minetest.get_item_group(node_above.name, "water")
	if not (g_above_water ~= 0 and def_above.liquidtype == "source") then
		return itemstack
	end

	if minetest.is_protected(pos_under, player_name) or
			minetest.is_protected(pos_above, player_name) then
		minetest.log("action", player_name
			.. " tried to place " .. itemstack:get_name()
			.. " at protected position "
			.. minetest.pos_to_string(pos_under))
		minetest.record_protection_violation(pos_under, player_name)
		return itemstack
	end

	-- Select a seagrass node
	if node_under.name == "mcl_core:dirt" then
		node_under.name = "mcl_ocean:seagrass_dirt"
	elseif node_under.name == "mcl_core:sand" then
		node_under.name = "mcl_ocean:seagrass_sand"
	elseif node_under.name == "mcl_core:redsand" then
		node_under.name = "mcl_ocean:seagrass_redsand"
	elseif node_under.name == "mcl_core:gravel" then
		node_under.name = "mcl_ocean:seagrass_gravel"
	else
		return itemstack
	end
	node_under.param2 = minetest.registered_items[node_under.name].place_param2 or 3
	if node_under.param2 < 8 and math.random(1,2) == 1 then
		-- Random horizontal displacement
		node_under.param2 = node_under.param2 + 8
	end
	local def_node = minetest.registered_items[node_under.name]
	if def_node.sounds then
		minetest.sound_play(def_node.sounds.place, { gain = 0.5, pos = pos_under }, true)
	end
	minetest.set_node(pos_under, node_under)
	if not minetest.is_creative_enabled(player_name) then
		itemstack:take_item()
	end

	return itemstack
end

minetest.register_craftitem("mcl_ocean:seagrass", {
	description = S("Seagrass"),
	_tt_help = S("Grows in water on dirt, sand, gravel"),
	_doc_items_create_entry = false,
	inventory_image = "mcl_ocean_seagrass_item.png",
	wield_image = "mcl_ocean_seagrass_item.png",
	on_place = seagrass_on_place,
	groups = {deco_block = 1, compostability = 30},
})

-- Seagrass nodes: seagrass on a surface node

for s=1, #surfaces do
	local def = minetest.registered_nodes[surfaces[s][2]]
	local alt
	if surfaces[s][3] == 1 then
		alt = surfaces[s][2]
	end
	local sounds = table.copy(def.sounds)
	local leaf_sounds = mcl_sounds.node_sound_leaves_defaults()
	sounds.dig = leaf_sounds.dig
	sounds.dug = leaf_sounds.dug
	sounds.place = leaf_sounds.place
	local doc_longdesc, doc_img, desc
	if surfaces[s][1] == "dirt" then
		doc_longdesc = S("Seagrass grows inside water on top of dirt, sand or gravel.")
		desc = S("Seagrass")
		doc_create = true
		doc_img = "mcl_ocean_seagrass_item.png"
	else
		doc_create = false
	end
	minetest.register_node("mcl_ocean:seagrass_"..surfaces[s][1], {
		_doc_items_entry_name = desc,
		_doc_items_longdesc = doc_longdesc,
		_doc_items_create_entry = doc_create,
		_doc_items_image = doc_img,
		drawtype = "plantlike_rooted",
		paramtype = "light",
		paramtype2 = "meshoptions",
		place_param2 = 3,
		tiles = def.tiles,
		special_tiles = {
			{
			image = "mcl_ocean_seagrass.png",
			animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=1.0},
			}
		},
		inventory_image = "mcl_ocean_seagrass_item.png",
		wield_image = "mcl_ocean_seagrass_item.png",
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
				{ -0.5, 0.5, -0.5, 0.5, 1.3, 0.5 },
			},
		},
		groups = { handy = 1, shearsy = 1, deco_block = 1, plant = 1, seagrass = 1, falling_node = surfaces[s][3], not_in_creative_inventory = 1 },
		sounds = sounds,
		node_dig_prediction = surfaces[s][2],
		after_dig_node = function(pos)
			minetest.set_node(pos, {name=surfaces[s][2]})
		end,
		drop = "",
		_mcl_falling_node_alternative = alt,
		_mcl_shears_drop = { "mcl_ocean:seagrass" },
		_mcl_hardness = 0,
		_mcl_blast_resistance = 0,
	})
	if mod_doc and surfaces[s][1] ~= "dirt" then
		doc.add_entry_alias("nodes", "mcl_ocean:seagrass_dirt", "nodes", "mcl_ocean:seagrass_"..surfaces[s][1])
	end
end

if mod_doc then
	doc.add_entry_alias("nodes", "mcl_ocean:seagrass_dirt", "craftitems", "mcl_ocean:seagrass")
end

minetest.register_lbm({
	label = "Fix incorrect seagrass",
	name = "mcl_ocean:fix_incorrect_seagrass",
	nodenames = {"group:seagrass"},
	run_at_every_load = false,
	action = function(pos, node)
		if node.param2 ~= 3 then
			node.param2 = 3
			minetest.set_node(pos, node)
		end
	end
})
