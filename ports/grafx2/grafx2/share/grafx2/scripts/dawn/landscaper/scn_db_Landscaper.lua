--SCENE: #Landscaper (Lightsourced Noise) 
--by Richard 'DawnBringer' Fhager
--

 VERSION = "VERSION: 1.0"

 dofile("../libs/dawnbringer_lib.lua")
 dofile("../libs/db_perlin.lua")
 dofile("../libs/db_interpolation.lua")
 dofile("../libs/db_interactivity.lua")
 dofile("../libs/db_noise.lua")
 dofile("../libs/db_text.lua")
 dofile("../ffonts/font_mini_3x4.lua")

-- Changes:
-- Ambient modifer (AMB) removed. It was an addition of lightcolor without regards for any other modifer. 
--  (can be rewritten as: c = lightcolor*amb + lightcolor*amp*angle)
--  This would make it an unreliable representation/fraction of a scene's lumination character.
--  And Ambient light can be directly controlled via Basecolor (so AMB was quite redundant and complicating things)
 
w,h = getpicturesize()

if w <= 1024 or h < 640 then
 --font_f = font_mini_3x4
 text.setFont(font_mini_3x4)
end

TXT = text.white

-- Easy Text Interface
function TXT2(xpos,ypos,txt)
 local hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag,backup_flag
--font_f = font_mini_3x4
-- font_f:  Font data (function), will use built-in font by default, use anything undefined as argument, f.ex. 'f' 
hspace = 1
vspace = 3            -- Letter spacing, horizontal/vertical
maxwidth = 1000       --   Paragraph/Box width (i.e point where ONE MORE word is allowed)
col = {255,255,255}   -- RGB colorvalue {r,g,b}
transparency = 0      -- transparency 0..1, 0 = No Transparency
linebreak_char = "|"  -- character that will function as linebreak
aa_str = 1           -- AA strength, 1 = Normal/full AA, 0 = No AA,Solid color. For Dark text on bright bg use about 0.5.
clear_flag = false    
backup_flag = false
void_col = matchcolor(0,0,0)

 text.write(font_f,txt,xpos,ypos,hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag,backup_flag, void_col)
end




--
function core(o)
 
 local Ceil,Min,Max,Abs,Floor,Atan,Cos,Sin,Rnd,Pi,Pi2

 -- Misc
 local w,h,v

 -- Light/Scene Settings
 local LS, AMP, Scl, FC, HARDNESS, RNDLIGHT, FC_R, FC_G, FC_B

 -- ISO settings
 local VSCALE,BASELINE,YPLOTS, CenterX,CenterY, Alt, Ofx,Ofy, Width,Height,ISOMODE

 -- Perlin Settings
 local OCTAVES, PERSIST, FREQ_MULT, FREQ_BASE, MULTIPLY, IP_FUNC

 -- Map Settings
 local ZOOM, OFFSETX, OFFSETY, PSEED, Perlin_Seed, OFFSETX_05, OFFSETY_05
 local AUTOMATA, MAP_ERODE_FREQ, MAP_ERODE_POW

 -- Visuals
 local ADD_BASE, ADD_MULT, MAKEPAL_FLAG, ALT_LEVEL, ADD_Shoreline 
 local TEXTURE, TEXTURE_STR, TEXTURE_TYPE, TEXTURE_FREQ, Texture_Strength
 local HAZE_POW, HAZE_BASE, HAZE_EXP, HAZE_DMULT, HAZE_VMULT, HAZE_R, HAZE_G, HAZE_B
 local BUMP_TEXTURE, BUMP_FREQ, BUMP_HEIGHT, BUMP_DETAILBALANCE, BUMP_DISTFADE, BUMP_LEVEL_LO, Bump_DistR, Bump_Dist05

 -- Arrays
 local PerlinMap, TextureMap, addFuncs, altFuncs, textureFuncs

 -- Function Refs
 local ADD_FUNC, ALT_FUNC, TEXTURE_FUNC, BUMP_FUNC

 -- Functions
 local makeSamplePal, doISO, doNormal, lightsRecalcAngles, randomizeLights -- Function, single run or optional
 local p1, perlinLine, perl, perl_sample, calcLightRGBprecalc
 local Texturize, Bump
 local alt_add_0, alt_add_1, alt_add_2, alt_add_3
 local alt_Modify_NONE, alt_Modify_1, alt_Modify_2, alt_Modify_3, alt_Modify_4, alt_Modify_5, alt_Modify_6, alt_Modify_7

 local texture_Combo, texture_Cloud, texture_PostInflected, texture_Inflected, texture_GrainedPatchy, texture_Cyclic, texture_Cow


 Ceil,Min,Max,Abs,Floor,Atan,Cos,Sin,Rnd,Pi,Pi2 = math.ceil, math.min, math.max, math.abs, math.floor, math.atan, math.cos, math.sin, math.random, math.pi, math.pi/2


--
-- Recalculate the angles (degrees) Lights-data to the final product used in calcLightRGB. 
-- Adds (Multiplies) Global Luminance (AMP) with Light-values.
-- OLD:(Overwrites old indexes, first two: (1 & 2))
-- NEW: Creates new list to remove possible reference (if defined in object (o.LS) then LS=o.LS is a ref)
function lightsRecalcAngles(light, globalrotation, amp)
 local n,li,az,el,deg,ax,ay,newlight
 newlight = {}
 globalrotation = globalrotation or 0
 deg = 180 / math.pi
 for n = 1, #light, 1 do
  newlight[n] = {}
  li = light[n]
  az = (li[1] + globalrotation) / deg
  el = li[2] / deg
  ax = el * math.cos(az)
  ay = el * math.sin(az)
  newlight[n][1] = ax
  newlight[n][2] = ay
  newlight[n][3] = {li[3][1]*amp, li[3][2]*amp, li[3][3]*amp} -- {rgb}
  newlight[n][4] = li[4] -- exp
 end
 return newlight
end
--



--
-- This version expects lightdata with recalculated angles using lightsRecalcAngles(), 
-- index 1 & 2 are no longer degree angles but "final products": li[1] = el*cos(az/deg), li[2] = el*sin(az/deg)
-- Amp (Global Luminance) is now pre-multipled with Lights and not "amp * rdc()..."
--
-- NOTE THE "GLOBAL" (local to project) ATAN, MAX  COS (seem to improve speed about 0.5%)
--
function calcLightRGBprecalc(r,g,b, z1,z2,z3,light,scl)
 local n,rx,ry,Pax,Pay,co,sp,rdc,li -- cos,xD,yD,az,el

 rx = Atan((z1 - z3) * scl)
 ry = Atan((z1 - z2) * scl)
 Pax, Pay = Cos(ry) * rx, Cos(rx) * ry -- Rotation/Angle of plane

 for n = 1, #light, 1 do

  li = light[n]

  co, sp = li[3], li[4]

  rdc = (Max(0, Cos(li[1] - Pax) * Cos(li[2] - Pay)))^sp -- Reduce mult (0..1) (same as xD * Yd)

  r = r + co[1] * rdc
  g = g + co[2] * rdc
  b = b + co[3] * rdc

 end

 return r,g,b
end
--


--[[
--
function randomizeLights()
 local f,m,n,ls
 f = io.open("lightsource.txt", "w");
 m = math.random
 ls = {}
 for n = 1, m(3,7), 1 do
  ls[n] = {m()*360,m()*90,{m()*255,m()*255,m()*255},1+m()*9}
  f:write(db.ary2txt(ls[n]).."\n")
 end
 f:close()
 return ls
end
--
--]]

 --function cap(v) return math.floor(math.min(255,math.max(v,0))); end

 -- Do Nothing (Altitude doesn't change color)
 function alt_add_0(v1,v2,v3)
  return 0,0,0
 end
 --


 -- Altitude addition (Color Gradient)
 function alt_add_1(v1,v2,v3, r0,g0,b0, r1,g1,b1) -- values are usually fractions 0..1
   local avg,add,ra,ga,ba
   avg = (v1 + v2 + v3) / 3
   ra = r0 + r1 * avg
   ga = g0 + g1 * avg
   ba = b0 + b1 * avg
   return ra, ga, ba
 end


 -- These alt-functions are now "hardcoded" with the old formula [(avg+add)*mult]. Not much point trying to rewrite them
 -- or allowing users changing the values. The are best served as "scenes" right now.

 -- Altitude addition ("avg" is the source data and is not affected by render settings, i.e. altitudes are always the same)
 function alt_add_2(v1,v2,v3) -- values are usually fractions 0..1
   local avg,add,q,band,sea, add_base, add_mult
   add_base, add_mult = -300, 0.3
   avg = (v1 + v2 + v3) * 85 -- x255 / 3
   add =  (avg + add_base) * add_mult
   sea = 0; if avg < 77 then sea = 1; end -- 0.3 in function p1 sea effect
   --sea = 0; if Min(v1,v2,v3) < 0.3 then sea = 1; end -- 0.3 in function p1 sea effect
   band = (255-Abs(avg-140))^5 * 0.0000000001 -- green band, 140 is level
   return add-sea*32 -4 -band*0.2, add+sea*4 -18 + band*0.05, add+sea*12 -4 -band*0.5
 end
--

-- "Marsian"
function alt_add_3(v1,v2,v3) -- values are usually fractions 0..1
   local r,g,b,avg,add,q, add_base, add_mult
   add_base, add_mult = -300, 0.3
   avg = (v1 + v2 + v3) * 85
   add =  (avg + add_base) * add_mult
   r,g,b = add + (avg-144)*0.2, add + (avg-128)*0.1, add + (255-avg)*0.12
   return r,g,b 
 end


------------------------------------

--
function alt_Modify_0(v)
 return v
end
--

-- Sea Effect (fade to org + freq/*amp (fine detail))
function alt_Modify_1(v, level)

 ADD_Shoreline = 1 -- Let's just activate shoreline function here (executed in pearl())

 --if v <= 0.3 then v = (0.3 + (v-0.3)*0.075) - (Ceil(v*500)-v*500)*0.001; end
 --if v <= 0.3 then v = v*0.15 + 0.85*(0.3 + (v-0.3)*0.075) - (Ceil(v*500)-v*500)*0.001; end -- Some bottom seen
 --                           v*v/0.3, Max(0,v*v*v)/0.09 v*v*v*v/0.027 -- prominent beaches, less bottom seen at depth
 --                                                                                                          Rougher seas at depths
 --if v <= 0.3 then  v = 0.12 * Max(0,v*v*v/0.09) + 0.88 * (0.3 + (v-0.3)*0.075) - (Ceil(v*200)-v*200)*(0.001+(0.3-v)*0.01); end -- More bottom seen close to shore, less at depth
 if v <= level then  v = 0.12 * Max(0,v*v*v/(level*level)) + 0.88 * (level + (v-level)*0.075) - (Ceil(v*200)-v*200)*(0.001+(level-v)*0.01); end
 return v
end
--

-- "Plains" (level out depths)
-- v can be negative so greath depths can become protrusions
function alt_Modify_2(v, level) 
 local exp
 level = level or 0.5
   exp = 2 -- 1 = Basic Floor
 if v <= level then
  --v = v + Abs(v-level)^exp -- Exp Closer to 1 means flatter floor
  v = v + (level-v)^exp -- Same as above
 end
 return v
end
--


-- "Flats" (level out heights)
function alt_Modify_3(v, level) 
 local exp
 level = level or 0.5
   exp = 3 -- Higher exponent means LESS flattening
 if v >= level then
  v = v - (v-level)^exp
 end
 return v
end
--

-- "Plains" + "Flats" (level out heights)
function alt_Modify_4(v, level) 
 local exp
 level = level or 0.5
   exp = 3
 if v >= level then
  v = v - (v-level)^exp
 end
 if v <= level then
  v = v + (level-v)^2 -- "Plains"
 end
 return v
end
--

-- Peaks & Plains
function alt_Modify_5(v, level)
 local a,vn

 vn = v

 if v > level then
  a = ((v - level)*2)^2 + level
   else 
    vn = v + (level-v)^2 
     a = level - Min(1,(level-vn))^2
 end

     -- Peaks   Orig     Plain
 return a*0.6 + v*0.25 + vn*0.15

end
--

-- Plain Water/Floor
function alt_Modify_6(v, level)
 return Max(v, level)
 --local n
 --n = 5
 --return v + 2/n*Cos(0.5*Sin(v*Pi*n)) - level -- Terrass
end
--



-- Terrace
function alt_Modify_7(v, level)
 local n
 n = 5
 return v + 2/n*Cos(0.5*Sin(v*Pi*n)) - level -- Terrace
end
--



-----------------------------------


--
-- Increased Persistence (~0.6) and lowered Base (~1.5) can maintain or increase variance (little "squariness") 
-- and improve smoothness over nominal settings 0.5/2.0. But can require additional octaves as values separate.
-- Increased base (~2.5) can add some add extra detail with lower Persistence (~0.4), but mostly on smaller levels. (Large features intact)
--


--  perlin.getPerlinNoise2D_point modifed to do a line at a time (for speed)
--
-- NOTE: HARDCODED KEN-IP for 5-6% speed improvement
-- 
function perlinLine(map, yf, width, ox,oy) -- ox,oy is finetuning offsets for panning the map (ex: -0.073, -0.03 for s:999)
  
  ox = ox or 0
  oy = oy or 0

  local p,n,norm,i,xp,yp,iX,yX,fX,fY,v1,v2,v3,v4,mapsiz,frequency,amplitude,floor
  local v,x,xf,line, mapy1,mapy2, i16, nm05, ox05, x0,x1, fXr, fYr, WZoom, Zoom05ox05

  line = {}
  for x = 0, width, 1 do line[1+x] = 0; end

  floor = math.floor
  p,n,norm,mapsiz = PERSIST, OCTAVES, 1, #map  -- Note norm=1 for shorter i-loop

  --yf = yf + oy
  yf = (yf - 0.5) / ZOOM + 0.5 + oy
  ox05 = ox + 0.5

  WZoom = 1 / (width*ZOOM)
  Zoom05ox05 = -0.5 / ZOOM + ox05 

  for i = 1, n-1, 1 do norm = norm + p^i end -- Normalize (norm is 1/norm but applied as MULTIPLY / norm)
 

      for i = 0, n-1, 1 do

       i16 = i*16 -- Experimental try to make noise less "lined up", working?

       frequency = FREQ_BASE^i * FREQ_MULT -- Step/Wavelength (could be optimized as 0 is 1st step, but exp=0 is quite fast in Lua)
       amplitude = p^i  

       yp = yf * frequency --+ i*16
       iY = floor(yp)
       fY = yp - iY
 
        -- Hardcoded Ken
        fY = fY*fY*fY * (fY*(6*fY - 15) + 10)
        fYr = 1 - fY
        --

       mapy1 = map[1 + iY % mapsiz]
       mapy2 = map[1 + (iY+1) % mapsiz]

       for x = 0, width, 1 do -- Note that we go 1 pixel wider than screen (so x/width does reach 1, in a way...)

         --xf = (x/width - 0.5) / ZOOM + ox05  --xf = x/width + ox
        
         xf = x * WZoom + Zoom05ox05

         xp = xf * frequency + i16
       
         iX = floor(xp)
         fX = xp - iX
        
         x0 = 1 + iX % mapsiz
         x1 = 1 + (iX+1) % mapsiz
         v1,v2,v3,v4 = mapy1[x0], mapy1[x1], mapy2[x0], mapy2[x1]

          -- Hardcoded Ken
          fX = fX*fX*fX * (fX*(6*fX - 15) + 10) 
          fXr = 1 - fX
          line[1+x] = line[1+x] + ((v1*fXr + v2*fX)*fYr + (v3*fXr + v4*fX)*fY) * amplitude
          --  

       end -- x

      end -- i

     nm05 = MULTIPLY / norm * 0.5 -- *0.5 to make output -0.5 to 0.5
     for x = 1, width+1, 1 do 
      v = line[x] * nm05 + 0.5 -- output is -1 to 1, with +0.5 there's 0.5 overflow on both ends (-0.5 to 1.5)
      if BUMP_TEXTURE > 0 then
       line[x] = Bump(ALT_FUNC(v, ALT_LEVEL), ALT_LEVEL, x*WZoom + Zoom05ox05, yf)
        else line[x] = ALT_FUNC(v, ALT_LEVEL)
      end
     end

    return line
end
--



  -- 
  function makeSamplePal(w,h)

   local n,npal,ws,hs,xpos,ypos,t,i,w_,h_
   ws,hs = getpicturesize()

   --clearpicture(matchcolor(0,0,0))

  w_,h_,xpos = 200,100, ws/2 - 60

  db.drawRectangle(ws/2-w_/2,hs/2-h_/2,w_,h_,matchcolor(0,0,0))
  db.drawRectangleLine(ws/2-w_/2-1,hs/2-h_/2-1,w_+2,h_+2,matchcolor(255,255,255))   

   ypos = hs/2 - 24
   TXT2(xpos,ypos,"Making Sample Palette...")
   statusmessage("Making Sample Palette...")
   updatescreen(); waitbreak(0)

   local colors,frend
   colors = 256
   frend = perl_sample

   ypos=ypos+8; t = " Sampling Grid"
   TXT2(xpos,ypos, t); updatescreen(); waitbreak(0)

   local n,x,y,r,g,b,pal,xstep,ystep,res,m,rnd,w1,h1,mc
   n,pal,m,rnd,w1,h1 = 0,{},math, math.random, w-1, h-1, npal
   --res = 255
   xstep = m.floor(w^0.3) --m.ceil(w/res)
   ystep = m.floor(h^0.3) --m.ceil(h/res)
   i = 0
   for y = 0, h1, ystep do

    i=i+1; if (i%3==0) then TXT2(xpos,ypos, t..": "..m.ceil(y/h1*100).."%"); updatescreen(); waitbreak(0); end

   for x = (y%2)*m.floor(xstep/2), w1, xstep do
     r,g,b = frend(x,y,w,h)
     n = n+1
     r,g,b = db.rgbcapInt(r,g,b,255,0)
     pal[n] = {r,g,b,0}
    end;end

    TXT2(xpos,ypos, t..": 100%")
    ypos=ypos+8; TXT2(xpos,ypos," Sampling Random..."); updatescreen(); waitbreak(0)
    for x = 0, m.ceil((w+h)+(w*h)^0.5), 1 do -- Some random points
     r,g,b = frend(rnd(0,w1), rnd(0,h1),w,h)
     n = n+1
     r,g,b = db.rgbcapInt(r,g,b,255,0)
     pal[n] = {r,g,b,0}
    end

    ypos=ypos+8; TXT2(xpos,ypos," Color Reduction ("..#pal..")..."); updatescreen(); waitbreak(0)
    npal = db.medianCut(pal, colors, true, false, {0.26,0.55,0.19}, 8, 0) -- pal, cols, qual, quant, weights, bits, quantpower

    ypos=ypos+8; TXT2(xpos,ypos," Sorting & Setting..."); updatescreen(); waitbreak(0)
    npal = db.fixPalette(npal,1)
    for n=1, #npal, 1 do setcolor(n-1,npal[n][1],npal[n][2],npal[n][3]); end

    --clearpicture(matchcolor(0,0,0))
   
 end
  --


--[[
 --
 function makeSamplePal(w,h) -- w&h are not screen size here but render dimensions
  local n,npal,ws,hs
   ws,hs = getpicturesize()
   TXT(ws/2-50,hs/2,"Making Sample Palette...")
  statusmessage("Making Sample Palette...")
  updatescreen(); waitbreak(0)
  npal = db.makeSamplePal(w,h,256,perl_sample)
  for n=1, #npal, 1 do setcolor(n-1,npal[n][1],npal[n][2],npal[n][3]); end
  clearpicture(matchcolor(0,0,0))
 end
 --
--]]

------------------------------------------------

--
function Bump(v, level, xf,yf)
  local q,z
  q = BUMP_FUNC(TextureMap, xf,yf, BUMP_FREQ, BUMP_DETAILBALANCE)

  z = 1
  if BUMP_LEVEL_LO > -1 then -- -1 = Off (No vertical Bump fade)
   z = Sin((Min(1,Max(v,BUMP_LEVEL_LO)-BUMP_LEVEL_LO))*Pi2)
  end 

  return v + q*BUMP_HEIGHT * z * (Bump_DistR + (xf+yf) * Bump_Dist05)--Fade
end
--

-- Sin is centered at 0 so it can have a small freq. = large scale. Low Cos produces bright textures 

-- 1. Combo (4-level)
function texture_Combo(map,xf,yf,freq, detail_balance)
  local v
  detail_balance = detail_balance or 0
  v = perlin.getPerlinNoise2D_point(xf, yf, map, 7+detail_balance, 0.6, 6*freq, 2.0, ip_.kenip)
  v = 0.7*v + 0.3*Sin(4*Pi*v)
  return v
end
--

-- 2. SoftCloud
function texture_Cloud(map,xf,yf,freq, detail_balance)
  detail_balance = detail_balance or 0
  return perlin.getPerlinNoise2D_point(xf, yf, map, 6+detail_balance, 0.6, 6*freq, 3.0, ip_.kenip) -- SoftCloud
end
--

-- 3. Post-Inflected
function texture_PostInflected(map,xf,yf,freq, detail_balance)
  local v
  detail_balance = detail_balance or 0
  v = perlin.getPerlinNoise2D_point(xf, yf, map, 7+detail_balance, 0.55, 7*freq, 2.6, ip_.kenip) -- Post-Inflected SoftCloud
  v = 2*Abs(v)-1 
  --v = 2*(1-Abs(v))-1 -- Post-Inflected Ridged
  return v
end
--

-- 4. Inflected SoftCloud (Note the perlin function)
function texture_Inflected(map,xf,yf,freq, detail_balance)
  local v
  detail_balance = detail_balance or 0
  v = perlin.getPerlinNoise2Dinflect_point(xf, yf, map, 6+detail_balance, 0.52, 8*freq, 2.5, ip_.kenip) 
  --v = 2*(1-Abs(v))-1 -- Ridged
  return v
end
--

-- 5.  Grained Patchy
function texture_GrainedPatchy(map,xf,yf,freq, detail_balance)
  detail_balance = detail_balance or 0
  return Sin(1.6 * Pi*perlin.getPerlinNoise2D_point(xf, yf, map, 6+detail_balance, 0.75, 4*freq, 3.0, ip_.kenip))
end
--


-- 6. Cyclic ("Woodgrain")
function texture_Cyclic(map,xf,yf,freq, detail_balance)
  local v
  detail_balance = detail_balance or 0
  v = perlin.getPerlinNoise2D_point(xf, yf, map, 7+detail_balance, 0.4, freq, 3.2, ip_.kenip) --  Cyclic
  v = Sin(18 * Pi * v)
  return v
end
--

-- 7. Cow Hide-y
function texture_Cow(map,xf,yf,freq, detail_balance)
  detail_balance = detail_balance or 0
  return Sin(1.5 * Pi*perlin.getPerlinNoise2D_point(xf, yf, map, 7+detail_balance, 0.55, 10*freq, 2.0, ip_.kenip))
end
--

----------------------------------------------


-- Texture
function Texturize(xf,yf)

 --ZoomPanAdjust_X = 0.5 + OFFSETX - 0.5 / ZOOM
 --ZoomPanAdjust_Y = 0.5 + OFFSETY - 0.5 / ZOOM  
 --xf = xf/ZOOM + ZoomPanAdjust_X
 --yf = yf/ZOOM + ZoomPanAdjust_Y

 --xf = xf/ZOOM + 0.5 + OFFSETX - 0.5 / ZOOM
 --yf = yf/ZOOM + 0.5 + OFFSETY - 0.5 / ZOOM 

 xf = (xf-0.5)/ZOOM + OFFSETX_05
 yf = (yf-0.5)/ZOOM + OFFSETY_05 

 return TEXTURE_FUNC(TextureMap, xf,yf, TEXTURE_FREQ) * Texture_Strength
 
end
--



 --[[
 if TEXTURE == 8 then -- Meandering 4-level
  v = perlin.getPerlinNoise2D_point(xf, yf, map, 7, 0.4, 0.5*TEXTURE_FREQ, 3.2, IP_FUNC)
  v = Sin(Max(Sin(9 * Pi * v), Sin(48 * Pi * v)) * Pi * 0.25)
 end

 if TEXTURE == 9 then -- Waterrings
  xh=0.5-xf; yh=0.5-yf
  p = xh*xh+yh*yh
  a = Cos(32*Pi*p)*Sin(8*Pi*(xh+yh) * TEXTURE_FREQ)
  v = a 
 end 

-- Long meandering dark & bright channels through hi-freq "woodgrain" that fades into gray as freq increases
function texture_Cyclic(map,xf,yf,freq, ipfunc, detail_balance)
  local v
  detail_balance = detail_balance or 0
  v = perlin.getPerlinNoise2D_point(xf, yf, map, 7+detail_balance, 0.4, freq, 3.2, ipfunc) --  Cyclic
 
k = Cos(v*Pi*2) 
v = Sin(Pi*5 * Pi * k) * (k*k)
  return v
end
 --]]



-- perlin point, same as perlinLine but point-by-point for palette sampling
function p1(xf,yf) -- perlin
  local xc,yc,v
  xc = (xf - 0.5) / ZOOM + OFFSETX_05 -- offsets +0.5
  yc = (yf - 0.5) / ZOOM + OFFSETY_05
  -- output is -1 to 1, so negative & +1 values are possible if multiply > 1 (so m=2 gives a range of -0.5 to 1.5)
  -- *0.5 with +0.5 to normalize 0..1 range with multiply = 1
  -- So, should we redesign the system for 0..1 values (multiply=1), tweak the add's (that is now fitted to extremes) and scale up the geometry instead?
  v = perlin.getPerlinNoise2D_point(xc, yc, PerlinMap, OCTAVES, PERSIST, FREQ_MULT, FREQ_BASE, IP_FUNC) * MULTIPLY * 0.5 + 0.5 -- Multiply * 0.5 when nominal is 2 not 1
  --v = perlin.getPerlinNoise2D_Control_point(xc, yc, PerlinMap, octaves, persist, freq_mult, freq_base, ip_.map_Bicubic_wrap, ip_.cubip) * multiply * 0.5 + 0.5
  --v = perlin.getPerlinNoise2D_Control_point(xc, yc, PerlinMap, octaves, persist, freq_mult, freq_base, ip_.map_Bilinear_wrap, ip_.kenip) * multiply * 0.5 + 0.5

  if BUMP_TEXTURE > 0 then
   return Bump(ALT_FUNC(v, ALT_LEVEL), ALT_LEVEL, xc,yc)
    else return ALT_FUNC(v, ALT_LEVEL)
  end
end
--

-- Palette sampling call function
function perl_sample(x,y, w,h)
 local r,g,b,v1,v2,v3, ar,ag,ag,ab, xf,yf, u,z,q,k,v,d, haze

 xf,yf = x/w, y/h -- It's actually w-1 & h-1 but it doesn't matter with the sampling

 v1,v2,v3 = p1(xf,yf), p1((x+1)/w,yf), p1(xf,(y+1)/h)

 ar,ag,ab = ADD_FUNC(v1,v2,v3, ADD_R0,ADD_G0,ADD_B0, ADD_R1,ADD_G1,ADD_B1)

 r,g,b = calcLightRGBprecalc(FC_R+ar, FC_G+ag, FC_B+ab,v1,v2,v3,LS,Scl)

 if TEXTURE > 0 then
  u = Texturize(xf,yf) --* floordist    --floordist = (1 - Max(0,v1 - ALT_LEVEL))^2 --u = u + TEST2(x,y,w1,h1) * (1-floordist) -- 2 texture test
  z = 1 + u / 256 -- Multiply x0.5 to x1.5 for u=-1..1 
  q = u*0.3 -- Addition
  r = r * z + q 
  g = g * z + q 
  b = b * z + q
 end

 if HAZE_POW > 0 then
  d = (xf + yf)
  haze = HAZE_POW * (1 - Max(0,Min(1,(HAZE_DMULT * d / 2 + v1*HAZE_VMULT))-HAZE_BASE)^HAZE_EXP) -- 0 = No Effect
  k = 1 - haze
  d = d*2+2
  v = Rnd(-d,d)
  r = haze*(HAZE_R+v) + k * r
  g = haze*(HAZE_G+v) + k * g
  b = haze*(HAZE_B+v) + k * b 
 end

 return r, g, b, v1

end
--

-- Apply to perlin noise output f(py00[1+x])
--function f(v)
-- return (Cos(Pi*v*2) * 0.5 + 0.5)
--end


--
function perl(x,y, py00,py11, xf,yf) -- We might use xf,yf rather than w1,h1 (y/h1 optimization etc.)
 local r,g,b,v1,v2,v3, ar,ag,ab, floordist, u,z,q,k,v,d, haze

 v1,v2,v3 = py00[1+x], py00[2+x], py11[1+x]

 ar,ag,ab = ADD_FUNC(v1,v2,v3, ADD_R0,ADD_G0,ADD_B0, ADD_R1,ADD_G1,ADD_B1)
  
 r,g,b = calcLightRGBprecalc(FC_R+ar, FC_G+ag, FC_B+ab,v1,v2,v3,LS,Scl)

 if ADD_Shoreline == 1 then
  -- 0.001(thick) to 0.005(thin) for thickness
  -- Line starts on land and spreads to water, so making it thinner just looks odd
  --                                       Higher value expands width (going up on land)
  -- Nominal 0.001 / 0.01
  if (Abs(v1-v2)>0.001 and Abs(v3-ALT_LEVEL)<0.008) or (Abs(v1-v3)>0.001 and Abs(v2-ALT_LEVEL)<0.008) then 
   q = 1.1 + Rnd()*Rnd()*0.2; r,g,b = r*q+4,g*q+4,b*q+4
  end
 end

 if TEXTURE > 0 then
  u = Texturize(xf,yf) --* floordist    --floordist = (1 - Max(0,v1 - ALT_LEVEL))^2 --u = u + TEST2(x,y,w1,h1) * (1-floordist) -- 2 texture test
  z = 1 + u / 256 -- Multiply x0.5 to x1.5 for u=-1..1 
  q = u*0.3 -- Addition
  r = r * z + q 
  g = g * z + q 
  b = b * z + q
 end

 if HAZE_POW > 0 then
  d = (xf + yf)
  haze = HAZE_POW * (1 - Max(0,Min(1,(HAZE_DMULT * d / 2 + v1*HAZE_VMULT))-HAZE_BASE)^HAZE_EXP) -- 0 = No Effect
  k = 1 - haze
  d = d*2+2
  v = Rnd(-d,d)
  r = haze*(HAZE_R+v) + k * r
  g = haze*(HAZE_G+v) + k * g
  b = haze*(HAZE_B+v) + k * b 
 end

 return r, g, b, v1
 
end
--


 
------------------------------------




-----------------------------------------------------------------


--
-- w & h are size of matrix rather than screen and commonly a square area
-- screenwidth is the acutal physical width to allow drawing to fill the screen if width>height
--
function doISO(w,h, alt,ofx,ofy, ox,oy, screenwidth, yplots) -- ox,oy is fractional offsets for map panning
 local x,y,yf,r,g,b,p,v,c,xm,ym,a,j,yym,xyp,w1,h1
 local py0,py1,new_time,old_time

  yplots = yplots or 3 -- Number of vertical plots, A higher scale (or rare instances) can require more than 3 plots
  py0,py1 = {},{}
  xm, ym = 1, 0.5
  w1,h1 = w-1, h-1
 py1 = perlinLine(PerlinMap, 0, w, ox,oy)

 yplots = yplots - 1
 -- step y:3, x:4 is a good preview mode 6s vs 25s, y2x4 gives more accurate colors 9s, y2x3 = 9.5s.
 old_time = os.clock()
 for y = 0, h1, 1 do
   py0,py1 = py1,{} -- Calc Perlin for each line and swap next & current
   
   py1 = perlinLine(PerlinMap, (y+1)/h1, w, ox,oy)

   yf = y / h1
   yym = ofy + y*ym + 0.5
   xyp = ofx - y
   for x = 0, w1, 1 do 
     j = xyp + x   -- i.e x*xm - y*xm but xm=1
     if j >= 0 and j < screenwidth then
      r,g,b,v = perl(x,y, py0,py1, x/w1,yf)
      a = Floor(yym + x*0.5 -v*alt)
      c = matchcolor(r,g,b)
      --if x%16==0 or y%16==0 then c = matchcolor(r*0.75-8,g*0.75-8,b*0.75-8); end -- Grid   
      for p = a, a+yplots, 1 do putpicturepixel(j, p, c); end
     end
   end
   if y%8==0 then
    --old_time = new_time
    new_time = os.clock()
    statusmessage("Avg Speed: "..Floor((w*y)/(new_time-old_time)).." pts/s") 
    updatescreen();if (waitbreak(0)==1) then return end 
   end
  end
  updatescreen(); waitbreak(0)
end
--

--
-- w & h are size of matrix rather than screen and commonly a square area
-- screenwidth is the acutal physical width to allow drawing to fill the screen if width>height
--
function doNormal(w,h, alt,ofx,ofy, ox,oy) -- ox,oy is fractional offsets for map panning
 local x,y,yf,r,g,b,p,v,c,a,j,yym,xyp,w1,h1
 local py0,py1

  w1,h1 = w-1, h-1

  py0,py1 = {},{}

 py1 = perlinLine(PerlinMap, 0, w, ox,oy)

 for y = 0, h-1, 1 do

   py0,py1 = py1,{} -- Calc Perlin for each line and swap next & current
   yf = y / h1

   py1 = perlinLine(PerlinMap, (y+1)/(h-1), w, ox,oy)

   for x = 0, w-1, 1 do 
      r,g,b,v = perl(x,y, py0,py1, x/w1,yf)
      c = matchcolor(r,g,b)    
      putpicturepixel(x,y,c)
   end

   if y%8==0 then
    updatescreen();if (waitbreak(0)==1) then return end 
   end
  end
  updatescreen(); waitbreak(0)
end
--


--
function doOBLIQUE(w,h, alt,ofx,ofy, ox,oy, screenwidth, yplots) -- ox,oy is fractional offsets for map panning
 local x,y,yf,r,g,b,p,v,c,xm,ym,a,j,yym,xyp,w1,h1
 local py0,py1
  yplots = yplots or 3 -- Number of vertical plots, A higher scale (or rare instances) can require more than 3 plots
  py0,py1 = {},{}
  xm, ym = 1*1.5, 0.5*1.5
  w1,h1 = w-1, h-1

 py1 = perlinLine(PerlinMap, 0, w, ox,oy)

 yplots = yplots - 1
 -- step y:3, x:4 is a good preview mode 6s vs 25s, y2x4 gives more accurate colors 9s, y2x3 = 9.5s.
 for y = 0, h-1, 1 do
   py0,py1 = py1,{} -- Calc Perlin for each line and swap next & current
   yf = (y+1)/h1

   py1 = perlinLine(PerlinMap, yf, w, ox,oy)

   yym = Floor(ofy + y*ym + h/8) -- Number is offset
   xyp = ofx - y*ym - w/4*xm
   for x = 0, w-1, 1 do 
     j = xyp + x*xm   -- i.e x*xm - y*xm but xm=1
     if j >= 0 and j < screenwidth then
      r,g,b,v = perl(x,y, py0,py1, w1,h1)
      a = yym -v*alt -- x*ym
      c = matchcolor(r,g,b)
      for p = a, a+yplots, 1 do putpicturepixel(j,p,c); end
     end
   end
   if y%8==0 then
    updatescreen();if (waitbreak(0)==1) then return end 
   end
  end
  updatescreen(); waitbreak(0)
end
--

-----------------------------------------------


--clearpicture(matchcolor(0,0,0))


-- Read settings from data-object...

-- Isometrics -------------------

 ISOMODE = o.ISOMODE 
  VSCALE = o.VSCALE    -- 0.15 (0..1) Vertical scale as fraction of screen height (0.1125 = max height of 90 in a 800 image)
BASELINE = o.BASELINE  -- mars:0.5 water:0.3, Altitude of Noise where the Isometrics are centered vertically (ex 0.3 if waterline is at 0.3)
  YPLOTS = o.YPLOTS    -- Nom:3-4


-- Lights -----------------------------

HARDNESS = o.HARDNESS  -- Nom:1.0, Lights: Hardness/Contrast (no change to scale or altitude)
     AMP = o.AMP       -- Nom:0.9, Lights: Luminance multiple, nom=1.0 (amp); Map: 0.8, Sphere: 0.99
      FC = o.FC        -- Nom:{0,0,8}, Basecolor RGB. Now Also representing Ambient Light/Colorbalance. Pure Addition.
      LS = o.LS        -- Lights: ex {{157.5, 30, {260,255,220}, 3.0}} Az,Elev,RGB,Exp
    GROT = o.GROT      -- Global rotation of all lights (degrees)
RNDLIGHT = o.RNDLIGHT  -- Randomize Lights Flag


-- Perlin ------------------------------ 

  OCTAVES   = o.OCTAVES   -- Nom:7,  Octaves, Layers (Nominal 8, higher persistence may need more octaves for detail)
  PERSIST   = o.PERSIST   -- Nom:0.4, Persistence (Roughness): Nominal 0.5 (0.4 for Landscapes), Lower means later octaves will have reduced strength = Smoother
  FREQ_MULT = o.FREQ_MULT -- Nom:4.0, Frequency: Lower means "zoom-in" / enlarge (100% eq. to zooming the grid?)
  FREQ_BASE = o.FREQ_BASE -- Nom:2.0, "Scale Change": Nominal = 2.0. Lower = Softer, Less detail by octave, higher = more grain, "Zoom-out (>1.0) speed by octave"
  MULTIPLY  = o.MULTIPLY  -- Nom:1.0, Multiply/Contrast (for Clouds scenes etc.)
  IP_FUNC   = o.IP_FUNC   -- kenip HARDCODED override right now, BUT still active for Sampling
  if type(o.IP_FUNC) == 'table' then
    IP_FUNC = o.IP_FUNC[2] -- {"Function string", function ref}
  end 

  if MULTIPLY == 0 then OCTAVES = 0; end -- With multiply at 0 there's nothing to be done but returning 0.5

  AUTOMATA = o.AUTOMATA or 0 -- Celluar Automata Iterations of Noise Map (Island effect)
  MAP_ERODE_FREQ = o.MAP_ERODE_FREQ or 0 -- Erode/Decontrast noise-map, Frequency 0..1
  MAP_ERODE_POW  = o.MAP_ERODE_POW or 0 -- Power 0..1..4


-- Map ---------------------------------

 PSEED   = o.PSEED   -- Nom:999, Perlin Noise, Random Seed, -1 = Random
 OFFSETX = o.OFFSETX -- Nom:0, Noise Offset
 OFFSETY = o.OFFSETY -- Nom:0
 ZOOM    = o.ZOOM    -- Nom:1

-- Visuals -----------------------------

altFuncs = { -- Order matters not function name
             {alt_Modify_0, "NONE"}, 
             {alt_Modify_1, "Sea"}, 
             {alt_Modify_2, "Plains"}, 
             {alt_Modify_3, "Flats"}, 
             {alt_Modify_4, "Plains & Flats"}, 
             {alt_Modify_5, "Peaks & Plains"},
             {alt_Modify_7, "Terraces"},
             {alt_Modify_6, "Floor"} 
}



addFuncs = { --                             0 = None, 1 = Gradient, 2 = Scene
            {alt_add_0, "NONE",             0 },  
            {alt_add_1, "Gradient",         1 },  
            {alt_add_2, "{Mountain & Sea}", 2 },  
            {alt_add_3, "{Marsian}",        2 }
}



textureFuncs = { -- Also used for Bump-mapping
 {nil,                   "NONE"},
 {texture_Combo,         "Combo"},
 {texture_Cloud,         "Soft Cloud"},
 {texture_PostInflected, "PostInflected C"},
 {texture_Inflected,     "Inflected Cloud"},
 {texture_GrainedPatchy, "Grained Patchy"},
 {texture_Cyclic,        "Cyclic"},
 {texture_Cow,           "Cow Hide-y"}
}

MAKEPAL_FLAG  = o.MAKEPAL_FLAG -- Make sample palette flag
ADD_R0        = o.ADD_R0 or -128
ADD_G0        = o.ADD_G0 or -128
ADD_B0        = o.ADD_B0 or -128
ADD_R1        = o.ADD_R1 or 128
ADD_G1        = o.ADD_G1 or 128
ADD_B1        = o.ADD_B1 or 128
ADD_FUNC      = addFuncs[1 + o.ADD_FUNC][1]
 --if o.ADD_FUNC == 2 then ADD_Shoreline = 1; end -- Shoreline on Mountains&Water NOT Altitude Sea (Activated in ADD function)
ALT_FUNC      = altFuncs[1 + o.ALT_FUNC][1] -- Direct modification of the Perlin Noise output (f.ex Water effect)
ALT_LEVEL     = o.ALT_LEVEL or 0.5
TEXTURE       = o.TEXTURE or 0
TEXTURE_STR   = o.TEXTURE_STR or 50 -- %
TEXTURE_FREQ  = o.TEXTURE_FREQ or 1

HAZE_POW   = o.HAZE_POW   or 0.0  -- Total Effect, 0 = off
HAZE_BASE  = o.HAZE_BASE  or 0.0  -- Base Haze (Extra) 0..1
HAZE_EXP   = o.HAZE_EXP   or 0.75 -- Gradient Exponent: 1 = Linear, 0.5 = Haze mostly at the far back. ~0.75 is usually good
HAZE_DMULT = o.HAZE_DMULT or 1.0  -- Depth Fade, 0 = Full Haze at all depths, nom: 1.0
HAZE_VMULT = o.HAZE_VMULT or 0.5  -- Haze loses strength at heights, nom: 0.5
HAZE_R = o.HAZE_R or 127 -- 90,115,150
HAZE_G = o.HAZE_G or 127
HAZE_B = o.HAZE_B or 127

BUMP_TEXTURE = o.BUMP_TEXTURE or 0 -- Same set as normal textures #0-7 (0 = none / bump-mapping off)
BUMP_FREQ    = o.BUMP_FREQ or 1
BUMP_HEIGHT  = o.BUMP_HEIGHT or 0.05
BUMP_DETAILBALANCE = o.BUMP_DETAILBALANCE or 0
BUMP_DISTFADE = o.BUMP_DISTFADE or 0 -- 0..1, Detail depth fade, 0 = None/Off, 0.75 is good
BUMP_LEVEL_LO = o.BUMP_LEVEL_LO or -1 -- 0..1..-1 Lower level where bump-effect reaches 0, -1 = off

-- General --------------------------------------

o.CLEAR_HAZE = o.CLEAR_HAZE or 0 -- Clear background with haze color? 0=No,1=Yes

-----------------------------------------


w,h = getpicturesize()


------------------------
-- Dervied Parameters --
------------------------

-- Map -----------------------------

if PSEED >= 0 then
 Perlin_Seed = PSEED
  else
   Perlin_Seed = math.random(0,99999)
   o.LASTSEED = Perlin_Seed
end

OFFSETX_05, OFFSETY_05 = OFFSETX + 0.5, OFFSETY + 0.5 -- Common use of offsets in the code (optimize)

PerlinMap = perlin.MakeMap(256, Perlin_Seed) -- size, seed. Nice scenes: 999 (Gibraltar), 996, 9992

if TEXTURE > 0 or BUMP_TEXTURE > 0 then
 TextureMap = perlin.MakeMap(256, Perlin_Seed+1)
end

--PerlinMap = perlin.SmoothMap(PerlinMap, 1) -- amount 0..1, same, or veryyy similar effect can be achieved bu lowering Multiply value


--PerlinMap = perlin.DampenMap3x3(PerlinMap, 1, 0.5) -- Frequent, Low Erosion
--PerlinMap = perlin.DampenMap3x3(PerlinMap, 0.35, 1.0) -- Normal, Medium Erosion
--PerlinMap = perlin.DampenMap3x3(PerlinMap, 0.15, 4) -- Rare, High Erosion


--AUTOMATA = 3 -- 1-5-(10)
-- Celluar Automata ("Island formation")
if AUTOMATA > 0 then
 statusmessage("Applying Automata..."); waitbreak(0)
 noise_.convertPerlin2Fraction(PerlinMap)

 PerlinMap = noise_.noiseAutomata(PerlinMap, AUTOMATA, 3,5, 1, 1) -- A. is iterations

 noise_.convertFraction2Perlin(PerlinMap)
 statusmessage(""); waitbreak(0)
end
--



if MAP_ERODE_FREQ > 0 and MAP_ERODE_POW > 0 then
 perlin.DampenMap3x3(PerlinMap, MAP_ERODE_FREQ, MAP_ERODE_POW)
end


-- Isometrics ------------------------

--CenterX = 0; if w > h then CenterX = (w-h) * 0.5; end
CenterY = 0; if h > w then CenterY = (h-w) * 0.5; end	
		
v = Min(w,h)
Width,Height = v,v
--Width, Height = w,h

Alt = VSCALE * Height
--Ofx = 0.5 * Yscale + CenterX -- Centered (Yscale = Height)
Ofx = 0.5 * w  -- Centered
Ofy = BASELINE * Alt + CenterY -- 0 is centered, but since things are extruded upwards, we do some offset


-- Lights -----------------------------

Scl = HARDNESS * Height * 0.0456 -- Lights: Angle scale/'Global specularity'/Yscale, nom=1.0? (scl); Map 0.15(perlin, old = 0.1): Sphere 0.21
if RNDLIGHT then
 --messagebox("Randomizing Lights...")
 math.randomseed( os.time() )
 LS = randomizeLights()
end
LS = lightsRecalcAngles(LS, GROT, AMP)
 
FC_R, FC_G, FC_B = FC[1],FC[2],FC[3]

-- Misc ------------------------------
if ZOOM ~= 1 then
 Scl = Scl * ZOOM
 Alt = Alt * ZOOM
 Ofy = BASELINE * Alt + CenterY 
end


if BUMP_TEXTURE > 0 then
 BUMP_FUNC = textureFuncs[BUMP_TEXTURE + 1][1]
end

Bump_DistR = 1 - BUMP_DISTFADE
Bump_Dist05 = BUMP_DISTFADE * 0.5


if TEXTURE > 0 then
 TEXTURE_FUNC = textureFuncs[TEXTURE + 1][1]
end

Texture_Strength = TEXTURE_STR / 100 * 128

if MAKEPAL_FLAG then
 makeSamplePal(Width,Height)
end


if o.CLEAR_HAZE == 1 then
 clearpicture(matchcolor(HAZE_R,HAZE_G,HAZE_B))
 else 
   clearpicture(matchcolor(0,0,0))
end

----------------------------
if o.TEXT == 1 then

 --text.setFont(font_mini_3x4)
 --text.white(20,100,"Testing White text")

 local tX,tY,tV,t,n,q
 tX,tY,tV = 2,2,8

 TXT(tX,tY,"Perlin:")
 tY=tY+tV
 TXT(tX,tY," OCTAVES: "..OCTAVES..", PERSIST: "..PERSIST..", FREQ: "..FREQ_MULT..", BASE: "..FREQ_BASE..", MULTIPLY: "..MULTIPLY)
 tY=tY+tV*2
 TXT(tX,tY,"NOISE MAP:")
 tY=tY+tV
 TXT(tX,tY," SEED: "..Perlin_Seed..", ZOOM: "..ZOOM..", OFFSET X: "..OFFSETX..", OFFSET Y: "..OFFSETY) -- Use Perlin_Seed
 tY=tY+tV
 TXT(tX,tY," ISLAND EFFECT: "..AUTOMATA..", EROSION FREQUENCY: "..MAP_ERODE_FREQ..", EROSION POWER: "..MAP_ERODE_POW)

 t = ""
 for n = 1, #o.LS, 1 do -- Note o.LS here since LS has been reformatted
  q = o.LS[n]
  t = t.." "..n..". {"..q[1]..", "..q[2]..", ["..q[3][1]..", "..q[3][2]..", "..q[3][3].."], "..q[4].."}|" 
 end 


 tY=tY+tV*2
 TXT(tX,tY,"LIGHTS:")
 tY=tY+tV
 TXT(tX,tY," (GLOBALS) Hardness: "..HARDNESS..", Luminance: "..AMP..", Rotation: "..GROT)
 tY=tY+tV
 TXT(tX,tY," Base Color: ["..FC[1]..", "..FC[2]..", "..FC[3].."]")
 tY=tY+tV
 TXT(tX,tY,t)

 --tY=tY+tV*(1+#LS)

 tY = h - 72

 TXT(tX,tY,"ALTITUDE Settings:")
 tY=tY+tV
 TXT(tX,tY," Function: "..altFuncs[1 + o.ALT_FUNC][2]..", Level: "..ALT_LEVEL)

 tY=tY+tV*2
 TXT(tX,tY,"ADDITION Settings:")
 tY=tY+tV
 t = " Function: "..addFuncs[1 + o.ADD_FUNC][2]
 if addFuncs[1 + o.ADD_FUNC][3] == 1 then -- Gradient
  t = t.." (["..ADD_R0..", "..ADD_G0..", "..ADD_B0.."] + ["..ADD_R1..", "..ADD_G1..", "..ADD_B1.."])"
 end
 TXT(tX,tY,t)

 tY=tY+tV*2
 if HAZE_POW > 0 then
  TXT(tX,tY,"HAZE:")
  tY=tY+tV
  TXT(tX,tY," Power: "..HAZE_POW..", Depth Redux: "..HAZE_DMULT..", Height Redux: "..HAZE_VMULT)
  tY=tY+tV
  TXT(tX,tY," Fade Exp: "..HAZE_EXP..", Base: "..HAZE_BASE..", Color: ["..HAZE_R..", "..HAZE_G..", "..HAZE_B.."]")
   else TXT(tX,tY,"HAZE: (OFF)")
 end

 tX,tY = w - 380, h - 48

 --tY=tY+tV*2
 TXT(tX,tY,"TEXTURIZING:")
 tY=tY+tV
 t = " Texture: '"..textureFuncs[TEXTURE + 1][2].."'"
 if TEXTURE > 0 then
  t = t..", Strength: "..TEXTURE_STR.."%, FREQUENCY: "..TEXTURE_FREQ
 end
 TXT(tX,tY,t)

 tY=tY+tV*2
 TXT(tX,tY,"BUMP MAPPING:")
 tY=tY+tV
 t = " Texture: '"..textureFuncs[BUMP_TEXTURE + 1][2].."'"
 if BUMP_TEXTURE > 0 then
  t = t..", Height: "..BUMP_HEIGHT..", Detail Balance: "..BUMP_DETAILBALANCE..", FREQUENCY: "..BUMP_FREQ
 end
 TXT(tX,tY,t)
 tY=tY+tV
 if BUMP_TEXTURE > 0 then
  TXT(tX,tY," Detail Depth Fade: "..BUMP_DISTFADE..", Height Fade (Lower Level): "..BUMP_LEVEL_LO)
 end

 tX,tY = w - 5*#VERSION-1, 2
 TXT(tX,tY, VERSION)

end
-- text
----------------------------------------



t1 = os.clock()

if ISOMODE == 1 then
 doISO(Width,Height, Alt,Ofx,Ofy, OFFSETX,OFFSETY, w, YPLOTS)
 --doOBLIQUE(Width,Height, Alt,Ofx,Ofy, OFFSETX,OFFSETY, w, YPLOTS)
  else
   doNormal(Width,Height, Alt,Ofx,Ofy, OFFSETX,OFFSETY, w)
end

--messagebox("Seconds: "..(os.clock() - t1))

end -- core
--------------------------------------------------------------------------
-- ******************************************************************** --
--------------------------------------------------------------------------




Prefs = {
 text = 1,       -- Write text to screen
 clear_haze = 0  -- Use Haze color to clear background
}



-- Recursive copying of a Table
function tableCopy(o)
 local n,v,newo
 
 newo = {}

 --return {table.unpack(o)}
 for n = 1, #o, 1 do
  v = o[n]
  if type(v) == "table" then
   v = tableCopy(v)
  end
  newo[n] = v
  v = 0
 end
 return newo
end
--


--
function copyLS_object(o)
 local O
 
 O = {}

-- Isometrics -------------------

 O.ISOMODE = o.ISOMODE or 0 
  O.VSCALE = o.VSCALE or 0.15
O.BASELINE = o.BASELINE or 0.5
  O.YPLOTS = o.YPLOTS or 4

-- Lights -----------------------------

O.HARDNESS = o.HARDNESS or 1
     O.AMP = o.AMP or 1
      O.FC = tableCopy(o.FC or {0,0,0})
      O.LS = tableCopy(o.LS or {{0, 45, {255,0,0}, 1.0}})
    O.GROT = o.GROT or 0
O.RNDLIGHT = o.RNDLIGHT

-- Perlin ------------------------------ 

  O.OCTAVES   = o.OCTAVES or 1
  O.PERSIST   = o.PERSIST or 0.5
  O.FREQ_MULT = o.FREQ_MULT or 4
  O.FREQ_BASE = o.FREQ_BASE or 2
  O.MULTIPLY  = o.MULTIPLY or 1
  O.IP_FUNC   = o.IP_FUNC or ip_.kenip

  O.AUTOMATA = o.AUTOMATA or 0
  O.MAP_ERODE_FREQ = o.MAP_ERODE_FREQ or 0
  O.MAP_ERODE_POW  = o.MAP_ERODE_POW or 0
 
-- Map ---------------------------------

 O.PSEED   = o.PSEED or -1
 O.OFFSETX = o.OFFSETX or 0
 O.OFFSETY = o.OFFSETY or 0
 O.ZOOM    = o.ZOOM or 1

-- Visuals -----------------------------

O.MAKEPAL_FLAG  = o.MAKEPAL_FLAG
O.ADD_R0        = o.ADD_R0 or -128
O.ADD_G0        = o.ADD_G0 or -128
O.ADD_B0        = o.ADD_B0 or -128
O.ADD_R1        = o.ADD_R1 or 128
O.ADD_G1        = o.ADD_G1 or 128
O.ADD_B1        = o.ADD_B1 or 128
O.ADD_FUNC      = o.ADD_FUNC or 0
O.ALT_FUNC      = o.ALT_FUNC or 0
O.ALT_LEVEL     = o.ALT_LEVEL or 0.5
O.TEXTURE       = o.TEXTURE or 0
O.TEXTURE_STR   = o.TEXTURE_STR or 50
O.TEXTURE_FREQ  = o.TEXTURE_FREQ or 1

O.HAZE_POW   = o.HAZE_POW   or 0.0 -- Turn off after implementation  
O.HAZE_BASE  = o.HAZE_BASE  or 0.0
O.HAZE_EXP   = o.HAZE_EXP   or 1.0
O.HAZE_DMULT = o.HAZE_DMULT or 1.0
O.HAZE_VMULT = o.HAZE_VMULT or 0.5
O.HAZE_R = o.HAZE_R or 127 
O.HAZE_G = o.HAZE_G or 127
O.HAZE_B = o.HAZE_B or 127

O.BUMP_TEXTURE = o.BUMP_TEXTURE or 0 -- Same set as normal textures #0-7 (0 = none / bump-mapping off)
O.BUMP_FREQ    = o.BUMP_FREQ or 1
O.BUMP_HEIGHT  = o.BUMP_HEIGHT or 0.05
O.BUMP_DETAILBALANCE = o.BUMP_DETAILBALANCE or 0
O.BUMP_DISTFADE = o.BUMP_DISTFADE or 0
O.BUMP_LEVEL_LO = o.BUMP_LEVEL_LO or -1

-- General --------------------------

 --O.CLEAR_HAZE = o.CLEAR_HAZE or 0
 --O.TEXT

 return O
end
--




 Scenes = {
   list = dofile("_scenes.lua")(), -- Load scenes from pfunction
   title = "Preset Scenes",
   markselected = 0,
   selected = 1, -- Load scene #1 at startup
   menu = (function()
       local sel
       ia_.Menu(Scenes)
       sel = Scenes.selected
       if sel > 0 then
        loadSceneInfo() -- Sets selection to 0 after loading
        messagebox("Scene Loaded: '"..Scenes.list[sel][1].."'")
       end 
      end)
 }






 local BACK_TXT
 
 BACK_TXT = "[BACK]"


--
function isometrics()
 local w,h,dummy, ok, set1280 

 w,h = getpicturesize()

 ok, O.VSCALE, O.BASELINE, O.YPLOTS, O.ISOMODE, dummy,set1280, Prefs.text, Prefs.clear_haze  = inputbox("Isometrics ("..w.."x"..h..")",
  "Vertical Scale: 0..1", O.VSCALE,  0,1,2,
  "Baseline (Y-pos): 0..1", O.BASELINE,  0,1,2,     
  "Y-Plots: 1-24", O.YPLOTS,  1,24,1, 
  "Isometric Mode Active", O.ISOMODE,0,1,0,
  "--- Session Prefs ---", 0,0,0,4,
  "_Set Screen to 1280x640", 0,0,1,0,
  "_Write Text to Screen", Prefs.text,0,1,0,
  "_Background is Haze col", Prefs.clear_haze,0,1,0                                                                 
 );

 if ok then
  if set1280 == 1 then
   setpicturesize(1280,640)
   updatescreen(); waitbreak(0)
  end
 end

end
--


--
function map()
 local dummy, ok
 ok, O.PSEED, O.ZOOM, O.OFFSETX, O.OFFSETY, dummy, O.AUTOMATA, O.MAP_ERODE_FREQ, O.MAP_ERODE_POW  = inputbox("Map ("..O.LASTSEED..")",
  "Rnd Seed: (-1 = Random)", O.PSEED,-1,999999,1,
  "Zoom: x0.1-10",       O.ZOOM,     0.01,10,2,     
  "X Offset: -1.0..1.0", O.OFFSETX,  -10,10,2,
  "Y Offset: -1.0..1.0", O.OFFSETY,  -10,10,2,
  "--- Noise Map Modifications ---", 0,0,0,4,
  "Island Effect: 0-5", O.AUTOMATA,  0,10,1, -- Celluar Automata
  "Erosion Frequency: 0..2", O.MAP_ERODE_FREQ,  0,2,2,
  "Erosion Power:     0..4", O.MAP_ERODE_POW,   0,4,2                                                          
 );
end
--

--
function perlin_menu()
 local dummy, ok
 ok, O.OCTAVES, O.PERSIST, O.FREQ_MULT, O.FREQ_BASE, O.MULTIPLY, dummy,dummy  = inputbox("Perlin",
  "OCTAVES (Detail): 1-16", O.OCTAVES,1,16,1,
  "Persistence: 0..1", O.PERSIST, 0.1,1,2,     
  "Frequency: 0-16",   O.FREQ_MULT, 0,16,2,
  "Freq. Base: 1-4",   O.FREQ_BASE, 1,4,2, 
  "Multiply (Amp): 0-16",    O.MULTIPLY, 0,16,2,
  " (Multiply is strength/height)", 0,0,0,4,
  " (A value of 0 = Deactivated )", 0,0,0,4                                                           
 );
end
--



alt_funcs = {                    -- No current use for this number other than reminder of each item's data value
 list = {{"NONE",                0},
         {"Sea",                 1},
         {"Natural Plains",      2},
         {"Natural Flats",       3},
         {"Plains + Flats",      4},
         {"Peaks & Plains",      5},
         {"Terraces",            6},
         {"Floor/Water (Basic)", 7}
        
        },
 title = "Set Altitude Function",
 selected = 1,
 menu = (function()ia_.Menu(alt_funcs); O.ALT_FUNC = alt_funcs.selected - 1; end)
 --menu = (function()ia_.Menu(alt_funcs); O.ALT_FUNC = alt_funcs.list[alt_funcs.selected][2]; end)
}

--
function visuals_altlevel()
 local dummy, ok
 ok, O.ALT_LEVEL = inputbox("Visuals: Alt Level",
  "ALT LEVEL: 0..1", O.ALT_LEVEL,0,1,3                                                   
 );
end
--

--
function alt_menu()
 local do_selbox

 do_selbox = true
 while do_selbox do
  selectbox("ALT Settings", 
   "ALT Func: "..alt_funcs.list[alt_funcs.selected][1], alt_funcs.menu,
   "ALT: Level = "..O.ALT_LEVEL, visuals_altlevel,
   BACK_TXT,function() do_selbox = false; end  
  );     
 end

end
--



add_funcs = {
 list = {{"NONE",                -1},
         {"Gradient",            -1}, -- #1 & 2 slots are important as menus are built using this setup

         {"{Mountain & Sea}",    -1},
         {"{Marsian}",           -1}
        },
 title = "Set Add Function",
 selected = 1,
 menu = (function()ia_.Menu(add_funcs); O.ADD_FUNC = add_funcs.selected - 1; end)
 --menu = (function()ia_.Menu(add_funcs); O.ADD_FUNC = add_funcs.list[add_funcs.selected][2]; end)
}


--
function visuals_add_col0()
 local dummy, ok
 ok, O.ADD_R0, O.ADD_G0, O.ADD_B0  = inputbox("Visuals: Low RGB",
  "R: -255..255", O.ADD_R0,-384,384,1,
  "G: -255..255", O.ADD_G0,-384,384,1, 
  "B: -255..255", O.ADD_B0,-384,384,1                                                    
 );
end
--


--
function visuals_add_col1()
 local dummy, ok
 ok, O.ADD_R1, O.ADD_G1, O.ADD_B1  = inputbox("Visuals: High RGB",
  "R: -255..255", O.ADD_R1,-384,384,1,
  "G: -255..255", O.ADD_G1,-384,384,1, 
  "B: -255..255", O.ADD_B1,-384,384,1                                                    
 );
end
--


--
function add_menu()
 local do_selbox,lotxt,hitxt

 do_selbox = true
 while do_selbox do

  lotxt = " ["..O.ADD_R0..","..O.ADD_G0..","..O.ADD_B0.."]"
  hitxt = " ["..O.ADD_R1..","..O.ADD_G1..","..O.ADD_B1.."]"

  if add_funcs.selected == 2 then -- Values
   selectbox("ADD Settings", 
    "ADD Func: "..add_funcs.list[add_funcs.selected][1], add_funcs.menu,
    "Lo RGB"..lotxt, visuals_add_col0,
    "Hi RGB"..hitxt, visuals_add_col1,
    "{Set Grayscale  [25%]}", (function() O.ADD_R0=-64;O.ADD_G0=-64;O.ADD_B0=-64; O.ADD_R1=64;O.ADD_G1=64;O.ADD_B1=64; end),
    "{Set Grayscale  [50%]}", (function() O.ADD_R0=-128;O.ADD_G0=-128;O.ADD_B0=-128; O.ADD_R1=128;O.ADD_G1=128;O.ADD_B1=128; end),
    "{Set HueShift 1 [50%]}", (function() O.ADD_R0=-130;O.ADD_G0=-130;O.ADD_B0=-105; O.ADD_R1=140;O.ADD_G1=130;O.ADD_B1=85; end),
    "{Set HueShift 2 [50%]}", (function() O.ADD_R0=-160;O.ADD_G0=-130;O.ADD_B0=-120; O.ADD_R1=165;O.ADD_G1=130;O.ADD_B1=95; end),
    BACK_TXT,function() do_selbox = false; end  
   );     
  end

  if add_funcs.selected ~= 2 then -- NONE & Schemes 
   selectbox("ADD Settings", 
    "ADD Func: "..add_funcs.list[add_funcs.selected][1], add_funcs.menu,
    BACK_TXT,function() do_selbox = false; end  
   );     
  end

 end

end
--



 Textures = {
   list = {                       -- Number has no function, data is order of list which much correspond with functions in core
           {"NONE",            0},-- So these items can NOT be moved around without also changing the master-order in core 
           {"Combo",           1}, 
           {"Soft Cloud",      2}, 
           {"PostInflected C", 3},   
           {"Inflected Cloud", 4}, 
           {"Grained Patchy",  5},
           {"Cyclic",          6},
           {"Cow Hide-y",      7}, 
          }, 

   title = "Textures",
   selected = 1,
   menu = (function()ia_.Menu(Textures); O.TEXTURE = Textures.selected - 1; end)
   --menu = (function()ia_.Menu(Textures); O.TEXTURE = Textures.list[Textures.selected][2]; end)
 }

 Bump = {
   list = {
           {"NONE",            0}, 
           {"Combo",           1}, 
           {"Soft Cloud",      2}, 
           {"PostInflected C", 3}, 
           {"Inflected Cloud", 4}, 
           {"Grained Patchy",  5},
           {"Cyclic",          6},
           {"Cow Hide-y",      7},   
          }, 

   title = "Bump Map",
   selected = 1,
   menu = (function()ia_.Menu(Bump); O.BUMP_TEXTURE = Bump.selected - 1; end)
   --menu = (function()ia_.Menu(Bump); O.BUMP_TEXTURE = Bump.list[Bump.selected][2]; end)
 }



--
function bump_height()
 local dummy, ok
 ok, O.BUMP_HEIGHT = inputbox("Bump Mapping Height",
   "Height: 0..1", O.BUMP_HEIGHT,0,1,3                                       
 );
end
--

--
function bump_balance()
 local dummy, ok
 ok, O.BUMP_DETAILBALANCE = inputbox("Bump Detail Balance",
   "Detail Balance: -5 to 5", O.BUMP_DETAILBALANCE,-5,5,1                                       
 );
end
--

--
function bump_freq()
 local dummy, ok
 ok, O.BUMP_FREQ,dummy = inputbox("Bump Texture Frequency",
   "Frequency: (0.1..16)", O.BUMP_FREQ,0.1,16,2,
   "", 0,0,0,4,
   "f>1 = Zoom Out / Smaller Scale", 0,0,0,4                                      
 );
end
--

--
function bump_distfade()
 local dummy, ok
 ok, dummy, O.BUMP_DISTFADE = inputbox("Bump Depth Fade (ISO)",
   "- Detail loss at far distance -", 0,0,0,4,
   "Fraction: 0..1", O.BUMP_DISTFADE, 0,1,3                                       
 );
end
--

--
function bump_level_lo()
 local dummy, ok
 ok, dummy, dummy, O.BUMP_LEVEL_LO = inputbox("Bump Height Fade",
   "- Lower altitude where bumps -", 0,0,0,4,
   "- fades to 0. -1 = No fading -", 0,0,0,4,
   "Level: 0..1", O.BUMP_LEVEL_LO, -1,1,3                                       
 );
end
--


--
function bump_menu()
 local do_selbox, p
 do_selbox = true

 -- Dynamically built selectbox
 while do_selbox do
    p = {}

    ia_.AddItem2Package(p, "BUMP MAP: "..Bump.list[Bump.selected][1], Bump.menu)
    ia_.AddItem2Package(p, "Height: "..O.BUMP_HEIGHT,                 bump_height)
    ia_.AddItem2Package(p, "Detail Balance: "..O.BUMP_DETAILBALANCE,  bump_balance)
    ia_.AddItem2Package(p, "Frequency: x"..O.BUMP_FREQ,               bump_freq)
    ia_.AddItem2Package(p, "Depth Fade (ISO): "..O.BUMP_DISTFADE,     bump_distfade)
    ia_.AddItem2Package(p, "Height Fade (Low): "..O.BUMP_LEVEL_LO,    bump_level_lo)
   if Bump.selected > 1 then
    ia_.AddItem2Package(p, "<Disable Bump Mapping>",                  (function() Bump.selected = 1; O.BUMP_TEXTURE = 0; end) )
   end
    ia_.AddItem2Package(p, BACK_TXT,                                  (function() do_selbox = false; end) )                                                      
   
    selectbox("Bump Mapping", unpack(p)) 

 end

end
--


--
function texture_strength()
 local dummy, ok
 ok, O.TEXTURE_STR = inputbox("Texture Strength",
   "Strength %", O.TEXTURE_STR,0,100,1                                       
 );
end
--

--
function texture_freq()
 local dummy, ok
 ok, O.TEXTURE_FREQ,dummy = inputbox("Texture Frequency",
   "Frequency: (0.1..16)", O.TEXTURE_FREQ,0.1,16,2,
   "", 0,0,0,4,
   "f>1 = Zoom Out / Smaller Scale", 0,0,0,4                                      
 );
end
--

--
function texture_menu()
 local do_selbox, p
 do_selbox = true

 -- Dynamically built selectbox
 while do_selbox do
    p = {}

    ia_.AddItem2Package(p, "TEXTURE: "..Textures.list[Textures.selected][1], Textures.menu)
    ia_.AddItem2Package(p, "Strength: "..O.TEXTURE_STR.."%",                 texture_strength)
    ia_.AddItem2Package(p, "Frequency: x"..O.TEXTURE_FREQ,                   texture_freq)
   if Textures.selected > 1 then
    ia_.AddItem2Package(p, "<Disable Texture>",                              (function() Textures.selected = 1; O.TEXTURE = 0; end) )
   end
    ia_.AddItem2Package(p, BACK_TXT,                                         (function() do_selbox = false; end) )                                                      
   
   selectbox("Texture", unpack(p)) 

 end

end
--


--
function haze_menu()
 local ok

 ok, O.HAZE_POW, O.HAZE_DMULT, O.HAZE_VMULT, O.HAZE_EXP, O.HAZE_BASE, O.HAZE_R, O.HAZE_G, O.HAZE_B = inputbox("Haze / Distance Fade",
  "Power: 0..1 (0 = off)", O.HAZE_POW,  0,2,2,
  "Depth Redux (ISO): 0..1", O.HAZE_DMULT,  0,1,2, 
  "Height Redux: 0..1", O.HAZE_VMULT,  0,1,2,
  "Fade Exponent: 0..4", O.HAZE_EXP,  0,4,2,
  "Base Haze (Extra): 0..1", O.HAZE_BASE,  0,1,2,
  "Haze color, R: 0-255", O.HAZE_R,  0,255,1, 
  "            G: 0-255", O.HAZE_G,  0,255,1, 
  "            B: 0-255", O.HAZE_B,  0,255,1        
                                                           
 );

end
--



--
function visuals_menu()
 local do_selbox, pswap,altxt,adtxt,txtxt,hztxt,bmtxt

 do_selbox = true
 while do_selbox do
  pswap = "NO"; if O.MAKEPAL_FLAG then pswap = "YES"; end
  altxt = " (NONE)"; if alt_funcs.list[alt_funcs.selected][1] ~= "NONE" then altxt = " (f "..O.ALT_LEVEL..")"; end
  adtxt = " (Scheme)"
  txtxt = "(Textures)"; if Textures.selected > 1 then txtxt = "TEXTURES"; end
  hztxt = "(Haze)"; if O.HAZE_POW > 0 then hztxt = "HAZE"; end
  bmtxt = "(Bump Mapping)";  if Bump.selected > 1 then bmtxt = "BUMP MAPPING"; end
  if add_funcs.selected == 1 then adtxt = " (NONE)"; end
  if add_funcs.selected == 2 then adtxt = " (Gradient)"; end -- Values
  selectbox("Visuals", 
   "Make Sample Palette: "..pswap, (function() O.MAKEPAL_FLAG = not O.MAKEPAL_FLAG; end),
   "ALT Settings"..altxt, alt_menu, 
   "ADD Settings"..adtxt, add_menu,
   hztxt, haze_menu, 
   txtxt, texture_menu, 
   bmtxt, bump_menu, 

   BACK_TXT,function() do_selbox = false; end                                                      
  );
 end
end
--

---- Lights

settings = {
 MAX_LIGHTS = 6,
 new_azimuth   = 0,
 new_elevation = 25,
 new_exponent  = 2,
 new_rgb = {255,255,224},
}


Prelights = {
  list = { --   2.Lum/Amp, 3.Hardness, 4.Rotation, 5.BaseColor, 6.Lights
           {"(Current)"},
           {"Default/Reset [1]", 1,    1,      0, {0,0,0},   {{0, 25, {255,255,255}, 3.0}} },
           {"Lone Star     [1]", 1,    1,      0, {0,0,32},  {{100, 25, {215,190,140}, 4}} },
           {"Low Blue      [2]", 1,    1,   -130, {-4,4,12}, {{-45, 34, {255,208,160}, 4.0}, {90, 40, {115,155,215}, 8.0}} },
           {"Marsian       [2]", 0.85, 1,    -10, {10,2,12}, {{9, 13, {255,176,100}, 6}, {100, 35, {100,90,105}, 10}} },
           {"OmniBrown     [2]", 1,    1,      0, {0,0,5},   {{0, 8, {148,146,160}, 4}, {-5, 47, {144,77,27}, 5}} },
           {"Rusty Hills   [2]", 1,    1,      0, {0,10,24}, {{163, 43, {104,120,118}, 7}, {303, 24, {252,187,138}, 4}} },
           {"Red & Blue    [2]", 1,    1,      0, {0,8,8},   {{205, 20, {210,120,75}, 5}, {-40, 45, {160,200,250}, 4}} },
           {"Blue Snow     [2]", 0.8,  1,   -150, {0,0,0},   {{212, 9, {50,90,135}, 4}, {125, 20, {170,180,165}, 3}} },
           {"Minty         [2]", 1,    1,      0, {0,8,16},  {{85, 30, {150,170,30}, 4}, {40, 15, {40,90,160}, 5}} },
           {"Kola          [2]", 1.1,  1,      0, {0,0,0},   {{162, 8, {177,117,53}, 2}, {28, 33, {100,110,200}, 11}} },
           {"Purple Haze   [3]", 1,    1,      0, {0,16,16}, {{300, 40, {50,100,180}, 6}, {120, 35, {250,160,190}, 3}, {60, 25, {30,20,35}, 2.0}} },
           {"Sweet Reds    [4]", 1.5,  1,   -140, {0,0,0},   {{97, 45, {167,171,244}, 8}, {297, 56, {252,112,59}, 3}, {53, 33, {268,69,85}, 7}, {243, 81, {256,8,94}, 5}} },
           {"Green Dream   [6]", 0.35, 1,      0, {4,0,4},   {{339, 25, {219,198,34}, 11}, {182, 27, {222,152,149}, 9}, {271, 19, {109,186,78}, 8}, {21, 49, {234,126,84}, 12}, {2, 44, {104,160,207}, 3}, {107, 53, {132,233,244}, 2}} }
          }, 

   title = "Preset Light Scenes",
   markselected = 0,
   selected = 0, -- "Action buttons" only, selection erased after use
   menu = (function() 
            local v,sel 
            ia_.Menu(Prelights)
            if Prelights.selected > 0 then 
             v=Prelights.list[Prelights.selected]; Prelights.selected = 0
             if #v>1 then 
              O.LS=tableCopy(v[6]); O.AMP=v[2]; O.HARDNESS=v[3]; O.GROT=v[4]; O.FC=tableCopy(v[5]);
             end
            end 
           end
          )
}


--
function randomizeLights()
 local f,m,n,ls,floor,exp,num,el
 --f = io.open("lightsource.txt", "w");
 m = math.random
 floor = math.floor
 ls = {}
 --num = m(1,6)
 num = 2 - m(0,1) + m(0,m(0,4))
 --num = 1
 for n = 1, num, 1 do
  -- Exp=1 only for single lights, More lights = greater average exponent (less diffuse lights, darker)
  exp = 5 - m()*(4- (1-floor((7-num)/6)) ) + m()*m()*(10+num)

  el = floor(5 + m()*m()*(61 + num*4)) -- Avoid lowest elevations for singe/few lights scenes (can get too dark)
  --el = 70

  if num == 1 then 
    exp = math.min(exp,4 - math.floor(el/27))  -- 4 is the highest exponent for single lights, 1-3 with lower elevation
  end

  ls[n] = {floor(m()*360), el, {floor(m()*255),floor(m()*255),floor(m()*255)},floor(exp)}
  --f:write(db.ary2txt(ls[n]).."\n")
 end
 --saveLights(ls)
 --f:close()
 return ls
end
--


-- {{-45, 20, {265,255,208}, 7}},
--
function saveLights(ls)
 local f,n,t,q,fil
 ls = ls or O.LS
 fil = "lightsource.txt"
 f = io.open(fil, "w");
 t = "O.LS = {"
 for n = 1, #ls, 1 do
  q = ls[n]
  t = t.."{"..q[1]..", "..q[2]..", {"..q[3][1]..","..q[3][2]..","..q[3][3].."}, "..q[4].."}" 
  if #ls>1 and n<#ls then t = t..",\n"; end
 end 
 t = t.."}"
 f:write(t)
 f:close()
 messagebox("Information","Lights were saved as file:\n\n"..fil)
end
--

-- Figure out a suitable Luminance value for the lights
function calcLightNormalizer(ls)
 local bri,n,l,nom

 nom = 208
 bri = 0
 if #ls > 0 then 
  for n = 1, #ls, 1 do
   l = ls[n]
   bri = bri + (1/(l[4]^0.2) * math.cos(l[2]*math.pi/180)^0.75 * ((l[3][1]^2 + l[3][2]^2 + l[3][3]^2) / 3)^0.5)
  end
  if bri < nom then bri = nom - (nom-bri)^0.92; end -- Less effect when brightening (Bright scenes are the real problem)
  return (nom / math.max(1,bri))
   else return 1
 end
 
end
--

--
function setbasecolor()
 local dummy, ok
 ok, dummy, O.FC[1], O.FC[2], O.FC[3] = inputbox("Lights: Base Color",
  "- Base Color of Surfaces -",0,0,0,4,
  "Red:   0-255", O.FC[1],-128,255,1,
  "Green: 0-255", O.FC[2],-128,255,1,  
  "Blue:  0-255", O.FC[3],-128,255,1                                                    
 );
end
--

--
function lights_settings()
 local dummy, ok
 ok, O.HARDNESS, O.AMP, O.GROT = inputbox("Lights: Global Properties",
  "Hardness:  0..5", O.HARDNESS,0,5,2,
  "Luminance: 0..2", O.AMP,0,20,2,
  "Rotation: -180..180", O.GROT,-180,180,1                                                    
 );
end
--

--   Az      El 
-- {{157.5, 30, {260,255,220}, 3.0}}
--
function lights_lights_set(n)
  local dummy, ok, r,g,b, l, az, el, ex, remove

  if n > #O.LS then -- New Light (n will always be #O.LS+1 here)
   --O.LS[n] = {settings.new_azimuth, settings.new_elevation, settings.new_rgb, settings.new_exponent}
   l = settings
   r = l.new_rgb[1]
   g = l.new_rgb[2]
   b = l.new_rgb[3]
   az = l.new_azimuth
   el = l.new_elevation
   ex = l.new_exponent
    else
      l = O.LS[n]
      r = l[3][1]
      g = l[3][2]
      b = l[3][3]
      az = l[1]
      el = l[2]
      ex = l[4]
  end

  ok, az,el,r,g,b,dummy,ex, remove = inputbox("Lights: Set Light "..n,
   "Azimuth:   0-360", az,-360,360,2,
   "Elevation: 0-90", el,0,90,2,
   "R: 0-255", r,0,384,1,
   "G: 0-255", g,0,384,1,
   "B: 0-255", b,0,384,1,
   "Softness/Specularity Character", 0,0,0,4,
   "Exponent:  0.5-20", ex,0.5,20,3,
   "!Remove this Light!", 0,0,1,0                                              
  );
 if ok then
  if remove == 0 then
   if n > #O.LS then O.LS[n] = {}; l = O.LS[n]; end -- New Light
   l[1] = az
   l[2] = el
   l[3] = {r,g,b} 
   l[4] = ex
    else
      table.remove(O.LS,n)
  end
 end
end
--

--
function lightText(n)
 local l,r,g,b,az,al,ex,t
      l = O.LS[n]
      r = l[3][1]
      g = l[3][2]
      b = l[3][3]
      az = l[1]
      el = l[2]
      ex = l[4]

  t = " ("..math.floor(az)..":"..math.floor(el)..":"..db.rgb2HEX(r,g,b,"")..":"..math.floor(ex)..")"

  return t
end
--

--
function lights_lights()
 local do_selbox,title,args,i
 
 do_selbox = true
 while do_selbox do

  math.randomseed( os.time() )

  title = "Lights: Lights (Lum="..O.AMP..")"
 args,i = {},1
 for n = 1, #O.LS, 1 do
  args[i] = "Light "..n..lightText(n); i=i+1
  args[i] = (function() lights_lights_set(n); end); i=i+1
 end
 if #O.LS < settings.MAX_LIGHTS then
  args[i] = "<ADD LIGHT>"; i=i+1
  args[i] = (function() lights_lights_set(#O.LS+1); end); i=i+1
 end
 args[i] = "<Randomize Lights>"; i=i+1
 args[i] = (function() O.LS = randomizeLights(); O.AMP = db.format(calcLightNormalizer(O.LS),2); end); i=i+1

 args[i] = "RENDER>>"; i=i+1
 args[i] = (function() launch(); end); i=i+1

 --args[i] = "{Preset Lights}"; i=i+1
 --args[i] = Prelights.menu; i=i+1

 --args[i] = "<Save Lights to File>"; i=i+1
 --args[i] = (function() saveLights(O.LS); end); i=i+1

 args[i] = BACK_TXT; i=i+1
 args[i] = (function() do_selbox = false; end); i=i+1 

   selectbox(title,unpack(args));
 end
end
--

--
function lights_load()
 local f
 f = loadfile("lightsource.txt")
 if (f ~= nil) then
  dofile("lightsource.txt")
  messagebox("'lightsource.txt' was successfully loaded!")
   else messagebox("Lights not loaded! \n\nNo valid 'lightsource.txt' file was found")
 end
end
--

--
function lights_menu()
 local do_selbox,lrand

 do_selbox = true
 while do_selbox do
  lrand = "NO"; if O.RNDLIGHT then lrand = "YES"; end
  selectbox("Lights", 
   "LIGHTS ("..#O.LS..")", lights_lights,
   "Global Properties", lights_settings,
   "Set Base Color", setbasecolor,
   "{Preset Light Scenes}", Prelights.menu,
   "<File: Load Lights>", lights_load,
   "<File: Save Lights>", saveLights,
   --"Randomize Light: "..lrand, (function() O.RNDLIGHT = not O.RNDLIGHT; end), 
   BACK_TXT,function() do_selbox = false; end                                                      
  );
 end
end
--


----- SCENE LOADING -------------------------


-- Update active settings in the interface when loading a scene
function updateMenuSettings()
 O.LASTSEED = O.PSEED
 add_funcs.selected = O.ADD_FUNC + 1
 alt_funcs.selected = O.ALT_FUNC + 1
 Textures.selected = (O.TEXTURE or 0) + 1
 Bump.selected = (O.BUMP_TEXTURE or 0) + 1
end
--

-- Changes done when loading a new scene/preset
function loadSceneInfo()
 O = copyLS_object(Scenes.list[Scenes.selected][2]); Scenes.selected = 0 -- Remove scene selection (stops loading when esc scene-menu)
 updateMenuSettings()
end
--

--
function scene_load()
 local f
 f = loadfile("scene.txt")
 if (f ~= nil) then
  dofile("scene.txt")
  messagebox("'scene.txt' was successfully loaded!")
  updateMenuSettings()
   else messagebox("Scene not loaded! \n\nNo valid 'scene.txt' file was found")
 end
end
--

-----------------------------------------------------

--
function scene_save(o)
 local f,n,t,q,fil,r
 
 o = o or O

 fil = "scene.txt"
 f = io.open(fil, "w");
 r = ",\n " 
 t = "O = {\n\n "

 t = t.."-- Isometrics -------------------\n "
 t = t.."ISOMODE = "..o.ISOMODE..r 
 t = t.."VSCALE = "..o.VSCALE..r 
 t = t.."BASELINE = "..o.BASELINE..r 
 t = t.."YPLOTS = "..o.YPLOTS..r

 t = t.."\n-- Lights -----------------------\n "
 t = t.."HARDNESS = "..o.HARDNESS..r
 t = t.."AMP = "..o.AMP..r
 t = t.."GROT = "..o.GROT..r       
 t = t.."RNDLIGHT = false"..r -- Disabled   
 t = t.."FC = {"..o.FC[1]..", "..o.FC[2]..", "..o.FC[3].."}"..r
 t = t.."LS = {"
 for n = 1, #o.LS, 1 do
  q = o.LS[n]
  t = t.."{"..q[1]..", "..q[2]..", {"..q[3][1]..","..q[3][2]..","..q[3][3].."}, "..q[4].."}" 
  if #o.LS>1 and n<#o.LS then t = t..", "; end
 end 
 t = t.." },\n"

 t = t.."\n-- Perlin -----------------------\n "
 t = t.."OCTAVES   = "..o.OCTAVES..r 
 t = t.."PERSIST   = "..o.PERSIST..r
 t = t.."FREQ_MULT = "..o.FREQ_MULT..r
 t = t.."FREQ_BASE = "..o.FREQ_BASE..r
 t = t.."MULTIPLY  = "..o.MULTIPLY..r
 if type(o.IP_FUNC) == 'table' then 
  t = t.."IP_FUNC = "..o.IP_FUNC[1]..r -- Get the function name (string) {"function name", function_ref}
   else 
    t = t.."IP_FUNC = ip_.kenip"..r
 end

 t = t.."\n-- Map --------------------------\n "
 t = t.."PSEED   = "..o.PSEED..r
 t = t.."OFFSETX = "..o.OFFSETX..r
 t = t.."OFFSETY = "..o.OFFSETY..r
 t = t.."ZOOM    = "..o.ZOOM..r
 t = t.."\n "
 t = t.."AUTOMATA = "..o.AUTOMATA..r
 t = t.."MAP_ERODE_FREQ = "..o.MAP_ERODE_FREQ..r
 t = t.."MAP_ERODE_POW  = "..o.MAP_ERODE_POW..r

 t = t.."\n-- Visuals ----------------------\n "
 t = t.."MAKEPAL_FLAG = "..tostring(o.MAKEPAL_FLAG)..r

 t = t.."ADD_R0 = "..o.ADD_R0..r 
 t = t.."ADD_G0 = "..o.ADD_G0..r 
 t = t.."ADD_B0 = "..o.ADD_B0..r 
 t = t.."ADD_R1 = "..o.ADD_R1..r 
 t = t.."ADD_G1 = "..o.ADD_G1..r 
 t = t.."ADD_B1 = "..o.ADD_B1..r 
 t = t.."ADD_FUNC = "..o.ADD_FUNC..r 
 t = t.."ALT_FUNC = "..o.ALT_FUNC..r
 t = t.."ALT_LEVEL = "..o.ALT_LEVEL..r
 t = t.."\n "
 t = t.."TEXTURE      = "..o.TEXTURE..r 
 t = t.."TEXTURE_STR  = "..o.TEXTURE_STR..r
 t = t.."TEXTURE_FREQ = "..o.TEXTURE_FREQ..r
 t = t.."\n "
 t = t.."HAZE_POW   = "..o.HAZE_POW..r
 t = t.."HAZE_BASE  = "..o.HAZE_BASE..r
 t = t.."HAZE_EXP   = "..o.HAZE_EXP..r
 t = t.."HAZE_DMULT = "..o.HAZE_DMULT..r
 t = t.."HAZE_VMULT = "..o.HAZE_VMULT..r
 t = t.."HAZE_R = "..o.HAZE_R..r
 t = t.."HAZE_G = "..o.HAZE_G..r
 t = t.."HAZE_B = "..o.HAZE_B..r
 t = t.."\n "
 t = t.."BUMP_TEXTURE = "..o.BUMP_TEXTURE..r
 t = t.."BUMP_FREQ    = "..o.BUMP_FREQ..r
 t = t.."BUMP_HEIGHT  = "..o.BUMP_HEIGHT..r
 t = t.."BUMP_DETAILBALANCE = "..o.BUMP_DETAILBALANCE..r
 t = t.."BUMP_DISTFADE = "..o.BUMP_DISTFADE..r
 t = t.."BUMP_LEVEL_LO = "..o.BUMP_LEVEL_LO..r
 t = t.."\n\n "
 t = t.."dummy = 0\n"

 t = t.."\n}"
 f:write(t)
 f:close()
 messagebox("Information","Scene was saved as file:\n\n"..fil)
end
--

-- p = {}
--    ia_.AddItem2Package(p, "TEXTURE: "..Textures.list[Textures.selected][1], Textures.menu)
-- selectbox("Texture", unpack(p)) 

--selectbox("Scenes", 
--   "{Preset Scenes}", Scenes.menu,
--   "<File: Load Scene>", scene_load,
--   "<File: Save Scene>", scene_save, 
--   BACK_TXT,(function() do_selbox = false; end)                                                      
--  );

--
function scenes_menu()
 local do_selbox,load_exist,f,p
 do_selbox = true

 while do_selbox do
  p = {}
 
 --[[
  load_exist = false
  f = loadfile("scene.txt")
  if (f ~= nil) then
   load_exist = true
  end
  f = nil
 --]]

  ia_.AddItem2Package(p, "{Preset Scenes}", Scenes.menu)
  --if load_exist then
   ia_.AddItem2Package(p, "<File: Load Scene>", scene_load)
  --end
  ia_.AddItem2Package(p, "<File: Save Scene>", scene_save)
  ia_.AddItem2Package(p, BACK_TXT, (function() do_selbox = false; end))

  selectbox("Scenes", unpack(p)) 
 end
end
--


--
function launch()
 O.TEXT = Prefs.text -- Write text to screen (O.TEXT is not part of original data (or saved), the prefs is just parsed this way)
 O.CLEAR_HAZE = Prefs.clear_haze
 core(O)
end
--



--
function boxer()
  local do_selbox, isotxt, maptxt, ligtxt, pertxt, vistxt,vis0,vis1, mapadd, spc, quit

  --
  function quit()
   selectbox("Really Quit?",
     "[YES, QUIT!]", (function() do_selbox = false; end),
     "[NO, KEEP WORKING!]", (function() do_selbox = true; end)
   );
  end
  --

  loadSceneInfo()

  do_selbox = true
  while do_selbox do

   math.randomseed( os.time() ) -- Perlin Noise may have set a seed, causing the same sequence to repeat

   pertxt = "Perlin (o"..O.OCTAVES..")"
   if O.MULTIPLY == 0 then pertxt = "(Perlin)"; end
   ligtxt = "Lights ("..#O.LS..")"
   isotxt = "Isometrics"; if O.ISOMODE == 0 then isotxt = "(Isometrics)"; end
   
   mapadd = "("
   maptxt = "Map" 
   spc = ""
   if O.PSEED == -1 then mapadd = mapadd.."Rnd"; spc=" "; end
   if O.ZOOM ~= 1.0 then mapadd = mapadd..spc.."x"..O.ZOOM; end
   if #mapadd > 1 then mapadd = mapadd..")"; maptxt = maptxt.." "..mapadd; end
 
   vis0,vis1 = "",""
   if O.MAKEPAL_FLAG or O.TEXTURE > 0 or O.ADD_FUNC > 0 or O.ALT_FUNC > 0 or O.HAZE_POW >0 or O.BUMP_TEXTURE > 0 then vis0,vis1 = "(",")"; end
   vistxt = "Visuals "..vis0
   if O.MAKEPAL_FLAG then vistxt = vistxt.."P"; end
   if O.ALT_FUNC > 0 then vistxt = vistxt.."-"; end
   if O.ADD_FUNC > 0 then vistxt = vistxt.."/"; end
   if O.HAZE_POW > 0 then vistxt = vistxt.."H"; end
   if O.TEXTURE  > 0 then vistxt = vistxt.."T"; end
   if O.BUMP_TEXTURE > 0 then vistxt = vistxt.."B"; end
   vistxt = vistxt..vis1

   selectbox("# LandScaper",
     ligtxt, lights_menu, 
     isotxt, isometrics,
     pertxt, perlin_menu,
     maptxt, map,
     vistxt, visuals_menu,
     "RENDER >>", launch,
     ":Scenes:", scenes_menu,
     "[DONE/QUIT]", quit
   );
  end

end
--

boxer()



--for x = 0, 99, 1 do 
--updatescreen();if (waitbreak(1)==1) then return end ;end


 


