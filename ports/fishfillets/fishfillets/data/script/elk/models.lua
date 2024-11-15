
createRoom(45, 32, "images/"..codename.."/deutsche-pozadi.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
.............................................
.............................................
....XX....XX.................................
.....X....X..................................
XXXXXX....XXXXXXXXXXXX...X...................
XXXXXX....XXXXXXXXXXXXX.XX...................
X....X....X.....X.....XXXX...................
X............................................
XX...................................X.......
XXX...................XXXX..........XX.......
XXXXX.XXXX.XXXXX.XXXXXX.XX..........XX.......
XXXXXXXXXXXXXXXXXXXXXX...X...........XX.XX...
XXXXXXXXXXXXXXXXXXXXXX...........XXXXXXXXX...
XXXXXXXXX.....................XXXXXXXXXXX....
XXXXXXXXXX..................XXX.....XXXXXX...
XXXXXXXXXXX................XXX......XXXXXXXXX
XXXXXXXXXXXXX........X....XXX........XXXXXXX.
XXXXXXXXXXXXXX.......XX..XXX...........XX....
XXXXXXXXXXXXXX........XXXXX............XX....
XXXXXXXXXXXXX..........XXX.............XX....
XXXXXXXXXXXX............X..............X.....
XXXXXXXXXXXX....XX.....................X.....
XXXXXXXXXXXX.....XX...................XX.....
XXXXXXXXXXXXX.....XX.................XX......
XXXXXXXXXXXXXX....XXX...............XXX......
XXXXXXXXXXXXXXXX.XXX...............XXX.......
XXXXXXXXXXXXXXXXXXX...............XXX........
XXXXXXXXXXXXXXXXXX...............XXXXXXXX....
XXXXXXXXXXXXXXXXXX...........XXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXX........XXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXX...XXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/deutsche-okoli.png")

papouch = addModel("item_light", 17, 8,
[[
XX.
XXX
]])
addItemAnim(papouch, "images/"..codename.."/papoucha_00.png")
-- extsize=1; first="papouchA1.BMP"

snecik = addModel("item_light", 11, 1,
[[
X
]])
addItemAnim(snecik, "images/"..codename.."/maly_snek_00.png")
-- extsize=3; first="maly snek1.BMP"

loos = addModel("item_light", 29, 20,
[[
.XX.XX.
XXX.XXX
XXXXXXX
XXX.XXX
.XXXXX.
..XXXX.
.XXXX..
.XX....
]])
addItemAnim(loos, "images/"..codename.."/los_00.png")
-- extsize=7; first="los1.BMP"

item_heavy = addModel("item_heavy", 31, 15,
[[
XX
X.
X.
X.
X.
]])
addItemAnim(item_heavy, "images/"..codename.."/4-ocel.png")

big = addModel("fish_big", 34, 17,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

small = addModel("fish_small", 8, 8,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

item_light = addModel("item_light", 13, 8,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/naboj.png")

item_heavy = addModel("item_heavy", 29, 6,
[[
XXX.....
..XXXX..
..X..XX.
..XX..X.
...XX.X.
....XXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/9-ocel.png")

item_light = addModel("item_light", 17, 6,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/naboj.png")



