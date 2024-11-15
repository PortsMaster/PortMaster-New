
createRoom(40, 30, "images/"..codename.."/pozadi.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXX....XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXX......................XXXXXXXXXXX
XXXXXXX......................XXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXX....XXXXXXXXXXX
X.......................X....X.........X
X......................................X
X....................................XXX
X...XX.................................X
X...XXX....XXXX..X..XXXXXXXXXXXXX......X
X...XXX....XXXXXXXXXXXXXXXXXXXXXX......X
X...X......X...................X.......X
X...X..........................X.......X
X...X..........................X.......X
X...XXXXXXXX..X..XXXXXXXXX....XX.......X
X...XXXXXXXXXXXXXXXXXXXXXX....XX.......X
X...XX..............X..................X
X...XX.................................X
X...XX.................................X
X...XXX....XXXX..X..XXXXXXXXXXXXX......X
X...XXX....XXXXXXXXXXXXXXXXXXXXXX......X
X...X......X...................XX......X
X...X..........................XX......X
X..............................XX......X
X...XXXXXXXX..X..XXXXXXXXX....XXX......X
X...XXXXXXXXXXXXXXXXXXXXXX....XXX......X
X...X...............X...........X......X
X...X...........................X......X
X......................................X
XXXXXXXXXXXXXXX..X..XXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/knihovna-zed1.png")

universal = addModel("item_light", 25, 4,
[[
XX
]])
addItemAnim(universal, "images/"..codename.."/drahokam_00.png")
-- extsize=5; first="drahokam 0.BMP"

item_light = addModel("item_light", 18, 21,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/koruna_00.png")
-- extsize=5; first="koruna0.BMP"

item_light = addModel("item_light", 18, 11,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/koruna_00.png")
-- extsize=5; first="koruna0.BMP"

item_light = addModel("item_light", 12, 26,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/svicen.png")

item_light = addModel("item_light", 12, 16,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/svicen.png")

item_light = addModel("item_light", 12, 6,
[[
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/svicen.png")

small = addModel("fish_small", 5, 27,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

big = addModel("fish_big", 5, 25,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

item_heavy = addModel("item_heavy", 6, 7,
[[
XXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/3-ocel.png")

item_heavy = addModel("item_heavy", 25, 12,
[[
XXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/3-ocel.png")

item_heavy = addModel("item_heavy", 6, 17,
[[
XXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/3-ocel.png")

item_heavy = addModel("item_heavy", 25, 22,
[[
XXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/3-ocel.png")

item_heavy = addModel("item_heavy", 32, 10,
[[
X
X
X
X
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/7-ocel.png")

pc2 = addModel("item_light", 31, 17,
[[
XXX
]])
addItemAnim(pc2, "images/"..codename.."/prsten-3_00.png")
-- extsize=5; first="prsten-31.BMP"

switcher = addModel("item_light", 35, 5,
[[
XXX
]])
addItemAnim(switcher, "images/"..codename.."/vazav.png")

pf2 = addModel("item_light", 25, 5,
[[
XXX
]])
addItemAnim(pf2, "images/"..codename.."/prsten-_00.png")
-- extsize=1; first="prsten-5.BMP"

item_light = addModel("item_light", 7, 5,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/vazav.png")

item_light = addModel("item_light", 4, 6,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/vazav1.png")

db1 = addModel("item_light", 4, 5,
[[
XXX
]])
addItemAnim(db1, "images/"..codename.."/drahokam_b_00.png")
-- extsize=1; first="drahokam b2.BMP"

pf1 = addModel("item_light", 7, 6,
[[
XXX
]])
addItemAnim(pf1, "images/"..codename.."/prsten-_00.png")
-- extsize=1; first="prsten-5.BMP"

item_light = addModel("item_light", 23, 7,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/vazav.png")

db2 = addModel("item_light", 20, 6,
[[
XXX
]])
addItemAnim(db2, "images/"..codename.."/drahokam_b_00.png")
-- extsize=1; first="drahokam b0.BMP"

item_light = addModel("item_light", 22, 5,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/vazav1.png")

pazur = addModel("item_light", 33, 4,
[[
XXX
]])
addItemAnim(pazur, "images/"..codename.."/prsten-4.png")

pc1 = addModel("item_light", 20, 4,
[[
XXX
]])
addItemAnim(pc1, "images/"..codename.."/prsten-2_00.png")
-- extsize=5; first="prsten-21.BMP"

item_light = addModel("item_light", 26, 6,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/amfora_cervena-a.png")

item_light = addModel("item_light", 27, 6,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/pohar.png")

item_light = addModel("item_light", 28, 6,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/amfora_zelena-a.png")

item_light = addModel("item_light", 29, 6,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/amfora-a.png")

item_light = addModel("item_light", 30, 6,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/vaza_cervena-a.png")

item_light = addModel("item_light", 4, 4,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/pohar-a.png")

item_light = addModel("item_light", 20, 5,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/amfora.png")

item_light = addModel("item_light", 21, 7,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/vaza_cervena.png")

item_light = addModel("item_light", 24, 6,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/amfora_zelena.png")

krystal = addModel("item_light", 12, 25,
[[
X
]])
addItemAnim(krystal, "images/"..codename.."/krystal_00.png")
-- extsize=27; first="krystal0.BMP"

item_light = addModel("item_light", 13, 25,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal_00.png")
-- extsize=27; first="krystal0.BMP"

item_light = addModel("item_light", 18, 20,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal_00.png")
-- extsize=27; first="krystal0.BMP"

item_light = addModel("item_light", 19, 20,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal_00.png")
-- extsize=27; first="krystal0.BMP"

item_light = addModel("item_light", 12, 15,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal_00.png")
-- extsize=27; first="krystal0.BMP"

item_light = addModel("item_light", 13, 15,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal_00.png")
-- extsize=27; first="krystal0.BMP"

item_light = addModel("item_light", 18, 10,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal_00.png")
-- extsize=27; first="krystal0.BMP"

item_light = addModel("item_light", 19, 10,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal_00.png")
-- extsize=27; first="krystal0.BMP"

item_light = addModel("item_light", 12, 5,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal_00.png")
-- extsize=27; first="krystal0.BMP"

item_light = addModel("item_light", 13, 5,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/krystal_00.png")
-- extsize=27; first="krystal0.BMP"



