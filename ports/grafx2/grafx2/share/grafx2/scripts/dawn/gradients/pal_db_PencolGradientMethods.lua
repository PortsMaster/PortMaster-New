--PALETTE: Gradients from Pen-cols V1.1
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")


 FC = getforecolor()
 BC = getbackcolor()

 if FC > BC then FC,BC = BC,FC; end

 cols = math.abs(FC - BC)

 r0,g0,b0 = getcolor(FC)
 r1,g1,b1 = getcolor(BC)

 first = FC

 t = "- ["..r0..","..g0..","..b0.."] to ["..r1..","..g1..","..b1.."] -"

OK,dummy,m_normal,m_bricorr,m_gamma,m_gamgrad,m_gammin,m_gamprod,m_mult, gam = inputbox("Palette Gradient (#"..FC.." - #"..BC..")",
                      
                           t, 0,0,0,4,
                       
                           "1. Normal/Linear",          0,  0,1,-1,  
                           "2. Brightness Corrected",   1,  0,1,-1, 
                           "3. Gamma Adjusted*",        0,  0,1,-1, 
                           "4. Gamma Gradient*",        0,  0,1,-1,
                           "5. Gamma Minimum*",         0,  0,1,-1,
                           "6. Gamma Min-Product*",     0,  0,1,-1,
                           "7. Exponential (No 0's)",   0,  0,1,-1,  
 
                           "*Gamma: 0.5-3.0",  1.6, 0.5,3.0,2                     
);


--
if OK then

bri0 = db.getBrightness(r0,g0,b0)
bri1 = db.getBrightness(r1,g1,b1)

dif0 = (math.max(r0,g0,b0) - math.min(r0,g0,b0))/255 
dif1 = (math.max(r1,g1,b1) - math.min(r1,g1,b1))/255 
min_dif = math.min(dif0,dif1)


rm = (math.max(1,r1) / math.max(1,r0))^(1/cols)
gm = (math.max(1,g1) / math.max(1,g0))^(1/cols)
bm = (math.max(1,b1) / math.max(1,b0))^(1/cols)

function rup(v)
 return math.ceil(v * 10000) * 0.0001
end

for n = 0, cols, 1 do

 f1 = n/cols
 f0 = 1 - f1

 if m_bricorr == 1 then
  r,g,b = db.getGradientCol_BriCorr(r0,g0,b0,r1,g1,b1, f1, bri0,bri1)
 end

 if m_normal == 1 then
  r,g,b = db.getGradientCol_Linear(r0,g0,b0,r1,g1,b1, f1)
 end

 if m_gamma == 1 then
  r,g,b = db.getGradientCol_Gamma(r0,g0,b0,r1,g1,b1, f1, gam)
 end

 if m_gamgrad == 1 then
  r,g,b = db.getGradientCol_GammaGradient(r0,g0,b0,r1,g1,b1,f1, gam, dif0,dif1)
 end

 if m_gammin == 1 then
  r,g,b = db.getGradientCol_GammaMin(r0,g0,b0,r1,g1,b1, f1, gam, min_dif)
 end

 if m_gamprod == 1 then
  r,g,b = db.getGradientCol_GammaMinProduct(r0,g0,b0,r1,g1,b1,f1, gam, dif0,dif1)
 end

 if m_mult == 1 then
  --r = math.ceil(math.max(1,r0) * rm^n * 1000) * 0.001 
  r = math.max(1,r0) * rup(rm^n) -- round up / avoid erratic downrounding from exponent precision loss
  g = math.max(1,g0) * rup(gm^n) 
  b = math.max(1,b0) * rup(bm^n)
  --r = math.max(1,r1) / rup(rm^n) -- round up / avoid erratic downrounding from exponent precision loss
  --g = math.max(1,g1) / rup(gm^n) 
  --b = math.max(1,b1) / rup(bm^n)
 end

 setcolor(n+first,r,g,b)

end

end -- ok
--