## Notes

Thanks to Adeline Software International for giving Twinsen four ways to tackle a problem, and to [2.21](https://twinsenslittlebigadventure.com/) and [LBA2 Classic Community](https://github.com/LBALab/lba2-classic-community) for releasing and maintaining the engine source.

## How to install

- Install the port files via PortMaster.
- Install [Little Big Adventure 2 Classic from GOG](https://www.gog.com/game/little_big_adventure_2).
- Open the installed game's data folder (look for `LBA2.HQR` or `lba2.hqr`, usually under `Common` or `CommonClassic`) and copy its contents into `ports/lba2/gamedata/`.
- The `.HQR` files should sit directly in `gamedata/` alongside the `.ILE` and `.OBL` files and the music, video, and voice folders. The data is about 520 MB.

Saves and settings live in `ports/lba2/savedata`. The game runs widescreen at your screen's own size; Options → Display switches between that and the classic 640x480 4:3.

## Controls

| Button | Action |
|--|--|
|D-Pad|Move|
|A|Talk / search · confirm in menus, inventory and holomap|
|X|Behaviour action · confirm in menus|
|Y|Inventory|
|B|Recentre camera · back out of menus, inventory and holomap|
|L1|Behaviour menu|
|R1|Throw magic ball / use weapon|
|R2 (or L3)|Dodge|
|L2|Turn the camera 90°|
|R-Stick|Camera|
|Select|Holomap|
|Start|Menu|
|Select + Start (hold)|Exit to the frontend|

Button names follow **Options → Controls → Gamepad** and may differ from the labels printed on your handheld. The game reads the controller directly, and you can rebind gameplay controls in that menu. Item shortcuts removed from the D-pad remain available in the inventory.

With a controller, the game names new save slots automatically. A physical keyboard lets you enter a custom name.

Twinsen walks in the direction you press, relative to the camera. **Options → Controls → Movement: classic turn** restores the original tank controls. **Auto camera** is off by default; enable it under **Options → Advanced options** if you prefer a following camera.

## Compile

See the [build instructions](lba2/patches/README.md) for the pinned upstream revisions, cross-compiler setup, and patches for both the engine and SDL shim. On an installed device, the guide is at `ports/lba2/patches/README.md`.
