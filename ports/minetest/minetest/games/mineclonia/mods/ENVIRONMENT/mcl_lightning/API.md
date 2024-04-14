# lightning
Lightning mod for MineClone2 with the following API:

## lightning.register_on_strike(function(pos, pos2, objects))
Custom function called when a lightning strikes.

* `pos`: impact position
* `pos2`: rounded node position where fire is placed
* `objects`: table with ObjectRefs of all objects within a radius of 3.5 around pos2

## lightning.strike(pos)
Let a lightning strike.

* `pos`: optional, if not given a random pos will be chosen
* `returns`: bool - success if a strike happened


### Examples:

```
lightning.register_on_strike(function(pos, pos2, objects)
        for _, obj in pairs(objects) do
                obj:remove()
        end
        minetest.add_entity(pos, "mobs_mc:sheep")
end)

minetest.register_on_respawnplayer(function(player)
        lightning.strike(player:get_pos())
end)
```
