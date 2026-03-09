# `mcl_buttons` API

This API allows for registering and pushing buttons.

## `mcl_buttons.push_button(pos, node)`

Push button with node `node` at position `pos`.

## `mcl_buttons.register_button(basename, buttondef)`

Register button from button definition `buttondef`. It will register the nodes
`mcl_buttons:button_<basename>_on` and `mcl_buttons:button_<basename>_off`.

The button definition should have the following fields:

```lua
{
	description = "",       -- Description of button
	texture = "",           -- Texture of button
	recipeitem = "",        -- Item used to craft button
	groups = {},            -- Groups to add to button
	sounds = "",            -- Sounds
	push_by_arrow = false,  -- If button should be pushable by arrow
	longdesc = "",          -- Long description for documentation
	push_duration = 0,      -- How long button stays pressed
	push_sound = "",        -- Sound when button is pressed
	burntime = nil,         -- How long button is burnable as fuel
}
```
