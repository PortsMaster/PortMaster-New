
createRoom(51, 32, "images/"..codename.."/tetris-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....XXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....XXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....XXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....XXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....XXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....XXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....XXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....XXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXX...............XXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXX...............XXXXXXXXXXXX
XXXXX..................................XXXXXXXXXXXX
X......................................XXXXXXXXXXXX
X......................................XXXXXXXXXXXX
XXXXX..................................XXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXX..........XXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXX............XXXXXXXXXXXX
XXXXXXXXXXXX...........................XXXXXXXXXXXX
XXXXXXXXXXXXX...............X..........XXXXXXXXXXXX
XXXXXXXXXXXXXX...XXXXXXXXXXXX..........XXXXXXXXXXXX
XXXXXXXXXXXXXX...XXXXXXXXXXXX..........XXXXXXXXXXXX
XXXXXXXXXXXXXX...XXXXXXXXXXXX..........XXXXXXXXXXXX
XXXXXXXXXXXXXX...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/tetris-w2.png")

first_cube = addModel("item_light", 28, 13,
[[
XXXX
]])
addItemAnim(first_cube, "images/"..codename.."/dlouha.png")

item_light = addModel("item_light", 26, 12,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/ctverec.png")

item_light = addModel("item_light", 23, 12,
[[
.XX
XX.
]])
addItemAnim(item_light, "images/"..codename.."/zidle2l.png")

item_light = addModel("item_light", 20, 12,
[[
XXX
..X
]])
addItemAnim(item_light, "images/"..codename.."/elko2o.png")

item_light = addModel("item_light", 18, 11,
[[
.X
XX
X.
]])
addItemAnim(item_light, "images/"..codename.."/zidle1s.png")

item_light = addModel("item_light", 16, 11,
[[
X.
XX
X.
]])
addItemAnim(item_light, "images/"..codename.."/lods.png")

item_light = addModel("item_light", 13, 12,
[[
XX.
.XX
]])
addItemAnim(item_light, "images/"..codename.."/zidle1l.png")

item_light = addModel("item_light", 10, 12,
[[
..X
XXX
]])
addItemAnim(item_light, "images/"..codename.."/elko1l.png")

item_light = addModel("item_light", 8, 12,
[[
XXX
.X.
]])
addItemAnim(item_light, "images/"..codename.."/lodo.png")

item_light = addModel("item_light", 5, 12,
[[
XXX
X..
]])
addItemAnim(item_light, "images/"..codename.."/elko1o.png")

item_light = addModel("item_light", 12, 15,
[[
...............X.
XXXXXXXXXXXXXXXXX
.X...X...........
]])
addItemAnim(item_light, "images/"..codename.."/vozik.png")

trubka = addModel("item_heavy", 28, 3,
[[
.........X
.........X
.........X
.........X
.........X
.........X
XXXXXXXXXX
]])
addItemAnim(trubka, "images/"..codename.."/12-ocel.png")

item_heavy = addModel("item_heavy", 5, 10,
[[
XXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/13-ocel.png")

big = addModel("fish_big", 1, 11,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

small = addModel("fish_small", 14, 19,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")



