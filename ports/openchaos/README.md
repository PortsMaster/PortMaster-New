## Notes

OpenChaos is a fan modernization of Urban Chaos, based on the released original source code and requiring original game data. This PortMaster package runs the OpenGL ES handheld build with controller-first defaults and a PortMaster launcher for small Linux handhelds.

The current release package is `aarch64` only. It ships an SDL3 shim that uses
the device's SDL2 runtime, plus the required ARM64 shared libraries under
`openchaos/libs.aarch64/`.

This package does not include Urban Chaos game data. Copy your own game resources
into `openchaos/assets/` before launching, including:

- `clumps/`
- `data/`
- `text/`
- `config.ini`
- the other resource folders from the original game install

When those resources are present, the launcher runs Open Chaos from
`openchaos/assets/`. At minimum, the game expects `clumps/frontend.txc`,
`data/DARCI1.all`, and a language file such as `text/lang_english.txt`.
Steam game files have been verified to work with this package.

### Credits

#### Urban Chaos modernization

Thanks to [UltimaBeaR](https://github.com/UltimaBeaR/OpenChaos) for the modernization of *Urban Chaos* through OpenChaos.

Thanks to the Urban Chaos fork chain:

* [Mike Diskett](https://github.com/dizzy2003/MuckyFoot-UrbanChaos) — released the original *Urban Chaos* source code under the MIT license in 2017.
* [Kai Stüdemann](https://github.com/kstuedem/MuckyFoot-UrbanChaos) — modernized the codebase with VS2017 support, SDL2/OpenAL, removal of legacy D3D/DirectSound/DirectPlay, rendering fixes, and inline assembly cleanup.
* [Jordan Davidson](https://github.com/jordandavidson/MuckyFoot-UrbanChaos) — added vcpkg integration and VS2019 support.
* [PieroZ](https://github.com/PieroZ/MuckyFoot-UrbanChaos) — contributed rendering fixes, editor work, mods, and utilities. OpenChaos was forked from and references this repo.

#### Original creators

Thanks to Mucky Foot Productions Ltd.

#### Porting support

Thanks to bmdhacks for the SDL3-to-SDL2 backend shim.

#### Testing

Thanks to the testers:

* Jabar
* mikerx
* MarkDonut
* Terror Senpai
* NotYerAvgPorter

#### Handheld port

Modded for handhelds by [jckhng](https://github.com/jckhng/OpenChaos/tree/portmaster-aarch64-gles).


## Controls

Open the in-game Options menu and set Controls to HANDHELD for the recommended
PortMaster layout, or CUSTOM to use `openchaos/controls/gamepad.json`.

| Button | Action |
|--|--|
| Left stick | Move |
| Right stick | Camera |
| A / Cross | Jump |
| B / Circle | Sprint / back |
| X / Square | Punch / shoot |
| Y / Triangle | Kick / siren while driving |
| L1 | Aim / back walk / brake while driving |
| L2 | Tactical / roll / reverse while driving |
| R1 | Use / interact |
| R2 | Accelerate while driving |
| R3 | Inventory / weapon cycle |
| D-pad | Weapon shortcuts |
| Start | Pause |
| Select / Back | PortMaster quit combo with Start |

## Custom Controls

Edit `openchaos/controls/gamepad.json`, then select Controls: CUSTOM in the
in-game Options menu. The file maps game actions to SDL gamepad button names.
Accepted names are `south/a/cross`, `east/b/circle`, `west/x/square`,
`north/y/triangle`, `select/back/view`, `start/menu/options`, `l1/lb`, `r1/rb`,
`l2/lt`, `r2/rt`, `l3/left_stick`, `r3/right_stick`, `dpad_up`, `dpad_down`,
`dpad_left`, `dpad_right`, and `none`.

Punch/shoot has two fields: `punch` for a digital button and `punch_trigger` for
an analog trigger. Set `punch_trigger` to `none` if you want punch/shoot only on
the digital button.

Movement, camera look, D-pad weapon shortcuts, and proportional analog driving
remain fixed in this first custom-binding version.
