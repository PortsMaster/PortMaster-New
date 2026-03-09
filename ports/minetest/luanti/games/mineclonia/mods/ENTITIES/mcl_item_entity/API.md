# mcl_item_entity
## Credits
Originally ported from mtg item entity by Pilzadam (WTFPL)
## Item definition
### Fields
#### _mcl_silk_touch_drop
* true: Drop itself when dug by tool with silk touch enchantment
* table: Drop every itemstring in this table when dug with silk touch
#### _mcl_shears_drop
* same as above for being dug by shears
### Callbacks
#### _on_set_item_entity = function(stack, luaentity)
* Called when an item is converted to an item entity (i.e. "dropped").
* Should return the stack and optionally as a second argument modified object properties to be applied to the entity.
#### _on_entity_step = function(luaentity, dtime, itemstring)
* Called on every step when the item is in entity form (item entity, itemframe).
* May return the modified itemstring which will be applied to the item entity.
