## Notes

LILT is an original piece by deadquiet42, first made for a homebrew front end on the R36S and adapted here for PortMaster. Thanks to the PortMaster team and testers for the tooling that makes small projects like this easy to share.

LILT is a small native program. It draws its own interface and generates all of its sound in real time through the system SDL2 library, with no bundled libraries, samples or fonts.

At startup, choose one of three sound banks with the D-Pad and press A. The next screen shows the controls; press any button to start.

LILT is freeware, distributed through PortMaster with the author's permission. See `lilt/licenses/LICENSE.lilt.txt`.

## Controls

| Button | Action |
|--|--|
| D-Pad | Move (hold to keep moving) |
| Left Stick | Move (where present) |
| A | Place notes (hold to paint) |
| B | Remove notes (hold to erase) |
| X | Empty the pattern |
| Y | Change wobble |
| L1 / R1 | Change pace |
| L2 / R2 | Change voice |
| Select + D-Pad Left / Right | Change echo |
| Select + D-Pad Up / Down | Change space |
| Start | Rest or resume |
| Select + X | Fresh start |
| Select + Start | Exit |

## Saves

The pattern and settings are kept in `ports/lilt/conf/lilt.state`.

## Compile

Source: https://github.com/deadquiet42/lilt

    gcc -O2 -s lilt.c -o lilt $(sdl2-config --cflags --libs) -lm -lpthread

Build on an aarch64 device or chroot with the SDL2 development files. The release binary was cross compiled with Zig targeting glibc 2.17; see the repo README for that command.
