-- local FACE_NORTH = mcl_levelgen.FACE_NORTH
-- local FACE_WEST = mcl_levelgen.FACE_WEST
-- local FACE_SOUTH = mcl_levelgen.FACE_SOUTH
-- local FACE_EAST = mcl_levelgen.FACE_EAST
-- local FACE_UP = mcl_levelgen.FACE_UP
-- local FACE_DOWN = mcl_levelgen.FACE_DOWN

-- local face_opposites = mcl_levelgen.face_opposites
-- local face_directions = mcl_levelgen.face_directions
-- local FACE_ORDINALS = mcl_levelgen.FACE_ORDINALS

------------------------------------------------------------------------
-- Sculk spread logic.
------------------------------------------------------------------------

--[[
local sculk_default_logic = {}
local get_sturdy_faces = mcl_levelgen.get_sturdy_faces
local cid_air = core.CONTENT_AIR
local cid_water_source = core.get_content_id ("mcl_core:water_source")

function sculk_default_logic:spread_sculk_vein (x, y, z)
	-- Attach a vein block to all adjacent faces.
	-- TODO: implement sculk veins as multi-face blocks.
	for _, face in ipairs (FACE_ORDINALS) do
		local dir = face_directions[face]
		local opposite = face_opposites[face]
		local sturdy = get_sturdy_faces (x + dir[1], y + dir[2], z + dir[3])

	end
end

function sculk_default_logic:consume_charge (current)
	return current
end

local function logic_for_block (cid)
	return sculk_default_logic
end
]]--

------------------------------------------------------------------------
-- Sculk patch feature.
------------------------------------------------------------------------

--[[
local sculk_patch_cfg = {
	charge_count = nil,
	amount_per_charge = nil,
	spread_attempts = nil,
	growth_rounds = nil,
	spread_rounds = nil,
	extra_rare_growths = nil,
	catalyst_chance = nil,
}

local spread_iterator = {
	x = nil,
	y = nil,
	z = nil,
	charge = nil,
}

local function longhash (x, y, z)
	return (32768 + x) * 65536 * 65536 + (32768 + y) * 65536
		+ (32768 + z)
end

local insert = table.insert
local get_block = mcl_levelgen.get_block

local function iterator_step (self, rng, org_x, org_y, org_z,
			      allow_spread)
	if self.charge <= 0 then
		return
	end

	local x = self.x
	local y = self.y
	local z = self.z
	local cid, param2 = get_block (x, y, z)
	local sculk_logic = logic_for_block (cid)
end

local function sculk_iterate (iterators, rng, org_x, org_y, org_z)
	for _, iterator in ipairs (iterators) do
		iterator_step (iterator, rng, org_x, org_y, org_z)
	end
end
]]--

-- XXX: not yet implemented.

mcl_levelgen.register_feature ("mcl_sculk:sculk_patch", {
	place = function (_, _, _, _, _, _)
		return false
	end,
})

local ZERO = function (_) return 0 end
local uniform_height = mcl_levelgen.uniform_height

mcl_levelgen.register_configured_feature ("mcl_sculk:sculk_patch_ancient_city", {
	feature = "mcl_sculk:sculk_patch",
	amount_per_charge = 32,
	catalyst_chance = 0.5,
	charge_count = 10,
	extra_rare_growths = uniform_height (1, 3),
	growth_rounds = 0,
	spread_attempts = 64,
	spread_rounds = 1,
})

mcl_levelgen.register_configured_feature ("mcl_sculk:sculk_patch_deep_dark", {
	feature = "mcl_sculk:sculk_patch",
	amount_per_charge = 32,
	catalyst_chance = 0.5,
	charge_count = 10,
	extra_rare_growths = ZERO,
	growth_rounds = 0,
	spread_attempts = 64,
	spread_rounds = 1,
})

-- local overworld = mcl_levelgen.overworld_preset
-- local OVERWORLD_MIN = overworld.min_y

mcl_levelgen.register_placed_feature ("mcl_sculk:sculk_patch_deep_dark", {
	configured_feature = "mcl_sculk:sculk_patch_deep_dark",
	placement_modifiers = {
		-- mcl_levelgen.build_count (TWO_HUNDRED_AND_FIFTY_SIX),
		-- mcl_levelgen.build_in_square (),
		-- mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 256)),
		-- mcl_levelgen.build_in_biome (),
		-- Not yet implemented.
	},
})

mcl_levelgen.register_placed_feature ("mcl_sculk:sculk_vein", {
	configured_feature = "mcl_sculk:sculk_patch_deep_dark",
	placement_modifiers = {
		-- Not yet implemented.
	},
})
