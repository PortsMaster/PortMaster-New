--PICTURE: #Alpha Channel Distortions
--by Richard Fhager 

-- NOTE: the check_Bounds() optimization that ignores areas outside the image doesn't work perfectly with some
--       violent distortions (ex: water/alpha1), it may result in less good looking AA in the image/bg transitions. 
--
-- NOTE: Bilinear on Upscaling does not directly apply to ZOOM, only Up-scaling regions in the Alpha will be affected 
--
-- NOTE: Depth Shading does not work properly with ZOOM (Shading is fixed on the "full-screen" Alpha.)

--messagebox(getbackuppixel(-0.5,1))

dofile("../libs/db_interpolation.lua") -- prefix: ip_
dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_alpha.lua")
--dofile("../libs/db_curves.lua")
--pfunc = dofile("../pfunctions/pfunc_AlphaCurve.lua")


--
function distortAlpha(s_o, a_o) -- s_o = settings object, a_o = alpha object

 bilinear_up = bilinear_up or 0

 local c,r,g,b,d,v,w,h,w1,h1,Cx,Cy,fx,fy,oyf,dt,dx,dy,ox,oy,t1,t2,pal,TC,DT
 local Lights, light_strength, Strength_Multiplier, strength, final_strength, final_lightstrength
 local dither_power2
 local INSIDE,OUTSIDE, Adjust_Exponent  
 local cos,floor,max,min,abs,log,ceil

 local f1,f2,fget
 local blurmap
 local lightMap, lightMapNatural, makeBlurMap, control, getAlphaValue, check_Bounds

 --local elastic, basic, bilinear, subpixel, posx,posy

 local str,Levels,light_power, dither_power, bilinear, gamma, ZOOM
 local alpha_func,xflip_flag, yflip_flag, invert_flag, rotate_flag, curve_func

--str,Levels,light_power,dither_power, a_o, bilinear_up, gamma

          str = s_o.strength 
       Levels = s_o.levels
  light_power = s_o.light_power 
 dither_power = s_o.dither_power
  bilinear_up = s_o.bilinear_up 
        gamma = s_o.gamma
         ZOOM = s_o.zoom

 alpha_func   = a_o.func
 xflip_flag   = a_o.xflip_flag
 yflip_flag   = a_o.yflip_flag
 invert_flag  = a_o.invert_flag
 rotate_flag  = a_o.rotate_flag
 curve_func   = a_o.curve_func
 
 Cx,Cy = 0.5, 0.5
 
 TC = gettranscolor()

 -- Depth Shading control (further info in the code below)
 Adjust_Exponent = 0.5 + db.getBrightness(getcolor(TC))/255 


 Strength_Multiplier = 2 -- (1 + 0.5*Strength_Multiplier), 2 means x0.5-x2, 6 means x0.25-x4 (at 100%)

  --elastic = 0
  --basic = 0
  --bilinear = 0
 --subpixel = 1

 gamma = gamma or 1.6

 dither_power2 = dither_power * 2 

 t1 = os.clock()

 cos,floor,max,min,abs,log,ceil = math.cos, math.floor, math.max, math.min, math.abs, math.log, math.ceil


 --
 function getAlphaValue(fx,fy)
   return alpha_.Control(alpha_func, fx,fy, xflip_flag, yflip_flag, invert_flag, rotate_flag, curve_func)
 end 
 --


 -- Change Brightness: Addition / Multiplication hybrid
 function lightMapHybrid(r,g,b, v, strength)
  local m,add
  add = (v-0.5) * strength
  m = 1
  if add > 0 then
   m = 1 + add/255
  end
  if add < 0 then
   m = 1 / (1 -add/255) -- add is negative so no div by 0
  end
  r = r*m + add*0.4
  g = g*m + add*0.4
  b = b*m + add*0.4
  return r,g,b
 end
 --




Lights = false
if light_power > 0 then
 Lights = true
 light_strength = light_power / 100 * 512 -- 512 is max (0.5 * 512 = 256)
  else light_strength = 0
end

strength = str / 100 -- 0..1, 0 is full effect

final_strength = strength * Strength_Multiplier

final_lightstrength = light_strength * max(Strength_Multiplier/100,final_strength) -- Allow lights without any distortions (strength = 0)


w, h = getpicturesize()
f1 = getbackuppixel
f2 = putpicturepixel
fget = getbackupcolor

w1,h1 = w-1,h-1


--
function control(ox,oy,w1,h1) -- ox,oy are fractions (xf,yf)

 local dx,dy,dt,d,q

 dx,dy = Cx-ox, Cy-oy

 --dt = getAlphaValue(max(0,ox),max(0,oy))  -- ox & oy may be <0 & >1 from the way ip_.fractionalSampling center things
 --dt = getAlphaValue(min(1,max(0,ox)),min(1,max(0,oy)))  
 dt = getAlphaValue(ox,oy)

 if dt >= 0.5 then -- Scale Up (gray to white)     
   d = ZOOM / (1 + (dt-0.5) * final_strength) -- "linear", working
    else -- Scale Down (black to gray)
     q = min(0.9999, (0.5-dt) * final_strength) -- min capping: there's  point when down-scaling stops, it can usually not be seen below 0.9
     d = ZOOM / (1 - q) -- Linear appearance
 end

 ox = Cx - dx * d -- d = 2 means scaling 50%
 oy = Cy - dy * d

 -- Tally pixels inside image to acquire a quota for how much effect Depth Shading should have on a given pixel
 -- This is really important for the AA-region between Image and Background
 dx = ceil(ox*w1-0.5) -- Note the re-using of "dx","dy"
 dy = ceil(oy*h1-0.5) -- 
 if dx>=0 and dx<=w1 and dy>=0 and dy<=h1 then
   INSIDE = INSIDE + 1
    else OUTSIDE = OUTSIDE + 1
 end

 -- Note: getpixels round positives down and negatives up -0.9 & 0.9 are both rounded to 0
 return getcolor(getbackuppixel(dx, dy))
 --return getcolor(getbackuppixel(ceil(ox*w1-0.5), ceil(oy*h1-0.5))); -- ceil -0.5 looks centered and right!?
 --return getcolor(getbackuppixel(ox*w1+0.5, oy*h1+0.5))

end
--

-- Is position within image (or out of bounds)
function check_Bounds(ox,oy, m) -- m = margin (margin needed varies greatly depending on distortion, for water at 50%, 8 is not enough)

 local dx,dy,dt,d,q

 m = m or 0

 dx,dy = Cx-ox,  Cy-oy

 --dt = getAlphaValue(ox,oy) 

 if DT >= 0.5 then -- Scale Up (gray to white)     
   d = ZOOM / (1 + (DT-0.5) * final_strength) -- "linear", working
    else -- Scale Down (black to gray)
     q = min(0.9999, (0.5-DT) * final_strength) -- min capping: there's  point when down-scaling stops, it can usually not be seen below 0.9
     d = ZOOM / (1 - q) -- Linear appearance
 end

 ox = Cx - dx * d
 oy = Cy - dy * d

 dx = ox*w1
 dy = oy*h1

 if dx<0-m or dx>w1+m or dy<0-m or dy>h1+m then return false; end
 return true

end
--

for y = 0, h - 1, 1 do
  fy = y / h1
  dy = Cy-fy
  for x = 0, w - 1, 1 do
    fx = x / w1

    INSIDE,OUTSIDE = 0,0
    --INSIDE,OUTSIDE = 1,1

    DT = getAlphaValue(fx,fy)

    if check_Bounds(fx,fy,4) then -- Inside image? Add margin to allow for AA (sharp distortions (ex. "Water") may require much wider margin)

       if bilinear_up == 0 then -- Always subpixel
         -- SubPixel
         r,g,b = ip_.fractionalSampling(Levels, x,y, w1,h1, control, gamma)
       end      

       if bilinear_up == 1 then -- Use Bilinear when enlarging/upscaling
       
         if DT >= 0.5 then -- Scale Up (gray to white)
           INSIDE,OUTSIDE = 1,0
           d = ZOOM / (1 + (DT-0.5) * final_strength) -- "linear", working
           dx = Cx-fx
           ox = Cx - dx * d
           oy = Cy - dy * d
           r,g,b,pal = ip_.pixelRGB_Bilinear_PAL_gamma(ox*w1, oy*h1, fget,f1,ip_.linip,gamma) 
            else  r,g,b = ip_.fractionalSampling(Levels, x,y, w1,h1, control, gamma)
         end 
       end

          if Lights then 
            -- Adjust Exponent: Gradient 0.5 for Black to 1 for White.
            --  Bright areas AAing to black BG with Shading applied will get a bright rim
            --  because effect reduction is too great (allowing the original bright gradient to peak up)
            -- Ex: 50% Inside means x0.5, 0.5^0.5 = 0.71
            -- Now, this doesn't work great for Dark areas AAing to Bright BGs ("will lose the AA"), linear (1) is fine here.
            -- So the exponent is a gradient  depending on BG brightness: Black(0.5) to White(1.0)
            r,g,b = lightMapHybrid(r,g,b, DT, final_lightstrength * (INSIDE/(INSIDE+OUTSIDE))^Adjust_Exponent)
          end

          v = 0
          if dither_power > 0 then
           if check_Bounds(fx,fy,0) then -- Don't dither background
            v = -dither_power + db.dithOrder8x8_frac(x,y) * dither_power2
           end
          end  
  
          f2(x, y, matchcolor2(min(255,max(0,r+v)), min(255,max(0,g+v)), min(255,max(0,b+v))));
    
  else f2(x,y,TC) 
 end

  end

  if db.donemeter(10,y,w,h,true) then return; end

end

 t2 = os.clock()
 ts = (t2 - t1) 
 --messagebox("Seconds: "..ts)

 updatescreen(); waitbreak(0)

end 
-- distortAlpha








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
         {"Water",          alpha_.Alpha1},
         {"Plaid",          alpha_.Plaid}
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


--
-- Create a SelectBox menu from an object
-- ex: o = {list = {"Item1", "Item2"}, selected = 1}
--
function menuORG(o)
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


settings = {
    strength = 50,
      levels = 2,
 bilinear_up = 0, -- use bilinear scaling when enlarging (rather than always using sampling)
       gamma = 1.6,
 light_power = 50,
dither_power = 0,
        zoom = 1 -- 2 = 50%, 0.5 = 200%
}

--
function strength()
 local ok,dummy
 ok,settings.strength, dummy,  settings.zoom, dummy,dummy,dummy = inputbox("Distortion: Strength",
  "Strength %: 1-600",       settings.strength,  0,600,1,
  "", 0,0,0,4,
  "Zoom: (0.1-10)",  settings.zoom,      0.1,10,2,
  "<1.0 = Zoom In, >1.0 = Zoom Out", 0,0,0,4,
  "Not perfect /w Shading & Bilinear", 0,0,0,4,
  "Zoom scales image, NOT Alpha!", 0,0,0,4                                                                              
 );
end
--

--
function levels()
 local ok,dummy
 ok,settings.levels, settings.bilinear_up, settings.gamma,dummy, dummy, dummy = inputbox("Distortion: IP Quality",
   "IP Quality: (0-8)", settings.levels,  0,8,0,
   "Smooth UpScale (bilinear)",  settings.bilinear_up,  0,1,0,
   "Gamma: (1.0-2.2)", settings.gamma,  1,2.2,2,
   "---------------------------------",        0,  0,0,4,
   "Interpolation: Sampling Levels.",          0,  0,0,4,
   "More = Higher quality but slower.",        0,  0,0,4                                                                 
 );
end
--

--
function lightpower()
 local ok
 ok,settings.light_power = inputbox("Distortion: Depth Shading",
  "Depth Shading %: 0-999", settings.light_power,  0,1000,1                                                                    
 );
end
--

--
function ditherpower()
 local ok
 ok,settings.dither_power = inputbox("Distortion: Dither",
  "Dither Power: 0-16", settings.dither_power,  0,16,1                                                                   
 );
end
--

--
function launch()
 local alpha_o

  alpha_o = {
   func = alpha_maps.list[alpha_maps.selected][2],
   xflip_flag  = alpha_modes.list[alpha_modes.selected][2][1],
   yflip_flag  = alpha_modes.list[alpha_modes.selected][2][2],
   invert_flag = alpha_modes.list[alpha_modes.selected][2][3],
   rotate_flag = alpha_modes.list[alpha_modes.selected][2][4],
   curve_func  = null
 }

 distortAlpha(settings, alpha_o)
end
--

--
function restore()
 local x,y,w,h
 w,h = getpicturesize()
 for y = 0, h - 1, 1 do
  for x = 0, w - 1, 1 do
   putpicturepixel(x,y,getbackuppixel(x,y))
  end
 end
 updatescreen(); waitbreak(0)
end
--

--
function main()
  local do_selbox,ipbi,zom
  
  do_selbox = true
  while do_selbox do

   ipbi = ""; if settings.bilinear_up == 1 then ipbi = " *"; end
   zom = ""; if settings.zoom < 1 then zom = " (z+)"; end
             if settings.zoom > 1 then zom = " (z-)"; end

   selectbox("# Alpha Distortions", 
   
    "Strength: "..settings.strength.."%"..zom,  strength,
    "IP Quality: "..settings.levels.."/8"..ipbi,  levels,
    "Depth Shading: "..settings.light_power.."%",  lightpower,
    "Dither Power: "..settings.dither_power,  ditherpower,
    "ALPHA MAP: "..alpha_maps.list[alpha_maps.selected][1],  alpha_maps.menu,
    "Alpha Mode: "..alpha_modes.list[alpha_modes.selected][1],  alpha_modes.menu,
 
    "RENDER >>", launch,
    "RESTORE IMAGE >>", restore,
    "[DONE/QUIT]",function() do_selbox = false; end
   );
  end

end
--

main()







--[[
     fx = x / w1

     dt = getAlphaValue(fx,fy)

      if dt >= 0.5 then -- Scale Up (gray to white)     
        d = 1 / (1 + (dt-0.5) * final_strength) -- "linear", working
         else -- Scale Down (black to gray)
          d = 1 / (1 - min(1,(0.5-dt) * final_strength)) -- Linear appearance
      end

      dx = cx-fx

      ox = cx - dx * d
      oy = cy - dy * d
--]]

--[[

OK,str,Levels,light_power,dither_power = inputbox("Distortion Alpha",

                           "Strength %: 1-600",       50,  0,600,1,
                          
                           "IP Quality: (0-8)",        2,  0,8,0,

                           "Depth Shading %: 0-1000", 50,  0,1000,1,

                           "Dither Power: 0-16",       0,  0,16,1

                          
                                                                      
 );

if OK then
 alpha_func = alpha_.Alpha1 -- looks best with low strength, about x0.1
 --alpha_func = alpha_.Horizontal
 --alpha_func = alpha_.Vertical
 --alpha_func = alpha_.Radial
 --alpha_func = alpha_.Sphere
 --alpha_func = alpha_.Diagonal

 o = {
         func = alpha_func,
  xflip_flag  = false,
  yflip_flag  = false,
  invert_flag = false,
  rotate_flag = false,
  curve_func  = null
 }
 distortAlpha(str,Levels,light_power,dither_power, o)
end

--]]











--if cubic == 1 then
-- r,g,b = ip_.pixelRGB_Bicubic(posx,posy,fget,f1,ip_.cubip)
-- c = matchcolor2(r,g,b) 
--end

--OK,str,basic,bilinear,subpixel,Levels,gamma,lightpower,elastic = inputbox("Distortion Alpha",
--"# Gamma",             1.6,  0.1,5.0,3,
-- "Elastic Edges over Void", elastic,  0,1,0

--[[
  elastic = 0 -- "elastic" edges
  if elastic == 1 then
   ox = max(0,min(ox,1)); oy = max(0,min(oy,1)) -- "Elastic Edges"
  end

  --posx,posy = ox*w1, oy*h1

  if basic == 1 then
    c = f1(floor(posx + 0.5),floor(posy + 0.5))
    r,g,b = getcolor(c) 
 end

  if subpixel == 1 then
   --c = matchcolor2(ip_.fractionalSampling(Levels, x,y, w1,h1, control, gamma))
   r,g,b = ip_.fractionalSampling(Levels, x,y, w1,h1, control, gamma)
  end

if bilinear == 1 then
            if gamma <= 1.0 then
             -- No border protection by default in these interpolations
             -- Out of bounds means Transparancy color is used (by system)
             r,g,b = ip_.pixelRGB_Bilinear(posx,posy,fget,f1,ip_.kenip) -- px,py, col_func, get_func, ip_func
             else
              --r,g,b,pal = ip_.pixelRGB_Bilinear_PAL_gamma(posx,posy,fget,f1,ip_.kenip,gamma) -- px,py, col_func, get_func, ip_func
              r,g,b,pal = ip_.pixelRGB_Bilinear_PAL_gamma(posx,posy,fget,f1,ip_.linip,gamma)   
           end
          end
--]]




