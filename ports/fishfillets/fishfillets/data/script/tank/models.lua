
createRoom(50, 37, "images/"..codename.."/svatba-pozadi.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXX..X..........................................
X......XXXXXXXXXXXXX..............................
X......X...........XX.............................
X......X............XX............................
X......X.............XX...........................
X........X............XX..........................
X......................XX.........................
XXXXX...XX..............XX........................
X........................XXXXXXXX.................
X.........................XXXXXXXXXXXXXXXXXXXXXXXX
X..........................XXXXXXXXXXXXXXXXXXXXXXX
X...........................XXXXXXXXXXXXXXXXXXXXXX
X.....X...XXXX...............XXXXXXXXXXXXXXXXXXXXX
X.............................XXXXXXXXXXXXXXXXXXXX
X.............................XXX.................
X.............................X...................
X......XXX....................X...................
X.....X.XX..X.................X...................
X..........XX.................X...................
X........................XXXXXX...................
X.................................................
X.................................................
XX........XX......XX.X.X.XXXXXX...................
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX...................
..................................................
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX...........
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX..........
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.........
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/svatba-okoli.png")

small = addModel("fish_small", 1, 18,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

big = addModel("fish_big", 1, 19,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

item_heavy = addModel("item_heavy", 24, 18,
[[
XX.
X..
XXX
..X
]])
addItemAnim(item_heavy, "images/"..codename.."/3-ocel.png")

item_heavy = addModel("item_heavy", 5, 4,
[[
XX
X.
X.
]])
addItemAnim(item_heavy, "images/"..codename.."/4-ocel.png")

item_heavy = addModel("item_heavy", 6, 5,
[[
X.......
XXXXXXXX
.......X
]])
addItemAnim(item_heavy, "images/"..codename.."/5-ocel.png")

item_heavy = addModel("item_heavy", 5, 3,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/6-ocel.png")

item_heavy = addModel("item_heavy", 6, 3,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/7-ocel.png")

item_heavy = addModel("item_heavy", 6, 22,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/6-ocel.png")

item_light = addModel("item_light", 10, 18,
[[
X.
XX
X.
X.
]])
addItemAnim(item_light, "images/"..codename.."/roboruka.png")

zebr = addModel("item_light", 6, 13,
[[
X
X
X
X
]])
addItemAnim(zebr, "images/"..codename.."/zebrik.png")

item_light = addModel("item_light", 1, 6,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/naboj.png")

mun3 = addModel("item_light", 5, 0,
[[
XX
]])
addItemAnim(mun3, "images/"..codename.."/naboj-a.png")

item_light = addModel("item_light", 6, 21,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/patron.png")

item_light = addModel("item_light", 9, 4,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/maly_snek_00.png")
-- extsize=3; first="maly snek1.BMP"

item_light = addModel("item_light", 3, 6,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/patron.png")

item_light = addModel("item_light", 9, 3,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/patron.png")

item_light = addModel("item_light", 11, 5,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/patron.png")

mun2 = addModel("item_light", 5, 1,
[[
XX
]])
addItemAnim(mun2, "images/"..codename.."/naboj-a.png")

mun1 = addModel("item_light", 5, 2,
[[
XX
]])
addItemAnim(mun1, "images/"..codename.."/naboj-a.png")



