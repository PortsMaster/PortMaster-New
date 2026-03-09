# mcl_throwing

## mcl_throwing.throw(throw_item, pos, dir, velocity, thrower)
Throw a throwable item.

* throw_item: itemstring of the throwable item
* pos: initial position of the entity
* dir: direction where the throwable item will be thrown
* velocity: (optional) will overide the default velocity value (can be nil)
* thrower: (optional) player/entity who throw the object (can be nil)

## mcl_throwing.register_throwable_object(name, entity, velocity)
Register a throwable item.

* name: itemname of the throwable object
* entity: entity thrown
* velocity: initial velocity of the entity

## mcl_throwing.dispense_function(stack, dispenserpos, droppos, dropnode, dropdir)
Throw throwable item from dispencer.

Shouldn't be called directly.

Must be used in item definition:

`_on_dispense = mcl_throwing.dispense_function,`

## mcl_throwing.get_player_throw_function(entity_name, velocity)

Return a function who handle item throwing (to be used in item definition)

Handle creative mode, and throw params.

* entity_name: the name of the entity to throw
* velocity: (optional) velocity overide (can be nil)

## mcl_throwing.get_staticdata(self)
Must be used in entity def if you want the entity to be saved after unloading mapblock.

## mcl_throwing.on_activate(self, staticdata, dtime_s)
Must be used in entity def if you want the entity to be saved after unloading mapblock.
