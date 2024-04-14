local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

mcl_walls = {}

local function rshift(x, by)
	return math.floor(x / 2 ^ by)
end

local directions = {
	{x = 1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = -1},
	{x = 0, y = -1, z = 0},
}

local function connectable(itemstring)
	return (minetest.get_item_group(itemstring, "wall") == 1) or (minetest.get_item_group(itemstring, "solid") == 1)
end

function mcl_walls.update_wall(pos)
	local thisnode = minetest.get_node(pos)

	if minetest.get_item_group(thisnode.name, "wall") == 0 then
		return
	end

	-- Get the node's base name, including the underscore since we will need it
	local colonpos = thisnode.name:find(":")
	local underscorepos
	local itemname, basename, modname
	if colonpos then
		itemname = thisnode.name:sub(colonpos+1)
		modname = thisnode.name:sub(1, colonpos-1)
	end
	underscorepos = itemname:find("_")
	if underscorepos == nil then -- New wall
		basename = thisnode.name .. "_"
	else -- Already placed wall
		basename = modname .. ":" .. itemname:sub(1, underscorepos)
	end

	local sum = 0

	-- Neighbouring walkable nodes
	for i = 1, 4 do
		local dir = directions[i]
		local node = minetest.get_node({x = pos.x + dir.x, y = pos.y + dir.y, z = pos.z + dir.z})
		if connectable(node.name) then
			sum = sum + 2 ^ (i - 1)
		end
	end

	-- Torches or walkable nodes above the wall
	local upnode = minetest.get_node({x = pos.x, y = pos.y+1, z = pos.z})
	if sum == 5 or sum == 10 then
		if (connectable(upnode.name)) or (minetest.get_item_group(upnode.name, "torch") == 1) then
			sum = sum + 11
		end
	end

	--[[if sum == 0 then
		sum = 15
	end]]

	minetest.add_node(pos, {name = basename..sum})
end

local function update_wall_global(pos)
	for i = 1,5 do
		local dir = directions[i]
		mcl_walls.update_wall({x = pos.x + dir.x, y = pos.y + dir.y, z = pos.z + dir.z})
	end
end

local half_blocks = {
    {4/16, -0.5, -3/16, 0.5, 5/16, 3/16},
    {-3/16, -0.5, 4/16, 3/16, 5/16, 0.5},
    {-0.5, -0.5, -3/16, -4/16, 5/16, 3/16},
    {-3/16, -0.5, -0.5, 3/16, 5/16, -4/16}
}

local pillar = {-4/16, -0.5, -4/16, 4/16, 0.5, 4/16}

local full_blocks = {
    {-0.5, -0.5, -3/16, 0.5, 5/16, 3/16},
    {-3/16, -0.5, -0.5, 3/16, 5/16, 0.5}
}

--[[ Adds a new wall type.
* nodename: Itemstring of base node to add. Must not contain an underscore
* description: Item description (tooltip), visible to user
* source: Source block to craft this thing, for graphics, tiles and crafting (optional)
* tiles: Wall textures table
* inventory_image: Inventory image (optional)
* groups: Base group memberships (optional, default is {pickaxey=1})
* sounds: Sound table (optional, default is stone)
]]
function mcl_walls.register_wall(nodename, description, source, tiles, inventory_image, groups, sounds, overrides)

	local base_groups = groups
	if not base_groups then
		base_groups = {pickaxey=1}
	end
	base_groups.wall = 1

	local internal_groups = table.copy(base_groups)
	internal_groups.not_in_creative_inventory = 1

	local main_node_groups = table.copy(base_groups)
	main_node_groups.deco_block = 1

	-- TODO: Stop hardcoding blast resistance

	if not sounds then
		sounds = mcl_sounds.node_sound_stone_defaults()
	end

	if (not tiles) and source then
		if minetest.registered_nodes[source] then
			tiles = minetest.registered_nodes[source].tiles
		end
	end

	for i = 0, 15 do
		local need = {}
		local need_pillar = false
		for j = 1, 4 do
			if rshift(i, j - 1) % 2 == 1 then
				need[j] = true
			end
		end

		local take = {}
		if need[1] == true and need[3] == true then
			need[1] = nil
			need[3] = nil
			table.insert(take, full_blocks[1])
		end
		if need[2] == true and need[4] == true then
			need[2] = nil
			need[4] = nil
			table.insert(take, full_blocks[2])
		end
		for k in pairs(need) do
			table.insert(take, half_blocks[k])
			need_pillar = true
		end
		if i == 15 or i == 0 then need_pillar = true end
		if need_pillar then table.insert(take, pillar) end

		minetest.register_node(nodename.."_"..i, table.merge({
			collision_box = {
				type = "fixed",
				fixed = {-4/16, -0.5, -4/16, 4/16, 1, 4/16}
			},
			drawtype = "nodebox",
			is_ground_content = false,
			tiles = tiles,
			use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
			paramtype = "light",
			sunlight_propagates = true,
			groups = internal_groups,
			drop = nodename,
			node_box = {
				type = "fixed",
				fixed = take
			},
			sounds = sounds,
			_mcl_blast_resistance = 6,
			_mcl_hardness = 2,
			_mcl_stonecutter_recipes = {source},
		}, overrides or {}))

		-- Add entry alias for the Help
		if minetest.get_modpath("doc") then
			doc.add_entry_alias("nodes", nodename, "nodes", nodename.."_"..i)
		end
	end

	minetest.register_node(nodename.."_16", table.merge({
		drawtype = "nodebox",
		collision_box = {
				type = "fixed",
				fixed = {-4/16, -0.5, -4/16, 4/16, 1, 4/16}
		},
		tiles = tiles,
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
		paramtype = "light",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = internal_groups,
		drop = nodename,
		node_box = {
			type = "fixed",
			fixed = {pillar, full_blocks[1]}
		},
		sounds = sounds,
		_mcl_blast_resistance = 6,
		_mcl_hardness = 2,
		_mcl_stonecutter_recipes = {source},
	}, overrides or {}))
	-- Add entry alias for the Help
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", nodename, "nodes", nodename.."_16")
	end

	minetest.register_node(nodename.."_21", table.merge({
		drawtype = "nodebox",
		collision_box = {
				type = "fixed",
				fixed = {-4/16, -0.5, -4/16, 4/16, 1, 4/16}
		},
		tiles = tiles,
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
		paramtype = "light",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = internal_groups,
		drop = nodename,
		node_box = {
			type = "fixed",
			fixed = {pillar, full_blocks[2]}
		},
		sounds = sounds,
		_mcl_blast_resistance = 6,
		_mcl_hardness = 2,
		--_mcl_base_node = source,
	}, overrides or {}))
	-- Add entry alias for the Help
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", nodename, "nodes", nodename.."_21")
	end

	-- Inventory item
	minetest.register_node(nodename, table.merge({
		description = description,
		_doc_items_longdesc = S("A piece of wall. It cannot be jumped over with a simple jump. When multiple of these are placed to next to each other, they will automatically build a nice wall structure."),
		paramtype = "light",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = main_node_groups,
		tiles = tiles,
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
		inventory_image = inventory_image,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = pillar
		},
		collision_box = {
				type = "fixed",
				fixed = {-4/16, -0.5, -4/16, 4/16, 1, 4/16}
		},
		collisionbox = {-0.2, 0, -0.2, 0.2, 1.4, 0.2},
		on_construct = mcl_walls.update_wall,
		sounds = sounds,
		_mcl_blast_resistance = 6,
		_mcl_hardness = 2,
	}, overrides or {}))
	if source then
		minetest.register_craft({
			output = nodename .. " 6",
			recipe = {
				{source, source, source},
				{source, source, source},
			}
		})
	end
end

function mcl_walls.register_wall_def(name,def)
	local source = def.source
	def.source = nil
	mcl_walls.register_wall(name, nil, source, nil, nil, nil, nil, def)
end

dofile(modpath.."/register.lua")

minetest.register_on_placenode(update_wall_global)
minetest.register_on_dignode(update_wall_global)
