--BRUSH Remap: ColorBalance V2.1
--by Richard 'DawnBringer' Fhager 

--(V2.1 Swapped position of Strict & Loose, same as col & pal versions)
--(V2.0: Absolute RGB instead of %)


dofile("../libs/dawnbringer_lib.lua")


OK,red,grn,blu,add,bri,loose,nobg,briweight = inputbox("Brush - Color Balance",
                         "  Red: -255..255", 0, -255,255,0,
                         "Green: -255..255", 0, -255,255,0,
                         " Blue: -255..255", 0, -255,255,0,
                         "1. Normal (additive)",     1,0,1,-1,
                         "2. Strict (bri preserv.)", 0,0,1,-1,
                         "3. Loose preservation",    0,0,1,-1,
                         
                         "Exclude Background",      1,0,1,0,
                         "ColMatch Bri-Weight %", 25,  0,100,0    
                
);

if OK == true then

pal = db.makePalList(256)

  if nobg == 1 then
   pal = db.stripIndexFromPalList(pal,getbackcolor())
  end

w, h = getbrushsize()

brikeep   = false;
loosemode = false; 
if   bri == 1 then brikeep = true; loosemode = false; end
if loose == 1 then brikeep = true; loosemode = true; end

 -- Let's convert all colors of the palette instead of each pixel, could be hundred times faster...
  cols = {}
  --rd = red*2.55
  --gd = grn*2.55
  --bd = blu*2.55
  rd = red
  gd = grn
  bd = blu
  for n = 0, 255, 1 do
    r,g,b = getcolor(n)
    r,g,b = db.ColorBalance(r,g,b, rd,gd,bd, brikeep, loosemode)
   -- cols[n+1] = matchcolor(r,g,b)
    cols[n+1] = db.getBestPalMatchHYBRID({r,g,b},pal,briweight/100,true) 
  end

 if nobg == 1 then cols[getbackcolor()+1] = getbackcolor(); end

for x = 0, w - 1, 1 do
 for y = 0, h - 1, 1 do
   putbrushpixel(x, y, cols[getbrushbackuppixel(x,y) + 1]);
 end
end

end -- ok
