# `mcl_gamemode`

## `mcl_gamemode.gamemodes`

List of availlable gamemodes.

Currently `{"survival", "creative"}`

## `mcl_gamemode.get_gamemode(player)`

Get the player's gamemode.

Returns "survival" or "creative".

## `mcl_gamemode.set_gamemode(player, gamemode)`

Set the player's gamemode.

gamemode: "survival" or "creative"

## `mcl_gamemode.register_on_gamemode_change(function(player, old_gamemode, new_gamemode))`

Register a function that will be called when `mcl_gamemode.set_gamemode` is called.

## `mcl_gamemode.registered_on_gamemode_change`

Map of registered on_gamemode_change.
