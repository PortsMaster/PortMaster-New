### Installation

#### GOG.com (recommended)
The simplest way to install all three games is to purchase the Medal of Honor: Allied Assault War Chest on gog.com. Select the offline installer. Download all three files (`setup...exe`, `setup...1.bin`, `setup...2.bin`) and put them in `ports/openmohaa/`. The first time you run the game, the patcher will be used to extract the game files. Note that the total installation size is around 2.5GB. 

#### PC files (unsupported)
If you own the Windows version of one or more of the games, you can use the files from your PC installation. You may need to patch the files as described [here](https://github.com/openmoh/openmohaa/blob/main/docs/getting_started_installation.md). Put the patched files (`main` and surrounding files and directories) in `ports/openmohaa/`. Note that the total installation size will be between 1 and 2.5 GB.

### Performance
This is a demanding game, so performance is modest on many handheld devices. For best performance, use a higher spec device, e.g. Retroid Pocket 5.

### Controls

| Button             | Action                          |
| :----------------- | :------------------------------ |
| Left stick         | Forward / back / strafe    WASD |
| Right stick        | Aim                       Mouse |
| R1                 | Primary attack             Left |
| R2                 | Secondary attack          Right |
| L1                 | Slow mouse / precise aim        |
| Hotkey + L2        | Previous weapon           Wheel |
| L2                 | Next weapon               Wheel |
| L3/R3 (hold)       | Walk                      Shift |
| A                  | Jump                      Space |
| B                  | Crouch                     Ctrl |
| X                  | Reload                        R |
| Y                  | Holster weapon                Q |
| D-pad up           | Objectives/scores           Tab |
| D-pad down         | Use                           E |
| D-pad left         | Quick save                   f5 |
| D-pad right        | Quick load                   f9 |

#### Quick weapon selection:
Hotkey plus:

| Button             | Action                          |
| :----------------- | :------------------------------ |
| Left stick up      | Pistol                        1 |
| Left stick right   | Rifle                         2 |
| Left stick down    | SMG                           3 |
| Left stick left    | MG                            4 |
| Right stick up     | Grenade                       5 |
| Right stick right  | Heavy                         6 |
| Left stick down    | Papers/binoculars             7 |

### Acknowledgements
Thanks to Electronic Arts for the original games, and to the [OpenMoHAA](https://github.com/openmoh/openmohaa/) team for creating an open-source version of MoHAA. 

Thanks to ptitSeb for the [gl4es](https://github.com/ptitSeb/gl4es) library, and to Jeod for the custom game launcher.

The game was compiled by beniamino and the launcher was created by Jeod.

### Port details
This is an arm64 build of the unmodified [source code](https://github.com/openmoh/openmohaa/). Graphics settings have been reduced for good performance on low-spec devices, but can be increased using the in-game options.

See [BUILDING.md](https://github.com/PortsMaster/PortMaster-New/blob/main/ports/openmohaa/openmohaa/BUILDING.md) for building instructions.
