
createRoom(48, 35, "images/"..codename.."/banka-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
.............................................
.............................................
.............................................
...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
...X........................................X
...X........................................X
...X........................................X
...X........................................X
...XXXXXX...................................X
...X........................................X
...X........................................X
...X..............XXXXXXXXXXXX..............X
...X........................................X
...X........................................X
...X........................................X
...X........................................X
...X.........XX...XXXXXXXXXXXXXXXXXXXXXX....X
...X..........X.............................X
...X..........X.............................X
...X..........X.............................X
...X........................................X
...X...........XXXXXXXXXXXX...XXXXXXXXXX....X
XXXXXXXX..................XXXXX.............X
..........................X...X.............X
............................................X
XXXXXXXX....................................X
...X...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....X
...X........................................X
...X........................................X
...X........................................X
...X........................................X
...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/banka-w.png")

klicka = addModel("item_heavy", 32, 8,
[[
XXXXXXX
X.....X
X.....X
X.....X
X..X..X
X..X..X
X..X..X
XXXXXXX
]])
addItemAnim(klicka, "images/"..codename.."/klec_00.png")
-- extsize=1; first="Klec0.BMP"

small = addModel("fish_small", 7, 13,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

big = addModel("fish_big", 7, 10,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

item_heavy = addModel("item_heavy", 6, 15,
[[
X....XXXX
XXXXXX...
]])
addItemAnim(item_heavy, "images/"..codename.."/banka-3-tmp.png")

item_heavy = addModel("item_heavy", 17, 7,
[[
XXX
X.X
X.X
XXX
]])
addItemAnim(item_heavy, "images/"..codename.."/banka-4-tmp.png")

item_heavy = addModel("item_heavy", 24, 7,
[[
XXXX
X..X
...X
XXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/banka-5-tmp.png")

zataras = addModel("item_heavy", 37, 18,
[[
XXXX
X..X
XXXX
]])
addItemAnim(zataras, "images/"..codename.."/banka-6-tmp.png")

item_heavy = addModel("item_heavy", 32, 17,
[[
XXXX
X...
X.X.
XXX.
]])
addItemAnim(item_heavy, "images/"..codename.."/banka-7-tmp.png")

item_light = addModel("item_light", 12, 14,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/zk_lezici.png")

horni1 = addModel("item_light", 25, 8,
[[
XX
]])
addItemAnim(horni1, "images/"..codename.."/horni_tvor_00.png")
-- extsize=5; first="horni tvor0.BMP"

dolni1 = addModel("item_light", 25, 9,
[[
XX
]])
addItemAnim(dolni1, "images/"..codename.."/spodni_tvor_00.png")
-- extsize=5; first="spodni tvor0.BMP"

zkum = addModel("item_light", 15, 24,
[[
X
X
]])
addItemAnim(zkum, "images/"..codename.."/zk_b_00.png")
-- extsize=2; first="zk b0.bmp"

item_light = addModel("item_light", 19, 24,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_r_00.png")
-- extsize=2; first="zk r0.bmp"

item_light = addModel("item_light", 21, 24,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_zd_00.png")
-- extsize=2; first="zk zd0.bmp"

item_light = addModel("item_light", 27, 14,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_c_00.png")
-- extsize=2; first="zk c0.bmp"

item_light = addModel("item_light", 23, 14,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_m_00.png")
-- extsize=2; first="zk m0.bmp"

item_light = addModel("item_light", 20, 9,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_c_00.png")
-- extsize=2; first="zk c0.bmp"

item_light = addModel("item_light", 19, 27,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_m_00.png")
-- extsize=2; first="zk m0.bmp"

item_light = addModel("item_light", 26, 14,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_f_00.png")
-- extsize=2; first="zk f0.bmp"

item_light = addModel("item_light", 21, 27,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_f_00.png")
-- extsize=2; first="zk f0.bmp"

item_light = addModel("item_light", 24, 14,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_o_00.png")
-- extsize=2; first="zk o0.bmp"

item_light = addModel("item_light", 8, 5,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_b_00.png")
-- extsize=2; first="zk b0.bmp"

item_light = addModel("item_light", 19, 29,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_o_00.png")
-- extsize=2; first="zk o0.bmp"

item_light = addModel("item_light", 18, 29,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_r_00.png")
-- extsize=2; first="zk r0.bmp"

item_light = addModel("item_light", 17, 29,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_zd_00.png")
-- extsize=2; first="zk zd0.bmp"

item_light = addModel("item_light", 20, 29,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_m_00.png")
-- extsize=2; first="zk m0.bmp"

item_light = addModel("item_light", 21, 29,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_c_00.png")
-- extsize=2; first="zk c0.bmp"

item_light = addModel("item_light", 17, 27,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_y.png")

item_light = addModel("item_light", 25, 14,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_y.png")

item_light = addModel("item_light", 20, 27,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_z.png")

item_light = addModel("item_light", 28, 24,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_z.png")

horni2 = addModel("item_light", 34, 29,
[[
XX
]])
addItemAnim(horni2, "images/"..codename.."/horni_tvor_00.png")
-- extsize=5; first="horni tvor0.BMP"

dolni2 = addModel("item_light", 34, 30,
[[
XX
]])
addItemAnim(dolni2, "images/"..codename.."/spodni_tvor_00.png")
-- extsize=5; first="spodni tvor0.BMP"

item_light = addModel("item_light", 6, 7,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/nuz.png")

kostra = addModel("item_light", 38, 30,
[[
XXX
]])
addItemAnim(kostra, "images/"..codename.."/mrtvolka_00.png")
-- extsize=8; first="mrtvolka0.BMP"

item_light = addModel("item_light", 35, 7,
[[
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/pilka.png")

item_light = addModel("item_light", 36, 6,
[[
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/injekc.png")

oko = addModel("item_light", 7, 6,
[[
X
]])
addItemAnim(oko, "images/"..codename.."/oko_00.png")
-- extsize=4; first="oko 0.bmp"

qldik1 = addModel("item_light", 29, 15,
[[
X
]])
addItemAnim(qldik1, "images/"..codename.."/q_00.png")
-- extsize=7; first="q0.bmp"

qldik2 = addModel("item_light", 23, 30,
[[
X
]])
addItemAnim(qldik2, "images/"..codename.."/q_00.png")
-- extsize=7; first="q0.bmp"

qldik3 = addModel("item_light", 34, 18,
[[
X
]])
addItemAnim(qldik3, "images/"..codename.."/q_00.png")
-- extsize=7; first="q0.bmp"

lahvac = addModel("item_light", 19, 13,
[[
.XX
.XX
.XX
]])
addItemAnim(lahvac, "images/"..codename.."/lahvac_00.png")
-- extsize=33; first="lahvac0.BMP"

oka = addModel("item_light", 26, 28,
[[
XX
XX
XX
]])
addItemAnim(oka, "images/"..codename.."/oka_00.png")
-- extsize=14; first="oka0.BMP"

item_light = addModel("item_light", 29, 28,
[[
XX
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/med.png")

malej = addModel("item_light", 9, 24,
[[
XX
XX
]])
addItemAnim(malej, "images/"..codename.."/mala_00.png")
-- extsize=6; first="mala0.BMP"

ruka = addModel("item_light", 32, 28,
[[
XX
XX
XX
]])
addItemAnim(ruka, "images/"..codename.."/sklena_00.png")
-- extsize=11; first="sklena0.BMP"

item_light = addModel("item_light", 38, 24,
[[
X..
XXX
]])
addItemAnim(item_light, "images/"..codename.."/kreveta.png")

item_light = addModel("item_light", 33, 18,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/zk_y.png")

dvere1 = addModel("item_light", 9, 27,
[[
X
X
X
X
]])
addItemAnim(dvere1, "images/"..codename.."/dvere.png")

dvere2 = addModel("item_light", 12, 27,
[[
X
X
X
X
]])
addItemAnim(dvere2, "images/"..codename.."/dvere.png")

pldicek = addModel("item_light", 33, 9,
[[
X
]])
addItemAnim(pldicek, "images/"..codename.."/p_00.png")
-- extsize=36; first="p0.bmp"

item_light = addModel("item_light", 33, 10,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 33, 11,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 33, 12,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 33, 13,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 33, 14,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 34, 9,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 34, 10,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 34, 11,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 34, 12,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 34, 13,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 34, 14,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 35, 9,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 35, 10,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 35, 11,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 36, 9,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 36, 10,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 36, 11,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 36, 12,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 36, 13,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 36, 14,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 37, 9,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 37, 10,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 37, 11,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 37, 12,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 37, 13,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

item_light = addModel("item_light", 37, 14,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/p_00.png")

mutant = addModel("item_light", 5, 27,
[[
...
.X.
.X.
XXX
]])
addItemAnim(mutant, "images/"..codename.."/mutant_00.png")
-- extsize=9; first="Mutant0.bmp"



