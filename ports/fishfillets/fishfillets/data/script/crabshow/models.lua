
createRoom(39, 32, "images/"..codename.."/secret-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
..XX.XX.....XX.XX.....XX.XX.....XX.XX..
...XXX.......XXX.......XXX.......XXX...
...XXX.......XXX.......XX........XXX...
....X.............................X....
....X.............................X....
....X.........X.........X.........X....
....X.........X.........X.........X....
XXXXXXXXXXXXXXXXX......XXXXX...XXXXXXX.
....X.........X.........X.........X....
....X.........X...................X....
....X.........X...................X....
....X.........X.........X.........X....
....X.........X.........X.........X....
....X...................X..............
.XXXXX....XXXX.......XXXX...XXXXXXX...X
....X...................X.........X....
....X...................X..............
....X...................X..............
....X...................X.........X....
....X.............................X....
....X.........X.........X.........X....
XXXXX....XXXXXXXXXXXX..XX.XX..XXXXXXX..
....X.........X.........X.........X....
....X.........X.........X.........X....
....X.........X.........X..............
....X..................................
....X..................................
....X.................................X
XXXXXXXXXXXXX...XXXXX..X.XX..X....XXXXX
XXXXXXXXXXXXXXXXXXXXXX.XXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/secret-w.png")

cihla = addModel("item_light", 14, 4,
[[
X
X
]])
addItemAnim(cihla, "images/"..codename.."/zed-big.png")

drzka = addModel("item_light", 18, 26,
[[
XX
XX
XX
]])
addItemAnim(drzka, "images/"..codename.."/hlava_00.png")
-- extsize=19; first="hlava 1.BMP"

item_heavy = addModel("item_heavy", 17, 26,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/6-ocel.png")

item_heavy = addModel("item_heavy", 20, 26,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/6-ocel.png")

item_light = addModel("item_light", 34, 14,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/zed-small.png")

small = addModel("fish_small", 14, 19,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 7, 5,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

lbalon = addModel("item_light", 26, 7,
[[
X
]])
addItemAnim(lbalon, "images/"..codename.."/balonek_00.png")
-- extsize=3; first="balonek1.bmp"

rbalon = addModel("item_light", 31, 7,
[[
X
]])
addItemAnim(rbalon, "images/"..codename.."/balonek_00.png")
-- extsize=3; first="balonek1.bmp"

balon1 = addModel("item_light", 12, 14,
[[
X
]])
addItemAnim(balon1, "images/"..codename.."/balonek_00.png")
-- extsize=3; first="balonek1.bmp"

balon2 = addModel("item_light", 15, 18,
[[
X
]])
addItemAnim(balon2, "images/"..codename.."/balonek_00.png")
-- extsize=3; first="balonek1.bmp"

balon3 = addModel("item_light", 19, 25,
[[
X
]])
addItemAnim(balon3, "images/"..codename.."/balonek_00.png")
-- extsize=3; first="balonek1.bmp"

item_light = addModel("item_light", 23, 1,
[[
.X
]])
addItemAnim(item_light, "images/"..codename.."/anticka_hlava_ulomena.png")

hlava1 = addModel("item_light", 3, 1,
[[
.X
]])
addItemAnim(hlava1, "images/"..codename.."/anticka_hlava_00.png")
-- extsize=3; first="anticka hlava1.BMP"

hlava2 = addModel("item_light", 13, 1,
[[
.X
]])
addItemAnim(hlava2, "images/"..codename.."/anticka_hlava_00.png")
-- extsize=3; first="anticka hlava1.BMP"

hlava3 = addModel("item_light", 33, 1,
[[
.X
]])
addItemAnim(hlava3, "images/"..codename.."/anticka_hlava_00.png")
-- extsize=3; first="anticka hlava1.BMP"

krab = addModel("item_light", 26, 4,
[[
..XX..
XXXXXX
X....X
]])
addItemAnim(krab, "images/"..codename.."/kr_00.png")
-- extsize=17; first="kr0.BMP"

shrimp = addModel("item_light", 20, 20,
[[
XXX
X..
]])
addItemAnim(shrimp, "images/"..codename.."/shrimp_00.png")
-- extsize=4; first="shrimp1.bmp"

krabik = addModel("item_light", 29, 21,
[[
XX
]])
addItemAnim(krabik, "images/"..codename.."/krab_00.png")
-- extsize=5; first="krab1.BMP"



