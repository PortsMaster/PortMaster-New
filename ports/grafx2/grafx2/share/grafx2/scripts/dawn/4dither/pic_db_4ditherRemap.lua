--PICTURE: 4-Dither System - Image Remapping
--(Remap current image with spare palette) 
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_4dither.lua")

sPal = db.makeSparePalList(256) -- Dither Palette original, untouched
Pal = db.fixPalette(sPal,1) -- Sorted Bright to Dark

LIMIT         = 32 -- Max # of colors in palette
LIMIT2        = 64 -- Max # of colors in palette with 2-dither
Gamma         = -2.2
Briweight     = 0.25 
Dither_Factor = 0.025 -- 0 = Best Colormatch only, any Dither goes. ("Roughness tolerance"), At 1.0 Coursness count as much as colormatching (and will result in only solid colors)
Two_Flag      = false -- Only 2-dithers
StripThreshold = math.max(15,100 - math.floor(math.max(0,#Pal-10)^1.3))  -- 90 for 16 cols, 45 for 32 cols, 100 for <11 colors

roughness = (1-Dither_Factor) * 100
bw = Briweight*100


OK,dummy1,StripThreshold,roughness,two_only,bw,dummy2,Gamma = inputbox("4-Dither Remap (SparePal: "..#Pal.." col)",
                                        
  "- Strip Rough Dithers, 100 = worst -",    0,0,0,4,
  "Strip Threshold: 1-100",  StripThreshold,  1.0,100.0,2,
  "Roughness Tolerance %",  roughness,  0,100,2,
  "2 Col Dithers Only",  0,0,1,0,
  "ColMatch Bri-Weight %",    bw,  0,100,0,
  "- Negative Value Sets Dynamic Mode -",  0,0,0,4,
  "MixColor Gamma",  Gamma,  -5.0,5.0,2 -- Negative input sets Dynamic Gamma mode

);


-- * Stripping rough dithers reduces the palette--dither colormatching and will speed things up (good for 32 col palettes)
-- * Roughness tolerance...

--
if OK then

 if two_only == 1 then Two_Flag = true; end
 Dither_Factor = 1-(roughness * 0.01)
 Briweight = bw / 100

 cPal = db.makePalList(256) -- Current Image pal (or dither pal for drawing combos)

 if #Pal <= LIMIT or (Two_Flag and #Pal <= LIMIT2) then

  -- Pal is fixed version of spare pal (sPal) 
  statusmessage("Matching Best Dithers...");waitbreak(0)
  MixPal = d4_.makeRatedMixpal(Pal,Gamma,Two_Flag,true) --  {r,g,b, v1,v2,v3,v4, rating, brightness}
  if StripThreshold < 100 then
   MixPal = d4_.stripMixpal(MixPal,StripThreshold) -- Only keep Mixcolors with a rating of StripThreshold or less
   messagebox("Size after stripping dithers with rating higher than "..StripThreshold..": "..#MixPal)
  end
  Match = d4_.scoreMatchDithers(MixPal,cPal, Dither_Factor, Briweight) -- Match to current untouch image-palette colors
  for n = 1, #sPal, 1 do; c = sPal[n]; setcolor(n-1,c[1],c[2],c[3]); end -- Copy Spare pal exactly, dither is drawn by these indexes
  --for n = #sPal, 255, 1 do; setcolor(n,0,0,0); end 
  d4_.fourDither_Score(MixPal,Match) -- Pal is fixed version of spare pal (sPal) and that which MixPal uses

   else messagebox("Too Many Colors in Spare Palette!","Max number of Colors: "..LIMIT)
 end

end
--