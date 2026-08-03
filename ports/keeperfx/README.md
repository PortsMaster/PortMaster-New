## Notes

KeeperFX is an open-source engine recreation and expansion for Dungeon Keeper. It does not include Bullfrog/EA game data.

Install KeeperFX on a PC with files from a legally owned Dungeon Keeper CD, [GOG](https://www.gog.com/game/dungeon_keeper), or [Steam](https://store.steampowered.com/app/1996630/Dungeon_Keeper_Gold/). Copy these folders from that working installation into `ports/keeperfx`:

```text
campgns
creatrs
data
fxdata
ldata
levels
music
sound
```

`mods`, `multiplayer`, and existing `save` folders are optional. Keep the packaged `keeperfx.aarch64`, `keeperfx.cfg`, `libs.aarch64`, and `licenses` files. The required original files are listed in the [KeeperFX repository](https://github.com/dkfans/keeperfx/blob/master/docs/files_required_from_original_dk.txt).

Thanks to the [KeeperFX team](https://keeperfx.net) for recreating and extending the engine, and to Bullfrog Productions for the original game. The catalogue screenshot was captured from this port running on a 720×720 AArch64 ROCKNIX handheld.

## Controls

| Button | Action |
| :-- | :-- |
| Left stick | Move camera |
| Right stick | Move pointer |
| R2 / L2 | Left / right click |
| D-pad | Navigate buttons and tabs |
| A + D-pad up/down | Zoom in/out |
| A + D-pad left/right | Rotate clockwise/counter-clockwise |
| L3 | Toggle map |
| X / Y | Jump to fight / Dungeon Heart |
| L1 / R1 | Previous / next possession instance |
| Start | Pause or close pause menu |
| Start + Select | Exit KeeperFX |

## Compile

```sh
git clone https://github.com/nasedkinpv/keeperfx.git
cd keeperfx
./portmaster/package.sh
```

The script builds in PortMaster's official AArch64 container and writes the submission tree and `keeperfx.zip` under `dist/portmaster`.

## Additional information

The launcher selects the device's native display size. Square displays use KeeperFX's compact bottom HUD; wider displays keep the standard side panel.

Launcher output is saved to `ports/keeperfx/log.txt`, engine diagnostics to `ports/keeperfx/keeperfx.log`, and settings/saves under `ports/keeperfx/save`.
