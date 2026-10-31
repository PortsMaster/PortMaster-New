## Notes
Thanks to [Tribute Games](https://tributegames.com/presskit/sheet.php?p=Scott+Pilgrim+EX) for creating Scott Pilgrim EX, a brawler with interconnected Toronto neighborhoods and badge-based fighter customization.

## Get the PC Data
Buy [Scott Pilgrim EX on Steam](https://store.steampowered.com/app/2640950/). This port supports these Windows versions:

| Steam build | Game version | DLC support |
|--|--|--|
| 24607859 | 1.0.0.15231 | Back in the Band, when owned and installed |
| 22184139 | 1.0.0.13988 | Only base game |

Copy the contents of your supported PC `ScottPilgrimEX` folder into `ports/scottpilgrimex/gamedata` .

To download an exact supported Windows version, sign into Steam with an account that owns the game. Open the Steam console using Windows + R and `steam://open/console`, then enter one of these commands:

DLC Support Build 24607859 / version 1.0.0.15231:
```text
download_depot 2640950 2640951 3465397373957977557
```

Only Base Game build 22184139 / version 1.0.0.13988:
```text
download_depot 2640950 2640951 1913154938847254259
```

Wait for the download to finish. Steam prints its location, normally `steamapps/content/app_2640950/depot_2640951`. Use that folder's contents as the PC data.
Only the base game (build 22184139) performs well on RK3326 devices with 1 GB of RAM.

## Back in the Band DLC
The optional [Back in the Band DLC](https://store.steampowered.com/app/4861470/) requires Windows build 24607859. Buy and install it through Steam on your PC.

1. Keep Steam open and signed into the account that owns the game and DLC.
2. On the Windows PC, extract the scottpilgrimex.zip and run `scottpilgrimex/patches/ExportDLC.exe` from the extracted port package. It checks Steam and creates `dlc-owned.txt` beside itself.
3. Copy that `dlc-owned.txt` into `ports/scottpilgrimex/gamedata` along with the PC game files. Include `Content/Videos/GameIntro_DLC.ogv` and all the DLC character assets.

The helper writes `ExportDLC.log` beside itself if it cannot find the game or verify the DLC. For a Steam library outside the default location, run it with the installed game folder as its argument, for example `ExportDLC.exe "D:\SteamLibrary\steamapps\common\ScottPilgrimEX"`. Without an owned-DLC export, the current build runs as the base game.

## First launch
Keep at least 2 GB free after copying the files. First launch patches the game and converts textures and both available intro videos. Keep the device powered and awake until setup finishes. If conversion is interrupted, launch again to resume. Keep an original PC copy of the game files.

When changing game versions, replace `gamedata` with a clean copy of the chosen PC build. Keep `scottpilgrimex/savedata` to preserve handheld saves, and copy your DLC export again when using build 24607859.

## Controls

The game uses native SDL controller input. These are the game's default SDL/Xbox button names, which can differ from the letters printed on a handheld. Check the in-game controls menu to view or change bindings.

| Key | Action |
|--|--|
| D-Pad / Left stick | Move / Navigate menus |
| SDL A (bottom face button) | Jump / Confirm |
| SDL B (right face button) | Grab or pick up / Cancel |
| SDL X (left face button) | Fast attack |
| SDL Y (top face button) | Strong attack |
| L1 | Call assist |
| R1 | Sprint |
| L2 | Drop money or a heart |
| R2 | Block |
| Start | Pause |
| Select / Back | Inventory |
| L2 (button press) | Show player ID |
