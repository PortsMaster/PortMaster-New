
dofile("../pfunctions/pfunc_Lsystem.lua")()

--[[
dofile("../pfunctions/pfunc_AlphaCurve.lua")(
{ -- Data object, default values:

     alpha_func = alpha_.Horizontal,
             xf = 0, -- Coords for custom applications (not using the render-mode)
             yf = 0,
     xflip_flag = true,
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
    render_flag = true  -- Render the entire Alpha-channel to the current image (rather than returing a single value for xf,yf)
 }

)
--]]