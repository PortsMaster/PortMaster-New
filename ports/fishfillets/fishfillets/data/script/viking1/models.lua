
createRoom(36, 29, "images/"..codename.."/drakar1-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
...................................
...................................
..................X................
..................XX...............
..................XX...............
....XXXXXXXXXXXXXXXXXXXXXXXX.......
..................XX........X......
..................XX........X......
..................XX........X......
..XXX.............XX........X......
...XXXXX..........XX........X......
..XXXXX...........XX........X......
....XXX...........XX........X......
....XX............XX........X......
....XX............XX...............
....XX............X.............X..
...XXXX...........X.............X..
...XXXX........................XXX.
..XXXXXX......................XXXX.
..XXXXXX.....................XXXXXX
..XXXXXXXXXXX................XXXXXX
..XXXXXXXXXXXXX..........XXXXXXXXXX
..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
..XXXXXXXXXXXXXXXXXXXXXXXXXX.XXXXXX
...XXXXXXXXXXXXXXXXXXXXXXXX...XXXXX
...XXXXXXX.XXXXXXXXXXXXXX....XXXXXX
....XXXXXX..XXXXXXXXXXXXXXXX.XXXXX.
....XXXX...XXXXXXXXXXXXXXXXXXXXXX..
.....XXXX.XXXXXXXXXXXXXXXXXXXXXX...
]])
addItemAnim(room, "images/"..codename.."/drakar1-w.png")

melodak1 = addModel("item_light", 13, 17,
[[
XXX
XXX
XXX
XXX
]])
addItemAnim(melodak1, "images/"..codename.."/vik2_00.png")
-- extsize=4; first="vik2_0.bmp"

hlavni = addModel("item_light", 9, 16,
[[
XXX
XXX
XXX
XXX
]])
addItemAnim(hlavni, "images/"..codename.."/vik1_00.png")
-- extsize=4; first="vik1_0.bmp"

basak = addModel("item_light", 17, 18,
[[
XXX
XXX
XXX
XXX
]])
addItemAnim(basak, "images/"..codename.."/vik6_00.png")
-- extsize=3; first="vik6_0.bmp"

piskac = addModel("item_light", 21, 18,
[[
XXX
XXX
XXX
XXX
]])
addItemAnim(piskac, "images/"..codename.."/vik7_00.png")
-- extsize=7; first="vik7_0.bmp"

melodak2 = addModel("item_light", 25, 17,
[[
XXX
XXX
XXX
XXX
]])
addItemAnim(melodak2, "images/"..codename.."/vik5_00.png")
-- extsize=3; first="vik5_0.bmp"

small = addModel("fish_small", 21, 15,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 8, 11,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

item_light = addModel("item_light", 13, 14,
[[
XX..
XXXX
XX..
]])
addItemAnim(item_light, "images/"..codename.."/sekera1.png")

item_light = addModel("item_light", 13, 11,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/stit-na_vysku.png")

item_light = addModel("item_light", 5, 7,
[[
XX
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/stit_zepredu.png")

snecek = addModel("item_light", 21, 17,
[[
X
]])
addItemAnim(snecek, "images/"..codename.."/maly_snek_00.png")
-- extsize=3; first="maly snek1.BMP"

item_light = addModel("item_light", 26, 15,
[[
XX
X.
]])
addItemAnim(item_light, "images/"..codename.."/lebzna1.png")

item_light = addModel("item_light", 24, 1,
[[
.X.
.X.
XXX
XXX
]])
addItemAnim(item_light, "images/"..codename.."/sekera2.png")



