--BRUSH Remap: Super Saturation
--by Richard Fhager 

dofile("../libs/dawnbringer_lib.lua") 


OK,sat_prc,brikeeplev,lowsat,nobg,briweight = inputbox("Brush - SuperSaturate",
                         " Add Saturation: 1-500", 50, 1,500,0,
                         "Keep Brightness: 0-2",  2,  0,2,0,
                         "GrayFade Mode",  1,0,1,0, 
                         "Exclude Background",      1,0,1,0,
                         "ColMatch Bri-Weight %", 25,  0,100,0
                                
);


if OK == true then

  pal = db.makePalList(256)

  if nobg == 1 then
   pal = db.stripIndexFromPalList(pal,getbackcolor())
  end

  sat = sat_prc * 2.55

  damp_flag = false
  if lowsat == 1 then damp_flag = true; end

  w, h = getbrushsize()

  -- Let's convert all colors of the palette instead of each pixel, could be hundred times faster...
  cols = {}
  for n = 0, 255, 1 do
   r,g,b = getcolor(n)
   r,g,b = db.saturateAdv(sat_prc,r,g,b,brikeeplev,damp_flag)
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