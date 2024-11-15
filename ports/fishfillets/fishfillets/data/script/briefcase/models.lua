
createRoom(48, 37, "images/"..codename.."/kufrik-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
.XXXX...........................................
..XXXXXX........XXXXXXX.........................
...XXXXXXXXXXXXXXXXXXXXX.....XXX.......XX.......
X....XXXXXXXXXXXXXXXXXXXXXXXXXXXXX..XXXXXXX.....
X.....XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX...
X.............XXXXX......XXXX..XXXXXXXXXXXXXXX..
XX..............XX...............XXXXXXXXXXXXXXX
XXX..............................XXXXXXXXXXXXXXX
XXX...................................XXXXXXXXXX
XXXX...................................XXXXXXXXX
XXXXXXXXXXXXXXXXX.......................XXXXXXXX
XXXXXXXXXXXXXXXXX.......................XXXXXXXX
XXXXXXXXXXXXXXXXX........................XXXXXXX
XXXX.....XXXXXXXX........................XXXXXXX
XX.......XXXXXXXXXXXXXXXXXXXX.............XXXXXX
X..............XXXXXXXXXXXXX..............XXXXXX
X...............XXXXXXXXXXXX...XX.........XXXXXX
X...............XXXXXXXXXXXX...XXXX.......XXXXXX
X..........XX...XXXX...X...X...XXXX.......XXXXXX
XX...............X............XXXX........XXXXXX
XXXXX............X.............XXX........XXXXXX
XX...............X.............XX.........XXXXXX
X.........................................XXXXXX
X........................................XXXXXXX
X........................XXXX............XXXXXXX
XX.......................XXXX...........XXXXXXXX
XXXXXX...................XXXXXX........XXXXXXXXX
XX.......................XXXXXXXX....XXXXXXXXXXX
X................X.......XXXXXXXXXXXXXXXXXXXXXXX
X...............XX....XX.XXXXXXXXXXXXXXXXXXXXXXX
X............XXXXX....XXXXXXXXXXXXXXXXXXXXXXXXXX
X...............XX....XXXXXXXXXXXXXXXXXXXXXXXXXX
XX...............X.....XXXXXXXXXXXXXXXXXXX......
XX...............X........XXXXXXXXXXXXX.........
XXXX...........XXXX.............................
XXXXXXXXXXXXXXXXXXXX........................XXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/kufrik-w.png")

kufr = addModel("item_light", 10, 3,
[[
........
........
........
........
XXXXXXXX
XXXXXXXX
XXXXXXXX
]])
addItemAnim(kufr, "images/"..codename.."/kufr_00.png")
-- extsize=10; first="kufr0.BMP"

small = addModel("fish_small", 2, 4,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

big = addModel("fish_big", 3, 6,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

ocel = addModel("item_heavy", 28, 18,
[[
X.
X.
X.
X.
X.
XX
]])
addItemAnim(ocel, "images/"..codename.."/4-ocel.png")

item_light = addModel("item_light", 24, 18,
[[
XXX
XXX
XXX
XXX
XXX
]])
addItemAnim(item_light, "images/"..codename.."/cedule.png")

item_light = addModel("item_light", 25, 23,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/matka_a.png")

item_light = addModel("item_light", 5, 23,
[[
X...
XXXX
X...
]])
addItemAnim(item_light, "images/"..codename.."/kladivo.png")

item_light = addModel("item_light", 11, 27,
[[
XXXXX
XX...
XXXXX
]])
addItemAnim(item_light, "images/"..codename.."/kleste.png")

item_light = addModel("item_light", 11, 15,
[[
.X
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/kanystr.png")

item_heavy = addModel("item_heavy", 13, 26,
[[
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/10-ocel.png")



