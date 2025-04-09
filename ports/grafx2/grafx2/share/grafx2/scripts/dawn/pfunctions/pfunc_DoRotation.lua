---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--  DoRotation V2.0
--
--  Program-Function (pfunction) - Dependencies: dawnbringer_lib.lua, db_interpolation.lua
--
--  by Richard 'DawnBringer' Fhager (dawnbringer@hem.utfors.se)
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--
-- Rotate Image or Brush
-- 
--
-- Usage:
-- dofile("pfunc_DoRotation.lua")(args..)
-- or
-- myfunc = dofile("pfunc_DoRotation.lua"); myfunc(args..)
--
--
-- Arguments: 
--
-- target:     1 = Brush, 2 = Picture, 3 = Brush-to-Picture
-- rot:        Rotation in degrees, + is clockwise
-- ipmode:     0 = None (Simple/Sharp), 1 = 2*Cos (mid), 2 = Ken P., 3 = Cos, 4 = Linear, 5 = Bicubic
-- spritemode: 0 = Off, 1 = On (Only match adjacent colors, use with Bilinear-Ip. for good result)
-- resize:     0 = No, 1 = Yes (Resize Image/Brush to fit all gfx, otherwise clip)
-- update:     0 = No, 1 = Yes (Update screen while drawing)
-- xoffset:    For use with Brush-to-Picture operations
-- yoffset:    For use with Brush-to-Picture operations
-- gamma:      Gamma for Bilinear interpolations [Optional] (1.0-2.2)
--
---------------------------------------------------------------------------------------

 
 dofile("../libs/db_interpolation.lua") -- prefix: ip_
 dofile("../libs/dawnbringer_lib.lua")


return function(target,rot,ipmode,spritemode,resize,update, xoffset,yoffset, gamma)

 local trg,f,w,h,x,y,r,g,b,c,hub_x,hub_y,x1,y1,x2,y2,x3,y3,x4,y4,dX,dY,dXs,dYs,ox,oy,mx,my,xp,yp,pallist
 local pal,func,ipfunctions,ip_func,ip_txt,m

 m = math

 gamma = gamma or 1.6

 pallist = db.makePalList(256)
 pallist = db.fixPalette(pallist,1) -- Adds Double data etc

 -- Interpolation functions, in order of sharp-->smooth
 ipfunctions = {{ip_.midip, "IP: 2*Cos (Sharp)"}, 
                {ip_.kenip, "IP: Ken P. (Medium)"}, 
                {ip_.cosip, "IP: Cos (Medium+)"}, 
                {ip_.linip, "IP: Linear (Smooth)"},

                {ip_.cubip, "IP: BiCubic"}
               } 
 ip_text = "Nearest Neighbour"
 if ipmode > 0 then
  ip_func = ipfunctions[ipmode][1]
  ip_text = ipfunctions[ipmode][2]
 end

 function donothing(n)
 end

func = {
 {getsize=getbrushsize,   setsize=setbrushsize,   clear=donothing,    get=getbrushbackuppixel, put=putbrushpixel},
 {getsize=getpicturesize, setsize=setpicturesize, clear=clearpicture, get=getbackuppixel,      put=putpicturepixel},
 {getsize=getbrushsize,   setsize=donothing,      clear=donothing,    get=getbrushbackuppixel, put=putpicturepixel}
}
trg = func[target]

 f = db.rotationFrac
 w,h = trg.getsize()
 hub_x = w / 2 - 0.5 -- Rotates 90,180 perfectly, not 45
 hub_y = h / 2 - 0.5
 --hub_x = w / 2
 --hub_y = h / 2
 x1,y1 = f (-rot,hub_x,hub_y,0,0) -- Rot is negative coz we read destination and write to source
 x2,y2 = f (-rot,hub_x,hub_y,w-1,0)
 x3,y3 = f (-rot,hub_x,hub_y,0,h-1)
 x4,y4 = f (-rot,hub_x,hub_y,w-1,h-1)
 dX  = (x2 - x1) / w
 dY  = (y2 - y1) / w
 dXs = (x4 - x2) / h
 dYs = (y3 - y1) / h

 adjx,adjy = 0,0
 ox,oy = 0,0
 if resize == 1 then
  mx = m.ceil(m.max(m.abs(x1-hub_x),m.abs(x3-hub_x))) * 2 + 2
  my = m.ceil(m.max(m.abs(y1-hub_y),m.abs(y3-hub_y))) * 2 + 2
   if target == 3 then -- Center gfx at Brush-to-Picture
    adjx = -mx/2
    adjy = -my/2
   end
  ox = (mx - w) / 2
  oy = (my - h) / 2
  trg.setsize(mx,my)
 end

 trg.clear(0)

 for y = -oy, h-1+oy, 1 do
   for x = -ox, w-1+ox, 1 do
    
    xp = x1 + dX * x + dXs * y 
    yp = y1 + dY * x + dYs * y 

   -- Don't fetch pixels outside image (brush noise), but allow 1 pixel border for AA
   if xp > -1 and xp <= w and yp > -1 and yp <= h then

    if ipmode > 0 then
       --r,g,b,pal = bilinear(xp,yp,w,h,trg.get, mode_co) -- removed, look in 150102 backup

       if ipmode == 5 then 
        r,g,b = ip_.pixelRGB_Bicubic(xp,yp,getcolor,trg.get,ip_.cubip)
         else
          --r,g,b, pal = ip_.pixelRGB_Bilinear_PAL(xp,yp,getcolor,trg.get,ip_func) -- ipmodes 1,2,3 & 4
          -- Gamma version
          r,g,b, pal = ip_.pixelRGB_Bilinear_PAL_gamma(xp,yp,getcolor,trg.get,ip_func, gamma) -- ipmodes 1,2,3 & 4
        end

      if spritemode == 1 and ipmode ~= 5 then -- Bicubic doesn't support spritemode right now
       c = db.getBestPalMatchHYBRID({r,g,b},pal,0.65,true) -- Brightness do very little in general with 4 set colors
        else 
         c = matchcolor2(r,g,b)
         --c = db.getBestPalMatchHYBRID({r,g,b},pallist,0.25,true) 
      end
       else c = trg.get(xp+0.5,yp+0.5) -- +0.5 for proper rounding
    end -- ipmode > 0


--[[
-- Fractional Sampling (for rotations) is pretty much equivalent to Bilinear IP (mode4), maybe maybe a tiiiny bit better,
-- ...but not enough to warrant implementing(?) (esp. as it's so much slower)
c = matchcolor2(ip_.fractionalSampling(8, xp,yp, w,h, (function(ox,oy,w,h) return getcolor(trg.get(ox*w+0.5,oy*h+0.5)); end), 1.6))
--]]

     trg.put(x+ox+xoffset+adjx,y+oy+yoffset+adjy, c)
   end -- within original image
   
  end 
   if update == 1 and m.abs(m.floor(y))%10 == 0 then
    statusmessage(ip_text.." %"..m.floor(((y+oy) / (h-1+2*oy))*100))
    updatescreen(); if (waitbreak(0)==1) then return; end
   end
 end

end; -- doRotation

