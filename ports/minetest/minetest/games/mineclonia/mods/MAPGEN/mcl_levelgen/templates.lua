------------------------------------------------------------------------
-- Structure templates.
--
-- Templates are constructs which are akin to schematics but which
-- record the metadata and inventories of certain types of nodes and
-- differ in the axis around which templates are rotated.
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Template decoding.
------------------------------------------------------------------------

local ipairs = ipairs
local mathmax = math.max
local mathmin = math.min
local floor = math.floor
local rshift = bit.rshift
local lshift = bit.lshift
local band = bit.band
local decode_node = mcl_levelgen.decode_node
local encode_node = mcl_levelgen.encode_node
local STRUCTURE_VOID = 0x100000000
local insert = table.insert
local indexof = table.indexof

local function extract_idx (template, idx)
	local idx = idx - 1
	return floor (idx / (template.height * template.length)) % template.width,
		floor (idx / (template.length)) % template.height,
		idx % template.length
end

local FACE_NORTH = mcl_levelgen.FACE_NORTH
local FACE_WEST = mcl_levelgen.FACE_WEST
local FACE_SOUTH = mcl_levelgen.FACE_SOUTH
local FACE_EAST = mcl_levelgen.FACE_EAST
local FACE_UP = mcl_levelgen.FACE_UP
local FACE_DOWN = mcl_levelgen.FACE_DOWN

local facedir_rotations = {
	[0] = "0", -- South
	"90", -- West
	"180", -- North
	"270", -- East
}

local function facedir_to_jigsaw_dir (param2)
	local facing = rshift (param2, 2)
	local rotation = band (param2, 3)

	if facing == 0 then
		return FACE_UP, facedir_rotations[rotation]
	elseif facing == 5 then
		rotation = band (4 - rotation, 3)
		return FACE_DOWN, facedir_rotations[rotation]
	else
		-- Rotation is not significant.
		if facing == 1 then
			return FACE_NORTH, "0"
		elseif facing == 2 then
			return FACE_SOUTH, "0"
		elseif facing == 3 then
			return FACE_EAST, "0"
		elseif facing == 4 then
			return FACE_WEST, "0"
		end
	end
	return nil, nil
end
mcl_levelgen.facedir_to_jigsaw_dir = facedir_to_jigsaw_dir

local cid_ignore = core.CONTENT_IGNORE
local cid_air = core.CONTENT_AIR

local function construct_unhash (value)
	local x = rshift (value, 20)
	local y = band (rshift (value, 10), 0x3ff)
	local z = band (value, 0x3ff)
	return x, y, z
end

function mcl_levelgen.read_structure_template (name)
	local f, err, _ = io.open (name, "rb")
	if err then
		return nil, "Opening " .. name .. ": " .. err
	end
	local data = f:read ("*a")
	f:close ()

	if not data then
		return nil, "Failed to read from file " .. name
	end
	local ok, data = pcall (core.decompress, data, "zstd")
	if not ok or not data then
		return nil, "Failed to decompress file "
			.. name .. ": " .. data
	end
	local _
	ok, data, _ = pcall (core.deserialize, data)
	if not ok or not data then
		return nil, "Template " .. name .. " is invalid"
	end

	-- Verify the structure template.
	if type (data) ~= "table"
		or type (data.nodes) ~= "table"
		or type (data.metadata) ~= "table"
		or type (data.names) ~= "table"
		or type (data.nodes_to_construct) ~= "table"
		or type (data.jigsaws) ~= "table"
		or type (data.width) ~= "number"
		or type (data.height) ~= "number"
		or type (data.length) ~= "number"
		or data.width <= 0
		or data.height <= 0
		or data.length <= 0 then
		return nil, "Template is invalid"
	end

	local data_sz = data.width * data.height * data.length
	if #data.nodes ~= data_sz then
		return nil, "Template was truncated to "
			.. #data.nodes .. " elements (expected " .. data_sz .. ")"
	end

	for i = 1, data_sz do
		local node = data.nodes[i]
		local meta_id = rshift (node, 24)
		if meta_id ~= 0 then
			local meta = data.metadata[meta_id]
			if type (meta) ~= "table"
				or type (meta.inventory) ~= "table"
				or type (meta.fields) ~= "table" then
				return nil, "Invalid or nonexistent metadata table: "
					.. dump (meta)
			end

			for _, list in pairs (meta.inventory) do
				if type (list) ~= "table" then
					return "Invalid metadata inventory list: "
						.. dump (list)
				end
			end
		end
		local id, param2 = decode_node (node)
		if not data.names[id]
			or type (data.names[id]) ~= "string" then
			return nil, "ID not defined: " .. id
		end

		local name = data.names[id]
		if name ~= "mcl_levelgen:structure_void" then
			local ok, cid = pcall (core.get_content_id, name)
			if not ok then
				return nil, "Node not defined: " .. name
			end
			local new_node = lshift (meta_id, 24) + encode_node (cid, param2)
			data.nodes[i] = new_node
		else
			data.nodes[i] = STRUCTURE_VOID
		end
	end

	for i, item in ipairs (data.nodes_to_construct) do
		if type (item) ~= "number" or item ~= floor (item) then
			return nil, "Invalid element in node constructor list"
		end

		local dx, dy, dz = construct_unhash (item)
		if dx < 0 or dy < 0 or dz < 0
			or dx >= data.width or dy >= data.height or dz >= data.length then
			return nil, "Node constructor out of bounds: "
				.. string.format ("%d,%d,%d", dx, dy, dz)
		end

		data.nodes_to_construct[i]
			= ((dx * data.height) + dy) * data.length + dz + 1
	end

	local rpl_jigsaws = {}
	local jigsaw_meta = {}
	for i, item in ipairs (data.jigsaws) do
		if type (item) ~= "number" or item ~= floor (item) then
			return nil, "Invalid element in jigsaw block list"
		end

		if i > data_sz or i <= 0 then
			return nil, "Jigsaw block list index out of bounds"
		end

		local content = data.nodes[item]
		local meta_idx = rshift (content, 24)
		local dx, dy, dz = extract_idx (data, item)

		if meta_idx ~= 0 then
			if not data.metadata[meta_idx] then
				return nil, "Jigsaw block meta index out of bounds"
			end
			local _, param2 = decode_node (content)
			local facing, rotation
				= facedir_to_jigsaw_dir (param2)
			if not facing or not rotation then
				return nil, "param2 invalid in jigsaw block: " .. param2
			end
			local fields = data.metadata[meta_idx].fields
			if not fields then
				return nil, "Invalid jigsaw block meta"
			end
			local meta_str = fields["mcl_levelgen:structure_jigsaw_save_data"]
			if not meta_str then
				return nil, "Jigsaw save data absent"
			end
			local _, meta = pcall (core.deserialize, meta_str)
			if not meta then
				return nil, "Invalid jigsaw block meta"
			end
			if not meta.name or type (meta.name) ~= "string"
				or not meta.target_pool or type (meta.target_pool) ~= "string"
				or not meta.target_name or type (meta.target_name) ~= "string"
				or not meta.turns_into or type (meta.turns_into) ~= "string" then
				return nil, "Name, target pool, target name, or replacement block not defined in jigsaw meta"
			end
			if not meta.selection_priority
				or type (meta.selection_priority) ~= "number" then
				return nil, "Selection priority not defined in jigsaw meta"
			end
			if not meta.placement_priority
				or type (meta.placement_priority) ~= "number" then
				return nil, "Placement priority not defined in jigsaw meta"
			end

			insert (rpl_jigsaws, {
				dx = dx,
				dy = dy,
				dz = dz,
				metadata = meta,
				facing = facing,
				rotation = rotation,
			})
			local _, cid_replace_with
				= pcall (core.get_content_id, meta.turns_into)
			if not ok then
				core.log ("warning", ("[mcl_levelgen]: Jigsaw replacement block does not exist: "
						      .. meta.turns_into))
				cid_replace_with = cid_air
			end
			if cid_replace_with == cid_ignore then
				cid_replace_with = nil
			end
			jigsaw_meta[meta_idx] = {
				cid_replace_with = cid_replace_with,
			}
		end
	end
	data.jigsaws = rpl_jigsaws
	data.jigsaw_meta = jigsaw_meta

	if not data.data_blocks then
		data.data_block_data = {}
	else
		data.data_block_data = {}
		for i, item in ipairs (data.data_blocks) do
			if type (item) ~= "number" then
				return nil, "Data block index is not a number"
			end

			local content = data.nodes[item]
			local meta_idx = rshift (content, 24)

			if meta_idx == 0 or not data.metadata[meta_idx] then
				return nil, "Data block has no metadata"
			end

			local fields = data.metadata[meta_idx].fields
			if not fields then
				return nil, "Invalid data block meta"
			end
			local meta_str = fields["mcl_levelgen:structure_data_save_data"]
			if not meta_str then
				return nil, "Data block save data absent"
			end
			local _, meta = pcall (core.deserialize, meta_str)
			if not meta or type (meta) ~= "table"
				or type (meta.value) ~= "string"
				or type (meta.param1) ~= "string"
				or type (meta.param2) ~= "string" then
				return nil, "Invalid data block meta"
			end

			local x, y, z = extract_idx (data, item)
			data.data_block_data[i] = {
				x = x,
				y = y,
				z = z,
				idx = item,
				value = meta.value,
				param1 = meta.param1,
				param2 = meta.param2,
			}
		end
	end

	return data
end

------------------------------------------------------------------------
-- Template geometry.
------------------------------------------------------------------------

function mcl_levelgen.get_transformed_origin (px, py, pz, mirroring, rotation, width,
					      length)
	local sx = width - 1
	local sz = length - 1
	local xmax = mirroring == "front_back" and sx or 0
	local zmax = mirroring == "left_right" and sz or 0
	local x, y, z

	if rotation == "270" then
		x, y, z = zmax, 0, sx - xmax
	elseif rotation == "90" then
		x, y, z = sz - zmax, 0, xmax
	elseif rotation == "180" then
		x, y, z = sx - xmax, 0, sz - zmax
	elseif rotation == "0" then
		x, y, z = sx + xmax, 0, sz + zmax
	else
		assert (false)
	end

	return px + x, py + y, pz + z
end

function mcl_levelgen.template_transform (data, x, y, z, px, pz,
					  mirroring, rotation)
	if mirroring == "left_right" then
		z = -z
	elseif mirroring == "front_back" then
		x = -x
	end

	if rotation == "270" then
		return px - pz + z, y, px + pz - x
	elseif rotation == "90" then
		return px + pz - z, y, pz - px + x
	elseif rotation == "180" then
		return px + px - x, y, pz + pz - z
	else
		return x, y, z
	end
end

local template_transform = mcl_levelgen.template_transform

function mcl_levelgen.get_template_bounding_box (data, x, y, z, px, pz,
						 mirroring, rotation)
	local x1, y1, z1 = template_transform (data, 0, 0, 0, px, pz,
					       mirroring, rotation)
	local x2, y2, z2 = template_transform (data, data.width - 1,
					       data.height - 1,
					       data.length - 1,
					       px, pz, mirroring,
					       rotation)
	return mathmin (x1, x2) + x,
		mathmin (y1, y2) + y,
		mathmin (z1, z2) + z,
		mathmax (x1, x2) + x,
		mathmax (y1, y2) + y,
		mathmax (z1, z2) + z
end

------------------------------------------------------------------------
-- Template placement.
------------------------------------------------------------------------

local ipos1 = mcl_levelgen.ipos1
local get_template_bounding_box = mcl_levelgen.get_template_bounding_box

local function param2_identity (cid, param2)
	return param2
end

local mirror_param2_x = mcl_levelgen.mirror_param2_x
local mirror_param2_z = mcl_levelgen.mirror_param2_z
local rotate_param2 = mcl_levelgen.rotate_param2
local template_index = nil
local template_meta = nil
local template_suppressions = {}

function mcl_levelgen.current_template_index ()
	return template_index
end

local function apply_schematic_processors (processors, x, y, z, rng,
					   cid_current, param2_current,
					   cid, param2, idx)
	template_index = idx
	for _, processor in ipairs (processors) do
		cid, param2 = processor (x, y, z, rng, cid_current,
					 param2_current, cid, param2)
		if not cid then
			return nil, nil
		end
	end
	return cid, param2
end

function mcl_levelgen.get_current_template_meta ()
	return template_meta
end

function mcl_levelgen.set_current_template_meta (tbl, suppress_construction)
	template_meta = tbl
	if suppress_construction then
		insert (template_suppressions, template_index)
	end
end

local x_stride, y_stride, z_stride, i_start
local x1, y1, z1, x2, y2, z2
local template_mirroring

function mcl_levelgen.suppress_constructors (x, y, z)
	if x <= x2 and y <= y2 and z <= z2
		and x >= x1 and y >= y1 and z >= z1 then
		local dx, dz
		if template_mirroring == "left_right" then
			dx = x - x1
			dz = z2 - z
		elseif template_mirroring == "front_back" then
			dx = x2 - x
			dz = z - z1
		else
			dx = x - x1
			dz = z - z1
		end

		local dy = y - y1
		local index = dx * x_stride
			+ dy * y_stride
			+ dz * z_stride + i_start
		insert (template_suppressions, index)
	end
end

local warned = {}
local registered_data_block_processors = {}

local function call_data_block_processor (rng, data, mirroring, rotation, x, y, z, item)
	local value = item.value
	local fn = registered_data_block_processors[value]
	if fn then
		return fn (rng, data, mirroring, rotation, x, y, z, item)
	elseif not warned[value] then
		core.log ("warning", "[mcl_levelgen]: Processing data block of unknown type: " .. value)
		return nil, nil
	end
end

local cid_structure_block_data

if core.register_on_mods_loaded then
	core.register_on_mods_loaded (function ()
		if not mcl_levelgen.levelgen_enabled
			and not mcl_levelgen.enable_ersatz then
			return false
		end
		cid_structure_block_data
			= core.get_content_id ("mcl_levelgen:structure_block_data")
	end)
else
	cid_structure_block_data
		= core.get_content_id ("mcl_levelgen:structure_block_data")
end

function mcl_levelgen.place_template_internal (data, x, y, z, px, pz, options,
					       bounds, mirroring, rotation,
					       processors, rng, set_block, get_block)
	template_suppressions = {}

	local mirror_param2, iterator
	local initial_mirroring = mirroring
	x1, y1, z1, x2, y2, z2
		= get_template_bounding_box (data, x, y, z, px, pz,
					     mirroring, rotation)

	do
		local xstride = data.height * data.length
		local ystride = data.length
		local zstride = 1

		if mirroring == "left_right" then
			mirror_param2 = mirror_param2_z
		elseif mirroring == "front_back" then
			mirror_param2 = mirror_param2_x
		else
			mirror_param2 = param2_identity
		end

		if rotation == "0" then
			x_stride = xstride
			y_stride = ystride
			z_stride = zstride
			i_start = 1
		elseif rotation == "90" then
			-- X = -Z
			-- Z = X
			x_stride = -zstride
			y_stride = ystride
			z_stride = xstride
			i_start = 1 + zstride * (data.length - 1)

			if mirroring == "left_right" then
				mirroring = "front_back"
			elseif mirroring == "front_back" then
				mirroring = "left_right"
			end
		elseif rotation == "180" then
			-- X = -X
			-- Z = -Z
			x_stride = -xstride
			y_stride = ystride
			z_stride = -zstride
			i_start = 1 + zstride * (data.length - 1)
				+ xstride * (data.width - 1)
		elseif rotation == "270" then
			-- X = Z
			-- Z = -X
			x_stride = zstride
			y_stride = ystride
			z_stride = -xstride
			i_start = 1 + xstride * (data.width - 1)

			if mirroring == "left_right" then
				mirroring = "front_back"
			elseif mirroring == "front_back" then
				mirroring = "left_right"
			end
		end

		local ix1, iy1, iz1, ix2, iy2, iz2

		if bounds then
			ix1 = mathmax (x1, bounds[1])
			iy1 = mathmax (y1, bounds[2])
			iz1 = mathmax (z1, bounds[3])
			ix2 = mathmin (x2, bounds[4])
			iy2 = mathmin (y2, bounds[5])
			iz2 = mathmin (z2, bounds[6])
		else
			ix1, iy1, iz1, ix2, iy2, iz2
				= x1, y1, z1, x2, y2, z2
		end

		iterator = ipos1 (ix1, iy1, iz1, ix2, iy2, iz2)
	end

	template_mirroring = mirroring
	local data_replacements = {}
	do
		-- Execute actions specified by data blocks.
		for i, item in ipairs (data.data_block_data) do
			local dx, dy, dz
				= template_transform (data, item.x, item.y, item.z,
						      px, pz, initial_mirroring,
						      rotation)
			local cid, param2
				= call_data_block_processor (rng, data, initial_mirroring,
							     rotation,
							     x + dx, y + dy, z + dz, item)
			if cid then
				data_replacements[i] = encode_node (cid, param2)
			else
				data_replacements[i] = STRUCTURE_VOID
			end
		end
	end

	local nodes = data.nodes
	local metadata = data.metadata
	local jigsaw_meta = data.jigsaw_meta
	local n_processors = processors and #processors or 0
	local keep_jigsaws = options and options.keep_jigsaws

	for x, y, z in iterator do
		local dx, dz
		if mirroring == "left_right" then
			dx = x - x1
			dz = z2 - z
		elseif mirroring == "front_back" then
			dx = x2 - x
			dz = z - z1
		else
			dx = x - x1
			dz = z - z1
		end

		local dy = y - y1
		local index = dx * x_stride
			+ dy * y_stride
			+ dz * z_stride + i_start
		local node = nodes[index]
		do
			local cid, _ = decode_node (node)
			if cid == cid_structure_block_data then
				local i = indexof (data.data_blocks, index)
				if i ~= -1 then
					node = data_replacements[i]
				end
			end
		end
		if node ~= STRUCTURE_VOID then
			local cid, param2 = decode_node (node)
			local meta_idx = rshift (node, 24)
			template_meta = (meta_idx ~= 0
					 and indexof (template_suppressions, index) == -1)
				and metadata[meta_idx] or nil
			local jigsaw_meta = jigsaw_meta[meta_idx]

			if jigsaw_meta and not keep_jigsaws then
				cid = jigsaw_meta.cid_replace_with
				if cid ~= node then
					param2, template_meta = 0, nil
				end
			end

			if cid then
				param2 = mirror_param2 (cid, param2)
				param2 = rotate_param2 (cid, param2, rotation)

				if n_processors > 0 then
					local cid_current, param2_current = get_block (x, y, z)
					cid, param2
						= apply_schematic_processors (processors,
									      x, y, z, rng,
									      cid_current,
									      param2_current,
									      cid, param2,
									      index)
				end

				if cid then
					set_block (x, y, z, cid, param2, template_meta)
				end
			end
		end
	end

	template_meta = nil
	return template_suppressions
end

function mcl_levelgen.run_template_constructors (data, x, y, z, px, pz,
						 mirroring, rotation,
						 construct_block,
						 suppressions)
	if data.nodes_to_construct then
		for _, idx in ipairs (data.nodes_to_construct) do
			if not suppressions
				or indexof (suppressions, idx) == -1 then
				local dx, dy, dz = extract_idx (data, idx)
				local dx, dy, dz = template_transform (data, dx, dy, dz, px, pz,
								       mirroring, rotation)
				construct_block (dx + x, dy + y, dz + z)
			end
		end
	end
end

------------------------------------------------------------------------
-- Structure template pools.
------------------------------------------------------------------------

-- Template pools cannot be copied across environments and must be
-- individually registered in each environment.

local registered_template_pools = {}

-- local template_element = {
-- 	template = "file_name" or nil,
--	N.B.: "terrain_matching" is not yet implemented.
-- 	projection = "rigid" or "terrain_matching",
--	processors = {},
--	ground_level_delta = 1 or nil,
-- 	weight = 1,
--	no_terrain_adaptation = false,
-- }

-- local template_pool = {
-- 	total_weight = 0,
--	fallback_pool = "" or nil,
-- 	elements = {},
-- }

function mcl_levelgen.register_template_pool (id, data)
	if not mcl_levelgen.levelgen_enabled
		and not mcl_levelgen.enable_ersatz
	-- XXX: this case would better be provided for by moving the
	-- definition of mcl_levelgen:empty elsewhere...
		and id ~= "mcl_levelgen:empty" then
		return
	end

	if registered_template_pools[id] then
		error ("Template pool " .. id .. " is already registered")
	end

	assert (type (data.elements) == "table")
	assert (not data.fallback_pool
		or type (data.fallback_pool) == "string")

	local new_data = {
		total_weight = 0,
		must_complete = data.must_complete,
		elements = {},
	}

	for _, element in ipairs (data.elements) do
		new_data.total_weight
			= new_data.total_weight + element.weight
		local template, instance

		if mcl_levelgen.is_levelgen_environment then
			local err
			template, err
				= mcl_levelgen.read_structure_template (element.template)
			if not template then
				error ("Failed to read structure template"
				       .. element.template .. ": " .. err)
			end
		else
			template = element.template
			core.register_on_mods_loaded (function ()
				local template, err
					= mcl_levelgen.read_structure_template (element.template)
				if not template then
					error ("Failed to read structure template"
					       .. element.template .. ": " .. err)
				end
				instance.template = template
			end)
		end
		assert (type (element.projection or "rigid") == "string")
		assert (type (element.processors) == "table")
		assert (type (element.ground_level_delta or 1) == "number")
		instance = {
			template = template,
			projection = element.projection or "rigid",
			processors = element.processors,
			ground_level_delta = element.ground_level_delta or 1,
			weight = element.weight,
			no_terrain_adaptation = element.no_terrain_adaptation,
		}
		table.insert (new_data.elements, instance)
	end
	registered_template_pools[id] = new_data
end

local warned = {}

local function random_template_element (pool, rng)
	local tbl = registered_template_pools[pool]
	if not tbl then
		if not warned[pool] then
			warned[pool] = true
			core.log ("error", "[mcl_levelgen]: Template pool " .. pool .. " does not exist")
		end
		return nil
	end

	if tbl.total_weight == 0 then
		return nil, tbl.must_complete
	else
		local weight = rng:next_within (tbl.total_weight)
		for _, element in ipairs (tbl.elements) do
			weight = weight - element.weight
			if weight < 0 then
				return element
			end
		end
		return nil, tbl.must_complete
	end
end

------------------------------------------------------------------------
-- Jigsaw placement.
------------------------------------------------------------------------

local function get_jigsaw (element, name)
	local template = element.template
	for _, jigsaw in ipairs (template.jigsaws) do
		if jigsaw.metadata.name == name then
			return jigsaw
		end
	end
	return nil
end

local random_schematic_rotation = mcl_levelgen.random_schematic_rotation
local bbox_center = mcl_levelgen.bbox_center
local fit_children

local function all_pieces_complete_p (plist)
	for _, piece in ipairs (plist) do
		assert (piece.must_complete)
		if piece.jigsaws_satisfied < piece.jigsaws_required then
			return false
		end
	end
	return true
end

local function piece_retain_p (piece)
	local plist = piece.parents_liable_to_removal
	local must_complete = piece.must_complete
	if not plist and not must_complete then
		return true
	else
		assert (piece.jigsaws_satisfied <= piece.jigsaws_required)
		if not must_complete
			or (piece.jigsaws_satisfied == piece.jigsaws_required) then
			return not plist
				or all_pieces_complete_p (plist)
		end
		return false
	end
end

local huge = math.huge

function mcl_levelgen.generate_jigsaw (rng, x, y, z, rotation, start_pool,
				       start_name, max_radius, max_depth,
				       create_piece, test_spawn_position,
				       project_start, arg1, arg2, arg3,
				       level_min, level_height)
	local pieces = {}
	local rotation = rotation or random_schematic_rotation (rng)
	local start = random_template_element (start_pool, rng)

	if not start or not start.template then
		return {}
	else
		local start_jigsaw = nil

		if start_name then
			start_jigsaw = get_jigsaw (start, start_name)
			if not start_jigsaw then
				core.log ("error", table.concat ({
					"[mcl_levelgen] Starting jigsaw ",
					tostring (start_name),
					" not present in template pool ",
					tostring (start_pool),
				}))
				return {}
			end
		end
		local sx, sy, sz = x, y, z
		if start_jigsaw then
			local jx, jy, jz
				= template_transform (start.template,
						      start_jigsaw.dx,
						      start_jigsaw.dy,
						      start_jigsaw.dz,
						      0, 0, nil, rotation)
			sx = sx - jx
			sy = sy - jy
			sz = sz - jz
		end

		local ground_level_delta = start.ground_level_delta
		local bbox
		do
			local x1, y1, z1, x2, y2, z2
				= get_template_bounding_box (start.template, sx, sy, sz,
							     0, 0, nil, rotation)
			bbox = {
				x1, y1, z1,
				x2, y2, z2,
			}
		end

		local x_center, _, z_center = bbox_center (bbox)
		if project_start then
			local projection = project_start (x_center, z_center, arg1, arg2, arg3)
			sy = sy + projection - ground_level_delta
			bbox[2] = bbox[2] + projection - ground_level_delta
			bbox[5] = bbox[5] + projection - ground_level_delta
		end
		if test_spawn_position then
			local x, _, z = bbox_center (bbox)
			if not test_spawn_position (x, sy, z,
						    sx, sy, sz, arg1,
						    arg2, arg3) then
				return {}
			end
		end
		local bbox_max = {
			x_center - max_radius,
			bbox[2] - max_radius,
			z_center - max_radius,
			x_center + max_radius,
			bbox[2] + max_radius,
			z_center + max_radius,
		}
		if level_min and level_height then
			bbox_max[2] = mathmax (bbox_max[2], level_min)
			bbox_max[5] = mathmin (bbox_max[5], level_min + level_height - 1)
			if bbox_max[2] > bbox_max[5] then
				return {}
			end
		end
		local piece = create_piece (start, rotation, rng,
					    sx, sy, sz, bbox)
		insert (pieces, piece)

		-- Non-Minecraft extension: if must_complete is
		-- enabled for pool, pieces generated from the said
		-- pool are to be removed if any jigsaws in the said
		-- pieces' children not themselves marked with
		-- `must_complete' fail to generate.
		piece.must_complete = start_pool.must_complete
		piece.jigsaws_required = huge
		piece.jigsaws_satisfied = 0

		fit_children (pieces, start, rng, bbox_max, max_depth,
			      create_piece)
		local i1 = 1
		for i = 1, #pieces do
			local piece = pieces[i]
			if piece_retain_p (piece) then
				pieces[i1] = piece
				i1 = i1 + 1
			end
		end
		for i = i1, #pieces do
			pieces[i] = nil
		end
		return pieces
	end
end

local region_init_from_aabb = mcl_util.region_init_from_aabb

local function shape_from_aabb_inclusive (bbox)
	local x, y, z = bbox[4], bbox[5], bbox[6]
	bbox[4] = bbox[4] + 1.0
	bbox[5] = bbox[5] + 1.0
	bbox[6] = bbox[6] + 1.0
	local shape = region_init_from_aabb (bbox)
	bbox[4], bbox[5], bbox[6] = x, y, z
	return shape
end

local function queue_next (queue)
	local priority = queue.top_priority

	if priority == 0 then
		return nil
	else
		local items = queue.arrays[priority]
		while not items or #items == 0 do
			priority = priority - 1
			items = queue.arrays[priority]
			if priority == 0 then
				queue.top_priority = priority
				return nil
			end
		end
		queue.top_priority = priority
		local n = #items
		local item = items[n]
		items[n] = nil
		return item
	end
end

local function queue_insert (queue, priority_in, elem)
	local priority = priority_in + 1
	local array = queue.arrays[priority]
	if not array then
		array = {}
		queue.arrays[priority] = array
	end
	insert (array, elem)
	queue.top_priority
		= mathmax (queue.top_priority, priority)
end

local fisher_yates = mcl_levelgen.fisher_yates
local stable_sort = table.stable_sort

local function compare_selection_priority (a, b)
	return a.metadata.selection_priority > b.metadata.selection_priority
end

local function jigsaw_blocks_shuffled (rng, element, ignore)
	local template = element.template
	local jigsaws = {}
	for _, jigsaw in ipairs (template.jigsaws) do
		if jigsaw ~= ignore then
			insert (jigsaws, jigsaw)
		end
	end
	fisher_yates (jigsaws, rng)
	stable_sort (jigsaws, compare_selection_priority)
	return jigsaws
end

local face_directions = mcl_levelgen.face_directions

local function compose_facing (facing, rot)
	if rot ~= "0" then
		if facing == FACE_NORTH then
			if rot == "90" then
				return FACE_EAST
			elseif rot == "180" then
				return FACE_SOUTH
			elseif rot == "270" then
				return FACE_WEST
			else
				return facing
			end
		elseif facing == FACE_EAST then
			if rot == "90" then
				return FACE_SOUTH
			elseif rot == "180" then
				return FACE_WEST
			elseif rot == "270" then
				return FACE_NORTH
			else
				return facing
			end
		elseif facing == FACE_SOUTH then
			if rot == "90" then
				return FACE_WEST
			elseif rot == "180" then
				return FACE_NORTH
			elseif rot == "270" then
				return FACE_EAST
			else
				return facing
			end
		elseif facing == FACE_WEST then
			if rot == "90" then
				return FACE_NORTH
			elseif rot == "180" then
				return FACE_EAST
			elseif rot == "270" then
				return FACE_SOUTH
			else
				return facing
			end
		end
	end

	return facing
end

local function bbox_contains_p (bbox, x, y, z)
	return x >= bbox[1] and y >= bbox[2] and z >= bbox[3]
		and x <= bbox[4]
		and y <= bbox[5]
		and z <= bbox[6]
end

local function build_shuffled_element_list (rng, target_pool)
	local pool = registered_template_pools[target_pool]
	if not pool then
		if not warned[target_pool] then
			warned[target_pool] = true
			core.log ("error", table.concat ({
				"[mcl_levelgen]: Template pool ",
				pool,
				" nonexistent",
			}))
		end
		return nil
	end
	local fallback_pool = registered_template_pools[pool.fallback]
	local array_default = {}
	for _, elem in ipairs (pool.elements) do
		for i = 1, elem.weight do
			insert (array_default, elem)
		end
	end
	fisher_yates (array_default, rng)
	if fallback_pool then
		local array_fallback = {}
		for _, elem in ipairs (fallback_pool.elements) do
			for i = 1, elem.weight do
				insert (array_fallback, elem)
			end
		end
		fisher_yates (array_fallback, rng)
		local n = #array_default
		for i = 1, #array_fallback do
			array_default[n + i] = array_fallback[i]
		end
	end
	return array_default, pool.must_complete
end

local compositions = {
	["0"] = {
		["0"] = "0",
		["90"] = "90",
		["180"] = "180",
		["270"] = "270",
	},
	["90"] = {
		["0"] = "90",
		["90"] = "180",
		["180"] = "270",
		["270"] = "0",
	},
	["180"] = {
		["0"] = "180",
		["90"] = "270",
		["180"] = "0",
		["270"] = "90",
	},
	["270"] = {
		["0"] = "270",
		["90"] = "0",
		["180"] = "90",
		["270"] = "180",
	},
}

local function compose_rotation (a, b)
	return compositions[a][b]
end

local face_opposites = mcl_levelgen.face_opposites

local function jigsaws_compatible_p (jigsaw, rotation, facing,
				     parent_rotation)
	local jigsaw_facing
		= compose_facing (jigsaw.facing, rotation)
	local rollable = jigsaw.facing < FACE_UP
		or jigsaw.metadata.joint_type == 2
	return facing == face_opposites[jigsaw_facing]
		and (rollable
		     or (compose_rotation (rotation, jigsaw.rotation)
			 == parent_rotation))
end

local function target_bbox (elem, x, y, z, rotation)
	local x1, y1, z1, x2, y2, z2
		= get_template_bounding_box (elem.template, x, y, z,
					     0, 0, nil, rotation)
	return {
		x1, y1, z1,
		x2, y2, z2,
	}
end

local function unpack3 (x)
	return x[1], x[2], x[3]
end

local OP_SUB = mcl_util.OP_SUB

local function fit_one_child (pieces, rng, item, queue, create_piece)
	local parent = item.parent
	local rotation = parent.rotation
	local element = parent.element
	local local_shape = {
		shape_from_aabb_inclusive (parent.bbox),
	}

	local jigsaws = jigsaw_blocks_shuffled (rng, element,
						item.parent_jigsaw)
	parent.jigsaws_required = #jigsaws

	-- Update the number of jigsaws in the parent that have been
	-- exhausted, and so forth, till the toplevel piece, or a
	-- piece labeled `must_complete', is encountered.

	if #jigsaws == 0 or parent.must_complete then
		local parent = parent.parent

		while parent do
			local t = parent.jigsaws_satisfied
			parent.jigsaws_satisfied = t + 1
			if t + 1 < parent.jigsaws_required then
				break
			end

			if parent.must_complete then
				break
			end
			parent = parent.parent
		end
	end

	-- print ("jigsaws: ", dump (jigsaws))
	local rotations = {
		"0",
		"90",
		"180",
		"270",
	}
	for _, jigsaw in ipairs (jigsaws) do
		local facing = compose_facing (jigsaw.facing, rotation)
		local parent_rotation
			= compose_rotation (jigsaw.rotation, rotation)
		local dx, dy, dz = unpack3 (face_directions[facing])
		local x, y, z = template_transform (element.template,
						    jigsaw.dx, jigsaw.dy,
						    jigsaw.dz,
						    0, 0, nil, rotation)

		-- Position of source jigsaw block.
		x = x + parent.x
		y = y + parent.y
		z = z + parent.z

		-- Position of target jigsaw block.
		local x_target, y_target, z_target
			= x + dx, y + dy, z + dz

		-- Decide to which allocation to confine any generated
		-- structure.  If the target jigsaw block is within
		-- the parent, it need not be impacted by the presence
		-- of structures placed beyond its confines.

		local effective_shape_ref = local_shape
		if not bbox_contains_p (parent.bbox, x_target,
					y_target, z_target) then
			effective_shape_ref = item.available
		-- 	print ("Allocation: parent")
		-- else
		-- 	print ("Allocation: local")
		end

		-- Locate and fit a matching jigsaw block in the
		-- target pool.
		local target_pool = jigsaw.metadata.target_pool
		local target_name = jigsaw.metadata.target_name
		local elements, must_complete
			= build_shuffled_element_list (rng, target_pool)
		fisher_yates (rotations, rng)
		-- print ("Elements available: " .. #elements, target_pool)
		if elements then
			for _, elem in ipairs (elements) do
				if not elem.template then
					-- print ("  <-- Terminated")
					break
				end

				for _, rotation in ipairs (rotations) do
					local jigsaws
						= jigsaw_blocks_shuffled (rng, elem, nil)

					for _, target in ipairs (jigsaws) do
						-- print (target.metadata.name, target_name)
						if target.metadata.name == target_name
							and jigsaws_compatible_p (target,
										  rotation,
										  facing,
										  parent_rotation) then
							-- print ("  <-- Jigsaws compatible")

							local jigsaw_x, jigsaw_y, jigsaw_z
								= template_transform (elem.template,
										      target.dx,
										      target.dy,
										      target.dz,
										      0, 0, nil,
										      rotation)
							local target_bbox
								= target_bbox (elem,
									       x_target - jigsaw_x,
									       y_target - jigsaw_y,
									       z_target - jigsaw_z,
									       rotation)

							-- TODO: rigid/terrain_matching distinction.
							local shape = effective_shape_ref[1]
							local target_shape = shape_from_aabb_inclusive (target_bbox)
							if shape:contains_p (target_shape) then
								-- print ("  <-- Target accessible")
								local shape_1 = shape:op (target_shape, OP_SUB)
								if not shape_1 then
									return false
								end

								effective_shape_ref[1] = shape_1
								local piece = create_piece (elem, rotation, rng,
											    x_target - jigsaw_x,
											    y_target - jigsaw_y,
											    z_target - jigsaw_z,
											    target_bbox)
								insert (pieces, piece)
								piece.parent = parent
								piece.must_complete = must_complete
								piece.jigsaws_satisfied = 0
								-- If piece is never provided to fit_one_child,
								-- it's a fair assumption that its jigsaws will
								-- never be satisfied.
								piece.jigsaws_required = huge

								do
									-- Maintain a record of parents which
									-- are qualified `must_complete'.
									local plist = parent.parents_liable_to_removal
									local must_complete = parent.must_complete
									if plist and must_complete then
										local list = {}
										for i = 1, #plist do
											list[i] = plist[i]
										end
										insert (list, parent)
										piece.parents_liable_to_removal = list
									elseif plist then
										piece.parents_liable_to_removal = plist
									elseif must_complete then
										piece.parents_liable_to_removal = {
											parent,
										}
									end
								end

								local priority = jigsaw.metadata.placement_priority
								if item.cur_depth + 1 < item.max_depth then
									queue_insert (queue, priority, {
										cur_depth = item.cur_depth + 1,
										max_depth = item.max_depth,
										available = effective_shape_ref,
										parent = piece,
										parent_jigsaw = target,
									})
								end
							end
						end
					end
				end
			end
		end
	end

	return true
end

function fit_children (pieces, start, rng, bbox_max, max_depth, create_piece)
	local max = region_init_from_aabb (bbox_max)
	local available = max:subtract (pieces[1].bbox)
	assert (available)

	local toplevel = {
		cur_depth = 0,
		max_depth = max_depth,
		available = {available,},
		parent = pieces[1],
	}
	local queue = {
		arrays = {},
		top_priority = 0,
	}
	local rc = fit_one_child (pieces, rng, toplevel, queue, create_piece)
	if not rc then
		return
	end

	local item = queue_next (queue)
	while item do
		local rc = fit_one_child (pieces, rng, item, queue, create_piece)
		if not rc then
			return -- Cuboid region size exceeded.
		end
		item = queue_next (queue)
	end
end

mcl_levelgen.register_template_pool ("mcl_levelgen:empty", {
	elements = {},
})

mcl_levelgen.init_structures_after_templates ()

------------------------------------------------------------------------
-- Data Block processors.
------------------------------------------------------------------------

function mcl_levelgen.register_data_block_processor (id, processor)
	registered_data_block_processors[id] = processor
end
