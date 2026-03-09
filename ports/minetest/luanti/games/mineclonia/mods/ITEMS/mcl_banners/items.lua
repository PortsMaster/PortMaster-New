local modname = core.get_current_modname()
local S = core.get_translator(modname)
local D = mcl_util.get_dynamic_translator(modname)
local C = core.colorize

local function readable_name(str)
	str = str:gsub("_", " ")
    return (str:gsub("^%l", string.upper))
end

local special_patterns = {
	["thing"] 		 = { craft_item="mcl_core:apple_gold_enchanted", rarity=2 },
	["skull"] 		 = { craft_item="mcl_heads:wither_skeleton", rarity=2 },
	["creeper"] 	 = { craft_item="mcl_heads:creeper", rarity=1 },
	["flower"] 		 = { craft_item="mcl_flowers:oxeye_daisy" },
	["bricks"] 		 = { craft_item="mcl_core:brick_block" },
	["curly_border"] = { craft_item="mcl_core:vine" },
	["globe"] 		 = {},
	["piglin"] 		 = { rarity=1 },
	["guster"] 		 = { rarity=2 },
	["flow"] 		 = { rarity=2 }
}

for pattern, defs in pairs(special_patterns) do
	core.register_craftitem("mcl_banners:pattern_"..pattern,{
		description = D(readable_name(pattern).." Banner Pattern"),
		_tt_help = C(mcl_colors.GRAY, S("Can be used to craft special banner designs on the loom")),
		_doc_items_longdesc = S("Special Banner Pattern"),
		inventory_image = "mcl_banners_pattern_"..pattern..".png",
		wield_image = "mcl_banners_pattern_"..pattern..".png",
		groups = { banner_pattern = 1, rarity = defs.rarity or 0 },
		_pattern = pattern,
	})

	if defs.craft_item and type(defs.craft_item) == "string" then
		core.register_craft({
			output = "mcl_banners:pattern_"..pattern,
			recipe = { "mcl_core:paper", defs.craft_item },
			type = "shapeless"
		})
	end
end
