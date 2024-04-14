# MineClone 2 Campfire API
## `mcl_campfires.register_campfire`
Used to register campfires.

**Example Usage**
```
mcl_campfires.register_campfire("mcl_campfires:campfire", {
	description = S("Campfire"),
	inv_texture = "mcl_campfires_campfire_inv.png",
	fire_texture = "mcl_campfires_campfire_fire.png",
	lit_logs_texture = "mcl_campfires_campfire_log_lit.png",
	drops = "mcl_core:charcoal_lump 2",
	lightlevel = 14,
	damage = 1,
})
```
**Values**
* description - human readable node name.
* inv_texture - campfire inventory texture.
* fire_texture - texture of the campfire fire.
* lit_logs_texture - texture for the logs of the lit campfire. if not changed, specify mcl_campfires_log.png.
* drops - what items drop when the campfire is mined.
* lightlevel - the level of light the campfire emits.
* damage - amount of damage the campfire deals when the player stands on it.

## Cooking Items
To allow an item to be cooked on the campfire, it must first have a registered cooked variant. To allow placing the item on the campfire to be cooked, add `campfire_cookable = 1` into the item groups list.
