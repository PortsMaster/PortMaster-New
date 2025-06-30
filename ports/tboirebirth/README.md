# Thanks
Thanks to [Edmund McMillen](https://x.com/edmundmcmillen) and [Nicalis](https://www.nicalis.com/) for creating this game.

Thanks to ptitSeb for creating [box64](https://github.com/ptitSeb/box64) and [gl4es](https://github.com/ptitSeb/gl4es), without which this port would've not been possible.
Thanks to all the people on the PM Discord for very thoroughly testing this port and pushing me to get it to much better state than it was initially in.

## Controls

| Control             | Action                      |
|---------------------|-----------------------------|
| DPad, Left Stick    | Move, Menus                 |
| ABXY, Right Stick   | Shoot                       |
| L1                  | Place Bomb                  |
| R1                  | Use single-use item         |
| L2                  | Drop trinket                |
| R2                  | Activated items (spacebar)  |
| Start               | Enter (accept)              |
| Select              | Escape (pause/back)         |
| Tap Guide           | Toggle minimap size         |
| Hold Guide          | Expand Minimap              |

## Hacks and Mods

This ports includes a custom launcher that adds a couple of hacks, mods and fixes that make the game perform better on low-end hardware:


| Name                      | Description                                                                                                                            |
|---------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| Non-Integer Scaling Hack  | Hack that enables scaling to non-integer values. Increases visibility on small screens, but looks worse.                               |
| Disable Effects           | Turns off lighting and visual effects. Big performance boost, looks worse.                                                             |
| Disable Fog/Overlays      | Turns off fog and overlays like shadows. Big performance boost on later floors, looks worse.                                           |
| Reduce Texture Quality    | Reduces bitdepth to 16 bit. Small performance boost, lower RAM usage. Looks worse.                                                     |
| X11 Performance Hack      | Caches and reduces XGetWindowAttributes calls. Massive performance boost. Slight visual glitches on startup.                           |
| XKB Crash Fix             | Prevents crashes related to XkbGetKeyboard on XWayland. Keep enabled unless you're on a pure X11 system.                               |
| Swap A/B Buttons          | For TrimUI devices, swaps A/B buttons to correspond to their cardinal directions.                                                      |
| XBox Style A/B/X/Y        | For devices with XBox style controls. Swaps A/B/X/Y buttons to correspond to their cardinal directions.                                |


It is recommended to leave the default hacks enabled, unless you have a powerful device that can handle it. 

If your device has a different layout for A/B/X/Y buttons and Isaac is firing in the wrong directions, try enabling either "Swap A/B Buttons" or "XBox Style A/B/X/Y"

## Runtimes, custom libraries and mods

This port uses the Westonpack 0.2 runtime to bring X11 software to non-X11 devices. It also uses GL4ES to provide OpenGL 2.1 and Box64 to run x64 code on Arm64 devices.
It also includes two custom libraries that fix problems with the original game:

1. xkb-compat

This game uses a statically linked GLFW to facilitate windowing and input. The version they used is pretty old and has a bug: It does not check if XkbGetKeyboard returns NULL before attempting to use its output.
This function can return NULL if no keyboard is attached or if the system uses XWayland (which all Westonpack ports do). This library stubs out XkbGetKeyboard and returns a fake struct that causes the keymap detection to fail gracefully, rather than crash.

2. x11-cache

This game calls the X11 function XGetWindowAttributes on every frame, apparently just to check for window size changes. This function however returns a huge amount of information and is quite CPU heavy. Originally this made up around 50% of CPU time overall. This library intercepts the function calls and caches them, only hitting the actual function once every 10 seconds, making the load much lighter.

3. Non-integer scaling hack

This game always scales its pixel art in perfect integer multiples, making the graphics look nice, but unfortunately very tiny on 640x480 screens. This hack patches out a couple of instructions and calls to "floorf" in the function that decides the scaling multiple, which means that the game no longer rounds down to integers, but instead scales fractionally.

4. No fog and overlays

To increase performance, i created my own version of the "fogless" and "nooverlays" mods. This replaces a bunch of optional effects textures with empty textures, allowing them to render much faster. 

