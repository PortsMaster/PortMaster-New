-- Other nodes
local S = core.get_translator(core.get_current_modname())

core.register_node("mcl_core:bone_block", {
	description = S("Bone Block"),
	_doc_items_longdesc = S("Bone blocks are decorative blocks and a compact storage of bone meal."),
	tiles = {"mcl_core_bone_block_top.png", "mcl_core_bone_block_top.png", "mcl_core_bone_block_side.png"},
	is_ground_content = false,
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = {pickaxey = 1, building_block = 1, material_stone = 1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_3way,
	_mcl_hardness = 2,
	_mcl_crafting_output = {single = {output = "mcl_bone_meal:bone_meal 9"}}
})

core.register_node("mcl_core:slimeblock", {
	description = S("Slime Block"),
	_doc_items_longdesc = S("Slime blocks are very bouncy and prevent fall damage."),
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		}
	},
	selection_box = {
		type = "regular",
	},
	tiles = {"mcl_core_slime.png"},
	use_texture_alpha = "blend",
	-- According to Minecraft Wiki, bouncing off a slime block from a height off 255 blocks should result in a bounce height of 50 blocks
	-- bouncy=44 makes the player bounce up to 49.6. This value was chosen by experiment.
	-- bouncy=80 was chosen because it is higher than 66 (bounciness of bed)
	groups = {dig_immediate = 3, bouncy = 80, fall_damage_add_percent = -100, deco_block = 1, pathfinder_partial = 2, redstone_conductive = 1,},
	sounds = {
		dug = {name = "slimenodes_dug", gain = 0.6},
		place = {name = "slimenodes_place", gain = 0.6},
		footstep = {name = "slimenodes_step", gain = 0.3},
	},
	_mcl_hardness = 0,
	_mcl_pistons_sticky = function(node, node_to, direction)
		return node_to.name ~= "mcl_honey:honey_block"
	end,
	_mcl_crafting_output = {single = {output = "mcl_mobitems:slimeball 9"}}
})

core.register_node("mcl_core:cobweb", {
	description = S("Cobweb"),
	_tt_help = S("Slows down movement"),
	_doc_items_longdesc = S("Cobwebs can be walked through, but significantly slow you down."),
	drawtype = "plantlike",
	paramtype2 = "degrotate",
	visual_scale = 1.1,
	tiles = {"mcl_core_web.png"},
	inventory_image = "mcl_core_web.png",
	paramtype = "light",
	move_resistance = 14,
	walkable = false,
	groups = {swordy_cobweb = 1, shearsy_cobweb = 1, fake_liquid = 1, disable_jump = 1, deco_block = 1, dig_by_piston = 1,
		dig_by_water = 1, destroy_by_lava_flow = 1, unsticky = 1},
	drop = "mcl_mobitems:string",
	_mcl_shears_drop = true,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_hardness = 4,
})


core.register_node("mcl_core:deadbush", {
	description = S("Dead Bush"),
	_doc_items_longdesc = S("Dead bushes are unremarkable plants often found in dry areas. They can be harvested for sticks."),
	_doc_items_hidden = false,
	drawtype = "plantlike",
	waving = 1,
	tiles = {"default_dry_shrub.png"},
	inventory_image = "default_dry_shrub.png",
	wield_image = "default_dry_shrub.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {handy = 1, shearsy = 1, flammable = 3, attached_node = 1, plant = 1, non_mycelium_plant = 1, dig_by_piston = 1,
	    dig_by_water = 1, destroy_by_lava_flow = 1, deco_block = 1, fire_encouragement = 60, fire_flammability = 100, unsticky = 1},
	drop = {
		max_items = 1,
		items = {
			{
				items = {"mcl_core:stick 2"},
				rarity = 3,
			},
			{
				items = {"mcl_core:stick 1"},
				rarity = 2,
			},
		}
	},
	_mcl_shears_drop = true,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-5 / 16, -8 / 16, -5 / 16, 5 / 16, 1 / 16, 5 / 16},
	},
	_mcl_hardness = 0,
	_mcl_burntime = 5
})

mcl_flowerpots.register_potted_flower("mcl_core:deadbush", {
	name = "deadbush",
	desc = S("Dead Bush"),
	image = "default_dry_shrub.png",
})

------------------------------------------------------------------------
-- Technical blocks.
------------------------------------------------------------------------

core.register_node("mcl_core:barrier", {
	description = S("Barrier"),
	_doc_items_longdesc = S("Barriers are invisible walkable blocks. They are used to create boundaries of adventure maps and the like. Monsters and animals won't appear on barriers, and fences do not connect to barriers. Other blocks can be built on barriers like on any other block."),
	_doc_items_usagehelp = S("When you hold a barrier in hand, you reveal all placed barriers in a short distance around you."),
	drawtype = "airlike",
	paramtype = "light",
	inventory_image = "mcl_core_barrier.png",
	wield_image = "mcl_core_barrier.png",
	tiles = {"blank.png"},
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {creative_breakable = 1, not_in_creative_inventory = 1, not_solid = 1, unmovable_by_piston = 1, rarity = 3},
	on_blast = function() end,
	drop = "",
	_mcl_blast_resistance = 36000008,
	_mcl_hardness = -1,
	after_place_node = function(pos, placer)
		if placer == nil then
			return
		end
		core.add_particle({
			pos = pos,
			expirationtime = 1,
			size = 8,
			texture = "mcl_core_barrier.png",
			glow = 14,
			playername = placer:get_player_name()
		})
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
			return itemstack
		end

		-- Use pointed node's on_rightclick function first, if present
		local new_stack = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if new_stack then
			return new_stack
		end

		local name = placer:get_player_name()
		local privs = core.get_player_privs(name)
		if not privs.maphack then
			core.chat_send_player(name, "Placement denied. You need the “maphack” privilege to place barriers.")
			return itemstack
		end
		local new_itemstack = core.item_place_node(itemstack, placer, pointed_thing)
		return new_itemstack
	end,
})

-- Same as barrier, but non-pointable. This node is only to be used internally to separate realms.
-- It must NOT be used for anything else.
-- This node only exists because Minetest does not have support for “dimensions” yet and needs to
-- be removed when support for this is implemented.
core.register_node("mcl_core:realm_barrier", {
	description = S("Realm Barrier"),
	_doc_items_create_entry = false,
	drawtype = "airlike",
	paramtype = "light",
	inventory_image = "mcl_core_barrier.png^[colorize:#FF00FF:127^[transformFX",
	wield_image = "mcl_core_barrier.png^[colorize:#FF00FF:127^[transformFX",
	tiles = {"blank.png"},
	-- To avoid players getting stuck forever between realms
	damage_per_second = 8,
	sunlight_propagates = true,
	is_ground_content = false,
	pointable = false,
	groups = {not_in_creative_inventory = 1, not_solid = 1, unmovable_by_piston = 1, rarity = 3},
	on_blast = function() end,
	drop = "",
	_mcl_blast_resistance = 36000008,
	_mcl_hardness = -1,
	-- Prevent placement to protect player from screwing up the world, because the node is not pointable and hard to get rid of.
	node_placement_prediction = "",
	on_place = function(_, placer, _)
		if placer then
			core.chat_send_player(placer:get_player_name(),
				core.colorize(mcl_colors.RED, "You can't just place a realm barrier by hand!"))
		end
	end,
})


--- Light blocks

local light_block_pattern = "^mcl_core:light_(%d+)$"

for i = 0, 14 do --core.LIGHT_MAX
	core.register_node("mcl_core:light_" .. i, {
		description = S("Light"),
		_doc_items_longdesc = S("Lights are invisible blocks. They are used to light up adventure maps and the like."),
		_doc_items_usagehelp = S("When you hold a light in hand, you reveal all placed lights in a short distance around you."),
		drawtype = "airlike",
		paramtype = "light",
		pointable = false,
		pointabilities = { nodes = { ["group:light_block"] = true } },
		walkable = false,
		light_source = i,
		drop = "",
		buildable_to = true,
		node_placement_prediction = "",
		inventory_image = "mcl_core_light_" .. i .. ".png",
		wield_image = "mcl_core_light_" .. i .. ".png",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {creative_breakable = 1, not_solid = 1, light_block = i + 1, rarity = 3},
		on_blast = function() end,
		on_use = function(itemstack, user, pointed_thing)
			-- user:get_player_control() returns {} for non players, so we don't need user:is_player()
			if pointed_thing.type == "node" and string.match(core.get_node(pointed_thing.under).name, light_block_pattern) and not user:get_player_control().sneak then
				core.dig_node(pointed_thing.under)
				return
			end
			itemstack:set_name("mcl_core:light_" .. ((i == 14) and 0 or i + 1))
			return itemstack
		end,
		on_place = mcl_util.bypass_buildable_to(function(node_name)
			return string.match(node_name, light_block_pattern)
		end),
		after_place_node = function(pos, placer)
			if not placer then
				return
			end
			core.add_particle({
				pos = pos,
				expirationtime = 1,
				size = 8,
				texture = "mcl_core_light_" .. i .. ".png",
				glow = 14,
				playername = placer:get_player_name()
			})
		end,
		_mcl_blast_resistance = 36000008,
		_mcl_hardness = -1,
	})
end




-- The void below the bedrock. Void damage is handled in mcl_playerplus.
-- The void does not exist as a block in Minecraft but we register it as a
-- block here to make things easier for us.
core.register_node("mcl_core:void", {
	description = S("Void"),
	_doc_items_create_entry = false,
	drawtype = "airlike",
	paramtype = "light",
	pointable = false,
	walkable = false,
	inventory_image = "mcl_core_void.png",
	wield_image = "mcl_core_void.png",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {not_in_creative_inventory = 1, unmovable_by_piston = 1},
	on_blast = function() end,
	-- Prevent placement to protect player from screwing up the world, because the node is not pointable and hard to get rid of.
	node_placement_prediction = "",
	on_place = function(_, placer, _)
		if placer then
			core.chat_send_player(placer:get_player_name(),
				core.colorize(mcl_colors.RED, "You can't just place the void by hand!"))
		end
	end,
	drop = "",
	-- Infinite blast resistance; it should never be destroyed by explosions
	_mcl_hardness = -1,
})
