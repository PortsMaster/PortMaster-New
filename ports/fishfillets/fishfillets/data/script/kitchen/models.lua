
createRoom(51, 34, "images/"..codename.."/kuchyne-pozadi.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XX..............................X...............XXX
XX..............................X...............XXX
XX..............................X.....XXX.......XXX
XX....................XXXXXXXXXXX...............XXX
XX.............................X................XXX
XX.......XXXXXXXXXXX...........X................XXX
XX.......XXXXXXXXXXX...........X................XXX
XX.............................X................XXX
XX.............................X................XXX
XX.............................XXXXXXXX..XXX....XXX
XX.......XXXXXXXXXXX.....X......................XXX
XX.......XXXXXXXXXXX.....X......................XXX
X........................XXXXXXXXXXXXXX.XXXXXXXXXXX
X.......................................XXXXXXXXXXX
X.......................................XXXXXXXXXXX
X.......................................X.........X
X.......................................X.........X
X.................................................X
X...........XX....................................X
XXXXXXX.....XX.................XX.................X
.....XX.....XXXXXXXXXXXXXXXXXX.XXXXXXXXXXXXX......X
.....XX.....XX.............................X......X
X....XX.....XX.............................X......X
X....XX.....XX.............................X......X
X....XX.....XX....................................X
X....XX.....XX....................................X
X...........XX...................................XX
X................................................XX
X................................................XX
X................................................XX
X...........XX...................................XX
X......X....XX...X...............................XX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/kuchyne-okoli.png")

big = addModel("fish_big", 32, 7,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

small = addModel("fish_small", 2, 28,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

item_heavy = addModel("item_heavy", 31, 11,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/3-ocel.png")

zavazedlo2 = addModel("item_light", 38, 6,
[[
XX
X.
X.
XX
]])
addItemAnim(zavazedlo2, "images/"..codename.."/stolek-a.png")

zavazedlo1 = addModel("item_light", 36, 6,
[[
XX
.X
.X
XX
]])
addItemAnim(zavazedlo1, "images/"..codename.."/stolek.png")

papir = addModel("item_light", 38, 2,
[[
XXX
]])
addItemAnim(papir, "images/"..codename.."/mapa_v.png")

spindira = addModel("item_light", 23, 2,
[[
XX
XX
]])
addItemAnim(spindira, "images/"..codename.."/hrnec.png")

stolek = addModel("item_light", 8, 3,
[[
XXXXX
..X..
..X..
]])
addItemAnim(stolek, "images/"..codename.."/stolekv.png")

item_light = addModel("item_light", 3, 30,
[[
XXX
.X.
.X.
]])
addItemAnim(item_light, "images/"..codename.."/stolekm.png")

item_light = addModel("item_light", 11, 8,
[[
XX
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/sud.png")

mecik = addModel("item_light", 30, 25,
[[
....X..
XXXXXXX
....X..
]])
addItemAnim(mecik, "images/"..codename.."/mec.png")

kreslak = addModel("item_light", 8, 28,
[[
XX.
XX.
X..
XXX
X.X
]])
addItemAnim(kreslak, "images/"..codename.."/kreslo.png")

item_light = addModel("item_light", 11, 1,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/pohar.png")

item_light = addModel("item_light", 25, 6,
[[
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/stozar_v_l.png")

item_light = addModel("item_light", 29, 25,
[[
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/rahno_m.png")

item_light = addModel("item_light", 28, 27,
[[
.XXXX
..XXX
..XXX
..XXX
..XXX
XXXXX
]])
addItemAnim(item_light, "images/"..codename.."/stul.png")

item_heavy = addModel("item_heavy", 38, 29,
[[
XXXXXX
X....X
X.....
X.....
]])
addItemAnim(item_heavy, "images/"..codename.."/17-ocel.png")

item_heavy = addModel("item_heavy", 35, 18,
[[
X....X
X....X
XXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/18-ocel.png")

item_light = addModel("item_light", 15, 10,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/vejce.png")

item_light = addModel("item_light", 13, 18,
[[
XXXXXXXX
]])
addItemAnim(item_light, "images/"..codename.."/rahno_v.png")

item_light = addModel("item_light", 28, 2,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/hrnecek.png")



