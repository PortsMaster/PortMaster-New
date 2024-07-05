--BRUSH: Color Diagram v1.2 (mem)
--by Richard Fhager 


-- NOTE: This is not just a mem-version, it's an update...

--dofile("dawnbringer_lib.lua") 
dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/memory.lua")



grades = 9
big_radius = 11
space = 1
colors = 256
dspc = 0.5 -- Double lines spacing

bri_step = 16
bri_map = 0.87

choice = memory.load({samp=grades,size=big_radius,step=bri_step,bri=1,sat=1,hue=1,bm=bri_map})
OK,samp,size,step,bri,sat,hue,bm = inputbox(".Color Diagram",
                       "Samples",               choice.samp,  1,16,0,
                       "Size (adj. if need)",   choice.size,  3,30,0,    
                       "Increment",             choice.step, 1,128,0,
                       "Show Brightness",       choice.bri,  0,1,0, 
                       "Show Saturation",       choice.sat,  0,1,0,
                       "Show Hues",             choice.hue,  0,1,0,
                       "Bri-Weight: 0..1",      choice.bm, 0,1,2                
);

if OK == true then
memory.save({samp=samp,size=size,step=step,bri=bri,sat=sat,hue=hue,bm=bm})


f_cir = db.drawBrushCircle
--f_cir = db.filledDiscBrush -- Bresenham, only has integer radii so it doesn't fit well in this context

grades = samp
if grades >= size then size = grades+1; end
big_radius = size
bri_step = step
bri_map = bm


avg_radius = (2*big_radius - grades) / 2
dots = 1 + grades * 2
size = dots * (avg_radius*2 + space)
cent = math.floor(size / 2)

setbrushsize(size, size)

cf = getforecolor()
cb = getbackcolor()
rf,gf,bf = getcolor(cf)
rb,gb,bb = getcolor(cb)

--db.drawBrushRectangle(0,0,size-1,size-1,2)
f_cir(cent,cent,big_radius,cf)

palList = db.makePalList(colors)





-- Brightness
if bri == 1 then
for y = 1, grades, 1 do
 l = bri_step * y
 off = y*(big_radius*2-y+space)
 rad = math.max(1,big_radius-y)
 c0 = matchcolor(rf+l, gf+l, bf+l)
 c1 = db.getBestPalMatchHYBRID({rf+l, gf+l, bf+l},palList,bri_map, false)
 f_cir(cent-avg_radius*dspc,cent-off,rad,c0)
 f_cir(cent+avg_radius*dspc,cent-off,rad,c1)
 c0 = matchcolor(rf-l, gf-l, bf-l)
 c1 = db.getBestPalMatchHYBRID({math.max(0,rf-l), math.max(0,gf-l), math.max(0,bf-l)},palList,bri_map, false)
 f_cir(cent-avg_radius*dspc,cent+off,rad,c0)
 f_cir(cent+avg_radius*dspc,cent+off,rad,c1)
end
end;

-- Saturation
if sat == 1 then
for x = 1, grades, 1 do
 off = x*(big_radius*2-x+space)
 rad = math.max(1,big_radius-x)
 -- DeSat
 r,g,b = db.desaturate(100/grades*x,rf,gf,bf)
 c0 = matchcolor(r, g, b)
 f_cir(cent-off,cent-avg_radius*dspc,rad,c0)
 c1 = db.getBestPalMatchHYBRID({r, g, b},palList,bri_map, false)
 f_cir(cent-off,cent+avg_radius*dspc,rad,c1)
 -- Sat
 r,g,b = db.saturate(100/grades*x,rf,gf,bf)
 c0 = matchcolor(r, g, b)
 f_cir(cent+off,cent-avg_radius*dspc,rad,c0)
 c1 = db.getBestPalMatchHYBRID({r, g, b},palList,bri_map, false)
 f_cir(cent+off,cent+avg_radius*dspc,rad,c1)
end
end;

-- Colors

if hue == 1 then
-- red
for n = 1, grades, 1 do
 off = n*(big_radius*2-n+space) * 0.7
 rad = math.max(1,big_radius-n)
 disp = avg_radius*dspc * 0.7
 nb = n * bri_step
 r = math.min(255,rf + nb)
 g = math.max(0,gf - nb/2)
 b = math.max(0,bf - nb/2)
 c0 = matchcolor(r,g,b)
 f_cir(cent-off+disp,cent-off-disp,rad,c0)
 c1 = db.getBestPalMatchHYBRID({r, g, b},palList,bri_map, false)
 f_cir(cent-off-disp,cent-off+disp,rad,c1)
end

-- green
for n = 1, grades, 1 do
 off = n*(big_radius*2-n+space) * 0.7
 rad = math.max(1,big_radius-n)
 disp = avg_radius*dspc * 0.7
 nb = n * bri_step
 r = math.max(0,rf - nb/2)
 g = math.min(255,gf + nb)
 b = math.max(0,bf - nb/2)
 c0 = matchcolor(r,g,b)
 f_cir(cent-off-disp,cent+off-disp,rad,c0)
 c1 = db.getBestPalMatchHYBRID({r, g, b},palList,bri_map, false)
 f_cir(cent-off+disp,cent+off+disp,rad,c1)
end


-- blue
for n = 1, grades, 1 do
 off = n*(big_radius*2-n+space) * 0.7
 rad = math.max(1,big_radius-n)
 disp = avg_radius*dspc * 0.7
 nb = n * bri_step
 r = math.max(0,rf - nb/2)
 g = math.max(0,gf - nb/2)
 b = math.min(255,bf + nb)
 c0 = matchcolor(r,g,b)
 f_cir(cent+off+disp,cent+off-disp,rad,c0)
 c1 = db.getBestPalMatchHYBRID({r, g, b},palList,bri_map, false)
 f_cir(cent+off-disp,cent+off+disp,rad,c1)
end


-- yellow (4th color)
for n = 1, grades, 1 do
 off = n*(big_radius*2-n+space) * 0.7
 rad = math.max(1,big_radius-n)
 disp = avg_radius*dspc * 0.7
 nb = n * bri_step
 r = math.min(255,rf + nb)
 g = math.min(255,gf + nb)
 b = math.max(0,bf - nb*2)
 c0 = matchcolor(r,g,b)
 f_cir(cent+off-disp,cent-off-disp,rad,c0)
 c1 = db.getBestPalMatchHYBRID({r, g, b},palList,bri_map, false)
 f_cir(cent+off+disp,cent-off+disp,rad,c1)
end

end; -- eof hues

end; -- OK


