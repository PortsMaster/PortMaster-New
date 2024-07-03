--INFO: ColorInfo V2.2
--by Richard Fhager 


-- Load my function library (db)
-- dofile("dawnbringer_lib.lua")
dofile("../libs/dawnbringer_lib.lua")
--dofile("../libs/dawnColors.lua")
--> db.getHUE(r,g,b,greytolerance)
--> db.getSaturation(r,g,b)
--> db.getLightness(r,g,b)
--> db.getAppSaturation(r,g,b)
--> db.rgb2HEX(r,g,b,prefix)
--> db.getBrightness(r,g,b)
--> db.getAvgContrast(r,g,b)


colorDescription = dofile("../pfunctions/pfunc_DawnColors.lua")

t = ""
c = getforecolor()
r,g,b = getcolor(c)


function format(v,p)
 return math.floor(v * 10^p) / 10^p
end

hist = db.makeHistogram()
w, h = getpicturesize()

function findColor(c)
 for y = 0, h-1, 1 do
 for x = 0, w-1, 1 do
   if getpicturepixel(x,y) == c then return x,y; end
 end
 end
 return -1,-1
end

firstX,firstY = findColor(c)

-- HUE
-- 0-6
hue = db.getHUE(r,g,b, 0) * 60
h_i = "°"
if hue >= 360 then h_i = "Gry"; hue = -1; end

-- Saturation
sat = db.getSaturation(r,g,b)
sat_prc = sat / 2.55

sat_abs = db.getSaturationAbs(r,g,b) * 100 -- Absolute, fraction of distance gray-->full saturation

--app_sat = db.getAppSaturation(r,g,b) -- Mix between HSL and True
pur_sat = db.getPrimarity(r,g,b, 1, true)
hsv_sat = db.getSaturationHSV(r,g,b)
tru_sat = db.getTrueSaturationX(r,g,b) -- Distance from grayscale axis
rel_sat = db.getRealSaturation(r,g,b) -- (Abs*True)^0.5
-- Brightness (Dawn 3.0)
bri = db.getBrightness(r,g,b)
bri_prc = bri /2.55

-- Contrast (average channel)
con_prc = db.getAvgContrast(r,g,b) * 100

t = t.."COL: #"..c.." ["..r..","..g..","..b.."] ("..db.rgb2HEX(r,g,b,"#")..")"
t = t.."\n\n"
t = t.."HSL: ["..format(hue,1)..""..h_i..", "..format(sat_prc,1).."%, "..format(db.getLightness(r,g,b)/2.55,1).."%]"
t = t.."\n\n"
t = t.."Descript: "..colorDescription(r,g,b)
t = t.."\n\n"
t = t.."BRI: "..format(bri,2).." ("..format(bri_prc,1).."%) (perceptual)"
t = t.."\n\n"
--- t = t.."Saturations ---\n"
t = t.."SAT: Purity: "..format(pur_sat*100,1).."%, HSB: "..format(hsv_sat*100,2).."%"
--t = t.."Sat: "..format(pur_sat*100,1).."% (Purity), "..format(hsv_sat*100,2).."% (HSV)"
--t = t.."\nSat: "..format(sat_abs,2).."% (abs), "..format(tru_sat/2.55,2).."% (true)"
t = t.."\n.Abs distance from gray: "..format(sat_abs,2).."%"
t = t.."\n.Fraction of dist gray/max: "..format(tru_sat/2.55,2).."%"

--t = t.."\n\n"
--t = t.."Con: "..format(con_prc,2).."% (avg. ch. contrast)"
t = t.."\n\n"
if firstX > -1 then
 t = t.."First pix at: "..firstX..","..firstY.." [Count: "..hist[c+1].."]"
 else
 t = t.."Color is not used in image"
end


messagebox("Color Info", t)