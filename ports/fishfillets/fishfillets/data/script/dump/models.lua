
createRoom(43, 32, "images/"..codename.."/smetak-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXX....X...................................
XXX......X..............................XXX
XXXX.....X...................XXXXXXX....XXX
XXXX.....X..............................XXX
XXXXX....X..............................XXX
XXXXXX...X.............................XXXX
XXXXXXXXXX..............................XXX
...............................X........XXX
...............................X........XXX
XXXXXXXXXXX.X.XXXXXX.X..............XXX.XXX
XXXX........X.XXXXXX................XX..XXX
XXXX....................................XXX
XXXX...XXXXX...XXXXXX..........X........XXX
XXXX.....XX....X.X.............X........XXX
XXX.........X....X................XX....XXX
XXX................................X....XXX
XXX.......XXXX.XXXXXXX.XXXXX.X..........XXX
XXX...............XXXX.XXXXX............XXX
XXX..................X............XX....XXX
XXX....X...........................X....XXX
XXX....XXXXXXX.X...........XX...........XXX
XXX........XXXXX.X......................XXX
XXXXXXXX...........XX...................XXX
XXXX..............XXXXXX...XXXXX..XXXXX.XXX
XXXX...XX..X...............XXXXXXXXXXXXXXXX
XXXX.................XXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/smetak-w.png")

meduza = addModel("item_light", 11, 11,
[[
X
X
X
]])
addItemAnim(meduza, "images/"..codename.."/medusa_00.png")
-- extsize=2; first="medusa1.BMP"

mic = addModel("item_light", 11, 14,
[[
X
]])
addItemAnim(mic, "images/"..codename.."/balonek_00.png")
-- extsize=3; first="balonek1.bmp"

item_light = addModel("item_light", 16, 16,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/matka_a.png")

item_light = addModel("item_light", 18, 14,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/cola.png")

item_light = addModel("item_light", 20, 12,
[[
X.
X.
XX
]])
addItemAnim(item_light, "images/"..codename.."/zralok.png")

item_light = addModel("item_light", 14, 5,
[[
X
X
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zebrik.png")

item_light = addModel("item_light", 10, 21,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/amfora_zelena.png")

meduza2 = addModel("item_light", 38, 10,
[[
X
X
]])
addItemAnim(meduza2, "images/"..codename.."/meduza_00.png")
-- extsize=1; first="Meduza1.BMP"

meduza1 = addModel("item_light", 36, 10,
[[
X
X
]])
addItemAnim(meduza1, "images/"..codename.."/meduzaz_00.png")
-- extsize=1; first="Meduzaz1.BMP"

item_light = addModel("item_light", 37, 10,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/flaska.png")

item_light = addModel("item_light", 36, 21,
[[
...X
..XX
.XXX
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/harmonika.png")

stonozka = addModel("item_light", 28, 6,
[[
.......X
XXXXXXXX
]])
addItemAnim(stonozka, "images/"..codename.."/mnohonozka_00.png")
-- extsize=1; first="mnohonozka0.BMP"

item_heavy = addModel("item_heavy", 29, 8,
[[
XXXXXXX
X.....X
......X
]])
addItemAnim(item_heavy, "images/"..codename.."/smetak-13-tmp.png")

item_light = addModel("item_light", 30, 9,
[[
XXXXX
]])
addItemAnim(item_light, "images/"..codename.."/stozar_v.png")

item_light = addModel("item_light", 34, 14,
[[
.X
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/kotva.png")

item_light = addModel("item_light", 34, 18,
[[
X.
XX
.X
]])
addItemAnim(item_light, "images/"..codename.."/retez.png")

lod = addModel("item_light", 26, 20,
[[
.....X
XXX..X
.XXXXX
.....X
]])
addItemAnim(lod, "images/"..codename.."/charon.png")

item_light = addModel("item_light", 37, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/sklenicka_pr.png")

item_heavy = addModel("item_heavy", 28, 16,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/smetak-19-tmp.png")

item_heavy = addModel("item_heavy", 28, 18,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/smetak-20-tmp.png")

item_light = addModel("item_light", 23, 24,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/lodnisroub.png")

item_heavy = addModel("item_heavy", 31, 12,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/smetak-20-tmp.png")

ostnatec = addModel("item_light", 15, 8,
[[
.XX
XX.
]])
addItemAnim(ostnatec, "images/"..codename.."/ostnatec_00.png")
-- extsize=2; first="ostnatec0.BMP"

item_light = addModel("item_light", 16, 10,
[[
X....
XXXXX
]])
addItemAnim(item_light, "images/"..codename.."/pohr.png")

item_light = addModel("item_light", 17, 14,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/tenisak.png")

item_light = addModel("item_light", 16, 17,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/lahev.png")

item_light = addModel("item_light", 9, 3,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/savle.png")

uhor = addModel("item_light", 7, 17,
[[
XXX
X..
X..
]])
addItemAnim(uhor, "images/"..codename.."/uhor_00.png")
-- extsize=1; first="Uhor0.BMP"

item_light = addModel("item_light", 10, 19,
[[
....X
XXXXX
...XX
]])
addItemAnim(item_light, "images/"..codename.."/sekyrka.png")

item_light = addModel("item_light", 9, 18,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/musla.png")

budik = addModel("item_light", 7, 16,
[[
X
]])
addItemAnim(budik, "images/"..codename.."/budik_00.png")
-- extsize=1; first="budik0.BMP"

item_light = addModel("item_light", 5, 20,
[[
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/stozar_v_l.png")

item_light = addModel("item_light", 11, 26,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/bota.png")

item_light = addModel("item_light", 12, 25,
[[
XXXXXX
....X.
....X.
]])
addItemAnim(item_light, "images/"..codename.."/zavora.png")

small = addModel("fish_small", 3, 19,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

big = addModel("fish_big", 3, 17,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")



