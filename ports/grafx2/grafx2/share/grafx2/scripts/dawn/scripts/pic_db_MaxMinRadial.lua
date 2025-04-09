--PICTURE: Radial Max/Min Filter V1.0
--by Richard Fhager

-- Radial Quick Hack. Only works with odd size (radius) of 3,5... 
-- I think Radial is more attractive then the square (Photoshop) method


function maxminFilter(diam,amt,mode)
 local r,g,b,mx,my,mxh,myh,mp,xx,yy,x,y,w,h,ro,go,bo,amtr
 local mxr,mxg,mxb,xir,mig,mib,mr,mg,mb,max,min,f1,lx,black
 local dist,radii,ypyp

 min,max = math.min,math.max
 black = matchcolor(0,0,0)

 -- max
 if mode == 1 then f1 = function(a,b) return a; end; end
 -- min
 if mode == 2 then f1 = function(a,b) return b; end; end
 -- median
 if mode == 3 then f1 = function(a,b) return (a + b) / 2; end; end;

 amtr = 1 - amt
 w, h = getpicturesize()
 mxh = math.floor(diam / 2) + 1
 --myh = math.floor(cy / 2) + 1

 --dist = (yp*yp + xp*xp)^0.5 - 0.25 -- adjustment for better looking discs, looks good for 3,5,7 & 9
 --if dist <= math.floor(cx/2)
 -- gives for unrooted dist
  radii = (math.floor(diam/2) + 0.25)^2

  for y = 0, h-1, 1 do
  for x = 0, w-1, 1 do
   ro,go,bo = getcolor(getbackuppixel(x,y))
   mxr,mxg,mxb = 0,0,0
   mir,mig,mib = 255,255,255

   for my = 1, diam, 1 do
    yp = my-mxh
    yy = y + yp

    if yy>=0 and yy<h then 

     ypyp = yp*yp

     for mx = 1, diam, 1 do
      xp = mx-mxh
      xx = x + xp

      if xx>=0 and xx<w then

       dist = ypyp + xp*xp 

       if dist <= radii then
        r,g,b = getcolor(getbackuppixel(xx,yy)) 
        mxr = max(mxr,r)
        mxg = max(mxg,g)
        mxb = max(mxb,b)  
        mir = min(mir,r)
        mig = min(mig,g)
        mib = min(mib,b)
       end

      end

     end -- mx
    end -- if yy
   end -- my

   mr = f1(mxr,mir)
   mg = f1(mxg,mig)
   mb = f1(mxb,mib)
   r = (ro * amtr) + mr * amt 
   g = (go * amtr) + mg * amt
   b = (bo * amtr) + mb * amt
   putpicturepixel(x,y,matchcolor(r,g,b))
 end;
 statusmessage("Done: "..math.floor((y+1)*100/h).."%")
 if y%8==0 then
  for lx = 0, w-1, 2 do putpicturepixel(lx,y+1,black); end
  updatescreen(); if (waitbreak(0)==1) then return; end; 
 end
 end;

end



OK,MAX,MIN,MED,R3,R5,R7,R9,R11,AMT = inputbox("Max/Min Filter (Radial)",
                           "1. Max",               1,    0,1,-1, 
                           "2. Min",               0,    0,1,-1,
                           "3. Median",            0,    0,1,-1,
                           "a) Radius 1.5",           0,    0,1,-2, 
                           "b) Radius 2.5",           1,    0,1,-2,
                           "c) Radius 3.5",           0,    0,1,-2, 
                           "d) Radius 4.5",           0,    0,1,-2,
                           "e) Radius 5.5",           0,    0,1,-2,                           
                           "AMOUNT %",             100,  0,100,0   
);

if OK == true then

DIAM = 1 + 2 * (1 + math.log(R3 + R5*2 + R7*4 + R9*8 + R11*16) / math.log(2))

MODE = MAX*1 + MIN*2 + MED*3
maxminFilter(DIAM,AMT/100,MODE)

end