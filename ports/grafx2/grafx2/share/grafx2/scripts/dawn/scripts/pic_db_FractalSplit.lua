--PICTURE: Fractal Split V1.6
--(Recursive 2-split Fractal)
--by Richard 'DawnBringer' Fhager


--Pencolor is line col
--Same pencol enables line-contrast mode

dofile("../libs/dawnbringer_lib.lua")

function main(Iter,Variance,Terminate,TermIterLimit,Line_Strength,BrightRND,MINSPLIT)

 local Img,fget,fput,frend,cap,x,y,w,h,r,g,b,n,v,npal,update
 local Mr,Total,Count,Render,Term,Line_Col,MinSplit,CONTRAST
 local fcontrol, stuff, line
 local floor  

 Variance = Variance / 100

 Mr = math.random
 floor = math.floor

 Render = true
 Total = db.recursiveSum(2,Iter-1)
 Count = 0
 
 Line_Col = matchcolor(0,0,0)
 MinSplit = MINSPLIT -- Smallest cellsize allowed to be split again

 -- Contrast Line Mode 
 CONTRAST = (getforecolor() == getbackcolor())
 if CONTRAST and Line_Strength>0 then
  messagebox("Contrast Mode Enabled!", "Pencolors are the same index -->\n\nLine-Contrast mode enabled!")
 end

--
function line(p0,p1,p2,p3,ra,ga,ba)
 local x,y,xs,ys
 x,y,xs,ys = p0[1],p0[2],p1[1]-p0[1],p2[2]-p0[2]
  local r,g,b
  r,g,b = getcolor(getforecolor())
  if CONTRAST then -- Line Contrast mode
   r,g,b = (ra+128)%255, (ga+128)%255, (ga+128)%255
  end
  db.lineTranspAAgamma(x,y,x+xs-1,y,r,g,b,Line_Strength,2.2, 0)
  db.lineTranspAAgamma(x,y,x,y+ys-1,r,g,b,Line_Strength,2.2, 0)
 --db.lineTransp(x,y,x+xs,y, Line_Col, Line_Strength) 
 --db.lineTransp(x,y,x,y+ys, Line_Col, Line_Strength)
end
--

 --
 function stuff(p0,p1,p2,p3,iter_count)

  local x,y,xp,yp,xs,ys,r,g,b,rt,gt,bt,pix,v,ra,ga,ba,c,q,ypy
  xp,yp,xs,ys = p0[1],p0[2],p1[1]-p0[1],p2[2]-p0[2]

   rt,gt,bt,pix,gam = 0,0,0,0,2.0
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

   q = (20 / (20 + iter_count))^2 -- 0.27 at 18th iteration (less bri-variation in smaller cells)
   --v = 80 - iter_count*6
   v = Mr(-BrightRND*q,BrightRND*q)
   ra,ga,ba = (rt/pix)^rgam+v,(gt/pix)^rgam+v,(bt/pix)^rgam+v
   c = matchcolor2(ra,ga,ba)
   for y = 0, ys - 1, 1 do
    ypy = yp+y
    for x = 0, xs - 1, 1 do
     putpicturepixel(xp+x,ypy,c)
    end
   end 

   return ra,ga,ba
 end
--

 update = Iter^math.floor(1+Iter/8)

 -- Recursive control function
 --
 function fcontrol(p0,p1,p2,p3,iter_count)
  local x,y,r,g,b,xd,yd,frand,nosplit
  local r01,g01,b01,r02,g02,b02,r13,g13,b13,r23,g23,b23,r55,g55,b55

  --if Line_Strength > 0 then line(p0,p1,p2,p3); end

  nosplit = true
  if iter_count < Iter then

   xd = p1[1] - p0[1]
   yd = p2[2] - p0[2]

  if Mr(0,100) >= Terminate or iter_count<TermIterLimit then
   if xd >= yd and xd >= MinSplit then -- Split on x
    x = floor((p0[1] + p1[1]) / 2 + xd * Variance * (Mr()-0.5))
    --x = math.floor((p0[1] + p1[1]) / 2 + xd * Mr(-1,1) * 0.25) -- 25,50 or 75 % splits
    fcontrol(p0, {x,p0[2]}, p2, {x,p2[2]}, iter_count+1)
    fcontrol({x,p0[2]}, p1, {x,p2[2]}, p3, iter_count+1)
    nosplit = false
    else
     if yd >= MinSplit then
       y = floor((p0[2] + p2[2]) / 2 + yd * Variance * (Mr()-0.5))
       --y = math.floor((p0[2] + p2[2]) / 2 + yd * Mr(-1,1) * 0.25)
       fcontrol(p0, p1, {p0[1],y}, {p1[1],y}, iter_count+1)
       fcontrol({p0[1],y}, {p1[1],y}, p2, p3, iter_count+1)
       nosplit = false
     end -- yd
   end -- xd
  end -- terminate?

       Count = Count + 1
       if (Count % (1+update) == 0) then 
        statusmessage(Count.." / "..Total); --updatescreen(); 
        if (waitbreak(0)==1) then Iter = 0; Render = false; return; end;
       end
       
   end -- iter_count

    if nosplit then -- Draw final cell
      --db.backdrop(p0,p1,p2,p3,putpicturepixel,"cosine")
      ra,ga,ba = stuff(p0,p1,p2,p3,iter_count)
      if Line_Strength > 0 then line(p0,p1,p2,p3,ra,ga,ba); end
    end

    if iter_count < 5 then updatescreen();if (waitbreak(0)==1) then return end; end

 end -- Control
 --

 w,h = getpicturesize()

 fcontrol({0,0},{w,0},{0,h},{w,h},0)
 --

end
-- main


OK,Levels,Variance,MINSPLIT,BRIGHTRND,LINESTR ,Terminate,TermIterLimit = inputbox("Fractal Split Image",
                   
                           "Iterations",              14,   0,19,0,  
                           "Offset Variance %",       65,   0,100,0,
                           "MinSplit Size: 2-100",     4,   2,100,0,
                           "RND Brightness: 0-128",   20,   0,128,0,
                           "Line Strength %",         15,   0,100,0,   
                           "Termination Chance* %",    0,   0,100,0,
                           "*Term. Iteration Limit",   7,   0,18,0
                           
                                      
);

if OK then

 main(Levels,Variance,Terminate,TermIterLimit,LINESTR/100,BRIGHTRND,MINSPLIT)

end





