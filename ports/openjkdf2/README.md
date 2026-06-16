## Notes

Star Wars Jedi Knight: Dark Forces II (1997) by **LucasArts**. This port runs the **OpenJKDF2** engine (thanks to [ShinyQuagsire](https://github.com/shinyquagsire23/OpenJKDF2) and contributors).

You must own the game and copy the original files from **GOG** or **Steam** into `openjkdf2/jk1/`. Optional expansion **Mysteries of the Sith** goes in `openjkdf2/mots/`. Launch it via the optional **Mysteries of the Sith** PortMaster entry, or switch from the in-game **Expansions & Mods** menu.

Launch follows the [PortMaster shell template](http://portmaster.games/packaging.html) in each `*.sh` wrapper. External-gamepad and low-RAM swap helpers live in `openjkdf2/helpers/` (`gamepad.inc`, `swap.inc`). Game data paths are resolved case-insensitively by the engine on Linux (ext4); launch scripts do not rename or move user files.

Saves and settings are stored under `openjkdf2/conf/`.

## Supported firmware (PortMaster)

Requires **aarch64** and **PortMaster** with native **GLES** (Mali or equivalent).

| CFW | Ports folder (typical) | Status |
|-----|------------------------|--------|
| [knulli](https://knulli.org/) | `/userdata/roms/ports/` | Tested (RG34XX SP) |
| [muOS](https://muos.dev/) | `/mnt/mmc/ROMS/Ports/` or `/roms/ports/` | Expected |
| [ROCKNIX](https://rocknix.org/) | `/roms/ports/` | Expected |
| [ArkOS](https://github.com/christianhaitian/arkos) | `/roms/ports/` or `/roms2/ports/` | Expected |
| [Batocera](https://batocera.org/) | varies by device | Expected |
| AmberELEC / JELOS / UnofficialOS | `/roms/ports/` | Expected (aarch64 devices) |

**Not supported:** 32-bit **armhf** devices, this port ships `openjkdf2.aarch64` only.

**Recommended hardware:** Anbernic H700 family (RG35XX Plus/H/SP, RG34XX, RG40XX) or similar aarch64 handheld with 1 or 2 GB RAM and Mali GPU.

## Installation

1. Unzip the port to your CFW’s `ports/` folder (see table above).
2. Copy JKDF2 game data to `openjkdf2/jk1/` (`episode/`, `resource/`, `MUSIC/`, etc.).
3. (Optional) Copy MOTS data to `openjkdf2/mots/`.
4. Launch **Star Wars Jedi Knight - Dark Forces II** from PortMaster.

If the game fails to start, check `openjkdf2/log.txt` on the device SD card.

If stray entries appear in EmulationStation after updating, delete obsolete scripts and restart ES: `ports/openjkdf2/launch.run`, `ports/.openjkdf2.launch.inc`.

## Controls (handheld)

| Button | Action |
|--------|--------|
| Left stick / D-pad | Move |
| Right stick | Look |
| A | Use / Activate |
| B | Jump |
| X | Use inventory item / Force power |
| Y | Cycle weapon |
| L1 / R1 | Strafe |
| L2 / R2 | Inventory prev / next |
| Hold A + stick | Inventory selection |
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
