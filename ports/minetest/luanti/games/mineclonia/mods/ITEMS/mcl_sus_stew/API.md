# API for `mcl_sus_stew`

Register your own sus stews!

# Groups

## sus_stew_ingredient

Items that can be used as an ingredient for a suspicious stew must have this
group set in their item definition.

# Functions

## mcl_sus_stew.register_sus_stew(ingredient, effect, duration)

Registers a suspicious stew.

* ingredient: will be used as 4th recipe ingredient.
* effect: must be an effect registered with mcl_potions.
* duration: the length of time the effect lasts.

## mcl_sus_stew.get_sus_stew(ingredient)

Returns an itemstack containing a suspicious stew.

* ingredient: determines the effect of the stew.
