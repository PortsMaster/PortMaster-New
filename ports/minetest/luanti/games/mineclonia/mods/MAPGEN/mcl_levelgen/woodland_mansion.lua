local ipairs = ipairs
local R = mcl_levelgen.build_random_spread_placement

------------------------------------------------------------------------
-- Portable schematics.
------------------------------------------------------------------------

local schematics = {
	"allium_room",
	"altar",
	"arch_hallway",
	"bedroom_with_loft",
	"birch_office",
	"birch_pillar_room",
	"carpet_strip",
	"checkerboard",
	"clean_chest",
	"corridor_3way",
	"corridor_4way",
	"corridor_left",
	"corridor_right",
	"corridor_separator",
	"corridor_straight",
	"door",
	"entrance_facade",
	"entrance_facade_flipped",
	"ersatz_portal",
	"exterior_wall",
	"exterior_wall_flipped",
	"flower_room",
	"forge_room",
	"foyer",
	"gray_banner",
	"hidden_attic",
	"illager_head",
	"large_dining_room",
	"large_gaol",
	"large_storage_room",
	"library",
	"master_bedroom",
	"medium_bedroom",
	"medium_dining_room",
	"medium_library",
	"melon_farm",
	"nature_room",
	"obsidian_room",
	"office",
	"pile_room",
	"pumpkin_ring",
	"redstone_gaol",
	"sapling_farm",
	"single_bedroom",
	"situation_room",
	"small_dining_room",
	"small_library",
	"small_storage_room",
	"spider",
	"tree_chopping_room",
	"triple_bedroom",
	"wall",
	"wheat_farm",
	"white_tulip_sanctuary",
	"winding_staircase",
	"x_room",
}

local woodland_mansion_loot = {
	{
			stacks_min = 3,
			stacks_max = 3,
			items = {
				{ itemstring = "mcl_mobitems:bone", weight = 10, amount_min = 1, amount_max=8 },
				{ itemstring = "mcl_mobitems:gunpowder", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10, amount_min = 1, amount_max=8 },
				{ itemstring = "mcl_mobitems:string", weight = 10, amount_min = 1, amount_max=8 },

				{ itemstring = "mcl_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
			},
	},
	{
		stacks_min = 1,
		stacks_max = 4,
		items = {
			{ itemstring = "mcl_farming:wheat_item", weight = 20, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_farming:bread", weight = 20, amount_min = 1, amount_max = 1 },
			{ itemstring = "mcl_core:coal_lump", weight = 15, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_redstone:redstone", weight = 15, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_farming:beetroot_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_farming:melon_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_farming:pumpkin_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_core:iron_ingot", weight = 10, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_buckets:bucket_empty", weight = 10, amount_min = 1, amount_max = 1 },
			{ itemstring = "mcl_core:gold_ingot", weight = 5, amount_min = 1, amount_max = 4 },
		},
	},
	{
		stacks_min = 1,
		stacks_max = 4,
		items = {
			--{ itemstring = "FIXME:lead", weight = 20, amount_min = 1, amount_max = 1 },
			{ itemstring = "mcl_mobitems:nametag", weight = 2, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_books:book", weight = 1,
			  func = function(stack, pr)
				  mcl_enchanting.enchant_uniform_randomly (stack, {"soul_speed"}, pr)
			  end, },
			{ itemstring = "mcl_armor:chestplate_chain", weight = 1, },
			{ itemstring = "mcl_armor:chestplate_diamond", weight = 1, },
			{ itemstring = "mcl_core:apple_gold_enchanted", weight = 2, },
			{ itemstring = "mcl_armor:vex", amount_max = 1, },
		},
	},
}

local level_to_minetest_position = mcl_levelgen.level_to_minetest_position
local v = vector.new ()

local function handle_mansion_construct_node (_, node_list)
	for _, node in ipairs (node_list) do
		local x, y, z, loot_seed
			= node[1], node[2], node[3], node[4]
		x, y, z = level_to_minetest_position (x, y, z)
		v.x = x
		v.y = y
		v.z = z
		mcl_structures.init_node_construct (v)

		if loot_seed then
			local node = core.get_node (v)
			if node.name == "mcl_chests:chest_small" then
				local meta = core.get_meta (v)
				local pr = PcgRandom (loot_seed)
				local loot = mcl_loot.get_multi_loot (woodland_mansion_loot, pr)
				mcl_loot.fill_inventory (meta:get_inventory (),
							 "main", loot, pr)
			end
		end
	end
end

local staticdata = core.serialize ({
	_structure_generation_spawn = true,
	persistent = true,
})

local function handle_mansion_spawn_mob (_, mob)
	local x, y, z, mob_type
		= mob[1], mob[2], mob[3], mob[4]
	x, y, z = level_to_minetest_position (x, y, z)
	v.x = x
	v.y = y - 0.5
	v.z = z
	core.add_entity (v, mob_type, staticdata)
end

local function handle_mansion_specific_loot (_, loot)
	local x, y, z, stack, container, enchantment, level
		= loot[1], loot[2], loot[3], loot[4], loot[5], loot[6], loot[7]
	x, y, z = level_to_minetest_position (x, y, z)
	v.x = x
	v.y = y
	v.z = z

	local node = core.get_node (v)
	if node.name == container then
		mcl_structures.init_node_construct (v)
		local stack = ItemStack (stack)
		if enchantment then
			mcl_enchanting.enchant (stack, enchantment, level)
		end
		local meta = core.get_meta (v)
		local inv = meta:get_inventory ()
		inv:set_stack ("main", 1, stack)
	end
end

if core and not mcl_levelgen.is_levelgen_environment then
	for _, schematic in ipairs (schematics) do
		local name = "mcl_levelgen:woodland_mansion_" .. schematic
		local file = mcl_levelgen.prefix
			.. "/schematics/mcl_levelgen_woodland_mansion_"
			.. schematic .. ".mts"

		mcl_levelgen.register_portable_schematic (name, file, true)
	end
	mcl_levelgen.register_notification_handler ("mcl_levelgen:mansion_construct_node",
						    handle_mansion_construct_node)
	mcl_levelgen.register_notification_handler ("mcl_levelgen:mansion_spawn_mob",
						    handle_mansion_spawn_mob)
	mcl_levelgen.register_notification_handler ("mcl_levelgen:mansion_specific_loot",
						    handle_mansion_specific_loot)
end

------------------------------------------------------------------------
-- Woodland Mansion construction.
------------------------------------------------------------------------

local function getcid (name)
	if core and mcl_levelgen.is_levelgen_environment then
		return core.get_content_id (name)
	else
		-- Content IDs are not required outside level
		-- generation environments.
		return nil
	end
end

local floor = math.floor
local lshift = bit.lshift
local rshift = bit.rshift
local band = bit.band
local bor = bit.bor
local mathmin = math.min
local mathmax = math.max
local mathabs = math.abs
local insert = table.insert

-- Create an unoriented mansion grid (comprising 7x7 cubes) from RNG.
-- Generate the first and second stories and reserve the two cubes at
-- the center and near the southern side for an entrance, and generate
-- a randomized network of corridors within the grid.

local BASE_WIDTH = 11
local BASE_LENGTH = 11

local function gindex (grid, x, z)
	return grid.width * z + x + 1
end

local function in_grid (grid, x, z)
	return x >= 0 and z >= 0 and x < grid.width and z < grid.length
end

-- Special module types.

local ENTRANCE = "E"
local CORRIDOR = "C"
local ALLOCATED = "."

local n_allocated = 0
local n_total = 0

local function value (grid, x, z)
	if not in_grid (grid, x, z) then
		return ALLOCATED
	end

	return grid.modules[gindex (grid, x, z)]
end

local function allocate (grid, x, z, type)
	if not in_grid (grid, x, z) then
		return ALLOCATED
	end

	local index = gindex (grid, x, z)
	local modules = grid.modules
	local old = modules[index]
	if not old then
		modules[index] = (type or ALLOCATED)
		n_allocated = n_allocated + 1
	end
	return old
end

local function restore (grid, old, x, z)
	if not in_grid (grid, x, z) then
		return
	end
	local index = gindex (grid, x, z)
	local modules = grid.modules

	if modules[index] and not old then
		n_allocated = n_allocated - 1
	end
	modules[index] = old
	return
end

local function dir_forward (dir)
	if dir == "south" then
		return 0, 1
	elseif dir == "east" then
		return 1, 0
	elseif dir == "north" then
		return 0, -1
	elseif dir == "west" then
		return -1, 0
	end
end

local function dir_left (dir)
	if dir == "south" then
		return 1, 0, "east"
	elseif dir == "east" then
		return 0, -1, "north"
	elseif dir == "north" then
		return -1, 0, "west"
	elseif dir == "west" then
		return 0, 1, "south"
	end
end

local function dir_right (dir)
	if dir == "south" then
		return -1, 0, "west"
	elseif dir == "east" then
		return 0, 1, "south"
	elseif dir == "north" then
		return 1, 0, "east"
	elseif dir == "west" then
		return 0, -1, "north"
	end
end

local iterations = 0

local function default_stop_cond ()
	iterations = iterations + 1
	return n_allocated >= n_total - 15
		or iterations > 150000
end

local function secondary_stop_cond ()
	iterations = iterations + 1
	return iterations > 150000
end

local function route_corridors_1 (rng, grid, x, z, dir, limit, stop_cond,
				  stop_on_failure)
	local lx, lz, left = dir_left (dir)
	local rx, rz, right = dir_right (dir)
	local dx, dz = dir_forward (dir)

	if limit < 0 then
		return true
	end

	if not in_grid (grid, x, z)
		or value (grid, x, z) ~= nil
		or value (grid, x + lx, z + lz) == CORRIDOR
		or value (grid, x + rx, z + rz) == CORRIDOR then
		-- Contacting corridor or out of range?
		return false
	else
		-- Decide where to turn.
		local turndir = rng:next_within (20)
		if turndir <= 17 then
			turndir = 0
		else
			turndir = turndir - 17
		end
		local old_here = allocate (grid, x, z, CORRIDOR)
		if stop_cond () then
			allocate (grid, x + lx, z + lz)
			allocate (grid, x + rx, z + rz)
			return true
		end
		for i = 0, 2 do
			local d = (turndir + i) % 3

			if d == 0 and in_grid (grid, x + dx, z + dz) then
				-- Attempt to allocate elements to the
				-- left and right and move forward.
				local old_left = allocate (grid, x + lx, z + lz)
				local old_right = allocate (grid, x + rx, z + rz)
				if stop_cond () then
					if not value (grid, x + dx, z + dz) then
						allocate (grid, x + dx, z + dz)
					end
					return true
				elseif route_corridors_1 (rng, grid, x + dx, z + dz, dir,
							  limit - 1, stop_cond, stop_on_failure) then
					return true
				elseif stop_on_failure then
					if not value (grid, x + dx, z + dz) then
						allocate (grid, x + dx, z + dz)
					end
					return false
				else
					restore (grid, old_left, x + lx, z + lz)
					restore (grid, old_right, x + rx, z + rz)
				end
			elseif d == 1 and in_grid (grid, x + lx, z + lz) then
				-- Allocate elements along a left turn.
				local old_right = allocate (grid, x + rx, z + rz)
				local old_right_corner = allocate (grid, x + rx + dx,
								   z + rz + dz)
				local old_forward = allocate (grid, x + dx, z + dz)
				if stop_cond () then
					if not value (grid, x + lx, z + lz) then
						allocate (grid, x + lx, z + lz)
					end
					return true
				elseif route_corridors_1 (rng, grid, x + lx, z + lz, left,
							  limit - 1, stop_cond, stop_on_failure) then
					return true
				elseif stop_on_failure then
					if not value (grid, x + lx, z + lz) then
						allocate (grid, x + lx, z + lz)
					end
					return false
				else
					restore (grid, old_right, x + rx, z + rz)
					restore (grid, old_right_corner, x + rx + dx,
						 z + rz + dz)
					restore (grid, old_forward, x + dx, z + dz)
				end
			elseif d == 2 and in_grid (grid, x + rx, z + rz) then
				-- Allocate elements along a right turn.
				local old_left = allocate (grid, x + lx, z + lz)
				local old_left_corner = allocate (grid, x + lx + dx,
								  z + lz + dz)
				local old_forward = allocate (grid, x + dx, z + dz)
				if stop_cond () then
					if not value (grid, x + rx, z + rx) then
						allocate (grid, x + rx, z + rz)
					end
					return true
				elseif route_corridors_1 (rng, grid, x + rx, z + rz, right,
							  limit - 1, stop_cond, stop_on_failure) then
					return true
				elseif stop_on_failure then
					if not value (grid, x + rx, z + rz) then
						allocate (grid, x + lx, z + lz)
					end
					return false
				else
					restore (grid, old_left, x + lx, z + lz)
					restore (grid, old_left_corner, x + lx + dx,
						 z + lz + dz)
					restore (grid, old_forward, x + dx, z + dz)
				end
			end
		end
		if stop_on_failure then
			if not value (grid, x + dx, z + dz) then
				allocate (grid, x + dx, z + dz)
			end
			return false
		end
		restore (grid, old_here, x, z)
		return false
	end
end

-- local debug_corridors = {
-- 	{0, 0,},
-- 	{0, 1,},
-- 	{0, 2,},
-- 	{0, 3,},
-- 	{0, 4,},
-- 	{1, 0,},
-- 	{2, 0,},
-- 	{3, 0,},
-- 	{4, 0,},
-- 	{5, 0,},
-- }

local function route_corridors (rng, grid, entrance_x, entrance_z,
				exit_x, exit_z)
	n_allocated = 4
	n_total = grid.width * grid.length

	allocate (grid, entrance_x, entrance_z + 1)
	allocate (grid, entrance_x, entrance_z, CORRIDOR)
	allocate (grid, exit_x, entrance_z + 1)
	allocate (grid, exit_x, exit_z, CORRIDOR)

	-- for _, pos in ipairs (debug_corridors) do
	-- 	allocate (grid, pos[1], pos[2], CORRIDOR)
	-- end

	while true do
		iterations = 0
		if route_corridors_1 (rng, grid, entrance_x - 1,
				      entrance_z, "west", 216,
				      default_stop_cond, false) then
			break
		end
	end

	iterations = 0
	route_corridors_1 (rng, grid, exit_x + 1, exit_z, "east",
			   216, secondary_stop_cond, true)
end

local function M (schematic_name, processors)
	local name = "mcl_levelgen:woodland_mansion_" .. schematic_name
	return {
		name,
		processors,
	}
end

local function verify_schematics (sx, sz, modules)
	-- XXX: this is rather hideous: schematics are only verified
	-- when this file is loaded in the feature generation
	-- environment, as in the mapgen environment portable
	-- schematics are not available when structure definitions are
	-- first loaded.
	if mcl_levelgen.load_feature_environment then
		for _, module in ipairs (modules) do
			local schem = module[1]
			local x, _, z = mcl_levelgen.get_schematic_size (schem, "0")
			local blurb = schem .. "'s dimensions are different than expected: "
				.. x .. "," .. z .. ", not " .. sx .. "," .. sz
			assert (sx == x and sz == z, blurb)
		end
	end
	return modules
end

local is_cid_chest_or_wire = {}

for _, cid in ipairs (mcl_levelgen.construct_cid_list ({
	"group:chest_entity",
	"group:redstone_wire",
})) do
	is_cid_chest_or_wire[cid] = true
end

local cid_soul_torch
	= getcid ("mcl_blackstone:soul_torch") -- Vindicator.
local cid_soul_campfire_lit
	= getcid ("mcl_campfires:soul_campfire_lit") -- Evoker.
local cid_hanging_banner
	= getcid ("mcl_banners:hanging_banner") -- Evoker.
local notify_generated = mcl_levelgen.notify_generated
local cid_air = core and core.CONTENT_AIR or nil

local function default_processor (x, y, z, rng, cid_existing,
				  param2_existing, cid, param2)
	if is_cid_chest_or_wire[cid] or cid == cid_hanging_banner then
		notify_generated ("mcl_levelgen:mansion_construct_node", x, y, z,
				  { x, y, z, }, true)
	elseif cid == cid_soul_campfire_lit then
		notify_generated ("mcl_levelgen:mansion_spawn_mob", x, y, z,
				  { x, y, z, "mobs_mc:evoker", })
		return cid_air, 0
	elseif cid == cid_soul_torch then
		notify_generated ("mcl_levelgen:mansion_spawn_mob", x, y, z,
				  { x, y, z, "mobs_mc:vindicator", })
		return cid_air, 0
	end
	return cid, param2
end

local wall_processor = mcl_levelgen.wall_update_processor ()

local default_processors = {
	default_processor,
	wall_processor,
}

local function chest_loot_processor (x, y, z, rng, cid_existing,
				     param2_existing, cid, param2)
	if is_cid_chest_or_wire[cid] or cid == cid_hanging_banner then
		notify_generated ("mcl_levelgen:mansion_construct_node", x, y, z,
				  { x, y, z, mathabs (rng:next_integer ()), }, true)
	elseif cid == cid_soul_campfire_lit then
		notify_generated ("mcl_levelgen:mansion_spawn_mob", x, y, z,
				  { x, y, z, "mobs_mc:evoker", })
		return cid_air, 0
	elseif cid == cid_soul_torch then
		notify_generated ("mcl_levelgen:mansion_spawn_mob", x, y, z,
				  { x, y, z, "mobs_mc:vindicator", })
		return cid_air, 0
	end
	return cid, param2
end

local chest_loot_processors = {
	chest_loot_processor,
	wall_processor,
}

local function build_specific_loot_processor (stack, container_name,
					      enchantment, level)
	local cid_container = getcid (container_name)
	return function (x, y, z, rng, cid_existing,
			 param2_existing, cid, param2)
		if cid == cid_container then
			notify_generated ("mcl_levelgen:mansion_specific_loot", x, y, z, {
				x, y, z,
				stack, container_name, enchantment, level,
			})
		end
		return cid, param2
	end
end

local modules_first_storey = {
	single = verify_schematics (7, 7, {
		M ("flower_room", default_processors),
		M ("office", default_processors),
		M ("checkerboard", chest_loot_processors),
		M ("white_tulip_sanctuary", default_processors),
		M ("birch_office", default_processors),
		M ("single_bedroom", default_processors),
		M ("small_dining_room", default_processors),
		M ("small_library", default_processors),
		M ("allium_room", {
			build_specific_loot_processor ("mcl_flowers:allium 8",
						       "mcl_chests:chest_small"),
		}),
	}),
	double = verify_schematics (7, 15, {
		M ("wheat_farm", default_processors),
		M ("gray_banner", chest_loot_processors),
		M ("forge_room", default_processors),
		M ("pile_room", default_processors),
		M ("sapling_farm", {
			build_specific_loot_processor ("mcl_trees:sapling_dark_oak 26",
						       "mcl_chests:chest_small"),
		}),
		M ("melon_farm", default_processors),
		M ("small_storage_room", default_processors),
		M ("arch_hallway", chest_loot_processors),
		M ("winding_staircase", chest_loot_processors),
		M ("illager_head", default_processors),
		M ("medium_library", default_processors),
		M ("master_bedroom", default_processors),
		M ("bedroom_with_loft", chest_loot_processors),
		M ("altar", default_processors),
		M ("clean_chest", chest_loot_processors),
		M ("ersatz_portal", {
			build_specific_loot_processor ("mcl_throwing:ender_pearl 2",
						       "mcl_chests:trapped_chest_small"),
		}),
		M ("redstone_gaol", default_processors),
		M ("tree_chopping_room", {
			build_specific_loot_processor ("mcl_tools:axe_iron 1",
						       "mcl_chests:chest_small",
						       "efficiency", 1),
		}),
	}),
	quad = verify_schematics (15, 15, {
		M ("library", default_processors),
		M ("library", default_processors),
		M ("library", default_processors),
		M ("library", default_processors),
		M ("large_gaol", default_processors),
		M ("large_gaol", default_processors),
		M ("large_gaol", default_processors),
		M ("large_storage_room", default_processors),
		M ("large_storage_room", default_processors),
		M ("large_storage_room", default_processors),
		M ("large_storage_room", default_processors),
		M ("nature_room", default_processors),
		M ("nature_room", default_processors),
		M ("nature_room", default_processors),
		M ("nature_room", default_processors),
	}),
}

local modules_second_storey = {
	single = verify_schematics (7, 7, {
		M ("flower_room", default_processors),
		M ("office", default_processors),
		M ("checkerboard", chest_loot_processors),
		M ("white_tulip_sanctuary", default_processors),
		M ("birch_office", default_processors),
		M ("single_bedroom", default_processors),
		M ("small_dining_room", default_processors),
		M ("small_library", default_processors),
		M ("allium_room", {
			build_specific_loot_processor ("mcl_flowers:allium 8",
						       "mcl_chests:chest_small"),
		}),
	}),
	double = verify_schematics (7, 15, {
		M ("wheat_farm", default_processors),
		M ("gray_banner", chest_loot_processors),
		M ("forge_room", default_processors),
		M ("pile_room", default_processors),
		M ("sapling_farm", {
			build_specific_loot_processor ("mcl_trees:sapling_dark_oak 26",
						       "mcl_chests:chest_small"),
		}),
		M ("melon_farm", default_processors),
		M ("small_storage_room", default_processors),
		M ("arch_hallway", chest_loot_processors),
		M ("winding_staircase", chest_loot_processors),
		M ("illager_head", default_processors),
		M ("medium_library", default_processors),
		M ("master_bedroom", default_processors),
		M ("bedroom_with_loft", chest_loot_processors),
		M ("altar", default_processors),
		M ("ersatz_portal", {
			build_specific_loot_processor ("mcl_throwing:ender_pearl 2",
						       "mcl_chests:trapped_chest_small"),
		}),
		M ("redstone_gaol", default_processors),
		M ("hidden_attic", chest_loot_processors),
		M ("tree_chopping_room", {
			build_specific_loot_processor ("mcl_tools:axe_iron 1",
						       "mcl_chests:chest_small",
						       "efficiency", 1),
		}),
	}),
	quad = verify_schematics (15, 15, {
		M ("situation_room", default_processors),
		M ("situation_room", default_processors),
		M ("situation_room", default_processors),
		M ("situation_room", default_processors),
		M ("situation_room", default_processors),
		M ("situation_room", default_processors),
		M ("situation_room", default_processors),
		M ("large_dining_room", default_processors),
		M ("large_dining_room", default_processors),
		M ("large_dining_room", default_processors),
		M ("large_dining_room", default_processors),
		M ("large_dining_room", default_processors),
		M ("large_dining_room", default_processors),
		M ("large_dining_room", default_processors),
		M ("large_dining_room", default_processors),
	}),
}

local SINGLE = 0x1
local DOUBLE_0 = 0x2
local DOUBLE_90 = 0x4
local QUAD = 0x8

local function is_replaceable (grid, x, z)
	if in_grid (grid, x, z) then
		local value = value (grid, x, z)
		return value == nil or value == ALLOCATED
	end
	return false
end

local function is_corridor (grid, x, z)
	local value = value (grid, x, z)
	return value == CORRIDOR or (type (value) == "table"
				     and value.type == "corridor")
end

local function get_allocation (grid, x, z)
	local alloc = SINGLE
	local double_0_space_available = false
	local double_90_space_available = false

	if is_replaceable (grid, x, z + 1) then
		double_0_space_available = true
		-- Don't allocate an oblong module unless a corridor
		-- be present along one of its sides.
		if is_corridor (grid, x, z - 1)
			or is_corridor (grid, x, z + 2) then
			alloc = alloc + DOUBLE_0
		end
	end

	if is_replaceable (grid, x + 1, z) then
		double_90_space_available = true
		if is_corridor (grid, x - 1, z)
			or is_corridor (grid, x + 2, z) then
			alloc = alloc + DOUBLE_90
		end
	end

	if double_90_space_available
		and double_0_space_available
		and is_replaceable (grid, x + 1, z + 1) then
		alloc = alloc + QUAD
	end

	return alloc
end

local single_dirs = {
	{ "north", 0, -1, },
	{ "west", -1, 0, },
	{ "east", 1, 0, },
	{ "south", 0, 1, },
}

local function assign_single_module (grid, rng, module, x, z)
	-- What corridor to face?
	local corridors = {}

	for _, dir in ipairs (single_dirs) do
		local dx, dz = dir[2], dir[3]
		if is_corridor (grid, x + dx, z + dz) then
			insert (corridors, dir[1])
		end
	end

	if #corridors > 0 then
		local dir = corridors[1 + rng:next_within (#corridors)]
		return {
			module = module,
			facing = dir,
			type = "single",
		}
	else
		-- Otherwise, return a random orientation.
		local dir = single_dirs[1 + rng:next_within (4)][1]
		return {
			module = module,
			facing = dir,
			type = "single",
		}
	end
end

local function assign_double_module (grid, rng, module, x1, z1, x2, z2)
	local facing

	if x1 ~= x2 then
		assert (z1 == z2)
		-- DOUBLE_90

		local corridor_left
			= is_corridor (grid, x1 - 1, z1)
		local corridor_right
			= is_corridor (grid, x2 + 1, z1)

		if (corridor_left and not corridor_right)
			or (corridor_left and corridor_right
			    and rng:next_boolean ()) then
			facing = "west"
		else
			facing = "east"
		end
	else
		assert (x1 == x2 and z1 ~= z2)
		-- DOUBLE_0

		local corridor_forward
			= is_corridor (grid, x1, z1 + 1)
		local corridor_rear
			= is_corridor (grid, x1, z1 - 1)

		if (corridor_rear and not corridor_forward)
			or (corridor_rear and corridor_forward
			    and rng:next_boolean ()) then
			facing = "north"
		else
			facing = "south"
		end
	end

	return {
		module = module,
		facing = facing,
		type = "double",
		x = x1,
		z = z1,
	}
end

local quad_dirs = {
	{ "north", 0, -1, },
	{ "west", -1, 1, },
	{ "south", 1, 2, },
	{ "east", 2, 0, },
}

local function assign_quad_module (grid, rng, module, x, z)
	-- What corridor to face?
	local corridors = {}

	for _, dir in ipairs (quad_dirs) do
		local dx, dz = dir[2], dir[3]
		if is_corridor (grid, x + dx, z + dz) then
			insert (corridors, dir[1])
		end
	end

	if #corridors > 0 then
		local dir = corridors[1 + rng:next_within (#corridors)]
		return {
			module = module,
			facing = dir,
			type = "quad",
			x = x,
			z = z,
		}
	else
		-- Otherwise, return a random orientation.
		local dir = quad_dirs[1 + rng:next_within (4)][1]
		return {
			module = module,
			facing = dir,
			type = "quad",
			x = x,
			z = z,
		}
	end
end

local function classify_corridor (grid, x, z)
	local forward = is_corridor (grid, x, z + 1)
	local rear = is_corridor (grid, x, z - 1)
	local right = is_corridor (grid, x - 1, z)
	local left = is_corridor (grid, x + 1, z)

	if forward and rear and left and right then
		return "4way"
	elseif left and right and rear then
		return "3way_0"
	elseif left and forward and rear then
		return "3way_90"
	elseif left and right and forward then
		return "3way_180"
	elseif right and forward and rear then
		return "3way_270"
	elseif left and rear then
		return "left_0" -- Actually west.
	elseif left and forward then
		return "left_90"
	elseif right and rear then
		return "right_0" -- Actually east.
	elseif right and forward then
		return "right_270"
	elseif forward or rear then
		return "straight_0"
	else
		return "straight_90"
	end
end

local corridor_class_to_schematics = {
	["4way"] = { M ("corridor_4way"), "north", },
	["3way_0"] = { M ("corridor_3way"), "north", },
	["3way_90"] = { M ("corridor_3way"), "west", },
	["3way_180"] = { M ("corridor_3way"), "south", },
	["3way_270"] = { M ("corridor_3way"), "east", },
	["left_0"] = { M ("corridor_left"), "north", },
	["left_90"] = { M ("corridor_left"), "east", },
	["right_0"] = { M ("corridor_right"), "north", },
	["right_270"] = { M ("corridor_right"), "west", },
	["straight_0"] = { M ("corridor_straight"), "north", },
	["straight_90"] = { M ("corridor_straight"), "west", },
}

local function unpack2 (x)
	return x[1], x[2]
end

local foyer_module = M ("foyer")

local function assign_modules (rng, grid, module_list)
	local cnt_single = #module_list.single
	local cnt_double = #module_list.double
	local cnt_quad = #module_list.quad
	local modules = grid.modules

	for z = 0, grid.length - 1 do
		for x = 0, grid.width - 1 do
			local idx = gindex (grid, x, z)
			local current = modules[idx]
			if current == ALLOCATED then
				-- Measure the space available for
				-- this module.
				local allocation = get_allocation (grid, x, z)

				-- Select a module at random.
				local total = cnt_single
				local max_double = total
				local double_0 = band (allocation, DOUBLE_0) ~= 0
				local double_90 = band (allocation, DOUBLE_90) ~= 0
				local any_double = double_0 or double_90
				local any_quad
					= band (allocation, QUAD) ~= 0
				if any_double then
					total = total + cnt_double
					max_double = total
				end
				if any_quad then
					total = total + cnt_quad
				end

				local i = 1 + rng:next_within (total)
				if i <= cnt_single then
					local module = module_list.single[i]
					modules[idx] = assign_single_module (grid, rng, module, x, z)
				elseif i <= max_double then
					local x2, z2, idx_1
					i = i - cnt_single
					local module = module_list.double[i]
					if double_90 and double_0 then
						if rng:next_boolean () then
							idx_1 = gindex (grid, x + 1, z)
							x2, z2 = x + 1, z
						else
							idx_1 = gindex (grid, x, z + 1)
							x2, z2 = x, z + 1
						end
					elseif double_90 then
						idx_1 = gindex (grid, x + 1, z)
						x2, z2 = x + 1, z
					else
						idx_1 = gindex (grid, x, z + 1)
						x2, z2 = x, z + 1
					end
					modules[idx] = assign_double_module (grid, rng, module, x, z, x2, z2)
					modules[idx_1] = modules[idx]
				else
					i = i - max_double
					local module = module_list.quad[i]
					local idx1 = gindex (grid, x + 1, z)
					local idx2 = gindex (grid, x + 1, z + 1)
					local idx3 = gindex (grid, x, z + 1)
					modules[idx] = assign_quad_module (grid, rng, module, x, z)
					modules[idx1] = modules[idx]
					modules[idx2] = modules[idx]
					modules[idx3] = modules[idx]
				end
			elseif current == CORRIDOR then
				local class = classify_corridor (grid, x, z)
				local module, facing
					= unpack2 (corridor_class_to_schematics[class])
				modules[idx] = {
					type = "corridor",
					module = module,
					facing = facing,
				}
			elseif current == ENTRANCE then
				local idx_1 = gindex (grid, x + 1, z)
				local idx_2 = gindex (grid, x, z + 1)
				local idx_3 = gindex (grid, x + 1, z + 1)
				assert (modules[idx_1] == ENTRANCE
					and modules[idx_2] == ENTRANCE
					and modules[idx_3] == ENTRANCE)
				modules[idx] = {
					module = foyer_module,
					facing = "north",
					type = "entrance",
					x = x,
					z = z,
				}
				modules[idx_1] = modules[idx]
				modules[idx_2] = modules[idx]
				modules[idx_3] = modules[idx]
			end
		end
	end
end

local function is_broadly_quad (value)
	return value.type == "quad" or value.type == "entrance"
end

local function is_type_broadly_quad (type)
	return type == "quad" or type == "entrance"
end

-- local function print_grid (grid)
-- 	for z = grid.length - 1, 0, -1 do
-- 		local tbl = {}
-- 		for x = grid.width - 1, 0, -1 do
-- 			local value = grid.modules[gindex (grid, x, z)]
-- 			local char = value
-- 			if type (value) == "table" then
-- 				if value.type == "single" then
-- 					char = "S"
-- 				elseif value.type == "secret" then
-- 					char = "W"
-- 				elseif value.type == "corridor" then
-- 					char = "C"
-- 				elseif value.type == "double"
-- 					or value.type == "double_90" then
-- 					if x == value.x and z == value.z then
-- 						char = "D"
-- 					else
-- 						char = "d"
-- 					end
-- 				elseif value.type == "quad" then
-- 					if x == value.x and z == value.z then
-- 						char = "Q"
-- 					else
-- 						char = "q"
-- 					end
-- 				elseif value.type == "entrance" then
-- 						char = "E"
-- 				end
-- 			end
-- 			table.insert (tbl, (char or " ") .. " ")
-- 		end
-- 		print (table.concat (tbl))
-- 	end
-- end

local modules1
local modules2
local g_grid1
-- local g_grid2

local function is_allocated (x, z)
	if x < 0 or z < 0
		or z >= g_grid1.length or x >= g_grid1.width then
		return false
	end
	local idx = gindex (g_grid1, x, z)
	if modules1[idx] ~= nil or modules2[idx] ~= nil then
		return true
	end
	return false
end

local dir_flags = {
	north = 0x1,
	west = 0x2,
	south = 0x4,
	east = 0x8,
}

local function dir_opposite (dir)
	if dir == "west" then
		return 1, 0, "east"
	elseif dir == "north" then
		return 0, 1, "south"
	elseif dir == "east" then
		return -1, 0, "west"
	elseif dir == "south" then
		return 0, -1, "north"
	end
	assert (false)
end

local function dir_values (dir)
	if dir == "west" then
		return -1, 0, dir
	elseif dir == "north" then
		return 0, -1, dir
	elseif dir == "east" then
		return 1, 0, dir
	elseif dir == "south" then
		return 0, 1, dir
	end
	assert (false)
end

local CONCAVE = 0x4

local function outline_grids (grid1, grid2, x, z)
	local x_org, z_org = x, z
	local dx, dz, dir = -1, 0, "west"
	local sx, sz, side = 0, -1, "north"

	assert (grid1.length == grid2.length)
	assert (grid1.width == grid2.width)
	local width = grid1.width
	local outline = {}
	for i = 1, width * grid1.length do
		outline[i] = 0
	end

	modules1 = grid1.modules
	modules2 = grid2.modules
	g_grid1 = grid1
	-- g_grid2 = grid2
	repeat
		local x_next = x + dx
		local z_next = z + dz

		if is_allocated (x_next, z_next) then
			if not is_allocated (x_next + sx, z_next + sz) then
				local idx = width * z + x + 1
				x = x_next
				z = z_next
				outline[idx] = bor (outline[idx], dir_flags[side])
			else
				local idx = width * z + x + 1
				-- Concave corner.
				x = x_next + sx
				z = z_next + sz

				local new_sx, new_sz, new_side
					= dir_opposite (dir)
				dx, dz, dir = sx, sz, side
				outline[idx] = bor (outline[idx], dir_flags[side],
						    lshift (dir_flags[new_side], CONCAVE))

				local idx_1 = width * z + x + 1
				outline[idx_1]
					= bor (outline[idx_1], lshift (dir_flags[side],
								       CONCAVE))
				sx, sz, side = new_sx, new_sz, new_side
			end
		else
			-- Convex corner:
			--   ----> (~side)
			-- G G G ...
			-- G
			-- G
			-- G

			local idx = width * z + x + 1
			local dx_1, dz_1, dir_1 = dir_opposite (side)
			outline[idx] = bor (outline[idx], dir_flags[side],
					    dir_flags[dir])
			if is_allocated (x + dx_1, z + dz_1) then
				x = x + dx_1
				z = z + dz_1
				sx, sz, side = dx, dz, dir
				dx, dz, dir = dx_1, dz_1, dir_1
			else
				-- Return in reverse.
				dx, dz, dir = dir_opposite (dir)
				sx, sz, side = dx_1, dz_1, dir_1
			end
		end
	until (x == x_org and z == z_org)
	return outline
end

-- local function print_outline (outline, grid)
-- 	for z = grid.length - 1, 0, -1 do
-- 		local tbl = {}
-- 		for x = grid.width - 1, 0, -1 do
-- 			local idx = gindex (grid, x, z)
-- 			table.insert (tbl, string.format ("%2x", outline[idx]) or "  ")
-- 		end
-- 		print (table.concat (tbl))
-- 	end
-- end

local outline_rotations_90 = {
	[0] = 0,
}
local outline_rotations_180 = {
	[0] = 0,
}

for i = 0x1, 0xf do
	local output_90 = 0
	local output_180 = 0

	if band (i, dir_flags.north) ~= 0 then
		output_90 = output_90 + dir_flags.east
		output_180 = output_180 + dir_flags.south
	end

	if band (i, dir_flags.east) ~= 0 then
		output_90 = output_90 + dir_flags.south
		output_180 = output_180 + dir_flags.west
	end

	if band (i, dir_flags.south) ~= 0 then
		output_90 = output_90 + dir_flags.west
		output_180 = output_180 + dir_flags.north
	end

	if band (i, dir_flags.west) ~= 0 then
		output_90 = output_90 + dir_flags.north
		output_180 = output_180 + dir_flags.east
	end
	outline_rotations_90[i] = output_90
	outline_rotations_180[i] = output_180
end

local EAST = dir_flags.east
local WEST = dir_flags.west

local NORTH = dir_flags.north
local SOUTH = dir_flags.south

local function dir_horizontal_p (dir)
	return dir == "east" or dir == "west"
end

local rotated = {}

local function rotate_module (value, arg, oldwidth, oldlength)
	-- If this is a module proper, reorient it accordingly.  A
	-- second pass will correct the origins of doubles and quads.

	if value and value.facing and not rotated[value] then
		rotated[value] = true
		if arg == "180" then
			local _, _, opposite = dir_opposite (value.facing)
			value.facing = opposite

			-- Calculate the rotated origin of this
			-- module.
			if value.type == "double" then
				if dir_horizontal_p (opposite) then
					local x = oldwidth - (value.x + 1) - 1
					local z = oldlength - value.z - 1
					value.x = x
					value.z = z
				else
					local x = oldwidth - value.x - 1
					local z = oldlength - (value.z + 1) - 1
					value.x = x
					value.z = z
				end
			elseif is_broadly_quad (value) then
				local x = oldwidth - (value.x + 1) - 1
				local z = oldlength - (value.z + 1) - 1
				value.x = x
				value.z = z
			end
		elseif arg == "90" then
			local facing = value.facing
			if facing == "north" then
				facing = "east"
			elseif facing == "east" then
				facing = "south"
			elseif facing == "south" then
				facing = "west"
			elseif facing == "west" then
				facing = "north"
			end

			if value.type == "double" then
				if dir_horizontal_p (value.facing) then
					local x = oldlength - value.z - 1
					local z = value.x
					value.x = x
					value.z = z
				else
					local x = oldlength - (value.z + 1) - 1
					local z = value.x
					value.x = x
					value.z = z
				end
			elseif is_broadly_quad (value) then
				local z = value.x
				local x = oldlength - (value.z + 1) - 1
				value.x = x
				value.z = z
			end
			value.facing = facing
		end
	end
	return value
end

local function rotate_outline (value, arg, _, _)
	if arg == "90" then
		local sides = band (value, 0xf)
		local concave = rshift (value, 4)
		return bor (outline_rotations_90[sides],
			    lshift (outline_rotations_90[concave],
				    CONCAVE))
	elseif arg == "180" then
		local sides = band (value, 0xf)
		local concave = rshift (value, 4)
		return bor (outline_rotations_180[sides],
			    lshift (outline_rotations_180[concave],
				    CONCAVE))
	else
		assert (false)
	end
end

local function rot90 (data, width, length, apply)
	local array = {}

	for dx = 0, length - 1 do
		for dz = 0, width - 1 do
			local dst_idx = dx * length + dz + 1
			local src_x = (width - dz - 1)
			local src_z = dx
			local src_idx = src_x * width + src_z + 1
			array[dst_idx] = apply (data[src_idx], "90", width, length)
		end
	end
	return array
end

local function rot180 (data, width, length, apply)
	local w_half = floor (width / 2)
	local l_half = floor (length / 2)
	local l_odd = (l_half * 2) ~= length

	-- Swap Z.
	for x = 0, width - 1 do
		for z = 0, l_half - 1 do
			local other = length - z - 1
			local idx_1 = z * width + x + 1
			local idx_2 = other * width + x + 1
			local a, b = apply (data[idx_2], "180", width, length),
				apply (data[idx_1], "180", width, length)
			data[idx_1], data[idx_2] = a, b
		end

		if l_odd then
			local idx = l_half * width + x + 1
			data[idx] = apply (data[idx], "180", width, length)
		end
	end

	-- Swap X.
	for z = 0, length - 1 do
		for x = 0, w_half - 1 do
			local other = width - x - 1
			local idx_1 = z * width + x + 1
			local idx_2 = z * width + other + 1
			data[idx_1], data[idx_2] = data[idx_2], data[idx_1]
		end
	end
end

local function rotate_1 (outline, width, length, rot, apply)
	if rot == "0" then
		return outline, width, length
	elseif rot == "90" then
		outline = rot90 (outline, width, length, apply)
		rotated = {}
		return outline, length, width
	elseif rot == "180" then
		rot180 (outline, width, length, apply)
		rotated = {}
		return outline, width, length
	elseif rot == "270" then
		rot180 (outline, width, length, apply)
		rotated = {}
		outline = rot90 (outline, width, length, apply)
		rotated = {}
		return outline, length, width
	end
	assert (false)
end

local function rotate_grids_and_outline (grid1, grid2, outline, rot)
	grid1.modules, grid1.width, grid1.length
		= rotate_1 (grid1.modules, grid1.width, grid1.length, rot,
			    rotate_module)
	grid2.modules, grid2.width, grid2.length
		= rotate_1 (grid2.modules, grid2.width, grid2.length, rot,
			    rotate_module)
	local outline, _, _
		= rotate_1 (outline, grid1.width, grid1.length, rot,
			    rotate_outline)
	return outline
end

-- Create additional secret rooms in spaces created by the outline.

local cid_mob_spawner = getcid ("mcl_mobspawners:spawner")

local function instantiate_spider_spawners (x, y, z, rng, cid_existing,
					    param2_existing, cid, param2)
	if cid == cid_mob_spawner then
		notify_generated ("mcl_levelgen:mob_spawner_constructor", x, y, z, {
			x = x,
			y = y,
			z = z,
			mob = "mobs_mc:spider",
		})
	end
	return cid, param2
end

local secret_rooms = {
	M ("spider", {
		instantiate_spider_spawners,
	}),
	M ("pumpkin_ring"),
	M ("x_room", chest_loot_processors),
	M ("obsidian_room"),
	M ("birch_pillar_room"),
}

local function alloc_secret_room (rng)
	local idx = 1 + rng:next_within (#secret_rooms)
	local dir = single_dirs[1 + rng:next_within (4)][1]
	return {
		module = secret_rooms[idx],
		facing = dir,
		type = "secret",
	}
end

local function fill_winding (rng, grid1, grid2, outline)
	local length = grid2.length
	local width = grid2.width
	local m1 = grid1.modules
	local m2 = grid2.modules

	for z = 0, length - 1 do
		local winding = false
		local base = z * width + 1

		for x = 0, length - 1 do
			local idx = base + x
			local value = outline[idx]

			if band (value, WEST) ~= 0 then
				winding = true
			end

			if winding and not m1[idx] then
				m1[idx] = alloc_secret_room (rng)
			end
			if winding and not m2[idx] then
				m2[idx] = alloc_secret_room (rng)
			end

			if band (value, EAST) ~= 0 then
				winding = false
			end
		end
	end
end

function mcl_levelgen.prepare_mansion_grid (rng, rot)
	local grids = {
		{
			width = BASE_WIDTH,
			length = BASE_LENGTH,
			modules = {},
		},
		{
			width = BASE_WIDTH,
			length = BASE_LENGTH,
			modules = {},
		},
	}

	local center = floor (BASE_WIDTH / 2)
	grids[1].modules[center + 1] = ENTRANCE
	grids[1].modules[center + 2] = ENTRANCE
	grids[1].modules[BASE_LENGTH + center + 1] = ENTRANCE
	grids[1].modules[BASE_LENGTH + center + 2] = ENTRANCE
	grids[2].modules[center + 1] = ENTRANCE
	grids[2].modules[center + 2] = ENTRANCE
	grids[2].modules[BASE_LENGTH + center + 1] = ENTRANCE
	grids[2].modules[BASE_LENGTH + center + 2] = ENTRANCE

	route_corridors (rng, grids[1], center - 1, 0, center + 2, 0)
	route_corridors (rng, grids[2], center - 1, 0, center + 2, 0)
	assign_modules (rng, grids[1], modules_first_storey)
	assign_modules (rng, grids[2], modules_second_storey)
	local outline = outline_grids (grids[1], grids[2], center, 0)
	fill_winding (rng, grids[1], grids[2], outline)
	outline = rotate_grids_and_outline (grids[1], grids[2], outline, rot)
	-- print_grid (grids[1])
	-- print ("=========================")
	-- print_grid (grids[2])
	-- print_outline (outline, grids[1])
	return grids, outline
end

local prepare_mansion_grid = mcl_levelgen.prepare_mansion_grid

-- First floor: 8 nodes.
-- Second floor: 11 nodes.

------------------------------------------------------------------------
-- Woodland Mansion structure.
------------------------------------------------------------------------

local FIRST_STORY_HEIGHT = 8
local SECOND_STORY_HEIGHT = 11

local rotations = {
	"0",
	"90",
	"180",
	"270",
}

local height_of_lowest_corner_including_center
	= mcl_levelgen.height_of_lowest_corner_including_center
local structure_biome_test = mcl_levelgen.structure_biome_test
local huge = math.huge

local cid_cobblestone = getcid ("mcl_core:cobble")

-- Wall on two sides, 7x7 module occupying the interior.
local GRID_UNIT = 8

local ipos4 = mcl_levelgen.make_ipos_iterator ()
local ipos3 = mcl_levelgen.ipos3
local set_block = mcl_levelgen.set_block

local function fill_area (x1, y1, z1, x2, y2, z2, cid, param2)
	for x, y, z in ipos3 (mathmin (x1, x2),
			      y1,
			      mathmin (z1, z2),
			      mathmax (x1, x2),
			      y2,
			      mathmax (z1, z2)) do
		set_block (x, y, z, cid, param2)
	end
end

local cid_dark_oak_wood = getcid ("mcl_trees:wood_dark_oak")
local cid_stairs_dark_oak = getcid ("mcl_stairs:stair_dark_oak")
local cid_stairs_dark_oak_outer = getcid ("mcl_stairs:stair_dark_oak_outer")
-- local cid_stairs_dark_oak_inner = getcid ("mcl_stairs:stair_dark_oak_inner")
local place_schematic = mcl_levelgen.place_schematic
local push_schematic_processor = mcl_levelgen.push_schematic_processor
local push_schematic_processors = mcl_levelgen.push_schematic_processors
local pop_schematic_processors = mcl_levelgen.pop_schematic_processors
local index_heightmap = mcl_levelgen.index_heightmap

local function mansion_wall_place (self, level, terrain, rng, x1, z1, x2, z2)
	-- Which grid positions intersect this region?

	local x, y, z = self.x, self.y, self.z
	-- Include the eaves of grid positions at the edges.
	local gx1 = mathmax (self.xmin, floor ((x1 - 4 - x) / GRID_UNIT))
	local gz1 = mathmax (self.zmin, floor ((z1 - 4 - z) / GRID_UNIT))
	local gx2 = mathmin (self.xmax, floor ((x2 + 4 - x) / GRID_UNIT))
	local gz2 = mathmin (self.zmax, floor ((z2 + 4 - z) / GRID_UNIT))

	local ymax_wall = y + FIRST_STORY_HEIGHT + SECOND_STORY_HEIGHT - 1
	local outline = self.outline
	local modules_1 = self.grid_1.modules
	local modules_2 = self.grid_2.modules

	for gx, _, gz in ipos4 (gx1, 0, gz1, gx2, 0, gz2) do
		local idx = gz * BASE_WIDTH + gx + 1
		local value = outline[idx]

		local ix1 = x + gx * GRID_UNIT
		local iz1 = z + gz * GRID_UNIT
		local ix2 = ix1 + GRID_UNIT
		local iz2 = iz1 + GRID_UNIT
		local north = band (value, NORTH) ~= 0
		local south = band (value, SOUTH) ~= 0
		local west = band (value, WEST) ~= 0
		local east = band (value, EAST) ~= 0
		local schem = "mcl_levelgen:woodland_mansion_exterior_wall"
		local schem_flipped = "mcl_levelgen:woodland_mansion_exterior_wall_flipped"
		local module_a = modules_1[idx]
		local module_a_foyer_facing = module_a
			and module_a.type == "entrance"
			and module_a.facing

		local depth = push_schematic_processor (wall_processor)
		if north and module_a_foyer_facing ~= "north" then
			place_schematic (ix1, y, iz1 - 1, schem_flipped, "0", true, nil, rng)
		end
		if south and module_a_foyer_facing ~= "south" then
			place_schematic (ix1, y, iz2, schem, "0", true, nil, rng)
		end
		if west and module_a_foyer_facing ~= "west" then
			place_schematic (ix1 - 1, y, iz1, schem, "90", true, nil, rng)
		end
		if east and module_a_foyer_facing ~= "east" then
			place_schematic (ix2, y, iz1, schem_flipped, "90", true, nil, rng)
		end
		pop_schematic_processors (depth)

		-- local concave = rshift (value, CONCAVE)
		-- local north_concave = band (concave, NORTH) ~= 0
		-- local west_concave = band (concave, WEST) ~= 0
		-- local south_concave = band (concave, SOUTH) ~= 0
		-- local east_concave = band (concave, EAST) ~= 0

		-- Ceiling.
		if module_a or modules_2[idx] then
			fill_area (ix1, ymax_wall + 1, iz1, ix2, ymax_wall + 3, iz2,
				   cid_dark_oak_wood, 0)

			-- Create a solid cobblestone foundation.
			for x, _, z in ipos3 (mathmax (x1, ix1 - 1),
					      0,
					      mathmax (z1, iz1 - 1),
					      mathmin (x2, ix2 + 1),
					      0,
					      mathmin (z2, iz2 + 1)) do
				local surface, _ = index_heightmap (x, z, true)
				for y = y - 1, surface, -1 do
					set_block (x, y, z, cid_cobblestone, 0)
				end
			end
		end

		-- Eaves.  TODO: handle inner corners without dividing
		-- ceilings and eaves into separate passes.

		if north then
			for dz = 0, 2 do
				local cycle_length = GRID_UNIT + dz

				local ix2 = ix1 + cycle_length
				local ix1 = ix1 - dz

				if west then
					ix1 = ix1 + 1
				end

				local y  = ymax_wall + 3 - dz
				local z  = iz1 - dz
				fill_area (ix1, y, z, ix2, y, z, cid_stairs_dark_oak, 2)

				if east then
					set_block (ix2, y, z, cid_stairs_dark_oak_outer, 3)
				end
			end
		end

		if east then
			for dx = 0, 2 do
				local cycle_length = GRID_UNIT + dx

				local iz2 = iz1 + cycle_length
				local iz1 = iz1 - dx
				if north then
					iz1 = iz1 + 1
				end
				local y = ymax_wall + 3 - dx
				local x = ix1 + GRID_UNIT + dx
				fill_area (x, y, iz1, x, y, iz2, cid_stairs_dark_oak, 3)

				if south then
					set_block (x, y, iz2, cid_stairs_dark_oak_outer, 0)
				end
			end
		end

		if south then
			for dz = 0, 2 do
				local cycle_length = GRID_UNIT + dz

				local ix1 = ix2 - cycle_length
				local ix2 = ix2 + dz

				if east then
					ix2 = ix2 - 1
				end

				local y  = ymax_wall + 3 - dz
				local z  = iz1 + GRID_UNIT + dz
				fill_area (ix1, y, z, ix2, y, z, cid_stairs_dark_oak, 0)

				if west then
					set_block (ix1, y, z, cid_stairs_dark_oak_outer, 1)
				end
			end
		end

		if west then
			for dx = 0, 2 do
				local cycle_length = GRID_UNIT + dx

				local iz1 = iz2 - cycle_length
				local iz2 = iz2 + dx
				if south then
					iz2 = iz2 - 1
				end
				local y = ymax_wall + 3 - dx
				local x = ix1 - dx
				fill_area (x, y, iz1, x, y, iz2, cid_stairs_dark_oak, 1)

				if north then
					set_block (x, y, iz1, cid_stairs_dark_oak_outer, 2)
				end
			end
		end
	end
end

local function prepare_mansion_wall (outline, grids, x, y, z)
	local xmin = huge
	local xmax = -huge
	local zmin = huge
	local zmax = -huge

	for dx = 0, BASE_WIDTH - 1 do
		for dz = 0, BASE_LENGTH - 1 do
			local idx = dz * BASE_WIDTH + dx
			local value = outline[idx]

			if value ~= 0 then
				zmin = mathmin (zmin, dz)
				zmax = mathmax (zmax, dz)
				xmin = mathmin (xmin, dx)
				xmax = mathmax (xmax, dx)
			end
		end
	end

	return {
		place = mansion_wall_place,
		bbox = {
			x + (xmin * GRID_UNIT) - 4,
			y,
			z + (zmin * GRID_UNIT) - 4,
			x + (xmax * GRID_UNIT + 8) + 4,
			y + FIRST_STORY_HEIGHT + SECOND_STORY_HEIGHT + 2,
			z + (zmax * GRID_UNIT + 8) + 4,
		},
		outline = outline,
		x = x,
		y = y,
		z = z,
		grid_1 = grids[1],
		grid_2 = grids[2],
		xmin = xmin,
		zmin = zmin,
		xmax = xmax,
		zmax = zmax,
		mansion_type = "mansion_wall",
	}, xmin, xmax, zmin, zmax
end

local function prior_placement_test (x, z, gx, gz, gx1, gz1, gx2, gz2)
	return x >= gx1
		and x <= gx2
		and z >= gz1
		and z <= gz2
		and (x < gx or (x == gx and z < gz))
end

local function module_already_placed_p (gx, gz, gx1, gz1, gx2, gz2, mod)
	local modtype = mod.type
	if modtype == "single" or modtype == "secret" or modtype == "corridor" then
		return false
	else
		-- It is possible to establish whether a module has
		-- already been placed by establishing whether any
		-- component of the module within (GX1, GZ1) - (GX2,
		-- GZ2) comes before (GX, GZ).

		if modtype == "double" and dir_horizontal_p (mod.facing) then
			local x0, z0 = mod.x, mod.z
			local x1 = x0 + 1

			return prior_placement_test (x0, z0, gx, gz, gx1, gz1, gx2, gz2)
				or prior_placement_test (x1, z0, gx, gz, gx1, gz1, gx2, gz2)
		elseif modtype == "double" then
			local x0, z0 = mod.x, mod.z
			local z1 = z0 + 1

			return prior_placement_test (x0, z0, gx, gz, gx1, gz1, gx2, gz2)
				or prior_placement_test (x0, z1, gx, gz, gx1, gz1, gx2, gz2)
		elseif is_type_broadly_quad (modtype) then
			local x0, z0 = mod.x, mod.z
			local x1, z1 = mod.x + 1, mod.z
			local x2, z2 = mod.x, mod.z + 1
			local x3, z3 = mod.x + 1, mod.z + 1
			return prior_placement_test (x0, z0, gx, gz, gx1, gz1, gx2, gz2)
				or prior_placement_test (x1, z1, gx, gz, gx1, gz1, gx2, gz2)
				or prior_placement_test (x2, z2, gx, gz, gx1, gz1, gx2, gz2)
				or prior_placement_test (x3, z3, gx, gz, gx1, gz1, gx2, gz2)
		end
	end
	assert (false)
end

local facing_to_rotation = {
	north = "180",
	south = "0",
	west = "90",
	east = "270",
}

local function is_initial_origin (facing, mod_b, bx, bz)
	if facing == "north" then
		return bx == mod_b.x and bz == mod_b.z
	elseif facing == "east" then
		return bx == mod_b.x + 1 and bz == mod_b.z
	elseif facing == "south" then
		return bx == mod_b.x + 1 and bz == mod_b.z + 1
	elseif facing == "west" then
		return bx == mod_b.x and bz == mod_b.z + 1
	end
	assert (false)
end

local function corridor_test (ax, az, bx, bz, mod_a, mod_b)
	if mod_a.type == "corridor" then
		local facing = mod_b.facing
		if facing then
			if mod_b.type == "quad"
				and not is_initial_origin (facing, mod_b, bx, bz) then
				return false
			end
			if mod_b.type == "secret" then
				return false
			end
			local dx, dz, _ = dir_values (facing)
			if bx + dx == ax and bz + dz == az then
				return true
			end
		end
	end
	return false
end

local mansion_rot

local function place_walls (x1, y1, z1, y2, modules, mod_x, mod_z, lengthwise, rng)
	-- Establish what it is that this wall separates.  If both
	-- sides are corridors, generate a corridor_separator.

	local idx_a = mod_z * BASE_WIDTH + mod_x + 1
	local mod_a = modules[idx_a]
	local mod_b, bx, bz
	local check_entrance

	if lengthwise then
		mod_b = modules[idx_a - 1]
		bx = mod_x - 1
		bz = mod_z
		check_entrance = (mansion_rot == "0" or mansion_rot == "180")
	else
		mod_b = modules[idx_a - BASE_WIDTH]
		bz = mod_z - 1
		bx = mod_x
		check_entrance = (mansion_rot == "90" or mansion_rot == "270")
	end

	local schem, rotation
	if mod_a == mod_b then
		return
	elseif check_entrance and mod_a	and mod_b
		and (mod_a.type == "corridor" and mod_b.type == "entrance"
		     or mod_b.type == "corridor" and mod_a.type == "entrance") then
		rotation = lengthwise and "90" or "0"
		schem = "mcl_levelgen:woodland_mansion_carpet_strip"
	elseif mod_a and mod_b
		and mod_a.type == "corridor"
		and mod_b.type == "corridor" then
		schem = "mcl_levelgen:woodland_mansion_corridor_separator"
		rotation = lengthwise and "90" or "0"
	-- If one side is a corridor and the other is a module facing
	-- it, generate a door.
	elseif mod_a and mod_b then
		local b_corridor = corridor_test (mod_x, mod_z, bx, bz, mod_a, mod_b)
		if b_corridor then
			schem = "mcl_levelgen:woodland_mansion_door"
			rotation = lengthwise and "270" or "180"
		elseif corridor_test (bx, bz, mod_x, mod_z, mod_b, mod_a) then
			schem = "mcl_levelgen:woodland_mansion_door"
			rotation = lengthwise and "270" or "180"
		else
			schem = "mcl_levelgen:woodland_mansion_wall"
			rotation = lengthwise and "90" or "0"
		end
	else
		schem = "mcl_levelgen:woodland_mansion_wall"
		rotation = lengthwise and "90" or "0"
	end
	place_schematic (x1, y1, z1, schem, rotation, true, nil, rng)

	-- Replace the remainder with dark oak wood.
	if y2 >= y1 + FIRST_STORY_HEIGHT then
		if lengthwise then
			fill_area (x1, y1 + FIRST_STORY_HEIGHT, z1,
				   x1, y2, z1 + GRID_UNIT - 1,
				   cid_dark_oak_wood, 0)
		else
			fill_area (x1, y1 + FIRST_STORY_HEIGHT, z1,
				   x1 + GRID_UNIT - 1, y2, z1,
				   cid_dark_oak_wood, 0)
		end
	end
end

local get_schematic_size = mcl_levelgen.get_schematic_size

local function place_module (self, x, y, z, mod, gx, gz, rng)
	local module = mod.module
	local schematic = module[1]
	local processors = module[2]
	local y1 = self.bbox[5]
	local mod_x = mod.x or gx
	local mod_z = mod.z or gz
	local x = x + mod_x * GRID_UNIT + 1
	local z = z + mod_z * GRID_UNIT + 1
	local rotation = facing_to_rotation[mod.facing]
	if processors then
		local depth = push_schematic_processors (processors)
		place_schematic (x, y, z, schematic, rotation,
				 true, nil, rng)
		pop_schematic_processors (depth)
	else
		place_schematic (x, y, z, schematic, rotation,
				 true, nil, rng)
	end

	local sx, sy, sz = get_schematic_size (schematic, rotation)
	-- Fill any areas left unaltered by the schematic with air.
	if y + sy <= y1 then
		fill_area (x, y + sy, z, x + sx - 1, y1, z + sz - 1,
			   cid_air, 0)
	end
end

local function place_module_walls (self, x, y, z, modules, mod_x, mod_z, rng)
	-- Place the module's walls, if appropriate.
	local y1 = self.bbox[5]

	local x = x + mod_x * GRID_UNIT
	local z = z + mod_z * GRID_UNIT
	if mod_x > 0 then
		place_walls (x, y, z, y1, modules, mod_x, mod_z, true, rng)
	end

	if mod_z > 0 then
		place_walls (x, y, z, y1, modules, mod_x, mod_z, false, rng)
	end
end

local function mansion_storey_place (self, level, terrain, rng, x1, z1, x2, z2)
	local x, y, z = self.x, self.y, self.z
	local gx1 = mathmax (floor ((x1 - x) / GRID_UNIT), self.xmin)
	local gz1 = mathmax (floor ((z1 - z) / GRID_UNIT), self.zmin)
	local gx2 = mathmin (floor ((x2 - x) / GRID_UNIT), self.xmax)
	local gz2 = mathmin (floor ((z2 - z) / GRID_UNIT), self.zmax)
	local ignore_foyer = self.ignore_foyer
	mansion_rot = self.rotation

	local modules = self.grid.modules
	for gx, _, gz in ipos4 (gx1, 0, gz1, gx2, 0, gz2) do
		local idx = gz * BASE_WIDTH + gx + 1
		local mod = modules[idx]

		if mod then
			local modtype = type (mod)
			if modtype == "table" then
				if not module_already_placed_p (gx, gz, gx1, gz1,
								gx2, gz2, mod)
					and (not ignore_foyer
					     or mod.type ~= "entrance") then
					place_module (self, x, y, z, mod, gx, gz, rng)
				end
				place_module_walls (self, x, y, z, modules, gx, gz, rng)
			end
		end
	end
end

local function prepare_mansion_storey (grid, x, y, z, xmin, xmax,
				       zmin, zmax, ignore_foyer, rot)
	return {
		place = mansion_storey_place,
		bbox = {
			x + (xmin * GRID_UNIT + 1),
			y,
			z + (zmin * GRID_UNIT + 1),
			x + (xmax * GRID_UNIT + 7),
			y + (ignore_foyer
			     and SECOND_STORY_HEIGHT
			     or FIRST_STORY_HEIGHT) - 1,
			z + (zmax * GRID_UNIT + 7),
		},
		x = x,
		y = y,
		z = z,
		grid = grid,
		xmin = xmin,
		zmin = zmin,
		xmax = xmax,
		zmax = zmax,
		ignore_foyer = ignore_foyer,
		mansion_type = "mansion_storey",
		rotation = rot,
	}
end

local create_structure_start = mcl_levelgen.create_structure_start
local make_schematic_piece = mcl_levelgen.make_schematic_piece

local function prepare_mansion_foyer_wall (grid, x, y, z, xmin, zmin, rot, rng)
	-- Locate the foyer.
	local fx, fz = nil
	for dx = 0, grid.width - 1 do
		for dz = 0, grid.length - 1 do
			local foyer = value (grid, dx, dz)
			if foyer and foyer.type == "entrance" then
				fx, fz = dx, dz
				break
			end
		end
		if fx then
			break
		end
	end

	assert (fx and fz)

	local foyer_min_x, foyer_min_z, foyer_schem
	if rot == "0" or rot == "90" then
		if rot == "0" then
			foyer_min_x = (fx) * GRID_UNIT
			foyer_min_z = (fz) * GRID_UNIT - 5
		else
			foyer_min_x = (fx + 1) * GRID_UNIT + GRID_UNIT
			foyer_min_z = (fz) * GRID_UNIT
		end
		foyer_schem = "mcl_levelgen:woodland_mansion_entrance_facade_flipped"
	else
		if rot == "270" then
			foyer_min_x = (fx) * GRID_UNIT - 5
			foyer_min_z = (fz) * GRID_UNIT
		else
			foyer_min_x = (fx) * GRID_UNIT
			foyer_min_z = (fz + 1) * GRID_UNIT + GRID_UNIT
		end
		foyer_schem = "mcl_levelgen:woodland_mansion_entrance_facade"
	end

	local schematic_rot
	if rot == "0" or rot == "180" then
		schematic_rot = "0"
	else
		schematic_rot = "90"
	end

	foyer_min_x = x + foyer_min_x
	foyer_min_z = z + foyer_min_z
	return make_schematic_piece (foyer_schem, foyer_min_x, y, foyer_min_z,
				     schematic_rot, rng, false, true, nil, nil,
				     nil)
end

local overworld_factory = mcl_levelgen.overworld_preset.factory
local mansion_rng = overworld_factory ("mcl_levelgen:mansions"):fork_positional ()
mansion_rng = mansion_rng:create_reseedable ()

local function woodland_mansion_create_start (self, level, terrain, rng, cx, cz)
	local rot = rotations[1 + rng:next_within (4)]
	local lowest = height_of_lowest_corner_including_center (terrain, cx, cz, rot)
	if lowest < 60 then
		return nil
	else
		local x = cx * 16 + 7
		local z = cz * 16 + 7
		local y = lowest
		local pieces = {}

		if structure_biome_test (level, self, x, y, z) then
			x = x - 50
			z = z - 50

			-- The JVM LCG's quality is not sufficient to
			-- generate interesting mansions.
			mansion_rng:reseed_positional (cx, y, cz)
			local rng = mansion_rng
			local grids, outline
				= prepare_mansion_grid (rng, rot)
			local wall_piece, xmin, xmax, zmin, zmax
				= prepare_mansion_wall (outline, grids, x, y, z)
			local piece_bottom
				= prepare_mansion_storey (grids[1], x, y, z,
							  xmin, xmax, zmin, zmax,
							  false, rot)
			local piece_top
				= prepare_mansion_storey (grids[2], x,
							  y + FIRST_STORY_HEIGHT,
							  z,
							  xmin, xmax, zmin, zmax,
							  true, rot)
			local foyer_wall_piece
				= prepare_mansion_foyer_wall (grids[1], x, y, z,
							      xmin, zmin, rot, rng)
			insert (pieces, piece_bottom)
			insert (pieces, piece_top)
			insert (pieces, wall_piece)
			insert (pieces, foyer_wall_piece)
			local start = create_structure_start (self, pieces)
			return start
		end
		return nil
	end
end

------------------------------------------------------------------------
-- Woodland Mansion registration.
------------------------------------------------------------------------

local has_woodland_mansion = {
	"DarkForest",
}

mcl_levelgen.modify_biome_groups (has_woodland_mansion, {
	has_woodland_mansion = true,
})

mcl_levelgen.register_structure ("mcl_levelgen:woodland_mansion", {
	create_start = woodland_mansion_create_start,
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "none",
	biomes = mcl_levelgen.build_biome_list ({"#has_woodland_mansion",}),
})

mcl_levelgen.register_structure_set ("mcl_levelgen:woodland_mansion", {
	structures = {
		"mcl_levelgen:woodland_mansion",
	},
	placement = R (1.0, "default", 80, 20, 10387319, "triangular", nil, nil),
})
