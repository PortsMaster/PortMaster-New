------------------------------------------------------------------------
-- Lua models of the Carpathian map generator.
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

function mcl_mapgen_models.carpathian_mapgen_model ()
	local np_height1
		= core.get_mapgen_setting_noiseparams ("mgcarpathian_np_height1")
	local np_height2
		= core.get_mapgen_setting_noiseparams ("mgcarpathian_np_height2")
	local np_height3
		= core.get_mapgen_setting_noiseparams ("mgcarpathian_np_height3")
	local np_height4
		= core.get_mapgen_setting_noiseparams ("mgcarpathian_np_height4")
	local np_hills_terrain
		= core.get_mapgen_setting_noiseparams ("mgcarpathian_np_hills_terrain")
	local np_ridge_terrain
		= core.get_mapgen_setting_noiseparams ("mgcarpathian_np_ridge_terrain")
	local np_step_terrain
		= core.get_mapgen_setting_noiseparams ("mgcarpathian_np_step_terrain")
	local np_hills
		= core.get_mapgen_setting_noiseparams ("mgcarpathian_np_hills")
	local np_ridge_mnt
		= core.get_mapgen_setting_noiseparams ("mgcarpathian_np_ridge_mnt")
	local np_step_mnt
		= core.get_mapgen_setting_noiseparams ("mgcarpathian_np_step_mnt")
	local np_rivers
		= core.get_mapgen_setting_noiseparams ("mgcarpathian_np_rivers")
	local np_mnt_var
		= core.get_mapgen_setting_noiseparams ("mgcarpathian_np_mnt_var")

	local flags = mcl_mapgen_models.parse_flags ("mgcarpathian_spflags")

	local base_level
		= tonumber (core.get_mapgen_setting ("mgcarpathian_base_level"))
	local river_depth
		= tonumber (core.get_mapgen_setting ("mgcarpathian_river_depth"))
	local river_width
		= tonumber (core.get_mapgen_setting ("mgcarpathian_river_width"))
	local valley_width
		= tonumber (core.get_mapgen_setting ("mgcarpathian_valley_width"))
	local water_level = tonumber (core.get_mapgen_setting ("water_level"))
	local grad_wl = 1 - water_level

	local n_height1 = core.get_value_noise (np_height1)
	local n_height2 = core.get_value_noise (np_height2)
	local n_height3 = core.get_value_noise (np_height3)
	local n_height4 = core.get_value_noise (np_height4)
	local n_hills_terrain = core.get_value_noise (np_hills_terrain)
	local n_ridge_terrain = core.get_value_noise (np_ridge_terrain)
	local n_step_terrain = core.get_value_noise (np_step_terrain)
	local n_hills = core.get_value_noise (np_hills)
	local n_ridge_mnt = core.get_value_noise (np_ridge_mnt)
	local n_step_mnt = core.get_value_noise (np_step_mnt)
	local n_rivers = core.get_value_noise (np_rivers)
	local n_mnt_var = core.get_value_noise (np_mnt_var)

	local gen_rivers = flags.rivers

	local mathmin = math.min
	local mathmax = math.max
	local mathabs = math.abs
	local ceil = math.ceil
	local floor = math.floor
	local sqrt = math.sqrt

	local function get_steps (n)
		local w = 0.5
		local k = floor (n / w)
		local f = (n - k * w) / w
		local s = mathmin (2.0 * f, 1.0)
		return (k + s) * w
	end

	local max_mnt_var = value_noise_max (np_mnt_var)

	local function sortlerp (a, b)
		local m2 = a + max_mnt_var * (b - a)
		local m1 = a + -max_mnt_var * (b - a)
		return mathmax (m2, m1), mathmin (m1, m2)
	end

	local function lerp (a, b, progress)
		return a + progress * (b - a)
	end

	local pos = vector.new ()
	return {
		is_ersatz_model = false,
		get_biome_override = function (x, z)
			pos.x = x
			pos.y = z
			local height1 = n_height1:get_2d (pos)
			local height2 = n_height2:get_2d (pos)
			local height3 = n_height3:get_2d (pos)
			local height4 = n_height4:get_2d (pos)

			local hterabs = mathabs (n_hills_terrain:get_2d (pos))
			local n_hills = n_hills:get_2d (pos)
			local hill_mnt = hterabs * hterabs * hterabs * n_hills * n_hills

			local rterabs = mathabs (n_ridge_terrain:get_2d (pos))
			local n_ridge_mnt = n_ridge_mnt:get_2d (pos)
			local ridge_mnt = rterabs * rterabs * rterabs
				* (1.0 - mathabs (n_ridge_mnt))

			local sterabs = mathabs (n_step_terrain:get_2d (pos))
			local n_step_mnt = n_step_mnt:get_2d (pos)
			local step_mnt = sterabs * sterabs * sterabs
				* get_steps (n_step_mnt)

			local y = water_level + 3
			pos.y = y
			pos.z = z
			local mnt_var = n_mnt_var:get_3d (pos)
			local hill1 = lerp (height1, height2, mnt_var)
			local hill2 = lerp (height3, height4, mnt_var)
			local hill3 = lerp (height3, height2, mnt_var)
			local hill4 = lerp (height1, height4, mnt_var)
			local hilliness = mathmax (mathmin (hill1, hill2),
						   mathmin (hill3, hill4))
			local hills = hill_mnt * hilliness
			local ridged_mountains = ridge_mnt * hilliness
			local step_mountains = step_mnt * hilliness
			local grad = y < water_level
				and grad_wl + (water_level - y) * 3
				or (1 - y)
			local mountains = hills + ridged_mountains + step_mountains
			local est_surface_level = (base_level + mountains + grad) / 4

			if est_surface_level < -20 then
				return "DeepOcean"
			elseif est_surface_level < -2 then
				return "Ocean"
			end
			return nil
		end,
		get_column_height = function (x, z, fluids_solid_p)
			pos.x = x
			pos.y = z
			local height1 = n_height1:get_2d (pos)
			local height2 = n_height2:get_2d (pos)
			local height3 = n_height3:get_2d (pos)
			local height4 = n_height4:get_2d (pos)

			local hterabs = mathabs (n_hills_terrain:get_2d (pos))
			local n_hills = n_hills:get_2d (pos)
			local hill_mnt = hterabs * hterabs * hterabs * n_hills * n_hills

			local rterabs = mathabs (n_ridge_terrain:get_2d (pos))
			local n_ridge_mnt = n_ridge_mnt:get_2d (pos)
			local ridge_mnt = rterabs * rterabs * rterabs
				* (1.0 - mathabs (n_ridge_mnt))

			local sterabs = mathabs (n_step_terrain:get_2d (pos))
			local n_step_mnt = n_step_mnt:get_2d (pos)
			local step_mnt = sterabs * sterabs * sterabs
				* get_steps (n_step_mnt)

			local valley = 1.0
			local river = 0.0

			local hill1max, hill1min = sortlerp (height1, height2)
			local hill2max, hill2min = sortlerp (height3, height4)
			local hill3max, hill3min = sortlerp (height3, height2)
			local hill4max, hill4min = sortlerp (height4, height3)

			local hilliness_max = mathmax (hill1max, hill2max,
						       hill3max, hill4max)
			local hilliness_min = mathmin (hill1min, hill2min,
						       hill3min, hill4min)

			local hills_max = hill_mnt * hilliness_max
			local ridged_mountains_max = ridge_mnt * hilliness_max
			local step_mountains_max = step_mnt * hilliness_max
			local mountains_max = hills_max + ridged_mountains_max
				+ step_mountains_max
			local hills_min = hill_mnt * hilliness_min
			local ridged_mountains_min = ridge_mnt * hilliness_min
			local step_mountains_min = step_mnt * hilliness_min
			local mountains_min = hills_min + ridged_mountains_min
				+ step_mountains_min

			local y_max = ceil ((base_level + mathmax (mountains_max,
								   mountains_min) + 1) / 2)
			local y_min = floor ((base_level + mathmin (mountains_min,
								    mountains_max) + 2) / 2)

			if gen_rivers then
				river = mathabs (n_rivers:get_2d (pos)) - river_width
				if river <= valley_width then
					if river < 0.0 then
						valley = river
					else
						local riversc = river / valley_width
						valley = riversc * riversc * (3.0 - 2.0 * riversc)
					end
					if valley < 0.0 then
						local tem = water_level - sqrt (-valley) * river_depth
						y_min = mathmin (y_min, tem)
					else
						-- XXX: fewer assumptions.
						y_min = mathmin (y_min, -128)
					end
				end
			end

			pos.z = z
			for y = y_max, y_min, -1 do
				pos.y = y
				local mnt_var = n_mnt_var:get_3d (pos)
				local hill1 = lerp (height1, height2, mnt_var)
				local hill2 = lerp (height3, height4, mnt_var)
				local hill3 = lerp (height3, height2, mnt_var)
				local hill4 = lerp (height1, height4, mnt_var)
				local hilliness = mathmax (mathmin (hill1, hill2),
							   mathmin (hill3, hill4))
				local hills = hill_mnt * hilliness
				local ridged_mountains = ridge_mnt * hilliness
				local step_mountains = step_mnt * hilliness
				local grad = y < water_level
					and grad_wl + (water_level - y) * 3
					or (1 - y)
				local mountains = hills + ridged_mountains + step_mountains
				local surface_level = base_level + mountains + grad

				if gen_rivers and river <= valley_width then
					if valley < 0.0 then
						local tem = water_level - sqrt (-valley) * river_depth
						surface_level = mathmin (surface_level, tem)
					elseif surface_level > water_level then
						surface_level = water_level
							+ (surface_level - water_level) * valley
					end
				end

				if y < surface_level then
					return y + 1
				elseif y <= water_level and fluids_solid_p then
					return y + 1
				end
			end
			return y_min
		end,
	}
end
