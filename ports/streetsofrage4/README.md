## Notes

Thanks to Dotemu, Lizardcube, and Guard Crush Games for creating Streets of Rage 4, a hand-drawn beat ’em up set in Wood Oak City, and to Playdigious for the Android edition. PortMaster adaptation by Ronax. [Game credits](https://www.dotemu.com/PressKit/project/Games/Streets%20of%20Rage%204)
Thanks to NextOS for the startup Android compatibility code this port builds on.

## Get the APK

On Android, install your copy of Streets of Rage 4 from the Epic Games Store mobile app. Check that you have version **1.4.10**, version code **100**. [Streets of Rage 4 on Epic](https://store.epicgames.com/p/streets-of-rage-4-android-b10fcc)

The setup verifies the complete APK against SHA-256 `b96068021a1c59758734843c25d584f4e168525735a5677fca748135ddc15b2b`. A backup must match that checksum.

1. Open AnExplorer and tap **Apps** on the home screen.
2. Find **Streets of Rage 4** and long-press its icon or name.
3. Tap **Backup** or **Save as APK**. Find the export in `Internal Storage/Backup/Apps/` or the destination shown by AnExplorer.
4. Copy the exported file to `<ports directory>/streetsofrage4/gamedata/base.apk`.

[AnExplorer APK backup guide](https://anexplorer.io/solve/backup-apps-apk)

## First launch

1. Leave at least 3 GB free after copying the APK. Launch **Streets of Rage 4**.
2. Let setup finish. The PortMaster patch screen shows progress. If setup is interrupted, relaunch to resume from verified files. After setup verifies and installs the game data, it removes the handheld's `gamedata/base.apk` copy. Keep your original APK backup elsewhere for reinstalls or updates that require fresh preparation.

The launcher creates `streetsofrage4/conf/` for saves and settings and binds it to the game's save path through PortMaster. Keep `conf/` when updating.

The port uses the firmware display size. It keeps compressed ASTC textures where the GPU supports them and uses reduced-resolution decoding elsewhere. Setup, launch, and audio logs are `repack.log`, `log.txt`, and `wwise.log` in the port folder.

## Controls

Gameplay uses native SDL input. See **Options** in the game for your controller’s assignments.

| Button or key | Action |
| --- | --- |
| D-pad / left stick | Move / navigate |
| X | Attack |
| A | Jump |
| Y | Special |
| B | Pick up or throw |
| R2 | Backside Attack |
| START | Confirm |
| Select + Start | Exit through the game |

## Local co-op

Connect a second SDL-compatible controller before launch. With Player 1, open character selection from **Fight → Story** or **Arcade**. Press **Confirm** on the second controller to join. Select and confirm both characters, then start the stage.

## Compile

The [port source](https://github.com/ronaxdevil/sorage4-portmaster.git) includes a `BUILD.md` guide. Run `bash build.sh all build/release` from the source checkout after installing the tools and sysroots listed in that guide.

## Mr. X Nightmare

This release leaves DLC characters locked because Epic purchase verification is unavailable in the handheld port. The add-on can be played in the Epic Android installation under the account that owns it. [Mr. X Nightmare on Epic](https://store.epicgames.com/p/streets-of-rage-4-mr-x-nightmare-dlc-73371b)
