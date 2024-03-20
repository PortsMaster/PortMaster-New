## Notes

Copy 
* data.win
* audiogroup1.dat
* audiogroup2.dat
into 
/ports/bunnysflowers/gamedata

from the Steam version of [Bunny's Flowers](https://store.steampowered.com/app/1375480/Bunnys_Flowers/)

## Controls

| Button | Action |
|--|--| 
|D-PAD|Move|
|Start|Open menu|
|B|Undo|
|Y|Restart level|
|A|Open a portal|


## Compile

```shell
Added a small patch with UnderTaleModTool save after each room:

added 
> ds_map_secure_save(save_data, file_name)
to
> gml_Object_obj_roomHandler_Other_4
just after 
> ds_map_replace()
on line 27

```
