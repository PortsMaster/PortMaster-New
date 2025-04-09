--PICTURE: Analyze Palette V2.21 
--by Richard 'DawnBringer' Fhager 
--Email: dawnbringer@hem.utfors.se


-- (V2.21 Optimized colmatching, Made Indexed Palette clearer, Purity instead of "Real" Saturation)




--
function main()

 dofile("../libs/dawnbringer_lib.lua")
 dofile("../libs/db_text.lua")
 dofile("../ffonts/font_mini_3x4.lua")

 local palList, data

 -- Not all variables are localized (main() is a 'global' context)...just a tiny speed optimization
 local n,t,x,y,z,o,r,g,b,s,d,i,h1,h2,h3,xx,yy,ox,oy,px,py,bx,by,xp,yp,xf,yf,sp,ts,bw,wd,ht
 local rgb,col,bri,hue,sat, spc,zspc, rmp1,xsize,ysize,gamma,cspace,cwidth,space,colors,big_sz
 local graytolerance
 local LEN

 local desat_bri, drawRamp, drawPackage, upd, bri



MIX = 1 -- Colormixes
CLC = 1 -- Close colors

timer1 = os.clock()


sat_txt = "Purity";  sat_func_frac = db.getPurity;        sat_func_255 = db.getPurity_255;        sat_func_comp1 = db.getSaturationHSV_255; sat_txt2 = "HSV/HSB"
if sat_mod2 == 1 then
 sat_txt = "HSV/HSB"; sat_func_frac = db.getSaturationHSV; sat_func_255 = db.getSaturationHSV_255; sat_func_comp1 = db.getPurity_255;        sat_txt2 = "Purity"
end
if sat_mod3 == 1 then
 sat_txt = "HSL";     sat_func_frac = db.getSaturationHSL; sat_func_255 = db.getSaturationHSL_255; sat_func_comp1 = db.getPurity_255;        sat_txt2 = "Purity"
end

-- Right-side saturation model in comp diagram
sat_func_comp2 = sat_func_255 

-- Override: Brightness in Satcomp diagram instead of a 2nd sat-model
sat_func_comp1 = db.getBrightness; sat_txt2 = "Bri"



-- Analysis 
palList = db.makePalList(256)

palList = db.fixPalette(palList,1) -- Adds Double data etc
palList = db.addHSBtoPalette(palList, sat_func_255 ) -- db.drawHSBdiagram, Note that addHSB uses 0 graytolerance and other values causes errors!?

palList = db.addUnNormalizedBrightness2Palette(palList)

BG = getbackcolor() 
if NOBG == 1 then
 r,g,b = getcolor(BG)
 palList = db.strip_RGB_FromPalList(palList,r,g,b)
end

--palList = db.stripBlackFromPalList(palList)


picX = 640
picY = 432
cntX = 610
cntY = 406

setpicturesize(picX,picY)
--Clearcolor = db.getBestPalMatchHYBRID({100,100,100},palList,0.25,true)
Clearcolor = matchcolor(100,100,100)
clearpicture(Clearcolor)

-- Global offset
OX = 17
OY = 16
RIGHT_MARGIN = OX + cntX 

BlackBG = matchcolor(0,0,0)
db.drawRectangle(OX,OY,cntX,cntY,BlackBG)


function upd() updatescreen(); waitbreak(0); end


-- Easy Text Interface
function txt(xpos,ypos,txt)
 local hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag,font_f
--
font_f = font_mini_3x4
-- font_f:  Font data (function), will use built-in font by default, use anything undefined as argument, f.ex. 'f' 
-- txt:     Text
-- xpos,ypos: text screen location
hspace = 1
vspace = 1            -- Letter spacing, horizontal/vertical
maxwidth = 1000       --   Paragraph/Box width (i.e point where ONE MORE word is allowed)
col = {255,255,255}   -- RGB colorvalue {r,g,b}
transparency = 0      -- transparency 0..1, 0 = No Transparency
linebreak_char = "|"  -- character that will function as linebreak
aa_str = 0.85            -- AA strength, 1 = Normal/full AA, 0 = No AA,Solid color. For Dark text on bright bg use about 0.5.
clear_flag = false    --  restore background when overwriting text (true/false). 
--             When doing text+shadow use true for shadow and false for text. 
--             Overwriting old text+shadow requires a restoration of the previous text (an extra leading print with 'true')

text.write(font_f,txt,xpos,ypos,hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag)
end

-- Easy Text Interface
function txt2(xpos,ypos,txt,big) -- dark
 local hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag,font_f
--
if big ~= 1 then
 font_f = font_mini_3x4
end
-- font_f:  Font data (function), will use built-in font by default, use anything undefined as argument, f.ex. 'f' 
-- txt:     Text
-- xpos,ypos: text screen location
hspace = 1
vspace = 1            -- Letter spacing, horizontal/vertical
maxwidth = 1000       --   Paragraph/Box width (i.e point where ONE MORE word is allowed)
col = {0,0,0}   -- RGB colorvalue {r,g,b}
transparency = 0.25      -- transparency 0..1, 0 = No Transparency
linebreak_char = "|"  -- character that will function as linebreak
aa_str = 0.8            -- AA strength, 1 = Normal/full AA, 0 = No AA,Solid color. For Dark text on bright bg use about 0.5.
clear_flag = false    --  restore background when overwriting text (true/false). 
--             When doing text+shadow use true for shadow and false for text. 
--             Overwriting old text+shadow requires a restoration of the previous text (an extra leading print with 'true')

text.write(font_f,txt,xpos,ypos,hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag)
end



---- NEW OFFSETS ----



SPECTRUM_X = OX + 1
SPECTRUM_Y1 = OY + 100
SPECTRUM_Y2 = OY + 132
SPECTRUM_Y3 = OY + 164
SPECTRUM_WD = 6

GRAY_X = OX + 1
GRAY_Y = OY + 1
GRAY_W = 10

HSB1_X = OX + 19  +16
HSB2_X = OX + 111 +16
HSB3_X = OX + 203 +16
HSB_Y  = OY + 1
HSB_WD = 90
HSB_HT = 96

BRIMATCH_X = OX + 295 +16
BRIMATCH_Y = OY + 1
BRIMATCH_W = 20
BRIMATCH_H = 192

ISOCUBE_X = OX + 340 +15
ISOCUBE_Y = OY + 3

BIGBRIHUE_X = OX + 381 + 16 + 2
BIGBRIHUE_Y = OY + 92

SATBRIHUE_X = OX + 334 + 16 + 2 --small 3 saturation level bri-hue diagrams
SATBRIHUE_Y = OY + 92

MAINPAL_X = OX + 1
MAINPAL_Y = OY + 215 - 1
MAINPAL_WIDTH = 512 -- 512
MAINPAL_HEIGHT = 10

-- RoYGCaBvM ramp-diagrams
TRIRAMP_X  = OX + 513 --96
TRIRAMP_Y  = OY + 218 --197 --244
TRIRAMP_W  = 96 -- even values
-- Heigths
TRIRAMP_H1 = 3  -- #1: bw=0, solid ramp
TRIRAMP_H2 = 10 -- #2: bw = 0.1 to 0.85
TRIRAMP_H3 = 4  -- #3 Best Colormatch ramp. bw = 0.2 to 0.7

HALFSHADE_LIMIT = 64 -- Also limit for Neutralizers

-- 8 shades crashes with 256 colors!??
-- Will not produce a full table with DB16 and 32 shades
-- Only 16 seem reliable, must investigate
MIXDITHER_SHADES = 16  -- shades: 16 = 12bit, very slow with more shades, seem to flip out at 64.
MIXDITHER_LIMIT  = 64 -- Don't do mixes for palettes with more colors than this 
MIXDITHER_X = OX + 533
MIXDITHER_Y = OY + 1
MIXDITHER_WD = 10 -- width  11,9,1,16,7
MIXDITHER_HT = 9  -- height
MIXDITHER_SP = 1  -- spacing
MIXDITHER_XN = 7 -- Columns
MIXDITHER_YN = 7  -- rows


POLAR_X = OX + 137 --96
POLAR_Y = OY + 251
POLAR_SAT_HI = 255
POLAR_SAT_LO = 96

--
COLSPACE12_X = OX + 1 -- 20
COLSPACE12_Y = OY + 256
--

-- Closest colors
CLOSEST_N = 10 
CLOSEST_W = 9
CLOSEST_H = 9
CLOSEST_X  = OX + 206 
CLOSEST_Y1 = OY + 149      
CLOSEST_Y2 = OY + 149 + 20 
CLOSEST_BW_LO = CBW1 / 100 --0.10
CLOSEST_BW_HI = CBW2 / 100 --0.7

-- Small palette, doubles marked
PALTABLE_X  = OX + 205 + 3 -- 0 
PALTABLE_Y  = OY + 100 + 7 -- 244
PALTABLE_WD = 3
PALTABLE_HT = 4
PALTABLE_TXT_Y = PALTABLE_Y - 7
PALTABLE_TXT_X = PALTABLE_X - 2

-- Saturation diagram
if #palList <= MIXDITHER_LIMIT then
 SATCOMP_X = OX + 533 --443 --220
 SATCOMP_Y = OY + 82 --250 --105
 SATCOMP_WD = 74
 SATCOMP_COLS = 64 --74 --44
  else -- Make SatComp diagram bigger by using the space of missing MixDither
 SATCOMP_X = OX + 533
 SATCOMP_Y = OY + 6
 SATCOMP_WD = 74
 SATCOMP_COLS = 104
end


-- Complementary diagrams
COMP_X = OX + 296
COMP_Y = OY + 256
COMP_W = 70
COMP_H = 70

-- Hue-Sat Diagram
HUESAT_RD = 52
HUESAT_CX = OX + 60
HUESAT_CY = OY + 346


----------------------

if #palList <= MIXDITHER_LIMIT then
 t = "USEFUL MIXES"
 for n = 1, #t, 1 do
  txt2(RIGHT_MARGIN + 4, OY + 1 + (n-1)*6, string.sub(t,n,n), 1)  
 end
end

--t = "SATURATION" -- +32
t = "BRI & SATURATION"
for n = 1, #t, 1 do
 txt2(RIGHT_MARGIN + 4, SATCOMP_Y + (n-1)*6 + 14, string.sub(t,n,n), 1)  
end

t = "ROYGCABVM"
for n = 1, #t, 1 do
 txt2(RIGHT_MARGIN + 4, TRIRAMP_Y +  (n-1)*21 + 6, string.sub(t,n,n), 1)  
end

VERSION_X = 270
VERSION_Y = 2
txt(VERSION_X,VERSION_Y,"- Analyze Palette V"..VERSION.." -") 

REPORT_X = 2
REPORT_Y = 2
txt(REPORT_X,REPORT_Y,"Unique cols in pal: "..#palList) 

t = "* SATURATION MODEL: "..sat_txt
txt(picX - #t*4 - 1, 2, t)


txt(PALTABLE_TXT_X - 1,PALTABLE_TXT_Y,"INDEXED PALETTE:")  -- X=-1 Because of leading "i" 

txt(SATBRIHUE_X,SATBRIHUE_Y-5,"* SAT") 
--txt(SATBRIHUE_X,SATBRIHUE_Y-5,"PURITY") 
txt(BIGBRIHUE_X+103,BIGBRIHUE_Y-5,"BRI-HUE") 

txt(CLOSEST_X,CLOSEST_Y1-5,            "CLOSE COLS: "..(CLOSEST_BW_LO*100).."% BRI-MATCH") 
txt(CLOSEST_X,CLOSEST_Y2+CLOSEST_H*2+1,"CLOSE COLS: "..(CLOSEST_BW_HI*100).."% BRI-MATCH") 

txt(POLAR_X,POLAR_Y,"S:"..POLAR_SAT_HI)
txt(POLAR_X+133,POLAR_Y+150,"S:"..POLAR_SAT_HI)
txt(POLAR_X+137,POLAR_Y+59,"S:"..POLAR_SAT_LO)
txt(POLAR_X,POLAR_Y+91,"S:"..POLAR_SAT_LO)

txt(COLSPACE12_X+1,COLSPACE12_Y-5,"12 BIT COLSPACE")

wd = GRAY_W + 1
txt2(GRAY_X,GRAY_Y-6,"R0") 
txt2(GRAY_X+wd,GRAY_Y-6,"50") 
txt2(GRAY_X+wd*2,GRAY_Y-6,"85") 

txt2(HSB1_X,HSB_Y-7, "*SAT:"..dia_sat[1], 1) 
txt2(HSB2_X,HSB_Y-7, "*SAT:"..dia_sat[2], 1) 
txt2(HSB3_X,HSB_Y-7, "*SAT:"..dia_sat[3], 1)  

txt2(BRIMATCH_X,OY-5,"BRI-MATCH",0) 

txt2(ISOCUBE_X+35,OY-6,"RGB-COLORSPACE (ISO)",1) 

sp = SPECTRUM_WD
txt2(SPECTRUM_X-5*3-2,SPECTRUM_Y1,      "B65%", 0) 
txt2(SPECTRUM_X-5*3-2,SPECTRUM_Y1+sp+1, "B10%", 0)
txt2(SPECTRUM_X-5*3-1,SPECTRUM_Y1+sp*2+3, "S50", 1)
txt2(SPECTRUM_X-5*3-1,SPECTRUM_Y1+sp*3+4, "L50", 1)

if #palList <= HALFSHADE_LIMIT then
 txt2(MAINPAL_X-5*3-1,MAINPAL_Y-14,"NEU",1)  
 txt2(MAINPAL_X-5*3-2,MAINPAL_Y-7,"GRAY",0) 
 txt2(MAINPAL_X-5*3-1,MAINPAL_Y+12,"HLF",1)   
end
 
txt2(MAINPAL_X-5*3-1,MAINPAL_Y+2,"PAL",1)  
   

BOTTOM = 423
txt2(185,BOTTOM,"* POLAR HUE-BRIGHTNESS",1)  

txt2(345,BOTTOM,"COMPLEMENTARIES / DESATURATION",1)

txt2(43,BOTTOM,"* HUE-SATURATION",1)  

txt2(550,BOTTOM,"PRIMARY RANGES",1) 


-------------------------
--LOWEROFFSET = 40 + 20 -- Bottom 1/2 Content Offset







--
function desat_bri(desat,bri,c) -- average desaturation, desat%, "brightness" is in %, c is a pointer to a reused list (don't alter it)
 
 local cnew
 cnew = {c[1],c[2],c[3]}

 if bri ~= 0 then
  cnew = db.lightness(bri,c) -- I think Lightness before Desaturation is best
  --cnew[1] = c[1] + bri*2.55;  cnew[2] = c[2] + bri*2.55;  cnew[3] = c[3] + bri*2.55 -- bri is %
 end

 if desat ~= 0 then
  --cnew = db.desatAVG(desat,cnew) -- I think Lightness before Desaturation is best
  cnew = db.desaturateBri_A(desat,cnew)
 end

 return cnew

end
--

-- Now supports any range (steps/resolution)
function drawRamp(len,wid,ori,range,ox,oy,rgb1,rgb2,crop,desat,bri,gap,pal_list,bri_weight)

  local c,m,l,yp,ry,rx,aX,aY,rcx,rcy,rd,gd,bd,sx,sy,rgb,r,g,b,nolist,Max,Floor,ofx,xsize,xsiz,ysiz,rng1

  bri_weight = bri_weight or 0.1

  Max,Floor = math.max, math.floor

  --if desat ~= 0 or bri ~= 0 then 
  --  rgb1 = desat_bri(desat,bri,rgb1)
  --  rgb2 = desat_bri(desat,bri,rgb2)
  --end

  --range = 96

  ry = len / (range - crop)
  rx = wid

  rng1 = range - 1

  aX = 0
  aY = ry

  -- Add another pixel or two to the colorcells if crop/scale to avoid gaps (hope this works ok)
  rcx = 1
  rcy = 1
  if gap > 0 then
    if ori == 1 then
      rcx = 0 else rcy = 0
    end
  end

  if ori == 1 then ry,rx = rx,ry; aX,aY = aY,aX; end -- swap orientation 0 == vertical, 1 == horizontal

  rd = (rgb2[1] - rgb1[1]) / rng1
  gd = (rgb2[2] - rgb1[2]) / rng1
  bd = (rgb2[3] - rgb1[3]) / rng1

  nolist = false; if pal_list == nil or #pal_list == 0 then nolist = true; end

  xsiz = Floor(Max(0,rx - rcx))
  ysiz = Floor(Max(0,ry - rcy))

  for l = 0, range - (1 + crop), 1 do

   m = l
 
    r = db.cap(rgb1[1] + rd*m) -- could produce negative values
    g = db.cap(rgb1[2] + gd*m)  
    b = db.cap(rgb1[3] + bd*m)

    if desat ~= 0 or bri ~= 0 then -- Apply effect to each value in gradient rather than interpolating the adjusted keypoints
     rgb = desat_bri(desat,bri,{r,g,b}) 
     r,g,b = rgb[1],rgb[2],rgb[3]
      -- else
      --  rgb = {r,g,b}
    end

   if nolist then
    c = matchcolor2(r,g,b, bri_weight); -- Not in use?, Perceptual RGB-space, 10% Brightness weight (fairly colortrue)
    --c = matchcolor(rgb[1],rgb[2],rgb[3])
    else
     --c = db.getBestPalMatchHYBRID(rgb,pal_list,bri_weight,true); -- return index of Grafx2 pal color
     c = db.getBestPalMatch_Hybrid(r,g,b,pal_list,bri_weight,true) -- Unnormalized bri version
     --c = matchcolor2(rgb[1],rgb[2],rgb[3], bri_weight) -- not 100% eq. to Hybrid
   end


   --[[
   -- One Step/Cell
   ofx = ox + aX*l
   xsize = Max(0,rx - rcx)
   for sy = 0, Max(0,ry - rcy), 1 do -- max to assure long ranges (small steps will work)
    yp = oy+sy + aY*l
    for sx = 0, xsize, 1 do
       putpicturepixel(sx + ofx, yp, c);
    end
   end
   --]]

   ofx = ox + aX*l
   ofy = oy + aY*l
   drawfilledrect(ofx,ofy, ofx+xsiz,ofy+ysiz, c)

  end;
end
--

--
function drawPackage(pack,range,len,wid,posx,posy,ori,scale,crop,desat,bri,gap,pal_list,bri_weight)

 local ox,oy,n,r,ramps,thiscrop,cols,rgb1,rgb2,bridif,size,abs,c1,c2,seg,scl

 abs = math.abs

 curX = posx
 curY = posy

 for n = 1, #pack, 1 do    -- {{BLK,BLU},{BLU,WHT},{WHT,GRN}}
 
   ramps = pack[n]
 
   seg = len / #ramps
   scl = len / scale

   for r = 1, #ramps, 1 do -- {BLK,BLU}

     -- If crop, skip last color on all but the last ramp
     thiscrop = 0
     if crop == 1 and r ~= #ramps then thiscrop = 1; end

     cols = ramps[r]
     c1,c2 = cols[1],cols[2]

     rgb1 = c1[2] 
     rgb2 = c2[2]
   bridif = abs(c1[1] - c2[1])
   
     size = seg
     if scale > 0 then -- wtf???
       --size = bridif / scale * len  -- Scale ramp colors to uniform brightness, Scale is max brightness diff in ramps/packiges (now 12 = max)
       size = bridif * scl 
     end

     ox = curX
     oy = curY
     if ori == 0 then curY = curY + size; end -- Track ramp position according to orientation
     if ori == 1 then curX = curX + size; end

     drawRamp(size,wid,ori,range,ox,oy,rgb1,rgb2,thiscrop,desat,bri,gap,pal_list,bri_weight)

   end
 
   if ori == 0 then curX = curX + wid; curY = posy; end -- Track ramp position according to orientation
   if ori == 1 then curY = curY + wid; curX = posx; end
 end

end
--

-- ***********************************************************



-- 48 Brightness steps 48 * 4 = 192, 192 / 2 = 96, 192/3 = 64
-- Size must be divisible by 2, 3 and range to avoid gaps

BLK = {  0, {0,  0,  0}   } -- first is some weird "scale brightness" value!? Not in use I think
WHT = { 12, {255,255,255} }
RED = {  4, {255,0,  0}   }
GRN = {  4, {0,  255,0}   }
BLU = {  4, {0,  0,  255} }
YEL = {  8, {255,255,0}   }
MAG = {  8, {255,0,  255} }
TUR = {  8, {0,  255,255} }
ORA = {  6, {255,127,0}   }
YGR = {  6, {127,255,0}   }
GRT = {  6, {0  ,255,127} }
TBL = {  6, {0,  127,255} }
BLM = {  6, {127,0,255}   }
MRD = {  6, {255,0,127}   }
GRY = {  6, {127,127,127} }


-- Hue-Saturation Diagram
min_sz = 2; if #palList > 24 then min_sz = 1; end
max_sz = 4;
if #palList > 64 then max_sz = 3; end
if #palList > 128 then max_sz = 2; end
db.drawHueSaturationDiagram(sat_func_frac, palList, HUESAT_CX,HUESAT_CY,HUESAT_RD, min_sz,max_sz)


--db.polarHSBdiagram(ox*1,oy,radius,pol,brilev,huelev,hisat,dark)
--brilev = 128
--pol = math.floor(0.3 + math.sqrt(brilev/2))
--rad = 40
--db.polarHSBdiagram(98+rad,244+rad,rad,pol,brilev,120,255,dark)

ox = POLAR_X
oy = POLAR_Y
radius = 45
pol_exp = 1.25
dark2bright_flag = false
--db.polarHSBdiagram_Pixel(palList,ox,oy,radius,saturation,pol_exp,dark2bright_flag)
wd = radius * 2 + 1 
w23 = radius * 2 * 2^0.5/2 + 1
db.polarHSBdiagram_Pixel(palList,ox,     oy,radius,POLAR_SAT_HI,pol_exp,false)
db.polarHSBdiagram_Pixel(palList,ox+w23*1,oy+w23*1,radius, POLAR_SAT_HI,pol_exp,true)

db.polarHSBdiagram_Pixel(palList,ox+wd*1,oy,radius*2/3+1, POLAR_SAT_LO, pol_exp,false)
db.polarHSBdiagram_Pixel(palList,ox+1,oy+wd*1+1,radius*2/3+1, POLAR_SAT_LO, pol_exp,true)


-- Complementary diagrams
data = {
 {{255,0,0},   "Red/Cyan"},
 {{255,127,0}, "Orange/Azure"},
 {{255,255,0}, "Yellow/Blue"},
 {{127,255,0}, "Chartreuse/Violet"},
 {{0,255,0},   "Green/Magenta"},
 {{0,255,127}, "Spring-Green/Rose"}
}
ox = COMP_X
oy = COMP_Y
xsize = COMP_W
ysize = COMP_H
sp = 2
ts = 5
bw = 0.25
for y = 0, 1, 1 do
 for x = 0, 2, 1 do
  o = data[y*3+x+1]; rgb,t = o[1],o[2]
  px = ox + (xsize+sp)*x
  py = oy + (ysize+sp+ts+2)*y
  --db.drawRectangleLine(px-1,py-1,xsize+2,ysize+2,matchcolor(0,0,0))  
  txt(px,py-ts,t, 1)  
  db.complementaryDiagram(px,py,xsize,ysize,palList,rgb[1],rgb[2],rgb[3],bw)
end
end
--




-- Grayscales
ox = GRAY_X
oy = GRAY_Y
wd = GRAY_W
--pack,range,len,wid,posx,posy,ori,scale,crop,desat%,lightness%,gapfix, pal_list,bri_weight)
drawPackage({{{BLK,WHT}}}, 32, 96, wd, ox,oy, 0, 0, 0, 0, 0, 0, palList, 0.0)
-- Grayscale Brightness matched
-- why did/do we have 1.0 lightness??? It does work better with Aurora256 though. Better with DB32. (No diff on DB16)
drawPackage({{{BLK,WHT}}}, 96, 96, wd, ox+(wd+1)*1,oy, 0, 0, 0, 0, 0.0, 0, palList, 0.5) 
drawPackage({{{BLK,WHT}}}, 96, 96, wd, ox+(wd+1)*2,oy, 0, 0, 0, 0, 0.0, 0, palList, 0.85) 


-- Pal, posz,posy,width,height,size,saturation
db.drawHSBdiagram(palList, HSB1_X,HSB_Y, HSB_WD,HSB_HT,1, dia_sat[1]) -- x,y, xcells,ycells,res, sat
db.drawHSBdiagram(palList, HSB2_X,HSB_Y, HSB_WD,HSB_HT,1, dia_sat[2])
db.drawHSBdiagram(palList, HSB3_X,HSB_Y, HSB_WD,HSB_HT,1, dia_sat[3])

upd()

-- ISOCUBES
ISOWIDTH = 80
-- ox,oy,width,zscale,pallist,plotscale,view, bri_base, bri_mult --zscale is height, nom=1.0
db.drawIsoCubeRGB_Diagram(ISOCUBE_X,              ISOCUBE_Y, ISOWIDTH, 1.0, palList,0.25,1, 32,16)
db.drawIsoCubeRGB_Diagram(ISOCUBE_X + ISOWIDTH+7, ISOCUBE_Y, ISOWIDTH, 1.0, palList,0.25,2, 32,16)


upd()

--
--db.drawColorspace12bit(COLSPACE12_X,COLSPACE12_Y,8,1)
db.drawColorspace12bit_fromPalList(COLSPACE12_X,COLSPACE12_Y,8,1, palList) -- Allows omitting BG-col
--

upd()

-- Bri-Match + BriLevel Diagrams
bx = BRIMATCH_X
by = BRIMATCH_Y
wd = BRIMATCH_W
ht = BRIMATCH_H
cspace,cwidth = 3,2
if #palList > 64 then cspace,cwidth = 2,1; end
db.drawBriMatchDiagram(palList,bx,by,wd,ht); upd() 
db.drawBriLevelDiagram(palList,bx+wd+1,by,ht, cspace,cwidth)
--

upd()

-- Big BriHue Diagram
graytolerance = 0.095 --0.06-0.065 seem good
big_sz = math.min(7, math.floor(48 / math.sqrt(#palList))) 
xsize = 130
ysize = 91 + 8
space = math.floor(big_sz/2)+0 -- frame spacing
britrace_len = 3          -- Color Brightness lines, length in dots
if #palList > 64 then britrace_len = 0; end
britrace_mono_flag = true -- Use grayscale rather than colored dots 
frame_flag   = true       -- Draw framing box
 grid_flag   = true       -- Draw grids, Primary Hue lines and 3 grayscales
briplot_flag = true       -- Plot Brightness positions at bottom

db.drawBriHuePlotDiagram(palList,BIGBRIHUE_X,BIGBRIHUE_Y,xsize,ysize,space,big_sz,graytolerance,  britrace_len, britrace_mono_flag, briplot_flag, frame_flag, grid_flag)
--

upd()

 -- Small HueBri diagrams
 yf = SATBRIHUE_Y
 xf = SATBRIHUE_X
-- Small boxes sat used to be (Hybrid HSL+True)/2
-- db.drawSatLevelsBriHue_Diagrams(Levels, sat_f, pallist, xpos,ypos, Width, Height, plotsize, spacing, padding, gauge_flag, gauge_width)
--db.drawSatLevelsBriHue_Diagrams(3, db.getRealSaturation_255, palList, xf,yf, 46, 33, 0.5, -1, 0, true, 1)
db.drawSatLevelsBriHue_Diagrams(3, sat_func_255, palList, xf,yf, 46, 33, 0.5, -1, 0, true, 1, greytolerance)

upd()

-- Saturation diagram
xp  = SATCOMP_X
yp  = SATCOMP_Y
wd  = SATCOMP_WD
col = SATCOMP_COLS -- 64 as default

-- Current space available ~ 132 pixels, 64 cols = 1 bar+1 space = 2*64 = 128 pixel diagram
n = #palList
if n <= 42 then col,siz = 42,2; end
if n <= 32 then col,siz = 32,3; end
if n <= 24 then col,siz = 24,4; end
if n <= 16 then col,siz = 16,6; end


txt(xp,yp-5,sat_txt2)
--t = "* "..sat_txt
t = "* Sat"
txt(xp+wd-#t*4 + 2,yp-5, t) --txt(xp+wd-15-2*4,yp-5,"PURITY")
--db.saturationComp_Diagram(sat_f1,sat_f2,pallist,xpos,ypos,width,cols,separation, size,bspace, horizontal_flag)
--db.saturationComp_Diagram(db.getSaturation,db.getRealSaturation_255,palList, xp,yp, wd, col, 3, 1,1, false)
db.saturationComp_Diagram(sat_func_comp1, sat_func_comp2,palList, xp,yp, wd, col, 3, siz,1, false)
--

upd()

---------------


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

-- old bri spot


--for n = 1, 12, 1 do drawCircle(32 + n*16,307,n/2,1); end

-- Scale: Adjust ramps to uniform brightness, 0 = no scaling, 12 = max brigtness diff (As in any range from black-x-white)
-- Ori:   Ramp orientation: 0 = Vertical, 1 = Horizontal
-- Crop:  don't draw last color (i.e. to make ranges like B-R-W rather than B-RR-W), length of colorcells scaled up accordingly



         --pack,range,len,wid,posx,posy,ori,scale,crop,desat%,lightness%,gapfix, pal_list,bri_weight)

RANGE = 16
WID = 6
LEN = 96  -- at least 6*RANGE to assure no gaps etc.
STP = 75


-- Spectrum Ramp Diagram
--[[
  rmp1 = { {{BLK,RED},{RED,WHT}}, {{BLK,ORA},{ORA,WHT}}, {{BLK,YEL},{YEL,WHT}}, {{BLK,YGR},{YGR,WHT}}, 
           {{BLK,GRN},{GRN,WHT}}, {{BLK,GRT},{GRT,WHT}}, {{BLK,TUR},{TUR,WHT}}, {{BLK,TBL},{TBL,WHT}},
           {{BLK,BLU},{BLU,WHT}}, {{BLK,BLM},{BLM,WHT}}, {{BLK,MAG},{MAG,WHT}}, {{BLK,MRD},{MRD,WHT}}}
  
drawPackage(rmp1, RANGE, LEN, WID, 203,0, 0, 12, 1, 0,      0, 1, palList, Bri) -- Old spectrum diagram

--]]


function bri(r,g,b)
 --return (r+g+b) / 63.75
 return -1 -- this shit ain't used anymore?
end



-- Find pseudo-primaries
--messagebox(matchcolor2(255,0,0))
match = matchcolor -- We're looking for archetypical colors rather good brightness matches
r,g,b = getcolor(match(255,0,0))
_red = {  bri(r,g,b), {r,  g,  b}   }
r,g,b = getcolor(match(0,255,0))
_grn = {  bri(r,g,b), {r,  g,  b}   }
r,g,b = getcolor(match(0,0,255))
_blu = {  bri(r,g,b), {r,  g,  b}   }
r,g,b = getcolor(match(255,255,0))
_yel = {  bri(r,g,b), {r,  g,  b}   }
r,g,b = getcolor(match(255,0,255))
_mag = {  bri(r,g,b), {r,  g,  b}   }
r,g,b = getcolor(match(0,255,255))
_tur = {  bri(r,g,b), {r,  g,  b}   }
r,g,b = getcolor(match(0,0,0))
_blk = {  bri(r,g,b), {r,  g,  b}   }
r,g,b = getcolor(match(255,255,255))
_wht = {  bri(r,g,b), {r,  g,  b}   }
r,g,b = getcolor(match(127,127,127))
_gry = {  bri(r,g,b), {r,  g,  b}   }
r,g,b = getcolor(match(255,127,0))
_ora = {  bri(r,g,b), {r,  g,  b}   }
r,g,b = getcolor(match(127,255,0))
_ygr = {  bri(r,g,b), {r,  g,  b}   }
r,g,b = getcolor(match(0,255,127))
_grt = {  bri(r,g,b), {r,  g,  b}   }
r,g,b = getcolor(match(0,127,255))
_tbl = {  bri(r,g,b), {r,  g,  b}   }
r,g,b = getcolor(match(127,0,255))
_blm = {  bri(r,g,b), {r,  g,  b}   }
r,g,b = getcolor(match(255,0,127))
_mrd = {  bri(r,g,b), {r,  g,  b}   }

--drawPackage(pack,range,len,wid,posx,posy,ori,scale,crop,desat,bri,gap,pal_list,bri_weight)


-- Top-left spectrum ramps
LEN = 192 + 8 
rmp1 = { {{YEL,BLU},{BLU,GRN},{GRN,RED},{RED,MAG},{MAG,TUR}} }
wd = SPECTRUM_WD
d = SPECTRUM_WD + 1
ox = SPECTRUM_X
oy = SPECTRUM_Y1 
RES = LEN -- 16
rmp = { {{_yel,_blu},{_blu,_grn},{_grn,_red},{_red,_mag},{_mag,_tur}} }
drawPackage(rmp, RES, LEN, wd, ox, oy,       1, 0, 0,  0,  0,   1, palList, 0.65)
upd()
drawPackage(rmp1,RES, LEN, wd, ox, oy+d*1,   1, 0, 0,  0,  0,   1, palList, 0.1)
upd()
drawPackage(rmp1,RES, LEN, wd, ox, oy+d*2+1, 1, 0, 0, 50,  0,   1, palList, 0.25) -- 50% desat
upd()
drawPackage(rmp1,RES, LEN, wd, ox, oy+d*3+1, 1, 0, 0,  0,-50,   1, palList, 0.25) -- 50% darker (Lightness)
upd()

rmp1 = { {{GRN,MAG},{MAG,YEL},{YEL,TUR},{TUR,RED},{RED,BLU}} }
wd = SPECTRUM_WD
d = SPECTRUM_WD + 1
ox = SPECTRUM_X
oy = SPECTRUM_Y2
wd = SPECTRUM_WD
rmp = { {{_grn,_mag},{_mag,_yel},{_yel,_tur},{_tur,_red},{_red,_blu}} }
drawPackage(rmp, RES, LEN, wd, ox, oy,       1, 0, 0,  0,  0, 1, palList, 0.65)
upd()
drawPackage(rmp1,RES, LEN, wd, ox, oy+d*1,   1, 0, 0,  0,  0, 1, palList, 0.1)
upd()
drawPackage(rmp1,RES, LEN, wd, ox, oy+d*2+1, 1, 0, 0, 50,  0, 1, palList, 0.25) -- 50% desat
upd()
drawPackage(rmp1,RES, LEN, wd, ox, oy+d*3+1, 1, 0, 0,  0,-50, 1, palList, 0.25) -- 50% darker
upd()

rmp1 = { {{RED,YEL},{YEL,GRN},{GRN,TUR},{TUR,BLU},{BLU,MAG}} }
wd = SPECTRUM_WD
d = SPECTRUM_WD + 1
ox = SPECTRUM_X
oy = SPECTRUM_Y3
rmp = { {{_red,_yel},{_yel,_grn},{_grn,_tur},{_tur,_blu},{_blu,_mag}} }
drawPackage(rmp, RES, LEN, wd, ox, oy,       1, 0, 0,  0,  0, 1, palList, 0.65)
upd()
drawPackage(rmp1,RES, LEN, wd, ox, oy+d*1,   1, 0, 0,  0,  0, 1, palList, 0.1)
upd()
drawPackage(rmp1,RES, LEN, wd, ox, oy+d*2+1, 1, 0, 0, 50,  0, 1, palList, 0.25) -- 50% desat
upd()
drawPackage(rmp1,RES, LEN, wd, ox, oy+d*3+1, 1, 0, 0,  0,-50, 1, palList, 0.25) -- 50% darker
upd()


--[[ -- GRAY TO COLORS
x = 195
y = 100
s = 68
d = 7
--pack,range,len,wid,posx,posy,ori,scale,crop,desat%,lightness%,gapfix, pal_list,bri_weight)
                                                      --D--L--g
drawPackage({{{GRY,RED}}}, 16, s, 6, x+d*0, y, 0, 0, 0, 0, 0, 1)
drawPackage({{{GRY,GRN}}}, 16, s, 6, x+d*1, y, 0, 0, 0, 0, 0, 1)
drawPackage({{{GRY,BLU}}}, 16, s, 6, x+d*2, y, 0, 0, 0, 0, 0, 1)
drawPackage({{{GRY,YEL}}}, 16, s, 6, x+d*3, y, 0, 0, 0, 0, 0, 1)
drawPackage({{{GRY,TUR}}}, 16, s, 6, x+d*4, y, 0, 0, 0, 0, 0, 1)
drawPackage({{{GRY,MAG}}}, 16, s, 6, x+d*5, y, 0, 0, 0, 0, 0, 1)
drawPackage({{{GRY,ORA}}}, 16, s, 6, x+d*6, y, 0, 0, 0, 0, 0, 1)
--]]

--pack,range,len,wid,posx,posy,ori,scale,crop,desat%,lightness%,gapfix, pal_list,bri_weight)


-- Analysis --



--for n = 0, 255, 1 do
--  db.drawRectangle(n*w,182,w,8,n)
--end

-- Find Halfshade: HSL method (preserves saturation, but is unreliable in brightness)
-- halfshade: lightness fraction, nominal = 0.5
-- topshade: lightness fraction, halfshade..1.0, 1.0 = Original color, nominal = 0.75
-- returns palette index
function findHalfshade_hsl(r,g,b,pallist)
 local c,l,hue,sat,lig,r1,g1,b1,r2,g2,b2,dist,min_dist,min_col,step,co,penalty,maxshade,darkboost,halfshade,topshade
 penalty   = 10 -- penalty multiple, 25% off with 1000 penalty = +62.5 in distance
 halfshade = 0.65
 topshade  = 0.2 + 0.575 -- halfshade..1.0 (note: Lower topshade allows darkboost to enhance dark color ranges over bright ones)
 darkboost = 1.0 -- Fraction of max, 1.0 == full range
 step = 0.025
 hue = db.getHUE(r,g,b, 0.2) / 6  -- Note inc. greytolerance to avoid near grays matched with hi sat cols
 --hue = math.max(0,hue - 0.025)

 --if hue > 0.92 then hue = hue - 0.05; end
 --if math.abs(hue - 0.08) < 0.08 then hue = (1 + hue - 0.05) % 1; end
 
 if math.abs(hue - 0.1666) < 0.08 then hue = hue - (0.0555 - math.abs(hue - 0.1666)/3); end -- Make Yellow turn towards orange

 sat = db.getSaturation(r,g,b) / 255
 lig = db.getLightness(r,g,b) / 255
 min_dist = 256
 min_col = -1; -- fail, don't draw code
 co = db.getBestPalMatchHYBRID({r,g,b},pallist,0,true)
  
 maxshade = topshade + (1-topshade)*(1-lig)^3*darkboost -- Potential boost * darkness * boost

 while min_col == - 1 and halfshade >= 0 do -- make sure dark colors get a match
 for l = lig*halfshade, lig*maxshade, step do
   r1,g1,b1 = db.HSLtoRGB(hue, sat, l)

   --c = matchcolor(r1,g1,b1) -- No brightness weight for more true hue
   --c = db.getBestPalMatchHYBRID({r1,g1,b1},pallist,0,true)
   c = db.getBestPalMatch_Hybrid(r1,g1,b1,pallist,0,true)

   if c ~= co then -- Don't match with source color, THIS WILL FAIL FOR DARKEST COLOR AND DEFAULT TO INDEX 255 (min_col = -1)
    r2,g2,b2 = getcolor(c)
    dist = (lig*halfshade-l)^2*penalty + db.getColorDistance_weightNorm(r1,g1,b1,r2,g2,b2,0.26,0.55,0.19) -- penalty + dist
    if dist < min_dist then min_dist = dist; min_col = c; end
   end
 end
 halfshade = halfshade - 0.05
 end


 return min_col
end
--

--co = matchcolor2(20/2,12/2,28/2)
--messagebox(co)

-- Not in use
function findHalfshade_bri(r,g,b,pallist)
 local v,c,l,n,i,p,hue,sat,satd,bri,brih,brid,r1,g1,b1,r2,g2,b2,dist,score,min_score,min_col,co,sat2,hue2,hsdist,bri2
 local top,maxshade,darkboost,halfshade,topshade,hisat,spots,brilim,totalbrilimit
 halfshade = 0.52 -- Fractions of full color 1.0
 topshade  = 0.70 -- halfshade..1.0 (note: Lower topshade allows darkboost to enhance dark color ranges over bright ones)
 darkboost = 0.5 -- Fraction of max, 1.0 == full range
 spots = 6 -- Test spots bewteen halfshade and topshade (1 = Half & top)
 brilim = 0.78 -- Highest allowed fractional brightness of halfshade 0.8 = max 80% of original color's brightness
 briadd = 0.1 -- Allowed increase of f.brightness for darker colors (full effect at black)
 hue = db.getHUE(r,g,b, 0.1) -- (0-6) Note inc. greytolerance to avoid near grays matched with hi sat cols
 
 -- If real saturation is higher than 30% then use HSL saturation for extra oomph (B.blue->blue in Arne16)
 -- Problem with some colors that would benefit from Real sat.
 hisat = false
 --sat = db.getRealSaturation(r,g,b)
 sat = db.getPurity(r,g,b)
 if sat > 0.3 then
  hisat = true
  sat = db.getSaturation(r,g,b) / 255
 end


 --lig = db.getLightness(r,g,b) / 255
 bri = db.getBrightness(r,g,b) / 255
 min_score = 999999
 min_col = -1
 co = matchcolor2(r,g,b)
 
 --function cap(v) return math.min(255,math.max(v,0)); end

 maxshade = topshade + (1-topshade)*(1-bri)^3*darkboost -- Potential boost * darkness * boost
 --maxshade = topshade
 --top = (maxshade-halfshade)

 --brifrac = (topshade - halfshade) * bri

 brih = db.getBrightness(r * halfshade, g * halfshade, b * halfshade) / 255

 totalbrilimit = brilim + briadd * (1-bri)

 for l = 0, spots, 1 do
   qwe()
   pr =  l / spots
   p  = 1 - pr 
   hf = halfshade * p + maxshade * pr
   r1 = r * hf --* (1-(b^0.5)/64-(g^0.5)/64)
   g1 = g * hf --* (1+(0.15 + (b^0.5)/32 - (r^0.5)/32 ))
   b1 = b * hf --* (1+(0.25 + (g^0.5)/4  - (r^0.5)/5 ))

   brih = db.getBrightness(r1, g1, b1) / 255

   for n = 1, #pallist, 1 do
    p = pallist[n]
    r2,g2,b2,i,hue2,sat2,bri2 =  p[1],p[2],p[3],p[4],p[5],p[6]/255,p[7]/255 -- r,g,b,i,hue,sat,bri
    if i ~= co and bri2 < bri and (bri2 / bri) < totalbrilimit then
     if hisat then
      sat2 = db.getSaturation(r2,g2,b2) / 255
      else
       --sat2 = db.getRealSaturation(r2,g2,b2)
       sat2 = db.getPurity(r2,g2,b2)
     end
     --hue2 = db.getHUE(r2,g2,b2, 0.2)
     hsdist = db.getHueSatDistanceC(hue,sat,hue2,sat2)
     dist = db.getColorDistance_weightNorm(r1,g1,b1,r2,g2,b2,0.26,0.55,0.19)
     brid = math.abs(brih - bri2) / brih -- Ideal halfshade / match differance 
     satd = math.abs(sat - sat2) -- Saturation of original colors
     score = dist*6.5 + brid*150 + satd*300*bri + hsdist*1500
       --if co == 3 and i == 0 then
       --messagebox(score)
       --end
     if score <= min_score then min_score = score; min_col = i; end
    end -- if i
   end -- n
 end -- l

 return min_col
end
--

--messagebox(db.getHUE(157,157,157, 0.2))




--
function gammaHalfshade(r,g,b,pallist,gamma)
 local c,c0,col,mult,r1,g1,b1

 --c0 = db.getBestPalMatchHYBRID({r,g,b},pallist,0,true)
 c0 = db.getBestPalMatch_Hybrid(r,g,b,pallist,0,true)

 col = -1

 while col == -1 and gamma >= 0 do -- The darkest colors may self-match even at gamma 1.0
  mult = 0.5^(1/gamma)
  r1,g1,b1 = r * mult, g * mult, b * mult
  --c = db.getBestPalMatchHYBRID({r1,g1,b1},pallist,0,true)
  c = db.getBestPalMatch_Hybrid(r1,g1,b1,pallist,0,true)
  if c ~= c0 then col = c; end
  gamma = gamma - 0.05
 end

 return col

end
--



--*** LOWER PART ***--

---------------------------------------------------------------------------------
-- Brightness Sorted Palette + Complementaries and HalfShades
---------------------------------------------------------------------------------

l = #palList
w = math.max(1,math.floor(MAINPAL_WIDTH / l))

posy  = MAINPAL_Y      -- Palette
posx  = MAINPAL_X
ys    = MAINPAL_HEIGHT
cmpy  = posy - 14      -- Complementary color
mixy  = posy - 8       -- Neutralized Mix
hlfy1 = posy + ys + 1  -- Halfshades
--hlfy2 = posy + ys + 1+ 7
--hlfy3 = posy + ys + 1+ 7 + 7


mixw = 0
if w <= 12 then mixw = 1; end -- make complemetary display wider for larger palettes

darkest = palList[1][4]
nextdarkest = palList[2][4]

DarkestIsBG = false; if darkest == BlackBG then DarkestIsBG = true; end

for n = 1, l, 1 do
 rgb = palList[n]
 co = rgb[4]

 --ColorIsBG = false; if darkest == BlackBG and co == darkest then ColorIsBG = true; end

 if co == darkest and DarkestIsBG then
  db.drawRectangleLine(posx+(n-1)*w,posy,w,ys,nextdarkest)
   else
    db.drawRectangle(posx+(n-1)*w,posy,w,ys,rgb[4])
 end

  -- Halfshades
  if l <= HALFSHADE_LIMIT then

   r,g,b = rgb[1],rgb[2],rgb[3]

   -- Complementary Grays
   i = db.findBestNeutralizer(2.0,r,g,b,palList)
   if i ~= -1 then
    db.drawRectangle(posx+(n-1)*w+2-mixw,cmpy,w-4+mixw*2,6, palList[i][4])
    db.drawRectangleMix(posx+(n-1)*w+3-mixw,mixy,w-6+mixw*2,7, rgb[4],palList[i][4])
   end

   --[[
   -- HSL fractions
   --hue = db.getHUE(r,g,b, 0) / 6
   hue = rgb[5] / 6
   --sat = db.getSaturation(r,g,b) / 255
   sat = rgb[6] / 255 -- This is REAL (addSHBtoPalette) not HSL
   --lig = db.getLightness(r,g,b) / 255
   lig = rgb[7] / 255
   r1,g1,b1 = db.HSLtoRGB(hue, sat, lig*0.5)
   --c = matchcolor2(r1,g1,b1)
   --]]

   --c = matchcolor2(r*0.52,g*0.52,b*0.52) -- Basic Halfshade (Can't use matchcolor with omitted color)

   --[[
   c = db.getBestPalMatchHYBRID({r*0.52,g*0.52,b*0.52},palList,0.25,true); -- return index of Grafx2 pal color
   if c == co then
    c = db.getBestPalMatchHYBRID({r*0.4,g*0.4,b*0.4},palList,0.25,true)
   end
   if c ~= co then
    db.drawRectangle(posx+(n-1)*w+1,hlfy1,w-2,6, c) -- HSL seems to preserve more Hue in choices
     if c == darkest then -- Next darkest color, halfshade must be(?) background. Draw box instead.
       db.drawRectangleLine(posx+(n-1)*w+1,hlfy1,w-2,6, nextdarkest)
     end
   end

   c = findHalfshade_hsl(r,g,b, palList)
   if c ~= -1 then
    db.drawRectangle(posx+(n-1)*w+2,hlfy2,w-4,6, c) 
     if c == darkest then
       db.drawRectangleLine(posx+(n-1)*w+2,hlfy2,w-4,6, nextdarkest)
     end
   end

   c = findHalfshade_bri(r,g,b,palList)
   if c ~= -1 then
    db.drawRectangle(posx+(n-1)*w+2,hlfy3,w-4,6, c) 
     if c == darkest then
       db.drawRectangleLine(posx+(n-1)*w+2,hlfy3,w-4,6, nextdarkest)
     end
   end

  --]]



 -- New Halfshades

  gamma = {2.6, 1.9, 1.3}
  hlf_ht = 5 
   hlfy2 = hlfy1 + hlf_ht * #gamma + 1
  

 for i = 0, #gamma-1, 1 do
  gam = gamma[i+1]
  c = gammaHalfshade(r,g,b,palList, gam)
  if c ~= -1 then
   if c == darkest and DarkestIsBG then
    db.drawRectangleLine(posx+(n-1)*w+1,hlfy1+i*hlf_ht,w-2,hlf_ht, nextdarkest)
     else
      db.drawRectangle(posx+(n-1)*w+1,hlfy1+i*hlf_ht,w-2,hlf_ht, c)
   end
  end
 end


  c = findHalfshade_hsl(r,g,b, palList)
  if c ~= -1 then
    if c == darkest and DarkestIsBG then 
     db.drawRectangleLine(posx+(n-1)*w+2,hlfy2,w-4,hlf_ht, nextdarkest)
      else
       db.drawRectangle(posx+(n-1)*w+2,hlfy2,w-4,hlf_ht, c)
    end
  end

 --


  end -- Halfshades & Complementaries
  if n%4==0 then updatescreen(); if (waitbreak(0)==1) then return; end; end
end
--------------------------------------------------------------------



--drawPackage(pack,range,len,wid,posx,posy,ori,scale,crop,desat,bri,gap,pal_list,bri_weight)

-- 1. RGB ramp, Briweight = 0
-- 2. RGB ramp, Briweight = 0.1 to 0.85 (exp = 0.5)
-- 3. Best matchcolor Ramp, Briweight = 0.2 to 0.7
-- width should be even (width/2 * 2)
function tripramp(pallist, xpos,ypos, width, h1,h2,h3, r1,g1,b1, r2,g2,b2, r3,g3,b3)
 db.drawRamp_dual(pallist, xpos, ypos,    width, h1, r1,g1,b1, r2,g2,b2, r3,g3,b3, 0,0, 1.0) 
 db.drawRamp_dual(pallist, xpos, ypos+h1+1, width, h2, r1,g1,b1, r2,g2,b2, r3,g3,b3, 0.1,0.85, 0.5)
 rm1,gm1,bm1 = getcolor(matchcolor(r1,g1,b1))
 rm2,gm2,bm2 = getcolor(matchcolor(r2,g2,b2))
 rm3,gm3,bm3 = getcolor(matchcolor(r3,g3,b3))
 db.drawRamp_dual(pallist, xpos, ypos+h1+h2+2, width, h3, rm1,gm1,bm1, rm2,gm2,bm2, rm3,gm3,bm3, 0.2, 0.7, 1.0)
end
--


yo = TRIRAMP_Y
xo = TRIRAMP_X
wd = TRIRAMP_W
h1 = TRIRAMP_H1
h2 = TRIRAMP_H2
h3 = TRIRAMP_H3
sp = h1+h2+h3+4

--r1,g1,b1 = 0,0,0
--r2,g2,b2 = 255,0,0
r3,g3,b3 = 255,255,255

tripramp(palList, xo,yo,      wd, h1,h2,h3, 0,0,0, 255,0,0, r3,g3,b3)
tripramp(palList, xo,yo+sp*1, wd-2, h1,h2,h3, 0,0,0, 255,127,0, r3,g3,b3)
tripramp(palList, xo,yo+sp*2, wd, h1,h2,h3, 0,0,0, 255,255,0, r3,g3,b3)
tripramp(palList, xo,yo+sp*3, wd, h1,h2,h3, 0,0,0, 0,255,0, r3,g3,b3)
tripramp(palList, xo,yo+sp*4, wd, h1,h2,h3, 0,0,0, 0,255,255, r3,g3,b3)
tripramp(palList, xo,yo+sp*5, wd-2, h1,h2,h3, 0,0,0, 0,127,255, r3,g3,b3)
tripramp(palList, xo,yo+sp*6, wd, h1,h2,h3, 0,0,0, 0,0,255, r3,g3,b3)
tripramp(palList, xo,yo+sp*7, wd-2, h1,h2,h3, 0,0,0, 127,0,255, r3,g3,b3)
tripramp(palList, xo,yo+sp*8, wd, h1,h2,h3, 0,0,0, 255,0,255, r3,g3,b3)

--[[
Bri = 0.65 -- General brightness weight ramps that uses it
MatchBri = 0.65
GreyBri  = 0.8

-- RGBYTM brightness gradients
yo = 184 + LOWEROFFSET; ml = 22; yd = 7; sz = 6; x = 94; xd = 0
y = yo + ml*0; 
drawPackage({ {{BLK,RED},{RED,WHT}} },     16, 96, sz, x+xd*0,y+yd*0, 1, 0, 0, 0, 0, 0, palList, 0)
drawPackage({ {{BLK,RED},{RED,WHT}} },     16, 96, sz, x+xd*1,y+yd*1, 1, 0, 0, 0, 0, 0, palList, Bri)
drawPackage({ {{_blk,_red},{_red,_wht}} }, 16, 96, sz, x+xd*4,y+yd*2, 1, 0, 0, 0, 0, 0, palList, MatchBri)

y = yo + ml*1; 
drawPackage({ {{BLK,GRN},{GRN,WHT}} },     16, 96, sz, x+xd*0,y+yd*0, 1, 0, 0, 0, 0, 0, palList, 0)
drawPackage({ {{BLK,GRN},{GRN,WHT}} },     16, 96, sz, x+xd*1,y+yd*1, 1, 0, 0, 0, 0, 0, palList, Bri)
drawPackage({ {{_blk,_grn},{_grn,_wht}} }, 16, 96, sz, x+xd*4,y+yd*2, 1, 0, 0, 0, 0, 0, palList, MatchBri)

y = yo + ml*2; 
drawPackage({ {{BLK,BLU},{BLU,WHT}} },     16, 96, sz, x+xd*0,y+yd*0, 1, 0, 0, 0, 0, 0, palList, 0)
drawPackage({ {{BLK,BLU},{BLU,WHT}} },     16, 96, sz, x+xd*1,y+yd*1, 1, 0, 0, 0, 0, 0, palList, Bri)
drawPackage({ {{_blk,_blu},{_blu,_wht}} }, 16, 96, sz, x+xd*4,y+yd*2, 1, 0, 0, 0, 0, 0, palList, MatchBri)

y = yo + ml*3;
drawPackage({ {{BLK,YEL},{YEL,WHT}} },     16, 96, sz, x+xd*0,y+yd*0, 1, 0, 0, 0, 0, 0, palList, 0)
drawPackage({ {{BLK,YEL},{YEL,WHT}} },     16, 96, sz, x+xd*1,y+yd*1, 1, 0, 0, 0, 0, 0, palList, Bri)
drawPackage({ {{_blk,_yel},{_yel,_wht}} }, 16, 96, sz, x+xd*4,y+yd*2, 1, 0, 0, 0, 0, 0, palList, MatchBri)

y = yo + ml*4; 
drawPackage({ {{BLK,TUR},{TUR,WHT}} },     16, 96, sz, x+xd*0,y+yd*0, 1, 0, 0, 0, 0, 0, palList, 0)
drawPackage({ {{BLK,TUR},{TUR,WHT}} },     16, 96, sz, x+xd*1,y+yd*1, 1, 0, 0, 0, 0, 0, palList, Bri)
drawPackage({ {{_blk,_tur},{_tur,_wht}} }, 16, 96, sz, x+xd*4,y+yd*2, 1, 0, 0, 0, 0, 0, palList, MatchBri)

y = yo + ml*5; 
drawPackage({ {{BLK,MAG},{MAG,WHT}} },     16, 96, sz, x+xd*0,y+yd*0, 1, 0, 0, 0, 0, 0, palList, 0)
drawPackage({ {{BLK,MAG},{MAG,WHT}} },     16, 96, sz, x+xd*1,y+yd*1, 1, 0, 0, 0, 0, 0, palList, Bri)
drawPackage({ {{_blk,_mag},{_mag,_wht}} }, 16, 96, sz, x+xd*4,y+yd*2, 1, 0, 0, 0, 0, 0, palList, MatchBri)

--pack,range,len,wid,posx,posy,ori,scale,crop,desat%,lightness%,gapfix, pal_list,bri_weight)
--]]


--[[
-- Draw spectrum from best-selection colors and +25% brigthness color-matching
n = 0
bri = (_wht[1] - _blk[1])
  rmp1 = { {{_blk,_red},{_red,_wht}}, {{_blk,_ora},{_ora,_wht}}, {{_blk,_yel},{_yel,_wht}}, {{_blk,_ygr},{_ygr,_wht}}, 
           {{_blk,_grn},{_grn,_wht}}, {{_blk,_grt},{_grt,_wht}}, {{_blk,_tur},{_tur,_wht}}, {{_blk,_tbl},{_tbl,_wht}},
           {{_blk,_blu},{_blu,_wht}}, {{_blk,_blm},{_blm,_wht}}, {{_blk,_mag},{_mag,_wht}}, {{_blk,_mrd},{_mrd,_wht}}}
  drawPackage(rmp1, 16, 96, 6, 20+n*80,218, 0, bri, 1, n * 25, 0, 1, palList, 0.25)
--]]


-- Palette
if palList["doubles"] == nil then 
 messagebox ("Palette not processed - Doubles cannot be marked"); 
 palList["doubles"] = {}
end
xo = PALTABLE_X
yo = PALTABLE_Y
w =  PALTABLE_WD
h =  PALTABLE_HT
bl = matchcolor(0,0,0)
wt = matchcolor(255,255,255)
for y = 0, 7, 1 do
 for x = 0, 31, 1 do
  c = y*32+x
  db.drawRectangle(xo + x*w,yo + y*h,w,h,c)
   if palList["doubles"][c] == true then -- Mark doubles
     putpicturepixel(xo + x*w+w/2-0.5,yo + y*h+h/2-1,wt); 
     putpicturepixel(xo + x*w+w/2-0.5,yo + y*h+h/2+0,bl);
   end
 end
end

-- Draw a box around the palette
db.drawRectangleLine(xo-2, yo-2, 32*w+4, 8*h+4, matchcolor(80,80,80))

--

upd()


t = ""
t = t..#palList.." unique colors in palette"

if CLC == 1 then
 --t = t.."\n\n Closest colors:"

 x = CLOSEST_X; y = CLOSEST_Y1; sx,sy = CLOSEST_W,CLOSEST_H

 cl = db.findClosestColors(palList, CLOSEST_N, CLOSEST_BW_LO) -- 0.5 is default briweight
 for n = 1, math.min(CLOSEST_N,#cl), 1 do
  r1,g1,b1 = getcolor(cl[n][2]); r2,g2,b2 = getcolor(cl[n][3]); --t = t.."\n"..cl[n][2].."-"..cl[n][3].." ("..cl[n][1]..")"
  db.drawRectangle(x+(sx+1)*(n-1),y,sx,sy,cl[n][2])
  db.drawRectangle(x+(sx+1)*(n-1),y+sy,sx,sy,cl[n][3])
 end

 y = CLOSEST_Y2
 cl = db.findClosestColors(palList, CLOSEST_N, CLOSEST_BW_HI) -- 0.5 is default briweight
 for n = 1, math.min(CLOSEST_N,#cl), 1 do
  r1,g1,b1 = getcolor(cl[n][2]); r2,g2,b2 = getcolor(cl[n][3])
  db.drawRectangle(x+(sx+1)*(n-1),y,sx,sy,cl[n][2])
  db.drawRectangle(x+(sx+1)*(n-1),y+sy,sx,sy,cl[n][3])
 end

 --t = t.."\n Entries: "..#cl
end

 --db.drawRectangle(x,y+(sy+1)*(n-1),sx,sy,cl[n][2]) -- Y-orientation
 --db.drawRectangle(x+sx,y+(sy+1)*(n-1),sx,sy,cl[n][3])


upd()
 

--
if MIX == 1 and #palList <= MIXDITHER_LIMIT then -- Color mixer (Sorted by quality and usefulness (Missing colors))
mix,p,c1,c2 = db.colormixAnalysis(MIXDITHER_SHADES, false, null, palList) -- shades: 16 = 12bit color space operations
len = #mix
ox = MIXDITHER_X
oy = MIXDITHER_Y
wd = MIXDITHER_WD
ht = MIXDITHER_HT
sp = MIXDITHER_SP
xn = MIXDITHER_XN
yn = MIXDITHER_YN
 for y = 0, yn-1, 1 do
  for x = 0, xn-1, 1 do
   n = xn*y + x
    if len > n then
     c1 = mix[n+1][2]
     c2 = mix[n+1][3]
     db.drawRectangleMix(ox+(wd+sp)*x,oy+(ht+sp)*y,wd,ht,c1,c2)
    end
    upd()
  end
 end

end -- eof MIX
--

upd()



timer2 = os.clock()
ts = db.format((timer2 - timer1),2) 
t =t.."\n\n Time: "..ts.." s"

--txt(2,2,"Palette Analysis")


updatescreen(); waitbreak(0)
messagebox("Analysis:", t)

end
----------------------------------------------------------------------------
-- eof main()




VERSION = "2.21"

dia_sat = {255,128,48} -- HSB diagrams saturations, High, medium & low

OK,NOBG,CBW1,CBW2,dia_sat[1],dia_sat[2],dia_sat[3], sat_mod1, sat_mod2, sat_mod3 = inputbox("Analyze Palette v"..VERSION,                    
                          
                           --"ColorMixes",   1,  0,1,0, 
                           --"Close Colors", 1,  0,1,0,
"Exclude BG Color", 0,  0,1,0,
"CloseCols1 BriWeight %",     10,  0,100,0, 
"CloseCols2 BriWeight %",     70,  0,100,0, 
"HSB Diagram Hi Sat",         dia_sat[1],  0,255,0, 
"HSB Diagram Med Sat",        dia_sat[2],  0,255,0, 
"HSB Diagram Low Sat",        dia_sat[3],  0,255,0,
"1. Sat Mode: Purity",         1,  0,1,-1,  
"2. Sat Mode: HSV/HSB",        0,  0,1,-1, 
"3. Sat Mode: HSL",            0,  0,1,-1   
                          
);

--
if OK == true then

 main()

end -- OK
--

