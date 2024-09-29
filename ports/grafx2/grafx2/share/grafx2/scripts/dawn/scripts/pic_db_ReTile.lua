--PICTURE: #ReOrganize Tilesheet V2.0
--by Richard 'DawnBringer' Fhager


--
function perform(o)

     ox = o.ox
     oy = o.oy
     nx = o.nx
     ny = o.ny
 swapxy = o.swapxy
  xflip = o.xflip
  yflip = o.yflip
  rot90 = o.rot90
 halign = o.halign
 valign = o.valign
      w = o.w
      h = o.h

if rot90 == 1 then
 -- getsize
 setpicturesize(h,w)
 for y = 0, h-1, 1 do
  for x = 0, w-1, 1 do
   c = getbackuppixel(x,y)
   putpicturepixel(y,x,c)
  end
  end  
  finalizepicture()
  --
  w,h = h,w
  swapxy = (swapxy + 1) % 2 -- hor/ver flip (required if rotating, deactivated if flipping is wanted)
  xflip  = (xflip + 1)  % 2
  ox,oy  = oy,ox
  nx,ny  = ny,nx
  --
end

BG = getbackcolor()

ofx,ofy = 0,0

--[[
halign = 0
valign = 0

if center == 1 then
 halign = 1 -- 0:Left, 1:Centre, 2:Right
 valign = 1 -- 0:Top,  1:Middle, 2:Bottom
end
--]]

if halign == 0 then -- Left Align
 ofx = 0
end

if halign == 1 then -- Centre Align
 ofx = (nx - ox) / 2 
end

if halign == 2 then -- Right Align
 ofx = nx - ox
end


if valign == 0 then -- Top Align
 ofy = 0
end

if valign == 1 then  -- Middle Align
 ofy = (ny - oy) / 2 
end

if valign == 2 then -- Bottom Align
 ofy = ny - oy
end

--w,h = getpicturesize()

-- Tiles in original picture
tx = math.floor(w / ox)
ty = math.floor(h / oy)

nw = tx * nx
nh = ty * ny

if swapxy == 1 then
 nw = ty * nx
 nh = tx * ny
end


setpicturesize(nw,nh)

clearpicture(BG)

for y = 0, ty-1, 1 do
 for x = 0, tx-1, 1 do
   d1,d2 = x,y; if swapxy == 1 then d1,d2 = d2,d1; end
   for yy = 0, oy-1, 1 do
    for xx = 0, ox-1, 1 do
      sx,sy = xx,yy
      if xflip == 1 then sx = (ox-1) - xx; end
      if yflip == 1 then sy = (oy-1) - yy; end
      c = getbackuppixel(x*ox + sx, y*oy + sy)
      if c ~= BG then
        xp = ofx + d1*nx + xx
        yp = ofy + d2*ny + yy
        putpicturepixel(xp, yp, c)   
      end
   end;end;
 end;end

end
-- eof perform



w,h = getpicturesize()

O = {
 ox = 32,
 oy = 32,
 nx = 48,
 ny = 48,
 swapxy = 0,
  xflip = 0,
  yflip = 0,
  rot90 = 0,
 halign = 1,
 valign = 1,

      w = w,
      h = h
}


--
function currentSize()
  local OK,ox,oy
  OK,ox,oy = inputbox("Current Size",                                                                
      "Current X-size",   O.ox,  2,512,0,
      "Current Y-size",   O.oy,  2,512,0
  )
  if OK then
    O.ox = ox
    O.oy = oy
  end
end
--

--
function newSize()
  local OK,ox,oy
  OK,nx,ny = inputbox("New Size",                                                                
      "New X-size",   O.nx,  2,512,0,
      "New Y-size",   O.ny,  2,512,0
  )
  if OK then
    O.nx = nx
    O.ny = ny
  end
end
--

--
function Flip()
  local OK,fx,fy
  OK,fx,fy = inputbox("Flip",                                                                
      "X-Flip",  O.xflip,  0,1,0,
      "Y-Flip",  O.yflip,  0,1,0
  )
  if OK then
    O.xflip = fx
    O.yflip = fy
  end
end
--

--
function Align()
  local OK,dummy,ax,ay, s,h,v
  h = {0,0,0}
  v = {0,0,0}
  h[O.halign + 1] = 1
  v[O.valign + 1] = 1
  OK,dummy,h[1],h[2],h[3], dummy,v[1],v[2],v[3] = inputbox("Align",
      "--- Horizontal Alignment ---",    0,0,0,4,                                                                
      "Left",    h[1],  0,1,-1,
      "Center",  h[2],  0,1,-1,
      "Right",   h[3],  0,1,-1,
      "--- Vertical Alignment ---",    0,0,0,4,                                                                
      "Top",     v[1],  0,1,-2,
      "Center",  v[2],  0,1,-2,
      "Bottom",  v[3],  0,1,-2
  )
  if OK then
   s = h[1] + h[2]*2 + h[3]*4
   O.halign = math.log(s) / math.log(2)
   s = v[1] + v[2]*2 + v[3]*4
   O.valign = math.log(s) / math.log(2)
  end
end
--

--
function doRotation()
 local o,w,h
 o = {
 ox = O.ox,
 oy = O.oy,
 nx = O.ox,
 ny = O.oy,
 swapxy = 0,
  xflip = 0,
  yflip = 0,
  rot90 = 1,
 halign = 0,
 valign = 0,

      w = O.w,
      h = O.h
}
 
 launch(o)

 finalizepicture()

 O.ox, O.oy = O.oy, O.ox
 O.nx, O.ny = O.ny, O.nx

 w,h = getpicturesize()
 O.w, O.h = w,h

 launch() -- Apply the current settings to the finalized image (Same as if the user would select 'ReTile')

end
--


--
function launch(o)
 o = o or O
 perform(o)
 updatescreen(); waitbreak(0)
end
--

--
function boxer()
  local do_selbox, noyes, ha,va

  ha = {"Left", "Center", "Right"}
  va = {"Top",  "Center", "Bottom"}

  noyes = {"NO","YES"}

  do_selbox = true
  while do_selbox do

   selectbox("ReOrganize Sheet / ReTiler",
 
     --"ROTATE TILES 90° >>", doRotation,
     "Current Size: "..O.ox.." x "..O.oy, currentSize, 
     "    New Size: "..O.nx.." x "..O.ny, newSize,
     "Swap Horiz/Vert: "..noyes[1+O.swapxy], (function() O.swapxy = (O.swapxy + 1) % 2; end),
     "Flip: X="..noyes[1+O.xflip]..", Y="..noyes[1+O.yflip], Flip,
     "Align: "..ha[1+O.halign].." / "..va[1+O.valign], Align,
     --"Rotate Tiles 90°: "..noyes[1+O.rot90], (function() O.rot90 = (O.rot90 + 1) % 2; end),
   
     "RETILE >>", launch,
     "ROTATE TILES 90° >>", doRotation,
  
     "[DONE/QUIT]",function() do_selbox = false; end
   );
  end

end
--

boxer()
