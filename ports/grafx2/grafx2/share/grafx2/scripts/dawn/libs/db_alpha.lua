---------------------------------------------------
---------------------------------------------------
--
--                Alpha Library
--              
--                    V1.0
-- 
--                Prefix: alpha_.
--
--        by Richard 'DawnBringer' Fhager
--                                   
--        Email: dawnbringer@hem.utfors.se
--               dawnbringer@bahnhof.se
--
---------------------------------------------------
---------------------------------------------------

-- Abstract:
--  A set of 2-dimensional Alpha-channels (transition functions).
--  For use as: Curves, Gradients, Interpolations or Distortion Maps etc.

---------------------------------------------------

--  Input: fractional x,y coords (0..1)
-- Output: fractional value (0..1). Multiply with 255 for grayscale value.
--  0 = Nothing, Black color 
--  1 = Full Strength, White color

-- !!!NOTE!!!: Add 0.5 to the resulting value before colormatching etc. 
-- to balance the internal rounding and get an even distribution.
-- Ex: ...v = 0.5 + alpha_function(xf,yf) * 255; putpicturepixel(x,y,matchcolor(v,v,v))...

-- For full (and easy) control use the pfunction pfunc_AlphaCurves.lua that 
-- adds curve-transitions to the Alpha-channels (and can imagerender)

---------------------------------------------------


alpha_ = {}


--
-- (curve_func): Curve/Transition function (optional), returns a new value between 0 and 1
--
function alpha_.Control(alpha_func, xf,yf, xflip_flag, yflip_flag, invert_flag, rotate_flag, curve_func)

 curve_func = curve_func or (function(v) return v; end)

 if rotate_flag then xf,yf = 1-yf,xf; end -- Rotate 90 degrees

 if xflip_flag then xf = 1 - xf; end
 if yflip_flag then yf = 1 - yf; end

 if invert_flag then 
   return curve_func(1 - alpha_func(xf,yf))
   else
     return curve_func(alpha_func(xf,yf))
 end

end
--

-- Horizontal Gradient, Left (0) --> Right (1)
function alpha_.Horizontal(xf,yf)
 return xf
end
--


-- Vertical Gradient, Top (0) --> Bottom (1)
function alpha_.Vertical(xf,yf)
 return yf
end
--


-- Diagonal, TopLeft (0) --> BottomRight (1) 
function alpha_.Diagonal(xf,yf)
 return (xf+yf)/2
end
--


-- Radial, Center (1) ---> Out (0)
function alpha_.Radial(xf,yf)
 return 1 - math.min(1,2 * ((xf-0.5)*(xf-0.5) + (yf-0.5)*(yf-0.5))^0.5)
end
--


-- Sphere, Center (1) ---> Out (0)
function alpha_.Sphere(xf,yf)
 return math.max(0,0.25 - ((xf-0.5)*(xf-0.5) + (yf-0.5)*(yf-0.5)))^0.5 * 2 
end
--

-- Sphere/Radial Intermediate, Center (1) ---> Out (0), Same as (Sphere())^2
function alpha_.SphereSoft(xf,yf)
 return math.max(0,0.25 - ((xf-0.5)*(xf-0.5) + (yf-0.5)*(yf-0.5))) * 4 
end
--

-- Vertical (Standing) Cylinder (Sphere X-axis) (0)-->(1)-->(0)
function alpha_.Cylinder_Sphere_X(xf,yf)
  return math.max(0,0.25 - ((xf-0.5)*(xf-0.5)))^0.5 * 2
end
--

-- Cosine Horizontal (Vertical (Standing) "Cylinder"),  (0)-->(1)-->(0)
function alpha_.Cosine_X(xf,yf)
 return 0.5 - math.cos(xf * math.pi * 2) * 0.5
end
--

     
-- Pillow Corner, TopLeft (0) --> BottomRight (1) 
function alpha_.PillowCorner(xf,yf)
 return (xf*yf)^0.5
end
--

-- Radial Corner, TopLeft (0) --> BottomRight (1) 
function alpha_.RadialCorner(xf,yf)
 return ((xf*xf+yf*yf)/2)^0.5
end
--

-- Diamond, Center (1) --> Out (0)
function alpha_.Diamond(xf,yf)
 --return math.max(math.abs(0.5 - xf), math.abs(0.5 - yf)) * 2 -- "Pyramid"
 return 1 - (math.abs(0.5 - xf) +  math.abs(0.5 - yf))
end
--


-- Pillow ("SinusSquareBall"), Center (1) --> Out (0)
function alpha_.Pillow(xf,yf)
 return math.sin(xf*math.pi)*math.sin(yf*math.pi) -- note: Always positive
end
--

-- Torus, Center (0) --> (1) -->Out (0)
function alpha_.Torus(xf,yf)
 return math.max(0,math.sin(((xf-0.5)*(xf-0.5) + (yf-0.5)*(yf-0.5)) * 12.56637061)) -- pi*4
end
--

-------------------------------------------------------------------------------------
-- Structured Alpha-channels (non gradient, but still ordered)
-------------------------------------------------------------------------------------

-- SinusRings, Center (0) --> (1) --> (0) --> (1)... (Same formula as Inverted Torus)
function alpha_.SinusRings(xf,yf, mult)
 mult = mult or 64
 return 1 - math.max(0,0.5 + 0.5*math.sin(((xf-0.5)*(xf-0.5) + (yf-0.5)*(yf-0.5)) * 12.56637061 * 16)) -- pi*4
end
--

--
function alpha_.SinusCurve(xf,yf)
 return math.abs((yf-0.5)*2 + math.sin(xf*math.pi*2)) * 0.5
end
--

-- Modulus Plaid
function alpha_.Plaid(xf,yf)
 return (math.floor(xf*9)%2 + math.floor(yf*9)%2) * 0.5
end
--

-- 
function alpha_.test(xf,yf)
 --return 1 - math.min(1,2 * ((xf-0.5)*(xf-0.5))^0.5) -- radial x
 return (1-(0.5-xf)*(0.5-xf)*4)^0.5 -- cylinder
 --return math.max(0,0.25 - ((xf-0.5)*(xf-0.5)))^0.5 * 2  -- same as above
end
--


-------------------------------------------------------------------------------------
-- Complex Alpha-channels (Scenes)
-------------------------------------------------------------------------------------

--
function alpha_.Alpha1(xf,yf,amp) -- To decrease amplitude (soften, >0to<1) use pfunction with with noadjust=1 and scale +1
 local p,a,xh,yh,m
 amp = amp or 1
 xh=0.5-xf; yh=0.5-yf; m = math
 p = m.pow(xh*xh+yh*yh,0.7);
 a = m.cos(32*m.pi*p)*m.sin(8*m.pi*(xh+yh));
 return 0.5 + (a * amp) * 0.5
end
--





----------------------------------------------



--
-- Test Control function, Renders the alpha channel
--
function alpha_.testControl(alpha_func, xflip_flag, yflip_flag, invert_flag, rotate_flag, curve_func)
 local x,y,v,w,h,xf,yf
 w,h = getpicturesize()
 for y = 0, h-1, 1 do
  yf = y / (h-1)
  for x = 0, w-1, 1 do
   xf = x / (w-1)
   v = 0.5 + alpha_.Control(alpha_func, xf,yf, xflip_flag, yflip_flag, invert_flag, rotate_flag, curve_func) * 255 -- NOTE: +0.5 for proper internal rounding
   putpicturepixel(x,y,matchcolor(v,v,v))
  end
  if y%8 == 0 then updatescreen(); if (waitbreak(0)==1) then return; end; end
 end
end
--




--[[

-- Horizontal Gradient, Right (0) --> Left (1)
function alpha_.Horizontal_RL(xf,yf)
 return 1-xf
end
--

-- Diagonal, BottomLeft (0) --> TopRight (1) 
function alpha_.Diagonal_BL(xf,yf)
 return (xf+(1-yf))/2
end
--

--
function alpha_.testAlpha(channel, xinv_flag, yinv_flag)
 local x,y,v,w,h,xf,yf
 w,h = getpicturesize()
 for y = 0, h-1, 1 do
  if yinv_flag then yf = 1 - y / (h-1) else yf = y / (h-1); end
  for x = 0, w-1, 1 do
   if xinv_flag then xf = 1 - x / (w-1) else xf = x / (w-1); end
   v = channel(xf,yf) * 255
   putpicturepixel(x,y,matchcolor(v,v,v))
  end
  if y%8 == 0 then updatescreen(); if (waitbreak(0)==1) then return; end; end
 end
end
--

--]]