
createRoom(45, 27, "images/"..codename.."/letadlo-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
..XXXXXXXXXXXXX.XXXXXXXXXXXXXXX..............
...XXXXXXXXXXXXXXXXXXXXXXXXXXX...............
...XXXXXXXXXXXXXXXXXXXXXXXXXX................
....XXXXXXXXXXXXXXXXXXXXXXXX.................
....XXXXXXXXXXXXXXXXXXXXXXXXXXX..............
.....XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX........
.....XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
......XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
......XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
.......XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
......XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
.....XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
....XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....
...XXXXXXXXXXXXXXXXXXXXXXXXXXXXX.............
..XXXXXXXXXXXXXXXXXXXXXXX....................
.XXXXXXXXXXXXXXXXXXX.........................
XXXXXXXXXXXXXXXXX............................
XXXXXXXXXXXXXXX..............................
XXXXXXXXXXXXX.............................XXX
XXXXXXXXXXXX.............................XXXX
XXXXXXXXXXX..................................
XXXXXXXXXX................................XXX
XXXXXXXXX...............................XXXXX
XXXXXXXX..........................XXX.X.XXXXX
XXXXXXXXX.................XXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXX......XXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/letadlo-w.png")

small = addModel("fish_small", 35, 19,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 16, 18,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

item_heavy = addModel("item_heavy", 34, 14,
[[
X
X
X
X
X
X
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/letadlo-3-tmp.png")

item_heavy = addModel("item_heavy", 39, 14,
[[
X
X
X
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/letadlo-4-tmp.png")

item_heavy = addModel("item_heavy", 38, 20,
[[
.XXXX
XX...
]])
addItemAnim(item_heavy, "images/"..codename.."/letadlo-5-tmp.png")

sed1 = addModel("item_light", 27, 15,
[[
..X
..X
..X
XXX
]])
addItemAnim(sed1, "images/"..codename.."/sedadlo.png")

sed2 = addModel("item_light", 25, 20,
[[
...X
...X
XXXX
]])
addItemAnim(sed2, "images/"..codename.."/sedadlo2.png")

sed3 = addModel("item_light", 14, 19,
[[
X..
X..
X..
XXX
]])
addItemAnim(sed3, "images/"..codename.."/sedadlo1.png")

item_light = addModel("item_light", 36, 1,
[[
XXXX
...X
...X
]])
addItemAnim(item_light, "images/"..codename.."/sedadlo3.png")

item_light = addModel("item_light", 34, 0,
[[
X..
X..
X..
XXX
]])
addItemAnim(item_light, "images/"..codename.."/sedadlo1.png")

ocicko = addModel("item_light", 16, 20,
[[
X
]])
addItemAnim(ocicko, "images/"..codename.."/oko_00.png")
-- extsize=4; first="oko 0.bmp"



