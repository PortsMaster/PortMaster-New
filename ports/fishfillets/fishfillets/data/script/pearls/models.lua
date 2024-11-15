
createRoom(33, 32, "images/"..codename.."/jednicky-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXX.XXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXX...XXXXXXXXXXXXXXXXXXXXXX
XXXXX........XXXXXXXXXX..XXXXXXXX
XXXXX............X...X.......XXXX
XXXX..........................XXX
XXXX.....XX....................XX
XXXX......X....XXXXX.XXXXXXXXX.XX
XXXXX.....X...............XXX..XX
..........X..........X.........XX
.....................X..........X
...XXXXX.XXXXXX.XXXXXX.XXXXXX...X
...XXXXX.X........XXXX.X..X.....X
....................XX.X.XX.....X
X..XXXXXXX.............X.XX....XX
XX.XXXXXXX.........XX.XX..X....XX
XX.XX..............XX.XXX.X....XX
XX.................XX.X...XX...XX
X......XXXXX.......XX.X.XXXX...XX
X.XX...XXXXX.......XX...XXXX...XX
X.XX...XXXX........XXXXXXXX....XX
X.XX.....X..........XXXX........X
X..X............................X
XX.X............................X
XX.XX...........................X
...XXX..........................X
.XXXX...........................X
.XXXX.X.........................X
..XXX.XXXX...XXXXXXXXXXXXXX.XXX.X
X.XX..XX.......XXXXXXXXXXXX.X....
X....XXX.XX.....................X
X.XX.....XXXXXXXXXXXXXXXXXXXXXXXX
X.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/jednicky-w.png")

small = addModel("fish_small", 12, 11,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 11, 4,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

zeva = addModel("item_light", 10, 15,
[[
XXXX
XXXX
]])
addItemAnim(zeva, "images/"..codename.."/zeva_00.png")
-- extsize=7; first="zeva0.BMP"

item_light = addModel("item_light", 6, 21,
[[
...X
...X
...X
XXXX
X...
]])
addItemAnim(item_light, "images/"..codename.."/koral.png")

item_light = addModel("item_light", 17, 13,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/musle_troj.png")

item_light = addModel("item_light", 16, 4,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/musla.png")

item_heavy = addModel("item_heavy", 9, 1,
[[
X
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/1-ocel.png")

item_heavy = addModel("item_heavy", 16, 9,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/2-ocel.png")

item_heavy = addModel("item_heavy", 16, 7,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/2-ocel.png")

item_heavy = addModel("item_heavy", 18, 5,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/2-ocel.png")

perla1 = addModel("item_light", 16, 8,
[[
X
]])
addItemAnim(perla1, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

perla2 = addModel("item_light", 16, 3,
[[
X
]])
addItemAnim(perla2, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

perla3 = addModel("item_light", 24, 9,
[[
X
]])
addItemAnim(perla3, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

perla4 = addModel("item_light", 24, 8,
[[
X
]])
addItemAnim(perla4, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

perla5 = addModel("item_light", 27, 5,
[[
X
]])
addItemAnim(perla5, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

perla6 = addModel("item_light", 24, 5,
[[
X
]])
addItemAnim(perla6, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

perla7 = addModel("item_light", 21, 5,
[[
X
]])
addItemAnim(perla7, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

perla8 = addModel("item_light", 4, 30,
[[
X
]])
addItemAnim(perla8, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

perla9 = addModel("item_light", 19, 26,
[[
X
]])
addItemAnim(perla9, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

perla10 = addModel("item_light", 22, 26,
[[
X
]])
addItemAnim(perla10, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

perla11 = addModel("item_light", 26, 26,
[[
X
]])
addItemAnim(perla11, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

perla12 = addModel("item_light", 25, 11,
[[
X
]])
addItemAnim(perla12, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

perla13 = addModel("item_light", 29, 26,
[[
X
]])
addItemAnim(perla13, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"

perla14 = addModel("item_light", 31, 29,
[[
X
]])
addItemAnim(perla14, "images/"..codename.."/perla_00.png")
-- extsize=3; first="perla0.BMP"



