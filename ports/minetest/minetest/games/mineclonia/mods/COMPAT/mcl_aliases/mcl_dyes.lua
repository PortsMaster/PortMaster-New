-- Legacy (mcl2) "mcl_dye" itemstrings
minetest.register_alias("mcl_dye:grey","mcl_dyes:silver")
minetest.register_alias("mcl_dye:dark_grey","mcl_dyes:grey")
minetest.register_alias("mcl_dye:violet","mcl_dyes:purple")
minetest.register_alias("mcl_dye:lightblue","mcl_dyes:light_blue")
minetest.register_alias("mcl_dye:cyan","mcl_dyes:cyan")
minetest.register_alias("mcl_dye:dark_green","mcl_dyes:green")
minetest.register_alias("mcl_dye:green","mcl_dyes:lime")
minetest.register_alias("mcl_dye:yellow","mcl_dyes:yellow")
minetest.register_alias("mcl_dye:orange","mcl_dyes:orange")
minetest.register_alias("mcl_dye:red","mcl_dyes:red")
minetest.register_alias("mcl_dye:magenta","mcl_dyes:magenta")
minetest.register_alias("mcl_dye:pink","mcl_dyes:pink")

-- these 4 used to double as other items, aliases to the old items
-- are provided so people do not loose their hard earned lapis etc.
minetest.register_alias("mcl_dye:white","mcl_bone_meal:bone_meal")
minetest.register_alias("mcl_dye:black","mcl_mobitems:ink_sac")
minetest.register_alias("mcl_dye:blue","mcl_core:lapis")
minetest.register_alias("mcl_dye:brown","mcl_cocoas:cocoa_beans")

-- Old messy colornames - not following the color naming scheme most of the codebase uses
minetest.register_alias("mcl_dyes:dark_green","mcl_dyes:green")
minetest.register_alias("mcl_dyes:dark_grey","mcl_dyes:grey")
minetest.register_alias("mcl_dyes:violet","mcl_dyes:purple")
minetest.register_alias("mcl_dyes:lightblue","mcl_dyes:light_blue")

function register_alias_if_not_exists(alias, name)
	if not minetest.registered_nodes[alias] then
		minetest.register_alias(alias, name)
	end
end
minetest.register_on_mods_loaded(function()
	for name, cdef in pairs(mcl_dyes.colors) do
		if cdef.mcl2 then
			register_alias_if_not_exists("mcl_stairs:slab_concrete_"..cdef.mcl2, "mcl_stairs:slab_concrete_"..name)
			register_alias_if_not_exists("mcl_stairs:slab_concrete_"..cdef.mcl2.."_double", "mcl_stairs:slab_concrete_"..name.."_double")
			register_alias_if_not_exists("mcl_stairs:stair_concrete_"..cdef.mcl2, "mcl_stairs:stair_concrete_"..name)
			register_alias_if_not_exists("mcl_stairs:stair_concrete_"..cdef.mcl2.."_inner", "mcl_stairs:stair_concrete_"..name.."_inner")
			register_alias_if_not_exists("mcl_stairs:stair_concrete_"..cdef.mcl2.."_outer", "mcl_stairs:stair_concrete_"..name.."_outer")
		end
	end
end)
