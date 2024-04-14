# API documentation for dispensers

The dispensers API allows you to add custom code which is called when a
particular item is dispensed.
Just add the `_on_dispense` function to the item definition.
By default, items are just thrown out as item entities.

## Additional fields for item definitions

### `_on_dispense(stack, pos, droppos, dropnode, dropdir)`

This is a function which is called when an item is dispensed by the dispenser.
These are the parameters:

* stack: Itemstack which is dispense. This is always exactly 1 item
* pos: Position of dispenser
* droppos: Position to which to dispense item
* dropnode: Node of droppos
* dropdir: Drop direction

By default (return value: `nil`), the itemstack is consumed by the dispenser afterwards.
Optionally, you can explicitly set the return value to a custom leftover itemstack.

### `_dispense_into_walkable`

By default, items will only be dispensed into non-walkable nodes.
But if this value is set If `true`, the item can be dispensed into walkable nodes.

### `entity._on_dispense(self, dropitem, pos, droppos, dropnode, dropdir)`

This is a function which is called when an item is dropped out of the dispenser
on an entity. Should return leftover itemstack.

Call mcl_mobs.mob_class._on_dispense to call the original _on_dispense function
for mobs e.g. to feed them.
