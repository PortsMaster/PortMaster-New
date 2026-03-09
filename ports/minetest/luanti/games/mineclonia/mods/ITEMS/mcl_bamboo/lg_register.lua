------------------------------------------------------------------------
-- Async bamboo feature.
------------------------------------------------------------------------

-- local bamboo_cfg = {
-- 	-- Probability of podzol generation.
-- 	probability = nil,
-- }

local cid_bamboo_trunk
	= core.get_content_id ("mcl_bamboo:bamboo_big")
local cid_bamboo_small
	= core.get_content_id ("mcl_bamboo:bamboo_big_leafsmall")
local cid_bamboo_large
	= core.get_content_id ("mcl_bamboo:bamboo_big_leafbig")
local cid_podzol
	= core.get_content_id ("mcl_core:podzol")

local run_minp = mcl_levelgen.placement_run_minp
local run_maxp = mcl_levelgen.placement_run_maxp
local is_air = mcl_levelgen.is_air
local is_air_with_dirt_below = mcl_levelgen.is_air_with_dirt_below
local index_heightmap = mcl_levelgen.index_heightmap
local set_block = mcl_levelgen.set_block
-- local get_block = mcl_levelgen.get_block

local function replay_rng (rng, cfg)
	rng:next_within (12)
	if rng:next_float () < cfg.probability then
		rng:next_integer (4)
	end
	rng:next_within (4)
end

local function bamboo_place (_, x, y, z, cfg, rng)
	if y < run_minp.y or y > run_maxp.y then
		replay_rng (rng, cfg)
		return false
	else
		if not is_air (x, y, z) then
			replay_rng (rng, cfg)
			return false
		end

		local trunk_height = 5 + rng:next_within (12)
		if rng:next_float () < cfg.probability then
			-- Generate podzol.
			local r = 1 + rng:next_within (4)
			local dsqr = r * r

			for dx = -r, r do
				for dz = -r, r do
					local d = dx * dx + dz * dz
					if d < dsqr then
						local x = x + dx
						local z = z + dz
						local y = index_heightmap (x, z, false)
						if is_air_with_dirt_below (x, y, z) then
							set_block (x, y - 1, z, cid_podzol, 0)
						end
					end
				end
			end
		end

		-- Generate the trunk of the bamboo.
		local random4dir = rng:next_within (4)
		local max_height = 0

		for yend = y, y + trunk_height - 1 do
			if not is_air (x, y, z) then
				break
			end
			max_height = max_height + 1
		end

		if max_height > 3 then
			for i = 0, max_height - 4 do
				set_block (x, y + i, z, cid_bamboo_trunk, random4dir)
			end
			set_block (x, y + max_height - 3, z, cid_bamboo_small, random4dir)
			set_block (x, y + max_height - 2, z, cid_bamboo_large, random4dir)
			set_block (x, y + max_height - 1, z, cid_bamboo_large, random4dir)
		else
			for i = 1, max_height do
				set_block (x, y + i, z, cid_bamboo_trunk, random4dir)
			end
		end
		return true
	end
end

mcl_levelgen.register_feature ("mcl_bamboo:bamboo", {
	place = bamboo_place,
})

mcl_levelgen.register_configured_feature ("mcl_bamboo:bamboo_some_podzol", {
	feature = "mcl_bamboo:bamboo",
	probability = 0.2,
})

mcl_levelgen.register_configured_feature ("mcl_bamboo:bamboo_no_podzol", {
	feature = "mcl_bamboo:bamboo",
	probability = 0.0,
})

mcl_levelgen.register_placed_feature ("mcl_bamboo:bamboo", {
	configured_feature = "mcl_bamboo:bamboo_some_podzol",
	placement_modifiers = {
		mcl_levelgen.build_noise_based_count (160, 80.0, 0.3),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		mcl_levelgen.scan_beneath_leaves_far,
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_bamboo:bamboo_light", {
	configured_feature = "mcl_bamboo:bamboo_no_podzol",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (4),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("world_surface"),
		mcl_levelgen.scan_beneath_leaves_far,
		mcl_levelgen.build_in_biome (),
	},
})
