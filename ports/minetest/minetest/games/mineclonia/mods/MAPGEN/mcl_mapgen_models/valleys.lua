------------------------------------------------------------------------
-- Lua models of the Valleys map generator.
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

function mcl_mapgen_models.valleys_mapgen_model ()
	local np_inter_valley_fill
		= core.get_mapgen_setting_noiseparams ("mgvalleys_np_inter_valley_fill")
	local np_inter_valley_slope
		= core.get_mapgen_setting_noiseparams ("mgvalleys_np_inter_valley_slope")
	local np_rivers
		= core.get_mapgen_setting_noiseparams ("mgvalleys_np_rivers")
	local np_terrain_height
		= core.get_mapgen_setting_noiseparams ("mgvalleys_np_terrain_height")
	local np_valley_depth
		= core.get_mapgen_setting_noiseparams ("mgvalleys_np_valley_depth")
	local np_valley_profile
		= core.get_mapgen_setting_noiseparams ("mgvalleys_np_valley_profile")
	local flags = mcl_mapgen_models.parse_flags ("mgvalleys_spflags")

	local mgvalleys_river_depth
		= tonumber (core.get_mapgen_setting ("mgvalleys_river_depth"))
	local mgvalleys_river_size
		= tonumber (core.get_mapgen_setting ("mgvalleys_river_size"))
	local river_size_factor = mgvalleys_river_size / 100.0
	local river_depth_bed = mgvalleys_river_depth + 1.0

	local water_level = tonumber (core.get_mapgen_setting ("water_level"))

	local inter_valley_slope = core.get_value_noise (np_inter_valley_slope)
	local rivers = core.get_value_noise (np_rivers)
	local terrain_height = core.get_value_noise (np_terrain_height)
	local valley_depth = core.get_value_noise (np_valley_depth)
	local valley_profile = core.get_value_noise (np_valley_profile)
	local inter_valley_fill = core.get_value_noise (np_inter_valley_fill)

	local inter_valley_fill_max = value_noise_max (np_inter_valley_fill)

	local mathabs = math.abs
	local mathmax = math.max
	local mathmin = math.min
	local mathexp = math.exp
	local mathsqrt = math.sqrt

	local floor = math.floor
	local ceil = math.ceil

	local vary_river_depth = flags.vary_river_depth
	local f_altitude_chill = flags.altitude_chill
	local altitude_chill
		= tonumber (core.get_mapgen_setting ("mgvalleys_altitude_chill"))

	local pos = vector.new ()

	local function rtz (x)
		if x < 0 then
			return ceil (x)
		else
			return floor (x)
		end
	end

	return {
		is_ersatz_model = false,
		get_biome_override = function (x, z)
			pos.x = x
			pos.y = z

			local n_terrain_height = terrain_height:get_2d (pos)
			local n_valley = valley_depth:get_2d (pos)
			local n_valley_profile = valley_profile:get_2d (pos)
			local n_rivers = rivers:get_2d (pos)
			local river = mathabs (n_rivers) - river_size_factor
			local tv = mathmax (river / n_valley_profile, 0.0)
			local valley_d = n_valley * n_valley;
			local base = n_terrain_height + valley_d;
			local valley_h = valley_d * (1.0 - mathexp (-tv * tv))
			local est_surface_y = base + valley_h

			if est_surface_y < water_level - 20 then
				return "DeepOcean"
			elseif est_surface_y < water_level then
				return "Ocean"
			end
			return nil
		end,
		get_column_height = function (x, z, liquids_solid)
			pos.x = x
			pos.y = z

			local n_slope = inter_valley_slope:get_2d (pos)
			local n_rivers = rivers:get_2d (pos)
			local n_terrain_height = terrain_height:get_2d (pos)
			local n_valley = valley_depth:get_2d (pos)
			local n_valley_profile = valley_profile:get_2d (pos)

			local valley_d = n_valley * n_valley;
			local base = n_terrain_height + valley_d;
			local river = mathabs (n_rivers) - river_size_factor
			local tv = mathmax (river / n_valley_profile, 0.0)
			local valley_h = valley_d * (1.0 - mathexp (-tv * tv))
			local surface_y = base + valley_h
			local slope = n_slope * valley_h
			local river_y = base - 1.0

			if river < 0.0 then
				local tr = river / river_size_factor + 1.0
				local depth = river_depth_bed
					* mathsqrt (mathmax (0.0, 1.0 - tr * tr))
				surface_y = mathmin (mathmax (base - depth, water_level - 3),
						     surface_y)
				slope = 0.0
			end

			if vary_river_depth then
				local t_heat = core.get_heat (pos)
				local heat = f_altitude_chill
					and t_heat + 5.0 - (base - water_level) * 20.0 / altitude_chill
					or t_heat
				local delta = core.get_humidity (pos) - 50.0
				if delta < 0.0 then
					local t_evap = (heat - 32.0) / 300.0
					river_y = river_y + delta * mathmax (t_evap, 0.08)
				end
			end

			local max_gradient
				= ceil (inter_valley_fill_max * slope)

			local column_max_y = rtz (surface_y)
			if liquids_solid and column_max_y < water_level then
				column_max_y = water_level
			end
			local miny = column_max_y - max_gradient
			pos.z = z
			for y = column_max_y + max_gradient, miny, -1 do
				pos.y = y
				local n_fill = inter_valley_fill:get_3d (pos)
				local surface_delta = y - surface_y
				local density = slope * n_fill - surface_delta

				if density > 0.0 then
					return y + 1
				elseif y <= water_level and liquids_solid then
					return y + 1
				elseif y <= river_y and liquids_solid then
					return y + 1
				end
			end
			return miny
		end
	}
end
