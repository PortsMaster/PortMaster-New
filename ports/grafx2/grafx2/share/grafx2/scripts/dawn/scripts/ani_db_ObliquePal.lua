--ANIM: Oblique Pal Cubes V1.5
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")

--setpicturesize(500,300)
clearpicture(matchcolor(0,0,0))

w,h = getpicturesize()

s = math.floor(math.min(w/2,h) / (16*1.5))

SIDE = s 
OFX = 16 * s/2
OFY = math.floor(1 + (h - s*16*1.5)/2)
SPC = SIDE
BRI = 100
STEP = 1

--
function draw(side,xx,yy,spc,bri,step, rev_flag)

 local x,y,z,r,g,b,czspc

zspc = math.floor(side / 2) 

for z = 0, 15, step do
 for y = 15, 0, -step do
  for x = 0, 15, step do

   if rev_flag then
    c = matchcolor((15-x)*16,y*16,(15-z)*16)
     else 
      c = matchcolor(x*16,(15-y)*16,z*16)
   end

   r,g,b = getcolor(c)

   db.obliqueCube(side,xx+x*spc-z*zspc,yy+y*spc+z*zspc,r,g,b,bri,-1)

  end
   updatescreen();if (waitbreak(0)==1) then return end
 end
end

end
--

draw(SIDE,OFX,OFY,SPC,BRI,STEP, false)
draw(SIDE,OFX+SIDE*(16+8),OFY,SPC,BRI,STEP, true)

