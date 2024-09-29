--PICTURE: Line Demo V2.0 (AA lines)
--by Richard Fhager 

dofile("../libs/dawnbringer_lib.lua")
--> db.lineTransp(x1,y1,x2,y2,c,transp_frac)

w, h = getpicturesize()
c = getforecolor()
r,g,b = getcolor(c)

floor = math.floor

div = floor(math.sqrt(w*h) / 10)


for n = 0, div - 1, 1 do
 x1 = floor(w/div * n)
 y2 = floor(h - (h/div) * (n+1))
 --db.lineTransp(x1,h-1,w-1,y2,c,0.5)
 db.lineTranspAAgamma(x1,h-1,w-1,y2, r,g,b, 0.5, 1.6) --   transp, gamma
 updatescreen(); if (waitbreak(0.02)==1) then return; end
end
