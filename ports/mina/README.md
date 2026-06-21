Thank you to Yacht Club Games for creating such an incredible game,
and to the [Darling Project](https://www.darlinghq.org/) whose macOS
compatibility layer provided the foundation for Machismo.

Mina the Hollower is a top-down action-adventure from the creators of Shovel Knight. Whip your foes and burrow through the cursed Tenebrous Isle in a richly detailed 8-bit world!

## Installation

This port requires the **macOS** version of the game. You can install from either **GOG** or **Steam**.

### Option A: GOG (recommended — simplest)

1. Buy Mina the Hollower on [GOG](https://www.gog.com/game/mina_the_hollower).
2. Download the **macOS** installer (`.pkg` file).
3. Place the `.pkg` file in the port's `gamedata/` directory:
```
mina/
└── gamedata/
    └── mina_the_hollower_*.pkg           <- base game (required)
```
4. Launch the game — extraction happens automatically on first run.

**Note:** The `.pkg` takes several minutes to extract on handheld
devices. Be patient on first launch. The final install is about 1GB,
but extraction needs temporary space — make sure you have at least
2GB free.

### Option B: Steam

1. Buy Mina the Hollower on [Steam](https://store.steampowered.com/app/1875580/Mina_the_Hollower/).
2. Download the Mac depot. You need the Apple Silicon depot.

**Steam Console method:**
Open the Steam console by entering `steam://open/console` in your browser, then run:
```
download_depot 1875580 1875584
```
After the download, Steam will print the path where files were saved (usually under `steamapps/content/app_1875580/`).

3. Place the downloaded depot folder into the port's `gamedata/` directory:
```
mina/
└── gamedata/
    └── Mina the Hollower.app
```
4. Launch — the patcher will install the bundle automatically.

**Note:** Mina the Hollower has no DLC, so a single base-game installer is all you need.

## Controls
The game uses the controller natively. Use PortMaster's standard hotkey to quit.

## Licenses
Game assets are proprietary and must be purchased from Steam or GOG.
Open-source component licenses are in the `licenses/` directory:
- **Machismo / libgothic_patches** — GPL v3.0 (based on Darling)
- **libc++ / libc++abi (LLVM)** — Apache 2.0 with LLVM Exception
- **SPIRV-Cross** — Apache 2.0
- **SPIRV-Tools** — Apache 2.0
