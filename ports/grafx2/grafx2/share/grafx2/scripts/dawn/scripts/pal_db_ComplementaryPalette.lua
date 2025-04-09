--PALETTE: Make Complementary Palette V2.0
--by Richard Fhager 

dofile("../libs/dawnbringer_lib.lua")


FC = getforecolor()

OK,normal,dummy1,loose,strict,dummy2,gamma,invrgb,penonly   = inputbox("Make Complementary Palette",
                     
        "1. Normal", 1,  0,1,-1,     
        "-- Preserve Brightness --",0,0,0,-2,            
        "2. Loose",  0,  0,1,-1,
        "3. Strict", 0,  0,1,-1,
        "-------------------------",0,0,0,-2,
        "4. Neutralizer (GammaMix)",0,  0,1,-1,
        "5. 'Inverted RGB'",0,  0,1,-1,
        "Pen-Color only (#"..FC..")", 0, 0,1,0                                                                        
);


if OK == true then
 
 brikeeplev = 0
 if loose == 1 then brikeeplev = 1; end
 if strict == 1 then brikeeplev = 2; end
 if gamma == 1 then brikeeplev = 3; end

 for n = 0, 255, 1 do
  if penonly == 0 or n == FC then
   r,g,b = getcolor(n)
   if invrgb == 1 then
    r2 = (g+b)/2
    g2 = (r+b)/2
    b2 = (r+g)/2
     else
      r2,g2,b2 = db.makeComplementaryColor(r,g,b,brikeeplev)
   end
   setcolor(n,r2,g2,b2)
  end
 end

end