--ANIM: Iso Train V1.21
--by Richard 'DawnBringer' Fhager


-- V1.21 some speed optimizations


dofile("../libs/dawnbringer_lib.lua")


setpicturesize(512,320)
setcolor(1,88,88,88)
setcolor(2,80,80,80)
setcolor(3,112,144,192)
setcolor(4,192,128,128)

draw_bkg = true

iso_size = 16

w, h = getpicturesize()

-- Grid
--S = iso_size
--fc = getforecolor()
--bc = getbackcolor()
--fc = 2
--bc = 1
--for y = 0, h - 1, 1 do
--  for x = 0, w - 1, 1 do
--    v = math.floor((x/2+y+S/2) % S) * math.floor((x/2-y+S/2) % S) -- Isometric
--    c = fc
--    if v > 0 then c = bc; end
--    if not(c==bc and bg==0) then putpicturepixel(x, y, c); end;
--  end
--end


line = drawline -- db.line

-- Projection
pX = 1.0
pY = 0.5

-- Settings
ofx = 256.5
ofy = 168.5
radius = 10.5
r1 = radius * iso_size / pY / math.sqrt(2)
st = 24

--train = {{-1,-1},{1,-1},{1,1},{-1,1},  {-1,-1}}
train = {{-2,-1},{2,-1},{2,1},{-2,1},  {-2,-1}}
toffang = 45 
tsz = 8 -- 16*32

mf = math.floor
msin = math.sin
mcos = math.cos

frames = 360

r1px = r1 * pX
r1py = r1 * pY

for cycles = 0, 10, 1 do
for anim = 0, frames, 1 do -- (+1 is played)

clearpicture(1)

if draw_bkg then

for x = iso_size, w - 1, iso_size*2 do
 line(x,0,w,(w-x)/2,2)
 line(x,h,w,x/2+iso_size*4,2) -- dunno why 4, haven't got the exact formula yet
end

for y = iso_size/2, h - 1, iso_size do
 line(0,y,w,y+w/2,2)
 line(0,y,y*2,0,2)
end

end


for n = 0,st-1,1 do

 vink = 360/st*n + 90/frames * anim

 ang = math.rad(vink)

 ox1 = x1
 oy1 = y1
 x1 = mf( ofx + mcos(ang) * r1px ) -- Swapped cos/sin since db-lib rotation direction change
 y1 = mf( ofy + msin(ang) * r1py )


 line(ofx,ofy,x1,y1,4)
 --db.lineTranspAAgamma(ofx,ofy,x1,y1, 255,144,144, 0.65, 1.6)

 
 -- Trains
 for t = 1, #train, 1 do
  dx = train[t][1] * tsz
  dy = train[t][2] * tsz

  -- Rotation 
  tx,ty = db.rotationFrac(vink+toffang,0,0,dx,dy)

  -- Projection
  ptx = mf( x1 + tx*pX - ty*pX )
  pty = mf( y1 + ty*pY + tx*pY )


   if t > 1 then
    line(otx,oty,ptx,pty,3)
    --db.lineTranspAAgamma(otx,oty,ptx,pty, 176,208,255, 0.5, 1.6)

   end
  otx = ptx
  oty = pty
 end
 -- trains 

end

  updatescreen()
  if (waitbreak(0)==1) then
    return
  end

end -- anim
end -- cycles
