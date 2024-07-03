--SCENE: Smooth Mandelbrot v1.0
--by Richard 'DawnBringer' Fhager

dofile("../libs/memory.lua")
dofile("../libs/dawnbringer_lib.lua")


arg=memory.load({x0=-1.7,x1=0.7,ym=0,iter=256,freq=8,offset=0,mirror=1,dither=0,scene1=0})

OK, x0, x1, ym, iter, freq, offset, mirror, dither, scene1 = inputbox(".Smooth Mandelbrot v1.0",
  "X0",   arg.x0,   -2, 2,8,
  "X1",   arg.x1,   -2, 2,8,
  "Y-Position", arg.ym,   -2, 2,8,
  "Iterations", arg.iter, 1, 2048,0,
  "Color Frequency: 1-256", arg.freq, 1,256,0,
  "Palette Offset: 0-255", arg.offset, 0, 255,0,
  "Mirror Palette (256c)",  arg.mirror,  0,1,0,
  "Dither (Ordered 2x2)",  arg.dither,  0,1,0,
  "SET SCENE 'Inner Wave'",  arg.scene1,  0,1,0 
 
);

--offset = 64

-- -0.831116819,-0.831116815,0.2292112435,192
if OK == true then

memory.save({x0=x0,x1=x1,ym=ym,iter=iter, freq=freq, offset=offset, mirror=mirror, dither=dither, scene1=scene1})


 if scene1 == 1 then
  dofile("../gradients/pal_db_SetMandel1_256.lua")
  -- Inner Wave
  x0 = -0.831116819
  x1 = -0.831116815
  ym =  0.2292112435
  --freq = 4
  iter = 256
 end


--[[
-- Eyestorm
x0 = -0.777129978
x1 = -0.776078922
ym = 0.13455
iter = 800
--freq = 1
--]]


--[[
 c=math.pow(255,1/32)
 for n = 0, 32, 1 do
  v = n*8; d = (v*2+math.pow(c,n))/3
  setcolor(n,v*1.1,v,d)
  setcolor(64-n,d,d*1.1,v)
 end
--]]

--
function main(x0,x1,ym,iter,freq,offset,mirror,dither)

 local x,y,w,h,q,dc,div,it,p1,q1,zn,nu,it,wf,hf,span,step,steps, xwf
 local abs,log,log2,floor 
 local mandel

 abs  = math.abs
 log  = math.log
 log2 = math.log(2)
 floor = math.floor

 --
 function mandel(x,y,l,r,o,i,s) -- pos. as fraction of 1, left coord, right coord, y coord, iterations 

   local w,a,p,q,n,v

   --s = abs(r-l);

   a = l + s*x;
   p = a;
   b = o - s*(y-0.5);
   q = b;
   n,v,w = 1,0,0;
 
   while ((v+w)<256 and n<i) do n=n+1; v=p*p; w=q*q; q=2*p*q+b; p=v-w+a; end; -- 256 rather than 4 for better smootness

   return n,q,p
 end
 --

  w, h = getpicturesize()
  wf,hf = 1/w, 1/h
  
  span = abs(x1-x0)
  dc = 0
  div = freq
  steps = {32,16,8,1}
 for step = 1, #steps, 1 do

  step = steps[step]
  if step == 1 then
   for y = 0, h - 1, 1 do
    for x = y%2, w - 1, 2 do
     putpicturepixel(x,y,0)
  end;end;end

  for x = 0, w - 1, step do
    dc = dc + 1
    xwf = x * wf
    for y = 0, h - 1, step do
      dc = dc+1
     
     it,p1,q1 = mandel(xwf,y*hf,x0,x1,ym,iter,span)

     if it < iter then
      --zn = ( p1*p1 + q1*q1 )^0.5
      --nu = log( log(zn) / log2 ) / log2 

      -- log(x^0.5) = log(x)/2
      nu = log( log(p1*p1 + q1*q1)*0.5 / log2 ) / log2 -- 2-3% faster for the example scene, maybe 1% for default bug

      it = it + 1 - nu
     end

      --dith = 0; if dither == 1 then dith = ((y+x)%2)*0.5; end -- normal threshold

      -- dyna-dither 
      if floor(it * div + 0.5) == floor(it * div) then 
        dc = dc + 1
      end 
      --dith = 0; if dither == 1 then dith = (dc%2)*0.5; end
      dith = 0; if dither == 1 then dith = db.dithOrder2x2_frac(x,y); end

     --q = (offset + it * div + dith)

     if mirror == 1 then -- Mirror palette
      q = (offset + it * div + dith) % 512
      if q > 255 then q = 511 - q; end
       else q = (offset + it * div + dith) % 256
     end

     if step > 1 then
      --drawfilledrect(x,y,x+step,y+step,q)
      db.drawRectangle(x,y,step,step,q)
       else
        putpicturepixel(x, y, q);
     end

    end
    --if x%4==0 then updatescreen();if (waitbreak(0)==1) then return end; end
    if db.donemeter_x(4,x,w,h,step==1) then return; end
  end -- y
 end -- step

end -- main

--t1 = os.clock()
--x0, x1, ym, iter, freq, offset, mirror, dither, scene1
main(x0,x1,ym,iter,freq,offset,mirror,dither)
--messagebox("Seconds: "..(os.clock() - t1))

end -- ok


