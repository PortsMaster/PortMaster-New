local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local mod_doc = minetest.get_modpath("doc")

--maps normalized base color name to non-standard texture color names
local messy_texture_names = {
	["grey"] = "gray",
}

local function is_pane(pos)
	return minetest.get_item_group(minetest.get_node(pos).name, "pane") > 0
end

local function connects_dir(pos, name, dir)
	local aside = vector.add(pos, minetest.facedir_to_dir(dir))
	if is_pane(aside) then
		return true
	end

	local connects_to = minetest.registered_nodes[name].connects_to
	if not connects_to then
		return false
	end
	local list = minetest.find_nodes_in_area(aside, aside, connects_to)

	if #list > 0 then
		return true
	end

	return false
end

local function swap(pos, node, name, param2)
	if node.name == name and node.param2 == param2 then
		return
	end

	minetest.set_node(pos, {name = name, param2 = param2})
end

local function update_pane(pos)
	if not is_pane(pos) then
		return
	end
	local node = minetest.get_node(pos)
	local name = node.name
	if name:sub(-5) == "_flat" then
		name = name:sub(1, -6)
	end

	local any = node.param2
	local c = {}
	local count = 0
	for dir = 0, 3 do
		c[dir] = connects_dir(pos, name, dir)
		if c[dir] then
			any = dir
			count = count + 1
		end
	end

	if count == 0 then
		swap(pos, node, name .. "_flat", any)
	elseif count == 1 then
		swap(pos, node, name .. "_flat", (any + 1) % 4)
	elseif count == 2 then
		if (c[0] and c[2]) or (c[1] and c[3]) then
			swap(pos, node, name .. "_flat", (any + 1) % 4)
		else
			swap(pos, node, name, 0)
		end
	else
		swap(pos, node, name, 0)
	end
end

minetest.register_on_placenode(function(pos, node)
	if minetest.get_item_group(node.name, "pane") <= 0 then return end
	update_pane(pos)
	for i = 0, 3 do
		local dir = minetest.facedir_to_dir(i)
		update_pane(vector.add(pos, dir))
	end
end)

minetest.register_on_dignode(function(pos,node)
	if minetest.get_item_group(node.name, "pane") <= 0 then return end
	for i = 0, 3 do
		local dir = minetest.facedir_to_dir(i)
		update_pane(vector.add(pos, dir))
	end
end)

mcl_panes = {}
mcl_panes.update_pane = update_pane
function mcl_panes.register_pane(name, def)
	for i = 1, 15 do
		minetest.register_alias("mcl_panes:" .. name .. "_" .. i, "mcl_panes:" .. name .. "_flat")
	end

	local flatgroups = table.copy(def.groups)
	local drop = def.drop
	if not drop then
		drop = "mcl_panes:" .. name .. "_flat"
	end
	flatgroups.pane = 1
	flatgroups.deco_block = 1
	minetest.register_node(":mcl_panes:" .. name .. "_flat", {
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
		groups = flatgroups,
		drop = drop,
		sounds = def.sounds,
		node_box = {
			type = "fixed",
			fixed = {{-1/2, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		selection_box = {
			type = "fixed",
			fixed = {{-1/2, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		connect_sides = { "left", "right" },
		_mcl_blast_resistance = def._mcl_blast_resistance,
		_mcl_hardness = def._mcl_hardness,
		_mcl_silk_touch_drop = def._mcl_silk_touch_drop and {"mcl_panes:" .. name .. "_flat"},
	})

	local groups = table.copy(def.groups)
	groups.pane = 1
	groups.not_in_creative_inventory = 1
	minetest.register_node(":mcl_panes:" .. name, {
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		_doc_items_create_entry = false,
		tiles = {def.textures[3], def.textures[2], def.textures[1]},
		use_texture_alpha = def.use_texture_alpha,
		groups = groups,
		drop = drop,
		sounds = def.sounds,
		node_box = {
			type = "connected",
			fixed = {{-1/32, -1/2, -1/32, 1/32, 1/2, 1/32}},
			connect_front = {{-1/32, -1/2, -1/2, 1/32, 1/2, -1/32}},
			connect_left = {{-1/2, -1/2, -1/32, -1/32, 1/2, 1/32}},
			connect_back = {{-1/32, -1/2, 1/32, 1/32, 1/2, 1/2}},
			connect_right = {{1/32, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		connects_to = {"group:pane", "group:stone", "group:glass", "group:wood", "group:tree"},
		_mcl_blast_resistance = def._mcl_blast_resistance,
		_mcl_hardness = def._mcl_hardness,
		_mcl_silk_touch_drop = def._mcl_silk_touch_drop and {"mcl_panes:" .. name .. "_flat"},
	})

	minetest.register_craft({
		output = "mcl_panes:" .. name .. "_flat 16",
		recipe = def.recipe
	})

	if mod_doc and def._doc_items_create_entry ~= false then
		doc.add_entry_alias("nodes", "mcl_panes:" .. name .. "_flat", "nodes", "mcl_panes:" .. name)
	end
end

local canonical_color = "yellow"
-- Register glass pane (stained and unstained)
local function pane(description, node, append)
	local texture1, longdesc, entry_name, create_entry
	local is_canonical = true
	local txappend = append
	if messy_texture_names[append:gsub("_","")] then
		txappend = "_"..messy_texture_names[append:gsub("_","")]
	end

	-- Special case: Default (unstained) glass texture
	if append == "_natural" then
		texture1 = "default_glass.png"
		longdesc = S("Glass panes are thin layers of glass which neatly connect to their neighbors as you build them.")
	else
		if append ~= "_"..canonical_color then
			is_canonical = false
			create_entry = false
		else
			longdesc = S("Stained glass panes are thin layers of stained glass which neatly connect to their neighbors as you build them. They come in many different colors.")
			entry_name = S("Stained Glass Pane")
		end
		texture1 = "mcl_core_glass"..txappend..".png"
	end
	mcl_panes.register_pane("pane"..append, {
		description = description,
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = entry_name,
		_doc_items_longdesc = longdesc,
		textures = {texture1, texture1, "xpanes_top_glass"..txappend..".png"},
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "blend" or true,
		inventory_image = texture1,
		wield_image = texture1,
		sounds = mcl_sounds.node_sound_glass_defaults(),
		groups = {handy=1, material_glass=1},
		recipe = {
			{node, node, node},
			{node, node, node},
		},
		drop = "",
		_mcl_blast_resistance = 0.3,
		_mcl_hardness = 0.3,
		_mcl_silk_touch_drop = true,
	})

	if mod_doc and not is_canonical then
		doc.add_entry_alias("nodes", "mcl_panes:pane_".. canonical_color .. "_flat", "nodes", "mcl_panes:pane"..append)
		doc.add_entry_alias("nodes", "mcl_panes:pane_".. canonical_color .. "_flat", "nodes", "mcl_panes:pane"..append.."_flat")
	end
end

-- Iron Bars
mcl_panes.register_pane("bar", {
	description = S("Iron Bars"),
	_doc_items_longdesc = S("Iron bars neatly connect to their neighbors as you build them."),
	textures = {"xpanes_pane_iron.png","xpanes_pane_iron.png","xpanes_top_iron.png"},
	inventory_image = "xpanes_pane_iron.png",
	wield_image = "xpanes_pane_iron.png",
	groups = {pickaxey=1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot"},
	},
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

-- Glass Pane
pane(S("Glass Pane"), "mcl_core:glass", "_natural") -- triggers special case

-- Stained Glass Panes
for k,v in pairs(mcl_dyes.colors) do
	pane(S("@1 Glass Pane", v.readable_name), "mcl_core:glass_"..k, "_"..k)
end
