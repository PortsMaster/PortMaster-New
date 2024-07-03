--PICTURE: Shift RGB (Bleeding)
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")

  w,h = getpicturesize()


rshift = 3
gshift = 0
bshift = 0


OK,rshift,gshift,bshift = inputbox("Shift RGB (Bleeding)",
 
     "  Red H-Shift (pixels)", rshift,  -8,8,0, 
     "Green H-Shift (pixels)", gshift,  -8,8,0,  
     " Blue H-Shift (pixels)", bshift,  -8,8,0   
   
     --"1. Threshold Split BG/FG",        1,  0,1,-1,
     --"2. Gradient Map BG->FG #",     0,  0,1,-1,
     --"# Gradient Exponent", 1,  0.1,20,2, 
     --"AMOUNT %", 100,  0,100,0,                 
      
                          
);



for y = 0, h - 1, 1 do
 for x = 0, w - 1, 1 do
   r1,dum,dum = getcolor(getbackuppixel(x-rshift,y))
   dum,g1,dum = getcolor(getbackuppixel(x-gshift,y))
   dum,dum,b1 = getcolor(getbackuppixel(x-bshift,y))

   c = matchcolor2(r1,g1,b1)  
   putpicturepixel(x, y, c);
 end
 if db.donemeter(8,y,w,h,true) then return; end
 --updatescreen();if (waitbreak(0)==1) then return end
end
