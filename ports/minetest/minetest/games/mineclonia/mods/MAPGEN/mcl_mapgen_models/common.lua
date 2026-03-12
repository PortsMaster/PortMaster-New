------------------------------------------------------------------------
-- Lua models of the built-in map generators.
------------------------------------------------------------------------

function mcl_mapgen_models.parse_flags (flagparam)
	local flags = core.get_mapgen_setting (flagparam)
	local flagtbl = {}
	for _, flagword in ipairs (flags:split (",")) do
		local trimmed = flagword:trim ()
		if trimmed:sub (1, 2) == "no" then
			flagtbl[trimmed:sub (3)] = false
		else
			flagtbl[trimmed] = true
		end
	end
	return flagtbl
end

function mcl_mapgen_models.ersatz_model ()
	local sea_level = core.get_mapgen_setting ("water_level")
	return {
		is_ersatz_model = true,
		get_biome_override = function (x, z)
			return nil
		end,
		get_column_height = function (x, z)
			return sea_level + 1
		end,
	}
end
