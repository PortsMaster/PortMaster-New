### Manual

The Wesnoth manual is available [here](https://www.wesnoth.org/manual/stable/manual.en.html#_controls).

### Controls

| Button              | Action                                          |
| :------------------ | :---------------------------------------------- |
| D-pad               | Scroll                                          |
| Left analog         | Move mouse                                      |
| A                   | Select unit, move unit               Left mouse |
| B                   | Context menu, cancel action         Right mouse |
| X                   | Show enemy moves                         Ctrl-V |
| Y                   | Slow mouse                                      |
| Start               | End player's turn                    Ctrl+Space |
| Select              | Exit / cancel                               Esc |
| L1                  | Zoom in                                       - |
| L2                  | Zoom out                                      + |
| L3                  | Reset zoom                                    0 |
| R1                  | Cycle through units with moves remaining      N |
| R2                  | Toggle accelerated game mode             Ctrl-A |
| Right analog left   | Recruit unit                             Ctrl-R |
| Right analog right  | Repeat last recruit                  Ctrl-Alt-R |
| Right analog up     | Recall unit                               Alt-R |
| Right analog down   | Rename unit                              Ctrl-N |
| R3                  | Describe current unit                         D |

If you have no analog sticks, the D-pad will control the mouse.

In text entry boxes, you can press `hotkey + D-pad down` to enter text interactively:

| Button        | Action            |
| :-----------  | :---------------- |
| D-pad up/down | Choose character  |
| D-pad right   | Confirm character |
| D-pad left    | Delete character  |
| Start         | Confirm and exit  |
| Select        | Cancel text entry |

### Acknowledgements
Thanks to David White and many other contributors for creating the game. See [here](https://wiki.wesnoth.org/Credits) for credits.

Thanks to kloptops for his [SDL_sim_cursor](https://github.com/kloptops/SDL_sim_cursor) library.

Thanks to Slayer366, Fraxinus99, Ganimoth and ddrsoul for their help with the port.

### Building

The source code has been modified to add kloptops's sim_cursor library, which enables the mouse cursor on platforms that don't support a hardware cursor.

On Rocknix, commands are sent to sway before and after the game is run, to disable and re-enable hiding of the mouse cursor (which causes problems with click detection on touchscreen devices).

Various animations are disabled in order to save memory, and fit the game into 1GB.

See [BUILDING.md](https://github.com/PortsMaster/PortMaster-New/blob/main/ports/wesnoth/wesnoth/BUILDING.md) for building instructions.
