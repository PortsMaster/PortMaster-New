## Notes

Modified from source: [Slayer366](https://github.com/Slayer366/CatacombSDL-hh)

Both the floppy disk and GOG versions are compatible.

If you don't own either of the Catacomb games you can get Catacomb (1989) and The Catacomb (a.k.a. Catacomb II) from:
[GOG](https://www.gog.com/en/game/catacombs_pack)

Copy all *.CAT files into the 'ports/catacomb89/' directory.

Files should be uppercase.  If game files are lowercase, the launcher will attempt to convert them to uppercase automatically.

Game files needed:
- catacomb89/DEMO.CAT
- catacomb89/LEVEL1.CAT thru catacomb89/LEVEL10.CAT
- catacomb89/SOUNDS.CAT
- catacomb89/TOPSCORS.CAT

## Controls

| Button | Action |
|--|--| 
|Select|Quit|
|Start|Enter|
|A|Fire primary - hold to charge shot|
|B|Fire Bolt (req. Bolt scrolls)|
|X|Use health potion|
|Y|Answer Yes|
|L1|Hold to strafe|
|L2|Quick Save|
|R2|Quick Load|
|R1|Fire Nuke (req. Nuke scrolls)|
|Up|Move Up|
|Down|Move Down|
|Left|Move Left|
|Right|Move Right|
|Left Analog|Move (same as D-Pad)|

## Compile
catacomb89sdl-sauce.7z contains the modified CatacombSDL-hh source code to run the 1989 release
Extract the contents of the provided catacomb89sdl-sauce.7z archive
```shell
cd catacomb89sdl-sauce (or whichever folder you chose to extract to)
cmake . -DCMAKE_BUILD_TYPE=Release
make -j4
```
