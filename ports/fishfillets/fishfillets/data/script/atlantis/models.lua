
createRoom(50, 35, "images/"..codename.."/spunt-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXX......................XXX.......XXXXXXXX
XXXXXXX......................................XXXXX
XXXXXX...........................XXX..........XXXX
XXXXXX........................................XXXX
XXXXXX........................................XXXX
XXXXX.........................................XXXX
XXXXX.......................................XXXXXX
XXXXX..........................................XXX
XXXXX...........................................XX
XXXXX...........................X...............XX
XXXXX....................XXXXXXXX...............XX
XXXXX..........XXXXXXX..XXX.XXXXX...............XX
XXXXX...........XXX...........XXX...............XX
XXXXX...........X...............................XX
XXXXX...........X...............................XX
XXXX............XXXX..XX.......X................XX
...X.............XXX...........X................XX
...............................X................XX
...............................X....XXXXXXXXXXXXXX
........XXXXXXXXXXXX...........X.......XXXXXXXXXXX
...............................X........XXXXXXXXXX
................................XX.......XXXXXXXXX
................................XXX.....XXXXXXXXXX
XXX.............................XX......XXXXXXXXXX
XXXXX..................................XXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXX......XXXXX.....XXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXX......XXXXXX....XXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXX....XXXXXXXX..XXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXX....XXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXX..XXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXX..XXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXX.XXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXX..XXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXX.XXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/spunt-zed.png")

spunt = addModel("item_light", 25, 21,
[[
..XX..
XXXXXX
XXXXXX
.XXXX.
..XXX.
]])
addItemAnim(spunt, "images/"..codename.."/spunt.png")

item_heavy = addModel("item_heavy", 24, 14,
[[
XXXX
.X..
]])
addItemAnim(item_heavy, "images/"..codename.."/2-ocel.png")

big = addModel("fish_big", 26, 15,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

small = addModel("fish_small", 22, 15,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

item_heavy = addModel("item_heavy", 29, 2,
[[
XXXXXXX
X......
]])
addItemAnim(item_heavy, "images/"..codename.."/5-ocel.png")

item_heavy = addModel("item_heavy", 38, 6,
[[
XXXXXXXX
...XX...
]])
addItemAnim(item_heavy, "images/"..codename.."/6-ocel.png")

krab1 = addModel("item_light", 29, 1,
[[
XX
]])
addItemAnim(krab1, "images/"..codename.."/krab_00.png")
-- extsize=9; first="krab1.BMP"

item_light = addModel("item_light", 35, 21,
[[
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/sloupek_b.png")

item_light = addModel("item_light", 32, 25,
[[
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/atikac.png")

item_heavy = addModel("item_heavy", 34, 24,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/12-ocel.png")

hlava3 = addModel("item_light", 33, 21,
[[
X
]])
addItemAnim(hlava3, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

snecik1 = addModel("item_light", 11, 24,
[[
X
]])
addItemAnim(snecik1, "images/"..codename.."/maly_snek_00.png")
-- extsize=3; first="maly snek1.BMP"

item_heavy = addModel("item_heavy", 40, 4,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/15-ocel.png")

item_heavy = addModel("item_heavy", 31, 24,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/12-ocel.png")

item_heavy = addModel("item_heavy", 27, 13,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/19-ocel.png")

krab2 = addModel("item_light", 41, 18,
[[
XX
]])
addItemAnim(krab2, "images/"..codename.."/krab_00.png")
-- extsize=9; first="krab1.BMP"

snecik2 = addModel("item_light", 31, 25,
[[
X
]])
addItemAnim(snecik2, "images/"..codename.."/maly_snek_00.png")
-- extsize=3; first="maly snek1.BMP"

hlava2 = addModel("item_light", 11, 25,
[[
X
]])
addItemAnim(hlava2, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

hlava1 = addModel("item_light", 11, 23,
[[
X
]])
addItemAnim(hlava1, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"



