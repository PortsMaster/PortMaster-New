--BRUSH Scene: Sphere of PenColors V2.1
--by Richard Fhager 



w, h = getbrushsize()

rf,gf,bf = getcolor(getforecolor())
rb,gb,bb = getcolor(getbackcolor())

mx = math.max

-- Sphere
X = 0.5; Y = 0.5; Rd = 0.5; iR = 1 / Rd; Rd2 = Rd*Rd 

for y = 0, h - 1, 1 do

  oy = y / h; -- Fractionalize image dimensions
  Yo2 = (Y-oy)*(Y-oy)

  for x = 0, w - 1, 1 do

   ox = x / w;
   
   a = (mx(0,Rd2 - ((X-ox)*(X-ox)+Yo2)))^0.5 * iR
   q = 1-a  

   r = rf * a + rb * q
   g = gf * a + gb * q
   b = bf * a + bb * q

   putbrushpixel(x, y, matchcolor2(r,g,b,0.5));

  end
end
