# mcl_dyes

`mcl_dyes.colors`
This table contains all the colors indexed by cannonical color name:
```lua
{
	["colorname"] = {
		readable_name, -- the untranslated "readable" name of the color to be used in descriptions
		groups, -- table of the color groups including legacy "unicolor"
		rgb, -- hex RGB value of the color
		unicolor, --the name of the color in the "unicolor" format
		mcl2, --this field is set in the cases where the colorname mismatches with the correspoinding mcl2/voxelibre color. This was done to make color names more consistent and predictable.
	},
}
```

`mcl_dyes.unicolor_to_dye(unicolor_group)`
This returns the dye item name correspoinding to the unicolor group. Mostly provided for compatibility reasons.

`_on_dye_place(position, colorname)`
This is a field that can go into node definitions and the function will be called if the node is rightclicked with a dye item.
Return true to not subtract the an item from the itemstack.
