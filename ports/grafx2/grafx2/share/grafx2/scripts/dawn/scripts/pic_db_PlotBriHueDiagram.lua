--PICTURE: Plotted Hue-Brightness Diagram
--by Richard 'DawnBringer' Fhager


dofile("../libs/dawnbringer_lib.lua")


palList = db.makePalList(256)
palList = db.fixPalette(palList,1)
palList = db.addHSBtoPalette(palList) -- db.drawHSBdiagram

BG = getbackcolor() 
w,h = getpicturesize()

greytolerance = 0.095 --0.06-0.065 seem good
greytresh = greytolerance * 100

--ox = 50
--oy = 40

xsize = math.floor(w * 0.8) --120*2
ysize = math.floor(h * 0.8) --88*2

--sz = math.min(7, math.floor(48 / math.sqrt(#palList))) 
sz = math.min(11, math.floor(xsize^0.85 / (1+(#palList)^0.7) )) -- Pretty good formula for plotsize 0.85/0.7
--sz = 7

britrace_len = 2 + math.floor(sz/4)          -- Color Brightness lines, length in dots
if math.floor(sz) / (1.25+(#palList)^0.4) <= 1 or xsize < 80 then britrace_len = 0; end

--britrace_mono_flag = true -- Use grayscale rather than colored dots 
frame_flag   = true       -- Draw framing box
-- grid_flag   = true       -- Draw grids, Primary Hue lines and 3 grayscales
--briplot_flag = true       -- Plot Brightness positions at bottom


OK,xsize,ysize,sz,greytresh,britrace_len,britracecol,grid,briplot,nobg   =   inputbox("Plotted Hue-Brightness Diagram",
                           " Width: 25-800",  xsize,  25,800,0,
                           "Height: 25-800",  ysize,  25,800,0,
                           "Plot Size: 1-29", sz,     1,29,0, 
                           "Grayscale Treshold %",  greytresh, 0,100,2,     
                           "BriTrace Length*: 0-20",  britrace_len,  0,20,0, 
                           "*BriTrace in Color", 0, 0, 1, 0,
                           --"Draw Frame?", 1, 0, 1, 0,
                           "Draw Grids", 1, 0, 1, 0,
                           "Brightness Diagram", 1, 0, 1, 0,

                           "Omitt BG-Color (by RGB)", 0, 0, 1, 0
                          
   
   
                                                          
);

if OK == true then

 graytolerance = greytresh / 100

 space = math.floor(sz/2)+1 -- frame spacing

 if nobg == 1 then
  r,g,b = getcolor(BG)
  palList = db.strip_RGB_FromPalList(palList,r,g,b)
 end

 clearpicture(BG)

 ox = math.max(0,math.floor((w - xsize)/2))
 oy = math.max(0,math.floor((h - ysize)/2))

 britrace_mono_flag = true; if britracecol == 1 then britrace_mono_flag = false; end
   --frame_flag = false; if   frame == 1 then   frame_flag = true; end
    grid_flag = false; if    grid == 1 then    grid_flag = true; end
 briplot_flag = false; if briplot == 1 then briplot_flag = true; end

 db.drawBriHuePlotDiagram(palList,ox,oy,xsize,ysize,space,sz,graytolerance, britrace_len, britrace_mono_flag, briplot_flag, frame_flag, grid_flag)

end




