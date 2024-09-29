--PALETTE: Shuffle Palette (Diagnostics)
--by Richard Fhager

dofile("../libs/dawnbringer_lib.lua")


OK,onlysize,all256,remap = inputbox("Shuffle Palette",
  "1. Unique Colors only",      1,0,1,-1,                                  
  "2. All 256 Colors",   0,0,1,-1,
  "Remap Image",   0,0,1,0                
);

--
if OK then

pal = db.makePalList(256)

if onlysize == 1 then
 pal = db.fixPalette(pal)
 for n = 0, 255, 1 do
  setcolor(n,0,0,0)
 end
end

db.shuffle(pal)

for n = 1, #pal, 1 do
 c = pal[n]
 setcolor(n-1,c[1],c[2],c[3])
end


if remap == 1 then
 db.remapImage()
end

end -- OK
--