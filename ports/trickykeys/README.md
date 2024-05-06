## Notes

Thanks [Team Bugulon](https://team-bugulon.itch.io/) for creating this game and allowing us to distribute it!

## Controls

| Button | Action |
|--|--| 
|D-pad/L-stick|Movement |
|A / B|Jump|
|Select|Pause / Menu|

## Compile
Added a small patch with UTMT to save after every room in `gml_Script_stage_load`, added
```shell
save_write()
```
on the line after
```shell
global.level_unlocked = max(global.level_unlocked, index)
```