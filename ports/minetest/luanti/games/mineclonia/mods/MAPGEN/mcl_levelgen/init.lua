local prefix = "."
local floor = math.floor

local do_report_consing, last = false

local function print_consing ()
	collectgarbage ("collect")
	local val = collectgarbage ("count")
	if last then
		local new = floor ((val - last) / 1024 + 0.5)
		last = val
		if new >= 0 then
			return floor (val / 1024 + 0.5) .. " MB (+ " .. new .. ")"
		else
			return floor (val / 1024 + 0.5) .. " MB (- " .. -new .. ")"
		end
	else
		last = val
		return floor (val / 1024 + 0.5) .. " MB"
	end
end

local function report_consing (msg)
	if do_report_consing then
		print (msg .. ": " .. print_consing ())
	end
end

local function chunksize_already_configured_p ()
	local mapgen_settings
		= Settings (core.get_worldpath () .. "/map_meta.txt")
	local existing_option = mapgen_settings:get ("chunksize")
	-- chunksize may safely be altered.
	if not existing_option then
		return false
	-- If only `chunksize' exists, its value is 5,
	-- mcl_singlenode_mapgen is not set, and the world directory
	-- is empty of all known persisted files, this is a likewise a
	-- world that has just been created from the main menu whose
	-- chunksize may safely be altered.
	elseif existing_option == "5" then
		if mapgen_settings:get ("mcl_singlenode_mapgen") == "true" then
			return true
		else
			local dir = core.get_dir_list (core.get_worldpath (), false)
			for _, file in ipairs (dir) do
				if file == "env_meta.txt"
					or file == "force_loaded.txt"
					or file == "ipban.txt" then
					return true
				end
			end
		end

		return false
	end
	return true
end

local function init_chunksize ()
	-- N.B. that the Y axis value of the mt_chunk_origin
	-- established here is not meaningful or defined.
	if not core.get_mapgen_chunksize then
		local cs = tonumber (core.get_mapgen_setting ("chunksize")) or 5
		core.ipc_set ("mcl_levelgen:mt_chunksize", vector.new (cs, cs, cs))
		local origin = -floor (cs / 2)
		core.ipc_set ("mcl_levelgen:mt_chunk_origin",
			      vector.new (origin, origin, origin))
	elseif not mcl_vars.enable_mcl_levelgen
	-- Do not alter the chunksize if it has already been
	-- configured, or any misalignment between the previous and
	-- current chunksize may result in existing MapBlocks being
	-- overwritten.
		or chunksize_already_configured_p () then
		local cs = core.get_mapgen_chunksize ()
		core.ipc_set ("mcl_levelgen:mt_chunksize", cs)
		local origin_x, origin_y, origin_z = -floor (cs.x / 2),
			floor (cs.y / 2), -floor (cs.z / 2)
		core.ipc_set ("mcl_levelgen:mt_chunk_origin",
			      vector.new (origin_x, origin_y, origin_z))
	else
		local old_setting = core.get_mapgen_setting ("chunksize")
		local cs = core.get_mapgen_chunksize ()
		if cs.x ~= cs.z then
			local blurb = "Chunk size must be symmetrical along the X axis: "
				.. vector.to_string (cs)
			core.log ("error", blurb)
			error ("Invalid chunk size")
		end

		cs.y = 32 -- So that the MapChunk around sea level
			  -- extends from -256 to 256.
		core.set_mapgen_setting ("chunksize", vector.to_string (cs), true)

		local cs_new = core.get_mapgen_chunksize ()
		-- Verify that the adjustment above has not reset
		-- chunksize to 1, which is the case when minetest has
		-- not been modified to support non-cubic chunksizes.
		if not vector.equals (cs_new, cs) then
			core.set_mapgen_setting ("chunksize", old_setting, true)
			cs = core.get_mapgen_chunksize ()
		else
			cs = cs_new
		end
		core.ipc_set ("mcl_levelgen:mt_chunksize", cs)

		local origin_x, origin_y, origin_z = -floor (cs.x / 2),
			floor (cs.y / 2), -floor (cs.z / 2)
		core.ipc_set ("mcl_levelgen:mt_chunk_origin",
			      vector.new (origin_x, origin_y, origin_z))
	end
	core.ipc_set ("mcl_levelgen:mt_chunk_limit",
		      core.get_mapgen_setting ("mapgen_limit"))
end

if core and not core.get_mod_storage then
	prefix = core.ipc_get ("mcl_levelgen:modpath")
	mcl_vars = core.ipc_get ("mcl_levelgen:mcl_vars")
elseif core then
	prefix = core.get_modpath (core.get_current_modname ())
	core.ipc_set ("mcl_levelgen:modpath", prefix)
	core.ipc_set ("mcl_levelgen:mcl_vars", mcl_vars)
	init_chunksize ()
end

mcl_levelgen = { prefix = prefix, }
mcl_levelgen.report_consing = report_consing
mcl_levelgen.md5 = dofile (prefix .. "/md5.lua")
mcl_levelgen.sha = dofile (prefix .. "/sha2.lua")
mcl_levelgen.lighting_disabled = false
if core and core.settings and core.get_mapgen_setting then
	mcl_levelgen.use_ffi
		= core.settings:get_bool ("mcl_levelgen_use_ffi", false)
	mcl_levelgen.use_large_biomes
		= core.get_mapgen_setting ("mcl_levelgen_use_large_biomes") == "true"
	mcl_levelgen.custom_liquids_enabled
		= core.settings:get_bool ("mcl_liquids_enable", false)
	core.ipc_set ("mcl_levelgen:use_ffi", mcl_levelgen.use_ffi)
	core.ipc_set ("mcl_levelgen:use_large_biomes", mcl_levelgen.use_large_biomes)
	core.ipc_set ("mcl_levelgen:custom_liquids_enabled",
		      mcl_levelgen.custom_liquids_enabled)
elseif core then
	mcl_levelgen.use_ffi = core.ipc_get ("mcl_levelgen:use_ffi") or false
	mcl_levelgen.use_large_biomes
		= core.ipc_get ("mcl_levelgen:use_large_biomes") or false
	mcl_levelgen.custom_liquids_enabled
		= core.ipc_get ("mcl_levelgen:custom_liquids_enabled") or false
else
	mcl_levelgen.use_ffi = false
	mcl_levelgen.use_large_biomes = false
	mcl_levelgen.custom_liquids_enabled = false
end

if mcl_levelgen.use_ffi then
	local ffi = require ("ffi")
	mcl_levelgen.ffi_ns
		= ffi.load (mcl_levelgen.prefix .. "/ffi.so", false)
end

mcl_levelgen.mt_chunksize
	= core and core.ipc_get ("mcl_levelgen:mt_chunksize")
mcl_levelgen.mt_chunk_origin
	= core and core.ipc_get ("mcl_levelgen:mt_chunk_origin")
mcl_levelgen.mt_chunk_limit
	= core and core.ipc_get ("mcl_levelgen:mt_chunk_limit")

dofile (prefix .. "/util.lua")
dofile (prefix .. "/random.lua")
dofile (prefix .. "/noise.lua")
dofile (prefix .. "/density_funcs.lua")
dofile (prefix .. "/biomes.lua")
dofile (prefix .. "/presets.lua")
dofile (prefix .. "/terrain.lua")
dofile (prefix .. "/biomegen.lua")
dofile (prefix .. "/aquifer.lua")
dofile (prefix .. "/surface_system.lua")
dofile (prefix .. "/surface_presets.lua")
dofile (prefix .. "/carvers.lua")
dofile (prefix .. "/schematics.lua")
dofile (prefix .. "/scripting.lua")
dofile (prefix .. "/features.lua")
dofile (prefix .. "/structures.lua")

-- Is this file being loaded into Luanti?
if core and core.get_current_modname then
	dofile (prefix .. "/nodeprops.lua")
	dofile (prefix .. "/templates.lua")
	dofile (prefix .. "/register.lua")
end
