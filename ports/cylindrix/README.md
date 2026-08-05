## Cylindrix — ARM / handheld port


Cylindrix is a **3-vs-3** combat game set inside cylindrical arenas, with a retro Tron-style aesthetic of flat polygons and saturated colors. You don't fly alone: you pilot your own ship, command two AI wingmen, and your goal is to take down the enemy team's radar base, capture pylons, and survive while the opposing team tries to do the same to you. Movement is fully free on all three axes, the pace is fast, and the difference between winning and losing comes down to picking the right ship, giving the right orders to your wingmen, and reading the arena, rather than pure aim. A weird and very 90s hybrid between dogfighter, arena shooter, and pocket-sized RTS.

### Controls

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
| **BACK** (Home) | Escape | Back / quit menu |


If you want to remap anything, edit `cylindrix.gptk` next to the binary — no recompile needed.

---
### Project history

- **1996** — Original MS-DOS release by Goldtree Enterprises, developed by Hyper Image Productions / Hotwarez LLC. Credited programmers include John R. McCawley III, Chris W. Bankston, Joel H. Hunter, and D. J. Delorie.
- **2001** — John R. McCawley III obtains permission to release the game and its source code under the **LGPL**, together with an updated Windows build.
- **~2018** — Anthony Thibault (*hyperlogic*) refactors the codebase to be cross-platform on top of **SDL2, OpenGL and OpenAL**, hosted at [github.com/hyperlogic/cylindrix](https://github.com/hyperlogic/cylindrix).

### System dependencies

- `libopenal-dev`
- `libglm-dev`
- A driver with OpenGL ES 2.0 support (Mali, VideoCore VI, Adreno, etc.)




---

### Credits

- **Goldtree Enterprises / Hyper Image Productions / Hotwarez LLC** — original game (1996).
- **John R. McCawley III** — LGPL release (2001).
- **Anthony Thibault (hyperlogic)** — cross-platform refactor on top of SDL2 / OpenGL / OpenAL.
- **This fork** — ARM/aarch64 adaptation and fixes for PortMaster handhelds.



### Sources

- Official description — [Internet Archive: *Cylindrix* (Goldtree Enterprises)](https://archive.org/details/cylindrix12_18_2001)
- Development data and technical info — [MobyGames: *Cylindrix (1996)*](https://www.mobygames.com/game/1205/cylindrix/)
- Cross-platform refactor source — [github.com/hyperlogic/cylindrix](https://github.com/hyperlogic/cylindrix)
