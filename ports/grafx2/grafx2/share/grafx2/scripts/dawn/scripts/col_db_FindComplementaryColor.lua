--PEN: Find Complementary PenColor 
--by Richard Fhager 

dofile("../libs/dawnbringer_lib.lua")


OK,normal,dummy,loose,strict = inputbox("Find Complimentary Color",
                     
        "1. Normal", 1,  0,1,-1,  
        "-- Preserve Brightness --",0,0,0,4,                       
        "2. Loose",  0,  0,1,-1,
        "3. Strict", 0,  0,1,-1
                                                                           
);


if OK == true then
 
 brikeeplev = 0
 if loose == 1 then brikeeplev = 1; end
 if strict == 1 then brikeeplev = 2; end
 c = getforecolor()
 r,g,b = getcolor(c)

 r,g,b = db.makeComplementaryColor(r,g,b,brikeeplev)

 setforecolor(matchcolor2(r,g,b))

end