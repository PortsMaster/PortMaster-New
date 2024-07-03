--PALETTE: ColorCigarr V1.5
--(Fills the 'natural' part of colorspace)
--by Richard Fhager 
-- Email: dawnbringer@hem.utfors.se

-- (V1.5 Changed radius value from 5-50% to 10-100% (50% was actually full radius)

-- Colorcigarr also exists as a function in dawnbringer_lib.lua (db.colorCigarr(shades,radius,fill_flag))

SHADES = 8
RADIUS = 0.2 -- Fraction of colorsphere radius
--FILL = true

-- 16, 0.15*2 (214)
-- 8, 0.25*2  (116 filled)
-- 14, 0.2*2
-- 5, 0.18*2 (29 filled)
-- 16,16,no-fill good for analysis

OK,SHADES,RADIUS,fill = inputbox("ColorCigarr",
                  
                           "Shades",           SHADES,      2,16,0, 
                           "Radius %: 10-100", RADIUS*100*2, 10,100,2, 
                           "Fill volume",                1,  0,1,0 
        
);

RADIUS = RADIUS / 100 * 0.5
if fill == 1 then FILL = true; end

--
if OK == true then

step = math.floor(255 / (SHADES-1))
shalf = math.floor(SHADES / 2)
s = SHADES - 1

rad = math.floor(SHADES / 2 * RADIUS) -- Yeah, we should clean this radius mess up
radsq = rad^2

bas = 0
cols = {}
found = 0

for z = 0, s, 1 do 
 for y = 0, s, 1 do
  for x = 0, s, 1 do

  --0.26,0.55,0.19
  bri = (x + y + z ) / 3
  --bri = math.sqrt(((x*0.26)^2 + (y*0.55)^2 + (z*0.19)^2)) * 1.5609
  con = math.floor((SHADES - math.abs(bri - shalf)*2) * RADIUS)

  d = math.floor(math.sqrt((bri-x)^2 + (bri-y)^2 + (bri-z)^2))
  --d = math.floor(math.sqrt((bri-x*0.26)^2 + (bri-y*0.55)^2 + (bri-z*0.19)^2))


  -- Filled cigarr: Less or Equal, cigarr shell: Equal
   if d == con or (d < con and FILL) then 
      found = found + 1
      r = bas + x * step
      g = bas + y * step
      b = bas + z * step
      cols[found] = {r,g,b}
   end

end; end; end

messagebox("Colors found: "..found.."\n\n".."Run AnalyzePalette to examine")

for n = 0, 255, 1 do
 if n < found then
  c = cols[n+1]
  setcolor(n,c[1],c[2],c[3]) 
   else
    setcolor(n,0,0,0) 
 end
end

end;
--