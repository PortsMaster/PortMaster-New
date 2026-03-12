local S = core.get_translator(core.get_current_modname())

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
	overlays        = {
		["sentry"] 	  = {
			readable_name = "Sentry", dupe_item = "mcl_core:cobble"
		},
		["dune"] 	  = {
			readable_name = "Dune", dupe_item = "mcl_core:sandstone"
		},
		["coast"] 	  = {
			readable_name = "Coast", dupe_item = "mcl_core:cobble"
		},
		["wild"] 	  = {
			readable_name = "Wild", dupe_item = "mcl_core:mossycobble"
		},
		["tide"] 	  = {
			readable_name = "Tide", dupe_item = "mcl_ocean:prismarine"
		},
		["ward"] 	  = {
			readable_name = "Ward", dupe_item = "mcl_deepslate:deepslate_cobbled", rarity = 2
		},
		["vex"] 	  = {
			readable_name = "Vex", dupe_item = "mcl_core:cobble", rarity = 2
		},
		["rib"] 	  = {
			readable_name = "Rib", dupe_item = "mcl_nether:netherrack"
		},
		["snout"] 	  = {
			readable_name = "Snout", dupe_item = "mcl_blackstone:blackstone"
		},
		["eye"] 	  = {
			readable_name = "Eye", dupe_item = "mcl_end:end_stone", rarity = 2
		},
		["spire"] 	  = {
			readable_name = "Spire", dupe_item = "mcl_end:purpur_block", rarity = 2
		},
		["silence"]   = {
			readable_name = "Silence", dupe_item = "mcl_deepslate:deepslate_cobbled", rarity = 3
		},
		["wayfinder"] = {
			readable_name = "Wayfinder", dupe_item = "mcl_colorblocks:hardened_clay"
		},
		-- ["raiser"] = {
		-- 	readable_name = "Raiser", dupe_item = "mcl_colorblocks:hardened_clay"
		-- },
		-- ["shaper"] = {
		-- 	readable_name = "Shaper", dupe_item = "mcl_colorblocks:hardened_clay"
		-- },
		-- ["host"] = {
		-- 	readable_name = "Host", dupe_item = "mcl_colorblocks:hardened_clay"
		-- },
		["bolt"]      = {
			readable_name = "Bolt", dupe_item = "mcl_copper:block"
		},
		["flow"]      = {
			readable_name = "Flow", dupe_item = "mcl_mobitems:breeze_rod"
		}
	}
}

-- Hold the players attached head entity
-- example: mcl_armor.head_entity[player:get_player_name()] = entity
mcl_armor.head_entity = {}

local modpath = core.get_modpath(core.get_current_modname())

dofile(modpath .. "/api.lua")
dofile(modpath .. "/player.lua")
dofile(modpath .. "/damage.lua")
dofile(modpath .. "/register.lua")
dofile(modpath .. "/leather.lua")
dofile(modpath .. "/trims.lua")
