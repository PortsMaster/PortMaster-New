--PICTURE: Disc Filter V1.0
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")


--
--
-- Randomly place circles, every pixel will be tested to see if a circle may fit there.
--
-- mode: 1 or 2
--
-- 1. test_mode: Pixelbased Bresenham-circles fitting, no AA. Not quite as snugg & dense as dist_mode but very fast and exact.
-- 
-- 2. dist_mode: AA. Spacing ignores border. Mathematical circles & distances, always rendered as odd sizes thus becoming 1 pixel bigger.
--               which requires both the drawing radius and spacing to be increased by +1. 
--               (Diameter becomes +2 why +1 spacing is required to avoid overlapping)
--
-- Note: Things are currently hardcoded for drawing on black background, 
-- so negative spacing/overlapping will not render properly in dist_mode (AA)
--

function circlePattern(minrad,maxrad,spacing, mode)

 local w,h,x,y,n,count,max,min,floor,sqrt, maxr, dist_mode, test_mode
 local mindist,len,number,num,xd1,yd1,xd2,yd2,cd,dist,c,r,cx,cy,cr, cir
 local circles,numeric,used, zone
 local fillDiscArray, testDiscArray

 mode = mode or 1

 if spacing < 0 then -- Overlap can't be more than half the radius of minrad or it will run forever? Not sure why...one disc for each pixel possible?
  spacing = -math.min(math.floor(minrad/2), math.abs(spacing))
 end
  
 if mode == 1 then
  test_mode = true
  maxrad = maxrad + spacing
 end
 
 if mode == 2 then
  dist_mode = true
  spacing = spacing + 1
 end


 -- Bresenham fillDisc
 function fillDiscArray(xm, ym, r, w, ary)
   local x,y,n,err
   x = -r
   y = 0
   err = 2-2*r 
    while (x < 0) do
       for n=x, 1, 1 do
        ary[xm-n + (ym+y)*w] = 1
        ary[xm+n + (ym-y)*w] = 1
        ary[xm-y + (ym-n)*w] = 1
        ary[xm+y + (ym+n)*w] = 1
       end
       r = err;
       if (r <= y) then y = y+1; err = err + y*2+1; end          
       if (r > x or err > y) then x=x+1; err = err + x*2+1; end
    end
 end
 --

 -- Bresenham fillDisc
 function testDiscArray(xm, ym, minrad, maxrad, w, ary)
   local x,y,r,tr,n,err,goodrad
  
   goodrad = 0

   for tr=minrad, maxrad, 1 do
    r = tr
    x = -r
    y = 0
    err = 2-2*r 
    while (x < 0) do
       for n=x, 1, 1 do
        if ary[xm-n + (ym+y)*w] + ary[xm+n + (ym-y)*w] + ary[xm-y + (ym-n)*w] + ary[xm+y + (ym+n)*w] > 0 then return goodrad; end
       end
       r = err;
       if (r <= y) then y = y+1; err = err + y*2+1; end          
       if (r > x or err > y) then x=x+1; err = err + x*2+1; end
    end
    goodrad = tr-- a circle of radius r will fit
   end

   return goodrad -- maxrad is possible
 end
 --


 w,h = getpicturesize()

 max,min,floor,sqrt = math.max,math.min,math.floor,math.sqrt

 circles = {}
 numeric = {}
 used = {}
 
 w,h = getpicturesize()


 statusmessage("Initiating..."); waitbreak(0)

 count = 0
 for y = 0, h-1, 1 do
  for x = 0, w-1, 1 do
   number = y * w + x
   count = count + 1
   numeric[count] = number
      used[number] = 0 -- Free, 1 = used
  end
 end


 statusmessage("Shuffling..."); waitbreak(0)
 db.shuffle(numeric)
 
 statusmessage("Discing..."); waitbreak(0)


 for n = 1, #numeric, 1 do

  num = numeric[n]

  if used[num] == 0 then

    y = floor(num/w)
    x = num - y*w

    xd1 = x; xd2 = w-x-1
    yd1 = y; yd2 = h-y-1

    cd = w*h

    if dist_mode then -- Real distances, slower. More "symmetrical" and aestethic. Outlines can overlap when drawn with Bresenham, thus more dense than test mode.
     for c = 1, #circles, 1 do
      cir = circles[c]
      cx,cy,cr = cir[1],cir[2],cir[3]
      dist = sqrt((cx-x)*(cx-x) + (cy-y)*(cy-y)) - cr - spacing
      cd = min(cd,dist)
      if cd < minrad then break end
     end
     mindist = min(cd,xd1,xd2,yd1,yd2)
    end


    if test_mode then  -- Pixlebased method, no overlapping. Very fast.
     maxr = min(maxrad,xd1,xd2,yd1,yd2)
     if #circles == 0 then 
      mindist = maxr-spacing -- 1st circle, no need for testing (very slow for a big disc)
        else
         -- Spacing is added to both max & min rad (to avoid scanning areas that's within the spacing) then it's subtracted from the final radius
         -- This is also why spacing is affecting the border of the screen, the bigger scan radii would otherwise go out of bounds.
         mindist = testDiscArray(x, y, minrad+spacing, maxr, w, used)-spacing
     end
    end

    

    if mindist >= minrad then
     --messagebox("Got One!")
     len = #circles + 1
     r = min(maxrad,floor(mindist))
     circles[len] = {x,y,r}
     db.plotCircle(x, y, r, 0, 1) -- last is step/dot
     --db.drawDisc(x,y,r,0)
     --db.filledDisc(x, y, r, 0)
     zone = spacing*0; if dist_mode then zone = minrad-1+spacing; end -- Trick: add minrad to eliminate areas that are bound to fail
     fillDiscArray(x, y, r+zone, w, used) -- Yes, we need this even in dist-mode, maybe not 100% exact with euclidean but essential for speed
     --if len % floor(sqrt(len)) == 0 then
     if n % 13 == 0 then
      statusmessage("Discs: "..len..", Done: "..floor(n/#numeric*100).."%")
      updatescreen();if (waitbreak(0)==1) then return end
     end
      --else putpicturepixel(x,y,27)
    end

  end -- Free pixel: used[num] == 0

end
 
 return circles

end
-- circlePattern



 --
 function makeMatrix(rad) -- Circle 1,2,3,4,5.. Makes sure sizes of matrix are odd 1,3,5,7,9...so we can center on full pixels (like Bresenham)
    local x,y,ct,val,dist,diff,matrix,c,siz,max,min,sqrt
    max,min,sqrt = math.max, math.min, math.sqrt
    matrix = {}
    siz = rad*2 + 1
    ct = rad
    for y = 0, siz-1, 1 do
     matrix[y+1] = {}
     for x = 0, siz-1, 1 do
      dist = sqrt((x-ct)*(x-ct) + (y-ct)*(y-ct))
      matrix[y+1][x+1] = min(1,max(0,ct - dist)) -- Gradient border/AA, maybe exp. drop-off? linear looks ok, though.
    end; end
   return matrix
  end -- makeMatrix
  --

--
function getAreaColor(cx,cy,mx) -- Get the average image rgb of the active pixels in the matrix mx (0 = inactive, 1 = active)
 local w,h,rt,gt,bt,area,siz,xx,yy,r,g,b,mxy,yp
 rt,gt,bt,area = 0,0,0,0
 w,h = getpicturesize()
 siz = #mx
  for yy=0, siz-1, 1 do 
   mxy = mx[yy+1]
   yp = yy+cy
   if yp>=0 and yp<h then
    for xx=0, siz-1, 1 do
      if (mxy[xx+1] > 0 and cx+xx>=0 and cx+xx<w) then -- We should never be out of bounds so checking matrix first is probably faster
       r,g,b = getbackupcolor(getbackuppixel(cx+xx,yp))

          rt = rt + r
          gt = gt + g
          bt = bt + b
  
          area = area + 1
      end
    end -- xx
   end
  end -- yy
  if area > 0 then 
   return area, rt/area, gt/area, bt/area
    else return -1,-1,-1,-1
  end
end
--




-- Pixelmode, Bresenham circels. No AA.
--
-- circles: list of circles {x,y,r}
-- average_flag: true/false, use average rgb-value of circle area rather than center-point color
--
function renderPIXELmode(circles, average_flag)

 local w,h,c,cx,cy,cr,area,ra,ga,ba,matrix

 w,h = getpicturesize()
 clearpicture(matchcolor(0,0,0))

 matrix = {}

 for c = 1, #circles, 1 do
 
   cx,cy,cr = circles[c][1],circles[c][2],circles[c][3]

   if average_flag then
    if matrix[cr] == nil then matrix[cr] = makeMatrix(cr);end
    area,ra,ga,ba = getAreaColor(cx-cr,cy-cr,matrix[cr])
    c = matchcolor2(ra,ga,ba)
     else
      c = getbackuppixel(cx,cy)
   end

   db.filledDisc(cx, cy, cr, c)

   --db.plotCircle(cx, cy, cr, 0, 1)
   --db.filledDisc(cx, cy, cr, 0)
  end

end
--

 
--
 -- In order to make circles kiss in dist-mode we need to +1 the drawing radius and use spacing=1
  -- Since the odd-size matrices are 1 bigger than the diameter (Bresenham style) 
  -- and +1 radii increase causes an overlap (diameter is +2) we need to add 1 pixel space
  -- We could use test-mode and no extra spacing..but that's not a perfect match. Bresenham arbitrary pixelstructure vs euclidean distance,
  -- aa-areas may overlap other circles.
--
function renderDISTmode(circles,average_flag, gamma)

 local w,h,c,r,g,b,ra,ga,ba,dc,siz,mx,cx,cy,cr,area,xx,yy,mxy,val,yp,rgam,valt
 local matrix

 w,h = getpicturesize()
 clearpicture(matchcolor(0,0,0))

 matrix = {}

 gamma = gamma or 2.0
 rgam = 1/gamma

 for c = 1, #circles, 1 do

  cx,cy,cr = circles[c][1],circles[c][2],circles[c][3]+1 -- Note the +1

  if matrix[cr] == nil then
   matrix[cr] = makeMatrix(cr) 
  end

  mx = matrix[cr]

  if average_flag then
   area,ra,ga,ba = getAreaColor(cx-cr,cy-cr,mx)
    else ra,ga,ba = getbackupcolor(getbackuppixel(cx,cy)); area = 1
  end

  cx = cx - cr -- Center matrix
  cy = cy - cr

  if area > 0 then

    dc = matchcolor2(ra,ga,ba)   

    siz = #mx
    for yy=0, siz-1, 1 do
     mxy = mx[yy+1]
     yp = cy+yy
     for xx=0, siz-1,1 do
      if (yp>=0 and yp<h and cx+xx>=0 and cx+xx<w) then
         
        val = mxy[xx+1]

        if (val>0) then
         c = dc

         if (val<1) then
          valt = val^rgam -- Gamma corrected transparency: sqrt(c^2*t) = c*sqrt(t), PROVIDING..we're just drawing on black!
          r = ra*valt
          g = ga*valt
          b = ba*valt
          c = matchcolor2(r,g,b)   
         end

         putpicturepixel(cx+xx,yp,c)
        end

      end
    end;end

     if c % 10 == 0 then
      updatescreen();if (waitbreak(0)==1) then return end
     end

  end
 end -- circles 
 
end
-- eof renderDISTmode


----------------------------------------------------------------------------------

--math.randomseed(1979)

minrad  = 1
maxrad  = 32
spacing = 2
mode = 2

gamma = 1.7 -- Higher gamma (2-0 to 2.2) makes bigger circles very smooth, but the smallest appears a bit square. 1.6 to 1.8 is a good middleground.

average_flag = true 

OK,mode1,mode2, minrad, maxrad, spacing, colmode1, colmode2, gamma = inputbox("DiscRender Filter",
                        
                           "1. Pixel mode",               0,  0,1,-1,
                           "2. Smooth mode *",              1,  0,1,-1,
                          
                           "Min Radius", minrad,  1,1000,0,  
                           "Max Radius", maxrad,  1,1000,0,
                           "Spacing", spacing,    -8,32,0,

                           "a) Color: Area Average",      1,  0,1,-2,
                           "b) Color: Center Point",      0,  0,1,-2,

                           "* AA Gamma: 1.0-2.2", gamma,  1.0,2.2,2
                                                     
);


if OK then

 mode = 1 + mode2 -- mode can be 1 or 2, if mode2 is unselected mode = 1, if selected then 1+1 = 2
 average_flag = true -- Get average color of all pixels in circle vs. Using the color of the center pixel
 if colmode2 == 1 then average_flag = false; end

 circles = circlePattern(minrad,maxrad,spacing, mode) -- minrad, maxrad, spacing, mode (negative values can be used for blotching effect)

 statusmessage("Discs: "..#circles..". Rendering..."); waitbreak(0)
 --messagebox("Circles: "..#circles)

 if mode == 1 then
  renderPIXELmode(circles, average_flag)
 end

 if mode == 2 then 
  renderDISTmode(circles, average_flag, gamma)
 end

end



