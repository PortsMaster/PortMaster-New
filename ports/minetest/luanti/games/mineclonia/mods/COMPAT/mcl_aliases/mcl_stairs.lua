-- Aliases for backwards-compability with 0.21.0

local materials = {
	"wood", "junglewood", "sprucewood", "acaciawood", "birchwood", "darkwood",
	"cobble", "brick_block", "sandstone", "redsandstone", "stonebrick",
	"quartzblock", "purpur_block", "nether_brick"
}

for m=1, #materials do
	local mat = materials[m]
	core.register_alias("stairs:slab_"..mat, "mcl_stairs:slab_"..mat)
	core.register_alias("stairs:stair_"..mat, "mcl_stairs:stair_"..mat)

	-- corner stairs
	core.register_alias("stairs:stair_"..mat.."_inner", "mcl_stairs:stair_"..mat.."_inner")
	core.register_alias("stairs:stair_"..mat.."_outer", "mcl_stairs:stair_"..mat.."_outer")
end

core.register_alias("stairs:slab_stone", "mcl_stairs:slab_stone")
core.register_alias("stairs:slab_stone_double", "mcl_stairs:slab_stone_double")
