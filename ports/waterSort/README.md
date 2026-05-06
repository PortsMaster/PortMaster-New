## Notes

Water Sort Deluxe is a native SDL2 puzzle game built for ArkOS handhelds (RK3326 / R36 Ultra, 720×720). Pour coloured liquids between glass tubes until every tube holds a single pure colour.

**Controls**

| Button | Action |
|--------|--------|
| D-Pad / Left Stick | Move cursor between tubes |
| A | Select tube / confirm pour |
| B | Deselect selected tube |
| L1 | New game (instant restart) |
| Start | Pause menu (Resume / Restart / Undo / Main Menu) |

**Difficulty levels**

- Easy — 3 colours, 5 tubes
- Medium — 6 colours, 8 tubes  
- Hard — 9 colours, 11 tubes

**Technical notes**

The binary is compiled natively for aarch64. It uses SDL2 + SDL_mixer + SDL_ttf. All audio is synthesised at runtime — no external sound files are needed. The Dracula colour theme is baked into the binary via `ark_engine.hpp`.

Thanks to the SDL2 and ArkOS communities for the foundational libraries. Also thanks to mrinmoy2developer for the packaging for portmaster.
