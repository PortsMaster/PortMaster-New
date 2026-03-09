-- Glass nodes
local S = core.get_translator(core.get_current_modname())
local D = mcl_util.get_dynamic_translator()

core.register_node("mcl_core:glass", {
	description = S("Glass"),
	_doc_items_longdesc = S("A decorative and mostly transparent block."),
	drawtype = "glasslike_framed_optional",
	is_ground_content = false,
	tiles = {"default_glass.png", "default_glass_detail.png"},
	paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
	sunlight_propagates = true,
	groups = {handy=1, glass=1, building_block=1, material_glass=1},
	sounds = mcl_sounds.node_sound_glass_defaults(),
	drop = "",
	_mcl_hardness = 0.3,
	_mcl_silk_touch_drop = true,
})

local messy_textures = {
	["grey"] = "gray",
}

------------------------
-- Create Color Glass --
------------------------
local canonical_color = "yellow"

for color,colordef in pairs(mcl_dyes.colors) do
	local longdesc, create_entry, entry_name
	if color == canonical_color then
		longdesc = S("Stained glass is a decorative and mostly transparent block which comes in various different colors.")
		entry_name = S("Stained Glass")
	else
		create_entry = false
	end
	local texcol = color
	if messy_textures[color] then
		texcol = messy_textures[color]
	end
	core.register_node("mcl_core:glass_"..color, {
		description = D(colordef.readable_name .. " Stained Glass"),
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = entry_name,
		_doc_items_longdesc = longdesc,
		drawtype = "glasslike_framed_optional",
		is_ground_content = false,
		tiles = {"mcl_core_glass_"..texcol..".png", "mcl_core_glass_"..texcol.."_detail.png"},
		paramtype = "light",
		paramtype2 = "glasslikeliquidlevel",
		sunlight_propagates = true,
		use_texture_alpha = "blend",
		groups = {handy=1, glass=1, building_block=1, material_glass=1, ["basecolor_"..color] = 1},
		sounds = mcl_sounds.node_sound_glass_defaults(),
		drop = "",
		_mcl_hardness = 0.3,
		_mcl_silk_touch_drop = true,
		_color = color,
	})

	core.register_craft({
		output = "mcl_core:glass_"..color.." 8",
		recipe = {
			{"mcl_core:glass","mcl_core:glass","mcl_core:glass"},
			{"mcl_core:glass","mcl_dyes:"..color,"mcl_core:glass"},
			{"mcl_core:glass","mcl_core:glass","mcl_core:glass"},
		}
	})

	if color ~= canonical_color then
		doc.add_entry_alias("nodes", "mcl_core:glass_"..canonical_color, "nodes", "mcl_core:glass_"..color)
	end
end

-- legacy: for some reason glass was the only place where grey was spelled with an a
core.register_alias("mcl_core:glass_gray","mcl_core:glass_grey")
