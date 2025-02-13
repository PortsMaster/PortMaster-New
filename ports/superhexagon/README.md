## Notes

This port requires a paid Linux version of the game from Itch.io, GOG.com, or Steam. Depending on where your game is from, the install instructions are slightly different.
The port is compatible with all supported OS' and devices, except for Rocknix in libmali mode (switch to Panfrost), and TrimUI devices on Knulli. Compatibility will increase, so stay tuned.


## Installation

### Itch.io (https://terrycavanagh.itch.io/super-hexagon)
- Place the Linux installer (`uperhexagon-05282015-bin`) in `superhexagon/gamefiles/itch/`
### GOG.com (https://www.gog.com/game/super_hexagon)
- Place the Linux installer (`gog_super_hexagon_2.1.0.4.sh`) in `superhexagon/gamefiles/gog/`
### Steam (https://store.steampowered.com/app/221640/Super_Hexagon/)
- Open the Steam console by clicking this link -> steam://open/console/
- Download the Linux version of the game by copy pasting this command into the console `download_depot 221640 221643 7186315654381968499`
- The gamefiles will download to `content\app_221640\depot_221643` within your Steam Library. 
- Place the gamefiles within this folder (without any surrounding folders) into `superhexagon/gamefiles/steam/`

The necessary runtime to run this should be automatically downloaded, but if it isn't, download the `Westonpack 0.2` runtime on the Portmaster App.

---

Special thanks to **Terry Cavanagh** for creating this awesome game and **Chipzel** for creating the banger soundtrack for it.

**Game:** https://superhexagon.com/

**Soundtrack:** https://chipzelmusic.bandcamp.com/album/super-hexagon-ep

---

More special thanks:
- [ptitSeb](https://github.com/ptitSeb) for creating the X64 Emulator [Box64](https://github.com/ptitSeb/box64) and the OpenGL compatibility layer [GL4ES](https://github.com/ptitSeb/gl4es), which makes this whole port possible.
- [kotzebuedog](https://portmaster.games/profile.html?porter=kotzebuedog) for creating [hacksdl](https://github.com/cdeletre/hacksdl) which allowed me to disable the buggy controller input of the game.
- [Fraxinus88](https://portmaster.games/profile.html?porter=Fraxinus88) for sending me a directory listing of the GOG version so i could make it compatible with this port.
- [Cebion](https://portmaster.games/profile.html?porter=Cebion) for helping with Rocknix Panfrost compatibility.

---

This port uses the new Westonpack runtime and libcrusty to provide X11 compatibility on devices that do not support X11. The runtime is still in active development and somewhat experimentatl. If you are experiencing issues, please reach out to me on the PM discord server, so i can improve this runtime. Thanks!

**LEGAL DISCLAIMER:** This port includes a selfmade library that partially emulates the Steam API. This library does not bypass DRM protection measures, nor is it capable to do so, nor does the game actually have any protection measures. All this library does is tell the app that Steam is running, and reply with stub values to a couple of requests related to achievements and leaderboards to allow the app's online features to fail gracefully. The full source code (under MIT license) is included in the package for full disclosure.

---

## Controls

| Button | Action |
|--|--| 
|Analog Sticks, DPad, L1/R1 |Left/Right|
|A, Start|Confirm|
|B, Select|Cancel|
|X|Open Leaderboard|

