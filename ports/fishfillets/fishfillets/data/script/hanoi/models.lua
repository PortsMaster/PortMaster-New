
createRoom(57, 21, "images/"..codename.."/pozadi.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX......
X........................................................
X........................................................
X................XX..................XX..................
X................XX..................XX..................
X................XX..................XX..................
X................XX..................XX..................
X................XX..................XX..................
X................XX..................XX..................
X................XX..................XX..................
X................XX..................XX..................
X................XX..................XX..................
X................XX..................XX..................
XXXXXXXXX..XXXXXXXXXXXXXXXX..XXXXXXXXXXXXXXXX..XXXXXXXX..
X........................................................
X........................................................
X.....X......X..........X......X..........X......X.....X.
X.....XX....XX..........XX....XX..........XX....XX.......
X........................................................
X........................................................
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/popredi.png")

item_heavy = addModel("item_heavy", 7, 16,
[[
XXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/vocel.png")

item_heavy = addModel("item_heavy", 25, 16,
[[
XXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/vocel.png")

item_heavy = addModel("item_heavy", 43, 16,
[[
XXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/vocel.png")

item_light = addModel("item_light", 3, 3,
[[
.X.........X.
]])
addItemAnim(item_light, "images/"..codename.."/nejvysez.png")

item_light = addModel("item_light", 3, 5,
[[
..X.......X..
]])
addItemAnim(item_light, "images/"..codename.."/nahorez.png")

item_light = addModel("item_light", 3, 7,
[[
...X.....X...
]])
addItemAnim(item_light, "images/"..codename.."/uprostredz.png")

item_light = addModel("item_light", 3, 9,
[[
....X...X....
]])
addItemAnim(item_light, "images/"..codename.."/dolez.png")

item_light = addModel("item_light", 3, 11,
[[
.....X.X.....
]])
addItemAnim(item_light, "images/"..codename.."/nejnizez.png")

item_light = addModel("item_light", 9, 0,
[[
.
X
X
X
X
X
X
X
X
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/tyc.png")

item_light = addModel("item_light", 27, 0,
[[
.
X
X
X
X
X
X
X
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/styc.png")

item_light = addModel("item_light", 46, 0,
[[
.
X
X
X
X
X
X
X
X
X
X
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/tyc.png")

zluta = addModel("item_light", 3, 3,
[[
X...........X
.XXXXX.XXXXX.
]])
addItemAnim(zluta, "images/"..codename.."/nejvyse.png")

zelena = addModel("item_light", 3, 5,
[[
XX.........XX
..XXXX.XXXX..
]])
addItemAnim(zelena, "images/"..codename.."/nahore.png")

cyanova = addModel("item_light", 3, 7,
[[
XXX.......XXX
...XXX.XXX...
]])
addItemAnim(cyanova, "images/"..codename.."/uprostred.png")

modra = addModel("item_light", 3, 9,
[[
XXXX.....XXXX
....XX.XX....
]])
addItemAnim(modra, "images/"..codename.."/dole.png")

fialova = addModel("item_light", 3, 11,
[[
XXXXX...XXXXX
.....X.X.....
]])
addItemAnim(fialova, "images/"..codename.."/nejnize.png")

ocel = addModel("item_heavy", 51, 0,
[[
XXXXX
....X
....X
....X
....X
....X
....X
....X
....X
....X
....X
....X
....X
....X
....X
....X
]])
addItemAnim(ocel, "images/"..codename.."/ocel.png")

small = addModel("fish_small", 43, 1,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

big = addModel("fish_big", 51, 14,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")
