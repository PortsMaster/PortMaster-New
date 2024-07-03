--PICTURE: Ordered Radial PenCol Gradients V1.0
--by Richard 'DawnBringer' Fhager

-- Will create a perfectly dithered Ordered gradient using the palette colors between the Pen-colors (2-256)
--

dofile("../libs/dawnbringer_lib.lua")


 FC = getforecolor()
 BC = getbackcolor()

 if FC < BC then FC,BC = BC,FC; end
 cols = math.abs(FC - BC) + 1



 OK,Dummy,RADC,RADE,DIAM,SPHR,PILL,CORN,DITHER = inputbox("Radial Dither Gradients",
                           "-- Uses PenColor Range --",0,0,0,-2,
                           "1. Radial (corner)",      1,  0,1,-1,
                           "2. Radial (edge)",        0,  0,1,-1,
                           "3. Diamond",       0,  0,1,-1,
                           "4. Sphere",        0,  0,1,-1,
                           "5. Pillow",        0,  0,1,-1,
                           "6. Corner",        0,  0,1,-1,
                           "Dither: 0-3 (0 = none)",  3,  0,4,0    
                           --"Gamma Correction*",    1,  0,1,0,
                        
                                                                           
 );


--
if OK then

  w,h = getpicturesize()

   if RADC == 1 then
    function f(x,y,w,h) -- Radial
     local p,xf,yf,r
     xf = x / (w-1)
     yf = y / (h-1)
     p = 1 - (2*((0.5 - xf)^2 + (0.5 - yf)^2))^0.5 -- Radial to corners
     return p
    end
   end

   if RADE == 1 then
    function f(x,y,w,h) -- Radial
     local p,xf,yf,r
     xf = x / (w-1)
     yf = y / (h-1)
     p = 1 - math.min(1,((0.5 - xf)^2 + (0.5 - yf)^2)^0.5 * 2) -- Radial to edges
     return p
    end
   end

   if DIAM == 1 then
    function f(x,y,w,h) -- Radial/Diagonal
     local p,xf,yf,r
     xf = x / (w-1)
     yf = y / (h-1)
     p = 1 - (math.abs(0.5 - xf) +  math.abs(0.5 - yf)) -- Diamond to corners
     return p
    end
   end

   if SPHR == 1 then
    function f(x,y,w,h) -- Radial
     local p,xf,yf,r
     xf = x / (w-1)
     yf = y / (h-1)
     r = 0.5; p = math.max(0,(r*r - ((xf-0.5)^2 + (yf-0.5)^2)))^0.5 * 1/r -- Sphere
     return p
    end
   end

   if PILL == 1 then
    function f(x,y,w,h) -- Radial
     local p,xf,yf,r
     xf = x / (w-1)
     yf = y / (h-1)
     p = math.sin(xf*math.pi)*math.sin(yf*math.pi) -- SinusSquareBall, very similar to pillow (1-xf)*(xf*yf*16)*(1-yf)
     return p
    end
   end

   if CORN == 1 then
    function f(x,y,w,h) -- Radial, Corner
     local p,xf,yf,r
     xf = x / (w-1)
     yf = y / (h-1)
     p = math.sin(xf*math.pi*0.5)*math.sin(yf*math.pi*0.5) -- SinusSquareBall (very similar to Bend/Corner, but more filling)
     return p
    end
   end


     --p = xf*yf -- Bend/Corner 

     -- --p = (0.5-math.abs(0.5-xf))*(0.5-math.abs(0.5-yf))*4 -- "StarBend" (lesser pillow)


     --p = (1-xf)*(xf*yf*16)*(1-yf) -- Pillow

    

   
    




 
  
   --

  start_index = BC
  end_index   = FC
  dith_f      = db.dithOrderNONE_frac
  if DITHER == 1 then dith_f = db.dithOrder2x2_frac; end
  if DITHER == 2 then dith_f = db.dithOrder4x4_frac; end
  if DITHER == 3 then dith_f = db.dithOrder8x8_frac; end
 
  --dith_f = db.dithScanline8

  db.gradientRender(f, w,h,start_index, end_index, dith_f) 
  --db.gradientRender(f, w-64,h-40,start_index, end_index, dith_f, 48,32) 
 

end -- OK
--











--[[

   --power = x / (w-1) -- Horizontal
   --power = y / (h-1) -- vertical
   --power = (x+y)/(w+h-2) -- 45 degrees
   --power = 0.5 + math.sin(x/10)*math.cos(y/10) * 0.5
   --power =  (y / (h-1)) * x/(w-1) + (x / (w-1)) * (1-(x/(w-1))) -- X-grad to Y-grad across x

   -- X-grad to Y-grad across X to Diagonal across Y
   function fancy(x,y,w,h) 
     return ((x+y)/(w+h-2)) * (y/(h-1)) + ((y / (h-1)) * x/(w-1) + (x / (w-1)) * (1-(x/(w-1)))) * (1-(y/(h-1))) 
   end

   function bend(x,y,w,h)
    return (x*y)/(w*h) -- (x/w)*(y/h)
   end

--]]