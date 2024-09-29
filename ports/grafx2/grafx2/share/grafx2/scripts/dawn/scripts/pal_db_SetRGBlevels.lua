--PALETTE: Set RGB Levels V1.0
--by Richard Fhager 

dofile("../libs/dawnbringer_lib.lua")

OK,m676,m685,m884,m794,m5a5,m8a3,m4f4,m53f,REMAP = inputbox("Set RGB Level Palettes",
        
         "RGB 6-7-6  [252] (decent)", 1,  0,1,-1, 
         "RGB 6-8-5  [240] (v.good)", 0,  0,1,-1, 
         "RGB 8-8-4  [256] (good)", 0,  0,1,-1,  
         "RGB 7-9-4  [252] (v.good)", 0,  0,1,-1,
         "RGB 5-10-5 [250]", 0,  0,1,-1,
         "RGB 8-10-3 [240]", 0,  0,1,-1,
         "RGB 4-16-4 [256] (v.good)", 0,  0,1,-1,
         "RGB 5-3-16 [240] (bad!!!)", 0,  0,1,-1,    
         
         "Remap Image", 0,  0,1,0 
);

if OK == true then

clean = 1 -- remove old palette

-- Channel shades (shades = 2 ^ bit-depth)

colors = {}


if m676 == 1 then -- 252 colors
 rshade,gshade,bshade = 6,7,6
end

if m685 == 1 then -- 240 colors
 rshade,gshade,bshade = 6,8,5
end

if m884 == 1 then -- 256 colors
 rshade,gshade,bshade = 8,8,4
end

if m794 == 1 then -- 252 colors
 rshade,gshade,bshade = 7,9,4
end


if m5a5 == 1 then -- 250 colors
 rshade,gshade,bshade = 5,10,5
end


if m8a3 == 1 then -- 240 colors
 rshade,gshade,bshade = 8,10,3
end

if m53f == 1 then -- 240 colors
 rshade,gshade,bshade = 5,3,16
end

if m4f4 == 1 then -- 256 colors
 rshade,gshade,bshade = 4,16,4
end


rmult = 255 / (rshade-1)
gmult = 255 / (gshade-1)
bmult = 255 / (bshade-1)
col = 0
for r = 0, rshade-1, 1 do
  for g = 0, gshade-1, 1 do
    for b = 0, bshade-1, 1 do
       col = col + 1
       colors[col] = { r*rmult, g*gmult, b*bmult } 
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