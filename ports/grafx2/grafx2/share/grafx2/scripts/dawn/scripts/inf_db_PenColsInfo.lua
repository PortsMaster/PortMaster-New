--INFO: Pen Colors Info V1.1

dofile("../libs/dawnbringer_lib.lua")

function format(v,p)
 return math.ceil(v * 10^p) / 10^p
end

 floor = math.floor

 FC = getforecolor()
 BC = getbackcolor()

 r1,g1,b1 = getcolor(FC)
 r2,g2,b2 = getcolor(BC)

 ra,ga,ba = (r1+r2)/2, (g1+g2)/2, (b1+b2)/2

 mbri = db.getBrightness(ra,ga,ba)

 bri1 = db.getBrightness(r1,g1,b1)
 bri2 = db.getBrightness(r2,g2,b2)

 rm = ((r1^2 + r2^2)/2)^0.5
 gm = ((g1^2 + g2^2)/2)^0.5
 bm = ((b1^2 + b2^2)/2)^0.5

 mixbri = db.getBrightness(rm,gm,bm)

 ra,ga,ba = floor(ra + 0.5), floor(ga + 0.5), floor(ba + 0.5)
 rm,gm,bm = floor(rm + 0.5), floor(gm + 0.5), floor(bm + 0.5)

 cmix = matchcolor2(rm,gm,bm) -- matchcolor2 in v2.4 erroniously rounds values to integers before calcs
 cavg = matchcolor2(ra,ga,ba)

 proxdist = db.getColorDistanceProx(r1,g1,b1,r2,g2,b2,0.26,0.55,0.19,1.569, 1.0, 0)
  --coldist = db.getColorDistance_weight(r1,g1,b1,r2,g2,b2,0.26,0.55,0.19) * 1.5690256395005606
  coldist = db.getColorDistance_weightNorm(r1,g1,b1,r2,g2,b2,0.26,0.55,0.19)

  sat1 = db.getRealSaturation(r1,g1,b1)
  hue1 = db.getHUE(r1,g1,b1, 0.2)
  sat2 = db.getRealSaturation(r2,g2,b2)
  hue2 = db.getHUE(r2,g2,b2, 0.2)
hsdist = db.getHueSatDistanceC(hue1,sat1,hue2,sat2) -- Conceptual Hue-Saturation distance


 t = ""


 t = t.."FGcol #"..FC.." ["..r1..","..g1..","..b1.."] Bri "..format(bri1,1)
 t = t.."\n"
 t = t.."BGcol #"..BC.." ["..r2..","..g2..","..b2.."] Bri "..format(bri2,1)
 t = t.."\n\n"
 t = t.."DISTANCES: (255 Normalized)\n"
 t = t.."Range: "..(1+math.abs(FC-BC))..", Spaces: "..(math.abs(FC-BC)-1)
 t = t.."\n"
 t = t.."RGB: "..format(db.getColorDistance_weightNorm(r1,g1,b1,r2,g2,b2,1,1,1),1) 
 --t = t.."\n" 
 t = t..", Per: "..format(coldist,1)
 t = t..", Prx: "..format(proxdist,1)
 t = t.."\nBri: "..format(math.abs(bri2-bri1),1) 
 t = t..", Hue/Sat: "..format(hsdist*255,1) 
 t = t.."\n\n"
 t = t.."Avg: ".."["..ra..","..ga..","..ba.."], Bri = "..format(mbri,1)
 t = t.."\n"
 t = t.."Best Avg Match: #"..cavg
 t = t.."\n\n"
 t = t.."Mix: ".."["..rm..","..gm..","..bm.."], Bri = "..format(mixbri,1)
 t = t.."\n"
 t = t.."Best Mix Match: #"..cmix.." (Gamma 2.0)"

messagebox("PenColors Info", t)