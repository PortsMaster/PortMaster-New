-- Get the Brightness of a mixcolor by 4 specifed colors

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_4dither.lua")

c1 = 11
c2 = 8
c3 = 11
c4 = 11

r1,g1,b1 = getcolor(c1)
r2,g2,b2 = getcolor(c2)
r3,g3,b3 = getcolor(c3)
r4,g4,b4 = getcolor(c4)


combos = {{0,1,2,3}}
pal = {{r1,g1,b1,c1}, {r2,g2,b2,c2}, {r3,g3,b3,c3}, {r4,g4,b4,c4}}
gamma = -2.2

mixpal = d4_.make4DithPal(combos,pal,gamma) -- {r,g,b, v1,v2,v3,v4}

--mixpal = d4_.makeRatedMixpal(pal,gamma, false,false) --  {r,g,b, v1,v2,v3,v4, rating, brightness}
--bri = mixpal[1][9] *  1.5690256395005606 -- Mixpal brightness is unnormalized!


r,g,b = mixpal[1][1],mixpal[1][2],mixpal[1][3]
messagebox("RGB: "..r..", "..g..", "..b)

--messagebox(#mixpal)

bri = db.getBrightness(r,g,b)
messagebox("Brightness: "..bri)