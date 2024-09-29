--BRUSH: Smart Outline WIP V0.9

dofile("../libs/dawnbringer_lib.lua")

OK,glob_pow,brush_mode,bg_mode,inner_pow,brush_aa = inputbox("Brush - Smart Outline (WIP)",
                         "POWER %", 100, 0,100,0,
                         "1. Brush Mode",      1,0,1,-1,
                         "2. Background Mode", 0,0,1,-1,
                         "Inner Power %", 100, 0,100,0,
                         "Brush Edge AA %",    0, 0,100,0
                                      
);


-- !!! Should inner's always be aa against brush, even in bg-mode?
--     Should we exclude bg color from colormatching?

if OK == true then

pal = db.makePalList(256)

w,h = getbrushsize()

NORMAL = true  -- Outline 

BGMODE = false -- Outline is AA'd against background color, not brush.
if bg_mode == 1 then BGMODE = true; end


 POWER = glob_pow / 100


-- Resize
aX = 2
aY = 2
hX = aX / 2
hY = aY / 2
setbrushsize(w+aX,h+aY)

 mx = {{1,2,1},{2,0,2},{1,2,1}}
 sz = 1
 sum = 12
 

 --mx = {{1,2,4,2,1},
 --      {2,4,8,4,2},
 --      {4,8,0,8,4},
 --      {2,4,8,4,2},
 --      {1,2,4,2,1}}
 --sz = 2
 --sum = 84

 mof = sz + 1

 -- Brush AA
 BRUSH_AA = false -- Brush AA
 if brush_aa > 0 then BRUSH_AA = true; end
 --mx_in = {{0,1,0},{1,0,1},{0,1,0}}
 mx_in = {{1,2,1},{2,0,2},{1,2,1}}
 sum_in = 12
 str_in = brush_aa / 100 * POWER


 inner_power = inner_pow / 100 -- 0 = All Brush color 1 = Full outline effect (according to power)
 outer_power = 1
 i = inner_power * POWER
 o = outer_power * POWER
 pow = {0.6*o, 0.8*o, 0.9*o, 1.0*o, 0.85*i, 0.8*i, 0.75*i, 0.8*i, 0.8*i, 0.8*i, 0.8*i, 0.8*i}

 
 bg = getbackcolor(); bgr,bgg,bgb = getcolor(bg)
 fg = getforecolor(); fgr,fgg,fgb = getcolor(fg)

 
 for nx = -hX, w+hX, 1 do
  for ny = -hY, h+hY, 1 do

   xp = nx+hX
   yp = ny+hY

   c = getbrushbackuppixel(nx,ny)

    if c ~= bg then
      cn = c   
         -- Brush AA outline
        if BRUSH_AA == true then
         pr,pg,pb = getcolor(c)
         bk = 0
         for x = -sz, sz, 1 do
          for y = -sz, sz, 1 do
            m = mx_in[y+mof][x+mof]
            cm = getbrushbackuppixel(nx+x,ny+y)
            if cm == bg then bk = bk + m * str_in; end
          end
         end
         s = sum_in
         --cn = matchcolor((fgr*bk + pr*(s-bk))/s, (fgg*bk + pg*(s-bk))/s, (fgb*bk + pb*(s-bk))/s)
         cn = db.getBestPalMatchHYBRID({(fgr*bk + pr*(s-bk))/s, (fgg*bk + pg*(s-bk))/s, (fgb*bk + pb*(s-bk))/s},pal,0.25,false) 
        end
        --

     putbrushpixel(xp,yp,cn)
    end

    -- "normal" outline
    if c == bg and NORMAL == true then
     brush,r,g,b = 0,0,0,0
     for x = -sz, sz, 1 do
      for y = -sz, sz, 1 do
        m = mx[y+mof][x+mof]
        cm = getbrushbackuppixel(nx+x,ny+y)
        if cm ~= bg then
         brush = brush + m
         pr,pg,pb = getcolor(cm)
         r = r + pr*m
         g = g + pg*m
         b = b + pb*m
        end
      end
     end
     cn = bg
      if brush > 0 then
       --brush = math.floor(1 + brush * 12/84)
       v = pow[brush] 
       w = 1 - v 
       d = w / brush
        if BGMODE == false then
         --cn = matchcolor(r*d + fgr*v, g*d + fgg*v, b*d + fgb*v)
         cn = db.getBestPalMatchHYBRID({r*d + fgr*v, g*d + fgg*v, b*d + fgb*v},pal,0.25,false) 
        end
       if BGMODE == true then
         --cn = matchcolor(bgr*w + fgr*v, bgg*w + fgg*v, bgb*w + fgb*v)
         cn = db.getBestPalMatchHYBRID({bgr*w + fgr*v, bgg*w + fgg*v, bgb*w + fgb*v},pal,0.25,false) 
        end
      end
     putbrushpixel(xp,yp,cn)
    end

 end
end


end -- OK