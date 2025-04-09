--PICTURE: Line Demo V2.0 (Drawbuffer)
--by Richard Fhager 

-- Note: Right now this demo is repeatedly redrawing/updating the ever growing drawbuffer, so it slows down over time.
-- Maybe we should add options/controls to only draw a specific segment of the buffer?

dofile("../libs/db_drawbuffer.lua")

--dofile("../libs/dawnbringer_lib.lua")
--> db.lineTransp(x1,y1,x2,y2,c,transp_frac)

w, h = getpicturesize()

dbuf = drawb.Init(w,h,1.6)

c = getforecolor()
r,g,b = getcolor(c)

div = math.floor(math.sqrt(w*h) / 10)


for n = 0, div - 1, 1 do
 x1 = math.floor(w/div * n)
 y2 = math.floor(h - (h/div) * (n+1))
 --db.lineTransp(x1,h-1,w-1,y2,c,0.5)
 --db.lineTranspAAgamma(x1,h-1,w-1,y2, r,g,b, 0.5, 1.6) --   transp, gamma
 drawb.LineAA(dbuf,x1,h-1,w-1,y2,r,g,b,0.5)
 drawb.RenderBuffer(dbuf)
 updatescreen(); if (waitbreak(0)==1) then return; end
end

drawb.RenderBufferHQ(dbuf,0.65) -- briweight