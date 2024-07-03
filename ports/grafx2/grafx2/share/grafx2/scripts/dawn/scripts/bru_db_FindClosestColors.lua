--BRUSH: Find Closest Color V2.0
--1st Line is 25% Bri-Weight Matching Perceptual (0.26,0.55,0.19)
--2nd Line is 90% Bri-Weight Matching Perceptual (0.26,0.55,0.19) and a 1.4 Error-exponent
--
-- R.Fhager 2017
--

dofile("../libs/dawnbringer_lib.lua")

palList = db.fixPalette(db.makePalList(256),0)

SAMPLES = 3 + math.floor((#palList)^0.4)
SIZEx = 3
SIZEy = 4



--messagebox(db.getColorDistance_weightNorm(0,0,0, 255,255,255, 0.26,0.55,0.19))

FC = getforecolor()
r,g,b = getcolor(FC)



-- Make (sorted) distance list
function makeDistanceList(r,g,b, cindex, pallist, briweight, err_exp)
 local n,p,d,list,abs,obri,diffB,diffC,diff
 briweight = briweight or 0.25
 err_exp = err_exp or 1.0
 abs = math.abs
 obri = db.getBrightness(r,g,b)
 dist= {}
 for n = 1, #pallist, 1 do
  p = pallist[n]
   if p[4] ~= cindex then
     diffB = abs(obri - db.getBrightness(p[1],p[2],p[3]))^err_exp
     diffC = db.getColorDistance_weightNorm(r,g,b, p[1],p[2],p[3], 0.26,0.55,0.19)^err_exp   -- old:  d = db.getColorDistance_weight(r1,g1,b1,p[1],p[2],p[3],0.26,0.55,0.19)  * 1.569
     diff = briweight * (diffB - diffC) + diffC   
     dist[n] = {p[4], diff}
       else dist[n] = {cindex, 99999999}
   end
 end
 return db.sorti(dist,2)
end
--

dist1 = makeDistanceList(r,g,b, FC, palList, 0.25, 1.0)
dist2 = makeDistanceList(r,g,b, FC, palList, 0.9,  1.4)



--messagebox(dist[1][1]..", "..dist[2][1]) 

setbrushsize(SAMPLES*SIZEx,SIZEy*3+2)

db.drawBrushRectangle(0,SIZEy+1,SAMPLES*SIZEx,SIZEy,FC)
for n = 1, SAMPLES, 1 do
 if dist1[n] ~= null then
  if n == 1 then
    db.drawBrushRectangle(SIZEx*(n-1),0,        SIZEx,SIZEy+1, dist1[n][1]) -- Make 1st (best) matches a little taller
    db.drawBrushRectangle(SIZEx*(n-1),1+SIZEy*2,SIZEx,SIZEy+1, dist2[n][1])
   else 
    db.drawBrushRectangle(SIZEx*(n-1),1+0,      SIZEx,SIZEy, dist1[n][1])
    db.drawBrushRectangle(SIZEx*(n-1),1+SIZEy*2,SIZEx,SIZEy, dist2[n][1])
  end
 end
end



