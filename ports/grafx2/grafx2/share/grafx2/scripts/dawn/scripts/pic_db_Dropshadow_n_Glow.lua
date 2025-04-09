--PICTURE/LAYER: DropShadow / Glow  V0.51
--for Layer or Single image with transpcol as bkg
--by Richard Fhager

-- Effect is applied to the graphics of the current layer and interpolated with the background 
-- (shadow is drawn on current layer). If there are no layers, the selected color
-- in layers-menu is treated as the transparency/background of the image. 
--
-- Note: There is currently no code stopping the transp-color to be selected by color-matching
-- so it may be a good idea to set this color to one far different from anything like the shadow/glow.
--
-- Tip: For glow-effects, set offsets to 0 and ramp up strength to 3 or so (and use positive colors)
--

 RAD      = 7		    -- Radius (increase for smothness and size)
 POWER    = 5.0	    	    -- Strength
 DSCALE   = 0.25            -- Distance scaling: >1 = Sharper, <1 = Smoother (effects halo as well)
 RC,GC,BC = 0,0,0  	    -- Shadow/Glow color/balance 
 XO       = 0               -- Offset, is negative right now 
 YO       = 0

 -- With no shadow/glow set to 0,0,0 these are the same
 --HALO_MODE = "subtract" -- Reduce with glow/pixel diff (Will not be used with interface since there's not enough room)
 HALO_MODE  = "additive" -- "Selfglow", add pixel value (Used as default halo-mode with interface)

 HALO_EXP = 3.0 -- 1.0 - 5.0 Higher mean only pixels closer to edge will have an impact, high = AA, low = halo
 HALO_POW = 4.0  -- 0 turns off
 -- Ex. exp 2 and pow 5 will create a weak ghostly distant halo
 --         5 and pow 1 will create a tight nice AA

 INTPOL = 12 -- Internal interpolation, 0 = off, 4 is nominal, 1 is strongest, higher mean weaker

 RC,GC,BC = 128,128,128
 
  -- 1 / base^([distance])^exp
  -- Note that fall-off less than inverse square may cause articfacts
  -- Ex: Two parallell lines at a distance of [radius] may exhibit a bright midway-line
  -- that is, the power of 2 lines at r is greater than 1 line at r-1 
  BASE = 2 --  Nominal 2, Less = Smoother fall-off, not so fast and sharp
  EXP  = 0.5 -- Fall-off exponential, nominal = 0.5 (inverse square) Less = longer fall-off

CF = getforecolor()
CB = getbackcolor()
CT = gettranscolor()

w, h = getpicturesize()

min,max = math.min, math.max

function cap(v) return min(255,max(0,v)); end

--
function dropglow(rad,power,dscale,rc,gc,bc,xo,yo,halo_mode,halo_exp,halo_pow,intpol, base,exp) 

 done = {}; for y = 0, h - 1, 1 do done[y+1] = {};end

 -- Calculate matrix-sum
 shd = 0
 for my = -rad, rad, 1 do
  for mx = -rad, rad, 1 do
    pow = (1 / base^(((mx*mx + my*my)*dscale)^exp))
    shd = shd + pow
  end
 end
 div = shd
 --messagebox("radius "..rad.." has matrixsum: "..div)

divpow = 1 / div * power

for y = 0, h - 1, 1 do
 for x = 0, w - 1, 1 do

  if getlayerpixel(x, y) == CT then

  ri,gi,bi,shd = 0,0,0,0
  for my = -rad, rad, 1 do
   my2 = my*my
   yp = y+yo+my
     for mx = -rad, rad, 1 do
      xp = x+xo+mx
      lp = getlayerpixel(xp, yp)
      if lp ~= CT and done[yp+1][xp+1] ~= 1 then -- Not transp & not shadow (Note code: done[outside] would fail if ~= CT wouldn't break on outside screen)
       pow = 1 / base^(((mx*mx + my2)*dscale)^exp)
       shd = shd + pow
       ph  = pow^halo_exp
       r,g,b = getcolor(lp)
       if halo_mode == "subtract" then
        ri = ri + (r - rc) * ph
        gi = gi + (g - gc) * ph
        bi = bi + (b - bc) * ph
       end
       if halo_mode == "additive" then
        ri = ri + r * ph
        gi = gi + g * ph
        bi = bi + b * ph
       end
      end
   end
  end

  --shd = shd / div * power
  shd = shd * divpow

  if shd ~= 0 then
    cor = halo_pow * shd
    r,g,b = getcolor(getpicturepixel(x,y))
    rs = cap(r + rc*shd + ri*cor)
    gs = cap(g + gc*shd + gi*cor)
    bs = cap(b + bc*shd + bi*cor)

     -- Interpolate glow pixels adjacent to gfx
     if intpol ~= 0 then
       bas = intpol -- Power of center pixel, higher means less interpolation, nominal is 4
       tot = bas
       rt,gt,bt = 0,0,0
       c = getlayerpixel(x-1, y); if c ~= CT and done[y+1][x]   ~= 1 then tot = tot + 2; r1,g1,b1 = getcolor(c); rt = rt + r1*2; gt = gt + g1*2; bt = bt + b1*2; end
       c = getlayerpixel(x+1, y); if c ~= CT and done[y+1][x+2] ~= 1 then tot = tot + 2; r1,g1,b1 = getcolor(c); rt = rt + r1*2; gt = gt + g1*2; bt = bt + b1*2; end
       c = getlayerpixel(x, y-1); if c ~= CT and done[y][x+1]   ~= 1 then tot = tot + 2; r1,g1,b1 = getcolor(c); rt = rt + r1*2; gt = gt + g1*2; bt = bt + b1*2; end
       c = getlayerpixel(x, y+1); if c ~= CT and done[y+2][x+1] ~= 1 then tot = tot + 2; r1,g1,b1 = getcolor(c); rt = rt + r1*2; gt = gt + g1*2; bt = bt + b1*2; end
       
       c = getlayerpixel(x-1, y-1); if c ~= CT and done[y][x]     ~= 1 then tot = tot + 1; r1,g1,b1 = getcolor(c); rt = rt + r1; gt = gt + g1; bt = bt + b1; end
       c = getlayerpixel(x+1, y-1); if c ~= CT and done[y][x+2]   ~= 1 then tot = tot + 1; r1,g1,b1 = getcolor(c); rt = rt + r1; gt = gt + g1; bt = bt + b1; end
       c = getlayerpixel(x-1, y+1); if c ~= CT and done[y+2][x]   ~= 1 then tot = tot + 1; r1,g1,b1 = getcolor(c); rt = rt + r1; gt = gt + g1; bt = bt + b1; end
       c = getlayerpixel(x+1, y+1); if c ~= CT and done[y+2][x+2] ~= 1 then tot = tot + 1; r1,g1,b1 = getcolor(c); rt = rt + r1; gt = gt + g1; bt = bt + b1; end
    
       rs = (rs*bas + rt) / tot
       gs = (gs*bas + gt) / tot
       bs = (bs*bas + bt) / tot
     end

    putpicturepixel(x, y, matchcolor(rs, gs, bs));
   
    done[y+1][x+1] = 1
  end  

 end -- if CT  

 end -- x
 statusmessage("Done: "..math.floor(y*100/h).."%")
 updatescreen(); if (waitbreak(0)==1) then return; end
end -- y

end -- dropglow



-- Interface

IPLIST = {0, 24, 12, 9, 6, 4, 2} -- Interpolation matrix weights: off(0) --> strongest(2)
DSCALELIST = {100, 5, 2, 1, 0.5, 0.25, 0.10, 0.02} -- Distance scaling

function drop() -- Apparently needed so we can can exit everything
 DCin = 4 -- 1
 IPin = 1 -- 0
 OK,RC,GC,BC,POWER,RAD,dc,XO,YO,ip   = inputbox("Drop Shadow",
                        
                           "R", -128,  -1000,1000,0, 
                           "G", -128,  -1000,1000,0,
                           "B", -128,  -1000,1000,0,  
                           "Power: 0.0-10.0",  1.0,  0,10,1, 
                           "Radius: 1-30",   3,  1,30,0, 
                           "Softness: 0-7", (DCin-1),  0,7,0, 
                           "X-Offset", 5,  0,100,0,  
                           "Y-Offset", 5,  0,100,0, 
                           "Interpolation: 0-6", (IPin-1),  0,6,0 
                           --"Preserve Brightness", 1,  0,1,0,
                                                                             
 );

 if OK == true then
  dropglow(RAD,POWER,DSCALELIST[dc+1],RC,GC,BC,-XO,-YO, HALO_MODE,HALO_EXP,0,IPLIST[ip+1], BASE,EXP)
  else main()
 end
end

function glow() -- Apparently needed so we can can exit everything
  DCin = 6 -- 0.25
  IPin = 4 -- 9
  OK,RC,GC,BC,POWER,RAD,dc,HALO_POW,HALO_EXP,ip   = inputbox("Glow",
                        
                           "R", 192,  -1000,1000,0, 
                           "G", 192,  -1000,1000,0,
                           "B", 192,  -1000,1000,0,  
                           "Power: 0.0-10.0",  2.0,  0,10,1, 
                           "Radius: 1-30",   3,  1,30,0, 
                           "Softness: 0-7", (DCin-1),  0,7,0, 
                           "SelfGlow Power: 0.0-10.0", 1.0,  0,10,1,  
                           "SelfGlow Fade: 1.0-5.0", 3.5,  1,5,1, 
                           "Interpolation: 0-6", (IPin-1),  0,6,0 
                           --"Preserve Brightness", 1,  0,1,0,
                                                                             
 );

 if OK == true then
  dropglow(RAD,POWER,DSCALELIST[dc+1],RC,GC,BC,0,0, HALO_MODE,HALO_EXP,HALO_POW,IPLIST[ip+1], BASE,EXP)
  else main()
 end
end

function _quit()
 -- nada
end

function _info()
 local t
 
 t = "* The color selected in the Layers menu is the working transparency\n\n"
 t = t.."* Scripts will operate on active layer and interpolate with background (if using layers)\n\n"
 t = t.."* Transp-col may be selected by color-match, so set it to an odd color to prevent."
 messagebox("Info", t)
 main()
end

function main()
selectbox("DropShadow & Glow v0.51", 
  "Drop Shadow (i,l)", drop,
  "Glow (i,l)", glow,
  "[Info]", _info,
  "[Quit]", _quit -- We cannot go back to the DB ToolBox from here
 
);
end

main()



--dropglow(RAD,POWER,DSCALE,RC,GC,BC,XO,YO, HALO_MODE,HALO_EXP,HALO_POW,IPLIST[IP], BASE,EXP) 


