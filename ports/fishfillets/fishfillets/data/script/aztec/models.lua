
createRoom(48, 39, "images/"..codename.."/bottles-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXX...XXXXX............XX
XXXXXXXXXXXXX..XXXXXXXXX.......XXX.X..........XX
XXXXXXXXXXXXX.XXXXXXXX...........XXX..........XX
XXXXX..............................X..........XX
XXXXX.XXXX.........................X..........XX
XXXXX..............................X..........XX
XXXXX..............................X..........XX
XXXXX..............................X..........XX
XXXXX..............................XX.XX....X.XX
XXXXX.......XXXXXXXXX.XXXXXXXXXXXX.XX.XX....X.XX
XXXXX.......X.........................XX....X.XX
XXXXX......X..........................XX....X.XX
XXXXX......X.....XX...................XX......XX
XXXXX......X.....XX...................XX......XX
XXXXX......X..........................XX....X.XX
XXXX.......X................................X.XX
XXXXX......X................................X.XX
XXXXX......X..................X.............X.XX
XXXXX......X..........................XX....X.XX
XXXXX........................X..............X.XX
XXXXX......X................................X.XX
XXXX.......X................X...............X.XX
XXXXX......X..........................XX....X.XX
XXXXX......X.............X............XX....X.XX
XXXXX......X..........................XX....X.XX
XXXXX......X............X.............XX......XX
XXXXX.................................XX......XX
XXXXX..................X..............XX....X.XX
XXX...................................XX....X.XX
XXX.......................XX..........XX....X.XX
XXX...................................XX....X.XX
XXXXXXXXX..XX.XXXXXX...XXXXXXXXX......XX....X.XX
XXXXXXX....XX.XXX.........XXXXXX......XX....X.XX
XXXXXXX...XXX.XXX........XXXXXXXXX..XXXX....X.XX
.............X................................XX
..............................................XX
...X...........................................X
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/bottles-wall.png")

small = addModel("fish_small", 3, 29,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

big = addModel("fish_big", 3, 30,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

item_heavy = addModel("item_heavy", 8, 27,
[[
XX
X.
X.
X.
X.
]])
addItemAnim(item_heavy, "images/"..codename.."/bottles-3-tmp.png")

item_light = addModel("item_light", 27, 8,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/amfora_cervena.png")

item_light = addModel("item_light", 28, 8,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/amfora_zelena.png")

item_light = addModel("item_light", 28, 4,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/vaza.png")

item_light = addModel("item_light", 12, 15,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/vazav.png")

item_light = addModel("item_light", 12, 29,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/vazavh.png")

item_light = addModel("item_light", 12, 11,
[[
..X..X...
..XXXXXXX
.XX......
..X......
..XX.....
...X.....
...X.....
XXXXX....
....X....
..XXX....
..X......
.XXX.....
.X.......
.X.......
XX.......
.X.......
.X.......
.X.......
.X.......
]])
addItemAnim(item_light, "images/"..codename.."/drak.png")

sklebak = addModel("item_light", 34, 15,
[[
..XX..
..XX..
XXXXXX
XXXXXX
..XX..
..XX..
..XX..
..XX..
]])
addItemAnim(sklebak, "images/"..codename.."/totem_00.png")
-- extsize=5; first="totem0.BMP"

zlaty = addModel("item_light", 30, 35,
[[
...XX
XXXX.
]])
addItemAnim(zlaty, "images/"..codename.."/drak_m_00.png")
-- extsize=1; first="drak m0.BMP"

item_light = addModel("item_light", 44, 26,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/vaza_cervena.png")

item_light = addModel("item_light", 9, 4,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlavicka.png")

item_light = addModel("item_light", 39, 2,
[[
X
X
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/sloupek.png")

item_heavy = addModel("item_heavy", 11, 20,
[[
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/bottles-35-tmp.png")

konik = addModel("item_light", 26, 8,
[[
X
X
]])
addItemAnim(konik, "images/"..codename.."/konik_00.png")
-- extsize=3; first="konik1.BMP"

item_light = addModel("item_light", 25, 8,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/amfora_zelena.png")

item_light = addModel("item_light", 24, 8,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/vaza.png")

item_light = addModel("item_light", 25, 6,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/amfora_cervena.png")

item_light = addModel("item_light", 26, 6,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/vaza.png")

item_light = addModel("item_light", 27, 2,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/vaza.png")

item_light = addModel("item_light", 27, 6,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/amfora_zelena.png")

item_light = addModel("item_light", 26, 4,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/amfora_zelena.png")

item_light = addModel("item_light", 29, 6,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/amfora_zelena.png")

item_light = addModel("item_light", 6, 4,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlavicka.png")

item_light = addModel("item_light", 8, 4,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlavicka.png")

item_light = addModel("item_light", 7, 4,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlavicka.png")

item_light = addModel("item_light", 35, 1,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlavicka.png")

item_light = addModel("item_light", 44, 14,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlavicka.png")

item_light = addModel("item_light", 32, 37,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlavicka.png")

lebzna = addModel("item_light", 42, 2,
[[
XXX
XXX
XXX
]])
addItemAnim(lebzna, "images/"..codename.."/skull_00.png")
-- extsize=3; first="skull0.BMP"

item_light = addModel("item_light", 27, 4,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/amfora_cervena.png")

item_light = addModel("item_light", 29, 8,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/amfora.png")

item_light = addModel("item_light", 28, 6,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/amfora.png")

item_light = addModel("item_light", 30, 8,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/vaza_cervena.png")



