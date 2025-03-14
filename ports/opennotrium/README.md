## Controls
| Button       | Action            | Original    |
| :----------- | :---------------- | :---------- |
| D-pad        | Move character    | Cursor keys |
| Left analog  | Move character    |             |
| Right analog | Aim               | Mouse       |
| R1           | Fire              | Left click  |
| L1           | Pick up           | Right click |
| R2           | Use item          | U           |
| L2           | Drop item         | D           |
| R3           | Break item        | B           |
| L3           | Slow mouse        |             | 
| A            | Flashlight on/off | F           |
| B            | Cycle weapon      | E           |
| X            | Items menu        | I           |
| Y            | View journal      | J           |
| Start        | Select            | Enter       |
| Select       | Back / dismiss    | Space       |
  
## Save game menu
When naming a saved game, you can press `Start + D-pad left` to enter "Save". You can also press `Start + D-pad down` enter a name interactively:
| Button        | Action            |
| :-----------  | :---------------- |
| D-pad up/down | Choose character  |
| D-pad right   | Confirm character |
| D-pad left    | Delete character  |
| Start         | Confirm and exit  |
| Select        | Cancel text entry |

## Notes
The text is uncomfortably small on high resolution displays.

## CrossMix mouse problems
CrossMix is not a supported platform. The game does run, but the mouse sometimes fails to work. Restarting the game (perhaps more than once) should eventually fix this.

## Acknowlegements
Thanks to [Ville Mönkkönen](https://www.instantkingdom.com/about/) for the original game, and for releasing the source code. Thanks to Vincent Verhoeven and the community for [OpenNotrium](https://github.com/verhoevenv/OpenNotrium.git).

Thanks to ptitSeb for the [gl4es](https://github.com/ptitSeb/gl4es) library.

Thanks to Ganimoth and Worthis for extensive testing.

## Port details
The source code has been modified to fix a row of dark tiles at bottom of widescreen displays, the mouse cursor getting stuck in invisible boxes on Rocknix, and phantom mouse button presses on startup on ArkOS and CrossMix.

GL4ES is included so that OpenGL code can run on devices that only support GLES.
For compilation details see [BUILDING.md](https://github.com/PortsMaster/PortMaster-New/blob/main/ports/opennotrium/opennotrium/BUILDING.md)
