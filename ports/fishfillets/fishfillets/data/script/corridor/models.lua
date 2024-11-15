
createRoom(34, 37, "images/"..codename.."/chodba-p2.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXX.XXXXXXXXXXXXXXXXXXXXXXXXXX.XXX
XXX.XXXXXX.XXXXXXXXXXXX.XXXXXX.XXX
................XX................
..................................
..................................
..........XXX..X.....XXX..........
XXX.....XXXXXX.X....XXXXXX.....XXX
XXX.XXXXX.XXXX.X....XXXX.XXXXX.XXX
XXXXX...X.XXXX.X....XXXX.X...XXXXX
XXX............................XXX
XXX............X...............XXX
XXX......XXXXXXX..XXXXXXX......XXX
XXX............................XXX
XXX............................XXX
XXX............................XXX
XXX.XXXXXXXXXXXX..XXXXXXXXX....XXX
XXX.XXXXXXXXXXXX..XXXXXXXXX....XXX
XXX............................XXX
XXX............................XXX
XXX.....XXXXX.X.XX.X.XXXXXXXXX.XXX
XXX.............XX.............XXX
XXX............................XXX
XXX............................XXX
XXX.....XXXXXX.XXXX.XXXXXX.....XXX
XXX........X.........X.........XXX
XXX........X...................XXX
XXX........X...................XXX
XXX............................XXX
XXX............................XXX
XXX............................XXX
XXX............................XXX
XXX............................XXX
XXX............................XXX
XXX...........X....X...........XXX
XXX..........XX....XX..........XXX
XXX.........XXX....XXX.........XXX
XXXXXXXXXXXXXXX....XXXXXXXXXXXXXXX
]])
addItemAnim(room, "images/"..codename.."/chodba-okoli.png")

rightpes = addModel("item_light", 22, 30,
[[
XX.......
X....XXX.
XX....XXX
.XXXXXXXX
.XXXXXXX.
XX.....XX
]])
addItemAnim(rightpes, "images/"..codename.."/robright_00.png")
-- extsize=8; first="robright1.BMP"

leftpes = addModel("item_light", 3, 30,
[[
.......XX
.XXX....X
XXX....XX
XXXXXXXX.
.XXXXXXX.
XX.....XX
]])
addItemAnim(leftpes, "images/"..codename.."/robleft_00.png")
-- extsize=8; first="robleft1.BMP"

vypinac = addModel("item_light", 15, 3,
[[
XX
XX
]])
addItemAnim(vypinac, "images/"..codename.."/vypinac_00.png")
-- extsize=2; first="vypinac1.BMP"

small = addModel("fish_small", 27, 6,
[[
XXX
]])
addFishAnim(small, LOOK_LEFT, "images/fishes/small")

big = addModel("fish_big", 4, 5,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")

item_heavy = addModel("item_heavy", 3, 0,
[[
X
X
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-4-tmp.png")

item_heavy = addModel("item_heavy", 30, 0,
[[
X
X
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-4-tmp.png")

item_heavy = addModel("item_heavy", 10, 1,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-25-tmp.png")

item_heavy = addModel("item_heavy", 10, 4,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-25-tmp.png")

item_heavy = addModel("item_heavy", 23, 1,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-25-tmp.png")

item_heavy = addModel("item_heavy", 23, 4,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-25-tmp.png")

dvere1 = addModel("item_light", 23, 2,
[[
X
X
]])
addItemAnim(dvere1, "images/"..codename.."/dvere-b_00.png")
-- extsize=3; first="dvere-b1.bmp"

dvere2 = addModel("item_light", 9, 9,
[[
X
X
]])
addItemAnim(dvere2, "images/"..codename.."/dvere-b_00.png")
-- extsize=3; first="dvere-b1.bmp"

dvere3 = addModel("item_light", 10, 2,
[[
X
X
]])
addItemAnim(dvere3, "images/"..codename.."/dvere-a_00.png")
-- extsize=3; first="dvere-a1.bmp"

dvere4 = addModel("item_light", 24, 9,
[[
X
X
]])
addItemAnim(dvere4, "images/"..codename.."/dvere-a_00.png")
-- extsize=3; first="dvere-a1.bmp"

item_heavy = addModel("item_heavy", 9, 7,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-14-tmp.png")

item_heavy = addModel("item_heavy", 24, 7,
[[
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-14-tmp.png")

poklop2 = addModel("item_light", 25, 22,
[[
XXXXX
]])
addItemAnim(poklop2, "images/"..codename.."/poklop_00.png")
-- extsize=3; first="poklop1.BMP"

poklop1 = addModel("item_light", 4, 22,
[[
XXXXX
]])
addItemAnim(poklop1, "images/"..codename.."/poklop_00.png")
-- extsize=3; first="poklop1.BMP"

item_heavy = addModel("item_heavy", 12, 32,
[[
XXXXXXXXXX
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-20-tmp.png")

item_heavy = addModel("item_heavy", 14, 26,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-21-tmp.png")

item_heavy = addModel("item_heavy", 14, 29,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-21-tmp.png")

item_heavy = addModel("item_heavy", 19, 29,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-21-tmp.png")

item_heavy = addModel("item_heavy", 19, 26,
[[
X
X
X
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-21-tmp.png")

item_heavy = addModel("item_heavy", 19, 25,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-25-tmp.png")

item_heavy = addModel("item_heavy", 14, 25,
[[
X
]])
addItemAnim(item_heavy, "images/"..codename.."/chodba-25-tmp.png")

item_light = addModel("item_light", 12, 34,
[[
X
]])
addItemAnim(item_light, "images/"..codename.."/matka_a.png")



