--------------------------------------------------------------------------
-- Level generator scripting interface.
--------------------------------------------------------------------------

local level_generator_scripts = {}
local scripts_loaded = false
local script_initialization_cbs = {}

function mcl_levelgen.register_levelgen_script (script, ersatz)
	if not core then
		mcl_levelgen.is_levelgen_environment = true
		dofile (script)
	elseif core.get_mod_storage then
		table.insert (level_generator_scripts, {
			script = script,
			ersatz_supported = ersatz,
		})
		core.ipc_set ("mcl_levelgen:levelgen_scripts",
			      level_generator_scripts)
	end
end

local blurb = "`register_on_scripts_loaded' invoked after script initialization"

function mcl_levelgen.register_on_scripts_loaded (fn)
	assert (not scripts_loaded, blurb)
	table.insert (script_initialization_cbs, fn)
end

function mcl_levelgen.run_on_scripts_loaded ()
	scripts_loaded = true
	for _, fn in ipairs (script_initialization_cbs) do
		fn ()
	end
end

------------------------------------------------------------------------
-- Feature environment stubs.
------------------------------------------------------------------------

function mcl_levelgen.register_loot_table (_, _)
end
