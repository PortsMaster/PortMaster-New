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

## Multiplayer (LAN)

JKDF2 **LAN multiplayer** works on **aarch64 handhelds** and **x86_64** (RetroDECK / desktop). The port uses **GameNetworkingSockets** (provider **Valve GNS** in the multiplayer menu). Internet matchmaking and Steam are **not** supported — host and clients must be on the **same local network**.

### Requirements

1. **Game data:** `JK1MP.gob` must be present under `openjkdf2/jk1/episode/` (from your GOG or Steam install).
2. **Bundled libs:** Do not delete these from the port zip:
   - **aarch64:** `openjkdf2/libs.aarch64/libGameNetworkingSockets.so`, `libcrypto.so.1.1`, `libssl.so.1.1` (plus `libopenal.so`)
   - **x86_64:** `openjkdf2/libs.x86_64/libGameNetworkingSockets.so`, `libcrypto.so.1.1`, `libssl.so.1.1`

   OpenSSL 1.1 is bundled because most systems ship OpenSSL 3.x; without these libs multiplayer falls back to a stub and shows **Screaming Into The Void (GNS Failed)** in `log.txt`.

3. **Network:** Same Wi‑Fi/LAN. Default game port is **27020** (UDP). On the **host PC**, allow that port through the firewall if needed.

### Quick start: PC host + handheld join

**On the PC (x86_64):**

1. Launch the port and open **Multiplayer → Start Game**.
2. Configure the match (or rely on defaults) and start hosting.
3. Note the PC’s LAN IP (e.g. `192.168.1.42`).

**On the handheld (aarch64):**

1. On a PC, copy `openjkdf2/conf/mp.conf.example` to `openjkdf2/conf/mp.conf` on the SD card.
2. Edit `mp.conf`:

```ini
[join]
host=192.168.1.42:27020
password=

[character]
name=Kyle
rank=0
```

3. Launch the port → **Multiplayer → Join Game**.

The join IP, password, and character name/rank are read from `mp.conf` so you can avoid typing on the handheld.

### `mp.conf` reference

Path on device: `openjkdf2/conf/mp.conf` (edit on PC; saves live under `conf/openjkdf2/` when you play).

| Section | Keys | Purpose |
|---------|------|---------|
| `[join]` | `host` (IP or `IP:port`), `password` | **Join Game** — target host |
| `[character]` | `name`, `rank` (0–8) | **New Character** prefill; auto-load existing `.mpc` if present |
| `[host]` | `game_name`, `max_players`, `port`, `episode`, `map`, limits, `password`, etc. | **Start Game** defaults on the host |

Example host section:

```ini
[host]
game_name=Handheld LAN
max_players=4
port=27020
episode=JK1MP.gob
map=m2.jkl
max_rank=8
score_limit=10
time_limit=10
```

### Character on handheld

Set `name` and `rank` under `[character]`. On **New Character**, the fields are prefilled — confirm to create the `.mpc` without a keyboard. If the character already exists, it is loaded automatically before join or host.

### Troubleshooting

| Symptom | What to check |
|---------|----------------|
| **Screaming Into The Void (GNS Failed)** | Missing `libcrypto.so.1.1` / `libssl.so.1.1` in `libs.*`; reinstall the port zip. |
| **Failed to dlopen libGameNetworkingSockets.so** | Same as above; read `openjkdf2/log.txt`. |
| Join times out | Wrong IP, different subnet, firewall on host, or host not in **Start Game**. |
| No maps / episode error | `JK1MP.gob` missing from `jk1/episode/`. |
| Provider shows **Valve GNS** | Networking stack loaded correctly. |

Check `openjkdf2/log.txt` on the SD card (or next to the binary on PC) for lines such as `Loaded libGameNetworkingSockets.so successfully.`

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

Engine submodule + scripts live in the [port repository](https://github.com/juanvillacortac/OpenJKDF2). From a clone with submodules:

```shell
./build.sh
```

Fork with GLES/handheld patches: [juanvillacortac/OpenJKDF2](https://github.com/juanvillacortac/OpenJKDF2).

## Thanks

- [LucasArts](https://www.lucasarts.com/) for the original game
- [OpenJKDF2](https://github.com/shinyquagsire23/OpenJKDF2) developers and community
- [PortMaster](https://portmaster.games/) for handheld port tooling
- Slayer366 for feedback and testing on porting process
