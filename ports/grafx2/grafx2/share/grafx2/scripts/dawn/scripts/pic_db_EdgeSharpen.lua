--PICTURE: Edge Sharpen (Maxima/Minima)
--by Richard 'DawnBringer' Fhager

 dofile("../libs/dawnbringer_lib.lua")

-- Brired: Brightness reduction (minima) / Gamma adjust
function main(Power,Exp,Brired,Amount)
 local x,y,W,H,r0,g0,b0,out_r,out_g,out_b,rf,gf,bf,amtr
 local rmax,gmax,bmax,rmin,gmin,bmin,rdif,gdif,bdif,_Mult,_Pmult
 local Max,Min

 Max,Min = math.max,math.min

 amtr = 1 - Amount

 W,H = getpicturesize()

   _Mult = 255 / 255^Exp  -- Normalize
   _Pmult = Power * _Mult -- Combine Power and Normalizer to one value

 for y = 0, H-1, 1 do
  for x = 0, W-1, 1 do
  
   r0,g0,b0 = getbackupcolor(getbackuppixel(x,y))

   rmax,gmax,bmax,rmin,gmin,bmin = db.effectMaxMinRGB3x3(x,y,W,H,r0,g0,b0,Exp,_Pmult,Brired)

   ----[[
   -- Sharpen
   rdif = Min(255, Max(0,r0+(rmax-rmin)))
   gdif = Min(255, Max(0,g0+(gmax-gmin)))
   bdif = Min(255, Max(0,b0+(bmax-bmin)))
   out_r, out_g, out_b = rdif,gdif,bdif  
   --]]


   --[[
   -- Diff (Sharpening mask)
   rdif = Min(255, Max(0,127+(rmax-rmin)))
   gdif = Min(255, Max(0,127+(gmax-gmin)))
   bdif = Min(255, Max(0,127+(bmax-bmin)))
   out_r, out_g, out_b = rdif,gdif,bdif  
   --]] 

   rf = out_r * Amount + r0*amtr
   gf = out_g * Amount + g0*amtr
   bf = out_b * Amount + b0*amtr
   i = matchcolor(rf, gf, bf)
   putpicturepixel(x,y,i)

 end; -- x
  
  if db.donemeter(10,y,W,H,true) then return; end

 end; -- y

end
-- main


Power  = 1.0  -- 0.25/0.6(sharpen all), 1/1.6, 3/2.5
Exp    = 1.6
Brired = 0.7
Amount = 1.0

OK,dummy1,dummy2,Exp,str,bred = inputbox("Image Sharpen Edges",
           
   "-- Higher Exponent results in  --",   0,0,0,4,
   "-- less effect on weaker edges --",   0,0,0,4,               
   "Precision Exp.: 0.5-3.0",   Exp,0.5,3.0,3,
   "Strength %: 1-999",         Power*100,0,999,0,
   "Bright Edge Reduction %",   (1-Brired)*100,0,100,0                       
   --"AMOUNT %",       100,  0,100,0    
);

if OK then

 Power = str / 100 
 Brired = (100-bred) / 100

 --t1 = os.clock()
 main(Power, Exp, Brired, Amount)
 --messagebox("Seconds: "..(os.clock() - t1))

end -- ok








