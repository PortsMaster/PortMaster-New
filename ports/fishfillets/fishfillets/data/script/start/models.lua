
createRoom(29, 27, "images/"..codename.."/prvni-p.png")
setRoomWaves(4, 12, 5)

room = addModel("item_fixed", 0, 0,
[[
.............................
.............XX.XX...........
..............X.X............
..............X.X............
.XXXX.........X.X.....XX.X.XX
XXXXX.....XXXXX.X...XXXXXXXXX
XXXXXXXXXXXXXXX.XXXXXXXXXXXXX
XXXXXXXXXXXXXXX.XXXXXXXXXXXXX
XXXXXXXXXXX.....XXXXXXXXXXXXX
XXXXXXX...........XXXXXXXXXXX
XXXX.................XXXXXXXX
XXX....................XXXXXX
XXX....................XXXXXX
XXX.....................XXXXX
XXX......................XXXX
XXX........................XX
XXX..........................
XXX..........................
XXX..........................
XXXX.........................
XXXXX.....................XXX
XXXXXXX..................XXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/prvni-w.png")

item_light = addModel("item_light", 7, 17,
[[
X...
X...
XXXX
X..X
X..X
]])
addItemAnim(item_light, "images/"..codename.."/zidle_m.png")

zidlev = addModel("item_light", 20, 17,
[[
...X
...X
XXXX
X..X
X..X
]])
addItemAnim(zidlev, "images/"..codename.."/zidle_v.png")

item_light = addModel("item_light", 12, 18,
[[
XXXXXXX
.X...X.
.X...X.
.X...X.
]])
addItemAnim(item_light, "images/"..codename.."/stul.png")

trubka = addModel("item_heavy", 15, 0,
[[
X
X
X
X
X
X
X
X
]])
addItemAnim(trubka, "images/"..codename.."/val_00.png")
-- extsize=8; first="val0.BMP"

small = addModel("fish_small", 8, 17,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

big = addModel("fish_big", 19, 17,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

item_light = addModel("item_light", 8, 18,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/polstar.png")



