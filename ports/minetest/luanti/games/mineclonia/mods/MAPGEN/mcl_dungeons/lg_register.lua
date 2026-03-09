------------------------------------------------------------------------
-- Dungeon feature.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/DungeonFeature.html
------------------------------------------------------------------------

local ull = mcl_levelgen.ull
local get_block = mcl_levelgen.get_block
local set_block = mcl_levelgen.set_block
local run_minp = mcl_levelgen.placement_run_minp
local run_maxp = mcl_levelgen.placement_run_maxp
local is_solid = mcl_levelgen.is_solid
local is_air = mcl_levelgen.is_air
local count_adjoining_solids
	= mcl_levelgen.count_adjoining_solids
local fix_lighting = mcl_levelgen.fix_lighting
local notify_generated = mcl_levelgen.notify_generated
local convert_level_position = mcl_levelgen.convert_level_position

local cid_air = core.CONTENT_AIR
local cid_chest
	= core.get_content_id ("mcl_chests:chest")
local cid_monster_spawner
	= core.get_content_id ("mcl_mobspawners:spawner")
local cid_cobblestone
	= core.get_content_id ("mcl_core:cobble")
local cid_mossy_cobblestone
	= core.get_content_id ("mcl_core:mossycobble")

local unreplaceable_cids = mcl_levelgen.construct_cid_list ({
	"group:features_cannot_replace",
})
local mobs = {
	"mobs_mc:zombie",
	"mobs_mc:skeleton",
	"mobs_mc:zombie",
	"mobs_mc:spider",
}

local indexof = table.indexof

local function set_block_protected (x, y, z, cid, param2)
	local current, _ = get_block (x, y, z)
	if indexof (unreplaceable_cids, current) == -1 then
		set_block (x, y, z, cid, param2)
	end
end

local mathabs = math.abs
local dungeon_rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))

local function dungeon_place (_, x, y, z, cfg, rng)
	dungeon_rng:reseed (rng:next_long ())
	if y < run_minp.y or y > run_maxp.y then
		return false
	end
	local rng = dungeon_rng
	local rx = rng:next_within (2) + 2
	local rz = rng:next_within (2) + 2
	local xmin = -rx - 1
	local xmax = rx + 1
	local ymin = -1
	local ymax = 4
	local zmin = -rz - 1
	local zmax = rz + 1
	local openings = 0
	local miny = mcl_levelgen.placement_run_min_y

	-- Count the number of openings at the corners and
	-- test the solidity of the floor and ceiling.
	for dx = xmin, xmax do
		for dz = zmin, zmax do
			for dy = ymin, ymax do
				local x, y, z = x + dx, y + dy, z + dz
				if not is_solid (x, y, z) then
					if dy == ymin or dy == ymax then
						return false
					elseif dx == xmin or dx == xmax
						or dz == zmin or dz == zmax then
						if dy == 0 then
							if is_air (x, y, z)
								and is_air (x, y + 1, z) then
								openings = openings + 1
							end
						end
					end
				end
			end
		end
	end

	-- Place the dungeon if at least one corner but fewer than
	-- five is exposed to air.
	if openings >= 1 and openings <= 5 then
		for dx = xmin, xmax do
			for dz = zmin, zmax do
				for dy = ymin, ymax do
					local x, y, z = x + dx, y + dy, z + dz
					if dx == xmin or dx == xmax
						or dz == zmin or dz == zmax
						or dy == ymin or dy == ymax then
						-- Replace unexposed blocks along the
						-- margins with a mixture of mossy
						-- (if on floor) and regular cobblestone.

						if y > miny and not is_solid (x, y - 1, z) then
							set_block (x, y, z, cid_air, 0)
						elseif is_solid (x, y, z) then
							local cid = cid_cobblestone
							if dy == ymin and rng:next_within (4) ~= 0 then
								cid = cid_mossy_cobblestone
							end
							set_block_protected (x, y, z, cid, 0)
						end
					else
						-- Vacate the interior of the dungeon.
						set_block_protected (x, y, z, cid_air, 0)
					end
				end
			end
		end
	else
		return false
	end

	local chest_poses = {}
	-- Make two passes over the dungeon with three attempts at
	-- chest placement each.
	for i = 1, 2 do
		for j = 1, 3 do
			local dx = rng:next_within (rx * 2 + 1) - rx
			local dz = rng:next_within (rz * 2 + 1) - rz
			local x = x + dx
			local z = z + dz
			local cnt, cnt_x, cnt_z
				= count_adjoining_solids (x, y, z)
			if is_air (x, y, z) and cnt == 1 then
				local facedir

				if cnt_x > cnt_z
					or (cnt_x == cnt_z and rng:next_boolean ()) then
					if dx > 0 then
						facedir = 1
					else
						facedir = 3
					end
				else
					if dz > 0 then
						facedir = 2
					else
						facedir = 0
					end
				end

				set_block_protected (x, y, z, cid_chest, facedir)
				local cx, cy, cz
					= convert_level_position (x, y, z)
				local v = vector.new (cx, cy, cz)
				v.chest_seed = rng:next_integer ()
				table.insert (chest_poses, v)
				break
			end
		end
	end
	set_block_protected (x, y, z, cid_monster_spawner, 0)
	fix_lighting (x - rx - 1, y - 1, z - rz - 1,
		      x + rx + 1, y + ymax, z + rz + 1)
	notify_generated ("mcl_dungeons:dungeon_meta", {
		chests = chest_poses,
		position = vector.new (convert_level_position (x, y, z)),
		loot_seed = mathabs (rng:next_integer ()),
		mob = mobs[1 + rng:next_within (#mobs)],
	})
	return true
end

mcl_levelgen.register_feature ("mcl_dungeons:monster_room", {
	place = dungeon_place,
})

mcl_levelgen.register_configured_feature ("mcl_dungeons:monster_room", {
	feature = "mcl_dungeons:monster_room",
})

------------------------------------------------------------------------
-- Dungeon placement.
------------------------------------------------------------------------

local overworld = mcl_levelgen.overworld_preset
local OVERWORLD_TOP = overworld.min_y + overworld.height - 1
local OVERWORLD_MIN = overworld.min_y
local TEN = function (_) return 10 end
local FOUR = function (_) return 4 end
local uniform_height = mcl_levelgen.uniform_height

mcl_levelgen.register_placed_feature ("mcl_dungeons:monster_room", {
	configured_feature = "mcl_dungeons:monster_room",
	placement_modifiers = {
		mcl_levelgen.build_count (TEN),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (0, OVERWORLD_TOP)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_dungeons:monster_room_deep", {
	configured_feature = "mcl_dungeons:monster_room",
	placement_modifiers = {
		mcl_levelgen.build_count (FOUR),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN + 6, -1)),
		mcl_levelgen.build_in_biome (),
	},
})
