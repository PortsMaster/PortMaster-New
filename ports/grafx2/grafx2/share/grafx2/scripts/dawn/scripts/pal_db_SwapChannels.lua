--PALETTE: Swap Color Channels
--by Richard Fhager 

dofile("../libs/dawnbringer_lib.lua")

OK,grb,bgr,rbg,gbr,brg,amt,gamma,brikeep = inputbox("Swap Color Channels",
                        
                           "1. G-R-b (red & grn)",   1,  0,1,-1,
                           "2. B-g-R (red & blu)",   0,  0,1,-1,
                           "3. r-B-G (grn & blu)",   0,  0,1,-1, 
                           "4. G-B-R (swap all)",     0,  0,1,-1, -- Same as Hue shift +120 degrees
                           "5. B-R-G (swap all)",     0,  0,1,-1, -- Same as Hue shift -120 degrees
                           "AMOUNT %: 0-100*", 100,  0,100,0,
                           "*Gamma adjustment",      1,0,1,0,
                           "Preserve Brightness",    1,0,1,0
                           --"Gamma Exponent", 2.2,   1.0,2.2,2                                            
);



if OK == true then

 for c = 0, 255, 1 do
 
   r,g,b = getcolor(c)

   bri_o = db.getBrightness(r,g,b)
  

   if amt == 100 then
    if grb == 1 then r,g,b = g,r,b; end
    if bgr == 1 then r,g,b = b,g,r; end
    if rbg == 1 then r,g,b = r,b,g; end
    if gbr == 1 then r,g,b = g,b,r; end 
    if brg == 1 then r,g,b = b,r,g; end
   end 

   if amt < 100 then
    ex = 1.0
    if gamma == 1 then ex = 2.0; end
    er = 1 / ex
    a = amt / 100
    o = 1 - a
    rx = r^ex 
    gx = g^ex 
    bx = b^ex   
    if grb == 1 then r,g,b = (rx*o+gx*a)^er, (gx*o+rx*a)^er, (bx*o+bx*a)^er; end
    if bgr == 1 then r,g,b = (rx*o+bx*a)^er, (gx*o+gx*a)^er, (bx*o+rx*a)^er; end
    if rbg == 1 then r,g,b = (rx*o+rx*a)^er, (gx*o+bx*a)^er, (bx*o+gx*a)^er; end
    if gbr == 1 then r,g,b = (rx*o+gx*a)^er, (gx*o+bx*a)^er, (bx*o+rx*a)^er; end
    if brg == 1 then r,g,b = (rx*o+bx*a)^er, (gx*o+rx*a)^er, (bx*o+gx*a)^er; end
   end 

  if brikeep == 1 then
   for n = 0, 29, 1 do -- Must iterate to reduce brightness error
    bri_n = db.getBrightness(r,g,b)
    bdiff = (bri_o - bri_n) * 0.5 -- Do we ever gain better quality with smaller increments?
    r = db.cap(r + bdiff)
    g = db.cap(g + bdiff)
    b = db.cap(b + bdiff)
   end
  end


   setcolor(c, r,g,b)

 end

end