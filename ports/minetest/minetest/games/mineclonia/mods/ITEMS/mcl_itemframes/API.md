# mcl_itemframes
## Functions
* mcl_itemframes.register_itemframe(name, itemframe_definition)
* mcl_itemframes.remove_entity(pos)
	* Removes the item entity belonging to the itemframe at `pos`, does not delete the item(inventory) of the itemframe.
* mcl_itemframes.update_entity(pos)
	* Updates the item entity belonging to the itemframe at `pos` according to it's set item (node inventory)

## Itemframe definition

```lua
{
	node = {
		description = "My cool Frame",
		tiles = { "my_texture.png"},
		-- ... this can contain any node definition fields which will be used for the itemframe node
	},
	object_properties = {
		glow = 15,
		-- ... this can contain any object properties which will be applied to the item entity
	},
}
```
