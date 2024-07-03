--PICTURE: Maxima/Minima Edge Detection
--by Richard 'DawnBringer' Fhager

 dofile("../libs/dawnbringer_lib.lua")

-- Brired: Brightness reduction (minima) / Gamma adjust
function main(Power,Exp,Brired,Amount, Mode)
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

   if Mode == "maxima" then
    out_r, out_g, out_b = rmax,gmax,bmax  
   end

   if Mode == "minima" then
    out_r, out_g, out_b = rmin,gmin,bmin  
   end

   if Mode == "diff" then
    -- Diff (Sharpening mask)
    rdif = Min(255, Max(0,127+(rmax-rmin)))
    gdif = Min(255, Max(0,127+(gmax-gmin)))
    bdif = Min(255, Max(0,127+(bmax-bmin)))
    out_r, out_g, out_b = rdif,gdif,bdif  
   end  


   rf = out_r * Amount + r0*amtr
   gf = out_g * Amount + g0*amtr
   bf = out_b * Amount + b0*amtr
   i = matchcolor(rf, gf, bf)
   --i = matchcolor(r0+(out_r-255)*Amount, g0+(out_g-255)*Amount, b0+(out_b-255)*Amount) -- Add Outline
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

OK,max,min,dif,gray,Exp,str,bred,amt = inputbox("Max/Min Edge Detection",
  
   "1. Maxima           ",  1,  0,1,-1,
   "2. Minima           ",  0,  0,1,-1,
   "3. Diff (sharp mask) *",  0,  0,1,-1,
   "Make Image Grayscale", 1, 0,1,0,               
   "Precision Exp.: 0.5-3.0",   Exp,0.5,3.0,3, -- Higher Exponent results in less effect on weaker edges 
   "Strength %: 1-999",   Power*100,0,999,0,
   "*Bright Edge Reduction %",   (1-Brired)*100,0,100,0,                       
   "AMOUNT %",       100,  0,100,0    
);

if OK then

 Amount = amt / 100
 Power = str / 100

 Mode = "maxima"
 if min == 1 then Mode = "minima"; end

 Brired = 1.0 -- No reduction in min, just dif
 if dif == 1 then 
   Mode = "diff";
   Brired = (100-bred) / 100 
 end
 
 if gray == 1 then
  db.setGrayscaleAndRemap()
  finalizepicture()
 end

 --t1 = os.clock()
 main(Power, Exp, Brired, Amount, Mode)
 --messagebox("Seconds: "..(os.clock() - t1))

end -- ok








