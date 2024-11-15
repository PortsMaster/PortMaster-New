
createRoom(53, 29, "images/"..codename.."/drakar-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
.........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.......
........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX........
........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX........
.........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.......
........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.......
..........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX........
.........XXXXXX..........XXXXXXXXXXXXXXXXXXX........
.........XX................XX......XXXXXXXXX........
...........................XX...........XXXXX.......
..XXXX.....................XX.............XXXX......
...X.X......................................X.......
..XXXX.....................XX.......................
....XX.....................XX.......................
....XX.....................XX.......................
....XX.....................XX.......................
....XX.....................X........................
....XXX.............................................
....XXXX...........................................X
....XXXXX..........................................X
.....XXXXXX.......................................XX
......XXXXXXX...................................XXXX
......XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
.......XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
.........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.
..........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX..
...........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX...
.................XXXXXXXXXXXXXXXXXXXXXXXXXXX........
]])
addItemAnim(room, "images/"..codename.."/drakar-w.png")

viking1 = addModel("item_light", 14, 17,
[[
XXX
XXX
XXX
XXX
]])
addItemAnim(viking1, "images/"..codename.."/vik1_00.png")
-- extsize=4; first="vik1_0.bmp"

viking3 = addModel("item_light", 22, 17,
[[
XXX
XXX
XXX
XXX
]])
addItemAnim(viking3, "images/"..codename.."/vik6_00.png")
-- extsize=3; first="vik6_0.bmp"

viking4 = addModel("item_light", 26, 17,
[[
XXX
XXX
XXX
XXX
]])
addItemAnim(viking4, "images/"..codename.."/vik7_00.png")
-- extsize=7; first="vik7_0.bmp"

viking5 = addModel("item_light", 30, 17,
[[
XXX
XXX
XXX
XXX
]])
addItemAnim(viking5, "images/"..codename.."/vik2_00.png")
-- extsize=4; first="vik2_0.bmp"

viking6 = addModel("item_light", 34, 17,
[[
XXX
XXX
XXX
XXX
]])
addItemAnim(viking6, "images/"..codename.."/vik5_00.png")
-- extsize=3; first="vik5_0.bmp"

viking7 = addModel("item_light", 38, 17,
[[
XXX
XXX
XXX
XXX
]])
addItemAnim(viking7, "images/"..codename.."/vik3_00.png")
-- extsize=6; first="vik3_0.bmp"

viking8 = addModel("item_light", 39, 14,
[[
......
......
......
...XXX
...XXX
...XXX
...XXX
]])
addItemAnim(viking8, "images/"..codename.."/spalici_00.png")
-- extsize=5; first="spalici1.BMP"

item_light = addModel("item_light", 4, 2,
[[
.X..
XXXX
...X
]])
addItemAnim(item_light, "images/"..codename.."/korunka.png")

item_light = addModel("item_light", 25, 16,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/stit.png")

item_heavy = addModel("item_heavy", 0, 0,
[[
...XXXXXX
..XX.....
.XX......
XX.......
X........
X........
X........
X........
X........
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel-1.png")

item_light = addModel("item_light", 25, 10,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/stit.png")

item_heavy = addModel("item_heavy", 34, 15,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel-2.png")

pesos = addModel("item_light", 45, 17,
[[
.XX
.X.
.XX
XX.
]])
addItemAnim(pesos, "images/"..codename.."/pesos_00.png")
-- extsize=2; first="pesos1.BMP"

item_heavy = addModel("item_heavy", 25, 8,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel-2.png")

item_heavy = addModel("item_heavy", 28, 15,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel-2.png")

small = addModel("fish_small", 16, 11,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 15, 13,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

viking2 = addModel("item_light", 18, 17,
[[
XXX
XXX
XXX
XXX
]])
addItemAnim(viking2, "images/"..codename.."/vik2_00.png")
-- extsize=4; first="vik2_0.bmp"

hlavadr = addModel("item_light", 2, 9,
[[
...
..X
]])
addItemAnim(hlavadr, "images/"..codename.."/drakar-hlava_00.png")
-- extsize=2; first="Drakar-hlava0.BMP"



