--PALETTE Set: Custom RGB Levels V1.1
--by Richard Fhager 

dofile("../libs/dawnbringer_lib.lua")

OK,dummy,rshade,gshade,bshade,roff,goff,boff,clean,REMAP = inputbox("Custom RGB Level Palette",
 "--- R*G*B <= 256 ---", 0, 0,0,4,       
 "  Red Levels: 1-32", 6, 1,32,0,
 "Green Levels: 1-32", 6, 1,32,0,
 " Blue Levels: 1-32", 6, 1,32,0,
 "  Red Offset: -128..128", 0, -128,128,0,
 "Green Offset: -128..128", 0, -128,128,0,
 " Blue Offset: -128..128", 0, -128,128,0,
 "Remove Old Palette", 1,  0,1,0,
 "Remap Image", 0,  0,1,0 
);

if OK == true then

-- Channel shades (shades = 2 ^ bit-depth)


colors = {}

rmult = (255-roff) / (rshade-1)
gmult = (255-goff) / (gshade-1)
bmult = (255-boff) / (bshade-1)
col = 0
for r = 0, rshade-1, 1 do
  for g = 0, gshade-1, 1 do
    for b = 0, bshade-1, 1 do
       col = col + 1
       colors[col] = { r*rmult+roff, g*gmult+goff, b*bmult+boff } 
    end
  end
end

if col > 256 then
 messagebox("These values will produce a palette of more than 256 colors ("..col..").\nOnly the first 256 are set.")
end

for c = 1, math.min(256,#colors), 1 do
  setcolor(c-1,colors[c][1],colors[c][2],colors[c][3]) 
end

 if clean == 1 then
   for c = #colors+1, 256, 1 do 
     setcolor(c-1,0,0,0)  
   end
 end

 if REMAP == 1 then
  db.paletteRemap()
 end

end --OK