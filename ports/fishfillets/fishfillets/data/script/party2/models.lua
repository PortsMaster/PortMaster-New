
createRoom(52, 33, "images/"..codename.."/party1-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXX....XXXXXX...X.XXXXXXXXX
XXXXXXX.XXXX......XXXXXX..........XXX.......XXXXXXXX
XXXXXX..X..X........XX............XXX........XXXXXXX
XXXXXX.............................X...........XXXXX
XXXX.............................................XXX
XX...............................................XXX
XX................................................XX
XX................................................XX
XX.................................................X
X..................................................X
X..................................................X
X..................................................X
X..................................................X
....................................................
....................................................
XX................................................XX
XXXXXXXXXXXXXXXXXXXXXXX.......XXXXXXXXXXXXXXXXXXXXXX
X..................................................X
X..................................................X
X..................................................X
X...X...X.....X..X...X..X.......X...X....X....X....X
X...X...X..X..X..X.X.X..X...X...X...X....X....X....X
X..................................................X
...................................................X
..XXX...X.....X....X....X.......X....X............X.
...XX.XXXX.XXXXXX.XXXXXXXXXXXXXXXXXXXXXXXX.XXXXXXXX.
....XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.
.....XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX..
X..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX..
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/party2-w.png")

item_light = addModel("item_light", 19, 15,
[[
........
.......X
]])
addItemAnim(item_light, "images/"..codename.."/kabina_okna.png")

ocel = addModel("item_heavy", 5, 25,
[[
XXXXXXXXXX
X...X.X..X
]])
addItemAnim(ocel, "images/"..codename.."/1-ocel.png")

item_light = addModel("item_light", 12, 21,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/sklenicka_pr.png")

item_light = addModel("item_light", 10, 21,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/sklenicka_lezici.png")

item_light = addModel("item_light", 13, 21,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/sklenicka_rozb.png")

item_light = addModel("item_light", 11, 21,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/sklenicka_pr.png")

glass1 = addModel("item_light", 7, 21,
[[
X
]])
addItemAnim(glass1, "images/"..codename.."/sklenicka_00.png")
-- extsize=2; first="sklenicka0.BMP"

item_light = addModel("item_light", 6, 21,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/sklenicka_pr.png")

item_light = addModel("item_light", 9, 21,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/sklenicka_pr_roz.png")

big = addModel("fish_big", 1, 25,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

item_heavy = addModel("item_heavy", 23, 12,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/14-ocel.png")

item_heavy = addModel("item_heavy", 26, 12,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/14-ocel.png")

item_heavy = addModel("item_heavy", 29, 12,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/14-ocel.png")

glass_plate = addModel("item_light", 6, 22,
[[
XXXXXXXX
]])
addItemAnim(glass_plate, "images/"..codename.."/tacek_00.png")
-- extsize=2; first="tacek0.BMP"

small = addModel("fish_small", 1, 24,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

item_light = addModel("item_light", 8, 21,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/sklenicka_roz.png")

kuk = addModel("item_light", 22, 16,
[[
X
]])
addItemAnim(kuk, "images/"..codename.."/kuk_00.png")
-- extsize=23; first="kuk0.bmp"

ruka = addModel("item_light", 21, 17,
[[
X
]])
addItemAnim(ruka, "images/"..codename.."/ruka_00.png")
-- extsize=6; first="ruka0.bmp"

frkavec = addModel("item_light", 23, 17,
[[
X
]])
addItemAnim(frkavec, "images/"..codename.."/frkavec_00.png")
-- extsize=6; first="frkavec0.bmp"

hnat = addModel("item_light", 25, 17,
[[
X
]])
addItemAnim(hnat, "images/"..codename.."/hnat_00.png")
-- extsize=21; first="hnat0.bmp"

lahev = addModel("item_light", 27, 17,
[[
X
]])
addItemAnim(lahev, "images/"..codename.."/lahev_00.png")
-- extsize=14; first="lahev0.bmp"

frk = addModel("item_light", 29, 17,
[[
X
]])
addItemAnim(frk, "images/"..codename.."/frk_00.png")
-- extsize=1; first="frk0.bmp"

kabina = addModel("item_light", 19, 15,
[[
.XXXXXXXXXXXX.
..X.XXX.X.XXX.
XX.X.X.X.X.XXX
XXXXXXXXXXXXXX
....XXXXXXX...
]])
addItemAnim(kabina, "images/"..codename.."/kabina_.png")



