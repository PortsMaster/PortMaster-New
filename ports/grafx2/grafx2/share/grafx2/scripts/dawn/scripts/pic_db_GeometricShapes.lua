--PICTURE: Draw Geometric Shapes V1.1
--by Richard 'DawnBringer' Fhager



-- Note: The Memory function will not work if this script is executed outside the context of the Toolbox



dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/memory.lua")
--> db.lineTransp(x1,y1,x2,y2,c,transp_frac)

w, h = getpicturesize()
c = getforecolor()

points = 4
screenrad = math.floor(math.min(h/2,w/2) -2)
rad1 = screenrad
ang1 = 0
rad2 = math.floor(rad1/2)
ang2 = 360 --180 / points
transp = 1

txt = "(BG=FG-->Scale2Screen)"
reset = 0
if getbackcolor() == getforecolor() then 
 reset = 1 
end

ch = memory.load({points=points,rad1=rad1,ang1=ang1,rad2=rad2,ang2=ang2,jump=0,clines=0,globrot=0})

 if reset == 1 then
  ch.rad1 = math.floor(math.min(h/2,w/2) -2)
  ch.rad2 = math.floor(rad1/2)
 end

OK, points,rad1,ang1,rad2,ang2,jump,clines,globrot,doprojection = inputbox(".GeoShapes "..txt, 
                            "Points (neg. = pts only)",        ch.points, -1000, 1000, 0,
                            "#1 Radius (screen = "..screenrad..")", ch.rad1, 1, 1000, 0,
                            "#1 Angle",                ch.ang1, -359, 359,  0,
                            "#2 Radius (-1 = off)",    ch.rad2, -1, 1000, 0,
                            "#2 Angle (360 = auto)",   ch.ang2, -359, 360,  0,
                            "Line-Jump Step (points)", ch.jump, 0, 99,  0,
                            "Centerlines Mode: 0-3",   ch.clines, 0, 3,  0,
                            "Global Rotation",         ch.globrot, -359, 359,  3,
                            "Select a PROJECTION", 0, 0, 1, 0                                                
);

--
if OK then

 if doprojection == 1 then
  OK, normal,iso,oblique = inputbox("Select a Projection", 
   "1. Normal",       1,  0,1,-1,
   "2. Isometric",    0,  0,1,-1,
   "3. Oblique",      0,  0,1,-1 
  )
 end


memory.save({points=points,rad1=rad1,ang1=ang1,rad2=rad2,ang2=ang2,jump=jump,clines=clines,globrot=globrot})

 doLines = true
 if points < 0 then doLines = false; points = -points; end

rad1toCenter = false
rad2toCenter = false
if clines == 1 or clines == 3 then rad1toCenter = true; end
if clines == 2 or clines == 3 then rad2toCenter = true; end

if ang2 == 360 then
 ang2 = ang1 + 180 / points
end


--cx,cy = w/2,h/2
cx = math.floor(w / 2)
cy = math.floor(h / 2)



putpicturepixel(cx,cy,c)

dstep  = 360 / points
conv   = math.pi / 180

pts,pt = {},0
for s = 0, points-1, 1 do

 v1 = (globrot + ang1 + s * dstep) * conv
 x1 = math.ceil(cx + math.sin(v1) * rad1)
 y1 = math.ceil(cy + math.cos(v1) * rad1)
 pt = pt + 1; pts[pt] = {x1,y1,c,0}

 if rad2 ~= -1 then
  v2 = (globrot + ang2 + s * dstep) * conv
  x2 = math.floor(cx + math.sin(v2) * rad2)
  y2 = math.floor(cy + math.cos(v2) * rad2)
  pt = pt + 1; pts[pt] = {x2,y2,c,1}
 end

end


for s = 0, #pts-1, 1 do

 sn = (s + 1 + jump) % #pts

  p1 = pts[s+1]
  x1 = p1[1]
  y1 = p1[2]
  c1 = p1[3]
  r1 = p1[4]

  p2 = pts[sn+1]
  x2 = p2[1]
  y2 = p2[2]
  c2 = p2[3]
  r2 = p2[4]
 
 -- Projections
 if iso == 1 then
  -- Big = 1.0/0.5, Medium = 0.75/0.375, Small = 0.5/0.25
  pX = 0.707107
  pY = 0.353553
  --ptx = math.floor( x1 + tx*pX - ty*pX )
  --pty = math.floor( y1 + ty*pY + tx*pY )
  ox1,oy1,ox2,oy2 = x1,y1,x2,y2
  x1 = math.floor(cx + (ox1-cx)*pX - (oy1-cy)*pX) 
  y1 = math.floor(cy + (oy1-cy)*pY + (ox1-cx)*pY)
  x2 = math.floor(cx + (ox2-cx)*pX - (oy2-cy)*pX) 
  y2 = math.floor(cy + (oy2-cy)*pY + (ox2-cx)*pY)

  --x1 = cx + math.floor((ox1-cx)*pX) - math.floor((oy1-cy)*pX) 
  --y1 = cy + math.floor((oy1-cy)*pY) + math.floor((ox1-cx)*pY)
  --x2 = cx + math.floor((ox2-cx)*pX) - math.floor((oy2-cy)*pX) 
  --y2 = cy + math.floor((oy2-cy)*pY) + math.floor((ox2-cx)*pY)
 end

 if oblique == 1 then
  pX = 1.0
  pY = 0.5
  ox1,oy1,ox2,oy2 = x1,y1,x2,y2
  x1 = math.floor(cx + (ox1-cx)*pX + (oy1-cy)*pX/2) 
  y1 = math.floor(cy - (oy1-cy)*pY) 
  x2 = math.floor(cx + (ox2-cx)*pX + (oy2-cy)*pX/2)
  y2 = math.floor(cy - (oy2-cy)*pY) 
 end

 --

  if doLines then
   db.line(x1,y1,x2,y2,c)
   if rad1toCenter and r1 == 0 then db.line(x1,y1,cx,cy,c); end
   if rad2toCenter and r1 == 1 then db.line(x1,y1,cx,cy,c); end
    else putpicturepixel(x1,y1,c)
  end
 
end




--updatescreen(); if (waitbreak(0)==1) then return; end


end -- OK
