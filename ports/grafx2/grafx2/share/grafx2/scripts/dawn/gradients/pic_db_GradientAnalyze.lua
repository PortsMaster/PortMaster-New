--PICTURE: Gradient Analyze
--(Lower diagram is RGB-channels)
--by Richard 'DawnBringer' Fhager

--previously named DrawPalette

dofile("../libs/dawnbringer_lib.lua")

setpicturesize(768,656)
clearpicture(0)

--g198 = math.floor(db.getBrightness(255,255,255) * 100000) / 100000
--g199 = db.getBrightness(254,254,254)
--messagebox(" "..g198.." - "..g199)
--if g198 == 255 then messagebox("255 is ok"); end

w,h = getpicturesize()

colors = 256
height = 140


for x = 0, w - 1, 1 do
 c = math.floor(colors/w * x)
 for y = 0, height - 1, 1 do
    putpicturepixel(x, y, c);
 end
 if x%8 == 0 then updatescreen();if (waitbreak(0)==1) then return end; end
end


--
function gradientDiagram(ox,oy,xscale,yscale,func, dark,mid,white)
 local bottom,f,c,v,r,g,b

 white = white or 255
 mid = mid or 128
 dark = dark or 64

 white = matchcolor(white,white,white) 
 mid = matchcolor(mid,mid,mid)  
 dark = matchcolor(dark,dark,dark) 

 bottom = 255 * yscale
 f = 256 / colors * xscale

 for c = 0, colors-1, 1 do
  r,g,b = getcolor(c)
  bri = math.floor(math.min(255,func(r,g,b)) * 100 * yscale) * 0.01 
  -- The fractions will still screw up the grayscale values with just rounding down
  --bri = math.floor(db.getBrightness(r,g,b)) -- Only white [255,255,255] has brightness of 255
  db.line(ox+c*f,oy+bottom,ox+c*f,oy+(bottom-bri),mid)
  db.line(ox+c*f,oy,ox+c*f,oy+(bottom-bri),dark)
  putpicturepixel(ox+c*f,oy+(bottom-bri),white)
 end
end
--


--
ox = 0
oy = 142
yscale = 1.0
xscale = 3 -- Use 2 for 1 pixel separation
gradientDiagram(ox,oy,xscale,yscale,(function(r,g,b) return db.getBrightness(r,g,b); end))


ox = 0
oy = 400
yscale = 1.0
xscale = 3
gradientDiagram(ox,  oy,xscale,yscale,(function(r,g,b) return r; end), 40,90,180)
gradientDiagram(ox+1,oy,xscale,yscale,(function(r,g,b) return g; end), 55,95,255)
gradientDiagram(ox+2,oy,xscale,yscale,(function(r,g,b) return b; end), 20,85,120)











