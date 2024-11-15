
createRoom(51, 36, "images/"..codename.."/gral-pozadi.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXX........XXXXXXX.......
XXXXXXXXXXXXXXXX.XXXXXXXXXXXXXXX....XXXXXXXXX.XX...
XXXXXXX....XXXX......XXXXXXXXXXXX...XXXXXXXX..XXX..
XXX..........X.................XXX........XX..XXX..
XXX..............................XX...........X....
XXX...............................................X
XX....XXXX.XXXX.X.................................X
XX....XXX..XX............................X.XXX....X
XX.........X.............................X.X......X
XX.....................XXXX..............X.X......X
XX................XXXXXXXXXX....................XXX
.....XXXXXX.......XXXXXXXXX........................
.................XXXXXXXXXXX.......................
XXXX.XXXX......XXXXXX....XXXXXXX...XXXX....XX..X.XX
XX....XX........XXXX......XXX..X..XXXXX....XX..X..X
XX................................XXXX.........X..X
X..................................XXX.....X......X
X.................XXXX..XXXX..XXX..XX.....XX.......
X.................XX......XX...XX..XX..............
X......XXXX....................X...XX.....X...X..XX
X.....XXXXX....................XX.XXX.........X..XX
X.....XXXXX....X..XXXXXXXXXX..XXXXXXX.....XXXXX..XX
X........XXX...X..XX..........X.XXXXX........XX...X
X.........XX...X..................XX...............
XXX.......XX...X.............................XXX...
XX...X....XX.....................................XX
XX...X....XX................................XX....X
X.........XXX...............................X.....X
X.................................................X
X..X.................XXXXXXXX..............XXXXXXXX
X........XXX.....XXXXXXXXXXXXXXX........XXXXXXXXXXX
X.....................................XXXXXXXXXXXXX
X..................................................
.......X...XXXXXX..................................
....XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....XXXXXX...XXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/gral-zed.png")

light = addModel("item_light", 22, 14,
[[
XX
XX
]])
addItemAnim(light, "images/"..codename.."/gral_00.png")

aura = addModel("item_light", 22, 13,
[[
XX
]])
addItemAnim(aura, "images/"..codename.."/aura_00.png")
-- extsize=11; first="aura0.BMP"

item_heavy = addModel("item_heavy", 20, 16,
[[
..XX..
..XX..
XXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/8-ocel.png")

item_heavy = addModel("item_heavy", 32, 27,
[[
.X
.X
.X
.X
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/12-ocel.png")

item_heavy = addModel("item_heavy", 37, 10,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/16-ocel.png")

item_heavy = addModel("item_heavy", 27, 20,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/16-ocel.png")

dark = addModel("item_light", 5, 4,
[[
XX
XX
]])
addItemAnim(dark, "images/"..codename.."/gral_00.png")

item_heavy = addModel("item_heavy", 23, 6,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/16-ocel.png")

item_heavy = addModel("item_heavy", 19, 33,
[[
XXX
]])
addItemAnim(item_heavy, "images/"..codename.."/22-ocel.png")

item_heavy = addModel("item_heavy", 2, 8,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/27-ocel.png")

item_heavy = addModel("item_heavy", 10, 9,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/30-ocel.png")

item_heavy = addModel("item_heavy", 9, 6,
[[
.X
XX
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/29-ocel.png")

big = addModel("fish_big", 46, 32,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

small = addModel("fish_small", 1, 33,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

item_heavy = addModel("item_heavy", 42, 7,
[[
X.
X.
X.
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/33-ocel.png")

item_heavy = addModel("item_heavy", 44, 1,
[[
.X
XX
XX
.X
]])
addItemAnim(item_heavy, "images/"..codename.."/35-ocel.png")

item_heavy = addModel("item_heavy", 48, 13,
[[
X.
XX
X.
X.
]])
addItemAnim(item_heavy, "images/"..codename.."/40-ocel.png")

item_heavy = addModel("item_heavy", 45, 5,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/30-ocel.png")

item_heavy = addModel("item_heavy", 2, 24,
[[
.X.
XXX
XX.
]])
addItemAnim(item_heavy, "images/"..codename.."/43-ocel.png")

item_light = addModel("item_light", 23, 19,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 21, 19,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 19, 19,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 29, 15,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 26, 15,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 24, 15,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 20, 15,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 18, 15,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 32, 32,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 41, 28,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 43, 24,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 48, 17,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 45, 17,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 37, 11,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 42, 11,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 6, 31,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 3, 27,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 9, 17,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 1, 11,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 10, 4,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 23, 7,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 34, 2,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")

item_light = addModel("item_light", 25, 19,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/gral_00.png")



