--PICTURE: Fill Color with Brush V1.2
--by Richard Fhager

dofile("../libs/dawnbringer_lib.lua")

OK,DFILL,MDIST,POWER,EXP,CAP,NOBG,XOFF,YOFF = inputbox("Fill Color With Brush", 
 "Fill by ColorDistance*",      0,  0,1,0,
 "*Max ColDistance: 1-255", 32,     1,256,0,  
 "*POWER: 0.0-10.0", 1.0,     0,10,2, 
 "*Fall-off Exponent", 1.0,    0,8,2, 
 "*Cap on Overpower",          0,  0,1,0,
 "Use Brush Transp.",          1,  0,1,0,  
 "X-Offset", 0,  -256,256,0,    
 "Y-Offset", 0,  -256,256,0               
);


if OK == true then

 exp = EXP
 power = POWER
 cap = CAP

 FC = getforecolor()
 BG = getbackcolor()
 fr,fg,fb = getcolor(FC)
 w,h = getpicturesize()
 bw,bh = getbrushsize()

 min = math.min

for y = 0, h-1, 1 do
 for x = 0, w-1, 1 do

   ic = getbackuppixel(x,y)
   bc = getbrushpixel((x - XOFF) % bw, (y - YOFF) % bh)

  if (NOBG == 0 or (NOBG == 1 and bc ~= BG)) then
   if DFILL == 1 then
     r,g,b = getcolor(bc)
     ir,ig,ib = getcolor(ic)
     dist = db.getColorDistance_weightNorm(fr,fg,fb,ir,ig,ib,0.55,0.26,0.19)
     if dist < MDIST then
       ipow = (dist / MDIST) 
       if cap == 0 then
        bpow = ((1 - ipow) * power) ^ exp
         else
          bpow = min(1, ((1 - ipow) * power) ^ exp)
       end
       ipow = 1 - bpow
       dc = matchcolor2(ir*ipow+r*bpow, ig*ipow+g*bpow, ib*ipow+b*bpow)
       putpicturepixel(x,y,dc)
        else putpicturepixel(x,y,ic)
     end
   end

  if DFILL == 0 then
   if ic == FC then
    putpicturepixel(x,y,bc)
     else putpicturepixel(x,y,ic)
   end
  end
  
 end -- nobg

 end
 if y%8 == 0 then
  updatescreen(); if (waitbreak(0)==1) then return; end
 end
 --if db.donemeter(4,y,w,h,true) then return; end -- Can leave artifacts
end

end -- ok
