# STAR WARS: Dark Forces (The Force Engine)

Port of [The Force Engine](https://theforceengine.github.io/) for PortMaster (aarch64 and x86_64).

You must own the game. Copy original files from **GOG** or **Steam** into `theforceengine/game/` as-is (any case). On desktop, `./run.sh` can autodetect a local Steam/GOG install for testing.

## Supported firmware

| CFW | Status |
|-----|--------|
| muOS, ROCKNIX, Knulli | Target (OpenGL 3.3 GPU renderer) |
| ArkOS / dArkOS | Target |
| RetroDECK / PortMaster PC (x86_64) | Tested path via `theforceengine.x86_64` |

**Not supported:** 32-bit armhf.

## Graphics notes

- Handheld UI and input activate when `TFE_HANDHELD=1` (set by the PortMaster launcher). Linux kmsdrm (bare VT) also selects GLES. On x86_64 desktop, OpenGL is preferred and GLES is only a fallback (same as OpenJKDF2); `TFE_HANDHELD` does not force GLES.
- **GPU renderer (`renderer=1`)** needs GLES 3.2 texture buffers (or `GL_OES_texture_buffer` on 3.0), or the Mali **2D texture-buffer emulation** path when fragment texture buffers are unavailable. All GPU shaders compile as `#version 320 es` / `300 es` with clip-distance and precision preamble.
- Desktop x86_64 can force GLES (`TFE_FORCE_GLES=1`) or desktop GL (`TFE_FORCE_GL=1`).
- On square panels (e.g. 720×720), **gameplay** stretches to fill the display (1:1). Menus, cutscenes, PDA, and mission briefing stay **4:3 with letterbox/pillarbox**.
- First launch applies handheld defaults: **Match Window** resolution, widescreen, fullscreen, GPU renderer (software fallback only when GLES cannot support GPU rendering), bloom off.

## Controls

Button names follow the **SDL / Xbox layout** (A = south, B = east, X = west, Y = north). On Nintendo-style devices the physical labels may differ; SDL still reports A/B/X/Y.

`gptokeyb` uses an **empty** `theforceengine.gptk` so SDL keeps native gamepad input. Only **Select+Start** is handled outside the engine (PortMaster quit).

### In-game (default gamepad layout)

| Input | Action |
|-------|--------|
| **Left stick** | Move / strafe |
| **Right stick** | Look |
| **D-Pad** (alone) | Move forward / back / strafe left / right |
| **D-Pad** (while holding **Y**) | See [D-Pad tools](#d-pad-tools) below |
| **A** | Jump |
| **B** | Run (hold); double-tap toggles autorun (handheld) |
| **L1** | Previous weapon |
| **L3** (left stick click) | Toggle autorun (only if L3 has no other binding) |
| **R1** | Next weapon |
| **X** | Crouch |
| **Y** | Use / interact (doors, switches, items) |
| **R2** (right trigger) | Primary fire |
| **L2** (left trigger) | Secondary fire / alt-fire |
| **Start** | Pause menu (in-game escape menu: save, load, options, quit mission, etc.) |
| **Select** | PDA (inventory, weapons, mission data) |
| **Guide** (Home / FN / PS / hotkey) | [System menu](#system-menu-tfe-settings) |

Movement is on the **left stick** or **D-Pad** by default. Holding **Y** switches the D-Pad to tool shortcuts instead.

#### D-Pad tools

While **Y** is held:

| D-Pad | Action |
|-------|--------|
| **Up** | Automap |
| **Down** | Gas mask toggle |
| **Left** | Night vision toggle |
| **Right** | Head lamp toggle |

### Handhelds without analog sticks

Devices with **no sticks** or a **single left stick** (PortMaster sets `ANALOG_STICKS` to `0` or `1`) enable a dedicated profile via `TFE_HANDHELD_NO_STICKS=1`. The launcher does this automatically when `ANALOG_STICKS` is defined and less than `2`; if `ANALOG_STICKS` is unset, the normal two-stick layout is used.

You can force the profile manually: `TFE_HANDHELD_NO_STICKS=1` (requires `TFE_HANDHELD=1`).

#### Movement (tank controls)

| Input | Action |
|-------|--------|
| **D-Pad Up / Down** | Move forward / backward |
| **D-Pad Left / Right** (L2 **not** held) | Turn left / right (tank-style) |
| **D-Pad Left / Right** (while holding **L2**) | Strafe left / right |
| **Left stick** (if present) | Up/down = move; left/right = turn (or strafe while **L2** held) |

Horizontal turn and strafe use **run speed** automatically (no need to hold **B** to turn faster).

#### Combat and tools

| Input | Action |
|-------|--------|
| **R2** | Primary fire |
| **L2** | Strafe modifier (hold while pressing left/right) |
| **Y + R2** | Secondary fire / alt-fire |
| **Y** (alone) | Use / interact |
| **Y + D-Pad** | [D-Pad tools](#d-pad-tools) |

Autoaim is slightly tighter in this profile to compensate for coarser tank aiming.

#### Autorun

| Input | Action |
|-------|--------|
| **B** (double-tap quickly) | Toggle autorun on/off |
| **L3** (left stick click) | Toggle autorun (only if L3 has no other binding) |

When autorun is on, hold **B** to walk instead of run.

#### Unchanged from standard handheld

**A** jump, **X** crouch, **L1/R1** weapon cycle, **Start** pause, **Select** PDA, **Guide** / shoulder combo for system menu, **Select+Start** to quit the port.

### In-game menus (pause, PDA, mission select)

These use the classic Dark Forces UI (not ImGui).

| Input | Action |
|-------|--------|
| **D-Pad** or **left stick** | Move selection / scroll lists |
| **A** | Confirm / activate |
| **B** | Back / cancel |

- **Pause menu** — **Start** during gameplay.
- **PDA** — **Select** during gameplay; **B** closes it.
- **Mission / agent selection** (between missions) — **D-Pad** left/right changes agent or mission; **A** confirms.

### System menu (TFE settings)

Full engine configuration (graphics, saves, input remapping, etc.). This is separate from the in-game pause menu.

**Open**

| Input | Action |
|-------|--------|
| **Guide** | Toggle system menu |
| **L1 + L2 + R1 + R2** (all held, triggers past halfway) | Toggle system menu (pads without Guide) |
| **Alt+F1** | Keyboard |

**Navigate**

| Input | Action |
|-------|--------|
| **D-Pad** or **left stick** | Move focus in the current panel |
| **A** | Open a sidebar tab / toggle option / activate control |
| **L1** or **D-Pad Left** | Focus the **tabs** list (left column) |
| **R1** or **D-Pad Right** | Focus the **settings** panel (right column) |
| **Right stick** | Move the on-screen pointer (sliders, small checkboxes, file lists) |

**Close**

| Input | Action |
|-------|--------|
| **B** | Close and return to game |
| **Guide** | Close |
| **L1 + L2 + R1 + R2** | Close |

Sidebar sections: About, Game Settings, Save, Load, Replay, Input, Graphics, Hud, Enhancements, Sound, System, Accessibility, Developer.

In **Graphics**, choose **Match Window** to keep virtual resolution synced to the display size.

### Exit the port (PortMaster)

| Input | Action |
|-------|--------|
| **Select + Start** | Quit (handled by PortMaster `gptokeyb`, not the game) |

### External gamepad (HDMI / USB / Bluetooth)

If a real controller is connected (e.g. docked Switch Pro, DualSense, Xbox pad), the port **ignores the built-in handheld controls** so SDL only sees the external pad. Set `TFE_IGNORE_HANDHELD=1` to force-ignore the built-in pad, or `TFE_IGNORE_HANDHELD=0` to disable auto-detection.

## Handheld quality-of-life

- **Boot straight into the game** — skips the desktop ImGui launcher and mod picker when game data is found.
- **Automatic first-run setup** — widescreen, display-matched resolution, fullscreen, and sensible renderer defaults (see [Graphics notes](#graphics-notes)).
- **Handheld-tuned UI** — larger ImGui layout, gamepad navigation in the system menu, virtual cursor on the right stick for fine controls.
- **Save / Load in system menu** — gamepad-friendly file list and confirmation popups.
- **D-Pad movement layer** — walk/strafe on the D-Pad without tying up the **Y** button; tools stay on **Y + D-Pad**.
- **Stickless profile** — tank controls, L2 strafe modifier, **Y+R2** alt-fire, and autorun double-tap when `ANALOG_STICKS < 2` (see [Handhelds without analog sticks](#handhelds-without-analog-sticks)).
- **Square display support** — 1:1 widescreen stretch on 1:1 panels; Graphics menu keeps widescreen enabled.
- **GPU with safe fallback** — tries OpenGL/GLES GPU renderer first (including Mali Bifrost via 2D texture-buffer emulation); falls back to software only when GLES lacks the required features.
- **ArkOS sound workaround** — launcher restores `.asoundrc` from backup when needed.

Remap any action under **System menu → Input** (controller and keyboard).

## Saves

Portable install: `settings.ini` and saves live under `theforceengine/` when launched from PortMaster.

| Location | Contents |
|----------|----------|
| `theforceengine/settings.ini` | Game and graphics settings |
| `theforceengine/Saves/` | Save games |
| `theforceengine/Screenshots/` | Screenshots |
| `theforceengine/input.cfg` | Control bindings |

When using `TFE_DATA_HOME` (desktop `./run.sh`), per-user data can also live under `theforceengine/conf/`.

## Build (porters)

```bash
./build.sh              # Docker aarch64 + x86_64 (Ubuntu 20.04 / glibc 2.31)
./build.sh --native     # host toolchain, no Docker
./build.sh --x86_64-only
./run.sh --find-game    # show detected install path
./run.sh --game-root=/path/to/DARK.GOB/parent
```

Engine source: `TheForceEngine/` (fork of luciusDXL/TheForceEngine).
