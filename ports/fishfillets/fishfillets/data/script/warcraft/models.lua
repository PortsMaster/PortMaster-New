
createRoom(52, 37, "images/"..codename.."/warcr2-p1.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXX..............XXXXXXXXXXX........XXX......XXXXXX
XX......XX.............XXX.....................XXXXX
X.......XX....................................XXXXXX
X......XXXX................................XXXXXXXXX
XXX...XXXXX..............................XXXXXXXXXXX
XXXXXXXXXXXX...........................XXXXXXXXXXXXX
XXXXXXXXXXXX.........X.................XXXXXXXXXXXXX
XXXXXXXXX...........XXXXXXX...............XXX..XXXXX
XXXX..............XXXXXXXXXXXXXX................XXXX
..............X....XXXXXXXXXXXXX....XX............XX
..............XX.......XXXXXXXX.....XX..............
X.............X.........XXXX.........X..............
X..................................................X
X............X.......................XX............X
XX..........XX......................XX.............X
XX..................................X..............X
XXXX................................X..............X
XXXX...............................................X
XXXX...........................................XX..X
XXXXXXXX.........XXXX.X.XXXX............XXXX..XXX..X
XXXXXXXXXXX...XXXXXXXXXXXXXXX.XXXXX.....XXXXX.XX...X
XXXXXXXXXXX......XXXXXXXXXXXXXXXX........XX.XXX...XX
XXXXXXXXXX.......XXXXXXXXXXXXXXXX.................XX
XXXXXXXX.........XXXXXXXXX...X....................XX
XXXXXX...........XXXXXXXX.........................XX
XX.................XXX.....................XX......X
X..................XXX................XXXXXXXX.....X
XX.....................................XXXXXXX.....X
XXXX...................................XXXX........X
XXXXX..................................XXX........XX
XXX....................................XX........XXX
XX......................................X.........XX
X..................................................X
X..................................................X
XX................................................XX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/warcr2-w.png")

knight1 = addModel("item_light", 44, 33,
[[
XX.
XXX
.XX
]])
addItemAnim(knight1, "images/"..codename.."/jezdec.png")

item_light = addModel("item_light", 25, 33,
[[
.XX
.XX
XXX
]])
addItemAnim(item_light, "images/"..codename.."/vez.png")

dul2 = addModel("item_light", 7, 15,
[[
.XXXX.
XXXXXX
XXXXXX
XXXXXX
XXXXX.
]])
addItemAnim(dul2, "images/"..codename.."/dul.png")

item_light = addModel("item_light", 3, 16,
[[
XX
.X
]])
addItemAnim(item_light, "images/"..codename.."/peasant.png")

item_light = addModel("item_light", 45, 18,
[[
XX
.X
]])
addItemAnim(item_light, "images/"..codename.."/peasant.png")

item_light = addModel("item_light", 19, 6,
[[
XX
.X
]])
addItemAnim(item_light, "images/"..codename.."/peasant.png")

item_light = addModel("item_light", 2, 12,
[[
XXXXXXXXXXXX
XXXXXXXXXXXX
]])
addItemAnim(item_light, "images/"..codename.."/surrend.png")

item_light = addModel("item_light", 38, 12,
[[
XXXXXXXXXXXX
XXXXXXXXXXXX
]])
addItemAnim(item_light, "images/"..codename.."/exit.png")

item_light = addModel("item_light", 38, 6,
[[
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/kopi.png")

item_light = addModel("item_light", 11, 3,
[[
.XX.
XXXX
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/balista.png")

dul1 = addModel("item_light", 38, 15,
[[
.XXXX.
XXXXXX
XXXXXX
XXXXXX
XXXXX.
]])
addItemAnim(dul1, "images/"..codename.."/dul.png")

item_light = addModel("item_light", 37, 3,
[[
.XX.
XXXX
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/balista.png")

item_light = addModel("item_light", 13, 6,
[[
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/kopi.png")

item_light = addModel("item_light", 36, 33,
[[
.XX
.XX
XXX
]])
addItemAnim(item_light, "images/"..codename.."/vez.png")

item_light = addModel("item_light", 46, 17,
[[
XX
.X
]])
addItemAnim(item_light, "images/"..codename.."/peasant.png")

small = addModel("fish_small", 1, 34,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

big = addModel("fish_big", 47, 33,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

item_heavy = addModel("item_heavy", 4, 29,
[[
...XX..
.XXXXX.
XXXXXXX
XXXXXXX
XXXXXX.
.XXXXX.
..XXXX.
]])
addItemAnim(item_heavy, "images/"..codename.."/hradt.png")

item_light = addModel("item_light", 5, 18,
[[
XX
X.
]])
addItemAnim(item_light, "images/"..codename.."/peasantl.png")

item_light = addModel("item_light", 45, 25,
[[
XX
X.
]])
addItemAnim(item_light, "images/"..codename.."/peasantl.png")

knight2 = addModel("item_light", 5, 1,
[[
XX.
XXX
.XX
]])
addItemAnim(knight2, "images/"..codename.."/jezdec.png")

archer1 = addModel("item_light", 48, 29,
[[
XX
XX
]])
addItemAnim(archer1, "images/"..codename.."/lucistnik.png")

archer2 = addModel("item_light", 42, 2,
[[
XX
XX
]])
addItemAnim(archer2, "images/"..codename.."/lucistnik.png")



