--BRUSH Remap: Hue & Lightness
--by Richard Fhager 

dofile("../libs/dawnbringer_lib.lua")
--> db.shiftHUE(r,g,b,deg)
--> db.changeLightness(r,g,b,percent)

OK,deg,lig,nobg,briweight,brikeep = inputbox("Brush - Hue & Lightness",
                        
                          "      HUE °: -180..180", 0, -180,180,0,
                          "LIGHTNESS %: -100..100", 0, -100,100,0,
                          "Exclude Background",      1,0,1,0,
                          "ColMatch Bri-Weight %", 25,  0,100,0,
                          "Keep Brightness on Hue", 1, 0,1,0                                                 
);



if OK == true then

  pal = db.makePalList(256)

  if nobg == 1 then
   pal = db.stripIndexFromPalList(pal,getbackcolor())
  end

  w, h = getbrushsize()

  -- Let's convert all colors of the palette instead of each pixel, could be hundred times faster...
  cols = {}
  for n = 0, 255, 1 do
   r,g,b = getcolor(n)
     --if deg ~= 0 then r,g,b = db.shiftHUE(r,g,b,deg); end
     --if lig ~= 0 then r,g,b = db.changeLightness(r,g,b,lig); end
     --cols[n+1] = matchcolor(r,g,b)

     -- new, with bricorrection
     if deg ~= 0 then 
      r2,g2,b2 = db.shiftHUE(r,g,b,deg)
      if brikeep == 1 then
        brio = db.getBrightness(r,g,b)
         for i = 0, 5, 1 do -- 6 iterations, fairly strict brightness preservation
          brin = db.getBrightness(r2,g2,b2)
          diff = brin - brio
          r2,g2,b2 = db.rgbcap(r2-diff, g2-diff, b2-diff, 255,0)
         end
      end
       else r2,g2,b2 = r,g,b
     end
 
     if lig ~= 0 then r2,g2,b2 = db.changeLightness(r2,g2,b2,lig); end
     --

     cols[n+1] = db.getBestPalMatchHYBRID({r2,g2,b2},pal,briweight/100,true) 
  end

  if nobg == 1 then cols[getbackcolor()+1] = getbackcolor(); end

  for x = 0, w - 1, 1 do
   for y = 0, h - 1, 1 do
    putbrushpixel(x, y, cols[getbrushpixel(x,y) + 1]);
  end
 end

end
