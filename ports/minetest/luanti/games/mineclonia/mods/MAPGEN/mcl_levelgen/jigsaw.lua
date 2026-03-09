local S = core.get_translator (core.get_current_modname ())

local huge = math.huge
local mathmin = math.min
local mathmax = math.max
local floor = math.floor
local ipairs = ipairs

------------------------------------------------------------------------
-- Structure Block.
------------------------------------------------------------------------

-- Outline entity.

local active_outline_entities = {}

core.register_entity ("mcl_levelgen:structure_outline", {
	initial_properties = {
		visual = "cube",
		-- Attribution: schemedit_border_checkers.png in
		-- schemedit.
		textures = {
			"mcl_levelgen_schematic_border_checkers.png",
			"mcl_levelgen_schematic_border_checkers.png",
			"mcl_levelgen_schematic_border_checkers.png",
			"mcl_levelgen_schematic_border_checkers.png",
			"mcl_levelgen_schematic_border_checkers.png",
			"mcl_levelgen_schematic_border_checkers.png",
		},
		visual_size = {x = 10, y = 10,},
		pointable = false,
		physical = false,
		static_save = false,
		glow = core.LIGHT_MAX,
		use_texture_alpha = true,
		backface_culling = false,
	},
	on_step = function (self, dtime)
		local hash = self.initial_pos
		if not hash or active_outline_entities[hash] ~= self then
			self.initial_pos = nil
			self.object:remove ()
		end

		local node = core.get_node (core.get_position_from_hash (hash))
		if node.name ~= "mcl_levelgen:structure_block_load"
			and node.name ~= "mcl_levelgen:structure_block_save" then
			self.initial_pos = nil
			self.object:remove ()
		end
	end,
	on_deactivate = function (self, removal)
		if active_outline_entities[self.initial_pos] == self then
			active_outline_entities[self.initial_pos] = nil
		end
	end,
	on_activate = function (self)
		self.object:set_armor_groups ({immortal = 1,})
	end,
})

local symbolic_to_mirroring = {
	["|"] = nil,
	["^ v"] = "front_back",
	["< >"] = "left_right",
}

local function template_bbox (data, x, y, z)
	if data.sx then
		local z2 = -data.dz
		local z1 = -data.dz - data.sz + 1
		return data.dx + x, data.dy + y, z1 + z,
			data.dx + x + data.sx - 1,
			data.dy + y + data.sy - 1, z2 + z
	else
		assert (data.loaded_template)
		z = -z - 1
		local x1, y1, z1, x2, y2, z2
			= mcl_levelgen.get_template_bounding_box (data.loaded_template,
								  x + data.dx, y + data.dy,
								  z + data.dz, 0, 0,
								  symbolic_to_mirroring[data.mirroring],
								  data.rotation)
		return x1, y1, -z2 - 1, x2, y2, -z1 - 1
	end
end

local function hide_outline_entity (pos)
	local hash = core.hash_node_position (pos)
	if active_outline_entities[hash] then
		active_outline_entities[hash].object:remove ()
		active_outline_entities[hash] = nil
	end
end

local function display_outline_entity (pos, data)
	if data.sx and (data.sx <= 0 or data.sy <= 0 or data.sz <= 0)
		or (not data.sx and not data.loaded_template) then
		hide_outline_entity (pos)
		return false
	end

	local object
	local hash = core.hash_node_position (pos)

	if active_outline_entities[hash] then
		local entity = active_outline_entities[hash]
		object = entity.object
	else
		object = core.add_entity (vector.zero (),
					  "mcl_levelgen:structure_outline")
		if object then
			local entity = object:get_luaentity ()
			active_outline_entities[hash] = entity
			entity.initial_pos = hash
		else
			return
		end
	end


	local x1, y1, z1, x2, y2, z2
		= template_bbox (data, pos.x, pos.y, pos.z)
	local pos = vector.new ((x1 + x2) / 2, (y1 + y2) / 2, (z1 + z2) / 2)
	object:set_pos (pos)
	object:set_properties ({
		visual_size = {
			x = (x2 - x1 + 1 + 0.01),
			y = (y2 - y1 + 1 + 0.01),
			z = (z2 - z1 + 1 + 0.01),
		},
	})
end

core.register_lbm ({
	label = "Recreate structure block outline entities",
	name = "mcl_levelgen:recreate_structure_block_outlines",
	nodenames = {
		"mcl_levelgen:structure_block_load",
		"mcl_levelgen:structure_block_save",
	},
	run_at_every_load = true,
	action = function (pos, node)
		local meta = core.get_meta (pos)
		local data = node.name == "mcl_levelgen:structure_block_save"
			and mcl_levelgen.save_save_data (meta)
			or mcl_levelgen.load_save_data (meta)
		if data.toggle_display_bounds then
			display_outline_entity (pos, data)
		end
	end,
})

-- Structure Void block.

core.register_node ("mcl_levelgen:structure_void", {
	description = S ("Structure Void"),
	_tt_help = S ("Enables structures not to replace existing level contents"),
	_doc_items_usagehelp = S ([[The presence of a structure void block in a structure template indicates to the level generator that the contents of the level at the position it occupies mustn't be replaced while the template is being generated.

Structure Void nodes are normally invisible unless a Structure Void item is wielded, in which event any Structure Void blocks near the wielder will be revealed by particles containing its item image.]]),
	drawtype = "airlike",
	inventory_image = "mcl_levelgen_structure_void.png",
	wield_image = "mcl_levelgen_structure_void.png",
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	light_propagates = true,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
})

-- Structure blocks.

local load_formspec = [[
formspec_version[6]
size[11.75,5.45]
position[0.5,0.5]
field[0.5,1.0;10.75,0.5;structure_name;Structure Name;%s]
field[0.5,2.0;2.75,0.5;relative_position_x;Relative Position;%d]
field[3.25,2.0;2.75,0.5;relative_position_y;;%d]
field[6.0,2.0;2.75,0.5;relative_position_z;;%d]
label[8.75,1.87;Show Bounding Box]
button[8.75,2.0;2.5,0.5;toggle_display_bounds;%s]
field[0.5,3.0;2.75,0.5;structure_integrity;Structure Integrity and Seed;%f]
field[3.25,3.0;2.75,0.5;structure_seed;;%s]
label[0.5,4.5;Load Mode - Load from File]
button[0.5,4.65;1.0,0.5;load_mode_toggle;Load]
button[1.5,4.65;0.5,0.5;load_rot_0;%s]
button[2.0,4.65;0.5,0.5;load_rot_90;%s]
button[2.5,4.65;0.5,0.5;load_mirroring;%s]
button[3.0,4.65;0.5,0.5;load_rot_180;%s]
button[3.5,4.65;0.5,0.5;load_rot_270;%s]
button[10.15,4.65;1.0,0.5;load_execute;LOAD]
field_close_on_enter[structure_name;false]
field_close_on_enter[relative_position_x;false]
field_close_on_enter[relative_position_y;false]
field_close_on_enter[relative_position_z;false]
field_close_on_enter[structure_integrity;false]
field_close_on_enter[structure_seed;false]
]]

local save_formspec = [[
formspec_version[6]
size[11.75,5.45]
position[0.5,0.5]
field[0.5,1.0;10.75,0.5;structure_name;Structure Name;%s]
field[0.5,2.0;2.75,0.5;relative_position_x;Relative Position;%d]
field[3.25,2.0;2.75,0.5;relative_position_y;;%d]
field[6.0,2.0;2.75,0.5;relative_position_z;;%d]
label[8.75,1.87;Show Bounding Box]
button[8.75,2.0;2.5,0.5;toggle_display_bounds;%s]
field[0.5,3.0;2.75,0.5;structure_size_x;Structure Size;%d]
field[3.25,3.0;2.75,0.5;structure_size_y;;%d]
field[6.0,3.0;2.75,0.5;structure_size_z;;%d]
label[7.85,2.87;Detect Structure Size and Position]
button[8.75,3.0;2.5,0.5;detect_structure_size;DETECT]
label[0.5,4.5;Save Mode - Write to File]
button[0.5,4.65;1.0,0.5;save_mode_toggle;Save]
button[10.15,4.65;1.0,0.5;save_execute;SAVE]
field_close_on_enter[structure_name;false]
field_close_on_enter[relative_position_x;false]
field_close_on_enter[relative_position_y;false]
field_close_on_enter[relative_position_z;false]
field_close_on_enter[structure_size_x;false]
field_close_on_enter[structure_size_y;false]
field_close_on_enter[structure_size_z;false]
]]

local corner_formspec = [[
formspec_version[6]
size[11.75,5.45]
position[0.5,0.5]
field[0.5,1.0;10.75,0.5;structure_name;Structure Name;%s]
label[0.5,4.5;Corner Mode - Placement and Size Marker]
button[0.5,4.65;1.0,0.5;corner_mode_toggle;Corner]
field_close_on_enter[structure_name;false]
]]

local data_formspec = [[
formspec_version[6]
size[11.75,5.45]
position[0.5,0.5]
field[0.5,1.0;10.75,0.5;value;Data Tag Value;%s]
field[0.5,2.0;10.75,0.5;param1;Data Tag Parameter 1;%s]
field[0.5,3.0;10.75,0.5;param2;Data Tag Parameter 2;%s]
label[0.5,4.5;Data Mode - Game Logic Marker]
button[0.5,4.65;1.0,0.5;data_mode_toggle;Data]
field_close_on_enter[value;false]
field_close_on_enter[param1;false]
field_close_on_enter[param2;false]
]]

local structure_block = {
	description = S ("Structure Block"),
	_tt_help = S ("Saves, generates, or records structure data"),
	_doc_items_usagehelp = S ([[A structure block is an administrative and programmer block which enables existing constructs in a map to be recorded for subsequent reuse by generated structures, and records thereof to be recreated at other positions in various maps.  Structure blocks alternate between several modes of operation, each with a unique formspec that reflects its purpose, and which can be cycled through by a button on the bottom-left corner of each formspec, to wit:

- Load Mode:

  Preview or load a structure identified in the Structure Name field of the formspec as prescribed by the Relative Position, Rotation, and Mirroring options provided in the formspec.  The first invocation of "LOAD" will load and display an outline of the template's destination position and extents with all aforementioned options applied, and subsequent invocations will load the template into the map within those extents.

- Save Mode:

  Record a portion of the map whose extents are specified by the Relative Position and Structure Size fields of the formspec into a structure template identified by the said formspec's Structure Name field and stored as a file with the extension `.dat' within a `templates' subdirectory of the world save directory.

  Optionally, the Relative Position and Structure Size fields may be derived from two or more Structure Corner blocks with identical Structure Name fields placed around the corners or extents of a construct to be recorded, and selecting "Detect Structure Size and Position".

- Corner Mode:

  Mark the extents of a portion of the map to be recorded by another structure block in Save mode with an identical value in its Structure Name field within an 80x80x80 region of this structure block.

  The extents occupied by all matching corners within distance are interpreted as the extents of such a region outset by a single node; a minimum of two such corners is required to establish a structure's position and dimensions.

All coordinates and/or offsets are expected to be stated in Minecraft's coordinate system, which principally differs from Luanti's in the inversion of the Z axis.  When a recorded or loaded, certain blocks and their metadata carry a special significance and are not always reproduced faithfully from a structure template's data.  These include Structure Void blocks, Jigsaw Blocks (only when loaded during jigsaw block expansion), and any structure blocks in an internal Data Mode.]]),
	groups = {
		creative_breakable = 1,
		unmovable_by_piston = 1,
		structure_block = 1,
		rarity = 3,
	},
	drop = "",
	is_ground_content = false,
	_mcl_blast_resistance = 3600000,
	_mcl_hardness = -1,
}

-- local formspec_data = {
-- 	pos = vector.new (x, y, z),
-- 	node_type = "load" -- or "save", "corner".
-- }

local player_formspec_data = {}

core.register_on_leaveplayer (function (player)
	player_formspec_data[player] = nil
end)

local function display_formspec (pos, player, kind, processor, no_create)
	if not no_create then
		player_formspec_data[player] = {
			pos = pos,
			node_type = kind,
		}
	end
	core.show_formspec (player:get_player_name (),
			    "mcl_levelgen:structure_" .. kind .. "_formspec",
			    processor (pos, player))
end

-- Load structure block.

local ull = mcl_levelgen.ull
local tostringull = mcl_levelgen.tostringull
local stringtoull = mcl_levelgen.stringtoull

local function load_save_data (meta)
	local data = meta:get_string ("mcl_levelgen:structure_load_save_data")
	local meta
	if data ~= "" then
		meta = core.deserialize (data)
	else
		meta = {
			structure_name = "",
			rotation = "0",
			mirroring = "|", -- "< >" or "^ v"
			structure_integrity = 1.0,
			structure_seed = ull (0, 0),
			toggle_display_bounds = false,
			dx = 0,
			dy = 1,
			dz = 0,
		}
	end
	return meta
end
mcl_levelgen.load_save_data = load_save_data

local function load_formspec_processor (pos, _)
	local meta = core.get_meta (pos)
	local meta = load_save_data (meta)

	local rotation_0_depressed
		= meta.rotation == "0" and "[0]" or "0"
	local rotation_90_depressed
		= meta.rotation == "90" and "[90]" or "90"
	local rotation_180_depressed
		= meta.rotation == "180" and "[180]" or "180"
	local rotation_270_depressed
		= meta.rotation == "270" and "[270]" or "270"

	return string.format (load_formspec,
			      core.formspec_escape (meta.structure_name),
			      meta.dx,
			      meta.dy,
			      meta.dz,
			      meta.toggle_display_bounds and "ON" or "OFF",
			      meta.structure_integrity,
			      tostringull (meta.structure_seed),
			      rotation_0_depressed,
			      rotation_90_depressed,
			      meta.mirroring,
			      rotation_180_depressed,
			      rotation_270_depressed)
end

local function load_on_rightclick (pos, node, clicker, itemstack, pointed_thing)
	display_formspec (pos, clicker, "load", load_formspec_processor)
end

local worldpath = core.get_worldpath ()
local template_dir = worldpath .. "/templates/"
core.mkdir (template_dir)

local vm = nil
local area = nil
local place_template_internal = mcl_levelgen.place_template_internal
local run_template_constructors = mcl_levelgen.run_template_constructors
local cids, param2s = {}, {}
local v = vector.new ()

local function jigsaw_set_block (x, y, z, cid, param2, metadata)
	local idx = area:index (x, y, -z - 1)
	cids[idx] = cid
	param2s[idx] = param2

	if metadata then
		v.x, v.y, v.z = x, y, -z - 1
		local meta = core.get_meta (v)
		meta:from_table (metadata)
	end
end

local function jigsaw_get_block (x, y, z, cid, param2, metadata)
	local idx = area:index (x, y, -z - 1)
	return cids[idx], param2s[idx]
end

local function jigsaw_construct_block (x, y, z)
	v.x, v.y, v.z = x, y, -z - 1
	mcl_structures.init_node_construct (vector.copy (v))
end

local function execute_load (player, pos, data)
	if not data.structure_name then
		core.chat_send_player (player:get_player_name (),
				       S ("Template name is not specified"))
		return false
	end

	if not data.loaded_template then
		local name = template_dir .. data.structure_name .. ".dat"
		local template, err = mcl_levelgen.read_structure_template (name)
		if not template then
			core.chat_send_player (player:get_player_name (),
					       S ("Template `@1' is not available: @2",
						  data.structure_name, err))
			return false
		end
		data.loaded_template = template
		data.toggle_display_bounds = true
		return true
	else
		local mirroring
			= symbolic_to_mirroring[data.mirroring]
		local x1, y1, z1, x2, y2, z2
			= template_bbox (data, pos.x, pos.y, pos.z)
		local v1 = vector.new (x1, y1, z1)
		local v2 = vector.new (x2, y2, z2)
		vm = VoxelManip (v1, v2)
		vm:get_data (cids)
		vm:get_param2_data (param2s)
		area = VoxelArea (vm:get_emerged_area ())
		local rng = mcl_levelgen.xoroshiro_from_seed (data.structure_seed)
		local processors = {
			mcl_levelgen.block_rot_processor (data.structure_integrity, nil),
		}
		local keep_jigsaws = {
			keep_jigsaws = true,
		}
		local suppressions
			= place_template_internal (data.loaded_template,
						   pos.x + data.dx,
						   pos.y + data.dy,
						   -pos.z - 1 - data.dz,
						   0, 0, keep_jigsaws, nil,
						   mirroring, data.rotation,
						   processors,
						   rng, jigsaw_set_block,
						   jigsaw_get_block)
		vm:set_data (cids)
		vm:set_param2_data (param2s)
		vm:write_to_map (true)
		run_template_constructors (data.loaded_template,
					   pos.x + data.dx,
					   pos.y + data.dy,
					   -pos.z - 1 - data.dz,
					   0, 0, mirroring,
					   data.rotation,
					   jigsaw_construct_block,
					   suppressions)
		if vm.close then
			vm:close ()
		end
		vm = nil
	end

	return false
end

core.register_node ("mcl_levelgen:structure_block_load", table.merge (structure_block, {
	tiles = {
		"mcl_levelgen_structure_block_load_top.png",
		"mcl_levelgen_structure_block_load_top.png",
		"mcl_levelgen_structure_block_load_side.png",
		"mcl_levelgen_structure_block_load_side.png",
		"mcl_levelgen_structure_block_load_side.png",
		"mcl_levelgen_structure_block_load_side.png",
	},
	on_rightclick = load_on_rightclick,
}))

-- Save structure block.

local cids_with_meta
local cids_to_construct = {}

core.register_on_mods_loaded (function ()
	cids_with_meta = mcl_levelgen.construct_cid_list ({
		"group:structure_block",
		"group:jigsaw_block",
		"group:container",
		"group:sign",
		"mcl_itemframes:frame",
		"group:jigsaw_preserve_meta",
	})
	cids_to_construct = mcl_levelgen.construct_cid_list ({
		"group:container",
		"group:redstone_wire",
		"group:chest_entity",
		"group:sign",
		"mcl_itemframes:frame",
		"group:jigsaw_construct",
	})
end)

local encode_node = mcl_levelgen.encode_node
local indexof = table.indexof
local ipos3 = mcl_levelgen.ipos3
local lshift = bit.lshift

local function construct_hash (dx, dy, dz)
	assert (dx <= 1023 and dy <= 1023 and dz <= 1023)
	return lshift (dx, 20) + lshift (dy, 10) + dz
end

local cid_jigsaw_block
local cid_structure_block_data

local function execute_save (player, pos, tbl)
	if tbl.sx <= 0 or tbl.sy <= 0 or tbl.sz <= 0 then
		core.chat_send_player (player:get_player_name (),
				       S ("Invalid dimensions: @1,@2,@3",
					  tbl.sx, tbl.sy, tbl.sz))
		return
	end

	-- The format of a structure template is thus:
	--
	local nodes = {
		-- Array of packed cids and param2s in XYZ
		-- order and Minecraft's coordinate system (!).
		--
		-- The high 8 bits of an element yield, if any should
		-- be set, an index into the metadata array.
	}
	local metadata = {}
	local names = {}
	local nodes_to_construct = {}
	local jigsaws = {}
	local data_blocks = {}
	local structure_template = {
		nodes = nodes,
		metadata = metadata,
		nodes_to_construct = nodes_to_construct,
		names = names,
		jigsaws = jigsaws,
		width = tbl.sx,
		height = tbl.sy,
		length = tbl.sz,
		data_blocks = data_blocks,
	}
	local x1, y1, z1, x2, y2, z2
		= template_bbox (tbl, pos.x, pos.y, pos.z)
	local vm = VoxelManip (vector.new (x1, y1, z1),
			       vector.new (x2, y2, z2))
	local cids, param2s = {}, {}
	local area = VoxelArea (vm:get_emerged_area ())

	vm:get_data (cids)
	vm:get_param2_data (param2s)
	if vm.close then
		vm:close ()
	end

	local meta_id = 0
	local idx = 0
	for x, y, z in ipos3 (x1, y1, z1, x2, y2, z2) do
		idx = idx + 1
		local znew = z2 - (z - z1)
		local src = area:index (x, y, znew)
		local cid, param2 = cids[src], param2s[src]
		local encoded = encode_node (cid, param2)

		if indexof (cids_with_meta, cid) ~= -1 then
			if meta_id >= 255 then
				core.chat_send_player (player, S ("Metadata storage limit exceeded"))
				return
			end

			local meta = core.get_meta (vector.new (x, y, znew))
			meta_id = meta_id + 1
			encoded = encoded + lshift (meta_id, 24)
			local tbl = meta:to_table ()
			for _, list in pairs (tbl.inventory) do
				for i, stack in ipairs (list) do
					list[i] = stack:to_string ()
				end
			end
			metadata[meta_id] = tbl
		end
		nodes[idx] = encoded

		if cid == cid_jigsaw_block then
			table.insert (jigsaws, idx)
		elseif cid == cid_structure_block_data then
			table.insert (data_blocks, idx)
		end

		if indexof (cids_to_construct, cid) ~= -1 then
			local encoded = construct_hash (x - x1, y - y1, z - z1)
			table.insert (nodes_to_construct, encoded)
		end

		if not names[cid] then
			names[cid] = core.get_name_from_content_id (cid)
		end
	end
	local serialized = core.serialize (structure_template)
	local data = core.compress (serialized, "zstd")
	local name = tbl.structure_name .. ".dat"
	local file = template_dir .. name
	local f, err, _ = io.open (file, "wb")
	if not f then
		core.chat_send_player (player, S ("Creating file @1: @2", file, err))
		return
	end
	f:write (data)
	f:close ()
end

local function save_save_data (meta)
	local data = meta:get_string ("mcl_levelgen:structure_save_save_data")
	local meta
	if data ~= "" then
		meta = core.deserialize (data)
	else
		meta = {
			structure_name = "",
			dx = 0,
			dy = 1,
			dz = 0,
			toggle_display_bounds = false,
			sx = 0,
			sy = 0,
			sz = 0,
		}
	end
	return meta
end
mcl_levelgen.save_save_data = save_save_data

local function save_formspec_processor (pos, _)
	local meta = core.get_meta (pos)
	local meta = save_save_data (meta)
	return string.format (save_formspec,
			      core.formspec_escape (meta.structure_name),
			      meta.dx,
			      meta.dy,
			      meta.dz,
			      meta.toggle_display_bounds and "ON" or "OFF",
			      meta.sx,
			      meta.sy,
			      meta.sz)
end

local function save_on_rightclick (pos, node, clicker, itemstack, pointed_thing)
	display_formspec (pos, clicker, "save", save_formspec_processor)
end

local function detect_structure_extents (pos, structure_name)
	local pmin = vector.subtract (pos, 80, 80, 80)
	local pmax = vector.add (pos, 80, 80, 80)
	local corners = core.find_nodes_in_area (pmin, pmax,
						 "mcl_levelgen:structure_block_corner")
	local xmin, xmax, zmin, zmax, ymin, ymax
		= huge, -huge, huge, -huge, huge, -huge
	local set = false
	for _, pos in ipairs (corners) do
		local meta = core.get_meta (pos)
		local data = mcl_levelgen.corner_save_data (meta)
		if data.structure_name == structure_name then
			xmin = mathmin (xmin, pos.x)
			zmin = mathmin (zmin, pos.z)
			ymin = mathmin (ymin, pos.y)
			xmax = mathmax (xmax, pos.x)
			zmax = mathmax (zmax, pos.z)
			ymax = mathmax (ymax, pos.y)
			set = true
		end
	end
	if set and xmax - xmin > 1 and zmax - zmin > 1 and ymax - ymin > 1 then
		return xmin, ymin, -zmax - 1, xmax, ymax, -zmin - 1
	end
	return nil
end

core.register_node ("mcl_levelgen:structure_block_save", table.merge (structure_block, {
	tiles = {
		"mcl_levelgen_structure_block_save_top.png",
		"mcl_levelgen_structure_block_save_top.png",
		"mcl_levelgen_structure_block_save_side.png",
		"mcl_levelgen_structure_block_save_side.png",
		"mcl_levelgen_structure_block_save_side.png",
		"mcl_levelgen_structure_block_save_side.png",
	},
	groups = table.merge (structure_block.groups, {
		not_in_creative_inventory = 1,
	}),
	on_rightclick = save_on_rightclick,
	_doc_items_create_entry = false,
}))

-- Data structure block.

local function data_save_data (meta)
	local data = meta:get_string ("mcl_levelgen:structure_data_save_data")
	if data ~= "" then
		meta = core.deserialize (data)
	else
		meta = {
			value = "",
			param1 = "",
			param2 = "",
		}
	end
	return meta
end

local function data_formspec_processor (pos, _)
	local meta = core.get_meta (pos)
	local meta = data_save_data (meta)
	return string.format (data_formspec,
			      core.formspec_escape (meta.value),
			      core.formspec_escape (meta.param1),
			      core.formspec_escape (meta.param2))
end

local function data_on_rightclick (pos, node, clicker, itemstack, pointed_thing)
	display_formspec (pos, clicker, "data", data_formspec_processor)
end

core.register_node ("mcl_levelgen:structure_block_data", table.merge (structure_block, {
	tiles = {
		"mcl_levelgen_structure_block_data_top.png",
		"mcl_levelgen_structure_block_data_top.png",
		"mcl_levelgen_structure_block_data_side.png",
		"mcl_levelgen_structure_block_data_side.png",
		"mcl_levelgen_structure_block_data_side.png",
		"mcl_levelgen_structure_block_data_side.png",
	},
	groups = table.merge (structure_block.groups, {
		not_in_creative_inventory = 1,
	}),
	on_rightclick = data_on_rightclick,
	_doc_items_create_entry = false,
}))

cid_structure_block_data
	= core.get_content_id ("mcl_levelgen:structure_block_data")

-- Corner structure block.

local function corner_save_data (meta)
	local data = meta:get_string ("mcl_levelgen:structure_corner_save_data")
	local meta
	if data ~= "" then
		meta = core.deserialize (data)
	else
		meta = {
			structure_name = "",
		}
	end
	return meta
end
mcl_levelgen.corner_save_data = corner_save_data

local function corner_formspec_processor (pos, _)
	local meta = core.get_meta (pos)
	local meta = corner_save_data (meta)
	return string.format (corner_formspec,
			      core.formspec_escape (meta.structure_name))
end

local function corner_on_rightclick (pos, node, clicker, itemstack, pointed_thing)
	display_formspec (pos, clicker, "corner", corner_formspec_processor)
end

core.register_node ("mcl_levelgen:structure_block_corner", table.merge (structure_block, {
	tiles = {
		"mcl_levelgen_structure_block_corner_top.png",
		"mcl_levelgen_structure_block_corner_top.png",
		"mcl_levelgen_structure_block_corner_side.png",
		"mcl_levelgen_structure_block_corner_side.png",
		"mcl_levelgen_structure_block_corner_side.png",
		"mcl_levelgen_structure_block_corner_side.png",
	},
	groups = table.merge (structure_block.groups, {
		not_in_creative_inventory = 1,
	}),
	on_rightclick = corner_on_rightclick,
	_doc_items_create_entry = false,
}))

-- Formspec interface.

local function handle_structure_block_formspec (player, formname, fields)
	local data = player_formspec_data[player]

	if not data then
		return false
	elseif formname == "mcl_levelgen:structure_load_formspec" then
		if not core.check_player_privs (player, "server") then
			core.chat_send_player (player:get_player_name (),
					       S ("`server' privileges are required to utilize structure blocks"))
			return false
		end

		local meta = core.get_meta (data.pos)
		local tbl = load_save_data (meta)
		local toggle_bounds = false

		-- Copy any fields in FIELDS into data.
		if fields.structure_name then
			if tbl.structure_name ~= fields.structure_name then
				tbl.loaded_template = nil
				toggle_bounds = true
			end

			tbl.structure_name = fields.structure_name
		end
		if fields.load_rot_0 then
			tbl.rotation = "0"
			toggle_bounds = true
		elseif fields.load_rot_90 then
			tbl.rotation = "90"
			toggle_bounds = true
		elseif fields.load_rot_180 then
			tbl.rotation = "180"
			toggle_bounds = true
		elseif fields.load_rot_270 then
			tbl.rotation = "270"
			toggle_bounds = true
		end
		if fields.structure_integrity then
			local number = tonumber (fields.structure_integrity) or 1.0
			tbl.structure_integrity = number
		end
		if fields.load_mirroring then
			local current = tbl.mirroring
			if current == "|" then
				tbl.mirroring = "< >"
			elseif current == "< >" then
				tbl.mirroring = "^ v"
			else
				tbl.mirroring = "|"
			end
			toggle_bounds = true
		end
		if fields.relative_position_x then
			tbl.dx = tonumber (fields.relative_position_x) or 0
			toggle_bounds = true
		end
		if fields.relative_position_y then
			tbl.dy = tonumber (fields.relative_position_y) or 1
			toggle_bounds = true
		end
		if fields.relative_position_z then
			tbl.dz = tonumber (fields.relative_position_z) or 0
			toggle_bounds = true
		end
		if fields.structure_seed then
			if not stringtoull (tbl.structure_seed, fields.structure_seed) then
				tbl.structure_seed[1] = 0
				tbl.structure_seed[2] = 0
			end
		end
		if fields.toggle_display_bounds then
			tbl.toggle_display_bounds = not tbl.toggle_display_bounds
			toggle_bounds = true
		end

		meta:set_string ("mcl_levelgen:structure_load_save_data",
				 core.serialize (tbl))

		if fields.load_execute then
			if execute_load (player, data.pos, tbl) then
				meta:set_string ("mcl_levelgen:structure_load_save_data",
						 core.serialize (tbl))
				toggle_bounds = true
			end
		end
		if fields.load_mode_toggle then
			core.swap_node (data.pos, {
				name = "mcl_levelgen:structure_block_save",
			})
			local tbl_new = save_save_data (meta)
			tbl_new.structure_name = tbl.structure_name
			tbl_new.toggle_display_bounds = tbl.toggle_display_bounds
			tbl_new.dx = tbl.dx
			tbl_new.dy = tbl.dy
			tbl_new.dz = tbl.dz
			meta:set_string ("mcl_levelgen:structure_save_save_data",
					 core.serialize (tbl_new))
			if tbl_new.toggle_display_bounds then
				display_outline_entity (data.pos, tbl_new)
			else
				hide_outline_entity (data.pos)
			end
			display_formspec (data.pos, player, "save",
					  save_formspec_processor)
		elseif not fields.quit then
			display_formspec (data.pos, player, "load",
					  load_formspec_processor)

			if toggle_bounds then
				if tbl.toggle_display_bounds then
					display_outline_entity (data.pos, tbl)
				else
					hide_outline_entity (data.pos)
				end
			end
		end

		return true
	elseif formname == "mcl_levelgen:structure_save_formspec" then
		if not core.check_player_privs (player, "server") then
			core.chat_send_player (player:get_player_name (),
					       S ("`server' privileges are required to utilize structure blocks"))
			return false
		end

		local meta = core.get_meta (data.pos)
		local tbl = save_save_data (meta)
		local toggle_display = false

		if fields.structure_name then
			tbl.structure_name = fields.structure_name
		end
		if fields.relative_position_x then
			tbl.dx = tonumber (fields.relative_position_x) or 0
			toggle_display = true
		end
		if fields.relative_position_y then
			tbl.dy = tonumber (fields.relative_position_y) or 1
			toggle_display = true
		end
		if fields.relative_position_z then
			tbl.dz = tonumber (fields.relative_position_z) or 0
			toggle_display = true
		end
		if fields.toggle_display_bounds then
			tbl.toggle_display_bounds = not tbl.toggle_display_bounds
			toggle_display = true
		end
		if fields.structure_size_x then
			tbl.sx = tonumber (fields.structure_size_x) or 0
			toggle_display = true
		end
		if fields.structure_size_y then
			tbl.sy = tonumber (fields.structure_size_y) or 0
			toggle_display = true
		end
		if fields.structure_size_z then
			tbl.sz = tonumber (fields.structure_size_z) or 0
			toggle_display = true
		end

		if fields.detect_structure_size then
			local x1, y1, z1, x2, y2, z2
				= detect_structure_extents (data.pos, tbl.structure_name)
			if not x1 then
				core.chat_send_player (player:get_player_name (),
						       S ("Unable to detect structure size.  Add corners with matching structure names."))
			else
				local pos = data.pos
				local conv_z = -pos.z - 1

				tbl.dx, tbl.dy, tbl.dz = x1 - pos.x + 1, y1 - pos.y + 1, z1 - conv_z + 1
				tbl.sx, tbl.sy, tbl.sz = x2 - x1 - 1, y2 - y1 - 1, z2 - z1 - 1
			end
		end

		meta:set_string ("mcl_levelgen:structure_save_save_data",
				 core.serialize (tbl))

		if fields.save_execute then
			execute_save (player, data.pos, tbl)
		elseif fields.save_mode_toggle then
			core.swap_node (data.pos, {
				name = "mcl_levelgen:structure_block_corner",
			})

			local tbl_new = load_save_data (meta)
			local tbl_new_1 = corner_save_data (meta)
			if tbl.structure_name ~= tbl_new.structure_name then
				tbl_new.structure_name = tbl.structure_name
				tbl_new.loaded_template = nil
			end

			tbl_new.toggle_display_bounds = tbl.toggle_display_bounds
			tbl_new.dx = tbl.dx
			tbl_new.dy = tbl.dy
			tbl_new.dz = tbl.dz
			meta:set_string ("mcl_levelgen:structure_load_save_data",
					 core.serialize (tbl_new))
			tbl_new_1.structure_name = tbl.structure_name
			tbl_new_1.toggle_display_bounds = tbl.toggle_display_bounds
			meta:set_string ("mcl_levelgen:structure_corner_save_data",
					 core.serialize (tbl_new_1))
			display_formspec (data.pos, player, "corner",
					  corner_formspec_processor)
			hide_outline_entity (data.pos)
		elseif not fields.quit then
			display_formspec (data.pos, player, "save",
					  save_formspec_processor)

			if toggle_display and tbl.toggle_display_bounds then
				display_outline_entity (data.pos, tbl)
			else
				hide_outline_entity (data.pos)
			end
		end

		return true
	elseif formname == "mcl_levelgen:structure_corner_formspec" then
		if not core.check_player_privs (player, "server") then
			core.chat_send_player (player:get_player_name (),
					       S ("`server' privileges are required to utilize structure blocks"))
			return false
		end

		local meta = core.get_meta (data.pos)
		local tbl = corner_save_data (meta)

		if fields.structure_name then
			tbl.structure_name = fields.structure_name
		end

		meta:set_string ("mcl_levelgen:structure_corner_save_data",
				 core.serialize (tbl))

		if fields.corner_mode_toggle then
			core.swap_node (data.pos, {
				name = "mcl_levelgen:structure_block_load",
			})

			local tbl_new = load_save_data (meta)
			if tbl.structure_name ~= tbl_new.structure_name then
				tbl_new.structure_name = tbl.structure_name
				tbl_new.loaded_template = nil
			end
			meta:set_string ("mcl_levelgen:structure_load_save_data",
					 core.serialize (tbl_new))

			display_formspec (data.pos, player, "load",
					  load_formspec_processor)
			if tbl_new.toggle_display_bounds then
				display_outline_entity (data.pos, tbl_new)
			end

		elseif not fields.quit then
			display_formspec (data.pos, player, "corner",
					  corner_formspec_processor)
		end
		return true
	elseif formname == "mcl_levelgen:structure_data_formspec" then
		if not core.check_player_privs (player, "server") then
			core.chat_send_player (player:get_player_name (),
					       S ("`server' privileges are required to utilize structure blocks"))
			return false
		end

		local meta = core.get_meta (data.pos)
		local tbl = data_save_data (meta)

		if fields.value then
			tbl.value = fields.value
		end
		if fields.param1 then
			tbl.param1 = fields.param1
		end
		if fields.param2 then
			tbl.param2 = fields.param2
		end

		meta:set_string ("mcl_levelgen:structure_data_save_data",
				 core.serialize (tbl))

		if not fields.quit then
			display_formspec (data.pos, player, "data",
					  data_formspec_processor)
		end

		return true
	end
	return false
end

core.register_on_player_receive_fields (handle_structure_block_formspec)

------------------------------------------------------------------------
-- Jigsaw Block.
------------------------------------------------------------------------

local jigsaw_formspec = [[
formspec_version[6]
size[11.75,7.45]
position[0.5,0.5]
field[0.5,1.0;10.75,0.5;target_pool;Target Pool;%s]
field[0.5,2.0;10.75,0.5;name;Name;%s]
field[0.5,3.0;10.75,0.5;target_name;Target Name;%s]
field[0.5,4.0;10.75,0.5;turns_into;Turns Into;%s]
field[0.5,5.0;3.5,0.5;selection_priority;Selection Priority:;%d]
field[4.15,5.0;3.5,0.5;placement_priority;Placement Priority:;%d]
%s
field[0.5,6.0;3.5,0.5;levels;Levels;%d]
button[4.15,6.0;3.5,0.5;keep_jigsaws;Keep Jigsaws: %s]
button[7.8,6.0;3.5,0.5;generate;Generate]
field_close_on_enter[target_pool;false]
field_close_on_enter[name;false]
field_close_on_enter[target_name;false]
field_close_on_enter[turns_into;false]
field_close_on_enter[selection_priority;false]
field_close_on_enter[placement_priority;false]
field_close_on_enter[levels;false]
]]

local joint_type_formspec = [[
label[7.8,4.87;Joint Type:]
dropdown[7.8,5.0;3.5,0.5;joint_type;Aligned,Rollable;%d;true]
]]

local function jigsaw_save_data (meta)
	local data = meta:get_string ("mcl_levelgen:structure_jigsaw_save_data")
	local meta
	if data ~= "" then
		meta = core.deserialize (data)
	else
		meta = {
			target_pool = "mcl_levelgen:empty",
			name = "mcl_levelgen:empty",
			target_name = "mcl_levelgen:empty",
			turns_into = "air",
			selection_priority = 0,
			placement_priority = 0,
			joint_type = 1,
		}
	end
	return meta
end
mcl_levelgen.corner_save_data = corner_save_data

local function jigsaw_formspec_processor (pos, player)
	local node = core.get_node (pos)
	local meta = core.get_meta (pos)
	local data = jigsaw_save_data (meta)
	local fspec = player_formspec_data[player]

	local levels = fspec.levels or 0
	local keep_jigsaws = fspec.replace_jigsaws and "OFF" or "ON"
	local axis = floor (node.param2 / 4)
	local joint_type = (axis == 0 or axis == 5)
		and string.format (joint_type_formspec,
				   core.formspec_escape (data.joint_type))
		or ""

	local formspec = string.format (jigsaw_formspec,
					core.formspec_escape (data.target_pool),
					core.formspec_escape (data.name),
					core.formspec_escape (data.target_name),
					core.formspec_escape (data.turns_into),
					data.selection_priority,
					data.placement_priority,
					joint_type,
					levels, keep_jigsaws)
	return formspec
end

local function jigsaw_on_rightclick (pos, node, clicker, itemstack, pointed_thing)
	display_formspec (pos, clicker, "jigsaw", jigsaw_formspec_processor)
end

local NORTH = vector.new (0, 0, 1)
local SOUTH = vector.new (0, 0, -1)
local WEST = vector.new (-1, 0, 0)
local EAST = vector.new (1, 0, 0)
local DOWN = vector.new (0, -1, 0)

local function jigsaw_placement (dir, placer, above)
	if vector.equals (dir, NORTH) then
		return 4
	elseif vector.equals (dir, SOUTH) then
		return 10
	elseif vector.equals (dir, EAST) then
		return 13
	elseif vector.equals (dir, WEST) then
		return 19
	elseif vector.equals (dir, DOWN) then
		local dir = vector.subtract (above, placer:get_pos ())
		return (4 - core.dir_to_facedir (dir)) % 4 + 20
	else
		local dir = vector.subtract (above, placer:get_pos ())
		return core.dir_to_facedir (dir)
	end
end

local function jigsaw_on_place (itemstack, placer, pointed_thing)
	if not placer or not placer:is_player () then
		return itemstack
	end

	local rc = mcl_util.call_on_rightclick (itemstack, placer, pointed_thing)
	if rc then
		return rc
	end

	local above = pointed_thing.above
	if core.is_protected (above, placer:get_player_name ()) then
		core.record_protection_violation (above, placer:get_player_name ())
		return
	end
	local under = pointed_thing.under
	local dir = vector.subtract (above, under)
	return core.item_place_node (itemstack, placer, pointed_thing,
				     jigsaw_placement (dir, placer, above))
end

core.register_node ("mcl_levelgen:jigsaw_block", {
	description = S ("Jigsaw Block"),
	_tt_help = S ("Facilitates generation of multiple-piece structures"),
	groups = {
		creative_breakable = 1,
		unmovable_by_piston = 1,
		jigsaw_block = 1,
		rarity = 3,
	},
	tiles = {
		"mcl_levelgen_jigsaw_block_top.png",
		"mcl_levelgen_jigsaw_block_bottom.png",
		"mcl_levelgen_jigsaw_block_side_north.png",
		"mcl_levelgen_jigsaw_block_side_north.png",
		"mcl_levelgen_jigsaw_block_side_north.png",
		"mcl_levelgen_jigsaw_block_side_south.png",
	},
	on_construct = function (pos)
		local meta = core.get_meta (pos)
		local data = jigsaw_save_data (meta)
		meta:set_string ("mcl_levelgen:structure_jigsaw_save_data",
				 core.serialize (data))
	end,
	drop = "",
	is_ground_content = false,
	_mcl_blast_resistance = 3600000,
	_mcl_hardness = -1,
	on_rightclick = jigsaw_on_rightclick,
	paramtype2 = "facedir",
	on_place = jigsaw_on_place,
})

cid_jigsaw_block = core.get_content_id ("mcl_levelgen:jigsaw_block")

-- Jigsaw placement.

local function local_create_piece (element, rotation, rng, sx, sy, sz, bbox)
	return {
		rotation = rotation,
		element = element,
		x = sx,
		y = sy,
		z = sz,
		bbox = bbox,
	}
end

local extull = mcl_levelgen.extull
local xoroshiro_from_seed = mcl_levelgen.xoroshiro_from_seed
local face_directions = mcl_levelgen.face_directions
local facedir_to_jigsaw_dir = mcl_levelgen.facedir_to_jigsaw_dir

local function jigsaw_generate (pos, save, data)
	local ull = extull (floor (os.time () * 1000) % 0x100000000)
	local rng = xoroshiro_from_seed (ull)

	local param2 = core.get_node (pos).param2
	local facing, _ = facedir_to_jigsaw_dir (param2)
	if not facing then
		return
	end

	local x, y, z = pos.x, pos.y, -pos.z - 1
	local dx, dy, dz = unpack (face_directions[facing])
	local target_name = save.target_name
	if save.target_name == "mcl_levelgen:empty" then
		target_name = nil
	end
	local pieces = mcl_levelgen.generate_jigsaw (rng, x + dx,
						     y + dy, z + dz, nil,
						     save.target_pool,
						     target_name,
						     128,
						     data.levels or 0,
						     local_create_piece)
	local options = {
		keep_jigsaws = not data.replace_jigsaws,
	}

	if #pieces > 0 then
		local bbox = mcl_levelgen.bbox_from_pieces (pieces)
		local v1 = vector.new (bbox[1], bbox[2], -bbox[6] - 1)
		local v2 = vector.new (bbox[4], bbox[5], -bbox[3] - 1)
		vm = VoxelManip (v1, v2)
		vm:get_data (cids)
		vm:get_param2_data (param2s)
		area = VoxelArea (vm:get_emerged_area ())

		for _, piece in ipairs (pieces) do
			place_template_internal (piece.element.template,
						 piece.x,
						 piece.y,
						 piece.z, 0, 0,
						 options, nil, nil,
						 piece.rotation,
						 piece.element.processors,
						 rng, jigsaw_set_block,
						 jigsaw_get_block)
		end

		vm:set_data (cids)
		vm:set_param2_data (param2s)
		vm:write_to_map (true)

		for _, piece in ipairs (pieces) do
			run_template_constructors (piece.element.template,
						   piece.x,
						   piece.y,
						   piece.z, 0, 0, nil,
						   piece.rotation,
						   jigsaw_construct_block)
		end

		if vm.close then
			vm:close ()
		end
		vm = nil
	end
end

-- Formspec interface.

local function handle_jigsaw_block_formspec (player, formname, fields)
	local data = player_formspec_data[player]

	if not data then
		return false
	elseif formname == "mcl_levelgen:structure_jigsaw_formspec" then
		-- Although jigsaw blocks do not directly facilitate
		-- code execution on the server, it is prudent to err
		-- on the side of caution, lest ill-advised server
		-- owners should leave templates with exploitable Lua
		-- code or exposed structure blocks available to
		-- players.
		if not core.check_player_privs (player, "server") then
			core.chat_send_player (player:get_player_name (),
					       S ("`server' privileges are required to interact with jigsaw blocks"))
			return false
		end

		local meta = core.get_meta (data.pos)
		local save = jigsaw_save_data (meta)

		if fields.target_pool then
			save.target_pool = fields.target_pool
		end

		if fields.target_name then
			save.target_name = fields.target_name
		end

		if fields.name then
			save.name = fields.name
		end

		if fields.placement_priority then
			local priority = tonumber (fields.placement_priority) or 0
			save.placement_priority = mathmin (mathmax (priority, 0), 120)
		end

		if fields.selection_priority then
			local priority = tonumber (fields.selection_priority) or 0
			save.selection_priority = mathmin (mathmax (priority, 0), 120)
		end

		if fields.turns_into then
			save.turns_into = fields.turns_into
		end

		if fields.joint_type then
			local idx = tonumber (fields.joint_type) or 1
			save.joint_type = idx
		end

		if fields.keep_jigsaws then
			data.replace_jigsaws = not data.replace_jigsaws
		end

		if fields.levels then
			local levels = tonumber (fields.levels) or 1
			data.levels = levels
		end

		meta:set_string ("mcl_levelgen:structure_jigsaw_save_data",
				 core.serialize (save))

		if fields.generate then
			core.close_formspec (player:get_player_name (), formname)
			jigsaw_generate (data.pos, save, data)
		elseif not fields.quit then
			display_formspec (data.pos, player, "jigsaw",
					  jigsaw_formspec_processor, true)
		end
		return true
	end
	return false
end

core.register_on_player_receive_fields (handle_jigsaw_block_formspec)

-- ------------------------------------------------------------------------
-- -- Jigsaw Block testing.
-- ------------------------------------------------------------------------

-- function mcl_levelgen.local_template (template)
-- 	return template_dir .. template .. ".dat"
-- end

-- local function L (name, weight)
-- 	return {
-- 		projection = "rigid",
-- 		template = mcl_levelgen.local_template (name),
-- 		processors = {},
-- 		weight = weight,
-- 	}
-- end

-- mcl_levelgen.register_template_pool ("mcl_levelgen:jigsaw_test", {
-- 	elements = {
-- 		L ("demo_piece", 1),
-- 	},
-- })

-- mcl_levelgen.register_template_pool ("mcl_levelgen:jigsaw_test_1", {
-- 	elements = {
-- 		L ("demo_piece_1", 1),
-- 	},
-- })

-- mcl_levelgen.register_template_pool ("mcl_levelgen:jigsaw_test_2", {
-- 	elements = {
-- 		L ("line", 1),
-- 	},
-- })

-- mcl_levelgen.register_template_pool ("mcl_levelgen:jigsaw_test_4", {
-- 	elements = {
-- 		L ("jigsaw_demo_4", 1),
-- 	},
-- })

-- mcl_levelgen.register_template_pool ("mcl_levelgen:jigsaw_test_interior", {
-- 	elements = {
-- 		L ("jigsaw_interior_decoration", 1),
-- 	},
-- })
