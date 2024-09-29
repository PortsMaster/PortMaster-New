--PICTURE: Field Gradient V0.91
--(Interpolate data points)
--by Richard 'DawnBringer' Fhager


dofile("../libs/dawnbringer_lib.lua") 

-- FIELD GRADIENT v0.91
-- Create a gradient between a set of data-points (colors). 
-- The total contribution to a location is normalized; f.ex ([255,0,0] and [0,0,255] both at the same distance will normalize to [127,0,127])
-- The Exponent dictates how the impact of a value/color decreases with distance. 
-- The higher the exponent the more weight is given to the closest color(s), and the result will approach that of a Voronoi-diagram (exp = +9).
-- Exponent: 1 = Linear distance, 2 = Squared etc. Use 1-2 for smooth/blurry results, and +5 for more distinct cells.
--
-- If everything is scaled, the relative contribution from the points are preserved, 
-- which means that scaling a scenario down (moving points closer together in physical space) is the equivalent to increasing
-- the number of points.
--
-- Warning, this script will get very slow with increasing number of points!
--

OK,POINTS,EXPONENT,P_RND,P_IMG,P_HEX,P_READ,RNDCOLS,OMITTANCE = inputbox("Field Gradient v0.91",           
                          
                           "Points: 0-10.000", 50,  2,10000,0,
                           "Sharpness Exponent: 1-32", 4,  1,32,2, -- i.e. Distance fall-off
                          
                           "1. Rnd Points (palette) *",    0,    0,1,-1,  
                           "2. Image Pts (random)",        1,    0,1,-1,
                           "3. Image Pts (hexgrid) #",     0,    0,1,-1, 
                           "4. Get Plots (non BG-col)",    0,    0,1,-1,
                           "* Palette Colors: 2-256",     2,    2,256,0,
                           "# Grid Pts Omittance %", 50, 0,99,0


                           --"Plot Single Pixel Cells", 0, 0,1,0,   

                         
                                                             
);

--
if OK then

 floor = math.floor
 rnd = math.random

w,h = getpicturesize()
BG = getbackcolor()

Exp = EXPONENT -- distance = (xd^2 + yd^2)^(EXPONENT/2), EXPONENT=1 is normal linear distance (that is ^0.5), so 2 is squared distances

points = {}

-- Random points of random RGB-values
if P_RND == 1 then
 clearpicture(0)
 --RNDCOLS = 2
 for n = 1, POINTS, 1 do
  --points[n] = {math.random(0,w-1), math.random(0,h-1), math.random(0,255), math.random(0,255), math.random(0,255)} 
  c = math.random(0,RNDCOLS-1)
  r,g,b = getcolor(c)
  x = math.random(0,w-1)
  y = math.random(0,h-1)
  points[n] = {x,y, r,g,b}
  putpicturepixel(x,y,c) 
 end
end
--

 -- Random image points
if P_IMG == 1 then
  for n = 1, POINTS, 1 do
   x = math.random(0,w-1)
   y = math.random(0,h-1)
   r,g,b = getcolor(getbackuppixel(x,y))
   points[n] = {x,y,r,g,b}
   --putpicturepixel(x,y,matchcolor((points[n][3]+128)%255, (points[n][4]+128)%255,(points[n][5]+128)%255))
  end
end
--

-- Read points (not bg-color)
if P_READ == 1 then
  count = 0
  for y = 0, h-1, 1 do
   for x = 0, w-1, 1 do
     c = getbackuppixel(x,y)
     if c~= BG then
      r,g,b = getcolor(c)
      count=count+1
      if count <= POINTS then 
       points[count] = {x,y,r,g,b}
      end
     end
   end
  end
  if count > POINTS then
   messagebox("Warning!","You tried to read "..count..
              " points!\n\nI only recorded the current maximum of "..POINTS.."."..
              "\n\nMake sure the PEN and Image background-color is one and the same!"..
              "\n\nThe function of this option is to scan an image for a few select pixels that is not the BG-color.")
  end
end
--



-- Grid of image points, hexagonal tiling, randomly omitted points
-- With higher omittance, the step/cellsize will decrease 
-- There's is the effect; that with very high omittance (+90%) the step/point adjustment will start to fail,
-- and the adjusted number of points will approach 200% of the original target.
if P_HEX == 1 then
  --OMITTANCE = 50 -- Percent of skipping cells
  step = math.max(1,math.floor(((w*h)/ (POINTS* 100/(100-OMITTANCE)) )^0.5)) -- Point spacing in grid
  count = 0
  for y = 0, h-1, step do
   ystep = floor(y/step)%2 * step/2
   for x = 0, w-1, step do
    xo = x + ystep
    if rnd(0,99) >= OMITTANCE then -- Skip a few points/cells to break the pattern
     r,g,b = getcolor(getbackuppixel(xo,y))
     count=count+1; points[count] = {xo,y,r,g,b}
    end
   end
  end
end
--



messagebox("Points: "..#points..", Exponent = "..Exp)

if P_RND ~= 1 then
  for n = 1, #points, 1 do
   putpicturepixel(points[n][1], points[n][2], matchcolor((points[n][3]+128)%255, (points[n][4]+128)%255,(points[n][5]+128)%255));
  end
end

--t1 = os.clock()
db.makeFieldGradient(w,h, points, Exp, (function(x,y,r,g,b) putpicturepixel(x, y, matchcolor2(r,g,b));end), true)

--t2 = os.clock()
--ts = (t2 - t1) 
--messagebox("Seconds: "..ts)

end -- OK
