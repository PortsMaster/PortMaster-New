## Notes

This port is **ready to run** and includes release version 146 out of the box. If you wish to play a newer version, place your .jar file in the `mindustry/` directory. It will be patched upon first launch. Your milage may vary in terms of compatibility.

Depending on your screen resolution, the game's UI might be too big or too small. This can be adjusted in the game's graphics settings. Recommended UI scale setting:

- 480x320: 0.5x
- 640x480: 0.7x (default)
- 720x720: 0.8x
- higher: 1x or higher 

---

Special thanks to **Anuken** for creating this awesome game and releasing it and its game engine Arc as Open Source. If you like the game, please support the creator.

**Game:** https://github.com/Anuken/Mindustry

**Arc:** https://github.com/Anuken/Arc

---

Another special thanks to [kotzebuedog](https://portmaster.games/profile.html?porter=kotzebuedog) for the original version of the port script, the idea to patch the .jar with `zip` and for extensive testing.

---

This port uses a modified version of Arc that patches in GLES support.

The modified source code is available at https://github.com/binarycounter/Arc licensed under Apache 2.0.

---

This port uses BinaryCounter's libcrusty and nosignals libraries.

libcrusty is used to provide a software cursor for SDL2 apps on platforms where mouse cursors are unsupported (e.g. DRMKMS or fbdev).

nosignals is used to trap SDL2's attempts at registering signal handlers with are already used (and needed) by Java. Both libraries are licensed under MIT.

**libcrusty:** https://github.com/binarycounter/Crusty (access available upon request)

**no_signals:** https://gist.github.com/binarycounter/58269a779804c32cd2daa574ed41c492




## Controls

| Button | Action |
|--|--| 
|Left analog stick|Mouse Movement|
|Right analog stick|Unit movement|
|DPad left/right|Block selection left/right|
|DPad up/down|Block category selection up/down|
|A|Left click (place block)|
|B|Right click (Cancel)|
|Y|Pick Block|
|X|Slow down Mouse Movement|
|Start|Pause Time|
|Guide / Home|Escape (Pause Menu)|
|L1|Command Mode|
|L2|Control Unit|
|R1|Select All Units|
|R2|Select All Unit Factories|
|Select+X / Select+B|Zoom in / Zoom Out|
|Select+Y|Pickup Cargo|
|Select+A|Drop Cargo|
|Select+L1|Respawn|

All other gamepad buttons (L3, R3, Select+L2/R1/R3) are bound to keyboard buttons, and can be bound to additional ingame actions using the ingame control setttings.

