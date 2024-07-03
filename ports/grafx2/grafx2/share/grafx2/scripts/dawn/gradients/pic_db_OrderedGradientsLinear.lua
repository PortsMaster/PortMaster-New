--PICTURE: Ordered Gradients from PenCols V1.0
--by Richard 'DawnBringer' Fhager

-- Will create a perfectly dithered Ordered gradient using the palette colors between the Pen-colors (2-256)
--

dofile("../libs/dawnbringer_lib.lua")


 FC = getforecolor()
 BC = getbackcolor()

 if FC < BC then FC,BC = BC,FC; end
 cols = math.abs(FC - BC) + 1



 OK,Dummy,HOR,VER,D45,DIA,CUS,Xrat,Yrat,DITHER = inputbox("Linear Dither Gradients",
                           "-- Uses PenColor Range --",0,0,0,-2,
                           "1. Horizontal",      1,  0,1,-1,
                           "2. Vertical",        0,  0,1,-1,
                           "3. 45 Degrees",      0,  0,1,-1,
                           "4. Diagonal",        0,  0,1,-1,
                           "5. Custom Ratio *",  0,  0,1,-1,
                           "* X-Ratio: 0.01-1.0",      1,  0.01,1,2,
                           "* Y-Ratio: 0.01-1.0",   0.25,  0.01,1,2,
                           "Dither: 0-3 (0 = none)",  3,  0,4,0    
                           --"Gamma Correction*",    1,  0,1,0,
                        
                                                                           
 );


--
if OK then

  w,h = getpicturesize()

   if HOR == 1 then
    function f(x,y,w,h) -- Horizontal Gradient, same as a=1,b=0 in loadstring
     return x / (w-1)
    end
   end

   if VER == 1 then
    function f(x,y,w,h) -- Vertical Gradient
     return y / (h-1)
    end
   end
 
   if D45 == 1 then
    function f(x,y,w,h)
     return (x+y)/(w+h-2) -- 45 degrees
    end
   end


  -- "Eval" function, dynamically created function ([1,0] = Horizontal, [0,1] = Vertical, [1,1] = 45 degrees)
  -- [1, h/w] -- Horizontal diagonal (width is greater than height), [w/h,1] -- Vertical diagonal (height is greater than width)
  function makeLoadString(a,b)
   local XM,YM
   XM = ""..a
   YM = ""..b
   return loadstring("return (function(x,y,w,h)return (x*"..XM.."+y*"..YM..")/((w-1)*"..XM.."+(h-1)*"..YM..");end)")
  end

   if DIA == 1 then
    if w>=h then
     a = w/h
     b = 1 
    end
    if w<h then
     a = 1
     b = h/w 
    end
    f = makeLoadString(a,b)() -- Compile into function
   end 


   if CUS == 1 then
    a = Xrat
    b = Yrat
    f = makeLoadString(a,b)() -- Compile into function
   end 


  
   --

  start_index = BC
  end_index   = FC
  dith_f      = db.dithOrderNONE_frac
  if DITHER == 1 then dith_f = db.dithOrder2x2_frac; end
  if DITHER == 2 then dith_f = db.dithOrder4x4_frac; end
  if DITHER == 3 then dith_f = db.dithOrder8x8_frac; end
  if DITHER == 4 then dith_f = db.dithTest8x8; end
 
  --dith_f = db.dithScanline8

  db.gradientRender(f, w,h,start_index, end_index, dith_f) 
  --db.gradientRender(f, w-64,h-40,start_index, end_index, dith_f, 48,32) 
 

end -- OK
--


--main(BC, FC, db.dithOrder2x2_frac)
--main(BC, FC, db.dithOrderNONE_frac) 
--main(BC, FC, db.dithOrder4x4_frac)  
--main(BC, FC, db.dithOrder8x8_frac) 















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