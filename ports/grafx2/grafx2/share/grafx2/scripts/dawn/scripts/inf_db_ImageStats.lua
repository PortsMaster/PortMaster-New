--INFO: Image Info V1.1
--by Richard Fhager 


dofile("../libs/dawnbringer_lib.lua")


w,h = getpicturesize()
FG = getforecolor()
BG = getbackcolor()

IGNOREBG = 0
if FG == BG then IGNOREBG = 1; end
nobg = ""; if IGNOREBG == 1 then nobg = "*"; end

ihist = db.makeHistogramIndexed()
ipal  = db.makePalListFromIndexedHistogram(ihist)


--# of Unique colors in Image:
unique = db.fixPalette(ipal,1) -- ihist:{count,index,r,g,b}

function format(v,p)
 return math.floor(v * 10^p) / 10^p
end

-- Avg. RGB
px = 0
rt,gt,bt,app_sat_tot = 0,0,0
most,mosti,least,leasti = 0,-1,w*h,-1
for n = 1, #ihist, 1 do
 c = ihist[n]
 if (c[2] ~= BG) or IGNOREBG == 0 then

  r,g,b = c[3],c[4],c[5]

  rt = rt + r * c[1]
  gt = gt + g * c[1]
  bt = bt + b * c[1]
  px = px + c[1]
  if c[1] >= most  then most  = c[1]; mosti  = c[2]; end 
  if c[1]>0 and c[1] <= least then least = c[1]; leasti = c[2]; end 
 end
end
ra,ga,ba = rt/px, gt/px, bt/px
--app_sat = app_sat_tot / px
--

closestpair = db.findClosestColors(unique, 10) -- {dist,c1,c2}
c1,c2 = "NA","NA"
if #closestpair > 0 then
 c1 = closestpair[1][2]
 c2 = closestpair[1][3]
end

gcd = db.gcd(w,h)
ratx = w / gcd
raty = h / gcd


t = ""
t = t.."SIZE: "..w.."x"..h.." ("..ratx..":"..raty..")"
t = t.."\n_____ Pixels: "..w*h.." ("..nobg..px..")"
t = t.."\n\n"
t = t.."COLS: "..#ipal.." ("..#unique.." unique)"
t = t.."\n_____ Most similar: #"..c1.." & #"..c2

t = t.."\n\n"
t = t..nobg.."RGB avg.: "..db.format(ra,2)..", "..db.format(ga,2)..", "..db.format(ba,2)
t = t.."\n\n"
t = t..nobg.."Brightness avg.: "..db.format(db.getBrightness(ra,ga,ba),2)
t = t.."\n\n"
t = t..nobg.."Max Col: #"..mosti.." ("..most.."px = "..db.format(most/(w*h)*100,1).."%)"
t = t.."\n"
t = t..nobg.."Min Col: #"..leasti.." ("..least.."px = "..db.format(least/(w*h)*100,5).."%)"
--if #closestpair > 0 then
-- t = t.."\n\n"
--end

--t = t.."Bri: "..format(bri,2).." ("..format(bri_prc,1).."%) (perceptual)"
--t = t.."\n\n"
--t = t.."Sat: "..format(app_sat,2).." ("..format(app_sat/2.55,1).."%) (apparent)"
--t = t.."\n\n"
--t = t.."Con: "..format(con_prc,2).."% (avg. ch. contrast)"

title = "Image Stats (Set BG=FG -> Col Ex.)" --(BG-col = #"..BG..")"
messagebox(title, t)