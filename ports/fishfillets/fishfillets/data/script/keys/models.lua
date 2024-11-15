
createRoom(22, 22, "images/"..codename.."/pozadi.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXX...........
XXXXXXXXX.............
XXXXXXX.............XX
XXXXXX...........X..XX
XXXXX............X..XX
XXX..............X..XX
XX.......XX......X..XX
XX.....XXXXX....XX..XX
XX....XX............XX
XX....X.............XX
XX....X.............XX
XX....X.............XX
XX....X.............XX
XX..................XX
XX....X.............XX
XX....X.............XX
XX..................XX
XX..................XX
XXXX..XXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/popredi.png")

item_heavy = addModel("item_heavy", 7, 16,
[[
XX
X.
X.
X.
]])
addItemAnim(item_heavy, "images/"..codename.."/vocel.png")

item_heavy = addModel("item_heavy", 11, 5,
[[
X.
X.
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel1.png")
item_heavy = addModel("item_heavy", 12, 5,
[[
XX
.X
.X
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel2.png")
item_heavy = addModel("item_heavy", 14, 5,
[[
XX
X.
X.
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel3.png")
item_heavy = addModel("item_heavy", 15, 5,
[[
.X
.X
XX
]])
addItemAnim(item_heavy, "images/"..codename.."/ocel4.png")

item_light = addModel("item_light", 11, 2,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/mvalec.png")
item_light = addModel("item_light", 12, 2,
[[
XX
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/vvalec.png")
item_light = addModel("item_light", 14, 2,
[[
XX
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/vvalec.png")
item_light = addModel("item_light", 16, 2,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/mvalec.png")

klic = {}

local i
for i = 0, 3 do
klic[i] = addModel("item_light", 12+i, 10,
[[
X
X
]])
addItemAnim(klic[i], "images/"..codename.."/klic_00.png")
end

item_light = addModel("item_light", 13, 15,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/szamek.png")

item_light = addModel("item_light", 5, 15,
[[
XX
]])
addItemAnim(item_light, "images/"..codename.."/vzamek.png")

small = addModel("fish_small", 12, 17,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 12, 12,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_LEFT, "images/fishes/big")
