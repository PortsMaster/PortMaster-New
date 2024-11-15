
createRoom(28, 25, "images/"..codename.."/recycled-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXX.....XXXXXXXXXXX
XXXXXXXXXX..............XXXX
XXX..XX..................XXX
XXX......................XXX
XXX.......................XX
XXX...XX..................XX
XXX...XX..................XX
XX........................XX
XX........................XX
XX........................XX
XX........................XX
XX........................XX
XX........................XX
XX.................XXXXXXXXX
XXX................X......XX
XXX.......................XX
XXXX......................XX
XXXXXXXXXXXXX...XXXXXX....XX
XXXXXXXXX.................XX
XXXX......................XX
................XXXXXXXXXXXX
..............XXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/recycled-w.png")

item_light = addModel("item_light", 20, 8,
[[
.XX
.X.
.X.
.X.
.XX
XX.
]])
addItemAnim(item_light, "images/"..codename.."/koral1.png")

item_light = addModel("item_light", 9, 8,
[[
.X.
.X.
.XX
.X.
XX.
]])
addItemAnim(item_light, "images/"..codename.."/koral2.png")

valec = addModel("item_heavy", 13, 3,
[[
XX
X.
X.
X.
X.
X.
X.
]])
addItemAnim(valec, "images/"..codename.."/3-ocel.png")

item_light = addModel("item_light", 6, 13,
[[
.XXXXX
..X..X
..X...
..X...
XXX...
]])
addItemAnim(item_light, "images/"..codename.."/koral3.png")

krab = addModel("item_light", 6, 5,
[[
XX
]])
addItemAnim(krab, "images/"..codename.."/krab_00.png")
-- extsize=9; first="krab0.BMP"

small = addModel("fish_small", 15, 6,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 9, 5,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")



