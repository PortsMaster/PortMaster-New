
createRoom(24, 14, "images/"..codename.."/mikro-p.png")
setRoomWaves(4, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXX
XXXX..............XXXXXX
X.....................XX
X.....................XX
X.....................XX
X.....................XX
XX........XX.....XX...XX
XX........XXXXXXXXX...XX
XX....................XX
XXXXX.................XX
XXXXXXX....XXXXXXX....XX
XXXXXXX.XX.XXXX.......XX
XXXXXXX.XX.XXX........XX
XXXXXXXXXXXXX......XXXXX
]])
addItemAnim(room, "images/"..codename.."/mikro-w.png")

small = addModel("fish_small", 15, 3,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 2, 7,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

valec = addModel("item_heavy", 6, 7,
[[
X
X
X
]])
addItemAnim(valec, "images/"..codename.."/mikro-3-tmp.png")

item_heavy = addModel("item_heavy", 13, 1,
[[
XXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/mikro-4-tmp.png")

kun = addModel("item_light", 18, 3,
[[
X
X
]])
addItemAnim(kun, "images/"..codename.."/konik_00.png")
-- extsize=3; first="konik1.BMP"

rybusa = addModel("item_light", 17, 2,
[[
XX
]])
addItemAnim(rybusa, "images/"..codename.."/rybicka_h_00.png")
-- extsize=3; first="rybicka h1.BMP"

sepie = addModel("item_light", 15, 5,
[[
XXXX
]])
addItemAnim(sepie, "images/"..codename.."/sepijka_00.png")
-- extsize=5; first="sepijka 0.BMP"

krab4 = addModel("item_light", 13, 3,
[[
XX.
.XX
]])
addItemAnim(krab4, "images/"..codename.."/poustevnicek_b_00.png")
-- extsize=3; first="poustevnicek b0.BMP"

krab3 = addModel("item_light", 10, 3,
[[
XX.
.XX
]])
addItemAnim(krab3, "images/"..codename.."/poustevnicek_z_00.png")
-- extsize=3; first="poustevnicek z0.BMP"

krab2 = addModel("item_light", 9, 4,
[[
XX.
.XX
]])
addItemAnim(krab2, "images/"..codename.."/poustevnicek_f_00.png")
-- extsize=3; first="poustevnicek f0.BMP"

snek = addModel("item_light", 7, 2,
[[
X
]])
addItemAnim(snek, "images/"..codename.."/maly_snek_00.png")
-- extsize=3; first="maly snek1.BMP"

krab1 = addModel("item_light", 4, 5,
[[
XX.
.XX
]])
addItemAnim(krab1, "images/"..codename.."/poustevnicek_m_00.png")
-- extsize=3; first="poustevnicek m0.BMP"



