--BRUSH Remap: Grayscale Conversion
--by Richard Fhager 

dofile("../libs/dawnbringer_lib.lua")

OK,bri,sat,avg,amt,nobg,briweight = inputbox("Grayscale Brush - select method",
                        
                           "1. Brightness",       1,  0,1,-1,
                           "2. DeSaturate",       0,  0,1,-1,
                           "3. Average",          0,  0,1,-1, 
                           "AMOUNT %",          100,  0,100,0,
                           "Exclude Background",      1,0,1,0,
                           "ColMatch Bri-Weight %", 25,  0,100,0                                            
);


if OK == true then

 bg = getbackcolor()
 pal = db.fixPalette(db.makePalList(256))
 if nobg == 1 then
  pal = db.stripIndexFromPalList(pal,bg) -- Remove background color from pallist
 end

 fa = amt / 100
 fo = 1 - fa 

  w, h = getbrushsize()

  -- Let's convert all colors of the palette instead of each pixel, could be hundred times faster...
  cols = {}
  for n = 0, 255, 1 do
   r,g,b = getcolor(n)
     if bri == 1 then a = db.getBrightness(r,g,b); end
     if sat == 1 then a = db.desaturate(100,r,g,b); end
     if avg == 1 then a = (r+g+b)/3; end
     afa = a * fa
     r = r * fo + afa 
     g = g * fo + afa 
     b = b * fo + afa 
     --cols[n+1] = matchcolor(r,g,b)
     cols[n+1] = db.getBestPalMatchHYBRID({r,g,b},pal,briweight/100,true) 
  end

  if nobg == 1 then cols[getbackcolor()+1] = getbackcolor(); end

  for x = 0, w - 1, 1 do
   for y = 0, h - 1, 1 do
    putbrushpixel(x, y, cols[getbrushpixel(x,y) + 1]);
  end
 end

end
