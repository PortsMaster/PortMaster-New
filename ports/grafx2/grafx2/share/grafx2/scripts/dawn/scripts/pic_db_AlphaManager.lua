--PICTURE: #Alpha Manager V1.2
--Design Alpha-channels / Gradients
--by Richard 'DawnBringer' Fhager

--dofile("../libs/db_alpha.lua")
--dofile("../libs/db_curves.lua")
pfunc = dofile("../pfunctions/pfunc_AlphaCurve.lua") -- Also loads the alpha & curve libraries

alpha_maps = {
 list = {{"Horizontal",     alpha_.Horizontal},
         {"Vertical",       alpha_.Vertical},
         {"Diagonal",       alpha_.Diagonal},
         {"Cosine X",       alpha_.Cosine_X},
         {"CylinderSphere", alpha_.Cylinder_Sphere_X},
         {"Radial",         alpha_.Radial}, 
         {"Sphere",         alpha_.Sphere},
         {"Torus",          alpha_.Torus},
         {"Pillow",         alpha_.Pillow},  
         {"Diamond",        alpha_.Diamond}, 
         {"Pillow Corner",  alpha_.PillowCorner},
         {"Sinus Curve",    alpha_.SinusCurve}, 
         {"Sinus Rings",    alpha_.SinusRings}, 
         {"Water",          alpha_.Alpha1}
        },
 title = "Set Alpha Map",
 selected = 1,
 menu = (function()menu(alpha_maps);end)
}


alpha_modes = { --           X-flip Y-Flip Invert Rot90
 list = {{"Normal",         {false, false, false, false}},
         {"X-Flip",         {true,  false, false, false}},
         {"Y-Flip",         {false, true,  false, false}},
         {"X&Y Flip",       {true,  true,  false, false}},
         {"Inverted",       {false, false, true,  false}},
         {"Rotated 90",     {false, false, false, true}},
         {"Invert + Rot90", {false, false, true,  true}}
        },
 title = "Alpha Settings",
 selected = 1,
 menu = (function()menu(alpha_modes);end)
}


curve = {
 list = {{"Linear",           curve_.Linear}, 
         {"Cosine",           curve_.Cosine},
         {"Exponent 2",       curve_.Power2},
         {"Circle (Convex)",  curve_.CircleConvex},
         {"Bell",             curve_.BellCosine}
        },
 title = "Set Curve",
 selected = 1,
 menu = (function()menu(curve);end)
}

curve_settings = {
 scale    = 1.0,    -- 0.1 to 1.0, +1 if No Adjust
 offset   = 0.0,    -- -0.5 to 0.5
 noadjust = 0,      -- 0/1 Disable autoadjust (scale is adjusted if offset makes curve-ends(0&1) cross edges)
 invert   = false,  -- rotate curve 180
 menu = curve_settings_menu
}

--
function curve_settings_menu()
 local ok,dummy,scl,ofs,adj,inv
 inv = 0; if curve_settings.invert then inv = 1; end
 ok, dummy, scl, ofs, adj, inv = inputbox("Curve Settings",
  "(Def: scl=1, ofs=0, adj:Off, inv:Off)",0,0,0,4,                                
  "Scale: (0..1, NoAdj +1)", curve_settings.scale, 0.1,10,2, 
  "Offset: (-0.5 to 0.5)", curve_settings.offset, -0.5,0.5,2, 
  "No Adjust (Enables Zoom)", curve_settings.noadjust,  0,1,0,
  "Invert Curve (Rotate 180)", inv,  0,1,0                                                                                                     
 );
 if ok then 
  curve_settings.scale    = scl
  curve_settings.offset   = ofs
  curve_settings.noadjust = adj
  curve_settings.invert   = (inv==1)
 end
 --main()
end
--


final_settings = {
 negative_flag = false,
 swap_negative = function() final_settings.negative_flag = not final_settings.negative_flag; end -- main() removed
}


--[[
--
-- Create a SelectBox menu from an object
-- ex: o = {list = {"Item1", "Item2"}, selected = 1}
--
function menu(o)
 local n,args,i
 args,i = {},1
 for n = 1, #o.list, 1 do
  prefix = ""
  if o.selected == n then prefix = "*"; end
  args[i] = prefix..o.list[n]; i=i+1
  args[i] = (function() o.selected = n; end); i=i+1 --  o.selected = n; main() main removed
 end

 selectbox(o.title, unpack(args))

end
--
--]]

--
-- Create a SelectBox menu from an object
-- ex: o = {list = {{"Text1", func1}, {"Text2", func2}}, selected = 1}
--
function menu(o, ofs, maxlen)
 local n,args,i,len
 ofs = ofs or 0
 maxlen = maxlen or 7 
 maxlen = math.min(8,maxlen) -- Capped at 8 for a max total of 10 buttons (8 + back + more)
 len = math.min(#o.list-ofs, maxlen)
 args,i = {},1
 for n = 1+ofs, len+ofs, 1 do
  prefix = ""
  if o.selected == n then prefix = "*"; end
  args[i] = prefix..o.list[n][1]; i=i+1
  args[i] = (function() o.selected = n; end); i=i+1 --  o.selected = n; main() main removed
 end

 if (#o.list-ofs) > maxlen then
  args[i] = "[More]"; i=i+1
  args[i] = (function() menu(o, maxlen+ofs); end); i=i+1
 end

 if ofs > 0 then
  args[i] = "[Back]"; i=i+1
  args[i] = (function() menu(o, ofs-maxlen); end); i=i+1
 end

 selectbox(o.title, unpack(args))

end
--

--
function exekute()
 local o
 o = { 
     alpha_func = alpha_maps.list[alpha_maps.selected][2],
             xf = 0,
             yf = 0,
     xflip_flag = alpha_modes.list[alpha_modes.selected][2][1],
     yflip_flag = alpha_modes.list[alpha_modes.selected][2][2],
   ainvert_flag = alpha_modes.list[alpha_modes.selected][2][3], -- Invert Alpha (Note that this only affects the Alpha-channel and NOT the final result after Curves are applied)
    rotate_flag = alpha_modes.list[alpha_modes.selected][2][4],

     curve_func = curve.list[curve.selected][2], -- Transition curve, .Linear is default (doesn't change anything). Curve examples: .Linear, .Cosine, .Ken
          scale = curve_settings.scale,      -- Nominal = 1.0, Ex: 0.5 = Half-size/2x sharper, transition occurs over half the distance.
         offset = curve_settings.offset,     -- -0.5 to 0.5. Negative results in "more white", Positive "more black"
       noadjust = curve_settings.noadjust,   -- 1 = disable auto adjust (no locking the 0..1 range), upscaling/zooming possible (.scale can be >1)
   cinvert_flag = curve_settings.invert,

  negative_flag = final_settings.negative_flag, -- Invert FINAL RESULT (Render Only)
    render_flag = true  -- Render the entire Alpha-channel to the current image (rather than returing a single value for xf,yf)
 }

 pfunc(o)
 updatescreen(); waitbreak(0)
 --main()
end
--

--
function main()
  local cadj,cinv,swarn,final,do_selbox
  cadj,cinv,swarn = "","",""
  
  do_selbox = true
  while do_selbox do
   final = "Normal"; if final_settings.negative_flag then final = "Negative"; end
   if curve_settings.noadjust == 1 then cadj = "*"; end
   if curve_settings.invert then cinv = "(i) "; end
   if curve_settings.scale > 1 and curve_settings.noadjust == 0 then swarn = "(A!)"; end
   selectbox("# Alpha Channel Manager", 
    "ALPHA Map: "..alpha_maps.list[alpha_maps.selected][1],  alpha_maps.menu,
    "Alpha mode: "..alpha_modes.list[alpha_modes.selected][1],  alpha_modes.menu,
    "CURVE: "..curve.list[curve.selected][1],  curve.menu,
    "Curve set: "..cinv.."s="..curve_settings.scale..swarn..", o="..curve_settings.offset..cadj,  curve_settings_menu,
    "Final Result: "..final, final_settings.swap_negative,
    "RENDER ALPHA >>", exekute,
    "[DONE/QUIT]",function() do_selbox = false; end
   );
  end

end
--

main()