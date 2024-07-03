---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--  AlphaCurve V1.0
--
--  Program-Function (pfunction) - Dependencies: db_alpha.lua, db_curves.lua
--
--  by Richard 'DawnBringer' Fhager 2017  (dawnbringer@hem.utfors.se)
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--
-- A function providing direct control of Alpha-channels (Lib), 
-- whilst adding extra tweaking power through the application of Curves (Lib).
--
-- 
-- Usage:
-- dofile("../pfunctions/pfunc_AlphaCurve.lua")(data_object)
-- or
-- myfunc = dofile("../pfunctions/pfunc_AlphaCurve.lua"); myfunc(data_object)
--
--
-- Ex: Use alpha_.Radial + curve_.BellCosine to create a donut/torus shape
---------------------------------------------------------------------------------------



-- Note that libs are outside function to avoid being loaded at every call 
dofile("../libs/db_alpha.lua")  -- alpha_. 
dofile("../libs/db_curves.lua") -- curve_.


return function(o)
 
 o = o or { -- Data object, default values (Render-mode active):

     alpha_func = alpha_.Horizontal,
             xf = 0, -- Coords for custom applications (not using the render-mode)
             yf = 0,
     xflip_flag = false,
     yflip_flag = false,
   ainvert_flag = false, -- Invert Alpha (Note that this only affects the Alpha-channel and NOT the final result after Curves are applied)
    rotate_flag = false, -- Rotate 90 degrees

     curve_func = curve_.Linear, -- Transition curve, .Linear is default (doesn't change anything). Curve examples: .Linear, .Cosine, .Ken
          scale = 1.0,   -- Nominal = 1.0, Ex: 0.5 = Half-size/2x sharper, transition occurs over half the distance.
                         -- Using No Adjust and Scale +1 will "Zoom" into the curve.
         offset = 0.0,   -- -0.5 to 0.5. Negative results in "more white", Positive "more black"
       noadjust = 0,     -- 1 = disable auto adjust (no locking the 0..1 range), upscaling/zooming possible (.scale can be >1)
   cinvert_flag = false, -- Invert Curve (rotated 180), this affects the result after offset/scale.
                         -- Ex: A Basic cosinus curve is not affected (180degree symmetry), but an offset cosinus is.
                         --     Bell curves become negative. A Convex 1/4 circle curve will become Concave.
                         --     An exponential curve (flat start, steep end) will get properites reversed (steep start, flat end)

  negative_flag = false, -- Invert FINAL RESULT (Render Only)
    render_flag = true   -- Render the entire Alpha-channel to the current image (rather than returing a single value for xf,yf)
 }


 local v

 if o.render_flag then

   local x,y,w,h,xf,yf,q
   w,h = getpicturesize()
   for y = 0, h-1, 1 do
    yf = y / (h-1)
    for x = 0, w-1, 1 do
      xf = x / (w-1)
      v = alpha_.Control(o.alpha_func, xf,yf, o.xflip_flag, o.yflip_flag, o.ainvert_flag, o.rotate_flag)
      q = curve_.Control(v, o.curve_func, o.scale,  o.offset, o.noadjust, o.cinvert_flag)
      if o.negative_flag then q = 1 - q; end
      v = 0.5 + q * 255
      putpicturepixel(x,y,matchcolor(v,v,v))
    end
    if y%8 == 0 then updatescreen(); if (waitbreak(0)==1) then return; end; end
   end

  else -- For use in external loops that get the value for each point in the Alpha-channel
   v = alpha_.Control(o.alpha_func, o.xf,o.yf, o.xflip_flag, o.yflip_flag, o.ainvert_flag, o.rotate_flag)
   return curve_.Control(v, o.curve_func, o.scale,  o.offset, o.noadjust, o.cinvert_flag) -- returns a value 0..1 for xf,yf
 end

end; -- AlphaCurve

