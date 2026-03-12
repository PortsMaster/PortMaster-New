local S = core.get_translator(core.get_current_modname())
local D = mcl_util.get_dynamic_translator()

local messy_textures = { --translator table for the bed texture filenames names not adhering to the common color names of mcl_dyes
	["lightblue"] = "light_blue",
}

local canonical_color = "red"

for color, colordef in pairs(mcl_dyes.colors) do
	local is_canonical =

	core.register_craft({
		type = "shapeless",
		output = "mcl_beds:bed_"..color.."_bottom",
		recipe = { "group:bed", "mcl_dyes:"..color }
	})

	local entry_name, create_entry
	if is_canonical then
		entry_name = S("Bed")
	else
		create_entry = false
	end
	local texcol = color
	if messy_textures[color] then
		texcol = messy_textures[color]
	end
	-- Register bed
	mcl_beds.register_bed("mcl_beds:bed_"..color, {
		description = D(colordef.readable_name .. " Bed"),
		_doc_items_entry_name = entry_name,
		_doc_items_create_entry = create_entry,
		inventory_image = "mcl_beds_bed_"..texcol.."_inv.png",
		wield_image = "mcl_beds_bed_"..texcol.."_inv.png",

		tiles = {
			"mcl_beds_bed_"..texcol..".png"
		},
		recipe = {
			{"mcl_wool:"..color, "mcl_wool:"..color, "mcl_wool:"..color},
			{"group:wood", "group:wood", "group:wood"}
		},
	})

	if not is_canonical then
		doc.add_entry_alias("nodes", "mcl_beds:bed_"..canonical_color.."_bottom", "nodes", "mcl_beds:bed_"..color.."_bottom")
		doc.add_entry_alias("nodes", "mcl_beds:bed_"..canonical_color.."_bottom", "nodes", "mcl_beds:bed_"..color.."_top")
	end

	-- Alias old non-uniform node names
	if messy_textures[color] then
		core.register_alias("mcl_beds:bed_"..texcol.."_top","mcl_beds:bed_"..color.."_top")
		core.register_alias("mcl_beds:bed_"..texcol.."_bottom","mcl_beds:bed_"..color.."_bottom")
	end
end

core.register_alias("beds:bed_bottom", "mcl_beds:bed_red_bottom")
core.register_alias("beds:bed_top", "mcl_beds:bed_red_top")
