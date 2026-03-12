## Potions and Effects API

<!-- TOC -->
* [Potions and Effects API](#potions-and-effects-api)
    * [Namespace](#namespace)
    * [Effects](#effects)
        * [Functions](#functions)
        * [Deprecated Functions](#deprecated-functions)
        * [Tables](#tables)
        * [Internally registered effects](#internally-registered-effects)
        * [Constants](#constants)
        * [Effect Definition](#effect-definition)
    * [HP Hudbar Modifiers](#hp-hudbar-modifiers)
        * [Functions](#functions)
        * [HP Hudbar Modifier Definition](#hp-hudbar-modifier-definition)
    * [Potions](#potions)
        * [Functions](#functions)
        * [Tables](#tables)
        * [Internally registered potions](#internally-registered-potions)
        * [Constants](#constants)
        * [Potion Definition](#potion-definition)
    * [Brewing](#brewing)
        * [Functions](#functions)
    * [Miscellaneous Functions](#miscellaneous-functions)
<!-- TOC -->

### Namespace
All of the API is defined in the `mcl_potions` namespace.

### Effects
This section describes parts of the API related to defining and managing effects on players and entities. The mod defines a bunch of effects internally using the same API as described below.

#### Functions
`mcl_potions.register_effect(def)` – takes an effect definition (`def`) and registers an effect if the definition is valid, and adds the known parts of the definition as well as the outcomes of processing of some parts of the definition to the `mcl_potions.registered_effects` table. This should only be used at load time.


`mcl_potions.has_effect(object, effect_name)` – returns `true` if `object` (described by an ObjectRef) has the effect of the ID `effect_name`, `false` otherwise.


`mcl_potions.get_effect(object, effect_name)` - returns a table containing values of the effect of the ID `effect_name` on the `object` if the object has the named effect, `false` otherwise.


`mcl_potions.get_effect_level(object, effect_name)` – returns the level of the effect of the ID `effect_name` on the `object`. If the effect has no levels, returns `1`. If the object doesn't have the effect, returns `0`. If the effect is not registered, returns `nil`.


`mcl_potions.clear_effect(object, effect)` – attempts to remove the effect of the ID `effect` from the `object`. If the effect is not registered, logs a warning and returns `false`. Otherwise, returns `nil`.


`mcl_potions.make_invisible(obj_ref, hide)` – makes the object going by the `obj_ref` invisible if `hide` is true, visible otherwise.


`mcl_potions.register_generic_resistance_predicate(predicate)` – registers an arbitrary effect resistance predicate. This can be used e.g. to make some entity resistant to all (or some) effects under specific conditions.

* `predicate` – `function(object, effect_name)` - return `true` if `object` resists effect of the ID `effect_name`


`mcl_potions.give_effect_by_level(name, object, level, duration, no_particles)` – attempts to give effect of the ID `name` to the `object` with the provided `level` and `duration`. If `no_particles` is `true`, no particles will be emitted from the object when under the effect. This converts `level` to factor and calls `mcl_potions.give_effect()` internally, returning the return value of that function. `level` equal to `0` is no-op.


#### Tables
`mcl_potions.registered_effects` – contains all effects that have been registered. You can read from it various data about the effects. You can overwrite the data and alter the effects' definitions too, but this is discouraged, i.e. only do this if you really know what you are doing. You shouldn't add effects directly to this table, as this would skip important setup; instead use the `mcl_potions.register_effect()` function, which is described above.

#### Internally registered effects
You can't register effects going by these names, because they are already used:
* `invisibility`
* `poison`
* `regeneration`
* `strength`
* `weakness`
* `dolphin_grace`
* `leaping`
* `slow_falling`
* `swiftness`
* `slowness`
* `levitation`
* `night_vision`
* `darkness`
* `glowing`
* `health_boost`
* `absorption`
* `fire_resistance`
* `resistance`
* `luck`
* `bad_luck`
* `bad_omen`
* `hero_of_village`
* `withering`
* `frost`
* `blindness`
* `nausea`
* `hunger`
* `saturation`
* `haste`
* `fatigue`
* `conduit_power`

#### Effect Definition
```lua
def = {
-- required parameters in def:
    name = string -- effect name in code (unique ID) - can't be one of the reserved words ("list", "heal", "remove", "clear")
    description = S(string) -- actual effect name in game
-- optional parameters in def:
    get_tt = function(factor) -- returns tooltip description text for use with potions
    icon = string -- file name of the effect icon in HUD - defaults to one based on name
    res_condition = function(object) -- returning true if target is to be resistant to the effect
    on_start = function(object, factor) -- called when dealing the effect
	on_reject = function(object, factor) -- called when give_effect refuses to deal an effect of a lower level than already exists
    on_load = function(object, factor) -- called on_joinplayer and on_activate
    on_step = function(dtime, object, factor, duration) -- running every step for all objects with this effect
    on_hit_timer = function(object, factor, duration) -- if defined runs a hit_timer depending on timer_uses_factor value
    on_end = function(object) -- called when the effect wears off
    after_end = function(object) -- called when the effect wears off, after purging the data of the effect
    on_save_effect = function(object -- called when the effect is to be serialized for saving (supposed to do cleanup)
    particle_color = string -- colorstring for particles - defaults to #3000EE
    uses_factor = bool -- whether factor affects the effect
    lvl1_factor = number -- factor for lvl1 effect - defaults to 1 if uses_factor
    lvl2_factor = number -- factor for lvl2 effect - defaults to 2 if uses_factor
    timer_uses_factor = bool -- whether hit_timer uses factor (uses_factor must be true) or a constant value (hit_timer_step must be defined)
    hit_timer_step = float -- interval between hit_timer hits
    damage_modifier = string -- damage flag of which damage is changed as defined by modifier_func, pass empty string for all damage
    dmg_mod_is_type = bool -- damage_modifier string is used as type instead of flag of damage, defaults to false
    modifier_func = function(damage, effect_vals) -- see damage_modifier, if not defined damage_modifier defaults to 100% resistance
    modifier_priority = integer -- priority passed when registering damage_modifier - defaults to -50
    affects_item_speed = table
-- -- if provided, effect gets added to the item_speed_effects table, this should be true if the effect affects item speeds,
-- -- otherwise it won't work properly with other such effects (like haste and fatigue)
-- -- -- factor_is_positive - bool - whether values of factor between 0 and 1 should be considered +factor% or speed multiplier
-- -- --   - obviously +factor% is positive and speed multiplier is negative interpretation
-- -- --   - values of factor higher than 1 will have a positive effect regardless
-- -- --   - values of factor lower than 0 will have a negative effect regardless
}
```

### HP Hudbar Modifiers
This part of the API allows complex modification of the HP hudbar. It is mainly required here, so it is defined here. It may be moved to a different mod in the future.

#### Functions
`mcl_potions.register_hp_hudbar_modifier(def)` – this function takes a modifier definition (`def`, described below) and registers a HP hudbar modifier if the definition is valid.

#### HP Hudbar Modifier Definition
```lua
def = {
-- required parameters in def:
    predicate = function(player) -- returns true if player fulfills the requirements (eg. has the effects) for the hudbar look
    icon = string -- name of the icon to which the modifier should change the HP hudbar heart
    priority = signed_int -- lower gets checked first, and first fulfilled predicate applies its modifier
}
```

### Potions
Magic!

#### Functions
`mcl_potions.register_potion(def)` – takes a potion definition (`def`) and registers a potion if the definition is valid, and adds the known parts of the definition as well as the outcomes of processing of some parts of the definition to the `mcl_potions.registered_effects` table. This, depending on some fields of the definition, may as well register the corresponding splash potion, lingering potion and tipped arrow. This should only be used at load time.

#### Potion Definition
```lua
def = {
-- required parameters in def:
    name = string, -- potion name in code
-- optional parameters in def:
    desc_prefix = S(string), -- part of visible potion name, comes before the word "Potion"
    desc_suffix = S(string), -- part of visible potion name, comes after the word "Potion"
    _tt = S(string), -- custom tooltip text
    _dynamic_tt = function(level), -- returns custom tooltip text dependent on potion level
    _longdesc = S(string), -- text for in=game documentation
    stack_max = int, -- max stack size -  defaults to 1
    image = string, -- name of a custom texture of the potion icon
    color = string, -- colorstring for potion icon when image is not defined
    groups = table, -- item groups definition for the regular potion, not splash or lingering -
--   - must contain _mcl_potion=1 for tooltip to include dynamic_tt and effects
--   - defaults to {brewitem=1, food=3, can_eat_when_full=1, _mcl_potion=1}
    nocreative = bool, -- adds a not_in_creative_inventory=1 group - defaults to false
    _effect_list = {, -- all the effects dealt by the potion in the format of tables
-- -- the name of each sub-table should be a name of a registered effect, and fields can be the following:
        uses_level = bool, -- whether the level of the potion affects the level of the effect -
-- -- --   - defaults to the uses_factor field of the effect definition
        level = int, -- used as the effect level if uses_level is false and for lvl1 potions - defaults to 1
        level_scaling = int, -- used as the number of effect levels added per potion level - defaults to 1 -
-- -- --   - this has no effect if uses_level is false
        dur = float, -- duration of the effect in seconds - defaults to mcl_potions.DURATION
        dur_variable = bool, -- whether variants of the potion should have the length of this effect changed -
-- -- --   - defaults to true
-- -- --   - if at least one effect has this set to true, the potion has a "plus" variant
    }
    uses_level = bool, -- whether the potion should come at different levels -
--   - defaults to true if uses_level is true for at least one effect, else false
    drinkable = bool, -- defaults to true
    has_splash = bool, -- defaults to true
    has_lingering = bool, -- defaults to true
    has_arrow = bool, -- defaults to false
    has_potent = bool, -- whether there is a potent (e.g. II) variant - defaults to the value of uses_level
    default_potent_level = int, -- potion level used for the default potent variant - defaults to 2
    default_extend_level = int, -- extention level (amount of +) used for the default extended variant - defaults to 1
    custom_on_use = function(user, level), -- called when the potion is drunk, returns true on success
    custom_effect = function(object, level, plus), -- called when the potion effects are applied, returns true on success
    custom_splash_effect = function(pos, level), -- called when the splash potion explodes, returns true on success
    custom_linger_effect = function(pos, radius, level), -- called on the lingering potion step, returns true on success
}
```

### Brewing
Functions supporting brewing potions, used by the `mcl_brewing` module.

#### Functions
`mcl_potions.register_ingredient_potion(input, out_table)` – registers a potion (`input`, item string) that can be combined with multiple ingredients for different outcomes; `out_table` contains the recipes for those outcomes

`mcl_potions.register_water_brew(ingr, potion)` – registers a `potion` (item string) brewed from water with a specific ingredient (`ingr`)

`mcl_potions.register_awkward_brew(ingr, potion)` – registers a `potion` (item string) brewed from an awkward potion with a specific ingredient (`ingr`)

`mcl_potions.register_mundane_brew(ingr, potion)` – registers a `potion` (item string) brewed from a mundane potion with a specific ingredient (`ingr`)

`mcl_potions.register_thick_brew(ingr, potion)` – registers a `potion` (item string) brewed from a thick potion with a specific ingredient (`ingr`)

`mcl_potions.register_table_modifier(ingr, modifier)` – registers a brewing recipe altering the potion using a table; this is supposed to substitute one item with another

`mcl_potions.register_inversion_recipe(input, output)` – what it says

`mcl_potions.register_meta_modifier(ingr, mod_func)` – registers a brewing recipe altering the potion using a function; this is supposed to be a recipe that changes metadata only
