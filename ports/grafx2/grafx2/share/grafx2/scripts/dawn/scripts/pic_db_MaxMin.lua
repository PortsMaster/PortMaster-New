--PICTURE: Max/Min Filter V1.5 (PS style)
--by Richard Fhager

function maxminFilter(cx,cy,amt,mode)
 local r,g,b,mx,my,mxh,myh,mp,xx,yy,x,y,w,h,ro,go,bo,amtr
 local mxr,mxg,mxb,xir,mig,mib,mr,mg,mb,max,min,f1,lx,black

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
 mxh = math.floor(cx / 2) + 1
 myh = math.floor(cy / 2) + 1

  for y = 0, h-1, 1 do
  for x = 0, w-1, 1 do
   ro,go,bo = getcolor(getbackuppixel(x,y))
   mxr,mxg,mxb = 0,0,0
   mir,mig,mib = 255,255,255

   for my = 1, cy, 1 do
    yp = my-myh
    yy = y + yp

    if yy>=0 and yy<h then 
     for mx = 1, cx, 1 do
      xp = mx-mxh
      xx = x + xp

      if xx>=0 and xx<w then
       r,g,b = getcolor(getbackuppixel(xx,yy)) 
       mxr = max(mxr,r)
       mxg = max(mxg,g)
       mxb = max(mxb,b)  
       mir = min(mir,r)
       mig = min(mig,g)
       mib = min(mib,b)
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



OK,MAX,MIN,MED,XS,YS,AMT = inputbox("Max/Min Filter",
                           "1. Max",               1,    0,1,-1, 
                           "2. Min",               0,    0,1,-1,
                           "3. Median",            0,    0,1,-1,
                           "X-Size",               3,    1,16,0,                       
                           "Y-Size",               3,    1,16,0, 
                           "AMOUNT %",             100,  0,100,0   
);

if OK == true then

MODE = MAX*1 + MIN*2 + MED*3
maxminFilter(XS,YS,AMT/100,MODE)

end