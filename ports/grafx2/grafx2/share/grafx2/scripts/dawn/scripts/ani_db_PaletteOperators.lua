--ANIM: Visualize Palette Operators
--by Richard 'DawnBringer' Fhager

function operator1()

 OK,SUP,SAT,BRI,CON,LIG,BALP,BALA,FRAMES,DIAGRAMS = inputbox("Select Colorspace Animation",                       
                          
                          
                             "Saturate - DeSat (Super)",  1,  0,1,-1,
                             "Saturate - DeSat (Basic)",  0,  0,1,-1,
                             "Brightness - Darken(B)", 0,  0,1,-1,
                             "Contrast - DeContrast", 0,  0,1,-1,
                                            
                             "Lightness - Darken(L)", 0,  0,1,-1,
                             "Balance ex. (bri-pres.)", 0,  0,1,-1,
                             "Balance ex. (additive)", 0,  0,1,-1,
                             "FRAMES", 50, 5,1000,0,
                             "Draw Diagrams",  1,  0,1,0
                         
 );
 master()
end


function operator2()

 OK,HUE,HUEB,GAM,FRAMES,DIAGRAMS = inputbox("Select Colorspace Animation",                       
                                    
                             "Hue +180 - Hue -180", 1,  0,1,-1,  
                             "Hue (bri-pres.)", 0,  0,1,-1,           
                             "Gamma Up - Gamma Down",  0,  0,1,-1,
                             "FRAMES", 50, 5,1000,0,
                             "Draw Diagrams",  1,  0,1,0
 );
 master()
end


function master()
--
if OK == true then

 --r,g,b = db.saturateAdv(400,191,64,191, 2, true)
 --hslsat = db.getSaturation(r,g,b)
 --messagebox(r..", "..g..", "..b..": "..hslsat)

--dofile("dawnbringer_lib.lua") 
dofile("../libs/dawnbringer_lib.lua")

  LIGHP = 2
  SATUR = 3
  DESAT = 4
  CONTR = 5
  DECON = 6
  BRIGH = 7
  HUEP  = 8
  DARKN = 9
  DELIG = 10
  HUEN  = 11
  LIGHN = 12
  SUPER = 13
  BALP1 = 14
  BALP2 = 15
  BALA1 = 16
  BALA2 = 17
  GAMMU = 18
  GAMMD = 19
  HUEB1 = 20
  HUEB2 = 21


 if GAM == 1 then EFFECT = {GAMMU,GAMMD}; end

 if SAT == 1 then EFFECT = {SATUR,DESAT}; end
 if SUP == 1 then EFFECT = {SUPER,DESAT}; end
 if BRI == 1 then EFFECT = {BRIGH,DARKN}; end
 if CON == 1 then EFFECT = {CONTR,DECON}; end
 if HUE == 1 then EFFECT = {HUEP,HUEN}; end
 if HUEB == 1 then EFFECT = {HUEB1,HUEB2}; end
 if LIG == 1 then EFFECT = {LIGHP,LIGHN}; end
 if BALP == 1 then EFFECT = {BALP1,BALP2}; end
 if BALA == 1 then EFFECT = {BALA1,BALA2}; end

RANGE = 1
--FRAMES = 25

start,ends,dir = 0,FRAMES,1

startcol = 0
if DIAGRAMS == 1 then
 picX = 480
 picY = 256
 setpicturesize(picX,picY)
 startcol = 1
end

while 1 < 2 do
for effect = 1, 2, 1 do
 eff = EFFECT[effect]
for play = 0, 1, 1 do
for frame = start, ends, dir do

if DIAGRAMS == 1 then
 Clearcolor = matchcolor(0,0,0)
 clearpicture(Clearcolor)
end

amount = RANGE / FRAMES * frame

-- Meter
moffx = 0
moffy = 108
mxsiz = 8
c1 = matchcolor(32,32,32)
c2 = matchcolor(192,192,192)
db.drawRectangle(moffx,moffy, mxsiz, 100,c1)
db.drawRectangleNeg(moffx,moffy, mxsiz, -100,c1)
  db.drawRectangleNeg(moffx,moffy, mxsiz, amount*100*db.sign(effect*2-3),c2)
--


-- *** OPERATORS ***



  bri = 0
  fa = amount
  fo = 1 - fa 

  if eff == BRIGH then 
    bri = 255 * amount
  end

  if eff == DARKN then 
    bri = -255 * amount
  end
  
  --
  for c = startcol, 255, 1 do
    r,g,b = getbackupcolor(c)
 
     if eff == GAMMD then 
      r = db.gamma(r,255,1-amount*0.99) 
      g = db.gamma(g,255,1-amount*0.99) 
      b = db.gamma(b,255,1-amount*0.99) 
     end
     if eff == GAMMU then 
      r = db.gamma(r,255,1+amount*9) 
      g = db.gamma(g,255,1+amount*9) 
      b = db.gamma(b,255,1+amount*9) 
     end


    
     -- Color Balance
     if eff == BALP1 then
       r,g,b = db.ColorBalance(r,g,b, 0,-255*amount,0, true, false) -- brikeep, loosemode
     end
     if eff == BALP2 then
       r,g,b = db.ColorBalance(r,g,b, 0,255*amount,0, true, false) -- brikeep, loosemode
     end
 
     if eff == BALA1 then
       r,g,b = db.ColorBalance(r,g,b, 0,-255*amount,0, false, false) -- brikeep, loosemode
     end
     if eff == BALA2 then
       r,g,b = db.ColorBalance(r,g,b, 0,255*amount,0, false, false) -- brikeep, loosemode
     end


     -- Lightness
     if eff == LIGHP then
       r,g,b = db.changeLightness(r,g,b,100*amount)
     end
     if eff == LIGHN then
       r,g,b = db.changeLightness(r,g,b,-100*amount)
     end

     -- Contrast
     if eff == CONTR then
       r,g,b = db.changeContrast(r,g,b,100 * amount)
     end 

     -- DeContrast
     if eff == DECON then
       r,g,b = db.changeContrast(r,g,b,-100 * amount)
     end 

     -- Hue
     if eff == HUEP then
       r,g,b = db.shiftHUE(r,g,b,180 * amount)
     end 
     if eff == HUEN then
       r,g,b = db.shiftHUE(r,g,b,-180 * amount)
     end

     -- Hue Bri.preserve
     if eff == HUEB1 then
       r1,g1,b1 = db.shiftHUE(r,g,b,180 * amount)

         brio = db.getBrightness(r,g,b)
         for i = 0, 5, 1 do -- 6 iterations, fairly strict brightness preservation
          brin = db.getBrightness(r1,g1,b1)
          diff = brin - brio
          r1,g1,b1 = db.rgbcap(r1-diff, g1-diff, b1-diff, 255,0)
         end
         r,g,b = r1,g1,b1
     end 

     if eff == HUEB2 then
       r1,g1,b1 = db.shiftHUE(r,g,b,-180 * amount)

         brio = db.getBrightness(r,g,b)
         for i = 0, 5, 1 do -- 6 iterations, fairly strict brightness preservation
          brin = db.getBrightness(r1,g1,b1)
          diff = brin - brio
          r1,g1,b1 = db.rgbcap(r1-diff, g1-diff, b1-diff, 255,0)
         end
         r,g,b = r1,g1,b1
     end     
     

    -- Super Saturation
    if eff == SUPER then
      r,g,b = db.saturateAdv(400*amount,r,g,b, 2, true) -- Brikeeplev 0-2, grayfade_flag
    end

    -- Basic Saturation
    if eff == SATUR then
      r,g,b = db.saturateAdv(400*amount,r,g,b, 0, false) -- Brikeeplev 0-2, grayfade_flag
    end


     -- Desaturate
     if eff == DESAT then
      a = db.getBrightness(r,g,b)
      afa = a * fa
      r = r * fo + afa 
      g = g * fo + afa 
      b = b * fo + afa
     end 

    --
    setcolor(c, r+bri, g+bri, b+bri)
  end


-- *** eof OPERATORS ***

if DIAGRAMS == 1 then

-- Analysis 
palList = db.makePalList(256)
palList = db.fixPalette(palList,1)

-- for db.drawHSBdiagram
-- Use "custom" satfunc, since the default Real(Abs) is slow with lowsat colors
-- Apparent saturation is a fast and decent solution (HSL + True (distance from grayscale axis))
palList = db.addHSBtoPalette(palList, db.getAppSaturation) 

-- Pal, posz,posy,width,height,size,saturation
--db.drawHSBdiagram(palList,19,1,30,32,3,255)
--db.drawHSBdiagram(palList,111,1,30,32,3,128)

-- Map all colors on a Hue/Brightness diagram + iso color cube
colors = #palList
greytolerance = 0.05 + colors / 3000 -- Ability to count as greyshade
ox = 300
oy = 12
sz = math.min(8, math.floor(48 / math.sqrt(colors)))
st = math.min(8, math.floor(48 / math.sqrt(colors)))
hranges = 24 * 3 / st
branges = 32 * 3 / st
hm = hranges / 6
bm = branges / 256

 -- iso
 ix = 406 - 330
 iy = 62-6-6 + 50
 xstep = 1 *  1 
 ystep = 1 * 0.5
 zstep = 1 * 1.5
 div = 4


-- Draw iso cube (Beta, quick code...could be some crap here)
function drawIsoLine(ox,oy,r,g,b,rm,gm,bm,xstep,ystep,zstep,div,step,c)
 local x,y,n
 for n = 0, 255, step do
  x = (g+n*gm)/div*xstep - (r+n*rm)/div*xstep  
  y = (r+n*rm)/div*ystep + (g+n*gm)/div*ystep - (b+n*bm)/div*zstep
  putpicturepixel(ox+x,oy+y,c)
 end
end

-- Draw 2 iso-cube bkg's (by filling ramps in colorspace), derived code.
ofx = 140
rgb = {255,0,0}
col = {1,0,0}
e = {}; d = {}
s = 4
c = matchcolor(48,48,48);if c == 0 then c = matchcolor(255,255,255); end
for n = 0, 1, 1 do
  x = ix + ofx * n
 for l = 0, 8, 1 do
   m = 0; if l > 2 then m = 1; end
   q = math.floor(l/3)
   for c = 0, 2, 1 do
    d[c+1] = col[(l + c) % 3 + 1]  
    e[c+1] = rgb[(l + c + q) % 3 + 1] * m
   end
   drawIsoLine(x,iy,e[1],e[2],e[3], d[1],d[2],d[3],xstep,ystep,zstep,div,s,c)
 end
end
--

--messagebox(hm.." "..bm)
-- Diagram

 -- Small HueBri diagrams
 bs = 53 / 255
 bsl = bs*255 + 4
 hml = 4
 yf = 120 + 20
 xf = 370
 ds = 30
 co = matchcolor(48,48,48)

 
 -- HueBri boxes
 db.drawRectangleLine(xf-1,yf-2,     bsl,7.5*hml+1,co)
 db.drawRectangleLine(xf-1,yf+ds-2,  bsl,7.5*hml+1,co)
 db.drawRectangleLine(xf-1,yf+ds*2-2,bsl,7.5*hml+1,co)


-- Match by brightness
--bx = 320
--by = 1
--sc = 0.68
--for b = 0, 10, 1 do
--for n = 0, 255, 1 do
--  c = db.getBestPalMatchHYBRID({n,n,n},palList,0.1*b,true) 
--  putpicturepixel(bx+b,by + 256*sc - n*sc,c)
--end
--end

spc = 2
if colors > 176 then spc = 1; end
for n = 1, colors, 1 do
 c = palList[n][4] -- r,g,b,n,h,s,b
 r,g,b = getcolor(c)
 --r = palList[n][1]
 --g = palList[n][2]
 --b = palList[n][3]
 --hue = db.getHUE(r,g,b,greytolerance)
 --bri = db.getBrightness(r,g,b) 
 hue = palList[n][5]
 bri = palList[n][7]
 trusat = db.getTrueSaturationX(r,g,b)
 hslsat = db.getSaturation(r,g,b)
 sat = db.getAppSaturation(r,g,b)

 -- Saturation
 --soff = 116 + 20
 --xoff = 322

 if c < 256 then
  --db.line(248+c*2,167,248+c*2,math.floor(167-trusat/8),c)
  --db.line(248+c*2,164-math.floor(trusat/8),248+c*2,164-math.floor(trusat/8+hslsat/8),c)

  --db.line(xoff-math.floor(trusat/8),soff+c*2,xoff,soff+c*2,c)
  --db.line(xoff+2+math.floor(hslsat/8),soff+c*2,xoff+2,soff+c*2,c)

  soff = 196
  xoff = 10
  idx = c
  --idx = n
  db.line(xoff + idx*spc, soff - math.floor(trusat/8), xoff+idx*spc, soff,c)
  db.line(xoff + idx*spc, soff + math.floor(hslsat/8), xoff+idx*spc, soff+2,c)
 end 


 -- Big Hue-Bri diagram
 scale = 1.6
 if bri > 12 then
  db.drawCircle(ox+bri*st*bm*scale,oy+hue*st*hm*1.4,sz/2,c)

  free = 0
  while getpicturepixel(ox+bri*st*bm*scale,oy+114+free) ~= Clearcolor do
   free = free + 1
  end  
  putpicturepixel(ox+bri*st*bm*scale,oy+114+free,c)   

 end



 if sat >= 170 then 
    putpicturepixel(xf+bri*bs,yf+hue*hml,c)
 end

 if sat >= 85 and sat < 170 then 
    putpicturepixel(xf+bri*bs,yf+hue*hml+ds,c)
 end

 if sat < 85 then 
    putpicturepixel(xf+bri*bs,yf+hue*hml+ds*2,c)
 end

 -- iso 1
 x = g/div*xstep - r/div*xstep  
 y = r/div*ystep + g/div*ystep - b/div*zstep
 db.drawCircle(ix+x,iy+y,math.floor(sz/2)/2,c)
 
 -- iso 2 (rotated 90 degrees around green axis)
 r2 =-b + 255
 g2 = g
 b2 = r
 x = g2/div*xstep - r2/div*xstep  
 y = r2/div*ystep + g2/div*ystep - b2/div*zstep
 db.drawCircle(ix+x+ofx,iy+y,math.floor(sz/2)/2,c)

end    
--

-- Oblique
if true == false then
STEP = 4

side = 4	
xx = 430
yy = 200
bri = 100
spc = side
zspc = math.floor(side / 2) 

for z = 0, 15, STEP do
 for y = 15, 0, -STEP do
  for x = 0, 15, STEP do

  c = matchcolor(x*16,(15-y)*16,z*16)
  r,g,b = getcolor(c)

  db.obliqueCube(side,xx+x*spc-z*zspc,yy+y*spc+z*zspc,r,g,b,bri)

  end
 end
end;
end
--


-- Analysis --

l = #palList

w = math.max(1,math.floor(picX / l))

--for n = 0, 255, 1 do
-- db.drawRectangle(n*w,182,w,8,n)
--end

-- Brightness sorted
for n = 1, l, 1 do
 rgb = palList[n]
 db.drawRectangle((n-1)*w,240,w,8,rgb[4])
end

function bri(r,g,b)
 return (r+g+b) / 63.75
end
--

end
-- Diagrams

updatescreen(); 
if (waitbreak(0)==1) then 
  for c = 0, 255, 1 do
    r,g,b = getbackupcolor(c)
    setcolor(c, r, g, b)
  end
 return
 --main()
end

end -- frame
wait(0.5)
start,ends,dir = ends,start,-dir
end -- play
end -- effect
end -- while


end -- OK
--

end -- main




-- Interface for scn_db_PaletteOperators_upd.lua

function middle1() -- Apparently needed so we can can exit everything
 operator1()
 main()
end

function middle2() -- Apparently needed so we can can exit everything
 operator2()
 main()
end


function _quit()
 -- nada
end

function _info()
 local t
 t = "These anims displays your palette in RGB-colorspace and the actual"
 t = t.." effect different operators & modifers have on it when applied."
 t = t.."\n\n My algorithms often include options to preserve perceptual color-brightness, "
 t = t.."this can improve the palette modification quality."
 t = t.."\nNote: Color 0 is not affected by the operators."
 messagebox("Info", t)
 main()
end

function main()
 SUP,SAT,BRI,CON,HUE,LIG,BALP,BALA,GAM,HUEB = 0,0,0,0,0,0,0,0,0,0,0
 DIAGRAMS = 0
 selectbox("Palette Operators Anim", 
  ">PALETTE OPERATORS 1", middle1,
  ">PALETTE OPERATORS 2", middle2,
  "[Info]", _info,
  "[Quit]", _quit -- We cannot go back to the DB ToolBox from here
 
 );
end

main()
