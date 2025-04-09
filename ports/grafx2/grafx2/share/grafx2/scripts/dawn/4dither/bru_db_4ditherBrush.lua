--BRUSH: 4-Dither System 
--Make Dither Best Matching RGB-Value
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_4dither.lua")

 FC = getforecolor()
 BC = getbackcolor()

 gam = 1.3 
 rgm = 1 / gam
 r1,g1,b1 = getcolor(FC)
 r2,g2,b2 = getcolor(BC)

 -- Slightly Gamma-corrected average of the Pen-colors as inital RGB-selection
 r = (0.5*r1^gam + 0.5*r2^gam)^rgm
 g = (0.5*g1^gam + 0.5*g2^gam)^rgm
 b = (0.5*b1^gam + 0.5*b2^gam)^rgm


LIMIT         = 32 -- Max # of colors in palette
Size          = 32
Gamma         = 2.2 -- Dynamic Gamma
Briweight     = 0.25 
Dither_Factor = 0.025 -- 0 = Best Colormatch only, any Dither goes. 
Two_Flag      = false -- Only 2-dithers

roughness = (1-Dither_Factor) * 100

if FC==BC then
 EXt = "Exclude PenColor (#"..FC..")"
  else
 EXt = "Exclude PenCols (#"..BC.."/"..FC..")"
end

OK,r,g,b,Strip_Pen,Size,roughness,dynagam,two_only = inputbox("4-Dither Brush",
                                   
          "R (midpoint: preset is..)",  r,  0,255,0,
          "G (..gamma-corrected..)",    g,  0,255,0,
          "B (..pencolors average)",    b,  0,255,0, 
          EXt,  0,0,1,0,
          "Size: 2-256",    Size,  2,256,0,
          "Roughness Tolerance %",  roughness,  0,100,2,
          "Dynamic Gamma",       1,0,1,0,
          "2 Col Dithers Only",  0,0,1,0
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
  d4_.make4DitherBrush(Size,Size,r,g,b,Pal,Gamma,Dither_Factor,Briweight,Two_Flag)
   else messagebox("Too Many Colors in Palette!","Max number of Colors: "..LIMIT)
 end

end
--