
createRoom(28, 14, "images/"..codename.."/pozadi.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
......XXXXXXXX.XXXXXXXXXXXXX
XXXXXX...............XXXXXXX
XXXXXX................XXXXXX
XXXXX................XXXXXXX
XXXXX..X............XXXXXXXX
XXXXX.................XXXXXX
..............XXXXXXX.XXXXXX
XX........................XX
...........................X
...........................X
XXXXXX.X.XXXXXXXXXXXXXXXXXXX
XXXXXX.X.XXXXXXXXXXXXXXXXXXX
XXXXXX.XXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/popredi.png")

ocel1 = addModel("item_heavy", 5, 2,
[[
.X.
.X.
XX.
.X.
.XX
]])
addItemAnim(ocel1, "images/"..codename.."/ocel1.png")

ocel2 = addModel("item_heavy", 1, 6,
[[
XX
]])
addItemAnim(ocel2, "images/"..codename.."/ocel2.png")

ocel3 = addModel("item_heavy", 15, 4,
[[
XXXXX
]])
addItemAnim(ocel3, "images/"..codename.."/ocel3.png")

valecek = {}
local i
for i = 0, 4 do
valecek[i] = addModel("item_light", 15+i, 5,
[[
X
]])
addItemAnim(valecek[i], "images/"..codename.."/valec_00.png")
end

tyc = addModel("item_light", 7, 7,
[[
X
X
X
]])
addItemAnim(tyc, "images/"..codename.."/tyc_00.png")

svetelko = {}

svetelko[0] = addModel("item_light", 0, 0,
[[
X
]])
addItemAnim(svetelko[0], "images/"..codename.."/svetlo_00.png")

svetelko[1] = addModel("item_light", 0, 0,
[[
.X
]])
addItemAnim(svetelko[1], "images/"..codename.."/svetlo_00.png")

svetelko[2] = addModel("item_light", 0, 0,
[[
..X
]])
addItemAnim(svetelko[2], "images/"..codename.."/svetlo_00.png")

svetelko[3] = addModel("item_light", 0, 0,
[[
...X
]])
addItemAnim(svetelko[3], "images/"..codename.."/svetlo_00.png")

svetelko[4] = addModel("item_light", 0, 0,
[[
....X
]])
addItemAnim(svetelko[4], "images/"..codename.."/svetlo_00.png")

small = addModel("fish_small", 23, 7,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 23, 8,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")

tma = addModel("item_light", 0, 0,
[[
.....X
]])
addItemAnim(tma, "images/"..codename.."/tma.png")