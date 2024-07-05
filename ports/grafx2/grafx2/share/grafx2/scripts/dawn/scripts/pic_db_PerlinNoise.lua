--PICTURE: Perlin Noise V1.0
--by Richard 'DawnBringer' Fhager

dofile("../libs/db_perlin.lua")
dofile("../libs/db_interpolation.lua") -- prefix: ip_

function main()

 local octaves,persist,freq_mult,freq_base,multiply,balance
 local OCTAVES,PERSIST,FREQ,FREQ_BASE,SEED,MULTIPLY,BALANCE,IPMODE,SMOOTH
 local w,h,x,y,xf,yf,c,yyf, max, min
 local map, mtx
 local ctrl_func, ip_func

 max, min = math.max, math.min

--
octaves   = 8     -- Octaves, Layers (Nominal 8, higher persistence may need more octaves for detail)
persist   = 0.5   -- Persistence (Roughness): Nominal 0.5, Lower means later octaves will have reduced strength = Smoother
freq_mult = 4.0   -- Frequency: Lower means "zoom-in" / enlarge
freq_base = 2.0   -- "Scale Change": Nominal = 2.0. Lower = Softer, Less detail by octave, higher = more grain, "Zoom-out (>1.0) speed by octave"
-- Post effects
multiply  = 1.25  -- Multiply/Contrast (for Clouds scenes etc.)
balance   = 0     -- Octave output balance, ex: for high contrast, like Clouds, use something like balance -64 and mult = 2
--
---


--
OK,OCTAVES,PERSIST,FREQ,FREQ_BASE,SEED,MULTIPLY,BALANCE,IPMODE,SMOOTH = inputbox("Perlin Noise (256 col gradient)",
                        
  "Octaves/Layers: 1-16",  octaves,         1,16,0, 
  "Persistence: 0.1-1.0",  persist,         0.1,1.0,2, 
  "Frequency/Zoom: 0.1-64",     freq_mult,       0.1,64,2, 
  "Frequency Base: 0.1-4", freq_base,       0.1, 4,2, 
  "Random Seed (0 = none)",0,               -1,1000000,0, 
  "Contrast: 0.1-10",      multiply,        0.1,10,2,
  "Balance: -255..255",    balance,         -255,255,0,
  "IP Algo: 1-5 (2=Ken)",                   2,1,5,0, -- Mid,Ken,Cos,Lin,Cub                                               
  "Smoothing",            0,               0,1,0
                                                                        
);
--


if OK then

w,h = getpicturesize()
--
--perlin.setGradientPal()
if SEED >= 0 then
map = perlin.MakeMap(256,SEED) -- size, rnd seed (if >0)
end
if SEED == -1 then map = perlin.ImageMap(256); end -- Read spare image for data

if SMOOTH == 1 then map = perlin.SmoothMap(map); end

if IPMODE == 2 then -- Optimized KenIP version
 statusmessage("IP: Ken's [Optimized]")
 mtx = perlin.perlinNoise2D_layer(w,h,map, OCTAVES, PERSIST, FREQ, FREQ_BASE, true) -- last is update flag 
 perlin.RenderMap(mtx,MULTIPLY,BALANCE) -- Map,Mult,Balance (-255 to 255)
end


if IPMODE ~= 2 then -- Point by Point mode

 ipfunctions = {{ip_.midip, "IP: 2*Cos (Sharp)"},   -- 1
                {ip_.kenip, "IP: Ken P. (Medium)"}, -- 2
                {ip_.cosip, "IP: Cos (Medium+)"},   -- 3
                {ip_.linip, "IP: Linear (Smooth)"}, -- 4
                {ip_.cubip, "IP: BiCubic"}          -- 5
               } 

 ip_func = ipfunctions[IPMODE][1]


 if IPMODE == 5 then -- Interpolation Control functions (Yeah, extra stuff just to make BiCubic-IP "directly" available)
  ctrl_func = ip_.map_Bicubic_wrap
   else
    ctrl_func = ip_.map_Bilinear_wrap
 end



  xf = 1 / (w-1)
  yf = 1 / (h-1)
  statusmessage(ipfunctions[IPMODE][2])
  for y = 0, h-1, 1 do
   yyf = y * yf
   for x = 0, w-1, 1 do
    -- Control version (interface allowing implementation of ip-functions other than bilinear ones) 
    -- output is -1 to 1
    c = perlin.getPerlinNoise2D_Control_point(x*xf, yyf, map, OCTAVES, PERSIST, FREQ, FREQ_BASE, ctrl_func, ip_func) * 127.5 * MULTIPLY + 127.5 + BALANCE
    putpicturepixel(x,y, max(min(c,255),0))
  end
  if y%8 == 0 then updatescreen();if (waitbreak(0)==1) then return end; end
 end

end

end -- ok

end -- main

main()

















