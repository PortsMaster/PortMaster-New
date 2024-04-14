# mcl_death_drop
Drop registered inventories on player death.

## mcl_death_drop.register_dropped_list(inv, listname, drop)
* inv: can be:
    * "PLAYER": will be interpreted like player inventory (to avoid multiple calling to get_inventory())
    * function(player): must return inventory
* listname: string
* drop: bool
    * true: the list will be dropped
    * false: the list will only be cleared

## mcl_death_drop.registered_dropped_lists
Table containing dropped list inventory, name and drop state.