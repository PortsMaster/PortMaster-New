
createRoom(33, 23, "images/"..codename.."/fdto-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXX............................X
X...............................X
X.........XXXXXXXXXXXXXXXXX.....X
X...................X...........X
X...................X..........XX
X...................X.......XXXXX
X...................X............
X...................X............
X...................X............
X...................XXXXXXX.X...X
X...................XX....XXX...X
X....................X..........X
X.......................X.......X
X...................X...........X
X...................X...........X
X...................X...........X
X...................X...........X
X...................X...........X
X...................X...........X
X...................X...........X
X...................X...........X
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/fdto-w.png")

semafor = addModel("item_light", 4, 11,
[[
X.
X.
X.
X.
X.
X.
X.
X.
X.
XX
.X
]])
addItemAnim(semafor, "images/"..codename.."/semafor_00.png")

item_heavy = addModel("item_heavy", 13, 8,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/antena.png")

item_light = addModel("item_light", 12, 9,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/prazdne.png")

vrsek = addModel("item_light", 11, 10,
[[
XXXXX
]])
addItemAnim(vrsek, "images/"..codename.."/vrsek_00.png")

o = addModel("item_light", 11, 11,
[[
XXXXXX
X....X
.....X
.....X
.....X
.....X
.....X
.....X
.....X
]])
addItemAnim(o, "images/"..codename.."/o_00.png")

f = addModel("item_light", 10, 11,
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
addItemAnim(f, "images/"..codename.."/f_00.png")

nahore = addModel("item_light", 11, 12,
[[
....X
XXXXX
X....
]])
addItemAnim(nahore, "images/"..codename.."/nahore_00.png")

dole = addModel("item_light", 11, 14,
[[
....X
XXXXX
X....
]])
addItemAnim(dole, "images/"..codename.."/dole_00.png")

spodek = addModel("item_light", 11, 16,
[[
....X
XXXXX
X....
]])
addItemAnim(spodek, "images/"..codename.."/spodek_00.png")

item_light = addModel("item_light", 11, 18,
[[
....X
XXXXX
X....
]])
addItemAnim(item_light, "images/"..codename.."/dt.png")

obrryb = addModel("item_light", 10, 20,
[[
X....XX
XXXXXXX
]])
addItemAnim(obrryb, "images/"..codename.."/velryb_00.png")

konik = addModel("item_light", 28, 3,
[[
X
X
X
]])
addItemAnim(konik, "images/"..codename.."/konik_00.png")

item_light = addModel("item_light", 20, 12,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/micek_0"..random(6)..".png")

item_light = addModel("item_light", 24, 11,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/micek_0"..random(6)..".png")

item_light = addModel("item_light", 25, 16,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/micek_0"..random(6)..".png")

item_light = addModel("item_light", 26, 16,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/micek_0"..random(6)..".png")

item_light = addModel("item_light", 25, 17,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/micek_0"..random(6)..".png")

item_light = addModel("item_light", 25, 18,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/micek_0"..random(6)..".png")

item_light = addModel("item_light", 26, 18,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/micek_0"..random(6)..".png")

koral = addModel("item_light", 25, 16,
[[
..X
.XX
..X
..X
XXX
X..
]])
addItemAnim(koral, "images/"..codename.."/koral.png")

item_light = addModel("item_light", 25, 19,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/krab_00.png")

small = addModel("fish_small", 7, 19,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

big = addModel("fish_big", 6, 20,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")



