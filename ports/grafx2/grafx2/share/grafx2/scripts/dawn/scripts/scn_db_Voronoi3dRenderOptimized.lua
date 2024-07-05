--SCENE: Voronoi 3d (psuedo 4d) Render V1.5
--(Optimized version; Quadrant division) 
--by Richard 'DawnBringer' Fhager 


-- (V1.5 Localized, Root removed from Normal distance, total +100% faster) 

--
function main()

 local POINTS, DIST_MODE, APP_MODE, COLMULT, app1,app2,app3,dist0,dist1,Gradient
 local x,y,z,n,md,w,h,s,dist,xx,yy,xs,ys,sx,sy,xpx,ypy,best,best2,mindist,mindist2,xslot,yslot,dist_avg
 local total,xplot,xdiv,ydiv,px,py,pzw2,cut,min_points_per_slot
 local p, slots, super, points, slot
 local floor,ceil,rnd,max,min,abs,sin,cos

POINTS = 500

OK, POINTS,dist0,dist1,app0,app1,app2,app3,Gradient = inputbox("Voronoi 3D+ Render",
                        
         "POINTS: 1-500.000",     POINTS, 1,500000,0,
   
         "1. Euclidean Distance", 1,  0,1,-1,
         "2. Manhattan Distance",   0,  0,1,-1,
     
         "a) Normal Mode",        1,  0,1,-2,
         "b) Ice (2nd closest)",  0,  0,1,-2,
         "c) Bright Crystals",    0,  0,1,-2,
         "d) Tribal",             0,  0,1,-2,

        "Set Gradient Palette",  1, 0,1,0 
   
      --"Get POINTS from Image?", 0, 0,1,0,    
      --"Strength Mult. (0.1-5)",  MULT, 0.1,5,2,                                                       
);


if OK then

 DIST_MODE = 0 -- 0 = Normal, 1 = Manhattan (Sum)
 if dist1 == 1 then DIST_MODE = 1; end
 APP_MODE = 0 -- 0 = Normal, 1 = Ice (2nd dist), 2 = Crystals (bright), 3 = Tribal
 if app1 == 1 then APP_MODE = 1; end
 if app2 == 1 then APP_MODE = 2; end
 if app3 == 1 then APP_MODE = 3; end

 if Gradient == 1 then
  dofile("../gradients/pal_db_SetSteelBlue_256.lua")
 end

 w,h = getpicturesize()

  floor = math.floor
  ceil = math.ceil
  rnd = math.random
  max = math.max
  min = math.min
  abs = math.abs
  sin = math.sin
  cos = math.cos 

 z = 0.1 * (w*h)^0.5

dist_avg = 0.75 * (w*h*z*z/POINTS)^(1/4)*4^0.5   -- pseudo 4D

COLMULT = 1*(220 / dist_avg) -- distances shorten with more points and incr. with dimensions, around 2.8 seem good for 1000 points, 5.7 is good for 10.000 

points = {}
for n = 1, POINTS, 1 do

 points[n] = {rnd()*w,rnd()*h,(rnd()*z)^2+(rnd()*z)^2, -1} -- pseudo 4D, looks good..Conical distribution, more points at deeper depth
 --points[n] = {rnd()*w,rnd()*h,((rnd()*z)^2+(rnd()*z)^2+0.5*(rnd()*z)^2)*0.8, -1} -- Pseudo 4.5d 
 --points[n] = {rnd()*w,rnd()*h,((rnd()*z)^2+(rnd()*z)^2+(rnd()*z)^2)*0.5, -1} -- Pseudo 5d 
 --points[n] = {rnd()*w,rnd()*h,(rnd()*z *1.5)^2, -1} -- Plain 3D
end



 clearpicture(64)


-- Quadrant Optimization

cut = 25
-- More points/slot means bigger slots and less chance of failure, 10 seems safe
-- This formula tries to use more slots for lesser amounts of points (which seems ok, coz the slots are relatively big compared to z-depth)
min_points_per_slot = min(10,1 + floor(POINTS^0.25)) 
-- cut28: 10 = 11.000, 15 = 16.000 (with a max of 28 slots and 10 pts/slot, the max28 will be reached with 11.000 points = weakest situation)
-- cut27: 10 = 9.800, 
-- cut25-dynamic about 9000


if APP_MODE > 0 then -- mindist2 in play
 cut = 23; 
 min_points_per_slot = ceil(math.min(10,1 + floor(POINTS^0.25)) * 1.5)
end 


slots = POINTS / min_points_per_slot

if w>=h then
 sx = max(2,floor((slots / (w/h))^0.5))
 sy = max(2,floor(sx * h/w))
  else   
    sy = max(2,floor((slots / (h/w))^0.5))
    sx = max(2,floor(sy * w/h))
end


xslot = min(sx,cut)
yslot = min(sy,cut)


xdiv = (w / xslot)
ydiv = (h / yslot)

for y = 1, yslot, 1 do yp = y * ydiv; drawline(0,yp,w,yp,1); end
for x = 1, xslot, 1 do xp = x * xdiv; drawline(xp,0,xp,h,1); end

--messagebox(xslot.." "..yslot)

slots = {}
super = {}
for y = 1, yslot, 1 do
 slots[y] = {}
 super[y] = {}
 for x = 1, xslot, 1 do
  slots[y][x] = {}
  super[y][x] = {}
 end
end

for n = 1, POINTS, 1 do
 p = points[n]
 px,py,pzw2 = p[1],p[2],p[3]
 x = 1 + floor(px / xdiv)
 y = 1 + floor(py / ydiv)
 slots[y][x][#slots[y][x]+1] = n
end


-- Check if all points have been included in a slot
total = 0
xplot = floor(xdiv/3)
for y = 1, yslot, 1 do
 yp = (y-1) * ydiv + ydiv/8
 for x = 1, xslot, 1 do
   xp = (x-1) * xdiv + xdiv/8
   for n = 0, #slots[y][x]-1, 1 do -- Points in slot
     total = total + 1
     putpicturepixel(xp+(n-floor(n/xplot)*xplot)*2,yp+floor(n/xplot)*2,1)
   end
 end
end

--messagebox(total)


-- Superslots, summarize all points in 3x3 slot regions
for y = 1, yslot, 1 do
 for x = 1, xslot, 1 do
  for yy = -1, 1, 1 do
   for xx = -1, 1, 1 do
    ys = y + yy
    xs = x + xx
    if ys>0 and ys<=yslot and xs>0 and xs<=xslot then
      s = slots[ys][xs]
      for n = 1, #s, 1 do
       super[y][x][#super[y][x]+1] = s[n]
      end
    end
   end
  end 
 end
end
--


md = ((w+h)^3)^2
for y = 0, h - 1, 1 do

 sloty = super[1 + floor(y / ydiv)]

 for x = 0, w - 1, 1 do

  mindist,best,slot = md, -1, sloty[1 + floor(x / xdiv)]

  if DIST_MODE == 0 then -- Normal
    for n = 1, #slot, 1 do
     p = points[slot[n]]
     xpx,ypy = x-p[1],y-p[2]
     dist = xpx*xpx + ypy*ypy + p[3] -- Normal
       if dist <= mindist then 
         mindist2,mindist,best2,best = mindist,dist,best,n
          else if dist < mindist2 then best2,mindist2 = n,dist; end
       end
    end -- slot
    mindist = mindist^0.5
    mindist2 = mindist2^0.5
  end -- Normal

  if DIST_MODE == 1 then -- Manhattan
    for n = 1, #slot, 1 do
     p = points[slot[n]]
     xpx,ypy = x-p[1],y-p[2]
     dist = abs(xpx)+abs(ypy)+p[3]^0.5 -- Sum (Mahattan), Maxdist should be about x1.5 of euclidean
       if dist <= mindist then 
         mindist2,mindist,best2,best = mindist,dist,best,n
          else if dist < mindist2 then best2,mindist2 = n,dist; end
       end
    end -- slot
    mindist = mindist * 0.7
    mindist2 = mindist2 * 0.7
  end -- Manhattan

  

  if APP_MODE > 0 then
   if APP_MODE == 1 then v = mindist2; end                   -- "Ice" (4)
   if APP_MODE == 2 then v = (mindist2^2-mindist^2)^0.5; end -- "Bright Crystals (dark lines)" (4)
   if APP_MODE == 3 then v = sin(mindist/(7.5+cos(mindist2))) * mindist2 * 1.5; end -- (3) "Tribal", looks good with 500-1000 points 
    else
     v = mindist
  end

  putpicturepixel(x, y, max(0,min(v * COLMULT,255)));
 end
 updatescreen();if (waitbreak(0)==1) then return end
end


 end -- OK

end
-- main

t1 = os.clock()

main()

--messagebox("Seconds: "..(os.clock() - t1))





-- App modes
  --v = 100; if mindist2-mindist < 1 then v = 0; end
 --v = (mindist2*mindist)^0.5 -- "Blurry Ghostlines" (2)
  --v = ((0.1+mindist) / (0.1+mindist2))^2 * 103.2 -- "Glowlines" (3) 
  --v = (mindist2-mindist)*1.45 -- "Dark Crystals" (3)
  -- Appearance(s) changes drastically depending on divisor, ex 5,25,50...
  --v = math.sin(mindist/25) * mindist2