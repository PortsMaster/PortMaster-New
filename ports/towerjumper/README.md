## Notes

Thanks to [Dariasteam](https://github.com/Dariasteam/TowerJumper) for making TowerJumper, a free Godot remake of the helix tower-jumping game with randomly generated levels and swappable colour palettes.

Runs on the Godot 2.1.6 FRT runtime, downloaded automatically by PortMaster. The original touch-drag control has been extended so the tower can also be rotated with the D-Pad or left stick.

## Controls

| Button | Action |
|--|--|
| D-Pad Left / Left Stick Left | Rotate tower left |
| D-Pad Right / Left Stick Right | Rotate tower right |
| X | Toggle sound |
| Y | Toggle shadows |
| Start + Select | Quit |

## Build

TowerJumper needs no compiling: the project is packed into a Godot 2 `.pck` and run on the FRT runtime.

```bash
git clone https://github.com/Dariasteam/TowerJumper.git
```

Apply the gamepad input patch to `input_handler.gd`, then pack the project's runtime files (`engine.cfg`, `*.gd`, `palette.json`, `icon.png`, `Scenes/`, `Materials/`, `Mesh/*.msh`, `Sprites/`, `Fonts/`, `Sound/`) into `towerjumper.pck`, using the Godot 2.1 editor's export or any PCK v0 packer.
