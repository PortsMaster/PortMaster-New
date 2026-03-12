local modname			   = core.get_current_modname()
local mod_registername	  = modname .. ":"
local S					 = core.get_translator(modname)
local C                 = core.colorize
local D 			   = mcl_util.get_dynamic_translator()

for template_name, template_defs in pairs(mcl_armor.trims.overlays) do
	core.register_craftitem(mod_registername .. template_name, {
		description = D(template_defs.readable_name .. " Armor Trim"),
		_tt_help = S("Smithing Template").."\n\n"..
		C(mcl_colors.GRAY, S("Applies to:")) .."\n  "..C(mcl_colors.BLUE, S("Armor")).."\n"..
		C(mcl_colors.GRAY, S("Ingredients:")).."\n  "..C(mcl_colors.BLUE, S("Ingot & Crystals")),
		inventory_image  = template_name .. "_armor_trim_smithing_template.png",
		groups = { smithing_template = 1, rarity = template_defs.rarity or 1 },
	})

	if template_defs.dupe_item then
		core.register_craft({
			output = mod_registername .. template_name .. " 2",
			recipe = {
				{ "mcl_core:diamond", mod_registername .. template_name, "mcl_core:diamond" },
				{ "mcl_core:diamond", template_defs.dupe_item, "mcl_core:diamond" },
				{ "mcl_core:diamond", "mcl_core:diamond", "mcl_core:diamond" },
			}
		})
	end
end
