-- Register aliases
local doornames = {
	["door"] = "wooden_door",
	["door_jungle"] = "jungle_door",
	["door_spruce"] = "spruce_door",
	["door_dark_oak"] = "dark_oak_door",
	["door_birch"] = "birch_door",
	["door_acacia"] = "acacia_door",
	["door_iron"] = "iron_door",
}

for oldname, newname in pairs(doornames) do
	core.register_alias("doors:"..oldname, "mcl_doors:"..newname)
	core.register_alias("doors:"..oldname.."_t_1", "mcl_doors:"..newname.."_t_1")
	core.register_alias("doors:"..oldname.."_b_1", "mcl_doors:"..newname.."_b_1")
	core.register_alias("doors:"..oldname.."_t_2", "mcl_doors:"..newname.."_t_2")
	core.register_alias("doors:"..oldname.."_b_2", "mcl_doors:"..newname.."_b_2")
end

core.register_alias("doors:trapdoor", "mcl_doors:trapdoor")
core.register_alias("doors:trapdoor_open", "mcl_doors:trapdoor_open")
core.register_alias("doors:iron_trapdoor", "mcl_doors:iron_trapdoor")
core.register_alias("doors:iron_trapdoor_open", "mcl_doors:iron_trapdoor_open")
