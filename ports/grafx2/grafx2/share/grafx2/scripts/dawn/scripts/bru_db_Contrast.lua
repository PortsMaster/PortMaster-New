--BRUSH remap: Contrast & Brightness V2.0
--by Richard 'DawnBringer' Fhager 

--(V2.0: Absolute Brightness instead of %)


dofile("../libs/dawnbringer_lib.lua")
-->db.changeContrast(r,g,b,prc)


OK,con_prc,bri,nobg,briweight = inputbox("Brush - Contrast/Brightness",
                         "CONTRAST %: -100..100", 0, -100,100,0,
                         "BRIGHTNESS: -255..255", 0, -255,255,0,
                         "Exclude Background",      1,0,1,0,
                         "ColMatch Bri-Weight %", 25,  0,100,0 
           
);


if OK == true then

  pal = db.makePalList(256)

  if nobg == 1 then
   pal = db.stripIndexFromPalList(pal,getbackcolor())
  end

  w,h = getbrushsize()

  --bri = bri_prc * 2.55 

  cols = {}
  for c = 0, 255, 1 do
    r,g,b = getcolor(c)
    r,g,b = db.changeContrast(r,g,b,con_prc)
    --cols[c+1] = matchcolor(r+bri, g+bri, b+bri)
    cols[c+1] = db.getBestPalMatchHYBRID({r+bri,g+bri,b+bri},pal,briweight/100,true) 
  end

  if nobg == 1 then cols[getbackcolor()+1] = getbackcolor(); end

for x = 0, w - 1, 1 do
 for y = 0, h - 1, 1 do
   putbrushpixel(x, y, cols[getbrushbackuppixel(x,y) + 1]);
 end
end

end