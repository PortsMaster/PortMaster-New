
createRoom(47, 36, "images/"..codename.."/diry-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXX.........X...............................XXX
XXX.........X...............................XXX
XXX.........X...............................XXX
XXXXXXX...XXX...............................XXX
XXX............X.X.X.X...........X.X.X.X....XXX
XXX.........................................XXX
XXX.........................................XXX
XXX.........................................XXX
XXX....X.........XXXXXXX....................XXX
XXX....XXX.......XXXXXXX....................XXX
XXX.....XXX......XXXXXXX....................XXX
XXX......XX......XXXXXXX....................XXX
XXX..........X...XXXXXXX............X.......XXX
XXX...................XX....................XXX
XXX..X................XX....................XXX
XXX.....XXX.X..XXX....XX....................XXX
......................XX...............X....XXX
............................................XXX
XXX..X.XX.X.XX.XX.XX...X....................XXX
XXX..X.XX.X.XX.XX.XX........................XXX
XXX..XXXXXXXXXXXXXXX........................XXX
XXX.........................................XXX
XXX.......................X.................XXX
XXX.........................................XXX
XXX.........................................XXX
XXX...XXXXXXXXXXXXXXXXXX....................XXX
XXX................................X........XXX
XXX...XXXXXXXX.X.XXXXXXX....................XXX
XXX.........................................XXX
XXX.........................................XXX
XXX.........................................XXX
XXXX.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.XXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/diry-w.png")

item_light = addModel("item_light", 35, 27,
[[
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/atikaa.png")

item_light = addModel("item_light", 35, 26,
[[
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/atikab.png")

item_light = addModel("item_light", 36, 25,
[[
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/atikac.png")

item_light = addModel("item_light", 35, 24,
[[
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/atikad.png")

vladce = addModel("item_light", 40, 30,
[[
XX
XX
XX
]])
addItemAnim(vladce, "images/"..codename.."/hlava_00.png")
-- extsize=19; first="hlava 1.BMP"

item_light = addModel("item_light", 24, 17,
[[
XXXXX
.XXX.
..X..
]])
addItemAnim(item_light, "images/"..codename.."/preklad.png")

item_light = addModel("item_light", 33, 3,
[[
XXXXXXX
XXXXXXX
X.X.X.X
]])
addItemAnim(item_light, "images/"..codename.."/most.png")

xichtik = addModel("item_light", 15, 32,
[[
X
]])
addItemAnim(xichtik, "images/"..codename.."/hlava_m-_00.png")
-- extsize=2; first="hlava m-1.BMP"

val1 = addModel("item_heavy", 26, 22,
[[
X
X
]])
addItemAnim(val1, "images/"..codename.."/diry-9-tmp.png")

val2 = addModel("item_heavy", 36, 12,
[[
X
X
]])
addItemAnim(val2, "images/"..codename.."/diry-10-tmp.png")

val3 = addModel("item_heavy", 39, 16,
[[
X
X
]])
addItemAnim(val3, "images/"..codename.."/diry-11-tmp.png")

item_heavy = addModel("item_heavy", 20, 19,
[[
.XXXXX.
XX...XX
]])
addItemAnim(item_heavy, "images/"..codename.."/diry-12-tmp.png")

item_heavy = addModel("item_heavy", 12, 18,
[[
XX
X.
]])
addItemAnim(item_heavy, "images/"..codename.."/diry-13-tmp.png")

item_heavy = addModel("item_heavy", 18, 9,
[[
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/diry-14-tmp.png")

item_light = addModel("item_light", 9, 3,
[[
XXX
.X.
]])
addItemAnim(item_light, "images/"..codename.."/hlavice.png")

item_light = addModel("item_light", 12, 23,
[[
.X.
.X.
.X.
XXX
]])
addItemAnim(item_light, "images/"..codename.."/patka.png")

item_light = addModel("item_light", 20, 9,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/sloupek_a.png")

item_light = addModel("item_light", 7, 17,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/sloupek_b.png")

item_light = addModel("item_light", 6, 4,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/sloupek_c.png")

chobot = addModel("item_light", 13, 30,
[[
X...X
XXXXX
]])
addItemAnim(chobot, "images/"..codename.."/chobotnice_00.png")
-- extsize=8; first="chobotnice0.BMP"

item_light = addModel("item_light", 15, 28,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/maly_snek_00.png")
-- extsize=3; first="maly snek1.BMP"

small = addModel("fish_small", 27, 10,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 27, 12,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")



