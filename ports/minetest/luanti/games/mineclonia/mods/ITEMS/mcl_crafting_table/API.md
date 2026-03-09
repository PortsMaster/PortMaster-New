# `mcl_crafting_table`

Add a node which allow players to craft more complex things.


## `mcl_crafting_table.show_crafting_form(player)`

Show the crafting form to a player.

This uses `mcl_crafting_table.has_crafting_table(player)` (see below) to check
for the presence of a crafting table within player's reach. To enable showing
the crafting form without an actual crafting table node in range, that function
needs to be amended.


## `mcl_crafting_table.has_crafting_table(player)`

Returns `true` if a crafting table (node of `group:crafting_table`) is found
within the player's reach.

This function may be overwritten to facilitate custom behavior. Note that
whenever this function returns `true` opening the crafting form from the
crafting guide is enabled, too.