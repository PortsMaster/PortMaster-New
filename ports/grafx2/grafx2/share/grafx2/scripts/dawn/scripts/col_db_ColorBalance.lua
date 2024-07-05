--COLOR: ColorBalance V1.2
--by Richard Fhager 

-- (V1.2 Split penonly/penrange, added no change warning)
-- (V1.1 Added pen-color range)


dofile("../libs/dawnbringer_lib.lua")
--> db.ColorBalance(r,g,b, rd,gd,bd, brikeep_flag, loosemode_flag)

FC = getforecolor()
BC = getbackcolor()
range1 = math.min(FC,BC)
range2 = math.max(FC,BC)


OK,red,grn,blu,add,bri,loose,penonly,penrange = inputbox("ColorBalance (PenCol = "..FC..")",
                         "  Red: -255..255", 0, -255,255,0,
                         "Green: -255..255", 0, -255,255,0,
                         " Blue: -255..255", 0, -255,255,0,
                         "1. Normal (additive)",      0,0,1,-1,
                         "2. Strict (bri preserv.)",  1,0,1,-1,
                         "3. Loose preservation",     0,0,1,-1,
                         "a) Pen-Col only (#"..FC..")", 1, 0,1,-2,
                         "b) Color Range (#"..range1.."-"..range2..")", 0, 0,1,-2                 
);

if OK == true then

brikeep   = false;
loosemode = false; 
if   bri == 1 then brikeep = true; loosemode = false; end
if loose == 1 then brikeep = true; loosemode = true; end

  rd = red
  gd = grn
  bd = blu

 if penonly == 1 then
  r0,g0,b0 = getcolor(FC)
  r,g,b = db.ColorBalance(r0,g0,b0, rd,gd,bd, brikeep, loosemode)
  setcolor(FC,r,g,b)
  if (r==r0 and g==g0 and b==b0) then
   messagebox("Color Balance","No change could be done to color!\n\nTry Loose mode instead.")
  end
 end

 
 if penrange == 1 then
  for n = 0, 255, 1 do
    if (n >= range1 and n<= range2) then
     r,g,b = getcolor(n)
     r,g,b = db.ColorBalance(r,g,b, rd,gd,bd, brikeep, loosemode)
     setcolor(n,r,g,b)
    end
  end
 end

 --[[
  for n = 0, 255, 1 do
    if n == FC or (penrange == 1 and n >= range1 and n<= range2) then
     r,g,b = getcolor(n)
     r,g,b = db.ColorBalance(r,g,b, rd,gd,bd, brikeep, loosemode)
     setcolor(n,r,g,b)
    end
  end
 --]]

end -- ok
