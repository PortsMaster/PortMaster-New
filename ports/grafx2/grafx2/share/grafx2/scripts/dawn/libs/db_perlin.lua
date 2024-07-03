---------------------------------------------------
---------------------------------------------------
--
--            Perlin Noise Library
--              
--                    V1.1
-- 
--               Prefix: perlin.
--
--        by Richard 'DawnBringer' Fhager
--                                   
--        Email: dawnbringer@hem.utfors.se
--               dawnbringer@bahnhof.se
--
---------------------------------------------------
---------------------------------------------------

-- Abstract:
--  Functions for generating 2D Perlin Noise

-- Note:
--  Interpolation functions (ip_func) are not included, use the db_interpolation library.
--  Except for the optimized & hardcoded function: perlin.perlinNoise2D_layer


-- History:
-- v1.1 Added a function for wrapping/tiling perlin-noise (getPerlinNoise2D_point_WRAP)

---------------------------------------------------



perlin = {}


-- NOTE!!! This info isn't updated, internal ip-functions are disabled, interpolation-library is used.
-- Should we keep this semi-dependency or re-activate the (redundant) internal ip's?

--w,h = getpicturesize()
--
--octaves   = 8     -- Octaves, Layers (Nominal 8, higher persistence may need more octaves for detail)
--persist   = 0.5   -- Persistence (Roughness): Nominal 0.5, Lower means later octaves will have reduced strength = Smoother
--freq_mult = 4.0   -- Frequency: Lower means "zoom-in" / enlarge
--freq_base = 2.0   -- "Scale Change": Nominal = 2.0. Lower = Softer, Less detail by octave, higher = more grain, "Zoom-out (>1.0) speed by octave"
-- Post effects
--multiply  = 1.25  -- Multiply/Contrast (for Clouds scenes etc.)
--balance   = 0     -- Octave output balance, ex: for high contrast, like Clouds, use something like balance -64 and mult = 2
--
--ip_func   = perlin.kenip -- kenip, cosip, linip, cirip
---

-- Ex1. (Optimized. Generate complete matrix, hardcoded interpolation (ken))
--perlin.setGradientPal()
--map = perlin.MakeMap(256,0) -- size, rnd seed (if >0)
--mtx = perlin.perlinNoise2D_layer(w,h,map, octaves, persist, freq_mult, freq_base, true) -- last is update flag 
--perlin.RenderMap(mtx,multiply,balance) -- Map,Mult,Balance (-255 to 255)

-- Ex2.
--[[ -- Point by Point example (note: rnd seed won't produce the same result as with layer versions)
  xf = 1 / w
  yf = 1 / h
  map = perlin.MakeMap(256,0)
  for y = 0, h-1, 1 do
   for x = 0, w-1, 1 do
    c = perlin.getPerlinNoise2D_point(x * xf, y * yf, map, octaves, persist, freq_mult, freq_base, ip_func) * 127.5 * multiply + 127.5
   putpicturepixel(x,y,c)
  end
  updatescreen();if (waitbreak(0)==1) then return end
 end
--]]

-- Ex3. Clean, for testing. No multiply/contrast.
--map = perlin.MakeMap(256,0) -- size, rnd seed (if >0)
--map = perlin.SmoothMap(map)
--perlin.doPerlinNoise2D(w,h,map, octaves, persist, freq_mult, freq_base, ip_func, multiply) 



---------------------------
-- Interpolation methods --
---------------------------

--[[ -- Inactivated, remove and only use Interpolation lib?

-- Narrow cosine, very sharp, only interpolate in the 50% midrange
function perlin.midip(v1,v2,v3,v4,ofx,ofy)
 local fx,fy
 
 if ofx >= 0.25 and ofx <= 0.75 then
  fx = 0.5+math.cos((ofx+0.25)*2*math.pi)*0.5
 end
 if ofy >= 0.25 and ofy <= 0.75 then
  fy = 0.5+math.cos((ofy+0.25)*2*math.pi)*0.5
 end
 if ofx < 0.25 then fx = 0.0; end
 if ofx > 0.75 then fx = 1.0; end
 if ofy < 0.25 then fy = 0.0; end
 if ofy > 0.75 then fy = 1.0; end

 return (v1*(1-fx) + v2*fx)*(1-fy) + (v3*(1-fx) + v4*fx)*fy;
end
--

-- Linear
 function perlin.linip(v1,v2,v3,v4,fx,fy) 
   return (v1*(1-fx) + v2*fx)*(1-fy) + (v3*(1-fx) + v4*fx)*fy;
 end
--

-- Cosine
function perlin.cosip(v1,v2,v3,v4,fx,fy)
   fx = 0.5 - math.cos(fx * math.pi) * 0.5
   fy = 0.5 - math.cos(fy * math.pi) * 0.5
   return (v1*(1-fx) + v2*fx)*(1-fy) + (v3*(1-fx) + v4*fx)*fy;
 end
--


-- Ken Perlin's formula; slighty sharper s-curve than cosine (similar in appearance but with more contrast)
-- Compare to cosine in Wolfram:  6x^5 - 15x^4 + 10x^3 and 0.5 - cos(x * PI) * 0.5, x from 0 to 1
 function perlin.kenip(v1,v2,v3,v4,fx,fy)   
   --fx = 6*fx^5 - 15*fx^4 + 10*fx^3 -- Linear is 13% faster than this
   --fy = 6*fy^5 - 15*fy^4 + 10*fy^3
   fx = fx^3 * (6*fx^2 - 15*fx + 10) 
   fy = fy^3 * (6*fy^2 - 15*fy + 10)
   return (v1*(1-fx) + v2*fx)*(1-fy) + (v3*(1-fx) + v4*fx)*fy;
   --return v1
 end
--

-- Circular (Quite original with few octaves but normally similar to Ken's, some linear looking diamond-structures may appear)
function perlin.cirip(v1,v2,v3,v4,fx,fy)   
   local q,d1,d2,d3,d4,f,p1,p2,p3,p4,v 
   q = 1/(2^0.5)
 
   d1 = 1 - math.min(1,(fx^2 + fy^2)^0.5)
   d2 = 1 - math.min(1,((1-fx)^2 + fy^2)^0.5)
   d3 = 1 - math.min(1,(fx^2 + (1-fy)^2)^0.5)
   d4 = 1 - math.min(1,((1-fx)^2 + (1-fy)^2)^0.5)

   f = 1 / (d1+d2+d3+d4) 
   --f = 2.0

   p1 = d1 * f
   p2 = d2 * f
   p3 = d3 * f
   p4 = d4 * f
 
   v = v1*p1 + v2*p2 + v3*p3 + v4*p4;

   return v
 end
--

--]]

function perlin.cubip(v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,fx,fy) -- 4x4 grid
 local p0,p1,p2,p3

 function cubic_interpolation(v0,v1,v2,v3,f)
  local p,q
  p = (v3 - v2) - (v0 - v1)
  q = (v0 - v1) - p
  return p*f^3 + q*f^2 + (v2-v0)*f + v1
  --return v1 + 0.5 * f*(v2 - v0 + f*(2*v0 - 5*v1 + 4*v2 - v3 + f*(3*(v1 - v2) + v3 - v0))) -- not exactly the same
 end
 
 p0 = cubic_interpolation( v0, v1, v2, v3,fx)
 p1 = cubic_interpolation( v4, v5, v6, v7,fx)
 p2 = cubic_interpolation( v8, v9,v10,v11,fx)
 p3 = cubic_interpolation(v12,v13,v14,v15,fx)

 return cubic_interpolation(p0,p1,p2,p3,fy)
 
end


-- Note: This function is only used by perlin.doPerlinNoise2D for testing, use Interpolation library in any other situation
-- Interface for cubic interpolations (specific to Perlin library)
--
   function perlin.doCubicIp(map,mapsiz,iY,iX,fX,fY,ip_func)
       local v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15
       v0 = map[1 + (iY-1) % mapsiz][1 + (iX-1) % mapsiz]
       v1 = map[1 + (iY-1) % mapsiz][1 + (iX-0) % mapsiz]
       v2 = map[1 + (iY-1) % mapsiz][1 + (iX+1) % mapsiz]
       v3 = map[1 + (iY-1) % mapsiz][1 + (iX+2) % mapsiz]
        v4 = map[1 + (iY-0) % mapsiz][1 + (iX-1) % mapsiz]
        v5 = map[1 + (iY-0) % mapsiz][1 + (iX-0) % mapsiz]
        v6 = map[1 + (iY-0) % mapsiz][1 + (iX+1) % mapsiz]
        v7 = map[1 + (iY-0) % mapsiz][1 + (iX+2) % mapsiz]
       v8 = map[1 + (iY+1) % mapsiz][1 + (iX-1) % mapsiz]
       v9 = map[1 + (iY+1) % mapsiz][1 + (iX-0) % mapsiz]
      v10 = map[1 + (iY+1) % mapsiz][1 + (iX+1) % mapsiz]
      v11 = map[1 + (iY+1) % mapsiz][1 + (iX+2) % mapsiz]
       v12 = map[1 + (iY+2) % mapsiz][1 + (iX-1) % mapsiz]
       v13 = map[1 + (iY+2) % mapsiz][1 + (iX-0) % mapsiz]
       v14 = map[1 + (iY+2) % mapsiz][1 + (iX+1) % mapsiz]
       v15 = map[1 + (iY+2) % mapsiz][1 + (iX+2) % mapsiz]
      return ip_func(v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,fX,fY)
   end
--

---------- eof interpolation methods (remove all?)----------------


--
-- BiLinear Point Version
--
function perlin.getPerlinNoise2D_point(x, y, map, octaves, persist, freq_mult, freq_base, ip_func) -- coordinates expected to be fractional 0..1

     local total,p,n,norm,i,xp,yp,iX,yX,fX,fY,v1,v2,v3,v4,mapsiz,frequency,amplitude,floor, y0,y1, x0m,x1m

     floor = math.floor
     p,n,norm,mapsiz = persist, octaves, 1, #map  

     for i = 1, n-1, 1 do norm = norm + p^i end; norm = 1 / norm -- Normalize
 
      total = 0
      for i = 0, n-1, 1 do

       frequency = freq_base^i * freq_mult -- Step/Wavelength
       amplitude = p^i  

       xp = x * frequency + i*16
       yp = y * frequency --+ i*16 -- We don't use this offset in the optimized version, so get same result from seeds it can't be
     
       iX = floor(xp)
       fX = xp - iX
       iY = floor(yp)
       fY = yp - iY

       y0 = map[1 + iY % mapsiz]
       y1 = map[1 + (iY+1) % mapsiz]

       x0m = 1 + iX % mapsiz
       x1m = 1 + (iX+1) % mapsiz
       v1 = y0[x0m]
       v2 = y0[x1m]
       v3 = y1[x0m]
       v4 = y1[x1m]

       total = total + ip_func(v1,v2,v3,v4,fX,fY) * amplitude

      end

     return total * norm

end
--


-- Wrapping / Tiling version of the above function
--
function perlin.getPerlinNoise2D_point_WRAP(x, y, map, octaves, persist, freq_mult, freq_base, ip_func) -- coordinates expected to be fractional 0..1

     local total,p,n,norm,i,xp,yp,iX,yX,fX,fY,v1,v2,v3,v4,mapsiz,frequency,amplitude,floor, y0,y1, x0m,x1m

     floor = math.floor
     p,n,norm,mapsiz = persist, octaves, 1, #map  

     for i = 1, n-1, 1 do norm = norm + p^i end; norm = 1 / norm -- Normalize
 
      total = 0
      for i = 0, n-1, 1 do

       frequency = freq_base^i * freq_mult -- Step/Wavelength
       amplitude = p^i  

       xp = x * frequency + i*16
       yp = y * frequency --+ i*16 -- We don't use this offset in the optimized version, so get same result from seeds it can't be
     
       iX = floor(xp)
       fX = xp - iX
       iY = floor(yp)
       fY = yp - iY

       y0 = map[1 + (iY % mapsiz) % frequency]
       y1 = map[1 + ((iY+1) % mapsiz) % frequency]

       x0m = 1 + (iX % mapsiz) % frequency
       x1m = 1 + ((iX+1) % mapsiz) % frequency
       v1 = y0[x0m]
       v2 = y0[x1m]
       v3 = y1[x0m]
       v4 = y1[x1m]

       total = total + ip_func(v1,v2,v3,v4,fX,fY) * amplitude

      end

     return total * norm

end
--


--
-- BiLinear Point Version, INFLECTED
--
function perlin.getPerlinNoise2Dinflect_point(x, y, map, octaves, persist, freq_mult, freq_base, ip_func) -- coordinates expected to be fractional 0..1

     local total,p,n,norm,i,xp,yp,iX,yX,fX,fY,v1,v2,v3,v4,mapsiz,frequency,amplitude,floor, y0,y1, abs

     floor, abs = math.floor, math.abs
     p,n,norm,mapsiz = persist, octaves, 1, #map  

     for i = 1, n-1, 1 do norm = norm + p^i end; norm = 1 / norm -- Normalize
 
      total = 0
      for i = 0, n-1, 1 do

       frequency = freq_base^i * freq_mult -- Step/Wavelength
       amplitude = p^i  

       xp = x * frequency + i*16
       yp = y * frequency --+ i*16 -- We don't use this offset in the optimized version, so get same result from seeds it can't be
     
       iX = floor(xp)
       fX = xp - iX
       iY = floor(yp)
       fY = yp - iY

       y0 = map[1 + iY % mapsiz]
       y1 = map[1 + (iY+1) % mapsiz]

       v1 = y0[1 + iX % mapsiz]
       v2 = y0[1 + (iX+1) % mapsiz]
       v3 = y1[1 + iX % mapsiz]
       v4 = y1[1 + (iX+1) % mapsiz]
      
       total = total + abs(ip_func(v1,v2,v3,v4,fX,fY) * amplitude)


      end

     return (total * norm)*2 - 1

end
--

--
-- Control Point Version: (For Bicubic etc.)
-- Uses an interpolation control function, f.ex ip_.map_Bicubic_wrap(map,px,py,ip_func) 
-- Nominal output is -1 to 1.
--
function perlin.getPerlinNoise2D_Control_point(x, y, map, octaves, persist, freq_mult, freq_base, ctrl_func, ip_func) -- coordinates expected to be fractional 0..1

     local total,p,n,norm,i,xp,yp,iX,yX,fX,fY,mapsiz,frequency,amplitude
     --local v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15

     p,n,norm,mapsiz = persist, octaves, 0, #map  

     for i = 0, n-1, 1 do norm = norm + p^i end; norm = 1 / norm -- Normalize
 
      total = 0
      for i = 0, n-1, 1 do

       frequency = freq_base^i * freq_mult -- Step/Wavelength
       amplitude = p^i  

       total = total + ctrl_func(map, x * frequency + i*16, y * frequency, ip_func) * amplitude

      end

     return total * norm 
end
--

 
-- This version is not really used, but clean format and good for evaluating interpolation methods
-- coordinates expected to be fractional 0..1
-- All layers at once for each point
function perlin.doPerlinNoise2D(w,h,map, octaves, persist, freq_mult, freq_base, ip_func, cubic_flag, multiply) 

  local x,y,c,i,p,n,xf,yf,xp,yp,v1,v2,v3,v4,norm,iX,iY,fX,fY,total,frequecy,amplitude,mapsiz

  xf,yf = 1/w, 1/h

     mapsiz = #map

     p = persist 
     n = octaves 
     
     norm = 1; -- Normalize or Dramatize (increase contrast by using a higher set mult)
     for i = 0, n-1, 1 do norm = norm + p^i end; norm = 1 / norm -- Normalize
 
    for y = 0, h-1, 1 do
     for x = 0, w-1, 1 do

      total = 0
      for i = 0, n-1, 1 do

       frequency = freq_base^i * freq_mult -- Step/Wavelength
       amplitude = p^i  

       xp = x*xf * frequency + i*16
       iX = math.floor(xp)
       fX = xp - iX

       yp = y*yf * frequency + i*16   
       iY = math.floor(yp)
       fY = yp - iY


      if cubic_flag ~= true then
       v1 = map[1 + iY % mapsiz][1 + iX % mapsiz]
       v2 = map[1 + iY % mapsiz][1 + (iX+1) % mapsiz]
       v3 = map[1 + (iY+1) % mapsiz][1 + iX % mapsiz]
       v4 = map[1 + (iY+1) % mapsiz][1 + (iX+1) % mapsiz]

       --[[
       v1 = SmoothNoise(iY,iX)
       v2 = SmoothNoise(iY,iX+1)
       v3 = SmoothNoise(iY+1,iX)
       v4 = SmoothNoise(iY+1,iX+1)
       --]]

       total = total + ip_func(v1,v2,v3,v4,fX,fY) * amplitude 
      end -- not cubic

     if cubic_flag then
      total = total + perlin.doCubicIp(map,mapsiz,iY,iX,fX,fY,ip_func) * amplitude
     end

      end -- i

      c = total * norm * multiply * 127.5 + 127.5
      c = math.max(math.min(c,255),0) -- Cap, if not normalized
      putpicturepixel(x,y,c)

    end; 
    updatescreen();if (waitbreak(0)==1) then return end
   end; -- x,y

end
--

-- coordinates expected to be fractional 0..1
-- Returns Imagesize matrix
-- Optimized Layer by layer version, with rendering of final image it's twice as fast as the point-by-point version
-- Hardcoded interpolation (Ken's formula)
function perlin.perlinNoise2D_layer(w,h,map, octaves, persist, freq_mult, freq_base, update_flag) 

  local x,y,c,i,p,n,v,xf,yf,xp,yp,v1,v2,v3,v4,norm,iX,iY,fX,fY,total,frequecy,amplitude,mtx,of,fx,fy,fxr,fyr,mtx_y
  local mapy0,mapy1,mapsiz,xff,floor
  local x0,x1,amp_norm,colmult

  --update_flag = false

  floor = math.floor
 
   mtx = {}
   for y = 1, h, 1 do
     mtx[y] = {}
     for x = 1, w, 1 do
      mtx[y][x] = 0
   end;end

   xf,yf,mapsiz,p,n,norm = 1/(w-1), 1/(h-1), #map, persist, octaves, 0

   for i = 0, n-1, 1 do norm = norm + p^i end; norm = 1 / norm -- Normalize
 
   for i = 0, n-1, 1 do
       statusmessage("Layer: "..(i+1).." / "..n); waitbreak(0)
       frequency = freq_base^i * freq_mult -- Step/Wavelength
       amplitude = p^i 
        amp_norm = amplitude * norm
       of = i*16
        colmult = 127.5 * (1+i) -- *(1+i) is just a visual contrast-boost for the realtime update
    for y = 0, h-1, 1 do
       mtx_y = mtx[y+1]
       yp = y*yf * frequency   
       iY = floor(yp)
       fY = yp - iY, 1 + (iY+1) % mapsiz
       fy = fY*fY*fY * (fY*(6*fY - 15) + 10) -- Interpolation Ken's formula
       fyr = 1 - fy
       mapy0 = map[1 + iY % mapsiz]
       mapy1 = map[1 + (iY+1) % mapsiz]
       xff = xf * frequency
     for x = 0, w-1, 1 do
       xp = x * xff + of 
       iX = floor(xp)
       fX = xp - iX

       x0 = 1 + iX % mapsiz
       x1 = 1 + (iX+1) % mapsiz
       v1,v2,v3,v4 = mapy0[x0], mapy0[x1], mapy1[x0], mapy1[x1]

       fx = fX*fX*fX * (fX*(6*fX - 15) + 10) -- Interpolation Ken's formula
       fxr = 1 - fx    
       v = ((v1*fxr + v2*fx)*fyr + (v3*fxr + v4*fx)*fy) * amp_norm
       
       mtx_y[x+1] = mtx_y[x+1] + v
     
       if update_flag then putpicturepixel(x,y, v * colmult + 127.5); end

    end; 
    if update_flag and y%32 == 0 then updatescreen();if (waitbreak(0)==1) then return end; end
   end; -- x,y
  end -- i

  return mtx
end
--

-- Matrix is imagesize data of -1 to 1.
-- Palette index = altitude/brightness
--
function perlin.RenderMap(mtx,mult,balance)
 local x,y,w,h,c,max,min,mtxy
 max,min = math.max, math.min
 h,w = #mtx,#mtx[1]
 for y = 0, h-1, 1 do
   mtxy = mtx[y+1]
   for x = 0, w-1, 1 do
      c = max(min(mtxy[x+1] * mult * 127.5 + 127.5 + balance, 255),0) -- Cap, if not normalized
      putpicturepixel(x,y,c)
   end
   if y%8==0 then updatescreen();if (waitbreak(0)==1) then return end; end
  end
end
--



--
function perlin.MakeMap(size,seed)
  local x,y,map,rnd
  rnd = math.random
  if seed > 0  then math.randomseed(seed); end
  map = {} -- Matrix of any size can be used
  for y = 1, size, 1 do
   map[y] = {}
   for x = 1, size, 1 do
    map[y][x] = rnd() * 2 - 1 -- Values -1 to 1 allows for easy increase in contrast via mult
    --map[y][x] = rnd(0,1) * 2 - 1
   end  
  end
  return map
end
--

-- WIP Test, offsetting every 2nd line, x coord need to be x2 in renders
function perlin.MakeMapTEST(size,seed)
  local o,v,x,y,map,rnd
  rnd = math.random
  if seed > 0  then math.randomseed(seed); end
  map = {} -- Matrix of any size can be used
  for y = 1, size, 1 do
   map[y] = {}
   o = y % 2
   if o == 0 then
    for x = 1, size, 2 do
     v = rnd() * 2 - 1
     map[y][x] = v -- Values -1 to 1 allows for easy increase in contrast via mult
     map[y][x+1] = v
    end
   end  
   if o == 1 then
    map[y][1] = rnd() * 2 - 1
    map[y][size] = rnd() * 2 - 1
    for x = 1, size-2, 2 do
     v = rnd() * 2 - 1
     map[y][1+x] = v -- Values -1 to 1 allows for easy increase in contrast via mult
     map[y][1+x+1] = v
    end
   end  

  end
  return map
end
--


--
function perlin.ImageMap(size) -- Map from spare image, assumes 256 color gradient by index 0-255
  local x,y,map
  map = {} -- Matrix of any size can be used
  for y = 1, size, 1 do
   map[y] = {}
   for x = 1, size, 1 do
    map[y][x] = getsparepicturepixel(x-1,y-1) / 127.5 - 1
   end  
  end
  return map
end
--

--
-- Pre-smoothing of the map-data seems eq. to (the very slow) inline processing.
-- amount: 0..1 
--
-- However, this effect seem, if not identical, then very close to that of adjusting the Multiple value
--
function perlin.SmoothMap(map, amount)
 local x,y,v,s,nmap
  amount = amount or 1
  s = #map
  nmap = {} 
  for y = 1, s, 1 do
   nmap[1+y%s] = {}
   for x = 1, s, 1 do
    v = (map[1+(y-1)%s][1+(x-1)%s] + map[1+(y-1)%s][1+(x+1)%s] + map[1+(y+1)%s][1+(x-1)%s] + map[1+(y+1)%s][1+(x+1)%s]) / 16
    v = v + (map[1+y%s][1+(x-1)%s] + map[1+y%s][1+(x+1)%s] + map[1+(y-1)%s][1+x%s] + map[1+(y+1)%s][1+x%s]) / 8
    v = (v + map[1+y%s][1+x%s]) / 4
    v = v * amount + map[1+y%s][1+x%s] * (1-amount)
    nmap[1+y%s][1+x%s] = v
    putpicturepixel(x,y,v * 127.5 + 127.5)
   end
   updatescreen();if (waitbreak(0)==1) then return end
  end
  return nmap
end
--

-- Q: Move this function to the Noise-library?
-- Random Gaussian 3x3 Decontrast of Noise-map
-- map: Perlin noise map (2d-matrix with values -1 to 1)
-- freq: (0..1), Average fraction of map to be eroded 
-- power: 0..1(..4), Erosion power, 1 = full power on gaussian 3x3 matrix, 4 = Entire 3x3 area is wiped out (set to 0)
-- 
-- A High Frequency and Low Power will create an even erosion of the whole map, ex e=1, p=0.5
-- A Low Frequency and High Power will create random areas of great erosion and some areas left untouched, ex: e=0.15, p=4
--
function perlin.DampenMap3x3(map,freq,power)
  local x,y,n,size,rnd,amt,amt2,amt4,hits, x0,y0,xp1,yp1,xm1,ym1 
  rnd = math.random
  
  size = #map

  -- Prc:
  -- 0.15 = 2.500 hits on a 256x256 map
  -- 0.30 = 5.000 hits
  -- 0.61 = 10.000 hits
  -- 1.00 = 16.384 hits

  amt = math.max(0,1-power)
   amt2 = math.max(0,1 - power/2)
   amt4 = (1 - power/4)

  hits = freq * 0.25 * size*size -- 0.25 since 3x3 matrix has a total weight of 4


  for n = 0, hits, 1 do
    x = rnd(0,size-1)
    y = rnd(0,size-1)

    x0 = 1 + x % size
    y0 = 1 + y % size
    xp1 = 1 + (x+1)%size
    yp1 = 1 + (y+1)%size
    xm1 = 1 + (x-1)%size
    ym1 = 1 + (y-1)%size
   
    map[y0][x0]   = map[y0][x0] * amt
    map[yp1][x0]  = map[yp1][x0] * amt2
    map[ym1][x0]  = map[ym1][x0] * amt2
    map[y0][xp1]  = map[y0][xp1] * amt2
    map[y0][xm1]  = map[y0][xm1] * amt2
    map[yp1][xp1] = map[yp1][xp1] * amt4
    map[yp1][xm1] = map[yp1][xm1] * amt4
    map[ym1][xp1] = map[ym1][xp1] * amt4
    map[ym1][xm1] = map[ym1][xm1] * amt4

  end  
  
  return map
end
--


--
function perlin.setGradientPal()
 local n
 for n = 0, 255, 1 do setcolor(n,n,n,n); end
end
--





