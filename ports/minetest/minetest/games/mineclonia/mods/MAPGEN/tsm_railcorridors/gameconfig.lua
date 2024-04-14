-- This file stores the various node types. This makes it easier to plug this mod into games
-- in which you need to change the node names.

-- Adapted for MineClone 2!

-- Node names (Don't use aliases!)
tsm_railcorridors.nodes = {
	dirt = "mcl_core:dirt",
	chest = "mcl_chests:chest",
	rail = "mcl_minecarts:rail",
	torch_floor = "mcl_torches:torch",
	torch_wall = "mcl_torches:torch_wall",
	cobweb = "mcl_core:cobweb",
	spawner = "mcl_mobspawners:spawner",
}

-- This generates dark oak wood in mesa biomes and oak wood everywhere else.
function tsm_railcorridors.nodes.corridor_woods_function(pos, node)
	if minetest.get_item_group(node.name, "hardened_clay") ~= 0 then
		return "mcl_trees:wood_dark_oak", "mcl_fences:dark_oak_fence"
	else
		return "mcl_trees:wood_oak", "mcl_fences:oak_fence"
	end
end

tsm_railcorridors.carts = { "mcl_minecarts:chest_minecart" }

function tsm_railcorridors.on_construct_cart(pos, cart, pr_carts)
	local l = cart:get_luaentity()
	local inv = mcl_entity_invs.load_inv(l,27)
	local items = tsm_railcorridors.get_treasures(pr_carts)
	mcl_loot.fill_inventory(inv, "main", items, pr_carts)
	mcl_entity_invs.save_inv(l)
end

-- Fallback function. Returns a random treasure. This function is called for chests
-- only if the Treasurer mod is not found.
-- pr: A PseudoRandom object
function tsm_railcorridors.get_default_treasure(pr)
	-- UNUSED IN MINECLONE 2!
end

-- All spawners spawn cave spiders
function tsm_railcorridors.on_construct_spawner(pos)
	mcl_mobspawners.setup_spawner(pos, "mobs_mc:cave_spider", 0, 7)
end

-- MineClone 2's treasure function. Gets all treasures for a single chest.
-- Based on information from Minecraft Wiki.
function tsm_railcorridors.get_treasures(pr)
	local loottable = {
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "mcl_mobitems:nametag", weight = 30 },
			{ itemstring = "mcl_core:apple_gold", weight = 20 },
			{ itemstring = "mcl_books:book", weight = 10, func = function(stack, pr)
				mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
			end },
			{ itemstring = "", weight = 5},
			{ itemstring = "mcl_core:pick_iron", weight = 5 },
			{ itemstring = "mcl_core:apple_gold_enchanted", weight = 1 },
		}
	},
	{
		stacks_min = 2,
		stacks_max = 4,
		items = {
			{ itemstring = "mcl_farming:bread", weight = 15, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_core:coal_lump", weight = 10, amount_min = 3, amount_max = 8 },
			{ itemstring = "mcl_farming:beetroot_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_farming:melon_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_farming:pumpkin_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_core:iron_ingot", weight = 10, amount_min = 1, amount_max = 5 },
			{ itemstring = "mcl_core:lapis", weight = 5, amount_min = 4, amount_max = 9 },
			{ itemstring = "mesecons:redstone", weight = 5, amount_min = 4, amount_max = 9 },
			{ itemstring = "mcl_core:gold_ingot", weight = 5, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_core:diamond", weight = 3, amount_min = 1, amount_max = 2 },
		}
	},
	{
		stacks_min = 3,
		stacks_max = 3,
		items = {
			{ itemstring = "mcl_minecarts:rail", weight = 20, amount_min = 4, amount_max = 8 },
			{ itemstring = "mcl_torches:torch", weight = 15, amount_min = 1, amount_max = 16 },
			{ itemstring = "mcl_minecarts:activator_rail", weight = 5, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_minecarts:detector_rail", weight = 5, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_minecarts:golden_rail", weight = 5, amount_min = 1, amount_max = 4 },
		}
	},
	-- non-MC loot: 50% chance to add a minecart, offered as alternative to spawning minecarts on rails.
	-- TODO: Remove this when minecarts spawn on rails.
	{
		stacks_min = 0,
		stacks_max = 1,
		items = {
			{ itemstring = "mcl_minecarts:minecart", weight = 1 },
		}
	}
	}

	local items = mcl_loot.get_multi_loot(loottable, pr)

	return items
end
