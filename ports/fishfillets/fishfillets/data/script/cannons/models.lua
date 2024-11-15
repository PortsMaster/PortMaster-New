
createRoom(30, 27, "images/"..codename.."/dela-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XX..........................XX
XX..........................XX
XX..........................XX
XX..........................XX
..............................
..............................
..............................
XX..........................XX
XXXXXXXXXX.............XXXXXXX
XX...................XX.....XX
XX.................XX.......XX
.................XX...........
...............XX.............
..............................
XX..........................XX
XXXXXXXXXX..........XXXXXXXXXX
XXX..........XX............XXX
XXX............XX..........XXX
XXX..............XX........XXX
XXX................XX.....XXXX
XXXX......................XXXX
XXXXX....................XXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/dela-w.png")

item_heavy = addModel("item_heavy", 3, 15,
[[
XX
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel-1.png")

delo1 = addModel("item_light", 2, 2,
[[
XXXXX.
XX..XX
....XX
]])
addItemAnim(delo1, "images/"..codename.."/delo_00.png")
-- extsize=2; first="delo1.BMP"

item_heavy = addModel("item_heavy", 25, 15,
[[
XX
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel-1.png")

item_heavy = addModel("item_heavy", 4, 8,
[[
XX
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel-1.png")

item_heavy = addModel("item_heavy", 24, 8,
[[
XX
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel-1.png")

delo3 = addModel("item_light", 22, 2,
[[
.XXXXX
XX..XX
XX....
]])
addItemAnim(delo3, "images/"..codename.."/delorev_00.png")
-- extsize=2; first="deloRev1.BMP"

item_light = addModel("item_light", 11, 21,
[[
XX
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/sud.png")

item_light = addModel("item_light", 16, 4,
[[
XX
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/sud.png")

item_light = addModel("item_light", 12, 16,
[[
....X..
XXXXXXX
....X..
]])
addItemAnim(item_light, "images/"..codename.."/mec.png")

small = addModel("fish_small", 14, 7,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

big = addModel("fish_big", 17, 7,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

item_light = addModel("item_light", 9, 13,
[[
XX
X.
X.
X.
]])
addItemAnim(item_light, "images/"..codename.."/sekera.png")

delo2 = addModel("item_light", 1, 13,
[[
XXXXX.
XX..XX
....XX
]])
addItemAnim(delo2, "images/"..codename.."/delo_00.png")
-- extsize=2; first="delo1.BMP"

delo4 = addModel("item_light", 23, 13,
[[
.XXXXX
XX..XX
XX....
]])
addItemAnim(delo4, "images/"..codename.."/delorev_00.png")
-- extsize=2; first="deloRev1.BMP"

item_light = addModel("item_light", 9, 23,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/koulea.png")

item_light = addModel("item_light", 10, 23,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/kouleb.png")

item_light = addModel("item_light", 11, 20,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/koulec.png")

item_light = addModel("item_light", 8, 9,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/kouled.png")



