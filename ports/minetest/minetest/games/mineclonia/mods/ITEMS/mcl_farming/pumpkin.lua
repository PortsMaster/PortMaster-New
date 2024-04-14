local S = minetest.get_translator(minetest.get_current_modname())

local mod_screwdriver = minetest.get_modpath("screwdriver")

local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_simple
end

local function on_bone_meal(itemstack,placer,pointed_thing,pos,node)
	return mcl_farming.on_bone_meal(itemstack,placer,pointed_thing,pos,node,"plant_pumpkin_stem")
end

local function carve_pumpkin(itemstack, placer, pointed_thing)
	-- Only carve pumpkin if used on side
	if pointed_thing.above.y ~= pointed_thing.under.y then
		return
	end
	if not minetest.is_creative_enabled(placer:get_player_name()) then
		-- Add wear (as if digging a shearsy node)
		local toolname = itemstack:get_name()
		local wear = mcl_autogroup.get_wear(toolname, "shearsy")
		itemstack:add_wear(wear)
	end
	minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = pointed_thing.above}, true)
	local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
	local param2 = minetest.dir_to_facedir(dir)
	minetest.set_node(pointed_thing.under, {name="mcl_farming:pumpkin_face", param2 = param2})
	minetest.add_item(pointed_thing.above, "mcl_farming:pumpkin_seeds 4")
	return itemstack, true
end

-- Seeds
minetest.register_craftitem("mcl_farming:pumpkin_seeds", {
	description = S("Pumpkin Seeds"),
	_tt_help = S("Grows on farmland"),
	_doc_items_longdesc = S("Grows into a pumpkin stem which in turn grows pumpkins. Chickens like pumpkin seeds."),
	_doc_items_usagehelp = S("Place the pumpkin seeds on farmland (which can be created with a hoe) to plant a pumpkin stem. Pumpkin stems grow in sunlight and grow faster on hydrated farmland. When mature, the stem attempts to grow a pumpkin next to it. Rightclick an animal to feed it pumpkin seeds."),
	inventory_image = "mcl_farming_pumpkin_seeds.png",
	groups = {craftitem=1, compostability = 30},
	on_place = function(itemstack, placer, pointed_thing)
		return mcl_farming:place_seed(itemstack, placer, pointed_thing, "mcl_farming:pumpkin_1")
	end
})

local stem_drop = {
	max_items = 1,
	-- The probabilities are slightly off from the original.
	-- Update this drop list when the Minetest drop probability system
	-- is more powerful.
	items = {
		-- 1 seed: Approximation to 20/125 chance
		-- 20/125 = 0.16
		-- Approximation: 1/6 = ca. 0.166666666666667
		{ items = {"mcl_farming:pumpkin_seeds 1"}, rarity = 6 },

		-- 2 seeds: Approximation to 4/125 chance
		-- 4/125 = 0.032
		-- Approximation: 1/31 = ca. 0.032258064516129
		{ items = {"mcl_farming:pumpkin_seeds 2"}, rarity = 31 },

		-- 3 seeds: 1/125 chance
		{ items = {"mcl_farming:pumpkin_seeds 3"}, rarity = 125 },
	},
}

-- Unconnected immature stem

local startcolor = { r = 0x2E , g = 0x9D, b = 0x2E }
local endcolor = { r = 0xFF , g = 0xA8, b = 0x00 }

for s=1,7 do
	local h = s / 8
	local doc = s == 1
	local longdesc, entry_name
	if doc then
		entry_name = S("Premature Pumpkin Stem")
		longdesc = S("Pumpkin stems grow on farmland in 8 stages. On hydrated farmland, the growth is a bit quicker. Mature pumpkin stems are able to grow pumpkins.")
	end
	local colorstring = mcl_farming:stem_color(startcolor, endcolor, s, 8)
	local texture = "([combine:16x16:0,"..((8-s)*2).."=mcl_farming_pumpkin_stem_disconnected.png)^[colorize:"..colorstring..":127"
	minetest.register_node("mcl_farming:pumpkin_"..s, {
		description = S("Premature Pumpkin Stem (Stage @1)", s),
		_doc_items_entry_name = entry_name,
		_doc_items_create_entry = doc,
		_doc_items_longdesc = longdesc,
		paramtype = "light",
		walkable = false,
		drawtype = "plantlike",
		sunlight_propagates = true,
		drop = stem_drop,
		tiles = {texture},
		inventory_image = texture,
		wield_image = texture,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.15, -0.5, -0.15, 0.15, -0.5+h, 0.15}
			},
		},
		groups = {dig_immediate=3, not_in_creative_inventory=1, plant=1,attached_node=1, dig_by_water=1,destroy_by_lava_flow=1,},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0,
		_on_bone_meal = on_bone_meal,
	})
end

-- Full stem (not connected)
local stem_def = {
	description = S("Mature Pumpkin Stem"),
	_doc_items_longdesc = S("A mature pumpkin stem attempts to grow a pumpkin at one of its four adjacent blocks. A pumpkin can only grow on top of farmland, dirt or a grass block. When a pumpkin is next to a pumpkin stem, the pumpkin stem immediately bends and connects to the pumpkin. A connected pumpkin stem can't grow another pumpkin. As soon all pumpkins around the stem have been removed, it loses the connection and is ready to grow another pumpkin."),
	tiles = {"mcl_farming_pumpkin_stem_disconnected.png^[colorize:#FFA800:127"},
	wield_image = "mcl_farming_pumpkin_stem_disconnected.png^[colorize:#FFA800:127",
	inventory_image = "mcl_farming_pumpkin_stem_disconnected.png^[colorize:#FFA800:127",
}

-- Template for pumpkin
local pumpkin_base_def = {
	description = S("Faceless Pumpkin"),
	_doc_items_longdesc = S("A faceless pumpkin is a decorative block. It can be carved with shears to obtain pumpkin seeds."),
	_doc_items_usagehelp = S("To carve a face into the pumpkin, use the shears on the side you want to carve."),
	paramtype2 = "facedir",
	tiles = {"farming_pumpkin_top.png", "farming_pumpkin_top.png", "farming_pumpkin_side.png"},
	groups = {
		handy = 1, axey = 1, plant = 1, building_block = 1, dig_by_piston = 1,
		pumpkin = 1, enderman_takable = 1, compostability = 65
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_rotate = on_rotate,
	_on_shears_place = carve_pumpkin,
	_mcl_blast_resistance = 1,
	_mcl_hardness = 1,
}

local pumpkin_face_base_def = table.copy(pumpkin_base_def)
pumpkin_face_base_def.description = S("Pumpkin")
pumpkin_face_base_def._doc_items_longdesc = S("A pumpkin can be worn as a helmet. Pumpkins grow from pumpkin stems, which in turn grow from pumpkin seeds.")
pumpkin_face_base_def._doc_items_usagehelp = nil
pumpkin_face_base_def.tiles = {"farming_pumpkin_top.png", "farming_pumpkin_top.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_face.png"}
pumpkin_face_base_def.groups.armor=1
pumpkin_face_base_def.groups.non_combat_armor=1
pumpkin_face_base_def.groups.armor_head=1
pumpkin_face_base_def.groups.non_combat_armor_head=1
pumpkin_face_base_def._mcl_armor_mob_range_factor = 0
pumpkin_face_base_def._mcl_armor_mob_range_mob = "mobs_mc:enderman"

pumpkin_face_base_def._mcl_armor_element = "head"
pumpkin_face_base_def._mcl_armor_texture = "mcl_farming_pumpkin_face.png"
pumpkin_face_base_def._on_shears_place = nil

pumpkin_face_base_def.after_place_node = function(pos, placer, itemstack, pointed_thing)
	-- Attempt to spawn iron golem or snow golem
	mobs_mc.check_iron_golem_summon(pos, placer)
	mobs_mc.check_snow_golem_summon(pos, placer)
end

-- TODO: when < minetest 5.9 isn't supported anymore, remove this variable check and replace all occurences of [hud_elem_type_field] with type
local hud_elem_type_field = "type"
if not minetest.features.hud_def_type_field then
	hud_elem_type_field = "hud_elem_type"
end

if minetest.get_modpath("mcl_armor") then
	local pumpkin_hud = {}
	local function add_pumpkin_hud(player)
		pumpkin_hud[player] = {
			pumpkin_blur = player:hud_add({
				[hud_elem_type_field] = "image",
				position = {x = 0.5, y = 0.5},
				scale = {x = -101, y = -101},
				text = "mcl_farming_pumpkin_hud.png",
				z_index = -200
			}),
			--this is a fake crosshair, because hotbar and crosshair doesn't support z_index
			--TODO: remove this and add correct z_index values
			fake_crosshair = player:hud_add({
				[hud_elem_type_field] = "image",
				position = {x = 0.5, y = 0.5},
				scale = {x = 1, y = 1},
				text = "crosshair.png",
				z_index = -100
			})
		}
	end
	local function remove_pumpkin_hud(player)
		if pumpkin_hud[player] then
			player:hud_remove(pumpkin_hud[player].pumpkin_blur)
			player:hud_remove(pumpkin_hud[player].fake_crosshair)
			pumpkin_hud[player] = nil
		end
	end

	pumpkin_face_base_def.on_secondary_use = mcl_armor.equip_on_use
	pumpkin_face_base_def._on_equip = add_pumpkin_hud
	pumpkin_face_base_def._on_unequip = remove_pumpkin_hud

	minetest.register_on_joinplayer(function(player)
		if player:get_inventory():get_stack("armor", 2):get_name() == "mcl_farming:pumpkin_face" then
			add_pumpkin_hud(player)
		end
	end)
	minetest.register_on_dieplayer(function(player)
		if not minetest.settings:get_bool("mcl_keepInventory") then
			remove_pumpkin_hud(player)
		end
	end)
	minetest.register_on_leaveplayer(function(player)
		pumpkin_hud[player] = nil
	end)
end

-- Register stem growth
mcl_farming:add_plant("plant_pumpkin_stem", "mcl_farming:pumpkintige_unconnect", {"mcl_farming:pumpkin_1", "mcl_farming:pumpkin_2", "mcl_farming:pumpkin_3", "mcl_farming:pumpkin_4", "mcl_farming:pumpkin_5", "mcl_farming:pumpkin_6", "mcl_farming:pumpkin_7"}, 30, 5)

-- Register actual pumpkin, connected stems and stem-to-pumpkin growth
mcl_farming:add_gourd("mcl_farming:pumpkintige_unconnect", "mcl_farming:pumpkintige_linked", "mcl_farming:pumpkintige_unconnect", stem_def, stem_drop, "mcl_farming:pumpkin", pumpkin_base_def, 30, 15, "mcl_farming_pumpkin_stem_connected.png^[colorize:#FFA800:127")

-- Steal function to properly disconnect a carved pumpkin
pumpkin_face_base_def.after_destruct = minetest.registered_nodes["mcl_farming:pumpkin"].after_destruct
minetest.register_node("mcl_farming:pumpkin_face", pumpkin_face_base_def)

-- Jack o'Lantern
minetest.register_node("mcl_farming:pumpkin_face_light", {
	description = S("Jack o'Lantern"),
	_doc_items_longdesc = S("A jack o'lantern is a traditional Halloween decoration made from a pumpkin. It glows brightly."),
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = minetest.LIGHT_MAX,
	tiles = {"farming_pumpkin_top.png", "farming_pumpkin_top.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_face_light.png"},
	groups = {handy=1, axey=1, pumpkin=1, building_block=1, dig_by_piston=1 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_construct = function(pos)
		-- Attempt to spawn iron golem or snow golem
		mobs_mc.check_iron_golem_summon(pos)
		mobs_mc.check_snow_golem_summon(pos)
	end,
	on_rotate = on_rotate,
	_mcl_blast_resistance = 1,
	_mcl_hardness = 1,
})

-- Crafting

minetest.register_craft({
	output = "mcl_farming:pumpkin_face_light",
	recipe = {{"mcl_farming:pumpkin_face"},
	{"mcl_torches:torch"}}
})

minetest.register_craft({
	output = "mcl_farming:pumpkin_seeds 4",
	recipe = {{"mcl_farming:pumpkin"}}
})

minetest.register_craftitem("mcl_farming:pumpkin_pie", {
	description = S("Pumpkin Pie"),
	_doc_items_longdesc = S("A pumpkin pie is a tasty food item which can be eaten."),
	inventory_image = "mcl_farming_pumpkin_pie.png",
	wield_image = "mcl_farming_pumpkin_pie.png",
	on_place = minetest.item_eat(8),
	on_secondary_use = minetest.item_eat(8),
	groups = {food = 2, eatable = 8, compostability = 100},
	_mcl_saturation = 4.8,
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_farming:pumpkin_pie",
	recipe = {"mcl_farming:pumpkin", "mcl_core:sugar", "mcl_throwing:egg"},
})


if minetest.get_modpath("doc") then
	for i=2,8 do
		doc.add_entry_alias("nodes", "mcl_farming:pumpkin_1", "nodes", "mcl_farming:pumpkin_"..i)
	end
end
