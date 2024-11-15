
createRoom(29, 32, "images/"..codename.."/pozadi.png")
setRoomWaves(5, 10, 5)

item_light = addModel("item_light", 6, 12,
[[
XX...
.XXX.
...XX
]])
addItemAnim(item_light, "images/"..codename.."/python.png")

room = addModel("item_fixed", 0, 0,
[[
XX....XXXXXXXXX....XXXXXXXXXX
XX....XX...........XXXXXXXXXX
XX..........................X
XX..........................X
XX.................XXXXX....X
XX.................XXXXX....X
XX.................XXXXX....X
XX.................XXXXX....X
XX...XXXXXXXXX....XXXXXX....X
XX......XXXX..........XX....X
XX.....XX...................X
XXX.........................X
XXX.......X.................X
XXX.........................X
XX...................XX.....X
XX...............X....X.....X
XX......X...................X
X...........................X
X...........................X
XX..........................X
XX......X......XX..X........X
XXX.....XXX....XXXXX..X.....X
XXX.......X....XXXXX..X.....X
XXX.......X....XXXXXX.X....XX
XXX..XXXXXX....XXXXXXX....XXX
XXX..X........X...........XXX
XXXX.....XXXXXX..........XXXX
XXXXX......X.X........XXXXXXX
XXXXX......X.X....XXXXXXXXXXX
XXXXXX...........XXXXXXXXXXXX
XXXXX..XXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/popredi.png")

text = addModel("item_heavy", 5, 30,
[[
X
]])
addItemAnim(text, "images/"..codename.."/text_00.png")

cursor = addModel("item_heavy", 6, 30,
[[
X
]])
addItemAnim(cursor, "images/"..codename.."/cursor_00.png")

item_heavy = addModel("item_heavy",  16, 7,
[[
XXX
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel1.png")

item_heavy = addModel("item_heavy",  15, 6,
[[
XXXX
X...
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel2.png")

item_heavy = addModel("item_heavy", 8, 7,
[[
XXXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel3.png")

item_heavy = addModel("item_heavy", 2, 8,
[[
XX
XX
X.
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel4.png")

linuxak1 = addModel("item_light", 10, 15,
[[
X..
XX.
X..
X..
XX.
XXX
]])
addItemAnim(linuxak1, "images/"..codename.."/linuxak1_00.png")

linuxak2 = addModel("item_light", 19, 18,
[[
XXX
.XX
..X
..X
.XX
..X
]])
addItemAnim(linuxak2, "images/"..codename.."/linuxak2_00.png")

item_light = addModel("item_light", 18, 17,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/wilber.png")

bubble1 = addModel("item_light", 12, 27,
[[
X
]])
addItemAnim(bubble1, "images/"..codename.."/bubble1_00.png")

bubble2 = addModel("item_light", 12, 28,
[[
X
]])
addItemAnim(bubble2, "images/"..codename.."/bubble2_00.png")

item_light = addModel("item_light", 12, 29,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/bubble3.png")

small = addModel("fish_small", 11, 2,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 15, 2,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")
