
createRoom(50, 40, "images/"..codename.."/pozadi.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXX...................XXXXXXXXXXXXXX
XXXXXXXX.................................XXXXXXXXX
XXXXXXX.....................................XXXXXX
XXXXXX.......................................XXXXX
XXXXX.........................................XXXX
XX.............................................XXX
X...............................................XX
X................XX..X.X.X.X.X..XX..............XX
X...............XXXX.X.X.X.X.X.XXXX.............XX
X................XX..X.X.X.X.X..XX..............XX
X...............................................XX
X................................................X
X................................................X
X...............................................XX
X...............................................XX
XX..............................................XX
XXX...........................................XXXX
XXX.............................................XX
XXXX..............................................
XXXX..............................................
XXXXX............XX......XX......XX................
XXXXXXXXXXXXXXX..XX......XX......XX..XXXXXXXXX....
XXXXXXXXXXXXXXX..XX......XX......XX..XXXXXXXXXX...
XXXXXXXXXXXXXXX..XX......XX......XX..XXXXXXXXXXX..
XXXXXXXXXXXXXXX..XX......XX......XX..XXXXXXXXXXX..
XXXXXXXXXXXXXXX..XX......XX......XX..XXXXXXXXXXX..
XXXXXXXXXXXXXXX..XX......XX......XX..XXXXXXXXXXX..
XXXXXXXXXXXXXXX..XXX.....XX......XX..XXXXXXXXXXXXX
XXXXXXXXXXXXXXX...XX.....XX..X...XX..XXXXXXXXXXXXX
XXXXXXXXXXXXXXX...XX.....XX..X...XX..XXXXXXXXXXXXX
XXXXXXXXXXXXXXX...XX.....XX..X...XX..XXXXXXXXXXXXX
XXXXXXXXXXXXXXX...XXX....XX..X...XX..XXXXXXXXXXXXX
XXXXXXXXXXXXXXXXX..XX....XX..X...XX..XXXXXXXXXXXXX
XXXXXXXXXXXXXXXXX..XX....XX..X...XX..XXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXX..XX...XX..X...XX..XXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXX...XX..X...XXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXX..XX..XXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXX..XXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/popredi.png")

celenka = addModel("item_light", 11, 18,
[[
.X
XX
.X
]])
addItemAnim(celenka, "images/"..codename.."/nindpar.png")

item_light = addModel("item_light", 47, 21,
[[
.X
.X
XX
]])
addItemAnim(item_light, "images/"..codename.."/kreveta.png")

item_light = addModel("item_light", 4, 17,
[[
.X.
.X.
XXX
.X.
.X.
]])
addItemAnim(item_light, "images/"..codename.."/kriz.png")

barva = addModel("item_light", 10, 20,
[[
.X
X.
]])
addItemAnim(barva, "images/"..codename.."/barva_00.png")

lebka = addModel("item_light", 10, 20,
[[
X.
.X
]])
addItemAnim(lebka, "images/"..codename.."/lebka_00.png")

ocel = addModel("item_heavy", 48, 19,
[[
XX
XX
]])
addItemAnim(ocel, "images/"..codename.."/ocel_00.png")

shrimp = addModel("item_light", 43, 20,
[[
XXX
..X
]])
addItemAnim(shrimp, "images/"..codename.."/shrimp_00.png")

big = addModel("fish_big", 39, 8,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

small = addModel("fish_small", 29, 12,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

sluchatko = addModel("item_light", 11, 13,
[[
...
.XX
..X
..X
..X
..X
..X
..X
.XX
]])
addItemAnim(sluchatko, "images/"..codename.."/zsluch_00.png")
