## Notes

Thanks to [Jagged Alliance 2 Stracciatella Team](https://ja2-stracciatella.github.io/) for the open source Jagged Alliance 2 engine that makes this port possible.

Also thanks to the PortMaster team for all of the work they do.

Special thanks to @hugalafutro, @cebion, @not.your.average.paladin, @kloptops, and @laforge0780 for their guidance and help with testing the port in various devices, architectures and resolutions.

## Detailed Instructions

You need to add required game files either from GOG or an installed copy of the game.

For the GOG version, copy setup_jagged_alliance_2_\*.exe into ports/jaggedalliance2. For the installed version, copy installed game files into ports/jaggedalliance2/game.

Additionally, the install script automatically downloads the open-source Jagged Alliance 2 Stracciatella engine for ARM64. If you want to do it manually, download it from https://ja2-stracciatella.github.io/download/, make it executable, then run it with the "--appimage-extract" command. Copy everything to ports/jaggedalliance2/bin (create the bin folder if it does not exist), and make sure the ports/jaggedalliance2/bin/AppRun file is executable.

Save games, in-game settings, and other metadata will be saved under the ports/jaggedalliance2/conf folder.

Please note that the game requires a minimum resolution of 640x480.

## Controls

| Button | Description |
| - | - |
| dpad | mouse movement |
| left analog stick | mouse movement |
| right analog stick | move the map |
| a | mouse left click |
| b | mouse right click |
| x | enter |
| y | escape |
| select | in-game menu |
| start | hold for extra functions (see below) |
| menu / l2 / r2 | hold for hotkey (see below) |
| l1 | shift |
| l3 | "l" (change where the mercenary is looking) |
| r1 | ctrl |
| r3 | "m" (switch to map view from tactical view) |

The following options are available while holding the hotkey button (menu, l2, r2):

| Button | Description |
| - | - |
| l1 | quick load |
| r1 | quick save |
| dpad up | stand |
| dpad down | prone |
| dpad left | crouch |
| dpad right | look |
| a | toggle stealth mode |
| b | toggle run mode |
| x | swap primary and secondary hands |
| y | reload weapon |

The following options are available while holding the "start" button:

| Button | Description |
| - | - |
| dpad up | "m" (switch to map view from tactical view) |
| dpad down | text input |
| dpad left | "insert" (go up one surface level on the map) |
| dpad right | "delete" (go down one surface level on the map) |
| l1 | "/" (center the selected mercenary) |
| l2 | "-" (decrease time in global map) |
| r1 | space (select the next mercenary in the squad) |
| r2 | "+" (increase time in global map) |
| a | "d" (end turn in combat mode) |
| b | "alt" (to be able to strafe or step backwards) |
| y | "m" (switch to map view from tactical view) |

In text input mode, use the dpad left/right arrow to delete/add letter, and the up/down arrows to change the current letter. Use the "a" button to press "enter", and the "select" button is mapped to "tab". The latter is useful when you are filling out a form (e.g. in I.M.P.) and you need to navigate to the next input field for text entry.
