## Notes

Olduvai is a native recreation of the engine of **Prehistorik** (1991). It
ships no game content: copy your own game files into `ports/olduvai/game/`
(`FILESA.CUR`, `FILESB.CUR`, `FILESA.VGA`, `FILESB.VGA`, and `HISTORIK.EXE` or
GOG's `PREH.SQZ`). The game is sold by [GOG.com](https://www.gog.com/game/prehistorik_12).

Classic DOS plays it as it was in 1991; Enhanced HD adds smooth motion,
widescreen margins and upscaled graphics (Options - Style). Panels 600 lines
tall and up start in Enhanced (scaled x3, x4 from 800 lines, x2 from 400, a
4:3 panel filling its screen), shorter ones in Classic.

If Olduvai does not appear in Ports after installing, update the game list
(Start - Game Settings - Update Gamelists) or restart EmulationStation: on some
firmwares PortMaster's own refresh does not take effect.

Thanks to Titus Interactive, who created Prehistorik in 1991. Olduvai is not
affiliated with or endorsed by them or by any rights holder.

## Controls

| Button | Action |
|--|--|
| D-pad / left stick | Move (up also jumps) |
| A (right) | Jump, confirm in menus |
| B (bottom) | Attack, back in menus |
| Start | Pause menu |
| Select + R1 / L1 | Quicksave / quickload |
| Select + top / left | Cheats (when on) / bug report |
| Start + Select | Quit (PortMaster) |

Buttons can be remapped under Options - Controls.

## Building

Source and build instructions: https://github.com/ksokolowski/olduvai
(`packaging/build_knulli_release.sh` builds the aarch64 and armhf binaries,
`packaging/build_port_portmaster.sh` this package).
