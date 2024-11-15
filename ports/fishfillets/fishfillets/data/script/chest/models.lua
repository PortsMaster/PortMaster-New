
createRoom(39, 31, "images/"..codename.."/truhla-p.png")
setRoomWaves(7, 11, 7)

room = addModel("item_fixed", 0, 0,
[[
XXXX.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXX...XX.............XXXXXXXXXXXXXXXXXX
XX.......................XXXXXXXXXXXXX.
XX.....................................
XX.........................XXXX..XX....
XXX..........................XXXXXXXXX.
XX............................XXXXXXX..
X......................................
X..............................XXXXX...
XX................................XXX..
XXX....................................
XXXX.............................XXX...
XXXX..............................XXX..
XX.....................................
XXXX...............................XX..
XXX................................XX..
XXXX...............................XXX.
XXXX................................XXX
XXXXX................................XX
XXXX.................................XX
XXX...........................XX.....XX
XXXX..........................XX.....XX
XXX...........................XX.....XX
XX............................XX.....XX
........................X.....XX.....XX
........................X.....XX.....XX
.X....................X.......XX.....XX
.XXXXXXXXXXX....XXXXXXX..............XX
..XXXXXXXXXX.........................XX
....XXXXXXXX.........................XX
......XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/truhla-w.png")

drahokamy = addModel("item_light", 3, 13,
[[
X
]])
addItemAnim(drahokamy, "images/"..codename.."/krystal-o_00.png")
-- extsize=3; first="krystal-o0.BMP"

item_light = addModel("item_light", 18, 24,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal-m_00.png")
-- extsize=3; first="krystal-m0.BMP"

item_light = addModel("item_light", 27, 3,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal-d_00.png")
-- extsize=3; first="krystal-d0.BMP"

item_light = addModel("item_light", 28, 3,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal-z_00.png")
-- extsize=3; first="krystal-z0.BMP"

item_light = addModel("item_light", 30, 3,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal-t_00.png")
-- extsize=3; first="krystal-t0.BMP"

item_light = addModel("item_light", 31, 7,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal-y_00.png")
-- extsize=3; first="krystal-y0.BMP"

item_light = addModel("item_light", 32, 7,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal-c_00.png")
-- extsize=3; first="krystal-c0.BMP"

item_light = addModel("item_light", 33, 10,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal-o_00.png")
-- extsize=3; first="krystal-o0.BMP"

item_light = addModel("item_light", 35, 10,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal-m_00.png")
-- extsize=3; first="krystal-m0.BMP"

item_light = addModel("item_light", 36, 13,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal-t_00.png")
-- extsize=3; first="krystal-t0.BMP"

item_light = addModel("item_light", 5, 5,
[[
XXXXXXXXXXXX.....
XXXXXXXXXXX......
XXXXXXXXXX.......
XXXXXXXXX........
XXXXXXXX.........
XXXXXXX..........
XXXXXX...........
XXXXX............
XXXX.............
XXX..............
XX...............
XX...............
XX.............XX
XX.............XX
XX.............XX
XX.............XX
XX.............XX
XX.............XX
XX.............XX
XX.............XX
XXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXX
]])
addItemAnim(item_light, "images/"..codename.."/truhla2.png")

item_heavy = addModel("item_heavy", 8, 22,
[[
..X
XXX
X..
]])
addItemAnim(item_heavy, "images/"..codename.."/2-ocel.png")

small = addModel("fish_small", 10, 4,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

big = addModel("fish_big", 26, 9,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

item_light = addModel("item_light", 8, 3,
[[
XXXXXXXX
X......X
]])
addItemAnim(item_light, "images/"..codename.."/stolek2.png")

item_light = addModel("item_light", 11, 13,
[[
X.X.X
XXXXX
]])
addItemAnim(item_light, "images/"..codename.."/korunka.png")

item_light = addModel("item_light", 13, 19,
[[
XXX
XXX
XXX
.X.
.X.
XXX
]])
addItemAnim(item_light, "images/"..codename.."/gral.png")

item_light = addModel("item_light", 11, 17,
[[
XXXXX
X.X.X
]])
addItemAnim(item_light, "images/"..codename.."/korunka1.png")

item_heavy = addModel("item_heavy", 13, 27,
[[
X.....................X
X................X....X
XXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/12-ocel.png")

item_light = addModel("item_light", 34, 7,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/mince-1.png")

prsten = addModel("item_light", 32, 3,
[[
XXX
]])
addItemAnim(prsten, "images/"..codename.."/prsten-2_00.png")
-- extsize=5; first="prsten-2_1.BMP"

item_light = addModel("item_light", 2, 2,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/vazavh.png")

koruna1 = addModel("item_light", 12, 15,
[[
XX
XX
]])
addItemAnim(koruna1, "images/"..codename.."/koruna_00.png")
-- extsize=5; first="koruna0.BMP"

koruna2 = addModel("item_light", 29, 18,
[[
XX
XX
]])
addItemAnim(koruna2, "images/"..codename.."/koruna_00.png")
-- extsize=5; first="koruna0.BMP"



