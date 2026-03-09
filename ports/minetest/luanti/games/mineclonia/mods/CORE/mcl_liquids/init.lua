--[[
This is a liquid transformation mod that aims to work more similar to the
liquids seen in Minecraft.
]]


local MODNAME = core.get_current_modname()
local S = core.get_translator(MODNAME)


if not core.settings:get_bool('mcl_liquids_enable', false) then
	mcl_liquids = {
		liquids_enabled = false,
		register_liquid = function(def)
		end,
		get_node_level = core.get_node_level,
	}
	return
end


--------------------------------------------------------------------------------
-- Variables that are the same for all liquids
--------------------------------------------------------------------------------

-- This is the initial state of the liquid transformation mod.
-- If set to false, liquids do not flow until they activated.
local STEP_INTERVAL = (not core.is_singleplayer() and 0.01)
	or tonumber(core.settings:get('dedicated_server_step')) or 0.05
local UPDATE_SPEED_DEFAULT = tonumber(core.settings:get('mcl_liquids_update_speed')) or 1.0
local UPDATE_LIMIT = (tonumber(core.settings:get('mcl_liquids_max_updates_per_second')) or 100000) * STEP_INTERVAL



-- If set to false, liquids do not flow until they activated.
local is_running = true

-- The main tick speed. Changing that tick affects all liquids
-- proportionally.
local update_speed = UPDATE_SPEED_DEFAULT

-- A list of registered liquids
local registered_liquids = {}


-- Count the number of nodes that were updated in a single tick
local batch_update_cnt = 0

-- This table checks if a node is floodable
local floodable_tab = {}
-- This table contains all the node definitions
local ndef_tab = {}


-- Store the original core functions that need to be overridden.
local core_set_node = core.set_node
local core_add_node = core.add_node
local core_bulk_set_node = core.bulk_set_node
local core_remove_node = core.remove_node


core.register_on_mods_loaded(function()
	-- Initialize global tables

	floodable_tab[core.CONTENT_AIR] = true
	for name, ndef in pairs(core.registered_nodes) do
		local id = core.get_content_id(name)

		if core.get_item_group(name, "dig_by_water") ~= 0 or
			ndef.floodable
		then
			floodable_tab[id] = true
		end

		ndef_tab[id] = ndef
	end
end)




--------------------------------------------------------------------------------
-- Top level functions
--------------------------------------------------------------------------------


local function get_position_from_hash(hash)
	local x = (hash % 65536) - 32768
	hash = math.floor(hash / 65536)
	local y = (hash % 65536) - 32768
	hash = math.floor(hash / 65536)
	local z = (hash % 65536) - 32768
	return x, y, z
end

local function hash_node_position(x, y, z)
	return (z + 0x8000) * 0x100000000 + (y + 0x8000) * 0x10000 + (x + 0x8000)
end


local function hmap_clear(tb)
	for k, _ in pairs(tb) do
		tb[k] = nil
	end
end

local function arr_clear(tb)
	for k, _ in ipairs(tb) do
		tb[k] = nil
	end
end



--[[
This function applies the transformation mechanic to liquid nodes.

The `def` is a table of the following format:

{
	-- The name of the liquid source node, that already exists.
	name_source = nil,
	-- The name of the liquid flowing node, that already exists.
	name_flowing = nil,
	-- The range of the liquid. It defaults to 7.
	range_spread = 7,
	-- The search range for the pathfinding. It defaults to 5.
	range_path = 5,
	-- if true, the liquid will be renewable. It defaults to false.
	renewable = false,
	-- The time in [seconds] between ticks. Lower values make liquids flow faster.
	-- The liquid tick can be be shorter than the Luanti tick. Liquids could
	-- therefore transform almost instantly or even instantly when setting this
	-- value to 0.0.
	tick_duration = 0.5,
}
]]
local function register_liquid(def)

	-- Constants for this particular liquid.
	local LIQUID_MODNAME = core.get_current_modname()

	local NAME_SOURCE = def.name_source
	assert(NAME_SOURCE, '"name_source" was nil')

	local NAME_FLOWING = def.name_flowing
	assert(NAME_FLOWING, '"name_flowing" was nil ')

	local RANGE_SPREAD = def.range_spread
	assert(RANGE_SPREAD, '"range_spread" was nil')
	assert(RANGE_SPREAD >= 0 and RANGE_SPREAD < 8,
		'The range_spread must be in range [0 <= x < 8]')

	local RANGE_PATH = def.range_path or 5
	assert(RANGE_PATH >= 0 and RANGE_PATH <= 5,
		'The range must be in range [0 <= x < 5]')

	local RENEWABLE = def.renewable and true or false

	local TICK_DURATION = def.tick_duration
	assert(TICK_DURATION, '"tick_duration" was nil')
	assert(TICK_DURATION >= 0.0,
		'The tick_duration must be a positive number')


	-- Constant node ids
	local C_FLOWING = core.get_content_id(NAME_FLOWING)
	local C_SOURCE = core.get_content_id(NAME_SOURCE)
	local C_IGNORE = core.CONTENT_IGNORE
	local C_AIR = core.CONTENT_AIR


	-- This table is a function that calculates then next lower liquid level.
	local level_tab = {}
	for i = 0, 9 do
		level_tab[i+1] = math.round(math.floor(i * (RANGE_SPREAD+1) / 8) * 8 / (RANGE_SPREAD+1))
	end


	-- This table checks if a node is floodable
	local pretend_floodable_tab = {}

	local function init_floodable_tab()
		pretend_floodable_tab[C_AIR] = true
		pretend_floodable_tab[C_FLOWING] = true
		pretend_floodable_tab[C_SOURCE] = true

		for name, ndef in pairs(core.registered_nodes) do

			local id = core.get_content_id(name)
			if core.get_item_group(name, "dig_by_water") ~= 0 then
				pretend_floodable_tab[id] = true
			end

			if ndef.floodable then
				pretend_floodable_tab[id] = true
			end
		end
	end


	----------------------------------------------------------------------
	-- Variables for processing a burst of iterations
	----------------------------------------------------------------------

	-- Swappable list of positions to be processed in the next iteration
	local update_next_set_A = {}
	local update_next_set_B = {}
	local update_next_set = update_next_set_A

	-- A list of nodes that have been changed during a burst.
	local changed_nodes = {}
	-- A list of nodes that have been red during the burst (caching)
	local read_nodes_cache_id = {}
	local read_nodes_cache_param2 = {}

	----------------------------------------------------------------------
	-- Variables for path finding to the nearest slope
	----------------------------------------------------------------------

	-- The list of nodes to be updated next.
	-- Two of them for GC-free swapping
	local pf_search_list_A = { }
	local pf_search_list_B = { }
	local pf_search_list

	-- The map of potential liquid levels.
	local pf_pmap = {}

	-- An array of node positions that hit a slope.
	-- Two of them for GC-free swapping
	local pf_found_A = { }
	local pf_found_B = { }
	local pf_found

	-- If false the path finding was not successful the whole iteration will be
	-- void.
	local pf_ok = true

	----------------------------------------------------------------------
	-- Variables for one liquid transformation iteration
	----------------------------------------------------------------------


	local g_x
	local g_y
	local g_z

	-- variables for the node ids
	local g_id111
	local g_id011
	local g_id211
	local g_id110
	local g_id112
	local g_id101
	local g_id121
	--
	-- variables for the node param2
	local g_par111
	local g_par011
	local g_par211
	local g_par110
	local g_par112
	local g_par101
	local g_par121

	-- variables for the liquid level
	local g_l111
	local g_l011
	local g_l211
	local g_l110
	local g_l112
	local g_l101
	local g_l121

	-- The map that show where the current liquid shall spread to.
	local g_map
	-- The level of the new node when spreading
	local g_new_level


	--[[

	Push a position into the queue to be processed next.

	@param x          The x coordinate of the position
	@param y          The y coordinate of the position
	@param z          The z coordinate of the position
	@param map        The map that shows where the current liquid shall spread to.
	@param is_sinking If the liquid is only allowed to sink.

	]]
	local function update_next(x, y, z, map, is_sinking)
		local h = hash_node_position(x, y, z)
		if update_next_set[h] == nil then
			update_next_set[h] = {map = map, is_sinking = is_sinking}
		end
	end


	--[[
	This function returns the level of a liquid node or nil if it isn't a
	liquid node.

	@param id         The id of the node
	@param param2     The param2 of the node
	@return           The level of the liquid node or nil if it isn't a liquid node.
	]]
	local function get_liquid_level(id, param2)
		if id == C_SOURCE then
			return 8
		elseif id == C_FLOWING then
			if bit.band(param2, 0x08) ~= 0 then
				return 8
			else
				return bit.band(param2, 0x07)
			end
		else
			return nil
		end
	end


	--[[
	This function schedules the update of a liquid related node.

	If there is already a node scheduled to be updated. The node with more liquid
	wins.

	@param x          The x coordinate of the position
	@param y          The y coordinate of the position
	@param z          The z coordinate of the position
	@param level      The level of the liquid node or 'source' if it is a source node.
	]]
	local function set_liquid_node(x, y, z, level)

		local h = hash_node_position(x, y, z)
		local other_level = changed_nodes[h]

		if not other_level then
			changed_nodes[h] = level
		elseif other_level == 'source' then
			return
		elseif level == 'source' then
			changed_nodes[h] = 'source'
			return
		elseif level > other_level then
			changed_nodes[h] = level
		end
	end

	local get_node_raw = core.get_node_raw

	--[[
	This function returns a requested node from the map. A cache is used for
	performance reasons.

	@param x          The x coordinate of the position
	@param y          The y coordinate of the position
	@param z          The z coordinate of the position
	@return           The id and param2 of the node
	]]
	local function get_cached_node(x, y, z)
		local h = hash_node_position(x, y, z)
		local id = read_nodes_cache_id[h]

		if id then
			return id, read_nodes_cache_param2[h]
		else
			local id, _, param2 = get_node_raw(x, y, z)
			read_nodes_cache_id[h] = id
			read_nodes_cache_param2[h] = param2
			return id, param2
		end
	end

	local arshift = bit.arshift
	local is_node_generated = function (_) return true end

	if mcl_vars.enable_mcl_levelgen then
		core.register_on_mods_loaded (function ()
			local dimension_at_layer = mcl_levelgen.dimension_at_layer
			local is_generated = mcl_levelgen.is_generated
			function is_node_generated (x, y, z)
				local dim = dimension_at_layer (y)
				return not dim or is_generated (dim, arshift (x, 4),
								arshift (y - dim.y_global, 4),
								arshift (z, 4))
			end
			local default_get_node_raw = core.get_node_raw
			local cid_ignore = core.CONTENT_IGNORE
			function get_node_raw (x, y, z)
				if is_node_generated (x, y, z) then
					local cid, param1, param2, pos_ok
						= default_get_node_raw (x, y, z)
					return cid, param1, param2, pos_ok
				else
					return cid_ignore, 0, 0, false
				end
			end
		end)
	end

	--[[
	This function creates a new liquid node.
	]]
	local function make_liquid(level)
		-- This function creates a new liquid node
		if level == 'source' then
			return {
				name = NAME_SOURCE,
				param2 = 0,
			}
		elseif level >= 8 then
			return {
				name = NAME_FLOWING,
				param2 = 15,
			}
		elseif level <= 0 then
			return {
				name = 'air',
				param2 = 0,
			}
		else
			return {
				name = NAME_FLOWING,
				param2 = bit.band(level, 0x07),
			}
		end
	end


	--[[
	This function returns true if the node pretends to be floodable.
	Pretend because source nodes are not floodable, but liquids want to spread there anyway.
	]]
	local function is_pretend_floodable(id)
		return pretend_floodable_tab[id] or false
	end


	-- This function checks if the current position has an obstacle or a
	-- slope.
	--
	-- `hpos`  A hash of the position
	-- `x`     The shift in the x direction
	-- `y`     The shift in the y direction
	-- `z`     The shift in the z direction
	-- `level` The level at the new position
	local function pf_step(hpos, x, y, z, level)
		local px, py, pz =  get_position_from_hash(hpos)
		px = px + x
		py = py + y
		pz = pz + z
		local hpos_next = hash_node_position(px, py, pz)

		if pf_pmap[hpos_next] == nil then
			local id1, par1 = get_cached_node(px, py, pz)

			-- move one down
			local id2 = get_cached_node(px, py-1, pz)

			if id1 == C_IGNORE or id2 == C_IGNORE then
				pf_ok = false
				return
			end

			local l1 = get_liquid_level(id1, par1)
			local f1 = is_pretend_floodable(id1)
			local f2 = is_pretend_floodable(id2)

			if f1 and f2 then
				pf_found[#pf_found+1] = hpos_next
				pf_pmap[hpos_next] = level
			elseif f1 and (l1 or 0) <= level then
				pf_search_list[#pf_search_list+1] = hpos_next
				pf_pmap[hpos_next] = level
			end
		end
	end

	local function pf_back_trace(hpos, x, y, z, level)
		local px, py, pz = get_position_from_hash(hpos)
		px = px + x
		py = py + y
		pz = pz + z
		local hpos_next = hash_node_position(px, py, pz)

		local m = pf_pmap[hpos_next]
		if m and m > level then
			pf_found[#pf_found+1] = hpos_next
		end
	end

	local function rmap_read(map, x, y, z)
		if not map or map == 'dummy' then
			return nil
		end

		local hpos = hash_node_position(x, y, z)
		return map[hpos]
	end

	-- This function searches the nearest slopes within a maximum path distance
	-- of 4 nodes.
	-- If any node was 'ignore' then this function returns nil.
	local function path_find(x, y, z)
		local id, param2 = get_cached_node(x, y, z)
		local orig_level = get_liquid_level(id, param2)
		if orig_level <= 1 then
			-- If level of the origin is too small we return a dummy map.
			return 'dummy'
		end

		-- initialize the variables.
		pf_ok = true
		arr_clear(pf_search_list_A)
		arr_clear(pf_search_list_B)
		pf_search_list = pf_search_list_A

		local h = hash_node_position(x, y, z)
		pf_search_list[1] = h

		hmap_clear(pf_pmap)

		-- An array of node positions that hit a slope.
		arr_clear(pf_found_A)
		arr_clear(pf_found_B)
		pf_found = pf_found_A

		-- The map containing the real paths (decreasing liquid levels from origin
		-- to slope) (the result)
		-- rmap is intentionally GC collectable, this reference will run wild!
		local rmap = {}
		pf_pmap[h] = orig_level
		local level = orig_level

		for i = 1, RANGE_PATH do
			-- Decrease the liquid level.
			level = level_tab[level]
			if level == 0 then
				break
			end

			local l = pf_search_list

			-- Swap the search lists
			if pf_search_list == pf_search_list_A then
				arr_clear(pf_search_list_B)
				pf_search_list = pf_search_list_B
			else
				arr_clear(pf_search_list_A)
				pf_search_list = pf_search_list_A
			end

			for i, hpos in ipairs(l) do
				-- Step into all 4 directions
				pf_step(hpos, -1, 0, 0, level)
				pf_step(hpos,  1, 0, 0, level)
				pf_step(hpos,  0, 0,-1, level)
				pf_step(hpos,  0, 0, 1, level)

				if not pf_ok then
					break
				end
			end

			if not pf_ok or #pf_found > 0 then
				break
			end
		end

		if pf_ok then
			if #pf_found == 0 then
				-- If we hit the minimum level without finding a slope. The liquid
				-- shall flow in all directions where there is no obstacle. The
				-- potential map becomes the real map.
				rmap = pf_pmap
				-- Let the reference run wild
				pf_pmap = {}
			else
				-- If a slope within range was found we need to remove all levels that
				-- are not part of the shortest path to those slopes.
				while #pf_found > 0 do
					local l = pf_found

					if pf_found == pf_found_A then
						arr_clear(pf_found_B)
						pf_found = pf_found_B
					else
						arr_clear(pf_found_A)
						pf_found = pf_found_A
					end

					for i, hpos in ipairs(l) do
						local level = pf_pmap[hpos]
						rmap[hpos] = level

						-- Search the origin.
						pf_back_trace(hpos, -1, 0, 0, level)
						pf_back_trace(hpos,  1, 0, 0, level)
						pf_back_trace(hpos,  0, 0,-1, level)
						pf_back_trace(hpos,  0, 0, 1, level)
					end
				end
			end

			return rmap

		else
			return nil
		end
	end

	local function lt_flood(x, y, z, id, l)
		local cnt_flood = 0
		local m = rmap_read(g_map, x, y, z)
		if m and m == g_new_level then
			if is_pretend_floodable(id) then
				-- Pretend floodable counts as target reached
				cnt_flood = 1

				if g_new_level > (l or 0) then
					update_next(x, y, z, g_map, false)
					set_liquid_node(x, y, z, g_new_level)

				elseif g_id111 == C_SOURCE and l and l == 7 then
					-- Give it a chance to renew into a source node
					update_next(x, y, z)
				end
			end
		end
		return cnt_flood
	end

	local function lt_push_horizontal()
		-- This function pushes the liquid in all four directions if the
		-- map wants that and the real node there is actually floodable.
		-- The number of *potential* floods are counted. If the count
		-- remains 0, the map is no longer suitable.
		local cnt_flood = 0
		cnt_flood = cnt_flood + lt_flood(g_x-1, g_y+0, g_z+0, g_id011, g_l011)
		cnt_flood = cnt_flood + lt_flood(g_x+1, g_y+0, g_z+0, g_id211, g_l211)
		cnt_flood = cnt_flood + lt_flood(g_x+0, g_y+0, g_z-1, g_id110, g_l110)
		cnt_flood = cnt_flood + lt_flood(g_x+0, g_y+0, g_z+1, g_id112, g_l112)
		return cnt_flood
	end


	local function flow_iteration(x, y, z, map, is_sinking)

		g_x = x
		g_y = y
		g_z = z

		g_map = map or nil
		is_sinking = is_sinking or false


		g_id111, g_par111 = get_cached_node(x + 0, y + 0, z + 0)
		if g_id111 == C_IGNORE then
			return
		end
		g_id011, g_par011 = get_cached_node(x - 1, y + 0, z + 0)
		g_id211, g_par211 = get_cached_node(x + 1, y + 0, z + 0)
		g_id101, g_par101 = get_cached_node(x + 0, y - 1, z + 0)
		g_id121, g_par121 = get_cached_node(x + 0, y + 1, z + 0)
		g_id110, g_par110 = get_cached_node(x + 0, y + 0, z - 1)
		g_id112, g_par112 = get_cached_node(x + 0, y + 0, z + 1)

		if g_id011 == C_IGNORE or
			g_id211 == C_IGNORE or
			g_id110 == C_IGNORE or
			g_id112 == C_IGNORE or
			g_id101 == C_IGNORE or
			g_id121 == C_IGNORE then
			return
		end

		if RENEWABLE then
			local count_sources = 0
			if g_id011 == C_SOURCE then count_sources = count_sources + 1 end
			if g_id211 == C_SOURCE then count_sources = count_sources + 1 end
			if g_id110 == C_SOURCE then count_sources = count_sources + 1 end
			if g_id112 == C_SOURCE then count_sources = count_sources + 1 end

			if (g_id111 == C_FLOWING or g_id111 == C_AIR) and count_sources >= 2 then
				-- Renew liquid
				update_next(g_x, g_y, g_z)
				set_liquid_node(g_x, g_y, g_z, 'source')
				if g_id011 ~= C_SOURCE then update_next(g_x-1, g_y+0, g_z+0) end
				if g_id211 ~= C_SOURCE then update_next(g_x+1, g_y+0, g_z+0) end
				if g_id110 ~= C_SOURCE then update_next(g_x+0, g_y+0, g_z-1) end
				if g_id112 ~= C_SOURCE then update_next(g_x+0, g_y+0, g_z+1) end
				return
			end
		end

		-- These variables store the level or nil if the node isn't a liquid.
		g_l111 = get_liquid_level(g_id111, g_par111)
		g_l011 = get_liquid_level(g_id011, g_par011)
		g_l211 = get_liquid_level(g_id211, g_par211)
		g_l110 = get_liquid_level(g_id110, g_par110)
		g_l112 = get_liquid_level(g_id112, g_par112)
		g_l101 = get_liquid_level(g_id101, g_par101)
		g_l121 = get_liquid_level(g_id121, g_par121)


		-- calculate the liquid level that is supported here.
		local support_level = 1

		if g_l121 ~= nil then
			-- node above is a liquid
			support_level = 9
		elseif g_id111 == C_SOURCE then
			-- the current node is a source
			support_level = 9
		else
			-- the neighboring node on the same Y-plan with the highest level counts
			if g_l011 ~= nil and support_level < g_l011 then
				support_level = g_l011
			end
			if g_l211 ~= nil and support_level < g_l211 then
				support_level = g_l211
			end
			if g_l110 ~= nil and support_level < g_l110 then
				support_level = g_l110
			end
			if g_l112 ~= nil and support_level < g_l112 then
				support_level = g_l112
			end
		end

		-- subtract 1 so that the level reaches from 0 to 8
		-- This variable tells us what level the current node should have.
		-- If it is higher we will reduce it and if it is lower we increase it.
		support_level = level_tab[support_level]

		if g_l111 ~= nil then
			-- The current node is already a liquid
			if g_l111 == support_level and not is_sinking then
				-- The current node is on its terminal level
				-- This means it is ready to spread.

				if is_pretend_floodable(g_id101) then
					if not g_l101 or g_l101 < 8 then
						-- turn the liquid below into down-flowing
						update_next(g_x, g_y-1, g_z)
						set_liquid_node(g_x, g_y-1, g_z, 8)
					end
				end


				-- Get the next level from a table
				g_new_level = level_tab[support_level]

				if (g_id111 == C_SOURCE or not is_pretend_floodable(g_id101))
						and g_new_level and g_new_level > 0 then

					local is_new_map = false
					if not g_map then
						-- Make a new map if there is none.
						g_map = path_find(g_x, g_y, g_z)
						if not g_map then
							return
						end
						is_new_map = true
					end

					if lt_push_horizontal() == 0 and not is_new_map then
						-- The map might be outdated, try once more with a new map
						g_map = path_find(g_x, g_y, g_z)
						if not g_map then
							return
						end
						lt_push_horizontal()
					end
				end
			elseif g_l111 > support_level then
				-- The liquid level is too high here we need to reduce it.

				if support_level > 0 then
					update_next(g_x, g_y, g_z, nil, true)
				end
				set_liquid_node(g_x, g_y, g_z, support_level)

				-- Neighboring nodes might need to be reduced as well
				if g_l011 ~= nil then update_next(g_x-1, g_y+0, g_z+0, nil, true) end
				if g_l211 ~= nil then update_next(g_x+1, g_y+0, g_z+0, nil, true) end
				if g_l110 ~= nil then update_next(g_x+0, g_y+0, g_z-1, nil, true) end
				if g_l112 ~= nil then update_next(g_x+0, g_y+0, g_z+1, nil, true) end

				-- the node below might need an update as well, but only if the liquid
				-- has completely gone
				if support_level == 0 and g_l101 ~= nil then
					update_next(g_x, g_y-1, g_z, nil, true)
				end
			end
		else
			-- It seams that the current node is not a liquid at all.
			-- We update the neighbors because it might have been a liquid
			-- previously.
			if g_l011 ~= nil then update_next(g_x-1, g_y+0, g_z+0) end
			if g_l211 ~= nil then update_next(g_x+1, g_y+0, g_z+0) end
			if g_l101 ~= nil then update_next(g_x+0, g_y-1, g_z+0) end
			if g_l121 ~= nil then update_next(g_x+0, g_y+1, g_z+0) end
			if g_l110 ~= nil then update_next(g_x+0, g_y+0, g_z-1) end
			if g_l112 ~= nil then update_next(g_x+0, g_y+0, g_z+1) end
		end
	end

	local function liquid_update(x, y, z)
		update_next(x, y, z)
	end

	local function liquid_update_raw (poshash)
		local px, py, pz = get_position_from_hash (poshash)
		update_next (px, py, pz)
	end

	local function fix_ndef(ndef_name)
		local ndef = core.registered_nodes[ndef_name]
		local groups = table.copy(ndef.groups or {})
		local drawtype

		if ndef.liquidtype == 'source' then
			groups["liquid_source"] = 1
			drawtype                = "liquid"
		elseif ndef.liquidtype == 'flowing' then
			groups["liquid_flowing"] = 1
			drawtype                = "flowingliquid"
		end

		local liquid_move_physics = ndef.liquid_move_physics
		if liquid_move_physics == nil then
			liquid_move_physics = true
		end

		core.override_item(ndef.name, {
			drawtype = drawtype,
			paramtype = "light",
			paramtype2 = "flowingliquid",
			groups = groups,
			liquid_move_physics = liquid_move_physics,
		}, {'liquidtype'})

	end

	fix_ndef(NAME_SOURCE)
	fix_ndef(NAME_FLOWING)

	core.register_on_mods_loaded(function()
		-- Luanti activates the builtin liquid transformation based on the
		-- `liquidtype`. Therefor we need to set it's value to 'none'.
		-- BUT many mods also read that value to check if this node is a liquid.
		-- This hack sets the value to the respective liquid type after Luanti red
		-- its value.
		-- This way mods see what they need, at least their callbacks do.
		local function set_liquidtype(name, liquidtype)
			local mt = getmetatable(core.registered_nodes[name])
			local oldidx = mt.__index
			mt.__index = function(tbl, k)
				if k == "liquidtype" then
					return liquidtype
				end
				if type(oldidx) == "function" then return oldidx(tbl, k) end
				if type(oldidx) == "table" and not rawget(tbl, k) then return oldidx[k] end
				return tbl[k]
			end
			setmetatable(core.registered_nodes[name], mt)
		end

		set_liquidtype(NAME_SOURCE, 'source')
		set_liquidtype(NAME_FLOWING, 'flowing')

		assert(core.registered_nodes[NAME_SOURCE].liquidtype == 'source',
		'This hack does no longer work ('..NAME_SOURCE..')')
		assert(core.registered_nodes[NAME_FLOWING].liquidtype == 'flowing',
		'This hack does no longer work ('..NAME_FLOWING..')')

		init_floodable_tab()
	end)


	--[[
	This function makes a fitting name for the LBMs
	]]
	local function make_lbm_name(node)
		local arr = string.split(node, ":")
		local lbm = LIQUID_MODNAME .. ":" .. MODNAME
		lbm = lbm .. "__resume__" .. arr[1] .. "__" .. arr[2]
		return lbm
	end


	--[[
	This function tests if a source liquid needs to be updated.
	]]
	local function does_sl_need_update(x, y, z)

		--------------------------------------------------
		-- Check for potential spreading                --
		--------------------------------------------------

		-- Could spread down
		local id101, _, p101 = get_node_raw (x, y-1, z)
		if floodable_tab[id101] then return true end
		local l101 = get_liquid_level (id101, p101)
		if l101 and l101 < 8 then return true end

		local next_level = level_tab[8]

		-- Could spread to x-1
		local id011, _, p011 = get_node_raw (x-1, y, z)
		if floodable_tab[id011] then return true end
		local l011 = get_liquid_level (id011, p011)
		if l011 and l011 < next_level then return true end

		-- Could spread to x+1
		local id211, _, p211 = get_node_raw (x+1, y, z)
		if floodable_tab[id211] then return true end
		local l211 = get_liquid_level (id211, p211)
		if l211 and l211 < next_level then return true end

		-- Could spread to z-1
		local id110, _, p110 = get_node_raw (x, y, z-1)
		if floodable_tab[id110] then return true end
		local l110 = get_liquid_level (id110, p110)
		if l110 and l110 < next_level then return true end

		-- Could spread to z+1
		local id112, _, p112 = get_node_raw (x, y, z+1)
		if floodable_tab[id112] then return true end
		local l112 = get_liquid_level (id112, p112)
		if l112 and l112 < next_level then return true end

		return false
	end

	local band = bit.band

	core.register_lbm({
		label = "Continue the liquids",
		name = make_lbm_name(NAME_SOURCE),
		nodenames = {NAME_SOURCE},
		run_at_every_load = true,
		bulk_action = function(pos_list, dtime_s)
			local pos = pos_list[1]
			local minpos = vector.new (band (pos.x, -16),
						   band (pos.y, -16),
						   band (pos.z, -16))
			local maxpos = minpos:add (15)

			if not is_node_generated (minpos.x, minpos.y, minpos.z) then
				-- MapBlocks that have not yet been
				-- regenerated must not be subject to
				-- reflow processing.
				return false
			end

			-- load neighbouring mapblocks to avoid ignore nodes
			core.load_area(minpos:subtract(1), maxpos:add(1))

			if #pos_list == 16*16*16 then
				-- Special case if all nodes are the same liquid
				local a = minpos:subtract(1)
				local b = minpos:add(1)
				for i = 1, #pos_list do
					local pos = pos_list[i]
					local x = pos.x
					local y = pos.y
					local z = pos.z

					if a.x == x or b.x == x or
						a.y == y or b.y == y or
						a.z == z or b.z == z then

						if does_sl_need_update(x, y, z) then
							liquid_update (x, y, z)
						end
					end
				end
			else
				for i = 1, #pos_list do
					local pos = pos_list[i]
					local x = pos.x
					local y = pos.y
					local z = pos.z

					if does_sl_need_update(x, y, z) then
						liquid_update (x, y, z)
					end
				end
			end
		 end,
	})


	--[[
	This function tests if a flowing liquid needs to be updated.
	]]
	local function does_fl_need_update(x, y, z)

		--------------------------------------------------
		-- Check for potential spreading                --
		--------------------------------------------------

		-- Could spread down
		local id101, _, p101 = get_node_raw (x, y-1, z)
		if floodable_tab[id101] then return true end
		local l101 = get_liquid_level (id101, p101)
		if l101 and l101 < 8 then return true end

		local id111, _, p111 = get_node_raw (x, y, z)
		local l111 = get_liquid_level (id111, p111)
		if not l111 then
			-- TODO handle corrupted liquid node
			return false
		end

		local next_level = level_tab[l111] or 0

		-- Could spread to x-1
		local id011, _, p011 = get_node_raw (x-1, y, z)
		if floodable_tab[id011] then return true end
		local l011 = get_liquid_level (id011, p011)
		if l011 and l011 < next_level then return true end

		-- Could spread to x+1
		local id211, _, p211 = get_node_raw (x+1, y, z)
		if floodable_tab[id211] then return true end
		local l211 = get_liquid_level (id211, p211)
		if l211 and l211 < next_level then return true end

		-- Could spread to z-1
		local id110, _, p110 = get_node_raw (x, y, z-1)
		if floodable_tab[id110] then return true end
		local l110 = get_liquid_level (id110, p110)
		if l110 and l110 < next_level then return true end

		-- Could spread to z+1
		local id112, _, p112 = get_node_raw (x, y, z+1)
		if floodable_tab[id112] then return true end
		local l112 = get_liquid_level (id112, p112)
		if l112 and l112 < next_level then return true end

		--------------------------------------------------
		-- Check if the liquid could turn into a source --
		--------------------------------------------------

		local count_sources = 0
		if id011 == C_SOURCE then count_sources = count_sources + 1 end
		if id211 == C_SOURCE then count_sources = count_sources + 1 end
		if id110 == C_SOURCE then count_sources = count_sources + 1 end
		if id112 == C_SOURCE then count_sources = count_sources + 1 end
		if count_sources >= 2 then return true end


		--------------------------------------------------
		-- Check if the liquid level is supported       --
		--------------------------------------------------

		-- Check for support from x-1
		if l011 and l011 > l111 then return false end
		-- Check for support from x+1
		if l211 and l211 > l111 then return false end
		-- Check for support from z-1
		if l110 and l110 > l111 then return false end
		-- Check for support from z+1
		if l112 and l112 > l111 then return false end


		-- Check for support from above
		local id121, _, p121 = get_node_raw (x, y+1, z)
		local l121 = get_liquid_level (id121, p121)
		if l121 and l121 > 0 then return false end

		-- The level is not supported, so we need an update
		return true
	end


	core.register_lbm({
		label = "Continue the liquids",
		name = make_lbm_name(NAME_FLOWING),
		nodenames = {NAME_FLOWING},
		run_at_every_load = true,
		bulk_action = function(pos_list, dtime_s)
			local minpos = pos_list[1]:divide(16):floor():multiply(16)
			local maxpos = minpos:add(15)
			if is_node_generated (minpos.x, minpos.y, minpos.z) then
				-- load neighbouring mapblocks to avoid ignore nodes
				core.load_area(minpos:subtract(1), maxpos:add(1))

				for i = 1, #pos_list do
					local pos = pos_list[i]
					local x = pos.x
					local y = pos.y
					local z = pos.z

					if does_fl_need_update(x, y, z) then
						update_next(x, y, z)
					end
				end
			end
		 end,
	})

	local tick_dtime = 0.0


	-- This function does the final checks and writes the changed nodes into the
	-- world.
	local function write_changed_nodes(changed_nodes)
		for h, level in pairs(changed_nodes) do
			local x, y, z = get_position_from_hash(h)

			local old_id = get_cached_node(x, y, z)
			if is_pretend_floodable(old_id) then

				local old_ndef = ndef_tab[old_id]
				local pos = vector.new(x, y, z)
				local node = make_liquid(level)

				if old_ndef.on_flood then
					if not old_ndef.on_flood(pos, core.get_node(pos), node) then
						core_set_node(pos, node)
					end
				else
					core_set_node(pos, node)
				end
			end
		end
	end



	local function liquid_tick()
		tick_dtime = tick_dtime + STEP_INTERVAL * update_speed

		-- If the TICK_DURATION is smaller than Luanti default tick we do
		-- multiple steps per tick.
		while tick_dtime >= TICK_DURATION do
			tick_dtime = tick_dtime - TICK_DURATION

			if next(update_next_set) ~= nil then
				local q = update_next_set

				-- Reset the containers for reuse
				if update_next_set == update_next_set_A then
					hmap_clear(update_next_set_B)
					update_next_set = update_next_set_B
				else
					hmap_clear(update_next_set_A)
					update_next_set = update_next_set_A
				end

				hmap_clear(read_nodes_cache_id)
				hmap_clear(read_nodes_cache_param2)
				hmap_clear(changed_nodes)

				for hpos, item in pairs(q) do
					local x, y, z = get_position_from_hash(hpos)
					-- Do the flow magic
					flow_iteration(x, y, z, item.map, item.is_sinking)

					-- Continue the transformation in the next global step the
					-- limit has been reached.
					batch_update_cnt = batch_update_cnt + 1
					if batch_update_cnt == UPDATE_LIMIT then
						coroutine.yield()
						-- The nodes might have been changed. We need to clear
						-- the cache
						hmap_clear(read_nodes_cache_id)
						hmap_clear(read_nodes_cache_param2)
						batch_update_cnt = 0

					end
				end

				write_changed_nodes(changed_nodes)

			elseif TICK_DURATION == 0.0 then
				tick_dtime = 0.0
				break
			end
		end
	end

	registered_liquids[#registered_liquids+1] = {
		tick = liquid_tick,
		update = liquid_update,
		update_raw = liquid_update_raw,
		cid_source = C_SOURCE,
		cid_flowing = C_FLOWING,
	}
end

-- This function is called once per tick to update all registered liquids.
local liquid_tick = coroutine.wrap(function()
	while true do
		batch_update_cnt = 0
		for i, o in ipairs(registered_liquids) do
			-- Errors must be reported by hand, for the
			-- engine does not log errors in coroutines,
			-- which proceed silently to terminate them.
			local ok, err = pcall (o.tick)
			if not ok then
				local blurb
					= "Error in liquid transformation loop: " .. tostring (err)
				core.log ("error", blurb)
			end
		end
		-- We yield here because there is nothing left to do in this global step.
		coroutine.yield()
	end
end)


-- This function notifies the registered liquids about a node that has changed.
local function liquid_update(pos)
	for i, o in ipairs(registered_liquids) do
		o.update(pos.x, pos.y, pos.z)
	end
end

local timer = 0
core.register_globalstep(function(dtime)
	if not is_running then
		timer = 0
		return
	end

	timer = timer + dtime
	while timer > STEP_INTERVAL do
		liquid_tick ()
		timer = timer - STEP_INTERVAL
	end
end)

core.register_privilege("liquid", {
	description = S('Allows to change the runtime behaviour of liquids')
})

core.register_chatcommand('liquid', {
	params = 'run | stop | step',
	description = S('This command is used to debug liquid transformation'),
	privs = {liquid=true},

	func = function(name, param)
		if param == 'step' then
			is_running = false
			liquid_tick()
			return true
		elseif param == 'run' then
			is_running = true
			return true
		elseif param == 'stop' then
			is_running = false
			return true
		else
			return false
		end
	end
})

core.register_chatcommand('liquid_tick', {
	params = '<factor> | default | get',
	description =
		S('This command sets the time passed between Luanti ticks.')..' '..
		S('If this value is larger than the actual tick, liquids become faster than specified.'),
	privs = {liquid=true},

	func = function(name, param)
		if param == 'default' then
			update_speed = UPDATE_SPEED_DEFAULT
			return true
		elseif param == 'get' then
			return true, tostring(update_speed)
		else
			local new_speed = tonumber(param)
			if new_speed == nil then
				return false
			elseif new_speed >= 0.0 then
				update_speed = new_speed
				return true
			else
				return false, 'Invalid speed factor: '..param
			end
		end
	end
})

core.register_on_mods_loaded(function()
	-- `liquids_pointable` does not work anymore. This should solve many
	-- issues.
	for name, ndef in pairs(core.registered_items) do
		if ndef.liquids_pointable then
			local p = table.copy(ndef.pointabilities or {})

			if not p.nodes then
				p.nodes = {}
			end

			if not p.nodes["group:liquid"] and
				not p.nodes["group:liquid_source"] and
				not p.nodes["group:liquid_flowing"] then

				core.log("warning", 'Node "'..name..'" uses deprecated "liquids_pointable" attribute')
				p.nodes["group:liquid"] = true
				core.override_item(name, {
					pointabilities = p
				})
			end
		end
	end
end)

-- Override the set_node function so that it calls liquid_update() on every
-- node change.
core.set_node = function(pos, node)
	core_set_node(pos, node);
	liquid_update(pos);
end

-- Override the add_node function so that it calls liquid_update() on every
-- node change.
core.add_node = function(pos, node)
	core_add_node(pos, node)
	liquid_update(pos)
end

-- Override the bulk_set_node function so that it calls liquid_update() on every
-- node change.
core.bulk_set_node = function(positions, node)
	core_bulk_set_node(positions, node)
	for _, p in ipairs(positions) do
		liquid_update(p)
	end
end

-- Override the remove_node function so that it calls liquid_update() on every
-- node change.
core.remove_node = function(pos)
	core_remove_node(pos)
	liquid_update(pos)
end

-- Export the liquid API functions
mcl_liquids = {
	liquids_enabled = true,
	register_liquid = register_liquid,
	registered_liquids = registered_liquids,
}

local band = bit.band
local LIQUID_LEVEL_MASK = 0x7

function mcl_liquids.get_node_level (pos)
	local cid, _, param2
		= core.get_node_raw (pos.x, pos.y, pos.z)
	for _, liquid in ipairs (registered_liquids) do
		if liquid.cid_source == cid then
			return 8
		elseif liquid.cid_flowing == cid then
			return band (param2, LIQUID_LEVEL_MASK)
		end
	end
	return core.get_node_level (pos)
end
