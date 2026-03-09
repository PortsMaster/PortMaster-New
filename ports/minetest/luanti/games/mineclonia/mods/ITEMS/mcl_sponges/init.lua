local S = core.get_translator(core.get_current_modname())

local function absorb(pos)
	local change = false
	local river_water = 0
	local non_river_water = 0
	for nodename, nn in pairs(core.find_nodes_in_area(vector.offset(pos, -3, -3, -3), vector.offset(pos, 3, 3, 3), {"group:water"}, true)) do
		for _, p in pairs(nn) do
			if core.get_item_group(nodename, "river_water") > 0 then
				river_water = river_water + #nn
			else
				non_river_water = non_river_water + #nn
			end
			change = true
			core.remove_node(p)
		end
	end
	-- The dominant water type wins. In case of a tie, normal water wins.
	-- This slight bias is intentional.
	return change, river_water > non_river_water and "mcl_sponges:sponge_wet_river_water" or "mcl_sponges:sponge_wet"
end

core.register_node("mcl_sponges:sponge", {
	description = S("Sponge"),
	_tt_help = S("Removes water on contact"),
	_doc_items_longdesc = S("Sponges are blocks which remove water around them when they are placed or come in contact with water, turning it into a wet sponge."),
	drawtype = "normal",
	is_ground_content = false,
	tiles = {"mcl_sponges_sponge.png"},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	groups = {handy=1, hoey=1, building_block=1},
	on_place = function(itemstack, placer, pointed_thing)

		if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
			return itemstack
		end

		local pn = placer:get_player_name()

		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		if core.is_protected(pointed_thing.above, pn) then
			return itemstack
		end

		local pos = pointed_thing.above
		local on_water = false
		if core.get_item_group(core.get_node(pos).name, "water") ~= 0 then
			on_water = true
		end
		local water_found = core.find_node_near(pos, 1, "group:water")
		if water_found then
			on_water = true
		end
		if on_water then
			-- FIXME: pos is not always the right placement position because of pointed_thing
			local absorbed, wet_sponge = absorb(pos)
			if absorbed then
				core.item_place_node(ItemStack(wet_sponge), placer, pointed_thing)
				if not core.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item()
				end
				return itemstack
			end
		end
		return core.item_place_node(itemstack, placer, pointed_thing)
	end,
	_mcl_hardness = 0.6,
})

function place_wet_sponge(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
		return itemstack
	end

	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	local name = placer:get_player_name()

	if core.is_protected(pointed_thing.above, name) then
		return itemstack
	end

	if mcl_worlds.pos_to_dimension(pointed_thing.above) == "nether" then
		core.item_place_node(ItemStack("mcl_sponges:sponge"), placer, pointed_thing)
		local pos = pointed_thing.above

		for n = 1, 5 do
			core.add_particlespawner({
				amount = 5,
				time = 0.1,
				minpos = vector.offset(pos, -0.5, 0.6, -0.5),
				maxpos = vector.offset(pos, 0.5, 0.6, 0.5),
				minvel = vector.new(0, 0.1, 0),
				maxvel = vector.new(0, 1, 0),
				minexptime = 0.1,
				maxexptime = 1,
				minsize = 2,
				maxsize = 5,
				collisiondetection = false,
				vertical = false,
				texture = "mcl_particles_sponge" .. n .. ".png",
			})
		end
		if not core.is_creative_enabled(name) then
			itemstack:take_item()
		end
		return itemstack
	end

	return core.item_place_node(itemstack, placer, pointed_thing)
end

core.register_node("mcl_sponges:sponge_wet", {
	description = S("Waterlogged Sponge"),
	_tt_help = S("Can be dried in furnace"),
	_doc_items_longdesc = S("A waterlogged sponge can be dried in the furnace to turn it into (dry) sponge. When there's an empty bucket in the fuel slot of a furnace, the water will pour into the bucket."),
	drawtype = "normal",
	is_ground_content = false,
	tiles = {"mcl_sponges_sponge_wet.png"},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	groups = {handy=1, hoey=1, building_block=1},
	on_place = place_wet_sponge,
	_mcl_hardness = 0.6,
	_mcl_cooking_output = "mcl_sponges:sponge",
	_mcl_cooking_replacements = {{"mcl_buckets:bucket_empty", "mcl_buckets:bucket_water"}}
})

core.register_node("mcl_sponges:sponge_wet_river_water", {
	description = S("Riverwaterlogged Sponge"),
	_tt_help = S("Can be dried in furnace"),
	_doc_items_longdesc = S("This is a sponge soaking wet with river water. It can be dried in the furnace to turn it into (dry) sponge. When there's an empty bucket in the fuel slot of the furnace, the river water will pour into the bucket.") .. "\n" .. S("A sponge becomes riverwaterlogged (instead of waterlogged) if it sucks up more river water than (normal) water."),
	drawtype = "normal",
	is_ground_content = false,
	tiles = {"mcl_sponges_sponge_wet_river_water.png"},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	groups = {handy=1, building_block=1},
	on_place = place_wet_sponge,
	_mcl_hardness = 0.6,
	_mcl_cooking_output = "mcl_sponges:sponge",
	_mcl_cooking_replacements = {{"mcl_buckets:bucket_empty", "mcl_buckets:bucket_river_water"}}
})

core.register_abm({
	label = "Sponge water absorbtion",
	nodenames = { "mcl_sponges:sponge" },
	neighbors = { "group:water" },
	interval = 1,
	chance = 1,
	action = function(pos)
		local absorbed, wet_sponge = absorb(pos)
		if absorbed then
			core.set_node(pos, {name = wet_sponge})
		end
	end,
})
