
createRoom(27, 21, "images/"..codename.."/odpadky-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXX.....XXXXXXXXXXXXXXX
XXXXXXX......XXXXXXXXXXXXXX
XXXXXXXX.XX..XXXXXXXXXXXXXX
XXXXXXXX.XXX.XXXXX.XXXXXXXX
XXXXXXXX.XXX.X.XXX.XXXXXXXX
XXXXX.................XXXXX
XXXXX.................XXXXX
XXXXX.................XXXXX
XXXXX.................XXXXX
XXXXX.................XXXXX
XXXXX.................XXXXX
XXXXX.................XXXX.
XXXXX.......X.........XXXX.
.XXXXXXXX...X....XXXXXXXX..
............X..............
............X..............
....XXXXXXXXXXXXXXXXXXX....
...XXXXXXXXXXXXXXXXXXXXX..X
.XXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/odpadky-w.png")

small = addModel("fish_small", 9, 12,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 16, 8,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

item_light = addModel("item_light", 11, 10,
[[
XX
.X
]])
addItemAnim(item_light, "images/"..codename.."/roura_m.png")

item_light = addModel("item_light", 8, 10,
[[
XXX
X..
X..
]])
addItemAnim(item_light, "images/"..codename.."/roura_st.png")

item_light = addModel("item_light", 5, 12,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/cola.png")

item_light = addModel("item_light", 8, 9,
[[
XXXX
]])
addItemAnim(item_light, "images/"..codename.."/prkno.png")

kohoutek = addModel("item_light", 11, 6,
[[
.X
XX
X.
]])
addItemAnim(kohoutek, "images/"..codename.."/kohoutek.png")

item_light = addModel("item_light", 15, 10,
[[
XX..
.X.X
.XXX
]])
addItemAnim(item_light, "images/"..codename.."/kachna.png")

item_light = addModel("item_light", 14, 9,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/cola.png")

item_light = addModel("item_light", 14, 6,
[[
XXXXXX
X....X
]])
addItemAnim(item_light, "images/"..codename.."/roura_v.png")

item_heavy = addModel("item_heavy", 19, 7,
[[
.X.
.XX
..X
..X
XXX
X..
]])
addItemAnim(item_heavy, "images/"..codename.."/odpadky-11-tmp.png")

item_light = addModel("item_light", 8, 1,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/cola.png")



