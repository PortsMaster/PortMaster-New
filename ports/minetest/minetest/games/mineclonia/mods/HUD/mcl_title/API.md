# mcl_title

Allow mods to show messages in the hud of players.

## mcl_title.set(player, type, data)

Show a hud message of `type` to player `player` with `data` as params.

The element will stay for the per-player param `stay` or `data.stay` (in gametick which is 1/20 second).

Here is a usage exemple:

```lua
--show a title in the HUD with minecraft color "gold" 
mcl_title.set(player, "title", {text="dummy text", color="gold"})

--show a subtitle in the HUD with hex color "#612D2D" 
mcl_title.set(player, "subtitle", {text="dummy subtitle", color="#612D2D"})

--show an actionbar in the HUD (above the hotbar) with minecraft color "red"
mcl_title.set(player, "subtitle", {text="dummy actionbar", color="red"})

--show a title in the HUD with minecraft color "gold" staying for 3 seconds (override stay setting)
mcl_title.set(player, "title", {text="dummy text", color="gold", stay=60})
```

## mcl_title.remove(player, type)

Hide HUD element of type `type` for player `player`.

## mcl_title.clear(player)

Remove every title/subtitle/actionbar from a player.
Basicaly run `mcl_title.remove(player, type)` for every type.

## mcl_title.params_set(player, params)

Allow mods to set `stay` and upcomming `fadeIn`/`fadeOut` params.

```lua
mcl_title.params_set(player, {stay = 600}) --elements with no 'data.stay' field will stay during 30s (600/20)
```

## mcl_title.params_get(player)

Get `stay` and upcomming `fadeIn` and `fadeOut` params of a player as a table.

```lua
mcl_title.params_get(player)
```