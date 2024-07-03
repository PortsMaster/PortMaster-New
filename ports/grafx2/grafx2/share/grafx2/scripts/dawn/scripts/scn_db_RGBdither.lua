--SCENE: RGB-dither Remapping V1.1 (TB4.0)
--by Richard 'DawnBringer' Fhager 

-- Remaps current image with spare palette.
-- Scanline + horizontal alternating RGB dither, with optional horizontal error-diffusion.
-- Brightness preservation allows for truer image representation than classic dither metods (which usually become to bright).
-- A number of "basic" methods that together can produce very good results, perhaps better than most existing dithers.
--
-- Using max value (870) on X-dither allows for pure RGB dither in CRT-monitor fashion (that is; alternating Red, Green and Blue colors.)

dofile("../libs/dawnbringer_lib.lua")

--
function main()

 local OK,quick,y_lev,rgb_lev,x_diff,bri_corr,r_bal,g_bal,b_bal,briweight
 local x,y,c,q,m,w,h,r1,g1,b1,rd,gd,bd,rn,gn,bn,bri,drk,ydith,xdiff,briw
 local line,lx,red,grn,blu,rgb,pal


OK,quick,y_lev,rgb_lev,x_diff,bri_corr,r_bal,g_bal,b_bal,briweight = inputbox("RGB-Dither Remapping",                                        
                      
                           "FAST: HARD DITHER 48-64-8",  0,  0,1,0,  
                           "Y-Dither Level*: 0-128", 24,  0, 128,0,
                           "RGB X-Dither Lev*: 0-870", 48,  0, 2000,0,
                           "Err. Diffusion Pow.: 0-9", 0,  0, 9,0,
                           "*Brightness Correction",  1,  0,1,0,  
                           "Red Balance: -255..255", 0,  -255, 255,0,
                           "Grn Balance: -255..255", 0,  -255, 255,0,
                           "Blu Balance: -255..255", 0,  -255, 255,0,
                           "ColMatch Bri-Weight %", 25,  0,100,0 
                          
                                              
);

if OK == true then

briw = briweight / 100

w, h = getpicturesize()

red,grn,blu = {},{},{}
for c = 0, 255, 1 do
 r,g,b = getbackupcolor(c)
 red[c+1] = r 
 grn[c+1] = g 
 blu[c+1] = b 
end

pal = db.fixPalette(db.makeSparePalList(256))

for c = 0, 255, 1 do
 setcolor(c,getsparecolor(c))
end


-- Good for 8 primaries: 64-48-(3/5)
--                       32-64-(6/9)
-- RGB-dither (only R,G,B ranges): 0-870-1

if quick == 1 then 
 y_lev   = 48
 rgb_lev = 64
 x_diff  = 8
 --r_bal,g_bal,b_bal = -4,-4,-4
end


rgb = {1,0,0}
xdiff = x_diff / 10 -- x diffusion 0..0.9

line = {}
for x = 1, w, 1 do
 line[x] = {0,0,0}
end


for y = 0, h - 1, 1 do

  rd,gd,bd = 0,0,0
  --line = y%2 -- 0 = Black, 1 = white

   --ydith = y%2 * y_lev - y_lev/2
   -- Correct for exponential brightness
   --ydith = (math.sqrt(y%2 * y_lev) - math.sqrt(y_lev/2)) * y_lev^0.5 -- 
   -- -sqrt(x/2) * sqrt(x) = -0.707 * x
   -- (sqrt(x) - sqrt(x/2)) * sqrt(x) = x - 1/sqrt(2) * x  = x - 0.707*x  = x * (1 - 0.707)  = x * 0.293 
   -- same as:  ydith = y_lev * (y%2 - 0.707)

   if bri_corr == 1 then
    ydith = y_lev * ((y+1)%2 - 0.707) -- y+1 to avoid first line odd dither (when scanline+rgb+ed)
    bri = 0.293
    drk = 0.707
     else
      ydith = (y+1)%2 * y_lev - y_lev/2
      bri = 1
      drk = 1
   end

  q = rgb_lev/3 * drk + ydith
  m = rgb_lev * bri 
  for x = 0, w - 1, 1 do
   --xb = (x+math.floor(y/2))%2 * xbri
   --xb = x%2 * xbri
    
   c = 1 + getbackuppixel(x,y)
   --r,g,b = getbackupcolor(getbackuppixel(x,y))
   lx = line[1+x]
   r1 = red[c] + rgb[1+(x+y)%3]   * m - q + rd/2 + lx[1] + r_bal
   g1 = grn[c] + rgb[1+(x+1+y)%3] * m - q + gd/2 + lx[2] + g_bal
   b1 = blu[c] + rgb[1+(x+2+y)%3] * m - q + bd/2 + lx[3] + b_bal

   --c = matchcolor2(db.cap(r1), db.cap(g1), db.cap(b1), briw)
   c = db.getBestPalMatchHYBRID({db.cap(r1),db.cap(g1),db.cap(b1)},pal,briw,true)

   -- ED
   if xdiff > 0 then
     rn,gn,bn = getcolor(c)
     rd = (r1 - rn)*xdiff
     gd = (g1 - gn)*xdiff
     bd = (b1 - bn)*xdiff
     line[1+x] = {rd*0.3125,gd*0.3125,bd*0.3125} -- 5/16 = 0.3125
     if x>0 then
      lx = line[x]
      line[x] = {lx[1]+rd*0.1875,lx[2]+gd*0.1875,lx[3]+bd*0.1875} -- 3/16 = 0.1875
     end
   end
   --

   putpicturepixel(x, y, c);

  end

  --updatescreen(); if (waitbreak(0)==1) then return; end
 if db.donemeter(8,y,w,h,true) then return; end

end

end -- ok

end -- main

main()



