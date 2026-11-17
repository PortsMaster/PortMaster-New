## Notes

0RBE is an original orbital chain shooter by M.A. Vélez-Guerrero ([@mandresve](mailto:mandresve@hotmail.com)), made for the Trimui Brick and Brick Pro and packaged for PortMaster by the author. Thanks to the PortMaster team and testers for the tooling.

It is a small native program: it draws everything (orbs, skies, black holes, its own typeface) and generates all of its sound and music in real time through the system SDL2 library. No libraries, images, samples or fonts are bundled.

The first launch asks for the language (English, Español, Italiano, Français, Deutsch, Português, Nederlands); it can be changed later in Settings. It adapts to 4:3, 16:9 and 1:1 screens: the playfield is the same on all of them and the sky and the HUD fill the rest; other shapes get thin black bars.

0RBE is freeware, distributed through PortMaster with the author's permission. See `0rbe/licenses/LICENSE.0rbe.txt`.

## Controls

| Button | Action |
|--|--|
| D-Pad | Move the crosshair; menus |
| Left / Right Stick | Move the crosshair (where present) |
| L1 / R1 (hold) | Move the crosshair faster |
| A / R2 | Shoot; confirm |
| B / L2 | Swap the next orb; back |
| Y | Fire the Nova orb (when it's ready) |
| X (hold) | Precise aim |
| Select | Aim guide on / off |
| L3 / R3 | Center the crosshair (where present) |
| Start / Menu | Pause |
| Start + Select (hold 1 s) | Exit |

Everything can be played with the D-Pad alone.

## Saves

Progress and settings are kept in `ports/0rbe/conf/save.txt`; the log is `ports/0rbe/log.txt`.

## Compile

0RBE is closed source. The included `orbe.aarch64` is built by the author in the `ghcr.io/loveretro/tg5040-toolchain` image (GCC 8.3, glibc 2.17). It needs only `libSDL2-2.0.so.0` (SDL 2.0.18 or newer), `libm` and `libc`.
