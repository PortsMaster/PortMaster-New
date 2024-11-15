
createRoom(19, 19, "images/"..codename.."/noground-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
...............
...............
...............
...............
....X..........
...............
...............
...............
...............
...X........X.X
]])
addItemAnim(room, "images/"..codename.."/noground-w.png")

item_heavy = addModel("item_heavy", 2, 4,
[[
X....XXXXXXXXXX
X.............X
X.............X
X.............X
XXXX..........X
...X..........X
...X..........X
...X..........X
.XXX..........X
.X............X
.X....XXXX....X
.XX...X..X....X
..XXXXX..XXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/noground-1-tmp.png")

big = addModel("fish_big", 6, 6,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

small = addModel("fish_small", 7, 8,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

item_light = addModel("item_light", 12, 11,
[[
X.X
X.X
XXX
]])
addItemAnim(item_light, "images/"..codename.."/podkova.png")

item_light = addModel("item_light", 6, 10,
[[
.X.
.X.
.X.
XXX
]])
addItemAnim(item_light, "images/"..codename.."/kladivo.png")

item_light = addModel("item_light", 12, 8,
[[
XX
.X
.X
.X
.X
]])
addItemAnim(item_light, "images/"..codename.."/pohr.png")

item_light = addModel("item_light", 14, 13,
[[
.X
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/kanystr.png")



