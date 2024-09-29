---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--  Homing Missiles V1.02 
--
--  Program-Function (pfunction) - Dependencies: db_drawbuffer.lua, dawnbringer_lib.lua, db_text.lua
--
--  by Richard 'DawnBringer' Fhager 2015  (dawnbringer@hem.utfors.se)
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--
--  A simulation of homing missiles each targetting another unique missile, 
--  but with no pair of missiles targetting each other.
--  Can be rendered over any image/background, preferrably dark when using bright ink and vice versa.
--
-- 
-- Usage:
-- dofile("../pfunctions/pfunc_HomingMissiles.lua")(data_object)
-- or
-- myfunc = dofile("../pfunctions/pfunc_HomingMissiles.lua"); myfunc(data_object)
--
-- For Settings/Argument (data) see the default Data-object in the function
--
--
-- Last missile is targeting old position of first missile
--
--  * Assumes 256 color gradient palette from dark to bright
-- 
--  * Gamma correction
--  * Transparency Layering
--  * Drawbuffer - New Mult format
--  * Corrected Trignometrics (?)
--
-- History:
-- 
-- v1.02 Minor optimization of missile-array indexing (miss = missile[n+1]...)
-- v1.01 Implementation of atan2() for components(), about 1% speed improvement
---------------------------------------------------------------------------------------


  dofile("../libs/db_drawbuffer.lua") 
  dofile("../libs/dawnbringer_lib.lua")  --> db.shuffle
  dofile("../libs/db_text.lua")


--
-- Underscore variables/constants (ex. _MULT) are global within main
--
return function(data)

data = data or { -- Data object, default values:

            missiles = 80,
                seed = -1,    -- Random seed, -1 = Random
              frames = 5000,  -- Length of scene/anim

             drawmis = true,  -- Draw missiles
             misscol = -1,    -- Missile color, -1 = Ink / 2 (Black 0 = 0, White 255 = 128)

              update = 50,    -- Update screen every nth frame, 1 = real time, 50 = good fast mode
                wait = 0,     -- Update speed/wait in slow mode, nominal = 0

              ispeed = 18,    -- Inital Speed of missiles ("Explosion power")
             inertia = 0.05,  -- Missile Inertia i.e. Scale, negative values allowed, Lower inertia means bigger movements
                macc = 0.03,  -- Missile Acceleration
                drag = 0.965, -- Missile Drag multiple, 1 = none (missiles will accelerate to infinity), 0 = full stop

                 ink = 255,   -- Draw Color/Index 0..255 (0 = Black, 255 = White)
               stamp = 0.03,  -- Transparency 0..1, 1 = solid. Default 0.03 for white ink, 0.1 for black ink
                mult = 1.1,   -- Overdraw Multiplier, Default 1.0 for black ink, 1.1 for white ink
               gamma = 2.2,   -- Default 1.5 for black ink, 2.2 for white ink
          
                fade = 0.75,  --  Fade over the this last fraction of frames

           slideshow = 99,    -- Scenes to play in slideshow mode
           viewpause = 1.5,   -- Seconds of pausing image before next scene. (screen clearing also adds to the length of this pause)

              dotext = 1      -- Display text, 0 = no, 1 = yes (just simple compatability with inputbox())
     }

  local w,h,m,n,x,y,t,i, miss, missile,frame,mx1,my1, t1,t2, macc, drag, inertia,ink,misscol,space,log10
  local slides,fading
  local floor,cos,sin,atan,rnd,max,min,pi,atan2
  local _W,_H,_DBUF,_STAMP,_MULT,_DRAWMISSILES,_MISSCOL

  local initMissile, updateMissile, components, components2, writetext, breaktext, restore

  _W,_H = getpicturesize()

  space = {"      ","     ","    ","   ","  "," "}

  floor = math.floor
    cos = math.cos
    sin = math.sin
   atan = math.atan
  atan2 = math.atan2
    rnd = math.random
    max = math.max
    min = math.min
     pi = math.pi
  log10 = math.log10

--
function initMissile(ispeed,w,h)
   local a,s, mx,my, xc,yc, mdx,mdy, dummy
   mx,my = w / 2, h / 2
   a = rnd()*pi*2
   s = 0.1 + rnd()*rnd()*ispeed
   xc, yc = cos(a), sin(a)
   mdx, mdy = xc * s, yc * s
   --mdx = 0; mdy = 0; mx = rnd()*w; my = rnd()*h -- No init-speed, random pos
   --mdx = 0; mdy = 0
   --mx = floor(w/2)+rnd(-50,50); my = rnd(0,1) * h; mdx = 0; mdy = 0;
   return {mx,my,mdx,mdy}
end
--

--
-- If xd == 0 then yd/xd = infinity --> atan(infinity) = pi/2 = 90 degrees, cos(pi/2) = 0, sin(pi/2) = 1
--
function components(xd,yd)
  local a,xc,yc

  xc,yc = 0,0

  if xd == 0 then
   if yd > 0 then yc =  1; end
   if yd < 0 then yc = -1; end
  end

  if xd < 0 then 
   a = atan(yd/xd) - pi; xc,yc = cos(a), sin(a) 
  end
 
  if xd > 0 then
   a = atan(yd/xd); xc,yc = cos(a), sin(a) 
  end

  return xc,yc

end
--

-- Basically same as components() but with a slight shift in horizontal pos(?)
-- This code makes the default demo roughly 1% faster, so it's not much...
function components2(xd,yd)
  local a
  a = atan2(yd,xd)
  return cos(a), sin(a) 
end
--


--
function updateMissile(n,missile,tx,ty, macc,drag,inertia, ink)

  local m, mx,my, mdx,mdy, max,may, odx,ody

  m = missile[n]
  mx,my,mdx,mdy = m[1],m[2],m[3],m[4]

  xc,yc = components2(tx-mx, ty-my)
 
  max = xc * macc 
  may = yc * macc 
  odx,ody = mdx,mdy
  mdx = (mdx + max) * drag -- Note: Just applying drag to the momentum (MDX,MDY) is equal to changing MACC to MACC*DRAG 
  mdy = (mdy + may) * drag 

  mdx = inertia * (odx - mdx) + mdx -- same as [odx*inertia + mdx*(1-inertia)] but a little faster
  mdy = inertia * (ody - mdy) + mdy

  mx = mx + mdx 
  my = my + mdy 

  missile[n] = {mx,my, mdx,mdy} 

  drawb.IndexFractionalPlotDraw(_DBUF, tx,ty, _STAMP,_MULT, true) 

  if _DRAWMISSILES then             -- and mx>=1 and my>=1 and my<(h-1) and mx<(w-1)
    putpicturepixel(mx,my,_MISSCOL) 
  end

end
--

--
-- Clear image by fading pixels in drawbuffer
--
function restore(dbuf)
 local list,n,t,steps,plots,exp,speed
 steps = 7
 exp = 1.8 - dbuf.icol/255 * 1.25 -- Black Ink: Fade slow2fast, White ink fade fast2slow (since gamma makes darker colors brighter) 
 list = dbuf.list
 speed = floor(#list / 5)
 db.shuffle(list)
 plots = 0
 for t = 1, steps, 1 do
   for n = 1, #list, 1 do
    drawb.IndexRenderPixel(dbuf, list[n], 1 - (t/steps)^exp)
    plots = plots + 1; if plots % speed == 0 then updatescreen(); waitbreak(0); end
   end
 end
end
--


--
function writetext(transp, upd, txt,x,y) -- if arg txt is supplied then write only that
 local t,v
 if data.dotext == 1 then 
  --text.write(font_f,txt,xpos,ypos,hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag,backup_flag)
  t =       "Seed:     "..data.seed
  t = t.."~"
  t = t.."~Missiles: "..data.missiles
  t = t.."~Acc.:     "..data.macc
  t = t.."~Drag:     "..data.drag
  t = t.."~Inertia:  "..data.inertia
  t = t.."~Ispeed:   "..data.ispeed
  t = t.."~"
  t = t.."~Ink:      "..data.ink
  t = t.."~Stamp:    "..data.stamp
  t = t.."~Mult:     "..data.mult
  t = t.."~Gamma:    "..data.gamma
  t = t.."~"
  t = t.."~Frames:   "..data.frames
  t = t.."~Fade:     "..(data.fade*100).."%"
  v = data.ink
  t = txt or t
  x = x or 4
  y = y or 4
  text.write(null,t, x,y, 2,3, 200, {v,v,v}, transp, "~", 0.75, true, true)
  if upd >= 0 then updatescreen(); waitbreak(upd); end
 end
end
--

--
function breaktext(flag,upd,txt) -- Draw/Clear, update-wait (-1 = no)
 local t,x
 t = 1; if flag then t = 0; end
 txt = txt or "break now (esc) for complete image!"
 x = _W - #txt * 6 - 2
 writetext(t, upd, txt, x,4)
end
--


 math.randomseed(os.clock())

 slides = 0

 while slides < data.slideshow do

   if data.seed == -1 or slides > 0 then data.seed = math.random(1,999999);end
   math.randomseed(data.seed); 
 
   if data.dotext == 1 then
    for t = 1, 15, 1 do -- fade to 0.25 (75% solid)
      writetext(1.0 - t*0.05, 0.01)
    end
   end

   slides = slides + 1

   _STAMP = data.stamp
   _MULT = data.mult
   _DRAWMISSILES = data.drawmis
   if data.misscol == -1 then
     _MISSCOL = data.ink / 2
       else _MISSCOL = data.misscol
   end

   fading = data.fade * data.frames

   _DBUF = drawb.InitIndex(_W,_H,data.gamma,data.ink)
 
   missile = {}
   for n = 1, data.missiles, 1 do
    missile[n] = initMissile(data.ispeed, _W,_H)
   end

   t1 = os.clock()

   frame = 0
   while frame < data.frames do

    frame = frame + 1
    if frame == data.frames then _DRAWMISSILES = false; end
    if frame > data.frames-fading then 
      _STAMP = _STAMP - data.stamp / fading; -- Smooth ends
      _MULT = 1 + (data.mult-1) * -(frame-data.frames)/fading -- Derived, it's just a fade to 0 over the fading frames
    end 

    -- Store first missile
    m = missile[1]
    mx1,my1 = m[1],m[2] --  MX1,MY1,MDX1,MDY1

    macc    = data.macc
    drag    = data.drag
    inertia = data.inertia
    ink     = data.ink
    misscol = data.misscol
 
    for n = 1, #missile-1, 1 do
     miss = missile[n+1]  
     updateMissile(n,missile, miss[1],miss[2], macc,drag,inertia, ink) -- Target is coords of next missile in list
    end

    updateMissile(#missile,missile,mx1,my1, macc,drag,inertia, ink) -- Set target of last missile to the stored (old) position of missile #1


    if frame % 100 == 0 then     
      breaktext(true,-1,"Frame: "..frame..space[1+floor(log10(frame))]); 
    end

    if frame % data.update == 0 then     
      updatescreen(); if (waitbreak(data.wait)==1) then return; end
    end

  end -- Frames

 --t2 = os.clock();ts = (t2 - t1);messagebox("Seconds: "..ts)
 
  if data.slideshow > slides then
    writetext(0.25, 0) -- In case text was overdrawn, 0 = update screen
   
    breaktext(true,0)
    if (waitbreak(data.viewpause)==1) then breaktext(false,-1); return; end -- Hold for some time so the final image can be viewed
    -- Restore background
    breaktext(false,-1)
    writetext(0.5, -1)
    restore(_DBUF)
 
    for t = 1, 5, 1 do 
     writetext(0.5 + t*0.1, 0.01) -- 0.01 = updatescreen, wait 0.01
    end
 
    updatescreen(); waitbreak(0.5)
  end

  --updatescreen(); waitbreak(0); drawb.IndexRenderBuffer(dbuf,INK*255);  updatescreen(); if (waitbreak(2)==1) then return; end

 end -- While
end -- main 
--
