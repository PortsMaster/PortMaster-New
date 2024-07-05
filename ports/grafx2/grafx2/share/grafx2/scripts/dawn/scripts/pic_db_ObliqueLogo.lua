--PICTURE: Oblique GrafX2 Logo V1.1 (Now animated)
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")
--> db.obliqueCube

a = {}

a[1] = {1,1,1,1,0, 1,1,1,1,0, 1,1,1,1,0, 1,1,1,1,0, 1,0,0,1}
a[2] = {1,0,0,0,0, 1,0,0,1,0, 1,0,0,1,0, 1,0,0,0,0, 1,0,0,1}
a[3] = {1,0,1,1,0, 1,1,1,0,0, 1,1,1,1,0, 1,1,1,0,0, 0,1,1,0}
a[4] = {1,0,0,1,0, 1,0,0,1,0, 1,0,0,1,0, 1,0,0,0,0, 1,0,0,1}
a[5] = {1,1,1,1,0, 1,0,0,1,0, 1,0,0,1,0, 1,0,0,0,0, 1,0,0,1}

w,h = getpicturesize()

side = 12
depth = 3
 --_width  = (#a[1] + depth/2) 
 --_height = (#a    + depth/2) 
 _width  = (#a[1] + depth/2)
 _height = (#a    + depth/2) 

 qw = w / _width
 qh = h / _height
 side = math.floor(math.min(qw,qh)) 
--messagebox(_width..", "..side)

xx = (w - _width  * side) / 2
yy = (h - _height * side) / 2

r = 255
g = 128
b = 255
bri = 96
spc = side
zspc = math.floor(side / 2)

cols = -1 -- set to -1 if not used
for z = 1, depth, 1 do
 for y = #a, 1, -1 do
  for x = 1, #a[y], 1 do

  zf = (4-z) * 38 - 20

 if a[y][x] == 1 then
  cols = db.obliqueCube(side,xx+x*spc-(z-1)*zspc, yy+(y-1)*spc+z*zspc, 188 - zf + math.sin(x/3+20)*100 - y*8, 80 + 144 / 5 * y - zf, 48+200/25 * x - zf + y*8,bri,cols)
 end

   updatescreen(); if (waitbreak(0)==1) then return; end
  end
 end
end