# Player Physics API Documentation
This document explains how to use the Player Physics API as a developer.

## Quick start
Let's say you have a mod `example` and want to double the speed of the player (i.e. multiply it by a factor of 2), but you also don't want to break other mods that might touch the speed.

Previously, you might have written something like this:

`player:set_physics_override({speed=2})`

However, your mod broke down as soon the mod `example2` came along, which wanted to increase the speed by 50%. In the real game, the player speed randomly switched from 50% and 200% which was a very annoying bug.

In your `example` mod, you can replace the code with this:

`playerphysics.add_physics_factor(player, "speed", "my_double_speed", 2)`

Where `"my_double_speed` is an unique ID for your speed factor.

Now your `example` mod is interoperable! And now, of course, the `example2` mod has to be updated in a similar fashion.

## Precondition
There is only one precondition to using this mod, but it is important:

Mods *MUST NOT* call `set_physics_override` directly for numerical values. Instead, to modify player physics, all mods that touch player physics have to use this API.




## Functions
### `playerphysics.add_physics_factor(player, attribute, id, value)`
Adds a factor for a player physic and updates the player physics immediately.

#### Parameters
* `player`: Player object
* `attribute`: Which of the physical attributes to change. Any of the numeric values of `set_physics_override` (e.g. `"speed"`, `"jump"`, `"gravity"`)
* `id`: Unique identifier for this factor. Identifiers are stored on a per-player per-attribute type basis
* `value`: The factor to add to the list of products

If a factor for the same player, attribute and `id` already existed, it will be overwritten.



### `playerphysics.remove_physics_factor(player, attribute, id)`
Removes the physics factor of the given ID and updates the player's physics.

#### Parameters
Same as in `playerphysics.add_physics_factor`, except there is no `value` argument.



### `playerphysics.get_physics_factor(player, attribute, id)`
Returns the current physics factor of the given ID, if it exists.
If the ID exists, returns a number. If it does not exist, returns nil.

Note a missing physics factor is mathematically equivalent to a factor of 1.

#### Parameters
Same as in `playerphysics.add_physics_factor`, except there is no `value` argument.



## Examples
### Speed changes
Let's assume this mod is used by 3 different mods all trying to change the speed:
Potions, Exhaustion and Electrocution.
Here's what it could look like:

Potions mod:
```
playerphysics.add_physics_factor(player, "speed", "run_potion", 2)
```

Exhaustion mod:
```
playerphysics.add_physics_factor(player, "jump", "exhausted", 0.75)
```

Electrocution mod:
```
playerphysics.add_physics_factor(player, "jump", "shocked", 0.9)
```

When the 3 mods have done their change, the real player speed is simply the product of all factors, that is:

2 * 0.75 * 0.9 = 1.35

The final player speed is thus 135%.

### Speed changes, part 2

Let's take the example above.
Now if the Electrocution mod is done with shocking the player, it just needs to call:

```
playerphysics.remove_physics_factor(player, "jump", "shocked")
```

The effect is now gone, so the new player speed will be:

2 * 0.75 = 1.5

### Sleeping
To simulate sleeping by preventing all player movement, this can be done with this easy trick:

```
playerphysics.add_physics_factor(player, "speed", "sleeping", 0)
playerphysics.add_physics_factor(player, "jump", "sleeping", 0)
```

This works regardless of the other factors because 0 times anything equals 0.
