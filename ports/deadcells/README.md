## Notes
Thank you to Motion Twin for this incredible game, as well as the Haxe
Foundation for such a maleable platform for building games.

## Important: Before You Start
The first time you launch the game, a one-time patching process will run
**on-device**. This process compiles, optimizes, and re-encodes the game's
assets for your hardware. **Expect it to take 4-8 hours** depending on your
device. Plug in your device, start the process, and walk away — it will
pick up where it left off if interrupted.

**DLC is only supported with the GOG version.** Steam copies will play the
base (vanilla) game only — Steam does not provide a way to extract DLC content.
If you want the full experience with all DLCs, purchase the game from GOG.

## Installation
### Gog Instructions
Place the **LINUX** version installer (eg: `dead_cells_1_26_0_75679.sh`) in the port's `gamedata` folder.
If you have installed the **linux** version already, you can copy the `res.pak`
and `hlboot.dat` files from the installations `game` folder into the port's `gamedata` folder.
### GOG DLC
You can copy the GoG DLC installers into the `gamedata` folder too.
### Steam Instructions
* Open Steam console: `steam://open/console`
* Copy and paste command: `download_depot 588650 588653 5814907161645516281`
* Open the folder where this depot was downloaded and copy `res.pak`
  and `hlboot.dat` into the port's `gamedata` folder.  On windows this folder will be `C:\Program Files (x86)\Steam\steamapps\content\app_588650\depot_588653`

## Building
The source code for building this port can be obtained by
contacting bmdhacks, but most of the tooling that went into it can be
found on his [Github Page](https://github.com/bmdhacks?tab=repositories)
- hashlink
- heaps
- hlbc

## Thanks
klops, Dia, Ganimoth, and Zehmaluco helped test early versions that did not run very well, and generally made the struggle less lonely.
BinaryCounter was a constant technical coach, and came up with the two coolest ideas in this project: Offline ASTC guides, and LLVM-IR recompilation.

