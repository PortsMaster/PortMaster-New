--BRUSH: Find AA-colors from pencolors, Plain(1) + Brightness-weight(3) + Gamma adjusted(3) + Bw+Gamma(1)
--by Richard Fhager 


dofile("../libs/dawnbringer_lib.lua")

ip_div = 5

cellw = 6
cellh = 3
colors = 256

setbrushsize(cellw * 2 + cellw * ip_div, cellh * 7 + 2 + cellh + 1)


w,h = getbrushsize()
ct = gettranscolor()

for y = 0,h-1,1 do
 for x = 0,w-1,1 do
  putbrushpixel(x,y,ct)
 end
end

palList = db.makePalList(colors)

cf = getforecolor()
cb = getbackcolor()
rf,gf,bf = getcolor(cf)
rb,gb,bb = getcolor(cb)


gamma_table = {1.25, 1.6, 2.0}

bri_table = {0, 0.25, 0.5, 0.85}


q = {}


for b = 1,#bri_table,1 do
 q[b] = {cf}
 q[b][ip_div+2] = cb
for s = 0,ip_div-1,1 do

 f = 1 / (ip_div+1) * (ip_div-s)
 r = 1 - f 

 r1,g1,b1 = db.rgbcap(rf * f + rb * r,gf * f + gb * r,bf * f + bb * r, 255,0)

 c = db.getBestPalMatchHYBRID({r1,g1,b1},palList,bri_table[b], false)

 q[b][s+2] = c

 end -- s
end -- b


ofy = #bri_table
for b = 1,#gamma_table,1 do

 e = gamma_table[b]
 ei = 1 / e

 q[b+ofy] = {cf}
 q[b+ofy][ip_div+2] = cb
for s = 0,ip_div-1,1 do

 f = 1 / (ip_div+1) * (ip_div-s)
 r = 1 - f 

 r1,g1,b1 = db.rgbcap((rf^e * f + rb^e * r)^ei, (gf^e * f + gb^e * r)^ei, (bf^e * f + bb^e * r)^ei, 255,0)

 c = db.getBestPalMatchHYBRID({r1,g1,b1},palList,0.25, false)

 q[b+ofy][s+2] = c

 end -- s
end -- b


-- Hybrid
briweight = 0.4
        e = 1.7 -- Gamma
ei = 1 / e
ofy = #bri_table + #gamma_table
q[1+ofy] = {cf}
q[1+ofy][ip_div+2] = cb
for s = 0,ip_div-1,1 do

 f = 1 / (ip_div+1) * (ip_div-s)
 r = 1 - f 

 r1,g1,b1 = db.rgbcap((rf^e * f + rb^e * r)^ei, (gf^e * f + gb^e * r)^ei, (bf^e * f + bb^e * r)^ei, 255,0)

 c = db.getBestPalMatchHYBRID({r1,g1,b1},palList,briweight, false)

 q[1+ofy][s+2] = c

end -- s




 ofy = 0
 for y = 0, #q-1, 1 do
  if y == 1 or y == 4 or y == 7 then ofy = ofy+1; end
  for x = 0, #q[1]-1, 1 do
   db.drawBrushRectangle(x*cellw,y*cellh+ofy,cellw,cellh,q[y+1][x+1])
  end
 end

setbackcolor(ct)
