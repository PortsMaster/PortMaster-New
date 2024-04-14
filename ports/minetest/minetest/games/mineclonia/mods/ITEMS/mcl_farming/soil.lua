local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("mcl_farming:soil", {
	tiles = {"mcl_farming_farmland_dry.png", "default_dirt.png"},
	description = S("Farmland"),
	_tt_help = S("Surface for crops").."\n"..S("Can become wet"),
	_doc_items_longdesc = S("Farmland is used for farming, a necessary surface to plant crops. It is created when a hoe is used on dirt or a similar block. Plants are able to grow on farmland, but slowly. Farmland will become hydrated farmland (on which plants grow faster) when it rains or a water source is nearby. This block will turn back to dirt when a solid block appears above it or a piston arm extends above it."),
	drop = "mcl_core:dirt",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			-- 15/16 of the normal height
			{-0.5, -0.5, -0.5, 0.5, 0.4375, 0.5},
		}
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("wet", 0)
	end,
	groups = {handy=1,shovely=1, dirtifies_below_solid=1, dirtifier=1, soil=2, soil_sapling=1, deco_block=1 },
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
})

minetest.register_node("mcl_farming:soil_wet", {
	tiles = {"mcl_farming_farmland_wet.png", "default_dirt.png"},
	description = S("Hydrated Farmland"),
	_doc_items_longdesc = S("Hydrated farmland is used in farming, this is where you can plant and grow some plants. It is created when farmland is under rain or near water. Without water, this block will dry out eventually. This block will turn back to dirt when a solid block appears above it or a piston arm extends above it."),
	drop = "mcl_core:dirt",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.4375, 0.5},
		}
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("wet", 7)
	end,
	groups = {handy=1,shovely=1, not_in_creative_inventory=1, dirtifies_below_solid=1, dirtifier=1, soil=3, soil_sapling=1 },
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.6,
})

minetest.register_abm({
	label = "Farmland hydration",
	nodenames = {"mcl_farming:soil", "mcl_farming:soil_wet"},
	interval = 15,
	chance = 4,
	action = function(pos, node)
		-- Get wetness value
		local meta = minetest.get_meta(pos)
		local wet = meta:get_int("wet")
		if not wet then
			if node.name == "mcl_farming:soil" then
				wet = 0
			else
				wet = 7
			end
		end

		-- Turn back into dirt when covered by solid node
		local above_node = minetest.get_node_or_nil({x=pos.x,y=pos.y+1,z=pos.z})
		if above_node then
			if minetest.get_item_group(above_node.name, "solid") ~= 0 then
				node.name = "mcl_core:dirt"
				minetest.set_node(pos, node)
				return
			end
		end

		-- Check an area of 9×2×9 around the node for nodename (9×9 on same level and 9×9 below)
		local function check_surroundings(pos, nodename)
			local nodes = minetest.find_nodes_in_area({x=pos.x-4,y=pos.y,z=pos.z-4}, {x=pos.x+4,y=pos.y+1,z=pos.z+4}, {nodename})
			return #nodes > 0
		end

		if check_surroundings(pos, "group:water") then
			if node.name ~= "mcl_farming:soil_wet" then
				-- Make it wet
				node.name = "mcl_farming:soil_wet"
				minetest.set_node(pos, node)
			end
		else -- No water nearby.
			-- The decay branch (make farmland dry or turn back to dirt)

			-- Don't decay while it's raining
			if mcl_weather.rain.raining then
				if mcl_weather.is_outdoor(pos) then
					return
				end
			end
			-- No decay near unloaded areas since these might include water.
			if not check_surroundings(pos, "ignore") then
				if wet <= 0 then
					--local n_def = minetest.registered_nodes[node.name] or nil
					local nn = minetest.get_node_or_nil({x=pos.x,y=pos.y+1,z=pos.z})
					if not nn or not nn.name then
						return
					end
					local nn_def = minetest.registered_nodes[nn.name] or nil

					if nn_def and minetest.get_item_group(nn.name, "plant") == 0 then
						node.name = "mcl_core:dirt"
						minetest.set_node(pos, node)
						return
					end
				else
					if wet == 7 then
						node.name = "mcl_farming:soil"
						minetest.swap_node(pos, node)
					end
					-- Slowly count down wetness
					meta:set_int("wet", wet-1)
				end
			end
		end
	end,
})

