local R = mcl_levelgen.build_random_spread_placement
local ipairs = ipairs

------------------------------------------------------------------------
-- Ruined Portal callbacks.
------------------------------------------------------------------------

local ruined_portal_loot = {
	stacks_min = 4,
	stacks_max = 8,
	items = {
		{ itemstring = "mcl_core:iron_nugget", weight = 40, amount_min = 9, amount_max = 18 },
		{ itemstring = "mcl_core:flint", weight = 40, amount_min = 1, amount_max=4 },
		{ itemstring = "mcl_core:obsidian", weight = 40, amount_min = 1, amount_max=2 },
		{ itemstring = "mcl_fire:fire_charge", weight = 40, amount_min = 1, amount_max = 1 },
		{ itemstring = "mcl_fire:flint_and_steel", weight = 40, amount_min = 1, amount_max = 1 },
		{ itemstring = "mcl_core:gold_nugget", weight = 15, amount_min = 4, amount_max = 24 },
		{ itemstring = "mcl_core:apple_gold", weight = 15, },

		{ itemstring = "mcl_tools:axe_gold", weight = 15, func = function(stack, pr)
			  mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
		end },
		{ itemstring = "mcl_farming:hoe_gold", weight = 15, func = function(stack, pr)
			  mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
		end },
		{ itemstring = "mcl_tools:pick_gold", weight = 15, func = function(stack, pr)
			  mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
		end },
		{ itemstring = "mcl_tools:shovel_gold", weight = 15, func = function(stack, pr)
			  mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
		end },
		{ itemstring = "mcl_tools:sword_gold", weight = 15, func = function(stack, pr)
			  mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
		end },

		{ itemstring = "mcl_armor:helmet_gold", weight = 15, func = function(stack, pr)
			  mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
		end },
		{ itemstring = "mcl_armor:chestplate_gold", weight = 15, func = function(stack, pr)
			  mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
		end },
		{ itemstring = "mcl_armor:leggings_gold", weight = 15, func = function(stack, pr)
			  mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
		end },
		{ itemstring = "mcl_armor:boots_gold", weight = 15, func = function(stack, pr)
			  mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
		end },

		{ itemstring = "mcl_potions:speckled_melon", weight = 5, amount_min = 4, amount_max = 12 },
		{ itemstring = "mcl_farming:carrot_item_gold", weight = 5, amount_min = 4, amount_max = 12 },

		{ itemstring = "mcl_core:gold_ingot", weight = 5, amount_min = 2, amount_max = 8 },
		{ itemstring = "mcl_clock:clock", weight = 5, },
		{ itemstring = "mcl_mobitems:gold_horse_armor", weight = 1, },
		{ itemstring = "mcl_core:goldblock", weight = 1, amount_min = 1, amount_max = 2 },
		{ itemstring = "mcl_bells:bell", weight = 1, },
		{ itemstring = "mcl_core:apple_gold_enchanted", weight = 1, },
	}
}

local v = vector.zero ()
local level_to_minetest_position = mcl_levelgen.level_to_minetest_position

local function handle_ruined_portal_loot (_, data)
	local x, y, z = level_to_minetest_position (data.x, data.y, data.z)
	v.x = x
	v.y = y
	v.z = z
	core.load_area (v)
	local node = core.get_node (v)
	if node.name == "mcl_chests:chest_small" then
		local pr = PcgRandom (data.loot_seed)
		local loot = mcl_loot.get_loot (ruined_portal_loot, pr)
		local meta = core.get_meta (v)
		local inv = meta:get_inventory ()
		mcl_structures.init_node_construct (v)
		mcl_loot.fill_inventory (inv, "main", loot, pr)
	end
end

if not mcl_levelgen.is_levelgen_environment then
	mcl_levelgen.register_notification_handler ("mcl_levelgen:ruined_portal_loot",
						    handle_ruined_portal_loot)
end

------------------------------------------------------------------------
-- Ruined Portal structure.
------------------------------------------------------------------------

local schematics = {
	"ruined_portal_1",
	"ruined_portal_2",
	"ruined_portal_3",
	"ruined_portal_small_1",
	"ruined_portal_small_2",
	"ruined_portal_small_3",
	"ruined_portal_small_4",
	"ruined_portal_small_5",
}

if not mcl_levelgen.is_levelgen_environment then
	local modpath = mcl_levelgen.prefix
	for _, schem in ipairs (schematics) do
		local name = "mcl_levelgen:" .. schem
		local file = modpath .. "/schematics/mcl_levelgen_"
			.. schem .. ".mts"
		mcl_levelgen.register_portable_schematic (name, file, true)
	end
end

local schematics_portals = {
	"mcl_levelgen:ruined_portal_small_1",
	"mcl_levelgen:ruined_portal_small_2",
	"mcl_levelgen:ruined_portal_small_3",
	"mcl_levelgen:ruined_portal_small_4",
	"mcl_levelgen:ruined_portal_small_5",
	"mcl_levelgen:ruined_portal_small_1",
	"mcl_levelgen:ruined_portal_small_2",
	"mcl_levelgen:ruined_portal_small_3",
	"mcl_levelgen:ruined_portal_small_4",
	"mcl_levelgen:ruined_portal_small_5",
}

local schematics_portals_giant = {
	"mcl_levelgen:ruined_portal_1",
	"mcl_levelgen:ruined_portal_2",
	"mcl_levelgen:ruined_portal_3",
}

local random_schematic_rotation = mcl_levelgen.random_schematic_rotation
local get_schematic_size = mcl_levelgen.get_schematic_size
local bbox_center = mcl_levelgen.bbox_center
local is_not_air = mcl_levelgen.is_not_air
local is_walkable = mcl_levelgen.is_walkable
local decode_node = mcl_levelgen.decode_node
local is_temp_snowy = mcl_levelgen.is_temp_snowy
local place_schematic = mcl_levelgen.place_schematic

local floor = math.floor
local mathmax = math.max
local mathmin = math.min
local mathabs = math.abs
local toquart = mcl_levelgen.toquart

local col1 = {}
local col2 = {}
local col3 = {}
local col4 = {}

local push_schematic_processor = mcl_levelgen.push_schematic_processor
local pop_schematic_processors = mcl_levelgen.pop_schematic_processors

local function getcid (name)
	if core and mcl_levelgen.is_levelgen_environment then
		return core.get_content_id (name)
	else
		-- Content IDs are not required outside level
		-- generation environments.
		return nil
	end
end

local function optional_cid_list (cids_or_groups)
	-- Content IDs needn't be resolved when not within a level
	-- generation environment, as structure generators are only
	-- invoked to compute structure placements for the likes of
	-- /locate.
	if core and mcl_levelgen.is_levelgen_environment then
		return mcl_levelgen.construct_cid_list (cids_or_groups)
	else
		return {}
	end
end

local cid_gold_block = getcid ("mcl_core:goldblock")
local cid_netherrack = getcid ("mcl_nether:netherrack")
local cid_magma_block = getcid ("mcl_nether:magma")
local cid_air = core.CONTENT_AIR

local function substitute_air_for_gold (x, y, z, rng, cid_existing,
					param2_existing, cid, param2)
	if cid == cid_gold_block and rng:next_float () < 0.3 then
		return cid_air, 0
	end
	return cid, param2
end

local function disregard_air (x, y, z, rng, cid_existing, param2_existing,
			      cid, param2)
	if cid == cid_air then
		return nil
	end
	return cid, param2
end

local current_structure_piece = mcl_levelgen.current_structure_piece

local function disregard_air_selectively (x, y, z, rng, cid_existing, param2_existing,
					  cid, param2)
	if cid == cid_air then
		local piece = current_structure_piece ()
		local dy = piece.structure_y - y
		if dy == 0 then
			return nil
		else
			local dx = piece.structure_center_x - x
			local dz = piece.structure_center_z - z
			local r_width = piece.r_width
			local r_length = piece.r_length
			local r_height = piece.r_height

			if (dx * r_width * dx * r_width)
				+ (dz * r_length * dz * r_length)
				+ (dy * r_height * dy * r_height) > 1.0 then
				return nil
			end
		end
	end
	return cid, param2
end

local function substitute_magma_for_netherrack (x, y, z, rng, cid_existing,
						param2_existing, cid, param2)
	if cid == cid_netherrack and rng:next_float () < 0.07 then
		return cid_magma_block, 0
	end
	return cid, param2
end

local mossiness

local cid_obsidian
	= getcid ("mcl_core:obsidian")
local cids_stairs
	= optional_cid_list ({"group:stair",})
local cids_stone_bricks
	= optional_cid_list ({"group:stonebrick", "mcl_core:stone",})
local cids_slabs
	= optional_cid_list ({"group:slab",})

local cid_crying_obsidian = getcid ("mcl_core:crying_obsidian")

local cid_cracked_stone_bricks
	= getcid ("mcl_core:stonebrickcracked")
local cid_mossy_stone_bricks
	= getcid ("mcl_core:stonebrickmossy")

local cid_cracked_stone_brick_stairs
	= getcid ("mcl_stairs:stair_stonebrickcracked")
local cid_cracked_stone_brick_stairs_outer
	= getcid ("mcl_stairs:stair_stonebrickcracked_outer")
local cid_cracked_stone_brick_stairs_inner
	= getcid ("mcl_stairs:stair_stonebrickcracked_inner")
local cid_mossy_stone_brick_stairs
	= getcid ("mcl_stairs:stair_stonebrickmossy")
local cid_mossy_stone_brick_stairs_outer
	= getcid ("mcl_stairs:stair_stonebrickmossy_outer")
local cid_mossy_stone_brick_stairs_inner
	= getcid ("mcl_stairs:stair_stonebrickmossy_inner")

local cid_cracked_stone_brick_slab
	= getcid ("mcl_stairs:slab_stonebrickcracked")
local cid_mossy_stone_brick_slab
	= getcid ("mcl_stairs:slab_stonebrickmossy")
local cid_mossy_stone_brick_slab_top
	= getcid ("mcl_stairs:slab_stonebrickmossy_top")

local cidtype = {}
local cid_matching_mossy_stairs = {}
local cid_matching_cracked_stairs = {}

-- local cid_blackstone
-- 	= getcid ("mcl_blackstone:blackstone")
-- local cid_blackstone_slab
-- 	= getcid ("mcl_slabs:slab_blackstone")
-- local cid_blackstone_slab_top
-- 	= getcid ("mcl_slabs:slab_blackstone_top")
-- local cid_blackstone_stairs
-- 	= getcid ("mcl_slabs:stair_blackstone")
-- local cid_blackstone_stairs_inner
-- 	= getcid ("mcl_slabs:stair_blackstone_inner")
-- local cid_blackstone_stairs_outer
-- 	= getcid ("mcl_slabs:stair_blackstone_outer")

local cid_polished_blackstone
	= getcid ("mcl_blackstone:blackstone_polished")
local cid_polished_blackstone_slab
	= getcid ("mcl_stairs:slab_blackstone_polished")
local cid_polished_blackstone_slab_top
	= getcid ("mcl_stairs:slab_blackstone_polished_top")
local cid_polished_blackstone_stairs
	= getcid ("mcl_stairs:stair_blackstone_polished")
local cid_polished_blackstone_stairs_inner
	= getcid ("mcl_stairs:stair_blackstone_polished_inner")
local cid_polished_blackstone_stairs_outer
	= getcid ("mcl_stairs:stair_blackstone_polished_outer")

local blackstone_replacements = {}

for _, cid in ipairs (cids_stone_bricks) do
	cidtype[cid] = 0
	blackstone_replacements[cid] = cid_polished_blackstone
end

for _, cid in ipairs (cids_stairs) do
	cidtype[cid] = 1

	local name = core.get_name_from_content_id (cid)
	if name:match ("_outer$") then
		cid_matching_cracked_stairs[cid]
			= cid_cracked_stone_brick_stairs_outer
		cid_matching_mossy_stairs[cid]
			= cid_mossy_stone_brick_stairs_outer
		blackstone_replacements[cid]
			= cid_polished_blackstone_stairs_outer
	elseif name:match ("_inner$") then
		cid_matching_cracked_stairs[cid]
			= cid_cracked_stone_brick_stairs_inner
		cid_matching_mossy_stairs[cid]
			= cid_mossy_stone_brick_stairs_inner
		blackstone_replacements[cid]
			= cid_polished_blackstone_stairs_inner
	else
		cid_matching_cracked_stairs[cid]
			= cid_cracked_stone_brick_stairs
		cid_matching_mossy_stairs[cid]
			= cid_mossy_stone_brick_stairs
		blackstone_replacements[cid]
			= cid_polished_blackstone_stairs
	end
end

for _, cid in ipairs (cids_slabs) do
	local name = core.get_name_from_content_id (cid)
	if name:match ("_top$") then
		cidtype[cid] = 3
		blackstone_replacements[cid]
			= cid_polished_blackstone_slab_top
	else
		cidtype[cid] = 2
		blackstone_replacements[cid]
			= cid_polished_blackstone_slab
	end
end

local function select_stairs_or_bricks (rng, cid_bricks, cid_stairs)
	if rng:next_boolean () then
		return cid_bricks, 0
	else
		return cid_stairs, rng:next_within (6)
	end
end

local function select_stairs_or_bricks_0 (rng, cid_bricks, cid_stairs, param2)
	if rng:next_boolean () then
		return cid_bricks, 0
	else
		return cid_stairs, param2
	end
end

local function weather_blocks (x, y, z, rng, cid_existing,
			       param2_existing, cid, param2)
	local cid_type = cidtype[cid]
	if cid_type == 0 then
		if rng:next_float () < 0.5 then
			if mossiness > 0.0
				and rng:next_float () < mossiness then
				return select_stairs_or_bricks (rng, cid_mossy_stone_bricks,
								cid_mossy_stone_brick_stairs)
			else
				return select_stairs_or_bricks (rng, cid_cracked_stone_bricks,
								cid_cracked_stone_brick_stairs)
			end
		end
	elseif cid_type == 1 then
		if rng:next_float () < 0.5 then
			if mossiness > 0.0
				and rng:next_float () < mossiness then
				return select_stairs_or_bricks_0 (rng, cid_mossy_stone_brick_slab,
								  cid_matching_mossy_stairs[cid],
								  param2)
			else
				return select_stairs_or_bricks_0 (rng, cid_cracked_stone_brick_slab,
								  cid_matching_cracked_stairs[cid],
								  param2)
			end
		end
	elseif cid_type == 2 then
		if mossiness > 0.0
			and rng:next_float () < mossiness then
			return cid_mossy_stone_brick_slab, param2
		end
	elseif cid_type == 3 then
		if mossiness > 0.0
			and rng:next_float () < mossiness then
			return cid_mossy_stone_brick_slab_top, param2
		end
	elseif cid == cid_obsidian then
		if rng:next_float () < 0.15 then
			return cid_crying_obsidian, param2
		end
	end
	return cid, param2
end

local is_full_block = mcl_levelgen.is_full_block
local cid_lava_source = getcid ("mcl_core:lava_source")
local cid_lava_flowing = getcid ("mcl_core:lava_flowing")
local set_block = mcl_levelgen.set_block
local get_block = mcl_levelgen.get_block

local function replace_nonsolid_blocks_in_lava (x, y, z, rng, cid_existing,
						param2_existing, cid, param2)
	if cid_existing == cid_lava_source then
		-- Test whether this block, once placed at X, Y, Z,
		-- will be entirely solid.
		set_block (x, y, z, cid, param2)
		local solid_p = is_full_block (x, y, z)
		set_block (x, y, z, cid_existing, param2_existing)

		if not solid_p then
			return nil
		end
	end
	return cid, param2
end

local function replace_lava_with_netherrack (x, y, z, rng, cid_existing,
					     param2_existing, cid, param2)
	if cid == cid_lava_source or cid == cid_lava_flowing then
		return cid_netherrack, 0
	end
	return cid, param2
end

local function replace_with_blackstone (x, y, z, rng, cid_existing,
					param2_existing, cid, param2)
	local rpl_cid = blackstone_replacements[cid]
	if rpl_cid then
		return rpl_cid, param2
	end
	return cid, param2
end

local protected_cids
	= optional_cid_list ({"group:features_cannot_replace",})
local PROTECTED_BLOCKS_PROCESSOR
	= mcl_levelgen.protected_blocks_processor (protected_cids)

local notify_generated = mcl_levelgen.notify_generated
local cid_chest_small = getcid ("mcl_chests:chest_small")

local function post_ruined_portal_loot (x, y, z, rng, cid_existing,
					param2_existing, cid, param2)
	if cid == cid_chest_small then
		notify_generated ("mcl_levelgen:ruined_portal_loot", x, y, z, {
			x = x,
			y = y,
			z = z,
			loot_seed = mathabs (rng:next_integer ()),
		})
	end
	return cid, param2
end

local function build_processors (self)
	local i = push_schematic_processor (substitute_air_for_gold)
	if not self.air_pocket then
		push_schematic_processor (disregard_air)
	else
		push_schematic_processor (disregard_air_selectively)
	end
	if not self.cold then
		push_schematic_processor (substitute_magma_for_netherrack)
	else
		push_schematic_processor (replace_lava_with_netherrack)
	end
	push_schematic_processor (PROTECTED_BLOCKS_PROCESSOR)
	mossiness = self.mossiness
	push_schematic_processor (weather_blocks)
	push_schematic_processor (replace_nonsolid_blocks_in_lava)
	push_schematic_processor (post_ruined_portal_loot)
	if self.replace_with_blackstone then
		push_schematic_processor (replace_with_blackstone)
	end

	return i
end

local NETHERRACK_RING_PROBABILITIES = {
	1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -- 0 to 6
	0.9, 0.9, 0.8, 0.7, 0.6, 0.4, 0.2, -- 7 to 13
}

local ipos3 = mcl_levelgen.ipos3
local index_heightmap = mcl_levelgen.index_heightmap
local is_cid_magma_not_replaceable = {}
local magma_not_replaceable = {
	"air",
	"mcl_core:obsidian",
	"group:features_cannot_replace",
}

for _, cid in ipairs (optional_cid_list (magma_not_replaceable)) do
	is_cid_magma_not_replaceable[cid] = true
end

local function place_hot_block (self, rng, x, y, z)
	if not self.cold and rng:next_float () < 0.07 then
		set_block (x, y, z, cid_magma_block, 0)
	else
		set_block (x, y, z, cid_netherrack, 0)
	end
end

local is_air = mcl_levelgen.is_air
local cid_leaves_jungle = getcid ("mcl_trees:leaves_jungle")
local index_biome = mcl_levelgen.index_biome
local registered_biomes = mcl_levelgen.registered_biomes

local function place_leaves_above (self, rng, x, y, z)
	local cid, _ = get_block (x, y, z)
	if cid == cid_netherrack
		and rng:next_float () < 0.5
		and is_air (x, y + 1, z) then
		local biome = index_biome (x, y, z)
		local def = registered_biomes[biome]
		set_block (x, y + 1, z, cid_leaves_jungle,
			   32 + def.leaves_palette_index)
	end
end

local function extend_hot_block (self, rng, x, y, z)
	place_hot_block (self, rng, x, y, z)
	for i = 1, 8 do
		y = y - 1
		if rng:next_float () >= 0.5 then
			return
		end

		place_hot_block (self, rng, x, y, z)
	end
end

local bbox_width_z = mcl_levelgen.bbox_width_z
local bbox_width_x = mcl_levelgen.bbox_width_x

local function place_netherrack (self, rng)
	local bbox = self.bbox

	do
		local x, _, z = bbox_center (bbox)
		local ymin = bbox[2]
		local r = 14 -- #NETHERRACK_RING_PROBABILITIES
		local avg = floor ((bbox_width_z (bbox) + bbox_width_x (bbox)) / 2)
		local shrink = rng:next_within (mathmax (1, 8 - avg * 0.5))
		local placement = self.placement
		local overgrown = self.overgrown
		local on_surface = placement == "on_land_surface"
			or placement == "on_ocean_floor"

		for x1, _, z1 in ipos3 (x - r, 0, z - r, x + r, 0, z + r) do
			local dmanhattan = floor (mathabs (x - x1) + mathabs (z - z1))
			if dmanhattan + shrink < r then
				local chance = NETHERRACK_RING_PROBABILITIES[dmanhattan + 1]
				if rng:next_double () < chance then
					local height, _

					if placement == "on_ocean_floor" then
						_, height = index_heightmap (x1, z1, true)
					else
						height, _ = index_heightmap (x1, z1, true)
					end

					if not on_surface then
						height = mathmin (height, ymin + 1)
					end

					if mathabs ((height - 1) - ymin) <= 3 then
						local y = height - 1
						local cid, _ = get_block (x1, y, z1)
						if not is_cid_magma_not_replaceable[cid]
							and (placement == "in_nether"
							     or cid ~= cid_lava_source) then
							place_hot_block (self, rng, x1, y, z1)
							if overgrown then
								place_leaves_above (self, rng, x1, y, z1)
							end
							extend_hot_block (self, rng, x1, y - 1, z1)
						end
					end
				end
			end
		end
	end

	-- Place netherrack pillars beneath this structure.
	for x, y, z in ipos3 (bbox[1], bbox[2], bbox[3],
			      bbox[4], bbox[2], bbox[6]) do
		local cid, _ = get_block (x, y, z)
		if cid == cid_netherrack then
			extend_hot_block (self, rng, x, y - 1, z)
		end
	end
end

local face_directions = mcl_levelgen.face_directions
local face_opposites = mcl_levelgen.face_opposites

local FACE_NORTH = mcl_levelgen.FACE_NORTH
local FACE_WEST = mcl_levelgen.FACE_WEST
local FACE_SOUTH = mcl_levelgen.FACE_SOUTH
local FACE_EAST = mcl_levelgen.FACE_EAST
-- local FACE_UP = mcl_levelgen.FACE_UP
local FACE_DOWN = mcl_levelgen.FACE_DOWN

local VINES_DIRS = {
	FACE_NORTH,
	FACE_WEST,
	FACE_SOUTH,
	FACE_EAST,
	FACE_DOWN,
}

local cid_vine = getcid ("mcl_core:vine")
local ordinal_to_wallmounted = mcl_levelgen.ordinal_to_wallmounted
local get_sturdy_faces = mcl_levelgen.get_sturdy_faces
local band = bit.band

local function unpack3 (x)
	return x[1], x[2], x[3]
end

local function maybe_place_vines (rng, x, y, z)
	local cid, _ = get_block (x, y, z)
	if cid ~= cid_air and cid ~= cid_vine then
		local dir = VINES_DIRS[1 + rng:next_within (5)]
		local dx, dy, dz = unpack3 (face_directions[dir])
		if is_air (x + dx, y + dy, z + dz) then
			local faces = get_sturdy_faces (x, y, z)
			if band (faces, dir) ~= 0 then
				set_block (x + dx, y + dy, z + dz, cid_vine,
					   ordinal_to_wallmounted (face_opposites[dir]))
			end
		end
	end
end

local function ruined_portal_place (self, level, terrain, rng, x1, z1, x2, z2)
	local x, y, z = self.structure_x, self.structure_y, self.structure_z
	local i = build_processors (self)
	place_schematic (x, y, z, self.schematic, self.rotation, true, nil, rng)
	pop_schematic_processors (i)
	place_netherrack (self, rng)

	local overgrown, vines = self.overgrown, self.vines
	if overgrown or vines then
		local bbox = self.bbox
		for x, y, z in ipos3 (mathmax (x1, bbox[1]),
				      bbox[2],
				      mathmax (z1, bbox[3]),
				      mathmin (x2, bbox[4]),
				      bbox[5],
				      mathmin (z2, bbox[6])) do
			if overgrown then
				place_leaves_above (self, rng, x, y, z)
			end
			if vines then
				maybe_place_vines (rng, x, y, z)
			end
		end
	end
end

local function is_biome_cold (preset, x, y, z)
	local biome = preset:index_biomes (toquart (x),
					   toquart (y),
					   toquart (z))
	return is_temp_snowy (biome, x, y, z)
end

local function apply_vertical_placement (self, rng, terrain, height, placement, bbox,
					 create_air_pocket)
	local preset = terrain.preset
	local min_y = preset.min_y
	local max_y = min_y + preset.height - 1
	local min = min_y + 15
	local base_y

	if placement == "in_nether" then
		if create_air_pocket then
			base_y = 32 + rng:next_within (69)
		elseif rng:next_float () < 0.5 then
			base_y = 27 + rng:next_within (3)
		else
			base_y = 29 + rng:next_within (72)
		end
	elseif placement == "on_land_surface"
		or placement == "on_ocean_floor" then
		base_y = height
	else
		local schem_height = bbox[5] - bbox[2] + 1
		local tmp = height - schem_height

		if placement == "in_mountain" then
			base_y = tmp <= 70 and tmp
				or 70 + rng:next_within (tmp - 70 + 1)
		elseif placement == "underground" then
			base_y = tmp <= min and tmp
				or min + rng:next_within (tmp - min + 1)
		elseif placement == "partly_buried" then
			base_y = tmp + 2 + rng:next_within (7)
		else
			assert (false, placement)
		end
	end

	local col1 = terrain:get_one_column (bbox[1], bbox[3], col1)
	local col2 = terrain:get_one_column (bbox[4], bbox[3], col2)
	local col3 = terrain:get_one_column (bbox[1], bbox[6], col3)
	local col4 = terrain:get_one_column (bbox[4], bbox[6], col4)

	local predicate = is_not_air
	if placement == "on_ocean_floor" then
		predicate = is_walkable
	end

	for y = mathmin (base_y, max_y), min + 1, -1 do
		local idx = y - min_y + 1
		local cid1, param11 = decode_node (col1[idx])
		local cid2, param12 = decode_node (col2[idx])
		local cid3, param13 = decode_node (col3[idx])
		local cid4, param14 = decode_node (col4[idx])
		local cnt = 0

		if predicate (cid1, param11) then
			cnt = cnt + 1
		end

		if predicate (cid2, param12) then
			cnt = cnt + 1
		end

		if predicate (cid3, param13) then
			cnt = cnt + 1
		end

		if predicate (cid4, param14) then
			cnt = cnt + 1
		end

		-- If three or more corners are solid, return this
		-- position.
		if cnt >= 3 then
			return y
		end
	end
	return min
end

local structure_biome_test = mcl_levelgen.structure_biome_test
local create_structure_start = mcl_levelgen.create_structure_start

local function ruined_portal_create_start (self, level, terrain, rng, cx, cz)
	local cfg
	do
		local setups = self.setups
		if #setups > 1 then
			local total_weight = 0.0
			local weight = rng:next_float ()

			for _, this in ipairs (setups) do
				total_weight = total_weight + this.weight
			end

			for _, this in ipairs (setups) do
				weight = weight - (this.weight / total_weight)
				if weight < 0.0 then
					cfg = this
					break
				end
			end
			assert (cfg)
		else
			cfg = setups[1]
		end
	end


	local create_air_pocket = false
	local air_pocket_probability = cfg.air_pocket_probability

	if air_pocket_probability >= 1.0 then
		create_air_pocket = true
	elseif air_pocket_probability > 0.0 then
		create_air_pocket = rng:next_float () < air_pocket_probability
	end

	local schematic

	if rng:next_float () >= 0.05 then
		local idx = 1 + rng:next_within (#schematics_portals)
		schematic = schematics_portals[idx]
	else
		local idx = 1 + rng:next_within (#schematics_portals_giant)
		schematic = schematics_portals_giant[idx]
	end

	local rot = random_schematic_rotation (rng)
	rng:next_float () -- Not yet implemented.
	local sx, sy, sz = get_schematic_size (schematic, rot)
	local dx, dz = floor (sx / 2), floor (sz / 2)
	local x, z = cx * 16, cz * 16
	local bbox = {
		x - dx,
		0,
		z - dz,
		x - dx + sx - 1,
		sy - 1,
		z - dz + sz - 1,
	}
	local cx, _, cz = bbox_center (bbox)
	local placement = cfg.placement
	local height = terrain:get_one_height (cx, cz, (placement ~= "on_ocean_floor"
							and is_not_air or nil))
	local by = apply_vertical_placement (self, rng, terrain, height,
					     placement, bbox, create_air_pocket)

	if structure_biome_test (level, self, x, by, z) then
		local cold = cfg.can_be_cold
			and is_biome_cold (level.preset, x, by, z)
		bbox[2] = by
		bbox[5] = by + sy - 1

		local pieces = {
			{
				place = ruined_portal_place,
				schematic = schematic,
				rotation = rot,
				cold = cold,
				mossiness = cfg.mossiness,
				air_pocket = create_air_pocket,
				overgrown = cfg.overgrown,
				vines = cfg.vines,
				replace_with_blackstone = cfg.replace_with_blackstone,
				placement = cfg.placement,
				bbox = {
					bbox[1] - 14,
					bbox[2],
					bbox[3] - 14,
					bbox[4] + 14,
					bbox[5],
					bbox[6] + 14,
				},
				structure_x = bbox[1],
				structure_y = by,
				structure_z = bbox[3],
				structure_center_x = cx,
				structure_center_z = cz,
				r_width = 1 / (cx - bbox[1] + 1),
				r_length = 1 / (cz - bbox[3] + 1),
				r_height = 1 / (bbox[5] - bbox[2] + 1),
			},
		}
		return create_structure_start (self, pieces)
	end
	return nil
end

------------------------------------------------------------------------
-- Ruined Portal registration.
------------------------------------------------------------------------

local ruined_portal_standard_biomes = {
	"#is_beach",
	"#is_river",
	"#is_taiga",
	"#is_forest",
	"MushroomIslands",
	"IceSpikes",
	"DripstoneCaves",
	"LushCaves",
	"Savannah",
	"SnowyPlains",
	"Plains",
	"SunflowerPlains",
}

mcl_levelgen.modify_biome_groups (ruined_portal_standard_biomes, {
	has_ruined_portal_standard = true,
})

local ruined_portal_desert_biomes = {
	"Desert",
}

mcl_levelgen.modify_biome_groups (ruined_portal_desert_biomes, {
	has_ruined_portal_desert = true,
})

local ruined_portal_jungle_biomes = {
	"#is_jungle",
}

mcl_levelgen.modify_biome_groups (ruined_portal_jungle_biomes, {
	has_ruined_portal_jungle = true,
})

local ruined_portal_swamp_biomes = {
	"Swamp",
	"MangroveSwamp",
}

mcl_levelgen.modify_biome_groups (ruined_portal_swamp_biomes, {
	has_ruined_portal_swamp = true,
})

local ruined_portal_mountain_biomes = {
	"#is_badlands",
	"#is_hill",
	"SavannahPlateau",
	"WindsweptSavannah",
	"StonyShore",
	"#is_mountain",
}

mcl_levelgen.modify_biome_groups (ruined_portal_mountain_biomes, {
	has_ruined_portal_mountain = true,
})

local ruined_portal_ocean_biomes = {
	"#is_ocean",
}

mcl_levelgen.modify_biome_groups (ruined_portal_ocean_biomes, {
	has_ruined_portal_ocean = true,
})

local ruined_portal_nether_biomes = {
	"#is_nether",
}

mcl_levelgen.modify_biome_groups (ruined_portal_nether_biomes, {
	has_ruined_portal_nether = true,
})

mcl_levelgen.register_structure ("mcl_levelgen:ruined_portal", {
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "none",
	biomes = mcl_levelgen.build_biome_list ({"#has_ruined_portal_standard",}),
	create_start = ruined_portal_create_start,
	setups = {
		{
			air_pocket_probability = 1.0,
			can_be_cold = true,
			mossiness = 0.2,
			overgrown = false,
			placement = "underground",
			replace_with_blackstone = false,
			vines = false,
			weight = 0.5,
		},
		{
			air_pocket_probability = 0.5,
			can_be_cold = true,
			mossiness = 0.2,
			overgrown = false,
			placement = "on_land_surface",
			replace_with_blackstone = false,
			vines = false,
			weight = 0.5,
		},
	},
})

mcl_levelgen.register_structure ("mcl_levelgen:ruined_portal_desert", {
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "none",
	biomes = mcl_levelgen.build_biome_list ({"#has_ruined_portal_desert",}),
	create_start = ruined_portal_create_start,
	setups = {
		{
			air_pocket_probability = 0.0,
			can_be_cold = false,
			mossiness = 0.0,
			overgrown = false,
			placement = "partly_buried",
			replace_with_blackstone = false,
			vines = false,
			weight = 1.0,
		},
	},
})

mcl_levelgen.register_structure ("mcl_levelgen:ruined_portal_jungle", {
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "none",
	biomes = mcl_levelgen.build_biome_list ({"#has_ruined_portal_jungle",}),
	create_start = ruined_portal_create_start,
	setups = {
		{
			air_pocket_probability = 0.5,
			can_be_cold = false,
			mossiness = 0.8,
			overgrown = true,
			placement = "on_land_surface",
			replace_with_blackstone = false,
			vines = true,
			weight = 1.0,
		},
	},
})

mcl_levelgen.register_structure ("mcl_levelgen:ruined_portal_swamp", {
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "none",
	biomes = mcl_levelgen.build_biome_list ({"#has_ruined_portal_swamp",}),
	create_start = ruined_portal_create_start,
	setups = {
		{
			air_pocket_probability = 0.0,
			can_be_cold = false,
			mossiness = 0.5,
			overgrown = false,
			placement = "on_ocean_floor",
			replace_with_blackstone = false,
			vines = true,
			weight = 1.0,
		},
	},
})

mcl_levelgen.register_structure ("mcl_levelgen:ruined_portal_mountain", {
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "none",
	biomes = mcl_levelgen.build_biome_list ({"#has_ruined_portal_mountain",}),
	create_start = ruined_portal_create_start,
	setups = {
		{
			air_pocket_probability = 1.0,
			can_be_cold = true,
			mossiness = 0.2,
			overgrown = false,
			placement = "in_mountain",
			replace_with_blackstone = false,
			vines = false,
			weight = 0.5,
		},
		{
			air_pocket_probability = 0.5,
			can_be_cold = true,
			mossiness = 0.2,
			overgrown = false,
			placement = "on_land_surface",
			replace_with_blackstone = false,
			vines = false,
			weight = 0.5,
		},
	},
})

mcl_levelgen.register_structure ("mcl_levelgen:ruined_portal_ocean", {
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "none",
	biomes = mcl_levelgen.build_biome_list ({"#has_ruined_portal_ocean",}),
	create_start = ruined_portal_create_start,
	setups = {
		{
			air_pocket_probability = 0.0,
			can_be_cold = true,
			mossiness = 0.8,
			overgrown = false,
			placement = "on_ocean_floor",
			replace_with_blackstone = false,
			vines = false,
			weight = 1.0,
		},
	},
})

mcl_levelgen.register_structure ("mcl_levelgen:ruined_portal_nether", {
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "none",
	biomes = mcl_levelgen.build_biome_list ({"#has_ruined_portal_nether",}),
	create_start = ruined_portal_create_start,
	setups = {
		{
			air_pocket_probability = 0.5,
			can_be_cold = false,
			mossiness = 0.0,
			overgrown = false,
			placement = "in_nether",
			replace_with_blackstone = true,
			vines = false,
			weight = 1.0,
		},
	},
})

mcl_levelgen.register_structure_set ("mcl_levelgen:ruined_portals", {
	structures = {
		"mcl_levelgen:ruined_portal",
		"mcl_levelgen:ruined_portal_desert",
		"mcl_levelgen:ruined_portal_jungle",
		"mcl_levelgen:ruined_portal_swamp",
		"mcl_levelgen:ruined_portal_mountain",
		"mcl_levelgen:ruined_portal_ocean",
		"mcl_levelgen:ruined_portal_nether",
	},
	placement = R (1.0, "default", 40, 15, 34222645, "linear", nil, nil),
})
