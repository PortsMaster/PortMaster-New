
createRoom(43, 38, "images/"..codename.."/bludiste-p.png")
setRoomWaves(5, 10, 5)

room = addModel("item_fixed", 0, 0,
[[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXX............XXXXX....XXXXXXXXXXXXXXX
XXXX.............................XXX.XXXXXX
XXX...............................X...XXXXX
XXX.....................................XXX
XX.......................................XX
XX.......................................XX
XXX.......................................X
XXX.......................................X
XXX......................................XX
XXXX.....................................XX
XXXX.....................................XX
XXXX.....................................XX
XXX......................................XX
XXX......................................XX
XXX................X....................XXX
XXX.....................................XXX
XXXX...................................XXXX
XXXX...................................XXXX
XXXX...................................XXXX
XXX....................................XXXX
XXX....................................XXXX
XX.....................................XXXX
XX....................................XXXXX
XX....................................XXXXX
XX....................................XXXXX
XX....................................XXXXX
XXX...................................XXXXX
XXX..................................XXXXXX
XXXX.................................XXXXXX
XXXX..................................XXXXX
XXX......................................XX
XX.........................................
XXXX.......................................
XXXXXXX..XXXXXX..XXXX.........XXXX.X.......
XXXXX....XXXXXXXXXXXXXXXX..XXXXXXXXX.X.....
XXXX....XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX...
]])
addItemAnim(room, "images/"..codename.."/bludiste-w.png")

muchoblud = addModel("item_light", 18, 14,
[[
XXXXXXXXXXXXXXX
X...X.........X
XXX.X.XXX.XXX.X
X.X.X...X.X.X.X
X.X.XXXXX.X.X.X
X...X.....X...X
X.XXX.X.XXX.XXX
X.X...X...X.X.X
X.X.XXXXXXX.X.X
X.X.X.........X
X.X.X.XXX.X.XXX
X...X.X.X.X.X.X
X.X.X.XXX.XXX.X
X.X.X...X......
XXXXXXXXXXXXXXX
X..............
XXXXXXXXXXXXXXX
]])
addItemAnim(muchoblud, "images/"..codename.."/koral_b.png")

snecek = addModel("item_light", 19, 29,
[[
X
]])
addItemAnim(snecek, "images/"..codename.."/maly_snek_00.png")
-- extsize=3; first="maly snek1.BMP"

item_heavy = addModel("item_heavy", 19, 31,
[[
XXXXXXXXXXXXXXX
..............X
..............X
]])
addItemAnim(item_heavy, "images/"..codename.."/3-ocel.png")

small = addModel("fish_small", 34, 31,
[[
XXX
]])
addFishAnim(small, LOOK_RIGHT, "images/fishes/small")

big = addModel("fish_big", 33, 29,
[[
XXXX
XXXX
]])
addFishAnim(big, LOOK_RIGHT, "images/fishes/big")



