--INFO: Palette Info V2.0
--by Richard Fhager 


dofile("../libs/dawnbringer_lib.lua")
--dofile("../libs/dawnColors.lua")
--> db.getHUE(r,g,b,greytolerance)
--> db.getSaturation(r,g,b)
--> db.getLightness(r,g,b)
--> db.getAppSaturation(r,g,b)
--> db.rgb2HEX(r,g,b,prefix)
--> db.getBrightness(r,g,b)
--> db.getAvgContrast(r,g,b)


t = ""

pal = db.fixPalette(db.makePalList(256))

rt,gt,bt,sat_app_tot,sat_abs_tot,sat_tru_tot,sat_pur_tot,sat_hsb_tot = 0,0,0,0,0,0,0,0
tcont = 0
tbri = 0
brimax = 0
brimin = 255
for n = 1, #pal, 1 do
  r,g,b = getcolor(pal[n][4])
  --sat_app_tot = sat_app_tot + db.getAppSaturation(r,g,b)         -- Hybrid (HSL + True) / 2
  --sat_abs_tot = sat_abs_tot + db.getSaturationAbs(r,g,b) * 100   -- Fraction between Gray and Max Saturation
  sat_pur_tot = sat_pur_tot + db.getPurity(r,g,b) * 100
  sat_hsb_tot = sat_hsb_tot + db.getSaturationHSV(r,g,b) * 100

  rt = rt + r
  gt = gt + g
  bt = bt + b
  tcont = tcont + db.getAvgContrast(r,g,b)
  bri = db.getBrightness(r,g,b)
  tbri  = tbri  + bri
  brimax = math.max(brimax,bri)
  brimin = math.min(brimin,bri)
end
avg_rgb = {rt/#pal, gt/#pal, bt/#pal} 
--sat_app = sat_app_tot / #pal
--sat_tru = sat_tru_tot / #pal

sat_pur = sat_pur_tot / #pal
sat_hsb = sat_hsb_tot / #pal

acont = tcont / #pal
abri  = tbri  / #pal
medianbri = (brimax + brimin) / 2

function format(v,p)
 return math.floor(v * 10^p) / 10^p
end



t = t.."Unique Colors: "..#pal
t = t.."\n\n"
t = t.."RGB avg.: "..format(avg_rgb[1],1)..", "..format(avg_rgb[2],1)..", "..format(avg_rgb[3],1)
t = t.."\n\n"
t = t.."Brightness avg.: "..format(abri,1).." ("..format(abri/2.56,1).."%)"
t = t.."\n\n"
t = t.."Brightness median: "..format(medianbri,1)

t = t.."\n\n"
t = t.."Contrast avg.: "..format(acont*100,1).."%"

t = t.."\n\n"

t = t.."Saturation avg.: "..format(sat_pur,2).."% (Purity)"
t = t.."\n________________ "..format(sat_hsb,2).."% (HSB/HSV)"

messagebox("Palette Statistics", t)