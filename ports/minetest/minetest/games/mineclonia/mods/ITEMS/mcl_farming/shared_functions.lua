mcl_farming.plant_lists = {}

local plant_lists = {}

local plant_nodename_to_id_list = {}

local function get_intervals_counter(pos, interval, chance)
	local meta = minetest.get_meta(pos)
	local time_speed = tonumber(minetest.settings:get("time_speed") or 72)
	local current_game_time
	if time_speed == nil then
		return 1
	end
	if (time_speed < 0.1) then
		return 1
	end
	local time_multiplier = 86400 / time_speed
	current_game_time = .0 + ((minetest.get_day_count() + minetest.get_timeofday()) * time_multiplier)

	local approx_interval = math.max(interval, 1) * math.max(chance, 1)

	local last_game_time = meta:get_string("last_gametime")
	if last_game_time then
		last_game_time = tonumber(last_game_time)
	end
	if not last_game_time or last_game_time < 1 then
		last_game_time = current_game_time - approx_interval / 10
	elseif last_game_time == current_game_time then
		current_game_time = current_game_time + approx_interval
	end

	local elapsed_game_time = .0 + current_game_time - last_game_time

	meta:set_string("last_gametime", tostring(current_game_time))

	return elapsed_game_time / approx_interval
end

local function get_avg_light_level(pos)
	local node_light = tonumber(minetest.get_node_light(pos) or 0)
	local meta = minetest.get_meta(pos)
	local counter = meta:get_int("avg_light_count")
	local summary = meta:get_int("avg_light_summary")
	if counter > 99 then
		counter = 51
		summary = math.ceil((summary + 0.0) / 2.0)
	else
		counter = counter + 1
	end
	summary = summary + node_light
	meta:set_int("avg_light_count", counter)
	meta:set_int("avg_light_summary", summary)
	return math.ceil((summary + 0.0) / counter)
end

function mcl_farming:add_plant(identifier, full_grown, names, interval, chance)
	mcl_farming.plant_lists[identifier] = {}
	mcl_farming.plant_lists[identifier].full_grown = full_grown
	mcl_farming.plant_lists[identifier].names = names
	mcl_farming.plant_lists[identifier].interval = interval
	mcl_farming.plant_lists[identifier].chance = chance
	plant_lists = mcl_farming.plant_lists --provide local copy of plant lists (performances)
	minetest.register_abm({
		label = string.format("Farming plant growth (%s)", identifier),
		nodenames = names,
		interval = interval,
		chance = chance,
		action = function(pos, node)
			local low_speed = minetest.get_node({ x = pos.x, y = pos.y - 1, z = pos.z }).name ~= "mcl_farming:soil_wet"
			mcl_farming:grow_plant(identifier, pos, node, false, false, low_speed)
		end,
	})
	for _, nodename in pairs(names) do
		plant_nodename_to_id_list[nodename] = identifier
	end
end

-- Attempts to advance a plant at pos by one or more growth stages (if possible)
-- identifier: Identifier of plant as defined by mcl_farming:add_plant
-- pos: Position
-- node: Node table
-- stages: Number of stages to advance (optional, defaults to 1)
-- ignore_light: if true, ignore light requirements for growing

-- Returns true if plant has been grown by 1 or more stages.
-- Returns false if nothing changed.
function mcl_farming:grow_plant(identifier, pos, node, stages, ignore_light, low_speed)
	local average_light_level = get_avg_light_level(pos)
	local plant_info = plant_lists[identifier]
	local intervals_counter = get_intervals_counter(pos, plant_info.interval, plant_info.chance)
	local low_speed = low_speed or false
	if low_speed then
		if intervals_counter < 1.01 and math.random(0, 9) > 0 then
			return
		else
			intervals_counter = intervals_counter / 10
		end
	end
	if not minetest.get_node_light(pos) and not ignore_light and intervals_counter < 1.5 then
		return false
	end
	if minetest.get_node_light(pos) < 10 and not ignore_light and intervals_counter < 1.5 then
		return false
	end

	if intervals_counter >= 1.5 then
		if average_light_level < 0.1 then
			return false
		end
		if average_light_level < 10 then
			intervals_counter = intervals_counter * average_light_level / 10
		end
	end

	local step = nil

	for i, name in ipairs(plant_info.names) do
		if name == node.name then
			step = i
			break
		end
	end
	if step == nil then
		return false
	end
	if not stages then
		stages = 1
	end
	stages = stages + math.ceil(intervals_counter)
	local new_node = { name = plant_info.names[step + stages] }
	if new_node.name == nil then
		new_node.name = plant_info.full_grown
	end
	new_node.param = node.param
	new_node.param2 = node.param2
	minetest.set_node(pos, new_node)
	return true
end

function mcl_farming:place_seed(itemstack, placer, pointed_thing, plantname)
	local pt = pointed_thing
	if not pt then
		return
	end
	if pt.type ~= "node" then
		return
	end

	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	local pos = { x = pt.above.x, y = pt.above.y - 1, z = pt.above.z }
	local farmland = minetest.get_node(pos)
	pos = { x = pt.above.x, y = pt.above.y, z = pt.above.z }
	local place_s = minetest.get_node(pos)

	if string.find(farmland.name, "mcl_farming:soil") and string.find(place_s.name, "air") then
		minetest.sound_play(minetest.registered_nodes[plantname].sounds.place, { pos = pos }, true)
		minetest.add_node(pos, { name = plantname, param2 = minetest.registered_nodes[plantname].place_param2 })
		--local intervals_counter = get_intervals_counter(pos, 1, 1)
	else
		return
	end

	if not minetest.is_creative_enabled(placer:get_player_name()) then
		itemstack:take_item()
	end
	return itemstack
end


--[[ Helper function to create a gourd (e.g. melon, pumpkin), the connected stem nodes as

- full_unconnected_stem: itemstring of the full-grown but unconnected stem node. This node must already be done
- connected_stem_basename: prefix of the itemstrings used for the 4 connected stem nodes to create
- stem_itemstring: Desired itemstring of the fully-grown unconnected stem node
- stem_def: Partial node definition of the fully-grown unconnected stem node. Many fields are already defined. You need to add `tiles` and `description` at minimum. Don't define on_construct without good reason
- stem_drop: Drop probability table for all stem
- gourd_itemstring: Desired itemstring of the full gourd node
- gourd_def: (almost) full definition of the gourd node. This function will add on_construct and after_destruct to the definition for unconnecting any connected stems
- grow_interval: Will attempt to grow a gourd periodically at this interval in seconds
- grow_chance: Chance of 1/grow_chance to grow a gourd next to the full unconnected stem after grow_interval has passed. Must be a natural number
- connected_stem_texture: Texture of the connected stem
- gourd_on_construct_extra: Custom on_construct extra function for the gourd. Will be called after the stem check code
]]

function mcl_farming:add_gourd(full_unconnected_stem, connected_stem_basename, stem_itemstring, stem_def, stem_drop, gourd_itemstring, gourd_def, grow_interval, grow_chance, connected_stem_texture, gourd_on_construct_extra)

	local connected_stem_names = {
		connected_stem_basename .. "_r",
		connected_stem_basename .. "_l",
		connected_stem_basename .. "_t",
		connected_stem_basename .. "_b",
	}

	local neighbors = {
		{ x = -1, y = 0, z = 0 },
		{ x = 1, y = 0, z = 0 },
		{ x = 0, y = 0, z = -1 },
		{ x = 0, y = 0, z = 1 },
	}

	-- Connect the stem at stempos to the first neighboring gourd block.
	-- No-op if not a stem or no gourd block found
	local function try_connect_stem(stempos)
		local stem = minetest.get_node(stempos)
		if stem.name ~= full_unconnected_stem then
			return false
		end
		for n = 1, #neighbors do
			local offset = neighbors[n]
			local blockpos = vector.add(stempos, offset)
			local block = minetest.get_node(blockpos)
			if block.name == gourd_itemstring then
				if offset.x == 1 then
					minetest.set_node(stempos, { name = connected_stem_names[1] })
				elseif offset.x == -1 then
					minetest.set_node(stempos, { name = connected_stem_names[2] })
				elseif offset.z == 1 then
					minetest.set_node(stempos, { name = connected_stem_names[3] })
				elseif offset.z == -1 then
					minetest.set_node(stempos, { name = connected_stem_names[4] })
				end
				return true
			end
		end
	end

	-- Register gourd
	if not gourd_def.after_destruct then
		gourd_def.after_destruct = function(blockpos, oldnode)
			-- Disconnect any connected stems, turning them back to normal stems
			for n = 1, #neighbors do
				local offset = neighbors[n]
				local expected_stem = connected_stem_names[n]
				local stempos = vector.add(blockpos, offset)
				local stem = minetest.get_node(stempos)
				if stem.name == expected_stem then
					minetest.add_node(stempos, { name = full_unconnected_stem })
					try_connect_stem(stempos)
				end
			end
		end
	end
	if not gourd_def.on_construct then
		function gourd_def.on_construct(blockpos)
			-- Connect all unconnected stems at full size
			for n = 1, #neighbors do
				local stempos = vector.add(blockpos, neighbors[n])
				try_connect_stem(stempos)
			end
			-- Call custom on_construct
			if gourd_on_construct_extra then
				gourd_on_construct_extra(blockpos)
			end
		end
	end
	minetest.register_node(gourd_itemstring, gourd_def)

	-- Register unconnected stem

	-- Default values for the stem definition
	if not stem_def.selection_box then
		stem_def.selection_box = {
			type = "fixed",
			fixed = {
				{ -0.15, -0.5, -0.15, 0.15, 0.5, 0.15 }
			},
		}
	end
	if not stem_def.paramtype then
		stem_def.paramtype = "light"
	end
	if not stem_def.drawtype then
		stem_def.drawtype = "plantlike"
	end
	if stem_def.walkable == nil then
		stem_def.walkable = false
	end
	if stem_def.sunlight_propagates == nil then
		stem_def.sunlight_propagates = true
	end
	if stem_def.drop == nil then
		stem_def.drop = stem_drop
	end
	if stem_def.groups == nil then
		stem_def.groups = { dig_immediate = 3, not_in_creative_inventory = 1, plant = 1, attached_node = 1, dig_by_water = 1, destroy_by_lava_flow = 1, }
	end
	if stem_def.sounds == nil then
		stem_def.sounds = mcl_sounds.node_sound_leaves_defaults()
	end

	if not stem_def.on_construct then
		function stem_def.on_construct(stempos)
			-- Connect stem to gourd (if possible)
			try_connect_stem(stempos)
		end
	end
	minetest.register_node(stem_itemstring, stem_def)

	-- Register connected stems

	local connected_stem_tiles = {
		{ "blank.png", --top
		  "blank.png", -- bottom
		  "blank.png", -- right
		  "blank.png", -- left
		  connected_stem_texture, -- back
		  connected_stem_texture .. "^[transformFX" --front
		},
		{ "blank.png", --top
		  "blank.png", -- bottom
		  "blank.png", -- right
		  "blank.png", -- left
		  connected_stem_texture .. "^[transformFX", --back
		  connected_stem_texture, -- front
		},
		{ "blank.png", --top
		  "blank.png", -- bottom
		  connected_stem_texture .. "^[transformFX", -- right
		  connected_stem_texture, -- left
		  "blank.png", --back
		  "blank.png", -- front
		},
		{ "blank.png", --top
		  "blank.png", -- bottom
		  connected_stem_texture, -- right
		  connected_stem_texture .. "^[transformFX", -- left
		  "blank.png", --back
		  "blank.png", -- front
		}
	}
	local connected_stem_nodebox = {
		{ -0.5, -0.5, 0, 0.5, 0.5, 0 },
		{ -0.5, -0.5, 0, 0.5, 0.5, 0 },
		{ 0, -0.5, -0.5, 0, 0.5, 0.5 },
		{ 0, -0.5, -0.5, 0, 0.5, 0.5 },
	}
	local connected_stem_selectionbox = {
		{ -0.1, -0.5, -0.1, 0.5, 0.2, 0.1 },
		{ -0.5, -0.5, -0.1, 0.1, 0.2, 0.1 },
		{ -0.1, -0.5, -0.1, 0.1, 0.2, 0.5 },
		{ -0.1, -0.5, -0.5, 0.1, 0.2, 0.1 },
	}

	for i = 1, 4 do
		minetest.register_node(connected_stem_names[i], {
			_doc_items_create_entry = false,
			paramtype = "light",
			sunlight_propagates = true,
			walkable = false,
			drop = stem_drop,
			drawtype = "nodebox",
			node_box = {
				type = "fixed",
				fixed = connected_stem_nodebox[i]
			},
			selection_box = {
				type = "fixed",
				fixed = connected_stem_selectionbox[i]
			},
			tiles = connected_stem_tiles[i],
			use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
			groups = { dig_immediate = 3, not_in_creative_inventory = 1, plant = 1, attached_node = 1, dig_by_water = 1, destroy_by_lava_flow = 1, },
			sounds = mcl_sounds.node_sound_leaves_defaults(),
			_mcl_blast_resistance = 0,
		})

		if minetest.get_modpath("doc") then
			doc.add_entry_alias("nodes", full_unconnected_stem, "nodes", connected_stem_names[i])
		end
	end

	minetest.register_abm({
		label = "Grow gourd stem to gourd (" .. full_unconnected_stem .. " → " .. gourd_itemstring .. ")",
		nodenames = { full_unconnected_stem },
		neighbors = { "air" },
		interval = grow_interval,
		chance = grow_chance,
		action = function(stempos)
			local light = minetest.get_node_light(stempos)
			if light and light > 10 then
				-- Check the four neighbors and filter out neighbors where gourds can't grow
				local neighbors = {
					{ x = -1, y = 0, z = 0 },
					{ x = 1, y = 0, z = 0 },
					{ x = 0, y = 0, z = -1 },
					{ x = 0, y = 0, z = 1 },
				}
				local floorpos, floor
				for n = #neighbors, 1, -1 do
					local offset = neighbors[n]
					local blockpos = vector.add(stempos, offset)
					floorpos = vector.offset (blockpos, 0, -1,0) -- replaces { x = blockpos.x, y = blockpos.y - 1, z = blockpos.z }
					floor = minetest.get_node(floorpos)
					local block = minetest.get_node(blockpos)
					local soilgroup = minetest.get_item_group(floor.name, "soil")
					if not ((minetest.get_item_group(floor.name, "grass_block") == 1 or floor.name == "mcl_core:dirt" or soilgroup == 2 or soilgroup == 3) and block.name == "air") then
						table.remove(neighbors, n)
					end
				end

				-- Gourd needs at least 1 free neighbor to grow
				if #neighbors > 0 then
					-- From the remaining neighbors, grow randomly
					local r = math.random(1, #neighbors)
					local offset = neighbors[r]
					local blockpos = vector.add(stempos, offset)
					local p2
					if offset.x == 1 then
						minetest.set_node(stempos, { name = connected_stem_names[1] })
						p2 = 3
					elseif offset.x == -1 then
						minetest.set_node(stempos, { name = connected_stem_names[2] })
						p2 = 1
					elseif offset.z == 1 then
						minetest.set_node(stempos, { name = connected_stem_names[3] })
						p2 = 2
					elseif offset.z == -1 then
						minetest.set_node(stempos, { name = connected_stem_names[4] })
						p2 = 0
					end
					-- Place the gourd
					if gourd_def.paramtype2 == "facedir" then
						minetest.add_node(blockpos, { name = gourd_itemstring, param2 = p2 })
					else
						minetest.add_node(blockpos, { name = gourd_itemstring })
					end

					-- Reset farmland, etc. to dirt when the gourd grows on top

					-- FIXED: The following 2 lines were missing, and wasn't being set (outside of the above loop that
					-- finds the neighbors.)
					-- FYI - don't factor this out thinking that the loop above is setting the positions correctly.
					floorpos = vector.offset (blockpos, 0, -1,0) -- replaces { x = blockpos.x, y = blockpos.y - 1, z = blockpos.z }
					floor = minetest.get_node(floorpos)
					-- END OF FIX -------------------------------------
					if minetest.get_item_group(floor.name, "dirtifies_below_solid") == 1 then
						minetest.set_node(floorpos, { name = "mcl_core:dirt" })
					end
				end
			end
		end,
	})
end

-- Used for growing gourd stems. Returns the intermediate color between startcolor and endcolor at a step
-- * startcolor: ColorSpec in table form for the stem in its lowest growing stage
-- * endcolor: ColorSpec in table form for the stem in its final growing stage
-- * step: The nth growth step. Counting starts at 1
-- * step_count: The number of total growth steps
function mcl_farming:stem_color(startcolor, endcolor, step, step_count)
	local color = {}
	local function get_component(startt, endd, step, step_count)
		return math.floor(math.max(0, math.min(255, (startt + (((step - 1) / step_count) * endd)))))
	end
	color.r = get_component(startcolor.r, endcolor.r, step, step_count)
	color.g = get_component(startcolor.g, endcolor.g, step, step_count)
	color.b = get_component(startcolor.b, endcolor.b, step, step_count)
	local colorstring = string.format("#%02X%02X%02X", color.r, color.g, color.b)
	return colorstring
end

--[[Get a callback that either eats the item or plants it.

Used for on_place callbacks for craft items which are seeds that can also be consumed.
]]
function mcl_farming:get_seed_or_eat_callback(plantname, hp_change)
	return function(itemstack, placer, pointed_thing)
		local new = mcl_farming:place_seed(itemstack, placer, pointed_thing, plantname)
		if new then
			return new
		else
			return minetest.do_item_eat(hp_change, nil, itemstack, placer, pointed_thing)
		end
	end
end

function mcl_farming.on_bone_meal(itemstack,placer,pointed_thing,pos,n,plant,stages)
	local stages = stages or math.random(2, 5)
	return mcl_farming:grow_plant(plant, pos, n, stages, true)
end

minetest.register_lbm({
	label = "Add growth for unloaded farming plants",
	name = "mcl_farming:growth",
	nodenames = { "group:plant" },
	run_at_every_load = true,
	action = function(pos, node)
		local identifier = plant_nodename_to_id_list[node.name]
		if not identifier then
			return
		end
		local low_speed = minetest.get_node({ x = pos.x, y = pos.y - 1, z = pos.z }).name ~= "mcl_farming:soil_wet"
		mcl_farming:grow_plant(identifier, pos, node, false, false, low_speed)
	end,
})
