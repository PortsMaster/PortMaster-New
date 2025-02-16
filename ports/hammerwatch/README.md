## Notes

This port requires the 1.3 Steam release of the game. You can purchase it at https://store.steampowered.com/app/239070/Hammerwatch/.

The port is compatible with all supported OS' and devices, except for Rocknix in libmali mode (switch to Panfrost), and TrimUI devices on Knulli. Compatibility will increase, so stay tuned.

*Warning: This port takes 30-40 seconds to load on entry level devices. Switch your CPU governor to `performance` for the best experience.*

## Installation

- Open the Steam console by clicking this link -> steam://open/console/
- Download the Linux version of the game by copy pasting this command into the console `download_depot 239070 239071 6038447391393479561`
- The gamefiles will download to `content\app_239070\depot_239071` within your Steam Library. 
- Place the gamefiles within this folder (without any surrounding folders) into `hammerwatch/gamefiles/`

The necessary runtimes to run this should be automatically downloaded, but if they aren't, download the `Westonpack 0.2` and `Mono 6.12.0.122` runtimes on the Portmaster App.

---

Special thanks to **CrackShell** for creating this awesome game.

**Game:** https://store.steampowered.com/app/239070/Hammerwatch/

---

More special thanks:
- [flibitijibibo](https://github.com/flibitijibibo) for creating MonoKickstart
- [Ganimoth](https://portmaster.games/profile.html?porter=Ganimoth) for helping with debugging a problem with the runtime on older ArkOS devices.

---

This port uses the new Westonpack runtime and libcrusty to provide X11 compatibility on devices that do not support X11. The runtime is still in active development and somewhat experimental. If you are experiencing issues, please reach out to me on the PM discord server, so i can improve this runtime. Thanks!

---

## Controls

| Button | Action |
|--|--| 
|Analog Sticks, DPad |Movement|
|A|Attack|
|B, Ability 1|
|Y, Ability 2|
|X, Ability 3|
|L1|Strafe|
|L2|Hold|
|R1|Autofire Hold|
|R2|Potion|
|Start|Pause Menu|
|Select|Map|

