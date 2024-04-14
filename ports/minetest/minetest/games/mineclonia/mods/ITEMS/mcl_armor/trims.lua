local modname			   = minetest.get_current_modname()
local mod_registername	  = modname .. ":"
local S					 = minetest.get_translator(modname)

local function readable_name(str)
	str = str:gsub("_", " ")
    return (str:gsub("^%l", string.upper))
end

for _, template_name in pairs(mcl_armor.trims.overlays) do
	minetest.register_craftitem(mod_registername .. template_name, {
		description	  = S("Smithing Template"),
		_tt_help = S("@1 Armor Trim",readable_name(template_name)).."\n\n"..
		minetest.colorize(mcl_colors.GRAY, S("Applies to:")).."\n"..minetest.colorize(mcl_colors.BLUE, " "..S("Armor")).."\n"..
		minetest.colorize(mcl_colors.GRAY, S("Ingredients:")).."\n"..minetest.colorize(mcl_colors.BLUE, " "..S("Ingot & Crystals")),
		inventory_image  = template_name .. "_armor_trim_smithing_template.png",
		groups = { smithing_template  = 1 },
	})

	minetest.register_craft({
		output = mod_registername .. template_name .. " 2",
		recipe = {
			{"mcl_core:diamond",mod_registername .. template_name,"mcl_core:diamond"},
			{"mcl_core:diamond","mcl_core:cobble","mcl_core:diamond"},
			{"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
		}
	})
end

minetest.register_craft({
    output = mod_registername .. "silence",
    recipe = {
        {"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
        {"mcl_core:diamond", mod_registername.."ward","mcl_core:diamond"},
        {"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
    }
})
