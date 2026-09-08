## Notes

Thanks to [Polytron](http://polytroncorporation.com/) for FEZ, to Renaud Bedard and Ethan "flibitijibibo" Lee for the 1.12 FNA release this port is built on, and to [JohnnyOnFlame](https://ko-fi.com/johnnyonflame) for bringing Mono and FNA to PortMaster, which every FNA port here stands on.

## How to install

- Install the port files via PortMaster.
- You need to own FEZ, and this runs the **Linux** build of it. On a Linux PC, Steam has already put that under `~/.steam/steam/steamapps/common/FEZ`. On Windows or macOS, Steam installs the wrong build, so open the Steam console with `steam://open/console` and run `download_depot 224760 224762` (224762 is FEZ's Linux depot); it reports the download folder when it finishes.
- Copy the contents of that install into `ports/fez/gamedata`, so `FEZ.exe` and the `Content` folder sit directly in there. It comes to about 420 MB. `lib`, `lib64`, `FEZ.bin.x86` and `FEZ.bin.x86_64` are x86 and can be left behind.
- On first run the port deletes the game's bundled Mono and FNA assemblies, since it ships its own. Do not be surprised to find them gone.
- Enjoy.

Saves live in `ports/fez/savedata` and settings in `ports/fez/conf`. Steamworks is disabled, so Steam cloud saves are off. If your video settings ever end up somewhere you did not want, deleting `ports/fez/conf/Settings` brings the port's defaults back.

FEZ is drawn at your screen's own resolution, letterboxed to 16:9 where the panel is not. Lighting is off by default because it costs a lot on slower hardware; turn it back on in the game's own Video settings for the look FEZ intends, if your device has the power.

## Controls

| Button | Action |
|--|--|
|D-Pad/L-Stick|Move|
|A|Jump|
|X|Grab / Throw|
|B|Cancel / Talk|
|Y|Inventory|
|L1|Map zoom out|
|R1|Map zoom in|
|L2|Rotate world left|
|R2|Rotate world right|
|L3|First person view|
|R3|Clamp look|
|Select|Map|
|Start|Pause|
