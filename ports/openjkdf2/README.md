## Notes

Star Wars Jedi Knight: Dark Forces II (1997) by **LucasArts**. This port runs the **OpenJKDF2** engine (thanks to [ShinyQuagsire](https://github.com/shinyquagsire23/OpenJKDF2) and contributors).

You must own the game and copy the original files from **GOG** or **Steam** into `openjkdf2/jk1/`. Optional expansion **Mysteries of the Sith** goes in `openjkdf2/mots/`. Launch it via the optional **Mysteries of the Sith** PortMaster entry, or switch from the in-game **Expansions & Mods** menu.

Launch follows the [PortMaster shell template](http://portmaster.games/packaging.html) in each `*.sh` wrapper. Low-RAM swap (`DEVICE_RAM < 2`, using Slayer366 swap script) and external gamepad handling live in the launchers / `openjkdf2/helpers/gamepad.inc`. Game data paths are resolved case-insensitively by the engine on Linux (ext4); launch scripts do not rename or move user files.

Saves and settings are stored under `openjkdf2/conf/`.

## Supported firmware (PortMaster)

**aarch64 handhelds:** Requires **PortMaster** with native **GLES** (Mali or equivalent).

| CFW | Ports folder (typical) | Status |
|-----|------------------------|--------|
| [knulli](https://knulli.org/) | `/userdata/roms/ports/` | Tested |
| [muOS](https://muos.dev/) | `/mnt/mmc/ROMS/Ports/` or `/roms/ports/` | Tested |
| [ROCKNIX](https://rocknix.org/) | `/roms/ports/` | Tested |
| [ArkOS / dArkOS](https://github.com/christianhaitian/arkos) | `/roms/ports/` or `/roms2/ports/` | Tested |
| AmberELEC / JELOS / UnofficialOS | `/roms/ports/` | Tested (aarch64 devices) |

**x86_64 Linux:** [RetroDECK](https://retrodeck.net/) / PortMaster on PC (Steam Deck, desktop). Uses `openjkdf2.x86_64` (OpenGL desktop build); handheld QOL env vars still apply.

**Not supported:** 32-bit **armhf** devices.

**Recommended hardware (aarch64):** Anbernic H700 family (RG35XX Plus/H/SP, RG34XX, RG40XX) or similar aarch64 handheld with 1 or 2 GB RAM and Mali GPU.

## Installation

1. Unzip the port to your CFW’s `ports/` folder (see table above).
2. Copy JKDF2 game data to `openjkdf2/jk1/` (`episode/`, `resource/`, `MUSIC/`, etc.).
3. (Optional) Copy MOTS data to `openjkdf2/mots/`.
4. Launch **Star Wars Jedi Knight - Dark Forces II** from PortMaster.

If the game fails to start, check `openjkdf2/log.txt` on the device SD card.

**SDL / video:** The port links dynamically against the firmware’s SDL (kmsdrm, GLES, audio). Do **not** ship `libSDL2*.so` or `libSDL2_mixer*.so` in `libs.aarch64/` — if an older zip left them there, delete those files and relaunch.

## Multiplayer

JKDF2 **LAN multiplayer** works on handheld (**aarch64**) and PC (**x86_64**) via **Valve GameNetworkingSockets**. Configure join/host defaults in `openjkdf2/conf/mp.conf` (copy from `mp.conf.example`).

**Full guide:** [openjkdf2/MULTIPLAYER.md](openjkdf2/MULTIPLAYER.md) — LAN and Internet (Tailscale/VPS), `mp.conf` reference, dedicated server (`run-dedicated.run`), bundled OpenSSL libs, and troubleshooting.

## Controls (handheld)

| Button | Action |
|--------|--------|
| Left stick / D-pad | Move |
| Right stick | Look |
| X | Use / Activate |
| A + D-pad / A + Joystick | Inventory / Force powers navigation |
| Y | Jump |
| A | Use inventory item / Force power |
| B | Crouch |
| L1 / R1 | Weapons prev / next |
| L2 / R2 | Fire 1 / Fire 2 |
| Start / Select | Pause menu (save, load, setup) |

Select+Start quits the port (`$GPTOKEYB` with `openjkdf2.gptk`, which unmaps default key injection so SDL keeps native gamepad).

## Build (porters)

Engine submodule + scripts live in the [port repository](https://github.com/juanvillacortac/openjkdf2-aarch64-portmaster). From a clone with submodules:

```shell
./build.sh
```

Fork with GLES/handheld patches: [juanvillacortac/OpenJKDF2](https://github.com/juanvillacortac/OpenJKDF2).

## Thanks

- [LucasArts](https://www.lucasarts.com/) for the original game
- [OpenJKDF2](https://github.com/shinyquagsire23/OpenJKDF2) developers and community
- [PortMaster](https://portmaster.games/) for handheld port tooling
- Slayer366 for feedback and testing on porting process
