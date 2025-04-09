--BRUSH: 4-Dither System - Create Gradient Dithers
--(with custom # of steps between two colors) 
--by Richard 'DawnBringer' Fhager


dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_4dither.lua")

 FC = getforecolor()
 BC = getbackcolor()

LIMIT         = 64 -- Max # of colors in palette
Size          = 32
Gamma         = 2.2 -- Mixcolor gamma
Briweight     = 0.25 
Dither_Factor = 0.025 -- 0.025, 0 = Best Colormatch only, any Dither goes. 
Two_Flag      = false -- Only 2-dithers

Steps         = 10
GradientGamma = 1.0 -- 1.5 is good for saturated colors, 1.0 (linear) or even less (more dark colors) is good for grayscales 

roughness = (1-Dither_Factor) * 100

OK,dummy,Steps,GradientGamma,Strip_Pen,Size,roughness,dynagam,two_only = inputbox("4-Dither Gradient (Brush)",
          "- Makes a Gradient between PenCols -",    0,0,0,4,          
          "Gradient Steps: 3-32",  Steps,  3,32,0,
          "Gradient Gamma: 0.5-3.0",  GradientGamma,  0.5,3.0,2,

          "Exclude PenColors",                  0,0,1,0,
          "Size: 2-256",    Size,               2,256,0,
          "Roughness Tolerance %",  roughness,  0,100,2,
          "Dynamic Gamma (MixColors)",          1,0,1,0,
          "2 Col Dithers Only",                 0,0,1,0
);


--
if OK then

 if dynagam == 1 then Gamma = -Gamma; end

 if two_only == 1 then Two_Flag = true; end
 Dither_Factor = 1-(roughness * 0.01)
 Pal = db.fixPalette(db.makePalList(256),1) -- Sorted Bright to Dark
 if Strip_Pen == 1 then
  Pal = db.stripIndexFromPalList(Pal,FC)
  Pal = db.stripIndexFromPalList(Pal,BC)
 end

 if #Pal <= LIMIT then

   mixpal = d4_.makeRatedMixpal(Pal,Gamma,Two_Flag,false) --  {r,g,b, v1,v2,v3,v4, rating}

   setbrushsize(Size*Steps,Size)

   gam = GradientGamma
   rgm = 1 / gam
   r1,g1,b1 = getcolor(FC)
   r2,g2,b2 = getcolor(BC)

   for n = 0, Steps-1, 1 do

     statusmessage("Step: "..(n+1).."/"..Steps); waitbreak(0)

     f2 = 1 / (Steps-1) * n
     f1 = 1 - f2

     r = (f1*r1^gam + f2*r2^gam)^rgm -- Ok, it's redundant to repeatedly do the color exponents..but this takes very little time compared to the 4-dither stuff
     g = (f1*g1^gam + f2*g2^gam)^rgm
     b = (f1*b1^gam + f2*b2^gam)^rgm


     -- Returns match = {best combo,bestscore}
     combo = d4_.scoreMatchDithers(mixpal, {{r,g,b,-1}}, Dither_Factor, Briweight)[1][1] -- scores = {mixpal index,score}
     d4_.put4Dither(Size,Size,n*Size,0,mixpal,combo,putbrushpixel) -- draw the dither, match is best combo (mixpal index)
  
   end

   --d4_.make4DitherBrush(Size,Size,r,g,b,Pal,Gamma,Dither_Factor,Briweight,Two_Flag)

   else messagebox("Too Many Colors in Palette!","Max number of Colors: "..LIMIT)
 end

end
--