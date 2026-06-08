## Notes

Thanks to [ConcernedApe](https://www.stardewvalley.net/) for creating Stardew Valley.

Thanks to the [MonoGame](https://github.com/MonoGame/MonoGame) project for the framework that makes this port possible.

Thanks to JohnnyonFlame for the original Stardew Valley PortMaster port and help with this mainline port.

Mainline port work by Producdevity.

This port requires the Windows Steam version of Stardew Valley. Install the regular mainline Steam build, then copy all files from the Stardew Valley install folder into `ports/stardewvalleymainline/gamedata`.

Make sure Stardew Valley is not opted into the legacy _compatibility_ branch. The port patches the copied game files automatically on launch.

SMAPI is bundled. Leave `ports/stardewvalleymainline/Mods` empty for vanilla play, or copy SMAPI mods into that folder to launch through SMAPI automatically. Do not place user mods inside `gamedata/Mods`.

**SMAPI support is experimental.** Some mods may not work due to native Windows or x64 dependencies or not having enough memory.

### Steam Instructions

- [Open Steam console](steam://open/console)
- Copy and paste command: `download_depot 413150 413151 4278718763097142923`
- Copy the downloaded depot contents from `steamapps/content/app_413150/depot_413151` into `ports/stardewvalleymainline/gamedata`.

## Controls

| Button             | Action                 |
| ------------------ | ---------------------- |
| Left Stick / D-Pad | Move / menu navigation |
| Right Stick        | Move cursor            |
| A                  | Confirm / interact     |
| B                  | Cancel / back          |
| X                  | Use tool               |
| Y                  | Open menu              |
| L1 / R1            | Cycle toolbar row      |
| L2 / R2            | Cycle toolbar item     |
| Start              | Pause / open menu      |
| Select             | Open Journal           |
