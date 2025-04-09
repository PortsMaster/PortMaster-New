--SCENE: Fractal Clouds v0.96wip
--by Richard 'DawnBringer' Fhager
--
-- * Recursive 4-split Fractal
-- * Gradient Plasma/Fractal with Sigmoid Interpolation
-- * High-Quality Palette Generation by MedianCut on large sample
-- * Advanced Dithered Rendering
--
-- upd: 2014-11-28 IterExp currently not a factor, using 2^iter for fading power
-- Is there any reason to have termination chance with the current model? (It just looks bad)

Q = 0

dofile("../libs/dawnbringer_lib.lua")

--
function main()

 local core, backdrop_point, backdrop_fade
 local floor, cos, pi, rnd

 floor, cos, pi, rnd = math.floor, math.cos, math.pi, math.random

--
function backdrop_point(x,y,p0,p1,p2,p3,ip_mode) -- points:{x,y,r,g,b}, IpMode "linear" is default
   local ox,oy,xr,yr,r,g,b,ax,ay,w,h
    ax,ay = p0[1],p0[2]
    w = p1[1] - p0[1]
    h = p2[2] - p0[2]
    oy = (y-ay)/h
    if ip_mode == "cosine" then oy = 1 - (cos(oy * pi) + 1)/2; end
    yr = 1 - oy
    ox = (x-ax)/w
    if ip_mode == "cosine" then ox = 1 - (cos(ox * pi) + 1)/2; end
    xr = 1 - ox
    r = (p0[3]*xr + p1[3]*ox)*yr + (p2[3]*xr + p3[3]*ox)*oy;
    g = (p0[4]*xr + p1[4]*ox)*yr + (p2[4]*xr + p3[4]*ox)*oy;
    b = (p0[5]*xr + p1[5]*ox)*yr + (p2[5]*xr + p3[5]*ox)*oy;
    return r,g,b
end
--

--
-- Backdrop/Gradient Render (May be written to a matrix for rendering with db.fsrender)
--
 function backdrop_fade(p0,p1,p2,p3,fput,ip_mode, m0,m1,m2,m3,fade,fcount) -- points:{x,y,r,g,b}, IpMode "linear" is default

   local x,y,ox,oy,xr,yr,r,g,b,ax,ay,w,h, ro,go,bo, yay

   ax,ay = p0[1],p0[2]

   w = p1[1] - p0[1]
   h = p2[2] - p0[2]

  for y = 0, h, 1 do -- +1 to fill screen with FS-render

    oy = y/h
    if ip_mode == "cosine" then oy = 1 - (cos(oy * pi) + 1)/2; end
    yr = 1 - oy
    yay = y + ay

   for x = 0, w, 1 do 

    ox = x/w
    if ip_mode == "cosine" then ox = 1 - (cos(ox * pi) + 1)/2; end
    xr = 1 - ox

    r = (p0[3]*xr + p1[3]*ox)*yr + (p2[3]*xr + p3[3]*ox)*oy;
    g = (p0[4]*xr + p1[4]*ox)*yr + (p2[4]*xr + p3[4]*ox)*oy;
    b = (p0[5]*xr + p1[5]*ox)*yr + (p2[5]*xr + p3[5]*ox)*oy;

    if fade then  -- So "fade" means not terminating but "fading" the next fractal divisions?
      f0 = 0.25 -- Lower means more "fade"
      f1 = 1 - f0
      ro,go,bo = backdrop_point(ax+x,ayy,m0,m1,m2,m3,ip_mode)
      r = r*f0 + ro*f1 
      g = g*f0 + go*f1
      b = b*f0 + bo*f1
      --r,g,b = 0,0,0
    end
  

    fput(x+ax,yay,r,g,b)

   end;end

  end
-- eof backdrop


function core(Iter,InitMode,RandBri,RandHue,IterMult,IterExp,TermChance,MakePal,Dither,IpMode)

 local Img,fget,fput,fcontrol,frend,frand,cap,x,y,w,h,r,g,b,n,v,npal
 local Mr,Total,Count,Render,Update
 local P0,P1,P2,P3
  
 Mr = math.random

 Render = true
 Total = db.recursiveSum(4,Iter)
 Count = 0

 Update = Iter*Iter*Iter -- Done% update modulus value
 
  function frand(r,g,b,iter_count) -- Right now iter_count is 0 during first iteration
   local v,hu,br,deg,div
   --div = (iter_count*IterMult)^IterExp + 1
   div = IterMult * 2^iter_count -- Itermult is smoothness, 2^iter_count gives powerfade over iterations
   br = RandBri
   hu = RandHue
   deg = Mr(-hu,hu) / div
   r,g,b = db.shiftHUE(r,g,b,deg)
   v = Mr(-br,br) / div
   return r+v,g+v,b+v  
  end


 -- Recursive control function
 --
 function fcontrol(p0,p1,p2,p3,iter_count, m0,m1,m2,m3,fade,fcount)
  local x,y,r01,g01,b01,r02,g02,b02,r13,g13,b13,r23,g23,b23,r55,g55,b55

  --IterMult = 0.8
  --IterExp  = 1.8
  --RandBri  = 192
  --RandHue  = 90

  if iter_count < Iter then

   if fade == false and ((TermChance > rnd(0,99)) and not(rnd(0,iter_count) == 0)) then
    m0,m1,m2,m3,fade,fcount = p0,p1,p2,p3,true,Iter-iter_count -- Fade is turned on here
   end

   x = floor((p0[1] + p1[1]) / 2)
   y = floor((p0[2] + p2[2]) / 2)

   r01 = (p0[3] + p1[3])/2
   g01 = (p0[4] + p1[4])/2
   b01 = (p0[5] + p1[5])/2

   r02 = (p0[3] + p2[3])/2
   g02 = (p0[4] + p2[4])/2 
   b02 = (p0[5] + p2[5])/2 
   
   r13 = (p1[3] + p3[3])/2 
   g13 = (p1[4] + p3[4])/2 
   b13 = (p1[5] + p3[5])/2 
   
   r23 = (p2[3] + p3[3])/2 
   g23 = (p2[4] + p3[4])/2 
   b23 = (p2[5] + p3[5])/2 
   
   r55,g55,b55 = frand((p0[3] + p1[3] + p2[3] + p3[3])/4, (p0[4] + p1[4] + p2[4] + p3[4])/4, (p0[5] + p1[5] + p2[5] + p3[5])/4, iter_count) -- iter_count is 0 initally

       Count = Count + 4
       if (Count % Update == 0) then 
        statusmessage(Count.." / "..Total); --updatescreen(); 
        if (waitbreak(0)==1) then Iter = 0; Render = false; return; end;
       end
       fcontrol(p0, {x,p0[2],r01,g01,b01}, {p0[1],y,r02,g02,b02}, {x,y,r55,g55,b55},         iter_count+1, m0,m1,m2,m3,fade,fcount)
       fcontrol(    {x,p0[2],r01,g01,b01}, p1, {x,y,r55,g55,b55},     {p1[1],y,r13,g13,b13}, iter_count+1, m0,m1,m2,m3,fade,fcount)
       fcontrol({p0[1],y,r02,g02,b02}, {x,y,r55,g55,b55}, p2, {x,p2[2],r23,g23,b23},         iter_count+1, m0,m1,m2,m3,fade,fcount)
       fcontrol({x,y,r55,g55,b55}, {p1[1],y,r13,g13,b13}, {x,p2[2],r23,g23,b23}, p3,         iter_count+1, m0,m1,m2,m3,fade,fcount)
      else
        backdrop_fade(p0,p1,p2,p3,fput,IpMode, m0,m1,m2,m3,fade,fcount) 
   end -- if iter

 end -- Control
 --


 w,h = getpicturesize()

 Img = {}
 for y = 0, h+1, 1 do  -- FS Expanded
  Img[y+1] = {}; for x = 0, w+1, 1 do 
  Img[y+1][x+1] = {0,0,0}
 end; end
 
 function fget(x,y) return Img[floor(y)+1][floor(x)+1]; end
 function fput(x,y,r,g,b) Img[floor(y)+1][floor(x)+1] = {r,g,b}; end -- rgb array won't work as it's just a reference
 
 
 if InitMode == "color" then
  P0 = {0,0,       Mr(0,255), Mr(0,255), Mr(0,255)}
  P1 = {w-1,0,     Mr(0,255), Mr(0,255), Mr(0,255)}
  P2 = {0,h-1,     Mr(0,255), Mr(0,255), Mr(0,255)}
  P3 = {w-1,h-1,   Mr(0,255), Mr(0,255), Mr(0,255)}
 end

 if InitMode == "grey" then
  v = Mr(0,255); P0 = {0,0,       v,v,v}
  v = Mr(0,255); P1 = {w-1,0,     v,v,v}
  v = Mr(0,255); P2 = {0,h-1,     v,v,v}
  v = Mr(0,255); P3 = {w-1,h-1,   v,v,v}
 end

 if InitMode == "read" then
  P0 = {0,0,       getcolor(getpicturepixel(0,0))}
  P1 = {w-1,0,     getcolor(getpicturepixel(w-1,0))}
  P2 = {0,h-1,     getcolor(getpicturepixel(0,h-1))}
  P3 = {w-1,h-1,   getcolor(getpicturepixel(w-1,h-1))}
 end

 fcontrol(P0,P1,P2,P3,0,{},{},{},{},false,-1)
 --

 -- RENDER

 if Render == true then

 function frend(x,y,w,h) -- Render Engine function
  local rgb
  rgb = fget(x,y)
  return rgb[1],rgb[2],rgb[3]
 end

 --
 if MakePal > 0 then
  -- We sometimes get a black color since I think we may read outside the painted matrix (not sorting's fault)
  npal = db.makeSamplePal(w,h,MakePal,frend)
  for n=1, #npal, 1 do setcolor(n-1,npal[n][1],npal[n][2],npal[n][3]); end
 end
-- 

 -- Render
 local ditherprc,xdith,ydith,percep
 --pal = db.fixPalette(db.makePalList(MakePal)) -- Render does not use this currently, instead Matchcolor2
 ditherprc = math.min(99,math.ceil(Dither^1.25) * 22) -- 00 - 22 - 66 - 88 - 99 - 99
 xdith  = Dither * 1 -- 5
 ydith  = Dither * 2 -- 10
 percep = -1 -- Not used anymore
 -- Uses Matchcolor2 with 0% brightness-weight as default
 --db.fsrender(f,pal,ditherprc,xdith,ydith,percep,xonly, ord_bri,ord_hue,bri_change,hue_change,BRIWEIGHT, wd,ht,ofx,ofy)
 db.fsrender(frend,{},ditherprc,xdith,ydith,percep)
 --

 end -- eof Render

end -- core

Levels   = 8        -- RecursionLevels/Iterations(0-10), 0 = Backdrop between the 4 corners
InitMode = "color"  -- InitMode("color","grey","read")
RandBri  = 128      -- RandBri  = 192
RandHue  = 120       -- RandHue  = 90
IterMult = 1.0      -- IterMult = 0.8
--IterExp  = 1.8      -- IterExp  = 1.8
MakePal  = 256      -- MakePal Colors 0 = off 
Dither   = 3        -- DitherLevel(0-3+)
TermChance = 0
IpMode   = "linear" -- InterpolationMode("linear","cosine")

OK,Levels,RandBri,RandHue,IterMult,TermChance,Dither,MakePal,Read  = inputbox("Fractal Clouds v0.96wip",

                           "Iterations (0 = gradient)",             Levels,     0,10,0,  
                           "BRI Variation",      RandBri,    0,512,0, 
                           "HUE Variation (deg)",RandHue,    0,180,0,  
                           "Smoothness: 0.1-10",    IterMult,   0.1,10,3, 
                           --"(Iter Fade Exponent)", IterExp,    0.1,5,3, -- IterExp
                           "Terminate Chance %", TermChance,    0,99,0,  
                           "Dither Strength: 0-4",  Dither,     0,5,0, 
                           "Make Sample-Palette", 1,0,1,0,   
                           --"Cosine Interpolation",   0,0,1,0,    
                           "Use Image Corner Cols", 0,0,1,0                                       
);

if OK then

 if MakePal>0 then MakePal = 256; end
 if RandHue == 0 then InitMode = "grey"; end
 if Read    == 1 then InitMode = "read"; end
 --if TermChance == 0 then IpMode = "cosine"; end

 core(Levels,InitMode, RandBri,RandHue, IterMult,IterExp,TermChance,MakePal,Dither,IpMode)

end


end
-- main

main()




