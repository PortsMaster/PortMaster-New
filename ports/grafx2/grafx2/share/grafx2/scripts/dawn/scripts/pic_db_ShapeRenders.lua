--PICTURE: ShapeRenders V1.5 (some speed-up)
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")


 function progress(y,ys)
   statusmessage("Done: "..math.floor((y+1)*100/ys).."%")
 end

function getColorError(r1,g1,b1,r2,g2,b2,briweight)
  local diff,bri1,bri2,diffB,diffC
  bri1 = db.getBrightness(r1,g1,b1)
  bri2 = db.getBrightness(r2,g2,b2)
  diffB = math.abs(bri2 - bri1)
  diffC = db.getColorDistance_weightNorm(r1,g1,b1,r2,g2,b2,0.26,0.55,0.19)
  diff = briweight * (diffB - diffC) + diffC
  return diff*diff
end


-- Note: Triangles could be speed up maybe +25% if replacing the rgb-arrays

-- doSquares are for Triangles
--
function doSquare1(x,y,rgb1,rgb2,siz) --  */*
    local xx,yy,r,g,b,yyy
    --var col1 = pal[colfunc(rgb1,pal)] // for filter just use rgb1 (and ignore ED)
    --var col2 = pal[colfunc(rgb2,pal)]
   
   --col1 = db.getBestPalMatchHYBRID({db.rgbcap(rgb1[1],rgb1[2],rgb1[3],255,0)},pal,briweight,true)
   col1 = matchcolor2(rgb1[1],rgb1[2],rgb1[3],briweight)
   --col2 = db.getBestPalMatchHYBRID({db.rgbcap(rgb2[1],rgb2[2],rgb2[3],255,0)},pal,briweight,true)
   col2 = matchcolor2(rgb2[1],rgb2[2],rgb2[3],briweight)
   for yy = 0, siz-1, 1 do
    yyy = y+yy
    for xx = 0, siz-1, 1 do
      if (xx < siz - yy) then
       putpicturepixel(x+xx,yyy,col1)
        else 
         putpicturepixel(x+xx,yyy,col2)
      end
    end;end
    r,g,b = getcolor(col2)
    return  rgb2[1]-r,rgb2[2]-g,rgb2[3]-b
end
--

--
function doSquare2(x,y,rgb1,rgb2,siz) --  *\*
    local xx,yy,r,g,b,yyy
    --var col1 = pal[colfunc(rgb1,pal)] // for filter just use rgb1 (and ignore ED)
    --var col2 = pal[colfunc(rgb2,pal)]
   
    --col1 = db.getBestPalMatchHYBRID({db.rgbcap(rgb1[1],rgb1[2],rgb1[3],255,0)},pal,briweight,true)
    col1 = matchcolor2(rgb1[1],rgb1[2],rgb1[3],briweight)
    --col2 = db.getBestPalMatchHYBRID({db.rgbcap(rgb2[1],rgb2[2],rgb2[3],255,0)},pal,briweight,true)
    col2 = matchcolor2(rgb2[1],rgb2[2],rgb2[3],briweight)


    for yy = 0, siz-1, 1 do
     yyy = y+yy
     for xx = 0, siz-1, 1 do
       if (xx <= yy) then
        putpicturepixel(x+xx,yyy,col1)
         else 
          putpicturepixel(x+xx,yyy,col2)
       end
     end;end
    r,g,b = getcolor(col2)
    return  rgb2[1]-r,rgb2[2]-g,rgb2[3]-b
end
--

function dith_Triangle(pal,siz,xs,ys,briweight,edmode,edpow)
  local x,y,r,g,b,xx,yy,rgb,org,tri1a,tri1b,tri2a,tri2b,er,eg,eb,ep,yyy
  local tx1,tx2,area_A,area_B
  local Mp = math.pow

  tx1 = siz
  tx2 = siz - 1

  area_A = (tx1 * tx1 + tx1) / 2
  area_B = (tx2 * tx2 + tx2) / 2

  
 for y = 0, ys-siz, siz do
  er,eg,eb = 0,0,0
  for x = 0,xs-siz, siz do

    tri1a = {0,0,0} 
    tri1b = {0,0,0} 
    tri2a = {0,0,0} 
    tri2b = {0,0,0} 

 for yy = 0, siz-1, 1 do
  yyy = y+yy
  for xx = 0, siz-1, 1 do
  
      r,g,b = getbackupcolor(getbackuppixel(x+xx,yyy))

      if edmode == 1 then -- Simple Errordiffusion
       --ep = 1 - briweight
       ep = edpow / 100
       r = r + er*ep
       g = g + eg*ep
       b = b + eb*ep
      end

      if (xx < siz - yy) then -- Left triangle of square 1  /
       tri1a[1] = tri1a[1] + r
       tri1a[2] = tri1a[2] + g
       tri1a[3] = tri1a[3] + b
        else        
         tri1b[1] = tri1b[1] + r
         tri1b[2] = tri1b[2] + g
         tri1b[3] = tri1b[3] + b
      end

      if (xx <= yy) then -- Left triangle of square 2  \
       tri2a[1] = tri2a[1] + r
       tri2a[2] = tri2a[2] + g
       tri2a[3] = tri2a[3] + b
        else       
         tri2b[1] = tri2b[1] + r
         tri2b[2] = tri2b[2] + g
         tri2b[3] = tri2b[3] + b
      end 

    end;end;

    tri1a_rgb = {tri1a[1]/area_A,tri1a[2]/area_A,tri1a[3]/area_A}
    tri1b_rgb = {tri1b[1]/area_B,tri1b[2]/area_B,tri1b[3]/area_B} 

    tri2a_rgb = {tri2a[1]/area_A,tri2a[2]/area_A,tri2a[3]/area_A} 
    tri2b_rgb = {tri2b[1]/area_B,tri2b[2]/area_B,tri2b[3]/area_B} 

    -- Let's see what shape has least error 

    err1 = 0
    err2 = 0

    for yy = 0, siz-1, 1 do
     yyy = y+yy
    for xx = 0, siz-1, 1 do

      r,g,b = getbackupcolor(getbackuppixel(x+xx,yyy))

      if (xx < siz - yy) then -- Square 1
       err1 = err1 + getColorError(r,g,b, tri1a_rgb[1], tri1a_rgb[2],tri1a_rgb[3], briweight)
        else err1 = err1 + getColorError(r,g,b, tri1b_rgb[1], tri1b_rgb[2],tri1b_rgb[3], briweight)
      end

      if (xx <= yy) then -- Square 2
       err2 = err2 + getColorError(r,g,b, tri2a_rgb[1], tri2a_rgb[2],tri2a_rgb[3], briweight)
        else err2 = err2 + getColorError(r,g,b, tri2b_rgb[1], tri2b_rgb[2],tri2b_rgb[3], briweight)
      end
 

    end; end;

    if (err1 < err2) then 
      er,eg,eb = doSquare1(x,y,tri1a_rgb,tri1b_rgb,siz) 
        else er,eg,eb = doSquare2(x,y,tri2a_rgb,tri2b_rgb,siz) 
    end

  end;
  progress(y,ys)
  updatescreen(); if (waitbreak(0)==1) then return; end
 end; -- x/y

  
  
  


  --function diff(c1,c2){
  -- return Mp(c1[0]-c2[0],2)+Mp(c1[1]-c2[1],2)+Mp(c1[2]-c2[2],2)
  --}

end -- eof Triangle



function dith_Disc(pal,siz,xs,ys,briweight,edmode,edpow)
 local mx,rt,gt,bt,r,g,b,ra,ga,ba,dc,er,eg,eb,ep,gam,rgam,valt
 local x,y,c,xx,yy,val,rowspace,square,area,mxy,yyy
 local max,min
 local makeMatrix
 
 gam = 1.5 -- Gamma corrected transparency/AA, 
           -- Full gamma closes the gaps to much..less is rougher but more distinct cells 1.5 seem like a good compromise
 rgam = 1 / gam

 rowspace = math.floor(siz * 7/8) -- Exact is 3^0.5 / 2 but we prefer a little more space for now

 min,max = math.min, math.max

   --
   function makeMatrix(siz) -- Circle
    local x,y,ct,val,area,dist,diff,matrix,val,c,mxy
    matrix = {}
    ct = siz / 2
    area = 0   
    for y = 0, siz-1, 1 do
     matrix[y+1] = {}
     mxy = matrix[y+1]
     for x = 0, siz-1, 1 do
      val = 0
      dist = ((x-ct)*(x-ct) + (y-ct)*(y-ct))^0.5
      diff = min(1,max(0,ct - dist)) -- Gradient border/AA, maybe exp. drop-off? linear looks ok, though.
      val = diff
      if (dist < (ct-0.5)) then area = area + 1; end
      mxy[x+1] = val
    end; end
   return matrix
  end
  --

  mx = makeMatrix(siz)
  c = matchcolor(0,0,0)
  clearpicture(c)

  row = 0
  for y=-rowspace, ys-1, rowspace do
   xoff = (row % 2) * math.floor(siz / 2)
   er,eg,eb = 0,0,0
   for x=-xoff, xs-1, siz do
  
    rt,gt,bt,area = 0,0,0,0
    for yy=0, siz-1, 1 do
     mxy = mx[yy+1]
     yyy = yy+y
     for xx=0, siz-1,1 do
      val = mxy[xx+1]
      if (val>0 and yyy>=0 and yyy<ys and x+xx>=0 and x+xx<xs) then
       r,g,b = getbackupcolor(getbackuppixel(x+xx,yyy))

       square = 0
       if square == 1 then
        rt = rt + r*r
        gt = gt + g*g
        bt = bt + b*b
         else
          rt = rt + r
          gt = gt + g
          bt = bt + b
       end
       area = area + 1
      end
    end;end

   if area > 0 then

    if square == 1 then
     ra = (rt/area)^0.5 + er
     ga = (gt/area)^0.5 + eg
     ba = (bt/area)^0.5 + eb
      else
       ra = rt/area + er
       ga = gt/area + eg
       ba = bt/area + eb
    end

    -- find circle color
    --dc = db.getBestPalMatchHYBRID({ra,ga,ba},pal,briweight,true)
    dc = matchcolor2(ra,ga,ba,briweight)

    if edmode == 1 then
     r,g,b = getcolor(dc)
     --ep = 1 - briweight -- BriMatch & ED doesn't mix well, so we reduce ED if Brimatch increases
     ep = edpow / 100
     er = (ra - r)*ep
     eg = (ga - g)*ep
     eb = (ba - b)*ep
    end

    for yy=0, siz-1, 1 do
     mxy = mx[yy+1]
     yyy = y+yy
     for xx=0, siz-1,1 do
      val = mxy[xx+1]
      if (yyy>=0 and yyy<ys and x+xx>=0 and x+xx<xs) then

        if (val>0) then
         c = dc

         if (val<1) then
          valt = val^rgam -- Gamma corrected transparency: sqrt(c^2*t) = c*sqrt(t)
          r = ra*valt
          g = ga*valt
          b = ba*valt
          --if briweight == 0 then
           --c = matchcolor(r,g,b) -- We don't need to be exact on AA
           --else
           --c = db.getBestPalMatchHYBRID({r,g,b},pal,briweight,true)
           c = matchcolor2(r,g,b,briweight)
          --end    
         end

         putpicturepixel(x+xx,yyy,c)
        end

      end
    end;end
   end -- area

 end;
  row = row + 1
  progress(y+rowspace,ys)
  updatescreen(); if (waitbreak(0)==1) then return; end
 end;

end -- disc


function dith_Boxes(pal,siz,xs,ys,briweight,edmode,edpow)
  local x,y,r,g,b,xx,yy,rgb,org,tri1a,tri1b,tri2a,tri2b,er,eg,eb,ep,ord
  local yyy,floor,Mp
  
  Mp = math.pow
  floor = math.floor

  ord = edpow/100 * 64 -- Bridither power
 
  xsiz = siz
  ysiz = siz
  alternate = 1  -- Make checkered
  --EDpow = 0.5 -- Error diffusion 0..1  (0 deactivates)
  area = xsiz*ysiz

  areaO = xsiz*2 + ysiz*2 - 4  -- Outline area (Not true if any side=1)
  areaI = area - areaO         -- Inside area
  
  areas = {areaO,areaI}

 for y = 0, ys-ysiz, siz do
  --er,eg,eb = 0,0,0
  for x = 0,xs-xsiz, siz do

  rt,gt,bt = 0,0,0
  for yy = 0, ysiz-1, 1 do
   yyy = y+yy
   for xx = 0, xsiz-1, 1 do
  
      r,g,b = getbackupcolor(getbackuppixel(x+xx,yyy))

      rt = rt + r
      gt = gt + g 
      bt = bt + b

      --if edmode == 1 then -- Simple Errordiffusion
      -- ep = 1 - briweight
      -- r = r + er*ep
      -- g = g + eg*ep
      -- b = b + eb*ep
      --end

   end;end

   avg = {rt/area,gt/area,bt/area}
   --rgb1 = matchcolor(avg[1],avg[2],avg[3])
   --rgb1 = db.getBestPalMatchHYBRID(avg,pal,briweight,true)
   --rgb1 = db.getBestPalMatchHYBRID({rt/area-ord,gt/area-ord,bt/area-ord},pal,briweight,true) -- fake bri-dither
   rgb1 = matchcolor2(rt/area-ord,gt/area-ord,bt/area-ord,briweight) 

   r,g,b = getcolor(rgb1)

    -- Total error for entire area
    re = (avg[1] - r) * area
    ge = (avg[2] - g) * area
    be = (avg[3] - b) * area

    ar = 0
    if (alternate) then
     ar = floor(x/xsiz + y/ysiz) % 2 -- Flip areas if ar == 1
    end

    -- Error adjusted color for second area
    narea = areas[ar+1]
    --rgb2 = matchcolor(r+re/narea,g+ge/narea,b+be/narea)
    --rgb2 = db.getBestPalMatchHYBRID({r+re/narea,g+ge/narea,b+be/narea},pal,briweight,true)
    rgb2 = matchcolor2(r+re/narea,g+ge/narea,b+be/narea,briweight)


   -- ED here

   if (alternate == 1 and ar == 1) then rgb1,rgb2 = rgb2,rgb1; end
 
   -- Inside
   for yy = 1, ysiz-2, 1 do
    yyy = y+yy
    for xx = 1, xsiz-2, 1 do
     putpicturepixel(x+xx,yyy,rgb1)
   end;end

    -- Outline 
    for xx=0, xsiz-1, 1 do
     putpicturepixel(x+xx,y,rgb2)  
     putpicturepixel(x+xx,y+ysiz-1,rgb2)  
    end
    for yy=1, ysiz-1, 1 do
     putpicturepixel(x,y+yy,rgb2)
     putpicturepixel(x+xsiz-1,y+yy,rgb2)    
    end 

 end;
 progress(y,ys)
 updatescreen(); if (waitbreak(0)==1) then return; end
 end --x/y

end -- Boxes



function dith_Maya(pal,siz,xs,ys,briweight,edmode,edpow) -- Keep separate colors for the 2 char areas, ED built-in
  local x,y,r,g,b,xx,yy,rgb,org,tri1a,tri1b,tri2a,tri2b,er,eg,eb,ep,ord,area1,area2
  local mxy
  local Mp,floor

  Mp,floor = math.pow, math.floor

  ord = edpow/100 * 128 -- Bridither power
 
  xsiz = siz
  ysiz = siz
  alternate = 1  -- Make checkered
  --EDpow = 0.5 -- Error diffusion 0..1  (0 deactivates)
  area = xsiz*ysiz

  function makeMatrixRandom(xsiz,ysiz) 
    local x,y,ct,val,dist,diff,matrix,val,c
    matrix = db.newArrayInit2Dim(xsiz,ysiz,0)   
    for y = 0, ysiz-1, 1 do
     for x = 0, xsiz-1, 1 do
      val = math.random(0,1)
      matrix[y+1][x+1] = val
    end; end
   return matrix
  end -- makeMatrix

  function makeMatrix(xsiz,ysiz) -- Spiral
    local x,y,ct,val,dist,diff,matrix,val,c,xdir,ydir,dpos,moving,tries,nx,ny,nx2,ny2,failsafe
    xdir = {1,0,-1,0}
    ydir = {0,1,0,-1}
    matrix = db.newArrayInit2Dim(xsiz,ysiz,0)   
 
    dpos,tries,x,y = 0,0,0,1
    moving = true
    --failsafe = 0
    while moving do
      nx = x + xdir[dpos+1]
      ny = y + ydir[dpos+1] 
      nx2 = x + xdir[dpos+1]*2
      ny2 = y + ydir[dpos+1]*2 
      if nx<xsiz and ny<ysiz and nx>0 and ny>0 and matrix[ny2][nx2] ~= nil and matrix[ny2][nx2] ~= 1 then
       x,y,tries = nx,ny,0
       matrix[y][x] = 1
        else 
         dpos = (dpos + 1) % 4; tries = tries + 1; if tries > 1 then moving = false; end
      end
      --failsafe = failsafe + 1; if failsafe > 10000 then break; end
    end

   return matrix
  end -- makeMatrix

  mx = makeMatrix(xsiz,ysiz)

 for y = 0, ys-ysiz, siz do
  for x = 0, xs-xsiz, siz do

  r1,g1,b1 = 0,0,0
  r2,g2,b2 = 0,0,0
  area1,area2 = 0,0
  for yy = 0, ysiz-1, 1 do
   mxy = mx[yy+1]
   for xx = 0, xsiz-1, 1 do
  
      val = mxy[xx+1]
      r,g,b = getbackupcolor(getbackuppixel(x+xx,y+yy))

      if val == 0 then
       r1 = r1 + r
       g1 = g1 + g 
       b1 = b1 + b
       area1 = area1 + 1
      end

      if val == 1 then
       r2 = r2 + r
       g2 = g2 + g 
       b2 = b2 + b
       area2 = area2 + 1
      end

   end;end

   --db.rgbcap(r,g,b,mx,mi)

   --rgb1 = db.getBestPalMatchHYBRID({r1/area1-ord,g1/area1-ord,b1/area1-ord},pal,briweight,true) -- fake bri-dither
   rgb1 = matchcolor2(r1/area1-ord,g1/area1-ord,b1/area1-ord,briweight)
 
   r,g,b = getcolor(rgb1)

    re = (r1/area1 - r) 
    ge = (g1/area1 - g) 
    be = (b1/area1 - b) 

    ar = 0
    if (alternate) then
     --ar = math.floor(x/xsiz + y/ysiz) % 2 -- Flip areas if ar == 1
     ar = floor(x/xsiz) % 2 -- Flip areas if ar == 1
    end

    -- Error adjusted color for second area
    --rgb2 = db.getBestPalMatchHYBRID({db.rgbcap(r2/area2+re,g2/area2+ge,b2/area2+be,255,0)},pal,briweight,true)
    rgb2 = matchcolor2(r2/area2+re,g2/area2+ge,b2/area2+be,briweight)
 

   -- ED here

   if (alternate == 1 and ar == 1) then rgb1,rgb2 = rgb2,rgb1; end
 
   -- Inside
   for yy = 0, ysiz-1, 1 do
    mxy = mx[yy+1]
    for xx = 0, xsiz-1, 1 do
     val = mxy[xx+1]
     if val == 0 then putpicturepixel(x+xx,y+yy,rgb1); end
     if val == 1 then putpicturepixel(x+xx,y+yy,rgb2); end
   end;end

 end;
 progress(y,ys)
 updatescreen(); if (waitbreak(0)==1) then return; end
 end --x/y

end -- Maya


function dith_Diagonal(pal,siz,xs,ys,briweight,edmode,edpow) -- Diagonal Filter overflow
  local x,y,c,xx,yy,rt,gt,bt,rgb,org,val,xoffset,row,col,matrix,larea,mx,mid,step,diagoffset,yrows,yoff,r,g,b
  local er,eg,eb,ep
  local mxy

  --siz = math.floor(amt*100) -- Odd only
  if siz % 2 == 0 then siz = siz + 1; end
  mid = math.floor(siz/2)
  --var area = (siz * siz + 1)/2 + mid
  step = mid+1

  diagoffset = 1 

  yrows = math.floor(ys / (siz * 0.5)) - 1 + 3

  function makeMatrix(siz,bleft,tright) -- Make Diagonal pattern matrix
    local x,y,val,matrix
    matrix = {}
    for y=0, siz-1, 1 do
     matrix[y+1] = {}
     for x=0, siz-1, 1 do
     val = 1
     if (x<(mid-y) or x>(mid+y+tright)) then val = 0; end
     if (y>mid and (x<(y-mid-bleft) or x>(siz - y + mid - 1))) then val = 0; end
     matrix[y+1][x+1] = val
    end;end
   return matrix
  end

  mx = {}
  mx[1] = makeMatrix(siz,0,0)
  mx[2] = makeMatrix(siz,1,-1)

  row = 0
  yoff = -step + diagoffset
  for y=0, yrows-1, 1 do

   xoffset = ((row) % 2) * step + diagoffset
   col = (row % 2) 

   er,eg,eb = 0,0,0
   for x=xoffset-step, xs-1, siz do

    rt,gt,bt = 0,0,0
    matrix = row % 2

    larea = 0  

    for yy=0, siz-1, 1 do
     mxy = mx[matrix+1][yy+1]
     for xx=0, siz-1, 1 do
      val = mxy[xx+1]
      if (val==1 and yy+yoff>=0 and yy+yoff<ys and x+xx>=0 and x+xx<xs) then
       --org = img[yy+yoff][x+xx]
       r,g,b = getbackupcolor(getbackuppixel(x+xx,yy+yoff))
       rt = rt + r
       gt = gt + g
       bt = bt + b
       larea = larea + 1
      end 
    end;end;

    --rgb = pal[colfunc([rt/larea,gt/larea,bt/larea],pal)]
    if larea > 0 then
     --c = db.getBestPalMatchHYBRID({rt/larea+er,gt/larea+eg,bt/larea+eb},pal,briweight,true) 
      c = matchcolor2(rt/larea+er,gt/larea+eg,bt/larea+eb,briweight) 
      if edmode == 1 then  
       r,g,b = getcolor(c)
       ep = edpow / 100
       er = (rt / larea - r) * ep
       eg = (gt / larea - g) * ep
       eb = (bt / larea - b) * ep
      end
     else c = matchcolor(0,0,0)
    end

    for yy=0, siz-1, 1 do
     mxy = mx[matrix+1][yy+1]
     for xx=0, siz-1, 1 do
      val = mxy[xx+1]
      if (val==1 and yy+yoff>=0 and yy+yoff<ys and x+xx>=0 and x+xx<xs) then
        --img[yy+yoff][x+xx] = rgb
        putpicturepixel(x+xx,yy+yoff,c)
      end
    end;end 

    col = col + 1 
   end
  yoff = yoff + (step - (row+1) % 2)
  row = row + 1
  progress(y,ys) 
  updatescreen(); if (waitbreak(0)==1) then return; end
 end; 

end -- eof diagonal-test




OK,TRIA,DISC,DIAG,BOX,MAYA,SIZE,SPARE,EDPOW,BRIWEIGHT = inputbox("Shape Filters",
                    
                     
                         
                           "1. Triangles*",    1,  0,1,-1,
                           "2. Hexa-Discs*",   0,  0,1,-1,                      
                           "3. Diagonal* (odd)", 0,  0,1,-1,
                           "4. Boxes#",        0,  0,1,-1,
                           "5. Mayan#",        0,  0,1,-1,
                           "SIZE", 8,  3,200,0, 
                           "Use Spare Palette",    0,  0,1,0,
                           "*Err.Diff / #BriDith %",    0,  0,100,0,                          
                           "ColMatch Bri-Weight %", 25,  0,100,0  

                           --"Don't Square Errors",    0,  0,1,0
--                                                  
);

if OK then
 xs,ys = getpicturesize()

 if SPARE == 0 then
  pal = db.fixPalette(db.makePalList(256))
   else
    pal = db.fixPalette(db.makeSparePalList(256))
    for n=0, 255, 1 do setcolor(n,getsparecolor(n)); end
 end

 briweight = BRIWEIGHT / 100
 --SIZE = 12

 if EDPOW > 0 then EDMODE = 1; end

 if TRIA == 1 then
  dith_Triangle(pal,SIZE,xs,ys,briweight,EDMODE,EDPOW) 
 end
 
 if DISC == 1 then
  dith_Disc(pal,SIZE,xs,ys,briweight,EDMODE,EDPOW)
 end

 if BOX == 1 then
  dith_Boxes(pal,SIZE,xs,ys,briweight,EDMODE,EDPOW)
 end

if DIAG == 1 then
  dith_Diagonal(pal,SIZE,xs,ys,briweight,EDMODE,EDPOW)
 end

if MAYA == 1 then
  dith_Maya(pal,SIZE,xs,ys,briweight,EDMODE,EDPOW)
 end

end -- ok
