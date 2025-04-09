---------------------------------------------------
---------------------------------------------------
--
--           Voronoi / Blotter Library
--              
--                    V1.0
-- 
--                Prefix: vor.
--
--        by Richard 'DawnBringer' Fhager
--                                   
--        Email: dawnbringer@hem.utfors.se
--               dawnbringer@bahnhof.se
--
---------------------------------------------------
---------------------------------------------------

-- Abstract:
--  Various functions and systems for Voronoi-based effects

---------------------------------------------------


-- Note: Filler RADIUS for circle can't be bigger than 238 right now, use the formula
-- RADIUS = math.min(238, 25 + math.ceil(1.8 * PIXELS^0.5 / POINTS^0.5)) for a good estimate

-- Data / Settings (examples) --
--
-- PIXELS = w*h
-- POINTS = 250 -- Max points (may be less if randomized into same coords)
-- RES = 4      -- Point distribution resolution (min distance)
-- RADIUS = math.min(238, 25 + math.ceil(1.8 * PIXELS^0.5 / POINTS^0.5)) -- Max radius of circles (238 is currently max safe), this is also number of charting iterations.
-- GRACEPERIOD = 0 -- Diff in iter/time/dist that another circle can lay claim to an already claimed area ("Line thickness")
                -- A value of 0 will only include circles that layed claim at the same time.
                -- Areas with more than one claim ("Contested area") will be post-processed to find the winner.
-- Process display options:
-- RENDOPTION = 1  -- Render Option: 0 = Off, 1 = Point/Area (one color / area), 2 = Iteration (palette index gradient)
-- RENDLINES  = 1  -- Render Lines/Contested areas (color 0), If off area will be drawn by first claimed point
--
--


---
--- The Processes
---
-- 1. Randomize points (x,y)
-- 2. Place points on a distance Map (and remove any duplicates)
-- 3. Apply expanding Filler-shape (ex. Circle) to Map (in order to find closest point to any coord)

-- Render (nice graphic effect)
-- 4. Render the distance Map (That's it, you're done!)
 
-- Blotter (Image filter)
-- 4. Process any Uncharted areas (that the Filler-shapes didn't reach)
-- 5. Process contested/fuzzy areas (to find exactly which point is the closest)
-- 6. Convert Map to Areas (make lists of all pixels that are closest to each point, i.e Voronoi cells)
-- 7. Find the average Image color of each area
-- 8. Blot/Draw the areas
-- (9. optional) Apply AA to contested pixels or Draw the contested pixels as dividing lines 


-- BLOTTER example
--[[
filler = vor.fillShape_Circle(RADIUS)
points, map = vor.pointsMap(POINTS,w,h,RES) -- Initiate Map and Randomize (unique) Points, place them on map
vorObj = {map = map, points = points, filler = filler, height = h, width = w}
vorObj,pcount,contested = vor.claimCharting(vorObj,0,1,1) -- vorObj,GRACEPERIOD,RENDOPTION,RENDLINES
vorObj = vor.doUncharted(vorObj) -- map,filler
vorObj,cont_points = vor.doContested(vorObj) -- map,filler
area = vor.map2Areas(vorObj.map)
areacol = vor.areaColor(area)
vor.blotterCol(area,areacol, 0,0,true)
vor.doContestedAA(cont_points,areacol, 0,0); 
vor.contestedLines(cont_points,matchcolor(0,0,0), 0,0) -- 0,0 is offset
--]]

-- RENDER example
--[[
filler = vor.fillShape_Circle(RADIUS)
points = vor.initPoints(POINTS,w,h,RES) -- Render Points will not be checked for doubles
points,map = vor.addPoints2Map(points,w,h) -- Add points to map and remove duplicates
vorObj = {map = map, points = points, filler = filler, height = h, width = w}
vorObj,pcount,contested = vor.claimCharting(vorObj,GRACEPERIOD,RENDOPTION,RENDLINES)
vor.mapRender(vorObj.map,5)
--]]

-------------------------------------------------------------------


vor = {}


--
function vor.add(ary,val)
  table.insert(ary, #ary+1, val)
end
--


-------------------
-- Filler Shapes --
-------------------
-- Distance models, Quickly mapping distances by applying predefined growing geometric figures.
--


-- Square (Max, not Manhattan)
--
function vor.fillShape_Square(radius)
 local r,x,y,n,shape,cx,cy,point,dist

 shape = {}

 function shape.dist(x,y,px,py) -- max
  return math.max(math.abs(x-px), math.abs(y-py))
 end

 shape.radius = radius -- iterations for claimcharting

 for r = 1, radius, 1 do
  shape[r] = {}
  point = 1
 
  dist = r

  for n = -r, r, 1 do
    shape[r][point] = {n,-r, dist}; point = point + 1
    shape[r][point] = {n, r, dist}; point = point + 1
  end
  for n = -r+1, r-1, 1 do
    shape[r][point] = {-r, n, dist}; point = point + 1
    shape[r][point] = { r, n, dist}; point = point + 1
  end
  
  --updatescreen();if (waitbreak(0)==1) then return end;
 end

 return shape
end
--


--
-- Circle: circle[radius][point] = {x,y} --
--
function vor.fillShape_Circle(radius)
 local x,y,r,d,rad,deg,step,rd,cx,cy,chart,circle,point,dist
 rd = radius
 cx  = 0.5
 cy  = 0.5

 chart = {}
 for y = 1, rd*2+1, 1 do 
   chart[y] = {}
   for x = 1, rd*2+1, 1 do
    chart[y][x] = 0
  end
 end

 circle = {}
 rad = math.pi/180

 function circle.dist(x,y,px,py) -- include function for contested and uncharted processing
  return math.sqrt((x-px)^2 + (y-py)^2)
 end

 circle.radius = radius  -- iterations for claimcharting

 for r = 1, rd, 1 do -- Starting at 1 will exclude the center point (which is now added to charting at point rnd)
  circle[r] = {} -- r+1 if starting at rad = 0
  step = 0.12 -- 0.12 is good until rd=238
  if r < 180 then step = 0.15; end
  if r < 120 then step = 0.25; end
  if r < 54  then step = 0.5; end
  if r < 32  then step = 1.0; end

  point = 1
  for d = 0, 90, step do
  
   deg = rad*d
   x = math.floor(cx + math.sin(deg) * r)
   y = math.floor(cy + math.cos(deg) * r)

   dist = circle.dist(cx,cy,x,y) -- exact distance, we don't want to place the 1.5 offset anti-banding hack here...

   if chart[y+rd+1][x+rd+1]   == 0 then circle[r][point] = { x, y, dist}; chart[y+rd+1][x+rd+1]   = 1; point = point + 1; end
   if chart[-y+rd+1][x+rd+1]  == 0 then circle[r][point] = { x,-y, dist}; chart[-y+rd+1][x+rd+1]  = 1; point = point + 1; end
   if chart[y+rd+1][-x+rd+1]  == 0 then circle[r][point] = {-x, y, dist}; chart[y+rd+1][-x+rd+1]  = 1; point = point + 1; end
   if chart[-y+rd+1][-x+rd+1] == 0 then circle[r][point] = {-x,-y, dist}; chart[-y+rd+1][-x+rd+1] = 1; point = point + 1; end

  --putpicturepixel(x+rd,y+rd,r)
  end
 end

 chart = {}
 return circle
end
-- fillShape_Circle
--


------- eof Fillers ------------



---------------------------------------
------- Points & Distance Map ---------
---------------------------------------

 
--
-- Basic Randomization of points
--
function vor.initPoints(place_points,w,h,res)
 local n,x,y,points
 -- Data Points --
 points = {}
 for n = 0, place_points-1, 1 do
  x = math.random(0,math.floor((w-1)/res))*res
  y = math.random(0,math.floor((h-1)/res))*res -- point may not be outside screen (right now)
  points[n+1] = {x,y,1 + n%255}
 end
 return points
end
--

 
--
-- Get Points from Image (any index > 0)
--
function vor.readPoints(w,h,lim)
 local x,y,c,points,found
 found = 0
 points = {}
 for y = 0, h-1, 1 do
  for x = 0, w-1, 1 do
   c = getpicturepixel(x,y)
   if c > 0 and found <= lim then 
      found = found + 1
      points[found] = {x,y,c}
   end
  end
 end
 if found >= lim then
  messagebox("Too many points found! Any pixel not color 0 is a potential source point. Press 'ESC' to cancel render. Limit is "..lim.." points.")
 end
 return points
end

--
-- Place Points on a Map and remove any duplicates (Returns Map and clean Points)
--
function vor.addPoints2Map(points,w,h)
 local x,y,n,new_points,placed,map
  -- Map of Claims --
 map = {}
 for y = 1, h, 1 do 
   map[y] = {}
   for x = 1, w, 1 do
    map[y][x] = {}
  end
 end
 -- Data Points --
 new_points = {}
 placed = 0
 for n = 1, #points, 1 do
  x,y = points[n][1],points[n][2]
  if map[y+1][x+1][1] == nil then -- No doubles
   placed = placed + 1
   --new_points[placed] = {x,y}
   new_points[placed] = points[n] -- points may include color index {x,y,c}
   map[y+1][x+1] = {{placed,0,0}} -- Point, Iteration, Don't initiate this if circles do center point
  end 
 end
 points = {}
 return new_points,map -- return points stripped of duplicates
end
--


--
-- Randomize Points AND place them on a Map. Only used by Image Crystallize right now.
--
function vor.pointsMap(place_points,w,h,res) -- Desired Points/areas, placement resolution (min point dist) 
 local x,y,n,points,placed,map,halfoffset
  -- Map of Claims --
 map = {}
 for y = 1, h, 1 do 
   map[y] = {}
   for x = 1, w+res, 1 do
    map[y][x] = {}
  end
 end
 -- Data Points --
 points = {}
 placed = 0
 for n = 1, place_points, 1 do
  y = math.random(0,math.floor((h-1)/res))*res -- point may not be outside screen (right now)
  halfoffset = math.floor((math.floor(y/res)%2)*res/2) -- Hexagonal patter if density is high, *2 = diagonals 
  x = halfoffset + math.random(0,math.floor((w-1)/res - 0))*res
  
  if map[y+1][x+1][1] == nil then -- No doubles
   placed = placed + 1
   points[placed] = {x,y,n} -- for correct cell color, plot: use getbackuppixel(x,y)
   map[y+1][x+1] = {{placed,0,0}} -- Point, Iteration, Don't initiate this if circles do center point
  end 
 end
 --map.points = points
 return points,map
end
-- p&m
--


--
-- Claim Charting (flood fill with circles or other shape)
-- datapoints, filler shape (circle f.ex), iterations/radius, image width & height, 
-- graceperiod (line thickness, nom = 0),renderoption, renderlines
--
function vor.claimCharting(obj,graceperiod,RENDOPTION,RENDLINES)
 local i,cir,n,x,y,h,w,px,py,sx,sy,ropt,rend,PIXELS,pdead,dead,pcount,contested,iter,dist,points,map,filler
 -- Object {map = map, points = points, filler = filler, h = h, w = w}
    map = obj.map
 filler = obj.filler
 points = obj.points
      h = obj.height
      w = obj.width

 aa_adjust = 0; if obj.aa then graceperiod = graceperiod + 1; end -- Proper AA requires charting with +1 graceperiod

 PIXELS = w*h
 iter = filler.radius
 pcount = #points  -- this count is wrong if there's duplicate pixels
 contested = 0 

 PIXELS = w*h
 pdead = {} -- is point dead (can't fill anymore)
 RENDOPTION = RENDOPTION + 1 -- Just a small speed optimization to allow settings 0-2 without an additional +1 in the loop
 i = 0
 --messagebox(pcount)
 while i < iter and pcount<PIXELS do -- There's no danger in trying to do more than PIXELS to negotiate duplicate points.
 i = i+1
 cir = filler[i] 
  for n = 1, #points, 1 do
   if pdead[n] ~= 1 then -- if point is active
    px,py = points[n][1] + 1,points[n][2] + 1 -- add +1 here for speed
    dead = 1
    rend = {0,points[n][3],i}; ropt = rend[RENDOPTION] -- Render options:  1. off, 2. n for point/area, 3. i for iteration
     for p = 1, #cir, 1 do 
        x,y,dist = cir[p][1], cir[p][2], cir[p][3] -- distance is not used by areas/blotter  
        sx,sy = px + x, py + y
        if sx > 0 and sx <= w and sy > 0 and sy <= h then
          if map[sy][sx][1] == nil then
            vor.add(map[sy][sx],{n,i,dist}) -- point, iteration, exact distance (not used by blotter, only render)
            pcount = pcount + 1
            dead = 0
            if ropt > 0 then putpicturepixel(sx-1,sy-1,ropt); end -- Note that center point isn't plotted (or part of fillers)
            --putpicturepixel(sx-1,sy-1,math.floor(dist*1.5)/1.5)
             else
               if i - map[sy][sx][1][2] <= graceperiod then -- Contested (another circle claims the same pixel)
                 vor.add(map[sy][sx],{n,i,dist})
                 dead = 0
                 if #map[sy][sx] == 2 then contested = contested + 1; end -- only count first contesting entry
                 if RENDLINES == 1 then putpicturepixel(sx-1,sy-1,0); end -- Draw lines/contested areas
               end
          end -- map
        end -- on screen
       end -- circle
       if dead == 1 then pdead[n] = 1; end -- deactivate point (it can't fill anymore)
     end -- pdead
      
   end -- points

  if i%2==0 then
   statusmessage(pcount.." / "..PIXELS)
   updatescreen();if (waitbreak(0)==1) then return end; 
  end

 end -- radius
 --messagebox("Contested pixels: "..contested.."\n".."Uncharted pixels: "..(PIXELS-pcount))
 
 -- We don't actually have to update object with the new map data as it working by ref. and thus operates on the original.
 -- But we do it anyways and returns the updated object just to make things sure & clear
 obj.map = map

 return obj,pcount,contested
end
-- claimCharting
--


--
-- Uncharted --
--
function vor.doUncharted(obj)
  local x,y,n,l,h,w,px,py,line,dist,best,best2,mindist,mindist2,points,map,filler

    map = obj.map
 filler = obj.filler
 points = obj.points
      h = obj.height
      w = obj.width
  
  for y = 0, h-1, 1 do
   line = map[y+1]
   for x = 0, w-1, 1 do
    l = line[x+1]

     -- Uncharted --
     if #l == 0 then
      mindist = (w+h)^3
      best = -1
      for n = 1, #points, 1 do
        --
        px = points[n][1]
        py = points[n][2]
        dist = filler.dist(x,y,px,py)
        --dist = math.sqrt((x-px)^2 + (y-py)^2)
        if dist <= mindist then 
          mindist2 = mindist
          mindist = dist
          best2 = best
          best = n
           else if dist < mindist2 then best2 = n; mindist2 = dist; end -- best2 = p !???
        end 
        --
      end -- n
       --vor.add(map[y+1][x+1],{best,-1,-1}) -- point (area), iteration, exact distance
       map[y+1][x+1][1] = {best,-1, mindist} -- No adding, uncharted/contested only need 1 entry. Maprender uses mindist 
      putpicturepixel(x, y, best)
     end
     -- uncharted
   end -- x
   updatescreen();if (waitbreak(0)==1) then return end
  end -- y

  obj.map = map
  return obj
end
-- uncharted
--


-- Process CONTESTED pixels
-- Note that contested areas have map entries and IF NOT ANALYZED the first one will be processed as normal by other functions
--
function vor.doContested(obj,graceperiod)

    local x,y,l,n,w,h,p,px,py,line,cont_points,cont_count,mindist,best,mindist2,best2,dist,points,map,filler
 
    map = obj.map
 filler = obj.filler
 points = obj.points
      h = obj.height
      w = obj.width

    cont_points = {} -- for separate data, aa etc.
    cont_count = 0
  
    for y = 0, h-1, 1 do
     line = map[y+1]
     for x = 0, w-1, 1 do
      l = line[x+1]

       -- Contested
       if #l > 1 then
        mindist = (w+h)^3
        mindist2 = mindist
        best = -1 
        for n = 1, #l, 1 do
          p = l[n][1]
          --
          px = points[p][1]
          py = points[p][2]
          dist = filler.dist(x,y,px,py)
          --dist = math.max(math.abs(x-px), math.abs(y-py)) -- Square 
          --dist = math.sqrt((x-px)^2 + (y-py)^2)
          --if n==2 then mindist2,best2 = dist,p; end -- If first is best then 2nd best must be recorded here
          if dist <= mindist then 
            mindist2 = mindist
            mindist = dist
            best2 = best
            best = p
             else if dist < mindist2 then best2 = p; mindist2 = dist; end
          end
          --
        end -- n
        map[y+1][x+1][1] = {best,-1,-1}  -- contested is not using map data

        --putpicturepixel(x, y, best)
        --if #l>2 then putpicturepixel(x, y, matchcolor(255,0,0)); end -- "Corners"

      ----[[
      -- AA, data for contestedAA, Can only handle 2 areas, so things look ugly with 
      -- +2 contending areas and thick lines - but do we ever want/need GRACEPERIOD>0?
      -- However there's also some odd areas visible with GRACEPERIOD=0, is this the same +2 area problem?
      --
      -- For correct AA charting needs to be done with a +1 graceperiod than what is done here
      -- (Not that I'm sure this formula is 100% correct, but it looks pretty good)
      f1 = math.min(1, 0.5 + (mindist2 - mindist) / (graceperiod + 1) / 2)
      

      cont_count = cont_count+1
      cont_points[cont_count] = {x,y,best,best2,f1,1-f1}
      --  
      --]] 

     end
  
     end -- x
     --if y%4==0 then updatescreen();if (waitbreak(0)==1) then return end; end
    end -- y
    
    obj.map = map
    return obj,cont_points
end
-- contested
--


--
-- Create Area data (all pixels nearest a given point) from Map data (what point a given pixel belongs to)
--
function vor.map2Areas(map) -- Assumes areas/point numbered from 1 and up, Areas corresponds to Points
 local n,w,h,x,y,area,point,mp
 area = {} 
 h,w = #map,#map[1]
 for y = 0, h-1, 1 do 
  mp = map[y+1]
  for x = 0, w-1, 1 do
    if mp ~= nil and mp[x+1] ~= nil and mp[x+1][1] ~= nil then -- just to make sure data is valid
     point = mp[x+1][1][1]
     if area[point] == nil then area[point] = {}; end
     table.insert(area[point], #area[point]+1, {x,y})
    end
  end
 end
 return area
end
--


-------------
-- BLOTTER --
-------------
-- Voronoi map Image filter; same as Photoshop Crystallize filter

--
function vor.areaColor(area) -- Calculate average (gamma corr.) image color of each area
 local n,a,p,r,g,b,rt,gt,bt,len,gam,rgam,areacol
 areacol = {}
 gam  = 2.0
 rgam = 1 / gam
 for n = 1, #area, 1 do -- created areas may not be desired amount (AREA)?
   a = area[n] 
   rt,gt,bt = 0,0,0
   len = #a
   for p = 1, len, 1 do
    r,g,b = getcolor(getbackuppixel(a[p][1],a[p][2]))
    rt,gt,bt = rt+r^gam,gt+g^gam,bt+b^gam
   end
   ra,ga,ba = (rt/len)^rgam,(gt/len)^rgam,(bt/len)^rgam
   areacol[n] = {ra,ga,ba} 
 end -- n
 return areacol
end
--

--
function vor.areaColorIndex(area,points)
 local n,a,p,r,g,b,areacol
 areacol = {}
 for n = 1, #area, 1 do  
   r,g,b = getcolor(points[n][3])
   areacol[n] = {r,g,b} 
 end -- n
 return areacol
end
--
--
-- Blot with precalculated color for each area (areaColor())
--
function vor.blotterCol(area,areacol,update_flag)
 local n,a,p,c,rgb,rot
 rot = math.floor((#area)^0.5)
 for n = 1, #area, 1 do -- created areas may not be desired amount (AREA)?
   a = area[n] 
   rgb = areacol[n]
   c = matchcolor2(rgb[1],rgb[2],rgb[3])
   for p = 1, #a, 1 do
    putpicturepixel(a[p][1],a[p][2],c)
   end
   if update_flag then
    if n%rot == 0 then updatescreen();if (waitbreak(0)==1) then return end; end
   end
 end -- n
 updatescreen()
end 
-- 

-- Blot Areas with Palette Index: points{x,y,c} (blotterCol will work too but might be a little slower)
--
function vor.blotterArea(area,points,ofx,ofy,update_flag)
 local n,a,p,c,rot
 rot = math.floor((#area)^0.5)
 for n = 1, #area, 1 do -- created areas may not be desired amount (AREA)?
   a = area[n] 
   c = points[n][3] -- point{n} is map{{n,0,0}} is area{n}
   for p = 1, #a, 1 do
    putpicturepixel(a[p][1]+ofx,a[p][2]+ofy,c)
   end
   if update_flag then
    if n%rot == 0 then updatescreen();if (waitbreak(0)==1) then return end; end
   end
 end -- n
 updatescreen()
end 
--

--
-- Apply AA in contested / Fuzzy areas (not complete as it only considers the 2 closest points)
--
function vor.doContestedAA(cont_points,areacol,ofx,ofy)
 local n,x,y,con,p1,p2,f1,f2,rgb1,rgb2,r,g,b,c
 for n = 1, #cont_points, 1 do
  con = cont_points[n]
  x,y,p1,p2,f1,f2 = con[1],con[2],con[3],con[4],con[5],con[6]
  rgb1 = areacol[p1]
  rgb2 = areacol[p2]
  --r = rgb1[1]*f1 + rgb2[1]*f2
  --g = rgb1[2]*f1 + rgb2[2]*f2
  --b = rgb1[3]*f1 + rgb2[3]*f2 
  r = (rgb1[1]^2*f1 + rgb2[1]^2*f2)^0.5
  g = (rgb1[2]^2*f1 + rgb2[2]^2*f2)^0.5
  b = (rgb1[3]^2*f1 + rgb2[3]^2*f2)^0.5 
  c = matchcolor2(r,g,b) -- Can't use matchcolor2 here unless areacols also use it, it makes thing a bit slow but good
  putpicturepixel(x+ofx, y+ofy, c)
  if n%5000 == 0 then
     statusmessage("Applying AA...%"..math.floor(n/#cont_points * 100)); 
     updatescreen();if (waitbreak(0)==1) then return end; 
  end
 end
end
--

--
-- Apply AA on Fuzzy Lines (not complete as it only considers the 2 closest points)
--
function vor.doLineAA(cont_points,areacol,ofx,ofy)
 local n,x,y,con,p1,p2,f1,f2,f3,rgb1,rgb2,r,g,b,c,exp
 exp = 0.75 -- Lower exp = softer lines
 for n = 1, #cont_points, 1 do
  con = cont_points[n]
  x,y,p1,p2,f1,f2 = con[1],con[2],con[3],con[4],con[5],con[6]
  rgb1 = areacol[p1]
  rgb2 = areacol[p2]

  if f1 >= 0.5 then
   f3 = ((f1-0.5)*2)^exp
   r = rgb1[1]*f3 -- Other factor is black so do nothing (0 * (1-f3) = 0)
   g = rgb1[2]*f3
   b = rgb1[3]*f3
    else
   f3 = ((f2-0.5)*2)^exp
   r = rgb2[1]*f3 
   g = rgb2[2]*f3
   b = rgb2[3]*f3
  end  
   
  putpicturepixel(x+ofx, y+ofy, matchcolor2(r,g,b)) -- matchcolor2 is def better but a bit slow for crystallize
  if n%1000 == 0 then updatescreen();if (waitbreak(0)==1) then return end; end
 end
end
--


--
function vor.contestedLines(cont_points,col,ofx,ofy)
 local n
 for n = 1, #cont_points, 1 do
  putpicturepixel(ofx+cont_points[n][1], ofy+cont_points[n][2], col)
 end
end
--


--
-- Plot source points
--
function vor.markPoints(points,lim,ofx,ofy) -- lim = max points with big cross, single points at higher counts
   local k,l,n,r,g,b,c,x,y
   k,l = 1,3; if #points > lim then k,l = 0,0; end
   for n = 1, #points, 1 do
    p = points[n]
    x = p[1] + ofx
    y = p[2] + ofy
    r,g,b = getcolor(p[3])
    r = (r + 128) % 255
    g = (g + 128) % 255
    b = (b + 128) % 255
    c = matchcolor(r,g,b)
    putpicturepixel(x,y,c)
     for o = k, l, 2 do
      putpicturepixel(x-o,y,c)
      putpicturepixel(x+o,y,c)
      putpicturepixel(x,y-o,c)
      putpicturepixel(x,y+o,c)
     end
   end
end
--

---------
---------


-------------
-- RENDERS --
-------------
-- Render image directly from distance map
--

--
-- Render distance map, assumes a 256 color (gradient) palette
--
function vor.mapRender(map,mult,abo) -- map[y][x][1]=[point(area), iteration, exact distance], power/index multiplier
 local h,w,x,y,c,line,dist
 h = #map -- same as map.points.height
 w = #map[1]
 for y = 0, h-1, 1 do
   line = map[y+1]
   for x = 0, w-1, 1 do
     if line[x+1][1] ~= nil then
      dist = line[x+1][1][3]
      c = math.min(255, math.floor(mult * dist * abo) / abo) -- Anti-banding offset trick (abo = 1.5 for 256 col grad)
      putpicturepixel(x, y, c)
       else putpicturepixel(x, y, 255)
     end
   end
   updatescreen();if (waitbreak(0)==1) then return end
 end
end
--

-------------------------------------------------------------------

-----------------------
-- CONTROL FUNCTIONS --
-----------------------

function vor.setupFILLER(FILLER,PIXELS,POINTS) 
 local radius,filler,fill_str
 radius = math.min(238, 25 + math.ceil(1.8 * PIXELS^0.5 / POINTS^0.5))
 fill_str = "circle" -- Default
 if FILLER == "square" then fill_str = "square"; end
 if fill_str == "circle" then filler = vor.fillShape_Circle(radius); end -- Circle (Euclidian distances)
 if fill_str == "square" then filler = vor.fillShape_Square(radius); end -- Square (Max distances)
 return filler
end

--
function vor.imageCRYSTALLIZE(POINTS,RES,GRACEPERIOD,RENDOPTION,RENDLINES,AA_FLAG,LINE_FLAG,FILLER)

 local w,h,points,map,filler,vorObj,pixels,cont_points,area,areacol,contested,pcount

 w,h = getpicturesize()
 pixels = w*h

 points, map = vor.pointsMap(POINTS,w,h,RES) -- Initiate Map and Randomize (unique) Points, place them on map

 filler = vor.setupFILLER(FILLER,pixels,#points) 

 vorObj = {map = map, points = points, filler = filler, height = h, width = w, aa = AA_FLAG}
 -- Note the +1 on GRACEPERIOD here for better IP
 vorObj,pcount,contested = vor.claimCharting(vorObj,GRACEPERIOD,RENDOPTION,RENDLINES) -- vorObj,GRACEPERIOD,RENDOPTION,RENDLINES

                               if (pixels-pcount) > 0 then
                                statusmessage("Uncharted Areas..."); waitbreak(0)
              vorObj = vor.doUncharted(vorObj,GRACEPERIOD) -- map,filler
                               end
                               if contested > 0 then
                                statusmessage("Contested Areas..."); waitbreak(0)
  vorObj,cont_points = vor.doContested(vorObj,GRACEPERIOD) -- map,filler
                               end
                                statusmessage("Converting Areas..."); waitbreak(0)
                area = vor.map2Areas(vorObj.map)
                                statusmessage("Processing Colors..."); waitbreak(0)
             areacol = vor.areaColor(area)
                                statusmessage("Blotting..."); waitbreak(0)
             vor.blotterCol(area,areacol,0,0,true)



  if contested > 0 then -- If no contested pixels then no coint_points list exists, CAN CONTESTED BE ZERO???

   if AA_FLAG then
    if LINE_FLAG then
     statusmessage("Drawing AA Lines..."); waitbreak(0); 
     vor.doLineAA(cont_points,areacol, 0,0)
      else
     statusmessage("Applying AA..."); waitbreak(0); 
     vor.doContestedAA(cont_points,areacol, 0,0);
    end
   end 

   if LINE_FLAG and AA_FLAG == false then
    vor.contestedLines(cont_points,matchcolor(0,0,0), 0,0)
   end

  end

end
--

--
function vor.mapRENDER_1(POINTS,RES,GRACEPERIOD,RENDOPTION,RENDLINES,FILLER,MULT,READ_FLAG)
 
 local w,h,pixels,points,map,filler,vorObj,pcount,contested,mult,abo
 
 w,h = getpicturesize()
 pixels = w*h
 
     
      if READ_FLAG then
       points = vor.readPoints(w,h,25000) -- Get points from all pixels (index > 0) in image
        else
       points = vor.initPoints(POINTS,w,h,RES) -- Render Points will not be checked for doubles
      end
      
   points,map = vor.addPoints2Map(points,w,h) -- Add points to map and remove duplicates (removed = POINTS-#points)

       filler = vor.setupFILLER(FILLER,pixels,#points)
 
         mult = (#points)^0.5 / pixels^0.5 * 150 * MULT

                   vorObj = {map = map, points = points, filler = filler, height = h, width = w, aa = false}
  vorObj,pcount,contested = vor.claimCharting(vorObj,GRACEPERIOD,RENDOPTION,RENDLINES)

                               if (pixels-pcount) > 0 then
                                statusmessage("Uncharted Areas..."); waitbreak(0)
              vorObj = vor.doUncharted(vorObj) -- map,filler
                               end
  
  abo = 1.5; if MULT < 1.0 then abo = 1.0; end -- Anti-banding offset hack

  statusmessage("Rendering..."); waitbreak(0)
  vor.mapRender(vorObj.map,mult,abo)

end
--

-- Screen size diagram
function vor.makeDiagram(POINTS,RES,GRACEPERIOD,RENDOPTION,RENDLINES,FILLER,READ_FLAG,AA_FLAG,LINE_FLAG,POINT_FLAG)
 
 local w,h,pixels,points,map,filler,vorObj,pcount,contested,areacol,area,cont_points,ofx,ofy

 ofx,ofy = 0,0
 
 w,h = getpicturesize(); 
 pixels = w*h
      
      if READ_FLAG then
       points = vor.readPoints(w,h,25000) -- Get points from all pixels (index > 0) in image, 25000 is limit
        else
       points = vor.initPoints(POINTS,w,h,RES) -- Render Points will not be checked for doubles
      end
      
   points,map = vor.addPoints2Map(points,w,h) -- Add points to map and remove duplicates (removed = POINTS-#points)

       filler = vor.setupFILLER(FILLER,pixels,1) -- use min points for max radii, since user points may be clustered 
         
                   vorObj = {map = map, points = points, filler = filler, height = h, width = w, aa = AA_FLAG}
  vorObj,pcount,contested = vor.claimCharting(vorObj,GRACEPERIOD,RENDOPTION,RENDLINES) 

                               if (pixels-pcount) > 0 then
                                statusmessage("Uncharted Areas..."); waitbreak(0)
              vorObj = vor.doUncharted(vorObj) -- map,filler
                               end

                               if contested > 0 then
                                statusmessage("Contested Areas..."); waitbreak(0)
  vorObj,cont_points = vor.doContested(vorObj,GRACEPERIOD)
                               end

                statusmessage("Converting Areas..."); waitbreak(0)
               area = vor.map2Areas(vorObj.map)             

                statusmessage("Blotting..."); waitbreak(0)
               vor.blotterArea(area,points, ofx,ofy, true) -- area,points,update_flag
 
   if AA_FLAG then 
    areacol = vor.areaColorIndex(area,points) --vor.areaColor(area)
    if LINE_FLAG then
     statusmessage("Drawing AA Lines..."); waitbreak(0); 
     vor.doLineAA(cont_points,areacol, ofx,ofy)
      else
     statusmessage("Applying AA..."); waitbreak(0); 
     vor.doContestedAA(cont_points,areacol, ofx,ofy);
    end
   end 

   if LINE_FLAG and AA_FLAG == false then
    vor.contestedLines(cont_points,matchcolor(0,0,0), ofx,ofy)
   end

   if POINT_FLAG then vor.markPoints(points,100, ofx,ofy); end

end
--






