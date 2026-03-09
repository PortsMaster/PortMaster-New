# API information (WIP)
This API information is not complete yet.
The mod API is still pretty much unofficial; this mod is mostly seen
as standalone for now.

This may change in the future development of Mineclonia. Hopefully.

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

### `mcl_hunger.is_player_full(player)`
Check whether the player is full (has 20 or more hunger points)

### `mcl_hunger.prevent_eating(player)`
Prevents the player from eating until he stops holding rightclick.
The use case is when you want to do something when the player is rightclicking a node with food.
You'd need to call this function, otherwise they would just eat the food

### `mcl_hunger.exhaust(player, exhaust)`
Increase exhaustion of player by `exhaust`.

### More functions ...
There are more functions (of less importance) available, see `api.lua`.

## Groups
Items in group `food=3` will make a drinking sound and no particles.
Items in group `food` with any other rating will make an eating sound and particles,
based on the inventory image or wield image (whatever is available first).

## Suppressing food particles
Normally, all food items considered (except drinks) make food particles.
You can suppress the food particles by adding the field
`_mcl_spawn_food_particles=false` to the item definition.

## Eat animation
In addition of eating animation there is also new changes on how foods are defined

Food item must have `food` and `eatable` groups, the `eatable` value is treated as
the hunger change (e.g. `eatable=3` is the same as `core.item_eat(3)`).

You no longer need to add `core.item_eat(n)` explicitly to `on_secondary_use` or `on_place`.

There also few custom property used:
```lua
{
    -- Add status effect or any behavior when item consumed, optional
    _mcl_eat_effect = function (itemstack, player, pointed_thing) ... end,

    -- Replace consumed item, optional (e.g. _mcl_eat_replace_with = "mcl_core:bowl")
    _mcl_eat_replace_with = nil,

    -- Custom eat animation duration, optional
    _mcl_eat_delay = nil,
}
```
