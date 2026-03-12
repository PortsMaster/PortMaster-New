# `mcl_itemframes` API

## Functions

* `mcl_itemframes.register_itemframe(name, itemframe_definition)`
	* Registers a new item frame as `"mcl_itemframes:"..name`. See Itemframe definition below for reference.
* `mcl_itemframes.remove_entity(pos)`
	* Removes the item entity belonging to the itemframe at `pos`, does not delete the item (inventory) of the itemframe.
* `mcl_itemframes.update_entity(pos)`
	* Updates the item entity belonging to the itemframe at `pos` according to it's set item (node inventory).

## Tables

* `mcl_itemframes.registered_nodes`
    * List of all nodes registered by `mcl_itemframes`.
* `mcl_itemframes.registered_itemframes`
    * Dictionary of registered itemframe definitions, indexed by `name`, as passed into the registration function.

## Itemframe definition

```lua
{
	node = {
		description = "My cool Frame",
		tiles = {"my_texture.png"},
		-- ... this can contain any node definition fields which will be used for the itemframe node
	},
	object_properties = {
		glow = 15,
		-- ... this can contain any object properties which will be applied to the item entity
	},
}
```
