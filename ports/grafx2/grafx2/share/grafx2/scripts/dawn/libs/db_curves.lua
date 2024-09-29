---------------------------------------------------
---------------------------------------------------
--
--                Curve Library
--              
--                    V1.0
-- 
--               Prefix: curve_.
--
--        by Richard 'DawnBringer' Fhager
--                                   
--        Email: dawnbringer@hem.utfors.se
--               dawnbringer@bahnhof.se
--
---------------------------------------------------
---------------------------------------------------

-- Abstract:
--  A set of 1-Dimensional Curves (Interpolations, Transitions)
--  With an additional control-function to further tweak & transform a curve.

---------------------------------------------------
 
-- Input & Output: Fractional value 0..1

-- Ex: Convert a linear transition to a cosine version

---------------------------------------------------



curve_ = {}



--
function curve_.sgn(v)
  if v > 0 then return 1; end
  if v < 0 then return -1; end
  return 0 
end
--

--
-- Control the offset & scale/extention of a curve 
-- (f.ex making a cosine-interpolation sharper, which could be used to make 
--  a horisontal image transition occur over a shorter stretch (centered in the middle or elsewhere))
--
--  Arguments in () are optional:
--         xf: Fractional position 0..1 on curve (when applied to an alpha channel, xf here would be the resulting alpha-value, not the image x-coord)
-- curve_func: Curve function, ex. curve_.Cosine
--      scale: Size of curve extention <= 1.0, 1 is nominal (full size). scale=0.5 would make the curve half as long (transition twice as "sharp").
--             With [noadjust] active it's also possible to use scale-UP, that is +1 arguments (i.e. zoom in on curve). 
--             Ex. scale=2 would make a linear gradient return values from 0.25 to 0.75 rather than 0 to 1.  
--   (offset): Offset the center of the curve, -0.5 to +0.5 (set to 0 for the curve to remain centered)
-- (noadjust): By default, the [scale] will be auto-adjusted (shrunk) if [offset] makes it overflow the 0/1 limits.
--             Inactive (0) by default, set to 1 to deactivate autoadjust.
--   (invert): Inverts the curve (i.e rotate 180).
--             Ex: Linear & Cosine is unaffected (if not using offset/scale which breaks their symmetry), Bell curves become negative, 
--                 An exponential curve (flat start, steep end) will get properites reversed (steep start, flat end)
--
function curve_.Control(xf, curve_func, scale,  offset, noadjust, invert_flag)

 local wo,o

 if invert_flag then xf = 1 - xf; end

   offset = offset or 0
 noadjust = noadjust or 0

 o = 0.5 + offset

 wo = scale
 if noadjust == 0 then
  wo = math.max(0,math.min(wo/2, 1-o, o)) * 2
 end

 if invert_flag then
  if xf <= (o - wo/2) then return 1 - curve_func(0); end
  if xf >= (o + wo/2) then return 1 - curve_func(1); end
   else
   if xf <= (o - wo/2) then return curve_func(0); end
   if xf >= (o + wo/2) then return curve_func(1); end
 end

 if invert_flag then
  return 1 - curve_func((xf - (o - wo/2)) / wo)
  else
   return curve_func((xf - (o - wo/2)) / wo)     -- 1 / wo -- scale of curve segment
 end

end
--


-------------------------------------------------------------------------------------
-- Standard Curves: Centerline symmetry (Right half = Left side rotated 180 degrees)
-- values Starting at 0, Middle of 0.5 and Ending with 1 
-------------------------------------------------------------------------------------

-- Linear / (Returns input value)
function curve_.Linear(xf)
 return xf
end
--

 -- S-Curves (Flat start, Steep middle, Flat end)

-- Cosine _/~ (S-curve)
function curve_.Cosine(xf)
 return 0.5 - math.cos(xf * math.pi) * 0.5
end
--

-- CosineSoft _/~ (S-curve) Linear/Cosine Intermediate (Less sharp than cosine)
function curve_.CosineSoft(xf)
 return xf*0.5 + (1-0.5) * (0.5 - math.cos(xf * math.pi) * 0.5)
end
--

-- Ken Perlin's Polynomial _/~ (Simlar to, but slightly sharper than Cosine)
function curve_.Ken(xf)
 return xf^3 * (xf*(6*xf - 15) + 10)
end
--

----------------------------------------

-- Logistic S-Curves. 
--  Higher multiples means sharper (closer to staircase). 
--  !!!Note that these never fully reach 0 or 1!!!. x13 is the smallest multiple that will reach 0-255 for an alpha-channel with +0.5 rounding

-- Logistic x13 _/~ (S-curve), Quite a bit sharper than Ken/Cosine
function curve_.Logistic13(xf)
 return 1/(1+math.exp(1)^((0.5-xf)*13))
end
--

-- Logistic x16 _/~ (S-curve)
function curve_.Logistic16(xf)
 return 1/(1+math.exp(1)^((0.5-xf)*16))
end
--

-- Logistic x20 _|~ (S-curve), Very Sharp (Full transition takes place over about middle 60%)
function curve_.Logistic20(xf)
 return 1/(1+math.exp(1)^((0.5-xf)*20))
end
--

-- Logistic x50 _|~ (S-curve), Super Sharp (Full transition takes place over middle 25%)
function curve_.Logistic50(xf)
 return 1/(1+math.exp(1)^((0.5-xf)*50))
end
--

----------------------------------------

 -- Inverted S-Curves (Steep start, Wide middle, Steep end)
 -- Think of some naming conventions here...

-- x^2 Squared (Wide middle)
function curve_.Squared(xf)
 return 0.5 + curve_.sgn(xf-0.5) * 2 * (xf-0.5)^2
end
--

-- x^4 Quad (Very wide middle)
function curve_.Quad(xf)
 return 0.5 + curve_.sgn(xf-0.5) * 8 * (xf-0.5)^4
end
--




-------------------------------------------------------------------------------------
-- Gradient Curves: No centerline symmetry
-- values Starting at 0 and Ending with 1 (Middle might not be 0.5) 
-------------------------------------------------------------------------------------

-- ) Circle _/ (Concave, Flat start - Steep end)
function curve_.Circle(xf)
 return 1 - (1-xf*xf)^0.5
end
--

-- ( Circle /~ (Convex, Steep start - Flat end)
function curve_.CircleConvex(xf)
 return (2*xf - xf*xf)^0.5
end
--

-- Cosinus Squared __/'
function curve_.CosineSquared(xf)
 return 0.5 - math.cos(xf*xf * math.pi) * 0.5
end
--

-- x^2
function curve_.Power2(xf)
 return xf^2
end
--

-- x^3
function curve_.Power3(xf)
 return xf^3
end
--

-- x^4
function curve_.Power4(xf)
 return xf^4
end
--


-------------------------------------------------------------------------------------
-- Parabolic Curves:
-- values Starting at 0, Middle of 1 and Ending with 0 
-------------------------------------------------------------------------------------

-- BellCosine /\ (Bell-curve)
function curve_.BellCosine(xf)
 return 1 - math.cos(xf * math.pi)^2
end
--






---------------------------
-- TESTING & DIAGNOSTICS --
---------------------------

-- Testing Control function
function curve_.TestControl(curve_func, scale,  offset, noadjust)
 local x,y,v,c,w,h,xf,yf
 w,h = getpicturesize()
  for x = 0, w-1, 1 do
   xf = x / (w-1)
   v = 0.5 + curve_.Control(xf, curve_func, scale,  offset, noadjust) * 255 -- NOTE: +0.5 for proper internal rounding
   c = matchcolor(v,v,v)
   for y = 0, h-1, 1 do
    putpicturepixel(x,y,c)
   end -- y
  if x%8 == 0 then updatescreen(); if (waitbreak(0)==1) then return; end; end
 end -- x
end
--

-- Simple Plot Test
function curve_.Plot(curve_func)
 local w,h,ox,oy,c
 c = matchcolor(255,255,255)
 w,h = 100,100
 ox,oy = 1,1
 for x = 0, w-1, 1 do
  putpicturepixel(ox+x,oy+h- math.floor(0.5+curve_func(x/(w-1))*(h-1)) ,c) -- yes (h-1), coz 0 to (h-1) 
 end
end
--


