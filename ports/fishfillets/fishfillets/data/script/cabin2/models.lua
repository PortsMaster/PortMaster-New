
createRoom(28, 24, "images/"..codename.."/kajuta2p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXX.....................XXX
XXXX....................XXXX
XXXX.....................XXX
XXXX.....................XXX
XXXX.....................XXX
XXXX....X..............X.XXX
XXXX....XX...............XXX
XXXX....XX.XXXXX....XXXXXXXX
XXXX....X...............XXXX
XXXX....X................XXX
XXXX....X................XXX
XXXX....X..........XXXXXXXXX
XXXX....X......X.........XXX
XX.......X...............XXX
X........................XXX
X...............XXXXXXXXXXXX
XXXX....XXXXXXX.............
XXXX........................
XXXX........................
XXXX................XXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/kajuta2w.png")

truhla = addModel("item_light", 3, 16,
[[
XX
XX
]])
addItemAnim(truhla, "images/"..codename.."/truhla.png")

papouch = addModel("item_light", 8, 16,
[[
XX.
XXX
]])
addItemAnim(papouch, "images/"..codename.."/papoucha_00.png")
-- extsize=1; first="papouchA1.BMP"

lampa = addModel("item_light", 20, 2,
[[
XXXXX
X....
]])
addItemAnim(lampa, "images/"..codename.."/lampa.png")

chobot = addModel("item_light", 4, 5,
[[
XX..X
XXXXX
]])
addItemAnim(chobot, "images/"..codename.."/chobotnice_00.png")
-- extsize=8; first="chobotnice0.BMP"

lebka = addModel("item_light", 18, 11,
[[
XX
.X
]])
addItemAnim(lebka, "images/"..codename.."/lebzna.png")

item_heavy = addModel("item_heavy", 19, 15,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/trubka1.png")

poklop = addModel("item_heavy", 15, 8,
[[
XXXXXX
]])
addItemAnim(poklop, "images/"..codename.."/trubka2.png")

small = addModel("fish_small", 21, 14,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 21, 15,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

papzivy = addModel("item_light", 11, 16,
[[
X..
XXX
]])
addItemAnim(papzivy, "images/"..codename.."/pap-zivy_00.png")
-- extsize=9; first="pap-zivy0.BMP"



