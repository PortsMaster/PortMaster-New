English | [Español](README.es.md)

# rumble

The console vibrates at the strong moments of the game, with effects that
have a shape, not a flat buzz:

| When                                      | Effect                                        |
|-------------------------------------------|-----------------------------------------------|
| a battle starts (an enemy catches you)    | `heartbeat`: two beats and a fading tremor    |
| someone of the party takes damage         | `impact`: a dry hit and its rebound           |
| someone of the party falls                | `fade`: long and weaker and weaker            |
| damage on the map (poison, bleeding)      | `sting`: a weak double sting                  |

It vibrates the controller if it has a motor (the RG CubeXX, for example).
On Android, if the controller does not vibrate, the phone does. Consoles
without a motor do nothing.

It comes on. To turn it off: Options > Vibration: Off, or `rumble: Off` in
the Mods option of the menu of the port. It works with any other mod.

The effects are presets of quixjs
([runtime/engines/lib/rumble.js](../../../../runtime/engines/lib/rumble.js)):
`heartbeat`, `impact`, `heavy-impact`, `fade`, `quake`, `alarm`, `sting`,
`tick`. To change how a moment feels, change its name in `rumble.js` of
this mod.
