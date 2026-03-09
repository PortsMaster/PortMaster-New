------------------------------------------------------------------------
-- Level generator registration.
------------------------------------------------------------------------

mcl_levelgen.verbose = false
mcl_levelgen.enable_ersatz = false

-- Constants required by level generator scripts.
mcl_levelgen.REQUIRED_CONTEXT_Y = 2
mcl_levelgen.REQUIRED_CONTEXT_XZ = 1

local seed
local ull = mcl_levelgen.ull
local tostringull = mcl_levelgen.tostringull
local stringtoull = mcl_levelgen.stringtoull

if core.get_mapgen_setting then
	local seed_str = core.get_mapgen_setting ("seed")

	seed = ull (0, 0)
	mcl_levelgen.seed = seed
	if not stringtoull (seed, seed_str) then
		core.log ("error", "`" .. seed_str .. "' is not a valid seed")
	end
	core.ipc_set ("mcl_levelgen:level_seed", seed)

	if core.settings then
		mcl_levelgen.verbose
			= core.settings:get_bool ("mcl_verbose_level_generation") or false
		core.ipc_set ("mcl_levelgen:verbose", mcl_levelgen.verbose)
	else
		mcl_levelgen.verbose = core.ipc_get ("mcl_levelgen:verbose")
	end
else
	-- Async environment.
	seed = core.ipc_get ("mcl_levelgen:level_seed")
	mcl_levelgen.seed = seed
end

if mcl_vars.enable_mcl_levelgen then

mcl_levelgen.biome_seed = mcl_levelgen.get_biome_seed (seed)
mcl_levelgen.levelgen_enabled = true

-- Load existing biome ID assignments.
local assignments = {}
local mod_storage

if core and not core.get_mod_storage then
	-- Async or mapgen environment.
	assignments = core.ipc_get ("mcl_levelgen:biome_id_assignments")
else
	mod_storage = core.get_mod_storage ()
	local str = mod_storage:get_string ("biome_id_assignments")
	if str and str ~= "" then
		assignments = core.deserialize (str)
	end
end

-- Assign IDs to new biomes if any.
mcl_levelgen.assign_biome_ids (assignments)

-- Register default dimensions.
dofile (mcl_levelgen.prefix .. "/dimensions.lua")

-- Create level presets now.
local seed = mcl_levelgen.seed
mcl_levelgen.initialize_dimensions (seed)

if not core.get_mod_storage and not core.save_gen_notify then
	-- Async environment.
	dofile (mcl_levelgen.prefix .. "/async_register.lua")
elseif core.get_mod_storage then
	core.log ("action", ("[mcl_levelgen]: Initializing level generation with seed "
			     .. tostringull (seed) .. " (Biome seed: "
			     .. tostringull (mcl_levelgen.biome_seed) .. ")"))
	mod_storage:set_string ("biome_id_assignments",
				core.serialize (assignments))
	core.ipc_set ("mcl_levelgen:biome_id_assignments", assignments)
	core.register_mapgen_script (mcl_levelgen.prefix .. "/init.lua")
	dofile (mcl_levelgen.prefix .. "/areastore.lua")
	dofile (mcl_levelgen.prefix .. "/post_processing.lua")
	-- Start a second async environment to reduce the probability
	-- that another async environment will be instantiated while
	-- the game is executing, which is apt to block the server
	-- environment for a substantial length of time.
	core.after (1, function ()
		core.handle_async (function () core.ipc_poll ("", 1200) end,
				   function () end)
		core.handle_async (function () end, function () end)
	end)
end

if core and not core.get_player_by_name then
	mcl_levelgen.is_levelgen_environment = true
	-- Run level generation scripts.
	for _, script in ipairs (core.ipc_get ("mcl_levelgen:levelgen_scripts")) do
		dofile (script.script)
	end

	-- Initialize feature priorities.
	if mcl_levelgen.load_feature_environment then
		mcl_levelgen.initialize_biome_features ()
	end
	mcl_levelgen.run_on_scripts_loaded ()
elseif core then
	-- Load and register jigsaw blocks.
	dofile (mcl_levelgen.prefix .. "/jigsaw.lua")
	dofile (mcl_levelgen.prefix .. "/default_structures.lua")
	mcl_levelgen.register_levelgen_script (mcl_levelgen.prefix
					       .. "/default_structures.lua")
	mcl_levelgen.register_levelgen_script (mcl_levelgen.prefix
					       .. "/default_features.lua")

	-- The previous file has reached Lua's file-local variable
	-- limit and consequently a number of default features are
	-- implemented in a separate file.
	dofile (mcl_levelgen.prefix .. "/default_features1.lua")
	mcl_levelgen.register_levelgen_script (mcl_levelgen.prefix
					       .. "/default_features1.lua")
end

if core and not core.get_mod_storage and core.get_gen_notify then
	-- Emerge environment; create terrain after structures are
	-- registered.
	dofile (mcl_levelgen.prefix .. "/mg_register.lua")
end

else

-- Define stubs for a number of functions that would otherwise not be
-- loaded.

mcl_levelgen.seed = seed
mcl_levelgen.biome_seed = ull (0, 0)
mcl_levelgen.levelgen_enabled = false

function mcl_levelgen.register_notification_handler (_, _)
end

function mcl_levelgen.conv_pos (v)
	return nil
end

function mcl_levelgen.conv_pos_raw (v)
	return nil
end

function mcl_levelgen.conv_pos_dimension (v)
	return nil
end

local empty = {}

function mcl_levelgen.get_structures_at (_, _)
	return empty
end

function mcl_levelgen.is_protected_chunk (_)
	return false
end

function mcl_levelgen.get_dimension (_)
	return nil
end

if core.get_mapgen_setting ("mcl_levelgen_enable_ersatz") == "true"
	and core.get_mapgen_setting ("mg_name") ~= "singlenode"
	and core.features.generate_decorations_biomes then
	-- Load the ersatz level generation system.
	mcl_levelgen.enable_ersatz = true
	mcl_levelgen.ersatz_enable_carvers = false
	if core.get_mapgen_setting ("mcl_levelgen_enable_ersatz_carvers") == "true" then
		mcl_levelgen.ersatz_enable_carvers = true
	end
	dofile (mcl_levelgen.prefix .. "/ersatz.lua")
end

end
