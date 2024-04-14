mcl_dyes = {}

local S = minetest.get_translator(minetest.get_current_modname())

-- Common color table to be used by other mods. The "mcl2" field if present
-- represents the name of the color in mcl2 if it is different. This is used
-- in the mcl_dye compat mod to adabt the recipes.
mcl_dyes.colors = {
	["white"] = {
		readable_name = S("White"),
		groups = {basecolor_white=1,   excolor_white=1,     unicolor_white=1},
		rgb = "#d0d6d7",
		unicolor = "white",
	},
	["silver"] = {
		readable_name = S("Light Grey"),
		groups = {basecolor_grey=1,    excolor_grey=1,      unicolor_grey=1},
		rgb = "#818177",
		unicolor = "grey",
		mcl2 = "grey",
	},
	["grey"] = {
		readable_name = S("Grey"),
		groups = {basecolor_grey=1,    excolor_darkgrey=1,  unicolor_darkgrey=1},
		rgb = "#383c40",
		unicolor = "darkgrey",
		mcl2 = "dark_grey",
	},
	["black"] = {
		readable_name = S("Black"),
		groups = {basecolor_black=1,   excolor_black=1,     unicolor_black=1},
		rgb = "#080a10",
		unicolor = "black",
	},
	["purple"] = {
		readable_name = S("Purple"),
		groups = {basecolor_magenta=1, excolor_violet=1,    unicolor_violet=1},
		rgb = "#6821a0",
		unicolor = "violet",
		mcl2 = "violet",
	},
	["blue"] = {
		readable_name = S("Blue"),
		groups = {basecolor_blue=1,    excolor_blue=1,      unicolor_blue=1},
		rgb = "#2e3094",
		unicolor = "blue",
	},
	["light_blue"] = {
		readable_name = S("Light Blue"),
		groups = {basecolor_blue=1,    excolor_blue=1,      unicolor_light_blue=1},
		rgb = "#258ec9",
		unicolor = "light_blue",
		mcl2 = "lightblue",
	},
	["cyan"] = {
		readable_name = S("Cyan"),
		groups = {basecolor_cyan=1,    excolor_cyan=1,      unicolor_cyan=1},
		rgb = "#167b8c",
		unicolor = "cyan",
	},
	["green"] = {
		readable_name = S("Green"),
		groups = {basecolor_green=1,   excolor_green=1,     unicolor_dark_green=1},
		rgb = "#4b5e25",
		unicolor = "dark_green",
		mcl2 = "dark_green",
	},
	["lime"] = {
		readable_name = S("Lime"),
		groups = {basecolor_green=1,   excolor_green=1,     unicolor_green=1},
		rgb = "#60ac19",
		unicolor = "green",
		mcl2 = "green",
	},
	["yellow"] = {
		readable_name = S("Yellow"),
		groups = {basecolor_yellow=1,  excolor_yellow=1,    unicolor_yellow=1},
		rgb = "#f1b216",
		unicolor = "yellow",
	},
	["brown"] = {
		readable_name = S("Brown"),
		groups = {basecolor_brown=1,   excolor_orange=1,    unicolor_dark_orange=1},
		rgb = "#633d20",
		unicolor = "dark_orange",
	},
	["orange"] = {
		readable_name = S("Orange"),
		groups = {basecolor_orange=1,  excolor_orange=1,    unicolor_orange=1},
		rgb = "#e26501",
		unicolor = "orange",
	},
	["red"] = {
		readable_name = S("Red"),
		groups = {basecolor_red=1,     excolor_red=1,       unicolor_red=1},
		rgb = "#912222",
		unicolor = "red",
	},
	["magenta"] = {
		readable_name = S("Magenta"),
		groups = {basecolor_magenta=1, excolor_red_violet=1,unicolor_red_violet=1},
		rgb = "#ab31a2",
		unicolor = "red_violet",
	},
	["pink"] = {
		readable_name = S("Pink"),
		groups = {basecolor_red=1,     excolor_red=1,       unicolor_light_red=1},
		rgb = "#d56791",
		unicolor = "light_red",
	},
}

-- Takes an unicolor group name (e.g. “unicolor_white”) and returns a
-- corresponding dye name (if it exists), nil otherwise.
function mcl_dyes.unicolor_to_dye(unicolor_group)
	for k,v in pairs(mcl_dyes.colors) do
		if v.groups["unicolor_"..unicolor_group] == 1 then return k end
	end
end

for k,v in pairs(mcl_dyes.colors) do
	minetest.register_craftitem("mcl_dyes:" .. k, {
		inventory_image = "mcl_dye_white.png^(mcl_dye_mask.png^[colorize:"..v.rgb..")",
		description = S("@1 Dye", v.readable_name),
		_doc_items_longdesc = S("This item is a dye which is used for dyeing and crafting."),
		_doc_items_usagehelp = S("Rightclick on a sheep to dye its wool. Other things are dyed by crafting."),
		groups = table.update({craftitem = 1, dye = 1}, v.groups),
		_color = k,
		on_place = function(itemstack,placer,pointed_thing)
			local def = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
			if def and def._on_dye_place then
				local ret = def._on_dye_place(pointed_thing.under,k)
				if not minetest.is_creative_enabled(placer and placer:get_player_name() or "") then
					if ret ~= true then itemstack:take_item() end
				end
			end
			return itemstack
		end,
	})
end

minetest.register_craft({
	output = "mcl_dyes:white",
	recipe = {{"mcl_flowers:lily_of_the_valley"}},
})

minetest.register_craft({
	output = "mcl_dyes:white 3",
	recipe = {{"mcl_bone_meal:bone_meal"}},
})

minetest.register_craft({
	output = "mcl_dyes:black",
	recipe = {{"mcl_mobitems:ink_sac"}},
})

minetest.register_craft({
	output = "mcl_dyes:yellow",
	recipe = {{"mcl_flowers:dandelion"}},
})

minetest.register_craft({
	output = "mcl_dyes:yellow 2",
	recipe = {{"mcl_flowers:sunflower"}},
})

minetest.register_craft({
	output = "mcl_dyes:blue",
	recipe = {{"mcl_core:lapis"}},
})

minetest.register_craft({
	output = "mcl_dyes:blue",
	recipe = {{"mcl_flowers:cornflower"}},
})

minetest.register_craft({
	output = "mcl_dyes:light_blue",
	recipe = {{"mcl_flowers:blue_orchid"}},
})

minetest.register_craft({
	output = "mcl_dyes:silver",
	recipe = {{"mcl_flowers:azure_bluet"}},
})

minetest.register_craft({
	output = "mcl_dyes:silver",
	recipe = {{"mcl_flowers:oxeye_daisy"}},
})

minetest.register_craft({
	output = "mcl_dyes:silver",
	recipe = {{"mcl_flowers:tulip_white"}},
})

minetest.register_craft({
	output = "mcl_dyes:magenta",
	recipe = {{"mcl_flowers:allium"}},
})

minetest.register_craft({
	output = "mcl_dyes:magenta 2",
	recipe = {{"mcl_flowers:lilac"}},
})

minetest.register_craft({
	output = "mcl_dyes:orange",
	recipe = {{"mcl_flowers:tulip_orange"}},
})

minetest.register_craft({
	output = "mcl_dyes:brown",
	recipe = {{"mcl_cocoas:cocoa_beans"}},
})

minetest.register_craft({
	output = "mcl_dyes:pink",
	recipe = {{"mcl_flowers:tulip_pink"}},
})

minetest.register_craft({
	output = "mcl_dyes:pink 2",
	recipe = {{"mcl_flowers:peony"}},
})

minetest.register_craft({
	output = "mcl_dyes:red",
	recipe = {{"mcl_farming:beetroot_item"}},
})

minetest.register_craft({
	output = "mcl_dyes:red",
	recipe = {{"mcl_flowers:poppy"}},
})

minetest.register_craft({
	output = "mcl_dyes:red",
	recipe = {{"mcl_flowers:tulip_red"}},
})

minetest.register_craft({
	output = "mcl_dyes:red 2",
	recipe = {{"mcl_flowers:rose_bush"}},
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_dyes:green",
	recipe = "mcl_core:cactus",
	cooktime = 10,
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:grey 2",
	recipe = {"mcl_dyes:black", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:light_blue 2",
	recipe = {"mcl_dyes:blue", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:silver 3",
	recipe = {"mcl_dyes:black", "mcl_dyes:white", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:silver 2",
	recipe = {"mcl_dyes:grey", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:lime 2",
	recipe = {"mcl_dyes:green", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:magenta 4",
	recipe = {"mcl_dyes:blue", "mcl_dyes:white", "mcl_dyes:red", "mcl_dyes:red"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:magenta 3",
	recipe = {"mcl_dyes:pink", "mcl_dyes:red", "mcl_dyes:blue"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:magenta 2",
	recipe = {"mcl_dyes:purple", "mcl_dyes:pink"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:pink 2",
	recipe = {"mcl_dyes:red", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:cyan 2",
	recipe = {"mcl_dyes:blue", "mcl_dyes:green"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:purple 2",
	recipe = {"mcl_dyes:blue", "mcl_dyes:red"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:orange 2",
	recipe = {"mcl_dyes:yellow", "mcl_dyes:red"},
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_dyes:green",
	recipe = "mcl_core:cactus",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_dyes:lime",
	recipe = "group:sea_pickle",
	cooktime = 10,
})
