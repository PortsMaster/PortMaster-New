# Porting Notes

## Font Fix
In `gml_Object_cont_Create_0.gml`, use `32` instead of `30`:
```gml
fText = font_add_sprite(sFont, 32, 1, 1);
```

## Controller Prompt Update
In `gml_RoomCC_room42_<x>_Create` (`x` will vary), change the text to:
```gml
text = "  D-PAD - Move   B - Undo   R1 - Reset";
```

## Sprite Replacement
Replace the sprite `sPrompt_0` with:
```txt
CONVERT_sPrompt_0.png
```

