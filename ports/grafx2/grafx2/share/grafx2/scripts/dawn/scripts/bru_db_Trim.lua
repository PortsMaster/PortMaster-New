--BRUSH: Trim V1.0
--by Richard Fhager 


w,h = getbrushsize()

wmax = math.floor(w/2 - 0.5)
hmax = math.floor(h/2 - 0.5)

x0,x1,y0,y1 = 0,0,0,0

OK,dummy,x0,x1,y0,y1 = inputbox("Trim Brush ("..w.."x"..h..")",
           
 "--- Pixels to remove ---",   0,   0,0,4,                
 "Left",   x0,  0,wmax,0,  
 "Right",  x1,  0,wmax,0, 
 "Top",    y0,  0,hmax,0,
 "Bottom", y1,  0,hmax,0     
                                                                           
);


if OK then

 nw = w-x0-x1
 nh = h-y0-y1

 setbrushsize(nw,nh)

 for y = 0, nh-1, 1 do
  for x = 0, nw-1, 1 do
   putbrushpixel(x,y,getbrushbackuppixel(x+x0,y+y0))
  end
 end

end



