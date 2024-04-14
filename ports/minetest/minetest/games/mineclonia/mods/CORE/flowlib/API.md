# flowlib
Simple flow functions.

## flowlib.is_touching(realpos, nodepos, radius)
Return true if a sphere of <radius> at <realpos> collide with node at <nodepos>.
* realpos: position
* nodepos: position
* radius: number

## flowlib.is_water(pos)
Return true if node at <pos> is water, false overwise.
* pos: position

## flowlib.node_is_water(node)
Return true if <node> is water, false overwise.
* node: node

## flowlib.is_lava(pos)
Return true if node at <pos> is lava, false overwise.
* pos: position

## flowlib.node_is_lava(node)
Return true if <node> is lava, false overwise.
* node: node

## flowlib.is_liquid(pos)
Return true if node at <pos> is liquid, false overwise.
* pos: position

## flowlib.node_is_liquid(node)
Return true if <node> is liquid, false overwise.
* node: node

## flowlib.quick_flow(pos, node)
Return direction where the water is flowing (to be use to push mobs, items...).
* pos: position
* node: node

## flowlib.move_centre(pos, realpos, node, radius)
Return the pos of the nearest not water block near from <pos> in a sphere of <radius> at <realpos>.
WARNING: This function is never used in mcl2, use at your own risk. The informations described here may be wrong.
* pos: position
* realpos: position, position of the entity
* node: node
* radius: number