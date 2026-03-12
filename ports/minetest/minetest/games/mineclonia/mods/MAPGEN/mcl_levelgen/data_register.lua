------------------------------------------------------------------------
-- Default Data Block processors.
------------------------------------------------------------------------

local mathabs = math.abs
local level_to_minetest_position = mcl_levelgen.level_to_minetest_position
local loot_tables = {}

function mcl_levelgen.register_loot_table (id, tbl)
	loot_tables[id] = tbl
end

local v = vector.zero ()
local cid_air = core.CONTENT_AIR

local function handle_set_loot_table_1 (_, data, main_env_p)
	v.x, v.y, v.z = level_to_minetest_position (data[1], data[2], data[3])
	-- XXX: Y coordinates are not transformed when invoked from a
	-- structure block.
	if main_env_p then
		v.y = data[2]
	end
	local loot_table = loot_tables[data[4]]
	if not loot_table then
		local blurb
			= "[mcl_levelgen]: Loot table does not exist: " .. data[4]
		core.log ("warning", blurb)
		return
	end

	local loot_seed = data[5]
	core.load_area (v)
	mcl_structures.init_node_construct (v)
	local node = core.get_node (v)
	if core.get_item_group (node.name, "container") >= 1 then
		local pr = PcgRandom (loot_seed)
		local loot = mcl_loot.get_multi_loot (loot_table, pr)
		local meta = core.get_meta (v)
		mcl_loot.fill_inventory (meta:get_inventory (), "main", loot, pr)
	end
end

local function handle_create_entity_1 (_, data, main_env_p)
	local name = data[4]
	local staticdata = data[5]
	v.x, v.y, v.z
		= level_to_minetest_position (data[1], data[2], data[3])
	-- XXX: Y coordinates are not transformed when invoked from a
	-- structure block.
	if main_env_p then
		v.y = data[2]
	end
	v.y = v.y - 0.5
	core.add_entity (v, name, staticdata)
end

if mcl_levelgen.register_notification_handler then

mcl_levelgen.register_notification_handler ("mcl_levelgen:set_loot_table_1",
					    handle_set_loot_table_1)
mcl_levelgen.register_notification_handler ("mcl_levelgen:create_entity_1",
					    handle_create_entity_1)

end

local notify_generated = mcl_levelgen.notify_generated
local mcl_levelgen = mcl_levelgen
local suppress_constructors = mcl_levelgen.suppress_constructors

local function handle_set_loot_table (rng, data, mirroring, rotation, x, y, z, item)
	suppress_constructors (x, y - 1, z)
	if mcl_levelgen.is_levelgen_environment then
		notify_generated ("mcl_levelgen:set_loot_table_1", x, y - 1, z, {
			x, y - 1, z, item.param1, mathabs (rng:next_integer ()),
		})
	else
		core.after (0, handle_set_loot_table_1, nil, {
			x, y - 1, z, item.param1, mathabs (rng:next_integer ()),
		}, true)
	end
	return cid_air, 0
end

mcl_levelgen.register_data_block_processor ("mcl_levelgen:set_loot_table",
					    handle_set_loot_table)

local function handle_create_entity (rng, data, mirroring, rotation, x, y, z, item)
	if mcl_levelgen.is_levelgen_environment then
		notify_generated ("mcl_levelgen:create_entity_1", x, y, z, {
			x, y, z, item.param1, item.param2,
		})
	else
		handle_create_entity_1 (nil, {
			x, y, z, item.param1, item.param2,
		}, true)
	end
	return cid_air, 0
end

mcl_levelgen.register_data_block_processor ("mcl_levelgen:create_entity",
					    handle_create_entity)

------------------------------------------------------------------------
-- Default notification handlers.
------------------------------------------------------------------------

if mcl_levelgen.register_notification_handler then

local function handle_set_block_meta (_, data)
	for _, pos in ipairs (data) do
		local x, y, z
			= level_to_minetest_position (pos[1], pos[2], pos[3])
		v.x = x
		v.y = y
		v.z = z
		core.load_area (v)
		local meta = core.get_meta (v)
		meta:from_table (pos[4])
	end
end

mcl_levelgen.register_notification_handler ("mcl_levelgen:set_block_meta",
					    handle_set_block_meta)

local function handle_construct_block (_, data)
	local copy = vector.copy
	for _, pos in ipairs (data) do
		local x, y, z
			= level_to_minetest_position (pos[1], pos[2], pos[3])
		v.x = x
		v.y = y
		v.z = z
		core.load_area (v)
		mcl_structures.init_node_construct (copy (v))
	end
end

mcl_levelgen.register_notification_handler ("mcl_levelgen:construct_block",
					    handle_construct_block)

end
