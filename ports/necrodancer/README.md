# Crypt of the NecroDancer
Thank you to Brace Yourself Games for creating such an incredible game,
and to the [Darling Project](https://www.darlinghq.org/) whose macOS
compatibility layer provided the foundation for Machismo.

Crypt of the NecroDancer is an award winning hardcore roguelike rhythm game. Move to the music and deliver beatdowns to the beat!

## Installation

This port requires the **macOS** version of the game. You can install from either **GOG** or **Steam**.

### Option A: GOG (recommended — simplest)

1. Buy Crypt of the NecroDancer on [GOG](https://www.gog.com/game/crypt_of_the_necrodancer).
2. Download the **macOS** installer (`.pkg` file). If you own DLC, download those macOS `.pkg` files too.
3. Place all `.pkg` files in the port's `gamedata/` directory:
```
necrodancer/
└── gamedata/
    ├── crypt_of_the_necrodancer_*.pkg           <- base game (required)
    ├── dlc_crypt_of_the_necrodancer_amplified_*.pkg  <- Amplified DLC (optional)
    └── dlc_crypt_of_the_necrodancer_synchrony_*.pkg  <- Synchrony DLC (optional)
```
4. Launch the game — extraction happens automatically on first run.

**Note:** Each `.pkg` takes several minutes to extract on handheld
devices. Be patient on first launch. The final install is about 2GB,
but extraction needs temporary space — make sure you have at least
4GB free (6GB if installing with all DLC).

### Option B: Steam

1. Buy Crypt of the NecroDancer on [Steam](https://store.steampowered.com/app/247080/Crypt_of_the_NecroDancer/).
2. Download the two Mac depots. You need the Mac assets depot and the Apple Silicon binary depot.

**Steam Console method:**
Open the Steam console by entering `steam://open/console` in your browser, then run:
```
download_depot 247080 247082
download_depot 247080 247086
```
After each download, Steam will print the path where files were saved (usually under `steamapps/content/app_247080/`).

3. Place both downloaded depot folders into the port's `gamedata/` directory:
```
necrodancer/
└── gamedata/
    ├── depot_247082/          <- Mac assets depot
    │   └── NecroDancer.app/
    └── depot_247086/          <- Apple Silicon binary depot
        └── NecroDancerSP.app/
```
4. Launch — the patcher will merge the depots automatically.

**Note:** Steam DLC (Amplified, Synchrony) is not supported due to DRM. For DLC support, use the GOG version.

## Controls
No sticks needed, just dpad and buttons.

## Technical Details
This port uses [Machismo](https://github.com/bmdhacks/machismo) to load the arm64 Mach-O binary on aarch64 Linux.

## Licenses
Game assets are proprietary and must be purchased from Steam or GOG.
Open-source component licenses are in the `license/` directory:
- **Machismo / libsystem_shim / libgalaxy_shim** — GPL v3.0 (based on Darling)
- **libc++ / libc++abi** — Apache 2.0 with LLVM Exception
- **bgfx** — BSD 2-Clause
- **SFML** — zlib/libpng
- **LuaJIT** — MIT
