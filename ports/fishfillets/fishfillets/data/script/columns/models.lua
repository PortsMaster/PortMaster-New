
createRoom(40, 30, "images/"..codename.."/sloupy-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXX.......XXXXXXXXXXXX.......XXXXXXX
XXXX.............XXXXXX.............XXXX
XXX...............XXXX...............XXX
XX.................XX.................XX
...................XX.................XX
XX.................XX...................
X..................XX...................
...................XX....XXXX...XXX...XX
...................XX....XXXXXXXXXX...XX
...................XX.................XX
...................XX.................XX
...................XX.................XX
XXXXXXXXXXXX........X.................XX
X.....................................XX
X.....................................XX
..............XXXXXXXXXX........XX....XX
..............XXXXXXXXXX........XX....XX
......................................XX
......................................XX
.......................................X
.......................................X
..................................X.....
XXXXXXXXXXXXXX..........................
XXXXXXXXXXXXXXXX........................
........................................
XXXXXXXXXXXXXXXXXXXX....................
XXXXXXXXXXXXXXXXXXXXXX..................
........................................
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/sloupy-w.png")

item_light = addModel("item_light", 0, 7,
[[
.XXXXXXXXXXX
XXXXXXXXXXX.
XXXXXXXXXXX.
XXXXXXXXXX..
XXXXXXXXXX..
XXXXXXXXXXX.
]])
addItemAnim(item_light, "images/"..codename.."/vlys.png")

ocel = addModel("item_heavy", 28, 26,
[[
XX
.X
]])
addItemAnim(ocel, "images/"..codename.."/3-ocel.png")

samotna = addModel("item_light", 6, 6,
[[
X
]])
addItemAnim(samotna, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 23, 10,
[[
XXX
.X.
.X.
.X.
.X.
XXX
]])
addItemAnim(item_light, "images/"..codename.."/stalagnat.png")

item_light = addModel("item_light", 32, 2,
[[
.X.
.X.
.X.
.X.
.X.
XXX
]])
addItemAnim(item_light, "images/"..codename.."/patka.png")

item_light = addModel("item_light", 19, 19,
[[
X.
X.
X.
X.
X.
XX
]])
addItemAnim(item_light, "images/"..codename.."/troska.png")

small = addModel("fish_small", 27, 21,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 9, 2,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

rada1beg = addModel("item_light", 0, 25,
[[
X
]])
addItemAnim(rada1beg, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 1, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 2, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 3, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 4, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 5, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 6, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 7, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 8, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 9, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 10, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 11, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 12, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 13, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 14, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 15, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 16, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

rada1end = addModel("item_light", 17, 25,
[[
X
]])
addItemAnim(rada1end, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

rada2beg = addModel("item_light", 0, 28,
[[
X
]])
addItemAnim(rada2beg, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 1, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 2, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 3, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 4, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 5, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 6, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 7, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 8, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 9, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 10, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 11, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 12, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 13, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 14, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 15, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 16, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 17, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 18, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 19, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 20, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 21, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 22, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

rada2end = addModel("item_light", 23, 28,
[[
X
]])
addItemAnim(rada2end, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

item_light = addModel("item_light", 11, 21,
[[
XX........................
.XXX......................
...XXX....................
.....XXX..................
.......XXX................
.........XXX.............X
...........XXX............
.............XXXXXXXXXX...
]])
addItemAnim(item_light, "images/"..codename.."/stred.png")

sochoradi = addModel("item_light", 0, 17,
[[
XXXXXXXXXXXXXX
XXXXXXXXXXXXXX
XXXXXXXXXXXXXX
XXXXXXXXXXXXXX
XXXXXXXXXXX..X
XXXXXXXXXXXX..
]])
addItemAnim(sochoradi, "images/"..codename.."/leva_00.png")
-- extsize=7; first="leva0.BMP"

chlapik = addModel("item_light", 34, 22,
[[
......
.XXXXX
.XXXXX
.XXXXX
.X.XXX
..XXXX
XXXXXX
]])
addItemAnim(chlapik, "images/"..codename.."/prava_00.png")
-- extsize=9; first="prava0.BMP"




