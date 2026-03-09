------------------------------------------------------------------------
-- Lua models of the V5 map generator.
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

function mcl_mapgen_models.v5_mapgen_model ()
	local np_factor
		= core.get_mapgen_setting_noiseparams ("mgv5_np_factor")
	local np_height
		= core.get_mapgen_setting_noiseparams ("mgv5_np_height")
	local np_ground
		= core.get_mapgen_setting_noiseparams ("mgv5_np_ground")

	local n_factor = core.get_value_noise (np_factor)
	local n_height = core.get_value_noise (np_height)
	local n_ground = core.get_value_noise (np_ground)
	local max_ground = value_noise_max (np_ground)

	local sea_level = tonumber (core.get_mapgen_setting ("water_level"))

	local mathmax = math.max
	local ceil = math.ceil
	local floor = math.floor
	local ipairs = ipairs
	local ground_samples = {
		-8, -4, 0, 4, 8, 16, 24, 32, 64, 72, 84,
	}

	local pos = vector.new ()
	return {
		is_ersatz_model = false,
		get_biome_override = function (x, z)
			pos.x = x
			pos.y = z
			local factor = n_factor:get_2d (pos)
			local height = n_height:get_2d (pos)
			local f = mathmax (0.01, 0.55 + factor)
			if f >= 1.0 then
				f = f * 1.6
			end
			local avg_ground = 0.0
			pos.z = z
			for _, y in ipairs (ground_samples) do
				pos.y = y
				avg_ground = avg_ground + n_ground:get_3d (pos)
			end
			avg_ground = avg_ground / #ground_samples
			local h = f * avg_ground + height
			if h < -25 then
				return "DeepOcean"
			elseif h < -2 then
				return "Ocean"
			end
		end,
		get_column_height = function (x, z, fluids_solid_p)
			pos.x = x
			pos.y = z
			local factor = n_factor:get_2d (pos)
			local height = n_height:get_2d (pos)

			local f = mathmax (0.01, 0.55 + factor)
			if f >= 1.0 then
				f = f * 1.6
			end

			local max_y = ceil (ceil (max_ground * f) + height)
			local min_y = floor (floor (-max_ground * f) + height)
			pos.z = z
			for y = max_y, min_y, -1 do
				pos.y = y
				if n_ground:get_3d (pos) * f >= y - height then
					return y + 1
				elseif fluids_solid_p and y <= sea_level then
					return y + 1
				end
			end
			return min_y
		end,
	}
end
