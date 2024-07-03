--BRUSH: ** Magic Brush-Grab **
--Assign script to a KEY
--Mousepointer location selects target
--by Richard 'DawnBringer' Fhager

remove = 0 -- Clear sprite from image

function newArrayInit2Dim(xs,ys,val) 
  local x,y,ary; ary = {}
  for y = 1, ys, 1 do
   ary[y] = {}
   for x = 1, xs, 1 do
     ary[y][x] = val
   end
  end
  return ary
end

moved, key, mx, my, mb, ix, iy = waitinput(0)

w,h = getpicturesize()
BG = getbackcolor()


if ix < w and iy < h then

AX = {-1,0,1,-1,1,-1,0,1}
AY = {-1,-1,-1,0,0,1,1,1}

MARK = 256
FREE = 257
WALL = BG

map = newArrayInit2Dim(w,h,FREE) 

pixels = 0
node = {}
xleft       = -1
xright      = -1
xtop        = -1
xbottom     = -1
--lastnode    = -1
--currnode    =  0

-- 1st Node: Pixel under mouse.
c = getpicturepixel(ix,iy)
if c ~= WALL then
 --lastnode = 1
 --currnode = 1
 --node[lastnode] = {ix,iy}
 table.insert(node,{ix,iy})
 map[iy+1][ix+1] = MARK
 xleft       = ix
 xright      = ix
 xtop        = iy
 xbottom     = iy
 pixels = pixels + 1
end


while #node > 0 do
 --no = node[currnode]
 -- removing the last node may produce a very high node-count, but is still faster due to that
 -- lua doesn't have to re-arrange the array [table.remove(node,1) would remove the first] 
 no = table.remove(node) 
 x = no[1]
 y = no[2]
 for n = 1, 8, 1 do
  px = x + AX[n]
  py = y + AY[n]
  if px>=0 and px<w and py>=0 and py<h then
  if map[py+1][px+1] == FREE and getpicturepixel(px,py) ~= WALL then
    --lastnode = lastnode + 1
    --node[lastnode] = {px,py}
    table.insert(node,{px,py})
    map[py+1][px+1] = MARK
    xleft       = math.min(xleft,   px)
    xright      = math.max(xright,  px)
    xtop        = math.min(xtop,    py)
    xbottom     = math.max(xbottom, py)
    pixels = pixels + 1
  end
 end
 end
 --currnode = currnode + 1
end


if pixels > 0 then
 --messagebox("Got a brush")
 bw = xright  - xleft + 1
 bh = xbottom - xtop  + 1
 setbrushsize(bw,bh)
  for y = 0, bh-1, 1 do
   for x = 0, bw-1, 1 do
    px = x+xleft
    py = y+xtop
    if map[py+1][px+1] == MARK then
     putbrushpixel(x,y,getpicturepixel(px,py))
     if remove == 1 then putpicturepixel(px,py,BG); end
   end
   end
  end
end


end -- mouse inside image


