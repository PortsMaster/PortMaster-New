------------------------------------------------------------------------
-- Luanti map generator adapter (a.k.a. "ersatz levels").
-- TODO:
--  [X] Biome indexing and translation.
--  [X] Issuing generation notifications.
--  [X] Rudimentary beardificiation.
--  [X] Recording generated structure pieces.
--  [X] Re-enabling mcl_mapgen_core.
--  [X] End island map generator models.
------------------------------------------------------------------------

mcl_levelgen.initialize_nodeprops_in_async_env ()
mcl_levelgen.initialize_portable_schematics ()

------------------------------------------------------------------------
-- Ersatz carvers.
------------------------------------------------------------------------

local ersatz_carvers_loaded = false

if mcl_levelgen.ersatz_enable_carvers then

local function augment_overworld_carver (id)
	local carver = mcl_levelgen.registered_carvers[id]
	table.insert (carver.replaceable, "group:material_stone")
	table.insert (carver.replaceable, "group:snow_layer")
	table.insert (carver.replaceable, "mcl_core:clay")
	table.insert (carver.replaceable, "mcl_core:lava_source")
	table.insert (carver.replaceable, "mcl_core:snowblock")
	table.insert (carver.replaceable, "mcl_powder_snow:powder_snow")
end

local function augment_nether_carver (id)
	local carver = mcl_levelgen.registered_carvers[id]
	table.insert (carver.replaceable, "group:material_stone")
	table.insert (carver.replaceable, "mcl_nether:nether_lava_source")
end

augment_overworld_carver ("mcl_levelgen:cave_carver")
augment_overworld_carver ("mcl_levelgen:cave_extra_underground_carver")
augment_overworld_carver ("mcl_levelgen:ravine_carver")
augment_nether_carver ("mcl_levelgen:nether_cave_carver")

mcl_levelgen.load_carvers ()
ersatz_carvers_loaded = true

end

------------------------------------------------------------------------
-- Ersatz terrain generator.
------------------------------------------------------------------------

local ipairs = ipairs

local mathmin = math.min
local mathmax = math.max
local mathabs = math.abs

local mt_chunksize = core.ipc_get ("mcl_levelgen:mt_chunksize")
local chunksize = mt_chunksize.x * 16
local ychunksize = mt_chunksize.y * 16

local cid_air = core.CONTENT_AIR
local cid_ignore = core.CONTENT_IGNORE
local floor = math.floor

local encode_node, decode_node

if core.global_exists ("jit") then
	encode_node = mcl_levelgen.encode_node
	decode_node = mcl_levelgen.decode_node
else
	function encode_node (cid, param2)
		return cid * 256 + param2
	end

	function decode_node (data)
		return floor (data / 256), data % 256
	end
end

------------------------------------------------------------------------
-- Ersatz terrain generation.
------------------------------------------------------------------------

local gn = {}

for i = 1, chunksize * ychunksize * chunksize do
	gn[i] = 0
end

local heightmap, heightmap_wg = {}, {}
local cids, param2s = {}, {}
local biomes = {}
local biomemap_old, biomemap = {}

local walkable_p = mcl_levelgen.walkable_p
local pack_height_map = mcl_levelgen.pack_height_map

local function build_heightmap (min, max, chunkmin, chunkmax, y1, y2, y_global)
	local yw = (max.y - min.y + 1)
	local ystride = (max.x - min.x + 1)
	local zstride = (max.y - min.y + 1) * ystride
	local miny = min.y
	local dzstart = chunkmin.z - min.z
	local dzend = chunkmax.z - min.z
	local dxstart = chunkmin.x - min.x
	local dxend = chunkmax.x - min.x
	assert (dzstart == dxstart)
	assert (dzstart == max.z - chunkmax.z)
	assert (dzstart == max.x - chunkmax.x)

	local ytop = mathmin (yw - 1, y2 - miny + 1)
	local ybot = mathmax (0, y1 - miny)

	for dz = dzstart, dzend do
		local idx_base = dz * zstride
		for dx = dxstart, dxend do
			local idx_x = idx_base + dx
			local motion_blocking = -512
			local world_surface = -512
			for dy = ytop, ybot, -1 do
				local cid = cids[idx_x + dy * ystride + 1]
				if cid ~= cid_air then
					world_surface = mathmax (world_surface, dy)
				end
				if walkable_p (cid) then
					motion_blocking = mathmax (motion_blocking, dy)
				end
				if world_surface >= 0 and motion_blocking >= 0 then
					break
				end
			end
			local index = (dx - dxstart) * chunksize
				+ (chunksize - dz + dzstart)
			local y_offset = miny - y_global + 1
			local value
				= pack_height_map (world_surface + y_offset,
						   motion_blocking + y_offset)
			heightmap[index], heightmap_wg[index] = value, value
		end
	end
end

local ipos1 = mcl_levelgen.ipos1
local build_gn_from_data
local restore_data_from_gn

if core.global_exists ("jit") then
	-- Avoid expensive division operations by means of bitwise
	-- operations.

function build_gn_from_data (min, max, minp, maxp, y1, y2)
	local ystride = (max.x - min.x + 1)
	local zstride = (max.y - min.y + 1) * ystride
	local xdstride = chunksize * ychunksize
	local ydstride = chunksize
	assert (maxp.x - minp.x == chunksize - 1)
	assert (maxp.y - minp.y == ychunksize - 1)
	assert (maxp.z - minp.z == chunksize - 1)
	local border = minp.x - min.x
	assert (border == max.x - maxp.x)
	assert (border == minp.y - min.y)
	assert (border == max.y - maxp.y)
	assert (border == minp.z - min.z)
	assert (border == max.z - maxp.z)
	local ystart = y1 - min.y
	for x, y, z in ipos1 (minp.x - min.x,
			      ystart,
			      minp.z - min.z,
			      maxp.x - min.x,
			      y2 - min.y,
			      maxp.z - min.z) do
		local idx_src = z * zstride + y * ystride + x + 1
		local encoded = encode_node (cids[idx_src], param2s[idx_src])
		local idx_dst = (x - border) * xdstride
			+ (y - ystart) * ydstride
			+ ((chunksize - 1) - (z - border))
			+ 1
		gn[idx_dst] = encoded
	end
end

function restore_data_from_gn (min, max, minp, maxp, y1, y2)
	local ystride = (max.x - min.x + 1)
	local zstride = (max.y - min.y + 1) * ystride
	local xdstride = chunksize * ychunksize
	local ydstride = chunksize
	local border = minp.x - min.x
	local ystart = y1 - min.y
	for x, y, z in ipos1 (minp.x - min.x,
			      ystart,
			      minp.z - min.z,
			      maxp.x - min.x,
			      y2 - min.y,
			      maxp.z - min.z) do
		local idx_src = z * zstride + y * ystride + x + 1
		local idx_dst = (x - border) * xdstride
			+ (y - ystart) * ydstride
			+ ((chunksize - 1) - (z - border))
			+ 1
		local encoded = gn[idx_dst]
		local cid_new, param2_new = decode_node (encoded)
		cids[idx_src], param2s[idx_src]	= cid_new, param2_new
	end
end

else
	-- But avoid function call overhead on PUC Lua, which cannot
	-- perform inlining.

function build_gn_from_data (min, max, minp, maxp, y1, y2)
	local ystride = (max.x - min.x + 1)
	local zstride = (max.y - min.y + 1) * ystride
	local xdstride = chunksize * ychunksize
	local ydstride = chunksize
	assert (maxp.x - minp.x == chunksize - 1)
	assert (maxp.y - minp.y == ychunksize - 1)
	assert (maxp.z - minp.z == chunksize - 1)
	local border = minp.x - min.x
	assert (border == max.x - maxp.x)
	assert (border == minp.y - min.y)
	assert (border == max.y - maxp.y)
	assert (border == minp.z - min.z)
	assert (border == max.z - maxp.z)
	local ystart = y1 - min.y
	for x, y, z in ipos1 (minp.x - min.x,
			      ystart,
			      minp.z - min.z,
			      maxp.x - min.x,
			      y2 - min.y,
			      maxp.z - min.z) do
		local idx_src = z * zstride + y * ystride + x + 1
		local encoded = cids[idx_src] * 256 + param2s[idx_src]
		local idx_dst = (x - border) * xdstride
			+ (y - ystart) * ydstride
			+ ((chunksize - 1) - (z - border))
			+ 1
		gn[idx_dst] = encoded
	end
end

function restore_data_from_gn (min, max, minp, maxp, y1, y2)
	local ystride = (max.x - min.x + 1)
	local zstride = (max.y - min.y + 1) * ystride
	local xdstride = chunksize * ychunksize
	local ydstride = chunksize
	local border = minp.x - min.x
	local ystart = y1 - min.y
	for x, y, z in ipos1 (minp.x - min.x,
			      ystart,
			      minp.z - min.z,
			      maxp.x - min.x,
			      y2 - min.y,
			      maxp.z - min.z) do
		local idx_src = z * zstride + y * ystride + x + 1
		local idx_dst = (x - border) * xdstride
			+ (y - ystart) * ydstride
			+ ((chunksize - 1) - (z - border))
			+ 1
		local encoded = gn[idx_dst]
		local cid_new, param2_new
			= floor (encoded / 256), encoded % 256
		cids[idx_src], param2s[idx_src]	= cid_new, param2_new
	end
end

end

local chunk_start_x
local chunk_start_z
local emerged_area_x
local emerged_area_z
local emerged_area_size
local ersatz_translate_biome = mcl_levelgen.ersatz_translate_biome

local function build_biomemap_from_mgobject (min, max, minp, maxp, y1, y2)
	chunk_start_x = minp.x
	chunk_start_z = -maxp.z - 1
	emerged_area_x = minp.x
	emerged_area_z = minp.z
	emerged_area_size = maxp.x - minp.x + 1
	biomemap = core.get_mapgen_object ("biomemap")
	for i = 1, #biomemap do
		biomemap_old[i] = biomemap[i]
		biomemap[i] = ersatz_translate_biome (biomemap[i])
			or "Plains"
	end
end

local function index (x, y, z, chunksize, level_height)
	return ((x * ychunksize) + y) * chunksize + z + 1
end

local beard_weights = {}

local cid_dirt = core.get_content_id ("mcl_core:dirt")
local cid_stone = core.get_content_id ("mcl_core:stone")
local cid_grass_block = core.get_content_id ("mcl_core:dirt_with_grass")

local walkable_p = mcl_levelgen.walkable_p
local air_water_or_lava_p = mcl_levelgen.air_water_or_lava_p
local ssum, bsum

local function sample_density (x, y, z, s)
	local index = index (x, y, z, chunksize, nil)
	local cid, _ = decode_node (gn[index])
	ssum = ssum + (walkable_p (cid) and 1.0 or 0.0) * s
	bsum = bsum + beard_weights[index] * s
end

local function scale_neg (value)
	if value < 0 then
		return value * 3
	else
		return value
	end
end

local function density (x, y, z, ystart, yend)
	ssum, bsum = 0.0, 0.0
	sample_density (mathmax (0, x + -1), mathmax (ystart, y + -1), mathmax (0, z + -1), 0.090615)
	sample_density (mathmax (0, x + -1), mathmax (ystart, y + -1), z, 0.140786)
	sample_density (mathmax (0, x + -1), mathmax (ystart, y + -1), mathmin (chunksize - 1, z + 1), 0.090615)
	sample_density (mathmax (0, x + -1), y, mathmax (0, z + -1), 0.140786)
	sample_density (mathmax (0, x + -1), y, z, 0.250000)
	sample_density (mathmax (0, x + -1), y, mathmin (chunksize - 1, z + 1), 0.140786)
	sample_density (mathmax (0, x + -1), mathmin (yend, y + 1), mathmax (0, z + -1), 0.090615)
	sample_density (mathmax (0, x + -1), mathmin (yend, y + 1), z, 0.140786)
	sample_density (mathmax (0, x + -1), mathmin (yend, y + 1), mathmin (chunksize - 1, z + 1), 0.090615)
	sample_density (x, mathmax (ystart, y + -1), mathmax (0, z + -1), 0.140786)
	sample_density (x, mathmax (ystart, y + -1), z, 0.250000)
	sample_density (x, mathmax (ystart, y + -1), mathmin (chunksize - 1, z + 1), 0.140786)
	sample_density (x, y, mathmax (0, z + -1), 0.250000)
	sample_density (x, y, z, 1.000000)
	sample_density (x, y, mathmin (chunksize - 1, z + 1), 0.250000)
	sample_density (x, mathmin (yend, y + 1), mathmax (0, z + -1), 0.140786)
	sample_density (x, mathmin (yend, y + 1), z, 0.250000)
	sample_density (x, mathmin (yend, y + 1), mathmin (chunksize - 1, z + 1), 0.140786)
	sample_density (mathmin (chunksize - 1, x + 1), mathmax (ystart, y + -1), mathmax (0, z + -1), 0.090615)
	sample_density (mathmin (chunksize - 1, x + 1), mathmax (ystart, y + -1), z, 0.140786)
	sample_density (mathmin (chunksize - 1, x + 1), mathmax (ystart, y + -1), mathmin (chunksize - 1, z + 1), 0.090615)
	sample_density (mathmin (chunksize - 1, x + 1), y, mathmax (0, z + -1), 0.140786)
	sample_density (mathmin (chunksize - 1, x + 1), y, z, 0.250000)
	sample_density (mathmin (chunksize - 1, x + 1), y, mathmin (chunksize - 1, z + 1), 0.140786)
	sample_density (mathmin (chunksize - 1, x + 1), mathmin (yend, y + 1), mathmax (0, z + -1), 0.090615)
	sample_density (mathmin (chunksize - 1, x + 1), mathmin (yend, y + 1), z, 0.140786)
	sample_density (mathmin (chunksize - 1, x + 1), mathmin (yend, y + 1), mathmin (chunksize - 1, z + 1), 0.090615)
end

local function augmented_density (x, y, z, ystart, yend)
	density (x, y, z, ystart, yend)
	return ssum + scale_neg (bsum), bsum
end

local encoded_grass = encode_node (cid_grass_block, 0)
local encoded_default_block = encode_node (cid_stone, 0)
local encoded_air = encode_node (cid_air, 0)
local encoded_top_nodes = {}

local function ersatz_surface_rule (heightmap, biome, x, y, z, idx_above)
	local dz = chunksize - z - 1
	local idx = dz * chunksize + x + 1
	if heightmap[idx] <= y then
		-- Don't place grass while terraforming if the node
		-- above is not air (e.g. a liquid node), even if it
		-- is below the heightmap.
		if not idx_above or cids[idx_above] == cid_air then
			heightmap[idx] = y
			return encoded_top_nodes[biome]
				or encoded_grass
		end
	end
	return encoded_default_block
end

for biome, def in pairs (core.registered_biomes) do
	local id = core.get_biome_id (biome)
	local cid_top_node
		= core.get_content_id (def.node_top or "mcl_core:dirt_with_grass")
	encoded_top_nodes[id] = encode_node (cid_top_node, 0)
end

local function unpack6 (x)
	return x[1], x[2], x[3], x[4], x[5], x[6]
end

local function form_terrain (beard_weights, ystart, ymax, min, max, border, boxes)
	local heightmap = core.get_mapgen_object ("heightmap")
	local miny = min.y
	local minx = min.x
	local minz = -max.z - 1
	local xw = max.x - minx + 1
	local yw = max.y - miny + 1

	for _, box in ipairs (boxes) do
		local x1 = mathmax (box[1] - minx - border, 0)
		local y1 = mathmax (box[2] - ystart, 0)
		local z1 = mathmax (box[3] - minz - border, 0)
		local x2 = mathmin (box[4] - minx - border, chunksize - 1)
		local y2 = mathmin (box[5] - ystart, ymax)
		local z2 = mathmin (box[6] - minz - border, chunksize - 1)
		assert (x1 >= 0 and y1 >= 0 and z1 >= 0
			and x2 < chunksize and y2 <= ymax and z2 < chunksize)

		for x, _, z in ipos1 (x1, 0, z1, x2, 0, z2) do
			for y = y2, y1, -1 do
				local i = index (x, y, z, chunksize, nil)
				local density, bsum = augmented_density (x, y, z, 0, ymax)
				if mathabs (bsum) > 0.1 then
					local cid, _ = decode_node (gn[i])
					local oldz = (chunksize - z - 1 + border)
					local oldy = (border + y)
					assert (oldz < xw and oldz > 0)
					assert (oldy < xw and oldy > 0)
					local old_index = oldz * xw * yw
						+ oldy * xw + x + border + 1
					local y_abs = y + miny + border
					local biome = biomemap_old [z * chunksize + x + 1]
					if density < 0.8 and not air_water_or_lava_p (cid) then
						if y > 0 then
							-- Fix the heightmap.
							local dz = chunksize - z - 1
							local idx = dz * chunksize + x + 1
							if heightmap[idx] == y_abs then
								heightmap[idx] = y_abs - 1
							end

							-- Propagate grass cover to dirt nodes below.
							local i_below = index (x, y - 1, z, chunksize, nil)
							local cid, _ = decode_node (gn[i_below])
							if cid == cid_dirt then
								gn[i_below] = ersatz_surface_rule (heightmap, biome,
												   x, y, z, nil)
							end
						end
						gn[i] = encoded_air
						cids[old_index], param2s[old_index] = cid_air, 0
					elseif density > 1.6 and not walkable_p (cid) then
						local node = ersatz_surface_rule (heightmap, biome,
										  x, y_abs, z,
										  old_index + xw)
						gn[i] = node
						cids[old_index], param2s[old_index] = decode_node (node)
					end
				end
			end
		end
	end
end

local get_ersatz_terrain = mcl_levelgen.get_ersatz_terrain

local function do_terrain_modifications (min, max, minp, maxp, y1, y2,
					 ystart, yend, dim)
	local xmin = minp.x
	local zmin = -maxp.z - 1
	for i = 1, #gn do
		beard_weights[i] = 0.0
	end

	local terrain = get_ersatz_terrain (dim)
	local level = terrain.structures
	terrain.heightmap = heightmap
	terrain.heightmap_wg = heightmap_wg
	encoded_default_block = encode_node (terrain.cid_default_block, 0)
	-- chunksize_y is only consulted by the structure generator to
	-- establish whether structure pieces or generation
	-- notifications in fact intersect the region of the chunk
	-- being generated.
	assert (yend - ystart + 1 <= ychunksize)
	terrain.chunksize_y = yend - ystart + 1
	mcl_levelgen.prepare_structures (level, terrain, xmin, zmin)
	local boxes = {}
	if mcl_levelgen.beardify_1 (level, terrain, beard_weights, index, xmin,
				    zmin, yend - ystart + 1, ystart, chunksize,
				    boxes) then
		local border = minp.x - min.x
		form_terrain (beard_weights, ystart, yend - ystart, min, max, border,
			      boxes)
	end
	build_heightmap (min, max, minp, maxp, y1, y2, dim.y_global)
	if ersatz_carvers_loaded then
		terrain.aquifer:reseat (xmin, ystart, zmin)
		mcl_levelgen.carve_terrain (dim.preset, gn, biomes, heightmap,
					    xmin, ystart, zmin, chunksize, index,
					    ystart, yend - ystart + 1, terrain)
	end
	mcl_levelgen.finish_structures (level, terrain, biomes,
					xmin, ystart, zmin, ystart,
					yend - ystart + 1, index, gn)
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

local function write_gen_notifies (dim, minp, maxp)
	local notifies, pieces
		= mcl_levelgen.flush_structure_gen_data ()
	transform_structure_pieces (pieces, dim, minp, maxp)
	core.save_gen_notify ("mcl_levelgen:gen_notifies", notifies)
	core.save_gen_notify ("mcl_levelgen:structure_pieces", pieces)
end

local cid_biome_dust = core.ipc_get ("mcl_biomes:biome_dust_cids")

local is_cid_dustable = {}

for name, def in pairs (core.registered_nodes) do
	local cid = core.get_content_id (name)
	is_cid_dustable[cid] = (def.drawtype == "normal"
				or def.drawtype == "allfaces"
				or def.drawtype == "allfaces_optional"
				or def.drawtype == "glasslike"
				or def.drawtype == "glasslike_framed"
				or def.drawtype == "glasslike_framed_optional")
		and def.walkable
end

local function generate_biome_dust (vm, min, max, minp, maxp)
	local area = VoxelArea (min, max)
	local modified = false
	local initialized = false

	local index = 0
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			index = index + 1
			local biome = biomemap_old[index]
			local cid_dust = cid_biome_dust[biome]
			if cid_dust then
				if not initialized then
					vm:get_data (cids)
					vm:get_param2_data (param2s)
					initialized = true
				end
				local i = area:index (x, max.y, z)
				local full_max, y_start = cids[i], nil
				if full_max == cid_air then
					y_start = max.y - 1
				elseif full_max == cid_ignore then
					i = area:index (x, maxp.y + 1, z)
					if cids[i] == cid_air then
						y_start = maxp.y
					end
				end

				if y_start then
					i = area:index (x, y_start, z)
					local stride = max.x - min.x + 1
					for y = y_start, minp.y - 1, -1 do
						if cids[i] ~= cid_air then
							break
						end
						i = i - stride
					end

					if is_cid_dustable[cids[i]] and cids[i] ~= cid_dust then
						cids[i + stride] = cid_dust
						param2s[i + stride] = 0
						modified = true
					end
				end
			end
		end
	end

	if modified then
		vm:set_data (cids)
		vm:set_param2_data (param2s)
	end
end

local dims_intersecting = mcl_levelgen.dims_intersecting
core.register_on_generated (function (vm, minp, maxp, _)
	local min, max = vm:get_emerged_area ()

	vm:get_data (cids)
	vm:get_param2_data (param2s)

	local generated = false

	for y1, y2, ystart, yend, dim in dims_intersecting (minp.y, maxp.y) do
		if generated then
			-- Mostly since it would inflate the size of
			-- the gen_notify arrays, and doesn't really
			-- appear to be necessary.
			error ("Not yet implemented: simultaneous generation of multiple dimensions")
		end

		-- min and max represent the emerged area of the
		-- vmanip, which is always one mapblock larger than a
		-- MapChunk and contains generated terrain.
		--
		-- This partially supplies the absence of complete map
		-- data within this dimension, which are not available
		-- to structures.  Heightmap data only extends to the
		-- end of this region and the carefree engine proceeds
		-- on its merry way with fingers crossed, in the hope
		-- that any damage occasioned by discrepancies will be
		-- confined to the region that is not actually
		-- generated, as is its wont...

		build_gn_from_data (min, max, minp, maxp, y1, y2)
		build_biomemap_from_mgobject (min, max, minp, maxp, y1, y2)
		do_terrain_modifications (min, max, minp, maxp, y1, y2,
					  ystart, yend, dim)
		restore_data_from_gn (min, max, minp, maxp, y1, y2)
		write_gen_notifies (dim, minp, maxp)
		generated = true
	end

	vm:set_data (cids)
	vm:set_param2_data (param2s)
	core.generate_decorations (vm, minp, maxp, true)
	generate_biome_dust (vm, min, max, minp, maxp)
	vm:set_lighting ({day = 0, night = 0,}, minp, maxp)
	vm:calc_lighting (minp, maxp)
end)

------------------------------------------------------------------------
-- Structure generation overrides.
------------------------------------------------------------------------

local function ersatz_biomemap_index (x, z)
	local dx = x - emerged_area_x
	local dz = (-z - 1) - emerged_area_z
	local index = dz * emerged_area_size + dx + 1
	return index
end

mcl_levelgen.ersatz_biomemap_index = ersatz_biomemap_index

function mcl_levelgen.index_biome (x, y, z)
	if x < chunk_start_x or x >= chunk_start_x + chunksize
		or z < chunk_start_z or z >= chunk_start_z + chunksize then
		return nil
	end
	return biomemap[ersatz_biomemap_index (x, z)]
end

------------------------------------------------------------------------
-- Scripting interface.
------------------------------------------------------------------------

mcl_levelgen.is_levelgen_environment = true
-- Run level generation scripts registered to execute in the ersatz
-- environment.
for _, script in ipairs (core.ipc_get ("mcl_levelgen:levelgen_scripts")) do
	if script.ersatz_supported then
		dofile (script.script)
	end
end
mcl_levelgen.run_on_scripts_loaded ()
