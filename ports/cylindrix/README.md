# Cylindrix — ARM / handheld port

`aarch64` port of the classic 3D combat game **Cylindrix** (Goldtree Enterprises, 1996), adapted for handhelds in the **PortMaster** ecosystem (Rocknix, ArkOS, AmberELEC, JELOS, Knulli, etc.) on top of OpenGL ES 2.0.

---

## Quick overview

Cylindrix is a **3-vs-3** combat game set inside cylindrical arenas, with a retro Tron-style aesthetic of flat polygons and saturated colors. You don't fly alone: you pilot your own ship, command two AI wingmen, and your goal is to take down the enemy team's radar base, capture pylons, and survive while the opposing team tries to do the same to you. Movement is fully free on all three axes, the pace is fast, and the difference between winning and losing comes down to picking the right ship, giving the right orders to your wingmen, and reading the arena, rather than pure aim. A weird and very 90s hybrid between dogfighter, arena shooter, and pocket-sized RTS.


## Project history

- **1996** — Original MS-DOS release by Goldtree Enterprises, developed by Hyper Image Productions / Hotwarez LLC. Credited programmers include John R. McCawley III, Chris W. Bankston, Joel H. Hunter, and D. J. Delorie.
- **2001** — John R. McCawley III obtains permission to release the game and its source code under the **LGPL**, together with an updated Windows build.
- **~2018** — Anthony Thibault (*hyperlogic*) refactors the codebase to be cross-platform on top of **SDL2, OpenGL and OpenAL**, hosted at [github.com/hyperlogic/cylindrix](https://github.com/hyperlogic/cylindrix).
- **2026 — this port** — Build adapted for `aarch64` with an OpenGL ES 2.0 renderer, packaged for PortMaster, with handheld-specific fixes.


The binary is produced at `build/cylindrix`. Rename it to `cylindrix.aarch64` and place it next to `cylindrix.sh` in `/roms/ports/cylindrix/` on the device.

### System dependencies

- `libsdl2-dev`
- `libopenal-dev`
- `libglm-dev`
- A driver with OpenGL ES 2.0 support (Mali, VideoCore VI, Adreno, etc.)

---

## Changes vs upstream

This fork carries a number of fixes specific to running the game on handhelds with sway/Wayland or KMSDRM:

| File | Changes |
|---|---|
| `src/system/sdl/system.cpp` | Fullscreen by default (`SDL_WINDOW_FULLSCREEN_DESKTOP`); CLI flags `-window` / `-fullscreen`; query the real drawable size via `SDL_GL_GetDrawableSize` + `glViewport` (the image no longer stays in a corner); `SDL_WINDOWEVENT_SIZE_CHANGED` handler (the upstream one used SDL1's `SDL_VIDEORESIZE`); event-driven input instead of polling with `SDL_GetKeyboardState` (fixes short presses dropped in menus, typical of START/SELECT through gptokeyb); diagnostics routed through `stderr` to bypass `tee` buffering; window title cleaned up. |
| `src/glescylindrix.cpp` | Ortho matrix matched to the quad aspect (1.333) instead of the screen aspect — the image stretches edge-to-edge with no pillarbox bars on 16:9 displays; removed a per-frame `printf` that was flooding the log. |

---

## Controls

The controller-to-keyboard mapping below is the one shipped in `cylindrix.gptk`. The game itself still listens for keyboard input — gptokeyb translates each handheld button into the corresponding key press.

| Handheld button | Sent key | In-game action |
|---|---|---|
| D-Pad ↑ ↓ ← → | Arrow keys | Steering / menu navigation |
| Left analog stick | Arrow keys (same as D-Pad) | Steering / menu navigation |
| **A** | `A` | Accelerate (air mode) |
| **B** | `Z` | Decelerate (air mode) |
| **X** | `X` | Special weapon |
| **Y** | `V` | Change view |
| **L1** | Left Alt | Sidestep |
| **L2** | `S` | Toggle mode (air / ground) |
| **R1** | Left Ctrl | Fire laser |
| **R2** | Space | Fire missile |
| **START** | Enter | Confirm / menu select |
| **GUIDE** (Home) | Escape | Back / quit menu |
| L3 / R3 (stick click) | Mouse left / right | *(optional, unused in-game)* |

If you want to remap anything, edit `cylindrix.gptk` next to the binary — no recompile needed.

---

## Credits

- **Goldtree Enterprises / Hyper Image Productions / Hotwarez LLC** — original game (1996).
- **John R. McCawley III** — LGPL release (2001).
- **Anthony Thibault (hyperlogic)** — cross-platform refactor on top of SDL2 / OpenGL / OpenAL.
- **This fork** — ARM/aarch64 adaptation and fixes for PortMaster handhelds.



## Sources

- Official description — [Internet Archive: *Cylindrix* (Goldtree Enterprises)](https://archive.org/details/cylindrix12_18_2001)
- Development data and technical info — [MobyGames: *Cylindrix (1996)*](https://www.mobygames.com/game/1205/cylindrix/)
- Cross-platform refactor source — [github.com/hyperlogic/cylindrix](https://github.com/hyperlogic/cylindrix)
