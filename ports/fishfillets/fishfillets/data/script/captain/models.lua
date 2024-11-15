
createRoom(41, 29, "images/"..codename.."/vladova-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXX.X.XXXXXXX.XXXXXXXXXXXXXXX
XXXXXXXXXXXXXXX.X.XXXXXXX.XXXXXXXXXXXXXXX
XXXXXXXXXXXXXXX.X.XXXXXXX.XXXXXXXXXXXXXXX
XXXXXXX.......X.X.XXXXXXX.XXXXXXXXXXXXXXX
XXXXXXX.......X.X.X....................XX
XXXXXXX.......X.X.X....................XX
XXXXXXX...........X........X....X......XX
XXXXXXX...........X........XXXXXX......XX
XXXXXXX................................XX
XXXXXXX.................................X
XXXXXXX........X.X.............XXXXXX...X
XXXXXXX........X.X...............XXXX...X
XXXXXXX........X.X......................X
XXXXXXX........X.X...............X......X
XXXXXXX........XXXX..............X......X
X...XXX........X.................X.....XX
X.X..............................X.....XX
X......................................XX
XXXXXX.X.XX...XXX.XX.X.................XX
XXXXXX...XXXXXXXXXXX.XXXXXXXX.......XXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXX....XX..XXXX
...........X................X........XXXX
.................................XX..XXXX
......................................XXX
XXXXX..XXXXX....XXXXXXXXX.XXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/vladova-w.png")

item_light = addModel("item_light", 11, 11,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/mapa_v.png")

item_heavy = addModel("item_heavy", 12, 9,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/vladova-2-tmp.png")

small = addModel("fish_small", 12, 12,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 8, 12,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

item_light = addModel("item_light", 15, 5,
[[
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/stozar_m.png")

item_light = addModel("item_light", 15, 0,
[[
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/stozar_v_l.png")

item_light = addModel("item_light", 17, 0,
[[
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/stozar_v.png")

item_light = addModel("item_light", 17, 5,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/pohar.png")

diamant3 = addModel("item_light", 26, 23,
[[
X
]])
addItemAnim(diamant3, "images/"..codename.."/krystal_m_00.png")
-- extsize=3; first="krystal m 0.BMP"

item_heavy = addModel("item_heavy", 26, 21,
[[
XX
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/vladova-10-tmp.png")

ocko = addModel("item_light", 35, 20,
[[
X
]])
addItemAnim(ocko, "images/"..codename.."/oko_00.png")
-- extsize=4; first="oko 0.bmp"

item_light = addModel("item_light", 30, 5,
[[
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/rahno_m.png")

item_light = addModel("item_light", 22, 5,
[[
XXXXXXXX
]])
addItemAnim(item_light, "images/"..codename.."/rahno_v.png")

lebkic = addModel("item_light", 9, 16,
[[
XX
XX
]])
addItemAnim(lebkic, "images/"..codename.."/lebza_00.png")
-- extsize=3; first="lebza 0.BMP"

diamant1 = addModel("item_light", 8, 11,
[[
X
]])
addItemAnim(diamant1, "images/"..codename.."/krystal_f_00.png")
-- extsize=3; first="krystal f 0.BMP"

hakahak = addModel("item_light", 31, 11,
[[
XX
X.
X.
X.
X.
X.
]])
addItemAnim(hakahak, "images/"..codename.."/hak_00.png")
-- extsize=2; first="hak0.BMP"

item_light = addModel("item_light", 32, 12,
[[
XXX
..X
..X
..X
..X
.XX
]])
addItemAnim(item_light, "images/"..codename.."/stul.png")

item_heavy = addModel("item_heavy", 32, 19,
[[
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/vladova-18-tmp.png")

item_light = addModel("item_light", 31, 17,
[[
....X
XXXXX
]])
addItemAnim(item_light, "images/"..codename.."/nuz.png")

item_light = addModel("item_light", 35, 12,
[[
XX.
XX.
X..
XXX
X.X
]])
addItemAnim(item_light, "images/"..codename.."/kreslo.png")

item_heavy = addModel("item_heavy", 25, 3,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/vladova-21-tmp.png")

diamantv = addModel("item_light", 32, 21,
[[
XX
]])
addItemAnim(diamantv, "images/"..codename.."/drahokam_00.png")
-- extsize=5; first="drahokam 0.BMP"

diamant2 = addModel("item_light", 19, 17,
[[
X
]])
addItemAnim(diamant2, "images/"..codename.."/krystal_c_00.png")
-- extsize=3; first="krystal c 0.BMP"

item_light = addModel("item_light", 34, 21,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/mapa_m.png")



