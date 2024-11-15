
createRoom(41, 27, "images/"..codename.."/motor-pozadi.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXX....XXXXXXXXXXXXXXXX....XXXX
XXXXXXXXXXXXX....XXXXXXXXXXXXXXXX....XXXX
XXXXXXXXXXXXX....XXXXXXXXXXXXXXXX....XXXX
XXX.........X....X..............X....XXXX
XXX.............................X....XXXX
XXX.........X....X...................XXXX
XXX.........X....X...................XXXX
XXX.........X....X...................XXXX
XXX.........X....X.......X...........XXXX
XXX.........X....X.......XX..........XXXX
XXX.........X.............X..........XXXX
XXX...................................XXX
XXX.......................X..........XXXX
XXX......................XX..........XXXX
XXX......................XX..........XXXX
XXX......................X...........XXXX
XXX.........XXXXXXXXXXXXXX...........XXXX
XXX....................X.X...........XXXX
XXX....................X.X...........XXXX
XXX....................X.XXXXXX......XXXX
XXX....................X.............XXXX
XXXXXXXXXX...........................XXXX
XXXXXXXXXX...........................XXXX
XXXXXXXXXX....XXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXX..XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/motor-okoli.png")

klicek = addModel("item_light", 11, 12,
[[
XX..
XXXX
XX..
]])
addItemAnim(klicek, "images/"..codename.."/key_00.png")
-- extsize=2; first="key1.bmp"

motorek = addModel("item_light", 14, 10,
[[
...XXX...
XXXXXXXX.
XXXXXXXXX
..XXXXXXX
XXXXXXXX.
XXXXXX...
]])
addItemAnim(motorek, "images/"..codename.."/motor.png")

small = addModel("fish_small", 32, 20,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 17, 19,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

item_light = addModel("item_light", 9, 18,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/matka_a.png")

item_heavy = addModel("item_heavy", 24, 17,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/6-ocel.png")

item_heavy = addModel("item_heavy", 24, 20,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/6-ocel.png")

item_heavy = addModel("item_heavy", 9, 19,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/8-ocel.png")

item_heavy = addModel("item_heavy", 16, 4,
[[
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/9-ocel.png")

item_heavy = addModel("item_heavy", 12, 4,
[[
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/9-ocel.png")

klicisko = addModel("item_light", 27, 15,
[[
XXX..XX.
..XXXX..
..XXXX..
.XX..XXX
]])
addItemAnim(klicisko, "images/"..codename.."/hasak.png")

item_light = addModel("item_light", 17, 22,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/matka_a.png")

item_light = addModel("item_light", 3, 20,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/sroub.png")

item_light = addModel("item_light", 4, 19,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/matka_a.png")



