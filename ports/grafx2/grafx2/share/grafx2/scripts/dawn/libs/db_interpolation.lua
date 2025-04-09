---------------------------------------------------
---------------------------------------------------
--
--            Interpolation Library
--              
--                    V1.0
-- 
--                Prefix: ip_.
--
--        by Richard 'DawnBringer' Fhager
--                                   
---------------------------------------------------
---------------------------------------------------

-- Abstract:
--  Bilinear & bicubic (2-dimensional) data & image interpolations, for 1-dimensional see Curve-library.
--  Also has a function for fractional sampling.

---------------------------------------------------

-- Use: dofile("../libs/db_interpolation.lua") 

---------------------------------------------------



ip_ = {}


-----------------------------
--- Linear interpolations ---
-----------------------------

-----------------------------
-- Bilinear interpolations --
-----------------------------


-- The "Circles" s-curve (over arch - level - under arch)
-- sqrt(-(x-1)*x)*(1-2*floor(0.5+x))+floor(0.5+x)
-- sqrt(x-x^2)*(1-2*floor(0.5+x))+floor(0.5+x)


-- Linear
 function ip_.linip(v1,v2,v3,v4,fx,fy) 
   return (v1*(1-fx) + v2*fx)*(1-fy) + (v3*(1-fx) + v4*fx)*fy;
 end
--

-- Cosine
function ip_.cosip(v1,v2,v3,v4,fx,fy)
   fx = 0.5 - math.cos(fx * 3.141592654) * 0.5
   fy = 0.5 - math.cos(fy * 3.141592654) * 0.5
   return (v1*(1-fx) + v2*fx)*(1-fy) + (v3*(1-fx) + v4*fx)*fy;
end
--

-- "Inverted Cosine", quick trans. to a broad middle; *8 & ^4 or *2 & ^2 (less curved, *8,^4 is too strong)
--
--   __/
--  /
--
-- Wolfram, "inverted cosinus" or quick rise to middle:  x and 0.5+sgn(x-0.5)*8*(x-0.5)^4, x from 0 to 1
function ip_.icoip(v1,v2,v3,v4,fx,fy)
   local sx,sy
   sx,sy = 1,1 
   if fx < 0.5 then sx = -1; end
   if fy < 0.5 then sy = -1; end
   fx = 0.5+sx*2*(fx-0.5)^2
   fy = 0.5+sy*2*(fy-0.5)^2
   return (v1*(1-fx) + v2*fx)*(1-fy) + (v3*(1-fx) + v4*fx)*fy;
end
--

-- Ken Perlin's formula; slighty sharper s-curve than cosine (similar in appearance but with more contrast)
-- Compare to cosine in Wolfram:  6x^5 - 15x^4 + 10x^3 and 0.5 - cos(x * PI) * 0.5, x from 0 to 1
function ip_.kenip(v1,v2,v3,v4,fx,fy)   
   --fx = fx^3 * (6*fx^2 - 15*fx + 10) -- About as fast as cosine
   --fy = fy^3 * (6*fy^2 - 15*fy + 10)
   --fx = fx^3 * (fx*(6*fx - 15) + 10) -- 38% faster than 6*fx^2.., ~1.25x faster than cosine
   --fy = fy^3 * (fy*(6*fy - 15) + 10)
   fx = fx*fx*fx * (fx*(6*fx - 15) + 10) 
   fy = fy*fy*fy * (fy*(6*fy - 15) + 10)
   return (v1*(1-fx) + v2*fx)*(1-fy) + (v3*(1-fx) + v4*fx)*fy;
end
--

-- Narrow cosine, very sharp, only interpolate in the 50% midrange
function ip_.midip(v1,v2,v3,v4,ofx,ofy)
 local fx,fy
 
 if ofx >= 0.25 and ofx <= 0.75 then
  fx = 0.5+math.cos((ofx+0.25)*2*3.141592654)*0.5
 end
 if ofy >= 0.25 and ofy <= 0.75 then
  fy = 0.5+math.cos((ofy+0.25)*2*3.141592654)*0.5
 end
 if ofx < 0.25 then fx = 0.0; end
 if ofx > 0.75 then fx = 1.0; end
 if ofy < 0.25 then fy = 0.0; end
 if ofy > 0.75 then fy = 1.0; end

 return (v1*(1-fx) + v2*fx)*(1-fy) + (v3*(1-fx) + v4*fx)*fy;
end
--

-- Circular (Quite original with few octaves but normally similar to Ken's, some linear looking diamond-structures may appear)
function ip_.cirip(v1,v2,v3,v4,fx,fy)   
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


------------------------------
--- Bicubic interpolations ---
------------------------------

function ip_.cubip(v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,fx,fy) -- 4x4 grid
 local p0,p1,p2,p3,cubic_interpolation

 function cubic_interpolation(v0,v1,v2,v3,f)
  local p,q
  p = (v3 - v2) - (v0 - v1)
  q = (v0 - v1) - p
  return p*f*f*f + q*f*f + (v2-v0)*f + v1
  --return v1 + 0.5 * f*(v2 - v0 + f*(2*v0 - 5*v1 + 4*v2 - v3 + f*(3*(v1 - v2) + v3 - v0))) -- not exactly the same
 end
 
 p0 = cubic_interpolation( v0, v1, v2, v3,fx)
 p1 = cubic_interpolation( v4, v5, v6, v7,fx)
 p2 = cubic_interpolation( v8, v9,v10,v11,fx)
 p3 = cubic_interpolation(v12,v13,v14,v15,fx)

 return cubic_interpolation(p0,p1,p2,p3,fy)
 
end


--
function ip_.pixelRGB_Bicubic(px,py,col_func,get_func,ip_func) -- decimal coord, interpolate between adjacent integer pixels
 local r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16
 local g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,g11,g12,g13,g14,g15,g16
 local b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16
 local fx,fy,r,g,b,ix,iy

           ix,iy = math.floor(px), math.floor(py)

           r1,g1,b1 = col_func(get_func(ix-1, iy-1)); -- NOTE: NO BORDER PROTECTION! Add a cap?
           r2,g2,b2 = col_func(get_func(ix+0, iy-1));
           r3,g3,b3 = col_func(get_func(ix+1, iy-1));
           r4,g4,b4 = col_func(get_func(ix+2, iy-1));

           r5,g5,b5 = col_func(get_func(ix-1, iy)); 
           r6,g6,b6 = col_func(get_func(ix+0, iy));
           r7,g7,b7 = col_func(get_func(ix+1, iy));
           r8,g8,b8 = col_func(get_func(ix+2, iy));

           r9,g9,b9    = col_func(get_func(ix-1, iy+1)); 
           r10,g10,b10 = col_func(get_func(ix+0, iy+1));
           r11,g11,b11 = col_func(get_func(ix+1, iy+1));
           r12,g12,b12 = col_func(get_func(ix+2, iy+1));

           r13,g13,b13 = col_func(get_func(ix-1, iy+2)); 
           r14,g14,b14 = col_func(get_func(ix+0, iy+2));
           r15,g15,b15 = col_func(get_func(ix+1, iy+2));
           r16,g16,b16 = col_func(get_func(ix+2, iy+2));

           fx = px - ix
           fy = py - iy

           r = ip_func(r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,fx,fy) -- only ip_.cubip right now
           g = ip_func(g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,g11,g12,g13,g14,g15,g16,fx,fy)
           b = ip_func(b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,fx,fy)

           return r,g,b
end
--

-- Map/Matrix wrap-around Bicubic interpolation control function 
-- px,py is decimal coord, ex: 15.8, 19.3
function ip_.map_Bicubic_wrap(map,px,py,ip_func)
       local v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,ix,iy,fx,fy,xsiz,ysiz
       ix,iy = math.floor(px), math.floor(py)
       ysiz,xsiz = #map,#map[1]
    
       v0 = map[1 + (iy-1) % ysiz][1 + (ix-1) % xsiz]
       v1 = map[1 + (iy-1) % ysiz][1 + (ix-0) % xsiz]
       v2 = map[1 + (iy-1) % ysiz][1 + (ix+1) % xsiz]
       v3 = map[1 + (iy-1) % ysiz][1 + (ix+2) % xsiz]
        v4 = map[1 + (iy-0) % ysiz][1 + (ix-1) % xsiz]
        v5 = map[1 + (iy-0) % ysiz][1 + (ix-0) % xsiz]
        v6 = map[1 + (iy-0) % ysiz][1 + (ix+1) % xsiz]
        v7 = map[1 + (iy-0) % ysiz][1 + (ix+2) % xsiz]
       v8 = map[1 + (iy+1) % ysiz][1 + (ix-1) % xsiz]
       v9 = map[1 + (iy+1) % ysiz][1 + (ix-0) % xsiz]
      v10 = map[1 + (iy+1) % ysiz][1 + (ix+1) % xsiz]
      v11 = map[1 + (iy+1) % ysiz][1 + (ix+2) % xsiz]
       v12 = map[1 + (iy+2) % ysiz][1 + (ix-1) % xsiz]
       v13 = map[1 + (iy+2) % ysiz][1 + (ix-0) % xsiz]
       v14 = map[1 + (iy+2) % ysiz][1 + (ix+1) % xsiz]
       v15 = map[1 + (iy+2) % ysiz][1 + (ix+2) % xsiz]

       fx = px - ix
       fy = py - iy

      return ip_func(v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,fx,fy)
end
--


-- eof bicubic



-----------------------------
----- Control Functions -----
-----------------------------

-- Map/Matrix wrap-around Bilinear interpolation control function 
-- px,py is decimal coord, ex: 15.8, 19.3
function ip_.map_Bilinear_wrap(map,px,py,ip_func)
       local v0,v1,v2,v3,ix,iy,fx,fy,xsiz,ysiz
       ix,iy = math.floor(px), math.floor(py)
       ysiz,xsiz = #map,#map[1]
    
       v0 = map[1 + iy % ysiz][1 + ix % xsiz]
       v1 = map[1 + iy % ysiz][1 + (ix+1) % xsiz]
       v2 = map[1 + (iy+1) % ysiz][1 + ix % xsiz]
       v3 = map[1 + (iy+1) % ysiz][1 + (ix+1) % xsiz]
        
       fx = px - ix
       fy = py - iy

      return ip_func(v0,v1,v2,v3,fx,fy)
end
--

--
-- Image/Brush Pixel RGB Bilinear 
--
--      px,py: Fractional pixel position, ex. 17.6
--   col_func: getcolor, getbackupcolor etc.
--   get_func: getpicturepixel, getbackuppixel etc.
--    ip_func: Interpolation function, ex (sharpest to smoothest): ip_.midip, ip_.kenip, ip_.cosip, ip_.linip
--
--    returns: r, g, b
--
-- ex: r,g,b = ip_.pixelRGB_Bilinear(px, py, getbackupcolor, getpicturepixel, ip_.kenip)
--
function ip_.pixelRGB_Bilinear(px,py,col_func,get_func,ip_func) -- decimal coord, interpolate between adjacent integer pixels
 local fx,fy,r1,r2,r3,r4,g1,g2,g3,g4,b1,b2,b3,b4,r,g,b,ix,iy

           ix,iy = math.floor(px), math.floor(py)

           --r1,g1,b1 = col_func(get_func(math.floor(px),math.floor(py)));
           --r2,g2,b2 = col_func(get_func(math.ceil(px), math.floor(py)));
           --r3,g3,b3 = col_func(get_func(math.floor(px),math.ceil(py)));
           --r4,g4,b4 = col_func(get_func(math.ceil(px), math.ceil(py)));

           r1,g1,b1 = col_func(get_func(ix,   iy));  -- NOTE: NO BORDER PROTECTION!
           r2,g2,b2 = col_func(get_func(ix+1, iy));
           r3,g3,b3 = col_func(get_func(ix,   iy+1));
           r4,g4,b4 = col_func(get_func(ix+1, iy+1));

           fx = px - ix
           fy = py - iy

           r = ip_func(r1,r2,r3,r4,fx,fy)
           g = ip_func(g1,g2,g3,g4,fx,fy)
           b = ip_func(b1,b2,b3,b4,fx,fy)

           return r,g,b
end
--

--
-- Same as ip_.pixelRGB_Bilinear but also returns a PALETTE of the four colors (for rotation spritemode f.ex)
--
-- Returns r,g,b, pal 
--
function ip_.pixelRGB_Bilinear_PAL(px,py,col_func,get_func,ip_func) -- decimal coord, interpolate between adjacent integer pixels
 local fx,fy,r1,r2,r3,r4,g1,g2,g3,g4,b1,b2,b3,b4,r,g,b,ix,iy,pal,c1,c2,c3,c4

           ix,iy = math.floor(px), math.floor(py)   
     
           c1 = get_func(ix,   iy)  -- NOTE: NO BORDER PROTECTION!
           c2 = get_func(ix+1, iy)
           c3 = get_func(ix,   iy+1)
           c4 = get_func(ix+1, iy+1)
           r1,g1,b1 = col_func(c1);  
           r2,g2,b2 = col_func(c2);
           r3,g3,b3 = col_func(c3);
           r4,g4,b4 = col_func(c4);

           pal = {{r1,g1,b1,c1},{r2,g2,b2,c2},{r3,g3,b3,c3},{r4,g4,b4,c4}}

           fx = px - ix
           fy = py - iy

           r = ip_func(r1,r2,r3,r4,fx,fy)
           g = ip_func(g1,g2,g3,g4,fx,fy)
           b = ip_func(b1,b2,b3,b4,fx,fy)
  
           return r,g,b, pal
end
--


-- Gamma version
function ip_.pixelRGB_Bilinear_PAL_gamma(px,py,col_func,get_func,ip_func, gamma) -- decimal coord, interpolate between adjacent integer pixels
 local fx,fy,r1,r2,r3,r4,g1,g2,g3,g4,b1,b2,b3,b4,r,g,b,ix,iy,pal,c1,c2,c3,c4,q,p

           ix,iy = math.floor(px), math.floor(py)   
     
           c1 = get_func(ix,   iy)  -- NOTE: NO BORDER PROTECTION!
           c2 = get_func(ix+1, iy)
           c3 = get_func(ix,   iy+1)
           c4 = get_func(ix+1, iy+1)
           r1,g1,b1 = col_func(c1);  
           r2,g2,b2 = col_func(c2);
           r3,g3,b3 = col_func(c3);
           r4,g4,b4 = col_func(c4);

           pal = {{r1,g1,b1,c1},{r2,g2,b2,c2},{r3,g3,b3,c3},{r4,g4,b4,c4}}

           fx = px - ix
           fy = py - iy

           q = gamma
           p = 1 / q 

           r = ip_func(r1^q,r2^q,r3^q,r4^q,fx,fy)
           g = ip_func(g1^q,g2^q,g3^q,g4^q,fx,fy)
           b = ip_func(b1^q,b2^q,b3^q,b4^q,fx,fy)
  
           return r^p,g^p,b^p, pal
end
--


-----------------------------------------------------
----- Distortion AA / Fractional Pixel Sampling -----
-----------------------------------------------------
-- Split target pixel into (1+n)^2 areas and process each one to sum up and calculate a more accurate average RGB.
-- This is primarily intended for heavy distortions where interpolations start to fail. F.ex Twirl operator.
--
-- 3 levels is a little smoother than basic bilinear ip (and no levels)
-- Difference between 3 & 6 levels is trivial for medium distortions
--
-- Returns r,g,b (average of rgb_func executed on pixel x,y)
--
-- See pic_db_Twirl for an example of implementation
--
-- Usage Example:
-- c = matchcolor2(ip_.fractionalSampling(8, x,y, w,h, (function(ox,oy,w,h) return getcolor(getbackuppixel(ox*w+0.5,oy*h+0.5)); end), 1.6))
--
-- NOTE: the control() getpixel function should always add 0.5 to the coords
--
function ip_.fractionalSampling(levels, x,y, w,h, rgb_func, gamma) -- split levels (areas 0=none,1=4,2=9..), integer coord, image dimensions, control function

 local sz,sn,of,fx,fy,ox,oy,r,g,b,rt,gt,bt,rgam,ofx,ofy

 gamma = gamma or 1

 rgam = 1 / gamma

 sz = levels + 1 -- 1*1 (no extra action), 2*2(4),3*3(9),4*4(16),5*5(25),6*6(36)
 sn = sz*sz
 of = -(1 - 1/sz)/2 -- This will center in each sub-square, origo is x,y
 ofx = x + of 
 ofy = y + of
 rt,gt,bt = 0,0,0

 for fy = 0, sz-1, 1 do
  --oy = (y + fy/sz + of) / h 
  oy = (ofy + fy/sz) / h 
  for fx = 0, sz-1, 1 do

     --ox = (x + fx/sz + of) / w
     ox = (ofx + fx/sz) / w  
     
     r,g,b = rgb_func(ox,oy, w,h) -- For 0 Levels ox,oy = (x+0)/w,(y+0)/h
 
     if gamma ~= 1.0 then
      rt = rt + r^gamma 
      gt = gt + g^gamma 
      bt = bt + b^gamma
      else
       rt = rt + r 
       gt = gt + g 
       bt = bt + b
      end

  end
 end

 return (rt/sn)^rgam,(gt/sn)^rgam,(bt/sn)^rgam

end
--

--


-----------------------------
----- Special Functions -----
-----------------------------

-- Draw/Make a complete Backdrop/Gradient, data: {x,y,r,g,b}
-- In order to draw, create a put-function like
--  [function(x,y,r,g,b) putpicturepixel(x,y,matchcolor(r,g,b));end] and use as put_func argument
--
-- Can also be written to a matrix for rendering with db.fsrender
--
-- Direct plot Example:
-- x0,y0 = 10,20
-- x1,y1 = 200,150 
-- p0 = {x0, y0, 255,100,100}
-- p1 = {x1, y0, 0,  255,  0}
-- p2 = {x0, y1, 100,100,255}
-- p3 = {x1, y1, 100,  0,  0}
-- ip_.drawBackdrop(p0,p1,p2,p3, (function(x,y,r,g,b)putpicturepixel(x,y,matchcolor2(r,g,b));end), ip_.linip)
--
--
function ip_.drawBackdrop(p0,p1,p2,p3,put_func,ip_func)

   local x,y,px,py,r,g,b,ax,ay,w,h

   ax,ay = p0[1],p0[2]

   w = p1[1] - p0[1]
   h = p2[2] - p0[2]

  for y = 0, h, 1 do -- +1 to fill screen with FS-render

   py = y/h
   
   for x = 0, w, 1 do 

    px = x/w

    r = ip_func(p0[3],p1[3],p2[3],p3[3],px,py) 
    g = ip_func(p0[4],p1[4],p2[4],p3[4],px,py) 
    b = ip_func(p0[5],p1[5],p2[5],p3[5],px,py) 

    put_func(x+ax,y+ay,r,g,b)

   end;end

end
--


--
function ip_.drawBackdropA(p0,p1,p2,p3,put_func,ip_func)

   local x,y,px,py,r,g,b,ax,ay,w,h

   ax,ay = p0[1],p0[2]

   w = p1[1] - p0[1]
   h = p2[2] - p0[2]

  for y = 0, h, 1 do -- +1 to fill screen with FS-render

   py = y/h
   
   for x = 0, w, 1 do 

    px = x/w

    r = ip_func(p0[3][1],p1[3][1],p2[3][1],p3[3][1],px,py) 
    g = ip_func(p0[3][2],p1[3][2],p2[3][2],p3[3][2],px,py) 
    b = ip_func(p0[3][3],p1[3][3],p2[3][3],p3[3][3],px,py) 

    put_func(x+ax,y+ay,r,g,b)

   end;end

end
--

