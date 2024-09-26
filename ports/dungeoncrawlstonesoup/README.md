## Notes
Thanks to the [Crawl Dev Teams & Contributors](https://github.com/crawl/crawl/blob/master/crawl-ref/CREDITS.txt) for creating this game and making it open-source!
 
## Controls
### Main menu
```
D-Pad - menu navigation
A - select
B - back/exit
```

### Dungeon/Gameplay
```
D-Pad - movement
L1 - fire/throw
R1 - auto-explore
L2 - go upstairs
R2 - go downstairs/enter shop

Select+L1 - wait one turn
Select+R1 - pickup item
Select+L2 - N (useful for yes/no in-game prompts)
Select+R2 - Y (useful for yes/no in-game prompts)

A - enter
B - esc
Y - open actions menu
X - open info menu
Select+B - *

Start - open game menu (save/exit)
```

To make the game handheld-friendly most operations were condensed into two menus:
 - __Actions menu__ - allows to do a certain action like read, quaff, quiver, drop, open/close door, rest, etc.
 - __Info menu__ - allows to check certain information like inventory, spells, mutations, religion, resists, map, skills, etc.

### Actions/Info menu (specifically)
```
D-Pad - menu navigation
X,Y,A - select item
B - close menu
```

### On level-up (stats prompt)
```
Select+Y - select strength
Select+X - select intellect
Select+A - select dexterity
```

### all other in-game menus (like inventory, spells, skills, drop/read/quaff, etc.)
```
D-Pad Up, D-Pad Down - menu navigation
D-Pad Right, D-Pad Left - select item (if menu allows to select multiple items, like drop menu or shop)
A - select/confirm
B - back/close
```

### Map/Lookup
```
D-Pad - navigation
A - select
B - exit
X - exclude this area
Y - show description
L1 - zoom out
R1 - zoom in
```

## Version
0.33-a0-54-g55745971f8

## Compile
```shell
git clone https://github.com/crawl/crawl
cd ./crawl/crawl-ref/source
make -j4 DATADIR="" FONTDIR="dat/tiles/" CROSSHOST=aarch64-linux-gnu TILES=y USE_SDL=y NOWIZARD=y V=y
```
### Required files and directories to make game work
```
./crawl/crawl-ref/source/crawl
./crawl/crawl-ref/source/dat
./crawl/crawl-ref/docs (only txt files needed in this directory)
```

Put __DejaVuSans.ttf__ and __DejaVuSansMono.ttf__ in `dat/tiles/` folder
