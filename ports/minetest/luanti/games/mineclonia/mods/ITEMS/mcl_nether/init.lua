local S = core.get_translator(core.get_current_modname())
local C = core.colorize

core.register_node("mcl_nether:glowstone", {
	description = S("Glowstone"),
	_doc_items_longdesc = S("Glowstone is a naturally-glowing block which is home to the Nether."),
	tiles = {"mcl_nether_glowstone.png"},
	groups = {handy=1,building_block=1, material_glass=1},
	drop = {
	max_items = 1,
	items = {
			{items = {"mcl_nether:glowstone_dust 4"}, rarity = 3},
			{items = {"mcl_nether:glowstone_dust 3"}, rarity = 3},
			{items = {"mcl_nether:glowstone_dust 2"}},
		}
	},
	paramtype = "light",
	light_source = core.LIGHT_MAX,
	sounds = mcl_sounds.node_sound_glass_defaults(),
	_mcl_hardness = 0.3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"mcl_nether:glowstone_dust"},
		min_count = 2,
		max_count = 4,
		cap = 4,
	}
})

core.register_node("mcl_nether:quartz_ore", {
	description = S("Nether Quartz Ore"),
	_doc_items_longdesc = S("Nether quartz ore is an ore containing nether quartz. It is commonly found around netherrack in the Nether."),
	tiles = {"mcl_nether_quartz_ore.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, xp=3, blast_furnace_smeltable = 1},
	drop = "mcl_nether:quartz",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
	_mcl_cooking_output = "mcl_nether:quartz"
})

core.register_node("mcl_nether:ancient_debris", {
	description = S("Ancient Debris"),
	_doc_items_longdesc = S("Ancient debris can be found in the nether and is very very rare."),
	tiles = {"mcl_nether_ancient_debris_top.png", "mcl_nether_ancient_debris_side.png"},
	groups = {pickaxey=4, building_block=1, material_stone=1, xp=0, blast_furnace_smeltable = 1,
		fire_immune = 1},
	drop = "mcl_nether:ancient_debris",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 1200,
	_mcl_hardness = 30,
	_mcl_silk_touch_drop = true,
	_mcl_cooking_output = "mcl_nether:netherite_scrap"
})

core.register_node("mcl_nether:netheriteblock", {
	description = S("Block of Netherite"),
	_doc_items_longdesc = S("Netherite block is very hard and can be made of 9 netherite ingots."),
	tiles = {"mcl_nether_netheriteblock.png"},
	is_ground_content = false,
	groups = { pickaxey=4, building_block=1, material_stone=1, xp = 0, fire_immune=1, beacon_block = 1 },
	drop = "mcl_nether:netheriteblock",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 1200,
	_mcl_hardness = 50,
	_mcl_silk_touch_drop = true,
	_mcl_crafting_output = {single = {output = "mcl_nether:netherite_ingot 9"}}
})

-- For eternal fire on top of netherrack and magma blocks
-- (this code does not require a dependency on mcl_fire)
local function eternal_after_destruct(pos)
	pos.y = pos.y + 1
	if core.get_node(pos).name == "mcl_fire:eternal_fire" then
		core.remove_node(pos)
	end
end

local function eternal_on_ignite(player, pointed_thing)
	local pos = pointed_thing.under
	local flame_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
	local fn = core.get_node(flame_pos)
	local pname = player:get_player_name()
	if core.is_protected(flame_pos, pname) then
		core.record_protection_violation(flame_pos, pname)
		return
	end
	if fn.name == "air" and pointed_thing.under.y < pointed_thing.above.y then
		core.set_node(flame_pos, {name = "mcl_fire:eternal_fire"})
		return true
	else
		return false
	end
end

core.register_node("mcl_nether:netherrack", {
	description = S("Netherrack"),
	_doc_items_longdesc = S("Netherrack is a stone-like block home to the Nether. Starting a fire on this block will create an eternal fire."),
	tiles = {"mcl_nether_netherrack.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, enderman_takable=1, nether_ore_target=1,},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_hardness = 0.4,
	_mcl_cooking_output = "mcl_nether:netherbrick",

	-- Eternal fire on top
	after_destruct = eternal_after_destruct,
	_on_ignite = eternal_on_ignite,
	_on_bone_meal = function(_, _, _, pos , _)
		local n = core.find_node_near(pos,1,{"mcl_crimson:warped_nylium","mcl_crimson:crimson_nylium"})
		if n then
			core.set_node(pos,core.get_node(n))
		end
	end,
})

core.register_node("mcl_nether:magma", {
	description = S("Magma Block"),
	_tt_help = core.colorize(mcl_colors.YELLOW, S("Burns your feet")),
	_doc_items_longdesc = S("Magma blocks are hot solid blocks which hurt anyone standing on it, unless they have fire resistance. Starting a fire on this block will create an eternal fire."),
	tiles = {{name="mcl_nether_magma.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=1.5}}},
	light_source = 3,
	groups = {pickaxey=1, building_block=1, material_stone=1, fire=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_hardness = 0.5,

	-- Eternal fire on top
	after_destruct = eternal_after_destruct,
	_on_ignite = eternal_on_ignite,
})

mcl_player.register_globalstep_slow(function(player)
	if mcl_player.players[player].nodes.stand ~= "mcl_nether:magma" then return end
	local armor_feet = player:get_inventory():get_stack("armor", 5)
	if player and player:get_player_control().sneak or (core.global_exists("mcl_enchanting") and mcl_enchanting.has_enchantment(armor_feet, "frost_walker")) or (core.global_exists("mcl_potions") and mcl_potions.has_effect(player, "fire_resistance")) then
		return
	end
	-- Hurt players standing on top of this block
	if player:get_hp() > 0 then
		mcl_util.deal_damage(player, 1, {type = "hot_floor"})
	end
end)

core.register_node("mcl_nether:soul_sand", {
	description = S("Soul Sand"),
	_tt_help = S("Reduces walking speed"),
	_doc_items_longdesc = S("Soul sand is a block from the Nether. It has a slowing effect when walked on."),
	tiles = {"mcl_nether_soul_sand.png"},
	groups = {handy = 1, shovely = 1, building_block = 1, soil_nether_wart = 1, material_sand = 1, soul_block = 1, pathfinder_partial = 2 },
	collision_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, 0.5 - 2/16, 0.5 },
	},
	sounds = mcl_sounds.node_sound_sand_defaults(),
	_mcl_hardness = 0.5,
	-- Mobs only.
	_mcl_velocity_factor = 0.4,
})

mcl_player.register_globalstep_slow(function(player)
	-- Standing on soul sand or soul soil?
	if core.get_item_group(mcl_player.players[player].nodes.stand, "soul_block") > 0 then
		-- TODO: Tweak walk speed
		local inv = player:get_inventory ()
		local boots = inv:get_stack("armor", 5)
		local soul_speed = mcl_enchanting.get_enchantment(boots, "soul_speed")
		-- If player wears Soul Speed boots, increase speed
		if soul_speed > 0 then
			playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:soul_sand", soul_speed * 0.105 + 1.3)
			-- Apply a 4% chance of damaging the boots per
			-- tick, taking into account that each "slow"
			-- globalstep is supposed to extend over 10
			-- ticks.

			if not core.is_creative_enabled (player:get_player_name ()) then
				for i = 1, 10 do
					if math.random () < 0.04 then
						mcl_armor.use_durability (player, inv, 5, boots, 1)
						if boots:is_empty () then
							mcl_armor.update (player)
							break
						end
					end
				end
			end
		elseif mcl_player.players[player].nodes.stand == "mcl_nether:soul_sand" then
			-- Otherwise walk slower on soul sand.
			playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:soul_sand", 0.4)
		else
			playerphysics.remove_physics_factor(player, "speed", "mcl_playerplus:soul_sand")
		end
	else
		playerphysics.remove_physics_factor(player, "speed", "mcl_playerplus:soul_sand")
	end
end)

local nether_brick = {
	description = S("Nether Brick Block"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_nether_nether_brick.png"},
	is_ground_content = false,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
}

core.register_node("mcl_nether:nether_brick", table.merge(nether_brick,{
	groups = {pickaxey=1, building_block=1, material_stone=1, stonecuttable = 1},
	_mcl_cooking_output = "mcl_nether:cracked_nether_brick"
}))

core.register_node("mcl_nether:red_nether_brick", table.merge(nether_brick,{
	description = S("Red Nether Brick Block"),
	tiles = {"mcl_nether_red_nether_brick.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, stonecuttable = 1},
}))

local chiseled_nether_brick = table.copy(nether_brick)
chiseled_nether_brick.description = S("Chiseled Nether Brick Block")
chiseled_nether_brick.tiles = {"mcl_nether_chiseled_nether_bricks.png"}
chiseled_nether_brick._mcl_stonecutter_recipes = {"mcl_nether:nether_brick"}
core.register_node("mcl_nether:chiseled_nether_brick", chiseled_nether_brick)

local cracked_nether_brick = table.copy(nether_brick)
cracked_nether_brick.description = S("Cracked Nether Bricks")
cracked_nether_brick.tiles = {"mcl_nether_cracked_nether_bricks.png"}
core.register_node("mcl_nether:cracked_nether_brick", cracked_nether_brick)

core.register_node("mcl_nether:nether_wart_block", {
	description = S("Nether Wart Block"),
	_doc_items_longdesc = S("A nether wart block is a purely decorative block made from nether wart."),
	tiles = {"mcl_nether_nether_wart_block.png"},
	is_ground_content = false,
	groups = {handy=1, hoey=7, swordy=1, building_block=1, compostability = 85},
	sounds = mcl_sounds.node_sound_leaves_defaults(
		{
			footstep={name="default_dirt_footstep", gain=0.7},
			dug={name="default_dirt_footstep", gain=1.5},
		}
	),
	_mcl_hardness = 1,
})

core.register_node("mcl_nether:quartz_block", {
	description = S("Block of Quartz"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	is_ground_content = false,
	tiles = {"mcl_nether_quartz_block_top.png", "mcl_nether_quartz_block_bottom.png", "mcl_nether_quartz_block_side.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1, stonecuttable=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_hardness = 0.8,
	_mcl_cooking_output = "mcl_nether:quartz_smooth",
	_mcl_crafting_output = {square2 = {output = "mcl_blackstone:quartz_brick 4"}}
})

core.register_node("mcl_nether:quartz_chiseled", {
	description = S("Chiseled Quartz Block"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	is_ground_content = false,
	tiles = {"mcl_nether_quartz_chiseled_top.png", "mcl_nether_quartz_chiseled_top.png", "mcl_nether_quartz_chiseled_side.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_hardness = 0.8,
	_mcl_stonecutter_recipes = { "mcl_nether:quartz_block" },
})

core.register_node("mcl_nether:quartz_pillar", {
	description = S("Pillar Quartz Block"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = mcl_util.rotate_axis,
	tiles = {"mcl_nether_quartz_pillar_top.png", "mcl_nether_quartz_pillar_top.png^[transformFY", "mcl_nether_quartz_pillar_side.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_3way,
	_mcl_hardness = 0.8,
	_mcl_stonecutter_recipes = { "mcl_nether:quartz_block" },
})
core.register_node("mcl_nether:quartz_smooth", {
	description = S("Smooth Quartz"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	is_ground_content = false,
	tiles = {"mcl_nether_quartz_block_bottom.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1, stonecuttable = 1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
	_mcl_stonecutter_recipes = { "mcl_nether:quartz_block" },
})

mcl_stairs.register_stair_and_slab("quartzblock", {
	baseitem = "mcl_nether:quartz_block",
	description_stair = S("Quartz Stairs"),
	description_slab = S("Quartz Slab"),
	recipeitem = "group:quartz_block",
	overrides = {_mcl_stonecutter_recipes = {"mcl_nether:quartz_block"}},
})

mcl_stairs.register_stair_and_slab("quartz_smooth", {
	baseitem = "mcl_nether:quartz_smooth",
	description_stair = S("Smooth Quartz Stairs"),
	description_slab = S("Smooth Quartz Slab"),
	recipeitem = "mcl_nether:quartz_smooth",
	overrides = {_mcl_stonecutter_recipes = {"mcl_nether:quartz_smooth"}},
})

mcl_stairs.register_stair_and_slab("nether_brick", {
	baseitem = "mcl_nether:nether_brick",
	description_stair = S("Nether Brick Stairs"),
	description_slab = S("Nether Brick Slab"),
	overrides = {_mcl_stonecutter_recipes = { "mcl_nether:nether_brick" }},{_mcl_stonecutter_recipes = { "mcl_nether:nether_brick" }},
})
mcl_stairs.register_stair_and_slab("red_nether_brick", {
	baseitem = "mcl_nether:red_nether_brick",
	description_stair = S("Red Nether Brick Stairs"),
	description_slab = S("Red Nether Brick Slab"),
	overrides = {_mcl_stonecutter_recipes = { "mcl_nether:red_nether_brick" }},{_mcl_stonecutter_recipes = { "mcl_nether:red_nether_brick" }},
})

-- Nether Brick Fence (without fence gate!)
mcl_fences.register_fence_def("nether_brick_fence", {
	description = S("Nether Brick Fence"),
	tiles = { "mcl_fences_fence_nether_brick.png" },
	groups = { pickaxey = 1, fence_nether_brick = 1 },
	connects_to = { "group:fence_nether_brick", "group:solid" },
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
	_mcl_fences_baseitem = "mcl_nether:nether_brick",
	_mcl_fences_stickreplacer = "mcl_nether:netherbrick",
	_mcl_fences_output_amount = 6
})

core.register_craftitem("mcl_nether:glowstone_dust", {
	description = S("Glowstone Dust"),
	_doc_items_longdesc = S("Glowstone dust is the dust which comes out of broken glowstones. It is mainly used in crafting."),
	inventory_image = "mcl_nether_glowstone_dust.png",
	groups = { craftitem=1, brewitem=1 },
	_mcl_crafting_output = {square2 = {output = "mcl_nether:glowstone"}}
})

core.register_craftitem("mcl_nether:quartz", {
	description = S("Nether Quartz"),
	_doc_items_longdesc = S("Nether quartz is a versatile crafting ingredient."),
	inventory_image = "mcl_nether_quartz.png",
	groups = { craftitem = 1 },
	_mcl_armor_trim_color = "#c9bcb9",
	_mcl_armor_trim_desc = S("Quartz Material"),
	_mcl_crafting_output = {square2 = {output = "mcl_nether:quartz_block"}}
})

core.register_craftitem("mcl_nether:netherite_scrap", {
	description = S("Netherite Scrap"),
	_doc_items_longdesc = S("Netherite scrap is a crafting ingredient for netherite ingots."),
	inventory_image = "mcl_nether_netherite_scrap.png",
	groups = { craftitem = 1, fire_immune=1 },
})

core.register_craftitem("mcl_nether:netherite_ingot", {
	description = S("Netherite Ingot"),
	_doc_items_longdesc = S("Netherite ingots can be used with a smithing table to upgrade items to netherite."),
	inventory_image = "mcl_nether_netherite_ingot.png",
	groups = { craftitem = 1, fire_immune=1, beacon_fuel = 1 },
	_mcl_armor_trim_color = "#302a26",
	_mcl_armor_trim_desc = S("Netherite Material"),
	_mcl_crafting_output = {square3 = {output = "mcl_nether:netheriteblock"}}
})

core.register_craftitem("mcl_nether:netherbrick", {
	description = S("Nether Brick"),
	_doc_items_longdesc = S("Nether bricks are the main crafting ingredient for crafting nether brick blocks and nether fences."),
	inventory_image = "mcl_nether_netherbrick.png",
	groups = { craftitem = 1 },
	_mcl_crafting_output = {square2 = {output = "mcl_nether:nether_brick"}}
})

core.register_craftitem("mcl_nether:netherite_upgrade_template", {
	description	= S("Netherite Upgrade Template"),
	_tt_help = S("Smithing Template").."\n\n"..
	C(mcl_colors.GRAY, S("Applies to:")).."\n\t"..C(mcl_colors.BLUE, S("Diamond Equipment")).."\n"..
	C(mcl_colors.GRAY, S("Ingredients:")).."\n\t"..C(mcl_colors.BLUE, S("Netherite Ingot")),
	inventory_image  = "mcl_nether_netherite_upgrade_template.png",
	groups = { rarity = 1, upgrade_template  = 1 },
})

core.register_craft({
    output = "mcl_nether:netherite_upgrade_template 2",
    recipe = {
        {"mcl_core:diamond", "mcl_nether:netherite_upgrade_template","mcl_core:diamond"},
        {"mcl_core:diamond", "mcl_nether:netherrack","mcl_core:diamond"},
        {"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
    }
})

core.register_craft({
	output = "mcl_nether:quartz_pillar 2",
	recipe = {
		{"mcl_nether:quartz_block"},
		{"mcl_nether:quartz_block"},
	}
})

core.register_craft({
	output = "mcl_nether:red_nether_brick",
	recipe = {
		{"mcl_nether:nether_wart_item", "mcl_nether:netherbrick"},
		{"mcl_nether:netherbrick", "mcl_nether:nether_wart_item"},
	}
})
core.register_craft({
	output = "mcl_nether:red_nether_brick",
	recipe = {
		{"mcl_nether:netherbrick", "mcl_nether:nether_wart_item"},
		{"mcl_nether:nether_wart_item", "mcl_nether:netherbrick"},
	}
})

core.register_craft({
	output = "mcl_nether:chiseled_nether_brick",
	recipe = {
		{"mcl_stairs:slab_nether_brick"},
		{"mcl_stairs:slab_nether_brick"},
	}
})

core.register_craft({
	type = "shapeless",
	output = "mcl_nether:netherite_ingot",
	recipe = {
		"mcl_nether:netherite_scrap", "mcl_nether:netherite_scrap", "mcl_nether:netherite_scrap",
		"mcl_nether:netherite_scrap", "mcl_core:gold_ingot", "mcl_core:gold_ingot",
		"mcl_core:gold_ingot", "mcl_core:gold_ingot", },
})

local modpath = core.get_modpath (core.get_current_modname ())
dofile(modpath.."/nether_wart.lua")
dofile(modpath.."/lava.lua")
mcl_levelgen.register_levelgen_script (modpath .. "/lg_register.lua")
