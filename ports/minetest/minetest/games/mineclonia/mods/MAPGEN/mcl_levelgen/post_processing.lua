local ipairs = ipairs
local ipos1 = mcl_levelgen.ipos1
local ipos2 = mcl_levelgen.ipos2
local insert = table.insert

local function get_generation_extents (mt_chunksize, center, limit)
	assert (center.x == center.z)
	assert (mt_chunksize.x == mt_chunksize.z)
	local mapgen_limit = limit or core.get_mapgen_setting ("mapgen_limit")
	local max_block = math.floor (mapgen_limit / 16) - 1 -- Overgeneration.
	local cnt_to_max_block = max_block - center.x + 1
	local max_chunk = math.floor (cnt_to_max_block / mt_chunksize.x)
	local max = center.x + max_chunk * mt_chunksize.x - 1

	local min_block = -max_block
	local min_start = center.x - 1
	local cnt_to_min_block = min_start - min_block + 1
	local min_chunk = math.floor (cnt_to_min_block / mt_chunksize.x)
	local min = min_start - min_chunk * mt_chunksize.x + 1

	return max, min
end

local S = core.get_translator ("mcl_levelgen")
local maxblock, minblock
local mt_chunksize = mcl_levelgen.mt_chunksize
local chunksize = mt_chunksize.x * 16
local server_map_save_interval
	= (core.settings:get ("server_map_save_interval") or 5.3)

do
	local mt_chunk_origin = mcl_levelgen.mt_chunk_origin
	local mt_chunk_limit = mcl_levelgen.mt_chunk_limit
	maxblock, minblock = get_generation_extents (mt_chunksize,
						     mt_chunk_origin,
						     mt_chunk_limit)
end

--------------------------------------------------------------------------
-- Level post-processing.
--------------------------------------------------------------------------

-- Decorations are divided into two types, structures and features,
-- between which the chief difference is that structure placement is
-- decided by the level seed alone, and precedes and exerts influence
-- on terrain generation, while feature placement is contingent on
-- characteristics of the terrain unavailable before generation
-- concludes.  Therefore, in contrast to structures, which may occupy
-- multiple MapChunks because their positions in each are available
-- independently of the contents of their origins or adjoining chunks,
-- features must be placed after their origins are generated and care
-- must be taken that adjoining mapblocks should also be available and
-- ready to receive any portion of a feature that should extrude
-- beyond the chunk where it is placed.  This does however place an
-- upper limit on the size of a feature; more below.
--
-- Since adjacent chunks are not available in an emerge environment,
-- terrain that is initially received from the said environment is
-- designated as "proto-chunks", and some record-keeping is undertaken
-- in the main thread to ascertain when a sufficient periphery has
-- been generated around a proto-chunk for feature placement to
-- commence, whereupon the periphery and proto-chunk at hand are
-- loaded into a VoxelManipulator and submitted to an async
-- environment for feature processing and the periphery is excluded
-- from further modification till the proto-chunk is complete.  This
-- component is the "regeneration scheduler."
--
-- Feature generation may also be influenced by the products of prior
-- feature generation, in particular, on alterations to the surface
-- height they may have produced.  This is problematic because
-- Luanti worlds are also partitioned into MapBlocks vertically, so
-- that heightmap modifications for one phase are not certain to be
-- conclusive when the next phase commences, which issue is partially
-- addressed by increasing the height of the periphery required of
-- each MapBlock processed.

local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local lshift = bit.lshift
local rshift = bit.rshift
local arshift = bit.arshift

local floor = math.floor
local mathmin = math.min
local mathmax = math.max

local function dbg (...)
	-- print (string.format (...))
end

local function dbgjournal (...)
	-- print (string.format (...))
end

local dummy_map_backend_enabled_p

do
	local settings = Settings (core.get_worldpath () .. "/world.mt")
	dummy_map_backend_enabled_p = settings:get ("backend") == "dummy"
end

-- Server-side occlusion culling prevents MapBlocks near the player
-- from being regenerated, but only applies to MapBlocks that are yet
-- to be emerged.  Therefore it should be harmless just to disable it.
core.settings:set_bool ("server_side_occlusion_culling", false)

--------------------------------------------------------------------------
-- MapBlock tagging.
--------------------------------------------------------------------------

-- Each column of MapBlocks in each dimension enjoys 8 bits' worth of
-- tags globally accessible that decide whether or not it is a
-- proto-block.  These tags are stored in mod storage in 256x24x256
-- sections (in the case of the Overworld); when represented as
-- doubles where 32 bits of the significand are available for bitwise
-- operations each section amounts to roughly 4 megabytes.

local SS = 256
local SSHIFT = 8
local HEIGHT = 32
local HEIGHT_SHIFT = 5
local NUMBER_BITS = 4
local INDICES = floor ((SS * HEIGHT * SS * 8 + NUMBER_BITS - 1) / NUMBER_BITS)

local namespaces = {}
local current_namespace_id = nil
local current_namespace_height = nil
local current_namespace = nil
local max_data_namespace = 0

-- Build a list of namespaces from currently registered dimensions.

if not mcl_levelgen.load_feature_environment then

core.register_on_mods_loaded (function ()
	local for_each_dimension = mcl_levelgen.for_each_dimension
	for _, dim in for_each_dimension () do
		local namespace = {
			-- MapBlock extents of the level this
			-- namespace represents in the global
			-- coordinate system.
			y_bottom = floor (dim.y_global / 16),
			y_top = floor (dim.y_max / 16),

			-- Node extents of the level this namespace
			-- represents in the global coordinate system.
			y_global = dim.y_global,
			y_global_top = dim.y_max,

			-- Bottom of level in its coordinate system.
			y_min = dim.preset.min_y,

			-- Offset for translating global coordinates
			-- into level-local coordinates.
			y_offset = dim.y_offset,

			-- Identifiers.
			dim_id = dim.id,
			data_namespace = dim.data_namespace,
		}
		local height = namespace.y_top - namespace.y_bottom + 1
		assert (height <= HEIGHT)
		namespace.height = height
		namespaces[dim.data_namespace] = namespace
		max_data_namespace = mathmax (dim.data_namespace,
					      max_data_namespace)
	end
	mcl_levelgen.clear_sections_loaded ()
end)

end

local function switch_to_namespace (id)
	if id then
		current_namespace = namespaces[id]
		current_namespace_id = id
		current_namespace_height = current_namespace.height
	else
		current_namespace = nil
		current_namespace_id = nil
		current_namespace_height = nil
	end
end

local storage = core.get_mod_storage and core.get_mod_storage () or nil

local function section (bx, bz)
	local xs = bx - 128
	local zs = bz - 128
	return arshift (xs, SSHIFT), arshift (zs, SSHIFT)
end

local function section_hash (id, sx, sz)
	return lshift (id, 10) + lshift (sx + 9, 5) + sz + 9
end

local loaded_mb_sections = {}
local section_access_times = {}
local sections_loaded = {}

function mcl_levelgen.clear_sections_loaded ()
	for i = 1, section_hash (max_data_namespace, 8, 8) + 1 do
		sections_loaded[i] = false
	end
end

local function create_section (hash)
	local tbl = {}
	for i = 1, INDICES do
		tbl[i] = 0
	end
	return tbl
end

-- The three low order bits are reserved for a state ordinal,
-- while bits 3:7 of the lowermost 8 MapBlocks are reserved for
-- heightmap references.

local MBS_UNKNOWN = 0
local MBS_LOCKED = 1
local MBS_LOCKED_GENERATED = 2
local MBS_REGENERATING = 3
local MBS_PROTO_CHUNK = 4
local MBS_GENERATED = 5

local function reset_loaded_section (section)
	for i, word in ipairs (section) do
		local mask = bnot (0x07070707)
		local temp = band (word, mask)
		local w1 = band (word, 7)
		local w2 = band (rshift (word, 8), 7)
		local w3 = band (rshift (word, 16), 7)
		local w4 = band (rshift (word, 24), 7)

		if w1 >= MBS_LOCKED and w1 <= MBS_REGENERATING then
			w1 = ((w1 == MBS_LOCKED or w1 == MBS_REGENERATING)
			      and MBS_PROTO_CHUNK or MBS_GENERATED)
		end
		if w2 >= MBS_LOCKED and w2 <= MBS_REGENERATING then
			w2 = ((w2 == MBS_LOCKED or w2 == MBS_REGENERATING)
			      and MBS_PROTO_CHUNK or MBS_GENERATED)
		end
		if w3 >= MBS_LOCKED and w3 <= MBS_REGENERATING then
			w3 = ((w3 == MBS_LOCKED or w3 == MBS_REGENERATING)
			      and MBS_PROTO_CHUNK or MBS_GENERATED)
		end
		if w4 >= MBS_LOCKED and w4 <= MBS_REGENERATING then
			w4 = ((w4 == MBS_LOCKED or w4 == MBS_REGENERATING)
			      and MBS_PROTO_CHUNK or MBS_GENERATED)
		end

		section[i] = bor (temp, w1, lshift (w2, 8),
				  lshift (w3, 16), lshift (w4, 24))
	end
end

local open_section_journal

local function load_section (sx, sz)
	local hash = section_hash (current_namespace_id, sx, sz)
	local section = loaded_mb_sections[hash]
	if not loaded_mb_sections[hash] then
		local str = storage:get_string ("mbs," .. hash)
		if not str or str == "" then
			dbgjournal ("Creating section %d", hash)
			section = create_section (hash)
			loaded_mb_sections[hash] = section
			sections_loaded[hash] = true
		else
			local data = core.decompress (str, "zstd")
			section = loadstring (data) ()
			loaded_mb_sections[hash] = section
			dbgjournal ("Loading section %d", hash)

			-- If this is the first occasion on which the
			-- section has been loaded in this session,
			-- revert instances of MBS_LOCKED and
			-- MBS_REGENERATING into MBS_PROTO_CHUNK.
			if not sections_loaded[hash] then
				dbgjournal ("  -> Resetting section %d", hash)
				reset_loaded_section (section)
				sections_loaded[hash] = true
			end
		end
		section_access_times[hash] = 0
		open_section_journal (hash)
	end
	return section
end

local function mapblock_index (bx, by, bz)
	local sx, sz = section (bx, bz)
	local section = load_section (sx, sz)
	local ix = band (bx - 128, 0xff)
	local iy = band (by, 0x1f)
	local iz = band (bz - 128, 0xff)
	local index = bor (lshift (bor (lshift (ix, 8), iz), 5), iy)
	local section_index = rshift (index, 2) + 1
	local bit_index = lshift (band (index, 0x3), 3)
	return section, section_index, bit_index
end

local function mapblock_index_1 (bx, by, bz)
	local ix = band (bx - 128, 0xff)
	local iy = band (by, 0x1f)
	local iz = band (bz - 128, 0xff)
	local index = bor (lshift (bor (lshift (ix, 8), iz), 5), iy)
	local section_index = rshift (index, 2) + 1
	local bit_index = lshift (band (index, 0x3), 3)
	return section_index, bit_index
end

local function mapblock_flagbyte (bx, by, bz)
	local section, section_index, bit_index	= mapblock_index (bx, by, bz)
	return band (rshift (section[section_index], bit_index), 0xff)
end

local function mapblock_state (bx, by, bz)
	return band (mapblock_flagbyte (bx, by, bz), 0x7)
end

local function set_mapblock_state (bx, by, bz, state)
	local section, section_index, bit_index	= mapblock_index (bx, by, bz)
	-- dbg ("  MapBlock state change: X: %d, Y: %d, Z: %d -> %d",
	--      bx, by, bz, state)
	section[section_index] = bor (band (bnot (lshift (0x7, bit_index)),
					    section[section_index]),
				      lshift (state, bit_index))
end

-- local function mapblock_flag (bx, by, bz, i)
-- 	return band (rshift (mapblock_flagbyte (bx, by, bz), i + 3), 1)
-- end

-- local function set_mapblock_flag (bx, by, bz, i)
-- 	local section, section_index, bit_index	= mapblock_index (bx, by, bz)
-- 	section[section_index] = bor (lshift (1, bit_index + i + 3),
-- 				      section[section_index])
-- end

-- local function clear_mapblock_flag (bx, by, bz, i)
-- 	local section, section_index, bit_index	= mapblock_index (bx, by, bz)
-- 	section[section_index] = band (bnot (lshift (1, bit_index + i + 3)),
-- 				       section[section_index])
-- end

local close_section_journal

local function save_section (hash, sdata)
	dbgjournal ("Saving section %d", hash)
	loaded_mb_sections[hash] = nil
	section_access_times[hash] = nil
	local str = "return {" .. table.concat (sdata, ",") .. "}"
	local data = core.compress (str, "zstd")
	storage:set_string ("mbs," .. hash, data)
	close_section_journal (hash)
end

-- local SECTION_EVICTION_DELAY = 30
-- local MAX_JOURNAL_SIZE = 4193404

local journal_size
local save_feature_placement_queue
local journal_checkpoint

local function manage_sections (dtime)
	local feature_placement_queue_saved = false
	for hash, t in pairs (section_access_times) do
		section_access_times[hash] = t + dtime

		if t > 30 or journal_size (hash) > 4193404 then
			-- Since a journal is about to be closed, save
			-- the feature placement queue (which may hold
			-- entries that would otherwise be restored
			-- from the journal) to disk.
			if not feature_placement_queue_saved then
				feature_placement_queue_saved = true
				save_feature_placement_queue (true)
			end
			save_section (hash, loaded_mb_sections[hash])
		end
	end
end

local function save_sections ()
	for hash, section in pairs (loaded_mb_sections) do
		save_section (hash, section)
	end
end
mcl_levelgen.save_sections = save_sections

if not mcl_levelgen.load_feature_environment
	and not dummy_map_backend_enabled_p then
	core.register_globalstep (manage_sections)
	core.register_on_shutdown (save_sections)
end

--------------------------------------------------------------------------
-- MapBlock tag journaling.
--------------------------------------------------------------------------

local huge = math.huge

local function hashmapblock (x, y, z)
	return (y + 2048) * 16777216
		+ (x + 2048) * 4096
		+ (z + 2048)
end

mcl_levelgen.hashmapblock = hashmapblock

local set_mapblock_heightmap

do
	local worldpath = core.get_worldpath ()
	local journal_dir = worldpath .. "/journals/"
	local journals = {}
	local journal_generations = {}
	local feature_placement_queue_journal = journal_dir .. "featurequeue"
	local suppress_journaling = false
	local last_checkpoint = nil
	local last_checkpoint_counter = 0
	local current_checkpoint = nil

	core.mkdir (journal_dir)

	function open_section_journal (sid)
		if suppress_journaling or dummy_map_backend_enabled_p then
			return false
		end
		local f = assert (io.open (journal_dir .. sid, "a"))
		f:setvbuf ("no") -- It's "no" rather than _IONBF apparently.
		journals[sid] = { f, nil, }
	end

	local function maybe_checkpoint (data)
		local f = data[1]
		if data[2] ~= current_checkpoint then
			assert (current_checkpoint)
			f:write ("chk=" .. current_checkpoint .. "\n")
			data[2] = current_checkpoint
		end
	end

	local function deferred_deletion_cb (sid, generation)
		dbgjournal ("Removing journal %d_%d", sid, generation)
		assert (os.remove (string.format ("%s%d_%d", journal_dir,
						  sid, generation)))
	end

	function close_section_journal (sid)
		if suppress_journaling or dummy_map_backend_enabled_p then
			return false
		end

		local data = assert (journals[sid], "Journal for section " .. sid .. " is not open")
		local f = data[1]
		f:close ()
		journals[sid] = nil

		-- Assign a version number to the contents of this
		-- journal and delete it once it is no longer
		-- required.
		local generation = journal_generations[sid] or 0
		assert (os.rename (journal_dir .. sid,
				   string.format ("%s%d_%d", journal_dir,
						  sid, generation)))
		dbgjournal ("  %d -> %d_%d", sid, sid, generation)
		journal_generations[sid] = (generation + 1) % 0x100000000
		core.after (server_map_save_interval + 1,
			    deferred_deletion_cb, sid, generation)
	end

	function mcl_levelgen.journal_append (bx, by, bz, value)
		if suppress_journaling or dummy_map_backend_enabled_p then
			return false
		end

		local sx, sz = section (bx, bz)
		local sid = section_hash (current_namespace_id, sx, sz)
		local ix = band (bx - 128, 0xff)
		local iy = band (by, 0x1f)
		local iz = band (bz - 128, 0xff)
		local index = bor (lshift (bor (lshift (ix, 8), iz), 5), iy)
		local data = assert (journals[sid])
		maybe_checkpoint (data)
		local f = data[1]
		f:write (index .. "," .. value .. "\n")
		section_access_times[sid] = 0
	end

	local function checkpoint_string ()
		local time = os.time ()
		if time == last_checkpoint then
			last_checkpoint_counter = last_checkpoint_counter + 1
			return time .. "," .. last_checkpoint_counter
		else
			last_checkpoint_counter = 1
			last_checkpoint = time
			return time .. "," .. last_checkpoint_counter
		end
	end

	function mcl_levelgen.journal_checkpoint ()
		current_checkpoint = checkpoint_string ()
		return current_checkpoint
	end

	function journal_size (sid)
		if suppress_journaling or dummy_map_backend_enabled_p then
			return 0
		end

		local f = assert (journals[sid])[1]
		return f:seek ("cur")
	end

	local function unsection (sx, sz)
		return lshift (sx, SSHIFT) + 128, lshift (sz, SSHIFT) + 128
	end

	local function section_unhash (id)
		local chunk = band (id, 0x3ff)
		return rshift (chunk, 5) - 9, band (chunk, 0x1f) - 9
	end
	mcl_levelgen.section_unhash = section_unhash

	local function restore_journal (sid, generation, current_states)
		local data_namespace = rshift (sid, 10)
		switch_to_namespace (data_namespace)
		local file = generation
			and string.format ("%s%d_%d", journal_dir,
					   sid, generation)
			or journal_dir .. sid
		local sx, sz = section_unhash (sid)
		local bx, bz = unsection (sx, sz)
		local checkpoint = storage:get_string ("mbs_journal_checkpoint")
		local chk_a, chk_b = unpack (checkpoint:split (","))
		chk_a = tonumber (chk_a) or 0
		chk_b = tonumber (chk_b) or 0
		-- Restoring the journal will restore MapBlock states
		-- but not the separately managed feature placement
		-- queue, whose contents must be reconstructed from
		-- the previously-persisted feature placement queue
		-- and by reprocessing MapBlocks that were journaled
		-- as proto-chunks.  Pains must be taken to guarantee
		-- that the feature placement queue which is restored
		-- contains all MapBlocks which are not currently
		-- journaled; this is realized by saving the feature
		-- placement queue to disk (rather than to mod
		-- storage) whenever a section is unloaded.
		local recovered_states = {}
		local lines_valid = {}
		for line in io.lines (file) do
			if line:sub (1, 4) == "chk=" then
				local checkpoint_b = line:sub (5)
				local chk1_a, chk1_b = unpack (checkpoint_b:split (","))
				chk1_a = tonumber (chk1_a)
				chk1_b = tonumber (chk1_b)

				if chk1_a > chk_a or (chk1_a == chk_a and chk1_b > chk_b) then
					break
				end
			elseif #line > 0 then
				insert (lines_valid, line)
				local id, str = unpack (line:split (","))
				local number = tonumber (id)
				assert (number, line)
				local by = band (id, 0x1f)
				local bz = bz + band (rshift (id, 5), 0xff)
				local bx = bx + band (rshift (id, 13), 0xff)
				local mbhash = hashmapblock (bx, by, bz)
				do
					local sx_1, sz_1 = section (bx, bz)
					assert (sx_1 == sx and sz_1 == sz)
				end

				if str:sub (1, 10) == "heightmap=" then
					local heightmap = tonumber (str:sub (11))
					assert (heightmap)
					set_mapblock_heightmap (bx, bz, heightmap)
					local blurb
						= "[mcl_levelgen]: Heightmap is not accessible after level corruption: %d"
					if storage:get_string ("heightmap" .. heightmap) == "" then
						core.log ("error", string.format (blurb, heightmap))
						set_mapblock_heightmap (bx, by, bz, 0)
					end
				else
					local state = tonumber (str)
					assert (state == MBS_PROTO_CHUNK
						or state == MBS_GENERATED, str)
					if not current_states[mbhash] then
						current_states[mbhash]
							= mapblock_state (bx, by, bz, state)
					end
					set_mapblock_state (bx, by, bz, state)
					recovered_states[mbhash] = state
				end
			end
		end
		-- Remove elements from the file that are invalid.
		local valid_lines = table.concat (lines_valid, "\n") .. "\n"
		assert (core.safe_file_write (file, valid_lines))
		switch_to_namespace (nil)
		return recovered_states
	end

	local function delete_journal (sid, generation)
		if not generation then
			dbgjournal ("Deleting empty journal %d", sid)
			assert (os.remove (journal_dir .. sid))
		else
			dbgjournal ("Deleting empty journal %d_%d", sid, generation)
			assert (os.remove (string.format ("%s%d_%d", journal_dir,
							  sid, generation)))
		end
	end

	local function parse_journal_name (sid)
		local sid_1, generation = sid:match ("(%d+)_(%d+)")
		if sid_1 and generation then
			return tonumber (sid_1), tonumber (generation)
		end
		return tonumber (sid), nil
	end

	local function sort_by_sid_then_generation (a, b)
		if a[2] < b[2] then
			return true
		elseif a[2] > b[2] then
			return false
		else
			return (a[3] or huge) < (b[3] or huge)
		end
	end

	function mcl_levelgen.restore_journals (blocks_generated)
		if dummy_map_backend_enabled_p then
			return false
		end

		local journals = core.get_dir_list (journal_dir, false)
		local any_journals = false
		local to_load = {}
		for _, journal in ipairs (journals) do
			local sid, generation = parse_journal_name (journal)
			if sid then
				insert (to_load, { journal, sid, generation, })
			end
		end

		table.sort (to_load, sort_by_sid_then_generation)

		local lastsid, recovered_states, current_states = nil, {}, {}
		for i = 1, #to_load + 1 do
			local journal_table = to_load[i]

			-- At the end of the list or switching to a
			-- different set of journals?
			if lastsid and (not journal_table
					or journal_table[2] ~= lastsid) then
				local sid = lastsid
				-- Versions of the same journal must
				-- be considered as a single unit.
				local seen = {}
				local data_namespace = rshift (sid, 10)
				local list = blocks_generated[data_namespace]
				if not list then
					list = {}
					blocks_generated[data_namespace] = list
				end

				-- Only consider the recentest journal
				-- to have affected any provided
				-- mapblock.
				local any_restored = false
				for j = #recovered_states, 1, -1 do
					local tbl = recovered_states[j]
					local recoveries = tbl[2]
					local generation = tbl[1] >= 0 and tbl[1] or nil
					local any = false

					for hash, state in pairs (recoveries) do
						if not seen[hash] or seen[hash] == generation then
							seen[hash] = generation
							if current_states[hash] ~= state then
								if state == MBS_PROTO_CHUNK
									or state == MBS_GENERATED then
									insert (list, hash)
									any = true
								end
							end
						end
					end

					-- This journal yielded no values.
					if not any then
						delete_journal (sid, generation)
					else
						any_restored = true
						if not generation then
							generation = journal_generations[sid] or 0
							journal_generations[sid] = generation + 1
							assert (os.rename (journal_dir .. sid,
									   string.format ("%s%d_%d", journal_dir,
											  sid, generation)))
							dbgjournal ("  %d -> %d_%d", sid, sid, generation)
						end

						-- Delete this version
						-- after the next
						-- `server_map_save_interval'.
						dbgjournal ("Deferring deletion of journal %d_%d",
							    sid, generation)
						core.after (server_map_save_interval + 1,
							    deferred_deletion_cb,
							    sid,
							    generation)
					end
				end

				recovered_states = {}
				current_states = {}

				if any_restored then
					local blurb = "[mcl_levelgen]: Restored section %d's metadata from %d journal(s)"
					core.log ("action", string.format (blurb, sid, #to_load))
					any_journals = true
				end
			end

			if journal_table then
				local sid = journal_table[2]
				local generation = journal_table[3]
				lastsid = sid
				if generation then
					dbgjournal ("Loading journal %d_%d", sid, generation)
				else
					dbgjournal ("Loading journal %d", sid)
				end

				-- Update the monotonically
				-- incrementing generation ID counter.
				if generation then
					local gen_max = journal_generations[sid] or 0
					journal_generations[sid] = mathmax (gen_max,
									    generation + 1)
				end

				local local_recovered_states
					= restore_journal (sid, generation, current_states)
				insert (recovered_states, {
					generation or -1,
					local_recovered_states,
				})
			end
		end

		return any_journals
	end

	function mcl_levelgen.write_feature_placement_queue (qdata)
		return core.safe_file_write (feature_placement_queue_journal, qdata)
	end

	function mcl_levelgen.delete_feature_placement_queue ()
		os.remove (feature_placement_queue_journal)
	end

	function mcl_levelgen.decode_feature_placement_queue ()
		local f, _ = io.open (feature_placement_queue_journal)
		if f then
			local data = f:read ("*all")
			local str = core.decompress (data, "zstd")
			f:close ()
			return str
		end
		return nil
	end

	function mcl_levelgen.suppress_journaling (suppress)
		if not suppress then
			mcl_levelgen.save_sections ()
		end
		suppress_journaling = suppress
	end
end

local journal_append = mcl_levelgen.journal_append
journal_checkpoint = mcl_levelgen.journal_checkpoint

--------------------------------------------------------------------------
-- MapBlock tag initialization.
--------------------------------------------------------------------------

local save_gen_data
local run_structure_notifications
local attempt_feature_placement
local require_regeneration

-- local parent = {}

local schedule_regeneration_for_emerge
local dims_intersecting = mcl_levelgen.dims_intersecting

local function post_process_mapchunk_in_dim (minp, maxp, dim)
	local bx = minp.x / 16
	local by = minp.y / 16
	local bz = minp.z / 16
	local bx1 = floor (maxp.x / 16)
	local by1 = floor (maxp.y / 16)
	local bz1 = floor (maxp.z / 16)

	switch_to_namespace (dim.data_namespace)

	by = by - current_namespace.y_bottom
	by1 = by1 - current_namespace.y_bottom

	assert (by >= 0 and by <= current_namespace_height - 1)
	assert (by1 >= 0 and by1 >= by and by1 <= current_namespace_height - 1)

	-- As the engine saves mod storage before the map database,
	-- there is still a chance that the database engine will
	-- succeed in writing mod storage prior to the map if Luanti
	-- is aborted between the two processes in AsyncRunStep.
	-- Happily, this should be insignificant in view of the other
	-- circumstances where inopportune termination can cause the
	-- journaling system to fail.
	storage:set_string ("mbs_journal_checkpoint", journal_checkpoint ())

	local fmt
		= "MapBlock %d,%d,%d (%d) was likely overwritten by the generation of the region between %s and %s"

	-- Verify that no locked or generated mapblocks have been
	-- overwritten by overgeneration.
	for x, y, z in ipos1 (bx, by, bz, bx1, by1, bz1) do
		local current = mapblock_state (x, y, z)
		if current == MBS_GENERATED
			or current == MBS_LOCKED
			or current == MBS_LOCKED_GENERATED then
			local blurb = string.format (fmt, x, y, z, current,
						     minp:to_string (),
						     maxp:to_string ())
			core.log ("warning", blurb)
			require_regeneration (current, x, y, z)
		end
	end

	local blurb
		= "An existing MapBlock (%d) was reported to post_process_mapchunk: X: %d, Y: %d, Z: %d (src = %s, %s)"

	for x, y, z in ipos1 (bx, by, bz, bx1, by1, bz1) do
		local current = mapblock_state (x, y, z)
		-- local hash = mcl_levelgen.hashmapblock (x, y, z)

		-- Blocks that are locked for
		-- regeneration are liable to be
		-- processed by this loop.
		if current == MBS_UNKNOWN then
			set_mapblock_state (x, y, z, MBS_PROTO_CHUNK)
			journal_append (x, y, z, MBS_PROTO_CHUNK)
			assert (mapblock_state (x, y, z) == MBS_PROTO_CHUNK)
		else
			core.log ("warning", string.format (blurb, current, x, y, z,
							    minp:to_string (),
							    maxp:to_string ()))
			if current == MBS_LOCKED_GENERATED
				or current == MBS_GENERATED then
				require_regeneration (current, x, y, z)
			end
			-- core.log ("warning", "   MapBlock was previously generated by "
			-- 	  .. dump (parent[hash]))
		end
		-- parent[hash] = { minp = minp, maxp = maxp, }
	end

	save_gen_data (bx, bx1, by, by1, bz, bz1, chunksize)
	run_structure_notifications ()
	schedule_regeneration_for_emerge (bx, bx1, by, by1, bz, bz1)
	switch_to_namespace (nil)
end

local function post_process_mapchunk (minp, maxp)
	local generated = false
	for y1, y2, ystart, yend, dim in dims_intersecting (minp.y, maxp.y) do
		if generated then
			break
		end

		minp.y = y1
		maxp.y = y2
		post_process_mapchunk_in_dim (minp, maxp, dim)
		generated = true
	end
end

if not mcl_levelgen.load_feature_environment then
	core.register_on_generated (post_process_mapchunk)
end

--------------------------------------------------------------------------
-- Min-heap implementation.  TODO: merge this with pathfinding.lua.
--------------------------------------------------------------------------

do

local function shift_up (self, node, idx)
	local priority = node.priority
	local heap = self.heap
	while idx > 1 do
		local parent = floor (idx / 2)
		local n = heap[parent]

		if n.priority < priority then
			break
		end

		-- Swap node positions.
		heap[idx] = n
		n.idx = idx
		idx = parent
	end

	-- idx is now the proper depth of this node in the tree.
	heap[idx] = node
	node.idx = idx
end

local function shift_down (self, node, idx)
	local priority = node.priority
	local heap = self.heap
	local size = self.size

	while true do
		local left = idx * 2
		local right = left + 1

		-- Break early if it is known that no nodes exist
		-- greater than this.
		if left > size then
			break
		end
		local leftnode = heap[left]
		local rightnode = heap[right]
		local lp, rp = leftnode.priority
		rp = rightnode and rightnode.priority or huge

		if lp < rp then
			if lp >= priority then
				break
			end
			heap[idx] = leftnode
			leftnode.idx = idx
			idx = left
		else
			if rp >= priority then
				break
			end
			heap[idx] = rightnode
			rightnode.idx = idx
			idx = right
		end
	end

	heap[idx] = node
	node.idx = idx
end

local function mintree_enqueue (self, item, priority)
	assert (not item.idx)
	local i = self.size + 1
	self.size = i
	self.heap[i] = item
	item.idx = i
	item.priority = priority
	shift_up (self, item, i)
end

local function mintree_dequeue (self, item)
	local heap = self.heap
	local n, size = heap[1], self.size
	-- dbg ("Dequeueing: " .. dump (n) .. " [" .. self.size .. "]")
	heap[1], heap[size] = heap[size], nil
	self.size = size - 1
	if size > 0 then
		shift_down (self, heap[1], 1)
	end
	n.idx = nil
	return n
end

local function mintree_update (self, item, priority)
	local f_old = item.priority
	item.priority = priority

	-- dbg ("Update start: " .. dump (item))

	if priority < f_old then
		shift_up (self, item, item.idx)
	elseif priority > f_old then
		shift_down (self, item, item.idx)
	end

	-- dbg ("Update complete: " .. dump (self))
end

local function mintree_empty (self)
	return self.size == 0
end

local function mintree_contains (self, item)
	return item.idx ~= nil
end

local mintree_meta = {
	enqueue = mintree_enqueue,
	dequeue = mintree_dequeue,
	update = mintree_update,
	empty = mintree_empty,
	contains = mintree_contains,
}
mintree_meta.__index = mintree_meta

local function new_mintree ()
	local tbl = {
		heap = { },
		size = 0,
	}
	setmetatable (tbl, mintree_meta)
	return tbl
end

mcl_levelgen.mintree_meta = mintree_meta
mcl_levelgen.new_mintree = new_mintree
end

--------------------------------------------------------------------------
-- Regeneration scheduling.
--------------------------------------------------------------------------

local shutdown_complete = false

local feature_placement_queue = mcl_levelgen.new_mintree ()
local mb_records = {}

function mcl_levelgen.get_feature_placement_queue ()
	return feature_placement_queue
end

local function getmapblock (x, y, z)
	local hash = hashmapblock (x, y, z)
	local value = mb_records[hash]

	if not value then
		value = {}
		mb_records[hash] = value
	end
	return value
end

local REQUIRED_CONTEXT_Y = mcl_levelgen.REQUIRED_CONTEXT_Y
local REQUIRED_CONTEXT_XZ = mcl_levelgen.REQUIRED_CONTEXT_XZ

-- XXX: `compare_block_status' is surprisingly expensive; therefore
-- the criteria applied in deciding whether to skip a mapblock is
-- instead one of distance.

local mathabs = math.abs

local function nearest_power_of_2 (x)
	local k, m = 1, 0
	while x > k do
		k = lshift (k, 1)
		m = m + 1
	end
	return k, m
end

local base_cache_size

do
	local chunk_check_size
		= mt_chunksize.x + (REQUIRED_CONTEXT_XZ + 1) * 2
	base_cache_size = mathmax (6, chunk_check_size)
end

local player_block_positions = {}
local n_player_block_positions
local position_requested_by_area_generator_p

local function dist_to_nearest_player (x, y, z)
	local d = 4096 * 4096 * 4096
	local n = n_player_block_positions
	local p = player_block_positions
	local y = y + current_namespace.y_bottom
	if position_requested_by_area_generator_p (x, z) then
		return 0
	end
	for i = 1, n, 3 do
		local x1, y1, z1 = p[i], p[i + 1], p[i + 2]
		local dx = x - x1
		local dy = y - y1
		local dz = z - z1
		d = mathmin (d, dx * dx + dy * dy + dz * dz)
	end
	return d
end

local is_initializing = false

local function refresh_player_block_positions ()
	if is_initializing then
		player_block_positions = {}
		n_player_block_positions = 0
		return
	end
	player_block_positions = {}
	for player in mcl_util.connected_players () do
		local pos = mcl_util.get_nodepos (player:get_pos ())
		local x = floor (pos.x / 16)
		local y = floor (pos.y / 16)
		local z = floor (pos.z / 16)
		insert (player_block_positions, x)
		insert (player_block_positions, y)
		insert (player_block_positions, z)
	end
	n_player_block_positions = #player_block_positions
end

local mbs_cache = { }
local mbs_cache_width, mbs_cache_shift_x
do
	local mbs_cache_shift_base
	mbs_cache_width, mbs_cache_shift_base
		= nearest_power_of_2 ((base_cache_size
				       + REQUIRED_CONTEXT_XZ + 1) * 2 + 1)
	mbs_cache_shift_x = mbs_cache_shift_base + HEIGHT_SHIFT
end

local mbs_cache_min_x
local mbs_cache_min_y
local mbs_cache_min_z

local function local_set_mapblock_state (x, y, z, state)
	set_mapblock_state (x, y, z, state)
	local ix = x - mbs_cache_min_x
	local iy = y - mbs_cache_min_y
	local iz = z - mbs_cache_min_z
	-- assert (ix >= 0 and iy >= 0 and iz >= 0
	-- 	and ix < mbs_cache_width
	-- 	and iy < HEIGHT
	-- 	and iz < mbs_cache_width)
	local hash = bor (lshift (ix, mbs_cache_shift_x),
			  lshift (iz, HEIGHT_SHIFT), iy) + 1
	mbs_cache[hash] = state
end

local function local_mapblock_state (x, y, z)
	local ix = x - mbs_cache_min_x
	local iy = y - mbs_cache_min_y
	local iz = z - mbs_cache_min_z
	-- assert (ix >= 0 and iy >= 0 and iz >= 0
	-- 	and ix < mbs_cache_width
	-- 	and iy < HEIGHT
	-- 	and iz < mbs_cache_width)
	local hash = bor (lshift (ix, mbs_cache_shift_x),
			  lshift (iz, HEIGHT_SHIFT), iy) + 1
	local k = mbs_cache[hash]
	if k then
		return k
	end
	k = mapblock_state (x, y, z)
	mbs_cache[hash] = k
	return k
end

local function clear_mbs_cache (width)
	local nelem = width * HEIGHT * width
	for i = 1, nelem do
		mbs_cache[i] = false
	end
end

local surroundings = {
}

for x = -REQUIRED_CONTEXT_XZ - 1, REQUIRED_CONTEXT_XZ + 1 do
	for z = -REQUIRED_CONTEXT_XZ - 1, REQUIRED_CONTEXT_XZ + 1 do
		if mathabs (x) > REQUIRED_CONTEXT_XZ
			or mathabs (z) > REQUIRED_CONTEXT_XZ then
			insert (surroundings, x)
			insert (surroundings, z)
		end
	end
end

local all_surroundings = {
}

for x = -REQUIRED_CONTEXT_XZ - 1, REQUIRED_CONTEXT_XZ + 1 do
	for z = -REQUIRED_CONTEXT_XZ - 1, REQUIRED_CONTEXT_XZ + 1 do
		insert (all_surroundings, x)
		insert (all_surroundings, z)
	end
end

local n_surroundings = #surroundings
local n_all_surroundings = #all_surroundings

local function in_generation_range (bx, bz)
	return bx >= minblock and bz >= minblock
		and bx <= maxblock and bz <= maxblock
end

local function context_range (x, z, y1, y2)
	local x1 = mathmax (x - REQUIRED_CONTEXT_XZ, minblock)
	local y1 = mathmax (y1 - REQUIRED_CONTEXT_Y, 0)
	local z1 = mathmax (z - REQUIRED_CONTEXT_XZ, minblock)
	local x2 = mathmin (x + REQUIRED_CONTEXT_XZ, maxblock)
	local y2 = mathmin (y2 + REQUIRED_CONTEXT_Y, current_namespace_height - 1)
	local z2 = mathmin (z + REQUIRED_CONTEXT_XZ, maxblock)
	return x1, y1, z1, x2, y2, z2
end

local function area_context_range (x1, z1, y1, x2, z2, y2)
	local x1 = mathmax (x1 - REQUIRED_CONTEXT_XZ, minblock)
	local y1 = mathmax (y1 - REQUIRED_CONTEXT_Y, 0)
	local z1 = mathmax (z1 - REQUIRED_CONTEXT_XZ, minblock)
	local x2 = mathmin (x2 + REQUIRED_CONTEXT_XZ, maxblock)
	local y2 = mathmin (y2 + REQUIRED_CONTEXT_Y, current_namespace_height - 1)
	local z2 = mathmin (z2 + REQUIRED_CONTEXT_XZ, maxblock)
	return x1, y1, z1, x2, y2, z2
end

local function context_iterator_xzy (iter_func, x, z, y1, y2)
	local x1, y1, z1, x2, y2, z2
		= context_range (x, z, y1, y2)
	return iter_func (x1, z1, y1, x2, z2, y2)
end

local function context_iterator (iter_func, x, z, y1, y2)
	return iter_func (context_range (x, z, y1, y2))
end

local function area_context_iterator (iter_func, x1, z1, y1, x2, z2, y2)
	return iter_func (area_context_range (x1, z1, y1, x2, z2, y2))
end

local function vertical_context_generated (x, y, z)
	if y >= current_namespace_height or y < 0 then
		return true
	end
	for i = 1, n_all_surroundings, 2 do
		local dx = all_surroundings[i]
		local dz = all_surroundings[i + 1]
		if in_generation_range (x + dx, z + dz)
			and local_mapblock_state (x + dx, y, z + dz) == MBS_UNKNOWN then
			return false
		end
	end
	return true
end

local function adequate_context_exists_p (x, y, z, curstate)
	for x = x - REQUIRED_CONTEXT_XZ, x + REQUIRED_CONTEXT_XZ do
		for z = z - REQUIRED_CONTEXT_XZ, z + REQUIRED_CONTEXT_XZ do
			-- Note that MapBlocks in excess of the
			-- configured generation limit mustn't be
			-- considered here.
			if in_generation_range (x, z)
				and local_mapblock_state (x, y, z) < MBS_PROTO_CHUNK then
				return false
			end
		end
	end

	if curstate == MBS_GENERATED then
		-- A MapBlock can't have been generated unless its
		-- surroundings were previously.
		return true
	end

	-- Verify that a further MapBlock's margin around the context
	-- itself has been generated, or subsequent level generation
	-- may overwrite any data that is written into the context.
	for i = 1, n_surroundings, 2 do
		local x = x + surroundings[i]
		local z = z + surroundings[i + 1]
		if in_generation_range (x, z)
			and local_mapblock_state (x, y, z) == MBS_UNKNOWN then
			return false
		end
	end

	return vertical_context_generated (x, y + 1, z)
		and vertical_context_generated (x, y - 1, z)
end

-- local mapblock_lockers = {}
-- local function whohasit (x, y, z)
-- 	return mapblock_lockers[core.hash_node_position (vector.new (x, y, z))]
-- end
-- local function record_whohasit (x, y, z, run)
-- 	mapblock_lockers[core.hash_node_position (vector.new (x, y, z))] = run
-- end

local function run_hash (run)
	local y_bottom = current_namespace.y_bottom
	return hashmapblock (run.x, run.y1 + y_bottom, run.z)
end

local function queue_mapblock_run (x, y_start, y_end, z, d, supplemental,
				   data)
	local y_bottom = current_namespace.y_bottom
	local run = getmapblock (x, y_start + y_bottom, z)

	run.x = x
	run.z = z
	run.y1 = y_start
	run.y2 = y_end
	run.supplemental = supplemental
	run.data = data
	run.data_namespace = current_namespace_id

	dbg ("Queueing mapblock run: X: %d, Y: %d - %d, Z: %d (supplemental: %s)",
	     x, y_start, y_end, z, tostring (supplemental))

	-- Lock surrounding MapBlocks.

	for x, z, y in context_iterator_xzy (ipos1, x, z, y_start, y_end) do
		local rec = mb_records[hashmapblock (x, y + y_bottom, z)]
		assert (not rec or rec == run)
		local state = local_mapblock_state (x, y, z)
		if state == MBS_PROTO_CHUNK then
			local_set_mapblock_state (x, y, z, MBS_LOCKED)
			-- record_whohasit (x, y, z, run)
		elseif state == MBS_GENERATED then
			local_set_mapblock_state (x, y, z, MBS_LOCKED_GENERATED)
			-- record_whohasit (x, y, z, run)
		else
			-- dbg ("MapBlock conflict: ", x, y, z,
			--        dump (run),
			--        dump (whohasit (x, y, z)))
			assert (false)
		end
	end

	-- Enqueue this run of MapBlocks; its state should be updated
	-- to MBS_GENERATED unless it is a supplemental run.
	for y = y_start, y_end do
		if not supplemental then
			assert (local_mapblock_state (x, y, z) == MBS_LOCKED)
			local_set_mapblock_state (x, y, z, MBS_REGENERATING)
		else
			assert (local_mapblock_state (x, y, z) == MBS_LOCKED_GENERATED
				or local_mapblock_state (x, y, z) == MBS_LOCKED)
		end
	end
	feature_placement_queue:enqueue (run, d)
	-- dbg ("  --> Feature placement queue: " .. dump (feature_placement_queue))
end

local function maybe_reprioritize (d, x, y, z)
	local y_bottom = current_namespace.y_bottom
	local hash = hashmapblock (x, y + y_bottom, z)
	local value = mb_records[hash]

	if value and value.idx then
		-- Increase the priority if appropriate.
		if d + 16 < value.priority then
			dbg ("Reprioritizing X: %d, Y: %d - %d, Z: %d from %d -> %d",
			     value.x, value.y1, value.y2, value.z, value.priority, d)
			feature_placement_queue:update (value, d)
		end
	end
end

function attempt_feature_placement (x, z)
	local sx, sz = section (x, z)
	local hash = section_hash (current_namespace_id, sx, sz)
	section_access_times[hash] = 0

	-- Search for MapBlocks with valid and loaded context from
	-- the bottom to the top of the map.
	local cnt_below, last_above = 0, -huge
	local runs = {}
	local lastrun, nextrun = huge, -huge
	local maxy = current_namespace_height - 1

	for y = 0, maxy do
		if y > last_above then
			for i = y, maxy do
				if adequate_context_exists_p (x, i, z) then
					last_above = i
				else
					break
				end
			end
		end

		local curstate = local_mapblock_state (x, y, z)
		local context_adequate
			= adequate_context_exists_p (x, y, z, curstate)
		local d = dist_to_nearest_player (x, y, z)

		if curstate == MBS_PROTO_CHUNK and context_adequate then
			local min = mathmax (-(y - 2), 0)
			local max = mathmax (-(maxy - y - 2), 0)
			local required_below = REQUIRED_CONTEXT_Y - min
			local required_above = REQUIRED_CONTEXT_Y - max
			local cnt_above = last_above - y

			if cnt_below >= required_below
				and cnt_above >= required_above
			-- Do not permit subsequent runs to be
			-- enqueued if their context would overlap
			-- this one's.
				and (y == lastrun + 1
				     or y > nextrun + REQUIRED_CONTEXT_Y) then
				insert (runs, y)
				insert (runs, d)
				lastrun = y
				nextrun = y + REQUIRED_CONTEXT_Y
			end
		end

		if context_adequate then
			cnt_below = cnt_below + 1
		else
			cnt_below = 0
		end
	end

	if #runs > 0 then
		-- Enqueue runs in reverse.
		local min_d = huge
		local prev_y = nil
		local last_y = nil

		for i = #runs, 1, -2 do
			local d = runs[i]
			local y = runs[i - 1]

			if y + 1 ~= last_y and prev_y then
				queue_mapblock_run (x, last_y, prev_y, z,
						    mathmin (d, min_d),
						    false, nil)
				prev_y = y
				min_d = d
			elseif not prev_y then
				prev_y = y
				min_d = d
			else
				min_d = mathmin (d, min_d)
			end

			last_y = y
		end
		local y_initial = runs[1]
		local d_initial = runs[2]
		queue_mapblock_run (x, y_initial, prev_y, z,
				    mathmin (min_d, d_initial),
				    false, nil)
	end
end

local REGENERATION_QUOTA_US = 8000

if mcl_levelgen.load_feature_environment then
	-- This global variable holds the last VM to be supplied to
	-- async_function.  It exists as, for reasons that ought to
	-- require no explanation, a VM cannot be closed before the
	-- function returns.
	levelgen_previous_vm = nil
end

local function async_function (vm, run, dim_id, heightmap, wg_heightmap, biomes,
			       structure_masks, structure_features)
	if levelgen_previous_vm and levelgen_previous_vm.close then
		levelgen_previous_vm:close ()
	end
	local dimension = mcl_levelgen.get_dimension (dim_id)
	local y_offset = dimension.y_offset
	local preset = dimension.preset
	local relight_list, gen_notifies, features, c_above, c_below
		= mcl_levelgen.process_features (vm, run, heightmap, wg_heightmap,
						 structure_masks, structure_features,
						 biomes, y_offset, preset.min_y,
						 preset.height, preset)
	levelgen_previous_vm = vm

	return vm, run, heightmap, relight_list, gen_notifies,
		features, c_above, c_below
end

local v1 = vector.zero ()
local v2 = vector.zero ()
local warned = {}
local registered_notification_handlers = {}
mcl_levelgen.registered_notification_handlers
	= registered_notification_handlers

local apply_heightmap_modifications
local schedule_regeneration_for_unlock
local apply_feature_context_requisitions
local run_notification_handlers
local report_mbs_generation
local run_execution_cb

do

local registered_liquids = core.global_exists ("mcl_liquids")
	and mcl_liquids.registered_liquids
local custom_liquids_enabled = mcl_levelgen.custom_liquids_enabled

local function get_registered_liquid (cid)
	for _, liquid in ipairs (registered_liquids) do
		if liquid.cid_source == cid or liquid.cid_flowing == cid then
			return liquid
		end
	end
	return nil
end

local function find_gen_notify (gen_notifies, name)
	for _, notify in ipairs (gen_notifies) do
		if notify.name == name then
			return notify
		end
	end
	return nil
end

local function do_liquid_updates (vm, run, gen_notifies)
	if not custom_liquids_enabled then
		vm:update_liquids ()
	else
		local liquid_list
			= find_gen_notify (gen_notifies,
					   "mcl_levelgen:custom_liquid_list")
		if not liquid_list then
			return
		end
		for liquidtype, poses in pairs (liquid_list.data) do
			local def = get_registered_liquid (liquidtype)
			if not def then
				assert (def, ("Liquid for type "
					      .. core.get_name_from_content_id (liquidtype)
					      .. " is not defined"))
			end
			local liquid_update_raw = def.update_raw

			for _, pos in ipairs (poses) do
				liquid_update_raw (pos)
			end
		end
	end
end

function run_execution_cb (vm, run, heightmap, relight_queue, gen_notifies,
			   features_requesting_additional_context,
			   c_above, c_below)
	if shutdown_complete then
		vm:close ()
		return
	end

	switch_to_namespace (run.data_namespace)

	-- It appears that this calback is occasionally called oftener
	-- than once.
	local run_hash = run_hash (run)
	if not mb_records[run_hash] then
		dbg ("A MapBlock execution task completed twice: X: %d, Y: %d - %d, Z: %d",
		     run.x, run.y1, run.y2, run.z)
		switch_to_namespace (nil)
		return
	end
	mb_records[run_hash] = nil
	do_liquid_updates (vm, run, gen_notifies)
	vm:write_to_map (false)
	-- 5.13.0 only API.
	if vm.close then
		vm:close ()
	end

	-- Unlock all MapBlocks that were locked for the duration of
	-- this run.
	local supplemental = run.supplemental

	dbg ("Completed MapBlock run: X: %d, Y: %d - %d, Z: %d",
	     run.x, run.y1, run.y2, run.z)

	storage:set_string ("mbs_journal_checkpoint", journal_checkpoint ())

	for x, y, z in context_iterator (ipos1, run.x, run.z, run.y1, run.y2) do
		if (x == run.x and y >= run.y1 and y <= run.y2 and z == run.z)
			and not supplemental then
			local state = mapblock_state (x, y, z)
			assert (state == MBS_REGENERATING)
			set_mapblock_state (x, y, z, MBS_GENERATED)
			journal_append (x, y, z, MBS_GENERATED)
			report_mbs_generation (x, y, z)
		else
			local state = mapblock_state (x, y, z)
			if state == MBS_LOCKED then
				set_mapblock_state (x, y, z, MBS_PROTO_CHUNK)
			elseif state == MBS_LOCKED_GENERATED then
				set_mapblock_state (x, y, z, MBS_GENERATED)
			else
				dbg ("MapBlock execution inconsistency detected: ")
				dbg ("  From X: %d, Y: %d - %d, Z: %d (supplemental: %s)",
				     run.x, run.y1, run.y2, run.z, tostring (run.supplemental))
				dbg ("  X: %d, Y: %d, Z: %d is %d rather than L or G",
				     x, y, z, state)
				assert (false)
			end
		end
	end

	if heightmap then
		apply_heightmap_modifications (run, heightmap)
	end

	-- local time = core.get_us_time ()
	local lighting_disabled = mcl_levelgen.lighting_disabled
	for _, rgn in ipairs (relight_queue) do
		v1.x, v1.y, v1.z = rgn[1], rgn[2], rgn[3]
		v2.x, v2.y, v2.z = rgn[4], rgn[5], rgn[6]
		if not lighting_disabled then
			core.fix_light (v1, v2)
		end
	end
	-- print (string.format ("%.2f", (core.get_us_time () - time) / 1000))
	run_notification_handlers (gen_notifies)
	apply_feature_context_requisitions (run, features_requesting_additional_context,
					    c_above, c_below)
	schedule_regeneration_for_unlock (run.x, run.z)
	switch_to_namespace (nil)
end

end

-- local function cancel_mapblock_run (run, y_min, y_max)
-- 	local run_hash = run_hash (run)
-- 	assert (mb_records[run_hash] == run)

-- 	for x, y, z in ipos1 (run.x - REQUIRED_CONTEXT_XZ, y_min,
-- 			      run.z - REQUIRED_CONTEXT_XZ,
-- 			      run.x + REQUIRED_CONTEXT_XZ, y_max,
-- 			      run.z + REQUIRED_CONTEXT_XZ) do
-- 		local state = mapblock_state (x, y, z)
-- 		assert (state == MBS_LOCKED
-- 			or state == MBS_LOCKED_GENERATED
-- 			or state == MBS_REGENERATING)

-- 		if state == MBS_LOCKED then
-- 			set_mapblock_state (x, y, z, MBS_PROTO_CHUNK)
-- 		elseif state == MBS_LOCKED_GENERATED then
-- 			set_mapblock_state (x, y, z, MBS_GENERATED)
-- 		elseif state == MBS_REGENERATING then
-- 			set_mapblock_state (x, y, z, MBS_PROTO_CHUNK)
-- 		end
-- 	end
-- 	mb_records[run_hash] = nil
-- end

local function resume_mapblock_run (run)
	switch_to_namespace (run.data_namespace)
	local run_hash = run_hash (run)
	for x, y, z in context_iterator (ipos1, run.x, run.z, run.y1, run.y2) do
		local state = mapblock_state (x, y, z)
		assert (state == MBS_PROTO_CHUNK or state == MBS_GENERATED)

		if state == MBS_PROTO_CHUNK then
			set_mapblock_state (x, y, z, MBS_LOCKED)
		elseif state == MBS_GENERATED then
			set_mapblock_state (x, y, z, MBS_LOCKED_GENERATED)
		end
	end

	local x = run.x
	local z = run.z
	for y = run.y1, run.y2 do
		set_mapblock_state (x, y, z, MBS_REGENERATING)
	end
	mb_records[run_hash] = run
	switch_to_namespace (nil)
end

local function mapblock_run_recoverable_p (run)
	for x, y, z in context_iterator (ipos1, run.x, run.z, run.y1, run.y2) do
		local state = mapblock_state (x, y, z)

		if state ~= MBS_PROTO_CHUNK
			and (state ~= MBS_GENERATED
			     -- XXX: supplemental runs may execute twice.
			     or (not run.supplemental
				 and x == run.x and z == run.z
				 and y >= run.y1 and y <= run.y2)) then
			return false
		end
	end
	return true
end

local construct_heightmaps_for_run
local biome_data_for_run
local structure_features_for_run

local v = vector.zero ()

local function post_mapblock_run (run)
	dbg ("Issuing MapBlock run: X: %d, Y: %d - %d, Z: %d", run.x,
	     run.y1, run.y2, run.z)

	switch_to_namespace (run.data_namespace)
	v1.x = (run.x - REQUIRED_CONTEXT_XZ) * 16
	v1.z = (run.z - REQUIRED_CONTEXT_XZ) * 16
	v1.y = (run.y1 - REQUIRED_CONTEXT_Y) * 16 + current_namespace.y_global
	v2.x = (run.x + REQUIRED_CONTEXT_XZ) * 16 + 15
	v2.z = (run.z + REQUIRED_CONTEXT_XZ) * 16 + 15
	v2.y = (run.y2 + REQUIRED_CONTEXT_Y) * 16 + 15 + current_namespace.y_global
	v1.y = mathmax (v1.y, current_namespace.y_global)
	v2.y = mathmin (v2.y, current_namespace.y_global_top)

	for x, y, z in context_iterator (ipos1, run.x, run.z, run.y1, run.y2) do
		-- Verify that the context of the run is consistent,
		-- and abandon it if it has since been unloaded.
		local state = mapblock_state (x, y, z)
		if not (state == MBS_LOCKED
			or state == MBS_LOCKED_GENERATED
			or state == MBS_REGENERATING) then
			local blurb = "  Inconsistency detected: X: %d, Y: %d, Z: %d is %d, not locked"
			dbg (blurb, x, y, z, state)
			assert (false)
		end

		-- Bump its ttl.
		local sx, sz = section (x, z)
		local hash = section_hash (current_namespace_id, sx, sz)
		section_access_times[hash] = 0
	end

	local heightmap, wg_heightmap, structure_masks
		= construct_heightmaps_for_run (run)
	local biomes = biome_data_for_run (run)
	local structure_features = structure_features_for_run (run)
	local vm = VoxelManip (v1, v2)
	local dim_id = current_namespace.dim_id

	core.handle_async (async_function, run_execution_cb, vm, run,
			   dim_id, heightmap, wg_heightmap, biomes,
			   structure_masks, structure_features)
	if vm.close then
		vm:close ()
	end

	-- mb_records will continue to hold `run' until such time as
	-- it completely processed as a further test of consistency.
	local run_hash = run_hash (run)
	assert (mb_records[run_hash] == run)
	switch_to_namespace (nil)
end

local timer = 0

local check_supplemental_generation

function require_regeneration (current, x, y, z)
	-- Regenerate this mapblock or arrange to have it regenerated
	-- when regeneration of its surroundings is complete.  This
	-- would not be necessary if the engine were not liable
	-- sporadically to generate existing mapblocks.
	if current == MBS_GENERATED then
		refresh_player_block_positions ()
		mbs_cache_min_x = x - REQUIRED_CONTEXT_XZ - 3
		mbs_cache_min_y = 0
		mbs_cache_min_z = z - REQUIRED_CONTEXT_XZ - 3
		clear_mbs_cache (mbs_cache_width)

		journal_append (x, y, z, MBS_PROTO_CHUNK)
		set_mapblock_state (x, y, z, MBS_PROTO_CHUNK)
		attempt_feature_placement (x, z)
	end
	-- A locked & generated or simply locked MapBlock's contents
	-- are already available and will soon be restored to the
	-- level.
end

function schedule_regeneration_for_emerge (bx, bx1, by, by1, bz, bz1)
	refresh_player_block_positions ()
	-- Each MapBlock is capable of influencing the generation of
	-- other blocks within two blocks of itself on either axis,
	-- the one as context and the other by reason of being
	-- generated.
	mbs_cache_min_x = bx - REQUIRED_CONTEXT_XZ - 3
	mbs_cache_min_y = 0
	mbs_cache_min_z = bz - REQUIRED_CONTEXT_XZ - 3
	clear_mbs_cache (mbs_cache_width)
	-- BY1 is intentionally disregarded as
	-- attempt_feature_placement will test the entirety of the
	-- column provided.
	for bx, _, bz in area_context_iterator (ipos2, bx - 1, bz - 1, 0,
						bx1 + 1, bz1 + 1, 0) do
		check_supplemental_generation (bx, bz)
		attempt_feature_placement (bx, bz)
	end
end

function schedule_regeneration_for_unlock (bx, bz)
	refresh_player_block_positions ()
	mbs_cache_min_x = bx - REQUIRED_CONTEXT_XZ - 3
	mbs_cache_min_y = 0
	mbs_cache_min_z = bz - REQUIRED_CONTEXT_XZ - 3
	clear_mbs_cache (mbs_cache_width)
	for bx, _, bz in area_context_iterator (ipos2, bx - 1, bz - 1, 0,
						bx + 1, bz + 1, 0) do
		check_supplemental_generation (bx, bz)
		attempt_feature_placement (bx, bz)
	end
end

local reprioritization_dist = 1
local positions_at_distance_chebyshev = mcl_levelgen.positions_at_distance_chebyshev
local dimension_at_layer = mcl_levelgen.dimension_at_layer

local function schedule_regeneration (dtime)
	timer = timer + dtime
	if timer < 0.10 then
		return
	end
	timer = 0

	-- Update priorities of MapBlocks that are nearer to a player
	-- than when they were first generated.
	reprioritization_dist = (reprioritization_dist % 5) + 1
	refresh_player_block_positions ()
	for i = 1, n_player_block_positions, 3 do
		local bx = player_block_positions[i]
		local by = player_block_positions[i + 1]
		local bz = player_block_positions[i + 2]
		local dim = dimension_at_layer (by * 16)

		if dim then
			switch_to_namespace (dim.data_namespace)
			for dx, dz in positions_at_distance_chebyshev (reprioritization_dist) do
				for by = 0, current_namespace_height - 1 do
					local bx, bz = bx + dx, bz + dz
					local d = dist_to_nearest_player (bx, by, bz)
					maybe_reprioritize (d, bx, by, bz)
				end
			end
			switch_to_namespace (nil)
		end
	end

	local start_time = core.get_us_time ()
	repeat
		if feature_placement_queue:empty () then
			return
		end

		-- Begin dispatching VoxelManips to async threads.
		local run = feature_placement_queue:dequeue ()
		post_mapblock_run (run)
	until core.get_us_time () - start_time >= REGENERATION_QUOTA_US
end

local additional_ctx_requisitions = {}

function save_feature_placement_queue (journal_p)
	if not journal_p then
		-- Cancel every run that is currently in progress by
		-- returning it to the feature placement queue.
		for hash, run in pairs (mb_records) do
			if not feature_placement_queue:contains (run) then
				-- This run must have existed
				-- previously.  Assign it its old
				-- priority.
				assert (run and run.priority)
				feature_placement_queue:enqueue (run, run.priority)
			end
		end
		mb_records = {}

		local sdata = core.serialize (feature_placement_queue)
		storage:set_string ("feature_placement_queue", sdata)

		local sdata = core.serialize (additional_ctx_requisitions)
		storage:set_string ("additional_ctx_requisitions", sdata)

		-- At this point, the state of the level generator has
		-- been saved to disk and any extant tasks which might
		-- still complete should be disregarded.  Delete any
		-- feature placement queue journal that may exist.
		mcl_levelgen.delete_feature_placement_queue ()
		shutdown_complete = true
	else
		local new_mb_records = {}
		for _, run in pairs (mb_records) do
			if not feature_placement_queue:contains (run) then
				insert (new_mb_records, run)
			end
		end
		local sdata = core.serialize ({
			mb_records = new_mb_records,
			feature_placement_queue = feature_placement_queue,
			additional_ctx_requisitions = additional_ctx_requisitions,
		})
		local data = core.compress (sdata, "zstd")
		mcl_levelgen.write_feature_placement_queue (data)
	end
end
mcl_levelgen.save_feature_placement_queue = save_feature_placement_queue

local function unhashmapblock (hash)
	local y = floor (hash / 16777216) - 2048
	local x = floor (hash / 4096 % 4096) - 2048
	local z = hash % 4096 - 2048
	return x, y, z
end
mcl_levelgen.unhashmapblock = unhashmapblock

local function restore_feature_placement_queue ()
	local blocks_generated = {}
	mcl_levelgen.suppress_journaling (true)
	is_initializing = true

	local str = mcl_levelgen.decode_feature_placement_queue ()
	local tbl = nil
	if str then
		tbl = core.deserialize (str)
		setmetatable (tbl.feature_placement_queue,
			      mcl_levelgen.mintree_meta)
		for _, run in ipairs (tbl.mb_records) do
			tbl.feature_placement_queue:enqueue (run, run.priority)
		end
		additional_ctx_requisitions = tbl.additional_ctx_requisitions
	end

	if mcl_levelgen.restore_journals (blocks_generated) then
		refresh_player_block_positions ()
		-- The feature placement queue must be restored from
		-- journaled data rather than mod storage.  Moreover,
		-- modifications that are journaled may not be
		-- reflected in the feature placement queue, and hence
		-- protochunks and generated chunks whose state is
		-- restored from the journal must also be
		-- re-evaluated.

		for namespace, list in pairs (blocks_generated) do
			local rows_checked_proto = {}
			local rows_checked_generated = {}
			switch_to_namespace (namespace)
			for _, block in ipairs (list) do
				local x, y, z = unhashmapblock (block)
				-- print (x, y, z)
				local row = (x + 2048) * 4096 + z + 2048
				local state = mapblock_state (x, y, z)
				-- A new protochunk should be subject
				-- to a feature placement attempt,
				-- while a transition to a generated
				-- state should see mapblocks in the
				-- vicinity evaluated.
				if state == MBS_PROTO_CHUNK and not rows_checked_proto[row] then
					mbs_cache_min_x = x - REQUIRED_CONTEXT_XZ - 3
					mbs_cache_min_y = 0
					mbs_cache_min_z = z - REQUIRED_CONTEXT_XZ - 3
					clear_mbs_cache (mbs_cache_width)
					rows_checked_proto[row] = true
					attempt_feature_placement (x, z)
				elseif state == MBS_GENERATED and not rows_checked_generated[row] then
					rows_checked_generated[row] = true
					schedule_regeneration_for_unlock (x, z)
				end
			end
			switch_to_namespace (nil)
		end

		-- Only items in the queue that were not locked by the
		-- preceding loop should be restored.
		if tbl then
			local queue = tbl.feature_placement_queue
			for _, item in ipairs (queue) do
				for i = 1, queue.size do
					local run = queue.heap[i]
					if mapblock_run_recoverable_p (run) then
						resume_mapblock_run (run)
						feature_placement_queue:enqueue (run, run.priority)
					end
				end
			end
		end
		core.log ("action", string.format ("[mcl_levelgen]: Restored %d feature placement tasks",
						   feature_placement_queue.size))

		-- Commit all modifications that may have been applied
		-- from the journal to mod storage, save the modified
		-- feature placement queue to a journal file, and
		-- delete the remaining journal files.
		mcl_levelgen.save_sections ()
		save_feature_placement_queue (true)
	else
		-- If there is a newer journaled feature placement
		-- queue, restore it despite the absence of a journal,
		-- as this feature placement queue should be newer.

		local queue = tbl and tbl.feature_placement_queue

		if not queue then
			local sdata = storage:get_string ("feature_placement_queue")
			if sdata ~= nil and sdata ~= "" then
				queue = core.deserialize (sdata)
			end

			local sdata = storage:get_string ("additional_ctx_requisitions")
			if sdata ~= nil and sdata ~= "" then
				additional_ctx_requisitions = core.deserialize (sdata)
			end
		end

		if queue then
			setmetatable (queue, mcl_levelgen.mintree_meta)

			if queue.size > 0 then
				local blurb = "[mcl_levelgen]: Resuming %d feature placement task(s)"
				core.log ("action", string.format (blurb, queue.size))
				feature_placement_queue = queue

				for i = 1, queue.size do
					resume_mapblock_run (queue.heap[i])
				end
			end
		end
	end

	if additional_ctx_requisitions then
		local n = 0
		for k, req in pairs (additional_ctx_requisitions) do
			switch_to_namespace (req.data_namespace)
			v1.x = (req.x - REQUIRED_CONTEXT_XZ - 1) * 16
			v1.z = (req.z - REQUIRED_CONTEXT_XZ - 1) * 16
			v1.y = band (req.min, -16)
				+ current_namespace.y_global
				- REQUIRED_CONTEXT_Y * 16
			v2.x = (req.x + REQUIRED_CONTEXT_XZ + 1) * 16 + 15
			v2.z = (req.z + REQUIRED_CONTEXT_XZ + 1) * 16 + 15
			v2.y = band (req.max + 15, -16)
				+ current_namespace.y_global
				+ REQUIRED_CONTEXT_Y * 16 + 15
			core.emerge_area (v1, v2)
			n = n + 1
			switch_to_namespace (nil)
		end
		local blurb = "[mcl_levelgen]: Replayed %d placement run requisitions"
		if n > 1 then
			core.log ("action", string.format (blurb, n))
		end
	end
	is_initializing = false
	mcl_levelgen.suppress_journaling (false)
end

if not mcl_levelgen.load_feature_environment then
	core.register_globalstep (schedule_regeneration)
	core.register_on_shutdown (function ()
		save_feature_placement_queue (false)
	end)
	core.register_on_mods_loaded (restore_feature_placement_queue)
end

local function update_section_access_times (bx, bz)
	local sx, sz = section (bx, bz)
	local hash = section_hash (current_namespace_id, sx, sz)
	section_access_times[hash] = 0
end

function mcl_levelgen.is_emerged (dim, bx, by, bz)
	local old_namespace, rc = current_namespace_id
	switch_to_namespace (dim.data_namespace)
	rc = mapblock_state (bx, by, bz) > MBS_UNKNOWN
	update_section_access_times (bx, bz)
	switch_to_namespace (old_namespace)
	return rc
end

function mcl_levelgen.is_generated (dim, bx, by, bz)
	local old_namespace, rc = current_namespace_id
	switch_to_namespace (dim.data_namespace)
	rc = mapblock_state (bx, by, bz) == MBS_GENERATED
	update_section_access_times (bx, bz)
	switch_to_namespace (old_namespace)
	return rc
end

function mcl_levelgen.is_regeneration_possible (dim, x, y, z)
	local bx = arshift (x, 4)
	local by = arshift (y, 4)
	local bz = arshift (z, 4)
	local old_namespace, rc = current_namespace_id, false
	switch_to_namespace (dim.data_namespace)
	for bx, by, bz in context_iterator (ipos2, bx, bz, by, by) do
		if mapblock_state (bx, by, bz) < MBS_GENERATED then
			rc = true
			break
		end
	end
	switch_to_namespace (old_namespace)
	return rc
end

------------------------------------------------------------------------
-- Supplemental generation.  This facility enables features with
-- immense vertical context requirements to request execution in an
-- isolated environment with additional context, subject to certain
-- handicaps documented in API.txt.
------------------------------------------------------------------------

-- local function supplemental_context_cb (run)
-- 	dbg ("Supplemental context is available for run: %s", dump (run))
-- end

function apply_feature_context_requisitions (run, features_requesting_additional_context,
					     above, below)
	if not (above > 0 or below > 0) then
		return nil
	end

	dbg ("Supplemental context requested by run: X: %d, Y: %d - %d, Z: %d: %d, %d",
	     run.x, run.y1, run.y2, run.z, above, below)

	local hash = hashmapblock (run.x, current_namespace_id, run.z)
	local existing = additional_ctx_requisitions[hash] or {
		min = run.y1 * 16,
		max = run.y2 * 16 + 15,
		x = run.x,
		z = run.z,
		data_namespace = run.data_namespace,
		features = {},
	}
	additional_ctx_requisitions[hash] = existing
	existing.min = mathmax (mathmin (existing.min, run.y1 * 16 - below), 0)
	existing.max = mathmin (mathmax (existing.max, run.y2 * 16 + 15 + above),
				current_namespace_height * 16 - 1)
	for _, feature in ipairs (features_requesting_additional_context) do
		if table.indexof (existing.features, feature) == -1 then
			table.insert (existing.features, feature)
		end
	end
	v1.x = (run.x - REQUIRED_CONTEXT_XZ - 1) * 16
	v1.z = (run.z - REQUIRED_CONTEXT_XZ - 1) * 16
	v1.y = band (existing.min, -16)
		+ current_namespace.y_global
		- REQUIRED_CONTEXT_Y * 16
	v2.x = (run.x + REQUIRED_CONTEXT_XZ + 1) * 16 + 15
	v2.z = (run.z + REQUIRED_CONTEXT_XZ + 1) * 16 + 15
	v2.y = band (existing.max + 15, -16)
		+ current_namespace.y_global
		+ REQUIRED_CONTEXT_Y * 16 + 15
	dbg ("  -> Emerging %s, %s", v1:to_string (), v2:to_string ())
	core.emerge_area (v1, v2)
end

function check_supplemental_generation (bx, bz)
	local hash = hashmapblock (bx, current_namespace_id, bz)
	local requirements = additional_ctx_requisitions[hash]
	if requirements then
		-- Are the requirements met?
		local y1 = floor (requirements.min / 16)
		local y2 = floor (requirements.max / 16)

		local first_locked = mathmax (0, y1 - REQUIRED_CONTEXT_Y)
		local last_locked = mathmin (current_namespace_height - 1,
					     y2 + REQUIRED_CONTEXT_Y)

		dbg ("Testing supplemental context requisition from %d to %d at %d,%d",
		     y1, y2, bx, bz)

		for by = first_locked, last_locked do
			if not adequate_context_exists_p (bx, by, bz) then
				return
			end
		end

		dbg ("Supplemental context has appeared from %d to %d at %d,%d",
		     y1, y2, bx, bz)
		queue_mapblock_run (bx, y1, y2, bz, 0, true, requirements)

		-- If any further requirements should arrive in the
		-- interim, defer posting them till this run completes
		-- if they overlap.
		additional_ctx_requisitions[hash] = nil
	end
end

------------------------------------------------------------------------
-- Heightmap & structure mask provisioning.
--
-- Each generated MapChunk provides a heightmap that continues to
-- exist indefinitely; they are recorded when a horizontal MapChunk is
-- first generated, and are identified by 31-bit IDs recorded in the
-- tagging data of the bottommost 8 MapBlocks of each horizontal
-- column.  Heightmaps are liable partially to be modified by
-- decoration placement.
--
-- Each heightmap structure additionally holds a table of structures
-- mapping regions of its MapBlock to a packed array of values
-- associating nodes with the structure generation step(s).
------------------------------------------------------------------------

local loaded_heightmaps = {}
local heightmap_ttl = {}
local HEIGHTMAP_TTL = 60

local function load_heightmap (id)
	local tem = loaded_heightmaps[id]
	if tem then
		heightmap_ttl[id] = HEIGHTMAP_TTL
		return tem
	end

	local data = storage:get_string ("heightmap" .. id)
	if data == "" then
		error (string.format ("Could not satisfy request for heightmap %d; Level is corrupt", id))
	end
	local str = core.decompress (data, "zstd")
	local fn, err = loadstring (str)
	if not fn then
		error (string.format ("Heightmap %d is corrupt: %s", id, err))
	end
	tem = fn ()
	heightmap_ttl[id] = HEIGHTMAP_TTL
	loaded_heightmaps[id] = tem
	return tem
end

local function mapblock_heightmap (x, z, worldgen)
	local w1 = mapblock_flagbyte (x, 0, z)
	local w2 = mapblock_flagbyte (x, 1, z)
	local w3 = mapblock_flagbyte (x, 2, z)
	local w4 = mapblock_flagbyte (x, 3, z)
	local w5 = mapblock_flagbyte (x, 4, z)
	local w6 = mapblock_flagbyte (x, 5, z)
	local w7 = mapblock_flagbyte (x, 6, z)
	local w8 = mapblock_flagbyte (x, 7, z)
	-- print ("<- ", band (rshift (w1, 3), 0xf),
	--        band (rshift (w2, 3), 0xf),
	--        band (rshift (w3, 3), 0xf),
	--        band (rshift (w4, 3), 0xf),
	--        band (rshift (w5, 3), 0xf),
	--        band (rshift (w6, 3), 0xf),
	--        band (rshift (w7, 3), 0xf),
	--        band (rshift (w8, 3), 0xf))
	local value = bor (band (rshift (w1, 3), 0xf),
			   lshift (band (rshift (w2, 3), 0xf), 4),
			   lshift (band (rshift (w3, 3), 0xf), 8),
			   lshift (band (rshift (w4, 3), 0xf), 12),
			   lshift (band (rshift (w5, 3), 0xf), 16),
			   lshift (band (rshift (w6, 3), 0xf), 20),
			   lshift (band (rshift (w7, 3), 0xf), 24),
			   lshift (band (rshift (w8, 3), 0xf), 28))
	if worldgen then
		return value ~= 0 and value + 1 or 0
	else
		return value
	end
end

function set_mapblock_heightmap (x, z, id)
	local w1 = lshift (band (id, 0xf), 3)
	local w2 = lshift (band (rshift (id, 4), 0xf), 3)
	local w3 = lshift (band (rshift (id, 8), 0xf), 3)
	local w4 = lshift (band (rshift (id, 12), 0xf), 3)
	local w5 = lshift (band (rshift (id, 16), 0xf), 3)
	local w6 = lshift (band (rshift (id, 20), 0xf), 3)
	local w7 = lshift (band (rshift (id, 24), 0xf), 3)
	local w8 = lshift (band (rshift (id, 28), 0xf), 3)
	local sx, sz = section (x, z)
	local section = load_section (sx, sz)
	local i, bit, mask
	-- print ("-> ", rshift (w1, 3),
	--        rshift (w2, 3),
	--        rshift (w3, 3),
	--        rshift (w4, 3),
	--        rshift (w5, 3),
	--        rshift (w6, 3),
	--        rshift (w7, 3),
	--        rshift (w8, 3))

	i, bit = mapblock_index_1 (x, 0, z)
	mask = bnot (lshift (0x78, bit)) -- 0x78 = (0xf << 3)
	section[i] = bor (band (section[i], mask), lshift (w1, bit))
	i, bit = mapblock_index_1 (x, 1, z)
	mask = bnot (lshift (0x78, bit)) -- 0x78 = (0xf << 3)
	section[i] = bor (band (section[i], mask), lshift (w2, bit))
	i, bit = mapblock_index_1 (x, 2, z)
	mask = bnot (lshift (0x78, bit)) -- 0x78 = (0xf << 3)
	section[i] = bor (band (section[i], mask), lshift (w3, bit))
	i, bit = mapblock_index_1 (x, 3, z)
	mask = bnot (lshift (0x78, bit)) -- 0x78 = (0xf << 3)
	section[i] = bor (band (section[i], mask), lshift (w4, bit))
	i, bit = mapblock_index_1 (x, 4, z)
	mask = bnot (lshift (0x78, bit)) -- 0x78 = (0xf << 3)
	section[i] = bor (band (section[i], mask), lshift (w5, bit))
	i, bit = mapblock_index_1 (x, 5, z)
	mask = bnot (lshift (0x78, bit)) -- 0x78 = (0xf << 3)
	section[i] = bor (band (section[i], mask), lshift (w6, bit))
	i, bit = mapblock_index_1 (x, 6, z)
	mask = bnot (lshift (0x78, bit)) -- 0x78 = (0xf << 3)
	section[i] = bor (band (section[i], mask), lshift (w7, bit))
	i, bit = mapblock_index_1 (x, 7, z)
	mask = bnot (lshift (0x78, bit)) -- 0x78 = (0xf << 3)
	section[i] = bor (band (section[i], mask), lshift (w8, bit))
	assert (mapblock_heightmap (x, z) == id)
end

local function allocate_heightmap_id ()
	-- It is not realistic for a level to overflow this counter.
	local heightmap_id
	-- Not 0x80000000 as heightmap IDs are offset by 1.
		= storage:get_int ("next_heightmap_id", 0) % 0x7fffffff
	storage:set_int ("next_heightmap_id", heightmap_id + 2)
	return heightmap_id + 1
end

local function write_heightmap (id, x, y, z, chunksize, data, structure_masks)
	local list = {
		"return {",
		string.format ("x=%d, y=%d, z=%d, chunksize=%d, data={",
			       x, y, z, chunksize),
		table.concat (data, ","),
		"},",
	}
	if structure_masks then
		table.insert (list, "structure_masks={")
		for _, mask in ipairs (structure_masks) do
			table.insert (list, "{")
			table.insert (list, table.concat (mask, ","))
			table.insert (list, "},")
		end
		table.insert (list, "}")
	end
	table.insert (list, "}")
	local heightmap_data = table.concat (list)
	local compressed = core.compress (heightmap_data, "zstd")
	storage:set_string ("heightmap" .. id, compressed)
end

-- local function copy_table (heightmap)
-- 	local value = {}
-- 	for i = 1, #heightmap do
-- 		value[i] = heightmap[i]
-- 	end
-- 	return value
-- end

local indexof = table.indexof
local save_structure_pieces = mcl_levelgen.save_structure_pieces

function save_gen_data (bx, bx1, by, by1, bz, bz1, chunksize)
	local custom = core.get_mapgen_object ("gennotify").custom
	assert (custom)
	local heightmaps = custom["mcl_levelgen:level_height_map"]
	assert (heightmaps)
	local data = heightmaps.level
	local data_wg = heightmaps.wg
	assert (data and data_wg)

	-- Verify the dimensions of this heightmap.
	local idx_max = chunksize * chunksize
	assert (#data == idx_max)
	local id = allocate_heightmap_id ()
	local used = false

	local structuremask = custom["mcl_levelgen:structure_mask"]
	local assigned = {}

	-- if structuremask then
	-- 	for i = 7, #structuremask do
	-- 		if structuremask[i] ~= 0 then
	-- 			print ("Nonempty structuremask",
	-- 			       structuremask[1],
	-- 			       structuremask[2],
	-- 			       structuremask[3])
	-- 			break
	-- 		end
	-- 	end
	-- end

	for x = bx, bx1 do
		for z = bz, bz1 do
			local heightmap = mapblock_heightmap (x, z, false)
			-- Retain the heightmap assignments of
			-- existing MapBlocks.
			if heightmap == 0 then
				-- But write a heightmap as soon as it
				-- is referenced by a MapBlock.
				if not used then
					used = true

					-- Heightmap is written twice;
					-- the second map is assigned
					-- an ID 1 MapBlock greater
					-- than the first, which is
					-- never altered and as such
					-- always represents the
					-- terrain of the world at the
					-- time of generation.
					local structure_masks = { structuremask, }
					write_heightmap (id, bx, by, bz, chunksize, data,
							 structure_masks)
					loaded_heightmaps[id] = {
						x = bx,
						y = by,
						z = bz,
						chunksize = chunksize,
						data = data,
						structure_masks = structure_masks,
					}
					heightmap_ttl[id] = HEIGHTMAP_TTL
					storage:set_string ("mbs_journal_checkpoint",
							    journal_checkpoint ())
					write_heightmap (id + 1, bx, by, bz, chunksize, data_wg, nil)
					loaded_heightmaps[id + 1] = {
						x = bx,
						y = by,
						z = bz,
						chunksize = chunksize,
						data = data_wg,
					}
					heightmap_ttl[id + 1] = HEIGHTMAP_TTL
				end
				journal_append (x, 0, z, "heightmap=" .. id)
				set_mapblock_heightmap (x, z, id)
			elseif structuremask
				and indexof (assigned, heightmap) == -1 then
				table.insert (assigned, heightmap)

				-- Assign this structure mask to this
				-- MapBlock's generation data list.
				local heightmap = load_heightmap (heightmap)
				table.insert (heightmap.structure_masks,
					      structuremask)
			end
		end
	end

	local pieces = custom["mcl_levelgen:structure_pieces"]
	if pieces then
		save_structure_pieces (pieces)
	end
end

local function manage_heightmaps (dtime)
	for id, ttl in pairs (heightmap_ttl) do
		if ttl - dtime < 0 then
			heightmap_ttl[id] = nil
			local heightmap = loaded_heightmaps[id]
			assert (heightmap)
			-- print ("Writing heightmap " .. id)
			write_heightmap (id, heightmap.x,
					 heightmap.y, heightmap.z,
					 heightmap.chunksize,
					 heightmap.data,
					 heightmap.structure_masks)
			loaded_heightmaps[id] = nil
		else
			heightmap_ttl[id] = ttl - dtime
		end
	end
end

local function save_heightmaps ()
	for id, heightmap in pairs (loaded_heightmaps) do
		heightmap_ttl[id] = nil
		local heightmap = loaded_heightmaps[id]
		assert (heightmap)
		-- print ("Writing heightmap " .. id)
		write_heightmap (id, heightmap.x,
				 heightmap.y, heightmap.z,
				 heightmap.chunksize,
				 heightmap.data,
				 heightmap.structure_masks)
		loaded_heightmaps[id] = nil
	end
end

if not mcl_levelgen.load_feature_environment then
	core.register_globalstep (manage_heightmaps)
	core.register_on_shutdown (save_heightmaps)
end

local HEIGHTMAP_SIZE = REQUIRED_CONTEXT_XZ * 2 + 1
local HEIGHTMAP_SIZE_NODES = HEIGHTMAP_SIZE * 16
mcl_levelgen.HEIGHTMAP_SIZE = HEIGHTMAP_SIZE
mcl_levelgen.HEIGHTMAP_SIZE_NODES = HEIGHTMAP_SIZE_NODES

local function unpack_augmented_height_map (vals)
	-- Bit 31 indicates that the true value of `surface' is only
	-- known to be an indeterminate value between the value
	-- returned and the bottom of the level.  Bit 32 means the
	-- same of `motion_blocking'.

	local bias = 512
	local bits = 10
	local mask = 0x3ff
	local surface = band (rshift (vals, bits), mask) - bias
	local motion_blocking = band (vals, mask) - bias
	return surface, motion_blocking, rshift (vals, 28)
end

local function pack_augmented_height_map (surface, motion_blocking, flags)
	-- Bit 29 indicates that the true value of `surface' is only
	-- known to be an indeterminate value between the value
	-- returned and the bottom of the level.  Bit 30 means the
	-- same of `motion_blocking'.  Bit 31 means that `surface' has
	-- changed; bit 32 means that of `motion_blocking'.

	local bias = 512
	local bits = 10
	local mask = 0x3ff
	local surface = lshift (band (surface + bias, mask), bits)
	local motion_blocking = band (motion_blocking + bias, mask)
	return bor (surface, motion_blocking, lshift (flags, 28))
end

local SURFACE_UNCERTAIN = 0x1
local MOTION_BLOCKING_UNCERTAIN = 0x2
local SURFACE_MODIFIED = 0x4
local MOTION_BLOCKING_MODIFIED = 0x8
local MODIFIED_MASK = bnot (bor (SURFACE_UNCERTAIN, MOTION_BLOCKING_MODIFIED))

mcl_levelgen.unpack_augmented_height_map = unpack_augmented_height_map
mcl_levelgen.SURFACE_UNCERTAIN = SURFACE_UNCERTAIN
mcl_levelgen.SURFACE_MODIFIED = SURFACE_MODIFIED
mcl_levelgen.MOTION_BLOCKING_UNCERTAIN = MOTION_BLOCKING_UNCERTAIN
mcl_levelgen.MOTION_BLOCKING_MODIFIED = MOTION_BLOCKING_MODIFIED

local AABB_intersect_p = mcl_levelgen.AABB_intersect_p
local scratch = {}

local function copy_heightmap_segment (run, dst, wg, dx, dz, structure_masks)
	-- Transform output coordinates.
	local x = 16 + dx * 16
	local z = (HEIGHTMAP_SIZE - (2 + dz)) * 16

	if in_generation_range (run.x + dx, run.z + dz) then
		-- Transform heightmap coordinates.
		local id = mapblock_heightmap (run.x + dx, run.z + dz, wg)
		local heightmap = load_heightmap (id)
		assert (run.x + dx >= heightmap.x)
		assert (run.z + dz >= heightmap.z)
		local cs = heightmap.chunksize
		local run_x = (run.x + dx) * 16
		local origin_x = run_x - (heightmap.x * 16)
		local run_z = (run.z + dz) * 16
		local origin_z = cs - (run_z - (heightmap.z * 16)) - 16

		-- Write transformed data into the destination heightmap.
		assert (origin_x >= 0 and origin_z >= 0
			and origin_x < cs and origin_z < cs)
		local idx_dst = x * HEIGHTMAP_SIZE_NODES + z + 1
		local idx_src = origin_x * cs + origin_z + 1
		local src = heightmap.data

		for x1 = 1, 16 do
			for i = 0, 15 do
				assert (src[idx_src + i])
				dst[idx_dst + i] = src[idx_src + i]
			end

			idx_dst = idx_dst + HEIGHTMAP_SIZE_NODES
			idx_src = idx_src + cs
		end

		-- Load any structure masks that intersect the run.
		if structure_masks then
			local y_min = current_namespace.y_min
			scratch[1] = run_x
			scratch[2] = ((run.y1 - REQUIRED_CONTEXT_Y) * 16) + y_min
			scratch[3] = -run_z - 16
			scratch[4] = run_x + 15
			scratch[5] = ((run.y2 + REQUIRED_CONTEXT_Y) * 16 + 15) + y_min
			scratch[6] = -run_z - 1

			for _, mask in ipairs (heightmap.structure_masks) do
				if AABB_intersect_p (mask, scratch)
					and indexof (structure_masks, mask) == -1 then
					insert (structure_masks, mask)
				end
			end
		end
	else
		-- Construct an empty heightmap if this MapBlock is
		-- outside the Luanti map.
		local idx_dst = x * HEIGHTMAP_SIZE_NODES + z + 1
		for x1 = 1, 16 do
			for i = 0, 15 do
				dst[idx_dst + i] = 0
			end

			idx_dst = idx_dst + HEIGHTMAP_SIZE_NODES
		end
	end
end

-- Create heightmaps REQUIRED_CONTEXT_XZ * 2 + 1 Minecraft chunks in
-- width and length for the run RUN, represented in the Minecraft
-- coordinate system.  Value is the heightmap representing the current
-- and potentially modified state of the level followed by that which
-- represents the state of the level at the time of generation.
--
-- Additionally return any structure masks intersecting the run.

function construct_heightmaps_for_run (run)
	local heightmap, wg_heightmap, structure_masks = {}, {}, {}
	local expected_size = HEIGHTMAP_SIZE_NODES * HEIGHTMAP_SIZE_NODES
	heightmap[expected_size] = nil

	copy_heightmap_segment (run, heightmap, false, -1, -1, structure_masks)
	copy_heightmap_segment (run, heightmap, false, -1, 0, structure_masks)
	copy_heightmap_segment (run, heightmap, false, -1, 1, structure_masks)
	copy_heightmap_segment (run, heightmap, false, 0, -1, structure_masks)
	copy_heightmap_segment (run, heightmap, false, 0, 0, structure_masks)
	copy_heightmap_segment (run, heightmap, false, 0, 1, structure_masks)
	copy_heightmap_segment (run, heightmap, false, 1, -1, structure_masks)
	copy_heightmap_segment (run, heightmap, false, 1, 0, structure_masks)
	copy_heightmap_segment (run, heightmap, false, 1, 1, structure_masks)
	assert (#heightmap == expected_size)

	copy_heightmap_segment (run, wg_heightmap, true, -1, -1, nil)
	copy_heightmap_segment (run, wg_heightmap, true, -1, 0, nil)
	copy_heightmap_segment (run, wg_heightmap, true, -1, 1, nil)
	copy_heightmap_segment (run, wg_heightmap, true, 0, -1, nil)
	copy_heightmap_segment (run, wg_heightmap, true, 0, 0, nil)
	copy_heightmap_segment (run, wg_heightmap, true, 0, 1, nil)
	copy_heightmap_segment (run, wg_heightmap, true, 1, -1, nil)
	copy_heightmap_segment (run, wg_heightmap, true, 1, 0, nil)
	copy_heightmap_segment (run, wg_heightmap, true, 1, 1, nil)
	assert (#wg_heightmap == expected_size)
	return heightmap, wg_heightmap, structure_masks
end

-- Reconciliation of divergent heightmaps.
--
-- Vertically separated runs should be prevented from writing outdated
-- values to the heightmap.  As runs cannot modify content beyond the
-- the accessible region of the level, reconciling modifications where
-- the heightmap value increases is trivial--simply a matter of taking
-- the greater of the two values.  If a value is reduced, the
-- reduction must only be applied if the previous value sits within
-- the region locked by the run whose modifications are being applied,
-- for otherwise the heightmap has been altered by another run with a
-- higher accessible region or the code that corrects heightmaps is
-- defective and has overstepped the run's confines (and in neither
-- case is it desirable to apply the changes).

local function restore_heightmap_segment (run, src, dx, dz)
	-- Transform output coordinates.
	local x = 16 + dx * 16
	local z = (HEIGHTMAP_SIZE - (2 + dz)) * 16

	-- Reject out of bounds heightmaps.
	if not in_generation_range (run.x + dx, run.z + dz) then
		return
	end

	-- Transform heightmap coordinates.
	local id = mapblock_heightmap (run.x + dx, run.z + dz, false)
	local heightmap = load_heightmap (id)
	assert (run.x + dx >= heightmap.x)
	assert (run.z + dz >= heightmap.z)
	local cs = heightmap.chunksize
	local run_x = (run.x + dx) * 16
	local origin_x = run_x - (heightmap.x * 16)
	local run_z = (run.z + dz) * 16
	local origin_z = cs - (run_z - (heightmap.z * 16)) - 16

	-- Restore transformed data from the destination heightmap.
	local idx_dst = x * HEIGHTMAP_SIZE_NODES + z + 1
	local idx_src = origin_x * cs + origin_z + 1
	local dst = heightmap.data
	local run_min_y = (run.y1 - REQUIRED_CONTEXT_Y) * 16
	local run_max_y = (run.y2 + REQUIRED_CONTEXT_Y) * 16 + 15

	for x1 = 0, 15 do
		for i = 0, 15 do
			local old = dst[idx_src + i]
			local new = src[idx_dst + i]

			-- Must only apply these modifications
			-- if RUN was in a position to edit
			-- the previous value.
			local old_1, old_2, flags
				= unpack_augmented_height_map (old)
			local new_1, new_2, new_flags
				= unpack_augmented_height_map (new)

			if band (new_flags, SURFACE_MODIFIED) ~= 0 then
				if new_1 >= old_1
					or (old_1 - 1 >= run_min_y and old_1 - 1 <= run_max_y) then
					old_1 = new_1
					flags = bor (band (flags, bnot (SURFACE_UNCERTAIN)),
						     band (new_flags, SURFACE_UNCERTAIN))
				end
			end
			if band (new_flags, MOTION_BLOCKING_MODIFIED) ~= 0 then
				if new_2 >= old_2
					or (old_2 - 1 >= run_min_y and old_2 - 1 <= run_max_y) then
					old_2 = new_2
					flags = bor (band (flags, bnot (MOTION_BLOCKING_UNCERTAIN)),
						     band (new_flags, MOTION_BLOCKING_UNCERTAIN))
				end
			end

			flags = band (flags, MODIFIED_MASK)
			dst[idx_src + i]
				= pack_augmented_height_map (old_1, old_2, flags)
		end

		idx_dst = idx_dst + HEIGHTMAP_SIZE_NODES
		idx_src = idx_src + cs
	end
end

function apply_heightmap_modifications (run, result)
	restore_heightmap_segment (run, result, -1, -1)
	restore_heightmap_segment (run, result, -1, 0)
	restore_heightmap_segment (run, result, -1, 1)
	restore_heightmap_segment (run, result, 0, -1)
	restore_heightmap_segment (run, result, 0, 0)
	restore_heightmap_segment (run, result, 0, 1)
	restore_heightmap_segment (run, result, 1, -1)
	restore_heightmap_segment (run, result, 1, 0)
	restore_heightmap_segment (run, result, 1, 1)
end

local function global_index_heightmap (heightmap, node_x, node_z)
	local cs = heightmap.chunksize
	local x = node_x - heightmap.x * 16
	local z = node_z - heightmap.z * 16
	local index = x * chunksize + (cs - z - 1) + 1
	local surface, motion_blocking, flags
		= unpack_augmented_height_map (heightmap.data[index])
	return surface, motion_blocking, flags
end

function mcl_levelgen.map_index_heightmap (dim, x, z, generation_only)
	local namespace = current_namespace_id
	switch_to_namespace (dim.data_namespace)
	local bx = arshift (x, 4)
	local bz = arshift (z, 4)
	local id = mapblock_heightmap (bx, bz, generation_only)
	if id == 0 then
		switch_to_namespace (namespace)
		return nil
	end
	local heightmap = load_heightmap (id)
	switch_to_namespace (namespace)
	return global_index_heightmap (heightmap, x, z)
end

------------------------------------------------------------------------
-- Biome provisioning.
------------------------------------------------------------------------

-- Return a table of every biome data string of a MapBlock in RUN
-- indexed by MapBlock hash including its context.  Coordinates in
-- this table are expected to be represented in Luanti's standard
-- coordinate system.

local get_biome_meta = mcl_levelgen.get_biome_meta

function biome_data_for_run (run, result)
	local data = {}
	local y_bottom = current_namespace.y_bottom

	for x, z, y in context_iterator_xzy (ipos2, run.x, run.z, run.y1, run.y2) do
		local hash = hashmapblock (x, y, z)
		data[hash] = get_biome_meta (x, y + y_bottom, z)
		if not data[hash] then
			local err
				= string.format ("Biome metadata for MapBlock %d,%d,%d is unavailable",
						 x, y, z)
			core.log ("warning", err)

			local plains
				= mcl_levelgen.biome_name_to_id_map["TheVoid"]
			data[hash] = string.char (64)
				.. string.char (plains)
		end
	end
	return data
end

------------------------------------------------------------------------
-- Debug HUD.
------------------------------------------------------------------------

local huds = {}

local function get_status_string (bx, by, bz)
	v.x = bx * 16
	v.y = by * 16 + current_namespace.y_global
	v.z = bz * 16
	local state = mapblock_state (bx, by, bz)
	if core.compare_block_status (v, "loaded") then
		if state == MBS_UNKNOWN then
			return "U "
		elseif state == MBS_PROTO_CHUNK then
			return "P "
		elseif state == MBS_LOCKED or state == MBS_LOCKED_GENERATED then
			return "L "
		elseif state == MBS_REGENERATING then
			return "R "
		elseif state == MBS_GENERATED then
			return "G "
		else
			return "! "
		end
	else
		if state == MBS_UNKNOWN then
			return "? "
		elseif state == MBS_PROTO_CHUNK then
			return "x "
		elseif state == MBS_LOCKED or state == MBS_LOCKED_GENERATED then
			return "l "
		elseif state == MBS_REGENERATING then
			return "r "
		elseif state == MBS_GENERATED then
			return "g "
		else
			return "? "
		end
	end
end

local template
	= "ID: %d; X: %d, Y: %d, Z: %d; CS: %d\nWORLD_SURFACE: %s%3d MOTION_BLOCKING: %s%3d\nStructure at position: %s (%d)"

local function debug_index_heightmap (heightmap, node_x, node_z)
	return global_index_heightmap (heightmap, node_x, node_z)
end

local function debug_index_structuremask (heightmap, x, y, z)
	if not heightmap.structure_masks then
		return 0
	end

	local level_x = x
	local level_y = y + current_namespace.y_offset
	local level_z = -z - 1

	for _, mask in ipairs (heightmap.structure_masks) do
		local x1, y1, z1 = mask[1], mask[2], mask[3]
		local x2, y2, z2 = mask[4], mask[5], mask[6]

		if level_x >= x1 and level_y >= y1 and level_z >= z1
			and level_x <= x2 and level_y <= y2 and level_z <= z2 then
			local h = (y2 - y1) + 1
			local l = (z2 - z1) + 1
			local ix, iy, iz = level_x - x1, level_y - y1, level_z - z1
			local idx = ((ix * h) + iy) * l + iz
			local elem = rshift (idx, 3) + 7
			local bit = lshift (band (idx, 7), 2)
			return band (rshift (mask[elem], bit), 0xf)
		end
	end
	return 0
end

local STRUCTURE_STAGE_NAMES = {
	[0] = "TERRAIN",
	"RAW_GENERATION",
	"LAKES",
	"LOCAL_MODIFICATIONS",
	"UNDERGROUND_STRUCTURES",
	"SURFACE_STRUCTURES",
	"STRONGHOLDS",
	"UNDERGROUND_ORES",
	"UNDERGROUND_DECORATION",
	"FLUID_SPRINGS",
	"VEGETAL_DECORATION",
	"TOP_LAYER_MODIFICATION",
}

local function get_heightmap_string (x, z, self_pos, generation_only)
	local id = mapblock_heightmap (x, z, generation_only)
	if id == 0 then
		return " (none)"
	else
		local heightmap = load_heightmap (id)
		local surface, motion_blocking, flags
			= debug_index_heightmap (heightmap, self_pos.x,
						 self_pos.z)
		local structure_stage
			= debug_index_structuremask (heightmap, self_pos.x,
						     self_pos.y, self_pos.z)
		local surface_quals
			= band (flags, SURFACE_UNCERTAIN) ~= 0 and "?" or ""
		local motion_blocking_quals
			= band (flags, MOTION_BLOCKING_UNCERTAIN) ~= 0 and "?" or ""
		return string.format (template, id,
				      heightmap.x, heightmap.y, heightmap.z,
				      heightmap.chunksize,
				      surface_quals, surface,
				      motion_blocking_quals, motion_blocking,
				      STRUCTURE_STAGE_NAMES[structure_stage],
				      structure_stage)
	end
end

local function get_structure_string (self_pos)
	local strs = {}

	for i, entry in pairs (mcl_levelgen.get_structures_at (self_pos, true)) do
		if #strs >= 1 then
			table.insert (strs, ", ")
		end
		table.insert (strs, (entry.data .. " // "
				     .. vector.to_string (entry.min)
				     .. " "
				     .. vector.to_string (entry.max)))
	end
	if #strs > 3 then
		local n = #strs
		for i = 5, #strs do
			strs[i] = nil
		end
		strs[4] = ", and " .. (n - 3) .. " more"
	end
	return table.concat (strs)
end

local function get_section_string ()
	local fmt = "   %d (%d/%d,%d): %.2f"
	local section_unhash = mcl_levelgen.section_unhash
	local values = {}
	for section, dtime in pairs (section_access_times) do
		local sx, sz = section_unhash (section)
		local id = rshift (section, 10)
		insert (values, string.format (fmt, section, id, sx, sz, dtime))
	end
	table.sort (values)
	return "Loaded sections: \n"
		.. table.concat (values, "\n")
end

local registered_hud_callbacks = {}
mcl_levelgen.registered_hud_callbacks = registered_hud_callbacks

local function hud_text (pos)
	local self_pos = pos
	local x = floor (self_pos.x / 16)
	local y = floor (self_pos.y / 16)
	local z = floor (self_pos.z / 16)
	local level_pos, dim = mcl_levelgen.conv_pos (self_pos)

	if not dim then
		return "Outside confines of level"
	end

	local namespace = current_namespace_id
	switch_to_namespace (dim.data_namespace)
	y = y - current_namespace.y_bottom

	local tbl = {}
	for z1 = 12, -11, -1 do
		for x1 = -11, 12 do
			if x1 == 0 and z1 == 0 then
				table.insert (tbl, "* ")
			else
				table.insert (tbl, get_status_string (x + x1, y, z + z1))
			end
		end
		table.insert (tbl, "\n")
	end
	table.insert (tbl, string.format ("You: %d, %d, %d, %s(%s / %d, %d, %d)\n", x, y, z,
					  get_status_string (x, y, z), dim.id,
					  level_pos.x, level_pos.y, level_pos.z))
	local biomestr
	do
		local biome = mcl_levelgen.get_biome (self_pos)
		local biome_sampled = mcl_levelgen.get_biome (self_pos, true, true)
		if biome then
			biomestr = biome .. " / " .. biome_sampled .. "\n"
		else
			biomestr = "No biome / " .. biome_sampled .. "\n"
		end
	end
	table.insert (tbl, biomestr)
	table.insert (tbl, dim.preset:biome_debug_string (level_pos.x,
							  level_pos.y,
							  level_pos.z) .. "\n")
	table.insert (tbl, string.format ("Heightmap: %s\n",
					  get_heightmap_string (x, z, self_pos, false)))
	table.insert (tbl, string.format ("Heightmap (Generation time): %s\n",
					  get_heightmap_string (x, z, self_pos, true)))
	table.insert (tbl, string.format ("Intersecting structures: %s\n",
					  get_structure_string (self_pos)))
	table.insert (tbl, get_section_string ())
	for _, fn in ipairs (registered_hud_callbacks) do
		local value = fn (self_pos.x, self_pos.y, self_pos.z)
		if value then
			table.insert (tbl, "\n")
			table.insert (tbl, value)
		end
	end
	switch_to_namespace (namespace)
	return table.concat (tbl)
end

local function init_hud (player)
	if not huds[player] then
		local pos = mcl_util.get_nodepos (player:get_pos ())
		local meta = player:get_meta ()
		meta:set_int ("mcl_levelgen:debug_hud_enabled", 1)
		huds[player] = player:hud_add ({
			type = "text",
			alignment = {
				x = 1,
				y = -1,
			},
			text = core.colorize ("#808080", hud_text (pos)),
			style = 5,
			position = {x = 0.0073, y = 0.889},
		})
	end
end

local function delete_hud (player)
	local meta = player:get_meta ()
	meta:set_int ("mcl_levelgen:debug_hud_enabled", 0)
	if huds[player] then
		player:hud_remove (huds[player])
		huds[player] = nil
	end
end

local function update_hud (player)
	local hud = huds[player]
	if hud then
		local pos = mcl_util.get_nodepos (player:get_pos ())
		player:hud_change (hud, "text",
				   core.colorize ("#808080", hud_text (pos)))
	end
end

function mcl_levelgen.register_hud_callback (fn)
	table.insert (registered_hud_callbacks, fn)
end

if not mcl_levelgen.load_feature_environment then

mcl_player.register_globalstep_slow (update_hud)

core.register_chatcommand ("level_generation_status", {
	privs = { debug = true, },
	description = S ("Enable or disable the level generation HUD"),
	func = function (name, toggle)
		local player = core.get_player_by_name (name)
		if toggle == "on" then
			init_hud (player)
		elseif toggle == "off" then
			delete_hud (player)
		end
	end,
})

core.register_on_joinplayer (function (player)
	local meta = player:get_meta ()
	if meta:get_int ("mcl_levelgen:debug_hud_enabled", 0) == 1 then
		init_hud (player)
	end
end)

core.register_on_leaveplayer (function (player)
	huds[player] = nil
end)

function mcl_levelgen.async_fix_structure_pieces (playername, name, x, y, z, dim)
	local dim = mcl_levelgen.get_dimension (dim)
	assert (dim)
	mcl_levelgen.initialize_terrain (dim)
	local sets = { name, }
	local pieces
		= mcl_levelgen.fix_structure_pieces (dim.terrain, x, y, z, sets, 0)
	local piece_data = {}
	for _, piece in _G.ipairs (pieces) do
		local bbox = piece.bbox
		assert (bbox)
		local x1, y1, z1, x2, y2, z2
			= bbox[1], bbox[2], bbox[3], bbox[4], bbox[5], bbox[6]
		z1, z2 = -z2 - 1, -z1 - 1
		table.insert (piece_data, {
			      x1,
			      y1 - dim.y_offset,
			      z1,
			      x2,
			      y2 - dim.y_offset,
			      z2,
			      piece.sid,
		})
	end
	return playername, piece_data
end

function mcl_levelgen.structure_pieces_cb (playername, pieces)
	save_structure_pieces (pieces)
	local blurb
		= S ("@1 structure piece(s) were (re-)inserted into the structure database", #pieces)
	core.chat_send_player (playername, blurb)
	mcl_levelgen.outstanding_structure_operation = nil
end

core.register_chatcommand ("fix_structures", {
	privs = { debug = true, },
	description = S ("Regenerate nearby structure pieces for a structure set"),
	func = function (name, arg)
		if mcl_levelgen.outstanding_structure_operation then
			local blurb = S ("The structure database is currently being repaired.  Please wait.")
			core.chat_send_player (name, blurb)
			return true
		end
		local player = core.get_player_by_name (name)
		local pos = mcl_util.get_nodepos (player:get_pos ())
		local x, y, z, dimension = mcl_levelgen.conv_pos_raw (pos)
		if dimension then
			mcl_levelgen.outstanding_structure_operation = true
			core.handle_async (mcl_levelgen.async_fix_structure_pieces,
					   mcl_levelgen.structure_pieces_cb,
					   name, arg, x, y, z, dimension.id)
		else
			core.chat_send_player (name, S ("No level contains the position @1,@2,@3",
							pos.x, pos.y, pos.z))
		end
	end,
})

------------------------------------------------------------------------
-- Scripting interface.
------------------------------------------------------------------------

function mcl_levelgen.register_notification_handler (name, handler)
	assert (type (name) == "string")
	registered_notification_handlers[name] = handler
end

function run_notification_handlers (gen_notifies)
	for _, notify in ipairs (gen_notifies) do
		local name = notify.name
		-- These values are processed before vm:write_to_map.
		if name ~= "mcl_levelgen:custom_liquid_list" then
			local handler = registered_notification_handlers[name]
			if not handler and not warned[name] then
				warned[name] = true
				core.log ("warning", "Invoking unknown feature generation handler: " .. name)
			elseif handler then
				handler (notify.name, notify.data)
			end
		end
	end
end

function run_structure_notifications ()
	local custom = core.get_mapgen_object ("gennotify").custom
	assert (custom)
	local notifications = custom["mcl_levelgen:gen_notifies"]
	assert (notifications)
	run_notification_handlers (notifications)
end

function mcl_levelgen.level_to_minetest_position (x, y, z)
	if current_namespace then
		return x, y - current_namespace.y_offset, -z - 1
	else
		-- Don't convert Y positions if no dimension currently
		-- exists; this is exercised by structure blocks.
		return x, y, -z - 1
	end
end

------------------------------------------------------------------------
-- Structure deferred feature generation & other structure-related
-- sundries.
------------------------------------------------------------------------

local level_to_minetest_position = mcl_levelgen.level_to_minetest_position

function structure_features_for_run (run)
	local features = {}

	if not run.supplemental then
		local start = current_namespace.y_bottom
		local x, z = run.x, run.z
		for y = run.y1, run.y2 do
			local name = "dg" .. hashmapblock (x, y + start, z)
			local deferred_data = storage:get_string (name)
			if deferred_data and deferred_data ~= "" then
				local record = core.deserialize (deferred_data)
				for _, feature in ipairs (record) do
					table.insert (features, feature)
				end
			end
		end
	end
	return features
end

local function handle_deferred_generation (_, data)
	local x, y, z = level_to_minetest_position (data[1], data[2], data[3])
	local bx, by, bz = arshift (x, 4), arshift (y, 4), arshift (z, 4)
	local hash = hashmapblock (bx, by, bz)
	local deferred_data = storage:get_string ("dg" .. hash)
	local list
	if deferred_data and deferred_data ~= "" then
		list = core.deserialize (deferred_data)

		-- Don't permit the same feature to be generated twice
		-- in the same position.
		for _, existing in ipairs (list) do
			if existing[1] == data[1]
				and existing[2] == data[2]
				and existing[3] == data[3]
				and existing[4] == data[4] then
				return
			end
		end
		table.insert (list, data)
	else
		list = { data, }
	end
	storage:set_string ("dg" .. hash, core.serialize (list))
end

mcl_levelgen.register_notification_handler ("mcl_levelgen:defer_feature_placement",
					    handle_deferred_generation)

------------------------------------------------------------------------
-- Area protection.
------------------------------------------------------------------------

local old_is_protected = core.is_protected
local conv_pos_dimension = mcl_levelgen.conv_pos_dimension
local is_generated = mcl_levelgen.is_generated

function mcl_levelgen.is_protected_chunk (pos)
	local x, y, z, dim = conv_pos_dimension (pos)
	if dim then
		local bx = floor (x / 16)
		local by = floor (y / 16)
		local bz = floor (z / 16)
		if is_generated (dim, bx, by, bz) then
			return false
		end
		return true
	end
	return false
end

function core.is_protected (pos, name)
	if pos then
		return mcl_levelgen.is_protected_chunk (pos)
			or old_is_protected (pos, name)
	end
	return old_is_protected (pos, name)
end

------------------------------------------------------------------------
-- Level generation callbacks.
------------------------------------------------------------------------

local area_generator_cbs = {}
local EMERGE_ERRORED = core.EMERGE_ERRORED
local EMERGE_CANCELLED = core.EMERGE_CANCELLED

function position_requested_by_area_generator_p (bx, bz)
	for _, desc in ipairs (area_generator_cbs) do
		if desc.namespace == current_namespace
			and bx >= desc.bx1 and bz >= desc.bz1
			and bx <= desc.bx2 and bz <= desc.bz2 then
			return true
		end
	end
	return false
end

local function get_containing_mapchunk (x, z, max)
	local origin = mcl_levelgen.mt_chunk_origin
	local chunksize = mcl_levelgen.mt_chunksize
	local x1, z1 = x - origin.x, z - origin.z

	if not max then
		x = floor (x1 / chunksize.x) * chunksize.x
		z = floor (z1 / chunksize.z) * chunksize.z
	else
		x = floor (x1 / chunksize.x) * chunksize.x
			+ chunksize.x - 1
		z = floor (z1 / chunksize.z) * chunksize.z
			+ chunksize.z - 1
	end
	return x, z
end

local function emerge_progress_cb (blockpos, action, calls_remaining, param)
	if action == EMERGE_ERRORED or action == EMERGE_CANCELLED then
		-- Attempt to emerge this area again.  This must be
		-- performed in the next globalstep; otherwise, if an
		-- async error arrives, a deadlock is liable to result
		-- during shutdown.  See
		-- https://github.com/luanti-org/luanti/issues/15419.
		local v = vector.multiply (blockpos, 16)
		core.after (0, core.emerge_area, v, v,
			    emerge_progress_cb, param)
	else
		local hash = hashmapblock (blockpos.x, blockpos.y, blockpos.z)
		if not param.emerged[hash] then
			local progress = param.progress
			param.emerged[hash] = true
			progress.n_emerged = progress.n_emerged + 1
			param.cb_progress (progress, param.data1, param.data2)
		end
	end
end

local ipos_afg = mcl_levelgen.make_ipos_iterator ()

local function area_fully_regenerated_p (desc)
	for x, y, z in ipos_afg (desc.bx1, desc.by1, desc.bz1,
				 desc.bx2, desc.by2, desc.bz2) do
		local state = mapblock_state (x, y, z)
		if state < MBS_GENERATED and state ~= MBS_LOCKED_GENERATED then
			return false
		end
	end
	return true
end

function mcl_levelgen.is_area_fully_regenerated (dim, x1, y1, z1, x2, y2, z2)
	local namespace = current_namespace_id
	switch_to_namespace (dim.data_namespace)
	local bx1 = mathmax (arshift (x1, 4), minblock)
	local bx2 = mathmin (arshift (x2, 4), maxblock)
	local bz1 = mathmax (arshift (z1, 4), minblock)
	local bz2 = mathmin (arshift (z2, 4), maxblock)
	local by1 = mathmax (arshift (y1 - dim.y_global, 4), 0)
	local by2 = mathmin (arshift (y2 - dim.y_global, 4),
			     current_namespace_height - 1)
	for x, y, z in ipos_afg (bx1, by1, bz1, bx2, by2, bz2) do
		local state = mapblock_state (x, y, z)
		if state < MBS_GENERATED and state ~= MBS_LOCKED_GENERATED then
			switch_to_namespace (namespace)
			return false
		end
	end
	switch_to_namespace (namespace)
	return true
end

local function do_nothing ()
end

function report_mbs_generation (bx, by, bz)
	local i1 = 1
	for i = 1, #area_generator_cbs do
		local desc = area_generator_cbs[i]
		if desc.namespace == current_namespace
			and bx >= desc.bx1
			and bz >= desc.bz1
			and by >= desc.by1
			and bx <= desc.bx2
			and by <= desc.by2
			and bz <= desc.bz2 then
			local progress = desc.progress
			progress.n_regenerated = progress.n_regenerated + 1
			desc.cb_progress (progress, desc.data1, desc.data2)
			-- print (hud_text (desc.center))

			if progress.n_regenerated >= progress.total_regen
			-- Also remove entries if all MapBlocks in
			-- their areas have been regenerated, so as to
			-- provide for operations extending across
			-- multiple levels.
				or (progress.n_dimensions > 1
				    and area_fully_regenerated_p (desc)) then
				do_nothing ()
			else
				area_generator_cbs[i1] = desc
				i1 = i1 + 1
			end
		else
			area_generator_cbs[i1] = desc
			i1 = i1 + 1
		end
	end
	for i = i1, #area_generator_cbs do
		area_generator_cbs[i] = nil
	end
end

local function generate_area_1 (dim, progress, x1, y1, z1, x2, y2, z2,
				cb_progress, data1, data2)
	local bx1 = mathmax (arshift (x1, 4), minblock)
	local bx2 = mathmin (arshift (x2, 4), maxblock)
	local bz1 = mathmax (arshift (z1, 4), minblock)
	local bz2 = mathmin (arshift (z2, 4), maxblock)
	local by1 = arshift (y1, 4)
	local by2 = arshift (y2, 4)
	local dx, dy, dz = bx2 - bx1 + 1, by2 - by1 + 1, bz2 - bz1 + 1
	local total_regen = dx * dy * dz
	local n_regenerated = 0

	switch_to_namespace (dim.data_namespace)
	for x, z, y in ipos1 (bx1, bz1, by1, bx2, bz2, by2) do
		local state = mapblock_state (x, y, z)
		if state == MBS_GENERATED
			or state == MBS_LOCKED_GENERATED then
			n_regenerated = n_regenerated + 1
		end
	end

	local cx1, cy1, cz1, cx2, cy2, cz2
		= area_context_range (bx1 - 1, bz1 - 1, by1 - 1,
				      bx2 + 1, bz2 + 1, by2 + 1)
	cx1, cz1 = get_containing_mapchunk (cx1, cz1, false)
	cx2, cz2 = get_containing_mapchunk (cx2, cz2, true)

	v1.x = cx1 * 16
	v1.y = cy1 * 16 + dim.y_global
	v1.z = cz1 * 16
	v2.x = cx2 * 16 + 15
	v2.y = cy2 * 16 + 15 + dim.y_global
	v2.z = cz2 * 16 + 15
	local dcx, dcy, dcz
		= cx2 - cx1 + 1, cy2 - cy1 + 1, cz2 - cz1 + 1

	local desc = {
		bx1 = bx1,
		by1 = by1,
		bz1 = bz1,
		bx2 = bx2,
		by2 = by2,
		bz2 = bz2,
		cx1 = cx1,
		cy1 = cy1 + dim.y_global_block,
		cz1 = cz1,
		cx2 = cx2,
		cy2 = cy2 + dim.y_global_block,
		cz2 = cz2,
		emerged = {},
		cb_progress = cb_progress,
		data1 = data1,
		data2 = data2,
		progress = progress,
		namespace = current_namespace,
	}
	progress.total_regen = progress.total_regen + total_regen
	progress.n_regenerated = progress.n_regenerated + n_regenerated
	progress.total_emerge = progress.total_emerge + dcx * dcz * dcy
	core.emerge_area (v1, v2, emerge_progress_cb, desc)

	if total_regen > n_regenerated then
		insert (area_generator_cbs, desc)
	end
end

-- Generate each MapBlock between X1, Y1, Z1, and X2, Y2, Z2, invoking
-- CB_PROGRESS with the approximate progress of the emerge operation
-- and that of MapBlock regeneration in the provided area as a table
-- of integer values.  All MapBlocks necessary for each MapBlock in
-- the supplied area to be regenerated will be emerged, excepting
-- those beyond the world border; MapBlock regeneration where it is
-- impeded by the world border will also be dispensed with.

function mcl_levelgen.generate_area (x1, y1, z1, x2, y2, z2, cb_progress,
				     data1, data2)
	local progress = {
		total_regen = 0,
		n_regenerated = 0,
		total_emerge = 0,
		n_emerged = 0,
		n_dimensions = 0,
	}
	local namespace = current_namespace
	for y1, y2, ystart, yend, dim in dims_intersecting (y1, y2) do
		local y1 = y1 - dim.y_global
		local y2 = y2 - dim.y_global
		generate_area_1 (dim, progress, x1, y1, z1, x2, y2, z2,
				 cb_progress, data1, data2)
		progress.n_dimensions = progress.n_dimensions + 1
	end
	switch_to_namespace (namespace)
	cb_progress (progress, data1, data2)
end

------------------------------------------------------------------------
-- Async environment registration.
------------------------------------------------------------------------

core.register_async_dofile (mcl_levelgen.prefix .. "/init.lua")

end -- if not mcl_levelgen.load_feature_environment
