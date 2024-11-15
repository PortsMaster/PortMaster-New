
createRoom(44, 30, "images/"..codename.."/reaktor-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXX....................................XXXX
XXXX....................................XXXX
XXXX....................................XXXX
XXXX....................................XXXX
XXXX....................................XXXX
XXXX....................................XXXX
XXXX....................................XXXX
XXXX....................................XXXX
XXXX....................................XXXX
XXXXXX.XXXXXX.X.X.X.X.X.X.X.X.X.......X.XXXX
XXXXXX.XXXXXX.X.X.X.X.X.X.X.X.X.......X.XXXX
XXXXXX.XXXXXX.X.X.X.X.X.X.X.X.X.......X.XXXX
XXXXX...XXXXX.X.XXX.X.X.X.XXX.X.........XXXX
XXXX.....XXXX.XXXXX.X.X.X.XXX.X.......X.XXXX
XXX.......XXX.XXXXX.X.X.XXXXXXX.......X.XXXX
XXX.......XXX.XXXXX.X.X.XXXXXXX.......X.XXXX
XXX.......XXXXXXXXX.X.X.XXXXXXX.......X.XXXX
XXXXX....XXXXXXXXXX.X.XXXXXXXXX.......X.XXXX
XXXXXXXXXXXXXXXXXXX.XXX.XXXXXXX.........XXXX
XXXXXXXXXXXXXXXXXXXXXXX.XXXXXXX.........XXXX
XXXXXXXXXXXXXXXXXXXXXXX.................XXXX
XXXXXXXXXXXXXXXXXXXXXXX.................XXXX
XXXXXXXXXXXXXXXXXXXXXXX......XXX..XXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXX......XXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXX....XXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXX....XXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/reaktor-w.png")

tyc = addModel("item_light", 38, 8,
[[
X
X
X
X
X
]])
addItemAnim(tyc, "images/"..codename.."/plutonium-5-_00.png")
-- extsize=2; first="plutonium-5-1.BMP"

item_light = addModel("item_light", 30, 8,
[[
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-5-_00.png")
-- extsize=2; first="plutonium-5-1.BMP"

item_light = addModel("item_light", 28, 8,
[[
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-5-_00.png")
-- extsize=2; first="plutonium-5-1.BMP"

item_light = addModel("item_light", 26, 10,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-3-_00.png")
-- extsize=2; first="plutonium-3-1.BMP"

item_light = addModel("item_light", 24, 9,
[[
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-4-_00.png")
-- extsize=2; first="plutonium-4-1.BMP"

item_light = addModel("item_light", 22, 9,
[[
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-4-_00.png")
-- extsize=2; first="plutonium-4-1.BMP"

item_light = addModel("item_light", 20, 5,
[[
X
X
X
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-8-_00.png")
-- extsize=2; first="plutonium-8-1.BMP"

item_light = addModel("item_light", 18, 11,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-2-_00.png")
-- extsize=2; first="plutonium-2-1.BMP"

item_light = addModel("item_light", 16, 9,
[[
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-4-_00.png")
-- extsize=2; first="plutonium-4-1.BMP"

item_light = addModel("item_light", 14, 6,
[[
X
X
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-7-_00.png")
-- extsize=2; first="plutonium-7-1.BMP"

item_light = addModel("item_light", 12, 10,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-3-_00.png")
-- extsize=2; first="plutonium-3-1.BMP"

item_light = addModel("item_light", 10, 5,
[[
X
X
X
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-8-_00.png")
-- extsize=2; first="plutonium-8-1.BMP"

item_light = addModel("item_light", 8, 11,
[[
.
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-1-_00.png")
-- extsize=2; first="plutonium-1-1.BMP"

item_light = addModel("item_light", 7, 12,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/plutonium-1a.png")

item_heavy = addModel("item_heavy", 34, 24,
[[
XX
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel.png")

small = addModel("fish_small", 32, 13,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 32, 10,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

pld = addModel("item_light", 3, 16,
[[
..XXX..
.XXXXX.
XXXXXXX
..XXXX.
]])
addItemAnim(pld, "images/"..codename.."/pld_00.png")
-- extsize=15; first="pld 1.BMP"



