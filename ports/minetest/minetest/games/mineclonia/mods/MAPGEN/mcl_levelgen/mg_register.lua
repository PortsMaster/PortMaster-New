------------------------------------------------------------------------
-- Level generator callbacks.
------------------------------------------------------------------------

local ipairs = ipairs
local mathmin = math.min
local mathmax = math.max

mcl_levelgen.initialize_nodeprops_in_async_env ()
mcl_levelgen.initialize_portable_schematics ()

-- local zone = require ("jit.zone")

if core.global_exists ("jit") then
	jit.opt.start ("maxmcode=40960", "maxtrace=100000",
		       -- Just large enough that loops employing RNGs
		       -- can be unrolled and compiled but the
		       -- fix_distances loop in pick_grid_positions is
		       -- not.
		       "loopunroll=35", "maxside=8000", "maxsnap=1000",
		       "maxrecord=8000")
	-- require ("jit.dump").start ("+birxmT", "server_perf.txt")
	-- local profile = require ("jit.p")
	-- profile.start ("fv")
end

-- Load carvers into biome descriptions.
mcl_levelgen.load_carvers ()

local mt_chunksize = mcl_levelgen.mt_chunksize
local chunksize = mt_chunksize.x * 16
mcl_levelgen.initialize_terrain ()

local cids, param2s, structuremask, biomes = {}, {}, {}, {}

local area = nil

local function index (x, y, z)
	return area:index (x, y, chunksize - z - 1)
end

local floor = math.floor

-- local profile = require ("jit.p")
-- local v = require ("jit.v")

-- local function do_jit_ctrl ()
-- 	if core.ipc_get ("mcl_levelgen:jit_flush") then
-- 		jit.flush ()
-- 		core.ipc_set ("mcl_levelgen:jit_flush", false)
-- 	end
-- 	if core.ipc_get ("mcl_levelgen:jit_profiler") then
-- 		profile.start ("f2v")
-- 		core.ipc_set ("mcl_levelgen:jit_profiler", false)
-- 	end
-- 	if core.ipc_get ("mcl_levelgen:jit_v") then
-- 		require ("jit.v").start ()
-- 		core.ipc_set ("mcl_levelgen:jit_profiler", false)
-- 	end
-- 	if core.ipc_get ("mcl_levelgen:jit_profiler_flush") then
-- 		profile.stop ()
-- 		core.ipc_set ("mcl_levelgen:jit_profiler_flush", false)
-- 	end
-- end

local function unpack6 (x)
	return x[1], x[2], x[3], x[4], x[5], x[6]
end

local function transform_structure_pieces (pieces, dim, minp, maxp)
	local y_offset = dim.y_offset

	for _, piece in ipairs (pieces) do
		local x1, y1, z1, x2, y2, z2 = unpack6 (piece)
		z1, z2 = -z2 - 1, -z1 - 1

		piece[1] = mathmax (x1, minp.x)
		piece[2] = mathmax (y1 - y_offset, minp.y)
		piece[3] = mathmax (z1, minp.z)
		piece[4] = mathmin (x2, maxp.x)
		piece[5] = mathmin (y2 - y_offset, maxp.y)
		piece[6] = mathmin (z2, maxp.z)

		if piece[1] > piece[4] or piece[2] > piece[5] or piece[3] > piece[6] then
			core.log ("warning", ("[mcl_levelgen]: Invalid structure extents: "
					      .. string.format ("(%d,%d,%d) - (%d,%d,%d)",
								unpack6 (piece))))
		end
	end
end

local dims_intersecting = mcl_levelgen.dims_intersecting

core.register_on_generated (function (vmanip, minp, maxp, _)
	-- profile.start ("5fv")
	-- do_jit_ctrl ()
	local emin, emax = vmanip:get_emerged_area ()
	area = VoxelArea (vector.subtract (emin, minp),
			  vector.subtract (emax, minp))
	vmanip:get_data (cids)
	vmanip:get_param2_data (param2s)
	local generated = false

	for y1, y2, ystart, yend, dim in dims_intersecting (minp.y, maxp.y) do
		if generated then
			-- Mostly since it would inflate the size of
			-- the gen_notify arrays, and doesn't really
			-- appear to be necessary.
			error ("Not yet implemented: simultaneous generation of multiple dimensions")
		end

		local block_x = minp.x / 16
		local block_y = (dim.y_offset + minp.y) / 16
		local block_z = minp.z / 16
		assert (block_x == floor (block_x))
		assert (block_y == floor (block_y))
		assert (block_z == floor (block_z))
		local preset, terrain = dim.preset, dim.terrain
		local level_min = preset.min_y / 16
		local level_height = preset.height / 16
		assert (level_min == floor (level_min))
		assert (level_height == floor (level_height))
		-- print (string.format ("{%d,%d,%d,%d,%d,%d,},", minp.x, minp.y, minp.z,
		-- 		      maxp.x, maxp.y, maxp.z))
		-- local clock = core.get_us_time ()
		-- zone ("Biome generation")
		mcl_levelgen.generate_biomes_at_block (preset, biomes, block_x,
						       level_min, block_z,
						       mt_chunksize.x, level_height)
		-- zone ()
		-- zone ("Terrain generation")
		if not terrain:generate (minp.x, dim.y_offset + minp.y,
					 -minp.z - chunksize, cids, param2s,
					 structuremask, index, biomes) then
			local notifications, _
				= mcl_levelgen.flush_structure_gen_data ()
			core.save_gen_notify ("mcl_levelgen:gen_notifies", notifications)
			core.save_gen_notify ("mcl_levelgen:structure_pieces", nil)
			return
		end
		-- print (string.format ("%.2f", (core.get_us_time () - clock) / 1000))
		-- zone ()
		vmanip:set_data (cids)
		vmanip:set_param2_data (param2s)

		if not dim.no_lighting then
			vmanip:set_lighting ({day=0, night=0,}, minp, maxp)
		end
		-- Artificial light should be processed even when the
		-- level is otherwise assumed to be sunlit.
		vmanip:calc_lighting (minp, maxp)
		local notifications, pieces
			= mcl_levelgen.flush_structure_gen_data ()
		core.save_gen_notify ("mcl_levelgen:gen_notifies", notifications)
		transform_structure_pieces (pieces, dim, minp, maxp)
		core.save_gen_notify ("mcl_levelgen:structure_pieces", pieces)

		-- zone ("Biome encoding")
		local compressed
			= mcl_levelgen.encode_biomes (biomes, block_y - level_min,
						      mt_chunksize.y, mt_chunksize.x,
						      level_height)
		core.save_gen_notify ("mcl_levelgen:biome_data", compressed)
		-- zone ()

		core.save_gen_notify ("mcl_levelgen:level_height_map", {
			level = terrain.heightmap,
			wg = terrain.heightmap_wg,
		})

		if #structuremask > 6 then
			core.save_gen_notify ("mcl_levelgen:structure_mask",
					      structuremask)
		end

		generated = true
	end
end)
