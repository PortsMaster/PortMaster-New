local ipairs = ipairs
local pairs = pairs

------------------------------------------------------------------------
-- Biome and level data transmission to client-side players.
------------------------------------------------------------------------

local insert = table.insert
local ipos3 = mcl_levelgen.ipos3
local levelgen_enabled = mcl_levelgen.levelgen_enabled
local floor = math.floor

local function send_biome_data_updates_p (state)
	return state.proto >= 7 or levelgen_enabled
end

local function get_biome_meta (x, y, z)
	if levelgen_enabled then
		return mcl_levelgen.get_biome_meta (x, y, z)
	else
		return mcl_serverplayer.get_engine_biome_meta (x, y, z)
	end
end

local function get_biome_state (state)
	if state.biome_state then
		return state.biome_state
	end
	local tbl = {
		-- Number of MapBlocks whose biome data is known to
		-- have been transferred to the client.
		num_loaded = 0,
		-- Map between MapBlock hashes and booleans indicating
		-- that data at that position is known to the client.
		is_loaded = {},
		dtime_since_last_transfer = 0.5,
	}
	state.biome_state = tbl
	return tbl
end

local MAX_LOADED_MAPBLOCKS = 2048
-- Transfer biome data within a radius of 3 blocks around each player,
-- or 2 when only the built-in biome system is available, as biome
-- sampling is too expensive to admit of the former value.
local MAP_BLOCK_RANGE
	= mcl_levelgen.levelgen_enabled and 3 or 2
local arshift = bit.arshift

local function hashmapblock (x, y, z)
	return (y + 2048) * 16777216
		+ (x + 2048) * 4096
		+ (z + 2048)
end

local function unhashmapblock (hash)
	local y = floor (hash / 16777216) - 2048
	local x = floor (hash / 4096 % 4096) - 2048
	local z = hash % 4096 - 2048
	return x, y, z
end

local function within_map_limits_p (x, y, z)
	return x >= -2048 and x <= 2047
		and z >= -2048 and z <= 2047
		and y >= -2048 and y <= 2047
end

local buffer = {}
local sub = string.sub
local concat = table.concat

local function substitute_zeros (meta)
	if not levelgen_enabled then
		-- Server-side biomes always yield IDs greater than 0.
		return meta
	end

	for i = 1, #meta do
		local c = sub (meta, i, i)
		if c == '\0' then
			buffer[i] = '\255'
		else
			buffer[i] = c
		end
	end

	for i = #meta + 1, #buffer do
		buffer[i] = nil
	end
	return concat (buffer)
end

local v = vector.new ()

function mcl_serverplayer.update_biome_data (state, player, dtime)
	if not send_biome_data_updates_p (state) then
		return
	end

	local tbl = get_biome_state (state)
	local t = tbl.dtime_since_last_transfer + dtime
	if t < 0.5 then
		tbl.dtime_since_last_transfer = t
		return
	else
		tbl.dtime_since_last_transfer = t % 0.5
	end

	if tbl.num_loaded > MAX_LOADED_MAPBLOCKS then
		-- The client isn't disposing of loaded MapBlocks;
		-- delete tbl.is_loaded to prevent it from burgeoning
		-- endlessly.
		tbl.is_loaded = {}
		tbl.num_loaded = 0
	end

	local self_pos = player:get_pos ()
	local node_pos = mcl_util.get_nodepos (self_pos)
	local bx = arshift (node_pos.x, 4)
	local by = arshift (node_pos.y, 4)
	local bz = arshift (node_pos.z, 4)

	local load_list, meta_list = {}, {}
	local len = 0

	local is_loaded = tbl.is_loaded
	for x, y, z in ipos3 (bx - MAP_BLOCK_RANGE,
			      by - MAP_BLOCK_RANGE,
			      bz - MAP_BLOCK_RANGE,
			      bx + MAP_BLOCK_RANGE,
			      by + MAP_BLOCK_RANGE,
			      bz + MAP_BLOCK_RANGE) do
		local hash = hashmapblock (x, y, z)
		if not is_loaded[hash] and within_map_limits_p (x, y, z) then
			v.x = x * 16
			v.y = y * 16
			v.z = z * 16
			if core.compare_block_status (v, "loaded") then
				local meta = get_biome_meta (x, y, z)
				if meta then
					is_loaded[hash] = true
					tbl.num_loaded = tbl.num_loaded + 1
					insert (load_list, hash)
					insert (load_list, len)
					len = len + #meta
					-- Replace biome ID 0 with ID
					-- 255, as the Luanti
					-- modchannel API is not
					-- NULL-byte clean.  It is not
					-- necessary to account for
					-- run length values, as they
					-- are never 0 anyway.
					insert (meta_list, substitute_zeros (meta))
				end
			end
		end
	end

	-- Dispatch the biome data to the client.
	if len > 0 then
		local index = table.concat (load_list, ',')
		local meta = table.concat (meta_list)
		mcl_serverplayer.send_biome_data (player, index, meta)
	end
end

local blurb = "[mcl_serverplayer]: Client %s attempted to report relinquishment of biome data in MapBlock not recorded by the server: %d,%d,%d"

function mcl_serverplayer.discard_biome_data (player, state, list)
	local tbl = get_biome_state (state)
	for _, block in ipairs (list) do
		if block >= 0x1000000000 then
			error ("MapBlock out of range: " .. block)
		end

		if not tbl.is_loaded[block] then
			local name = player:get_player_name ()
			local msg = string.format (blurb, name,
						   unhashmapblock (block))
			core.log ("warning", msg)
		else
			tbl.num_loaded = tbl.num_loaded - 1
			tbl.is_loaded[block] = nil
			assert (tbl.num_loaded >= 0)
		end
	end
end

------------------------------------------------------------------------
-- Engine biome system adapter.
------------------------------------------------------------------------

local engine_id_to_name_map, engine_name_to_def_map

function mcl_serverplayer.marshal_engine_biomes ()
	if engine_id_to_name_map then
		return engine_id_to_name_map,
			engine_name_to_def_map
	else
		local fields_to_copy = {
			"_mcl_biome_type",
		}
		engine_id_to_name_map = {}
		engine_name_to_def_map = {}
		for biome, def in pairs (core.registered_biomes) do
			local tbl = {}
			local id = core.get_biome_id (biome)
			assert (id > 0 and id <= 255)
			engine_id_to_name_map[tostring (id)] = biome
			engine_name_to_def_map[biome] = tbl

			for _, field in ipairs (fields_to_copy) do
				tbl[field] = def[field]
			end
		end
		return engine_id_to_name_map, engine_name_to_def_map
	end
end

local v = vector.new ()
local function get_biome_id (x, y, z)
	v.x = x
	v.y = y
	v.z = z
	return core.get_biome_data (v).biome or 1
end

local char = string.char

function mcl_serverplayer.get_engine_biome_meta (bx, by, bz)
	local x0 = bx * 16 + 4
	local y0 = by * 16 + 8
	local z0 = bz * 16 + 4
	local x1 = bx * 16 + 12
	local z1 = bz * 16 + 12

	-- Sample at 8 node intervals horizontally and at the center
	-- of the mapblock vertically.

	local x0y0z0 = get_biome_id (x0, y0, z0)
	local x0y0z1 = get_biome_id (x0, y0, z1)
	local x1y0z0 = get_biome_id (x1, y0, z0)
	local x1y0z1 = get_biome_id (x1, y0, z1)

	local x0y1z0 = x0y0z0
	local x0y1z1 = x0y0z1
	local x1y1z0 = x1y0z0
	local x1y1z1 = x1y0z1

	-- Encoded format:
	local str = {
		x0y0z0, x0y0z0,
		x0y0z1, x0y0z1,
		x0y0z0, x0y0z0,
		x0y0z1, x0y0z1,
		x0y0z0, x0y0z0,
		x0y0z1, x0y0z1,
		x0y0z0, x0y0z0,
		x0y0z1, x0y0z1,

		x0y1z0, x0y1z0,
		x0y1z1, x0y1z1,
		x0y1z0, x0y1z0,
		x0y1z1, x0y1z1,
		x0y1z0, x0y1z0,
		x0y1z1, x0y1z1,
		x0y1z0, x0y1z0,
		x0y1z1, x0y1z1,

		x1y0z0, x1y0z0,
		x1y0z1, x1y0z1,
		x1y0z0, x1y0z0,
		x1y0z1, x1y0z1,
		x1y0z0, x1y0z0,
		x1y0z1, x1y0z1,
		x1y0z0, x1y0z0,
		x1y0z1, x1y0z1,

		x1y1z0, x1y1z0,
		x1y1z1,	x1y1z1,
		x1y1z0, x1y1z0,
		x1y1z1,	x1y1z1,
		x1y1z0, x1y1z0,
		x1y1z1,	x1y1z1,
		x1y1z0, x1y1z0,
		x1y1z1,	x1y1z1,

		nil,
	}
	local meta = ""
	local n = 0
	for i = 1, 65 do
		local c = str[i]
		if i > 1 then
			local prev = str[i - 1]
			if c ~= prev then
				meta = meta .. char (n)
				meta = meta .. char (prev)
				n = 0
			end
		end
		n = n + 1
	end
	return meta
end

------------------------------------------------------------------------
-- Miscellaneous utilities.
------------------------------------------------------------------------

local dim_keys_to_copy = {
	"y_global",
	"y_global_block",
	"y_max",
	"y_offset",
	"id",
}

function mcl_serverplayer.marshal_registered_dimensions ()
	local tbl = {}
	for _, dim in ipairs (mcl_levelgen.dimensions_sorted) do
		local export = {}
		for _, key in ipairs (dim_keys_to_copy) do
			export[key] = dim[key]
		end
		table.insert (tbl, export)
	end
	return tbl
end
