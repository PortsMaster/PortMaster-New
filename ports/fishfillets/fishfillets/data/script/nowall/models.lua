
createRoom(30, 34, "images/"..codename.."/pozadi.png")
--setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, -37,
[[
.
]])
addItemAnim(room, "images/"..codename.."/hvezdy2.png")

item_heavy = addModel("item_heavy", 4, 14,
[[
...XXXXXXXXXXXXXXXXXXXXXXX
...X..............X......X
...X..............X......X
...X..............X......X
...X........XXXXXXX......X
...X..........X..........X
...X........XXX..........X
...X.....................X
.........................X
.........................X
...X.....................X
...X.....................X
...X.....................X
...X.....................X
...X.........XXXXXXXXXXXXX
XXXXXXXXXXXXXX............
]])
addItemAnim(item_heavy, "images/"..codename.."/vocel.png")

item_light = addModel("item_light", 11, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/perla_00.png")

item_light = addModel("item_light", 15, 16,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/perla_00.png")

item_light = addModel("item_light", 15, 15,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/krab_00.png")

item_light = addModel("item_light", 15, 17,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/krab_00.png")

item_light = addModel("item_light", 17, 16,
[[
X.
XX
]])
addItemAnim(item_light, "images/"..codename.."/plz_00.png")

item_light = addModel("item_light", 17, 27,
[[
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/matrace.png")

item_light = addModel("item_light", 22, 24,
[[
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/matrace.png")

item_light = addModel("item_light", 20, 26,
[[
XX..
.XXX
]])
addItemAnim(item_light, "images/"..codename.."/drak_m_00.png")

item_light = addModel("item_light", 25, 25,
[[
X.
XX
X.
]])
addItemAnim(item_light, "images/"..codename.."/netopejr_00.png")

item_light = addModel("item_light", 5, 12,
[[
X.
X.
X.
X.
X.
X.
X.
X.
X.
X.
XX
.X
.X
.X
.X
.X
.X
]])
addItemAnim(item_light, "images/"..codename.."/zlato3.png")

item_heavy = addModel("item_heavy", 3, 32,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/mocel.png")

small = addModel("fish_small", 15, 19,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 11, 30,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")
