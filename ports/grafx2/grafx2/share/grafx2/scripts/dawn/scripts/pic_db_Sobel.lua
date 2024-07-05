--PICTURE: Sobel Edge Detection V1.0
--(Edge detection, Sobel-Feldman operator)
--by Richard 'DawnBringer' Fhager 2015

function sobel(amt,neg,str,bias,mode)
 local r,g,b,mx,my,cx,cy,mxh,myh,mp,rb,gb,bb,xx,yy,x,y,w,h,n1,n2,amtr,ro,go,bo,mtx
 local r1,g1,b1,r2,g2,b2,convmx1,convmx2,mtx1,mtx2,mp1,mp2

 convmx1 = {{ -1,  0,  1,},
            { -2,  0,  2,}, 
            { -1,  0,  1 }}


 convmx2 = {{ -1, -2, -1,},
            {  0,  0,  0,}, 
            {  1,  2,  1 }}

 amt = amt or 1
 neg = neg or 1
 str = str or 1
 bias = bias or 0  -- Brighter is brighter even in negative modes
 mode = mode or "normal"

 --bias = -127 -- Funky mode
 --normal = neg = 1; divisor = 4
 --cartoon = neg = 0; divisor = 2 -- or 1

 n1 = 1
 n2 = bias
 if neg == 1 then
  n1 = -1
  n2 = 255 + bias
 end
 
 amtr = 1 - amt
 w, h = getpicturesize()
 cy = #convmx1
 cx = #convmx1[1]
 mxh = math.floor(cx / 2) + 1
 myh = math.floor(cy / 2) + 1

 t1 = os.clock()
 for y = 0, h-1, 1 do
  for x = 0, w-1, 1 do
   r1,g1,b1 = 0,0,0
   r2,g2,b2 = 0,0,0
   ro,go,bo = getcolor(getbackuppixel(x,y))
   for my = 1, cy, 1 do
    mtx1 = convmx1[my]
    mtx2 = convmx2[my]
    for mx = 1, cx, 1 do

     if not(mx == 2 and my == 2) then -- Centre has no effect so omitt for speed, ok mp1/mp2 would be more "pure", but hey, it's a speed hack

      xp = mx-mxh
      yp = my-myh
      mp1 = mtx1[mx]
      mp2 = mtx2[mx]
      xx = x + xp
      yy = y + yp
 
      -- "Extend the image across the border"
      if yy<0 then yy = 0; end
      if yy>=h then yy = h-1; end 
      if xx<0 then xx = 0; end
      if xx>=w then xx = w - 1; end

       rb,gb,bb = getcolor(getbackuppixel(xx,yy)) 
       r1 = r1 + rb * mp1
       g1 = g1 + gb * mp1
       b1 = b1 + bb * mp1
       r2 = r2 + rb * mp2
       g2 = g2 + gb * mp2
       b2 = b2 + bb * mp2

      end -- not centre
       
    end
   end
   r = (r1*r1 + r2*r2)^0.5
   g = (g1*g1 + g2*g2)^0.5
   b = (b1*b1 + b2*b2)^0.5
 
   -- funky
   --r = math.atan2(r2,r1) / 3.15 * 255 -- bias -127
   --g = math.atan2(g2,g1) / 3.15 * 255 
   --b = math.atan2(b2,b1) / 3.15 * 255
   

   if mode == "cartoon" then
    r = ro*amtr + (ro - n1*(r - 127)*str + bias)*amt  -- Cartoon mode, Controlled by divisor, 2 looks pretty good
    g = go*amtr + (go - n1*(g - 127)*str + bias)*amt
    b = bo*amtr + (bo - n1*(b - 127)*str + bias)*amt 
   end
   
  

   if mode == "normal" then
    r = ro*amtr + (n2 + (n1 * r)*str)*amt -- +bias
    g = go*amtr + (n2 + (n1 * g)*str)*amt 
    b = bo*amtr + (n2 + (n1 * b)*str)*amt 
   end
 

   putpicturepixel(x,y,matchcolor(r,g,b))
 end;
  if y%8 == 0 then
   statusmessage("Done: "..math.floor((y+1)*100/h).."%")
   updatescreen(); if (waitbreak(0)==1) then return; end
  end
 end;

 --messagebox("Seconds: "..(os.clock() - t1))
end




OK,normal,cartoon,str,bias,neg,amount = inputbox("Sobel Edge Detection (Color)",
                       
                           "1. Normal (Sobel)",  1,  0,1,-1,
                           "2. Glow/Cartoon  ",  0,  0,1,-1,
                           "Strength %",   50,0,200,0,
                           "Bias: -255..255",   0,  -255,255,0,
                           "NEGATIVE",        1,  0,1,0, 
                       
                           "AMOUNT %",       100,  0,100,0    
);

if OK then

--sobel(amt,neg,str,bias)
-- Normal: amt=1, neg=1 (negative/white bkg), str=0.25, bias=0
-- cartoo: amt=1, neg=0, str=0.5, bias=0
--sobel(1.0, 1, 0.5, 0, "normal") -- Same as PS "Find Edges" (with div=1)
--sobel(1.0, 1, 0.5, 0, "cartoon") -- amt=0.5,div=1 is eq. to amt=1,div=2 in cartoon mode

 mode = "normal"
 if cartoon == 1 then mode = "cartoon"; end

 sobel(amount/100, neg, str/100, bias, mode)

end
