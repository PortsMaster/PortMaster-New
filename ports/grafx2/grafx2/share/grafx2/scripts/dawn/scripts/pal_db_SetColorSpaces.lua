--PALETTE: Set Bitspaces & Shades V1.1
--by Richard Fhager 


-- Generate palette of all colors possible with a given number of shades for each channel
-- 2 shades = 1 bit / channel = 3 bit palette = 2^3 colors =  8 colors
-- 4 shades = 2 bit / channel = 6 bit palette = 2^6 colors = 64 colors

dofile("../libs/dawnbringer_lib.lua")

OK,b3,b6,s1,s3,s5,s6,clean,REMAP = inputbox("Set BitSpace / Shades",
         "3-Bit [8]", 1,  0,1,-1,
         "6-Bit [64]",0,  0,1,-1,
         "R,G,B & Black [4]",0,  0,1,-1,  
         "3 RGB-Shades [27]",0,  0,1,-1,  
         "5 RGB-Shades [125]",0,  0,1,-1,
         "6 RGB-Shades [216]",0,  0,1,-1,
         "Remove Old Palette", 1,  0,1,0,
         "Remap Image", 0,  0,1,0 
);

if OK == true then

-- Channel shades (shades = 2 ^ bit-depth)
shades = 1


colors = {}

if s1 == 1 then colors = {{0,0,0},{255,0,0},{0,255,0},{0,0,255}}; end

if b3 == 1 then shades = 2; end
if s3 == 1 then shades = 3; end
if b6 == 1 then shades = 4; end
if s5 == 1 then shades = 5; end
if s6 == 1 then shades = 6; end


if shades > 1 and shades <= 6 then
 mult = 255 / (shades-1)
 col = 0
 for r = 0, shades-1, 1 do
   for g = 0, shades-1, 1 do
     for b = 0, shades-1, 1 do
        col = col + 1
        colors[col] = { r*mult, g*mult, b*mult } 
     end
   end
 end
end

for c = 1, #colors, 1 do
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