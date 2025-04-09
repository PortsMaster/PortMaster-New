# Doom Engines -- A PortMaster implementation of Crispy Doom and GZDoom to play Doom WADs

## Installation
This port comes with the free Doom shareware and Freedoom1 and Freedoom2 WAD files. To use your own, place your WAD files in `ports/doomengines/iwads`.

## Versions
GZ Doom is on version `4.11.3` which is the latest known version to have functional level teleports. Doom Fusion requires at least `4.13.0` which has broken level teleports.

Crispy Doom is on version `7.0.0`.

## Play
To use addon mods, place `.pk3` files in `ports/doomengines/mods` (or whatever folder you want really) and list the `.pk3` files to load in `doomfiles/*.doom` for the relevant game. The launcher will search `doomfiles` and list its subfolders as well as any `.doom` files. Selecting a folder within the launcher will move into that subfolder, and pressing B will move backwards in the hierarchy.

Use the Left Shoulder and Right Shoulder buttons in the launcher to select which engine to use.

## Default Controls

| **Button**       | **Action**            |
|------------------|-----------------------|
| SELECT           | Toggle Menu           |
| START            | Use Inv Item          |
| DPAD U/D         | Move forward/back     |
| DPAD L/R         | Scroll inventory      |
| LEFT ANALOG      | Move / strafe         |
| RIGHT ANALOG     | Look / Turn           |
| L1               | Prev Weapon           |
| R1               | Next Weapon           |
| L2               | Secondary Fire        |
| R2               | Primary Fire          |
| A                | Use / Confirm         |
| B                | Toggle Menu           |
| X                | Toggle Automap        |
| Y                | Jump                  |
| L3               | Toggle Run            |
| R3               |                       |

\* On single stick devices, the analog stick performs the look/turn action and the d-pad strafes.

\*\* On d-pad only devices, the d-pad performs movement and turning.

Additional keybinds can be assigned within the `configs/*.gptk` files as needed. See [documentation](https://portmaster.games/gptokeyb-documentation.html#hotkey-button-for-additional-key-assignments) for doing this.

### Interactive Input Controls

When saving a game, using the key combination `START + DPAD DOWN` will enable an interactive input mode that works like entering high score initials on an arcade machine. The control scheme after activating this mode is as follows:

| **Button**       | **Action**             |
|------------------|------------------------|
| DPAD UP          | Previous letter        |
| DPAD DOWN        | Next letter            |
| DPAD RIGHT       | Next character         |
| DPAD LEFT        | Previous character     |
| L1               | Jump back 13 letters   |
| R1               | Jump forward 13 letters|
| SELECT           | Delete all characters  |
| START/A          | Confirm                |

## Mod
The launcher lists `*.doom` files in `doomengines/doomfiles` and uses their information to construct arguments passed to the engines. It performs file validation and will not display menu options for any games that are missing data. To create a `*.doom` file, open a text editor and add the following:

- `ENGINE` - The engine to use (crispydoom or gzdoom). This line can be used to enforce a specific engine regardless of the engine selected in the launcher.
- `IWAD` - File name of the WAD to use.
- `MOD` - Any `.pk3`, `.wad`, or `.zip` files to load after the data. You can load any number of files this way.
- `DIFF` - Sets the difficulty level (0 = I'm too young to die, 4 = Nightmare).
- `MAP` - Warps to map (e1m1 = Doom Episode 1 Map 1, 01 = Doom II map 01).
- `INI` - For GZ Doom, specifies which config file to load. Useful for alternate bindings.

Follow this example `doomfiles/Doom.doom` which launches vanilla Doom:

```
IWAD=iwads/DOOM.WAD
-- end --
```

This example `doomfiles/Addons/Sigil.doom` launches SIGIL by John Romero with the third difficulty option selected:

```
IWAD=iwads/DOOM.WAD
MOD=mods/SIGIL.wad
DIFF=3
MAP=e5m1
-- end --
```

This example `doomfiles/Mods/The Legend of Doom.doom` launches the mod The Legend of Doom which only runs in GZ Doom:

```
ENGINE=gzdoom
IWAD=iwads/FREEDOOM2.WAD
MOD=mods/LegendOfDoom-1.1.0.pk3
MOD=mods/LoDMusicLoops.pk3
-- end --
```

You do not need to adhere to the existing folder structure. For example, one tester preferred to keep single map mods separate from gameplay altering mods, and so they created `doomengines/maps`. This still follows the filepath rules for file loading, so `MOD=maps/SIGIL.wad` is just as valid as `MOD=mods/SIGIL.wad`.

## The Master Levels
Doom II comes with an addon called The Master Levels, but they're sometimes packaged as one WAD per level. You can use a WAD editor to merge them into one WAD (example, `masterlevels.wad` how it is for the commercial `Doom + Doom II` release) and load that as a mod to `DOOM2`. If you manage to do this, you will want to also load the [Master Levels Menu Interface](https://www.doomworld.com/idgames/utils/frontends/zdmlmenu) mod so you can actually select the addon.

## Building
GZ Doom does not require building as it has `arm64.deb` artifacts available on its [releases page](https://github.com/ZDoom/gzdoom/releases).

Crispy Doom is also relatively simple, see linux build instructions on the [crispy-doom repository](https://github.com/fabiangreffrath/crispy-doom/wiki/Building-on-Linux).

## Thanks
id Software -- Original games  
GZDoom Team -- GZDoom, see license file for individual contributions.  
Crispy Team -- Crispy engines, see license files for individual contributions.  
Andrew Hushult -- The [music](https://www.youtube.com/watch?v=Yctbs7A4KHk) used for the launcher.  
Slayer366 -- Original GZDoom push and port assistance.  
DDRSoul -- Previously customized Slayer366's GZDoom bundle for muOS and provided Crispy Doom.  
Cyril Deletre -- HackSDL to disable sdl gamepad allowing universal controls.  
PortMaster Discord -- Testers.  
