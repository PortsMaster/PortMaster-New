--PALETTE: Color Balance V3.0
--by Richard Fhager 

--(V3.0 Regional focus)

dofile("../libs/dawnbringer_lib.lua")
--> db.ColorBalance(r,g,b, rd,gd,bd, brikeep_flag, loosemode_flag)


FC = getforecolor()
r,g,b = getcolor(FC)
deg = db.format(db.getHUE(r,g,b,0) * 60,1)
if deg == 390 then 
 deg = "Grey"; 
  else deg = deg.."°"
end 


hue_center, bri_center, sat_center, txt,pre,hue_txt = -1,-1,-1,"(PenCol Hue="..deg..")","","HUE focus: 0-359°,360=Gry"
-- Get HSB values from pencolor
if getforecolor() == getbackcolor() then
  hue_center, bri_center, sat_center = db.getHSB(getcolor(getforecolor()))
  txt = "[Pen*: SAT focus="..math.floor(sat_center).."%]"
  pre = "*"
  hue_txt = "HUE focus: 0-359°"
end


OK,red,grn,blu,add,bri,loose,hue_center,bri_center, edit_width = inputbox("ColorBalance "..txt,
                         "  Red: -255..255", 0, -255,255,0,
                         "Green: -255..255", 0, -255,255,0,
                         " Blue: -255..255", 0, -255,255,0,
                         "1. Normal (additive)",    0,0,1,-1,
                         "2. Strict (bri preserv.)",  1,0,1,-1,
                         "3. Loose preservation",     0,0,1,-1,
                          pre..hue_txt, hue_center, -1,360,0, -- -1 = off, 360 = Gry, but that has no effect on Hue-shifting
                          pre.."BRI effect focus: 0-255",          bri_center, -1,255,0,
                          --"Saturation Edit: 0-100%", -1, -1,100,0,
                          "Focus Width %: 1-100", 33, 1,100,0
                         --"Pen-Color only (#"..FC..")", 0, 0,1,0         
);

if OK == true then

if bri_center == -1 and hue_center == -1 then sat_center = -1; end -- Don't let missing saturation turn on focus

penonly = 0
brikeep   = false;
loosemode = false; 
if   bri == 1 then brikeep = true; loosemode = false; end
if loose == 1 then brikeep = true; loosemode = true; end

if hue_center == 360 then sat_center = 0; end

  --rd = red*2.55
  --gd = grn*2.55
  --bd = blu*2.55
  rd = red
  gd = grn
  bd = blu

  for n = 0, 255, 1 do
    if penonly == 0 or n == FC then
     ro,go,bo = getcolor(n)
     rn,gn,bn = db.ColorBalance(ro,go,bo, rd,gd,bd, brikeep, loosemode)

     Amount = 1
     rf,gf,bf = db.editHSBregions(ro,go,bo,rn,gn,bn, Amount, hue_center, bri_center, sat_center, edit_width)

     setcolor(n,rf,gf,bf)

    end
  end

end -- ok
