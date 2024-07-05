--PICTURE: Gradient Remap from Pen-cols V1.1
--by Richard 'DawnBringer' Fhager


dofile("../libs/dawnbringer_lib.lua")


 FC = getforecolor()
 BC = getbackcolor()

 if FC < BC then FC,BC = BC,FC; end
 cols = math.abs(FC - BC) + 1

 -- Note: Gamma correction here does only regard the brightness of the source pixels and the size of the gradient,
 --       not the colorvalues of the gradient. 
 --       It's merely a method to counter the effect of rough dithers where the brighter color dominates.
 -- This gamma correction formula seems to work pretty well for grayscale ramps 2-6 colors (it's 1.1 from 7-11)
 gamma = 1.0 + math.floor(1 / (cols-1) * 10) / 10 -- Gamma 2.0 - 1.0, At 12 colors Gamma is down to 1.0
 
 OK,dummy1,dummy,NONE,O4,O16,O64,corr,gamma = inputbox("Ordered Gradient Remap",
                           "-- Remaps from Spare Image --",0,0,0,-2,
                           "-- Using PenCol Range      --",0,0,0,-2,
                           "1. No Dithering",      0,  0,1,-2,
                           "2. Ordered 4  (2x2)",  0,  0,1,-2,
                           "3. Ordered 16 (4x4)",  0,  0,1,-2,
                           "4. Ordered 64 (8x8)",  1,  0,1,-2,
                           "Gamma Correction *",    1,  0,1,0,
                           "* Gamma: 1.0-2.2",   gamma,1.0,2.2,3  
                                                                           
 );


--
if OK then

 w,h = getsparepicturesize()
 setpicturesize(w,h)

function nothing()
 return 0
end

if NONE== 1 then dithfunc = nothing; end
if O4  == 1 then dithfunc = db.dithOrder2x2_frac; end
if O16 == 1 then dithfunc = db.dithOrder4x4_frac; end
if O64 == 1 then dithfunc = db.dithOrder8x8_frac; end


if corr == 0 then gamma = 1.0; end

-- Span doubles as +1 for cols when no dither (as dither adds <1 thus -1))
-- dithfunc(-1,0) Returns the expansions value to stretch the gradient to include the last color (1/4, 1/16, 1/64), since A... B... C
span = 0.999999; if NONE ~= 1 then span = dithfunc(-1,0) - 0.000001; end
mult = ((cols-1) + span) / 255 

gam255 = 1 / (255^gamma / 255)

for y = 0, h-1, 1 do
 for x = 0, w-1, 1 do

  i = db.getBrightness(getsparecolor(getsparepicturepixel(x,y)))
 
  if gamma > 1.0 then
   i = i^gamma * gam255 -- With more shades the need for gammacorrection is greatly reduced
  end

  c = BC + i*mult + dithfunc(x,y)

  putpicturepixel(x,y,c)

 end
 if db.donemeter(16,y,w,h,true) then return; end
end 

end -- OK
--
