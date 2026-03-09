local R = mcl_levelgen.build_random_spread_placement

local WIDTH = 7
local LENGTH = 9
local HEIGHT = 7

------------------------------------------------------------------------
-- Swamp Hut.
-- https://maven.fabricmc.net/docs/yarn-1.20.4+build.1/net/minecraft/structure/SwampHutGenerator.html
------------------------------------------------------------------------

local ipos3 = mcl_levelgen.ipos3
local reorientate_coords = mcl_levelgen.reorientate_coords
local set_block = mcl_levelgen.set_block

local mathmin = math.min
local mathmax = math.max

local function getcid (name)
	if core and mcl_levelgen.is_levelgen_environment then
		return core.get_content_id (name)
	else
		-- Content IDs are not required outside level
		-- generation environments.
		return nil
	end
end

local cid_air = core.CONTENT_AIR
local cid_oak_fence = getcid ("mcl_fences:oak_fence")
local cid_potted_red_mushroom
	= getcid ("mcl_flowerpots:flower_pot_mushroom_red")
local cid_crafting_table
	= getcid ("mcl_crafting_table:crafting_table")
local cid_cauldron
	= getcid ("mcl_cauldrons:cauldron")
local cid_spruce_stairs
	= getcid ("mcl_stairs:stair_spruce")
local cid_spruce_stairs_outer
	= getcid ("mcl_stairs:stair_spruce_outer")
local cid_spruce_planks
	= getcid ("mcl_trees:wood_spruce")
local cid_oak_log
	= getcid ("mcl_trees:tree_oak")

local function fill_box_rotated (piece, x1, y1, z1, x2, y2, z2, cid, param2)
	local x1, y1, z1 = reorientate_coords (piece, x1, y1, z1)
	local x2, y2, z2 = reorientate_coords (piece, x2, y2, z2)

	for x, y, z in ipos3 (mathmin (x1, x2),
			      y1,
			      mathmin (z1, z2),
			      mathmax (x1, x2),
			      y2,
			      mathmax (z1, z2)) do
		set_block (x, y, z, cid, param2)
	end
end

local function set_block_reorientated (piece, x, y, z, cid, param2)
	local x, y, z = reorientate_coords (piece, x, y, z)
	set_block (x, y, z, cid, param2)
end

local corners = {
	1, 2,
	1, 7,
	5, 2,
	5, 7,
}

local is_water_air_or_lava = mcl_levelgen.is_water_air_or_lava

local function build_foundation_column (level_min, x, y, z)
	while y > level_min + 1 do
		if not is_water_air_or_lava (x, y, z) then
			break
		end
		set_block (x, y, z, cid_oak_log, 0)
		y = y - 1
	end
end

local function fill_supports (self, level_min, dx, dy, dz)
	local x, y, z = reorientate_coords (self, dx, dy, dz)
	build_foundation_column (level_min, x, y, z)
end

local facedirs = {
	north = 0,
	east = 1,
	south = 2,
	west = 3,
}

local reverse_facedirs = {
	north = 2,
	east = 3,
	south = 0,
	west = 1,
}

local left_facedirs = {
	north = 3,
	south = 3,
	west = 0,
	east = 0,
}

local right_facedirs = {
	north = 1,
	south = 1,
	west = 2,
	east = 2,
}

local northwest_stair_dirs = {
	north = 1,
	west = 3,
	south = 2,
	east = 2,
}

local northeast_stair_dirs = {
	north = 0,
	west = 0,
	south = 3,
	east = 1,
}

local southwest_stair_dirs = {
	north = 2,
	west = 2,
	south = 1,
	east = 3,
}

local southeast_stair_dirs = {
	north = 3,
	west = 1,
	south = 0,
	east = 0,
}

local staticdata_witch = core.serialize ({
	_structure_generation_spawn = true,
	persistent = true,
})
local staticdata_black_cat = core.serialize ({
	_structure_generation_spawn = true,
	persistent = true,
	_default_texture = "mobs_mc_cat_all_black.png",
})

local create_entity = mcl_levelgen.create_entity

local function swamp_hut_place (self, level, terrain, rng, x1, z1, x2, z2)
	fill_box_rotated (self, 1, 1, 1, 5, 1, 7, cid_spruce_planks, 0)
	fill_box_rotated (self, 1, 4, 2, 5, 4, 7, cid_spruce_planks, 0)
	fill_box_rotated (self, 2, 1, 0, 4, 1, 0, cid_spruce_planks, 0)
	fill_box_rotated (self, 2, 2, 2, 3, 3, 2, cid_spruce_planks, 0)
	fill_box_rotated (self, 1, 2, 3, 1, 3, 6, cid_spruce_planks, 0)
	fill_box_rotated (self, 5, 2, 3, 5, 3, 6, cid_spruce_planks, 0)
	fill_box_rotated (self, 2, 2, 7, 4, 3, 7, cid_spruce_planks, 0)
	fill_box_rotated (self, 1, 0, 2, 1, 3, 2, cid_oak_log, 0)
	fill_box_rotated (self, 5, 0, 2, 5, 3, 2, cid_oak_log, 0)
	fill_box_rotated (self, 1, 0, 7, 1, 3, 7, cid_oak_log, 0)
	fill_box_rotated (self, 5, 0, 7, 5, 3, 7, cid_oak_log, 0)
	set_block_reorientated (self, 2, 3, 2, cid_oak_fence, 0)
	set_block_reorientated (self, 3, 3, 7, cid_oak_fence, 0)
	set_block_reorientated (self, 1, 3, 4, cid_air, 0)
	set_block_reorientated (self, 5, 3, 4, cid_air, 0)
	set_block_reorientated (self, 5, 3, 5, cid_air, 0)
	set_block_reorientated (self, 1, 3, 5, cid_potted_red_mushroom, 0)
	set_block_reorientated (self, 3, 2, 6, cid_crafting_table, 0)
	set_block_reorientated (self, 4, 2, 6, cid_cauldron, 0)
	set_block_reorientated (self, 1, 2, 1, cid_oak_fence, 0)
	set_block_reorientated (self, 5, 2, 1, cid_oak_fence, 0)

	-- Eaves.
	local dir = self.dir
	fill_box_rotated (self, 0, 4, 1, 6, 4, 1, cid_spruce_stairs,
			  facedirs[dir])
	fill_box_rotated (self, 0, 4, 2, 0, 4, 7, cid_spruce_stairs,
			  right_facedirs[dir])
	fill_box_rotated (self, 6, 4, 2, 6, 4, 7, cid_spruce_stairs,
			  left_facedirs[dir])
	fill_box_rotated (self, 0, 4, 8, 6, 4, 8, cid_spruce_stairs,
			  reverse_facedirs[dir])
	set_block_reorientated (self, 0, 4, 1, cid_spruce_stairs_outer,
				northwest_stair_dirs[dir])
	set_block_reorientated (self, 6, 4, 1, cid_spruce_stairs_outer,
				northeast_stair_dirs[dir])
	set_block_reorientated (self, 6, 4, 8, cid_spruce_stairs_outer,
				southeast_stair_dirs[dir])
	set_block_reorientated (self, 0, 4, 8, cid_spruce_stairs_outer,
				southwest_stair_dirs[dir])

	local level_min = level.preset.min_y
	for i = 1, #corners, 2 do
		local dx = corners[i]
		local dz = corners[i + 1]

		fill_supports (self, level_min, dx, -1, dz)
	end

	local x, y, z = reorientate_coords (self, 2, 2, 5)
	create_entity (x, y, z, "mobs_mc:witch", staticdata_witch)
	create_entity (x, y, z, "mobs_mc:cat", staticdata_black_cat)
end

local random_orientation = mcl_levelgen.random_orientation
local make_rotated_bbox = mcl_levelgen.make_rotated_bbox

local is_not_air = mcl_levelgen.is_not_air
local structure_biome_test = mcl_levelgen.structure_biome_test
local create_structure_start = mcl_levelgen.create_structure_start

local function swamp_hut_create_start (self, level, terrain, rng, cx, cz)
	local gx, gz = cx * 16 + 8, cz * 16 + 8
	local gy = terrain:get_one_height (gx, gz, is_not_air)

	if structure_biome_test (level, self, gx, gy, gz) then
		local dir = random_orientation (rng)
		local bbox = make_rotated_bbox (gx - 8, gy, gz - 8, dir,
						WIDTH, HEIGHT, LENGTH)
		local y = terrain:area_average_height (bbox[1], bbox[3],
						       bbox[4], bbox[6],
						       is_not_air)
		bbox[2] = y
		bbox[5] = y + HEIGHT - 1
		local pieces = {
			{
				bbox = bbox,
				place = swamp_hut_place,
				dir = dir,
			},
		}
		return create_structure_start (self, pieces)
	end
end

------------------------------------------------------------------------
-- Swamp Hut registration.
------------------------------------------------------------------------

local swamp_hut_biomes = {
	"Swamp",
}

mcl_levelgen.modify_biome_groups (swamp_hut_biomes, {
	has_swamp_hut = true,
})

mcl_levelgen.register_structure ("mcl_levelgen:swamp_hut", {
	create_start = swamp_hut_create_start,
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "none",
	biomes = mcl_levelgen.build_biome_list ({"#has_swamp_hut",}),
})

mcl_levelgen.register_structure_set ("mcl_levelgen:swamp_huts", {
	structures = {
		"mcl_levelgen:swamp_hut",
	},
	placement = R (1.0, "default", 32, 8, 14357620, "linear",
		       nil, nil),
})
