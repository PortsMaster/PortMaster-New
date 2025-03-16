## Compatibility
Unfortunately, this port is not compatible with ArkOS, due to GCC requirements during building.

## Controls

### Mouse
| Button               | Action                              |
| :------------------- | :---------------------------------- |
| Left analog stick    | Mouse                               |
| R1                   | Left mouse button                   |
| R2                   | Right mouse button                  |

### Game Controls
| Button               | Action                              |
| :------------------- | :---------------------------------- |
| Start                | Toggle turn-based / real-time mode  |
| Select               | Dismiss text box                    |
| L3                   | Quick reference                     |

### Character controls
| Button               | Action                              |
| :------------------- | :---------------------------------- |
| D-pad                | Move character                      |
| Right stick up/down  | Look up / down                      |
| L2                   | Hold to run                         |
| R3                   | Hold to strafe                      |
| A                    | Attack                              |
| B                    | Search/activate body, chest, object |
| X                    | Jump                                |
| Y                    | Yell                                |
| L1                   | Cast readied spell                  |

On the spells page, double-click to choose a spell, then cast with mouse. Or click 'Set Spell' and then cast with L1.

### Flying (only if fly spell is activated)
The hotkey is Function or Select
| Button               | Action                              |
| :------------------- | :---------------------------------- |
| Hotkey + R1          | Fly down                            |
| Hotkey + R2          | Fly up                              |
| Hotkey + L1/L2       | Land                                |

## Acknowledgements
Thanks to 3DO and New World Computing for the original game, and to the [OpenEnroth team](https://github.com/OpenEnroth/OpenEnroth.git) for their open source reimplementation.

## Port information
The port has been modified to run on OpenGLES, and a custom cursor has been added (for platforms where the default cursor doesn't work). Game controller support has been disabled, and gptokeyb is used instead.

Thanks to Ganimoth for help with AmberELEC and Rocknix compatibility.

See [BUILDING.md](https://github.com/PortsMaster/PortMaster-New/blob/main/ports/openenroth/openenroth/BUILDING.md) for building instructions.
