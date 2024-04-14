--[------[ TRADING ]------]

-- LIST OF VILLAGER PROFESSIONS AND TRADES

-- TECHNICAL RESTRICTIONS (FIXME):
-- * You can't use a clock as requested item
-- * You can't use a compass as requested item if its stack size > 1
-- * You can't use a compass in the second requested slot
-- This is a problem in the mcl_compass and mcl_clock mods,
-- these items should be implemented as single items, then everything
-- will be much easier.


local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local E1 = { "mcl_core:emerald", 1, 1 } -- one emerald

return {
	unemployed = {
		name = S("Unemployed"),
		textures = {
				"mobs_mc_villager.png",
				"mobs_mc_villager.png",
			},
		trades = nil,
	},
	farmer = {
		name = S("Farmer"),
		texture = "mobs_mc_villager_farmer.png",
		jobsite = "mcl_composters:composter",
		trades = {
			{
			{ { "mcl_farming:wheat_item", 20, 20, }, E1 },
			{ { "mcl_farming:potato_item", 26, 26, }, E1 },
			{ { "mcl_farming:carrot_item", 22, 22, }, E1 },
			{ { "mcl_farming:beetroot_item", 15, 15 }, E1 },
			{ E1, { "mcl_farming:bread", 6, 6 } },
			},

			{
			{ { "mcl_farming:pumpkin", 6, 6 }, E1 },
			{ E1, { "mcl_farming:pumpkin_pie", 4, 4 } },
			{ E1, { "mcl_core:apple", 4, 4 } },
			},

			{
			{ { "mcl_farming:melon", 4, 4 }, E1 },
			{ { "mcl_core:emerald", 3, 3 }, {"mcl_farming:cookie", 18, 18 }, },
			},

			{
			{ E1, { "mcl_cake:cake", 1, 1 } },
			{ E1, { "mcl_sus_stew:stew", 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_farming:carrot_item_gold", 3, 3 } },
			{ { "mcl_core:emerald", 4, 4 }, { "mcl_potions:speckled_melon", 3, 3 } },
			},
		}
	},
	fisherman = {
		name = S("Fisherman"),
		texture = "mobs_mc_villager_fisherman.png",
		jobsite = "mcl_barrels:barrel_closed",
		trades = {
			{
			{ { "mcl_mobitems:string", 20, 20 }, E1 },
			{ { "mcl_core:coal_lump", 10, 10 }, E1 },
			{ { "mcl_core:emerald", 1, 1, "mcl_fishing:fish_raw", 6, 6 }, { "mcl_fishing:fish_cooked", 6, 6 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_buckets:bucket_cod", 1, 1 } },
			},

			{
			{ { "mcl_fishing:fish_raw", 15, 15 }, E1 },
			{ { "mcl_core:emerald", 1, 1, "mcl_fishing:salmon_raw", 6, 6 }, { "mcl_fishing:salmon_cooked", 6, 6 } },
			{ { "mcl_core:emerald", 2, 2 }, {"mcl_campfires:campfire_lit", 1, 1 } },
			},

			{
			{ { "mcl_fishing:salmon_raw", 13, 13 }, E1 },
			{ { "mcl_core:emerald", 8, 22 }, { "mcl_fishing:fishing_rod_enchanted", 1, 1 } },
			},

			{
			{ { "mcl_fishing:clownfish_raw", 6, 6 }, E1 },
			},

			{
			{ { "mcl_fishing:pufferfish_raw", 4, 4 }, E1 },

			--Boat cherry?
			{ { "mcl_boats:boat", 1, 1 }, E1 },
			{ { "mcl_boats:boat_acacia", 1, 1 }, E1 },
			{ { "mcl_boats:boat_spruce", 1, 1 }, E1 },
			{ { "mcl_boats:boat_dark_oak", 1, 1 }, E1 },
			{ { "mcl_boats:boat_birch", 1, 1 }, E1 },
			},
		},
	},
	fletcher = {
		name = S("Fletcher"),
		texture = "mobs_mc_villager_fletcher.png",
		jobsite = "mcl_fletching_table:fletching_table",
		trades = {
			{
			{ { "mcl_core:stick", 32, 32 }, E1 },
			{ E1, { "mcl_bows:arrow", 16, 16 } },
			{ { "mcl_core:emerald", 1, 1, "mcl_core:gravel", 10, 10 }, { "mcl_core:flint", 10, 10 } },
			},

			{
			{ { "mcl_core:flint", 26, 26 }, E1 },
			{ { "mcl_core:emerald", 2, 2 }, { "mcl_bows:bow", 1, 1 } },
			},

			{
			{ { "mcl_mobitems:string", 14, 14 }, E1 },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_bows:crossbow", 1, 1 } },
			},

			{
			{ { "mcl_mobitems:feather", 24, 24 }, E1 },
			{ { "mcl_core:emerald", 7, 21 } , { "mcl_bows:bow_enchanted", 1, 1 } },
			},

			{
			--FIXME: supposed to be tripwire hook{ { "tripwirehook", 8, 8 }, E1 },
			{ { "mcl_core:emerald", 8, 22 } , { "mcl_bows:crossbow_enchanted", 1, 1 } },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:healing_arrow", 5, 5 } },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:harming_arrow", 5, 5 } },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:night_vision_arrow", 5, 5 } },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:swiftness_arrow", 5, 5 } },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:slowness_arrow", 5, 5 } },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:leaping_arrow", 5, 5 } },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:poison_arrow", 5, 5 } },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:regeneration_arrow", 5, 5 } },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:invisibility_arrow", 5, 5 } },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:water_breathing_arrow", 5, 5 } },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:fire_resistance_arrow", 5, 5 } },
			},
		}
	},
	shepherd ={
		name = S("Shepherd"),
		texture =  "mobs_mc_villager_sheperd.png",
		jobsite = "mcl_loom:loom",
		trades = {
			{
			{ { "mcl_wool:white", 18, 18 }, E1 },
			{ { "mcl_wool:brown", 18, 18 }, E1 },
			{ { "mcl_wool:black", 18, 18 }, E1 },
			{ { "mcl_wool:grey", 18, 18 }, E1 },
			{ { "mcl_core:emerald", 2, 2 }, { "mcl_tools:shears", 1, 1 } },
			},

			{
			{ { "mcl_dyes:black", 12, 12 }, E1 },
			{ { "mcl_dyes:dark_grey", 12, 12 }, E1 },
			{ { "mcl_dyes:green", 12, 12 }, E1 },
			{ { "mcl_dyes:lightblue", 12, 12 }, E1 },
			{ { "mcl_dyes:white", 12, 12 }, E1 },

			{ E1, { "mcl_wool:white", 1, 1 } },
			{ E1, { "mcl_wool:grey", 1, 1 } },
			{ E1, { "mcl_wool:silver", 1, 1 } },
			{ E1, { "mcl_wool:black", 1, 1 } },
			{ E1, { "mcl_wool:yellow", 1, 1 } },
			{ E1, { "mcl_wool:orange", 1, 1 } },
			{ E1, { "mcl_wool:red", 1, 1 } },
			{ E1, { "mcl_wool:magenta", 1, 1 } },
			{ E1, { "mcl_wool:purple", 1, 1 } },
			{ E1, { "mcl_wool:blue", 1, 1 } },
			{ E1, { "mcl_wool:cyan", 1, 1 } },
			{ E1, { "mcl_wool:lime", 1, 1 } },
			{ E1, { "mcl_wool:green", 1, 1 } },
			{ E1, { "mcl_wool:pink", 1, 1 } },
			{ E1, { "mcl_wool:light_blue", 1, 1 } },
			{ E1, { "mcl_wool:brown", 1, 1 } },

			{ E1, { "mcl_wool:white_carpet", 4, 4 } },
			{ E1, { "mcl_wool:grey_carpet", 4, 4 } },
			{ E1, { "mcl_wool:silver_carpet", 4, 4 } },
			{ E1, { "mcl_wool:black_carpet", 4, 4 } },
			{ E1, { "mcl_wool:yellow_carpet", 4, 4 } },
			{ E1, { "mcl_wool:orange_carpet", 4, 4 } },
			{ E1, { "mcl_wool:red_carpet", 4, 4 } },
			{ E1, { "mcl_wool:magenta_carpet", 4, 4 } },
			{ E1, { "mcl_wool:purple_carpet", 4, 4 } },
			{ E1, { "mcl_wool:blue_carpet", 4, 4 } },
			{ E1, { "mcl_wool:cyan_carpet", 4, 4 } },
			{ E1, { "mcl_wool:lime_carpet", 4, 4 } },
			{ E1, { "mcl_wool:green_carpet", 4, 4 } },
			{ E1, { "mcl_wool:pink_carpet", 4, 4 } },
			{ E1, { "mcl_wool:light_blue_carpet", 4, 4 } },
			{ E1, { "mcl_wool:brown_carpet", 4, 4 } },
			},

			{
			{ { "mcl_dyes:red", 12, 12 }, E1 },
			{ { "mcl_dyes:grey", 12, 12 }, E1 },
			{ { "mcl_dyes:pink", 12, 12 }, E1 },
			{ { "mcl_dyes:yellow", 12, 12 }, E1 },
			{ { "mcl_dyes:orange", 12, 12 }, E1 },

			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_red_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_blue_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_cyan_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_grey_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_silver_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_black_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_yellow_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_green_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_magenta_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_orange_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_purple_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_brown_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_pink_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_lime_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_light_blue_bottom", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_beds:bed_white_bottom", 1, 1 } },
			},

			{
			{ { "mcl_dyes:dark_green", 12, 12 }, E1 },
			{ { "mcl_dyes:brown", 12, 12 }, E1 },
			{ { "mcl_dyes:blue", 12, 12 }, E1 },
			{ { "mcl_dyes:violet", 12, 12 }, E1 },
			{ { "mcl_dyes:cyan", 12, 12 }, E1 },
			{ { "mcl_dyes:magenta", 12, 12 }, E1 },

			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_white", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_grey", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_silver", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_black", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_red", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_yellow", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_green", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_cyan", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_blue", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_magenta", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_orange", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_purple", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_brown", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_pink", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_lime", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_light_blue", 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 2, 2 }, { "mcl_paintings:painting", 3, 3 } },
			},
		},
	},
	librarian = {
		name = S("Librarian"),
		texture = "mobs_mc_villager_librarian.png",
		jobsite = "mcl_lectern:lectern",
		trades = {
			{
			{ { "mcl_core:paper", 24, 24 }, E1 },
			{ { "mcl_core:emerald", 5, 64, "mcl_books:book", 1, 1 }, { "mcl_enchanting:book_enchanted", 1 ,1 } },
			{ { "mcl_core:emerald", 9, 9 }, { "mcl_books:bookshelf", 1 ,1 } },
			},

			{
			{ { "mcl_books:book", 4, 4 }, E1 },
			{ { "mcl_core:emerald", 5, 64, "mcl_books:book", 1, 1 }, { "mcl_enchanting:book_enchanted", 1 ,1 } },
			{ E1, { "mcl_lanterns:lantern_floor", 1, 1 } },
			},

			{
			{ { "mcl_mobitems:ink_sac", 5, 5 }, E1 },
			{ { "mcl_core:emerald", 5, 64, "mcl_books:book", 1, 1 }, { "mcl_enchanting:book_enchanted", 1 ,1 } },
			{ E1, { "mcl_core:glass", 4, 4 } },
			},

			{
			{ { "mcl_books:writable_book", 1, 1 }, E1 },
			{ { "mcl_core:emerald", 5, 64, "mcl_books:book", 1, 1 }, { "mcl_enchanting:book_enchanted", 1 ,1 } },
			{ { "mcl_core:emerald", 5, 5 }, { "mcl_clock:clock", 1, 1 } },
			{ { "mcl_core:emerald", 4, 4 }, { "mcl_compass:compass", 1 ,1 } },
			},

			{
			{ { "mcl_core:emerald", 20, 20 }, { "mcl_mobs:nametag", 1, 1 } },
			}
		},
	},
	cartographer = {
		name = S("Cartographer"),
		texture = "mobs_mc_villager_cartographer.png",
		jobsite = "mcl_cartography_table:cartography_table",
		trades = {
			{
			{ { "mcl_core:paper", 24, 24 }, E1 },
			{ { "mcl_core:emerald", 7, 7 }, { "mcl_maps:empty_map", 1, 1 } },
			},

			{
			{ { "mcl_panes:pane_natural_flat", 11, 11 }, E1 },
			--{ { "mcl_core:emerald", 13, 13, "mcl_compass:compass", 1, 1 }, { "FIXME:ocean explorer map" 1, 1 } },
			},

			{
			{ { "mcl_compass:compass", 1, 1 }, E1 },
			--{ { "mcl_core:emerald", 14, 14, "mcl_compass:compass", 1, 1 }, { "FIXME:woodland explorer map" 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 7, 7 }, { "mcl_itemframes:item_frame", 1, 1 } },

			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_white", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_grey", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_silver", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_black", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_red", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_yellow", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_green", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_cyan", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_blue", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_magenta", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_orange", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_purple", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_brown", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_pink", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_lime", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_banners:banner_item_light_blue", 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 8, 8 }, { "mcl_banners:pattern_globe", 1, 1 } },
			},
		},
	},
	armorer = {
		name = S("Armorer"),
		texture = "mobs_mc_villager_armorer.png",
		jobsite = "mcl_blast_furnace:blast_furnace",
		trades = {
			{
			{ { "mcl_core:coal_lump", 15, 15 }, E1 },
			{ { "mcl_core:emerald", 5, 5 }, { "mcl_armor:helmet_iron", 1, 1 } },
			{ { "mcl_core:emerald", 9, 9 }, { "mcl_armor:chestplate_iron", 1, 1 } },
			{ { "mcl_core:emerald", 7, 7 }, { "mcl_armor:leggings_iron", 1, 1 } },
			{ { "mcl_core:emerald", 4, 4 }, { "mcl_armor:boots_iron", 1, 1 } },
			},

			{
			{ { "mcl_core:iron_ingot", 4, 4 }, E1 },
			{ { "mcl_core:emerald", 36, 36 }, { "mcl_bells:bell", 1, 1 } },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_armor:leggings_chain", 1, 1 } },
			{ { "mcl_core:emerald", 1, 1 }, { "mcl_armor:boots_chain", 1, 1 } },
			},

			{
			{ { "mcl_buckets:bucket_lava", 1, 1 }, E1 },
			{ { "mcl_core:diamond", 1, 1 }, E1 },
			{ { "mcl_core:emerald", 1, 1 }, { "mcl_armor:helmet_chain", 1, 1 } },
			{ { "mcl_core:emerald", 4, 4 }, { "mcl_armor:chestplate_chain", 1, 1 } },
			{ { "mcl_core:emerald", 5, 5 }, { "mcl_shields:shield", 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 19, 33 }, { "mcl_armor:leggings_diamond_enchanted", 1, 1 } },
			{ { "mcl_core:emerald", 13, 27 }, { "mcl_armor:boots_diamond_enchanted", 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 13, 27 }, { "mcl_armor:helmet_diamond_enchanted", 1, 1 } },
			{ { "mcl_core:emerald", 21, 35 }, { "mcl_armor:chestplate_diamond_enchanted", 1, 1 } },
			},
		},
	},
	leatherworker = {
		name = S("Leatherworker"),
		texture = "mobs_mc_villager_leatherworker.png",
		jobsite = "group:cauldron",
		trades = {
			{
			{ { "mcl_mobitems:leather", 6, 6 }, E1 },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_armor:leggings_leather", 1, 1 } },
			{ { "mcl_core:emerald", 7, 7 }, { "mcl_armor:chestplate_leather", 1, 1 } },
			},

			{
			{ { "mcl_core:flint", 26, 26 }, E1 },
			{ { "mcl_core:emerald", 5, 5 }, { "mcl_armor:helmet_leather", 1, 1 } },
			{ { "mcl_core:emerald", 4, 4 }, { "mcl_armor:boots_leather", 1, 1 } },
			},

			{
			{ { "mcl_mobitems:rabbit_hide", 9, 9 }, E1 },
			{ { "mcl_core:emerald", 7, 7 }, { "mcl_armor:chestplate_leather", 1, 1 } },
			},

			{
			--{ { "FIXME: scute", 4, 4 }, E1 },
			{ { "mcl_core:emerald", 8, 10 }, { "mcl_mobitems:saddle", 1, 1 } },
			--FIXME: { { "mcl_core:emerald", 6, 6 }, { "mcl_mobitems:leather_horse_armor", 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 6, 6 }, { "mcl_mobitems:saddle", 1, 1 } },
			{ { "mcl_core:emerald", 5, 5 }, { "mcl_armor:helmet_leather", 1, 1 } },
			},
		},
	},
	butcher = {
		name = S("Butcher"),
		texture = "mobs_mc_villager_butcher.png",
		jobsite = "mcl_smoker:smoker",
		trades = {
			{
			{ { "mcl_mobitems:chicken", 14, 14 }, E1 },
			{ { "mcl_mobitems:porkchop", 7, 7 }, E1 },
			{ { "mcl_mobitems:rabbit", 4, 4 }, E1 },
			{ E1, { "mcl_mobitems:rabbit_stew", 1, 1 } },
			},

			{
			{ { "mcl_core:coal_lump", 15, 15 }, E1 },
			{ E1, { "mcl_mobitems:cooked_porkchop", 5, 5 } },
			{ E1, { "mcl_mobitems:cooked_chicken", 8, 8 } },
			},

			{
			{ { "mcl_mobitems:mutton", 7, 7 }, E1 },
			{ { "mcl_mobitems:beef", 10, 10 }, E1 },
			},

			{
			{ { "mcl_ocean:dried_kelp_block", 10, 10 }, E1 },
			},

			{
			{ { "mcl_farming:sweet_berry", 10, 10 }, E1 },
			},
		},
	},
	weapon_smith = {
		name = S("Weapon Smith"),
		texture = "mobs_mc_villager_weaponsmith.png",
		jobsite = "mcl_grindstone:grindstone",
		trades = {
			{
			{ { "mcl_core:coal_lump", 15, 15 }, E1 },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_tools:axe_iron", 1, 1 } },
			{ { "mcl_core:emerald", 7, 21 }, { "mcl_tools:sword_iron_enchanted", 1, 1 } },
			},

			{
			{ { "mcl_core:iron_ingot", 4, 4 }, E1 },
			{ { "mcl_core:emerald", 36, 36 }, { "mcl_bells:bell", 1, 1 } },
			},

			{
			{ { "mcl_core:flint", 24, 24 }, E1 },
			},

			{
			{ { "mcl_core:diamond", 1, 1 }, E1 },
			{ { "mcl_core:emerald", 17, 31 }, { "mcl_tools:axe_diamond_enchanted", 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 13, 27 }, { "mcl_tools:sword_diamond_enchanted", 1, 1 } },
			},
		},
	},
	tool_smith = {
		name = S("Tool Smith"),
		texture = "mobs_mc_villager_toolsmith.png",
		jobsite = "mcl_smithing_table:table",
		trades = {
			{
			{ { "mcl_core:coal_lump", 15, 15 }, E1 },
			{ E1, { "mcl_tools:axe_stone", 1, 1 } },
			{ E1, { "mcl_tools:shovel_stone", 1, 1 } },
			{ E1, { "mcl_tools:pick_stone", 1, 1 } },
			{ E1, { "mcl_farming:hoe_stone", 1, 1 } },
			},

			{
			{ { "mcl_core:iron_ingot", 4, 4 }, E1 },
			{ { "mcl_core:emerald", 36, 36 }, { "mcl_bells:bell", 1, 1 } },
			},

			{
			{ { "mcl_core:flint", 30, 30 }, E1 },
			{ { "mcl_core:emerald", 6, 20 }, { "mcl_tools:axe_iron_enchanted", 1, 1 } },
			{ { "mcl_core:emerald", 7, 21 }, { "mcl_tools:shovel_iron_enchanted", 1, 1 } },
			{ { "mcl_core:emerald", 8, 22 }, { "mcl_tools:pick_iron_enchanted", 1, 1 } },
			{ { "mcl_core:emerald", 4, 4 }, { "mcl_farming:hoe_diamond", 1, 1 } },
			},

			{
			{ { "mcl_core:diamond", 1, 1 }, E1 },
			{ { "mcl_core:emerald", 17, 31 }, { "mcl_tools:axe_diamond_enchanted", 1, 1 } },
			{ { "mcl_core:emerald", 10, 24 }, { "mcl_tools:shovel_diamond_enchanted", 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 18, 32 }, { "mcl_tools:pick_diamond_enchanted", 1, 1 } },
			},
		},
	},
	cleric = {
		name = S("Cleric"),
		texture = "mobs_mc_villager_priest.png",
		jobsite = "mcl_brewing:stand_000",
		trades = {
			{
			{ { "mcl_mobitems:rotten_flesh", 32, 32 }, E1 },
			{ E1, { "mesecons:redstone", 2, 2  } },
			},

			{
			{ { "mcl_core:gold_ingot", 3, 3 }, E1 },
			{ E1, { "mcl_core:lapis", 1, 1 } },
			},

			{
			{ { "mcl_mobitems:rabbit_foot", 2, 2 }, E1 },
			{ { "mcl_core:emerald", 4, 4 }, { "mcl_nether:glowstone", 1, 1 } },
			},

			{
			--{ { "FIXME: scute", 4, 4 }, E1 },
			{ { "mcl_potions:glass_bottle", 9, 9 }, E1 },
			{ { "mcl_core:emerald", 5, 5 }, { "mcl_throwing:ender_pearl", 1, 1 } },
			},

			{
			{ { "mcl_nether:nether_wart_item", 22, 22 }, E1 },
			{ { "mcl_core:emerald", 3, 3 }, { "mcl_experience:bottle", 1, 1 } },
			},
		},
	},
	mason =	{
		name = S("Mason"),
		texture = "mobs_mc_villager_mason.png",
		jobsite = "mcl_stonecutter:stonecutter",
		trades =  {
			{
			{ { "mcl_core:clay_lump", 10, 10 }, E1  },
			{ E1, { "mcl_core:brick", 10, 10 } },
			},

			{
			{ { "mcl_core:stone", 20, 20 }, E1 },
			{ E1, { "mcl_core:stonebrickcarved", 4, 4 } },
			},

			{
			{ { "mcl_core:granite", 16, 16 }, E1 },
			{ { "mcl_core:andesite", 16, 16 }, E1 },
			{ { "mcl_core:diorite", 16, 16 }, E1 },
			{ E1, { "mcl_core:andesite_smooth", 4, 4 } },
			{ E1, { "mcl_core:granite_smooth", 4, 4 } },
			{ E1, { "mcl_core:diorite_smooth", 4, 4 } },
			--FIXME: { E1, { "Dripstone Block", 4, 4 } },
			},

			{
			{ { "mcl_nether:quartz", 12, 12 }, E1 },
			{ E1, { "mcl_colorblocks:hardened_clay_white", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_grey", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_silver", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_black", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_red", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_yellow", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_green", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_cyan", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_blue", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_magenta", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_orange", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_brown", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_pink", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_light_blue", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_lime", 1, 1 } },
			{ E1, { "mcl_colorblocks:hardened_clay_purple", 1, 1 } },

			{ E1, { "mcl_colorblocks:glazed_terracotta_white", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_grey", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_silver", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_black", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_red", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_yellow", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_green", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_cyan", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_blue", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_magenta", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_orange", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_brown", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_pink", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_light_blue", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_lime", 1, 1 } },
			{ E1, { "mcl_colorblocks:glazed_terracotta_purple", 1, 1 } },
			},

			{
			{ E1, { "mcl_nether:quartz_pillar", 1, 1 } },
			{ E1, { "mcl_nether:quartz_block", 1, 1 } },
			},
		},
	},
	nitwit = {
		name = S("Nitwit"),
		texture = "mobs_mc_villager_nitwit.png",
		-- No trades for nitwit
		trades = nil,
	}
}
