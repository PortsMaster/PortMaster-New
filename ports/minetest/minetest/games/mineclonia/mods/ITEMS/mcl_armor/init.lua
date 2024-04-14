local S = minetest.get_translator(minetest.get_current_modname())

mcl_armor = {
	longdesc = S("This is a piece of equippable armor which reduces the amount of damage you receive."),
	usage = S("To equip it, put it on the corresponding armor slot in your inventory menu."),
	elements = {
		head = {
			name = "helmet",
			description = "Helmet", -- provided for backwards compatability
			durability = 0.6857,
			index = 2,
			craft = function(m)
				return {
					{ m,  m,  m},
					{ m, "",  m},
					{"", "", ""},
				}
			end,
		},
		torso = {
			name = "chestplate",
			description = "Chestplate", -- provided for backwards compatability
			durability = 1.0,
			index = 3,
			craft = function(m)
				return {
					{ m, "",  m},
					{ m,  m,  m},
					{ m,  m,  m},
				}
			end,
		},
		legs = {
			name = "leggings",
			description = "Leggings", -- provided for backwards compatability
			durability = 0.9375,
			index = 4,
			craft = function(m)
				return {
					{ m,  m,  m},
					{ m, "",  m},
					{ m, "",  m},
				}
			end,
		},
		feet = {
			name = "boots",
			description = "Boots", -- provided for backwards compatability
			durability = 0.8125,
			index = 5,
			craft = function(m)
				return {
					{ m, "",  m},
					{ m, "",  m},
				}
			end,
		}
	},
	player_view_range_factors = {},
}

mcl_armor.trims = {
	core_textures	= {},
	blacklisted		= {["mcl_armor:elytra"]=true, ["mcl_armor:elytra_enchanted"]=true},
	overlays        = {"sentry","dune","coast","wild","tide","ward","vex","rib","snout","eye","spire","silence","wayfinder"},
	colors			= {["amethyst"]="#8246a5",["gold"]="#ce9627",["emerald"]="#1b9958",["copper"]="#c36447",["diamond"]="#5faed8",["iron"]="#938e88",["lapis"]="#1c306b",["netherite"]="#302a26",["quartz"]="#c9bcb9",["redstone"]="#af2c23"},
}

local modpath = minetest.get_modpath("mcl_armor")

dofile(modpath .. "/api.lua")
dofile(modpath .. "/player.lua")
dofile(modpath .. "/damage.lua")
dofile(modpath .. "/register.lua")
dofile(modpath .. "/leather.lua")
dofile(modpath .. "/trims.lua")
