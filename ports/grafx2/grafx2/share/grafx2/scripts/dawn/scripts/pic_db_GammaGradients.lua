--PICTURE: Gamma Gradients Demonstration
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_text.lua")
dofile("../ffonts/font_mini_3x4.lua")



pallist = db.fixPalette(db.makePalList(256),1)
 --palList = db.addHSBtoPalette(palList)
 

-- Easy Text Interface
function txt(xpos,ypos,txt,col,transparency)
 local hspace,vspace,maxwidth,aa_str,linebreak_char,use_font,clear_flag
--
--font_f = font_mini_3x4
-- font_f:  Font data (function), will use built-in font by default, use anything undefined as argument, f.ex. 'f' 
-- txt:     Text
-- xpos,ypos: text screen location
hspace = 1
vspace = 1            -- Letter spacing, horizontal/vertical
maxwidth = 1000       --   Paragraph/Box width (i.e point where ONE MORE word is allowed)
--col = col or {0,0,0}   -- RGB colorvalue {r,g,b}
col = col or {255,255,255}   -- RGB colorvalue {r,g,b}
transparency = transparency or 0.5      -- transparency 0..1, 0 = No Transparency
linebreak_char = "|"  -- character that will function as linebreak
aa_str = 0.85            -- AA strength, 1 = Normal/full AA, 0 = No AA,Solid color. For Dark text on bright bg use about 0.5.
clear_flag = false    --  restore background when overwriting text (true/false). 
--             When doing text+shadow use true for shadow and false for text. 
--             Overwriting old text+shadow requires a restoration of the previous text (an extra leading print with 'true')

 use_font = null
 --if small == 1 then use_font = font_mini_3x4; end

 text.write(use_font,txt,xpos,ypos,hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag)
end

--text.DefaultFont = text.font_default
--text.DefaultFont = font_mini_3x4

dither = 0.5
bw = 0.25

 OK,dummy,dummy,dummy,bw,dither,setpal = inputbox("Gamma Adjusted Gradients",
                        
   "--- Demonstrating the effect ---",0,0,0,4,
   "---  of Gamma adjustment on  ---",0,0,0,4,
   "--- color-to-color Gradients ---",0,0,0,4,
   "ColMatch Bri-Weight %", bw*100,      0,100,0,                 
   "Dither %",              dither*100,  0,100,0,
   "Set Pal: Aurora [256]", 0,  0,1,0                       
                                                                      
 );

--
if OK then

dither = dither * 0.01
bw = bw * 0.01

W = 600
H = 430

setpicturesize(W,H)


if setpal == 1 then
 dofile("../palettes/pfunc_pal_Aurora11.lua")(true)
end

c = matchcolor(96,96,96)
clearpicture(c)

OX = 40
OY = 22

ramp_xoff   = OX
ramp_yoff   = OY + 76
ramp_width  = 256
ramp_height = 12
ramp_yspace = 1
pack_space  = 2

padding = 3

t = "GAMMA ADJUSTED GRADIENTS"
txt(4,4,t,{255,255,255},0.1)
t = "------------------------"
txt(4,4+text.ysize+1,t,{255,255,255},0.5)


t = "COLMATCH BRIWEIGHT: "..bw
txt(W-(text.xsize+1)*#t-3,4,t,{0,0,0})

text.setFont(font_mini_3x4) -- Change Current font function (Loads FontData into memory)


-- Black-White
gray_width = 512 + 4
gray_height = 64
gam0 = 1.0
gam1 = 2.2
db.drawGammaGradientDiagram({0,0,0},{255,255,255},gam0,gam1,gray_width,gray_height, OX,OY,bw,dither,8) -- update every 8th
t = text.AddDecimalZeros(gam0,2)
txt(OX-(text.xsize+1)*#t-padding+1,OY,t,{255,255,255}) -- +1 coz of -1 from char spacing
txt(OX+gray_width+padding,OY,t,{255,255,255})
t = text.AddDecimalZeros(gam1,2)
txt(OX-(text.xsize+1)*#t-padding+1,OY+gray_height-text.ysize,t,{255,255,255})
txt(OX+gray_width+padding,OY+gray_height-text.ysize,t,{255,255,255})

gamma = {1.0, 1.25, 1.6, 2.0}

rgb = {{{255,0,0},{0,255,255}}, {{255,128,0},{0,128,255}}, {{255,255,0},{0,0,255}}, 
       {{128,255,0},{128,0,255}},{{0,255,0},{255,0,255}}, {{0,255,128},{255,0,128}}}

for q = 1, #rgb, 1 do
 rgb1 = rgb[q][1]
 rgb2 = rgb[q][2]
 for n = 1, #gamma, 1 do
  g = gamma[n] 
  ypos = ramp_yoff+(n-1)*(ramp_height+ramp_yspace)+(q-1)*(pack_space+(ramp_height+ramp_yspace)*#gamma)
  transp = 0.5; if g == 1 then transp = 0.2; end
  t = text.AddDecimalZeros(g,2)
  txt(ramp_xoff-(text.xsize+1)*#t-padding+1,ypos+4,""..t,{255,255,255},transp)
  db.drawGammaGradientDiagram(rgb1,rgb2,g,g,ramp_width,ramp_height, ramp_xoff,ypos,bw,dither, 64) -- update every 64
 end
end

rgb = {{{0,0,255},{255,0,0}}, {{255,0,0},{0,255,0}}, {{0,255,0},{0,0,255}}, 
       {{0,255,255},{255,0,255}}, {{255,0,255},{255,255,0}}, {{255,255,0},{0,255,255}}}
xof = 260

for q = 1, #rgb, 1 do
 rgb1 = rgb[q][1]
 rgb2 = rgb[q][2]
 for n = 1, #gamma, 1 do
  g = gamma[n] 
  ypos = ramp_yoff+(n-1)*(ramp_height+ramp_yspace)+(q-1)*(pack_space+(ramp_height+ramp_yspace)*#gamma)
  transp = 0.5; if g == 1 then transp = 0.2; end
  t = text.AddDecimalZeros(g,2)
  txt(xof + ramp_xoff + ramp_width +padding+1,ypos+4,""..t,{255,255,255},transp)
  db.drawGammaGradientDiagram(rgb1,rgb2,g,g,ramp_width,ramp_height, xof + ramp_xoff,ypos,bw,dither, 64) -- update every 64
 end
end


end -- OK
--

--db.drawGammaGradientDiagram({255,255,0},{0,0,255},0.25,3.0,540,410, 16,16,0.25,1.0) 


