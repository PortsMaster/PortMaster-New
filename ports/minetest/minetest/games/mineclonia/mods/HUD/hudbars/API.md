API documentation for the HUD bars mod
======================================

## Introduction
This API allows you to add, change, hide and unhide custom HUD bars for this mod.

## Overview
To give you a *very* brief overview over this API, here is the basic workflow on how to add your own custom HUD bar:

* Create images for your HUD bar
* Call `hb.register_hudbar` to make the definition of the HUD bar known to this mod
* Call `hb.init_hudbar` for each player for which you want to use previously defined HUD bar
* Use `hb.change_hudbar` whenever you need to change the values of a HUD bar of a certain player
* If you need it: Use `hb.hide_hudbar` and `hb.unhide_hudbar` to hide or unhide HUD bars of a certain player

## The basic rules
In order to use this API, you should be aware of a few basic rules in order to understand it:

* A HUD bar is an approximate graphical representation of the ratio of a current value and a maximum value, i.e. current health of 15 and maximum health of 20. A full HUD bar represents 100%, an empty HUD bar represents 0%.
* The current value must always be equal to or smaller then the maximum 
* Both current value and maximum must not be smaller than 0
* Both current value and maximum must be real numbers. So no NaN, infinity, etc.
* The HUD bar will be hidden if the maximum equals 0. This is intentional.
* The health and breath HUD bars are hardcoded.

These are soft rules, the HUD bars mod will not enforce all of these.
But this mod has been programmed under the assumption that these rules are followed, for integrity.

## Adding a HUD bar
To make a new HUD bar known to this mod, you need …

* … an image of size 2×16 for the bar
* … an icon of size 16×16 (optional)
* … to register it with `hb.register_hudbar`

### Bar image
The image for the bar will be repeated horizontally to denote the “value” of the HUD bar.
It **must** be of size 2×16.
If neccessary, the image will be split vertically in half, and only the left half of the image
is displayed. So the final HUD bar will always be displayed on a per-pixel basis.

The default bar images are single-colored, but you can use other styles as well, for instance,
a vertical gradient.

### Icon
A 16×16 image shown left of the HUD bar. This is optional.

### `hb.register_hudbar(identifier, text_color, label, textures, default_start_value, default_start_max, default_start_hidden, format_string, format_string_config, direction)`
This function registers a new custom HUD bar definition to the HUD bars mod, so it can be later used to be displayed, changed, hidden
and unhidden on a per-player basis.
Note this does not yet display the HUD bar.

The HUD bars will be displayed in a “first come, first serve” order. This API does not allow fow a custom order or a way to set it
manually in a reliable way. However, you can use the setting `hudbars_sorting` for this. See the advanced setting menu in Minetest
for more information.


#### Parameters
* `identifier`: A globally unique internal name for the HUD bar, will be used later to refer to it. Please only rely on alphanumeric characters for now. The identifiers “`health`” and “`breath`” are used internally for the built-in health and breath bar, respectively. Please do not use these names.
* `text_color`: A 3-octet number defining the color of the text. The octets denote, in this order red, green and blue and range from `0x00` (complete lack of this component) to `0xFF` (full intensity of this component). Example: `0xFFFFFF` for white.
* `label`: A string which is displayed on the HUD bar itself to describe the HUD bar. Try to keep this string short.
* `textures`: A table with the following fields:
 * `bar`: The file name of the bar image (as string). This is only used for the `progress_bar` bar type (see `README.txt`, settings section).
 * `icon`: The file name of the icon, as string. For the `progress_bar` type, it is shown as single image left of the bar, for the two statbar bar types, it is used as the statbar icon and will be repeated. This field can be `nil`, in which case no icon will be used, but this is not recommended, because the HUD bar will be invisible if the one of the statbar bar types is used.
 * `bgicon`: The file name of the background icon, it is used as the background for the modern statbar mode only. This field can be `nil`, in which case no background icon will be displayed in this mode.
* `default_start_value`: If this HUD bar is added to a player, and no initial value is specified, this value will be used as initial current value
* `default_max_value`: If this HUD bar is added to a player, and no initial maximum value is specified, this value will be used as initial maximum value
* `default_start_hidden`: The HUD bar will be initially start hidden by default when added to a player. Use `hb.unhide_hudbar` to unhide it.
* `format_string`: Optional; You can specify an alternative format string to use for the final text on the HUD bar. The default format string is “`@1: @2/@3`” (The “@” numbers are placeholders that have a meaning in this order: @1 = Label, @2 = current value, @3 = maximum value). Do *not* use minetest.translator on this string, the string will be translated by `hudbars`, but you still must put this string into the translation catalogue file.
* `format_string_config`: Required if `format_string` is set. This allows to change which parameters to use in the format string. It's a table with these fields:
* `textdomain`: Text domain of the format string, used by `minetest.translate` if missing or set to `nil` will use `minetest.get_translator`
 * `order`: Table that contains the order of the placeholders. It's also possible to remove placeholders. Default order: `{ "label", "value", "max_value" }`
 * `format_value`: Format string to apply when displaying `value`. Syntax is same as in `string.format`. Default: `"%d"`
 * `format_max_value`: Same as `format_value` but is applied to `max_value`
* `direction`: Either left to right(0), or right to left(1). - note: this field was moved to the end in mcla 0.91 to restore compatibility with upstream hudbars

#### Example
Example (mostly) from `hbarmor` mod:

```
hb.register_hudbar("armor", 0xFFFFFF, minetest.translator("hbarmor", "Armor"), { icon = "hbarmor_icon.png", bgicon = "hbarmor_bgicon.png", bar = "hbarmor_bar.png" }, 0, 100, hbarmor.autohide, N("@1: @2%"), { order = { "label", "value" }, textdomain = "hbarmor" } )
```

Displays an armor HUD bar with a label of the form „Armor: 53%“. (`N` is a dummy function that returns its argument, used to make the string visible for translator scripts.)

#### Return value
Always `nil`.


## Displaying a HUD bar
After a HUD bar has been registered, they are not yet displayed yet for any player. HUD bars must be
explicitly initialized on a per-player basis.

You probably want to do this in the `minetest.register_on_joinplayer`.

### `hb.init_hudbar(player, identifier, start_value, start_max, start_hidden)`
This function initialzes and activates a previously registered HUD bar and assigns it to a
certain client/player. This has only to be done once per player and after that, you can change
the values using `hb.change_hudbar`.

However, if `start_hidden` was set to `true` for the HUD bar (in `hb.register_hudbar`), the HUD bar
will initially be hidden, but the HUD elements are still sent to the client. Otherwise,
the HUD bar will be initially be shown to the player.

#### Parameters
* `player`: `ObjectRef` of the player to which the new HUD bar should be displayed to.
* `identifier`: The identifier of the HUD bar type, as specified in `hb.register_hudbar`.
* `start_value`: The initial current value of the HUD bar. This is optional, `default_start_value` of the registration function will be used, if this is `nil`.
* `start_max`: The initial maximum value of the HUD bar. This is optional, `default_start_max` of the registration function will be used, if this is `nil`
* `start_hidden`: Whether the HUD bar is initially hidden. This is optional, `default_start_hidden` of the registration function will be used as default

#### Return value
`true` on success, `false` otherwise.


## Modifying a HUD bar
After a HUD bar has been added, you can change the current and maximum value and other attributes on a per-player basis.
You use the function `hb.change_hudbar` for this.

### `hb.change_hudbar(player, identifier, new_value, new_max_value, new_icon, new_bgicon, new_bar, new_label, new_text_color)`
Changes the values and the appearance of an initialized HUD bar for a certain player. `new_value`
and `new_max_value` are the most important parameters as they specify the new current and maximum new values, you do not need
to worry too much about the other parameters.

The following parameters are less important and provided for styling the HUD bar after registration (if
this is desired). The “styling” parameters parallel the parameters of `hb.register_hudbar`. It is
recommended to not change the style of a HUD bar too often as this can be distracting or confusing
for players.

`new_value`, `new_max_value` `new_icon`, `new_bgicon`, `new_bar`, `new_label` and `new_text_color` can be
`nil`; if one of them is `nil`, that means the value is unchanged. If all those values are `nil`, this
function is a no-op.

This function tries to minimize the amount of calls to `hud_change` of the Minetest Lua API
(and thus, network traffic), when you only change the value and/or  maximum value. In this case,
`hud_change` is only called if it is actually needed, e.g. when the actual length of the bar
or the displayed string changed, so you do not have to worry about it. There is, however, no
such network optimization for the “styling” parameters, so keep this in mind.

#### Parameters
* `player`: `ObjectRef` of the player to which the HUD bar belongs to
* `identifier`: The identifier of the HUD bar type to change, as specified in `hb.register_hudbar`.
* `new_value`: The new current value of the HUD bar
* `new_max_value`: The new maximum value of the HUD bar
* `new_icon`: File name of the new icon
* `new_bgicon`: File name of the new background icon for the modern-style statbar
* `new_bar`: File name of the new bar segment image
* `new_label`: A new text label of the HUD bar. Note the format string still applies
* `new_text_color`: A 3-octet number defining the new color of the text.

#### Return value
`true` on success, `false` otherwise.


## Hiding and unhiding a HUD bar
You can also hide custom HUD bars, meaning they will not be displayed for a certain player. You can still
use `hb.change_hudbar` on a hidden HUD bar, the new values will be correctly displayed after the HUD bar
has been unhidden. Both functions will only call `hud_change` if there has been an actual change to avoid
unneccessary traffic.

Note that the hidden state of a HUD bar will *not* be saved by this mod on server shutdown, so you may need
to write your own routines for this or by setting the correct value for `start_hidden` when calling
`hb.init_hudbar`.

### `hb.hide_hudbar(player, identifier)`
Hides the specified HUD bar from the screen of the specified player.

#### Parameters
* `player`: `ObjectRef` of the player to which the HUD bar belongs to
* `identifier`: The identifier of the HUD bar type to hide, as specified in `hb.register_hudbar`.

#### Return value
`true` on success, `false` otherwise.


### `hb.unhide_hudbar(player, identifier)`
Makes a previously hidden HUD bar visible again to a player.

#### Parameters
* `player`: `ObjectRef` of the player to which the HUD bar belongs to
* `identifier`: The identifier of the HUD bar type to unhide, as specified in `hb.register_hudbar`.

#### Return value
`true` on success, `false` otherwise.


## Reading HUD bar information
It is also possible to read information about existing HUD bars.

### `hb.get_hudbar_state(player, identifier)`
Returns the current state of the active player's HUD bar. Will return `nil` if the hudbar is not initialized.

#### Parameters
* `player`: `ObjectRef` of the player to which the HUD bar belongs to
* `identifier`: The identifier of the HUD bar type to hide, as specified in `hb.register_hudbar`.

#### Return value
On success, returns a table which holds information on the current state of the HUD bar. Note
the table is a deep copy of the internal HUD bar state, it is *not* a reference; the information
hold by the table is only true for the moment you called this function. The fields of this table are:

* `value`: Current value of HUD bar.
* `max`: Current maximum value of HUD bar.
* `hidden`: Boolean denoting whether the HUD bar is hidden.
* `barlength`: The length of the HUD bar in pixels. This field is meaningless if the HUD bar is currently hidden.
* `text`: The text shown on the HUD bar. This fiels is meaningless if the HUD bar is currently hidden.

If the player does not exist, returns `nil` instead.

### `hb.get_hudbar_identifiers()`
Returns a table of all currently registered HUD bar identifiers.
