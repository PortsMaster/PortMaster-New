--ANIM: Oblique Menger Sponge
--by Richard 'DawnBringer' Fhager

--
function main(levels,contrast, base_bri,y_bri,z_bri, rand)

   levels = levels or 3
 contrast = contrast or 112
 base_bri = base_bri or 64
    y_bri = y_bri or 48
    z_bri = z_bri or 96
     rand = rand or 3

 --setpicturesize(500,300)
 clearpicture(matchcolor(0,0,0))


 local w,h,n,x,y,z,d,a,f,r,g,b,v,xd,yd,zd,floor,abs,rnd,siz_x,siz_y,sideblocks,draw,SIDE,OFX,OFY,ABORT,RANDOMNESS
 local separation,spc,zspc
 local blocks, UPDATE,COUNT
 local sponge

 floor = math.floor
 abs = math.abs
 rnd = math.random

 w,h = getpicturesize()

 -- Default randomness = 0.04
 RANDOMNESS = rand / 75

 sideblocks = 3^levels
 blocks = 27^levels
 UPDATE = math.max(1, floor(blocks^0.5 * 2)) -- 0.01*levels^4

 d = h; if h>w then d = w; end

 SIDE = floor(d*0.66 / sideblocks)
 SIDE = floor(SIDE/2)*2 -- Keep size even, Odd sizes looks a bit weird
 OFX = floor(w/2 - (sideblocks * SIDE * 0.5)/2 - SIDE/2)
 OFY = (SIDE + h - (sideblocks * SIDE * 1.5)) / 2	

 separation = 0
 spc = SIDE + separation
 zspc = floor(SIDE / 2)+separation 


 f = 1 / sideblocks

--
function sponge(xx,yy,zz,i,max_i)
 local x,y,z,v,a,cx,cy,cz,ay,azy

 if not ABORT then

  for y = 1, -1, -1 do
   ay = abs(y)
   cy = 1+yy*3+y
   for z = -1, 1, 1 do
    azy = abs(z) + ay
    cz = 1+zz*3+z
    for x = -1, 1, 1 do

     if not((abs(x) + azy) <= 1) then 

      cx = 1+xx*3+x -- Make 0-2 to work with the old non-recursive offsets

      if i < max_i then 
       sponge(cx,cy,cz,i+1,max_i)
        else
         v = base_bri + f*cz*z_bri + f*(sideblocks-cy)*y_bri
         a = (1+(rnd()*2-0.5)*RANDOMNESS) * v
         db.obliqueCube(SIDE,OFX+cx*spc-cz*zspc,OFY+cy*spc+cz*zspc,a,a,a,contrast,-1)
         COUNT = COUNT + 1
         if COUNT % UPDATE == 0 then updatescreen();if (waitbreak(0)==1) then ABORT = true; return end; end
      end
    end
 
   end;end;end
 end
end
--

COUNT = 0
ABORT = false
if levels > 0 then
 sponge(0,0,0, 1,levels)
 else
 v = base_bri + z_bri*0.5 + y_bri*0.5
 sideblocks = sideblocks - 1
 db.obliqueCube(SIDE,OFX+sideblocks*spc-sideblocks*zspc,OFY+sideblocks*spc+sideblocks*zspc,v,v,v,contrast,-1)
end


end
-- eof main


dofile("../libs/dawnbringer_lib.lua")


LEVELS   = 3  -- 0-5
CONTRAST = 112  -- 0-255
BASE_BRI = 64   -- Base Brightness (max 255)
   Y_BRI = 96   -- Brightness change across Y (height)
   Z_BRI = 48   -- Brightness change across Z (dpeth)
RAND_BRI = 3    -- Brightness/Texture Randomness Level 0-10
  SETPAL = 1



OK,LEVELS,CONTRAST,BASE_BRI,Y_BRI,Z_BRI,RAND_BRI,SETPAL = inputbox("Menger Sponge Fractal (Oblique)",                                                           
                          
                           "ITERATIONS: 0-5", LEVELS,  0, 5,0,
                           "Contrast: 0-255", CONTRAST,  0, 255,0,
                           "Base Brightness", BASE_BRI,  -128, 255,0,
                           "Bri Change Over Y", Y_BRI,  -255, 255,0,
                           "Bri Change Over Z", Z_BRI,  -255, 255,0,
                           "Bri Randomness: 0-10", RAND_BRI,  0, 10,0,
                           "Set Gradient Palette",  SETPAL,  0,1,0  
                                                                                             
);


if OK then

 --
 if SETPAL == 1 then

  -- Make grayshade palette with a nice tint 
  -- db.Oblique uses colormatching and Sponge sets grayscale values, but this is close enough to grayscale to work nicely
  rgb0 = {0,0,0}
  rgb1 = {53,66,78}
  rgb2 = {127,127,127}
  start_index = 0
  cols = 128
  db.setTriRamp(rgb0,rgb1,rgb2, cols, start_index)

  rgb0 = {128,128,128}
  rgb1 = {190,198,166}
  rgb2 = {255,255,248}
  start_index = 128
  cols = 128
  db.setTriRamp(rgb0,rgb1,rgb2, cols, start_index)

 end
 --

 t1 = os.clock()
 main(LEVELS, CONTRAST, BASE_BRI, Y_BRI, Z_BRI, RAND_BRI)
 t2 = os.clock()
 ts = (t2 - t1) 
 --messagebox("Seconds: "..ts)

end


