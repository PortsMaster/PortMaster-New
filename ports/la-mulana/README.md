## Controls
The game manual is available [here](https://la-mulana.com/en/manual/l1/pc/index.php).

| Button              | Action                        |
| :------------------ | :---------------------------- |
| D-pad or left stick | Movement                      |
| Up                  | Climb ladder, enter shop      |
| Down                | Descend ladders, place weight |
| Down                | Open Save / Holy Grail menu   |
| A                   | Jump / Confirm                |
| B                   | Use sub weapon                |
| X                   | Use main weapon               |
| Y                   | Use item                      |
| L1                  | Previous main weapon or menu  |
| R1                  | Next main weapon or menu      |
| L2                  | Previous sub weapon           |
| R2                  | Next sub weapon               |
| Start               | Open/close main menu          |
| Back                | Open/close Pause Menu         |

## Rocknix
The game does not run on Rocknix panfrost -- please use the system menus to switch to libmali.

## Acknowledgements
Thanks to GR3 Project for the original game and [Nigoro](http://nigoro.jp/en/) for the remake.

Thanks to ptitSeb for the incredible [box86](https://github.com/ptitSeb/box86) and [gl4es](https://github.com/ptitSeb/gl4es) projects which make this port possible, and for help with debugging the port.

Thanks to kdog for [hacksdl](https://github.com/cdeletre/hacksdl), a modified version of which was used in this port, and to BinaryCounter for his steamstub library.

Thanks to Bamboozler and Shark for earlier versions of the port, and to Cebion for help with this version.

## Port information
The port uses [box86](https://github.com/ptitSeb/box86) to run 32-bit Intel code on ARM processors, and [gl4es](https://github.com/ptitSeb/gl4es) to run OpenGL code on machines that only support GLES.

It also includes a version of [hacksdl](https://github.com/cdeletre/hacksdl). This modifies SDL code used by the binary, to work round a bug, where (depending on the version SDL used), the game has a 10-15 minute delay on startup, after the title screen.

SDL has a function SDL_GetPerformanceCounter that returns a counter that increments over time. The starting value is arbitrary. Some versions of SDL start at an unreasonably huge starting number, and this seems to have broken the timing logic in La-Mulana. The solution was to use a derivative of kdog's hacksdl to MITM SDL_GetPerformanceCounter and subtract off the first value recorded. That brings it into a reasonable range that the binary can cope with.
