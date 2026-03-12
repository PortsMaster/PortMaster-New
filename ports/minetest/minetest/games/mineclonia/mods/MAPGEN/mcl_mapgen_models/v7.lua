------------------------------------------------------------------------
-- Lua models of the V7 map generator.
------------------------------------------------------------------------

if not core.get_value_noise then
	core.get_value_noise = core.get_perlin
end

local function value_noise_max (params)
	local a = 1.0
	local f = 1.0
	local g = 1.0
	for i = 0, params.octaves - 1 do
		a = a + g * 1.0
		f = f * params.lacunarity
		g = g * params.persistence
	end
	return params.offset + a * params.scale
end

function mcl_mapgen_models.v7_mapgen_model ()
	local np_terrain_base
		= core.get_mapgen_setting_noiseparams ("mgv7_np_terrain_base")
	local np_terrain_alt
		= core.get_mapgen_setting_noiseparams ("mgv7_np_terrain_alt")
	local np_terrain_persist
		= core.get_mapgen_setting_noiseparams ("mgv7_np_terrain_persist")
	local np_height_select
		= core.get_mapgen_setting_noiseparams ("mgv7_np_height_select")
	local np_mount_height
		= core.get_mapgen_setting_noiseparams ("mgv7_np_mount_height")
	local np_ridge_uwater
		= core.get_mapgen_setting_noiseparams ("mgv7_np_ridge_uwater")
	local np_mountain
		= core.get_mapgen_setting_noiseparams ("mgv7_np_mountain")
	local np_ridge
		= core.get_mapgen_setting_noiseparams ("mgv7_np_ridge")
	local mount_zero_level
		= tonumber (core.get_mapgen_setting ("mgv7_mount_zero_level"))
	local flags = mcl_mapgen_models.parse_flags ("mgv7_spflags")

	local terrain_persist = core.get_value_noise (np_terrain_persist)
	local height_select = core.get_value_noise (np_height_select)
	local mount_height = core.get_value_noise (np_mount_height)
	local ridge_uwater = core.get_value_noise (np_ridge_uwater)
	local mountain = core.get_value_noise (np_mountain)
	local ridge = core.get_value_noise (np_ridge)
	local pos = vector.new ()

	local mountain_noise_max = value_noise_max (np_mountain)
	local ridge_min = -value_noise_max (np_ridge)

	local mathmin = math.min
	local mathmax = math.max
	local mathabs = math.abs
	local ceil = math.ceil
	local floor = math.floor
	local huge = math.huge

	local mgv7_mountains = flags.mountains or false
	local mgv7_ridges = flags.ridges or false
	local sea_level = tonumber (core.get_mapgen_setting ("water_level"))

	local mg_overworld_min = mcl_vars.mg_overworld_min

	local v7_base_height
	local function v7_sampler_default (y, pos)
		return y <= v7_base_height
	end

	local v7_absuwatern
	local function v7_sampler_river (y, pos)
		local altitude = y - sea_level
		local height_mod = (altitude + 17.0) / 2.5
		local width_mod = 0.2 - v7_absuwatern
		local nridge = ridge:get_3d (pos)
			* mathmax (0, altitude) / 7.0
		return nridge + width_mod * height_mod < 0.6
	end

	local v7_mounthn
	local function v7_sampler_mountains (y, pos)
		if y <= v7_base_height then
			return true
		else
			local density_gradient = -((y - mount_zero_level) / v7_mounthn)
			local mountn = mountain:get_3d (pos)
			return mountn + density_gradient >= 0.0
		end
	end

	local function v7_sampler_mountains_river (y, pos)
		return v7_sampler_river (y, pos)
			and v7_sampler_mountains (y, pos)
	end

	local function rtz (x)
		if x < 0 then
			return ceil (x)
		else
			return floor (x)
		end
	end

	local function base_terrain_level ()
		-- MapgenV7::baseTerrainLevelFromMap (int)
		local persistence = terrain_persist:get_2d (pos)
		np_terrain_base.persistence = persistence
		np_terrain_alt.persistence = persistence
		local terrain_base = core.get_value_noise (np_terrain_base)
		local terrain_alt = core.get_value_noise (np_terrain_alt)
		local hselect = height_select:get_2d (pos)
		local height_alt = terrain_alt:get_2d (pos)
		local height_base = terrain_base:get_2d (pos)
		local hselect = mathmax (0.0, mathmin (hselect, 1.0))
		local base_height

		if height_alt > height_base then
			base_height = height_alt
		else
			base_height = (height_base * hselect)
				+ (height_alt * (1.0 - hselect))
		end
		return rtz (base_height)
	end

	local mount_noise_samples = {
		0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120,
	}
	local ipairs = ipairs

	return {
		is_ersatz_model = false,
		get_biome_override = function (x, z)
			pos.x = x
			pos.y = z
			local base_height = base_terrain_level ()

			if base_height < sea_level - 2 then
				local mounthn = mathmax (1.0, mount_height:get_2d (pos))
				pos.z = z

				local mountn = 0.0
				for i, y in ipairs (mount_noise_samples) do
					pos.y = y
					mountn = mathmax (mountn, mountain:get_3d (pos))
				end

				local y = mathmax (mountn * mounthn, 0.0)
					+ mount_zero_level
				base_height = base_height + y

				if base_height < sea_level - 15 then
					return "DeepOcean"
				elseif base_height < sea_level - 2 then
					return "Ocean"
				end
			end
			return nil
		end,
		get_column_height = function (x, z, liquids_solid)
			pos.x = x
			pos.y = z
			local base_height = base_terrain_level ()

			-- MapGenV7::getRiverChannelFromMap (int, int, s16)
			local any_river = false
			local river_max = -huge
			if mgv7_ridges then
				v7_absuwatern = mathabs (ridge_uwater:get_2d (pos)) * 2.0
				any_river = v7_absuwatern <= 0.2
				if any_river then
					local width_mod = 0.2 - v7_absuwatern

					-- m = (-119w + 10.5) / (2.5n + 7w)
					-- Where y - water_level = M, N = ridge_min, and W = width_mod.
					local max_alt = (-119 * width_mod + 10.5)
						/ (2.5 * ridge_min + 7 * width_mod)
					river_max = ceil (sea_level + max_alt)
				end
			end

			-- MapgenV7::getMountainTerrainFromMap (int, int, s16)
			local mountmax = -huge
			if mgv7_mountains then
				local mounthn = mathmax (1.0, mount_height:get_2d (pos))
				mountmax = ceil (mounthn / mountain_noise_max)
					+ ceil (mount_zero_level + mounthn)
				v7_mounthn = mounthn
			end

			local v7_sampler = v7_sampler_default
			v7_base_height = base_height
			if mountmax > river_max then
				if any_river then
					v7_sampler = v7_sampler_mountains_river
				else
					v7_sampler = v7_sampler_mountains
				end
			elseif any_river then
				if mgv7_mountains then
					v7_sampler = v7_sampler_mountains_river
				else
					v7_sampler = v7_sampler_river
				end
			end

			pos.x = x
			pos.z = z
			for y = mathmax (base_height, mountmax, river_max),
				mg_overworld_min, -1 do
				pos.y = y
				if (liquids_solid and y <= sea_level)
					or v7_sampler (y, pos) then
					return y + 1
				end
			end
			return mg_overworld_min
		end,
	}
end
