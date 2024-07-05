---------------------------------------------------
---------------------------------------------------
--
--             Draw Buffer Library
--              
--                    V1.3
--
--                 March 2017
-- 
--                Prefix: drawb.
--
--        by Richard 'DawnBringer' Fhager
--                                   
--        Email: dawnbringer@hem.utfors.se
--               dawnbringer@bahnhof.se
--
---------------------------------------------------
---------------------------------------------------

-- Abstract:
--  A true-color graphics system with gammma-corrected transparency and layering.
--  Where drawing is done to a buffer, which is later rendered (and cleared).
--  It also includes a (faster) index based system for 256 color gradients.


--
-- Use: dofile("../libs/db_drawbuffer.lua") 
--

-- History:
-- update 2017-03-29: Added RenderBufferHQupdate() (piecemeal updated drawing of big High-Quality scenes, L-sys f.ex)
--                    Added Buffer2Palette() (Creates a colorlist of the buffer for (Median Cut) palette creation)
-- update 2017-01-23: Added Index Line function, removed redundant usages of "icol".


-- USAGE:

-- Note: There are two systems available;
-- 1. RGB-system (full color, gamma corrected calculations)
-- 2. Index-system (256 color monochrome gradients, allows for any gradient used based only on numeric index)

-- transparency "t": 1 is solid, 0 is transparent.

-- Usage ex:
-- drawb.Init(w,h,gamma) -- Initiate a draw buffer, Needs to be done for each frame of an anim
-- drawb.LineAA(dbuf,x1,y1,x2,y2,r,g,b,t) -- Draw a line to the buffer
-- drawb.RenderBuffer(dbuf) -- Render the draw buffer (use RenderBufferHQ for better quality, or RenderBufferHQupdate for showing slow renders)
-- For anims also use
-- drawb.ReplaceBackground(dbuf) -- Restore the background, after updatescreen() and before next Dbuf_Init

---------------------------------------------------


drawb = {}

--
function drawb.Init(w,h,gamma,dyngam_flag) -- Set size of screen and gamma for project
 local dbuf,list
 dbuf = {} -- [R,G,B,Transp] index is pixel: y*w+x
 dbuf.list = {} -- pixel y*w+x of dbuf entry
 dbuf.w = w
 dbuf.h = h
 dbuf.gamma = gamma
 --
 if dyngam_flag then
  local n,r,g,b,dyngam,bri,dgam,gam,igam
  dyng = {}
  for n = 0, 255, 1 do
   r,g,b = getcolor(n)
   bri = (r*r*0.0676 + g*g*0.3025 + b*b*0.0361)^0.5 * 1.5690256395005606
   dgam = 2.0
   gam = dgam - bri/255 * 0.7  -- 2.0 for Black bg, 1.3 for white bg
   igam = 1/gam
   dyng[n+1] = gam
  end
  dbuf.dyngam = dyng
 end
 --
 return dbuf
end
--

-- Plotting:
-- Adding (any number of) rgb-layers with transparencies and gamma-correction (without concerns about a potential background)
-- Producing a compund rgba-value that may later be rendered over a background and producing a result 100% equivalent 
-- to sequentially drawing transparent colors over a background, given infinite bitdepth. (It took some headscratching to figure this one out)
-- Note: transp=0 + old transp=0 will cause division by zero, and it's a waste of effort anyways...so we just do nothing when t=0
--
function drawb.Plot(dbuf, x,y, r,g,b, t)
 local e,p,to,ro,go,bo,tn,rn,gn,bn,igam,tof,w,gam

 w = dbuf.w
 if t>0 and x >= 0 and x < w then
  if y >= 0 and y < dbuf.h then

    p = 1 + y*w + x
    gam  = dbuf.gamma
    igam = 1 / gam

    if dbuf[p] == nil then
     dbuf.list[#dbuf.list + 1] = p -- List of active pixels in the buffer
     dbuf[p] = {r,g,b,t,x,y}
      else
       e = dbuf[p]; ro,go,bo,to = e[1],e[2],e[3],e[4]
       tof = (1-t)*to -- old transp factor
       tn = tof + t
       rn = ((ro^gam*tof + r^gam * t) / tn)^igam 
       gn = ((go^gam*tof + g^gam * t) / tn)^igam
       bn = ((bo^gam*tof + b^gam * t) / tn)^igam
       dbuf[p] = {rn,gn,bn,tn,x,y}
    end

  end -- if y
 end -- if x
 --return dbuf
end
--

--
-- function drawb.PlotDraw(dbuf, x,y, r,g,b, t) -- Plotting that also draws result to screen, for images that are generated over time
--

--
-- Fractional (AA) plot
--
function drawb.FracPlot(dbuf, x,y, r,g,b, t)

   local x_1,y_1,xf,yf
   
   x_1 = math.floor(x)
   y_1 = math.floor(y)

   xf = x - x_1
   yf = y - y_1

   drawb.Plot(dbuf, x_1,  y_1,   r,g,b, t * (1-xf)*(1-yf))
   drawb.Plot(dbuf, x_1+1,y_1,   r,g,b, t * xf*(1-yf))
   drawb.Plot(dbuf, x_1,  y_1+1, r,g,b, t * (1-xf)*yf)
   drawb.Plot(dbuf, x_1+1,y_1+1, r,g,b, t * xf*yf)

end
--


function drawb.LineAA(dbuf,x1,y1,x2,y2,r,g,b,t,skip) -- t = transp or amt: 0-1, 1 = Full color
 local n,st,m,x,y,x_1,y_1,xf,yf,stx,sty; 
 m = math
  
 -- Skip may have no or unpredictable performance with AA, REMOVE SKIP?
 -- Skip first plot if last plot ended in the same position. Method for avoding double plotting joints in drawTo line drawing (A-BB-C). 
 -- Probably not a perfect solution but it works very well.
 -- Is it even applicable in dbuf? (maybe for integer lines, but fractional??)
 skip = skip or 0 -- (1 for skip?)

 x,y = x1,y1 -- make sure we have a return coord
 st = m.max(1,m.abs(x2-x1),m.abs(y2-y1))
 stx = (x2-x1)/st
 sty = (y2-y1)/st
 for n = skip, st, 1 do

   x = x1 + n * stx  -- Skip works if coords are integers
   y = y1 + n * sty

   drawb.FracPlot(dbuf, x,y, r,g,b, t)

 end
 return x,y
end
--

-- No AA, Integer plotting with skip support (Transparencies & Gamma still works)
function drawb.Line(dbuf,x1,y1,x2,y2,r,g,b,t,skip) -- t = transp or amt: 0-1, 1 = Full color
 local n,st,m,x,y,x_1,y_1,xf,yf,stx,sty,floor; 
 m = math
 floor = m.floor  

 -- Skip first plot if last plot ended in the same position. Method for avoding double plotting joints in drawTo line drawing (A-BB-C). 
 -- Probably not a perfect solution but it works very well.
 skip = skip or 0 -- (1 for skip?)

 x,y = x1,y1 -- make sure we have a return coord
 st = m.max(1,m.abs(x2-x1),m.abs(y2-y1))
 stx = (x2-x1)/st
 sty = (y2-y1)/st
 for n = skip, st, 1 do

   x = floor(x1 + n * stx)  -- Skip works if coords are integers
   y = floor(y1 + n * sty)

  drawb.Plot(dbuf, x,y, r,g,b, t)

 end

 x2,y2 = floor(x2),floor(y2)
 if not (x==x2 and y==y2) then -- Make sure last pixel in line is drawn (while avoiding double-joints)
  drawb.Plot(dbuf, x2,y2, r,g,b, t)
  return x2,y2
 end

 return x,y
end
--

-- ? Should we add progressive mode, drawing over current rather than backup? F.ex multiple buffers drawn on top of one another.

-- Basic & Fast version using matchcolor()
function drawb.RenderBuffer(dbuf)
 local n,list,r,g,b,t,x,y,w,h,w,gam,co,ro,go,bo,igam,dyngam_flag
 list = dbuf.list
 gam = dbuf.gamma
 igam = 1 / gam
 w = dbuf.w

 dyngam_flag = false; if dbuf.dyngam ~= nil then dyngam_flag = true; end

 for n = 1, #list, 1 do
  -- x = p - y*w; y = math.floor(p / w) -- Which is faster; adding/reading x,y to dbuf or derive from p?
  e = dbuf[list[n]]
  r,g,b,t,x,y = e[1],e[2],e[3],e[4],e[5],e[6]
  co = getbackuppixel(x,y)
  ro,go,bo = getcolor(co)
  if dyngam_flag then gam = dbuf.dyngam[co+1]; igam = 1 / gam; end -- Dynamic Gamma (Less gamma on bright background)
  r = (r^gam*t + ro^gam*(1-t))^igam
  g = (g^gam*t + go^gam*(1-t))^igam
  b = (b^gam*t + bo^gam*(1-t))^igam
  putpicturepixel(x,y,matchcolor(r,g,b))
 end
end
--

-- High Quality (slow) version using matchcolor2(), use bw=0.5 to 0.65 to prevent bleeding/glowing lines (better bri match) 
function drawb.RenderBufferHQ(dbuf,briweight)
 local n,list,r,g,b,t,x,y,w,h,w,gam,ro,go,bo,igam
 list = dbuf.list
 gam = dbuf.gamma
 igam = 1 / gam
 w = dbuf.w
 dyngam_flag = false; if dbuf.dyngam ~= nil then dyngam_flag = true; end
 for n = 1, #list, 1 do
  e = dbuf[list[n]]
  r,g,b,t,x,y = e[1],e[2],e[3],e[4],e[5],e[6]
  co = getbackuppixel(x,y)
  ro,go,bo = getcolor(co)
  if dyngam_flag then gam = dbuf.dyngam[co+1]; igam = 1 / gam; end -- Dynamic Gamma (Less gamma on bright background)
  r = (r^gam*t + ro^gam*(1-t))^igam
  g = (g^gam*t + go^gam*(1-t))^igam
  b = (b^gam*t + bo^gam*(1-t))^igam
  putpicturepixel(x,y,matchcolor2(r,g,b,briweight))
 end
end
--

-- High Quality (slow) version using matchcolor2(), use bw=0.5 to 0.65 to prevent bleeding/glowing lines (better bri match) 
-- UPDATE (automatic realtime) version, for slow/big renders
function drawb.RenderBufferHQupdate(dbuf,briweight)
 local n,list,r,g,b,t,x,y,w,h,w,gam,ro,go,bo,igam, root,i,j
 local draw
 list = dbuf.list
 gam = dbuf.gamma
 igam = 1 / gam
 w = dbuf.w
 dyngam_flag = false; if dbuf.dyngam ~= nil then dyngam_flag = true; end
 root = math.floor((#list)^0.5)

 --
 function draw(n)
  e = dbuf[list[n]]
  r,g,b,t,x,y = e[1],e[2],e[3],e[4],e[5],e[6]
  co = getbackuppixel(x,y)
  ro,go,bo = getcolor(co)
  if dyngam_flag then gam = dbuf.dyngam[co+1]; igam = 1 / gam; end -- Dynamic Gamma (Less gamma on bright background)
  r = (r^gam*t + ro^gam*(1-t))^igam
  g = (g^gam*t + go^gam*(1-t))^igam
  b = (b^gam*t + bo^gam*(1-t))^igam
  putpicturepixel(x,y,matchcolor2(r,g,b,briweight))
 end 
 --

 n = 0
 for i = 1, root, 1 do
  for j = 1, root, 1 do n = n+1; draw(n); end -- j
  updatescreen(); if (waitbreak(0)==1) then return end; 
 end -- i
 for j = n+1, #list, 1 do draw(j); end

end
--


-- Create a list of colors in the Buffer (for use with Median Cut f.ex)
function drawb.Buffer2Palette(dbuf,step)
 local n,list,r,g,b,t,x,y,w,h,w,gam,co,ro,go,bo,igam,dyngam_flag,pal,cap,max,min,len
 list = dbuf.list
 gam = dbuf.gamma
 igam = 1 / gam
 w = dbuf.w
 dyngam_flag = false; if dbuf.dyngam ~= nil then dyngam_flag = true; end

 step = step or 1

 max,min = math.max, math.min
 function cap(v) return max(min(v,255),0); end
 
 pal = {}
 len = 0
 for n = 1, #list, step do
  e = dbuf[list[n]]
  r,g,b,t,x,y = e[1],e[2],e[3],e[4],e[5],e[6]
  co = getbackuppixel(x,y)
  ro,go,bo = getcolor(co)
  if dyngam_flag then gam = dbuf.dyngam[co+1]; igam = 1 / gam; end -- Dynamic Gamma (Less gamma on bright background)
  r = (r^gam*t + ro^gam*(1-t))^igam
  g = (g^gam*t + go^gam*(1-t))^igam
  b = (b^gam*t + bo^gam*(1-t))^igam
  len = len + 1
  pal[len] = {cap(r),cap(g),cap(b)}
 end
 return pal
end
--


-- Clear/Replace the pixels drawn in the buffer (rather than clearing the entire screen, allows animating over an image)
function drawb.ReplaceBackground(dbuf)
 local n,list,w,x,y,e
 list = dbuf.list
 for n = 1, #list, 1 do
  e = dbuf[list[n]]
  x,y = e[5],e[6]
  putpicturepixel(x,y,getbackuppixel(x,y))
 end
end
--



-- SplineDrawing, se Spline-section in dawnbringer_lib for actual spline functions.
-- esp. db.makeSplineData(x0,y0,x1,y1,x2,y2,x3,y3,points) 
function drawb.DrawSplineSegment(dbuf,splinedata,points,col,transp)
 
 local list,fx,fy,x,y,n,ox,oy,skip,mf,ma,v

 fx,fy = splinedata[1][1],splinedata[1][2]
 
 mf,ma = math.floor, math.abs

 ox,oy = -99,-99
 for n = 2, #splinedata, 1 do
  x,y = splinedata[n][1],splinedata[n][2]

  -- Yes, this seem to be the solution! Note that this is for lines within a segment.
  --skip = 0; v = ((ox-fx)^2+(oy-fy)^2)^0.5 if v < 1 then skip = 1-v; end 
 
  skip = 0; if n>2 then skip = 1; end -- using ox,oy (physical end of last line) as startpoints, skip is 1 for all but the first line of the segment

  r,g,b = getcolor(col)
  ox,oy = drawb.LineAA(dbuf,fx,fy,x,y,r,g,b,transp,skip)
  --fx,fy = x,y
    fx,fy = ox,oy
 end

end
--


---------------- Index / 256-col Gradient Sub-system ("Grayscale" / Transparancy only) ----------


--
-- icol: project ink color index/value (0-255, Black to White)
--
function drawb.InitIndex(w,h,gamma,icol) -- Set size of screen and gamma for project
 local dbuf,list,vgam
 vgam = {}
 dbuf = {} -- [R,G,B,Transp] index is pixel: y*w+x
 dbuf.list = {} -- pixel y*w+x of dbuf entry
 dbuf.w = w
 dbuf.h = h
 dbuf.gamma = gamma
 dbuf.igam = 1 / gamma
 dbuf.icol = icol
 dbuf.icolgamma = icol^gamma -- helps optimization

 for n = 1, 256, 1 do
  vgam[n] = (n-1)^gamma
 end

 dbuf.vgam = vgam

 return dbuf
end
--

-- Fractional Index-based plotting with Transparency only, for 256 color gradients. Optional drawing.
-- (we may need a progressive mode as well (drawing on current rather than backup))
-- Homing missiles uses realtime plotting and needs getbackuppixel since they use background when replacing basic missile-plots
--
function drawb.IndexFractionalPlotDraw(dbuf, x,y, stamp,mult, plot_flag) -- stamp = transparency
   local ix,iy,fx,fy,v0,v1,v2,v3, igam,icolgamma,c,i,gam, p0,p1,p2,p3, mult1, ix1,iy1, vgam

   ix,iy = math.floor(x), math.floor(y)
   fx,fy = x - ix, y - iy

   mult1,ix1,iy1 = mult - 1, ix + 1, iy + 1

   p0 = (1-fx)*(1-fy)
   p1 = fx*(1-fy)
   p2 = (1-fx)*fy
   p3 = fx*fy

   v0 = drawb.IndexPlot(dbuf, ix,  iy,  stamp * p0, 1 + mult1 * p0)
   v1 = drawb.IndexPlot(dbuf, ix1, iy,  stamp * p1, 1 + mult1 * p1)
   v2 = drawb.IndexPlot(dbuf, ix,  iy1, stamp * p2, 1 + mult1 * p2)
   v3 = drawb.IndexPlot(dbuf, ix1, iy1, stamp * p3, 1 + mult1 * p3)

   if plot_flag then
    vgam = dbuf.vgam -- List of all index values 0-255 with gamma applied
     gam = dbuf.gamma
    igam = dbuf.igam
    icolgamma = dbuf.icolgamma -- Ink index with gamma applied
    --c = getbackuppixel(ix, iy);  i = (vgam[c+1] *(1-v0) + icolgamma * v0)^igam; putpicturepixel(ix, iy, i) --c^gam
    -- same as...
    c = vgam[1+getbackuppixel(ix, iy)];  i = (v0 * (icolgamma - c) + c)^igam; putpicturepixel(ix, iy, i)
    c = vgam[1+getbackuppixel(ix1,iy)];  i = (v1 * (icolgamma - c) + c)^igam; putpicturepixel(ix1,iy, i)
    c = vgam[1+getbackuppixel(ix, iy1)]; i = (v2 * (icolgamma - c) + c)^igam; putpicturepixel(ix, iy1,i)
    c = vgam[1+getbackuppixel(ix1,iy1)]; i = (v3 * (icolgamma - c) + c)^igam; putpicturepixel(ix1,iy1,i)
   end

end
--

-- Drawing to Buffer (Integer)
-- Since it returns a value for plotting, even t = 0 must be processed
-- With the lack of RGB values, Index-mode is not completely compatible with the normal dbuf-system,
-- There's no need to keep redudnant information that greatly slows down the process...
-- ...so only the Transparancy is stored. For rendering; x & y coords can be derived from p.
--
function drawb.IndexPlot(dbuf, x,y, t, mult)
 local p,w

 w = dbuf.w
 if x >= 0 and x < w then 
  if y >= 0 and y < dbuf.h then

    p = 1 + y*w + x

    if dbuf[p] == nil then
     dbuf.list[#dbuf.list + 1] = p -- List of active pixels in the buffer
     dbuf[p] = t    -- {0,0,0,t,x,y}, dbuf[p][4]
      else
       t = math.min(1, (1-t) * dbuf[p] * mult + t)  -- Mult is an enhancement effect of overdrawn areas, making busy areas exp. stronger
       dbuf[p] = t
    end

  end -- if y
 end -- if x
 return t
end
--

-- 
-- old, pre icol removal: drawb.indexLineAA(dbuf,x1,y1,x2,y2,stamp,mult,icol, plot_flag, skip)
--
function drawb.indexLineAA(dbuf,x1,y1,x2,y2,stamp,mult, plot_flag, skip)
 local n,st,m,x,y,x_1,y_1,xf,yf,stx,sty; 
 m = math
  
 -- Skip first plot if last plot ended in the same position. Method for avoding double plotting joints in drawTo line drawing (A-BB-C). 
 -- Probably not a perfect solution but it works very well.
 skip = skip or 0 

 x,y = x1,y1 -- make sure we have a return coord
 st = m.max(1,m.abs(x2-x1),m.abs(y2-y1))
 stx = (x2-x1)/st
 sty = (y2-y1)/st
 for n = skip, st, 1 do

   x = x1 + n * stx
   y = y1 + n * sty

   --drawb.FracPlot(dbuf, x,y, r,g,b, t)
   drawb.IndexFractionalPlotDraw(dbuf, x,y, stamp,mult, plot_flag) 

 end
 return x,y
end
--

-- Is this actually used anywhere? When would one want to plot a single pixel in the curent buffer?
-- (other than as a sub-function to IndexRenderBuffer)
function drawb.IndexRenderPixel(dbuf,p,transp)
  local x,y,t,c,i,w
  w =  dbuf.w
  transp = transp or 1
  t = dbuf[p] * transp
  p = p - 1 -- index adjust (otherwise the image is shifted a pixel to the right)
  y = math.floor(p / w) 
  x = p - y * w
  c = getbackuppixel(x, y);
  if t == 0 then i = c -- Rounding error for exponents may return a lower index when transp == 0
   else  
    i = (c^dbuf.gamma*(1-t) + dbuf.icolgamma * t)^dbuf.igam; -- possible rounding error here, custom rounding? 
  end
  putpicturepixel(x, y, i)
end
--

--
-- icol is drawing palette index (usually 0 or 255), why arg, it's defined in the buffer init
-- We never vary icol during one use of a buffer, do we? icol is not used here, only icolgamma
--
-- current_flag: Draw/Blend buffer over existing/current image rather than the backup (image before script was run)
--
function drawb.IndexRenderBuffer(dbuf, current_flag)
local n,list,r,g,b,t,x,y,w,h,gam,igam,p,i,floor,f_get
 floor = math.floor
 list = dbuf.list
 gam = dbuf.gamma
 igam = dbuf.igam
 w = dbuf.w
 icolgamma = dbuf.icolgamma

 f_get = getbackuppixel
 if current_flag then f_get = getpicturepixel; end

 for n = 1, #list, 1 do
  p = list[n]
  t = dbuf[p]
  p = p - 1 -- index adjust (otherwise the image is shifted a pixel to the right)
  y = floor(p / w) 
  x = p - y*w
 
  c = f_get(x, y);  
   --gam = 1 + (1-(c / 255)) * 1.2; igam = 1 / gam;  icolgamma = icol^gam -- Background Gamma
  i = (c^gam*(1-t) + icolgamma * t)^igam; putpicturepixel(x, y, i)
  --if n%100 == 0 then updatescreen(); waitbreak(0); end
 end
end
--

------ eof Index system ----------


---------- eof Draw Buffer -----------
