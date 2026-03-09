local modname = core.get_current_modname()
local S = core.get_translator(modname)
local D = mcl_util.get_dynamic_translator()

mcl_panes = {}

local flat_pane_groups_tpl = {
	pane = 1,
	deco_block = 1,
	pathfinder_partial = 2
}

local pane_groups_tpl = {
	pane = 1,
	deco_block = 1,
	pathfinder_partial = 2,
	not_in_creative_inventory = 1
}

--maps normalized base color name to non-standard texture color names
local messy_texture_names = {
	["_grey"] = "_gray",
}

local pane_nodebox = {
	type          = "connected",
	fixed         = {{-1/16, -1/2, -1/16, 1/16,  1/2, 1/16}},
	connect_front = {{-1/16, -1/2, -1/2,  1/16,  1/2, -1/16}},
	connect_left  = {{-1/2,  -1/2, -1/16, -1/16, 1/2, 1/16}},
	connect_back  = {{-1/16, -1/2, 1/16,  1/16,  1/2, 1/2}},
	connect_right = {{1/16,  -1/2, -1/16, 1/2,   1/2, 1/16}},
}

local flat_pane_nodebox = {
	type = "fixed",
	fixed = {{-1/2, -1/2, -1/16, 1/2, 1/2, 1/16}},
}

local neighbour_offsets = {
	vector.new(1,  0,  0),
	vector.new(0,  0,  1),
	vector.new(-1, 0,  0),
	vector.new(0,  0,  -1),
}

local function connects_dir(pos, name, dir)
	local aside = vector.add(pos, dir)

	if core.get_item_group(core.get_node(aside).name, "pane") > 0 then
		return true
	end

	local connects_to = core.registered_nodes[name].connects_to
	if not connects_to then
		return false
	end

	local list = core.find_nodes_in_area(aside, aside, connects_to)

	return #list > 0
end

local function swap_node_if_different(pos, node, name, param2)
	if node.name == name and node.param2 == param2 then
		return
	end

	core.set_node(pos, {name = name, param2 = param2})
end

local function update_pane(pos)
	local node = core.get_node(pos)

	if core.get_item_group(node.name, "pane") <= 0 then
		return
	end

	local name = node.name
	local is_flat = name:find("_flat")
	if is_flat then
		name = name:gsub("_flat", "")
	end

	local any = node.param2
	local connects_to_side = {}
	local count = 0
	for i, dir in pairs(neighbour_offsets) do
		connects_to_side[i] = connects_dir(pos, name, dir)
		if connects_to_side[i] then
			any = dir
			count = count + 1
		end
	end

	if count == 2
			and (
				(connects_to_side[1] and connects_to_side[3])
				or (connects_to_side[2] and connects_to_side[4])
			) then
		if name:find("_preserved") then
			name = name:gsub("_preserved", "_flat_preserved")
		else
			name = name .. "_flat"
		end
		swap_node_if_different(pos,
			node,
			name,
			(core.dir_to_facedir(any) + 1) % 4
		)
	else
		swap_node_if_different(pos, node, name, 0)
	end
end

core.register_on_placenode(function(pos, _)
	for _, dir in pairs(neighbour_offsets) do
		update_pane(vector.add(pos, dir))
	end
end)

core.register_on_dignode(function(pos, _)
	for _, dir in pairs(neighbour_offsets) do
		update_pane(vector.add(pos, dir))
	end
end)

mcl_panes.update_pane = update_pane
function mcl_panes.register_pane(name, def)
	for i = 1, 15 do
		core.register_alias("mcl_panes:" .. name .. "_" .. i, "mcl_panes:" .. name .. "_flat")
	end

	local node_name_flat = "mcl_panes:" .. name .. "_flat"
	local node_name = "mcl_panes:" .. name

	local drop = def.drop or node_name_flat
	core.register_node(":mcl_panes:" .. name .. "_flat", {
		description = def.description,
		_doc_items_create_entry = def._doc_items_create_entry,
		_doc_items_entry_name = def._doc_items_entry_name,
		_doc_items_longdesc = def._doc_items_longdesc,
		_doc_items_usagehelp = def._doc_items_usagehelp,
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		paramtype2 = "facedir",
		tiles = {def.textures[3], def.textures[2], def.textures[1]},
		use_texture_alpha = def.use_texture_alpha,
		groups = table.merge(flat_pane_groups_tpl, def.groups),
		drop = drop,
		sounds = def.sounds,
		node_box = flat_pane_nodebox,
		_mcl_blast_resistance = def._mcl_blast_resistance,
		_mcl_hardness = def._mcl_hardness,
		_mcl_silk_touch_drop = def._mcl_silk_touch_drop and {node_name_flat},
		on_construct = function(pos)
			update_pane(pos)
		end,

		-- Flat panes don't use connected nodeboxes, but its used in the code to know when to turn into a nodebox pane
		connects_to = {"group:pane", "group:solid"},
	})

	core.register_node(":mcl_panes:" .. name, {
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		_doc_items_create_entry = false,
		tiles = {def.textures[3], def.textures[2], def.textures[1]},
		use_texture_alpha = def.use_texture_alpha,
		groups = table.merge(pane_groups_tpl, def.groups),
		drop = drop,
		sounds = def.sounds,
		node_box = pane_nodebox,
		connects_to = {"group:pane", "group:solid"},
		_mcl_blast_resistance = def._mcl_blast_resistance,
		_mcl_hardness = def._mcl_hardness,
		_mcl_silk_touch_drop = def._mcl_silk_touch_drop and {node_name_flat},
		on_construct = function(pos)
			update_pane(pos)
		end
	})

	core.register_craft({
		output = string.format("%s 16", node_name_flat),
		recipe = def.recipe
	})

	if def._doc_items_create_entry ~= false then
		doc.add_entry_alias("nodes", node_name_flat, "nodes", node_name)
	end
end

local canonical_color = "_yellow"
local function register_pane(description, node, suffix, color)
	local texture, longdesc, entry_name
	local is_canonical = true
	-- This is to handle the naming scheme clash between mcl_dyes and legacy texture names
	-- basically, mcl_dyes uses "grey", but the texture names use `gray`
	local texture_suffix = messy_texture_names[suffix] or suffix

	-- Special case: Default (unstained) glass texture
	if suffix == "_natural" then
		texture = "default_glass.png"
		longdesc = S("Glass panes are thin layers of glass which neatly connect to their neighbors as you build them.")
	else
		if suffix ~= canonical_color then
			is_canonical = false
		else
			longdesc = S("Stained glass panes are thin layers of stained glass which neatly connect to their neighbors as you build them. They come in many different colors.")
			entry_name = S("Stained Glass Pane")
		end
		texture = "mcl_core_glass"..texture_suffix..".png"
	end

	mcl_panes.register_pane("pane"..suffix, {
		description = description,
		_doc_items_create_entry = is_canonical,
		_doc_items_entry_name = entry_name,
		_doc_items_longdesc = longdesc,
		textures = {texture, texture, "xpanes_top_glass"..texture_suffix..".png"},
		use_texture_alpha = suffix == "_natural" and "clip" or "blend",
		inventory_image = texture,
		sounds = mcl_sounds.node_sound_glass_defaults(),
		groups = {handy=1, material_glass=1, pathfinder_partial=2},
		recipe = {
			{node, node, node},
			{node, node, node},
		},
		drop = "",
		_mcl_hardness = 0.3,
		_mcl_silk_touch_drop = true,
		_color = color,
	})

	if not is_canonical then
		doc.add_entry_alias("nodes", "mcl_panes:pane".. canonical_color .. "_flat", "nodes", "mcl_panes:pane"..suffix)
		doc.add_entry_alias("nodes", "mcl_panes:pane".. canonical_color .. "_flat", "nodes", "mcl_panes:pane"..suffix.."_flat")
	end
end

mcl_panes.register_pane("bar", {
	description = S("Iron Bars"),
	_doc_items_longdesc = S("Iron bars neatly connect to their neighbors as you build them."),
	textures = {"xpanes_pane_iron.png","xpanes_pane_iron.png","xpanes_top_iron.png"},
	inventory_image = "xpanes_pane_iron.png",
	groups = {pickaxey=1, iron_bars=1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	use_texture_alpha = "clip",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot"},
	},
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

register_pane(S("Glass Pane"), "mcl_core:glass", "_natural") -- triggers special case

for k, v in pairs(mcl_dyes.colors) do
	register_pane(D("@1 Glass Pane", v.readable_name), "mcl_core:glass_"..k, "_"..k, k)
end
