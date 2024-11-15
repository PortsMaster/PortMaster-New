
createRoom(37, 15, "images/"..codename.."/zrc-p.png")
setRoomWaves(6, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
..................................
..................................
..................................
................................XX
..............................XXXX
...XXXXX.XXXXXX..XXXXX.XXXXXXXXXX.
.........X.....................XX.
.XXX...........................XXX
.XXX.XXXXXXX..XXXXXXXXXXXXXXXXXXXX
..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.
...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.
..............................XXXX
................................XX
]])
addItemAnim(room, "images/"..codename.."/zrc-w.png")

peri = addModel("item_heavy", 21, 2,
[[
XX.
.X.
.X.
.X.
.X.
.XX
]])
addItemAnim(peri, "images/"..codename.."/peri_00.png")
-- extsize=7; first="peri1.BMP"

item_light = addModel("item_light", 8, 5,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/kriz.png")

lahev = addModel("item_light", 8, 6,
[[
X
X
]])
addItemAnim(lahev, "images/"..codename.."/lahev.png")

naboj = addModel("item_light", 13, 7,
[[
XX
]])
addItemAnim(naboj, "images/"..codename.."/naboj.png")

item_light = addModel("item_light", 27, 7,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/matka_a.png")

small = addModel("fish_small", 17, 7,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 3, 2,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

--NOTE: mirror should be the last item
zrcadlo = addModel("item_light", 11, 2,
[[
XX
XX
XX
]])
addItemAnim(zrcadlo, "images/"..codename.."/zrcadlo.png")



