--PICTURE:
--Complementaries / Desaturation Diagrams V1.0
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_text.lua")
dofile("../ffonts/font_mini_3x4.lua")


OK,XSIZE,YSIZE,SPACING,BRIWEIGHT,GAMMA,DITHER,DITHPOW = inputbox("Complementaries/Desat. Diagrams",
                                   
 "Diagrams Width",        150,  40, 400,0, 
 "Diagrams Height",       150,  40, 400,0,
 "Diagrams Spacing",       7,  0, 50,0,  
 "Colmatch Bri-weight %",  25,  0,100,0,
 "Gamma: 0.5-2.5",        1.0,  0.5,2.5,2,  
 "Dither*",                0,  0,1,0,
 "*Dither Power %: 1-400", 100,  1, 400,0                   
);

--
if OK then

-- Easy Text Interface
function txt(xpos,ypos,txt,small,col,transparency)
--
--font_f = font_mini_3x4
-- font_f:  Font data (function), will use built-in font by default, use anything undefined as argument, f.ex. 'f' 
-- txt:     Text
-- xpos,ypos: text screen location
hspace = 1
vspace = 1            -- Letter spacing, horizontal/vertical
maxwidth = 1000       --   Paragraph/Box width (i.e point where ONE MORE word is allowed)
--col = {255,255,255}   -- RGB colorvalue {r,g,b}
col = col or {0,0,0}   -- RGB colorvalue {r,g,b}
transparency = transparency or 0.5      -- transparency 0..1, 0 = No Transparency
linebreak_char = "|"  -- character that will function as linebreak
aa_str = 0.85            -- AA strength, 1 = Normal/full AA, 0 = No AA,Solid color. For Dark text on bright bg use about 0.5.
clear_flag = false    --  restore background when overwriting text (true/false). 
--             When doing text+shadow use true for shadow and false for text. 
--             Overwriting old text+shadow requires a restoration of the previous text (an extra leading print with 'true')

 use_font = font_f
 if small == 1 then use_font = font_mini_3x4; end

 text.write(use_font,txt,xpos,ypos,hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag)
end


data = {
 {{255,0,0},   "Red / Cyan"},
 {{255,127,0}, "Orange / Azure"},
 {{255,255,0}, "Yellow / Blue"},
 {{127,255,0}, "Chartreuse / Violet"},
 {{0,255,0},   "Green / Magenta"},
 {{0,255,127}, "Spring-Green / Rose"}
}


  --small = false
  --txt(px-1,py-tx,desc[y*4+x + 1],small)  

   --db.drawRectangleLine(px-1,py-1,xsize+2,ysize+2,matchcolor(0,0,0))  


palList = db.makePalList(256)
palList = db.fixPalette(palList,1)
--palList = db.addHSBtoPalette(palList) -- db.drawHSBdiagram

label_ys = 16
lx = 20
ly = 10
ox = 20
oy = 20 + label_ys
by = 20 -- bottom padding
xsize = XSIZE or 120
ysize = YSIZE or 120
sp = 1 + SPACING -- spacing not including frame
ts = 8 -- extra y-spacing for text

width = xsize * 3 + ox*2 + sp*2
height = ysize * 2 + oy + by + sp --+ label_ys 

setpicturesize(width,height)
clearpicture(matchcolor(112,112,112))

bw = BRIWEIGHT / 100
Dither_Power = 0
if DITHER == 1 then Dither_Power = DITHPOW/100; end

txt(lx,ly,  "COMPLEMENTARIES / DESATURATION GRADIENTS", 0, {255,255,255}, 0.1)  
txt(lx,ly+5,"----------------------------------------", 0, {255,255,255}, 0.5) 

t1 = #(""..bw)
t2 = #(""..GAMMA)
tmax = math.max(t1,t2)

 
t = "COLMATCH BRI-WEIGHT = "..bw
x = ox + xsize*3 + sp*2 - (#t-t1+tmax)*5
txt(x,ly,t, 0, {255,255,255}, 0.5) 

t = "GAMMA = "..GAMMA
x = ox + xsize*3 + sp*2 - (#t-t2+tmax)*5
txt(x,ly+7,t, 0, {0,0,0}, 0.5) 

for y = 0, 1, 1 do
 for x = 0, 2, 1 do
  o = data[y*3+x+1]; rgb,t = o[1],o[2]
  px = ox + (xsize+sp)*x
  py = oy + (ysize+sp)*y
  db.drawRectangleLine(px-1,py-1,xsize+2,ysize+2,matchcolor(0,0,0))  
  txt(px,py+(ysize+ts+1)*y-7,t, 0)  
  db.complementaryDiagram(px,py,xsize,ysize,palList,rgb[1],rgb[2],rgb[3],bw,GAMMA,Dither_Power)
 end
end

end -- ok
--



