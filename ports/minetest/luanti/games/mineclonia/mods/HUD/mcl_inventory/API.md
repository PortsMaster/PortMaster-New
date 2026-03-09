# `mcl_inventory`

## `mcl_inventory.to_craft_grid(player, craft)`
Puts the specified craft on the players crafting grid from player's inventory. The supported recipes are limited by the current width of the player's `craft` inventory (3 when using a crafting table, 2 when using the inventory)

## `mcl_inventory.fill_grid(player)`
Maximizes all itemstacks on the crafting grid grom the player's inventory equally for bulk crafting.

## `mcl_inventory.show_inventory(player)`

## `mcl_inventory.register_survival_inventory_tab(def)`

```lua
mcl_inventory.register_survival_inventory_tab({
	-- Page identifier
	-- Used to uniquely identify the tab
	id = "test",

	-- The tab description, can be translated
	description = "Test",

	-- The name of the item that will be used as icon
	item_icon = "mcl_core:stone",

	-- If true, the main inventory will be shown at the bottom of the tab
	-- Listrings need to be added by hand
	show_inventory = true,

	-- This function must return the tab's formspec for the player
	build = function(player)
		return "label[1,1;Hello hello]button[2,2;2,2;Hello;hey]"
	end,

	-- This function will be called in the on_player_receive_fields callback if the tab is currently open
	handle = function(player, fields)
		print(dump(fields))
	end,

	-- This function will be called to know if a player can see the tab
	-- Returns true by default
	access = function(player)
	end,
})
```

## Virtual items

Virtual items are variants of already existing items that should be treated as completely different by the game.
Currently this only means that they show up in creative inventory as seperate items. A great exampe of this is 
`mcl_enchanting_book_enchanted` item, Which has different enchantments stored in metadata, and is listed in the creative
inventory as seperate items.

To add virtual items to an item. You have to define `_get_all_virtual_items` function in the item's definition.
The function takes no argument and should return a table with following format:

```lua
{
    "brew" =
    {
        -- virtual items which will show up in the "brew" category of creative inventory
        itemstring,
        itemstring,
        itemstring,
        itemstring,
    }
    "deco" =
    {
        -- virtual items which will show up in the "deco" category of creative inventory
        itemstring,
        itemstring,
        itemstring,
        itemstring,
    }
}
```

Note that `_get_all_virtual_items` functions will be executed once after all mods have been loaded and before the server starts, meaning that

* the dynamic translation pattern can be used in a `_get_all_virtual_items` function
* adding or overriding a `_get_all_virtual_items` function in a `register_on_mods_loaded` handler won't work reliably
