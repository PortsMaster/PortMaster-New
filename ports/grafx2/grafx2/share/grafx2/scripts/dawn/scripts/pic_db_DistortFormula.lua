--PICTURE: #Radial Formula Distortions V1.0
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
--dofile("../libs/db_alpha.lua")
--dofile("../libs/db_curves.lua")
--pfunc = dofile("../pfunctions/pfunc_AlphaCurve.lua")



function main()

 -- Localzing formula_, sin & cos makes default render about 2% faster
 local sin,cos
 local main, launch, distortWaves, check_Bounds, randomizeParams, menu, boxer, strength, levels, freq_and_amp, params_abcd
 local formula_

 sin, cos = math.sin, math.cos 

formula_ = {}

--
function formula_.test(xf,yf, a,b,c,d, freq, amp)
 --return 0.5 + ((xf-0.5)*(xf-0.5)*a-(yf-0.5)*(yf-0.5)*b) * amp
 return 0.5 + xf*xf*a-yf*yf*b * amp
end 
--

--
function formula_.Rings(xf,yf, a,b,c,d, freq, amp)
 return 0.5 + 0.5 * sin(c + (xf*xf*a + yf*yf*b)*freq) * amp
end 
--

--
function formula_.Sin(xf,yf, a,b,c,d, freq, amp)
 return 0.5 + 0.5 * sin(c + (xf*a + yf*b)*freq) * amp
end 
--


--
function formula_.SinXCosY(xf,yf, a,b,c,d, freq, amp)
 return 0.5 + 0.5 * sin(c + xf*a*freq) * cos(d + yf*b*freq) * amp
end 
--

--
function formula_.SinSin(xf,yf, a,b,c,d, freq, amp)
 return 0.5 + 0.5 * sin((xf*a + yf*b)*freq) * sin((xf*c + yf*d)*freq) * amp
end 
--

--
function formula_.SinCos(xf,yf, a,b,c,d, freq, amp)
 return 0.5 + 0.5 * sin((xf*a + yf*b)*freq) * cos((xf*c + yf*d)*freq) * amp
end 
--




--
function distortWaves(s_o, p_o) -- s_o = settings object, p_o = parameter object

 bilinear_up = bilinear_up or 0

 local c,r,g,b,d,v,w,h,w1,h1,Cx,Cy,fx,fy,oyf,dt,dx,dy,ox,oy,t1,t2,pal,TC,DT
 local Lights, light_strength, Strength_Multiplier, strength, final_strength, final_lightstrength
 local dither_power2
 local INSIDE,OUTSIDE, Adjust_Exponent  
 local cos,sin,floor,max,min,abs,log,ceil

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

 

 local amplitude,frequency,A,B,C,D,formfunc,Ofs_x,Ofs_y

  formfunc = p_o.func

 amplitude = p_o.amplitude * p_o.scale_AMP
 frequency = p_o.frequency * p_o.scale_FRQ
        A = p_o.a * p_o.scale_PRM
        B = p_o.b * p_o.scale_PRM
        C = p_o.c * p_o.scale_PRM
        D = p_o.d * p_o.scale_PRM

  Ofs_x = p_o.offset_x
  Ofs_y = p_o.offset_y



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

 cos,sin,floor,max,min,abs,log,ceil = math.cos, math.sin,math.floor, math.max, math.min, math.abs, math.log, math.ceil


 --
 function getAlphaValue(fx,fy)
  --return alpha_.Control(alpha_func, fx,fy, xflip_flag, yflip_flag, invert_flag, rotate_flag, curve_func)
  --return 0.5 + 0.5 * (sin((fx*V1+fy*V2)*DIST_FRQ_rnd)*cos((fy*V3+fx*V4)*DIST_FRQ_rnd)*DIST_AMP_rnd)
 --return 0.5 + 0.5 * (sin((fx*A+fy*B)*frequency)*cos((fx*C+fy*D)*frequency)*amplitude)
 --return 0.5 + 0.5 * (sin((fx*A+fy*B)*frequency)*sin((fx*C+fy*D)*frequency)*amplitude)
  return formfunc(fx,fy, A,B,C,D, frequency,amplitude)
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
 dt = getAlphaValue(ox+Ofs_x,oy+Ofs_y)

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

    DT = getAlphaValue(fx+Ofs_x,fy+Ofs_y)
   
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
-- distortWaves



--[[
-- DISTORTIONS
DIST_AMP = 10.0   -- Amplitude, Maximum. Average is 25% of maximum + 0.05
DIST_FRQ = 10.0   -- Frequency, Maximum. Average is 25% of maximum + 0.25 
DIST_RND = 20    -- Parameter RND, frequency, nominal = 6 (in cases similar to increasing freq)
--
-- Distortion values
V1 = math.random()*DIST_RND - (DIST_RND/2) -- -10 to 10
V2 = math.random()*DIST_RND - (DIST_RND/2)
V3 = math.random()*DIST_RND - (DIST_RND/2)
V4 = math.random()*DIST_RND - (DIST_RND/2)
--V1,V2,V3,V4 = 5,-5,5,5
DIST_AMP_rnd = 0.1 * DIST_AMP * math.random() * math.random() -- 0..1.0, starting at 0.05 for random
DIST_FRQ_rnd = 0.5 * DIST_FRQ * math.random() * math.random() -- 0..5.0, starting at 0.25 for random
--DIST_AMP_rnd = 0.5
--DIST_FRQ_rnd = 1.0
--]]

parameters = {

 func = formula_.SinCos, 

 scale_AMP = 0.1, -- Values are normalized to 10, these are scalors
 scale_FRQ = 1.0,
 scale_PRM = math.pi, -- / 2.5

 max_amplitude = 10.0, -- Max Randomizing
 max_frequency = 10.0,
 max_randomize = 4.0, -- a,b,c,d

 amplitude = 2.5, --  scaled 0..1.0, starting at 0.05 for random
 frequency = 2.0, --  scaled 0..10.0, starting at 0.25 for random

 a =  1,
 b =  1,
 c =  1,
 d =  1,

 offset_x = -0.5, -- -1.0 to 1.0
 offset_y = -0.5

}

--
function randomizeParams()

 local rnd,o
 rnd = math.random
 o = parameters

 o.amplitude = 0.5 + o.max_amplitude * rnd()*rnd() -- 0.5 * 0.1 = 0.05
 o.frequency = 0.5 + o.max_frequency * rnd()*rnd() -- 0.5 * 0.5 = 0.25

 o.a = rnd()*o.max_randomize*2 - o.max_randomize
 o.b = rnd()*o.max_randomize*2 - o.max_randomize
 o.c = rnd()*o.max_randomize*2 - o.max_randomize
 o.d = rnd()*o.max_randomize*2 - o.max_randomize

end
--

settings = {
    strength = 50,
      levels = 2,
 bilinear_up = 0, -- use bilinear scaling when enlarging (rather than always using sampling)
       gamma = 1.6,
 light_power = 100,
dither_power = 0,
        zoom = 1 -- 2 = 50%, 0.5 = 200%
}

formula_funcs = {
 list = {{"Sin(aX + bY +c)",       formula_.Sin},
         {"Sin(aX+bY)·Sin(cX+dY)", formula_.SinSin},
         {"Sin(aX+bY)·Cos(cX+dY)", formula_.SinCos},
         {"Sin(aX +c)·Cos(bY +d)", formula_.SinXCosY},
         {"Sin(a·X·X + b·Y·Y +c)", formula_.Rings},
         {"a·X·X - b·Y·Y",         formula_.test}
        },
 title = "Set Formula",
 selected = 3,
 menu = (function()menu(formula_funcs);end)
}


--[[
alpha_maps = {
 list = {{"Horizontal",     alpha_.Horizontal},
         {"Vertical",       alpha_.Vertical}
        },
 title = "Set Alpha Map",
 selected = 1,
 menu = (function()menu(alpha_maps);end)
}
--]]


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



--
function strength()
 local ok,dummy
 ok,settings.strength, settings.light_power, dummy,  settings.zoom, dummy,dummy,dummy = inputbox("Distortion: Strength",
  "Strength %: 1-600",       settings.strength,  0,600,1,
  "Depth Shading %: 0-999", settings.light_power,  0,1000,1, 
  "", 0,0,0,4,
  "Zoom: (0.1-10)",  settings.zoom,      0.1,10,2,
  "<1.0 = Zoom In, >1.0 = Zoom Out", 0,0,0,4,
  "Not perfect /w Shading & Bilinear", 0,0,0,4,
  "Scales image, NOT Distortion!", 0,0,0,4                                                                              
 );
end
--

--[[
--
function lightpower()
 local ok
 ok,settings.light_power = inputbox("Distortion: Depth Shading",
  "Depth Shading %: 0-999", settings.light_power,  0,1000,1                                                                    
 );
end
--
--]]


--
function levels()
 local ok,dummy
 ok,settings.levels, settings.bilinear_up, settings.gamma, settings.dither_power, dummy, dummy, dummy = inputbox("Distortion: IP Quality",
   "IP Quality: (0-8)", settings.levels,  0,8,0,
   "Smooth UpScale (bilinear)",  settings.bilinear_up,  0,1,0,
   "Gamma: (1.0-2.2)", settings.gamma,  1,2.2,2,
   "Dither Power: 0-16", settings.dither_power,  0,16,1,   
   "---------------------------------",        0,  0,0,4,
   "Interpolation: Sampling Levels.",          0,  0,0,4,
   "More = Higher quality but slower.",        0,  0,0,4                                                                 
 );
end
--


--
function freq_and_amp()
 local ok,dummy
 ok,parameters.frequency, parameters.amplitude, dummy, dummy, dummy, dummy, parameters.offset_x,parameters.offset_y  = inputbox("Frequency & Amplitude",
  "Frequency: 0.0-10.0", parameters.frequency,  0,10,2,
  "Amplitude: 0.0-100.0", parameters.amplitude,  0,100,2,
  "",        0,  0,0,4,
  "Distortion Offset:",        0,  0,0,4,
  "(Fraction of Image size)",  0,  0,0,4, 
  "-0.5,-0.5 Puts Origo at Center",  0,  0,0,4,       
  "X Offset: -1.0 to 1.0", parameters.offset_x,  -1,1,2,
  "Y Offset: -1.0 to 1.0", parameters.offset_y,  -1,1,2                                                                      
 );
end
--

--
function params_abcd()
 local dummy, ok
 ok, dummy, dummy, parameters.a, parameters.b, parameters.c, parameters.d  = inputbox("Parameters: a,b,c & d",
  "Value range: -8.0 to 8.0",0,0,0,4,
  "[1 = PI]",0,0,0,4,
  "a = ", parameters.a,  -8,8,2,
  "b = ", parameters.b,  -8,8,2,
  "c = ", parameters.c,  -8,8,2,
  "d = ", parameters.d,  -8,8,2                                                                    
 );
end
--



--
function launch()

 parameters.func = formula_funcs.list[formula_funcs.selected][2]

 distortWaves(settings, parameters)
end
--

--[[
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
--]]

--
function boxer()
  local do_selbox,ipbi,zom,dith,ofs
  
  do_selbox = true
  while do_selbox do

   ipbi = ""; if settings.bilinear_up == 1 then ipbi = " *"; end
   zom = ""; if settings.zoom < 1 then zom = " (z+)"; end
             if settings.zoom > 1 then zom = " (z-)"; end

   dith = ""
   if settings.dither_power > 0 then
    dith = " d"..settings.dither_power
   end

   ofs = ""
   if parameters.offset_x ~= 0 or parameters.offset_y ~= 0 then
    ofs = " (o)"
   end

   selectbox("# Formula Distortions", 
    "Strength: "..settings.strength.."%"..zom.." (ds="..settings.light_power..")",  strength,
    "IP Quality: "..settings.levels.."/8"..ipbi..dith,  levels,
    --"Depth Shading: "..settings.light_power.."%",  lightpower,
    --"Dither Power: "..settings.dither_power,  ditherpower,
  
    "F()="..formula_funcs.list[formula_funcs.selected][1],  formula_funcs.menu,
    "<Randomize>",  randomizeParams,
    "FREQ: "..db.format(parameters.frequency,1)..", AMP: "..db.format(parameters.amplitude,1)..ofs, freq_and_amp,
    "a="..db.format(parameters.a,1).." b="..db.format(parameters.b,1).." c="..db.format(parameters.c,1).." d="..db.format(parameters.d,1), params_abcd,
    "RENDER >>", launch,
    --"RESTORE IMAGE >>", restore,
    "[DONE/QUIT]",function() do_selbox = false; end
   );
  end

end
--

boxer()

end
-- main

main()







