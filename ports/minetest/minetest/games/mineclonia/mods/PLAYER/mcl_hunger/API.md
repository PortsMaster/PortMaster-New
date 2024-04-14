# API information (WIP)
This API information is not complete yet.
The mod API is still pretty much unofficial; this mod is mostly seen
as standalone for now.

This may change in the future development of MineClone 2. Hopefully.

## Mod state
The hunger mechanic is disabled when damage is disabled
(setting `enable_damage=false`).
You can check the hunger state with `mcl_hunger.active`. If it's true,
then hunger is active.

If the hunger is disabled, most of the functions are no-ops or return
default values.

## Player values
### Hunger level
The hunger level of the player is a whole number between 0 and 20 inclusive.
0 is starving and 20 is full. The hunger level is represented in
the HUD by a statbar with 20 half-icons.

### Saturation
To be written ...

### Exhaustion
To be written ...

## Functions
This API documentation is not complete yet, more documentation will
come.

### `mcl_hunger.get_hunger(player)`
Returns the current hunger level of `player` (ObjectRef).

### `mcl_hunger.set_hunger(player, hunger)`
Sets the hunger level of `player` (ObjectRef) to `hunger` immediately.
`hunger` ***must*** be between 0 and 20 inclusive.

### `mcl_hunger.exhaust(player, exhaust)`
Increase exhaustion of player by `exhaust`.

### `mcl_hunger.stop_poison(player)`
Immediately stops food poisoning for player.

### More functions ...
There are more functions (of less importance) available, see `api.lua`.

## Groups
Items in group `food=3` will make a drinking sound and no particles.
Items in group `food` with any other rating will make an eating sound and particles,
based on the inventory image or wield image (whatever is available first).

## Suppressing food particles
Normally, all food items considered food (not drinks) make food particles.
You can suppress the food particles by adding the field
`_food_particles=false` to the item definition.
