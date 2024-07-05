--BRUSH/PICTURE: Mandelbrot Fractal V1.8 (mem)
--by Richard Fhager 


--(V1.8 fixed color offset bug)



dofile("../libs/memory.lua")



arg=memory.load({x0=-1.7,x1=0.7,ym=0,iter=64,colors=32,offset=0,pic=1,bru=0})

OK, x0, x1, ym, iter, colors, offset, pic, bru = inputbox(".Mandelbrot Fractal v1.8",
  "X0",   arg.x0,   -2, 2,8,
  "X1",   arg.x1,   -2, 2,8,
  "Y-Position", arg.ym,   -2, 2,8,
  "Iterations", arg.iter, 1, 2048,0,
  "Colors", arg.colors, 2,256,0,
  "Offset: 0..cols", arg.offset, 0,255,0,
  "Picture", arg.pic,0,1,-1,
  "Brush",   arg.bru,0,1,-1
);




-- -0.831116819,-0.831116815,0.2292112435,192
if OK == true then

memory.save({x0=x0,x1=x1,ym=ym,iter=iter,colors=colors,offset=offset,pic=pic,bru=bru})


function mandel(x,y,l,r,o,i) -- pos. as fraction of 1, left coord, right coord, y coord, iterations 

  local w,s,a,p,q,n,v,w

  s=math.abs(r-l);

  a = l + s*x;
  p = a;
  b = o - s*(y-0.5);
  q = b;
  n = 0; -- was 1
  v = 0;
  w = 0; 

  while (v+w<4 and n<i) do n=n+1; v=p*p; w=q*q; q=2*p*q+b; p=v-w+a; end;

  return n
end

if bru == 1 then
  w, h = getbrushsize()
  for x = 0, w - 1, 1 do
    xw = x/w
    for y = 0, h - 1, 1 do
     q = offset + (mandel(xw,y/h,x0,x1,ym,iter)) % colors; -- if index>255 it will automatically cycle around to 0
     putbrushpixel(x, y, q);
    end
  end
end

if pic == 1 then
  w, h = getpicturesize()
  for x = 0, w - 1, 1 do
    xw = x/w
    for y = 0, h - 1, 1 do
     q = offset + mandel(xw,y/h,x0,x1,ym,iter) % colors;
     --q = ((mandel(xw,y/h,x0,x1,ym,iter) -1) / iter)^0.5 * colors;

     putpicturepixel(x, y, q);
    end
    if x%4==0 then
     updatescreen();if (waitbreak(0)==1) then return end
    end
  end
end



end