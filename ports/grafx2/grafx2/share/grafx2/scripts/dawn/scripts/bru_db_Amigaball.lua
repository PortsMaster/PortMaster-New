--BRUSH Scene: Amiga Ball V1.01
--by Richard Fhager 


w, h = getbrushsize()

sqrt = math.sqrt
floor = math.floor
cos = math.cos
max = math.max
pi = math.pi

for y = 0, h - 1, 1 do
  for x = 0, w - 1, 1 do

   -- Fractionalize image dimensions
   ox = x / w;
   oy = y / h;

   -- Ball
   Xr = ox-0.5; Yr = oy-0.5; 
   W = (1 - 2*sqrt(Xr*Xr + Yr*Yr)); 

   -- 'FishEye' distortion / Fake 3D
   F = (cos((ox-0.5)*pi)*cos((oy-0.5)*pi))*0.65;
   ox = ox - (ox-0.5)*F; 
   oy = oy - (oy-0.5)*F; 

   -- Checkers
   V = ((floor(0.25+ox*10)+floor(1+oy*10)) % 2) * 255 * W;

   -- Specularities
   SPEC1 = max(0,(1-5*sqrt((ox-0.45)*(ox-0.45)+(oy-0.45)*(oy-0.45)))*112);
   SPEC2 = max(0,(1-15*sqrt((ox-0.49)*(ox-0.49)+(oy-0.48)*(oy-0.48)))*255);

   r = W * 255 + SPEC1 + SPEC2
   g = V + SPEC1 + SPEC2
   b = V + SPEC1 + SPEC2

   putbrushpixel(x, y, matchcolor(r,g,b));

  end
end
