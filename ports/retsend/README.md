# retsend

Transfer files between handhelds, phones and PCs over local Wi-Fi, using the
LocalSend protocol. Works with the official apps. Received ROMs go into their
respective console folders; everything else goes into the ROMs root folder
(configurable in Settings).

## Setup

1. Install [LocalSend](https://localsend.org) on your phone or PC, or retsend on another handheld.
2. Connect both devices to the same Wi-Fi network.
3. Launch retsend — nearby devices appear on the radar.

## Controls

| Button | Action                                                                                              |
|--------|-----------------------------------------------------------------------------------------------------|
| D-pad  | Navigate · left/right switch tabs or step a setting                                                 |
| A      | Send to device · select file · accept · repeat a send · type (keyboard)                             |
| B      | Back · decline · cancel · leave the keyboard                                                        |
| X      | Add a device by IP · pick save folder · delete a history row · take a folder · erase (keyboard)     |
| Y      | Pin / unpin the row under the cursor                                                                |
| Start  | Confirm send · OK (keyboard)                                                                        |
| Select | Refresh radar · switch roots · layer (keyboard)                                                     |
| L1/R1  | Switch tabs · page the file browser                                                                 |

## Credits

- Developed and ported by [mxmgorin](https://github.com/mxmgorin)
- Implements the [LocalSend](https://localsend.org) protocol
- Source: https://github.com/mxmgorin/retsend
