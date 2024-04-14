Screwdriver API
---------------

The screwdriver API allows you to control a node's behaviour when a screwdriver is used on it.
NOTE: This API is compatible with Minetest Game 5.1.0, but has some extensions.

To use it, add the `on_rotate` function to the node definition.

`on_rotate(pos, node, user, mode, new_param2)`

 * `pos`: Position of the node that the screwdriver is being used on
 * `node`: that node
 * `user`: The player who used the screwdriver
 * `mode`: `screwdriver.ROTATE_FACE` or `screwdriver.ROTATE_AXIS`
 * `new_param2` the new value of `param2` that would have been set if `on_rotate` wasn't there
 * return value: false to disallow rotation, nil to keep default behaviour, true to allow
 	it but to indicate that changed have already been made (so the screwdriver will wear out)
 * use `on_rotate = false` to always disallow rotation
 * use `on_rotate = screwdriver.rotate_simple` to allow only face rotation
 * use `on_rotate = screwdriver.rotate_3way` (MineClone 2 extension) for pillar-like nodes that should only have 3 possible orientations)



`after_rotate(pos)` (MineClone 2 extension)

Called after the rotation has been completed

 * `pos`: Position of the node that the screwdriver was used on
