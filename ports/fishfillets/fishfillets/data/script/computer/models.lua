
createRoom(36, 27, "images/"..codename.."/pocitac-pozadi.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXX...XXXXXX....XXXXXXXXXXXXXXXXXX
XXXXX...XXXXXXX...XXXXXXXXXXXXXXXXXX
XXXXXX...XXXXXX.XXXXXX..XXXXXXXXXXXX
XXXXXXX......XX...XXX....XXXXXXXXXXX
XXXXXXX............X.....XXXXXXXXXXX
XXXXXXX...................XXXXXXXXXX
XXXXXXXX....................XXXXXXXX
XXXXXXX......................XXXXXXX
XXXXX.........................XXXXXX
XXXXXXXX.....................XXXXXXX
XXXXXXXX....................XXXXXXXX
XXXXXXX............XX..........XXXXX
XXXXX.............XX............XXXX
XXXXXX..........................XXXX
XXXXXXX.........................XX..
XXXXXXX.............................
XXXXXXXX............................
XXXXXX............................X.
XXXXXX...........................XX.
XXXXXXX..........................X..
XXXXXX..............................
XXXX...............XX...............
XXXX................................
XXX.........................XX..X.XX
XXXX...X...........XXXX..XXXXXXXXXXX
XXXXXXXXX.........XXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXX....XXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/pocitac-okoli.png")

monitoor = addModel("item_light", 22, 11,
[[
XXX.......
XXXXXX....
XXXXXXXX..
XXXXXXXXXX
XXXXXXXXXX
XXXXXXXXXX
XXXXXXXX..
..XXXX....
]])
addItemAnim(monitoor, "images/"..codename.."/monitor.png")

pociitac = addModel("item_light", 21, 19,
[[
XXXXXXXXXXX
XXXXXXXXXXX
XXXXXXXXXXX
XXXXXXXXXXX
]])
addItemAnim(pociitac, "images/"..codename.."/pocitac.png")

item_light = addModel("item_light", 10, 23,
[[
XXXXXXXXX
XXXXXXXXX
]])
addItemAnim(item_light, "images/"..codename.."/klavesnice.png")

item_heavy = addModel("item_heavy", 22, 8,
[[
XXX
XXX
XXX
]])
addItemAnim(item_heavy, "images/"..codename.."/4-ocel.png")

item_light = addModel("item_light", 24, 6,
[[
X...
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/roura_st_a.png")

vrtidlo = addModel("item_light", 9, 4,
[[
...X
XXXX
...X
]])
addItemAnim(vrtidlo, "images/"..codename.."/vyvrtka.png")

small = addModel("fish_small", 12, 7,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 8, 6,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

item_light = addModel("item_light", 7, 8,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/cola.png")

item_light = addModel("item_light", 5, 21,
[[
XXX
.XX
]])
addItemAnim(item_light, "images/"..codename.."/kanystr.png")

item_light = addModel("item_light", 15, 0,
[[
XXX
X..
X..
]])
addItemAnim(item_light, "images/"..codename.."/roura_st.png")

item_light = addModel("item_light", 7, 23,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/cola.png")



