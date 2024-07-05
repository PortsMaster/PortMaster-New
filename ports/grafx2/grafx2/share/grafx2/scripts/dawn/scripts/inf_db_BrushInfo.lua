--INFO: BrushInfo V1.2
--by Richard Fhager 

--dofile("../libs/dawnbringer_lib.lua")


t = ""


function format(v,p)
 return math.floor(v * 10^p) / 10^p
end


w,h = getbrushsize()

bg = getbackcolor()

colsused = 0
cols = {}

ml,mr,mu,md = 99e9,0,99e9,0
rt,gt,bt = 0,0,0
gamma = 2.0
total = 0

 for y = 0, h-1, 1 do
 for x = 0, w-1, 1 do
   
  c = getbrushpixel(x,y)

  if cols[c+1] == nil then
   colsused = colsused+ 1
   cols[c+1] = 1
    else cols[c+1] = cols[c+1] + 1
  end

 -- Find margins
 if c ~= bg then
  if x<ml then ml = x; end
  if x>mr then mr = x; end
  if y<mu then mu = y; end
  if y>md then md = y; end

  r,g,b = getcolor(c) -- Let's omitt average gamma color for non-background pixels
  rt = rt + r^gamma
  gt = gt + g^gamma
  bt = bt + b^gamma
  total = total + 1

 end

 end
 end

r,g,b = getcolor(bg) -- Empty brush
if total > 0 then
 r = (rt / total)^(1/gamma)
 g = (gt / total)^(1/gamma)
 b = (bt / total)^(1/gamma)
end

gt = ""..gamma
dt = ""; if #gt == 1 then dt = ".0"; end

t = t.."Brush size: "..w.." x "..h.." pixels"
t = t.."\n\n"

if total >0 then
 t = t.."Colors used: "..colsused
 t = t.."\n\n"
 t = t.."Background outlines:"
 t = t.."\nLeft  margin: "..ml.." pixels"
 t = t.."\nRight margin: "..(w-mr-1).." pixels"
 t = t.."\nUpper margin: "..mu.." pixels"
 t = t.."\nLower margin: "..(h-md-1).." pixels"
 t = t.."\n\n"
 t = t.."Average gamma-adjusted ("..gamma..dt..") RGB:\n\n ["..format(r,1)..", "..format(g,1)..", "..format(b,1).."]"

  else t = t.."Brush is EMPTY!"
end


messagebox("Brush Info", t)