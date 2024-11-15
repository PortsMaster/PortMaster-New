
createRoom(50, 37, "images/"..codename.."/zelva-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXX..XXXXXXXXXXXXXXX...XXXXXXXX.XXXXXXXXXXXXX.....
XXX..XXXXXXXXXX.XXXXX...........XXXXXXXXX.......XX
XX..............XX.XXX............XXXXX.....XXXXXX
X..............XXX..XX.....................XXXXXXX
XX.............XXX..........XXXXXXX......XXXXXX..X
XXX.............XX...........XXXXXXXXX...........X
XXX..............................XX.XX..........XX
XX...............................X...X.........XXX
X................XXX.............X...X........XXXX
X................................X...X........XXXX
X...............................................XX
X................................................X
X.................................XXX............X
X.................................XXXX...........X
X.................................XXXXX..........X
X................................XXX.XX..........X
XXXXXXXXXXX..........................X...........X
X....................................X..X........X
X.......................................X.......XX
X.....X.........................................XX
X.....X.........................................XX
X.....X.......XXXX....................X.........XX
X.....X........XX.........X.....................XX
X.....X........XXXX.XXX...X.......XX............XX
X.............XX....XX....XXXX...XXXX....X.......X
....................XXXX.....XXXXXXXX.XXXX.......X
..................XXX.XX.....XXXXXXXXXX..........X
................XXX....XX......XXXXXX............X
X..XXX......XXXXXXX...XXXXXX....................XX
XXXX........XXXXX..........XXXXXXX.............XXX
XXXX......XXX...................X..............XXX
XXXX........X..................................XXX
XXXXX...............XXXX.....................XXXXX
XXXXX................XXXXX.....XX..........XXXXXXX
XXXXXXXXXXXXX.......XXXXXXX...XXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXX....XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXX.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/zelva-w.png")

zelva = addModel("item_light", 28, 20,
[[
..XXX..
..XXX..
XXXXXXX
]])
addItemAnim(zelva, "images/"..codename.."/z-_00.png")
-- extsize=45; first="z-0.BMP"

item_light = addModel("item_light", 26, 6,
[[
XXXXX.
X..X..
...X..
...X..
...XXX
]])
addItemAnim(item_light, "images/"..codename.."/koral2.png")

item_heavy = addModel("item_heavy", 16, 28,
[[
....X.....
..XXX.....
...X......
XXXXXXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/3-ocel.png")

big = addModel("fish_big", 43, 23,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

item_heavy = addModel("item_heavy", 34, 7,
[[
.X.
XXX
.X.
]])
addItemAnim(item_heavy, "images/"..codename.."/5-ocel.png")

item_light = addModel("item_light", 14, 34,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

perla = addModel("item_light", 21, 22,
[[
X
]])
addItemAnim(perla, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

item_light = addModel("item_light", 23, 30,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/musle_troj.png")

item_heavy = addModel("item_heavy", 38, 19,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/14-ocel.png")

item_heavy = addModel("item_heavy", 38, 16,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/15-ocel.png")

item_heavy = addModel("item_heavy", 39, 16,
[[
X
X
X
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/16-ocel.png")

item_heavy = addModel("item_heavy", 39, 22,
[[
X.
X.
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/17-ocel.png")

small = addModel("fish_small", 44, 13,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

item_heavy = addModel("item_heavy", 42, 30,
[[
XXXXX
...XX
]])
addItemAnim(item_heavy, "images/"..codename.."/20-ocel.png")

item_heavy = addModel("item_heavy", 35, 21,
[[
XX
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/24-ocel.png")

item_heavy = addModel("item_heavy", 31, 1,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/25-ocel.png")

rybka = addModel("item_light", 31, 3,
[[
XX
]])
addItemAnim(rybka, "images/"..codename.."/rybicka_h_00.png")
-- extsize=3; first="rybicka h1.BMP"

item_light = addModel("item_light", 2, 2,
[[
.XX....
..X....
XXX....
..X.XX.
..XXXXX
...X...
...X...
...X...
...XX..
]])
addItemAnim(item_light, "images/"..codename.."/koral1.png")

item_light = addModel("item_light", 10, 6,
[[
.X.
.X.
XX.
.X.
.XX
]])
addItemAnim(item_light, "images/"..codename.."/koral3.png")

item_light = addModel("item_light", 33, 9,
[[
......XX
XXXXXXX.
.X.X.X..
]])
addItemAnim(item_light, "images/"..codename.."/koral4.png")

item_light = addModel("item_light", 21, 0,
[[
X.....
XXX...
..XXXX
...XX.
..XX..
..X...
]])
addItemAnim(item_light, "images/"..codename.."/koral5.png")

item_light = addModel("item_light", 5, 11,
[[
XXXXXXX
.X..X..
XXX.X..
....XXX
....X.X
]])
addItemAnim(item_light, "images/"..codename.."/koral6.png")

item_light = addModel("item_light", 11, 31,
[[
...X
XXXX
...X
]])
addItemAnim(item_light, "images/"..codename.."/koral7.png")

item_light = addModel("item_light", 38, 31,
[[
X....X
XXXXXX
...X..
]])
addItemAnim(item_light, "images/"..codename.."/koral8.png")

item_light = addModel("item_light", 39, 14,
[[
X.....
XXXXXX
.X...X
]])
addItemAnim(item_light, "images/"..codename.."/koral9.png")

item_light = addModel("item_light", 7, 19,
[[
.....XXXXXX.
.XXXXX..X.XX
XX..........
.XXX........
...X........
]])
addItemAnim(item_light, "images/"..codename.."/koral10.png")



