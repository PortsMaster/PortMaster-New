--PALETTE: Fade Palette to a Color V1.0
--by Richard Fhager


OK,ra,ga,ba,AMT,GAMMA = inputbox("Fade Palette to Color",
   "  Red: 0-255", 127, 0,255,0,
   "Green: 0-255", 127, 0,255,0,
   " Blue: 0-255", 127, 0,255,0,
   "AMOUNT %", 80, 0,100,0,
   "Gamma: 0.1-5.0", 1.0, 0.1,5,2           
);

--
if OK then

 amt = AMT / 100
 rmt = 1 - amt

 gam = GAMMA
 rgm = 1 / gam

 for n = 0, 255, 1 do

  r,g,b = getcolor(n)

  rn = (ra^gam * amt + r^gam * rmt)^rgm
  gn = (ga^gam * amt + g^gam * rmt)^rgm
  bn = (ba^gam * amt + b^gam * rmt)^rgm

  setcolor(n,rn,gn,bn)

 end


end -- OK
--