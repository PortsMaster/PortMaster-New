local S = minetest.get_translator(minetest.get_current_modname())

local absorb = function(pos)
	local change = false
	-- Count number of absorbed river water vs other nodes
	-- to determine the wet sponge type.
	local river_water = 0
	local non_river_water = 0
	local p, n
	for i=-3,3 do
		for j=-3,3 do
			for k=-3,3 do
				p = {x=pos.x+i, y=pos.y+j, z=pos.z+k}
				n = minetest.get_node(p)
				if minetest.get_item_group(n.name, "water") ~= 0 then
					minetest.add_node(p, {name="air"})
					change = true
					if n.name == "mclx_core:river_water_source" or n.name == "mclx_core:river_water_flowing" then
						river_water = river_water + 1
					else
						non_river_water = non_river_water + 1
					end
				end
			end
		end
	end
	-- The dominant water type wins. In case of a tie, normal water wins.
	-- This slight bias is intentional.
	local sponge_type
	if river_water > non_river_water then
		sponge_type = "mcl_sponges:sponge_wet_river_water"
	else
		sponge_type = "mcl_sponges:sponge_wet"
	end
	return change, sponge_type
end

minetest.register_node("mcl_sponges:sponge", {
	description = S("Sponge"),
	_tt_help = S("Removes water on contact"),
	_doc_items_longdesc = S("Sponges are blocks which remove water around them when they are placed or come in contact with water, turning it into a wet sponge."),
	drawtype = "normal",
	is_ground_content = false,
	tiles = {"mcl_sponges_sponge.png"},
	walkable = true,
	pointable = true,
	diggable = true,
	buildable_to = false,
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	groups = {handy=1, hoey=1, building_block=1},
	on_place = function(itemstack, placer, pointed_thing)

		if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
			return itemstack
		end

		local pn = placer:get_player_name()

		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		if minetest.is_protected(pointed_thing.above, pn) then
			return itemstack
		end

		local pos = pointed_thing.above
		local on_water = false
		if minetest.get_item_group(minetest.get_node(pos).name, "water") ~= 0 then
			on_water = true
		end
		local water_found = minetest.find_node_near(pos, 1, "group:water")
		if water_found then
			on_water = true
		end
		if on_water then
			-- Absorb water
			-- FIXME: pos is not always the right placement position because of pointed_thing
			local absorbed, wet_sponge = absorb(pos)
			if absorbed then
				minetest.item_place_node(ItemStack(wet_sponge), placer, pointed_thing)
				if not minetest.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item()
				end
				return itemstack
			end
		end
		return minetest.item_place_node(itemstack, placer, pointed_thing)
	end,
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
})

function place_wet_sponge(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
		return itemstack
	end

	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	local name = placer:get_player_name()

	if minetest.is_protected(pointed_thing.above, name) then
		return itemstack
	end

	if mcl_worlds.pos_to_dimension(pointed_thing.above) == "nether" then
		minetest.item_place_node(ItemStack("mcl_sponges:sponge"), placer, pointed_thing)
		local pos = pointed_thing.above

		for n = 1, 5 do
			minetest.add_particlespawner({
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
		if not minetest.is_creative_enabled(name) then
			itemstack:take_item()
		end
		return itemstack
	end

	return minetest.item_place_node(itemstack, placer, pointed_thing)
end

minetest.register_node("mcl_sponges:sponge_wet", {
	description = S("Waterlogged Sponge"),
	_tt_help = S("Can be dried in furnace"),
	_doc_items_longdesc = S("A waterlogged sponge can be dried in the furnace to turn it into (dry) sponge. When there's an empty bucket in the fuel slot of a furnace, the water will pour into the bucket."),
	drawtype = "normal",
	is_ground_content = false,
	tiles = {"mcl_sponges_sponge_wet.png"},
	walkable = true,
	pointable = true,
	diggable = true,
	buildable_to = false,
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	groups = {handy=1, hoey=1, building_block=1},
	on_place = place_wet_sponge,
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
})

if minetest.get_modpath("mclx_core") then
	minetest.register_node("mcl_sponges:sponge_wet_river_water", {
		description = S("Riverwaterlogged Sponge"),
		_tt_help = S("Can be dried in furnace"),
		_doc_items_longdesc = S("This is a sponge soaking wet with river water. It can be dried in the furnace to turn it into (dry) sponge. When there's an empty bucket in the fuel slot of the furnace, the river water will pour into the bucket.") .. "\n" .. S("A sponge becomes riverwaterlogged (instead of waterlogged) if it sucks up more river water than (normal) water."),
		drawtype = "normal",
		is_ground_content = false,
		tiles = {"mcl_sponges_sponge_wet_river_water.png"},
		walkable = true,
		pointable = true,
		diggable = true,
		buildable_to = false,
		sounds = mcl_sounds.node_sound_dirt_defaults(),
		groups = {handy=1, building_block=1},
		on_place = place_wet_sponge,
		_mcl_blast_resistance = 0.6,
		_mcl_hardness = 0.6,
	})

	minetest.register_craft({
		type = "cooking",
		output = "mcl_sponges:sponge",
		recipe = "mcl_sponges:sponge_wet_river_water",
		cooktime = 10,
	})
end

minetest.register_craft({
	type = "cooking",
	output = "mcl_sponges:sponge",
	recipe = "mcl_sponges:sponge_wet",
	cooktime = 10,
})

minetest.register_abm({
	label = "Sponge water absorbtion",
	nodenames = { "mcl_sponges:sponge" },
	neighbors = { "group:water" },
	interval = 1,
	chance = 1,
	action = function(pos)
		local absorbed, wet_sponge = absorb(pos)
		if absorbed then
			minetest.add_node(pos, {name = wet_sponge})
		end
	end,
})
