---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--  Cloud Fractal V1.0 (Palette index based) 
--
--  Program-Function (pfunction) - Dependencies: dawnbringer_lib.lua
--
--  by Richard 'DawnBringer' Fhager (dawnbringer@hem.utfors.se)
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- 
-- Usage:
-- dofile("../pfunctions/pfunc_CloudFractal.lua")(args..)
-- or
-- myfunc = dofile("../pfunctions/pfunc_CloudFractal.lua"); myfunc(args..)
--
--
-- Arguments:
--[[
 Max_Iter      = 9            -- Max iterations, Iteration starts at 0 (a four corner backdrop)
 Min_Split     = 2            -- "Detail", Don't split area if its smallest side isn't bigger than this, 1 works fine, use max 2 for with lines
 Offset        = 0.65;        -- Midppoint offset randomization (0..0.99) 0 = Classic Clouds   
 Detail_Exp    = 1.8          -- "Smoothness", nom = 2.0, Base for exponetial detail fade by iteration (higher = smoother)
 Var_Strength  = 192          -- "Variation" (amplitude), 0..512 (lower = smoother)
 Mode          = "linear"/ "cosine" / "rect" / "lines" / ("imgrec") (there are two line modes, line overlay and lines only)  
 Line_Strength = 0            -- Draw lines, strength 0..1
 Dither_Flag   = true/false   -- Treshold dither
 Seed          = Random Seed >=0 [OPTIONAL]
 Object        = {xpos=10,ypos=20, xsiz=100,ysiz=50} [OPTIONAL]
--]]
--
---------------------------------------------------------------------------------------


dofile("../libs/dawnbringer_lib.lua")

return function(Max_Iter, Min_Split, Offset, Detail_Exp, Var_Strength, Mode, Line_Strength, Dither_Flag, Seed, Object)

 --Mode = "imgrec"

 local w,h,xp,yp,c1,c2,c3,c4,off5,rnd,cos,floor,PI,min,max
 local rec,cap,imageRectangle,backdrop_fpoint,drawBackdrop,ImgPlot 

   rnd = math.random
   cos = math.cos
   min = math.min
   max = math.max
 floor = math.floor
    PI = math.pi 

 math.randomseed(os.clock())

 Seed = Seed or -1
 if Seed == -1 then Seed = rnd(0,1000000); end 
 math.randomseed(Seed)

 Off5 = Offset*0.5 - 0.5

--
function cap(v)
 return min(255,max(0,v))
end
--

------------------ for imgrec mode (not really in use or very useful, FractalSplit script is better)
function imgPlot(x,y,r,g,b) -- for db.backdrop
 putpicturepixel(x,y,matchcolor(r,g,b))
end

--
function imageRectangle(x,y,xs,ys)
 local r1,g1,b1, r2,g2,b2,  r3,g3,b3, r4,g4,b4, c   
 r1,g1,b1 = getcolor(getbackuppixel(x,y))
 r2,g2,b2 = getcolor(getbackuppixel(x+xs-0,y)) -- Not -1 coz we need the same pixel for different cells
 r3,g3,b3 = getcolor(getbackuppixel(x,y+ys-0))  -- But it means coords outside screen on first iteration
 r4,g4,b4 = getcolor(getbackuppixel(x+xs-0,y+ys-0))
 c = matchcolor((r1+r2+r3+r4)/4, (g1+g2+g3+g4)/4, (b1+b2+b3+b4)/4)
 db.drawRectangle(x,y,xs,ys,c)
 --db.backdrop({x,y,r1,g1,b1},{x+xs-1,y,r2,g2,b2},{x,y+ys-1,r3,g3,b3},{x+xs-1,y+ys-1,r4,g4,b4},imgPlot,"cosine") -- points:{x,y,r,g,b}
end
--
-------------------

--
function backdrop_fpoint(xf,yf,c1,c2,c3,c4,ip_mode) -- IpMode "linear" is default
   local xr,yr
    if ip_mode == "cosine" then 
     yf = 0.5 - cos(yf * PI) * 0.5
     xf = 0.5 - cos(xf * PI) * 0.5
    end
    yr = 1 - yf
    xr = 1 - xf
    return (c1*xr + c2*xf)*yr + (c3*xr + c4*xf)*yf;
end
--

--
-- Draw a Backdrop/Plasma from Palette indexes (256 color gradient)
--
function drawBackdrop(x,y,xs,ys,c1,c2,c3,c4,ip_mode,dither_flag) -- IpMode "linear" is default
   local ox,oy,xr,yr,c,px,py,dith,ypy
    dith = 0
    for py = 0, ys - 1, 1 do
     oy = py / ys   
     ypy = y+py
     if ip_mode == "cosine" then oy = 0.5 - cos(oy * PI) * 0.5; end
     yr = 1 - oy
     for px = 0, xs - 1, 1 do
      ox = px / xs  
      if ip_mode == "cosine" then ox = 0.5 - cos(ox * PI) * 0.5; end
      xr = 1 - ox
      c = (c1*xr + c2*ox)*yr + (c3*xr + c4*ox)*oy;
      if dither_flag then dith = (y+py+x+px)%2 * 0.5; end -- Add some dither
      putpicturepixel(x+px,ypy,cap(c + dith)) 
     end
    end
end
--


function rec(x,y,xs,ys,c1,c2,c3,c4,iter) -- Recursive 4-split Cloud fractal
 local s,r,m,c12,c13,c24,c34,cmd,v1,ox,oy,xs1,xs2,ys1,ys2

 -- Normal clouds (no center point offset) works best with cosine, (strong) offsets (and few iter) work best with linear, 1 iter works with Cosine
 ox = rnd()*Offset - Off5 -- +0.5
 oy = rnd()*Offset - Off5 -- +0.5
 xs1 = floor(xs * ox)
 ys1 = floor(ys * oy)
 xs2 = xs - xs1
 ys2 = ys - ys1 

 if Mode == "lines" then -- Just draw these overlapping lines (older = darker)
  db.lineTransp(x,y,x+xs-1,y,0,Line_Strength); db.lineTransp(x,y,x,y+ys-1,0,Line_Strength)
 end

 if iter < 3 then updatescreen();if (waitbreak(0)==1) then return end; end

 if iter < Max_Iter and min(xs1,ys1) >= Min_Split and min(xs2,ys2) >= Min_Split then -- 9 iterations are usually enough, 10 is most ever needed?
 
  v1 = Var_Strength / Detail_Exp^iter
  c12 = c1*(1-ox) + c2*ox
  c13 = c1*(1-oy) + c3*oy
  c24 = c2*(1-oy) + c4*oy
  c34 = c3*(1-ox) + c4*ox
  cmd = (c1+c2+c3+c4) / 4  + rnd(-v1,v1) -- "incorrect" but more aesthetically pleasing?
  --cmd = cap(backdrop_fpoint(ox,oy,c1,c2,c3,c4,"linear")  + math.random(-v1,v1)) -- "Correct color"
  rec(x,y,        xs1,ys1,c1,  c12, c13, cmd,iter+1)
  rec(x+xs1,y,    xs2,ys1,c12,  c2, cmd, c24,iter+1)
  rec(x,y+ys1,    xs1,ys2,c13, cmd,  c3, c34,iter+1)
  rec(x+xs1,y+ys1,xs2,ys2,cmd, c24, c34,  c4,iter+1)
   else 
      if xs > 0 and ys > 0 and Mode ~= "lines" then -- Don't draw 0 size cells

          if Mode == "rect" then
           db.drawRectangle(x,y,xs,ys,cap(c1)) --  I like just using c1 rather than color average for stylistic reasons (avg is so close to ip)
          end
          if Mode == "cosine" or Mode == "linear" then      
             drawBackdrop(x,y,xs,ys,c1,c2,c3,c4,Mode,Dither_Flag) -- Interpolated backdrop
          end
          if Mode == "imgrec" then
           imageRectangle(x,y,xs,ys)
          end         

          if Line_Strength > 0 then
           --db.line(x,y,x+xs-1,y,cap(c1)); db.line(x,y,x,y+ys-1,cap(c1))
           db.lineTransp(x,y,x+xs-1,y,0,Line_Strength); db.lineTransp(x,y,x,y+ys-1,0,Line_Strength)
          end
      end
 end
end

-- Xpos,Ypos,width,height,corner colors (pal index), iteration
if Object == null then
 w,h = getpicturesize()
 xp,yp = 0,0
  else xp,yp,w,h = Object.xpos,Object.ypos,Object.xsiz,Object.ysiz
end 
c1 = rnd(0,255)
c2 = rnd(0,255)
c3 = rnd(0,255)
c4 = rnd(0,255)
rec(xp,yp,w,h, c1,c2,c3,c4,0)

end
----------------------
-- eof fractalCloud --
----------------------
