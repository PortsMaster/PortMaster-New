--PICTURE: Image 4-Split (QuadTree) Redux V1.1
--by Richard 'DawnBringer' Fhager
--
--Recursive image 4-splitting based on color-distances: 
--preserve areas of high detail, replace less detailed areas with their average (gamma-corrected) color,
--or just draw the dividing lines of the areas.
--

--

dofile("../libs/dawnbringer_lib.lua")

function main(Threshold,Variance,Line_Strength,BrightRND,MinSplit,Lines_Only,Clear_Img, Single_Plot)

 local Img,fget,fput,fcontrol,frend,cap,x,y,w,h,r,g,b,n,v,npal,update,W,H,Pixels,TOTAL,CONTRAST,AREACOUNT
 local Mr,Mx,Mf,Total,Count,Term,GoAhead,LinesOnlyMode, SingleCellPlot
 local CDIST,a
 local line, check, clearArea, drawArea, fcontrol

 AREACOUNT = 0 -- Total areas drawn

 Variance = Variance / 100

 SingleCellPlot = false
 if Single_Plot == 1 then SingleCellPlot = true; end

 LinesOnlyMode = false
 if Lines_Only == 1 then LinesOnlyMode = true; end -- Don't fill areas with avg. color
 ClearImage = false
 if Clear_Img == 1 then ClearImage = true; end

 if Line_Strength == 0 and not SingleCellPlot then
  if LinesOnlyMode or ClearImage then
     messagebox("Warning!","'Lines Only' or 'Solid Color' with a Line Strength of 0 won't produce anything... \n\nScript will exit.")
     return
   end
 end 

 W,H = getpicturesize()

 Pixels = W*H
 TOTAL = 0  -- Pixels processed
 Count = 0  -- Splits performed


 -- Contrast Line Mode
 -- Contrast mode doesn't work with LinesOnly as it would require a custom pixel-by-pixel inverse Line-drawing algorithm 
 CONTRAST = false
 if (getforecolor() == getbackcolor()) and Line_Strength>0 and not LinesOnlyMode then
  CONTRAST = true
  messagebox("Contrast Mode Enabled!", "Pencolors are the same index -->\n\nLine-Contrast mode enabled!")
 end

 Mr = math.random
 Mx = math.max
 Mf = math.floor

 --Total = db.recursiveSum(2,Iter-1)
 --MinSplit = 4 -- Smallest cellsize allowed to be split again


 GoAhead = true -- Allow program to run

 -------------------------
 -- Colors Distance Table
 CDIST = {}
 for a = 0, 255, 1 do
  CDIST[a+1] = {}
  r1,g1,b1 = getcolor(a)
  for b = a+1, 255, 1 do
   r2,g2,b2 = getcolor(b) 
    CDIST[a+1][b+1] = db.getColorDistance_weightNorm(r1,g1,b1,r2,g2,b2,0.26,0.55,0.19)
  end
 end
 --
 --------------------------

--
function line(p0,p1,p2,p3,r,g,b, iter_count)
 local x,y,xs,ys,pow
 x,y,xs,ys = p0[1],p0[2],p1[1]-p0[1],p2[2]-p0[2]

  pow = 1.0
  --pow = 1-math.min(1,(2^(iter_count-1))^0.5 / 16) -- Weaken with each iteration
  --pow = (2^(iter_count-1))^0.5 / 32 -- With strongest color at last iteration, not 100% knowing which iteration is last - it's tricky..-

 --db.lineTranspAAgamma(x1,y1,x2,y2,r0,g0,b0,amt,gamma,skip)
 db.lineTranspAAgamma(x,y,x+xs-1,y,r,g,b,Line_Strength*pow,2.2, 0)
 db.lineTranspAAgamma(x,y,x,y+ys-1,r,g,b,Line_Strength*pow,2.2, 0)
 --db.lineTransp(x,y,x+xs,y, Line_Col, Line_Strength) 
 --db.lineTransp(x,y,x,y+ys, Line_Col, Line_Strength)
end
--

--
 function check(p0,p1,p2,p3,iter_count) -- See if area is "smooth" enough to prevent further splitting

  local plist,fill,alist,found,i,j,maxdist
  local x,y,xp,yp,xs,ys,r,g,b,rt,gt,bt,pix,v,ra,ga,ba,c,q,result,ypy,cd
  xp,yp,xs,ys = p0[1],p0[2],p1[1]-p0[1],p2[2]-p0[2]

  result = 0; -- No split

  --
  plist = {} -- colors (indexes) found/active in area
  for x = 1, 256, 1 do
   plist[x] = 0
  end
  --

  fill = matchcolor(Mr(0,255),Mr(0,255),Mr(0,255))

  rt,gt,bt,pix = 0,0,0,0
   for y = 0, ys - 1, 1 do
    ypy = yp+y
    for x = 0, xs - 1, 1 do
     c = getbackuppixel(xp+x,ypy)
     plist[c+1] = 1

     -- draw a temporary process pattern
     if not LinesOnlyMode and iter_count<3 and (x+xp+ypy)%2 == 0 then -- iter 0 = entire screen, area is "re-patterned" for each iteration, so let's only do 3
      putpicturepixel(xp+x,ypy,fill) 
     end
 
     -- Saving Pink 
     --r,g,b = getcolor(c)
     --if r>g and r>b and b>g then result = 1; end

    end --x
   end --y 

   ----
   -- Finding Max Distance
   maxdist = 0
   alist = {} -- list of present colors only
   found = 0
   for x = 1, 256, 1 do
    if plist[x] == 1 then found = found+1; alist[found] = x; end
   end
   --
   for i = 1, #alist, 1 do
    cd = CDIST[alist[i]]
    for j = i+1, #alist, 1 do 
     --*** maxdist = Mx(maxdist, cd[alist[j]]) -- i must be the smallest value: {2,3} exist, {3,2} does not.
     if cd[alist[j]] > Threshold then return 1; end -- We only need to find one instance to conclude a split
    end
   end
   --
   --*** if maxdist > Threshold then result = 1; end -- Split if there's enough color-diff in the area
   ----
 
   return 0 -- No distance large enough found
   --**return result
  
 end
-- eof finding max distance

 --
 function clearArea(p0,p1,p2,p3,color)
   local x,y,xp,yp,xs,ys,r,g,b,rt,gt,bt,pix,v,ra,ga,ba,c,q,ypy
   xp,yp,xs,ys = p0[1],p0[2],p1[1]-p0[1],p2[2]-p0[2]
     for y = 0, ys - 1, 1 do
      ypy = yp+y
      for x = 0, xs - 1, 1 do
       putpicturepixel(xp+x,ypy,color)
      end
     end 
 end
 --

 --
 function drawArea(p0,p1,p2,p3,iter_count)

  local x,y,xp,yp,xs,ys,r,g,b,rt,gt,bt,pix,v,ra,ga,ba,c,q,ypy
  xp,yp,xs,ys = p0[1],p0[2],p1[1]-p0[1],p2[2]-p0[2]

  if not (xs<2 and ys<2) then -- Don't process single pixel areas

   v,rt,gt,bt,pix,gam = 0, 0,0,0, 0, 2.0
   rgam = 1 / gam
   for y = 0, ys - 1, 1 do
    ypy = yp+y
    for x = 0, xs - 1, 1 do 
     r,g,b = getcolor(getbackuppixel(xp+x,ypy))
     rt = rt + r^gam
     gt = gt + g^gam
     bt = bt + b^gam
     pix = pix + 1
    end
   end

   if BrightRND > 0 then
    q = (20 / (20 + iter_count))^2 -- 0.27 at 18th iteration (less bri-variation in smaller cells)
    v = Mr(-BrightRND*q,BrightRND*q)
   end
  
   --c = matchcolor(224+v,224+v,224+v) -- Plain background for lines only

     ra,ga,ba = (rt/pix)^rgam+v,(gt/pix)^rgam+v,(bt/pix)^rgam+v
     c = matchcolor2(ra,ga,ba)
     for y = 0, ys - 1, 1 do
      ypy = yp+y
      for x = 0, xs - 1, 1 do
         --putpicturepixel(xp+x,ypy,getbackuppixel(xp+x,ypy)) -- just replace/redraw image 
       putpicturepixel(xp+x,ypy,c)
       --putpicturepixel(xp+x,ypy,getbackcolor())
      end
     end 

    else c = getbackuppixel(xp,yp); putpicturepixel(xp,yp,c); ra,ga,ba = getcolor(c) 
   end -- if xs==0

   TOTAL = TOTAL + xs*ys

   return ra,ga,ba

 end
--

 --update = Iter^math.floor(1+Iter/8)

 -- Recursive control function
 --
 function fcontrol(p0,p1,p2,p3,iter_count)

  local x,y,r,g,b,xd,yd,frand,nosplit,result,rf,gf,bf,ra,ga,ba
  local r01,g01,b01,r02,g02,b02,r13,g13,b13,r23,g23,b23,r55,g55,b55

  nosplit = true

  if GoAhead then

   local p11,p01,p22,p02

   p11,p01,p22,p02 = p1[1],p0[1],p2[2],p0[2]

   xd = p11 - p01
   yd = p22 - p02

  result = check(p0,p1,p2,p3,iter_count) -- 0 = Done/Exit, Don't Split any further

  if result == 1 then

   if xd >= MinSplit and yd >= MinSplit then -- 4-split
    x = Mf((p01 + p11) / 2 + xd * Variance * (Mr()-0.5))
    y = Mf((p02 + p22) / 2 + yd * Variance * (Mr()-0.5))
    fcontrol(p0, {x,p02}, {p01,y}, {x,y}, iter_count+1)
    fcontrol({x,p02}, p1, {x,y}, {p11,y}, iter_count+1)
    fcontrol({p01,y}, {x,y}, p2, {x,p22}, iter_count+1)
    fcontrol({x,y}, {p11,y}, {x,p22}, p3, iter_count+1)
    nosplit = false; Count = Count + 1

     else
      if xd >= MinSplit then -- Allow splitting only in x if y is too small
       x = Mf((p01 + p11) / 2)
       fcontrol(p0, {x,p02}, p2, {x,p22}, iter_count+1)
       fcontrol({x,p02}, p1, {x,p22}, p3, iter_count+1)
       nosplit = false; Count = Count + 1
      end
      if yd >= MinSplit then -- Allow splitting only in y if x is too small
       y = Mf((p02 + p22) / 2)
       fcontrol(p0, p1, {p01,y}, {p11,y}, iter_count+1)
       fcontrol({p01,y}, {p11,y}, p2, p3, iter_count+1)
       nosplit = false; Count = Count + 1
      end

   end

  end -- split?  

       if (Count % 10 == 0) then
        done = math.floor(TOTAL/Pixels * 100)
        statusmessage("Split: "..Count..", Done: "..done.."%"); 
        if (waitbreak(0)==1) then
         --messagebox("!")
         GoAhead = false
        end;
       end

       
   end -- GoAhead

    if nosplit then -- Draw final cell
      AREACOUNT = AREACOUNT + 1
      rf,gf,bf = getcolor(getforecolor())
      ra,ga,ba = rf,gf,bf -- Give values for Contrast mode when ClearImage (BG fill mode) is active, resulting in inverse for line color (rather than same color for both))
      if not LinesOnlyMode then
       if ClearImage then
         clearArea(p0,p1,p2,p3,getbackcolor()) -- Can't have bg-mode and linesonly (don't affect image) at the same time
         else
          ra,ga,ba = drawArea(p0,p1,p2,p3,iter_count); 
       end
      end
      if Line_Strength > 0 then 
       r,g,b = rf,gf,bf
       if CONTRAST then r,g,b = (ra+128)%255,(ga+128)%255,(ba+128)%255; end
       line(p0,p1,p2,p3,r,g,b,iter_count); 
      end
          -- Plot single pixel cells
          -- Note that this is quite counterintuitive. If the image dimensions is not a power of 2 (512 f.ex)
          -- the divisions can form broken patterns/lines and clusters of different thickness or length.
          -- If a power of 2, then all plots will come in clusters/squares of 2x2 (as 2x2 areas are split into 4 single pixel cells)
          if SingleCellPlot then
           xd = p1[1] - p0[1] 
           yd = p2[2] - p0[2]
           if xd<2 and yd<2 then
            putpicturepixel(p0[1],p0[2],getforecolor())
           end
          end
          -- 
    end -- Final cell

    if iter_count < 5 then updatescreen();if (waitbreak(0)==1) then return end; end

 end -- Control
 --

 -- Note w, not w-1. We're splitting areas/#ofpixels, rather than dealing with coords
 -- So if we have an image of 100x100, we'll split (100-0)/2 and not (99-0)/2
t = ""
t1 = os.clock()
 fcontrol({0,0},{W,0},{0,H},{W,H},0) 
t2 = os.clock()
ts = (t2 - t1) 
t = t.."\n\n Time: "..db.format(ts,2).." s"
 messagebox("Areas: "..AREACOUNT..t)
 --

end
-- main


OK,Threshold,LINESTR,MINSPLIT,NORMAL,CLEARIMG,LINESONLY,SINGLEPLOT,Variance = inputbox("Image 4-Split Redux",           
                          
                           "Dist. Threshold: 0-255",    40,  0,255,0,
                           "Line Strength % (0 = off)", 20,  0,100,0, 
                           "MinSplit Size: 2-100",       2,   2,100,0,

                           "1. Average Color",                 1,    0,1,-1, -- Normal mode
                           "2. Fill Solid (BG col)",           0,    0,1,-1, -- BG color
                           "3. No Fill (lines Only)",          0,    0,1,-1, -- Lines Only

                           "Plot Single-pixel Cells", 0, 0,1,0,   

                           "Offset Variance %",         0,   0,100,0
                                                             
);


if OK then

 BRIGHTRND = 0 -- not used
 main(Threshold,Variance,LINESTR/100,BRIGHTRND,MINSPLIT,LINESONLY,CLEARIMG,SINGLEPLOT)

end





