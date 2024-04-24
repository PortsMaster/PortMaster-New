## Notes

Thanks to [zuza](https://www.zuza.games/) for creating this lovely game!


## Controls

| Button | Action |
|--|--| 
|D-pad|Move|
|Start|Open menu|
|B|Undo|
|Y|Restart level|
|A|Open a portal|


## Compile
Added a small patch with UnderTaleModTool save after each room:
```shell
added 
> ds_map_secure_save(save_data, file_name)
to
> gml_Object_obj_roomHandler_Other_4
just after 
> ds_map_replace()
on line 27
```