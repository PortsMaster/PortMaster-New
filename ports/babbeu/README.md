## Notes

Thanks to [lilybeevee](https://github.com/lilybeevee) for making this fan game of Baba Is You, turning its rules-as-physical-blocks mechanic into dozens of its own surprising puzzle twists, complete with a full campaign and a built-in level editor.

## Controls

| Button | Action |
|--|--|
| D-Pad | Move (menus: change selection; in-level: move) |
| A | Wait in place — also how you advance past a level's win screen |
| B | Undo |
| X | Pause / close menu |
| Y | Special action (only does something on levels whose rules use it, e.g. time-stop) |
| L1 | Special action (only does something on levels whose rules use it) |
| L2 | Restart level |
| R1 | Left click (level editor) |
| R2 | Right click (level editor) |
| Start | Confirm (menus) |

## Build

```sh
git clone https://github.com/lilybeevee/bab-be-u.git
cd bab-be-u
```

Add fullscreen defaults to `conf.lua` (there's no window manager on device to letterbox a windowed LÖVE app), right after `t.window.resizable = true`:

```lua
t.window.fullscreen = true
t.window.fullscreentype = "desktop"
```

The game only draws its mouse-cursor sprite when `is_mobile` (Android/iOS) is true, and its menus/level-select/editor are entirely mouse-driven with no keyboard fallback — without this the cursor is invisible on a handheld even though clicks still register. Add a build flag in `values.lua`, right after `--is_mobile = `:

```lua
FORCE_CURSOR_DRAW = true -- no OS-drawn cursor under KMS/DRM; force the game's own mobile cursor sprite
```

Then change each of the three `if is_mobile then` cursor-draw guards to `if is_mobile or FORCE_CURSOR_DRAW then`:
- `menu/scene.lua` (main menu, ~line 326)
- `editor/scene.lua` (level editor, ~line 2032)
- `editor/loadscene.lua` (level-select — add the same draw block after `gooi.draw()` at the end of `scene.draw()`, since upstream never draws a cursor here at all)

Several of the game's shaders mix bare integer literals with float operands (e.g. `tx.a == 0`, `amt/2`) — legal under desktop GL's looser typing but rejected outright by GLSL ES on real GLES2/3 hardware (Mali on RG351V confirmed: `no operation '==' exists that takes... type 'const int'`). Each is wrapped in `pcall` (`utils.lua:3306`, `pcallNewShader`) so it fails silently rather than crashing, but the affected visual effect just doesn't render. Fix by making every such literal an explicit float (`0` → `0.0`, `/2` → `/2.0`, etc.):
- `mask_shader` and `xwxShader`, inline in `game/scene.lua` (lines ~4-36) — these are the ones actually loaded at runtime; `tx.a == 0` → `tx.a == 0.0`, both `amt/2` → `amt/2.0`.
- `shader_pucker.txt` (the "za warudo" time-stop effect, loaded via `pcallNewShader("shader_pucker.txt")` at `game/scene.lua:40`) — same pattern throughout (`c.y == 0`, `time/130`, `cx/6`, etc.), all need the `.0`.
- `paletteshader_dunno.txt`/`paletteshader_autumn.txt` have the identical bug too, but upstream's own `love.graphics.newShader(...)` calls that would load them are commented out (`game/scene.lua:38-39` — dead code, superseded by the inline `paletteshader_0`) — harmless to fix for consistency, but not load-bearing.

The game also defaults its in-game "Auto Update" setting to on (`values.lua`'s `autoupdate = true`), which shells out to `git fetch`/`git pull` on every boot — meaningless (and noisy in the log) once the game is a `.love` file with no `.git` directory. Set it to `false`:

```lua
autoupdate = false,
```

Then package as a `.love`:

```sh
zip -9 -r babbeu.love . -x ".git/*"
```
