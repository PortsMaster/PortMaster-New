
createRoom(40, 30, "images/"..codename.."/ves-p.png")
setRoomWaves(5, 10, 4)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXX...XXXXXXXXXXXXXXXXXXXX
XX..............X...X...................
XX..............X...X....XXX....X.......
XX........XXXX..XX.XX....XXX....X.......
XX.........................X............
XX......................................
XXXXX..........X.....XX.....X.....XX....
XXXXX..........X.....XX.....X.....XX....
XXXXX....XX....X.....XX.....X.....XX....
XXXXX.....X....X.....XX.....X.....XX....
XXXXX.....X....X.....XX.....X.....XX....
XXXX......X....X.....XX.....X.....XX....
XXX............X.....XX.....X.....XX....
XX.............X.....XX.....X.....XX....
X..............X.....XX.....X.....XX....
X..............X.....XX.....X.....XX....
X..............X.....XX.....X.....XX....
X....................XX.....X.....XX....
XXXXX..........X.....XX.....X.....XX....
XX.............X.....XX.....X.....XX....
XX.............X.....XX.....X.....XX....
XX.............X.....XX.....X..........X
XX.............X.....XX.....X..........X
XXXXX................XX...........XXXXXX
XX...................XX...........XXXXXX
XX................................XXXXXX
XX.X......X.......XXXXXX...XXXXXXXXXXXXX
XXXXXX....XXXXXX..XXXXXX...XXXXXXXXXXXXX
XXXXXX....XXXXXX..XXXXXX...XXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/ves-w.png")

amp1 = addModel("item_light", 28, 4,
[[
XX
XX
]])
addItemAnim(amp1, "images/"..codename.."/amp_00.png")
-- extsize=9; first="amp1.BMP"

amp2 = addModel("item_light", 21, 4,
[[
XX
XX
]])
addItemAnim(amp2, "images/"..codename.."/amp_00.png")
-- extsize=9; first="amp1.BMP"

amp3 = addModel("item_light", 14, 4,
[[
XX
XX
]])
addItemAnim(amp3, "images/"..codename.."/amp_00.png")
-- extsize=9; first="amp1.BMP"

hlava = addModel("item_light", 33, 3,
[[
XX
XX
XX
]])
addItemAnim(hlava, "images/"..codename.."/hlava_00.png")
-- extsize=19; first="hlava 1.BMP"

small = addModel("fish_small", 5, 20,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 4, 21,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

item_light = addModel("item_light", 17, 2,
[[
XXX
.X.
.X.
.X.
]])
addItemAnim(item_light, "images/"..codename.."/stalaktit.png")

item_heavy = addModel("item_heavy", 5, 7,
[[
XXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/ves-8-tmp.png")

item_light = addModel("item_light", 6, 2,
[[
XXX
.X.
.X.
.X.
XXX
]])
addItemAnim(item_light, "images/"..codename.."/stalagnat.png")

item_light = addModel("item_light", 5, 17,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/sloupek.png")

item_light = addModel("item_light", 4, 25,
[[
.X
XX
]])
addItemAnim(item_light, "images/"..codename.."/lebka.png")

item_heavy = addModel("item_heavy", 7, 12,
[[
..X....
.XXX...
XX.X.X.
...X.X.
...XXX.
...X.X.
...X.X.
...XXX.
...X.X.
...X.X.
..XXXX.
.....X.
.....X.
...XXXX
......X
]])
addItemAnim(item_heavy, "images/"..codename.."/ves-12-tmp.png")

krabik = addModel("item_light", 11, 2,
[[
XX
]])
addItemAnim(krabik, "images/"..codename.."/krab_00.png")
-- extsize=5; first="krab1.BMP"

item_light = addModel("item_light", 26, 21,
[[
.X.
.X.
.X.
.X.
XXX
]])
addItemAnim(item_light, "images/"..codename.."/stalagnit.png")

item_light = addModel("item_light", 15, 17,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 15, 26,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_heavy = addModel("item_heavy", 35, 5,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/ves-17-tmp.png")



