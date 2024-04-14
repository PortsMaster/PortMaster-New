local S = minetest.get_translator(minetest.get_current_modname())
local mod_doc = minetest.get_modpath("doc")

local corals = {
	{ "tube", S("Tube Coral Block"), S("Dead Tube Coral Block"), S("Tube Coral"), S("Dead Tube Coral"), S("Tube Coral Fan"), S("Dead Tube Coral Fan") },
	{ "brain", S("Brain Coral Block"), S("Dead Brain Coral Block"), S("Brain Coral"), S("Dead Brain Coral"), S("Brain Coral Fan"), S("Dead Brain Coral Fan") },
	{ "bubble", S("Bubble Coral Block"), S("Dead Bubble Coral Block"), S("Bubble Coral"), S("Dead Bubble Coral"), S("Bubble Coral Fan"), S("Dead Bubble Coral Fan")},
	{ "fire", S("Fire Coral Block"), S("Dead Fire Coral Block"), S("Fire Coral"), S("Dead Fire Coral"), S("Fire Coral Fan"), S("Dead Fire Coral Fan") },
	{ "horn", S("Horn Coral Block"), S("Dead Horn Coral Block"), S("Horn Coral"), S("Dead Horn Coral"), S("Horn Coral Fan"), S("Dead Horn Coral Fan") },
}

local function coral_on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer then
		return itemstack
	end

	local player_name = placer:get_player_name()
	local pos_under = pointed_thing.under
	local pos_above = pointed_thing.above
	local node_under = minetest.get_node(pos_under)

	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	if pos_under.y >= pos_above.y then
		return itemstack
	end

	local g_block = minetest.get_item_group(node_under.name, "coral_block")
	local g_coral = minetest.get_item_group(itemstack:get_name(), "coral")
	local g_species_block = minetest.get_item_group(node_under.name, "coral_species")
	local g_species_plant = minetest.get_item_group(itemstack:get_name(), "coral_species")

	-- Placement rules:
	-- Coral plant can only be placed on top of a matching coral block.
	if g_block == 0 or (g_coral ~= g_block) or (g_species_block ~= g_species_plant) then
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

	node_under.name = itemstack:get_name()
	node_under.param2 = minetest.registered_items[node_under.name].place_param2 or 1
	if node_under.param2 < 8 and math.random(1,2) == 1 then
		-- Random horizontal displacement
		node_under.param2 = node_under.param2 + 8
	end
	minetest.set_node(pos_under, node_under)
	local def_node = minetest.registered_nodes[node_under.name]
	if def_node.sounds then
		minetest.sound_play(def_node.sounds.place, { gain = 0.5, pos = pos_under }, true)
	end
	if not minetest.is_creative_enabled(player_name) then
		itemstack:take_item()
	end

	return itemstack
end

-- Sound for non-block corals
local sounds_coral_plant = mcl_sounds.node_sound_leaves_defaults({footstep = mcl_sounds.node_sound_dirt_defaults().footstep})

for c=1, #corals do
	local id = corals[c][1]
	local doc_desc_block = S("Coral blocks live in the oceans and need a water source next to them to survive. Without water, they die off.")
	local doc_desc_coral = S("Corals grow on top of coral blocks and need to be inside a water source to survive. Without water, it will die off, as well as the coral block below.")
	local doc_desc_fan = S("Corals fans grow on top of coral blocks and need to be inside a water source to survive. Without water, it will die off, as well as the coral block below.")
	local tt_block = S("Needs water to live")
	local tt_coral_dead = S("Grows on coral block of same species")
	local tt_coral = tt_coral_dead .. "\n" .. S("Needs water to live")

	-- Coral Block
	minetest.register_node("mcl_ocean:"..id.."_coral_block", {
		description = corals[c][2],
		_doc_items_longdesc = doc_desc_block,
		_tt_help = tt_block,
		tiles = { "mcl_ocean_"..id.."_coral_block.png" },
		groups = { pickaxey = 1, building_block = 1, coral=1, coral_block=1, coral_species=c, },
		sounds = mcl_sounds.node_sound_dirt_defaults(),
		drop = "mcl_ocean:dead_"..id.."_coral_block",
		_mcl_hardness = 1.5,
		_mcl_blast_resistance = 6,
		_mcl_silk_touch_drop = true,
	})
	minetest.register_node("mcl_ocean:dead_"..id.."_coral_block", {
		description = corals[c][3],
		_doc_items_create_entry = false,
		tiles = { "mcl_ocean_dead_"..id.."_coral_block.png" },
		groups = { pickaxey = 1, building_block = 1, coral=2, coral_block=2, coral_species=c, },
		sounds = mcl_sounds.node_sound_dirt_defaults(),
		_mcl_hardness = 1.5,
		_mcl_blast_resistance = 6,
	})

	-- Coral
	minetest.register_node("mcl_ocean:"..id.."_coral", {
		description = corals[c][4],
		_doc_items_longdesc = doc_desc_coral,
		_tt_help = tt_coral,
		drawtype = "plantlike_rooted",
		paramtype = "light",
		paramtype2 = "meshoptions",
		place_param2 = 1,
		tiles = { "mcl_ocean_"..id.."_coral_block.png" },
		special_tiles = { { name = "mcl_ocean_"..id.."_coral.png" } },
		inventory_image = "mcl_ocean_"..id.."_coral.png",
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
				{ -0.5, 0.5, -0.5, 0.5, 1.0, 0.5 },
			}
		},
		groups = { dig_immediate = 3, deco_block = 1, coral=1, coral_plant=1, coral_species=c, },
		sounds = sounds_coral_plant,
		drop = "mcl_ocean:dead_"..id.."_coral",
		node_placement_prediction = "",
		node_dig_prediction = "mcl_ocean:"..id.."_coral_block",
		on_place = coral_on_place,
		after_dig_node = function(pos)
			local node = minetest.get_node(pos)
			if minetest.get_item_group(node.name, "coral") == 0 then
				minetest.set_node(pos, {name="mcl_ocean:"..id.."_coral_block"})
			end
		end,
		_mcl_hardness = 0,
		_mcl_blast_resistance = 0,
		_mcl_silk_touch_drop = true,
	})
	minetest.register_node("mcl_ocean:dead_"..id.."_coral", {
		description = corals[c][5],
		_doc_items_create_entry = false,
		_tt_help = tt_coral_dead,
		drawtype = "plantlike_rooted",
		paramtype = "light",
		paramtype2 = "meshoptions",
		place_param2 = 1,
		tiles = { "mcl_ocean_dead_"..id.."_coral_block.png" },
		special_tiles = { { name = "mcl_ocean_dead_"..id.."_coral.png" } },
		inventory_image = "mcl_ocean_dead_"..id.."_coral.png",
		groups = { dig_immediate = 3, deco_block = 1, coral=2, coral_plant=2, coral_species=c, },
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
				{ -0.5, 0.5, -0.5, 0.5, 1.0, 0.5 },
			}
		},
		sounds = sounds_coral_plant,
		node_placement_prediction = "",
		node_dig_prediction = "mcl_ocean:dead_"..id.."_coral_block",
		on_place = coral_on_place,
		after_dig_node = function(pos)
			local node = minetest.get_node(pos)
			if minetest.get_item_group(node.name, "coral") == 0 then
				minetest.set_node(pos, {name="mcl_ocean:dead_"..id.."_coral_block"})
			end
		end,
		_mcl_hardness = 0,
		_mcl_blast_resistance = 0,
	})

	-- Coral Fan
	minetest.register_node("mcl_ocean:"..id.."_coral_fan", {
		description = corals[c][6],
		_doc_items_longdesc = doc_desc_fan,
		_tt_help = tt_coral,
		drawtype = "plantlike_rooted",
		paramtype = "light",
		paramtype2 = "meshoptions",
		place_param2 = 4,
		tiles = { "mcl_ocean_"..id.."_coral_block.png" },
		special_tiles = { { name = "mcl_ocean_"..id.."_coral_fan.png" } },
		inventory_image = "mcl_ocean_"..id.."_coral_fan.png",
		groups = { dig_immediate = 3, deco_block = 1, coral=1, coral_fan=1, coral_species=c, },
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
				{ -0.5, 0.5, -0.5, 0.5, 1.0, 0.5 },
			}
		},
		sounds = sounds_coral_plant,
		drop = "mcl_ocean:dead_"..id.."_coral_fan",
		node_placement_prediction = "",
		node_dig_prediction = "mcl_ocean:"..id.."_coral_block",
		on_place = coral_on_place,
		after_dig_node = function(pos)
			local node = minetest.get_node(pos)
			if minetest.get_item_group(node.name, "coral") == 0 then
				minetest.set_node(pos, {name="mcl_ocean:"..id.."_coral_block"})
			end
		end,
		_mcl_hardness = 0,
		_mcl_blast_resistance = 0,
		_mcl_silk_touch_drop = true,
	})
	minetest.register_node("mcl_ocean:dead_"..id.."_coral_fan", {
		description = corals[c][7],
		_doc_items_create_entry = false,
		_tt_help = tt_coral_dead,
		drawtype = "plantlike_rooted",
		paramtype = "light",
		paramtype2 = "meshoptions",
		place_param2 = 4,
		tiles = { "mcl_ocean_dead_"..id.."_coral_block.png" },
		special_tiles = { { name = "mcl_ocean_dead_"..id.."_coral_fan.png" } },
		inventory_image = "mcl_ocean_dead_"..id.."_coral_fan.png",
		groups = { dig_immediate = 3, deco_block = 1, coral=2, coral_fan=2, coral_species=c, },
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
				{ -0.5, 0.5, -0.5, 0.5, 1.0, 0.5 },
			}
		},
		sounds = sounds_coral_plant,
		node_placement_prediction = "",
		node_dig_prediction = "mcl_ocean:dead_"..id.."_coral_block",
		on_place = coral_on_place,
		after_dig_node = function(pos)
			local node = minetest.get_node(pos)
			if minetest.get_item_group(node.name, "coral") == 0 then
				minetest.set_node(pos, {name="mcl_ocean:dead_"..id.."_coral_block"})
			end
		end,
		_mcl_hardness = 0,
		_mcl_blast_resistance = 0,
		_mcl_silk_touch_drop = true,
	})

	if mod_doc then
		doc.add_entry_alias("nodes", "mcl_ocean:"..id.."_coral", "nodes", "mcl_ocean:"..id.."_coral")
		doc.add_entry_alias("nodes", "mcl_ocean:"..id.."_coral_fan", "nodes", "mcl_ocean:"..id.."_coral_fan")
		doc.add_entry_alias("nodes", "mcl_ocean:"..id.."_coral_block", "nodes", "mcl_ocean:"..id.."_coral_block")
		doc.add_entry_alias("nodes", "mcl_ocean:"..id.."_coral", "nodes", "mcl_ocean:dead_"..id.."_coral")
		doc.add_entry_alias("nodes", "mcl_ocean:"..id.."_coral_fan", "nodes", "mcl_ocean:dead_"..id.."_coral_fan")
		doc.add_entry_alias("nodes", "mcl_ocean:"..id.."_coral_block", "nodes", "mcl_ocean:dead_"..id.."_coral_block")
	end
end

-- Turn corals and coral fans to dead corals if not inside a water source
minetest.register_abm({
	label = "Coral plant / coral fan death",
	nodenames = { "group:coral_plant", "group_coral_fan" },
	interval = 17,
	chance = 5,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		-- Check if coral's alive
		local coral_state = minetest.get_item_group(node.name, "coral")
		if coral_state == 1 then
			-- Check node above, here lives the actual plant (it's plantlike_rooted)
			if minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name ~= "mcl_core:water_source" then
				-- Find dead form (it's the same as the node's drop)
				local def = minetest.registered_nodes[node.name]
				if def then
					node.name = def.drop
				else
					return
				end
				-- Set node to dead form.
				minetest.set_node(pos, node)
			end
		end
	end,
})

-- Turn corals blocks to dead coral blocks if not next to a water source
minetest.register_abm({
	label = "Coral block death",
	nodenames = { "group:coral_block" },
	interval = 17,
	chance = 5,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		-- Check if coral's alive
		local coral_state = minetest.get_item_group(node.name, "coral")
		if coral_state == 1 then
			local posses = {
				{ x=0,y=1,z=0 },
				{ x=-1,y=0,z=0 },
				{ x=1,y=0,z=0 },
				{ x=0,y=0,z=-1 },
				{ x=0,y=0,z=1 },
				{ x=0,y=-1,z=0 },
			}
			-- Check all 6 neighbors for water
			for p=1, #posses do
				local checknode = minetest.get_node(vector.add(pos, posses[p]))
				if checknode.name == "mcl_core:water_source" then
					-- Water found! Don't die.
					return
				end
			end
			-- Find dead form (it's the same as the node's drop)
			local def = minetest.registered_nodes[node.name]
			if def then
				node.name = def.drop
			else
				return
			end
			-- Set node to dead form
			minetest.set_node(pos, node)
		end
	end,
})
