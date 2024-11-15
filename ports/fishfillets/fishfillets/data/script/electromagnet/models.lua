
createRoom(48, 20, "images/"..codename.."/background.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX......XXXXXX.X
X..............................X.X......X.X....X
...............................X.X......X.X..X.X
.............................................X.X
.XX............................................X
XXX............................................X
XXX....XXXX..................................X.X
XXX....X.....................................X.X
XXXXXXXX...X.................................X.X
X..........X.................................X.X
X.........XX.................................X.X
X.........X...........X......................X.X
X............................................X.X
X....XX.XXXX.........................X.XX...XX.X
X....XXXXXXX...XXXX...XXXXXXXX..XXXXXX.X....XX.X
X....XXXXXXXXXXXXXXXXXXXXXXX....XXXXXX.....XXX.X
X....XXXXXXXXXXXXXXXXXX.......XXXXXXXX.....XXX.X
X..........................................XXX.X
XXXXXXX........XXXXXXXXXX.XXXXXXXXXXXXXXXXXX.X.X
XXXXXXXXXXXXXXXXXXXXXXXXX.XXXXXXXXXXXXXXXXX..X.X
]])
addItemAnim(room, "images/"..codename.."/foreground.png")

small = addModel("fish_small", 33, 10,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 33, 8,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

item_named_S = addModel("item_heavy", 37, 12,
[[
X
]])
addItemAnim(item_named_S, "images/"..codename.."/steel-1.png")

item_named_a = addModel("item_light", 19, 10,
[[
XXXXXXX
]])
addItemAnim(item_named_a, "images/"..codename.."/item_named_a.png")

item_named_x = addModel("item_light", 44, 18,
[[
X
]])
addItemAnim(item_named_x, "images/"..codename.."/screw-nut.png")

item_named_d = addModel("item_light", 18, 7,
[[
XXXXXXXXXX
]])
addItemAnim(item_named_d, "images/"..codename.."/item_named_d.png")

item_named_y = addModel("item_light", 16, 2,
[[
.XX
.X.
XX.
]])
addItemAnim(item_named_y, "images/"..codename.."/powerline.png")

item_named_h = addModel("item_light", 4, 10,
[[
X.
XX
.X
]])
addItemAnim(item_named_h, "images/"..codename.."/cristall.png")

lever = addModel("item_light", 10, 1,
[[
....................................X
.....................................
.....................................
.....................................
.....................................
.....................................
.....................................
.....................................
.....................................
.....................................
.....................................
.....................................
.....................................
.....................................
.....................................
.....................................
.....................................
.X...................................
..................................X..
]])
addItemAnim(lever, "images/"..codename.."/lever_00.png")

item_named_g = addModel("item_light", 43, 4,
[[
X.X
]])
addItemAnim(item_named_g, "images/"..codename.."/magnet-small.png")

item_named_f = addModel("item_light", 29, 16,
[[
X
X
]])
addItemAnim(item_named_f, "images/"..codename.."/can.png")

plutonium = addModel("item_light", 3, 13,
[[
X
X
X
X
X
]])
addItemAnim(plutonium, "images/"..codename.."/plutonium-5-_00.png")

killozap = addModel("item_light", 9, 6,
[[
....X
XXXXX
]])
addItemAnim(killozap, "images/"..codename.."/kill-o-zap.png")

damage_wall = addModel("item_heavy", 0, 2,
[[
X
X
X
]])
addItemAnim(damage_wall, "images/"..codename.."/damage-wall_00.png")

item_named_e = addModel("item_light", 19, 6,
[[
XXXXXXXXX
]])
addItemAnim(item_named_e, "images/"..codename.."/item_named_e.png")

item_named_J = addModel("item_heavy", 45, 5,
[[
X
]])
addItemAnim(item_named_J, "images/"..codename.."/steel-1.png")

item_named_s = addModel("item_light", 6, 12,
[[
X
]])
addItemAnim(item_named_s, "images/"..codename.."/screw-nut.png")

thingy = addModel("item_light", 3, 1,
[[
.XXXXXXXXXXXXXXXXX..........
XXXX.XXXXXXXX...XXXXXXXXXXXX
...............XXXXXXXXXXX..
.......................XXXX.
]])
addItemAnim(thingy, "images/"..codename.."/thingy.png")

item_named_B = addModel("item_heavy", 29, 0,
[[
.......XX........X
.......XX.........
.......XX........X
XXXXXXXXXXXXXXXX.X
..XXX......XXX....
]])
addItemAnim(item_named_B, "images/"..codename.."/steelbig.png")

item_named_c = addModel("item_light", 20, 8,
[[
XXXXX
]])
addItemAnim(item_named_c, "images/"..codename.."/item_named_c.png")

item_named_b = addModel("item_light", 19, 9,
[[
XXXXXXXX
]])
addItemAnim(item_named_b, "images/"..codename.."/item_named_b.png")

item_named_z = addModel("item_light", 29, 15,
[[
X
]])
addItemAnim(item_named_z, "images/"..codename.."/screw-nut.png")

alienmagnet = addModel("item_light", 3, 5,
[[
XXX....XXX
]])
addItemAnim(alienmagnet, "images/"..codename.."/alienmagnet_00.png")

