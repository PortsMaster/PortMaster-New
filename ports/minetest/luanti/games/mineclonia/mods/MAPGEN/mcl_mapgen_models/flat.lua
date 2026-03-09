------------------------------------------------------------------------
-- Lua models of the Flat map generator.
------------------------------------------------------------------------

if not core.get_value_noise then
	core.get_value_noise = core.get_perlin
end

function mcl_mapgen_models.flat_mapgen_model ()
	local flags = mcl_mapgen_models.parse_flags ("mgflat_spflags")

	local np_terrain
		= core.get_mapgen_setting_noiseparams ("mgflat_np_terrain")
	local terrain = (flags.lakes or flags.hills)
		and core.get_value_noise (np_terrain)

	local sea_level = tonumber (core.get_mapgen_setting ("water_level"))
	local ground_level
		= tonumber (core.get_mapgen_setting ("mgflat_ground_level"))
	local lake_threshold
		= tonumber (core.get_mapgen_setting ("mgflat_lake_threshold"))
	local lake_steepness
		= tonumber (core.get_mapgen_setting ("mgflat_lake_steepness"))
	local hill_threshold
		= tonumber (core.get_mapgen_setting ("mgflat_hill_threshold"))
	local hill_steepness
		= tonumber (core.get_mapgen_setting ("mgflat_hill_steepness"))

	local ceil = math.ceil
	local floor = math.floor
	local mathmax = math.max

	local function rtz (x)
		if x < 0 then
			return ceil (x)
		else
			return floor (x)
		end
	end

	local pos = vector.new ()
	return {
		is_ersatz_model = false,
		get_biome_override = function (x, z)
			pos.x = x
			pos.y = z
			local n_terrain = terrain and terrain:get_2d (pos) or 0.0
			local stone_level = ground_level
			if flags.lakes and n_terrain < lake_threshold then
				local depress = (lake_threshold - n_terrain) * lake_steepness
				stone_level = stone_level - rtz (depress)

				if stone_level < -16 then
					return "DeepOcean"
				elseif stone_level < -3 then
					return "Ocean"
				end
			end
			return nil
		end,
		get_column_height = function (x, z, fluids_solid_p, dbg)
			pos.x = x
			pos.y = z
			local n_terrain = terrain and terrain:get_2d (pos) or 0.0
			local stone_level = ground_level
			if flags.lakes and n_terrain < lake_threshold then
				local depress = (lake_threshold - n_terrain) * lake_steepness
				stone_level = stone_level - rtz (depress)
			elseif flags.hills and n_terrain > hill_threshold then
				local rise = (n_terrain - hill_threshold) * hill_steepness
				stone_level = stone_level + rtz (rise)
			end

			if fluids_solid_p then
				return mathmax (stone_level, sea_level) + 1
			else
				return stone_level + 1
			end
		end,
	}
end
