## Notes

Play GTA 2 solo, on a LAN or online.

This port is a fork of the [GTA2 browser port](https://github.com/M1sterMo/gta2).

Source Code: [GTA2 native multiplayer](https://github.com/cdeletre/gta2-browser/tree/native-multiplayer)

## Game files

### Option A

You need GTA2's PC installer from the 2004 Rockstar Classics release. Copy `GTA2INSTALLER.exe` into `ports/gta2/gamedata`. On the first launch, PortMaster's patcher extracts the game files from it and
shows its progress on screen (1 to 5 minutes). The installer is deleted once everything is extracted;
if something fails, it stays, and `ports/gta2/patchlog.txt` tells why.

### Option B

Steam game: Install the game on Steam. Afterwards in Steam, right-click the game and choose `Manage > Browse local files`, then copy the whole data folder into `ports/gta2/gamedata/`, so you end up with `gamedata/data/`.

Note: the game is no longer sold on Steam, but if you bought it before it was removed, it is still in your library.

### Option C

Use you GTA2 CD and copy into `ports/gta2/gamedata/`:
- `data1.cab` (it's in `Install`)
- `data1.hdr` (it's in `Install`)
- `GTAudio` (the folder with the wav inside)

## Launchers

There are three launchers:
- `GTA 2` is the single-player game.
- `GTA 2 LAN` plays with other consoles on the
same network (LAN), with no server.
- `GTA 2 Online` plays through a GTA2 game server, with consoles and web browsers.

Multiplayer is for 2 to 6 players: free roam, Gang Wars or free-for-all, in any of the three districts.

## Online servers

The port comes with two preconfigured GTA 2 servers:
- `Coolgeek (PL)` in Europe
- `Coolgeek (CA)` in Canada

Please be respectful with these servers. If we see abuse, we will take them down.

To run a private game server for your group (a ready-made Docker image, on a VPS, a home server or a Raspberry Pi), see
[deploy/selfhost/README.md](https://github.com/cdeletre/gta2-browser/blob/native-multiplayer/deploy/selfhost/README.md).

## Saves and settings

The game's profiles, church saves and high scores are in `ports/gta2/saves/`.
The settings are in `ports/gta2/conf/`:
- `registry.txt` holds the game's own options.
- `controls.ini` is the controller layout (it is written with comments on the first launch).
- `lan.ini` and `online.ini` hold the multiplayer settings: your name, the rooms, the four quick
messages, and for `GTA 2 Online` the game servers (address, password).

## Options

From the main menu (Options), or during a game: press Start (the quit prompt), then
Select. The game is paused while the screen is open (a multiplayer match goes on). Up/down choose
a line, left/right change it, B or Start close it (in a game, B again resumes play). Settings:
- Music and radio volume, sound effects volume (applied at once).
- Text speed (from the next game), exploding scores, lighting.
- Face buttons: `auto`, `nintendo` or `xbox` (the A/B and X/Y layout, see below).
- Control: `Twin stick` (the default) or `Classic` (see Controls below). In a match where twin stick
  is not allowed, it shows `Twin (classic here)`.
- Radar: `Right` (the default), `Left` or `Off`: a round minimap in a bottom corner, with gang jobs,
  mission targets, weapons, power-ups and, in multiplayer, the other players and waypoints. While
  it is on, the gang and mission arrows sit on its rim instead of around the player.
- In `GTA 2 Online` and `GTA 2 LAN` only: Chat messages and Waypoints (`On` / `Off`), to show or
  hide the other players' messages and waypoints.

The settings are kept for the next launch.

## Controls

### Twin stick

The default. Choose Classic or Twin stick in Options, on the Control line. Only walking and aiming
change; driving stays the same as Classic.

| Button | Action |
|--|--|
| D-pad / Left stick | On foot: walk up, down, left or right on the screen (diagonals too). In a car: steer, as in Classic |
| Right stick | On foot: aim (the player turns to face it and can walk sideways or backwards). In a fire truck, tank or gun jeep: turn the turret |
| A / B | Accelerate / Reverse (in a car); on foot, walk up / down on the screen |
| R2 | Attack, shoot where you aim (no auto-aim; electric weapons keep theirs) |
| X | Horn (in a car), taunt (on foot) |
| R1 | Jump, handbrake |
| Y | Enter / exit a vehicle |
| L1 / L2 | Next / previous weapon |
| L3 (hold) | Look around with the D-pad |
| R3 | Status |
| Select | Next radio station (in a car) |
| Start | Quit prompt: then A, A to quit, B to resume, Select for Options |
| Menus: A / B | Confirm / Back |

Without the right stick, the player faces the way they walk. After you let go of the stick, the
aim holds for a third of a second.

In a multiplayer match, twin stick is used only when every player has a console with this
version. If a browser or an older console is in the match, everyone plays with Classic controls;
the lobby says so.

### Classic

| Button | Action |
|--|--|
| D-pad / Left stick | Walk, steer (up / down: forward / backward) |
| A / B | Accelerate / Reverse (also forward / backward on foot) |
| R2 | Attack, shoot |
| X | Horn (in a car), taunt (on foot) |
| R1 | Jump, handbrake |
| Y | Enter / exit a vehicle |
| L1 / L2 | Next / previous weapon |
| L3 (hold) | Look around with the D-pad |
| R3 | Status |
| Select | Next radio station (in a car) |
| Start | Quit prompt: then A, A to quit, B to resume, Select for Options |
| Menus: A / B | Confirm / Back |

The layout follows the PlayStation version (cross = A, square = B, triangle = Y, circle = X). Every button
can be changed in `conf/controls.ini`.

### Quitting

Press Start (the quit prompt), then A twice (the second press confirms "ARE YOU
SURE?"). B or Start resumes play. The quit prompt alone does not pause the game.
While the quit prompt is up, the district's map fills the screen, centred on you: the D-pad or
the left stick moves it, L1 / R1 zoom out / in.

### In a multiplayer match

| Button | Action |
|--|--|
| Select (short press) | Next radio station (in a car) |
| Select (hold) | Scoreboard: kills, deaths, points, each player's ping, your input delay |
| Select + D-pad | Send a quick message (up: "Follow me!", down: "Wait for me!", left: "Help!", right: "Nice one!"; change them in `conf/lan.ini` or `conf/online.ini`) |
| Select + L1 / R1 | Set your waypoint where you stand / clear it |

The other players' waypoints and chat show on screen; Options can hide them.

### In the multiplayer lobby

| Button | Action |
|--|--|
| D-pad up / down | Choose a line |
| D-pad left / right | Change it (mode, district, time limit, traffic...) |
| A | Act on the line: join, host, start the match, type a name or an address |
| B | Back |

Names, rooms, addresses and passwords are typed on an on-screen keyboard. In `GTA 2 LAN`, the host can set Traffic to More: 16 traffic cars a player (at most 64) instead of the original's 16 for the whole match, so that every player sees traffic and police.

### A/B and X/Y swap

You can change Face buttons in Options to `nintendo` or `xbox`
(it is saved as `face_buttons` in `conf/controls.ini`). The default, `auto`, follows PortMaster's
controller mapping; on some systems `nintendo` is needed.

## What differs from the PC game
- The view fills the screen whatever its shape. On a 4:3 screen it is the original 640x480 view,
  scaled. A wider screen (16:9) shows more of the city on the sides, and a taller one (1:1, as on the
  RG CubeXX) shows more above and below. Menus stay 4:3, with black bars.
- The intro movies are not played.
- Options opens a simple settings screen of the port, instead of the original's separate GTA2
  Manager program (see Options above).
- Twin stick controls by default (Classic in Options): walk with the left stick, aim with the
  right stick, and turn the turrets of the fire truck, tank and gun jeep.
- A radar in a bottom corner, and the district's map on the quit prompt (see Quitting above).
- In `GTA 2 LAN`, the host can choose More traffic (see the multiplayer lobby above).
- Select changes the car radio station. In a multiplayer match, a short press
  does that, and holding Select gives the multiplayer controls (see Controls above).

## Logs

The game writes its log to `ports/gta2/log.txt` (each launch replaces it), with a status
line every 60 seconds; in a match, a network line every 5 seconds too.
To help with a bug report, add `export GTA2_LOG_INPUT=1` to the launch script (it logs the controller mapping and every button press) and send the log. After a crash, the log ends with a crash report: please include it.

## Compile

The binary is built for aarch64 with clang, in a container based on the PortMaster build image
(on an ARM64 machine, or with emulation).

```shell
git clone -b native-multiplayer https://github.com/cdeletre/gta2-browser gta2
cd gta2
git clone https://github.com/CriminalRETeam/gta2_re research/gta2_re
git -C research/gta2_re checkout 02de8be
docker build --platform=linux/arm64 -t gta2-pm-img docker/
docker run -d --name gta2-pm --platform=linux/arm64 -v "$PWD":/workspace gta2-pm-img
./scripts/build_native.sh --preset release
```

The build script applies the engine patches to a copy of `gta2_re` (pinned at commit
`02de8be`); see `docs/native-status.md` for details.

The port binaries are:
- `build/native/release/dist/gta2.aarch64`
- `build/native/release/dist/gta2-lan.aarch64`
- `build/native/release/dist/gta2-online.aarch64`

## Credits & Acknowledgements
- [DMA Design and Rockstar Games](https://www.rockstargames.com/) for creating Grand Theft Auto 2,
and for making it available again in 2004 as part of Rockstar Classics.
- [CriminalRETeam](https://github.com/CriminalRETeam) for the decompilation of the original game, function by function in [GTA2 reverse engineering project (gta2_re)](https://github.com/CriminalRETeam/gta2_re).
- [M1sterMo](https://github.com/M1sterMo) for the [GTA2 browser port](https://github.com/M1sterMo/gta2) this port is based on.
- All the PortMaster port navigators that helped in testing this port
- Kdog for hosting the Canadian multiplayer server
- PortMaster for hosting the European multiplayer server
- Klod for helping me to write the Kode
