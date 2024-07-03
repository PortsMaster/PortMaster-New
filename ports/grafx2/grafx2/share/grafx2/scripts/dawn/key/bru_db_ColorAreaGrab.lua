--BRUSH: ** ColorArea Brush-Grab V1.5 **
--Assign script to a KEY
--Mousepointer location selects target
--by Richard 'DawnBringer' Fhager

--
function main()

 local x,y,n,w,h
 local moved,key,mx,my,mb,ix,iy
 local BG,COL,MARK,FREE
 local min,max
 local remove,px,py,bw,bh,xleft,xright,xtop,xbottom
 local AX,AY, map, node, no, mapy
 local newArrayInit2Dim

 min, max = math.min, math.max

remove = false -- Clear sprite from image 

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
COL = getpicturepixel(ix,iy)

if ix < w and iy < h then

AX = {-1,0,1,-1,1,-1,0,1}
AY = {-1,-1,-1,0,0,1,1,1}

MARK = 256
FREE = 257

map = newArrayInit2Dim(w,h,FREE) 

node = {}

-- 1st Node: Pixel under mouse.
 table.insert(node,{ix,iy})
 map[iy+1][ix+1] = MARK
 xleft       = ix
 xright      = ix
 xtop        = iy
 xbottom     = iy

while #node > 0 do
 -- removing the last node may produce a very high node-count, but is faster due to that
 -- lua doesn't have to re-arrange the array [table.remove(node,1) would remove the first] 
 no = table.remove(node) 
 x,y = no[1], no[2]
 for n = 1, 8, 1 do
  px = x + AX[n]
  py = y + AY[n]
  if px>=0 and px<w and py>=0 and py<h then
   if getpicturepixel(px,py) == COL and map[py+1][px+1] == FREE then
    table.insert(node,{px,py})
    map[py+1][px+1] = MARK
    xleft       = min(xleft,   px)
    xright      = max(xright,  px)
    xtop        = min(xtop,    py)
    xbottom     = max(xbottom, py)
   end
  end
 end
end


 bw = xright  - xleft + 1
 bh = xbottom - xtop  + 1
 setbrushsize(bw,bh)
  for y = 0, bh-1, 1 do
   py = y+xtop
   mapy = map[py+1]
   for x = 0, bw-1, 1 do
    px = x+xleft
    if mapy[px+1] == MARK then
     putbrushpixel(x,y,getpicturepixel(px,py))
     if remove then putpicturepixel(px,py,BG); end
   end
   end
  end


end -- mouse inside image

end
-- main

main()


