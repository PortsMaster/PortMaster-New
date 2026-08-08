# retsend

Transfer files between handheld and your phone or PC over wifi, using the
[LocalSend](https://localsend.org) protocol — no cable, no SSH.

## Setup

1. Install LocalSend on your phone or PC (localsend.org).
2. Connect both devices to the same wifi network.
3. Launch retsend — nearby devices appear on the radar.

Both directions work with the official app's default settings.
Received files land in the ROMs root by default; change the folder in Settings.

## Controls

| Button  | Action                                                |
|---------|--------------------------------------------------------|
| D-pad   | Navigate                                               |
| A       | Send to device / select file / accept / type (keyboard)|
| B       | Back / decline / cancel / erase (keyboard)             |
| Start   | Settings · confirm send · OK (keyboard)                |
| Select  | Refresh radar · switch roots · layer (keyboard)        |
| L1/R1   | Page through lists                                     |

## Credits

- Developed and ported by [mxmgorin](https://github.com/mxmgorin)
- Implements the [LocalSend](https://localsend.org) protocol
- Source: https://github.com/mxmgorin/retsend
