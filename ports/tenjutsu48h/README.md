## Tenjutsu - 48H Edition
This ready to run game was created in 48 hours for Ludum Dare 51 on itch.io ("every ten seconds").

Compiled from [source](https://github.com/bmdhacks/ld51-tenjutsu-48h)

## Controls

| Button(s)          | Action(s)  |
|:-------------------|:-----------|
| Left Stick / D-Pad | Move       |
| A, X               | Attack     |
| B, R1, R2          | Dodge      |
| SELECT             | Restart    |
| START              | Pause      |

## Building
You need to have Haxe 4.3.3 minimum and Haxelib installed and set up.

```
sudo apt install haxe
haxelib setup
git clone https://github.com/deepnight/ld51-tenjutsu-48h && cd ld51-tenjutsu-48h
haxelib install ase
haxelib git castle https://github.com/deepnight/castle.git
haxelib install deepnightlibs
haxelib install format
haxelib install heaps-aseprite
haxelib git heaps https://github.com/deepnight/heaps.git
haxelib install hlsdl
haxelib install hscript
haxelib install ldtk-haxe-api 1.5.3-rc.1
nano build.opengl.xml
```

Add line: `-lib hlopenal` and save

`haxe build.opengl.hxml`

Retrieve `bin/client.hl`

## Thanks
Deepnight -- Compiling guidance  
Deepnight Games -- The game  
beniamino -- Running help (gl4es)
