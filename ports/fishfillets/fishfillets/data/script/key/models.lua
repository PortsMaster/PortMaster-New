
createRoom(37, 36, "images/"..codename.."/background.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXX...X..........XXXXXXXXXXXXX
XX.X.X.XXX...X......X...XXXXXXXXXXXXX
XX.X.X.XXXXX.XX........XXXXXXXXXXXXXX
XX.X.X.XXXXX........XXXXX....XXXXXXXX
XX.X.X.X.........................XXXX
XX.X.X.X........X..................XX
............................X......XX
........................X..........XX
.X.X.X.X.........X..................X
.X.X.X.X........................X...X
XXXXXXX......X.XXX..................X
XXXXXX......XX.XXX..................X
XXXX.........X.....................XX
XXX...........................XXXXXXX
XX...............X..........XXXXXXXXX
X.........................XXXXXXXXXXX
........XXX.............XXXXXXXXXXXXX
X..........XX...........XXX.XXXX.XXXX
......................X.XXX.XXXX.XXXX
X.....................X.XXX.XXXX.XXXX
......................X.XXX.XXXX.XXXX
X.....................X.XXX.XXXX.XXXX
..................................XXX
X..................................XX
...................................XX
X..................................XX
...................................XX
X.................................XXX
.................................XXXX
X...............................XXXXX
XX..............................XXXXX
XXX.............................XXXXX
XXXXXX.........................XXXXXX
XXXXXXXXXXX.................XXXXXXXXX
XXXXXXXXXXXX....XXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/foreground.png")

small = addModel("fish_small", 8, 17,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 6, 19,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

item_named_S = addModel("item_light", 14, 0,
[[
.XXXXXXXX
XX.....XX
.X...XXX.
.X.......
]])
addItemAnim(item_named_S, "images/"..codename.."/stone.png")

item_named_x = addModel("item_light", 27, 12,
[[
XXX
XXX
]])
addItemAnim(item_named_x, "images/"..codename.."/barrellay.png")

item_named_d = addModel("item_light", 21, 13,
[[
.X.
.X.
.X.
.X.
XXX
]])
addItemAnim(item_named_d, "images/"..codename.."/broom.png")

item_named_j = addModel("item_light", 12, 29,
[[
....X...X....X
....X...X....X
....X...X....X
XXX.X...X....X
X.XXXXXXXXXXXX
XXX...........
]])
addItemAnim(item_named_j, "images/"..codename.."/key.png")

item_named_y = addModel("item_light", 30, 12,
[[
X
]])
addItemAnim(item_named_y, "images/"..codename.."/pearl.png")

item_named_cactus = addModel("item_light", 3, 26,
[[
...X..
...X..
...X..
...X..
XXXX..
...X.X
...XXX
]])
addItemAnim(item_named_cactus, "images/"..codename.."/cactus.png")

item_named_h = addModel("item_light", 32, 8,
[[
X
]])
addItemAnim(item_named_h, "images/"..codename.."/pearl.png")

item_named_M = addModel("item_heavy", 10, 1,
[[
XXX
..X
..X
]])
addItemAnim(item_named_M, "images/"..codename.."/steelangle.png")

item_named_g = addModel("item_light", 3, 29,
[[
X
]])
addItemAnim(item_named_g, "images/"..codename.."/pearl.png")

item_named_C = addModel("item_heavy", 6, 1,
[[
X..........................
X..........................
X..........................
X..........................
X..........................
...........................
...........................
...........................
...........................
...........................
...........................
...........................
...........................
...........................
...........................
...........................
..........................X
]])
addItemAnim(item_named_C, "images/"..codename.."/rightsteel.png")

item_named_f = addModel("item_light", 28, 30,
[[
XX
XX
XX
]])
addItemAnim(item_named_f, "images/"..codename.."/barrelstand.png")

icicle = addModel("item_light", 17, 1,
[[
XXX
.X.
.X.
.X.
.X.
.X.
]])
addItemAnim(icicle, "images/"..codename.."/icicle.png")

item_named_A = addModel("item_heavy", 2, 3,
[[
X.....................
X.....................
X.....................
X.....................
X.....................
......................
......................
......................
......................
......................
......................
......................
......................
......................
......................
......................
.....................X
]])
addItemAnim(item_named_A, "images/"..codename.."/leftsteel.png")

item_named_J = addModel("item_heavy", 1, 4,
[[
........X
........X
X........
X........
]])
addItemAnim(item_named_J, "images/"..codename.."/locksteel.png")

item_named_n = addModel("item_light", 10, 15,
[[
XXX.
.XXX
]])
addItemAnim(item_named_n, "images/"..codename.."/animal.png")

item_named_m = addModel("item_light", 28, 28,
[[
XXX
.XX
]])
addItemAnim(item_named_m, "images/"..codename.."/canister.png")

item_named_B = addModel("item_heavy", 4, 2,
[[
X.......................
X.......................
X.......................
X.......................
X.......................
........................
........................
........................
........................
........................
........................
........................
........................
........................
........................
........................
.......................X
]])
addItemAnim(item_named_B, "images/"..codename.."/middlesteel.png")

item_named_s = addModel("item_light", 15, 5,
[[
X
X
X
X
X
]])
addItemAnim(item_named_s, "images/"..codename.."/ladder.png")

item_named_coral = addModel("item_light", 24, 24,
[[
...X.
...X.
...X.
...X.
XXXX.
X.XXX
]])
addItemAnim(item_named_coral, "images/"..codename.."/coral.png")

item_named_p = addModel("item_light", 14, 27,
[[
XXX.
XXXX
.X..
.X..
]])
addItemAnim(item_named_p, "images/"..codename.."/hammer.png")

item_named_q = addModel("item_light", 14, 0,
[[
X
]])
addItemAnim(item_named_q, "images/"..codename.."/stones.png")

item_named_a = addModel("item_heavy", 3, 6,
[[
X.X.X
X.X.X
]])
addItemAnim(item_named_a, "images/"..codename.."/3steel.png")

item_named_z = addModel("item_light", 31, 12,
[[
X
]])
addItemAnim(item_named_z, "images/"..codename.."/pearl.png")

