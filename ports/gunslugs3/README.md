## Notes

Thanks to [Orangepixel](https://orangepixel.net/) for creating **Gunslugs 3 Rogue Tactics**. Choose stealth or gunfire as you complete missions through procedurally generated enemy territory. PortMaster adaptation by **Pixelforge Ports (Ronax)**.

## Get gunslugs3.dat from GOG
Windows:
1. Open [Gunslugs 3 Rogue Tactics on GOG](https://www.gog.com/en/game/gunslugs_3_rogue_tactics) in your owned library and download the **full Windows offline backup installer** for build **1.0.10b**.
2. Run the installer on Windows and open the installed game directory. Find `gunslugs3.dat` beside the game executable. Enable file extensions in Explorer so its name is visible.

Linux:
Alternatively, extract your full offline installer using [innoextract](https://constexpr.org/innoextract/).
Run `innoextract -d extracted "your-full-offline-installer.exe"`, then locate `gunslugs3.dat`
inside the extracted files (usually `extracted/app/`).

Supported archive SHA-256 (`gunslugs3.dat`):
```text
8e9f0784c8824119ac5572baa09e9d93e317ffd0a6ad3f1de1be4a76e61bebdf
```

Copy the owned file to **`<ports directory>/gunslugs3/gamedata/gunslugs3.dat`**.
Launch **Gunslugs 3 Rogue Tactics** from your firmware's ports menu.

The launcher detects display size and supports **640x480**, **720x480**, **720x720**, **1024x768**, **1280x720**, and other valid PortMaster dimensions while preserving aspect ratio. If detection is wrong, put the actual size, such as `720x480`, in `gunslugs3/resolution.txt`; use `auto` or remove the file to restore automatic detection.

Back up **`gunslugs3/saves/`** before updating. If startup fails, check **`gunslugs3/log.txt`**. When reporting a problem, include the device, firmware version, resolution, reproduction steps, and log. Keep purchased game files private.

## Controls

| Control | Keyboard input / action |
|---|---|
| D-pad / left stick | Arrow keys |
| A | A: use / interact |
| B | Z: swap weapon |
| X | X: shoot / menu confirm |
| y | Up: jump |
| L1 | Up |
| R1 | X |
| L2 | Z |
| R2 | Tab |
| Start | Enter |
| Back / Select | Escape |
| Select + Start | Exit; save through the game first |

These bindings are supplied by gptokeyb2 through `gunslugs3.ini`. The supported
Windows build uses arrow keys, Shoot X, Cancel Escape, Swap Weapon Z, Use A, and
Pause Tab. Use X or Start to confirm menus.
The Select + Start combination invokes PortMaster's force-close shortcut.
