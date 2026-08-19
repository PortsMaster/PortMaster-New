## Notes

Mines of Moria by [Rufe.org](https://github.com/RufeDotOrg/moria_at), a rebuild
of Umoria, which is Robert Alan Koeneke's 1983 Moria. Built from the `main`
branch of [this fork](https://github.com/mxmgorin/moria-handheld), on top of
upstream `da8a3e5`.

## Controls

### In the dungeon

| Button | Action |
|--|--|
|dpad|walk one step|
|L2 + dpad|run in that direction|
|A|act on the square you stand on|
|B|rest until healed, or until something is seen or heard|
|X|use an item — opens the inventory list|
|Y|repeat the last action|
|L1|character sheet, while held|
|R1|dungeon map, while held|
|R2|look along a direction — press, then a dpad direction|
|SELECT|message history|
|START|game menu — help, options, save and quit|

A on its own reads what is under you: stairs are taken, an item is picked up, a
shop door is entered, otherwise you search the square. Diagonals are two dpad
directions at once.

### Holding L2

| Button | Action |
|--|--|
|A|use equipment|
|X|drop an item|
|Y|help — the whole layout, in game|
|L1|magnification|
|R1|locate yourself on the level map|
|SELECT|undo a turn|

### In lists and menus

| Button | Action |
|--|--|
|dpad up/down|move the selection|
|dpad left/right|switch column, where a list has one|
|A|choose the selected entry|
|B, X|back out|
|Y|choose it the other way — inspect rather than use|
|Y + dpad up/down|jump half a page|
|Y + dpad left/right|jump to the start or the end|

Renderer, magnification and colours can be changed from the game menu under
`e) Extra features`.

The map is drawn to the shape of your screen, which on a wide panel means fewer
dungeon rows. `n) minimum map rows` sets a floor it will not crop below — raise
it and the map keeps its rows and gains bars down the sides instead.

## Where to get it

Source and releases live at
[moria_at](https://github.com/RufeDotOrg/moria_at). Rufe.org also publish it on
[Google Play](https://play.google.com/store/apps/details?id=org.rufe.moria) and
the [App Store](https://apps.apple.com/us/app/mines-of-moria/id6448195864) —
that is the way to support the developer.

## Credits

- Moria (1983) — Robert Alan Koeneke
- Umoria — its maintainers and contributors
- [moria_at](https://github.com/RufeDotOrg/moria_at), the rebuild this is built
  from — [Rufe.org](https://github.com/RufeDotOrg)
- Handheld changes and PortMaster port —
  [mxmgorin](https://github.com/mxmgorin),
  [moria-handheld](https://github.com/mxmgorin/moria-handheld)
