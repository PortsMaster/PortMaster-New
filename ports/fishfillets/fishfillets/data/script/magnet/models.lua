
createRoom(35, 31, "images/"..codename.."/paprsky-pozadi.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XX................................X
XX.................................
XX.................................
XX.................................
XX.................................
XX.................................
XXXX.........XXXXXXXXXXXXXXXXXXXXXX
XXXX.........XXXXXXXXXXXXXXXXXXXXXX
XXXX...XX......................XXXX
XXXX...XX......................XXXX
XXXX...XXXX....................XXXX
XXXX..........................XXXXX
XXXX..........................XXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXX....XXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXX....XXXXX
XXXXXXXXXXX......................XX
XXXXXXXXXXX......................XX
XXXXXXXXXXX......................XX
XXXXXXXXXXX.......................X
XXXXXXXXXXX.......................X
XXXXXXXXXXX................XX.....X
XXXXXXXXXXX...............XXX...XXX
XXXXXXXXXXX...............XXX...XXX
XXXXXXXXXXX....XXX.XXXXXXXXXX...XXX
XXXXXXXXXXX....XXX.XXXXXXXXXX...XXX
XXXXXXXXXXX....XXX.XXXXXXXXXXXXXXXX
XXXXXXXXXXX....XXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXX....XXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXX....XXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/paprsky-w.png")

small = addModel("fish_small", 25, 7,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 24, 4,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

magnetek = addModel("item_light", 20, 5,
[[
XXX
X.X
X.X
...
...
X.X
X.X
XXX
]])
addItemAnim(magnetek, "images/"..codename.."/magnety-oba-_00.png")
-- extsize=4; first="magnety-oba-0.bmp"

bambitka = addModel("item_light", 25, 18,
[[
XX.
.X.
.X.
.XX
.X.
]])
addItemAnim(bambitka, "images/"..codename.."/zbran.png")

superpristroj = addModel("item_light", 18, 11,
[[
X..
X..
XXX
XXX
]])
addItemAnim(superpristroj, "images/"..codename.."/radio-_00.png")
-- extsize=8; first="radio-1.BMP"

item_heavy = addModel("item_heavy", 29, 2,
[[
X.
XX
.X
.X
.X
.X
]])
addItemAnim(item_heavy, "images/"..codename.."/6-ocel.png")

konstrukce1 = addModel("item_heavy", 25, 22,
[[
X
X
X
]])
addItemAnim(konstrukce1, "images/"..codename.."/7-ocel.png")

item_heavy = addModel("item_heavy", 6, 7,
[[
XXXXX
..X..
..X..
]])
addItemAnim(item_heavy, "images/"..codename.."/8-ocel.png")

konstrukce2 = addModel("item_heavy", 11, 20,
[[
.....X
.....X
.....X
XXXXXX
.....X
]])
addItemAnim(konstrukce2, "images/"..codename.."/9-ocel.png")



