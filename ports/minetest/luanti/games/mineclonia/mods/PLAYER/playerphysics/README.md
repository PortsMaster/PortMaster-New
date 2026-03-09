# Player Physics API

Version: 1.1.0

This mod makes it possible for multiple mods to modify player physics (speed, jumping strength, gravity) without conflict.

## Introduction
### For players
Mods and games in Minetest can set physical attributes of players, such as speed and jump strength. For example, player speed could be set to 200%. But the way this works makes it difficult for multiple mods to *modify* physical attributes without leading to conflicts, problems and hilarious bugs, like speed that changes often to nonsense values.

The Player Physics API aims to resolve this conflict by providing a “common ground” for mods to work together in this regard.

This mod does nothing on its own, you will only need to install it as dependency of other mods.

When you browse for mods that somehow mess with player physics (namely: speed, jump strength or gravity) and want to use more than one of them, check out if they support the Player Physics API. If they don't, it's very likely these mods will break as soon you activate more than one of them, for example, if two mods try to set the player speed. If you found such a “hilarious bug”, please report it to the developers of the mods (or games) and point them to the Player Physics API.

Of course, not all mods need the Player Physics API. Mods that don't touch player physics at all won't need this mod.

The rest of this document is directed at developers.

### For developers
The function `set_physics_override` from the Minetest Lua API allows mod authors to override physical attributes of players, such as speed or jump strength.

This function works fine as long there is only one mod that sets a particular physical attribute at a time. However, as soon as at least two different mods (that do not know each other) try to change the same player physics attribute using only this function, there will be conflicts as each mod will undo the change of the other mod, as the function sets a raw value. A classic race condition occurs. This is the case because the mods fail to communicate with each other.

This mod solves the problem of conflicts. It bans the concept of “setting the raw value directly” and replaces it with the concept of factors that mods can add and remove for each attribute. The real physical player attribute will be the product of all active factors.

See `API.md` for the API documentation.

## License
This mod is free software, released under the MIT License.
