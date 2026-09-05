# Drywater — PortMaster port

An Old West survival and creature-taming game. Gather, craft, build a homestead,
and tame the horses, bears, elk and cougars that share the valley.

**Target hardware:** Anbernic RG35XX-H (Allwinner H700, ARM64) on muOS.
Should suit other H700-class handhelds; only the RG35XX-H is tested.

---

## What you need to buy, and where it goes

**Drywater is a commercial port.** This shell (the launch script and the
supporting files PortMaster installs) is free. The game itself —
`drywater.pck` — is sold separately on itch.io:

**<https://rcadden.itch.io/drywater>**

Buy it there, then drop the file at:

```
ports/drywater/drywater.pck
```

That one file is the only thing you supply. Everything else in this port
comes from PortMaster.

**Check you're on the right build:** the version shows in the bottom-right
corner of the title screen, and in a plain-text `VERSION` file inside the
`drywater/` folder — readable off the SD card without launching anything.

### Updating

Re-download `drywater.pck` from your itch.io library (a purchase there is a
permanent download key — every future release is a free re-download from the
same link) and overwrite the old file. `Drywater.sh` compares its own
expected version against the file you dropped in and will tell you plainly
if they disagree, rather than failing looking like a crash:

```
Your Drywater game data is v1.1 — this port needs v1.2.
Re-download drywater.pck from https://rcadden.itch.io/drywater
```

### Reporting a problem

Please include:

1. **The version** from the title screen or the `VERSION` file.
2. **Your device and firmware** (e.g. "RG35XX-H, muOS 2405").
3. **What you did**, in enough detail to try it again.
4. **`log.txt`** — written to the `drywater/` folder on every run, next to the
   `.pck`. For a crash or a failure to launch, this is the single most useful
   thing you can attach.

For a launch failure specifically, re-run with diagnostics on: edit
`Drywater.sh` and change `DRYWATER_DEBUG="${DRYWATER_DEBUG:-0}"` to `:-1`,
launch once, then send `log.txt`.

---

## Controls

| Button | Exploring | Build mode |
|---|---|---|
| D-pad / Left stick | Move | Move cursor |
| A | Interact | Confirm placement |
| B | Attack | Cancel |
| X | Cycle weapon | Cycle building |
| L1 | Quick food | Demolish |
| L2 | Flee | — |
| R3 (right stick click) | Equip clothing | — |
| R2 | Toggle build mode | Exit build mode |
| Select | Pack (inventory) | — |
| Start | Pause | — |

In menus the D-pad or left stick moves the highlight, **A** confirms and **B**
backs out — matching muOS itself, so moving between the launcher and the game
does not invert the player's thumb.

Face buttons intentionally do double duty; build mode is modal.

Not bound on gamepad, still available on a keyboard: **inspect** and **drop**.
`drop` is covered per-item by the Pack's Drop panel. `inspect` is a side
function and is intended to become an equippable spyglass rather than hold a
permanent button.

### Why these buttons, and why Y / R1 are missing

**This layout only holds while `DRYWATER_RAW_JOYPAD=1` in `Drywater.sh`.** The
bindings are RAW joypad indices; flipping that flag back to `0` restores SDL's
mapping and makes every one of them wrong.

Measured on an RG35XX-H, 2026-07-29:

| Physical | Raw index |
|---|---|
| A / B / X | 0 / 1 / 2 |
| L1 / L2 | 3 / 4 |
| R3 / R2 | 5 / 6 |
| Select / Start | 9 / 10 |
| D-pad up/down/left/right | 11 / 12 / 13 / 14 |
| Left stick | axis 4 (X), axis 2 (Y) |
| Right stick | axis 3 (X), axis 5 (Y) |

**Y, R1 and left-stick-click report nothing**, even with SDL's mapping
suppressed. Raw indices 7, 8 and 15 are unaccounted for — exactly three — so
those buttons are almost certainly wired there and never reach userspace on this
firmware. That cost the approved layout two slots: `quick_food` moved Y→L1 and
`equip clothing` moved R1→R3.

Note the left stick is on axes **4 and 2**, not the conventional 0 and 1. Every
binding before this used 0/1, so the stick did nothing and the D-pad was
carrying all movement.

---

## Manual install

**Until this port is live in the PortMaster store, install it by hand.**
Once it is listed, PortMaster's own installer places everything below except
`drywater.pck` for you — you would only ever need to supply that one file, as
described above.

**1. Runtimes.** Both of these must be in `<controlfolder>/libs` on the device —
on muOS that is `/mnt/mmc/MUOS/PortMaster/libs/`.

| Runtime | Size | Why |
|---|---|---|
| `godot_4.6.3.aarch64.squashfs` | 23 MB | matches this project's engine exactly |
| `weston_pkg_0.2.aarch64.squashfs` | 53 MB | muOS has no X11 or Wayland of its own |

**Do not use <https://portmaster.games/runtimes.html> — it does not list
either file.** Pull them straight from the runtime repository instead
(both verified HTTP 200, valid squashfs):

```
https://raw.githubusercontent.com/PortsMaster/PortMaster-New/main/runtimes/godot_4.6.3.aarch64.squashfs
https://raw.githubusercontent.com/PortsMaster/PortMaster-New/main/runtimes/weston_pkg_0.2.aarch64.squashfs
```

`Drywater.sh` asks harbourmaster to fetch them if they are missing, but that
does not work on every setup — copy them manually if the launch reports them
absent.

**2. The port.** On muOS the pieces go to *different* places:

- `Drywater.sh` → `/roms/PORTS/Drywater.sh` (this is what muOS scans)
- `drywater/` → `/ports/drywater/` (**not** under `roms`)
- Your purchased `drywater.pck` → `/ports/drywater/drywater.pck`

On ArkOS / AmberELEC / most other firmware, `Drywater.sh` and `drywater/` sit
together instead, under `/roms/ports/`.

Putting them together in one folder on muOS specifically is the ArkOS/AmberELEC
layout, and muOS will not find the port that way.

Saves live in `drywater/conf/` beside the port, not in `$HOME`.

**Don't rename anything.** The launch script looks for a folder called exactly
`drywater`, and muOS scans for a script called exactly `Drywater.sh`. Renaming
either breaks the launch with a "could not locate the drywater game folder"
error.

### Verified paths on Ricky's RG35XX-H (2026-07-29)

**The runtimes and the port can live on DIFFERENT CARDS.** PortMaster installed
itself to SD1 while the ports directory resolved to SD2 on this device, so a
single-card assumption can send half the files to a place nothing reads.

| | On-device path | Over USB |
|---|---|---|
| Runtimes | `/mnt/mmc/MUOS/PortMaster/libs/` | `RG35XX-H\SD1\MUOS\PortMaster\libs` |
| Game files | `/mnt/sdcard/ports/drywater/` | `RG35XX-H\SD2\ports\drywater` |
| Launch script | `/mnt/sdcard/roms/PORTS/` | `RG35XX-H\SD2\roms\PORTS` |
| Launch log | `/mnt/sdcard/ports/drywater/log.txt` | `RG35XX-H\SD2\ports\drywater\log.txt` |
| Input probe log | `…/drywater/conf/godot/app_userdata/Drywater/input_probe.log` | same, under `SD2\ports\drywater\conf\…` |

`Drywater.sh` derives the game directory from PortMaster's `$directory` and
probes several fallbacks, so it does not depend on these exact paths — they are
recorded for finding logs by hand.

---

## Known limitations

- Balance is still being tuned — prices, drain rates, and difficulty are all
  provisional.
- The rider's far leg isn't hidden behind the horse when riding.
- You wake up *beside* a proper bed rather than on it. Deliberate for now.

---

## Notes for future porters

- **Weston is mandatory, not optional.** muOS provides neither X11 nor Wayland.
  A stock Godot 4 Linux binary tries X11, falls back to Wayland, and dies with
  `Unable to create DisplayServer, all display drivers failed`. There is no
  direct-launch fallback worth keeping.
- **Shared runtime, ships only the `.pck`.** `godot_4.6.3` is an exact engine
  match. This also sidesteps a trap: Godot 4.6 *release export templates* are
  compiled with path overrides disabled and reject `--main-pack` outright, so a
  self-contained binary would need its `.pck` renamed to match the executable
  basename. The runtime binary has overrides enabled, which is how every Godot
  port loads its pack.
- **No gptokeyb.** Every action carries a real joypad binding in the InputMap,
  so SDL feeds Godot directly. Layering gptokeyb on top would double-fire.
- **Renderer.** The project has used the Compatibility (OpenGL ES 3) renderer
  since its first sprint, so `--rendering-driver opengl3_es` is the native fit.
- **Troubleshooting.** `Drywater.sh` tees everything to `drywater/log.txt` and
  prints an environment report — firmware, arch, resolution, resolved paths,
  runtime contents, and which binary it launched — before doing anything.

## Credits

Game and port by Ricky Cadden.
