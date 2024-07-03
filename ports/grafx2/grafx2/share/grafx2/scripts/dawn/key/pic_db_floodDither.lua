--PICTURE: ** Flood-Fill Dither V3.0 **
--Assign script to a KEY
--Mousepointer location selects target
--by Richard 'DawnBringer' Fhager


-- Flood-fills target color area with pencolor checker-dither
-- V3.0 Localized etc. about 70% faster


-- This version uses direct array-handling (no table instructions), with an expanding array
-- and read/end positions for the nodes. Slightly faster than the table.remove for last node version.

--
function main()

 local moved, key, mx, my, mb, ix, iy
 local x,y,w,h,n,px,py,len,pos,count,BG,FC,TC,FREE,MARK,WALL
 local no, node, map, AX, AY
 local newArrayInit2Dim

function newArrayInit2Dim(xs,ys,val) 
  local x,y,ary,aryy; ary = {}
  for y = 1, ys, 1 do
   ary[y] = {}
   aryy = ary[y]
   for x = 1, xs, 1 do
     aryy[x] = val
   end
  end
  return ary
end

moved, key, mx, my, mb, ix, iy = waitinput(0)

w,h = getpicturesize()
BG = getbackcolor()

TC = getpicturepixel(ix,iy)
FC = getforecolor()

if ix < w and iy < h then

--AX = {-1,0,1,-1,1,-1,0,1}
--AY = {-1,-1,-1,0,0,1,1,1}

AX = { 0,-1, 1, 0}
AY = {-1, 0, 0, 1}

MARK = 256
FREE = 257
WALL = BG

-- Use safe border
map = newArrayInit2Dim(w+2,h+2,FREE) 
for x = 1, w+2, 1 do
 map[1][x] = WALL
 map[h+2][x] = WALL
end
for y = 1, h+2, 1 do
 map[y][1] = WALL
 map[y][w+2] = WALL
end

node = {}

-- 1st Node: Pixel under mouse.
node[1] = {ix,iy}
map[iy+2][ix+2] = MARK
if (ix+iy) % 2 == 0 then
  putpicturepixel(ix,iy,FC)
end

t1 = os.clock()

count = 0
len = 1 -- write
pos = 1 -- read
while pos <= len do
 no = node[pos]; pos = pos + 1
 x,y = no[1], no[2]
 for n = 1, 4, 1 do 
  px = x + AX[n]
  py = y + AY[n]
  if map[py+2][px+2] == FREE and getpicturepixel(px,py) == TC then
    len = len + 1; node[len] = {px,py}
    map[py+2][px+2] = MARK
    if (px+py) % 2 == 0 then
     putpicturepixel(px,py,FC)
    end
  end
 end
 if pos%10000==0 then 
  statusmessage("Nodes: "..#node)
  updatescreen();if (waitbreak(0)==1) then return end; 
 end
end

end 

t2 = os.clock()
ts = (t2 - t1) 
--messagebox("Seconds: "..ts)

end
-- main

main()


