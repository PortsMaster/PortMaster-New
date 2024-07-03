--BRUSH: Make a Brush of the Histogram V1.1 (size fix)
--by Richard Fhager 

dofile("../libs/dawnbringer_lib.lua")
--> db.drawBrushRectangle(x,y,w,h,c)
--> db.makeHistogram()

colors = 32
width  = 4
height = 200

OK,colors,width,height,xpen = inputbox("Image Histogram as Brush",
                       "Colors",               colors,   2,256,0,
                       "Cell Width",            width,  1,32,0,
                       "Max Height",           height,  8,512,0,
                       "Exclude Pen-color",         0,  0,1,0 
                     
);

--
if OK == true then

penc = -1
if xpen == 1 then penc = getforecolor(); end

hist = db.makeHistogram()
max = 1; maxi = -1
for n = 1, colors, 1 do
 if hist[n] >= max and (n-1) ~= penc then 
  max = hist[n]; maxi = n; 
 end
end

scale = height / max


setbrushsize((colors - xpen) *  width, height)

 x = 0
 for c = 0, colors-1, 1 do
  --db.drawBrushRectangle(c*width,0,width,math.floor(1+hist[c+1]*scale),c)
  if c ~= penc then
   v = math.floor(1+hist[c+1]*scale)
   db.drawBrushRectangle(x*width,height-v,width,v,c)
   x = x + 1
  end
 end

end; 
--

