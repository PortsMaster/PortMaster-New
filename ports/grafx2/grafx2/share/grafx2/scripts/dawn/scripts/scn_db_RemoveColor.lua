--SCENE: Remove (pen)Color & Remap V1.0
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")

 FC    = getforecolor()
 r,g,b = getcolor(FC)
 pal   = db.stripIndexFromPalList(db.fixPalette(db.makePalList(256)), FC)
 c     = db.getBestPalMatchHYBRID({r,g,b},pal,0.35,true) 
 r2,g2,b2 = getcolor(c)

 w,h = getpicturesize()

count = 0
for y = 0, h - 1, 1 do
  for x = 0, w - 1, 1 do

   if getbackuppixel(x,y) == FC then
    putpicturepixel(x,y,c)
    count = count + 1
   end

  end
end

t = ""
t = t.."Color "..FC.." ["..r..", "..g..", "..b.."]" 
t = t.."\n\nreplaced with" 
t = t.."\n\nColor "..c.." ["..r2..", "..g2..", "..b2.."]" 
t = t.."\n\n("..count.." pixels)"

setcolor(FC,255,0,255)

messagebox("Remove Color & Remap",t)