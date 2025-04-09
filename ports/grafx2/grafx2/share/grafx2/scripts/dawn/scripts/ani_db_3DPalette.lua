--ANIM: 3D-Palette Viewer V1.5 
--by Richard 'Dawnbringer' Fhager


-- (V1.1 Major overhaul, everything localized in main(), Added Z-rotation by "z"-key)

-- Mouse:	Rotate Cube (Stops animation)
-- Arrow-keys:	Move Cube (in 3D world)
-- F1:		Start/Stop animation 
-- F2:		Reset
-- F3:		Increase Color-Size
-- F4:		Decrease Color-Size
-- F5:		(Wip) Cycle thru selected PenColor (Note that only unique colors are displayed)
-- F9:		RGB-space model
--F10:		HPB-space model (Hue-Purity-Brightness)
--F11:		HSL-space model
--F12:		HSLcubic-space model
-- "+" (Num):	Zoom In
-- "-" (Num):   Zoom Out
-- "z"          Rotate around Z-axis
-- Esc:		Exit script

-- If Pen-col == Background-col then this color becomes the background rather than black.

-- Drawing updated, rectangle missing, Sep11

dofile("../libs/dawnbringer_lib.lua")

--
function main()

 local Version = 1.5

 local ANIM, BRIDIAG_SHOW, BOX_DRK
 local OK,RGB,HPB,HSL,HSLC,BOX_BRI,COLSIZE_BASE,SET800x600

BRIDIAG_SHOW = 1     -- Show brightness/Grayscale diagonal (1 = on, 0 = off)
ANIM         = 1     -- Animation (1 = on, 0 = off)
BOX_DRK      = 8     -- Darkest   color used for box (0-255)
BOX_BRI      = 112   -- Brightest color used for box (0-255)
COLSIZE_BASE = 26    -- Colors base size (value to adjusted by palette-size, with 2 cols maxsize is v / 1.23)

--
OK,RGB,HPB,HSL,HSLC,COLSIZE_BASE,BOX_BRI,SET800x600 = inputbox("3D-Palette Viewer v"..Version,
                        
                           "1. RGB Cube       [F9]",       1,  0,1,-1,
                           "2. Hue-Purity-Bri [F10]",      0,  0,1,-1, -- Hue, Purity, Brightness (perceptual)
                           "3. HSL Cylinder   [F11]",      0,  0,1,-1,
                           "4. HSL Cubic      [F12]",0,  0,1,-1,
                           "Col Size: 1-100   [F3/F4]", COLSIZE_BASE,   1,100,0,  
                           "Box Brightness (0 = off)", BOX_BRI, 0,255,0,                  
                           "Set Screen to 800x600",      1,0,1,0
                                                                        
);
--

if OK then

 local w,h, n,p,zp,sz,c,l,p1,p2,radius,dorad, XP,YP, CX,CY, SIZE,DIST
 local Xsin,Ysin,Zsin,Xcos,Ycos,Zcos
 local SPACE, XANG, YANG, ZANG, ZOOM, COLSIZE_ADJ, XD, YD, WORLD_X, WORLD_Y, ZSELECT
 local CMAXSIZE, CMINSIZE, BOX_LINE_DIV, BOX_DIV_MULT, BKG_COL, ZOOM2_COLSIZE_ADJ
 local old_mouse_x, old_mouse_y, old_mouse_b, moved, old_key, key, mouse_x, mouse_y, mouse_b
 local sin,cos,min,max,pi,pi2,floor,ceil
 local pal, FG,BG, palcol, minz,totz,maxrad,maxradtotz
 local cols, colz, boxp, box_div, lin, pts
 local initColors, initPointsAndLines, initAndReset, draw3Dline, rotate3D_ALL, killinertia
 

 if SET800x600 == 1 then setpicturesize(800,600); end

 SPACE = "rgb"
 FORM  = "cube"
 if HSL == 1 then
  SPACE = "hsl"
  FORM  = "cylinder"
 end
 if HPB == 1 then
  SPACE = "hpb"
  FORM  = "cylinder"
 end
 if HSLC == 1 then
  SPACE = "hsl_cubic"
  FORM  = "cube"
 end


pal = db.fixPalette(db.makePalList(256))

FG = getforecolor() 
BG = getbackcolor()

palcol = FG

 cos = math.cos
 sin = math.sin
 min = math.min
 max = math.max
 pi = math.pi
 pi2 = math.pi * 2
 floor = math.floor
 ceil = math.ceil

--
function initColors(space)
  local n,c,hue,rad,div
  div = 127.5
  for n = 1, #pal, 1 do 
   c = pal[n]; 
   if space == "rgb" then
   cols[n] = {c[1]/div-1,c[2]/div-1,c[3]/div-1,c[4]};
  end
  if space == "hsl_cubic" then
   cols[n] = {}
   cols[n][1] = (db.getHUE(c[1],c[2],c[3],0) / 6.0 * 255) / div - 1
   cols[n][2] = (db.getSaturation(c[1],c[2],c[3])) / div - 1
   cols[n][3] = (db.getLightness(c[1],c[2],c[3])) / div - 1
   cols[n][4] = c[4]
  end

  if space == "hpb" then
   cols[n] = {}
   hue = db.getHUE(c[1],c[2],c[3],0) / 6.0 * math.pi*2
   --rad = db.getSaturationHSV(c[1],c[2],c[3]) -- 0..1
   rad = db.getPurity(c[1],c[2],c[3]) -- 0..1
   cols[n][1] = cos(hue) * rad
   cols[n][2] = sin(hue) * rad
   cols[n][3] = (db.getBrightness(c[1],c[2],c[3])) / div - 1
   cols[n][4] = c[4]
  end

  if space == "hsl" then
   cols[n] = {}
   hue = db.getHUE(c[1],c[2],c[3],0) / 6.0 * math.pi*2
   rad = db.getSaturation(c[1],c[2],c[3]) / 255
   --rad = db.getTrueSaturationX(c[1],c[2],c[3]) / 255
   cols[n][1] = cos(hue) * rad
   cols[n][2] = sin(hue) * rad
   cols[n][3] = (db.getLightness(c[1],c[2],c[3])) / div - 1
   cols[n][4] = c[4]
  end
 end
end
--

cols = {} -- Make points of palette colors
colz = {} -- To hold calculated points
initColors(SPACE)


--
function initPointsAndLines(form,bridiag)
 local p
 if form == "cube" then 
  pts = {{-1,1,-1},{1,1,-1},{1,-1,-1},{-1,-1,-1}, -- The box
        {-1,1, 1},{1,1, 1},{1,-1, 1},{-1,-1, 1}}
  lin = {{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}} -- Box Lines
  if bridiag == 1 then lin[13] = {4,6}; end
 end
 if form == "cylinder" then
  p = 28
  pts = {}
  lin = {}
  for n = 1, p, 1 do
   x = cos(pi2 / p * (n-1))
   y = sin(pi2 / p * (n-1))
   pts[n] = {x,y,-1}
   lin[n] = {n,1 + (n%p)}
   pts[n + p] = {x,y,1}
   lin[n + p] = {n+p,p + 1 + (n%p)}
  end
  lin[p*2+1] = {1,p+1} -- Red (0 degrees)
  lin[p*2+2] = {p+1,p+1+ceil(p/2)} -- Lightness end (needs an even # of points to work)
 end
end
--

boxp = {} -- To hold the calculated points
initPointsAndLines(FORM,BRIDIAG_SHOW)

w,h = getpicturesize()
CX,CY = w/2, h/2



function initAndReset()
 XANG, YANG, ZANG, ZOOM, COLSIZE_ADJ, XD, YD, WORLD_X, WORLD_Y, ZSELECT = 0,0,0,0,0,0,0,0,0,0
end

initAndReset()


SIZE = min(w,h)/4
DIST = 5 -- Distance perspective modifier, ~5 is nominal, more means "less 3D" 

CMAXSIZE = floor(COLSIZE_BASE / ((#pal)^0.3))
--CMAXSIZE = 8
CMINSIZE = 1 -- Negative values are ok. Color are never smaller than 1 pix

BOX_LINE_DIV = 20 -- Number of colors/segments that a box-line can be divided into (depth)
BOX_DIV_MULT = BOX_LINE_DIV / (math.sqrt(3)*2)

-- Box depth colors
box_div = {}
for n = 0, BOX_LINE_DIV-1, 1 do
 c = BOX_DRK + (BOX_BRI / (BOX_LINE_DIV - 1)) * n 
 --box_div[BOX_LINE_DIV - n] = matchcolor(c,c,c)
 box_div[BOX_LINE_DIV - n] = db.getBestPalMatchHYBRID({c,c,c},pal,0.5,true)
end

--BOX_COL = matchcolor(80,80,80)
BKG_COL = matchcolor(0,0,0)
if FG == BG then
 BKG_COL = BG
end
--CUR_COL = matchcolor(112,112,112)


 

 -- Use the Global constants?
 function rotate3D_ALL(points, cx,cy, size, world_x, world_y, dist, zoom, Xsin,Ysin,Zsin,Xcos,Ycos,Zcos) --xang,yang,zang

   local x1,x2,x3,y1,y2,y3,z1,z2,z3,xp,yp
   local n,v,x,y,z,f,distzoom,distsize
   --local Xsin,Xcos,Ysin,Ycos,Zsin,Zcos
   local boxp 
   
   distzoom = dist + zoom
   distsize = dist * size

   boxp = {}

   --Xsin = sin(xang); Xcos = cos(xang)
   --Ysin = sin(yang); Ycos = cos(yang)
   --Zsin = sin(zang); Zcos = cos(zang) 

   for n = 1, #points, 1 do

     v = points[n]
     x = v[1]
     y = v[2]
     z = v[3]

    -- Correct rotation (Match -17)?
    -- X Rotation
    x1 = x    
    y1 = y * Xcos - z * Xsin --
    z1 = y * Xsin + z * Xcos --
    -- Y Rotation
    x2 = x1 * Ycos - z1 * Ysin
    y2 = y1
    z2 = x1 * Ysin + z1 * Ycos
    -- Z Rotation
    x3 = x2 * Zcos - y2 * Zsin
    y3 = x2 * Zsin + y2 * Zcos
    --z3 = z2

     -- Apply "World"
     f = distsize / (z2 + distzoom)
     xp = cx + (x3 + world_x) * f
     yp = cy + (y3 + world_y) * f

     boxp[n] = {xp,yp,z2,v[4]}
  
   end

    return boxp
  end
--

 

--
function draw3Dline(x1,y1,z1,x2,y2,z2,div,mult,depthlist)
   local s,xt,yt,xd,yd,zd,xf,yf,depth,z1_1732
   xd = (x2 - x1) / div
   yd = (y2 - y1) / div
   zd = (z2 - z1) / div
   xf,yf = x1,y1
   --z1_1732 = z1 + 1.732
   z1_1732 = (z1 + 1.732) * mult + 1

  for s = 1, div, 1 do
    -- Depth assumes a 1-Box (z ranges from -sq(3) to sq(3))
    --depth = floor(1 + (z1+zd*s + 1.732) * mult) 
    --depth = floor(1 + (zd*s + z1_1732) * mult) -- same as above if z1_1732 = z1 + 1.732
    depth = floor(zd*s*mult + z1_1732)           -- same as above if z1_1732 = (z1 + 1.732) * mult + 1
    xt = x1 + xd*s -- + math.random()*8
    yt = y1 + yd*s -- + math.random()*8
    c = depthlist[depth]
    if c == null then c = 1; end -- Something isn't perfect, error is super rare but this controls it
    --db.line(xf,yf,xt,yt,c)
     drawline(xf,yf,xt,yt,c)
     --r,g,b = getcolor(c); db.lineTranspAAgamma(xf,yf,xt,yt, r,g,b, 1.0, 2.2)
    xf = xt
    yf = yt
  end
end
--

function killinertia()
 XD = 0
 YD = 0
end

 -- If using 1-box, z is -sq(3) to sq(3)
 minz = math.sqrt(3)
 totz = minz * 2
 maxrad = CMAXSIZE - CMINSIZE
 maxradtotz = maxrad / totz

while 1 < 2 do

 clearpicture(BKG_COL)

 Xsin = sin(XANG); Xcos = cos(XANG)
 Ysin = sin(YANG); Ycos = cos(YANG)
 Zsin = sin(ZANG); Zcos = cos(ZANG)
 
 boxp = rotate3D_ALL(pts,  CX,CY, SIZE, WORLD_X, WORLD_Y, DIST, ZOOM, Xsin,Ysin,Zsin,Xcos,Ycos,Zcos)
 colz = rotate3D_ALL(cols, CX,CY, SIZE, WORLD_X, WORLD_Y, DIST, ZOOM, Xsin,Ysin,Zsin,Xcos,Ycos,Zcos)

 
-------------------------------------
-------------------------------------

 -- sort on z
 db.sorti(colz,3) 

 ZOOM2_COLSIZE_ADJ = -ZOOM * 2 + COLSIZE_ADJ

 -- Draw colors
 for n = #colz, 1, -1 do
  p = colz[n]
  XP,YP,zp,c = p[1],p[2],p[3],p[4]

  --radius = CMINSIZE + maxrad - (zp+minz) / totz * maxrad
  radius = CMAXSIZE - (zp+minz) * maxradtotz
  --dorad  = floor(radius - ZOOM*2 + COLSIZE_ADJ)
  dorad  = floor(radius + ZOOM2_COLSIZE_ADJ)  

  if dorad >= 1 then
   --db.drawCircle(XP,YP,dorad,c) 
   --db.filledDisc(XP, YP, floor(dorad), c)
   drawdisk(XP,YP,dorad,c) 
     --db.drawRectangle(XP,YP,dorad,dorad,c)
   else putpicturepixel(XP,YP,c)
  end

  if c == FG or c == BG then
   sz = max(3,dorad + 3)
   if c == BKG_COL then v = (c+128) % 255; c = matchcolor(v,v,v); end
   db.drawRectangleLine(XP-sz,YP-sz,sz*2,sz*2,c)
  end

 end -- colz



 -- Draw box
 if BOX_BRI > 0 then
  for n = 1, #lin, 1 do
  
   l = lin[n]
   p1 = boxp[l[1]]
   p2 = boxp[l[2]]
   --x1,y1,z1 = p1[1],p1[2],p1[3]
   --x2,y2,z2 = p2[1],p2[2],p2[3]
   draw3Dline(p1[1],p1[2],p1[3], p2[1],p2[2],p2[3], BOX_LINE_DIV,BOX_DIV_MULT,box_div)

  end -- eof box
 end


 repeat

    old_key = key;
    old_mouse_x = mouse_x;
    old_mouse_y = mouse_y;
    old_mouse_b = mouse_b;
  
    updatescreen()

    moved, key, mouse_x, mouse_y, mouse_b = waitinput(0)    
    
    if mouse_b == 1 then ANIM = 0; end

    if (key==27) then
       return;
    end

    if (key==282) then  ANIM = (ANIM+1) % 2;  end -- F1: Stop/Start Animation
    if (key==283) then  initAndReset();       end -- F2: Reset all values
    if (key==284) then  COLSIZE_ADJ = COLSIZE_ADJ + 0.5;       end -- F3
    if (key==285) then  COLSIZE_ADJ = COLSIZE_ADJ - 0.5;       end -- F4

   --messagebox(key)

    if (key==286) then  
      --FG = (FG + 1) % 255; 
      palcol = (palcol + 1) % #pal 
      FG = pal[palcol+1][4]
      setforecolor(FG);
      setcolor(0,getcolor(0))  -- Force update of palette until setforecolor() is fixed
     end -- F5

    if (key==290) then -- F9
     initColors("rgb")
     initPointsAndLines("cube",BRIDIAG_SHOW)
    end
    if (key==291) then -- F10
     initColors("hpb")
     initPointsAndLines("cylinder", 0) -- Bridiag won't show even if turned on, it's only for cube
    end
    if (key==292) then -- F11
     initColors("hsl")
     initPointsAndLines("cylinder", 0) -- Bridiag won't show even if turned on, it's only for cube
    end
    if (key==293) then -- F12
     initColors("hsl_cubic")
     initPointsAndLines("cube",BRIDIAG_SHOW)
    end


    if (key==269) then  ZOOM = ZOOM + 0.1;  end
    if (key==270) then  ZOOM = ZOOM - 0.1;  end

    if (key==32) then  
      ZSELECT = (ZSELECT + pi/2) % pi2;  

      YANG = (YANG + pi/2) % pi2;
      XANG = (XANG + pi/2) % pi2;
      YANG = (YANG - pi/2) % pi2;
    end -- Rotate Z 90 Degrees

    SPEED = pi / 100
 

    if (key==273) then WORLD_Y = WORLD_Y - 0.05; killinertia();  end
    if (key==274) then WORLD_Y = WORLD_Y + 0.05; killinertia();  end

    if (key==276) then WORLD_X = WORLD_X - 0.05; killinertia();  end
    if (key==275) then WORLD_X = WORLD_X + 0.05; killinertia();  end
   
  until ((mouse_b == 1 and (old_mouse_x~=mouse_x or old_mouse_y~=mouse_y)) or key~=0 or ANIM==1 or math.abs(XD)>0.01 or math.abs(YD)>0.01);

 if (key==122) then ZSELECT = (ZSELECT + pi/100) % pi2;  end -- Z-rotation "Z" key

 if ANIM == 0 then
  if (mouse_b==1 and (old_mouse_x~=mouse_x or old_mouse_y~=mouse_y)) then -- Inertia
   XD = (mouse_y - old_mouse_y)*0.005
   YD = (mouse_x - old_mouse_x)*0.005
    else
     XD = XD*0.92
     YD = YD*0.92
  end
  XANG = (XANG + XD) % pi2
  YANG = (YANG + YD) % pi2
  ZANG = ZSELECT
 end 

 if ANIM == 1 then -- old speed 300,500,1000
    XANG = (XANG + pi/450)  % pi2
    YANG = (YANG + pi/750)  % pi2
    ZANG = (ZANG + pi/1500) % pi2
 end

 statusmessage("x"..floor(XANG*57.3).."° y"..floor(YANG*57.3).."° z"..floor(ZANG*57.3).."° Zm: "..floor(-ZOOM*10))

end

end -- OK

end -- main()

main()