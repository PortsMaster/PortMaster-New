mcl_mapgen_models = {}
local model = nil

local modpath = core.get_modpath (core.get_current_modname ())
dofile (modpath .. "/common.lua")
dofile (modpath .. "/v7.lua")
dofile (modpath .. "/valleys.lua")
dofile (modpath .. "/carpathian.lua")
dofile (modpath .. "/v5.lua")
dofile (modpath .. "/flat.lua")

------------------------------------------------------------------------
-- Lua models of the built-in map generators.
------------------------------------------------------------------------

local name

local function set_model ()
	if name == "v7" then
		model = mcl_mapgen_models.v7_mapgen_model ()
	elseif name == "valleys" then
		model = mcl_mapgen_models.valleys_mapgen_model ()
	elseif name == "carpathian" then
		model = mcl_mapgen_models.carpathian_mapgen_model ()
	elseif name == "v5" then
		model = mcl_mapgen_models.v5_mapgen_model ()
	elseif name == "flat" then
		model = mcl_mapgen_models.flat_mapgen_model ()
	else
		model = mcl_mapgen_models.ersatz_model ()
	end
end

if core and core.get_mod_storage then

name = core.get_mapgen_setting ("mg_name")
core.ipc_set ("mcl_mapgen_models:mg_name", name)

mcl_info.register_debug_field ("Estimated Generation Height", {
	level = 4,
	func = function (_, pos)
		if not model then
			set_model ()
		end
		if model then
			local x = math.floor (pos.x + 0.5)
			local z = math.floor (pos.z + 0.5)
			local fn = model.get_column_height
			local biome = model.get_biome_override (x, z) or "N/A"
			return string.format ("y=%d/%d (%s)", fn (x, z, false), fn (x, z, true),
					      biome)
		else
			return "N/A"
		end
	end,
})

core.register_mapgen_script (modpath .. "/init.lua")

else

name = core.ipc_get ("mcl_mapgen_models:mg_name")

end

------------------------------------------------------------------------
-- Exports.
------------------------------------------------------------------------

function mcl_mapgen_models.get_mapgen_model ()
	if not model then
		set_model ()
	end
	return model
end
