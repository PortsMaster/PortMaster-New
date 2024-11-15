
createRoom(46, 38, "images/"..codename.."/pozadi.png")
setRoomWaves(5, 20, 3)

objekty = addModel("item_light", 0, 0,
[[
X
]])
addItemAnim(objekty, "images/"..codename.."/potop_00.png")
-- extsize=4; first="potop0.BMP"

room = addModel("item_fixed", 0, 0,
[[
.XXXXXXXXXXXXXXXXXX......XXXXXXXXXXXXXXXXXXXXX
XXXX..X..........XX.....XXXXXXXXXXXXXXXXXXXXXX
..XX.......................XXXXXXXXXXXXXXXXXXX
...X..................X....XXXXXXXXXXXXXXXXXXX
......................X....XXXXXXXXXXXXXXXXXXX
................................XXXXXXXXXXXXXX
.......................X........XXXXXXXXXXXXXX
...........X..............X..........XXXXXXXXX
........XX.X............X.XXXXXXX.....XXXXXXXX
........XXXX.....X......XXXXXXXXXXX....XXXXXXX
X...X...XXX..............XXXXXXXXXX....XXXXXXX
X.XXX......................XX...........XXX.XX
XXXXXXXX......X.X..........X.............XX...
XX.......................................X....
X............XX.XX...........................X
XXX..........XXXX...........................XX
XXXXXX........XXX..........................XXX
XXXXXX........X............................XXX
XXXXX..............................X......XXXX
XXXX.............................XXX....XXXXXX
.XX..........................XXXXXX.....XXXX..
XXX........................XXXXXXXX.....X.....
XXX..........................XXXX......XX.....
XXX...........................XX.......X.....X
XXX............XX....X.......................X
XXXX..........XXX....XX......................X
XXXXX........XXXX.....X.....................XX
XXXXXXX.......XX............................XX
XXXXX.....................XXX...............XX
XXXXX......................X................XX
XXX.........................................XX
XXX......................XX.................XX
XX........................XX...............XXX
XXX......................XXXXX...........XXXXX
XXX.................XXXXXXXXXXXX.XXXXXXXXXXXXX
XXXX..XXXXX...XXX...XXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/lode-w.png")

buh2 = addModel("item_light", 6, 29,
[[
..XX..
..XX..
.XXXX.
.XXXX.
XXXXXX
XXXXXX
]])
addItemAnim(buh2, "images/"..codename.."/neptun_00.png")
-- extsize=45; first="neptun0.BMP"

buh1 = addModel("item_light", 18, 28,
[[
.XX..
XXX..
XXX..
XXXX.
XXXXX
XXXXX
]])
addItemAnim(buh1, "images/"..codename.."/poseidon_00.png")
-- extsize=48; first="poseidon0.BMP"

item_heavy = addModel("item_heavy", 14, 10,
[[
XXXXXX
..X...
]])
addItemAnim(item_heavy, "images/"..codename.."/3-ocel.png")

item_heavy = addModel("item_heavy", 14, 13,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/4-ocel.png")

item_heavy = addModel("item_heavy", 16, 7,
[[
.XXXX
XX...
]])
addItemAnim(item_heavy, "images/"..codename.."/5-ocel.png")

item_light = addModel("item_light", 8, 7,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/ping.png")

palka = addModel("item_light", 23, 2,
[[
.XXX
XXXX
.XXX
]])
addItemAnim(palka, "images/"..codename.."/palka.png")

item_light = addModel("item_light", 26, 5,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/domino.png")

item_light = addModel("item_light", 13, 10,
[[
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/kuzelka.png")

item_light = addModel("item_light", 16, 34,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/bota.png")

hul = addModel("item_light", 33, 32,
[[
XXXXXXX
X......
]])
addItemAnim(hul, "images/"..codename.."/hul.png")

kriketak = addModel("item_light", 39, 31,
[[
X
]])
addItemAnim(kriketak, "images/"..codename.."/tenisak.png")

small = addModel("fish_small", 41, 15,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 40, 23,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")


