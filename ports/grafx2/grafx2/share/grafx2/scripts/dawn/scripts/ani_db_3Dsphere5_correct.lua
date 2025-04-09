--ANIM: 3D-Sphere
--by Richard 'Dawnbringer' Fhager


dofile("../libs/dawnbringer_lib.lua")

setpicturesize(640,640)
dofile("../gradients/pal_db_SetWatermelon_256.lua")

--updatescreen()


function main()

 local ANIM,XANG, YANG, ZANG, ZOOM, XD, YD, WORLD_X, WORLD_Y
 local XSPEED,YSPEED,ZSPEED,XPOINTS,YPOINTS, BKG_COL, FIRST
 local w,h,p,x,y,z,n,l,p1,p2, PrepareExit
 local draw_lines, draw_points
 local cos,sin,pi2,floor,min,max
 local rotate3D_ALL, initAndReset
 local boxp,pts,lin

 PrepareExit = false

 cos = math.cos
 sin = math.sin
 min = math.min
 max = math.max
 pi = math.pi
 pi2 = math.pi * 2
 floor = math.floor

 draw_lines  = true
 draw_points = true

 -- Sphere points
 XPOINTS = 30 -- Latitudes
 YPOINTS = 60

 w,h = getpicturesize()

 CX,CY = w/2, h/2
 SIZE = math.min(w,h)/4
 DIST = 5 -- Distance perspective modifier, ~5 is nominal, more means "less 3D" 
 ANIM = 1
 FIRST = 1 -- Inital zoom anim

 -- Anim Rotation Speed (org /300,/500,/1000)
 XSPEED = pi / 600
 YSPEED = pi / 1000
 ZSPEED = pi / 2000

 BKG_COL = matchcolor(0,0,0)

--pal = db.fixPalette(db.makePalList(256))

--FG = getforecolor() 
--BG = getbackcolor()

--
function initPointsAndLines(xpoints,ypoints)
 
 local n,r,x,y,xf,yf,lat,lon,xp,yp,zp,nopoles
 local pts,lin

 -- xpoints is latitudes

 pts = {}
 lin = {}
 n = 0
 -- This all produces [ypoints] points in the single point at the poles
 for y = 0, ypoints-1, 1 do
  for x = 0, xpoints-1, 1 do

   --
   nopoles = 1  -- Draw poles? 1 = yes, 0 = no

   r = 1
   xf = 1 / (xpoints-(1-nopoles)) -- all the way to the 2nd pole
   yf = 1 / ypoints
      --r = 0.75+(math.pi*2) * yf * y * 0.25 -- "Snail"
      --r = math.sin((math.pi*1) * xf * x) * 1 -- Torso
      --r = 1 + math.sin(math.pi/2 + math.pi*2 * xf * x) * 0.5 -- Strangle the waist
   lat = (math.pi*1) * xf * x 
   lon = (math.pi*2) * yf * y -- Longitudes go around 360 degrees
   xp = r * sin(lat) * cos(lon) 
   yp = r * sin(lat) * sin(lon) 
   zp = r * cos(lat) --* sin(lon) --* 0.5

   n = n + 1
   pts[n] = {xp,yp,zp}
  end
 end

 if nopoles == 1 then -- Add points for poles
   n = n + 1
   pts[n] = {0,0,r}
   n = n + 1
   pts[n] = {0,0,-r}
 end

 -- Lines
 n = 0
 for y = 0, ypoints-2, 1 do
 for x = nopoles, xpoints-2, 1 do
   p = y * xpoints + x
   n = n + 1; lin[n] = {p+1,p+2} -- odd pixels?
   n = n + 1; lin[n] = {p+1,p+1+xpoints} -- Latitudes
 end
    n = n + 1; lin[n] = {p+2,p+2+xpoints} -- Last Latitude
 end
 
  p1 = xpoints-1
  p2 = (ypoints-1) * xpoints + xpoints-1
  n = n + 1; lin[n] = {p1+1,p2+1} -- Last Latitude between first & last

 for x = nopoles, xpoints-2, 1 do
  p = (ypoints-1) * xpoints + x -- Last longitude (Things are done in order of Longitudes)
  n = n + 1; lin[n] = {p+1, p+2}
  n = n + 1; lin[n] = {p+1, x+1} -- Latitudes between first & last longitude
 end
 
 return pts,lin
end
--

boxp = {} -- To hold the calculated points
pts,lin = initPointsAndLines(XPOINTS,YPOINTS)


function initAndReset()
 ZOOM, XANG, YANG, ZANG, XD, YD, WORLD_X, WORLD_Y = 0,0,0,0,0,0,0,0
end

initAndReset()





 -- Use the Global constants?
 function rotate3D_ALL(points, cx,cy, size, world_x, world_y, dist, zoom, xang,yang,zang)

   local x1,x2,x3,y1,y2,y3,z1,z2,z3,xp,yp
   local n,v,x,y,z,f,distzoom,distsize
   local Xsin,Xcos,Ysin,Ycos,Zsin,Zcos
   local boxp 
   
   distzoom = dist + zoom
   distsize = dist * size

   boxp = {}

   Xsin = sin(xang); Xcos = cos(xang)
   Ysin = sin(yang); Ycos = cos(yang)
   Zsin = sin(zang); Zcos = cos(zang) 

   for n = 1, #points, 1 do

     v = points[n]
     x = v[1]
     y = v[2]
     z = v[3]

    -- Correct rotation (March -17)?
    -- X Rotation
    x1 = x    
    y1 = y * Xcos - z * Xsin --
    z1 = y * Xsin + z * Xcos --
    -- Y Rotation
    x2 = x1 * Ycos - z1 * Ysin
    y2 = y1
    z2 = x1 * Ysin + z1 * Ycos
    -- Z Rotation
    x3 = x2 * Zcos - y2 * Zsin
    y3 = x2 * Zsin + y2 * Zcos
    z3 = z2

     -- Apply "World"
     f = distsize / (z3 + distzoom)
     xp = cx + (x3 + world_x) * f
     yp = cy + (y3 + world_y) * f

     boxp[n] = {xp,yp,z3}
  
   end

    return boxp
  end
--

 

function killinertia()
 XD = 0
 YD = 0
end

while 1 < 2 do

 clearpicture(BKG_COL)

 -- Rotate points + World
 boxp = rotate3D_ALL(pts, CX,CY, SIZE, WORLD_X, WORLD_Y, DIST, ZOOM, XANG,YANG,ZANG)

-------------------------------------
-------------------------------------

 -- Draw Lines
if draw_lines then
 for n = 1, #lin, 1 do
  
  l = lin[n]
  p1 = boxp[l[1]]; z1 = p1[3]

   if z1 < -0.35 then

    p2 = boxp[l[2]]; z2 = p2[3] 

    if z2 < -0.35 then

     x1,y1 = p1[1],p1[2]
     x2,y2 = p2[1],p2[2]

    --z = min(z1,z2) -- Closest/Brightest point
    z = (z1+z2)*0.5
    col = 15 + z*z * 112
    
    if PrepareExit then
      db.lineTranspAAgamma(x1,y1,x2,y2, col,col,col, 1.0, 2.4)
       else
        drawline(x1,y1,x2,y2,min(255,col))
    end 
  
    --putpicturepixel(x2,y2,31+col*224)
   end
  end
 
 end -- eof box
end

 -- Draw Points
if draw_points == true and ZOOM <= 2 then
 for n = 1, #boxp, 1 do
  p = boxp[n]
  z1 = p[3]
   if z1<-0.35 then
    x1,y1 = p[1],p[2]
    col = z1*z1
    putpicturepixel(p[1],p[2],47+col*208)
   end
 end 
end
-- eof points


 

 --repeat

    old_key = key;
    old_mouse_x = mouse_x;
    old_mouse_y = mouse_y;
    old_mouse_b = mouse_b;
    
    updatescreen()
    moved, key, mouse_x, mouse_y, mouse_b = waitinput(0)
    
    if mouse_b == 1 then ANIM = 0; end

    if PrepareExit == true then 
      return;
    end

    if (key==27) then
       PrepareExit = true -- Hold of one cycle to draw last frame with AA
       --return;
    end

    if (key==282) then  ANIM = (ANIM+1) % 2;  killinertia();  end -- F1: Stop/Start Animation
    if (key==283) then  initAndReset();       end -- F2: Reset all values

    if (key==269) then  ZOOM = ZOOM + 0.1;  end
    if (key==270) then  ZOOM = ZOOM - 0.1;  end


    if (key==273) then 
     XANG = (XANG + 0.01) % pi2;
    end

    if (key==274) then 
     XANG = (XANG - 0.01) % pi2;
    end

    if (key==275) then 
     YANG = (YANG + 0.01) % pi2;
    end

    if (key==276) then 
     YANG = (YANG - 0.01) % pi2;
    end


 if ANIM == 0 then
  FIRST = 0 -- Turn off intial zoom anim
  if (mouse_b==1 and (old_mouse_x~=mouse_x or old_mouse_y~=mouse_y)) then -- Inertia
   XD = (mouse_y - old_mouse_y)*0.005
   YD = (mouse_x - old_mouse_x)*0.005
    else
     XD = XD*0.92
     YD = YD*0.92
  end
  XANG = (XANG + XD) % pi2;
  YANG = (YANG + YD) % pi2;
  ZANG = 0
 end 

 if ANIM == 1 then
    if FIRST == 1 and ZOOM > -2 then -- Inital zoom anim
     ZOOM = ZOOM - 0.025
    end
    XANG = (XANG + XSPEED) % pi2
    YANG = (YANG + YSPEED) % pi2
    ZANG = (ZANG + ZSPEED) % pi2
 end

 --XANG = ((CY-mouse_y) / 200  % (math.pi*2));
  --YANG = ((mouse_x - CX) / 200  % (math.pi*2));
  --ZANG = 


  --statusmessage("X: "..floor(XANG*57.3).."°, Y: "..floor(YANG*57.3).."°, Z: "..floor(ZANG*57.3).."°, Zoom: "..floor(-ZOOM*10).."   ")
end

end
-- eof main


main()

