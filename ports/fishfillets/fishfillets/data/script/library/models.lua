
createRoom(21, 37, "images/"..codename.."/vrak-pozadi.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
........XXXXXXXXXXXXX
...........XXXXXXXXXX
...........XXXXXXXXXX
.....XX....X..XXXXXXX
...XXX........XXXXXXX
XXXXXX........XXXXXXX
XXXXX.........XXXXXXX
XXXXXXXXX.....XXXXXXX
XXXXXXXXXX....XXXXXXX
XXXXXXXXXX....XXXXXXX
XXXXXXXXX.....XXXXXXX
XXXXXXX.......XXXXXXX
XXXXXX........XXXXXXX
XXXXX.........XXXXXXX
XXXX.....X....XXXXXXX
XXXX.....X....XXXXXXX
X........X....XXX.XXX
X........X....XX...XX
X........X....X....XX
XXXX.....X......XXXXX
X........X........XXX
X........X........XXX
X........X........XXX
XXXX.....X.....XXXXXX
X........X........XXX
X........X........XXX
X........X........XXX
XXXX.....X......XXXXX
X........X........XXX
X........X........XXX
X........X........XXX
...............XXXXXX
..................XXX
X.X.......XXX.....XXX
XXX...............XXX
XXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/vrak-okoli.png")

big = addModel("fish_big", 4, 28,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

small = addModel("fish_small", 5, 27,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

sklibak = addModel("item_light", 8, 5,
[[
.XX
XX.
]])
addItemAnim(sklibak, "images/"..codename.."/ostnatec_00.png")
-- extsize=2; first="ostnatec0.BMP"

trubka = addModel("item_heavy", 8, 11,
[[
XX
.X
XX
]])
addItemAnim(trubka, "images/"..codename.."/4-ocel.png")

item_light = addModel("item_light", 1, 16,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/kniha-a.png")

item_light = addModel("item_light", 2, 16,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/kniha-b.png")

item_light = addModel("item_light", 2, 20,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/kniha-c.png")

item_light = addModel("item_light", 16, 20,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/mapa_v.png")

item_light = addModel("item_light", 3, 24,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/kniha-a.png")

item_light = addModel("item_light", 1, 25,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/kniha-mala.png")

item_light = addModel("item_light", 16, 18,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/kniha-lezi-b.png")

item_light = addModel("item_light", 3, 22,
[[
XXX
]])
addItemAnim(item_light, "images/"..codename.."/kniha-lezi-a.png")

item_light = addModel("item_light", 16, 24,
[[
XX
XX
XX
]])
addItemAnim(item_light, "images/"..codename.."/kniha-tlusta.png")

item_light = addModel("item_light", 17, 29,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/kniha-mala-a.png")

item_light = addModel("item_light", 17, 33,
[[
X
X
]])
addItemAnim(item_light, "images/"..codename.."/kniha-mala.png")

item_light = addModel("item_light", 15, 28,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/kniha-b.png")

item_light = addModel("item_light", 16, 28,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/kniha-a.png")

item_light = addModel("item_light", 16, 32,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/kniha-c.png")

item_light = addModel("item_light", 2, 30,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/mapa_v.png")

item_light = addModel("item_light", 15, 20,
[[
X
X
X
]])
addItemAnim(item_light, "images/"..codename.."/kniha-a.png")



