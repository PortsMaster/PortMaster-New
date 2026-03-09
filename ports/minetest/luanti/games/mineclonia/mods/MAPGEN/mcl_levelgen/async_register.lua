--------------------------------------------------------------------------
-- Feature generation environment registration.
--------------------------------------------------------------------------

if core.global_exists ("jit") then
	jit.opt.start ("maxmcode=40960", "maxtrace=100000",
		       "loopunroll=35", "maxside=1000")
end

-- jit.p = require ("jit.p")
-- jit.p.start ("fvm1")

mcl_levelgen.load_feature_environment = true

-- Load `features.lua' a second time to define the feature generation
-- environment.
dofile (mcl_levelgen.prefix .. "/post_processing.lua")
dofile (mcl_levelgen.prefix .. "/features.lua")
mcl_levelgen.initialize_nodeprops_in_async_env ()
mcl_levelgen.initialize_portable_schematics ()
