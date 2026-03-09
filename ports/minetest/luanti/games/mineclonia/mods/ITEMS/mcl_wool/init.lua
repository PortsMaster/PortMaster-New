local S = core.get_translator(core.get_current_modname())
local D = mcl_util.get_dynamic_translator()

-- Backwards compatibility with jordach's 16-color wool mod
core.register_alias("mcl_wool:dark_blue", "wool:blue")
core.register_alias("mcl_wool:gold", "wool:yellow")

local messy_textures = { --translator table for the bed texture filenames names not adhering to the common color names of mcl_dyes
	["light_blue"] = "mcl_wool_light_blue",
	["grey"] = "wool_dark_grey",
	["silver"] = "wool_grey",
	["green"] = "wool_dark_green",
	["lime"] = "mcl_wool_lime",
	["purple"] = "wool_violet",
}

local canonical_color = "white"

for color,colordef in pairs(mcl_dyes.colors) do
	local create_entry = false
	local longdesc_carpet, longdesc_wool, name_carpet, name_wool

	local is_canonical = color == canonical_color
	if is_canonical then
		name_carpet = S("Carpet")
		name_wool = S("Wool")
		longdesc_wool = S("Wool is a decorative block which comes in many different colors.")
		longdesc_carpet = S("Carpets are thin floor covers which come in many different colors.")
		create_entry = true
	end
	local texcolor = "wool_"..color
	if messy_textures[color] then
		texcolor = messy_textures[color]
	end

	core.register_node("mcl_wool:"..color, {
		description = D(colordef.readable_name .. " Wool"),
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = name_wool,
		_doc_items_longdesc = longdesc_wool,
		is_ground_content = false,
		tiles = {texcolor..".png"},
		groups = {handy=1,shearsy_wool=1, flammable=1,fire_encouragement=30, fire_flammability=60, wool=1,building_block=1,["unicolor_"..color]=1},
		sounds = mcl_sounds.node_sound_wool_defaults(),
		_color = color,
		_mcl_hardness = 0.8,
		_mcl_burntime = 5,
		_mcl_crafting_output = {line_wide2 = {output = "mcl_wool:"..color.."_carpet 3"}}
	})

	core.register_node("mcl_wool:"..color.."_carpet", {
		description = D(colordef.readable_name .. " Carpet"),
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = name_carpet,
		_doc_items_longdesc = longdesc_carpet,
		is_ground_content = false,
		tiles = {texcolor..".png"},
		wield_image = texcolor..".png",
		wield_scale = { x=1, y=1, z=0.5 },
		groups = {handy=1, carpet=1,supported_node=1,flammable=1,fire_encouragement=60, fire_flammability=20, dig_by_water=1,deco_block=1,["unicolor_"..color]=1},
		sounds = mcl_sounds.node_sound_wool_defaults(),
		paramtype = "light",
		sunlight_propagates = true,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
			},
		},
		_color = color,
		_mcl_hardness = 0.1,
		_mcl_burntime = 3.35
	})

	if not is_canonical then
		doc.add_entry_alias("nodes", "mcl_wool:"..canonical_color, "nodes", "mcl_wool:"..color)
		doc.add_entry_alias("nodes", "mcl_wool:"..canonical_color.."_carpet", "nodes", "mcl_wool:"..color.."_carpet")
	end

	core.register_craft({
		type = "shapeless",
		output = "mcl_wool:"..color,
		recipe = { "group:wool", "mcl_dyes:"..color }
	})
end
