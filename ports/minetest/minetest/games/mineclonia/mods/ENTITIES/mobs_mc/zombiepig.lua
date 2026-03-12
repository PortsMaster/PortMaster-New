-- Backwards compat code for "old" 0.83 and prior pigman. This transforms all
-- existing pigmen into the new zombified piglins.
local S = core.get_translator(core.get_current_modname())
local pigman = {
	description = S("Zombified Piglin"),
	textures = {{ "" }},
	after_activate = function(self)
		mcl_util.replace_mob(self.object, "mobs_mc:zombified_piglin")
	end,
	hp_min = 0,
}

mcl_mobs.register_mob("mobs_mc:pigman", pigman)
mcl_mobs.register_mob("mobs_mc:baby_pigman", pigman)
