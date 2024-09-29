
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--  L-System V2.0
--                            
--  Program-Function (pfunction) - Dependencies: dawnbringer_lib.lua, db_drawbuffer.lua
--
--  by Richard 'DawnBringer' Fhager 2017  (dawnbringer@hem.utfors.se)
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--
-- Usage:
-- dofile("../pfunctions/pfunc_Lsystem.lua")(data_object)
-- or
-- myfunc = dofile("../pfunctions/pfunc_Lsystem.lua"); myfunc(data_object)
--
-- For Settings/Argument (data) see the default Data-object in the function
--
-- Also see any scn_db_Lsys-* script for examples
---------------------------------------------------------------------------------------


--
return function(Data)

 dofile("../libs/dawnbringer_lib.lua")
 dofile("../libs/db_drawbuffer.lua")

 local tline, drawNormal, drawDBuffer, Lsys_Do, Lsys_Do_Dbuf, Lsys_makeData, Lsys_draw
 local BRIWEIGHT, SPEED, SKIPMODE, MAKEPAL

 --
 Data = Data or { -- Data object, default values:

       cx = 0.44,
       cy = 0.95,

     iter = 5,

     size = 0.00575,

   square = 0, -- Keep proportions square att all image dimensions? 1 = yes, 0 = no (stretch to image)

     rota = 0,

      rgb = {116,80,255},   -- Color
      rng = {1.0,0.6,-0.6}, -- Color change over time, 1.0 = +255 in color channel over drawing

   transp = 0.3,

     seed = "F",            -- Axiom (starting string)
     rule =  { 
              {'Draw',  'F', 'FF+[+F-F+F+F]-[-F+F-F-F]',  0}, -- Move Forward and Draw.
              {'Left',  '-', '-',   20},                      -- Rotate Left  (degrees)
              {'Right', '+', '+',   20},                      -- Rotate Right (degrees)
              {'Move',  'M', 'M',   0},		              -- Move Forward (without drawing)
              {'Save',  '[', '[',   0},			      -- Save Position
              {'Load',  ']', ']',   0},                       -- Load Position	
              --{'Build', 'X', 'XX',  0}                      -- String Evolution (If not handled by 'Draw'), Any number of build-rules are possible.			
             },

             -- 'Draw','Left','Right','Move','Save' & 'Load' are reserved instructions. 'Build' is just an arbitary label.


    speed = 1000,         -- Lines drawn per screenupdate, set high (+1000) for "buffer"-mode, 0 will deactivate updating (and preplotting in "buffer"-mode)
 
   skipmode = 1,     -- avoid double-drawing connecting points, 1 = active, 0 = deactivated (Only effects/noticable in "Normal"?)

   drawmode = "buffer_aa",  -- "normal", "buffer" or "buffer_aa"

      gamma = 2.2,       -- "buffer"-mode gamma value (1.0 - 2.2)
    makepal = 0,         -- Generate Palette (and remap background), Only for Buffer-mode, 1 = Yes, 0 = No

  briweight = 0.25       -- Colormatching Brightness-weight 0..1 (nominal = 0.25)

 }
 --


 -- Global values withing the pfunction

     SPEED = Data.speed or 250
 BRIWEIGHT = Data.briweight or 0.25 
  SKIPMODE = true 
  if Data.skipmode == 0 then SKIPMODE = false; end -- Active by default
  MAKEPAL = false -- Only Buffer mode
  if Data.makepal == 1 then MAKEPAL = true; end 

-- ********************************************
-- *** L-system (fractal curves & "plants") ***
-- ********************************************
--
--


-- Control function, Normal drawing
function Lsys_Do(iter,seed,rule,cx,cy,size,rota,rgb,rng,transp)
 local dat,set,xyr
 statusmessage("Building Fractal..."); waitbreak(0)
 dat = Lsys_makeData(rule)
 set = Lsys_makeSet(seed,iter,dat)
 statusmessage("Drawing...        "); waitbreak(0)
 xyr = Lsys_draw(set,dat,cx,cy,size, Data.square, rota,rgb,rng,transp, "normal")
end
--

-- Control function, DrawBuffer
function Lsys_Do_Dbuf(iter,seed,rule,cx,cy,size,rota,rgb,rng,transp, gamma, mode)
 local w,h,dbuf,dat,set,xyr,pal,cols

 w,h = getpicturesize()
 dbuf = drawb.Init(w,h, gamma) 

 briweight = briweight or 0.25

 statusmessage("Building Fractal..."); waitbreak(0)
 dat = Lsys_makeData(rule)
 set = Lsys_makeSet(seed,iter,dat)
 statusmessage("Drawing (to Buffer)..."); waitbreak(0)
 xyr = Lsys_draw(set,dat,cx,cy,size, Data.square, rota,rgb,rng,transp, mode, dbuf) -- mode = "buffer" or "buffer_aa"

 ----------
 if MAKEPAL == true then  
  updatescreen(); waitbreak(0) -- show finished sketch
  -- Let's keep the original background color (index 0) intact (since pure black is easily lost my Median Cut)
  cols = 255
  statusmessage("PalGen: Buffer Cols"); waitbreak(0)
  pal = drawb.Buffer2Palette(dbuf,4) -- Do every 4th pixel in Draw buffer
  --messagebox("Buffer Size: "..#pal)
  statusmessage("PalGen: M.Cut ("..#pal..")"); waitbreak(0)
  pal = db.fixPalette(db.medianCut(pal,cols,true,false,{1,1,1},8, 0), 1) -- {0.26,0.55,0.19} db.medianCut(pal,cnum,qual,quant,rgbw,bits,quantpow)
  for n = 1, #pal, 1 do  
   setcolor(n,pal[n][1],pal[n][2],pal[n][3]) -- Reserve color 0 (so start at n and not n-1)
  end
  statusmessage("Remap & Finalize..."); waitbreak(0)
  db.remapImage() -- Background is remapped with new palette, however it only uses colors from the drawbuffer plots (rest of image is ignored)
  finalizepicture() -- RenderBuffer needs the new colors. Alternative is to use Custom colormatch and that will be very slow
 end
 ---------

 statusmessage("Rendering...        "); waitbreak(0)
--drawb.RenderBuffer(dbuf)
--drawb.RenderBufferHQ(dbuf, BRIWEIGHT)
 drawb.RenderBufferHQupdate(dbuf, BRIWEIGHT) -- Speed of buffer-render is calculated, Lsystem Data.speed has nothing to do with it
end
--

--
function Lsys_makeData(a)
  local n,i; i = {}
  for n = 1, #a, 1 do i[a[n][2]] = a[n]; end
  return i
end
--

--
function Lsys_makeSet(seed,iter,dat)
  local s,n,i,nset,set,ssub
  ssub = string.sub
  set = seed
  for n = 1, iter, 1 do
   nset = ''
   for i = 1, #set, 1 do
    nset = nset..dat[ssub(set,i,i)][3]
   end
   set = nset
  end
  return set
end
--

-- amt = transp
function tline(x1,y1,x2,y2,r1,g1,b1,amt,skip) -- amt: 0-1, 1 = Full color
 local n,st,m,x,y,r,g,b,org; m = math
 org = 1 - amt
 st = m.max(1,m.abs(x2-x1),m.abs(y2-y1));
 for n = skip, st, 1 do
   x = m.floor(x1+n*(x2-x1)/st)
   y = m.floor(y1+n*(y2-y1)/st)
   r,g,b = getcolor(getpicturepixel(x,y))
   putpicturepixel(x, y, matchcolor2(r1*amt+r*org, g1*amt+g*org, b1*amt+b*org));
 end
 -- Make sure last pixel in line is plotted (without screwing up the doubleplotted joints fix)
 if not (m.floor(x)==m.floor(x2) and m.floor(y)==m.floor(y2)) then -- x,y are always floored already???
  putpicturepixel(x2, y2, matchcolor2(r1*amt+r*org, g1*amt+g*org, b1*amt+b*org, BRIWEIGHT));
  return m.floor(x2),m.floor(y2)
 end
 return x,y
end
--

-- V1.2 (Missing end pixel problem, Better drawing, 'Move' command added)
function Lsys_draw(set,dat,cx,cy,size,square,rot,rgb,rng,transp, drawmode, dbuf)

  local p,DEG,l,n,d,i,v,q,c,tx,ty,posx,posy,dval,w,h,s,cl,mf,msin,mcos,mmax,draw,dc,ox,oy,r,g,b,ang,ro,go,bo
  local f_w,f_h,ox,oy,ssub, r,g,b,nq, rgb1,rgb2,rgb3,rng1,rng2,rng3

  rgb1,rgb2,rgb3 = rgb[1],rgb[2],rgb[3]
  rng1,rng2,rng3 = rng[1],rng[2],rng[3]

  draw = {}

  drawmode = drawmode or "normal"
  if square ~= 1 then square = 0; end

  w,h = getpicturesize()

  f_w, f_h = w, h
  ox = cx * w -- Offset is always the same fraction of the image regardless of "square"-mode etc.
  oy = cy * h
  cx, cy = 0,0
  if square == 1 then
   f_w, f_h = math.min(w,h), math.min(w,h)
  end

  dc,p,DEG,l,msin,mcos,mf,mmax = 0,0, math.pi/180, #set, math.sin, math.cos, math.floor, math.max
  ssub = string.sub  

  posx={}; posy={}; dval={}

  if (rgb == null) then rgb = {0,0,0}; end
  --if (transp == null) then transp = 0; end
  col = db.newArrayMerge(rgb,{})
  q = 255 / (l-1)

  for n = 1, l, 1 do
    s = ssub(set,n,n)
    d = dat[s]
    i = d[1]
    v = d[4]

    if (i == 'Left')  then rot = rot - v; end
    if (i == 'Right') then rot = rot + v; end
 
    if (i == 'Save') then p=p+1; posx[p] = cx; posy[p] = cy; dval[p] = rot; end
    if (i == 'Load') then cx = posx[p]; cy = posy[p]; rot = dval[p]; p=p-1; end

    if (i == 'Draw') then
      --ang = (rot % 360 + 360) * DEG
      ang = rot * DEG
      tx = cx + msin(ang) * size -- Correct components are +cos,+sin, but +sin,+cos is the same but rotated the desired -90 degrees
      ty = cy - mcos(ang) * size
 
      nq = (n-1)*q -- Note that color changes over entire string, not just the drawing instances (so the exact start rgb may never be seen)
      r = mmax(rgb1 + nq * rng1, 0) -- Only cap negatives, overpowered positives is often a useful effect
      g = mmax(rgb2 + nq * rng2, 0)
      b = mmax(rgb3 + nq * rng3, 0)

      dc = dc + 1; draw[dc] = {ox+cx*f_w,oy+cy*f_h, ox+tx*f_w,oy+ty*f_h, r,g,b}

      cx = tx; cy = ty
    end

    if (i == 'Move') then
      --ang = (rot % 360 + 360) * DEG
      ang = rot * DEG
      cx = cx + msin(ang) * size
      cy = cy - mcos(ang) * size 
    end

  end -- n


  -- Solution to prevent drawing same point twice when connecting two lines; a-b-c rather than a-bb-c
  -- Skipmode is not responsible for the last missing pixel

  if drawmode == "normal" then
   drawNormal(draw,transp)
  end

  if drawmode == "buffer_aa" then
   drawDBuffer(dbuf, draw,transp,  drawb.LineAA)
  end

  if drawmode == "buffer" then
   drawDBuffer(dbuf, draw,transp,  drawb.Line)
  end

  return {cx,cy,rot}
end -- draw
--

--
function drawNormal(draw,transp)
  local n,d,cx,cy,tx,ty,ox,oy,skip,floor
  floor = math.floor
  ox,oy,skip = -1,-1,0
  for n = 1, #draw, 1 do
   d = draw[n]
   cx,cy,tx,ty,r,g,b = d[1],d[2],d[3],d[4],d[5],d[6],d[7]
   if SKIPMODE then skip = 0; if ox == floor(cx) and oy == floor(cy) then skip = 1; end; end 
   ox,oy = tline(cx,cy,tx,ty,r,g,b,transp,skip) 
   if n%SPEED == 0 and SPEED > 0 then
    updatescreen(); if (waitbreak(0)==1) then return end; 
   end
  end
end
--

--
function drawDBuffer(dbuf, draw,transp, f_line)
  local n,d,cx,cy,tx,ty,ox,oy,skip,floor
  floor = math.floor
  ox,oy,skip = -1,-1,0
  for n = 1, #draw, 1 do
   d = draw[n]
   cx,cy,tx,ty,r,g,b = d[1],d[2],d[3],d[4],d[5],d[6],d[7]
   if SPEED > 0 then
    putpicturepixel(cx,cy,matchcolor(r,g,b)) -- Draw something while creating the drawbuffer
    if n%SPEED == 0 then
     updatescreen(); if (waitbreak(0)==1) then return end; 
    end
   end
   if SKIPMODE then skip = 0; if ox == floor(cx) and oy == floor(cy) then skip = 1; end; end  -- Doesn't seem to make a differance
   --ox,oy = drawb.LineAA(dbuf,cx,cy,tx,ty,r,g,b,transp,skip)
   --ox,oy = drawb.Line(dbuf,cx,cy,tx,ty,r,g,b,transp,skip)
   ox,oy = f_line(dbuf,cx,cy,tx,ty,r,g,b,transp,skip)
  end
end
--


-- RUN 

 if Data.drawmode ~= "normal" and Data.drawmode ~= "buffer" and Data.drawmode ~= "buffer_aa" then
  messagebox("L-System","Unknown Draw-mode!\n\n'normal' activated")
  Data.drawmode = "normal"
 end

 if Data.drawmode == "normal" then
  Lsys_Do(Data.iter, Data.seed, Data.rule, Data.cx, Data.cy, Data.size, Data.rota, Data.rgb, Data.rng, Data.transp)
 end

 if Data.drawmode == "buffer" or Data.drawmode == "buffer_aa" then
  Lsys_Do_Dbuf(Data.iter, Data.seed, Data.rule, Data.cx, Data.cy, Data.size, Data.rota, Data.rgb, Data.rng, Data.transp, Data.gamma,  Data.drawmode)
 end


--

end
----------------------
-- eof L-System     --
----------------------
