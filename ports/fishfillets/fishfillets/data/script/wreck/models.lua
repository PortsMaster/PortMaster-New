
createRoom(28, 20, "images/"..codename.."/potopena-pozadi.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
.......................XX...
.......................XX...
...............XXXXXXXXXXXXX
..X....................XX...
.XXX...................XX...
.XXX...................XX...
..XX...................XX...
..XXX..................XX...
..XXX..................XX...
...XX..................XX...
...XXXX................XX...
...XXXXXXXXX.X....XXXXXXXXXX
....XXXXXXXXXX......XXXXXXXX
....XXXXXXXXXX....XXXXX.....
....XXXXXXXXXX..............
.....XXXXXXXXX.............X
......XXXXXXXX....XXXXXXXXXX
XXXXXXXXXXXXXX....XXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/potopena-hotovo.png")

item_heavy = addModel("item_heavy", 3, 3,
[[
XXXXXXXXXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/potopena-1-tmp.png")

item_light = addModel("item_light", 16, 5,
[[
X.XX.X
XXXXXX
]])
addItemAnim(item_light, "images/"..codename.."/klobrc.png")

item_heavy = addModel("item_heavy", 13, 9,
[[
XXX
X.X
]])
addItemAnim(item_heavy, "images/"..codename.."/potopena-3-tmp.png")

item_light = addModel("item_light", 7, 7,
[[
XX
X.
]])
addItemAnim(item_light, "images/"..codename.."/cepicka.png")

small = addModel("fish_small", 5, 9,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

big = addModel("fish_big", 17, 7,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

item_light = addModel("item_light", 16, 4,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/muslicka.png")

meduza = addModel("item_light", 22, 8,
[[
X
X
X
]])
addItemAnim(meduza, "images/"..codename.."/medusa_00.png")
-- extsize=2; first="medusa1.BMP"

item_light = addModel("item_light", 17, 12,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/rybicka_h_00.png")
-- extsize=3; first="rybicka h1.BMP"



