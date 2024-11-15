
createRoom(41, 38, "images/"..codename.."/pohon-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
........................................X
XXX...XXX...XXX...XXX...XXX...XXX...XXXXX
X......................................XX
.......................................XX
X......................................XX
X......................................XX
X......................................XX
X......................................XX
X....XXXX.......................XXXXX..XX
X.......................................X
X.......................................X
X.......................................X
X.......................................X
X.......................................X
X.......................................X
X.......................................X
X.......................................X
X.......................................X
X.......................................X
X.......................................X
X.......................................X
XXXXXXXX..X..X..X..X..X..XXXX...........X
X.........................X.X...........X
X.........................X.X...........X
X.........................X.X...........X
X.......................................X
X.....XX...................XX...........X
X.....XX.....................X..........X
X.....XX.....................X..........X
X.....XX.....................X..........X
X.....XX.....................X..........X
X.....XX....XXXXXXXXXXXX..XXXX..........X
........................................X
........................................X
......XX................................X
......XX..........X.....................X
X.....XX.......XXXX.....................X
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/pohon-w.png")

veve = addModel("item_light", 16, 24,
[[
XXXX.
XXXXX
XXXXX
XXXX.
]])
addItemAnim(veve, "images/"..codename.."/pohon_00.png")
-- extsize=11; first="pohon0.BMP"

bublik = addModel("item_light", 13, 28,
[[
...XXX..
XXXXXXXX
XXXXXXXX
]])
addItemAnim(bublik, "images/"..codename.."/podstavec_00.png")
-- extsize=3; first="podstavec0.BMP"

hadice = addModel("item_light", 14, 25,
[[
XX
X.
X.
X.
]])
addItemAnim(hadice, "images/"..codename.."/hadice_00.png")
-- extsize=1; first="hadice0.BMP"

item_light = addModel("item_light", 21, 22,
[[
..XXX
..X..
..X..
XXX..
..X..
]])
addItemAnim(item_light, "images/"..codename.."/rura.png")

item_light = addModel("item_light", 23, 27,
[[
XXX
XXX
XXX
XXX
]])
addItemAnim(item_light, "images/"..codename.."/cola.png")

nasrany = addModel("item_light", 6, 3,
[[
.XXX.
XXXXX
..X..
..X..
.XXX.
]])
addItemAnim(nasrany, "images/"..codename.."/ufo_00.png")
-- extsize=10; first="ufo0.BMP"

item_heavy = addModel("item_heavy", 2, 0,
[[
XXX
.X.
.X.
.X.
.X.
.X.
.X.
.X.
.XX
]])
addItemAnim(item_heavy, "images/"..codename.."/7-ocel.png")

item_heavy = addModel("item_heavy", 20, 0,
[[
XXX
.X.
.X.
.X.
.X.
.X.
.X.
.X.
.X.
]])
addItemAnim(item_heavy, "images/"..codename.."/8-ocel.png")

item_light = addModel("item_light", 21, 29,
[[
X.
XX
]])
addItemAnim(item_light, "images/"..codename.."/draty_.png")

smutny = addModel("item_light", 33, 3,
[[
XX
XX
XX
XX
XX
]])
addItemAnim(smutny, "images/"..codename.."/ufon-_00.png")
-- extsize=9; first="ufon-0.BMP"

item_heavy = addModel("item_heavy", 7, 29,
[[
...X....
...X....
...X....
XXXXXXXX
XXX....X
]])
addItemAnim(item_heavy, "images/"..codename.."/11-ocel.png")

item_heavy = addModel("item_heavy", 27, 7,
[[
...XXX
....X.
....X.
...XX.
...X..
..XX..
..X...
.XX...
.X....
XX....
]])
addItemAnim(item_heavy, "images/"..codename.."/12-ocel.png")

item_light = addModel("item_light", 33, 33,
[[
X....XX
XXXXXXX
]])
addItemAnim(item_light, "images/"..codename.."/kamna.png")

item_light = addModel("item_light", 35, 35,
[[
XX
.X
]])
addItemAnim(item_light, "images/"..codename.."/volant.png")

item_heavy = addModel("item_heavy", 14, 0,
[[
XXX
.X.
.X.
.X.
.X.
.X.
.X.
.X.
.X.
XX.
]])
addItemAnim(item_heavy, "images/"..codename.."/15-ocel.png")

item_heavy = addModel("item_heavy", 27, 22,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/16-ocel.png")

item_light = addModel("item_light", 27, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-1a.png")

plut1 = addModel("item_light", 33, 32,
[[
XXXX
]])
addItemAnim(plut1, "images/"..codename.."/plutonium-4-_00.png")
-- extsize=2; first="plutonium-4-1.BMP"

item_light = addModel("item_light", 5, 36,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/matka_a.png")

small = addModel("fish_small", 32, 26,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 14, 12,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

item_light = addModel("item_light", 28, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-1a.png")



