--BRUSH: Negative V1.0

dofile("../libs/dawnbringer_lib.lua")



OK,amt,nobg,briweight = inputbox("Brush - Negative Colors",
                         "AMOUNT %", 100, 0,100,0,                   
                         "Exclude Background",      1,0,1,0,
                         "ColMatch Bri-Weight %", 25,  0,100,0 
           
);


if OK == true then

  pal = db.makePalList(256)

  if nobg == 1 then
   pal = db.stripIndexFromPalList(pal,getbackcolor())
  end

  w,h = getbrushsize()

  a1 = amt / 100
  a2 = 1 - a1

 
  cols = {}
  for c = 0, 255, 1 do
    r,g,b = getcolor(c)
    r = (255 - r) * a1 + r*a2
    g = (255 - g) * a1 + g*a2
    b = (255 - b) * a1 + b*a2
    cols[c+1] = db.getBestPalMatchHYBRID({r,g,b},pal,briweight/100,true) 
  end

  if nobg == 1 then cols[getbackcolor()+1] = getbackcolor(); end

for x = 0, w - 1, 1 do
 for y = 0, h - 1, 1 do
   putbrushpixel(x, y, cols[getbrushbackuppixel(x,y) + 1]);
 end
end

end