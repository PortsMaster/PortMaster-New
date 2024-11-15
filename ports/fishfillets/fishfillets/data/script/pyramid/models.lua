
createRoom(43, 28, "images/"..codename.."/bunker-p.png")
setRoomWaves(2, 6, 4)

room = addModel("item_fixed", 0, 0,
[[
...........................................
....................XXX....................
...................XXXXX...................
..................XXX.XXX..................
.................XXX...XXX.................
................XXX.....XXX................
...............XXX.......XXX...............
..............XXX.........XXX..............
.............XXX...........XXX.............
............XXX.............XXX............
...........XXX...............XXX...........
..........XXX.................XXX..........
.........XXX............X......XXX.........
........XXX...X.................XXX........
.......XXX.......................XXX.......
......XXX.........................XXX......
.....XXX...........................XXX.....
....XXX.........................X...XXX....
...XXX....XXX..X.X..X................XXX...
..XXX.....XXX.........................XXX..
.XXX..X...XXXX..........X..X...........XXX.
XXX..XX...XXX.................X.........XXX
......X..........................X.........
......X.............................X......
............XXXXXXXXXXXX...............X...
X...........XX.........X..................X
X......................XXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/bunker-w.png")

small = addModel("fish_small", 37, 23,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 35, 24,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

faraon = addModel("item_light", 18, 20,
[[
XXX
XXX
XXX
.X.
]])
addItemAnim(faraon, "images/"..codename.."/faraon_00.png")
-- extsize=2; first="faraon 1.BMP"

item_heavy = addModel("item_heavy", 20, 17,
[[
XX
.X
.X
]])
addItemAnim(item_heavy, "images/"..codename.."/bunker-4-tmp.png")

deska2 = addModel("item_light", 11, 17,
[[
XX
]])
addItemAnim(deska2, "images/"..codename.."/desticka.png")

deska1 = addModel("item_light", 12, 16,
[[
XX
]])
addItemAnim(deska1, "images/"..codename.."/desticka.png")

deska3 = addModel("item_light", 33, 21,
[[
XX
]])
addItemAnim(deska3, "images/"..codename.."/desticka.png")

item_light = addModel("item_light", 15, 23,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/scarab.png")

item_light = addModel("item_light", 23, 11,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/mumysokol.png")

item_light = addModel("item_light", 21, 9,
[[
XXXXX
X...X
]])
addItemAnim(item_light, "images/"..codename.."/stul.png")

stela = addModel("item_light", 27, 14,
[[
XX
XX
XX
XX
XX
XX
]])
addItemAnim(stela, "images/"..codename.."/stela_00.png")
-- extsize=5; first="stela 1.BMP"

item_heavy = addModel("item_heavy", 6, 24,
[[
X....X
X....X
XXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/bunker-14-tmp.png")

item_light = addModel("item_light", 17, 26,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/mumysokol.png")

item_light = addModel("item_light", 32, 14,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/mumycat.png")

item_light = addModel("item_light", 23, 23,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/scarab.png")

item_light = addModel("item_light", 21, 23,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/scarab.png")

item_light = addModel("item_light", 14, 10,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/mumycat.png")

cerv = addModel("item_light", 37, 16,
[[
.XX
..X
]])
addItemAnim(cerv, "images/"..codename.."/cerv_00.png")
-- extsize=7; first="Cerv0.BMP"



