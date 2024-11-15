
createRoom(43, 35, "images/"..codename.."/koraly-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....XX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....XX....XX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.....XX....XX
XXXXXXXXXX............XXXXXXXXXX.........XX
XXXXX.....................................X
XX........................................X
XXX......X.XXXXXXXXXXXX.XXXXXX.......XX...X
XXX......XXXXXXXXXXXXXXXXXXXX......XXXXXXXX
XX........XXXXXXXXXXXXXXXXXX.........XXXXXX
X............XXXXX...XXX.............XXXXXX
X.....................X...............XXXXX
XX.XXX................................XXXXX
XXXXXXXXXXXX.XX...........XX...........XXXX
XX....XXXXXX............XXXXX..........XXXX
X.......XXXX...........XXXXX............XXX
XXXX....XXXX.............XX.............XXX
XXX....XXX..............................XXX
XX..XXXXXX...............................XX
XX.....XX...............................XXX
XXXXXX.XX.......X.......................XXX
..XXXX........XXXX..XXX....XX...........XXX
...XXXX.....XXXXXXX...XX.XXXXX.X.........XX
X..XXXX........XXX....XXXXXXXXXXX........XX
X...XXX........XXX...XXXXXXXXXXXXX......XXX
X...XX.........XXX..XXXXXXXXX............XX
XX..............XXX.XX...................XX
XX..............XX.......................XX
XX.......X.................XX...........XXX
XX......XX............XXX.XXX...........XXX
XXX.....XX............XXXXXXXX..........XXX
XXX.....XXX..........XXXXXXXXXX........XXXX
XXXXX..XXXX..XX......XXXXXXXXXX........XXXX
XXXXXXXXXXXXXXXX...XXXXXXXXXXXX.......XXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/koraly-w.png")

krab1 = addModel("item_light", 23, 12,
[[
XX
]])
addItemAnim(krab1, "images/"..codename.."/krab_00.png")
-- extsize=9; first="krab1.BMP"

balalajka = addModel("item_light", 18, 18,
[[
.XXX.
XXXXX
]])
addItemAnim(balalajka, "images/"..codename.."/balal_00.png")
-- extsize=10; first="balal 1.BMP"

sas1 = addModel("item_light", 10, 4,
[[
.X
.X
]])
addItemAnim(sas1, "images/"..codename.."/sasanka_00.png")
-- extsize=7; first="sasanka1.BMP"

sas2 = addModel("item_light", 12, 4,
[[
.X
.X
]])
addItemAnim(sas2, "images/"..codename.."/sasanka_00.png")
-- extsize=7; first="sasanka1.BMP"

sas3 = addModel("item_light", 14, 4,
[[
.X
.X
]])
addItemAnim(sas3, "images/"..codename.."/sasanka_00.png")
-- extsize=7; first="sasanka1.BMP"

sas4 = addModel("item_light", 16, 4,
[[
.X
.X
]])
addItemAnim(sas4, "images/"..codename.."/sasanka_00.png")
-- extsize=7; first="sasanka1.BMP"

sas5 = addModel("item_light", 18, 4,
[[
.X
.X
]])
addItemAnim(sas5, "images/"..codename.."/sasanka_00.png")
-- extsize=7; first="sasanka1.BMP"

sas6 = addModel("item_light", 20, 4,
[[
.X
.X
]])
addItemAnim(sas6, "images/"..codename.."/sasanka_00.png")
-- extsize=7; first="sasanka1.BMP"

item_heavy = addModel("item_heavy", 26, 10,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel-2.png")

item_light = addModel("item_light", 27, 11,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/maly_snek_00.png")
-- extsize=3; first="maly snek1.BMP"

elko = addModel("item_heavy", 30, 2,
[[
XXXX
...X
...X
]])
addItemAnim(elko, "images/"..codename.."/ocel-1.png")

krab2 = addModel("item_light", 37, 5,
[[
XX
]])
addItemAnim(krab2, "images/"..codename.."/krab_00.png")
-- extsize=9; first="krab1.BMP"

krab3 = addModel("item_light", 2, 14,
[[
XX
]])
addItemAnim(krab3, "images/"..codename.."/krab_00.png")
-- extsize=9; first="krab1.BMP"

krab4 = addModel("item_light", 11, 20,
[[
XX
]])
addItemAnim(krab4, "images/"..codename.."/krab_00.png")
-- extsize=9; first="krab1.BMP"

krab5 = addModel("item_light", 4, 16,
[[
XX
]])
addItemAnim(krab5, "images/"..codename.."/krab_00.png")
-- extsize=9; first="krab1.BMP"

krab6 = addModel("item_light", 22, 27,
[[
XX
]])
addItemAnim(krab6, "images/"..codename.."/krab_00.png")
-- extsize=9; first="krab1.BMP"

item_heavy = addModel("item_heavy", 18, 24,
[[
XX
.X
.X
.X
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel-3.png")

big = addModel("fish_big", 2, 26,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

small = addModel("fish_small", 2, 25,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

item_light = addModel("item_light", 40, 6,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/shell1.png")

sepie = addModel("item_light", 10, 11,
[[
XXX
..X
..X
]])
addItemAnim(sepie, "images/"..codename.."/sepie_00.png")
-- extsize=12; first="sepie 1.BMP"



