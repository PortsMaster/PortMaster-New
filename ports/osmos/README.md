## Notes

Special thanks to **Hemisphere Games** for creating this awesome game.

**Game:** https://osmos-game.com/

**Developer:** https://www.hemispheregames.com/

Additional special thanks to:
- [ptitSeb](https://github.com/ptitSeb) for creating the X64/X86 Emulators [Box64](https://github.com/ptitSeb/box64)/[Box86](https://github.com/ptitSeb/box86) and the OpenGL compatibility layer [GL4ES](https://github.com/ptitSeb/gl4es), which makes this whole port possible.
- Slobters, Doronimmo, NotYourAveragePaladin, bbilford83, Ganimoth, klops, tabreturn for participating in testing.

---

This port uses the Westonpack runtime and libcrusty to provide X11 compatibility on devices that do not support X11. The runtime is still in active development and somewhat experimental. If you are experiencing issues, please reach out to me on the PM discord server, so i can improve this runtime. Thanks!
This port also patches the Osmos binary to remove restrictions of running the game at lower resolutions than 800x600. It accomplishes this by using Python to fuzzy search for the values 800 and 600 in a specific configuration that matches the original resolution check function. The game is playable, but some text can be cutoff on very low resolutions.


**LEGAL DISCLAIMER:** This port includes a selfmade library that partially emulates the Steam API. This library does not bypass DRM protection measures, nor is it capable to do so, nor does the game actually have any protection measures. All this library does is tell the app that Steam is running, and reply with stub values to a couple of requests related to achievements and leaderboards to allow the app's online features to fail gracefully. The full source code (under MIT license) is included in the package for full disclosure.

---

## Controls


| Control              | Action                                |
|----------------------|---------------------------------------|
| DPad, Analog Sticks  | Move mouse cursor                     |
| R1, R2, A            | Left-Click (Menus and propel forward) |
| L1, L2               | Slow down, Speed up                   |
| X, B                 | Zoom in and out                       |
| Y                    | Randomize level                       |
| Start                | Space (move on to next level)         |
| Select               | Restart Level                         |
| Guide                | Pause Menu                            |

